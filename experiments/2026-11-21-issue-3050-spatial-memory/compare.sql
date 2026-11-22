-- Checks workaround-candidate.sql (cand) and workaround.sql (wa) against query.sql (orig) for every year in the DuckDB CLI,
-- on the Parquet files `repro.R write=<dir>` writes, run from that directory.
-- Stores the three results for all years, then compares the row counts and, per obsid, n_points, avg_dist and min_dist
-- up to a relative 1e-9, and counts the id_shop differences and how many of them are exact distance ties.
-- Handbook: none; supports duckdb/duckdb-r#3050.
INSTALL spatial;
LOAD spatial;
SET memory_limit = '4GB';
SELECT library_version, source_id, current_setting('threads') AS threads,
  current_setting('memory_limit') AS memory_limit FROM pragma_version();
CREATE VIEW geodata AS FROM read_parquet('geodata.parquet');
CREATE VIEW dataindex AS FROM read_parquet('dataindex.parquet');
CREATE OR REPLACE TEMP TABLE ref AS SELECT *, ST_GeomFromWKB(geometry) AS geom FROM geodata;
CREATE TEMP TABLE orig AS
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2015)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
CREATE TEMP TABLE cand AS
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
CREATE TEMP TABLE wa AS
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2016)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2017)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2018)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2019)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2020)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2021)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2022)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2023)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
INSERT INTO orig
WITH data AS (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex WHERE year = 2024)
SELECT d.obsid, year, COALESCE(stats.n_points, 0) AS n, stats.avg_dist, stats.min_dist / 1000 AS min_km, stats.id_shop
FROM data d
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist, MIN(dist) AS min_dist, arg_min(id_shop, dist) AS id_shop
  FROM (SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop FROM ref g
        WHERE ST_DWithin(d.geom, g.geom, 2500) ORDER BY dist LIMIT 5000) nn
) stats ON TRUE;
INSERT INTO cand
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
INSERT INTO wa
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
.mode duckbox
SELECT (SELECT count(*) FROM orig) AS rows_orig, (SELECT count(DISTINCT obsid) FROM orig) AS obsid_orig,
  (SELECT sum(n) FROM orig) AS sum_n_orig, (SELECT count(*) FROM orig WHERE n = 0) AS zero_orig,
  (SELECT count(*) FROM orig WHERE n = 5000) AS at_k_orig;
SELECT 'cand' AS version, (SELECT count(*) FROM cand) AS rows, (SELECT count(DISTINCT obsid) FROM cand) AS obsid,
  (SELECT sum(n_points) FROM cand) AS sum_n, (SELECT count(*) FROM cand WHERE n_points = 0) AS zero;
CREATE OR REPLACE TEMP TABLE cmp AS
SELECT o.obsid, o.year, o.n, w.n_points, o.avg_dist AS avg_o, w.avg_dist AS avg_w, o.min_km AS min_o, w.min_dist AS min_w,
  o.id_shop AS shop_o, w.id_shop AS shop_w, w.obsid IS NULL AS missing_in_w, o.obsid IS NULL AS missing_in_orig
FROM orig o FULL JOIN cand w ON o.obsid = w.obsid AND o.year = w.year;
SELECT 'cand' AS version, count(*) AS joined,
  count(*) FILTER (missing_in_w OR missing_in_orig) AS unmatched,
  count(*) FILTER (n IS DISTINCT FROM n_points) AS n_diff,
  count(*) FILTER (NOT (avg_o IS NULL AND avg_w IS NULL) AND
    (avg_o IS NULL OR avg_w IS NULL OR abs(avg_o - avg_w) > 1e-9 * greatest(abs(avg_o), 1))) AS avg_diff,
  count(*) FILTER (NOT (min_o IS NULL AND min_w IS NULL) AND
    (min_o IS NULL OR min_w IS NULL OR abs(min_o - min_w) > 1e-9 * greatest(abs(min_o), 1))) AS min_diff,
  max(abs(avg_o - avg_w)) AS max_abs_avg_diff, max(abs(min_o - min_w)) AS max_abs_min_diff
FROM cmp;
SELECT 'cand' AS version, count(*) AS id_shop_diff,
  count(*) FILTER (ST_Distance(d.geom, ro.geom) = ST_Distance(d.geom, rw.geom)) AS exact_ties
FROM cmp c
JOIN (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex) d USING (obsid, year)
LEFT JOIN ref ro ON ro.id_shop = c.shop_o
LEFT JOIN ref rw ON rw.id_shop = c.shop_w
WHERE c.shop_o IS DISTINCT FROM c.shop_w;
SELECT 'wa' AS version, (SELECT count(*) FROM wa) AS rows, (SELECT count(DISTINCT obsid) FROM wa) AS obsid,
  (SELECT sum(n_points) FROM wa) AS sum_n, (SELECT count(*) FROM wa WHERE n_points = 0) AS zero;
CREATE OR REPLACE TEMP TABLE cmp AS
SELECT o.obsid, o.year, o.n, w.n_points, o.avg_dist AS avg_o, w.avg_dist AS avg_w, o.min_km AS min_o, w.min_dist AS min_w,
  o.id_shop AS shop_o, w.id_shop AS shop_w, w.obsid IS NULL AS missing_in_w, o.obsid IS NULL AS missing_in_orig
FROM orig o FULL JOIN wa w ON o.obsid = w.obsid AND o.year = w.year;
SELECT 'wa' AS version, count(*) AS joined,
  count(*) FILTER (missing_in_w OR missing_in_orig) AS unmatched,
  count(*) FILTER (n IS DISTINCT FROM n_points) AS n_diff,
  count(*) FILTER (NOT (avg_o IS NULL AND avg_w IS NULL) AND
    (avg_o IS NULL OR avg_w IS NULL OR abs(avg_o - avg_w) > 1e-9 * greatest(abs(avg_o), 1))) AS avg_diff,
  count(*) FILTER (NOT (min_o IS NULL AND min_w IS NULL) AND
    (min_o IS NULL OR min_w IS NULL OR abs(min_o - min_w) > 1e-9 * greatest(abs(min_o), 1))) AS min_diff,
  max(abs(avg_o - avg_w)) AS max_abs_avg_diff, max(abs(min_o - min_w)) AS max_abs_min_diff
FROM cmp;
SELECT 'wa' AS version, count(*) AS id_shop_diff,
  count(*) FILTER (ST_Distance(d.geom, ro.geom) = ST_Distance(d.geom, rw.geom)) AS exact_ties
FROM cmp c
JOIN (SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom FROM dataindex) d USING (obsid, year)
LEFT JOIN ref ro ON ro.id_shop = c.shop_o
LEFT JOIN ref rw ON rw.id_shop = c.shop_w
WHERE c.shop_o IS DISTINCT FROM c.shop_w;
