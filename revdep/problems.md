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
       i /tmp/RtmpwLZkzC/working_dir/RtmpHhx3kw/duckdb
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

# BOLDNODE (1.0.0)

* Email: <mailto:spadhye@uoguelph.ca>
* GitHub mirror: <https://github.com/cran/BOLDNODE>

Run `revdepcheck::revdep_details(, "BOLDNODE")` for more info

## Newly broken

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      2. │ └─result %>% summarise(Total_records = n()) %>% collect()
      3. ├─dplyr::collect(.)
      4. └─dbplyr:::collect.tbl_sql(.)
      5.   ├─base::withCallingHandlers(...)
      6.   ├─dbplyr::db_collect(...)
      7.   └─dbplyr:::db_collect.DBIConnection(...)
      8.     ├─DBI::dbSendQuery(con, sql)
      9.     └─DBI::dbSendQuery(con, sql)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'Using_BOLDNODE.Rmd' failed with diagnostics:
     Failed to collect lazy table.
     Caused by error in `DBI::dbSendQuery()`:
     ! Binder Error: Deprecated lambda arrow (->) detected. Please transition to the new lambda syntax, i.e.., lambda x, i: x + i, before DuckDB's next release.
     Use SET lambda_syntax='ENABLE_SINGLE_ARROW' to revert to the deprecated behavior.
     For more information, see https://duckdb.org/docs/current/sql/functions/lambda.html.
     ℹ Context: rapi_prepare
     ℹ Error type: BINDER
     --- failed re-building ‘Using_BOLDNODE.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘Using_BOLDNODE.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# CDMConnector (2.8.0)

* GitHub: <https://github.com/darwin-eu/CDMConnector>
* Email: <mailto:g.inberg@erasmusmc.nl>
* GitHub mirror: <https://github.com/cran/CDMConnector>

