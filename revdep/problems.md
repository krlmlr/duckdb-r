# datacaged (0.2.1)

* GitHub: <https://github.com/gecomt/datacaged>
* Email: <mailto:alexsandro.prado@ufersa.edu.br>
* GitHub mirror: <https://github.com/cran/datacaged>

Run `revdepcheck::revdep_details(, "datacaged")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        5.     └─datacaged::caged_connect(db_path, read_only = TRUE, quiet = TRUE)
        6.       └─duckdb::duckdb(dbdir = db_path, read_only = read_only)
        7.         └─duckdb:::duckdb_impl(...)
        8.           └─duckdb:::warn_instance_settings_ignored(...)
        9.             └─rlang::abort(...)
       ── Error ('test-pipelines.R:216:3'): caged_adjustments_load() cria banco com tabela caged_ajustes ──
       Error in `duckdb::duckdb(dbdir = db_path, read_only = read_only)`: `read_only` can't be applied to the database instance for `/tmp/RtmpBX0UhV/working_dir/RtmpzpfYP3/caged_adj_mock_31177c2796b.duckdb`, which already exists.
       * These settings take effect only when the instance is created.
       * Release it with `duckdb_shutdown()` first, or pass them to the `duckdb()` call that creates it.
       Backtrace:
           ▆
        1. ├─base::suppressMessages(...) at test-pipelines.R:216:3
        2. │ └─base::withCallingHandlers(...)
        3. └─datacaged::caged_adjustments_load(...)
        4.   └─datacaged::caged_info(db_path)
        5.     └─datacaged::caged_connect(db_path, read_only = TRUE, quiet = TRUE)
        6.       └─duckdb::duckdb(dbdir = db_path, read_only = read_only)
        7.         └─duckdb:::duckdb_impl(...)
        8.           └─duckdb:::warn_instance_settings_ignored(...)
        9.             └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 5 | PASS 187 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# duckh3 (0.2.0)

* GitHub: <https://github.com/Cidree/duckh3>
* Email: <mailto:adrian.cidre@gmail.com>
* GitHub mirror: <https://github.com/cran/duckh3>

Run `revdepcheck::revdep_details(, "duckh3")` for more info

## Newly broken

*   checking examples ... ERROR
     ```
     ...
     Error in `duckspatial::ddbs_install()`:
     ! Failed to install the h3 extension.
     ✖ core: HTTP Error: Failed to download extension "h3" at URL
       "http://extensions.duckdb.org/v2.0.0-alpha46057/linux_amd64/h3.duckdb_extension.gz"
       (HTTP 404) Candidate extensions: "s3", "http", "https", "httpfs",
       "motherduck" For more info, visit
       https://duckdb.org/docs/current/extensions/troubleshooting?version=v2.0.0-alpha46057&platform=linux_amd64&extension=h3
       ℹ Context: rapi_execute ℹ Error type: HTTP
     ✖ community: HTTP Error: Failed to download extension "h3" at URL
       "http://community-extensions.duckdb.org/v2.0.0-alpha46057/linux_amd64/h3.duckdb_extension.gz"
       (HTTP 404) Candidate extensions: "s3", "http", "https", "httpfs",
       "motherduck" For more info, visit
       https://duckdb.org/docs/current/extensions/troubleshooting?version=v2.0.0-alpha46057&platform=linux_amd64&extension=h3
       ℹ Context: rapi_execute ℹ Error type: HTTP
     ℹ It might not be available for this version of DuckDB, or the install location
       may not be writable.
     ℹ Check that the extension name is correct:
       <https://duckdb.org/docs/extensions/overview>
     Backtrace:
         ▆
      1. └─duckh3::ddbh3_default_conn(threads = 1)
      2.   └─duckspatial::ddbs_install(conn, upgrade = upgrade_h3, quiet = TRUE, extension = "h3")
      3.     └─cli::cli_abort(...)
      4.       └─rlang::abort(...)
     Execution halted
     ```

*   checking tests ... ERROR
     ```
     ...
         ℹ Context: rapi_execute ℹ Error type: HTTP
       ℹ It might not be available for this version of DuckDB, or the install location
         may not be writable.
       ℹ Check that the extension name is correct:
         <https://duckdb.org/docs/extensions/overview>
       Backtrace:
            ▆
         1. └─testthat::test_check("duckh3")
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
        14.                         └─duckh3::ddbh3_default_conn() at ./setup.R:12:1
        15.                           └─duckspatial::ddbs_install(conn, upgrade = upgrade_h3, quiet = TRUE, extension = "h3")
        16.                             └─cli::cli_abort(...)
        17.                               └─rlang::abort(...)
       Execution halted
     ```

# overtureR (0.3.1)

* GitHub: <https://github.com/arthurgailes/overtureR>
* Email: <mailto:agailes1@gmail.com>
* GitHub mirror: <https://github.com/cran/overtureR>

Run `revdepcheck::revdep_details(, "overtureR")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       * Secrets are lost.
       i Run duckdb(shared_home = TRUE) (or create ~/.duckdb) to keep them (suitable for most users).
       i Run duckdb(shared_home = FALSE) to accept the temporary directory (and silence this message).
       i See ?duckdb_storage for details and alternatives.
       [ FAIL 2 | WARN 0 | SKIP 7 | PASS 306 ]
       
       ══ Skipped tests (7) ═══════════════════════════════════════════════════════════
       • On CRAN (7): 'test-live.R:5:3', 'test-live.R:25:3', 'test-live.R:54:3',
         'test-sql_builders.R:48:1', 'test-sql_builders.R:57:1',
         'test-sql_builders.R:76:1', 'test-sql_builders.R:111:1'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-open_curtain.R:93:3'): type = '*' reads every type in the theme ──
       Expected `sql` to match string "union_by_name = CAST('t' AS BOOLEAN)".
       Actual text:
       x | CREATE VIEW star AS SELECT * FROM (SELECT * FROM read_parquet(list_value('/tmp/Rtmpotkj5N/working_dir/RtmpeSaWap/overtureR_fixtures/release/2024-01-01.0/theme=buildings/type=building/part-00000-fixture-building.zstd.parquet', '/tmp/Rtmpotkj5N/working_dir/RtmpeSaWap/overtureR_fixtures/release/2024-01-01.0/theme=buildings/type=building_part/part-00000-fixture-building_part.zstd.parquet'), (filename = false), (hive_partitioning = true), (union_by_name = true))) AS master WHERE ((1 = 1) AND (bbox.xmax >= -73.988) AND (bbox.xmin <= -73.983) AND (bbox.ymax >= 40.757) AND (bbox.ymin <= 40.76));
       ── Failure ('test-open_curtain.R:141:3'): read_opts are passed to read_parquet ──
       Expected `view_sql(conn, "opts")` to match string "filename = CAST('t' AS BOOLEAN)".
       Actual text:
       x | CREATE VIEW opts AS SELECT * FROM (SELECT * FROM read_parquet(list_value('/tmp/Rtmpotkj5N/working_dir/RtmpeSaWap/overtureR_fixtures/release/2024-01-01.0/theme=buildings/type=building/part-00000-fixture-building.zstd.parquet'), (filename = true), (hive_partitioning = true), (union_by_name = false))) AS master WHERE ((1 = 1) AND (bbox.xmax >= -73.988) AND (bbox.xmin <= -73.983) AND (bbox.ymax >= 40.757) AND (bbox.ymin <= 40.76));
       
       [ FAIL 2 | WARN 0 | SKIP 7 | PASS 306 ]
       Error:
       ! Test failures.
       Execution halted
     ```

# quak (0.1.1)

* GitHub: <https://github.com/pedrobtz/quak>
* Email: <mailto:pedrobtz@gmail.com>
* GitHub mirror: <https://github.com/cran/quak>

Run `revdepcheck::revdep_details(, "quak")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       v Set `custom_extension_repository` = "https://core.example"
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
       ── Failure ('test-connection.R:104:3'): az_tune is quiet and wraps DuckDB setting failures ──
       Expected `az_tune(conn, transport = "curl")` to throw a error with class <quak_error_azure_tune_failed>.
       
       [ FAIL 1 | WARN 0 | SKIP 22 | PASS 327 ]
       Error:
       ! Test failures.
       Execution halted
     ```

