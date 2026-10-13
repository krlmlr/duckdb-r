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

