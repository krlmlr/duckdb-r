# dbMatrix (0.1.0)

* GitHub: <https://github.com/dbverse-org/dbmatrix-r>
* Email: <mailto:ecr7407@gmail.com>
* GitHub mirror: <https://github.com/cran/dbMatrix>

Run `revdepcheck::revdep_details(, "dbMatrix")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
       4. │ └─DBI::dbExecute(con, sql)
       5. │   ├─DBI::dbSendStatement(conn, statement, ...)
       6. │   └─DBI::dbSendStatement(conn, statement, ...)
       7. │     ├─DBI::dbSendQuery(conn, statement, ...)
       8. │     └─duckdb::dbSendQuery(conn, statement, ...)
       9. │       └─duckdb (local) .local(conn, statement, ...)
      10. │         └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
      11. │           └─duckdb:::duckdb_execute(res)
      12. │             └─duckdb:::rethrow_rapi_execute(...)
      13. │               ├─rlang::try_fetch(...)
      14. │               │ ├─base::tryCatch(...)
      15. │               │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
      16. │               │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
      17. │               │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
      18. │               │ └─base::withCallingHandlers(...)
      19. │               └─duckdb:::rapi_execute(stmt, convert_opts)
      20. ├─duckdb (local) `<fn>`(...)
      21. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
      22. │   └─rlang:::signal_abort(cnd, .file)
      23. │     └─base::signalCondition(cnd)
      24. └─rlang (local) `<fn>`(`<dckdb_rr>`)
      25.   └─handlers[[1L]](cnd)
      26.     └─duckdb:::rethrow_error_from_rapi(e, call)
      27.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
     Execution halted
     ```

*   checking tests ... ERROR
     ```
     ...
         8. │     └─duckdb::dbSendQuery(conn, statement, ...)
         9. │       └─duckdb (local) .local(conn, statement, ...)
        10. │         └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
        11. │           └─duckdb:::duckdb_execute(res)
        12. │             └─duckdb:::rethrow_rapi_execute(...)
        13. │               ├─rlang::try_fetch(...)
        14. │               │ ├─base::tryCatch(...)
        15. │               │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        16. │               │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        17. │               │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        18. │               │ └─base::withCallingHandlers(...)
        19. │               └─duckdb:::rapi_execute(stmt, convert_opts)
        20. ├─duckdb (local) `<fn>`(...)
        21. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        22. │   └─rlang:::signal_abort(cnd, .file)
        23. │     └─base::signalCondition(cnd)
        24. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        25.   └─handlers[[1L]](cnd)
        26.     └─duckdb:::rethrow_error_from_rapi(e, call)
        27.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 20 | WARN 2 | SKIP 1 | PASS 203 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
       3.   └─dbMatrix:::as.dbMatrix.matrix(...)
       4.     ├─DBI::dbExecute(con, sql)
       5.     └─DBI::dbExecute(con, sql)
       6.       ├─DBI::dbSendStatement(conn, statement, ...)
       7.       └─DBI::dbSendStatement(conn, statement, ...)
       8.         ├─DBI::dbSendQuery(conn, statement, ...)
       9.         └─duckdb::dbSendQuery(conn, statement, ...)
      10.           └─duckdb (local) .local(conn, statement, ...)
      11.             └─duckdb:::duckdb_result(connection = conn, stmt_lst = stmt_lst, arrow = arrow)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'operations.Rmd' failed with diagnostics:
     Invalid Input Error: Reading a column of the data frame was interrupted
     ℹ Context: rapi_execute
     ℹ Error type: INVALID_INPUT
     --- failed re-building ‘operations.Rmd’
     
     --- re-building ‘overview.Rmd’ using rmarkdown
     --- finished re-building ‘overview.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘operations.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

