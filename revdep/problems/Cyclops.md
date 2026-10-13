# Cyclops (3.7.1)

* GitHub: <https://github.com/ohdsi/cyclops>
* Email: <mailto:msuchard@ucla.edu>
* GitHub mirror: <https://github.com/cran/Cyclops>

Run `revdepcheck::revdep_details(, "Cyclops")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        24. │                   │ └─base::withCallingHandlers(...)
        25. │                   └─duckdb:::rapi_unregister_df(conn, name)
        26. ├─duckdb (local) `<fn>`(...)
        27. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        28. │   └─rlang:::signal_abort(cnd, .file)
        29. │     └─base::signalCondition(cnd)
        30. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        31. │ └─handlers[[1L]](cnd)
        32. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        33. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        34. │       └─rlang:::signal_abort(cnd, .file)
        35. │         └─base::signalCondition(cnd)
        36. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        37. │ └─cli::cli_abort(msg, parent = cnd)
        38. │   └─rlang::abort(...)
        39. │     └─rlang:::signal_abort(cnd, .file)
        40. │       └─base::signalCondition(cnd)
        41. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        42.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        43.     └─rlang::abort(...)
       
       [ FAIL 6 | WARN 0 | SKIP 26 | PASS 344 ]
       Error:
       ! Test failures.
       Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

