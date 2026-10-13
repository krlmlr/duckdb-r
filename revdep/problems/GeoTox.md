# GeoTox (1.0.1)

* GitHub: <https://github.com/NIEHS/GeoTox>
* Email: <mailto:skylar.marvel@nih.gov>
* GitHub mirror: <https://github.com/cran/GeoTox>

Run `revdepcheck::revdep_details(, "GeoTox")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
      21. │                           │ └─base::withCallingHandlers(...)
      22. │                           ├─dbplyr:::dbplyr_write_table(...)
      23. │                           └─dbplyr:::dbplyr_write_table.DBIConnection(...)
      24. │                             ├─base::withCallingHandlers(...)
      25. │                             ├─DBI::dbWriteTable(...)
      26. │                             └─DBI::dbWriteTable(...)
      27. │                               └─duckdb (local) .local(conn, name, value, ...)
      28. │                                 └─duckdb::duckdb_unregister(conn, view_name)
      29. │                                   └─duckdb:::rethrow_rapi_unregister_df(conn@conn_ref, enc2utf8(as.character(name)))
      30. │                                     ├─rlang::try_fetch(...)
      31. │                                     │ ├─base::tryCatch(...)
      32. │                                     │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
      33. │                                     │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
      34. │                                     │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
      35. │                                     │ └─base::withCallingHandlers(...)
      36. │                                     └─duckdb:::rapi_unregister_df(conn, name)
      37. ├─duckdb (local) `<fn>`(...)
      38. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
      39. │   └─rlang:::signal_abort(cnd, .file)
      40. │     └─base::signalCondition(cnd)
      41. └─rlang (local) `<fn>`(`<dckdb_rr>`)
      42.   └─handlers[[1L]](cnd)
      43.     └─duckdb:::rethrow_error_from_rapi(e, call)
      44.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
     Execution halted
     ```

*   checking tests ... ERROR
     ```
     ...
        24. │                     │ └─base::withCallingHandlers(...)
        25. │                     └─duckdb:::rapi_unregister_df(conn, name)
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
       
       [ FAIL 39 | WARN 0 | SKIP 0 | PASS 124 ]
       Error:
       ! Test failures.
       Execution halted
     ```

