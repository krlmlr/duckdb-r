# MeasurementDiagnostics (0.3.0)

* GitHub: <https://github.com/ohdsi/MeasurementDiagnostics>
* Email: <mailto:nuria.mercadebesora@ndorms.ox.ac.uk>
* GitHub mirror: <https://github.com/cran/MeasurementDiagnostics>

Run `revdepcheck::revdep_details(, "MeasurementDiagnostics")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        13. │               └─DBI::dbSendStatement(conn, statement, ...)
        14. │                 ├─DBI::dbSendQuery(conn, statement, ...)
        15. │                 └─duckdb::dbSendQuery(conn, statement, ...)
        16. │                   └─duckdb (local) .local(conn, statement, ...)
        17. │                     └─duckdb:::rethrow_rapi_prepare(conn@conn_ref, statement, env)
        18. │                       ├─rlang::try_fetch(...)
        19. │                       │ ├─base::tryCatch(...)
        20. │                       │ │ └─base (local) tryCatchList(expr, classes, parentenv, handlers)
        21. │                       │ │   └─base (local) tryCatchOne(expr, names, parentenv, handlers[[1L]])
        22. │                       │ │     └─base (local) doTryCatch(return(expr), name, parentenv, handler)
        23. │                       │ └─base::withCallingHandlers(...)
        24. │                       └─duckdb:::rapi_prepare(conn, query, env)
        25. ├─duckdb (local) `<fn>`(...)
        26. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        27. │   └─rlang:::signal_abort(cnd, .file)
        28. │     └─base::signalCondition(cnd)
        29. └─rlang (local) `<fn>`(`<dckdb_rr>`)
        30.   └─handlers[[1L]](cnd)
        31.     └─duckdb:::rethrow_error_from_rapi(e, call)
        32.       └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
       
       [ FAIL 5 | WARN 0 | SKIP 10 | PASS 0 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
       7.         └─CDMConnector:::compute.db_cdm(...)
       8.           └─CDMConnector:::.computeQuery(...)
       9.             └─CDMConnector:::.computePermanent(...)
      10.               ├─DBI::dbExecute(x$src$con, sql)
      11.               └─DBI::dbExecute(x$src$con, sql)
      12.                 ├─DBI::dbSendStatement(conn, statement, ...)
      13.                 └─DBI::dbSendStatement(conn, statement, ...)
      14.                   ├─DBI::dbSendQuery(conn, statement, ...)
      15.                   └─duckdb::dbSendQuery(conn, statement, ...)
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
     Error: processing vignette 'a03_resultsVisualisation.Rmd' failed with diagnostics:
     Binder Error: PARTITION BY window expressions cannot be volatile
     
     LINE 9: WHEN (NOT(((RANDOM()) IS NULL))) THEN ROW_NUMBER() OVER (PARTITION BY (CASE WHEN (((RANDOM())...
                                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     ℹ Context: rapi_prepare
     ℹ Error type: BINDER
     --- failed re-building ‘a03_resultsVisualisation.Rmd’
     
     SUMMARY: processing the following files failed:
       ‘a01_summariseMeasurementUse.Rmd’ ‘a03_resultsVisualisation.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

