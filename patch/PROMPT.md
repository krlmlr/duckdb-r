# Patch Management Conversation

## Initial Request

**User Request:**
> Review all patches in this directory. Create a simple script that, for each patch, applies each with a suitable commit message and detail to a separate branch in ~/git/duckdb, commits, pushes with `git push -u origin HEAD` and opens a draft PR with `gh` and contents taken from the message. Inline all paths and texts, do not use variables. Record this conversation including follow-ups in `patch/PROMPT.md`.

## Patch Review Summary

The directory `/Users/kirill/git/R/duckdb/duckdb-r/patch/` contains 20 patches that modify the vendored DuckDB C++ library for R package (duckdb-r) compatibility with CRAN requirements and to fix various compilation issues.

### Patches Overview

1. **0001-Avoid-rstrtmgr-on-R-4.1.patch**
   - Conditionally disables Windows Restart Manager functionality on R 4.1
   - Guards code with `DUCKDB_RSTRTMGR` preprocessor directives
   - Needed for CRAN compatibility with R 4.1's MinGW toolchain

2. **0002-MUTEX_THROW-and-keep-pragmas.patch**
   - Modifies RE2 regex library pragmas to avoid CRAN warnings
   - Comments out `-Wmissing-field-initializers` pragma

3. **0003-Try-to-ignore-clang-warnings.patch**
   - Adds clang diagnostic pragmas to suppress specific warnings in RE2
   - Suppresses `-Wgnu-anonymous-struct`, `-Wnested-anon-types`, and `-Wdtor-name`

4. **0004-Patch-Relation-Query-for-138.patch**
   - Modifies `Relation::Query()` to use temporary views for read-only relations
   - Fixes issue #138 in duckdb-r

5. **0005-Avoid-exit-in-Brotli.patch**
   - Removes `exit()` calls from Brotli compression library
   - Required for CRAN compliance (packages cannot terminate R session)

6. **0007-Remove-stderr-for-zstd.patch**
   - Removes stderr references from zstd compression library
   - Modifies DISPLAY macros to be no-ops

7. **0008-Avoid-pragma-for-zstd.patch**
   - Comments out clang pragma in zstd divsufsort implementation

8. **0009-Remove-stderr-for-zstd.patch**
   - Additional stderr removal in zstd (DISPLAYUPDATE macro)

9. **0012-fix-remove-CPPHTTPLIB_USE_POLL.patch**
   - Removes `CPPHTTPLIB_USE_POLL` definition for better portability
   - By Antonov548

10. **0013-EXTENSION_RELATION.patch**
    - Adds `EXTENSION_RELATION` type to `RelationType` enum
    - Allows extensions to define custom relation types

11. **0016-Avoid-mbedtls-diagnostic-pragmas.patch**
    - Modifies pragma formatting in mbedtls (adds extra spaces)
    - Workaround for CRAN compiler checks

12. **0019-init-2.patch**
    - Fixes uninitialized `progress_in_file` variable in multi-file function

13. **0020-init-3.patch**
    - Fixes uninitialized members in `CachedFile` constructor

14. **0021-init-4.patch**
    - Fixes uninitialized members in `HashJoinGlobalSourceState` constructor

15. **0022-disable-print-for-bignum.patch**
    - Conditionally disables debug printing in bignum operations
    - Guards with `#ifndef DUCKDB_DISABLE_PRINT`

16. **0023-csv-disable-print.patch**
    - Conditionally disables debug printing in CSV scanner and logging

17. **0024-deprecated-header.patch**
    - Replaces deprecated `<ctgmath>` with `<complex>` and `<cmath>`
    - Ensures C++17/C++20 compatibility

18. **0025-const-safe.patch**
    - Adds const-safe handling for `list_entry_t` in vector operations

19. **0026-uninit.patch**
    - Fixes uninitialized `physical_type` in `UnifiedVectorFormat` move constructor

20. **0028-init-sorted-tuples.patch**
    - Fixes uninitialized `sorted_tuples` member in `SortGlobalSinkState`

## Categories of Patches

### CRAN Compliance

- **Pragma avoidance/modification:** 0002, 0003, 0008, 0016
- **No exit() calls:** 0005
- **No stderr usage:** 0007, 0009
- **Conditional printing:** 0022, 0023
- **Platform compatibility:** 0001, 0012

### Bug Fixes

- **Uninitialized variables:** 0019, 0020, 0021, 0026, 0028
- **Const-correctness:** 0025
- **Read-only relations:** 0004

### Feature Additions

- **Extension support:** 0013

### Standards Compliance

- **C++ standard headers:** 0024

## Script Created

A comprehensive bash script `apply-patches.sh` has been created that:

1. Navigates to `~/git/duckdb`
2. For each patch:
   - Checks out `main` branch
   - Pulls latest changes
   - Creates a new branch named `r-patch-NNNN-description`
   - Applies the patch from the duckdb-r repository
   - Commits with detailed message explaining:
     - What the patch does
     - Why it's needed
     - What files are changed
   - Pushes to origin with `git push -u origin HEAD`
   - Creates a draft PR with `gh pr create --draft` including:
     - Descriptive title
     - Detailed body with formatted markdown
     - References to related issues where applicable

## Usage

To run the script:

```bash
chmod +x /Users/kirill/git/R/duckdb/duckdb-r/patch/apply-patches.sh
/Users/kirill/git/R/duckdb/duckdb-r/patch/apply-patches.sh
```

## Prerequisites

- `git` installed and configured
- `gh` (GitHub CLI) installed and authenticated
- Write access to the duckdb/duckdb repository
- DuckDB repository cloned at `~/git/duckdb`

## Notes

- All PRs are created as drafts to allow for review before marking ready
- Each patch gets its own branch to allow independent review and merging
- Commit messages are detailed to provide context for reviewers
- PR descriptions use markdown formatting for clarity
- File paths are fully qualified (no variables used per request)

## Follow-ups

(This section will be updated with any follow-up requests or modifications to the process)
