# commons (0.1.0)

* GitHub: <https://github.com/posit-dev/commons>
* Email: <mailto:simon.couch@posit.co>
* GitHub mirror: <https://github.com/cran/commons>

Run `revdepcheck::revdep_details(, "commons")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        14. │         └─DBI::dbSendStatement(conn, statement, ...)
        15. │           ├─DBI::dbSendQuery(conn, statement, ...)
        16. │           └─duckdb::dbSendQuery(conn, statement, ...)
        17. │             └─duckdb (local) .local(conn, statement, ...)
        18. │               └─duckdb:::rethrow_rapi_prepare(conn@conn_ref, statement, env)
        19. │                 ├─rlang::try_fetch(...)
        20. │                 │ ├─base::tryCatch(...)
        21. │                 │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        22. │                 │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        23. │                 │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        24. │                 │ └─base::withCallingHandlers(...)
        25. │                 └─duckdb:::rapi_prepare(conn, query, env)
        26. ├─duckdb (local) `<fn>`(...)
        27. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        28. │   └─rlang:::signal_abort(cnd, .file)
        29. │     └─base::signalCondition(cnd)
        30. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        31.   └─handlers[[1L]](cnd)
        32.     └─duckdb:::rethrow_error_from_rapi(e, call)
        33.       └─rlang::abort(msg, call = call)
       
       [ FAIL 13 | WARN 0 | SKIP 86 | PASS 7205 ]
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

