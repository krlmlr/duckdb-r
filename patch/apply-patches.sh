#!/bin/bash

set -e

# Navigate to the DuckDB repository
cd ~/git/duckdb

# Patch 0001: Avoid rstrtmgr on R 4.1
git checkout main
git pull
git checkout -b r-patch-0001-avoid-rstrtmgr
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0001-Avoid-rstrtmgr-on-R-4.1.patch
git add -A
git commit -m "Avoid rstrtmgr on R 4.1" -m "This patch conditionally disables the Windows Restart Manager functionality on R 4.1 by guarding the code with DUCKDB_RSTRTMGR preprocessor directives.

The Windows Restart Manager APIs are not available or compatible with R 4.1's MinGW toolchain, causing compilation failures. This change allows the code to compile on R 4.1 while maintaining the functionality on newer versions.

Changes:
- Wrapped GetPhysicallyInstalledSystemMemory and QueryFullProcessImageNameW declarations in #if DUCKDB_RSTRTMGR == 1
- Guarded AdditionalLockInfo implementation to return empty string when DUCKDB_RSTRTMGR is disabled
- Maintains backward compatibility for systems where Restart Manager is available

This is needed for CRAN compatibility with R 4.1."
git push -u origin HEAD
gh pr create --draft --title "Avoid rstrtmgr on R 4.1" --body "This patch conditionally disables the Windows Restart Manager functionality on R 4.1 by guarding the code with DUCKDB_RSTRTMGR preprocessor directives.

The Windows Restart Manager APIs are not available or compatible with R 4.1's MinGW toolchain, causing compilation failures. This change allows the code to compile on R 4.1 while maintaining the functionality on newer versions.

