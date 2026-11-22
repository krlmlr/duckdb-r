# The internal chunk-wise fetch entry points, called the way rapi_execute() opens a stream:
# rapi_stream_fetch() and rapi_stream_close() (src/statement.cpp)

local_stream <- function(con, sql, .local_envir = parent.frame()) {
  stmt <- rethrow_rapi_prepare(con@conn_ref, sql, new.env())
  withr::defer(rethrow_rapi_release(stmt$ref), envir = .local_envir)
  res <- rethrow_rapi_execute(
    stmt$ref,
    duckdb_convert_opts_impl(con@convert_opts, allow_stream_result = TRUE)
  )
  withr::defer(rethrow_rapi_stream_close(res), envir = .local_envir)
  res
}

stream_fetch <- function(con, res, n) {
  rethrow_rapi_stream_fetch(res, n, con@convert_opts)
}

range_sql <- function(n) {
  sprintf("SELECT i::INTEGER AS i, i::VARCHAR AS s FROM range(%d) t(i)", n)
}

test_that("a fetch returns exactly min(n, remaining) rows across chunk boundaries", {
  con <- local_con()
  total <- 10000L
  res <- local_stream(con, range_sql(total))
  expect_type(res, "externalptr")

  got <- integer()
  for (n in c(1, 2047, 3000, 2049, 5, 2048, 2048)) {
    out <- stream_fetch(con, res, n)
    expect_equal(nrow(out$df), min(n, total - length(got)))
    got <- c(got, out$df$i)
  }
  expect_identical(got, 0:(total - 1L))
  expect_true(out$eof)
})

test_that("n = -1 reads the rest, and n = 0 reads nothing", {
  con <- local_con()
  res <- local_stream(con, range_sql(5000))

  none <- stream_fetch(con, res, 0)
  expect_equal(nrow(none$df), 0)
  expect_named(none$df, c("i", "s"))
  expect_false(none$eof)

  first <- stream_fetch(con, res, 2500)
  expect_false(first$eof)
  rest <- stream_fetch(con, res, -1)
  expect_true(rest$eof)
  expect_identical(c(first$df$i, rest$df$i), 0:4999)
})

test_that("a fetch past the end returns no rows with eof", {
  con <- local_con()
  res <- local_stream(con, "SELECT i::INTEGER AS i FROM range(2048) t(i)")

  out <- stream_fetch(con, res, 2048)
  expect_equal(nrow(out$df), 2048)
  out <- stream_fetch(con, res, 1)
  expect_equal(nrow(out$df), 0)
  expect_true(out$eof)
  out <- stream_fetch(con, res, 10)
  expect_equal(nrow(out$df), 0)
  expect_named(out$df, "i")
  expect_true(out$eof)

  empty <- local_stream(con, "SELECT 1 AS i WHERE false")
  out <- stream_fetch(con, empty, 5)
  expect_equal(nrow(out$df), 0)
  expect_true(out$eof)
})

test_that("n must be -1 or a whole number", {
  con <- local_con()
  res <- local_stream(con, "SELECT 1 AS i")

  for (n in list(NA_real_, NaN, Inf, 1.5, -2, 2^70)) {
    expect_error(
      stream_fetch(con, res, n),
      "must be -1",
      class = "duckdb_error"
    )
  }
  expect_equal(nrow(stream_fetch(con, res, 1)$df), 1)
})

test_that("a closed stream refuses to fetch, and frees the connection", {
  con <- local_con()
  res <- local_stream(con, range_sql(10000))

  expect_equal(nrow(stream_fetch(con, res, 10)$df), 10)
  rethrow_rapi_stream_close(res)
  rethrow_rapi_stream_close(res)
  expect_error(stream_fetch(con, res, 1), "already been consumed")
  expect_identical(dbGetQuery(con, "SELECT 42 AS x")$x, 42L)
})

test_that("another statement invalidates an open stream, but not a drained one", {
  con <- local_con()
  res <- local_stream(con, range_sql(10000))
  expect_equal(nrow(stream_fetch(con, res, 10)$df), 10)
  dbGetQuery(con, "SELECT 1")
  expect_error(stream_fetch(con, res, 10), "invalidated")

  drained <- local_stream(con, "SELECT 1 AS i")
  expect_true(stream_fetch(con, drained, -1)$eof)
  dbGetQuery(con, "SELECT 1")
  out <- stream_fetch(con, drained, 10)
  expect_equal(nrow(out$df), 0)
  expect_true(out$eof)
})

test_that("an execution error is raised by the fetch, and the connection stays usable", {
  con <- local_con()
  sql <- "SELECT CASE WHEN i < 5000 THEN i ELSE error('boom') END AS i FROM range(10000) t(i)"
  expect_error(
    {
      res <- local_stream(con, sql)
      stream_fetch(con, res, -1)
    },
    "boom"
  )
  expect_identical(dbGetQuery(con, "SELECT 7 AS x")$x, 7L)
})

test_that("a completed result is read chunk-wise too", {
  con <- local_con()
  dbExecute(con, "CREATE TABLE t (i INTEGER)")
  # A statement that writes is completed rather than streamed
  res <- local_stream(
    con,
    "INSERT INTO t SELECT * FROM range(5000) RETURNING i"
  )

  got <- integer()
  repeat {
    out <- stream_fetch(con, res, 3000)
    expect_equal(nrow(out$df), min(3000, 5000 - length(got)))
    got <- c(got, out$df$i)
    if (out$eof) break
  }
  expect_identical(sort(got), 0:4999)
  expect_equal(dbGetQuery(con, "SELECT count(*) AS n FROM t")$n, 5000)
})

test_that("a streamed data frame is identical to dbGetQuery()'s", {
  con <- local_con()
  sql <- paste(
    "SELECT TIMESTAMPTZ '2020-01-01 12:00:00+00' AS ts, DATE '2020-01-02' AS d,",
    "1.5::DOUBLE AS x, 'x' AS s, NULL::INTEGER AS n, [1, 2] AS l,",
    "{'a': 1} AS st, 'abc'::BLOB AS b, 12345678901::BIGINT AS bi"
  )
  res <- local_stream(con, sql)
  expect_identical(stream_fetch(con, res, -1)$df, dbGetQuery(con, sql))
})

test_that("a single-row bind streams, a multi-row bind materializes", {
  con <- local_con()
  stmt <- rethrow_rapi_prepare(
    con@conn_ref,
    "SELECT i::INTEGER AS i FROM range(?::BIGINT) t(i)",
    new.env()
  )
  withr::defer(rethrow_rapi_release(stmt$ref))
  opts <- duckdb_convert_opts_impl(con@convert_opts, allow_stream_result = TRUE)

  out <- rethrow_rapi_bind(stmt$ref, list(3000L), opts)
  expect_length(out, 1)
  bound <- out[[1]]
  withr::defer(rethrow_rapi_stream_close(bound))
  expect_type(bound, "externalptr")
  expect_equal(nrow(stream_fetch(con, bound, -1)$df), 3000)

  out <- rethrow_rapi_bind(stmt$ref, list(c(2L, 3L)), opts)
  expect_length(out, 2)
  expect_equal(vapply(out, nrow, integer(1)), c(2L, 3L))
})