Run `revdepcheck::revdep_details(, "CDMConnector")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        22. │               │ └─base::withCallingHandlers(...)
        23. │               └─duckdb:::rapi_unregister_df(conn, name)
        24. ├─duckdb (local) `<fn>`(...)
        25. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        26. │   └─rlang:::signal_abort(cnd, .file)
        27. │     └─base::signalCondition(cnd)
        28. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        29. │ └─handlers[[1L]](cnd)
        30. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        31. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        32. │       └─rlang:::signal_abort(cnd, .file)
        33. │         └─base::signalCondition(cnd)
        34. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        35. │ └─cli::cli_abort(msg, parent = cnd)
        36. │   └─rlang::abort(...)
        37. │     └─rlang:::signal_abort(cnd, .file)
        38. │       └─base::signalCondition(cnd)
        39. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        40.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        41.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 2 | SKIP 45 | PASS 391 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# Characterization (4.1.0)

* GitHub: <https://github.com/OHDSI/Characterization>
* Email: <mailto:jreps@its.jnj.com>
* GitHub mirror: <https://github.com/cran/Characterization>

Run `revdepcheck::revdep_details(, "Characterization")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        31. ├─duckdb (local) `<fn>`(...)
        32. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        33. │   └─rlang:::signal_abort(cnd, .file)
        34. │     └─base::signalCondition(cnd)
        35. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        36. │ └─handlers[[1L]](cnd)
        37. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        38. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        39. │       └─rlang:::signal_abort(cnd, .file)
        40. │         └─base::signalCondition(cnd)
        41. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        42. │ └─cli::cli_abort(msg, parent = cnd)
        43. │   └─rlang::abort(...)
        44. │     └─rlang:::signal_abort(cnd, .file)
        45. │       └─base::signalCondition(cnd)
        46. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        47.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        48.     └─rlang::abort(...)
       
       [ FAIL 4 | WARN 3 | SKIP 8 | PASS 446 ]
       Error:
       ! Test failures.
       Warning message:
       call dbDisconnect() when finished working with a connection 
       Execution halted
     ```

# CohortMethod (6.0.3)

* GitHub: <https://github.com/OHDSI/CohortMethod>
* Email: <mailto:schuemie@ohdsi.org>
* GitHub mirror: <https://github.com/cran/CohortMethod>

Run `revdepcheck::revdep_details(, "CohortMethod")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        25. │                     │ └─base::withCallingHandlers(...)
        26. │                     └─duckdb:::rapi_unregister_df(conn, name)
        27. ├─duckdb (local) `<fn>`(...)
        28. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        29. │   └─rlang:::signal_abort(cnd, .file)
        30. │     └─base::signalCondition(cnd)
        31. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        32. │ └─handlers[[1L]](cnd)
        33. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        34. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        35. │       └─rlang:::signal_abort(cnd, .file)
        36. │         └─base::signalCondition(cnd)
        37. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        38. │ └─cli::cli_abort(msg, parent = cnd)
        39. │   └─rlang::abort(...)
        40. │     └─rlang:::signal_abort(cnd, .file)
        41. │       └─base::signalCondition(cnd)
        42. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        43.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        44.     └─rlang::abort(...)
       
       [ FAIL 6 | WARN 2 | SKIP 1 | PASS 450 ]
       Error:
       ! Test failures.
       Execution halted
     ```

## In both

*   checking re-building of vignette outputs ... WARNING
     ```
     ...
     ! Emergency stop.
     <read *> 
     
     Error: processing vignette 'MultipleAnalyses.Rmd' failed with diagnostics:
     LaTeX failed to compile MultipleAnalyses.tex. See https://yihui.org/tinytex/r/#debugging for debugging tips. See MultipleAnalyses.log for more info.
     --- failed re-building ‘MultipleAnalyses.Rmd’
     
     --- re-building ‘ResultsSchema.Rmd’ using rmarkdown
     --- finished re-building ‘ResultsSchema.Rmd’
     
     --- re-building ‘SingleStudies.Rmd’ using rmarkdown
     ! LaTeX Error: File `lmodern.sty' not found.
     
     ! Emergency stop.
     <read *> 
     
     Error: processing vignette 'SingleStudies.Rmd' failed with diagnostics:
     LaTeX failed to compile SingleStudies.tex. See https://yihui.org/tinytex/r/#debugging for debugging tips. See SingleStudies.log for more info.
     --- failed re-building ‘SingleStudies.Rmd’
     
     SUMMARY: processing the following files failed:
       ‘MultipleAnalyses.Rmd’ ‘SingleStudies.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

# CohortSymmetry (0.3.0)

* GitHub: <https://github.com/OHDSI/CohortSymmetry>
* Email: <mailto:danielle.newby@ndorms.ox.ac.uk>
* GitHub mirror: <https://github.com/cran/CohortSymmetry>

Run `revdepcheck::revdep_details(, "CohortSymmetry")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        25. │                     │ └─base::withCallingHandlers(...)
        26. │                     └─duckdb:::rapi_unregister_df(conn, name)
        27. ├─duckdb (local) `<fn>`(...)
        28. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        29. │   └─rlang:::signal_abort(cnd, .file)
        30. │     └─base::signalCondition(cnd)
        31. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        32. │ └─handlers[[1L]](cnd)
        33. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        34. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        35. │       └─rlang:::signal_abort(cnd, .file)
        36. │         └─base::signalCondition(cnd)
        37. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        38. │ └─cli::cli_abort(msg, parent = cnd)
        39. │   └─rlang::abort(...)
        40. │     └─rlang:::signal_abort(cnd, .file)
        41. │       └─base::signalCondition(cnd)
        42. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        43.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        44.     └─rlang::abort(...)
       
       [ FAIL 18 | WARN 36 | SKIP 55 | PASS 0 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      14.               ├─base::withCallingHandlers(...)
      15.               ├─DBI::dbWriteTable(...)
      16.               └─DBI::dbWriteTable(...)
      17.                 └─duckdb (local) .local(conn, name, value, ...)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'a06_Visualise_temporal_symmetry.Rmd' failed with diagnostics:
     Can't copy data to table dbplyr_tmp_nOibqWbfbE.
     Caused by error in `dbplyr_write_table()`:
     ! Can't write table dbplyr_tmp_nOibqWbfbE.
     Caused by error in `.local()`:
     ! TransactionContext Error: Current transaction is aborted (please ROLLBACK)
     ℹ Context: rapi_unregister_df
     ℹ Error type: TRANSACTION
     --- failed re-building ‘a06_Visualise_temporal_symmetry.Rmd’
     
     SUMMARY: processing the following files failed:
       ‘a01_Introduction.Rmd’ ‘a02_Generate_a_sequence_cohort.Rmd’
       ‘a03_Summarise_sequence_ratios.Rmd’
       ‘a04_Visualise_sequence_ratios.Rmd’
       ‘a05_Summarise_temporal_symmetry.Rmd’
       ‘a06_Visualise_temporal_symmetry.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# Cyclops (3.7.1)

* GitHub: <https://github.com/ohdsi/cyclops>
* Email: <mailto:msuchard@ucla.edu>
* GitHub mirror: <https://github.com/cran/Cyclops>

Run `revdepcheck::revdep_details(, "Cyclops")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        24. │                   │ └─base::withCallingHandlers(...)
        25. │                   └─duckdb:::rapi_unregister_df(conn, name)
        26. ├─duckdb (local) `<fn>`(...)
        27. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        28. │   └─rlang:::signal_abort(cnd, .file)
        29. │     └─base::signalCondition(cnd)
        30. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        31. │ └─handlers[[1L]](cnd)
        32. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        33. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        34. │       └─rlang:::signal_abort(cnd, .file)
        35. │         └─base::signalCondition(cnd)
        36. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        37. │ └─cli::cli_abort(msg, parent = cnd)
        38. │   └─rlang::abort(...)
        39. │     └─rlang:::signal_abort(cnd, .file)
        40. │       └─base::signalCondition(cnd)
        41. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        42.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        43.     └─rlang::abort(...)
       
       [ FAIL 6 | WARN 0 | SKIP 26 | PASS 344 ]
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

# dbMatrix (0.1.0)

* GitHub: <https://github.com/dbverse-org/dbmatrix-r>
* Email: <mailto:ecr7407@gmail.com>
* GitHub mirror: <https://github.com/cran/dbMatrix>

Run `revdepcheck::revdep_details(, "dbMatrix")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        28. │                       │ └─base::withCallingHandlers(...)
        29. │                       └─duckdb:::rapi_unregister_df(conn, name)
        30. ├─duckdb (local) `<fn>`(...)
        31. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        32. │   └─rlang:::signal_abort(cnd, .file)
        33. │     └─base::signalCondition(cnd)
        34. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        35. │ └─handlers[[1L]](cnd)
        36. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        37. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        38. │       └─rlang:::signal_abort(cnd, .file)
        39. │         └─base::signalCondition(cnd)
        40. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        41. │ └─cli::cli_abort(msg, parent = cnd)
        42. │   └─rlang::abort(...)
        43. │     └─rlang:::signal_abort(cnd, .file)
        44. │       └─base::signalCondition(cnd)
        45. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        46.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        47.     └─rlang::abort(...)
       
       [ FAIL 44 | WARN 2 | SKIP 1 | PASS 215 ]
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

# dbProject (0.1.1)

* GitHub: <https://github.com/dbverse-org/dbproject-r>
* Email: <mailto:ecr7407@gmail.com>
* GitHub mirror: <https://github.com/cran/dbProject>

Run `revdepcheck::revdep_details(, "dbProject")` for more info

## Newly broken

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      10.       └─dbplyr:::dbplyr_write_table.DBIConnection(...)
      11.         ├─base::withCallingHandlers(...)
      12.         ├─DBI::dbWriteTable(...)
      13.         └─DBI::dbWriteTable(...)
      14.           └─duckdb (local) .local(conn, name, value, ...)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'getting_started.Rmd' failed with diagnostics:
     Can't copy data to table mtcars.
     Caused by error in `dbplyr_write_table()`:
     ! Can't write table mtcars.
     Caused by error in `.local()`:
     ! TransactionContext Error: Current transaction is aborted (please ROLLBACK)
     ℹ Context: rapi_unregister_df
     ℹ Error type: TRANSACTION
     --- failed re-building ‘getting_started.Rmd’
     
     --- re-building ‘troubleshooting.Rmd’ using rmarkdown
     --- finished re-building ‘troubleshooting.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘getting_started.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# diseasystore (0.3.3)

* GitHub: <https://github.com/ssi-dk/diseasystore>
* Email: <mailto:rske@ssi.dk>
* GitHub mirror: <https://github.com/cran/diseasystore>

Run `revdepcheck::revdep_details(, "diseasystore")` for more info

## Newly broken

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      14.             ├─base::withCallingHandlers(...)
      15.             ├─DBI::dbWriteTable(...)
      16.             └─DBI::dbWriteTable(...)
      17.               └─duckdb (local) .local(conn, name, value, ...)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'extending-diseasystore-example.Rmd' failed with diagnostics:
     Can't copy data to table memory.main."ds.locks".
     Caused by error in `dbplyr_write_table()`:
     ! Can't write table memory.main."ds.locks".
     Caused by error in `.local()`:
     ! TransactionContext Error: Current transaction is aborted (please ROLLBACK)
     ℹ Context: rapi_unregister_df
     ℹ Error type: TRANSACTION
     --- failed re-building ‘extending-diseasystore-example.Rmd’
     
     Warning: Connection already closed.
     --- re-building ‘extending-diseasystore.Rmd’ using rmarkdown
     --- finished re-building ‘extending-diseasystore.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘extending-diseasystore-example.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# dm (1.1.2)

* GitHub: <https://github.com/cynkra/dm>
* Email: <mailto:kirill@cynkra.com>
* GitHub mirror: <https://github.com/cran/dm>

Run `revdepcheck::revdep_details(, "dm")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       Caused by error in `db_copy_to()`:
       ! Can't copy data to table "data_card_1()".
       Caused by error in `dbplyr_write_table()`:
       ! Can't write table "data_card_1()".
       Caused by error in `.local()`:
       ! {"exception_type":"TransactionContext","exception_message":"Current transaction is aborted (please ROLLBACK)"}
       i Context: rapi_register_df
       ── Error ('test-dm.R:96:3'): dm() works for adding tables ──────────────────────
       <purrr_error_indexed/rlang_error/error/condition>
       Error in `map(quos, eval_tidy)`: i In index: 2.
       Caused by error in `db_copy_to()`:
       ! Can't copy data to table "data_card_1()".
       Caused by error in `dbplyr_write_table()`:
       ! Can't write table "data_card_1()".
       Caused by error in `.local()`:
       ! TransactionContext Error: Current transaction is aborted (please ROLLBACK)
       i Context: rapi_unregister_df
       i Error type: TRANSACTION
       
       [ FAIL 4 | WARN 13 | SKIP 391 | PASS 1660 ]
       Error:
       ! Test failures.
       Warning message:
       call dbDisconnect() when finished working with a connection 
       Execution halted
     ```

# DrugExposureDiagnostics (1.2.0)

* GitHub: <https://github.com/darwin-eu/DrugExposureDiagnostics>
* Email: <mailto:g.inberg@erasmusmc.nl>
* GitHub mirror: <https://github.com/cran/DrugExposureDiagnostics>

Run `revdepcheck::revdep_details(, "DrugExposureDiagnostics")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       * Extensions are re-downloaded each session.
       * Secrets are lost.
       i Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       [ FAIL 1 | WARN 137 | SKIP 5 | PASS 509 ]
       
       ══ Skipped tests (5) ═══════════════════════════════════════════════════════════
       • Skipping (1): 'test-shiny.R:2:3'
       • Sys.getenv("TESTDB_USER") == "" is TRUE (1): 'test-SyntheaSqlServer.R:5:3'
       • does not work with latest omopgenerics (3): 'test-runBenchmark.R:2:3',
         'test-runBenchmark.R:36:3', 'test-runBenchmark.R:47:3'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-checkDrugRoutes.R:71:3'): getDrugRoutes ──────────────────────
       Expected `result$route_type` to equal `as.character(c("Oral", "Oral", NA, NA, NA))`.
       Differences:
       `actual`:   "Oral" NA     NA "Oral" NA
       `expected`: "Oral" "Oral" NA NA     NA
       
       
       [ FAIL 1 | WARN 137 | SKIP 5 | PASS 509 ]
       Error:
       ! Test failures.
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
       "http://extensions.duckdb.org/d4355d01c5/linux_amd64/spatial.duckdb_extension.gz"
       (HTTP 404) Extension "spatial" is an existing extension.  For more info,
       visit
       https://duckdb.org/docs/current/extensions/troubleshooting?version=d4355d01c5&platform=linux_amd64&extension=spatial
       ℹ Context: rapi_execute ℹ Error type: HTTP
     ✖ community: HTTP Error: Failed to download extension "spatial" at URL
       "http://community-extensions.duckdb.org/d4355d01c5/linux_amd64/spatial.duckdb_extension.gz"
       (HTTP 404) Extension "spatial" is an existing extension.  For more info,
       visit
       https://duckdb.org/docs/current/extensions/troubleshooting?version=d4355d01c5&platform=linux_amd64&extension=spatial
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

# duckplyr (1.2.1)

* GitHub: <https://github.com/tidyverse/duckplyr>
* Email: <mailto:kirill@cynkra.com>
* GitHub mirror: <https://github.com/cran/duckplyr>

Run `revdepcheck::revdep_details(, "duckplyr")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        30. │ └─handlers[[1L]](cnd)
        31. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        32. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        33. │       └─rlang:::signal_abort(cnd, .file)
        34. │         └─base::signalCondition(cnd)
        35. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        36. │ └─cli::cli_abort(msg, parent = cnd)
        37. │   └─rlang::abort(...)
        38. │     └─rlang:::signal_abort(cnd, .file)
        39. │       └─base::signalCondition(cnd)
        40. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        41.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        42.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 654 | PASS 2582 ]
       Error:
       ! Test failures.
       
       🛠: 2565
       🔨: 1348
       🦆: 1217
       add_count, anti_join, anti_join.data.frame, arrange, arrange.data.frame, compute, count, count.data.frame, cross_join, distinct, distinct.data.frame, do, eval, filter, filter.data.frame, filter_out, full_join, group_by, group_indices, group_keys, group_map, group_modify, group_nest, group_size, group_split, group_trim, head, inner_join, inner_join.data.frame, intersect, left_join, left_join.data.frame, mutate, mutate.data.frame, n_groups, nest_by, nest_join, pull, reframe, relocate, rename, rename_with, right_join, rows_append, rows_delete, rows_insert, rows_patch, rows_update, rows_upsert, rowwise, select, select.data.frame, semi_join, semi_join.data.frame, setdiff, setequal, slice, slice_head, slice_head.data.frame, slice_sample, slice_tail, summarise, summarise.data.frame, symdiff, transmute, ungroup, union_all
       
       00:01:47.625288
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