**Changes:**
- Wrapped GetPhysicallyInstalledSystemMemory and QueryFullProcessImageNameW declarations in \`#if DUCKDB_RSTRTMGR == 1\`
- Guarded AdditionalLockInfo implementation to return empty string when DUCKDB_RSTRTMGR is disabled
- Maintains backward compatibility for systems where Restart Manager is available

This is needed for CRAN compatibility with R 4.1.

**Files changed:**
- \`src/common/local_file_system.cpp\`"

# Patch 0002: MUTEX_THROW and keep pragmas
git checkout main
git pull
git checkout -b r-patch-0002-mutex-throw-pragmas
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0002-MUTEX_THROW-and-keep-pragmas.patch
git add -A
git commit -m "MUTEX_THROW and keep pragmas" -m "This patch modifies RE2 regex library pragmas to avoid CRAN warnings about diagnostic pragmas.

CRAN's compiler checks flag certain GCC diagnostic pragmas as problematic. This change comments out the -Wmissing-field-initializers pragma in RE2 to avoid these warnings while maintaining code functionality.

Changes:
- Commented out '#pragma GCC diagnostic ignored \"-Wmissing-field-initializers\"' in re2/re2.h

This is needed for CRAN compatibility."
git push -u origin HEAD
gh pr create --draft --title "MUTEX_THROW and keep pragmas" --body "This patch modifies RE2 regex library pragmas to avoid CRAN warnings about diagnostic pragmas.

CRAN's compiler checks flag certain GCC diagnostic pragmas as problematic. This change comments out the \`-Wmissing-field-initializers\` pragma in RE2 to avoid these warnings while maintaining code functionality.

**Changes:**
- Commented out \`#pragma GCC diagnostic ignored \"-Wmissing-field-initializers\"\` in \`re2/re2.h\`

This is needed for CRAN compatibility.

**Files changed:**
- \`third_party/re2/re2/re2.h\`
- \`third_party/re2/util/mutex.h\`"

# Patch 0003: Try to ignore clang warnings
git checkout main
git pull
git checkout -b r-patch-0003-ignore-clang-warnings
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0003-Try-to-ignore-clang-warnings.patch
git add -A
git commit -m "Try to ignore clang warnings" -m "This patch adds clang diagnostic pragmas to suppress specific warnings in the RE2 regex library.

CRAN's clang checks flag warnings for GNU anonymous structs, nested anonymous types, and destructor naming conventions. These pragmas suppress these specific warnings without affecting the functionality.

Changes:
- Added pragmas to ignore -Wgnu-anonymous-struct and -Wnested-anon-types in re2/prog.h
- Added pragma to ignore -Wdtor-name in re2/walker-inl.h

This is needed for CRAN compatibility with clang."
git push -u origin HEAD
gh pr create --draft --title "Try to ignore clang warnings" --body "This patch adds clang diagnostic pragmas to suppress specific warnings in the RE2 regex library.

CRAN's clang checks flag warnings for GNU anonymous structs, nested anonymous types, and destructor naming conventions. These pragmas suppress these specific warnings without affecting the functionality.

**Changes:**
- Added pragmas to ignore \`-Wgnu-anonymous-struct\` and \`-Wnested-anon-types\` in \`re2/prog.h\`
- Added pragma to ignore \`-Wdtor-name\` in \`re2/walker-inl.h\`

This is needed for CRAN compatibility with clang.

**Files changed:**
- \`third_party/re2/re2/prog.h\`
- \`third_party/re2/re2/walker-inl.h\`"

# Patch 0004: Patch Relation::Query for #138
git checkout main
git pull
git checkout -b r-patch-0004-relation-query
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0004-Patch-Relation-Query-for-138.patch
git add -A
git commit -m "Patch Relation::Query() for #138" -m "This patch modifies the Relation::Query() method to use temporary views for read-only relations.

The previous implementation would create permanent views which could cause issues with read-only database connections. This change makes the view creation depend on whether the relation is read-only, creating temporary views in that case.

Changes:
- Modified Relation::Query(name, sql) to use replace=true and temp=IsReadOnly()
- CreateView is now called with appropriate flags for read-only relations

This fixes issue #138 in duckdb-r.

Reference: https://github.com/duckdb/duckdb-r/issues/138"
git push -u origin HEAD
gh pr create --draft --title "Patch Relation::Query() for #138" --body "This patch modifies the \`Relation::Query()\` method to use temporary views for read-only relations.

The previous implementation would create permanent views which could cause issues with read-only database connections. This change makes the view creation depend on whether the relation is read-only, creating temporary views in that case.

**Changes:**
- Modified \`Relation::Query(name, sql)\` to use \`replace=true\` and \`temp=IsReadOnly()\`
- \`CreateView\` is now called with appropriate flags for read-only relations

This fixes issue duckdb/duckdb-r#138.

**Files changed:**
- \`src/main/relation.cpp\`

**Reference:**
https://github.com/duckdb/duckdb-r/issues/138"

# Patch 0005: Avoid exit in Brotli
git checkout main
git pull
git checkout -b r-patch-0005-avoid-exit-brotli
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0005-Avoid-exit-in-Brotli.patch
git add -A
git commit -m "Avoid exit in Brotli" -m "This patch removes exit() calls from the Brotli compression library.

CRAN policies strictly prohibit packages from calling exit() or abort() as it terminates the R session. This change removes exit(EXIT_FAILURE) calls that were used for \"should never happen\" error conditions in the Brotli hash memory allocation code.

Changes:
- Removed exit(EXIT_FAILURE) calls from three HashMemAllocInBytes implementations
- Replaced with comments indicating the checks can't call exit() on CRAN
- The original comment \"Should never happen\" remains to document the intent

This is required for CRAN compliance."
git push -u origin HEAD
gh pr create --draft --title "Avoid exit in Brotli" --body "This patch removes \`exit()\` calls from the Brotli compression library.

CRAN policies strictly prohibit packages from calling \`exit()\` or \`abort()\` as it terminates the R session. This change removes \`exit(EXIT_FAILURE)\` calls that were used for \"should never happen\" error conditions in the Brotli hash memory allocation code.

**Changes:**
- Removed \`exit(EXIT_FAILURE)\` calls from three \`HashMemAllocInBytes\` implementations
- Replaced with comments indicating the checks can't call \`exit()\` on CRAN
- The original comment \"Should never happen\" remains to document the intent

This is required for CRAN compliance.

**Files changed:**
- \`third_party/brotli/enc/brotli_hash.h\`"

# Patch 0007: Remove stderr for zstd
git checkout main
git pull
git checkout -b r-patch-0007-remove-stderr-zstd
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0007-Remove-stderr-for-zstd.patch
git add -A
git commit -m "Remove stderr for zstd" -m "This patch removes stderr references from the zstd compression library.

CRAN policies discourage direct use of stderr for output in library code. This change modifies the DISPLAY macro in zstd dictionary training code to be a no-op instead of writing to stderr.

Changes:
- Modified DISPLAY macro in cover.cpp to remove fprintf(stderr, ...) and fflush(stderr)
- Modified DISPLAY macro in fastcover.cpp to remove fprintf(stderr, ...) and fflush(stderr)
- Modified DISPLAY macro in zdict.cpp to be a no-op: do { } while (0)
- Added comments explaining CRAN does not allow stderr references

This is required for CRAN compliance."
git push -u origin HEAD
gh pr create --draft --title "Remove stderr for zstd" --body "This patch removes stderr references from the zstd compression library.

CRAN policies discourage direct use of stderr for output in library code. This change modifies the DISPLAY macro in zstd dictionary training code to be a no-op instead of writing to stderr.

**Changes:**
- Modified DISPLAY macro in \`cover.cpp\` to remove \`fprintf(stderr, ...)\` and \`fflush(stderr)\`
- Modified DISPLAY macro in \`fastcover.cpp\` to remove \`fprintf(stderr, ...)\` and \`fflush(stderr)\`
- Modified DISPLAY macro in \`zdict.cpp\` to be a no-op: \`do { } while (0)\`
- Added comments explaining CRAN does not allow stderr references

This is required for CRAN compliance.

**Files changed:**
- \`third_party/zstd/dict/cover.cpp\`
- \`third_party/zstd/dict/fastcover.cpp\`
- \`third_party/zstd/dict/zdict.cpp\`"

# Patch 0008: Avoid pragma for zstd
git checkout main
git pull
git checkout -b r-patch-0008-avoid-pragma-zstd
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0008-Avoid-pragma-for-zstd.patch
git add -A
git commit -m "Avoid pragma for zstd" -m "This patch removes a clang diagnostic pragma from the zstd compression library.

CRAN policies discourage certain compiler-specific pragmas. This change comments out the clang pragma that ignores -Wshorten-64-to-32 warnings in the divsufsort implementation.

Changes:
- Commented out '#pragma clang diagnostic ignored \"-Wshorten-64-to-32\"' in divsufsort.cpp
- Added comment explaining CRAN does not allow pragmas

This is required for CRAN compliance."
git push -u origin HEAD
gh pr create --draft --title "Avoid pragma for zstd" --body "This patch removes a clang diagnostic pragma from the zstd compression library.

CRAN policies discourage certain compiler-specific pragmas. This change comments out the clang pragma that ignores \`-Wshorten-64-to-32\` warnings in the divsufsort implementation.

**Changes:**
- Commented out \`#pragma clang diagnostic ignored \"-Wshorten-64-to-32\"\` in \`divsufsort.cpp\`
- Added comment explaining CRAN does not allow pragmas

This is required for CRAN compliance.

**Files changed:**
- \`third_party/zstd/dict/divsufsort.cpp\`"

# Patch 0009: Remove stderr for zstd
git checkout main
git pull
git checkout -b r-patch-0009-remove-stderr-zstd-2
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0009-Remove-stderr-for-zstd.patch
git add -A
git commit -m "Remove stderr for zstd (part 2)" -m "This patch removes additional stderr references from the zstd compression library.

This is a follow-up to patch 0007, removing another instance of stderr usage in the DISPLAYUPDATE macro. CRAN policies discourage direct use of stderr for output in library code.

Changes:
- Modified DISPLAYUPDATE macro in zdict.cpp to be a no-op
- Removed fprintf, fflush(stderr), and clock-based display logic
- Added comment explaining CRAN does not allow stderr references

This is required for CRAN compliance."
git push -u origin HEAD
gh pr create --draft --title "Remove stderr for zstd (part 2)" --body "This patch removes additional stderr references from the zstd compression library.

This is a follow-up to patch 0007, removing another instance of stderr usage in the DISPLAYUPDATE macro. CRAN policies discourage direct use of stderr for output in library code.

**Changes:**
- Modified DISPLAYUPDATE macro in \`zdict.cpp\` to be a no-op
- Removed \`fprintf\`, \`fflush(stderr)\`, and clock-based display logic
- Added comment explaining CRAN does not allow stderr references

This is required for CRAN compliance.

**Files changed:**
- \`third_party/zstd/dict/zdict.cpp\`"

# Patch 0012: fix remove CPPHTTPLIB_USE_POLL
git checkout main
git pull
git checkout -b r-patch-0012-remove-cpphttplib-use-poll
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0012-fix-remove-CPPHTTPLIB_USE_POLL.patch
git add -A
git commit -m "fix: remove CPPHTTPLIB_USE_POLL" -m "This patch removes the CPPHTTPLIB_USE_POLL definition from httplib.

The CPPHTTPLIB_USE_POLL macro was causing issues on certain platforms where poll() is not available or behaves differently. Removing this default definition allows the library to use its fallback mechanism (select()) which is more portable.

Changes:
- Removed '#ifndef CPPHTTPLIB_USE_POLL' and '#define CPPHTTPLIB_USE_POLL' block from httplib.hpp

This improves portability for R package compilation across different platforms.

Original patch by: Antonov548 <antonov5551998@gmail.com>"
git push -u origin HEAD
gh pr create --draft --title "fix: remove CPPHTTPLIB_USE_POLL" --body "This patch removes the \`CPPHTTPLIB_USE_POLL\` definition from httplib.

The \`CPPHTTPLIB_USE_POLL\` macro was causing issues on certain platforms where \`poll()\` is not available or behaves differently. Removing this default definition allows the library to use its fallback mechanism (\`select()\`) which is more portable.

**Changes:**
- Removed \`#ifndef CPPHTTPLIB_USE_POLL\` and \`#define CPPHTTPLIB_USE_POLL\` block from \`httplib.hpp\`

This improves portability for R package compilation across different platforms.

**Files changed:**
- \`third_party/httplib/httplib.hpp\`

**Original patch by:** Antonov548 <antonov5551998@gmail.com>"

# Patch 0013: EXTENSION_RELATION
git checkout main
git pull
git checkout -b r-patch-0013-extension-relation
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0013-EXTENSION_RELATION.patch
git add -A
git commit -m "EXTENSION_RELATION" -m "This patch adds support for EXTENSION_RELATION type to the RelationType enum.

This change adds a new relation type (EXTENSION_RELATION = 255) to support extension-defined relations. The enum utilities are updated to include this new type in string conversions.

Changes:
- Added EXTENSION_RELATION = 255 to RelationType enum in relation_type.hpp
- Added EXTENSION_RELATION case to RelationTypeToString() in relation_type.cpp
- Updated enum string utilities in enum_util.cpp to include EXTENSION_RELATION
- Updated array size from 28 to 29 elements in EnumUtil template functions

This allows DuckDB extensions to define custom relation types."
git push -u origin HEAD
gh pr create --draft --title "EXTENSION_RELATION" --body "This patch adds support for \`EXTENSION_RELATION\` type to the \`RelationType\` enum.

This change adds a new relation type (\`EXTENSION_RELATION = 255\`) to support extension-defined relations. The enum utilities are updated to include this new type in string conversions.

**Changes:**
- Added \`EXTENSION_RELATION = 255\` to \`RelationType\` enum in \`relation_type.hpp\`
- Added \`EXTENSION_RELATION\` case to \`RelationTypeToString()\` in \`relation_type.cpp\`
- Updated enum string utilities in \`enum_util.cpp\` to include \`EXTENSION_RELATION\`
- Updated array size from 28 to 29 elements in \`EnumUtil\` template functions

This allows DuckDB extensions to define custom relation types.

**Files changed:**
- \`src/common/enum_util.cpp\`
- \`src/common/enums/relation_type.cpp\`
- \`src/include/duckdb/common/enums/relation_type.hpp\`"

# Patch 0016: Avoid mbedtls diagnostic pragmas
git checkout main
git pull
git checkout -b r-patch-0016-avoid-mbedtls-pragmas
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0016-Avoid-mbedtls-diagnostic-pragmas.patch
git add -A
git commit -m "Avoid mbedtls diagnostic pragmas" -m "This patch modifies diagnostic pragmas in mbedtls to avoid CRAN warnings.

CRAN's compiler checks are sensitive to certain pragma formats. This change adds extra spaces in the pragma directives to work around these checks while maintaining the same functionality.

Changes:
- Modified '#pragma GCC diagnostic' to '#pragma  GCC  diagnostic' (with extra spaces)
- Modified '#pragma clang diagnostic' to '#pragma  clang  diagnostic' (with extra spaces)
- Applied to both constant_time_impl.h and platform_util.cpp

This is a workaround for CRAN compliance."
git push -u origin HEAD
gh pr create --draft --title "Avoid mbedtls diagnostic pragmas" --body "This patch modifies diagnostic pragmas in mbedtls to avoid CRAN warnings.

CRAN's compiler checks are sensitive to certain pragma formats. This change adds extra spaces in the pragma directives to work around these checks while maintaining the same functionality.

**Changes:**
- Modified \`#pragma GCC diagnostic\` to \`#pragma  GCC  diagnostic\` (with extra spaces)
- Modified \`#pragma clang diagnostic\` to \`#pragma  clang  diagnostic\` (with extra spaces)
- Applied to both \`constant_time_impl.h\` and \`platform_util.cpp\`

This is a workaround for CRAN compliance.

**Files changed:**
- \`third_party/mbedtls/library/constant_time_impl.h\`
- \`third_party/mbedtls/library/platform_util.cpp\`"

# Patch 0019: init-2
git checkout main
git pull
git checkout -b r-patch-0019-init-2
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0019-init-2.patch
git add -A
git commit -m "init-2" -m "This patch fixes an uninitialized variable warning in multi-file function progress tracking.

Static analyzers flag that 'progress_in_file' could be used uninitialized if the file state is neither OPEN nor CLOSED. This change initializes the variable to 0.0 to ensure safe default behavior.

Changes:
- Initialized progress_in_file to 0.0 in MultiFileFunction progress tracking
- Added comment explaining the initialization is to avoid uninitialized variable usage

This fixes compiler warnings and potential undefined behavior."
git push -u origin HEAD
gh pr create --draft --title "init-2: Fix uninitialized variable in multi-file progress tracking" --body "This patch fixes an uninitialized variable warning in multi-file function progress tracking.

Static analyzers flag that \`progress_in_file\` could be used uninitialized if the file state is neither OPEN nor CLOSED. This change initializes the variable to 0.0 to ensure safe default behavior.

**Changes:**
- Initialized \`progress_in_file\` to 0.0 in \`MultiFileFunction\` progress tracking
- Added comment explaining the initialization is to avoid uninitialized variable usage

This fixes compiler warnings and potential undefined behavior.

**Files changed:**
- \`src/include/duckdb/common/multi_file/multi_file_function.hpp\`"

# Patch 0020: init-3
git checkout main
git pull
git checkout -b r-patch-0020-init-3
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0020-init-3.patch
git add -A
git commit -m "init-3" -m "This patch fixes uninitialized member variables in CachedFile constructor.

Static analyzers flag that several member variables in CachedFile were not initialized in the constructor. This change explicitly initializes file_size, last_modified, can_seek, and on_disk_file to their default values.

Changes:
- Added initialization of file_size to 0
- Added initialization of last_modified to 0
- Added initialization of can_seek to false
- Added initialization of on_disk_file to false

This fixes compiler warnings and ensures predictable initial state."
git push -u origin HEAD
gh pr create --draft --title "init-3: Fix uninitialized members in CachedFile constructor" --body "This patch fixes uninitialized member variables in \`CachedFile\` constructor.

Static analyzers flag that several member variables in \`CachedFile\` were not initialized in the constructor. This change explicitly initializes \`file_size\`, \`last_modified\`, \`can_seek\`, and \`on_disk_file\` to their default values.

**Changes:**
- Added initialization of \`file_size\` to 0
- Added initialization of \`last_modified\` to 0
- Added initialization of \`can_seek\` to false
- Added initialization of \`on_disk_file\` to false

This fixes compiler warnings and ensures predictable initial state.

**Files changed:**
- \`src/storage/external_file_cache.cpp\`"

# Patch 0021: init-4
git checkout main
git pull
git checkout -b r-patch-0021-init-4
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0021-init-4.patch
git add -A
git commit -m "init-4" -m "This patch fixes uninitialized member variables in HashJoinGlobalSourceState constructor.

Static analyzers flag that full_outer_chunk_count and full_outer_chunk_done were not initialized in the constructor. This change explicitly initializes them to 0.

Changes:
- Added initialization of full_outer_chunk_count to 0
- Added initialization of full_outer_chunk_done to 0

This fixes compiler warnings and ensures predictable initial state for hash join operations."
git push -u origin HEAD
gh pr create --draft --title "init-4: Fix uninitialized members in HashJoinGlobalSourceState" --body "This patch fixes uninitialized member variables in \`HashJoinGlobalSourceState\` constructor.

Static analyzers flag that \`full_outer_chunk_count\` and \`full_outer_chunk_done\` were not initialized in the constructor. This change explicitly initializes them to 0.

**Changes:**
- Added initialization of \`full_outer_chunk_count\` to 0
- Added initialization of \`full_outer_chunk_done\` to 0

This fixes compiler warnings and ensures predictable initial state for hash join operations.

**Files changed:**
- \`src/execution/operator/join/physical_hash_join.cpp\`"

# Patch 0022: disable print for bignum
git checkout main
git pull
git checkout -b r-patch-0022-disable-print-bignum
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0022-disable-print-for-bignum.patch
git add -A
git commit -m "disable print for bignum" -m "This patch conditionally disables debug printing in bignum operations.

CRAN policies discourage packages from printing to stdout/stderr. This change guards bignum debug printing with #ifndef DUCKDB_DISABLE_PRINT to allow it to be disabled for CRAN builds.

Changes:
- Wrapped PrintBits() std::cout usage in #ifndef DUCKDB_DISABLE_PRINT
- Wrapped bignum_t::Print() implementation in #ifndef DUCKDB_DISABLE_PRINT
- Wrapped BignumIntermediate::Print() implementation in #ifndef DUCKDB_DISABLE_PRINT

This allows CRAN builds to disable debug printing while keeping it available for development."
git push -u origin HEAD
gh pr create --draft --title "disable print for bignum" --body "This patch conditionally disables debug printing in bignum operations.

CRAN policies discourage packages from printing to stdout/stderr. This change guards bignum debug printing with \`#ifndef DUCKDB_DISABLE_PRINT\` to allow it to be disabled for CRAN builds.

**Changes:**
- Wrapped \`PrintBits()\` std::cout usage in \`#ifndef DUCKDB_DISABLE_PRINT\`
- Wrapped \`bignum_t::Print()\` implementation in \`#ifndef DUCKDB_DISABLE_PRINT\`
- Wrapped \`BignumIntermediate::Print()\` implementation in \`#ifndef DUCKDB_DISABLE_PRINT\`

This allows CRAN builds to disable debug printing while keeping it available for development.

**Files changed:**
- \`src/common/bignum.cpp\`"

# Patch 0023: csv-disable-print
git checkout main
git pull
git checkout -b r-patch-0023-csv-disable-print
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0023-csv-disable-print.patch
git add -A
git commit -m "csv-disable-print" -m "This patch conditionally disables debug printing in CSV scanner and logging.

CRAN policies discourage packages from printing to stdout/stderr. This change guards CSV state machine and log storage printing with #ifndef DUCKDB_DISABLE_PRINT.

Changes:
- Wrapped CSVStateMachine::Print() std::cout usage in #ifndef DUCKDB_DISABLE_PRINT
- Wrapped StdOutWriteStream::WriteData() std::cout usage in #ifndef DUCKDB_DISABLE_PRINT

This allows CRAN builds to disable debug printing while keeping it available for development."
git push -u origin HEAD
gh pr create --draft --title "csv-disable-print" --body "This patch conditionally disables debug printing in CSV scanner and logging.

CRAN policies discourage packages from printing to stdout/stderr. This change guards CSV state machine and log storage printing with \`#ifndef DUCKDB_DISABLE_PRINT\`.

**Changes:**
- Wrapped \`CSVStateMachine::Print()\` std::cout usage in \`#ifndef DUCKDB_DISABLE_PRINT\`
- Wrapped \`StdOutWriteStream::WriteData()\` std::cout usage in \`#ifndef DUCKDB_DISABLE_PRINT\`

This allows CRAN builds to disable debug printing while keeping it available for development.

**Files changed:**
- \`src/include/duckdb/execution/operator/csv_scanner/csv_state_machine.hpp\`
- \`src/logging/log_storage.cpp\`"

# Patch 0024: deprecated-header
git checkout main
git pull
git checkout -b r-patch-0024-deprecated-header
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0024-deprecated-header.patch
git add -A
git commit -m "deprecated header" -m "This patch replaces deprecated <ctgmath> header with standard C++ headers.

The <ctgmath> header is deprecated in C++17 and removed in C++20. This change uses <complex> and <cmath> instead, which provide the same functionality and are the modern C++ approach.

Changes:
- Replaced '#include <ctgmath>' with '#include <complex>' and '#include <cmath>'
- Applied to stddev.hpp in core_functions aggregate

This ensures compatibility with newer C++ standards and avoids deprecation warnings.

This reverts commit ead59262f56a07dc23319e441ac048385d85bc21."
git push -u origin HEAD
gh pr create --draft --title "Replace deprecated <ctgmath> header" --body "This patch replaces deprecated \`<ctgmath>\` header with standard C++ headers.

The \`<ctgmath>\` header is deprecated in C++17 and removed in C++20. This change uses \`<complex>\` and \`<cmath>\` instead, which provide the same functionality and are the modern C++ approach.

**Changes:**
- Replaced \`#include <ctgmath>\` with \`#include <complex>\` and \`#include <cmath>\`
- Applied to \`stddev.hpp\` in \`core_functions\` aggregate

This ensures compatibility with newer C++ standards and avoids deprecation warnings.

**Files changed:**
- \`extension/core_functions/include/core_functions/aggregate/algebraic/stddev.hpp\`

**Note:** This reverts commit ead59262f56a07dc23319e441ac048385d85bc21."

# Patch 0025: const-safe
git checkout main
git pull
git checkout -b r-patch-0025-const-safe
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0025-const-safe.patch
git add -A
git commit -m "const-safe" -m "This patch adds const-safe handling for list_entry_t in vector operations.

The code was missing support for const list_entry_t in GetTypeId() template and ListVector::GetData(). This change adds proper const handling to avoid compilation errors when working with const vectors.

Changes:
- Added 'std::is_same<T, const list_entry_t>()' check in GetTypeId() template
- Added const overload of ListVector::GetData() that returns 'const list_entry_t*'
- The const version properly handles dictionary vectors by recursing to child

This improves const-correctness and enables working with const vector types."
git push -u origin HEAD
gh pr create --draft --title "const-safe: Add const handling for list_entry_t" --body "This patch adds const-safe handling for \`list_entry_t\` in vector operations.

The code was missing support for \`const list_entry_t\` in \`GetTypeId()\` template and \`ListVector::GetData()\`. This change adds proper const handling to avoid compilation errors when working with const vectors.

**Changes:**
- Added \`std::is_same<T, const list_entry_t>()\` check in \`GetTypeId()\` template
- Added const overload of \`ListVector::GetData()\` that returns \`const list_entry_t*\`
- The const version properly handles dictionary vectors by recursing to child

This improves const-correctness and enables working with const vector types.

**Files changed:**
- \`src/include/duckdb/common/type_util.hpp\`
- \`src/include/duckdb/common/types/vector.hpp\`"

# Patch 0026: uninit
git checkout main
git pull
git checkout -b r-patch-0026-uninit
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0026-uninit.patch
git add -A
git commit -m "uninit" -m "This patch fixes uninitialized member variable in UnifiedVectorFormat move constructor.

Static analyzers flag that physical_type was not initialized in the move constructor. This change explicitly initializes it to PhysicalType::INVALID to match the default constructor.

Changes:
- Added initialization of physical_type to PhysicalType::INVALID in move constructor

This ensures consistent initialization across all constructors and fixes compiler warnings."
git push -u origin HEAD
gh pr create --draft --title "uninit: Fix uninitialized physical_type in move constructor" --body "This patch fixes uninitialized member variable in \`UnifiedVectorFormat\` move constructor.

Static analyzers flag that \`physical_type\` was not initialized in the move constructor. This change explicitly initializes it to \`PhysicalType::INVALID\` to match the default constructor.

**Changes:**
- Added initialization of \`physical_type\` to \`PhysicalType::INVALID\` in move constructor

This ensures consistent initialization across all constructors and fixes compiler warnings.

**Files changed:**
- \`src/common/types/vector.cpp\`"

# Patch 0028: init-sorted-tuples
git checkout main
git pull
git checkout -b r-patch-0028-init-sorted-tuples
git apply /Users/kirill/git/R/duckdb/duckdb-r/patch/0028-init-sorted-tuples.patch
git add -A
git commit -m "init-sorted-tuples" -m "This patch fixes uninitialized sorted_tuples member in SortGlobalSinkState constructor.

Static analyzers flag that sorted_tuples was not initialized in the constructor. This change explicitly initializes it to 0 in the member initializer list.

Changes:
- Added initialization of sorted_tuples to 0 in constructor member initializer list

This ensures all members are properly initialized and fixes compiler warnings."
git push -u origin HEAD
gh pr create --draft --title "init-sorted-tuples: Fix uninitialized sorted_tuples member" --body "This patch fixes uninitialized \`sorted_tuples\` member in \`SortGlobalSinkState\` constructor.

Static analyzers flag that \`sorted_tuples\` was not initialized in the constructor. This change explicitly initializes it to 0 in the member initializer list.

**Changes:**
- Added initialization of \`sorted_tuples\` to 0 in constructor member initializer list

This ensures all members are properly initialized and fixes compiler warnings.

**Files changed:**
- \`src/common/sorting/sort.cpp\`"

echo "All patches have been applied, committed, pushed, and draft PRs created!"
