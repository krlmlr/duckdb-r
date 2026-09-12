# motherduck (0.2.1)

* Email: <mailto:alejandro.hagan@outlook.com>
* GitHub mirror: <https://github.com/cran/motherduck>

Run `revdepcheck::revdep_details(, "motherduck")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       i Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       Saving _problems/test-motherduck-405.R
       [ FAIL 1 | WARN 0 | SKIP 1 | PASS 22 ]
       
       ══ Skipped tests (1) ═══════════════════════════════════════════════════════════
       • empty test (1): 'test-motherduck.R:259:3'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Error ('test-motherduck.R:405:7'): read_excel / successfully reads a excel and copies table to database ──
       <purrr_error_indexed/rlang_error/error/condition>
       Error in `purrr::map(ext_lst$valid_ext, function(x) DBI::dbExecute(.con, glue::glue("INSTALL {x};")))`: i In index: 1.
       Caused by error in `duckdb_result()`:
       ! Invalid Error: HTTP Error: Failed to download extension "excel" at URL "http://extensions.duckdb.org/a3cd0deed1/linux_amd64/excel.duckdb_extension.gz" (HTTP 404)
       Extension "excel" is an existing extension.
       
       For more info, visit https://duckdb.org/docs/stable/extensions/troubleshooting?version=a3cd0deed1&platform=linux_amd64&extension=excel
       i Context: rapi_execute
       i Error type: INVALID
       
       [ FAIL 1 | WARN 0 | SKIP 1 | PASS 22 ]
       Error:
       ! Test failures.
       Execution halted
     ```

