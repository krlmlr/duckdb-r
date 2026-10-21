# BeeBDC (1.3.5)

* GitHub: <https://github.com/jbdorey/BeeBDC>
* Email: <mailto:jbdorey@me.com>
* GitHub mirror: <https://github.com/cran/BeeBDC>

Run `revdepcheck::revdep_details(, "BeeBDC")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       are planar
       duckdb keeps downloaded extensions and secrets in a temporary directory:
       i /tmp/RtmpZFUcJu/working_dir/Rtmpvez5Hj/duckdb
       This is removed when the R session ends.
       * Extensions are re-downloaded each session.
       * Secrets are lost.
       i Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       Saving _problems/test-taxadbToBeeBDC-14.R
       [ FAIL 1 | WARN 2 | SKIP 0 | PASS 248 ]
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Error ('test-taxadbToBeeBDC.R:7:2'): (code run outside of `test_that()`) ────
       Error: Could not reach the taxadb data repository at cboettig/taxadb
       Backtrace:
           ▆
        1. └─BeeBDC::taxadbToBeeBDC(...) at test-taxadbToBeeBDC.R:7:2
        2.   └─taxadb::td_create(...)
        3.     └─taxadb::td_download(...)
       
       [ FAIL 1 | WARN 2 | SKIP 0 | PASS 248 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# dbMatrix (0.1.0)

* GitHub: <https://github.com/dbverse-org/dbmatrix-r>
* Email: <mailto:ecr7407@gmail.com>
* GitHub mirror: <https://github.com/cran/dbMatrix>

Run `revdepcheck::revdep_details(, "dbMatrix")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
       4. │ └─DBI::dbExecute(con, sql)
       5. │   ├─DBI::dbSendStatement(conn, statement, ...)
       6. │   └─DBI::dbSendStatement(conn, statement, ...)
       7. │     ├─DBI::dbSendQuery(conn, statement, ...)
       8. │     └─duckdb::dbSendQuery(conn, statement, ...)
       9. │       └─duckdb (local) .local(conn, statement, ...)
      10. │         └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
      11. │           └─duckdb:::duckdb_execute(res)
      12. │             └─duckdb:::rethrow_rapi_execute(...)
      13. │               ├─rlang::try_fetch(...)
      14. │               │ ├─base::tryCatch(...)
      15. │               │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
      16. │               │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
      17. │               │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
      18. │               │ └─base::withCallingHandlers(...)
      19. │               └─duckdb:::rapi_execute(stmt, convert_opts)
      20. ├─duckdb (local) `<fn>`(...)
      21. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
      22. │   └─rlang:::signal_abort(cnd, .file)
      23. │     └─base::signalCondition(cnd)
      24. └─rlang (local) `<fn>`(`<dckdb_rr>`)
      25.   └─handlers[[1L]](cnd)
      26.     └─duckdb:::rethrow_error_from_rapi(e, call)
      27.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
     Execution halted
     ```

*   checking tests ... ERROR
     ```
     ...
         8. │     └─duckdb::dbSendQuery(conn, statement, ...)
         9. │       └─duckdb (local) .local(conn, statement, ...)
        10. │         └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
        11. │           └─duckdb:::duckdb_execute(res)
        12. │             └─duckdb:::rethrow_rapi_execute(...)
        13. │               ├─rlang::try_fetch(...)
        14. │               │ ├─base::tryCatch(...)
        15. │               │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        16. │               │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        17. │               │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        18. │               │ └─base::withCallingHandlers(...)
        19. │               └─duckdb:::rapi_execute(stmt, convert_opts)
        20. ├─duckdb (local) `<fn>`(...)
        21. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        22. │   └─rlang:::signal_abort(cnd, .file)
        23. │     └─base::signalCondition(cnd)
        24. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        25.   └─handlers[[1L]](cnd)
        26.     └─duckdb:::rethrow_error_from_rapi(e, call)
        27.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 18 | WARN 2 | SKIP 1 | PASS 206 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
          ▆
       1. └─dbMatrix::dbMatrix(...)
       2.   ├─dbMatrix::as.dbMatrix(...)
       3.   └─dbMatrix:::as.dbMatrix.matrix(...)
       4.     ├─DBI::dbExecute(con, sql)
       5.     └─DBI::dbExecute(con, sql)
       6.       ├─DBI::dbSendStatement(conn, statement, ...)
       7.       └─DBI::dbSendStatement(conn, statement, ...)
       8.         ├─DBI::dbSendQuery(conn, statement, ...)
       9.         └─duckdb::dbSendQuery(conn, statement, ...)
      10.           └─duckdb (local) .local(conn, statement, ...)
      11.             └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'overview.Rmd' failed with diagnostics:
     Invalid Input Error: Reading a column of the data frame was interrupted
     ℹ Context: rapi_execute
     ℹ Error type: INVALID_INPUT
     --- failed re-building ‘overview.Rmd’
     
     SUMMARY: processing the following files failed:
       ‘operations.Rmd’ ‘overview.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

