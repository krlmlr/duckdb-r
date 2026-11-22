-- Reproducer for duckdb/duckdb-r#3050 in the DuckDB CLI alone: run as `duckdb < cli-repro.sql`.
-- 1.5.6 finishes in seconds; 2.0.x spills to disk or fails with an out-of-memory error.
-- Handbook: none; supports duckdb/duckdb-r#3050.
INSTALL spatial;
LOAD spatial;
-- Synthetic points in projected metres, fixed by the seed:
-- generated on one thread so that random() runs in a fixed order.
SET threads = 1;
.mode trash
SELECT setseed(0.3050);
-- 40 towns in a 300 km square, Gaussian blobs with a spread of 0.8 to 2 km and uneven weights,
-- so a 2,500 m neighbourhood holds about 1,200 points at the median and up to 6,000.
CREATE TABLE town AS SELECT t, 300000 * random() AS x, 300000 * random() AS y, 800 + 1200 * random() AS sd,
  exp(1.2 * sqrt(-2 * ln(1 - random())) * cos(2 * pi() * random())) AS w FROM range(40) r(t);
CREATE TABLE cum AS SELECT *, (sum(w) OVER (ORDER BY t) - w) / sum(w) OVER () AS lo,
  sum(w) OVER (ORDER BY t) / sum(w) OVER () AS hi FROM town;
-- n points, a share of them rural (uniform), the others in a town drawn by weight, offset by Box-Muller.
CREATE MACRO pts(n, rural) AS TABLE SELECT i, CASE WHEN ur < rural THEN ST_Point(300000 * u1, 300000 * u2)
  ELSE ST_Point(x + sd * sqrt(-2 * ln(1 - u1)) * cos(2 * pi() * u2), y + sd * sqrt(-2 * ln(1 - u1)) * sin(2 * pi() * u2)) END AS geom
  FROM (SELECT i, random() AS ur, random() AS ut, random() AS u1, random() AS u2 FROM range(1, n + 1) r(i))
  JOIN cum ON ut >= lo AND ut < hi;
-- 70,000 reference points, and the query points of one year:
-- 170 of them have more than 4,096 reference points within 2,500 m.
CREATE TABLE ref AS SELECT i AS id_shop, geom FROM pts(70000, 0.05);
CREATE TABLE data AS SELECT i AS obsid, geom FROM pts(2600, 0.15);
-- The setting of the issue's machine, with a lower memory limit.
SET threads = 4;
SET memory_limit = '2GB';
.mode duckbox
SELECT library_version, current_setting('threads') AS threads, current_setting('memory_limit') AS memory_limit
  FROM pragma_version();
-- The issue's query, profiled into a JSON file in the working directory for the peak memory and temp size;
-- the file is written first so that a failed query leaves no stale profile behind.
.mode trash
COPY (SELECT 'query failed' AS note) TO 'cli-repro-profile.json' (FORMAT json);
SET enable_profiling = 'json';
SET profiling_output = 'cli-repro-profile.json';
.mode duckbox
.timer on
SELECT count(*) AS n, sum(n_points) AS sum_n_points FROM data d
LEFT JOIN LATERAL (
  SELECT count(*) AS n_points, avg(dist) AS avg_dist, min(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
.timer off
.mode trash
PRAGMA disable_profiling;
.mode duckbox
-- Peak buffer memory and peak temporary directory size of the query (1.5 and 2.0 name them differently).
SELECT format_bytes(coalesce(j->>'$.system.peak_buffer_memory', j->>'$.system_peak_buffer_memory')::BIGINT) AS peak_buffer_memory,
  format_bytes(coalesce(j->>'$.system.peak_temp_dir_size', j->>'$.system_peak_temp_dir_size')::BIGINT) AS peak_temp_dir_size,
  j->>'$.note' AS note FROM read_json_objects('cli-repro-profile.json') t(j);
