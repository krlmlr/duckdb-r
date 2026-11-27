#include "cpp11/environment.hpp"
#include "duckdb/common/enum_util.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/settings.hpp"
#include "r_progress_bar_display.hpp"
#include "rapi.hpp"

#include <mutex>
#include <thread>
#include <vector>

// Avoid clash with TRUE and FALSE macros in older rtools
#undef TRUE
#undef FALSE

using namespace duckdb;

void duckdb::ConnDeleter(ConnWrapper *conn) {
	cpp11::warning("Connection is garbage-collected, use dbDisconnect() to avoid this.");
	delete conn;
}

// Closing the connection closes the results still open on it: each lets go of its prepared statement, its query
// result or its stream, and the latter two of the client context they hold, so the context, and the database
// instance it holds, go with the connection rather than living on in a result the driver knows nothing about
// (handbook/architecture/glue/objects/README.md). The R objects stay, and report that their connection has closed.
// Closing a result does not take it out of its set, so each loop is safe, and the sets die with the connection.
ConnWrapper::~ConnWrapper() {
	for (auto stmt : statements) {
		stmt->Close();
	}
	// A query result owns the stream it reads through and destroys it here, which takes that stream out of `streams`
	// before the loop below reaches it.
	for (auto result : query_results) {
		result->Close();
	}
	// A stream handed over may be released on another thread meanwhile: it waits for the lock,
	// and finds its connection gone.
	lock_guard<mutex> guard(StreamsLock());
	for (auto stream : streams) {
		stream->Close();
	}
	streams.clear();
}

mutex &duckdb::StreamsLock() {
	// Never destroyed: a stream may be released after static destruction at exit
	static auto lock = new mutex();
	return *lock;
}

// Objects kept with R_PreserveObject() whose owner was destroyed off R's thread, where R must not be called:
// the callbacks of progress displays, and the connections that Arrow streams keep reachable.
// The next entry point on R's thread releases them.
static std::mutex orphaned_objects_lock;
static std::vector<SEXP> orphaned_objects;

void duckdb::ReleaseOnRThread(SEXP object) {
	if (OnRThread()) {
		R_ReleaseObject(object);
		return;
	}
	std::lock_guard<std::mutex> guard(orphaned_objects_lock);
	orphaned_objects.push_back(object);
}

void duckdb::ReleaseOrphanedObjects() {
	// Reached from the progress display's constructor, which runs on whichever thread issues the query,
	// not always R's (rapi_query_off_r_thread()); the next entry point on R's thread releases them instead.
	if (!OnRThread()) {
		return;
	}
	std::vector<SEXP> objects;
	{
		std::lock_guard<std::mutex> guard(orphaned_objects_lock);
		objects.swap(orphaned_objects);
	}
	for (auto object : objects) {
		R_ReleaseObject(object);
	}
}

unique_ptr<ProgressBarDisplay> RProgressBarDisplay::Create() {
	return make_uniq<RProgressBarDisplay>();
}

void RProgressBarDisplay::Initialize() {
	// Reached from ClientContext::PendingPreparedStatementInternal(), which
	// constructs the ProgressBar -- and with it this display -- while it holds
	// the client context lock. Looking the callback up evaluates R code, and
	// with it a garbage collection.
	RCallbackScope callback_scope;

	cpp11::function getNamespace = RStrings::get().getNamespace_sym;
	cpp11::environment duckdb_namespace(getNamespace(RStrings::get().duckdb_str));
	cpp11::sexp get_progress_display(Rf_lang1(RStrings::get().get_progress_display_sym));
	auto progress_display = cpp11::safe[Rf_eval](get_progress_display, duckdb_namespace);

	if (Rf_isFunction(progress_display)) {
		R_PreserveObject(progress_display);
		progress_callback = progress_display;
	}
}

// The engine builds the display when a query starts, on the thread that issues it, which is usually R's.
RProgressBarDisplay::RProgressBarDisplay() : ProgressBarDisplay() {
	ReleaseOrphanedObjects();
	Initialize();
}

RProgressBarDisplay::~RProgressBarDisplay() {
	if (progress_callback == R_NilValue) {
		return;
	}
	ReleaseOnRThread(progress_callback);
}

void RProgressBarDisplay::Update(double percentage) {
	// The engine updates the display from whichever thread fetches a streaming result,
	// a thread of arrow's pool among them, and R runs on its own thread only.
	if (progress_callback == R_NilValue || !OnRThread()) {
		return;
	}

	// Called from the executor while the query that drives it holds the lock.
	RCallbackScope callback_scope;

	try {
		cpp11::sexp call = Rf_lang2(progress_callback, Rf_ScalarReal(percentage));
		cpp11::safe[Rf_eval](call, R_BaseEnv);
	} catch (std::exception &e) {
		// Ignore progress bar error
	}
}

void RProgressBarDisplay::Finish() {
	Update(100);
}

static void SetDefaultConfigArguments(ClientContext &context) {
	auto &config = ClientConfig::GetConfig(context);
	// Set the function used to create the display for the progress bar
	config.display_create_func = RProgressBarDisplay::Create;
	// Generic settings since duckdb/duckdb#28571; their callbacks refuse a bar the system disabled.
	if (!config.system_progress_bar_disable_reason) {
		Settings::Set<EnableProgressBarSetting>(context, SetScope::SESSION, Value::BOOLEAN(true));
		Settings::Set<ProgressBarTimeSetting>(context, SetScope::SESSION, Value::BIGINT(0));
	}
}

