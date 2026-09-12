# duckspatial (1.2.1)

* GitHub: <https://github.com/Cidree/duckspatial>
* Email: <mailto:adrian.cidre@gmail.com>
* GitHub mirror: <https://github.com/cran/duckspatial>

Run `revdepcheck::revdep_details(, "duckspatial")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       ℹ Check that the extension name is correct:
         <https://duckdb.org/docs/extensions/overview>
       Backtrace:
            ▆
         1. └─testthat::test_check("duckspatial")
         2.   └─testthat::test_dir(...)
         3.     └─testthat:::test_files(...)
         4.       └─testthat:::test_files_serial(...)
         5.         └─testthat:::test_files_setup_state(...)
         6.           └─testthat::source_test_setup(".", env)
         7.             └─testthat::source_dir(path, "^setup.*\\.[rR]$", env = env, wrap = FALSE)
         8.               └─base::lapply(...)
         9.                 └─testthat (local) FUN(X[[i]], ...)
        10.                   └─testthat::source_file(...)
        11.                     ├─base::withCallingHandlers(...)
        12.                     └─base::eval(exprs, env)
        13.                       └─base::eval(exprs, env)
        14.                         ├─duckspatial::as_duckspatial_df(argentina_sf) at ./setup.R:15:1
        15.                         └─duckspatial:::as_duckspatial_df.sf(argentina_sf)
        16.                           └─duckspatial:::ddbs_default_conn()
        17.                             └─duckspatial::ddbs_create_conn(dbdir = "memory", ...)
        18.                               └─duckspatial::ddbs_install(conn, upgrade = upgrade, quiet = TRUE)
        19.                                 └─cli::cli_abort(...)
        20.                                   └─rlang::abort(...)
       Execution halted
     ```

