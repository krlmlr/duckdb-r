# overtureR (0.3.1)

* GitHub: <https://github.com/arthurgailes/overtureR>
* Email: <mailto:agailes1@gmail.com>
* GitHub mirror: <https://github.com/cran/overtureR>

Run `revdepcheck::revdep_details(, "overtureR")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
         5. │   └─DBI::dbSendStatement(conn, statement, ...)
         6. │     ├─DBI::dbSendQuery(conn, statement, ...)
         7. │     └─duckdb::dbSendQuery(conn, statement, ...)
         8. │       └─duckdb (local) .local(conn, statement, ...)
         9. │         └─duckdb:::rethrow_rapi_prepare(conn@conn_ref, statement, env)
        10. │           ├─rlang::try_fetch(...)
        11. │           │ ├─base::tryCatch(...)
        12. │           │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        13. │           │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        14. │           │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        15. │           │ └─base::withCallingHandlers(...)
        16. │           └─duckdb:::rapi_prepare(conn, query, env)
        17. ├─duckdb (local) `<fn>`(...)
        18. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        19. │   └─rlang:::signal_abort(cnd, .file)
        20. │     └─base::signalCondition(cnd)
        21. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        22.   └─handlers[[1L]](cnd)
        23.     └─duckdb:::rethrow_error_from_rapi(e, call)
        24.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 55 | WARN 0 | SKIP 5 | PASS 90 ]
       Error:
       ! Test failures.
       Execution halted
     ```

