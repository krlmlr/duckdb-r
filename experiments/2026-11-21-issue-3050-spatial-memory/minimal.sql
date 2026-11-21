-- The top-N per group the decorrelated LATERAL ... ORDER BY ... LIMIT k becomes,
-- without spatial and without LATERAL: 2,500 groups, 2,400 of 1,000 rows and 100 of 6,000 rows,
-- top 5,000 by a random double per group, through the ROW_NUMBER() filter the optimizer turns into
-- arg_min_nulls_last(..., k), then the same at k = 4,096.
-- Handbook: none; supports duckdb/duckdb-r#3050.
SET memory_limit = '4GB';
SELECT library_version, current_setting('threads') AS threads FROM pragma_version();
SELECT setseed(0.3050);
CREATE TABLE t AS
SELECT ('group ' || g)::BLOB AS g, random() AS v, i AS x
FROM (
  SELECT i, CASE WHEN i < 2400 * 1000 THEN i // 1000 ELSE 2400 + (i - 2400 * 1000) // 6000 END AS g
  FROM range(2400 * 1000 + 100 * 6000) r(i)
)
ORDER BY hash(i);
.timer on
SET enable_profiling = 'json';
SET profiling_output = 'minimal-5000.json';
SELECT count(*), sum(n) FROM (
  SELECT g, count(*) AS n, avg(v) FROM (
    SELECT g, v, x, row_number() OVER (PARTITION BY g ORDER BY v) AS rn FROM t
  ) WHERE rn <= 5000 GROUP BY g
);
SET profiling_output = 'minimal-4096.json';
SELECT count(*), sum(n) FROM (
  SELECT g, count(*) AS n, avg(v) FROM (
    SELECT g, v, x, row_number() OVER (PARTITION BY g ORDER BY v) AS rn FROM t
  ) WHERE rn <= 4096 GROUP BY g
);
SET enable_profiling = 'no_output';
