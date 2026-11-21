test_that("long-running queries can be cancelled", {
  skip_if_not_installed("callr")
  # Skip on Windows for R < 4.4, the signal doesn't seem to make it through
  # (but works for the toy repository)
  skip_if(getRversion() < "4.4.0" && .Platform$OS.type == "windows")
  skip_on_cran()

  r_session <- callr::r_session$new()
  pkg <- get_package_name()

  r_session$run(
    function(pkg) {
      .GlobalEnv$con <- DBI::dbConnect(asNamespace(pkg)$duckdb())
      DBI::dbExecute(
        .GlobalEnv$con,
        "CREATE TABLE data AS SELECT unnest(generate_series(1, 100000)) AS a"
      )
    },
    args = list(pkg)
  )

  r_session$call(function() {
    .GlobalEnv$interrupted <- FALSE
    tryCatch(
      DBI::dbGetQuery(
        .GlobalEnv$con,
        "SELECT COUNT(*) FROM data JOIN data AS data2 ON data.a != data2.a"
      ),
      interrupt = function(e) {
        .GlobalEnv$interrupted <- TRUE
      }
    )
  })

  start_time <- Sys.time()

  Sys.sleep(0.2)
  expect_equal(r_session$get_state(), "busy")
  polled <- r_session$poll_process(200)
  expect_equal(polled, "timeout")
  r_session$interrupt()
  polled <- r_session$poll_process(200)
  expect_equal(polled, "ready")
  expect_equal(r_session$read()$code, 200)
  expect_equal(r_session$get_state(), "idle")

  expect_true(r_session$run(function() .GlobalEnv$interrupted))

  end_time <- Sys.time()

  r_session$run(function() DBI::dbDisconnect(.GlobalEnv$con))
  r_session$close()

  expect_lt(end_time - start_time, 1)
})

test_that("an interrupted chunk-wise fetch does not read as complete", {
  skip_if_not_installed("callr")
  skip_if(getRversion() < "4.4.0" && .Platform$OS.type == "windows")
  skip_on_cran()

  r_session <- callr::r_session$new()
  pkg <- get_package_name()

  r_session$run(
    function(pkg) {
      ns <- asNamespace(pkg)
      .GlobalEnv$ns <- ns
      .GlobalEnv$con <- DBI::dbConnect(ns$duckdb())
      DBI::dbExecute(
        .GlobalEnv$con,
        "CREATE TABLE data AS SELECT unnest(generate_series(1, 100000)) AS a"
      )
      con <- .GlobalEnv$con
      stmt <- ns$rapi_prepare(
        con@conn_ref,
        "SELECT COUNT(*) AS n FROM data JOIN data AS data2 ON data.a != data2.a",
        new.env()
      )
      .GlobalEnv$stmt <- stmt
      .GlobalEnv$res <- ns$rapi_execute(
        stmt$ref,
        ns$duckdb_convert_opts_impl(
          con@convert_opts,
          allow_stream_result = TRUE
        )
      )
    },
    args = list(pkg)
  )

  r_session$call(function() {
    .GlobalEnv$interrupted <- FALSE
    tryCatch(
      .GlobalEnv$ns$rapi_stream_fetch(
        .GlobalEnv$res,
        -1,
        .GlobalEnv$con@convert_opts
      ),
      interrupt = function(e) {
        .GlobalEnv$interrupted <- TRUE
      }
    )
  })

  Sys.sleep(0.2)
  expect_equal(r_session$get_state(), "busy")
  r_session$interrupt()
  expect_equal(r_session$poll_process(2000), "ready")
  expect_equal(r_session$read()$code, 200)
  expect_true(r_session$run(function() .GlobalEnv$interrupted))

  refetched <- r_session$run(function() {
    tryCatch(
      {
        .GlobalEnv$ns$rapi_stream_fetch(
          .GlobalEnv$res,
          -1,
          .GlobalEnv$con@convert_opts
        )
        "no error"
      },
      error = function(e) conditionMessage(e)
    )
  })
  expect_match(refetched, "interrupted")

  r_session$run(function() DBI::dbDisconnect(.GlobalEnv$con))
  r_session$close()
})
