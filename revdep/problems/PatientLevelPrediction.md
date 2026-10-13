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

