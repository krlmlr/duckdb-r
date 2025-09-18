# dbi.table

<details>

* Version: 1.0.4
* GitHub: https://github.com/kjellpk/dbi.table
* Source code: https://github.com/cran/dbi.table
* Date/Publication: 2025-06-28 18:20:02 UTC
* Number of recursive dependencies: 68

Run `revdepcheck::cloud_details(, "dbi.table")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Complete output:
      > # This file is part of the standard setup for testthat.
      > # It is recommended that you do not modify it.
      > #
      > # Where should you do additional test configuration?
      > # Learn more about the roles of various files in:
      > # * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
      > # * https://testthat.r-lib.org/articles/special-files.html
      > 
      > library(testthat)
      > library(dbi.table)
      > 
      > test_check("dbi.table")
      [ FAIL 1 | WARN 0 | SKIP 2 | PASS 386 ]
      
      ══ Skipped tests (2) ═══════════════════════════════════════════════════════════
      • On CRAN (2): 'test-mariadb.R:10:3', 'test-postgres.R:11:3'
      
      ══ Failed tests ════════════════════════════════════════════════════════════════
      ── Error ('test-data.table-examples.R:102:5'): dbi.table works on data.table help examples [memory_duckdb] ──
      Error in `dbSendQuery(conn, statement, ...)`: Catalog Error: Table with name IN_QUERY_CTE24 does not exist!
      Did you mean "DBI_TABLE_PACKAGE_TEMPORARY_TABLE_16"?
      
      LINE 5:   FROM IN_QUERY_CTE24 AS IN_QUERY_CTE24
                     ^
      i Context: rapi_prepare
      i Error type: CATALOG
      i Raw message: Table with name IN_QUERY_CTE24 does not exist!
      Did you mean "DBI_TABLE_PACKAGE_TEMPORARY_TABLE_16"?
      
      LINE 5:   FROM IN_QUERY_CTE24 AS IN_QUERY_CTE24
                     ^
      Backtrace:
           ▆
        1. ├─testthat::expect_true(...) at test-data.table-examples.R:102:5
        2. │ └─testthat::quasi_label(enquo(object), label, arg = "object")
        3. │   └─rlang::eval_bare(expr, quo_get_env(quo))
        4. ├─dbi.table::reference.test(...)
        5. │ ├─data.table::as.data.table(dbit_eval)
        6. │ └─dbi.table (local) as.data.table.dbi.table(dbit_eval)
        7. │   ├─base::as.data.frame(x, n = n, strict = n > 0L)
        8. │   └─dbi.table:::as.data.frame.dbi.table(x, n = n, strict = n > 0L)
        9. │     ├─DBI::dbGetQuery(x, write_select_query(x, n, strict))
       10. │     └─DBI::dbGetQuery(x, write_select_query(x, n, strict))
       11. │       ├─dbi.table:::stry(...)
       12. │       │ ├─base::suppressWarnings(try(expr, silent = TRUE))
       13. │       │ │ └─base::withCallingHandlers(...)
       14. │       │ └─base::try(expr, silent = TRUE)
       15. │       │   └─base::tryCatch(...)
       16. │       │     └─base (local) tryCatchList(expr, classes, parentenv, handlers)
       17. │       │       └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
       18. │       │         └─base (local) doTryCatch(return(expr), name, parentenv, handler)
       19. │       ├─DBI::dbGetQuery(...)
       20. │       └─DBI::dbGetQuery(...)
       21. │         └─DBI (local) .local(conn, statement, ...)
       22. │           ├─DBI::dbSendQuery(conn, statement, ...)
       23. │           └─duckdb::dbSendQuery(conn, statement, ...)
       24. │             └─duckdb (local) .local(conn, statement, ...)
       25. │               └─duckdb:::rethrow_rapi_prepare(conn@conn_ref, statement, env)
       26. │                 ├─rlang::try_fetch(...)
       27. │                 │ ├─base::tryCatch(...)
       28. │                 │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
       29. │                 │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
       30. │                 │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
       31. │                 │ └─base::withCallingHandlers(...)
       32. │                 └─duckdb:::rapi_prepare(conn, query, env)
       33. ├─duckdb (local) `<fn>`(...)
       34. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
       35. │   └─rlang:::signal_abort(cnd, .file)
       36. │     └─base::signalCondition(cnd)
       37. └─rlang (local) `<fn>`(`<dckdb_rr>`)
       38.   └─handlers[[1L]](cnd)
       39.     └─duckdb:::rethrow_error_from_rapi(e, call)
       40.       └─rlang::abort(msg, call = call)
      
      [ FAIL 1 | WARN 0 | SKIP 2 | PASS 386 ]
      Error: Test failures
      Execution halted
    ```

