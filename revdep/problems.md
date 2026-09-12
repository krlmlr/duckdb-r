# BeeBDC (1.3.4)

* GitHub: <https://github.com/jbdorey/BeeBDC>
* Email: <mailto:jbdorey@me.com>
* GitHub mirror: <https://github.com/cran/BeeBDC>

Run `revdepcheck::revdep_details(, "BeeBDC")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        - Downloading taxonomy...
       duckdb keeps downloaded extensions and secrets in a temporary directory:
       i /tmp/RtmprsKj5S/working_dir/RtmpWewhQW/duckdb
       This is removed when the R session ends.
       * Extensions are re-downloaded each session.
       * Secrets are lost.
       i Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       Saving _problems/test-taxadbToBeeBDC-18.R
       [ FAIL 1 | WARN 3 | SKIP 0 | PASS 248 ]
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Error ('test-taxadbToBeeBDC.R:10:2'): (code run outside of `test_that()`) ───
       Error: Could not reach the taxadb data repository at cboettig/taxadb
       Backtrace:
           ▆
        1. └─BeeBDC::taxadbToBeeBDC(...) at test-taxadbToBeeBDC.R:10:2
        2.   └─taxadb::td_create(...)
        3.     └─taxadb::td_download(...)
       
       [ FAIL 1 | WARN 3 | SKIP 0 | PASS 248 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# commons (0.1.0)

* GitHub: <https://github.com/posit-dev/commons>
* Email: <mailto:simon.couch@posit.co>
* GitHub mirror: <https://github.com/cran/commons>

Run `revdepcheck::revdep_details(, "commons")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        14. │         └─DBI::dbSendStatement(conn, statement, ...)
        15. │           ├─DBI::dbSendQuery(conn, statement, ...)
        16. │           └─duckdb::dbSendQuery(conn, statement, ...)
        17. │             └─duckdb (local) .local(conn, statement, ...)
        18. │               └─duckdb:::rethrow_rapi_prepare(conn@conn_ref, statement, env)
        19. │                 ├─rlang::try_fetch(...)
        20. │                 │ ├─base::tryCatch(...)
        21. │                 │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        22. │                 │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        23. │                 │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        24. │                 │ └─base::withCallingHandlers(...)
        25. │                 └─duckdb:::rapi_prepare(conn, query, env)
        26. ├─duckdb (local) `<fn>`(...)
        27. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        28. │   └─rlang:::signal_abort(cnd, .file)
        29. │     └─base::signalCondition(cnd)
        30. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        31.   └─handlers[[1L]](cnd)
        32.     └─duckdb:::rethrow_error_from_rapi(e, call)
        33.       └─rlang::abort(msg, call = call)
       
       [ FAIL 13 | WARN 0 | SKIP 86 | PASS 7205 ]
       Error:
       ! Test failures.
       Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

# datacaged (0.2.1)

* GitHub: <https://github.com/gecomt/datacaged>
* Email: <mailto:alexsandro.prado@ufersa.edu.br>
* GitHub mirror: <https://github.com/cran/datacaged>

