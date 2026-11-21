# Reproduces duckdb/duckdb-r#3050: a per-year LEFT JOIN LATERAL with
# ST_DWithin(), ORDER BY and LIMIT, over points registered from data frames
# as WKB blobs, on synthetic town-clustered points in projected metres.
#
# Usage, with the duckdb under test first on the library path:
#   R_LIBS=<lib> Rscript repro.R [key=value ...]
#
# Keys (defaults in `opt` below):
#   source        register: duckdb_register() the data frames, as the issue
#                 does; parquet: read the Parquet files `data` names
#   write         a directory: write geodata.parquet and dataindex.parquet
#                 there and stop
#   n_ref, n_obs  reference and query points
#   k             the LIMIT is min(k, number of reference points)
#   years         all, or one year such as 2020
#   memory_limit  set before the run; "default" leaves the engine's default
#   set.<name>    any other engine setting, such as set.threads=1 or
#                 set.max_temp_directory_size=0B
#   variant       full (the issue's query), no_limit, no_order, no_argmin,
#                 no_order_limit
#   explain       none, explain (prints the plan of the first year),
#                 analyze (EXPLAIN ANALYZE of the first year, then stops)
#
# The data depend on the seed and the sizes only.
#
# Handbook: none; supports duckdb/duckdb-r#3050.

suppressPackageStartupMessages(library(duckdb))

opt <- list(
  source = "register",
  data = ".",
  write = "",
  n_ref = 70000,
  n_obs = 26000,
  years = "all",
  memory_limit = "4GB",
  k = 5000,
  variant = "full",
  explain = "none"
)
settings <- list()
for (a in commandArgs(trailingOnly = TRUE)) {
  kv <- strsplit(a, "=", fixed = TRUE)[[1]]
  stopifnot(length(kv) == 2)
  if (startsWith(kv[[1]], "set.")) {
    settings[[substring(kv[[1]], 5)]] <- kv[[2]]
  } else {
    stopifnot(kv[[1]] %in% names(opt))
    opt[[kv[[1]]]] <- kv[[2]]
  }
}
n_ref <- as.integer(opt$n_ref)
n_obs <- as.integer(opt$n_obs)

# ---- Data --------------------------------------------------------------------

# One WKB point: little-endian byte order, type 1, x, y.
wkb_header <- c(as.raw(1), writeBin(1L, raw(), size = 4, endian = "little"))
wkb_point <- function(x, y) {
  lapply(seq_along(x), function(i) {
    c(wkb_header, writeBin(c(x[[i]], y[[i]]), raw(), endian = "little"))
  })
}

set.seed(3050)
# 40 towns of uneven size in a 300 km square, each a Gaussian blob with a
# spread of 1 to 2.5 km, so a 2,500 m neighbourhood in a town holds hundreds
# to thousands of reference points.
n_town <- 40
town_x <- runif(n_town, 0, 300000)
town_y <- runif(n_town, 0, 300000)
town_sd <- runif(n_town, 1000, 2500)
town_w <- rlnorm(n_town, 0, 0.8)
town_w <- town_w / sum(town_w)

clustered <- function(n, rural_share) {
  rural <- runif(n) < rural_share
  town <- sample(n_town, n, replace = TRUE, prob = town_w)
  x <- ifelse(rural, runif(n, 0, 300000), rnorm(n, town_x[town], town_sd[town]))
  y <- ifelse(rural, runif(n, 0, 300000), rnorm(n, town_y[town], town_sd[town]))
  list(x = round(x, 1), y = round(y, 1))
}

ref_xy <- clustered(n_ref, 0.05)
geodata <- data.frame(id_shop = seq_len(n_ref))
geodata$geometry <- wkb_point(ref_xy$x, ref_xy$y)

obs_xy <- clustered(n_obs, 0.15)
dataindex <- data.frame(
  obsid = seq_len(n_obs),
  year = sample(2015:2024, n_obs, replace = TRUE)
)
dataindex$geometry <- wkb_point(obs_xy$x, obs_xy$y)

# ---- Connection --------------------------------------------------------------

con <- dbConnect(duckdb())
eng <- dbGetQuery(
  con,
  "SELECT library_version, source_id FROM pragma_version()"
)
cat(sprintf(
  "duckdb %s, engine %s (%s)\n",
  packageVersion("duckdb"),
  eng$library_version,
  eng$source_id
))

if (nzchar(opt$write)) {
  duckdb_register(con, "geodata", geodata)
  duckdb_register(con, "dataindex", dataindex)
  for (t in c("geodata", "dataindex")) {
    dbExecute(
      con,
      sprintf(
        "COPY %s TO '%s' (FORMAT parquet)",
        t,
        file.path(opt$write, paste0(t, ".parquet"))
      )
    )
  }
  cat("wrote", n_ref, "reference and", n_obs, "query points\n")
  quit(save = "no")
}

invisible(dbExecute(con, "INSTALL spatial"))
invisible(dbExecute(con, "LOAD spatial"))
if (opt$memory_limit != "default") {
  settings <- c(list(memory_limit = opt$memory_limit), settings)
}
for (s in names(settings)) {
  dbExecute(con, sprintf("SET %s = '%s'", s, settings[[s]]))
}
print(dbGetQuery(
  con,
  sprintf(
    "SELECT name, value FROM duckdb_settings() WHERE name IN (%s) ORDER BY name",
    paste0(
      "'",
      unique(c(
        "memory_limit",
        "threads",
        "preserve_insertion_order",
        "temp_directory",
        names(settings)
      )),
      "'",
      collapse = ", "
    )
  )
))

