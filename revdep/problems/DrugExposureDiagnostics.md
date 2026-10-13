# DrugExposureDiagnostics (1.2.0)

* GitHub: <https://github.com/darwin-eu/DrugExposureDiagnostics>
* Email: <mailto:g.inberg@erasmusmc.nl>
* GitHub mirror: <https://github.com/cran/DrugExposureDiagnostics>

Run `revdepcheck::revdep_details(, "DrugExposureDiagnostics")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       * Extensions are re-downloaded each session.
       * Secrets are lost.
       i Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       [ FAIL 1 | WARN 137 | SKIP 5 | PASS 509 ]
       
       ══ Skipped tests (5) ═══════════════════════════════════════════════════════════
       • Skipping (1): 'test-shiny.R:2:3'
       • Sys.getenv("TESTDB_USER") == "" is TRUE (1): 'test-SyntheaSqlServer.R:5:3'
       • does not work with latest omopgenerics (3): 'test-runBenchmark.R:2:3',
         'test-runBenchmark.R:36:3', 'test-runBenchmark.R:47:3'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-checkDrugRoutes.R:71:3'): getDrugRoutes ──────────────────────
       Expected `result$route_type` to equal `as.character(c("Oral", "Oral", NA, NA, NA))`.
       Differences:
       `actual`:   "Oral" NA     NA "Oral" NA
       `expected`: "Oral" "Oral" NA NA     NA
       
       
       [ FAIL 1 | WARN 137 | SKIP 5 | PASS 509 ]
       Error:
       ! Test failures.
       Execution halted
     ```

