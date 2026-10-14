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

