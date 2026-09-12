# BeeBDC (1.3.4)

* GitHub: <https://github.com/jbdorey/BeeBDC>
* Email: <mailto:jbdorey@me.com>
* GitHub mirror: <https://github.com/cran/BeeBDC>

Run `revdepcheck::revdep_details(, "BeeBDC")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        - Downloading taxonomy...
       duckdb keeps downloaded extensions and secrets in a temporary directory:
       i /tmp/RtmprsKj5S/working_dir/RtmpWewhQW/duckdb
       This is removed when the R session ends.
       * Extensions are re-downloaded each session.
       * Secrets are lost.
       i Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       Saving _problems/test-taxadbToBeeBDC-18.R
       [ FAIL 1 | WARN 3 | SKIP 0 | PASS 248 ]
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Error ('test-taxadbToBeeBDC.R:10:2'): (code run outside of `test_that()`) ───
       Error: Could not reach the taxadb data repository at cboettig/taxadb
       Backtrace:
           ▆
        1. └─BeeBDC::taxadbToBeeBDC(...) at test-taxadbToBeeBDC.R:10:2
        2.   └─taxadb::td_create(...)
        3.     └─taxadb::td_download(...)
       
       [ FAIL 1 | WARN 3 | SKIP 0 | PASS 248 ]
       Error:
       ! Test failures.
       Execution halted
     ```

