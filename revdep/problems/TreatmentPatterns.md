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

