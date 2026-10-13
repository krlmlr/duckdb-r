# dm (1.1.2)

* GitHub: <https://github.com/cynkra/dm>
* Email: <mailto:kirill@cynkra.com>
* GitHub mirror: <https://github.com/cran/dm>

Run `revdepcheck::revdep_details(, "dm")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       Caused by error in `db_copy_to()`:
       ! Can't copy data to table "data_card_1()".
       Caused by error in `dbplyr_write_table()`:
       ! Can't write table "data_card_1()".
       Caused by error in `.local()`:
       ! {"exception_type":"TransactionContext","exception_message":"Current transaction is aborted (please ROLLBACK)"}
       i Context: rapi_register_df
       ── Error ('test-dm.R:96:3'): dm() works for adding tables ──────────────────────
       <purrr_error_indexed/rlang_error/error/condition>
       Error in `map(quos, eval_tidy)`: i In index: 2.
       Caused by error in `db_copy_to()`:
       ! Can't copy data to table "data_card_1()".
       Caused by error in `dbplyr_write_table()`:
       ! Can't write table "data_card_1()".
       Caused by error in `.local()`:
       ! TransactionContext Error: Current transaction is aborted (please ROLLBACK)
       i Context: rapi_unregister_df
       i Error type: TRANSACTION
       
       [ FAIL 4 | WARN 13 | SKIP 391 | PASS 1660 ]
       Error:
       ! Test failures.
       Warning message:
       call dbDisconnect() when finished working with a connection 
       Execution halted
     ```