# DrugExposureDiagnostics (1.2.1)

* GitHub: <https://github.com/darwin-eu/DrugExposureDiagnostics>
* Email: <mailto:g.inberg@erasmusmc.nl>
* GitHub mirror: <https://github.com/cran/DrugExposureDiagnostics>

Run `revdepcheck::revdep_details(, "DrugExposureDiagnostics")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        37. │                       │ └─base::withCallingHandlers(...)
        38. │                       └─duckdb:::rapi_prepare(conn, query, env)
        39. ├─duckdb (local) `<fn>`(...)
        40. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        41. │   └─rlang:::signal_abort(cnd, .file)
        42. │     └─base::signalCondition(cnd)
        43. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        44. │ └─handlers[[1L]](cnd)
        45. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        46. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        47. │       └─rlang:::signal_abort(cnd, .file)
        48. │         └─base::signalCondition(cnd)
        49. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        50. │ └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        51. │   └─rlang::abort(...)
        52. │     └─rlang:::signal_abort(cnd, .file)
        53. │       └─base::signalCondition(cnd)
        54. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        55.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        56.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 120 | SKIP 5 | PASS 505 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
       adding: drugTypesOverall.csv (deflated 42%)
       adding: drugVerbatimEndDate.csv (deflated 63%)
       adding: drugVerbatimEndDateByConcept.csv (deflated 70%)
       adding: metadata.csv (deflated 50%)
       adding: missingValuesByConcept.csv (deflated 94%)
       adding: missingValuesOverall.csv (deflated 82%)
     --- finished re-building ‘IntroductionToDrugExposureDiagnostics.Rmd’
     
     --- re-building ‘Missingness.Rmd’ using rmarkdown
     --- finished re-building ‘Missingness.Rmd’
     
     --- re-building ‘Quantity.Rmd’ using rmarkdown
     --- finished re-building ‘Quantity.Rmd’
     
     --- re-building ‘Routes.Rmd’ using rmarkdown
     --- finished re-building ‘Routes.Rmd’
     
     --- re-building ‘VerbatimEndDate.Rmd’ using rmarkdown
     --- finished re-building ‘VerbatimEndDate.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘DrugTimeBetween.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# duckh3 (0.2.0)

* GitHub: <https://github.com/Cidree/duckh3>
* Email: <mailto:adrian.cidre@gmail.com>
* GitHub mirror: <https://github.com/cran/duckh3>

Run `revdepcheck::revdep_details(, "duckh3")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
     ! Failed to install the spatial extension.
     ✖ core: HTTP Error: Failed to download extension "spatial" at URL
       "http://extensions.duckdb.org/d54cbbe3df/linux_amd64/spatial.duckdb_extension.gz"
       (HTTP 404) Extension "spatial" is an existing extension.  For more info,
       visit
       https://duckdb.org/docs/current/extensions/troubleshooting?version=d54cbbe3df&platform=linux_amd64&extension=spatial
       ℹ Context: rapi_execute ℹ Error type: HTTP
     ✖ community: HTTP Error: Failed to download extension "spatial" at URL
       "http://community-extensions.duckdb.org/d54cbbe3df/linux_amd64/spatial.duckdb_extension.gz"
       (HTTP 404) Extension "spatial" is an existing extension.  For more info,
       visit
       https://duckdb.org/docs/current/extensions/troubleshooting?version=d54cbbe3df&platform=linux_amd64&extension=spatial
       ℹ Context: rapi_execute ℹ Error type: HTTP
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

