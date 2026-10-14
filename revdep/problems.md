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
       i /tmp/RtmpUMFu9K/working_dir/RtmpXje49l/duckdb
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

# datacaged (0.2.1)

* GitHub: <https://github.com/gecomt/datacaged>
* Email: <mailto:alexsandro.prado@ufersa.edu.br>
* GitHub mirror: <https://github.com/cran/datacaged>

Run `revdepcheck::revdep_details(, "datacaged")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        5.     └─datacaged::caged_connect(db_path, read_only = TRUE, quiet = TRUE)
        6.       └─duckdb::duckdb(dbdir = db_path, read_only = read_only)
        7.         └─duckdb:::duckdb_impl(...)
        8.           └─duckdb:::warn_instance_settings_ignored(...)
        9.             └─rlang::abort(...)
       ── Error ('test-pipelines.R:216:3'): caged_adjustments_load() cria banco com tabela caged_ajustes ──
       Error in `duckdb::duckdb(dbdir = db_path, read_only = read_only)`: `read_only` can't be applied to the database instance for `/tmp/RtmpBX0UhV/working_dir/RtmpzpfYP3/caged_adj_mock_31177c2796b.duckdb`, which already exists.
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
        7.         └─duckdb:::duckdb_impl(...)
        8.           └─duckdb:::warn_instance_settings_ignored(...)
        9.             └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 5 | PASS 187 ]
       Error:
       ! Test failures.
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
       `actual`:   NA     "Oral" NA "Oral" NA
       `expected`: "Oral" "Oral" NA NA     NA
       
       
       [ FAIL 1 | WARN 137 | SKIP 5 | PASS 509 ]
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

