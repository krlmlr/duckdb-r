# quak (0.1.1)

* GitHub: <https://github.com/pedrobtz/quak>
* Email: <mailto:pedrobtz@gmail.com>
* GitHub mirror: <https://github.com/cran/quak>

Run `revdepcheck::revdep_details(, "quak")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       v Set `custom_extension_repository` = "https://c.example"
       v Set `custom_extension_repository` = "https://fake.example"
       i Collecting data from Azure...
       [ FAIL 1 | WARN 0 | SKIP 22 | PASS 327 ]
       
       ══ Skipped tests (22) ══════════════════════════════════════════════════════════
       • On CRAN (21): 'test-azure.R:2:3', 'test-azure.R:22:3', 'test-azure.R:39:3',
         'test-azure.R:56:3', 'test-azure.R:67:3', 'test-azure.R:91:3',
         'test-azure.R:109:3', 'test-azure.R:128:3', 'test-azure.R:139:3',
         'test-azure.R:185:3', 'test-azure.R:208:3', 'test-datasets.R:234:3',
         'test-extensions.R:2:3', 'test-extensions.R:12:3', 'test-extensions.R:22:3',
         'test-extensions.R:39:3', 'test-extensions.R:51:3',
         'test-extensions.R:302:3', 'test-extensions.R:338:3',
         'test-extensions.R:352:3', 'test-extensions.R:367:3'
       • azure extension not installed (1): 'test-tables.R:41:3'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-conditions.R:60:3'): extension unavailable errors include extension metadata and parent ──
       Expected `err$parent` to be an S3 object.
       Actual OO type: none.
       
       [ FAIL 1 | WARN 0 | SKIP 22 | PASS 327 ]
       Error:
       ! Test failures.
       Execution halted
     ```

