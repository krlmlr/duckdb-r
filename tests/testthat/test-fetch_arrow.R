skip_on_cran()
skip_on_os("windows")
skip_if_not_installed("arrow", "5.0.0")
# Skip if parquet is not a capability as an indicator that Arrow is fully installed.
skip_if_not(
  arrow::arrow_with_parquet(),
  message = "The installed Arrow is not fully featured, skipping Arrow integration tests"
)

test_that("duckdb_fetch_arrow() test table over vector size", {
  con <- local_con()

  dbExecute(
    con,
    paste0("CREATE table test as select range a from range(10000);")
  )
  dbExecute(con, "INSERT INTO  test VALUES(NULL);")
  res <- dbSendQuery(con, "SELECT * FROM test", arrow = TRUE)
  withr::defer(dbClearResult(res))
  arrow_table <- duckdb_fetch_arrow(res)
  duckdb_register_arrow(con, "testarrow", arrow_table)

  expect_equal(
    dbGetQuery(con, "SELECT * from testarrow"),
    dbGetQuery(con, "SELECT * from test")
  )

  duckdb_unregister_arrow(con, "testarrow")
})

test_that("duckdb_fetch_arrow() empty table", {
  con <- local_con()

  dbExecute(con, paste0("CREATE TABLE test (a  INTEGER)"))

  res <- dbSendQuery(con, "SELECT * FROM test", arrow = TRUE)
  withr::defer(dbClearResult(res))
  arrow_table <- duckdb_fetch_arrow(res)
  duckdb_register_arrow(con, "testarrow", arrow_table)

  expect_equal(
    dbGetQuery(con, "SELECT * from testarrow"),
    dbGetQuery(con, "SELECT * from test")
  )

  duckdb_unregister_arrow(con, "testarrow")
})

test_that("duckdb_fetch_arrow() table with only nulls", {
  con <- local_con()

  dbExecute(con, paste0("CREATE TABLE test (a  INTEGER)"))

  dbExecute(con, "INSERT INTO  test VALUES(NULL);")
  res <- dbSendQuery(con, "SELECT * FROM test", arrow = TRUE)
  withr::defer(dbClearResult(res))
  arrow_table <- duckdb_fetch_arrow(res)
  duckdb_register_arrow(con, "testarrow", arrow_table)

  expect_equal(
    dbGetQuery(con, "SELECT * from testarrow"),
    dbGetQuery(con, "SELECT * from test")
  )

  duckdb_unregister_arrow(con, "testarrow")
})

test_that("duckdb_fetch_arrow() table with prepared statement", {
  con <- local_con()

  dbExecute(con, paste0("CREATE TABLE test (a  INTEGER)"))
  dbExecute(con, paste0("PREPARE s1 AS INSERT INTO test VALUES ($1), ($2 / 2)"))
  for (value in 1:1500) {
    dbExecute(con, sprintf("EXECUTE s1 (%d, %d);", value, value * 2))
  }
  res <- dbSendQuery(con, "SELECT * FROM test", arrow = TRUE)
  withr::defer(dbClearResult(res))
  arrow_table <- duckdb_fetch_arrow(res)
  duckdb_register_arrow(con, "testarrow", arrow_table)

  expect_equal(
    dbGetQuery(con, "SELECT * from testarrow"),
    dbGetQuery(con, "SELECT * from test")
  )

  duckdb_unregister_arrow(con, "testarrow")
})


test_that("duckdb_fetch_arrow() record_batch_reader ", {
  skip_if_not_installed("arrow", "4.0.1")
  con <- local_con()

  dbExecute(con, paste0("CREATE table t as select range a from range(3000);"))
  res <- dbSendQuery(con, "SELECT * FROM t", arrow = TRUE)
  withr::defer(dbClearResult(res))
  record_batch_reader <- duckdb_fetch_record_batch(res, 1024)
  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(1024, cur_batch$num_rows)

  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(1024, cur_batch$num_rows)

  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(952, cur_batch$num_rows)

  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(NULL, cur_batch)
})

test_that("duckdb_fetch_record_batch() closes with its connection", {
  con <- dbConnect(duckdb())
  res <- suppressWarnings(
    dbSendQuery(con, "SELECT i FROM range(3) t(i)", arrow = TRUE),
    classes = "deprecatedWarning"
  )
  reader <- duckdb_fetch_record_batch(res)
  dbClearResult(res)
  # The reader counts on its own: clearing the result does not release it.
  expect_warning(dbDisconnect(con), "1 result was still open")
  invisible(gc())

  expect_error(
    reader$read_table(),
    "connection this result was sent on has been closed"
  )
})