if (opt$source == "register") {
  duckdb_register(con, "geodata", geodata)
  duckdb_register(con, "dataindex", dataindex)
} else {
  for (t in c("geodata", "dataindex")) {
    path <- file.path(opt$data, paste0(t, ".parquet"))
    dbExecute(
      con,
      sprintf("CREATE VIEW %s AS FROM read_parquet('%s')", t, path)
    )
  }
}

# ---- Query -------------------------------------------------------------------

invisible(dbExecute(
  con,
  "CREATE OR REPLACE TEMP TABLE ref AS
   SELECT *, ST_GeomFromWKB(geometry) AS geom FROM geodata"
))
k <- min(as.integer(opt$k), dbGetQuery(con, "SELECT count(*) AS n FROM ref")$n)

order_by <- if (opt$variant %in% c("no_order", "no_order_limit")) {
  ""
} else {
  "ORDER BY dist"
}
limit <- if (opt$variant %in% c("no_limit", "no_order_limit")) {
  ""
} else {
  paste("LIMIT", k)
}
argmin <- if (opt$variant == "no_argmin") "NULL" else "arg_min(id_shop, dist)"

query <- function(y) {
  sprintf(
    "WITH data AS (
       SELECT obsid, year, ST_GeomFromWKB(geometry) AS geom
       FROM dataindex WHERE year = %d
     )
     SELECT d.obsid, year,
       COALESCE(stats.n_points, 0) AS n,
       stats.avg_dist,
       stats.min_dist / 1000 AS min_km,
       stats.id_shop
     FROM data d
     LEFT JOIN LATERAL (
       SELECT COUNT(*) AS n_points, AVG(dist) AS avg_dist,
         MIN(dist) AS min_dist, %s AS id_shop
       FROM (
         SELECT ST_Distance(d.geom, g.geom) AS dist, g.id_shop
         FROM ref g
         WHERE ST_DWithin(d.geom, g.geom, 2500)
         %s %s
       ) nn
     ) stats ON TRUE",
    as.integer(y),
    argmin,
    order_by,
    limit
  )
}

years <- if (opt$years == "all") 2015:2024 else as.integer(opt$years)

# Prints a profile as an indented tree: operator, rows, time summed over
# threads, bytes where the engine reports them, and the operator's details.
# Engine 1.5 and 2.0 name the fields differently.
print_profile <- function(node, depth = 0) {
  info <- node$extra_info
  info <- info[setdiff(names(info), c("Estimated Cardinality", "Projections"))]
  info <- vapply(info, function(x) paste(unlist(x), collapse = ", "), "")
  bytes <- node$intermediate_size_bytes
  cat(sprintf(
    "%s%s: %s rows%s, %.2f s%s\n",
    strrep("  ", depth),
    node$operator_name %||% node$type %||% node$operator_type,
    format(
      node$operator_cardinality %||% node$intermediate_rows,
      big.mark = ","
    ),
    if (is.null(bytes)) "" else sprintf(" (%.0f MiB)", bytes / 2^20),
    node$operator_timing %||% node$timing,
    if (length(info)) {
      paste0(" | ", paste(names(info), info, sep = ": ", collapse = "; "))
    } else {
      ""
    }
  ))
  for (child in node$children) {
    print_profile(child, depth + 1)
  }
}

if (opt$explain == "explain") {
  plan <- dbGetQuery(con, paste("EXPLAIN", query(years[[1]])))
  cat(plan[[2]], sep = "\n")
} else if (opt$explain == "analyze") {
  profile <- tempfile(fileext = ".json")
  invisible(dbExecute(con, "PRAGMA enable_profiling = 'json'"))
  invisible(dbExecute(con, sprintf("PRAGMA profiling_output = '%s'", profile)))
  t1 <- Sys.time()
  invisible(dbGetQuery(con, query(years[[1]])))
  cat(sprintf(
    "year %d: %.1f s\n",
    years[[1]],
    as.numeric(Sys.time() - t1, units = "secs")
  ))
  invisible(dbExecute(con, "PRAGMA disable_profiling"))
  json <- jsonlite::fromJSON(profile, simplifyVector = FALSE)
  # Peak buffer memory, peak temporary directory size, latency.
  sys <- json$system %||% json
  cat(sprintf(
    "peak buffer memory %.0f MiB, peak temp dir %.0f MiB, latency %.1f s\n",
    (sys$peak_buffer_memory %||% sys$system_peak_buffer_memory) / 2^20,
    (sys$peak_temp_dir_size %||% sys$system_peak_temp_dir_size) / 2^20,
    if (is.list(json$query)) json$query$total_time else json$latency
  ))
  for (root in json$operator %||% json$children) {
    print_profile(root)
  }
  quit(save = "no")
}

t0 <- Sys.time()
res <- vector("list", length(years))
for (i in seq_along(years)) {
  t1 <- Sys.time()
  res[[i]] <- dbGetQuery(con, query(years[[i]]))
  tmp <- dbGetQuery(
    con,
    "SELECT count(*) AS n, sum(size) AS size FROM duckdb_temporary_files()"
  )
  cat(sprintf(
    "year %d: %d rows, sum(n) %.0f, %.1f s, temp files %d (%.0f MiB)\n",
    years[[i]],
    nrow(res[[i]]),
    sum(res[[i]]$n),
    as.numeric(Sys.time() - t1, units = "secs"),
    tmp$n,
    if (is.na(tmp$size)) 0 else tmp$size / 2^20
  ))
}
res <- do.call(rbind, res)
cat(sprintf(
  "total: %d rows, sum(n) %.0f, mean(avg_dist) %.3f, %.1f s\n",
  nrow(res),
  sum(res$n),
  mean(res$avg_dist, na.rm = TRUE),
  as.numeric(Sys.time() - t0, units = "secs")
))
