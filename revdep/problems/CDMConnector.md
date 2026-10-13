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