[[cpp11::register]] duckdb::conn_eptr_t rapi_connect(duckdb::db_eptr_t dual, duckdb::ConvertOpts convert_opts) {
	if (!dual || !dual.get()) {
		rapi_error_with_context("rapi_connect", "Invalid database reference");
	}
	auto db = dual->get();
	if (!db || !db->db) {
		rapi_error_with_context("rapi_connect", "Database already closed");
	}

	auto conn_wrapper = make_uniq<ConnWrapper>(std::move(db), std::move(convert_opts));

	// Set progress display config
	auto &client_context = *conn_wrapper->conn->context;
	SetDefaultConfigArguments(client_context);

	// The connection now holds a reference to the database.
	// This reference is released when the connection is closed.
	// From the R side, the database pointer will remain valid
	// as long as at least one connection to that database is open.
	dual->unlock();

	return conn_eptr_t(conn_wrapper.release());
}

// Closes the connection, and with it the results still open on it (~ConnWrapper), and says how many there were:
// DBI asks for a warning when a connection closes with results uncleared (dbDisconnect__duckdb_connection.R).
// A stream handed over to nanoarrow or arrow and not read to its end or to an error counts on its own,
// since clearing its result does not release it: dbGetQueryArrow() clears the result as it returns the stream.
[[cpp11::register]] int rapi_disconnect(duckdb::conn_eptr_t conn) {
	// An object parked during the last R callback holds its client context, and with it the database:
	// destroy it before letting go of the connection, or the file stays open (#2934).
	// A no-op inside a callback, as everywhere: a finalizer may disconnect there.
	RCallbackScope::Drain();
	ReleaseOrphanedObjects();
	auto conn_wrapper = conn.release();
	if (!conn_wrapper) {
		return 0;
	}
	auto open_results = static_cast<int>(conn_wrapper->statements.size());
	{
		lock_guard<mutex> guard(StreamsLock());
		for (auto stream : conn_wrapper->streams) {
			if (stream->handed_over && !stream->ended) {
				open_results++;
			}
		}
	}
	delete conn_wrapper;
	return open_results;
}

// Whether a transaction begun by BEGIN is open: a statement's own transaction,
// and the one a streaming result holds, are not.
[[cpp11::register]] bool rapi_connection_in_transaction(duckdb::conn_eptr_t conn) {
	if (!conn || !conn.get() || !conn->conn) {
		rapi_error_with_context("rapi_connection_in_transaction", "Invalid connection");
	}
	return !conn->conn->IsAutoCommit();
}

// Test-only, unexported: runs a query on a thread of its own while R's thread only waits for it,
// so the query binds, and runs, off R's thread every time (#2962). Returns the error message, or NA.
[[cpp11::register]] SEXP rapi_query_off_r_thread(duckdb::conn_eptr_t conn, std::string sql) {
	if (!conn || !conn.get() || !conn->conn) {
		rapi_error_with_context("rapi_query_off_r_thread", "Invalid connection");
	}
	auto &connection = *conn->conn;
	bool failed = false;
	string message;
	std::thread worker([&]() {
		try {
			auto result = connection.Query(sql);
			if (result->HasError()) {
				failed = true;
				message = result->GetError();
			}
		} catch (std::exception &ex) {
			failed = true;
			message = ErrorData(ex).Message();
		} catch (...) {
			// An exception escaping a std::thread would terminate R
			failed = true;
			message = "unknown error";
		}
	});
	worker.join();
	if (!failed) {
		return Rf_ScalarString(NA_STRING);
	}
	return Rf_mkString(message.c_str());
}

// Replaces the policy that decides which errors abort the open transaction,
// and returns the one it replaced, so that the caller can put it back as it was.
// Set directly, as BEGIN sets it, rather than through SET, which a locked
// configuration refuses.
[[cpp11::register]] std::string rapi_connection_set_invalidation_policy(duckdb::conn_eptr_t conn, std::string policy) {
	if (!conn || !conn.get() || !conn->conn) {
		rapi_error_with_context("rapi_connection_set_invalidation_policy", "Invalid connection");
	}
	auto &transaction = conn->conn->context->transaction;
	auto previous = EnumUtil::ToString(transaction.GetInvalidationPolicy());
	transaction.SetInvalidationPolicy(EnumUtil::FromString<TransactionInvalidationPolicy>(policy));
	return previous;
}

[[cpp11::register]] bool rapi_connection_valid(duckdb::conn_eptr_t conn) {
	// Check connection validity without acquiring ClientContext locks
	// This avoids the "ScopedInterruptHandler already active" issue when
	// called from progress bar handlers or other contexts that already
	// have interrupt protection
	if (!conn || !conn.get()) {
		return false;
	}

	auto conn_wrapper = conn.get();
	if (!conn_wrapper) {
		return false;
	}

	// Check if the connection object exists
	if (!conn_wrapper->conn) {
		return false;
	}

	// Check if the database wrapper is still valid
	if (!conn_wrapper->db || !conn_wrapper->db->db) {
		return false;
	}

	// All checks passed - connection appears valid
	return true;
}