# GeoTox (1.0.1)

* GitHub: <https://github.com/NIEHS/GeoTox>
* Email: <mailto:skylar.marvel@nih.gov>
* GitHub mirror: <https://github.com/cran/GeoTox>

Run `revdepcheck::revdep_details(, "GeoTox")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
      21. │                           │ └─base::withCallingHandlers(...)
      22. │                           ├─dbplyr:::dbplyr_write_table(...)
      23. │                           └─dbplyr:::dbplyr_write_table.DBIConnection(...)
      24. │                             ├─base::withCallingHandlers(...)
      25. │                             ├─DBI::dbWriteTable(...)
      26. │                             └─DBI::dbWriteTable(...)
      27. │                               └─duckdb (local) .local(conn, name, value, ...)
      28. │                                 └─duckdb::duckdb_unregister(conn, view_name)
      29. │                                   └─duckdb:::rethrow_rapi_unregister_df(conn@conn_ref, enc2utf8(as.character(name)))
      30. │                                     ├─rlang::try_fetch(...)
      31. │                                     │ ├─base::tryCatch(...)
      32. │                                     │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
      33. │                                     │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
      34. │                                     │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
      35. │                                     │ └─base::withCallingHandlers(...)
      36. │                                     └─duckdb:::rapi_unregister_df(conn, name)
      37. ├─duckdb (local) `<fn>`(...)
      38. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
      39. │   └─rlang:::signal_abort(cnd, .file)
      40. │     └─base::signalCondition(cnd)
      41. └─rlang (local) `<fn>`(`<dckdb_rr>`)
      42.   └─handlers[[1L]](cnd)
      43.     └─duckdb:::rethrow_error_from_rapi(e, call)
      44.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
     Execution halted
     ```

