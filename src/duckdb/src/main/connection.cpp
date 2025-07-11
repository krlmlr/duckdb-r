#include "duckdb/main/connection.hpp"

#include "duckdb/common/types/column/column_data_collection.hpp"
#include "duckdb/function/table/read_csv.hpp"
#include "duckdb/main/appender.hpp"
#include "duckdb/main/client_context.hpp"
#include "duckdb/main/connection_manager.hpp"
#include "duckdb/main/database.hpp"
#include "duckdb/main/query_profiler.hpp"
#include "duckdb/main/relation/query_relation.hpp"
#include "duckdb/main/relation/read_csv_relation.hpp"
#include "duckdb/main/relation/table_function_relation.hpp"
#include "duckdb/main/relation/table_relation.hpp"
#include "duckdb/main/relation/value_relation.hpp"
#include "duckdb/main/relation/view_relation.hpp"
#include "duckdb/parser/parser.hpp"
#include "duckdb/planner/logical_operator.hpp"

namespace duckdb {

Connection::Connection(DatabaseInstance &database)
    : context(make_shared_ptr<ClientContext>(database.shared_from_this())), warning_cb(nullptr) {
	auto &connection_manager = ConnectionManager::Get(database);
	connection_manager.AddConnection(*context);
	connection_manager.AssignConnectionId(*this);

#ifdef DEBUG
	EnableProfiling();
	context->config.emit_profiler_output = false;
#endif
}

Connection::Connection(DuckDB &database) : Connection(*database.instance) {
	// Initialization of warning_cb happens in the other constructor
}

Connection::Connection(Connection &&other) noexcept : warning_cb(nullptr) {
	std::swap(context, other.context);
	std::swap(warning_cb, other.warning_cb);
}

Connection &Connection::operator=(Connection &&other) noexcept {
	std::swap(context, other.context);
	std::swap(warning_cb, other.warning_cb);
	return *this;
}

Connection::~Connection() {
	if (!context) {
		return;
	}
	ConnectionManager::Get(*context->db).RemoveConnection(*context);
}

string Connection::GetProfilingInformation(ProfilerPrintFormat format) {
	auto &profiler = QueryProfiler::Get(*context);
	return profiler.ToString(format);
}

optional_ptr<ProfilingNode> Connection::GetProfilingTree() {
	auto &client_config = ClientConfig::GetConfig(*context);
	auto enable_profiler = client_config.enable_profiler;

	if (!enable_profiler) {
		throw Exception(ExceptionType::SETTINGS, "Profiling is not enabled for this connection");
	}
	auto &profiler = QueryProfiler::Get(*context);
	return profiler.GetRoot();
}

void Connection::Interrupt() {
	context->Interrupt();
}

double Connection::GetQueryProgress() {
	return context->GetQueryProgress().GetPercentage();
}

void Connection::EnableProfiling() {
	context->EnableProfiling();
}

void Connection::DisableProfiling() {
	context->DisableProfiling();
}

void Connection::EnableQueryVerification() {
	ClientConfig::GetConfig(*context).query_verification_enabled = true;
}

void Connection::DisableQueryVerification() {
	ClientConfig::GetConfig(*context).query_verification_enabled = false;
}

void Connection::ForceParallelism() {
	ClientConfig::GetConfig(*context).verify_parallelism = true;
}

unique_ptr<QueryResult> Connection::SendQuery(const string &query) {
	return context->Query(query, true);
}

unique_ptr<MaterializedQueryResult> Connection::Query(const string &query) {
	auto result = context->Query(query, false);
	D_ASSERT(result->type == QueryResultType::MATERIALIZED_RESULT);
	return unique_ptr_cast<QueryResult, MaterializedQueryResult>(std::move(result));
}

unique_ptr<MaterializedQueryResult> Connection::Query(unique_ptr<SQLStatement> statement) {
	auto result = context->Query(std::move(statement), false);
	D_ASSERT(result->type == QueryResultType::MATERIALIZED_RESULT);
	return unique_ptr_cast<QueryResult, MaterializedQueryResult>(std::move(result));
}

unique_ptr<PendingQueryResult> Connection::PendingQuery(const string &query, bool allow_stream_result) {
	return context->PendingQuery(query, allow_stream_result);
}

unique_ptr<PendingQueryResult> Connection::PendingQuery(unique_ptr<SQLStatement> statement, bool allow_stream_result) {
	return context->PendingQuery(std::move(statement), allow_stream_result);
}

unique_ptr<PendingQueryResult> Connection::PendingQuery(const string &query,
                                                        case_insensitive_map_t<BoundParameterData> &named_values,
                                                        bool allow_stream_result) {
	return context->PendingQuery(query, named_values, allow_stream_result);
}

unique_ptr<PendingQueryResult> Connection::PendingQuery(unique_ptr<SQLStatement> statement,
                                                        case_insensitive_map_t<BoundParameterData> &named_values,
                                                        bool allow_stream_result) {
	return context->PendingQuery(std::move(statement), named_values, allow_stream_result);
}

static case_insensitive_map_t<BoundParameterData> ConvertParamListToMap(vector<Value> &param_list) {
	case_insensitive_map_t<BoundParameterData> named_values;
	for (idx_t i = 0; i < param_list.size(); i++) {
		auto &val = param_list[i];
		named_values[std::to_string(i + 1)] = BoundParameterData(val);
	}
	return named_values;
}

unique_ptr<PendingQueryResult> Connection::PendingQuery(const string &query, vector<Value> &values,
                                                        bool allow_stream_result) {
	auto named_params = ConvertParamListToMap(values);
	return context->PendingQuery(query, named_params, allow_stream_result);
}

unique_ptr<PendingQueryResult> Connection::PendingQuery(unique_ptr<SQLStatement> statement, vector<Value> &values,
                                                        bool allow_stream_result) {
	auto named_params = ConvertParamListToMap(values);
	return context->PendingQuery(std::move(statement), named_params, allow_stream_result);
}

unique_ptr<PreparedStatement> Connection::Prepare(const string &query) {
	return context->Prepare(query);
}

unique_ptr<PreparedStatement> Connection::Prepare(unique_ptr<SQLStatement> statement) {
	return context->Prepare(std::move(statement));
}

unique_ptr<QueryResult> Connection::QueryParamsRecursive(const string &query, vector<Value> &values) {
	auto named_params = ConvertParamListToMap(values);
	auto pending = PendingQuery(query, named_params, false);
	if (pending->HasError()) {
		return make_uniq<MaterializedQueryResult>(pending->GetErrorObject());
	}
	return pending->Execute();
}

unique_ptr<TableDescription> Connection::TableInfo(const string &database_name, const string &schema_name,
                                                   const string &table_name) {
	return context->TableInfo(database_name, schema_name, table_name);
}

unique_ptr<TableDescription> Connection::TableInfo(const string &schema_name, const string &table_name) {
	return TableInfo(INVALID_CATALOG, schema_name, table_name);
}

unique_ptr<TableDescription> Connection::TableInfo(const string &table_name) {
	return TableInfo(INVALID_CATALOG, DEFAULT_SCHEMA, table_name);
}

vector<unique_ptr<SQLStatement>> Connection::ExtractStatements(const string &query) {
	return context->ParseStatements(query);
}

unique_ptr<LogicalOperator> Connection::ExtractPlan(const string &query) {
	return context->ExtractPlan(query);
}

void Connection::Append(TableDescription &description, DataChunk &chunk) {
	if (chunk.size() == 0) {
		return;
	}
	ColumnDataCollection collection(Allocator::Get(*context), chunk.GetTypes());
	collection.Append(chunk);
	Append(description, collection);
}

void Connection::Append(TableDescription &description, ColumnDataCollection &collection) {
	context->Append(description, collection);
}

shared_ptr<Relation> Connection::Table(const string &table_name) {
	return Table(DEFAULT_SCHEMA, table_name);
}

shared_ptr<Relation> Connection::Table(const string &schema_name, const string &table_name) {
	auto table_info = TableInfo(INVALID_CATALOG, schema_name, table_name);
	if (!table_info) {
		throw CatalogException("Table %s does not exist!", ParseInfo::QualifierToString("", schema_name, table_name));
	}
	return make_shared_ptr<TableRelation>(context, std::move(table_info));
}

shared_ptr<Relation> Connection::Table(const string &catalog_name, const string &schema_name,
                                       const string &table_name) {
	unique_ptr<TableDescription> table_info;
	do {
		table_info = TableInfo(catalog_name, schema_name, table_name);
		if (table_info) {
			break;
		}

		if (catalog_name.empty() && !schema_name.empty()) {
			table_info = TableInfo(schema_name, DEFAULT_SCHEMA, table_name);
		}
	} while (false);

	if (!table_info) {
		throw CatalogException("Table %s does not exist!",
		                       ParseInfo::QualifierToString(catalog_name, schema_name, table_name));
	}
	return make_shared_ptr<TableRelation>(context, std::move(table_info));
}

shared_ptr<Relation> Connection::View(const string &tname) {
	return View(DEFAULT_SCHEMA, tname);
}

shared_ptr<Relation> Connection::View(const string &schema_name, const string &table_name) {
	return make_shared_ptr<ViewRelation>(context, schema_name, table_name);
}

shared_ptr<Relation> Connection::TableFunction(const string &fname) {
	vector<Value> values;
	named_parameter_map_t named_parameters;
	return TableFunction(fname, values, named_parameters);
}

shared_ptr<Relation> Connection::TableFunction(const string &fname, const vector<Value> &values,
                                               const named_parameter_map_t &named_parameters) {
	return make_shared_ptr<TableFunctionRelation>(context, fname, values, named_parameters);
}

shared_ptr<Relation> Connection::TableFunction(const string &fname, const vector<Value> &values) {
	return make_shared_ptr<TableFunctionRelation>(context, fname, values);
}

shared_ptr<Relation> Connection::Values(const vector<vector<Value>> &values) {
	vector<string> column_names;
	return Values(values, column_names);
}

shared_ptr<Relation> Connection::Values(vector<vector<unique_ptr<ParsedExpression>>> &&expressions) {
	vector<string> column_names;
	return make_shared_ptr<ValueRelation>(context, std::move(expressions), column_names);
}

shared_ptr<Relation> Connection::Values(const vector<vector<Value>> &values, const vector<string> &column_names,
                                        const string &alias) {
	return make_shared_ptr<ValueRelation>(context, values, column_names, alias);
}

shared_ptr<Relation> Connection::Values(const string &values) {
	vector<string> column_names;
	return Values(values, column_names);
}

shared_ptr<Relation> Connection::Values(const string &values, const vector<string> &column_names, const string &alias) {
	return make_shared_ptr<ValueRelation>(context, values, column_names, alias);
}

shared_ptr<Relation> Connection::ReadCSV(const string &csv_file) {
	named_parameter_map_t options;
	return ReadCSV(csv_file, std::move(options));
}

shared_ptr<Relation> Connection::ReadCSV(const vector<string> &csv_input, named_parameter_map_t &&options) {
	return make_shared_ptr<ReadCSVRelation>(context, csv_input, std::move(options));
}

shared_ptr<Relation> Connection::ReadCSV(const string &csv_input, named_parameter_map_t &&options) {
	vector<string> csv_files = {csv_input};
	return ReadCSV(csv_files, std::move(options));
}

shared_ptr<Relation> Connection::ReadCSV(const string &csv_file, const vector<string> &columns) {
	// parse columns
	named_parameter_map_t options;
	child_list_t<Value> column_list;
	for (auto &column : columns) {
		auto col_list = Parser::ParseColumnList(column, context->GetParserOptions());
		if (col_list.LogicalColumnCount() != 1) {
			throw ParserException("Expected a single column definition");
		}
		auto &col_def = col_list.GetColumnMutable(LogicalIndex(0));
		column_list.push_back({col_def.GetName(), col_def.GetType().ToString()});
	}
	vector<string> files {csv_file};
	return make_shared_ptr<ReadCSVRelation>(context, files, std::move(options));
}

shared_ptr<Relation> Connection::ReadParquet(const string &parquet_file, bool binary_as_string) {
	vector<Value> params;
	params.emplace_back(parquet_file);
	named_parameter_map_t named_parameters({{"binary_as_string", Value::BOOLEAN(binary_as_string)}});
	return TableFunction("parquet_scan", params, named_parameters)->Alias(parquet_file);
}

unordered_set<string> Connection::GetTableNames(const string &query, const bool qualified) {
	return context->GetTableNames(query, qualified);
}

shared_ptr<Relation> Connection::RelationFromQuery(const string &query, const string &alias, const string &error) {
	return RelationFromQuery(QueryRelation::ParseStatement(*context, query, error), alias);
}

shared_ptr<Relation> Connection::RelationFromQuery(unique_ptr<SelectStatement> select_stmt, const string &alias,
                                                   const string &query_p) {
	return make_shared_ptr<QueryRelation>(context, std::move(select_stmt), alias, query_p);
}

void Connection::BeginTransaction() {
	auto result = Query("BEGIN TRANSACTION");
	if (result->HasError()) {
		result->ThrowError();
	}
}

void Connection::Commit() {
	auto result = Query("COMMIT");
	if (result->HasError()) {
		result->ThrowError();
	}
}

void Connection::Rollback() {
	auto result = Query("ROLLBACK");
	if (result->HasError()) {
		result->ThrowError();
	}
}

void Connection::SetAutoCommit(bool auto_commit) {
	context->transaction.SetAutoCommit(auto_commit);
}

bool Connection::IsAutoCommit() {
	return context->transaction.IsAutoCommit();
}
bool Connection::HasActiveTransaction() {
	return context->transaction.HasActiveTransaction();
}

} // namespace duckdb
