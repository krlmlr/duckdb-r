# farr (1.1.0)

* GitHub: <https://github.com/iangow/farr>
* Email: <mailto:iandgow@gmail.com>
* GitHub mirror: <https://github.com/cran/farr>

Run `revdepcheck::revdep_details(, "farr")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        3.   └─farr (local) code(conn, events, dates) at ./helper-cumulative-returns.R:74:3
        4.     └─testthat::expect_error(...) at test-get_event_cum_rets.R:78:13
       ── Failure ('test-get_event_cum_rets.R:78:13'): DuckDB monthly reconstructed rejects returns below minus one even with a complete loss ──
       Expected `get_returns(events, conn, end_event_date = "last_event")` to throw a error.
       size
       Backtrace:
           ▆
        1. ├─base::do.call(...) at test-get_event_cum_rets.R:76:9
        2. └─farr (local) `<fn>`(...)
        3.   └─farr (local) code(conn, events, dates) at ./helper-cumulative-returns.R:74:3
        4.     └─testthat::expect_error(...) at test-get_event_cum_rets.R:78:13
       ── Failure ('test-get_event_cum_rets.R:78:13'): DuckDB monthly reconstructed rejects returns below minus one even with a complete loss ──
       Expected `get_returns(events, conn, end_event_date = "last_event")` to throw a error.
       size
       Backtrace:
           ▆
        1. ├─base::do.call(...) at test-get_event_cum_rets.R:76:9
        2. └─farr (local) `<fn>`(...)
        3.   └─farr (local) code(conn, events, dates) at ./helper-cumulative-returns.R:74:3
        4.     └─testthat::expect_error(...) at test-get_event_cum_rets.R:78:13
       
       [ FAIL 12 | WARN 0 | SKIP 29 | PASS 343 ]
       Error:
       ! Test failures.
       Execution halted
     ```

