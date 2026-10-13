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

