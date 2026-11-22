-- A workaround for the issue's query without LATERAL, for every year in the DuckDB CLI,
-- on the Parquet files `repro.R write=<dir>` writes, run from that directory.
-- The spatial join, a row number rn per obsid by distance, rn <= 5000 in a WHERE, the aggregates per obsid,
-- then a LEFT JOIN from the query points, so that points without a neighbour within 2,500 m
-- keep n_points = 0 and NULL statistics, as the LEFT JOIN LATERAL gives them.
-- rn is a running COUNT(*) rather than ROW_NUMBER(), which numbers the rows the same way
-- but is not rewritten by the optimizer's top_n_window_elimination into the arg_min_nulls_last aggregate that spills on 2.0.x.
-- SET disabled_optimizers = 'top_n_window_elimination' with ROW_NUMBER() does the same.
-- One copy of the query per year, 2015 to 2024; compare.sql checks it against query.sql.
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
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2015
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2016
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2017
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2018
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2019
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2020
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2021
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2022
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2023
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2024
),
stats AS (
  SELECT obsid, COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (
    SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
      COUNT(*) OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rn
    FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
  ) nn
  WHERE rn <= 5000
  GROUP BY obsid
)
SELECT d.obsid, d.year, COALESCE(s.n_points, 0) AS n_points, s.avg_dist, s.min_dist / 1000 AS min_dist, s.id_shop
FROM data d LEFT JOIN stats s ON s.obsid = d.obsid;
