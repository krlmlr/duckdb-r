# Characterization (4.1.0)

* GitHub: <https://github.com/OHDSI/Characterization>
* Email: <mailto:jreps@its.jnj.com>
* GitHub mirror: <https://github.com/cran/Characterization>

Run `revdepcheck::revdep_details(, "Characterization")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        31. ├─duckdb (local) `<fn>`(...)
        32. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        33. │   └─rlang:::signal_abort(cnd, .file)
        34. │     └─base::signalCondition(cnd)
        35. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        36. │ └─handlers[[1L]](cnd)
        37. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        38. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        39. │       └─rlang:::signal_abort(cnd, .file)
        40. │         └─base::signalCondition(cnd)
        41. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        42. │ └─cli::cli_abort(msg, parent = cnd)
        43. │   └─rlang::abort(...)
        44. │     └─rlang:::signal_abort(cnd, .file)
        45. │       └─base::signalCondition(cnd)
        46. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        47.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        48.     └─rlang::abort(...)
       
       [ FAIL 4 | WARN 3 | SKIP 8 | PASS 446 ]
       Error:
       ! Test failures.
       Warning message:
       call dbDisconnect() when finished working with a connection 
       Execution halted
     ```

