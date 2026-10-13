# CohortMethod (6.0.3)

* GitHub: <https://github.com/OHDSI/CohortMethod>
* Email: <mailto:schuemie@ohdsi.org>
* GitHub mirror: <https://github.com/cran/CohortMethod>

Run `revdepcheck::revdep_details(, "CohortMethod")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        25. │                     │ └─base::withCallingHandlers(...)
        26. │                     └─duckdb:::rapi_unregister_df(conn, name)
        27. ├─duckdb (local) `<fn>`(...)
        28. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        29. │   └─rlang:::signal_abort(cnd, .file)
        30. │     └─base::signalCondition(cnd)
        31. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        32. │ └─handlers[[1L]](cnd)
        33. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        34. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        35. │       └─rlang:::signal_abort(cnd, .file)
        36. │         └─base::signalCondition(cnd)
        37. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        38. │ └─cli::cli_abort(msg, parent = cnd)
        39. │   └─rlang::abort(...)
        40. │     └─rlang:::signal_abort(cnd, .file)
        41. │       └─base::signalCondition(cnd)
        42. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        43.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        44.     └─rlang::abort(...)
       
       [ FAIL 6 | WARN 2 | SKIP 1 | PASS 450 ]
       Error:
       ! Test failures.
       Execution halted
     ```

## In both

*   checking re-building of vignette outputs ... WARNING
     ```
     ...
     ! Emergency stop.
     <read *> 
     
     Error: processing vignette 'MultipleAnalyses.Rmd' failed with diagnostics:
     LaTeX failed to compile MultipleAnalyses.tex. See https://yihui.org/tinytex/r/#debugging for debugging tips. See MultipleAnalyses.log for more info.
     --- failed re-building ‘MultipleAnalyses.Rmd’
     
     --- re-building ‘ResultsSchema.Rmd’ using rmarkdown
     --- finished re-building ‘ResultsSchema.Rmd’
     
     --- re-building ‘SingleStudies.Rmd’ using rmarkdown
     ! LaTeX Error: File `lmodern.sty' not found.
     
     ! Emergency stop.
     <read *> 
     
     Error: processing vignette 'SingleStudies.Rmd' failed with diagnostics:
     LaTeX failed to compile SingleStudies.tex. See https://yihui.org/tinytex/r/#debugging for debugging tips. See SingleStudies.log for more info.
     --- failed re-building ‘SingleStudies.Rmd’
     
     SUMMARY: processing the following files failed:
       ‘MultipleAnalyses.Rmd’ ‘SingleStudies.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

