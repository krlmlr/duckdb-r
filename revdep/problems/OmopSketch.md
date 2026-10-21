# OmopSketch (1.1.1)

* GitHub: <https://github.com/OHDSI/OmopSketch>
* Email: <mailto:cecilia.campanile@ndorms.ox.ac.uk>
* GitHub mirror: <https://github.com/cran/OmopSketch>

Run `revdepcheck::revdep_details(, "OmopSketch")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       Actually got a <rlang_error> with message:
         Failed to collect lazy table.
         Caused by error in `DBI::dbSendQuery()`:
         ! Binder Error: PARTITION BY window expressions cannot be volatile
         
         LINE 6: WHEN (NOT(((RANDOM()) IS NULL))) THEN ROW_NUMBER() OVER (PARTITION BY (CASE WHEN (((RANDOM())...
                                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
         i Context: rapi_prepare
         i Error type: BINDER
       ── Error ('test-databaseCharacteristics.R:57:2'): sample works ─────────────────
       Error in `eval(code, test_env)`: object 'x' not found
       Backtrace:
           ▆
        1. ├─testthat::expect_equal(...) at test-databaseCharacteristics.R:57:2
        2. │ └─testthat::quasi_label(enquo(object), label)
        3. │   └─rlang::eval_bare(expr, quo_get_env(quo))
        4. ├─dplyr::pull(...)
        5. ├─dplyr::filter(...)
        6. └─omopgenerics::filterSettings(x, grepl("snapshot", result_type))
        7.   └─omopgenerics::settings(result)
       
       [ FAIL 2 | WARN 0 | SKIP 50 | PASS 15 ]
       Error:
       ! Test failures.
       Execution halted
     ```

