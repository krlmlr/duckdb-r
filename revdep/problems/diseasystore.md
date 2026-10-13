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

