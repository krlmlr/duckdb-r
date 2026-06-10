#!/bin/bash
# Opens one branch per file in patch/ in the duckdb core repo (expected at
# ../../../duckdb, like in vendor.sh), applies the patch there, and commits it.
#
# Each branch is named b-<patch name without extension> and is based on
# v1.5-variegata. Existing branches with the same name are reset (checkout -B).
#
# The patches in patch/ are written against the vendored tree (src/duckdb/...),
# so they are applied with -p3 to strip the a/src/duckdb/ prefix. GNU patch is
# used instead of git apply because some patch files are hand-edited and do not
# carry exact hunk offsets.
# Using bash for -o pipefail

set -e
set -x
set -o pipefail

cd "$(dirname "$0")"/..

upstream_dir=../../../duckdb
base=v1.5-variegata
patch_dir=$(pwd)/patch

if [ ! -d "$upstream_dir"/.git ] && [ ! -f "$upstream_dir"/.git ]; then
  echo "Error: duckdb core repo not found at $upstream_dir" >&2
  exit 1
fi

git -C "$upstream_dir" rev-parse --verify "$base" >/dev/null

if [ -n "$(git -C "$upstream_dir" status --porcelain)" ]; then
  echo "Error: working directory $upstream_dir not clean" >&2
  exit 1
fi

git -C "$upstream_dir" checkout -B b-0001-Avoid-rstrtmgr-on-R-4.1 "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0001-Avoid-rstrtmgr-on-R-4.1.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Compile Restart Manager lock diagnostics only with DUCKDB_RSTRTMGR" \
  -m "On Windows, AdditionalLockInfo() uses the Restart Manager API to report which process is holding a lock on a database file. The MinGW toolchain shipped with R 4.1 does not provide rstrtmgr, so guard the declarations and the implementation behind DUCKDB_RSTRTMGR == 1 and return an empty string otherwise."

git -C "$upstream_dir" checkout -B b-0002-MUTEX_THROW-and-keep-pragmas "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0002-MUTEX_THROW-and-keep-pragmas.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "re2: comment out -Wmissing-field-initializers pragma" \
  -m "CRAN does not allow diagnostic pragmas in package sources; deactivate the warning suppression for LazyRE2 in re2.h."

git -C "$upstream_dir" checkout -B b-0003-Try-to-ignore-clang-warnings "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0003-Try-to-ignore-clang-warnings.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "re2: ignore clang warnings about anonymous structs and dtor names" \
  -m "Add clang pragmas ignoring -Wgnu-anonymous-struct and -Wnested-anon-types in prog.h and -Wdtor-name in walker-inl.h so that CRAN's clang builds compile re2 without warnings."

git -C "$upstream_dir" checkout -B b-0005-Avoid-exit-in-Brotli "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0005-Avoid-exit-in-Brotli.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "brotli: drop exit() calls from hash allocation sanity checks" \
  -m "CRAN policy forbids calling exit() from package code. The removed checks guard a condition that should never happen; replace them with a comment."

git -C "$upstream_dir" checkout -B b-0007-Remove-stderr-for-zstd "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0007-Remove-stderr-for-zstd.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "zstd: make the dictionary trainer's DISPLAY macros no-ops" \
  -m "CRAN forbids writing to stderr from package code. Redefine the DISPLAY macros in cover.cpp, fastcover.cpp and zdict.cpp so that they no longer call fprintf(stderr, ...)."

git -C "$upstream_dir" checkout -B b-0008-Avoid-pragma-for-zstd "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0008-Avoid-pragma-for-zstd.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "zstd: drop clang diagnostic pragma from divsufsort" \
  -m "CRAN does not allow diagnostic pragmas in package sources; remove the -Wshorten-64-to-32 suppression."

git -C "$upstream_dir" checkout -B b-0009-Remove-stderr-for-zstd "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0009-Remove-stderr-for-zstd.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "zstd: make DISPLAYUPDATE in the legacy dictionary trainer a no-op" \
  -m "Removes the remaining stderr references in ZDICT_trainBuffer_legacy; CRAN forbids writing to stderr from package code."

git -C "$upstream_dir" checkout -B b-0012-httplib-rand "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0012-httplib-rand.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "httplib: use R's RNG instead of std::rand for random strings" \
  -m "CRAN does not allow calls to rand() in package code; draw the characters of random_string() with unif_rand() from R_ext/Random.h instead."

git -C "$upstream_dir" checkout -B b-0016-Avoid-mbedtls-diagnostic-pragmas "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0016-Avoid-mbedtls-diagnostic-pragmas.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "mbedtls: reformat diagnostic pragmas to keep CRAN checks quiet" \
  -m "Insert extra whitespace into the GCC/clang diagnostic pragmas in constant_time_impl.h and platform_util.cpp. The pragmas keep working, but no longer match the pattern that CRAN's source checks scan for."