test_that("a result of dbSendQuery() closes with its connection", {
  skip_if_not_installed("callr")

  # The Arrow conversion reads the client context, and reading one that is gone
  # crashed or wedged the session; the subprocess and its timeout turn that into
  # a failure here.
  pkg <- get_package_name()
  message <- callr::r(
    function(pkg) {
      ns <- asNamespace(pkg)
      con <- DBI::dbConnect(ns$duckdb())
      res <- suppressWarnings(
        DBI::dbSendQuery(con, "SELECT i FROM range(3) t(i)", arrow = TRUE),
        classes = "deprecatedWarning"
      )
      suppressWarnings(DBI::dbDisconnect(con))
      invisible(gc())

      out <- tryCatch(ns$duckdb_fetch_arrow(res), error = conditionMessage)
      DBI::dbClearResult(res)
      out
    },
    list(pkg = pkg),
    timeout = 30
  )
  expect_match(message, "connection this result was sent on has been closed")

  # A plain result holds its rows from dbSendQuery() on, and is closed all the same.
  con <- dbConnect(duckdb())
  res <- dbSendQuery(con, "SELECT i FROM range(3) t(i)")
  expect_warning(dbDisconnect(con), "1 result was still open")
  invisible(gc())

  expect_error(
    dbFetch(res),
    "connection this result was sent on has been closed"
  )
  expect_silent(dbClearResult(res))
})

test_that("duckdb_fetch_arrow() record_batch_reader multiple vectors per chunk", {
  skip_if_not_installed("arrow", "4.0.1")
  con <- local_con()
  dbExecute(con, paste0("CREATE table t as select range a from range(5000);"))
  res <- dbSendQuery(con, "SELECT * FROM t", arrow = TRUE)
  withr::defer(dbClearResult(res))
  record_batch_reader <- duckdb_fetch_record_batch(res, 2048)
  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(2048, cur_batch$num_rows)

  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(2048, cur_batch$num_rows)

  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(904, cur_batch$num_rows)

  record_batch_reader$read_next_batch()
})

test_that("record_batch_reader and table error", {
  skip_if_not_installed("arrow", "4.0.1")
  con <- local_con()
  dbExecute(con, paste0("CREATE table t as select range a from range(5000);"))
  res <- dbSendQuery(con, "SELECT * FROM t", arrow = TRUE)
  withr::defer(dbClearResult(res))
  # Refused before the result is consumed, so the same result serves both.
  expect_error(duckdb_fetch_record_batch(res, 0), "Chunk Size")
  expect_error(duckdb_fetch_arrow(res, 0), "Chunk Size")
})


test_that("duckdb_fetch_arrow() record_batch_reader defaultparamenter", {
  skip_if_not_installed("arrow", "4.0.1")
  con <- local_con()
  dbExecute(con, paste0("CREATE table t as select range a from range(5000);"))
  res <- dbSendQuery(con, "SELECT * FROM t", arrow = TRUE)
  withr::defer(dbClearResult(res))
  record_batch_reader <- duckdb_fetch_record_batch(res)
  cur_batch <- record_batch_reader$read_next_batch()
  expect_equal(5000, cur_batch$num_rows)

  record_batch_reader$read_next_batch()
})

test_that("duckdb_fetch_arrow() record_batch_reader Read Table", {
  skip_if_not_installed("arrow", "4.0.1")
  con <- local_con()

  dbExecute(con, paste0("CREATE table t as select range a from range(3000);"))
  res <- dbSendQuery(con, "SELECT * FROM t", arrow = TRUE)
  withr::defer(dbClearResult(res))
  record_batch_reader <- duckdb_fetch_record_batch(res)
  arrow_table <- record_batch_reader$read_table()
  expect_equal(3000, arrow_table$num_rows)
})

test_that("fetching from a consumed query result errors instead of crashing", {
  con <- local_con()

  res <- dbSendQuery(con, "SELECT 1 AS a", arrow = TRUE)
  record_batch_reader <- duckdb_fetch_record_batch(res)
  expect_true(inherits(record_batch_reader, "RecordBatchReader"))

  # The result has been moved into the record batch reader: fetching again
  # must raise an error, not crash the session.
  expect_error(duckdb_fetch_arrow(res), "consumed")
  expect_error(duckdb_fetch_record_batch(res), "consumed")

  expect_equal(record_batch_reader$read_table()$num_rows, 1)
  dbClearResult(res)
})

test_that("duckdb_fetch_arrow() and duckdb_fetch_record_batch() refuse a cleared result", {
  con <- local_con()

  res <- dbSendQuery(con, "SELECT * FROM range(10) t(i)", arrow = TRUE)
  dbClearResult(res)
  expect_error(duckdb_fetch_arrow(res), "cleared")
  expect_error(duckdb_fetch_record_batch(res), "cleared")
})
