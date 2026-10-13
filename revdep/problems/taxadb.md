# taxadb (0.3.0)

* GitHub: <https://github.com/ropensci/taxadb>
* Email: <mailto:cboettig@gmail.com>
* GitHub mirror: <https://github.com/cran/taxadb>

Run `revdepcheck::revdep_details(, "taxadb")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        32. │                 │ └─base::withCallingHandlers(...)
        33. │                 └─duckdb:::rapi_unregister_df(conn, name)
        34. ├─duckdb (local) `<fn>`(...)
        35. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        36. │   └─rlang:::signal_abort(cnd, .file)
        37. │     └─base::signalCondition(cnd)
        38. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        39. │ └─handlers[[1L]](cnd)
        40. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        41. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        42. │       └─rlang:::signal_abort(cnd, .file)
        43. │         └─base::signalCondition(cnd)
        44. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        45. │ └─cli::cli_abort(msg, parent = cnd)
        46. │   └─rlang::abort(...)
        47. │     └─rlang:::signal_abort(cnd, .file)
        48. │       └─base::signalCondition(cnd)
        49. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        50.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        51.     └─rlang::abort(...)
       
       [ FAIL 10 | WARN 0 | SKIP 2 | PASS 100 ]
       Error:
       ! Test failures.
       Execution halted
     ```

