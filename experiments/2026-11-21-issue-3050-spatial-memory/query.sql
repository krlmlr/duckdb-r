-- The issue's per-year query for every year, in the DuckDB CLI, on the
-- Parquet files `repro.R write=<dir>` writes, run from that directory.
-- One copy of the query per year, 2015 to 2024, with k = 5000.
-- Handbook: none; supports duckdb/duckdb-r#3050.
INSTALL spatial;
LOAD spatial;
SET memory_limit = '4GB';
SELECT library_version, source_id, current_setting('threads') AS threads,
  current_setting('memory_limit') AS memory_limit FROM pragma_version();
CREATE VIEW geodata AS FROM read_parquet('geodata.parquet');
CREATE VIEW dataindex AS FROM read_parquet('dataindex.parquet');
CREATE OR REPLACE TEMP TABLE ref AS SELECT *, ST_GeomFromWKB(geometry) AS geom FROM geodata;
.timer on
.mode trash
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2015)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2016)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2017)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2018)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2019)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2020)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2021)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2022)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2023)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2024)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
