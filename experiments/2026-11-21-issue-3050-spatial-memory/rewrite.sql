-- The query of query.sql for 2024 without LATERAL: the spatial join, ROW_NUMBER() per query point, rn <= 5000, then
-- the aggregates, the top-N partitioned by the geometry (as the decorrelated LATERAL does) and by obsid.
-- Run from the directory with the Parquet files; writes rewrite-<partition>.json profiles there.
-- Handbook: none; supports duckdb/duckdb-r#3050.
INSTALL spatial; LOAD spatial;
SET memory_limit = '4GB';
CREATE TEMP TABLE ref AS SELECT *, ST_GeomFromWKB(geometry) AS geom FROM read_parquet('geodata.parquet');
CREATE VIEW dataindex AS FROM read_parquet('dataindex.parquet');
.timer on
SET enable_profiling = 'json';
SET profiling_output = 'rewrite-geom.json';
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2024)
SELECT count(*), sum(n) FROM (
SELECT d.obsid, any_value(d.year), count(*) n, avg(dist), min(dist), arg_min(id_shop, dist) FROM (
  SELECT d.obsid, d.year, d.geom, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    row_number() OVER (PARTITION BY d.geom ORDER BY ST_Distance(d.geom, g.geom)) rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)) d
WHERE rn <= 5000 GROUP BY d.obsid);
SET profiling_output = 'rewrite-obsid.json';
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2024)
SELECT count(*), sum(n) FROM (
SELECT d.obsid, any_value(d.year), count(*) n, avg(dist), min(dist), arg_min(id_shop, dist) FROM (
  SELECT d.obsid, d.year, ST_Distance(d.geom, g.geom) AS dist, g.id_shop,
    row_number() OVER (PARTITION BY d.obsid ORDER BY ST_Distance(d.geom, g.geom)) rn
  FROM data d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500)) d
WHERE rn <= 5000 GROUP BY d.obsid);
SET enable_profiling = 'no_output';
