# quak (0.1.0)

* GitHub: <https://github.com/pedrobtz/quak>
* Email: <mailto:pedrobtz@gmail.com>
* GitHub mirror: <https://github.com/cran/quak>

Run `revdepcheck::revdep_details(, "quak")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       i This message has been shown 60 times and will not be shown again this session.
       i Collecting data from Azure...
       [ FAIL 1 | WARN 0 | SKIP 19 | PASS 260 ]
       
       ══ Skipped tests (19) ══════════════════════════════════════════════════════════
       • On CRAN (18): 'test-azure.R:2:3', 'test-azure.R:22:3', 'test-azure.R:39:3',
         'test-azure.R:56:3', 'test-azure.R:67:3', 'test-azure.R:91:3',
         'test-azure.R:109:3', 'test-azure.R:128:3', 'test-azure.R:139:3',
         'test-extensions.R:2:3', 'test-extensions.R:12:3', 'test-extensions.R:22:3',
         'test-extensions.R:39:3', 'test-extensions.R:51:3',
         'test-extensions.R:302:3', 'test-extensions.R:338:3',
         'test-extensions.R:352:3', 'test-extensions.R:367:3'
       • azure extension not installed (1): 'test-tables.R:46:3'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-conditions.R:60:3'): extension unavailable errors include extension metadata and parent ──
       Expected `err$parent` to be an S3 object.
       Actual OO type: none.
       
       [ FAIL 1 | WARN 0 | SKIP 19 | PASS 260 ]
       Error:
       ! Test failures.
       Execution halted
     ```

