-- The first candidate workaround for the issue's query without LATERAL, for every year in the DuckDB CLI,
-- on the Parquet files `repro.R write=<dir>` writes, run from that directory.
-- The spatial join, ROW_NUMBER() per obsid, and rn <= 5000 as a condition of the LEFT JOIN back to the query points.
-- Its results are right, but on 2.0.x it spills as the LATERAL does; workaround.sql is the fixed form.
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
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2016
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2017
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2018
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2019
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2020
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2021
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2022
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2023
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
WITH data AS (
  SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2024
),
nn AS (
  SELECT d.obsid, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    ROW_NUMBER() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) AS rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)
)
SELECT d.obsid, d.year,
  COUNT(nn.dist) AS n_points, AVG(nn.dist) AS avg_dist, MIN(nn.dist) / 1000 AS min_dist,
  arg_min(nn.id_shop, nn.dist) AS id_shop
FROM data d LEFT JOIN nn ON nn.obsid = d.obsid AND nn.rn <= 5000
GROUP BY d.obsid, d.year;
