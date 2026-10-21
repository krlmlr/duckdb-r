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

# irelink (0.0.1)

* GitHub: <https://github.com/christopherkenny/irelink>
* Email: <mailto:ctkenny@proton.me>
* GitHub mirror: <https://github.com/cran/irelink>

Run `revdepcheck::revdep_details(, "irelink")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
         'test-il_count_pairs.R:158:1', 'test-il_estimate.R:236:1',
         'test-il_score_pairs.R:81:1', 'test-il_score_pairs.R:94:1',
         'test-sql-profile.R:83:1', 'test-sql-profile.R:98:1',
         'test-stage6-plan.R:80:1', 'test-stage6-plan.R:87:1',
         'test-stage6-plan.R:98:1', 'test-stage6-plan.R:119:1',
         'test-stage6-plan.R:141:1', 'test-stage6-plan.R:163:1'
       
       ══ Failed tests ════════════════════════════════════════════════════════════════
       ── Failure ('test-sql-clustering.R:314:3'): SQL best_link with source_dataset matches R tie handling ──
       Expected `unname(sql_map["A"])` to equal `unname(sql_map["C"])`.
       Differences:
       `actual`:   "cluster_A"
       `expected`: "cluster_B"
       
       ── Failure ('test-sql-clustering.R:316:3'): SQL best_link with source_dataset matches R tie handling ──
       Expected `sql_map[c("A", "B", "C")] == sql_map["A"]` to equal `r_map[c("A", "B", "C")] == r_map["A"]`.
       Differences:
       `actual`:   TRUE FALSE FALSE
       `expected`: TRUE FALSE TRUE 
       
       
       [ FAIL 2 | WARN 0 | SKIP 22 | PASS 1155 ]
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

# Rduckhts (2.0.0.0.1.9)

* GitHub: <https://github.com/RGenomicsETL/duckhts>
* Email: <mailto:sounkoutoure@gmail.com>
* GitHub mirror: <https://github.com/cran/Rduckhts>

Run `revdepcheck::revdep_details(, "Rduckhts")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr1' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       [W::vcf_parse] Contig 'chr3' is not defined in the header. (Quick workaround: index the file with tabix.)
       [W::vcf_parse] Missing headers may cause later processing to fail
       
       test_bcf.R....................  258 tests OK [E::bgzf_read_block] Invalid BGZF header at offset 447
       [E::bgzf_read] Read block operation failed with error 2 after 0 of 32 bytes
       Error: rapi_execute: Invalid Input Error: read_bcf: failed to read or parse BCF/VCF record (error_type: INVALID_INPUT)
       Execution halted
     ```

## In both

*   checking compilation flags used ... NOTE
     ```
     Compilation used the following non-portable flag(s):
       ‘-Wdate-time’ ‘-Werror=format-security’ ‘-Wformat’
     ```

