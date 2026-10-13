# joinery (1.0.1)

* GitHub: <https://github.com/edubruell/joinery>
* Email: <mailto:eduard.bruell@zew.de>
* GitHub mirror: <https://github.com/cran/joinery>

Run `revdepcheck::revdep_details(, "joinery")` for more info

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
       
       [ FAIL 76 | WARN 0 | SKIP 19 | PASS 2167 ]
       Error:
       ! Test failures.
       Execution halted
     ```

