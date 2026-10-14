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

