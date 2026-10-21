# DrugExposureDiagnostics (1.2.1)

* GitHub: <https://github.com/darwin-eu/DrugExposureDiagnostics>
* Email: <mailto:g.inberg@erasmusmc.nl>
* GitHub mirror: <https://github.com/cran/DrugExposureDiagnostics>

Run `revdepcheck::revdep_details(, "DrugExposureDiagnostics")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        37. │                       │ └─base::withCallingHandlers(...)
        38. │                       └─duckdb:::rapi_prepare(conn, query, env)
        39. ├─duckdb (local) `<fn>`(...)
        40. │ └─rlang::abort(error_parts, class = "duckdb_error", !!!fields)
        41. │   └─rlang:::signal_abort(cnd, .file)
        42. │     └─base::signalCondition(cnd)
        43. ├─rlang (local) `<fn>`(`<dckdb_rr>`)
        44. │ └─handlers[[1L]](cnd)
        45. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        46. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        47. │       └─rlang:::signal_abort(cnd, .file)
        48. │         └─base::signalCondition(cnd)
        49. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        50. │ └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        51. │   └─rlang::abort(...)
        52. │     └─rlang:::signal_abort(cnd, .file)
        53. │       └─base::signalCondition(cnd)
        54. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        55.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        56.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 120 | SKIP 5 | PASS 505 ]
       Error:
       ! Test failures.
       Execution halted
     ```

*   checking re-building of vignette outputs ... ERROR
     ```
     ...
       adding: drugTypesOverall.csv (deflated 42%)
       adding: drugVerbatimEndDate.csv (deflated 63%)
       adding: drugVerbatimEndDateByConcept.csv (deflated 70%)
       adding: metadata.csv (deflated 50%)
       adding: missingValuesByConcept.csv (deflated 94%)
       adding: missingValuesOverall.csv (deflated 82%)
     --- finished re-building ‘IntroductionToDrugExposureDiagnostics.Rmd’
     
     --- re-building ‘Missingness.Rmd’ using rmarkdown
     --- finished re-building ‘Missingness.Rmd’
     
     --- re-building ‘Quantity.Rmd’ using rmarkdown
     --- finished re-building ‘Quantity.Rmd’
     
     --- re-building ‘Routes.Rmd’ using rmarkdown
     --- finished re-building ‘Routes.Rmd’
     
     --- re-building ‘VerbatimEndDate.Rmd’ using rmarkdown
     --- finished re-building ‘VerbatimEndDate.Rmd’
     
     SUMMARY: processing the following file failed:
       ‘DrugTimeBetween.Rmd’
     
     Error: Vignette re-building failed.
     Execution halted
     ```