# duckspatial (1.3.0)

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
        16.                           └─duckspatial::ddbs_default_conn()
        17.                             └─duckspatial::ddbs_create_conn(dbdir = "memory", ...)
        18.                               └─duckspatial::ddbs_install(conn, upgrade = upgrade, quiet = TRUE)
        19.                                 └─cli::cli_abort(...)
        20.                                   └─rlang::abort(...)
       Execution halted
     ```

# farr (1.1.0)

* GitHub: <https://github.com/iangow/farr>
* Email: <mailto:iandgow@gmail.com>
* GitHub mirror: <https://github.com/cran/farr>

Run `revdepcheck::revdep_details(, "farr")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        3.   └─farr (local) code(conn, events, dates) at ./helper-cumulative-returns.R:74:3
        4.     └─testthat::expect_error(...) at test-get_event_cum_rets.R:78:13
       ── Failure ('test-get_event_cum_rets.R:78:13'): DuckDB monthly reconstructed rejects returns below minus one even with a complete loss ──
       Expected `get_returns(events, conn, end_event_date = "last_event")` to throw a error.
       size
       Backtrace:
           ▆
        1. ├─base::do.call(...) at test-get_event_cum_rets.R:76:9
        2. └─farr (local) `<fn>`(...)
        3.   └─farr (local) code(conn, events, dates) at ./helper-cumulative-returns.R:74:3
        4.     └─testthat::expect_error(...) at test-get_event_cum_rets.R:78:13
       ── Failure ('test-get_event_cum_rets.R:78:13'): DuckDB monthly reconstructed rejects returns below minus one even with a complete loss ──
       Expected `get_returns(events, conn, end_event_date = "last_event")` to throw a error.
       size
       Backtrace:
           ▆
        1. ├─base::do.call(...) at test-get_event_cum_rets.R:76:9
        2. └─farr (local) `<fn>`(...)
        3.   └─farr (local) code(conn, events, dates) at ./helper-cumulative-returns.R:74:3
        4.     └─testthat::expect_error(...) at test-get_event_cum_rets.R:78:13
       
       [ FAIL 12 | WARN 0 | SKIP 29 | PASS 343 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# irelink (0.0.1)

* GitHub: <https://github.com/christopherkenny/irelink>
* Email: <mailto:ctkenny@proton.me>
* GitHub mirror: <https://github.com/cran/irelink>

Run `revdepcheck::revdep_details(, "irelink")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
         'test-il_count_pairs.R:158:1', 'test-il_estimate.R:236:1',
         'test-il_score_pairs.R:81:1', 'test-il_score_pairs.R:94:1',
         'test-sql-profile.R:83:1', 'test-sql-profile.R:98:1',
         'test-stage6-plan.R:80:1', 'test-stage6-plan.R:87:1',
         'test-stage6-plan.R:98:1', 'test-stage6-plan.R:119:1',
         'test-stage6-plan.R:141:1', 'test-stage6-plan.R:163:1'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-sql-clustering.R:314:3'): SQL best_link with source_dataset matches R tie handling ──
       Expected `unname(sql_map["A"])` to equal `unname(sql_map["C"])`.
       Differences:
       `actual`:   "cluster_A"
       `expected`: "cluster_B"
       
       ── Failure ('test-sql-clustering.R:316:3'): SQL best_link with source_dataset matches R tie handling ──
       Expected `sql_map[c("A", "B", "C")] == sql_map["A"]` to equal `r_map[c("A", "B", "C")] == r_map["A"]`.
       Differences:
       `actual`:   TRUE FALSE FALSE
       `expected`: TRUE FALSE TRUE 
       
       
       [ FAIL 2 | WARN 0 | SKIP 22 | PASS 1155 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# MeasurementDiagnostics (0.3.0)

* GitHub: <https://github.com/ohdsi/MeasurementDiagnostics>
* Email: <mailto:nuria.mercadebesora@ndorms.ox.ac.uk>
* GitHub mirror: <https://github.com/cran/MeasurementDiagnostics>

Run `revdepcheck::revdep_details(, "MeasurementDiagnostics")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        13. │               └─DBI::dbSendStatement(conn, statement, ...)
        14. │                 ├─DBI::dbSendQuery(conn, statement, ...)
        15. │                 └─duckdb::dbSendQuery(conn, statement, ...)
        16. │                   └─duckdb (local) .local(conn, statement, ...)
        17. │                     └─duckdb:::rethrow_rapi_prepare(conn@conn_ref, statement, env)
        18. │                       ├─rlang::try_fetch(...)
        19. │                       │ ├─base::tryCatch(...)
        20. │                       │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        21. │                       │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        22. │                       │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        23. │                       │ └─base::withCallingHandlers(...)
        24. │                       └─duckdb:::rapi_prepare(conn, query, env)
        25. ├─duckdb (local) `<fn>`(...)
        26. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        27. │   └─rlang:::signal_abort(cnd, .file)
        28. │     └─base::signalCondition(cnd)
        29. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        30.   └─handlers[[1L]](cnd)
        31.     └─duckdb:::rethrow_error_from_rapi(e, call)
        32.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 5 | WARN 0 | SKIP 10 | PASS 0 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
       7.         └─CDMConnector:::compute.db_cdm(...)
       8.           └─CDMConnector:::.computeQuery(...)
       9.             └─CDMConnector:::.computePermanent(...)
      10.               ├─DBI::dbExecute(x$src$con, sql)
      11.               └─DBI::dbExecute(x$src$con, sql)
      12.                 ├─DBI::dbSendStatement(conn, statement, ...)
      13.                 └─DBI::dbSendStatement(conn, statement, ...)
      14.                   ├─DBI::dbSendQuery(conn, statement, ...)
      15.                   └─duckdb::dbSendQuery(conn, statement, ...)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'a03_resultsVisualisation.Rmd' failed with diagnostics:
     Binder Error: PARTITION BY window expressions cannot be volatile
     
     LINE 9: WHEN (NOT(((RANDOM()) IS NULL))) THEN ROW_NUMBER() OVER (PARTITION BY (CASE WHEN (((RANDOM())...
                                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     ℹ Context: rapi_prepare
     ℹ Error type: BINDER
     --- failed re-building ‘a03_resultsVisualisation.Rmd’
     
     SUMMARY: processing the following files failed:
       ‘a01_summariseMeasurementUse.Rmd’ ‘a03_resultsVisualisation.Rmd’
     
     Error: Vignette re-building failed.
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
       ! HTTP Error: Failed to download extension "excel" at URL "http://extensions.duckdb.org/d54cbbe3df/linux_amd64/excel.duckdb_extension.gz" (HTTP 404)
       Extension "excel" is an existing extension.
       
       For more info, visit https://duckdb.org/docs/current/extensions/troubleshooting?version=d54cbbe3df&platform=linux_amd64&extension=excel
       i Context: rapi_execute
       i Error type: HTTP
       
       [ FAIL 1 | WARN 0 | SKIP 1 | PASS 22 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# OmopSketch (1.1.1)

* GitHub: <https://github.com/OHDSI/OmopSketch>
* Email: <mailto:cecilia.campanile@ndorms.ox.ac.uk>
* GitHub mirror: <https://github.com/cran/OmopSketch>

Run `revdepcheck::revdep_details(, "OmopSketch")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       Actually got a <rlang_error> with message:
         Failed to collect lazy table.
         Caused by error in `DBI::dbSendQuery()`:
         ! Binder Error: PARTITION BY window expressions cannot be volatile
         
         LINE 6: WHEN (NOT(((RANDOM()) IS NULL))) THEN ROW_NUMBER() OVER (PARTITION BY (CASE WHEN (((RANDOM())...
                                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
         i Context: rapi_prepare
         i Error type: BINDER
       ── Error ('test-databaseCharacteristics.R:57:2'): sample works ─────────────────
       Error in `eval(code, test_env)`: object 'x' not found
       Backtrace:
           ▆
        1. ├─testthat::expect_equal(...) at test-databaseCharacteristics.R:57:2
        2. │ └─testthat::quasi_label(enquo(object), label)
        3. │   └─rlang::eval_bare(expr, quo_get_env(quo))
        4. ├─dplyr::pull(...)
        5. ├─dplyr::filter(...)
        6. └─omopgenerics::filterSettings(x, grepl("snapshot", result_type))
        7.   └─omopgenerics::settings(result)
       
       [ FAIL 2 | WARN 0 | SKIP 50 | PASS 15 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# overtureR (0.3.2)

* GitHub: <https://github.com/arthurgailes/overtureR>
* Email: <mailto:agailes1@gmail.com>
* GitHub mirror: <https://github.com/cran/overtureR>

Run `revdepcheck::revdep_details(, "overtureR")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
         5. │   └─DBI::dbSendStatement(conn, statement, ...)
         6. │     ├─DBI::dbSendQuery(conn, statement, ...)
         7. │     └─duckdb::dbSendQuery(conn, statement, ...)
         8. │       └─duckdb (local) .local(conn, statement, ...)
         9. │         └─duckdb:::rethrow_rapi_prepare(conn@conn_ref, statement, env)
        10. │           ├─rlang::try_fetch(...)
        11. │           │ ├─base::tryCatch(...)
        12. │           │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        13. │           │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        14. │           │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        15. │           │ └─base::withCallingHandlers(...)
        16. │           └─duckdb:::rapi_prepare(conn, query, env)
        17. ├─duckdb (local) `<fn>`(...)
        18. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        19. │   └─rlang:::signal_abort(cnd, .file)
        20. │     └─base::signalCondition(cnd)
        21. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        22.   └─handlers[[1L]](cnd)
        23.     └─duckdb:::rethrow_error_from_rapi(e, call)
        24.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 55 | WARN 0 | SKIP 5 | PASS 90 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# quak (0.1.1)

* GitHub: <https://github.com/pedrobtz/quak>
* Email: <mailto:pedrobtz@gmail.com>
* GitHub mirror: <https://github.com/cran/quak>

Run `revdepcheck::revdep_details(, "quak")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       v Set `custom_extension_repository` = "https://c.example"
       v Set `custom_extension_repository` = "https://fake.example"
       i Collecting data from Azure...
       [ FAIL 1 | WARN 0 | SKIP 22 | PASS 327 ]
       
       ══ Skipped tests (22) ══════════════════════════════════════════════════════════
       • On CRAN (21): 'test-azure.R:2:3', 'test-azure.R:22:3', 'test-azure.R:39:3',
         'test-azure.R:56:3', 'test-azure.R:67:3', 'test-azure.R:91:3',
         'test-azure.R:109:3', 'test-azure.R:128:3', 'test-azure.R:139:3',
         'test-azure.R:185:3', 'test-azure.R:208:3', 'test-datasets.R:234:3',
         'test-extensions.R:2:3', 'test-extensions.R:12:3', 'test-extensions.R:22:3',
         'test-extensions.R:39:3', 'test-extensions.R:51:3',
         'test-extensions.R:302:3', 'test-extensions.R:338:3',
         'test-extensions.R:352:3', 'test-extensions.R:367:3'
       • azure extension not installed (1): 'test-tables.R:41:3'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-conditions.R:60:3'): extension unavailable errors include extension metadata and parent ──
       Expected `err$parent` to be an S3 object.
       Actual OO type: none.
       
       [ FAIL 1 | WARN 0 | SKIP 22 | PASS 327 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# querychat (0.4.1)

* GitHub: <https://github.com/posit-dev/querychat>
* Email: <mailto:garrick@posit.co>
* GitHub mirror: <https://github.com/cran/querychat>

Run `revdepcheck::revdep_details(, "querychat")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        10. │           └─duckdb::dbSendQuery(conn, statement, ...)
        11. │             └─duckdb (local) .local(conn, statement, ...)
        12. │               └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
        13. │                 └─duckdb:::duckdb_execute(res)
        14. │                   └─duckdb:::rethrow_rapi_execute(...)
        15. │                     ├─rlang::try_fetch(...)
        16. │                     │ ├─base::tryCatch(...)
        17. │                     │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        18. │                     │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        19. │                     │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        20. │                     │ └─base::withCallingHandlers(...)
        21. │                     └─duckdb:::rapi_execute(stmt, convert_opts)
        22. ├─duckdb (local) `<fn>`(...)
        23. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        24. │   └─rlang:::signal_abort(cnd, .file)
        25. │     └─base::signalCondition(cnd)
        26. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        27.   └─handlers[[1L]](cnd)
        28.     └─duckdb:::rethrow_error_from_rapi(e, call)
        29.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 1 | WARN 12 | SKIP 90 | PASS 2062 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# Rduckhts (2.0.0.0.1.9)

* GitHub: <https://github.com/RGenomicsETL/duckhts>
* Email: <mailto:sounkoutoure@gmail.com>
* GitHub mirror: <https://github.com/cran/Rduckhts>

Run `revdepcheck::revdep_details(, "Rduckhts")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       
       test_bcf.R....................  258 tests OK [E::bgzf_read_block] Invalid BGZF header at offset 447
       [E::bgzf_read] Read block operation failed with error 2 after 0 of 32 bytes
       Error: rapi_execute: Invalid Input Error: read_bcf: failed to read or parse BCF/VCF record (error_type: INVALID_INPUT)
       Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

