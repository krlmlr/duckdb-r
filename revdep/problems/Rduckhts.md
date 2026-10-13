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

