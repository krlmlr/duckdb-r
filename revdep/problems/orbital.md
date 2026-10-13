# orbital (0.7.0)

* GitHub: <https://github.com/tidymodels/orbital>
* Email: <mailto:emil.hvitfeldt@posit.co>
* GitHub mirror: <https://github.com/cran/orbital>

Run `revdepcheck::revdep_details(, "orbital")` for more info

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
       
       [ FAIL 96 | WARN 5 | SKIP 190 | PASS 973 ]
       Error:
       ! Test failures.
       Execution halted
     ```