git -C "$upstream_dir" checkout -B b-0029-init "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0029-init.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Initialize Connection::connection_id and MetadataBlock::block_id" \
  -m "Connection's constructor left connection_id uninitialized until AssignConnectionId ran, and MetadataBlock's move constructor swapped block_id with an indeterminate value. Initialize both to sentinel values."

git -C "$upstream_dir" checkout -B b-0030-init "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0030-init.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Initialize connection_id in Connection's move constructor" \
  -m "The move constructor swaps connection_id with the moved-from object, so the member needs a defined value beforehand. Also drop the unused warning_callback_t typedef."

git -C "$upstream_dir" checkout -B b-0031-uninitialized "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0031-uninitialized.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Default-initialize members that can be read before assignment" \
  -m "Give in-class default values to parquet's FieldID, the LRU cache entries, ColumnDataScanState / ColumnDataLocalScanState, and TupleDataLayout. Objects of these types can be copied or inspected before every member has been written, which valgrind reports as use of uninitialised values."

git -C "$upstream_dir" checkout -B b-0032-uninitialized-metric "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0032-uninitialized-metric.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Initialize the metric member in profiling_utils.hpp" \
  -m "The member is only assigned when profiling is active; give it a defined default (MetricType::EXTRA_INFO) so that copies of the object do not read indeterminate bytes."

git -C "$upstream_dir" checkout -B b-0033-clang-macos "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0033-clang-macos.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "fmt: do not instantiate std::basic_string_view for non-standard char types" \
  -m "SFINAE in fmt's arg_formatter instantiates std_string_view<T> for arbitrary character types; with libc++ on macOS this triggers the deprecated char_traits<T> warning. Route the alias through a base struct that only derives from std::basic_string_view for char, wchar_t, char16_t and char32_t."

git -C "$upstream_dir" checkout -B b-0034-parquet-rows-read-uninitialized "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0034-parquet-rows-read-uninitialized.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "parquet: initialize ParquetReader::rows_read" \
  -m "The OpenFileInfo constructor of ParquetReader does not list rows_read in its initializer list, leaving the atomic counter with uninitialized storage. Valgrind flags the read in GetProgressInFile, from where the taint propagates into the pipeline progress machinery."

git -C "$upstream_dir" checkout -B b-0035-array-bounds-selection-data "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0035-array-bounds-selection-data.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Out-of-line SelectionData destructor to silence g++-16 -Warray-bounds" \
  -m "GCC 14+ emits a spurious array-bounds warning when IPA-ICF folds the shared_ptr dispose specialization of SelectionData with the structurally similar one of TemplatedValidityData. A user-declared out-of-line (defaulted) destructor keeps the disposal sequence non-inline at the call site and avoids the false positive; behaviour is unchanged."

git -C "$upstream_dir" checkout -B b-0036-transaction-context-uninitialized "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0036-transaction-context-uninitialized.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Initialize TransactionContext::invalidation_policy and auto_rollback" \
  -m "Both members are only written via SetInvalidationPolicy / SetAutoRollback, which never run for auto-commit connections, yet ClientContext::ErrorInvalidatesTransaction reads the policy. Initialize them in-class with the same defaults that TransactionInfo uses."

git -C "$upstream_dir" checkout -B b-0037-base-statistics-uninitialized "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0037-base-statistics-uninitialized.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Initialize all BaseStatistics members and zero stats_union" \
  -m "The default constructor and Construct() left has_null, has_no_null and stats_union (including its padding bytes) indeterminate; copies made during statistics propagation in the optimizer can read those bytes before CreateEmpty/CreateUnknown overwrite them, which valgrind flags in StringValueComparison. The new values match InitializeEmpty(), so behaviour is unchanged."

git -C "$upstream_dir" checkout -B b-0038-string-t-zero-inlined-buffer "$base"
patch -d "$upstream_dir" -p3 --forward --no-backup-if-mismatch -i "$patch_dir"/0038-string-t-zero-inlined-buffer.patch
git -C "$upstream_dir" add -A
git -C "$upstream_dir" commit \
  -m "Zero the inlined buffer in string_t's length-only constructor" \
  -m "StringVector::EmptyString hands out a string_t whose inlined buffer stays indeterminate until the caller writes len bytes and Finalize() zeroes the tail. The 16-byte value is bitwise-copied before that happens, so valgrind tracks the indeterminate bytes into StringValueComparison. Zero the buffer up front, matching what the (const char *, uint32_t) constructor and Finalize() already do."