Run `revdepcheck::revdep_details(, "datacaged")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        3. └─datacaged::caged_load(...)
        4.   └─datacaged::caged_info(db_path)
        5.     └─datacaged::caged_connect(db_path, read_only = TRUE, quiet = TRUE)
        6.       └─duckdb::duckdb(dbdir = db_path, read_only = read_only)
        7.         └─duckdb:::warn_instance_settings_ignored(...)
        8.           └─rlang::abort(...)
       ── Error ('test-pipelines.R:216:3'): caged_adjustments_load() cria banco com tabela caged_ajustes ──
       Error in `duckdb::duckdb(dbdir = db_path, read_only = read_only)`: `read_only` can't be applied to the database instance for `/tmp/RtmpHP38fP/working_dir/RtmpvuPx3F/caged_adj_mock_31032d9f585.duckdb`, which already exists.
       * These settings take effect only when the instance is created.
       * Release it with `duckdb_shutdown()` first, or pass them to the `duckdb()` call that creates it.
       Backtrace:
           ▆
        1. ├─base::suppressMessages(...) at test-pipelines.R:216:3
        2. │ └─base::withCallingHandlers(...)
        3. └─datacaged::caged_adjustments_load(...)
        4.   └─datacaged::caged_info(db_path)
        5.     └─datacaged::caged_connect(db_path, read_only = TRUE, quiet = TRUE)
        6.       └─duckdb::duckdb(dbdir = db_path, read_only = read_only)
        7.         └─duckdb:::warn_instance_settings_ignored(...)
        8.           └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 5 | PASS 187 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# duckh3 (0.1.0)

* GitHub: <https://github.com/Cidree/duckh3>
* Email: <mailto:adrian.cidre@gmail.com>
* GitHub mirror: <https://github.com/cran/duckh3>

Run `revdepcheck::revdep_details(, "duckh3")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
       URL
       "http://extensions.duckdb.org/a3cd0deed1/linux_amd64/spatial.duckdb_extension.gz"
       (HTTP 404) Extension "spatial" is an existing extension.  For more info,
       visit
       https://duckdb.org/docs/stable/extensions/troubleshooting?version=a3cd0deed1&platform=linux_amd64&extension=spatial
       ℹ Context: rapi_execute ℹ Error type: INVALID
     ✖ community: Invalid Error: HTTP Error: Failed to download extension "spatial"
       at URL
       "http://community-extensions.duckdb.org/a3cd0deed1/linux_amd64/spatial.duckdb_extension.gz"
       (HTTP 404) Extension "spatial" is an existing extension.  For more info,
       visit
       https://duckdb.org/docs/stable/extensions/troubleshooting?version=a3cd0deed1&platform=linux_amd64&extension=spatial
       ℹ Context: rapi_execute ℹ Error type: INVALID
     ℹ It might not be available for this version of DuckDB, or the install location
       may not be writable.
     ℹ Check that the extension name is correct:
       <https://duckdb.org/docs/extensions/overview>
     Backtrace:
         ▆
      1. └─duckh3::ddbh3_default_conn(threads = 1)
      2.   └─duckspatial::ddbs_create_conn(...)
      3.     └─duckspatial::ddbs_install(conn, upgrade = upgrade, quiet = TRUE)
      4.       └─cli::cli_abort(...)
      5.         └─rlang::abort(...)
     Execution halted
     ```

*   checking tests ... ERROR
     ```
     ...
       ℹ It might not be available for this version of DuckDB, or the install location
         may not be writable.
       ℹ Check that the extension name is correct:
         <https://duckdb.org/docs/extensions/overview>
       Backtrace:
            ▆
         1. └─testthat::test_check("duckh3")
         2.   └─testthat::test_dir(...)
         3.     └─testthat:::test_files(...)
         4.       └─testthat:::test_files_serial(...)
         5.         └─testthat:::test_files_setup_state(...)
         6.           └─testthat::source_test_setup(".", env)
         7.             └─testthat::source_dir(path, "^setup.*\\.[rR]$", env = env, wrap = FALSE)
         8.               └─base::lapply(...)
         9.                 └─testthat (local) FUN(X[[i]], ...)
        10.                   └─testthat::source_file(...)
        11.                     ├─base::withCallingHandlers(...)
        12.                     └─base::eval(exprs, env)
        13.                       └─base::eval(exprs, env)
        14.                         └─duckh3::ddbh3_default_conn() at ./setup.R:12:1
        15.                           └─duckspatial::ddbs_create_conn(...)
        16.                             └─duckspatial::ddbs_install(conn, upgrade = upgrade, quiet = TRUE)
        17.                               └─cli::cli_abort(...)
        18.                                 └─rlang::abort(...)
       Execution halted
     ```

# duckspatial (1.2.1)

* GitHub: <https://github.com/Cidree/duckspatial>
* Email: <mailto:adrian.cidre@gmail.com>
* GitHub mirror: <https://github.com/cran/duckspatial>

Run `revdepcheck::revdep_details(, "duckspatial")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       ℹ Check that the extension name is correct:
         <https://duckdb.org/docs/extensions/overview>
       Backtrace:
            ▆
         1. └─testthat::test_check("duckspatial")
         2.   └─testthat::test_dir(...)
         3.     └─testthat:::test_files(...)
         4.       └─testthat:::test_files_serial(...)
         5.         └─testthat:::test_files_setup_state(...)
         6.           └─testthat::source_test_setup(".", env)
         7.             └─testthat::source_dir(path, "^setup.*\\.[rR]$", env = env, wrap = FALSE)
         8.               └─base::lapply(...)
         9.                 └─testthat (local) FUN(X[[i]], ...)
        10.                   └─testthat::source_file(...)
        11.                     ├─base::withCallingHandlers(...)
        12.                     └─base::eval(exprs, env)
        13.                       └─base::eval(exprs, env)
        14.                         ├─duckspatial::as_duckspatial_df(argentina_sf) at ./setup.R:15:1
        15.                         └─duckspatial:::as_duckspatial_df.sf(argentina_sf)
        16.                           └─duckspatial:::ddbs_default_conn()
        17.                             └─duckspatial::ddbs_create_conn(dbdir = "memory", ...)
        18.                               └─duckspatial::ddbs_install(conn, upgrade = upgrade, quiet = TRUE)
        19.                                 └─cli::cli_abort(...)
        20.                                   └─rlang::abort(...)
       Execution halted
     ```

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

# quak (0.1.0)

* GitHub: <https://github.com/pedrobtz/quak>
* Email: <mailto:pedrobtz@gmail.com>
* GitHub mirror: <https://github.com/cran/quak>

Run `revdepcheck::revdep_details(, "quak")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       i This message has been shown 60 times and will not be shown again this session.
       i Collecting data from Azure...
       [ FAIL 1 | WARN 0 | SKIP 19 | PASS 260 ]
       
       ══ Skipped tests (19) ══════════════════════════════════════════════════════════
       • On CRAN (18): 'test-azure.R:2:3', 'test-azure.R:22:3', 'test-azure.R:39:3',
         'test-azure.R:56:3', 'test-azure.R:67:3', 'test-azure.R:91:3',
         'test-azure.R:109:3', 'test-azure.R:128:3', 'test-azure.R:139:3',
         'test-extensions.R:2:3', 'test-extensions.R:12:3', 'test-extensions.R:22:3',
         'test-extensions.R:39:3', 'test-extensions.R:51:3',
         'test-extensions.R:302:3', 'test-extensions.R:338:3',
         'test-extensions.R:352:3', 'test-extensions.R:367:3'
       • azure extension not installed (1): 'test-tables.R:46:3'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-conditions.R:60:3'): extension unavailable errors include extension metadata and parent ──
       Expected `err$parent` to be an S3 object.
       Actual OO type: none.
       
       [ FAIL 1 | WARN 0 | SKIP 19 | PASS 260 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# Rduckhts (1.5.1-0.1.3)

* GitHub: <https://github.com/RGenomicsETL/duckhts>
* Email: <mailto:sounkoutoure@gmail.com>
* GitHub mirror: <https://github.com/cran/Rduckhts>

Run `revdepcheck::revdep_details(, "Rduckhts")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       MATCH: MAP -> data.frame
       MATCH: MAP -> data.frame
       MATCH: MAP -> data.frame
       
       test_type_mappings.R..........    0 tests    Testing type mapping function assertions...
       Type mapping function assertions passed!
       
       test_type_mappings.R..........   13 tests OK Type mapping test completed! Check output above for effective type mappings.
       
       test_type_mappings.R..........   13 tests OK 44ms
       
       test_variantkey_regionkey.R...    0 tests    
       test_variantkey_regionkey.R...    0 tests    
       test_variantkey_regionkey.R...    0 tests    
       test_variantkey_regionkey.R...   48 tests OK 68ms
       ----- FAILED[xcpt]: test_connection.R<143--143>
        call| test_reused_file_driver_rejected()
        call| -->expect_error(rduckhts_connect(dbdir = dbdir), "already has a live instance")
        diff| The error message:
        diff| '`shared_home`, `allow_extensions`, `config$allow_unsigned_extensions`, `config$autoinstall_known_extensions`, `config$autoload_known_extensions` can't be applied to the database instance for `/tmp/RtmpMvqQE6/working_dir/RtmpqHdbzq/rduckhts_reused_c361286b30d.duckdb`, which already exists.
        diff| These settings take effect only when the instance is created.
        diff| Release it with `duckdb_shutdown()` first, or pass them to the `duckdb()` call that creates it.'
        diff| does not match pattern 'already has a live instance'
       Error: 1 out of 2078 tests failed
       Execution halted
     ```

