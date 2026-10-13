# dbMatrix (0.1.0)

* GitHub: <https://github.com/dbverse-org/dbmatrix-r>
* Email: <mailto:ecr7407@gmail.com>
* GitHub mirror: <https://github.com/cran/dbMatrix>

Run `revdepcheck::revdep_details(, "dbMatrix")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        28. │                       │ └─base::withCallingHandlers(...)
        29. │                       └─duckdb:::rapi_unregister_df(conn, name)
        30. ├─duckdb (local) `<fn>`(...)
        31. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        32. │   └─rlang:::signal_abort(cnd, .file)
        33. │     └─base::signalCondition(cnd)
        34. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        35. │ └─handlers[[1L]](cnd)
        36. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        37. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        38. │       └─rlang:::signal_abort(cnd, .file)
        39. │         └─base::signalCondition(cnd)
        40. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        41. │ └─cli::cli_abort(msg, parent = cnd)
        42. │   └─rlang::abort(...)
        43. │     └─rlang:::signal_abort(cnd, .file)
        44. │       └─base::signalCondition(cnd)
        45. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        46.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        47.     └─rlang::abort(...)
       
       [ FAIL 44 | WARN 2 | SKIP 1 | PASS 215 ]
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