*   checking tests ... ERROR
     ```
     ...
        24. │                     │ └─base::withCallingHandlers(...)
        25. │                     └─duckdb:::rapi_unregister_df(conn, name)
        26. ├─duckdb (local) `<fn>`(...)
        27. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        28. │   └─rlang:::signal_abort(cnd, .file)
        29. │     └─base::signalCondition(cnd)
        30. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        31. │ └─handlers[[1L]](cnd)
        32. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        33. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        34. │       └─rlang:::signal_abort(cnd, .file)
        35. │         └─base::signalCondition(cnd)
        36. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        37. │ └─cli::cli_abort(msg, parent = cnd)
        38. │   └─rlang::abort(...)
        39. │     └─rlang:::signal_abort(cnd, .file)
        40. │       └─base::signalCondition(cnd)
        41. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        42.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        43.     └─rlang::abort(...)
       
       [ FAIL 39 | WARN 0 | SKIP 0 | PASS 124 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# joinery (1.0.1)

* GitHub: <https://github.com/edubruell/joinery>
* Email: <mailto:eduard.bruell@zew.de>
* GitHub mirror: <https://github.com/cran/joinery>

Run `revdepcheck::revdep_details(, "joinery")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        23. │                 │ └─base::withCallingHandlers(...)
        24. │                 └─duckdb:::rapi_unregister_df(conn, name)
        25. ├─duckdb (local) `<fn>`(...)
        26. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        27. │   └─rlang:::signal_abort(cnd, .file)
        28. │     └─base::signalCondition(cnd)
        29. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        30. │ └─handlers[[1L]](cnd)
        31. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        32. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        33. │       └─rlang:::signal_abort(cnd, .file)
        34. │         └─base::signalCondition(cnd)
        35. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        36. │ └─cli::cli_abort(msg, parent = cnd)
        37. │   └─rlang::abort(...)
        38. │     └─rlang:::signal_abort(cnd, .file)
        39. │       └─base::signalCondition(cnd)
        40. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        41.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        42.     └─rlang::abort(...)
       
       [ FAIL 76 | WARN 0 | SKIP 19 | PASS 2167 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# mfdb (7.4-0)

* Email: <mailto:lentinj@shuttlethread.com>
* GitHub mirror: <https://github.com/cran/mfdb>

Run `revdepcheck::revdep_details(, "mfdb")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
     2026-10-13 18:26:29.878779 INFO:mfdb:Dumping table stomach_state
     2026-10-13 18:26:29.879901 INFO:mfdb:Dumping table digestion_stage
     2026-10-13 18:26:29.880957 INFO:mfdb:Dumping table sampling_type
     2026-10-13 18:26:29.881876 INFO:mfdb:Dumping table population
     2026-10-13 18:26:29.882754 INFO:mfdb:Dumping table data_source
     2026-10-13 18:26:29.883627 INFO:mfdb:Dumping table index_type
     2026-10-13 18:26:29.884587 INFO:mfdb:Dumping table port
     2026-10-13 18:26:29.885443 INFO:mfdb:Dumping table trip
     2026-10-13 18:26:29.886366 INFO:mfdb:Dumping table tow
     2026-10-13 18:26:29.887325 INFO:mfdb:Dumping table vessel
     2026-10-13 18:26:29.888179 INFO:mfdb:Dumping table case_study
     2026-10-13 18:26:29.889163 INFO:mfdb:Dumping table survey_index
     2026-10-13 18:26:29.890017 INFO:mfdb:Dumping table division
     2026-10-13 18:26:29.890825 INFO:mfdb:Dumping table sample
     2026-10-13 18:26:29.891778 INFO:mfdb:Dumping table predator
     2026-10-13 18:26:29.892663 INFO:mfdb:Dumping table prey
     > mfdb_cs_restore(mdb_in, dump_path)
     2026-10-13 18:26:30.104165 INFO:mfdb:Restoring table institute
     2026-10-13 18:26:30.166093 WARNING:mfdb:Rolling back transaction...
     Error in .local(conn, name, value, ...) : 
       TransactionContext Error: Current transaction is aborted (please ROLLBACK)
     ℹ Context: rapi_unregister_df
     ℹ Error type: TRANSACTION
     Calls: mfdb_cs_restore -> mfdb_transaction
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
       ! HTTP Error: Failed to download extension "excel" at URL "http://extensions.duckdb.org/d4355d01c5/linux_amd64/excel.duckdb_extension.gz" (HTTP 404)
       Extension "excel" is an existing extension.
       
       For more info, visit https://duckdb.org/docs/current/extensions/troubleshooting?version=d4355d01c5&platform=linux_amd64&extension=excel
       i Context: rapi_execute
       i Error type: HTTP
       
       [ FAIL 1 | WARN 0 | SKIP 1 | PASS 22 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# orbital (0.7.0)

* GitHub: <https://github.com/tidymodels/orbital>
* Email: <mailto:emil.hvitfeldt@posit.co>
* GitHub mirror: <https://github.com/cran/orbital>

Run `revdepcheck::revdep_details(, "orbital")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        22. │               │ └─base::withCallingHandlers(...)
        23. │               └─duckdb:::rapi_unregister_df(conn, name)
        24. ├─duckdb (local) `<fn>`(...)
        25. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        26. │   └─rlang:::signal_abort(cnd, .file)
        27. │     └─base::signalCondition(cnd)
        28. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        29. │ └─handlers[[1L]](cnd)
        30. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        31. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        32. │       └─rlang:::signal_abort(cnd, .file)
        33. │         └─base::signalCondition(cnd)
        34. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        35. │ └─cli::cli_abort(msg, parent = cnd)
        36. │   └─rlang::abort(...)
        37. │     └─rlang:::signal_abort(cnd, .file)
        38. │       └─base::signalCondition(cnd)
        39. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        40.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        41.     └─rlang::abort(...)
       
       [ FAIL 96 | WARN 5 | SKIP 190 | PASS 973 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# overtureR (0.3.1)

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

# PatientLevelPrediction (6.7.0)

* GitHub: <https://github.com/OHDSI/PatientLevelPrediction>
* Email: <mailto:e.fridgeirsson@erasmusmc.nl>
* GitHub mirror: <https://github.com/cran/PatientLevelPrediction>

Run `revdepcheck::revdep_details(, "PatientLevelPrediction")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        26. │                 │ └─base::withCallingHandlers(...)
        27. │                 └─duckdb:::rapi_unregister_df(conn, name)
        28. ├─duckdb (local) `<fn>`(...)
        29. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        30. │   └─rlang:::signal_abort(cnd, .file)
        31. │     └─base::signalCondition(cnd)
        32. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        33. │ └─handlers[[1L]](cnd)
        34. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        35. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        36. │       └─rlang:::signal_abort(cnd, .file)
        37. │         └─base::signalCondition(cnd)
        38. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        39. │ └─cli::cli_abort(msg, parent = cnd)
        40. │   └─rlang::abort(...)
        41. │     └─rlang:::signal_abort(cnd, .file)
        42. │       └─base::signalCondition(cnd)
        43. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        44.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        45.     └─rlang::abort(...)
       
       [ FAIL 8 | WARN 0 | SKIP 149 | PASS 1118 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# posologyr (1.2.8)

* GitHub: <https://github.com/levenc/posologyr>
* Email: <mailto:cyril.leven@chu-brest.fr>
* GitHub mirror: <https://github.com/cran/posologyr>

Run `revdepcheck::revdep_details(, "posologyr")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
       Running ‘testthat.R’
     Running the tests in ‘tests/testthat.R’ failed.
     Complete output:
       > library(rxode2)
       rxode2 5.1.7.1 using 2 threads (see ?getRxThreads)
         no cache: create with `rxCreateCache()`
       > library(posologyr)
       > library(testthat)
       > setRxThreads(2L) #for CRAN, following the advice of mattfidler
       > 
       > test_check("posologyr")
       malloc(): unsorted double linked list corrupted
       Aborted (core dumped)
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

# Rduckhts (1.5.2-0.1.5)

* GitHub: <https://github.com/RGenomicsETL/duckhts>
* Email: <mailto:sounkoutoure@gmail.com>
* GitHub mirror: <https://github.com/cran/Rduckhts>

Run `revdepcheck::revdep_details(, "Rduckhts")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     Running examples in ‘Rduckhts-Ex.R’ failed
     The error most likely occurred in:
     
     > base::assign(".ptime", proc.time(), pos = "CheckExEnv")
     > ### Name: detect_complex_types
     > ### Title: Detect Complex Types in DuckDB Table
     > ### Aliases: detect_complex_types
     > 
     > ### ** Examples
     > 
     > library(DBI)
     > library(duckdb)
     > 
     > con <- rduckhts_connect()
     [duckhts] failed DuckVEP SQL registration: Binder Error: Deprecated lambda arrow (->) detected. Please transition to the new lambda syntax, i.e.., lambda x, i: x + i, before DuckDB's next release.
     Use SET lambda_syntax='ENABLE_SINGLE_ARROW' to revert to the deprecated behavior.
     For more information, see https://duckdb.org/docs/current/sql/functions/lambda.html.
     Error: rapi_execute: FATAL Error: Extension '<lib>/Rduckhts.Rcheck/Rduckhts/duckhts_extension/build/duckhts.duckdb_extension' failed to initialize but did not return an error. This indicates an error in the extension: C API extensions should return a boolean `true` to indicate successful initialization. This means that the Extension may be partially initialized resulting in an inconsistent state of DuckDB. (error_type: FATAL)
     Execution halted
     ```

*   checking tests ... ERROR
     ```
       Running ‘tinytest.R’
     Running the tests in ‘tests/tinytest.R’ failed.
     Complete output:
       > if (requireNamespace("tinytest", quietly = TRUE)) {
       +   tinytest::test_package("Rduckhts")
       + } else {
       +   message("tinytest not available; skipping tests")
       + }
       
       test_bam_bed_coverage.R.......    0 tests    
       test_bam_bed_coverage.R.......    0 tests    
       test_bam_bed_coverage.R.......    0 tests    [duckhts] failed DuckVEP SQL registration: Binder Error: Deprecated lambda arrow (->) detected. Please transition to the new lambda syntax, i.e.., lambda x, i: x + i, before DuckDB's next release.
       Use SET lambda_syntax='ENABLE_SINGLE_ARROW' to revert to the deprecated behavior.
       For more information, see https://duckdb.org/docs/current/sql/functions/lambda.html.
       Error: rapi_execute: FATAL Error: Extension '<lib>/Rduckhts.Rcheck/Rduckhts/duckhts_extension/build/duckhts.duckdb_extension' failed to initialize but did not return an error. This indicates an error in the extension: C API extensions should return a boolean `true` to indicate successful initialization. This means that the Extension may be partially initialized resulting in an inconsistent state of DuckDB. (error_type: FATAL)
       Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

# SCDB (0.6.2)

* GitHub: <https://github.com/ssi-dk/SCDB>
* Email: <mailto:rske@ssi.dk>
* GitHub mirror: <https://github.com/cran/SCDB>

Run `revdepcheck::revdep_details(, "SCDB")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        23. │                 │ └─base::withCallingHandlers(...)
        24. │                 └─duckdb:::rapi_unregister_df(conn, name)
        25. ├─duckdb (local) `<fn>`(...)
        26. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        27. │   └─rlang:::signal_abort(cnd, .file)
        28. │     └─base::signalCondition(cnd)
        29. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        30. │ └─handlers[[1L]](cnd)
        31. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        32. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        33. │       └─rlang:::signal_abort(cnd, .file)
        34. │         └─base::signalCondition(cnd)
        35. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        36. │ └─cli::cli_abort(msg, parent = cnd)
        37. │   └─rlang::abort(...)
        38. │     └─rlang:::signal_abort(cnd, .file)
        39. │       └─base::signalCondition(cnd)
        40. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        41.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        42.     └─rlang::abort(...)
       
       [ FAIL 4 | WARN 0 | SKIP 1 | PASS 760 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      11.         ├─base::withCallingHandlers(...)
      12.         ├─DBI::dbWriteTable(...)
      13.         └─DBI::dbWriteTable(...)
      14.           └─duckdb (local) .local(conn, name, value, ...)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'delta-loading.Rmd' failed with diagnostics:
     Can't copy data to table example_data.
     Caused by error in `dbplyr_write_table()`:
     ! Can't write table example_data.
     Caused by error in `.local()`:
     ! TransactionContext Error: Current transaction is aborted (please ROLLBACK)
     ℹ Context: rapi_unregister_df
     ℹ Error type: TRANSACTION
     --- failed re-building ‘delta-loading.Rmd’
     
     --- re-building ‘slowly-changing-dimension.Rmd’ using rmarkdown
     Loading required namespace: tidyverse
     --- finished re-building ‘slowly-changing-dimension.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘delta-loading.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

# sqlm (0.1.0)

* Email: <mailto:alejandro.hagan@outlook.com>
* GitHub mirror: <https://github.com/cran/sqlm>

Run `revdepcheck::revdep_details(, "sqlm")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        22. │               │ └─base::withCallingHandlers(...)
        23. │               └─duckdb:::rapi_unregister_df(conn, name)
        24. ├─duckdb (local) `<fn>`(...)
        25. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        26. │   └─rlang:::signal_abort(cnd, .file)
        27. │     └─base::signalCondition(cnd)
        28. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        29. │ └─handlers[[1L]](cnd)
        30. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        31. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        32. │       └─rlang:::signal_abort(cnd, .file)
        33. │         └─base::signalCondition(cnd)
        34. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        35. │ └─cli::cli_abort(msg, parent = cnd)
        36. │   └─rlang::abort(...)
        37. │     └─rlang:::signal_abort(cnd, .file)
        38. │       └─base::signalCondition(cnd)
        39. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        40.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        41.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 0 | PASS 0 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# taxadb (0.3.0)

* GitHub: <https://github.com/ropensci/taxadb>
* Email: <mailto:cboettig@gmail.com>
* GitHub mirror: <https://github.com/cran/taxadb>

Run `revdepcheck::revdep_details(, "taxadb")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        32. │                 │ └─base::withCallingHandlers(...)
        33. │                 └─duckdb:::rapi_unregister_df(conn, name)
        34. ├─duckdb (local) `<fn>`(...)
        35. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        36. │   └─rlang:::signal_abort(cnd, .file)
        37. │     └─base::signalCondition(cnd)
        38. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        39. │ └─handlers[[1L]](cnd)
        40. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        41. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        42. │       └─rlang:::signal_abort(cnd, .file)
        43. │         └─base::signalCondition(cnd)
        44. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        45. │ └─cli::cli_abort(msg, parent = cnd)
        46. │   └─rlang::abort(...)
        47. │     └─rlang:::signal_abort(cnd, .file)
        48. │       └─base::signalCondition(cnd)
        49. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        50.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        51.     └─rlang::abort(...)
       
       [ FAIL 10 | WARN 0 | SKIP 2 | PASS 100 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# tidier (0.3.0)

* GitHub: <https://github.com/talegari/tidier>
* Email: <mailto:sri.teach@gmail.com>
* GitHub mirror: <https://github.com/cran/tidier>

Run `revdepcheck::revdep_details(, "tidier")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        22. │               │ └─base::withCallingHandlers(...)
        23. │               └─duckdb:::rapi_unregister_df(conn, name)
        24. ├─duckdb (local) `<fn>`(...)
        25. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        26. │   └─rlang:::signal_abort(cnd, .file)
        27. │     └─base::signalCondition(cnd)
        28. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        29. │ └─handlers[[1L]](cnd)
        30. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        31. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        32. │       └─rlang:::signal_abort(cnd, .file)
        33. │         └─base::signalCondition(cnd)
        34. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        35. │ └─cli::cli_abort(msg, parent = cnd)
        36. │   └─rlang::abort(...)
        37. │     └─rlang:::signal_abort(cnd, .file)
        38. │       └─base::signalCondition(cnd)
        39. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        40.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        41.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 0 | PASS 7 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# TreatmentPatterns (3.1.2)

* GitHub: <https://github.com/darwin-eu/TreatmentPatterns>
* Email: <mailto:m.l.vankessel@erasmusmc.nl>
* GitHub mirror: <https://github.com/cran/TreatmentPatterns>

Run `revdepcheck::revdep_details(, "TreatmentPatterns")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        26. │                         │ └─base::withCallingHandlers(...)
        27. │                         └─duckdb:::rapi_unregister_df(conn, name)
        28. ├─duckdb (local) `<fn>`(...)
        29. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        30. │   └─rlang:::signal_abort(cnd, .file)
        31. │     └─base::signalCondition(cnd)
        32. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        33. │ └─handlers[[1L]](cnd)
        34. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        35. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        36. │       └─rlang:::signal_abort(cnd, .file)
        37. │         └─base::signalCondition(cnd)
        38. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        39. │ └─cli::cli_abort(msg, parent = cnd)
        40. │   └─rlang::abort(...)
        41. │     └─rlang:::signal_abort(cnd, .file)
        42. │       └─base::signalCondition(cnd)
        43. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        44.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        45.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 105 | PASS 1 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
      17.                   └─DBI::dbWriteTable(...)
      18.                     └─duckdb (local) .local(conn, name, value, ...)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'a030_Evaluating_Output.Rmd' failed with diagnostics:
     Can't copy data to table dbplyr_tmp_IniPFzx9w2.
     Caused by error in `dbplyr_write_table()`:
     ! Can't write table dbplyr_tmp_IniPFzx9w2.
     Caused by error in `.local()`:
     ! TransactionContext Error: Current transaction is aborted (please ROLLBACK)
     ℹ Context: rapi_unregister_df
     ℹ Error type: TRANSACTION
     --- failed re-building ‘a030_Evaluating_Output.Rmd’
     
     --- re-building ‘a998_Strategus.Rmd’ using rmarkdown
     --- finished re-building ‘a998_Strategus.Rmd’
     
     --- re-building ‘a999_Publications-Presentations.Rmd’ using rmarkdown
     --- finished re-building ‘a999_Publications-Presentations.Rmd’
     
     SUMMARY: processing the following files failed:
       ‘a010_Computing_Pathways.Rmd’ ‘a030_Evaluating_Output.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

