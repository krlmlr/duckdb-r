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

