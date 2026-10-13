# querychat (0.4.1)

* GitHub: <https://github.com/posit-dev/querychat>
* Email: <mailto:garrick@posit.co>
* GitHub mirror: <https://github.com/cran/querychat>

Run `revdepcheck::revdep_details(, "querychat")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        10. │           └─duckdb::dbSendQuery(conn, statement, ...)
        11. │             └─duckdb (local) .local(conn, statement, ...)
        12. │               └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
        13. │                 └─duckdb:::duckdb_execute(res)
        14. │                   └─duckdb:::rethrow_rapi_execute(...)
        15. │                     ├─rlang::try_fetch(...)
        16. │                     │ ├─base::tryCatch(...)
        17. │                     │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        18. │                     │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        19. │                     │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        20. │                     │ └─base::withCallingHandlers(...)
        21. │                     └─duckdb:::rapi_execute(stmt, convert_opts)
        22. ├─duckdb (local) `<fn>`(...)
        23. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        24. │   └─rlang:::signal_abort(cnd, .file)
        25. │     └─base::signalCondition(cnd)
        26. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        27.   └─handlers[[1L]](cnd)
        28.     └─duckdb:::rethrow_error_from_rapi(e, call)
        29.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 1 | WARN 12 | SKIP 90 | PASS 2062 ]
       Error:
       ! Test failures.
       Execution halted
     ```

