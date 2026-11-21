-- The pairs the spatial join of 2024 produces, materialized into a table, then the top-N per query point
-- through ROW_NUMBER() at k = 5,000 and 4,096, without LATERAL.
-- Run from the directory with the Parquet files; writes pairs-<k>.json profiles there.
-- Handbook: none; supports duckdb/duckdb-r#3050.
INSTALL spatial; LOAD spatial;
SET memory_limit = '4GB';
CREATE TEMP TABLE ref AS SELECT *, ST_GeomFromWKB(geometry) AS geom FROM read_parquet('geodata.parquet');
CREATE TEMP TABLE d AS SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM read_parquet('dataindex.parquet') WHERE year = 2024;
CREATE TEMP TABLE pairs AS SELECT d.geom AS dgeom, ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM d JOIN ref g ON ST_DWithin(d.geom, g.geom, 2500);
SELECT count(*), typeof(any_value(dgeom)) FROM pairs;
.timer on
SET enable_profiling = 'json';
SET profiling_output = 'pairs-5000.json';
SELECT count(*), sum(n) FROM (SELECT dgeom, count(*) n, min(dist), arg_min(id_shop, dist) FROM (SELECT * FROM (SELECT dgeom, dist, id_shop, row_number() OVER (PARTITION BY dgeom ORDER BY dist) rn FROM pairs) WHERE rn <= 5000) GROUP BY dgeom);
SET profiling_output = 'pairs-4096.json';
SELECT count(*), sum(n) FROM (SELECT dgeom, count(*) n, min(dist), arg_min(id_shop, dist) FROM (SELECT * FROM (SELECT dgeom, dist, id_shop, row_number() OVER (PARTITION BY dgeom ORDER BY dist) rn FROM pairs) WHERE rn <= 4096) GROUP BY dgeom);
SET enable_profiling = 'no_output';
