test_that("timezone_out works with default", {
  con <- local_con()

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(res[[1]], as.POSIXct("1970-01-01 12:00:00", tz = "UTC"))
})

test_that("timezone_out works with UTC specified", {
  con <- local_con(timezone_out = "UTC")

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(res[[1]], as.POSIXct("1970-01-01 12:00:00", tz = "UTC"))
})

test_that("timezone_out works with a specified timezone", {
  con <- local_con(timezone_out = "Pacific/Tahiti")

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(
    res[[1]],
    as.POSIXct("1970-01-01 02:00:00", tz = "Pacific/Tahiti")
  )
})

test_that("timezone_out works with '' and converts to local timezime", {
  unlockBinding(".sys.timezone", baseenv())
  withr::local_timezone("Pacific/Tahiti")
  con <- local_con(timezone_out = "")

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(
    res[[1]],
    as.POSIXct("1970-01-01 02:00:00", tz = "Pacific/Tahiti"),
    ignore_attr = TRUE
  )
})

test_that("timezone_out works with Sys.timezone", {
  unlockBinding(".sys.timezone", baseenv())
  withr::local_timezone("Pacific/Tahiti")
  con <- local_con(timezone_out = Sys.timezone())

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(
    res[[1]],
    as.POSIXct("1970-01-01 02:00:00", tz = "Pacific/Tahiti")
  )
})

test_that("timezone_out works with UTC and tz_out_convert = 'force'", {
  con <- local_con(timezone_out = "UTC", tz_out_convert = "force")

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(res[[1]], as.POSIXct("1970-01-01 12:00:00", tz = "UTC"))
})

test_that("timezone_out works with a specified timezone and tz_out_convert = 'force'", {
  con <- local_con(timezone_out = "Pacific/Tahiti", tz_out_convert = "force")

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(
    res[[1]],
    as.POSIXct("1970-01-01 12:00:00", tz = "Pacific/Tahiti")
  )
})

test_that("timezone_out works with '' and tz_out_convert = 'force': forces local timezime", {
  unlockBinding(".sys.timezone", baseenv())
  withr::local_timezone("Pacific/Tahiti")
  con <- local_con(timezone_out = "", tz_out_convert = "force")

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(
    res[[1]],
    as.POSIXct("1970-01-01 12:00:00", tz = "Pacific/Tahiti"),
    ignore_attr = TRUE
  )
})

test_that("timezone_out works with a specified local timezone and tz_out_convert = 'force': forces local timezime", {
  unlockBinding(".sys.timezone", baseenv())
  withr::local_timezone("Pacific/Tahiti")
  con <- local_con(timezone_out = Sys.timezone(), tz_out_convert = "force")

  query <- "SELECT '1970-01-01 12:00:00'::TIMESTAMP AS ts"
  res <- dbGetQuery(con, query)
  expect_equal(
    res[[1]],
    as.POSIXct("1970-01-01 12:00:00", tz = "Pacific/Tahiti")
  )
})

test_that("timezone_out gives a warning with invalid timezone, and converts to UTC", {
  expect_warning(con <- local_con(timezone_out = "not_a_timezone"))
  expect_equal(con@timezone_out, "UTC")
})

test_that("timezone_out gives a warning with NULL timezone, and converts to UTC", {
  expect_warning(con <- local_con(timezone_out = NULL))
  expect_equal(con@timezone_out, "UTC")
})

test_that("check_tz() passes a valid zone through without a warning", {
  expect_silent(expect_identical(check_tz("UTC"), "UTC"))
  expect_silent(expect_identical(check_tz("Pacific/Tahiti"), "Pacific/Tahiti"))
  expect_silent(expect_identical(check_tz(""), ""))
})

test_that("check_tz() warns for an invalid zone once the Olson list is cached", {
  # Fill the cache first: the check must still tell the zones apart afterwards.
  check_tz("UTC")

  expect_warning(
    expect_identical(check_tz("not_a_timezone"), "UTC"),
    "Invalid time zone 'not_a_timezone', falling back to UTC.",
    fixed = TRUE
  )
  expect_warning(
    expect_identical(check_tz(NULL), "UTC"),
    "Invalid time zone '', falling back to UTC.",
    fixed = TRUE
  )
})

test_that("check_tz() reads the Olson list from the session cache", {
  # As a set: `OlsonNames()` sorts in the collation of the moment,
  # and the cache was filled before testthat switched to the C locale.
  expect_setequal(olson_names(), OlsonNames())

  # A zone that only the cache knows passes, so the cache is what is consulted.
  cached <- the$olson_names
  withr::defer(the$olson_names <- cached)
  the$olson_names <- "Mars/Olympus"

  expect_silent(expect_identical(check_tz("Mars/Olympus"), "Mars/Olympus"))
  expect_warning(check_tz("UTC"), "Invalid time zone 'UTC'", fixed = TRUE)
})

test_that("check_tz() reads the Olson list again once `TZDIR` changes", {
  # On macOS, loading lubridate changes `TZDIR` in the middle of a session.
  check_tz("UTC")

  # A database that knows only one zone.
  tzdir <- withr::local_tempdir()
  dir.create(file.path(tzdir, "Mars"))
  file.create(file.path(tzdir, "Mars", "Olympus"))
  withr::local_envvar(TZDIR = tzdir)

  expect_silent(expect_identical(check_tz("Mars/Olympus"), "Mars/Olympus"))
  expect_warning(check_tz("UTC"), "Invalid time zone 'UTC'", fixed = TRUE)
})

test_that("dbConnect fails when tz_out_convert is misspecified", {
  drv <- duckdb()
  on.exit(duckdb_shutdown(drv))

  expect_error(dbConnect(drv, tz_out_convert = "nope"))
})

test_that("timezone_out and tz_out_convert = force with midnight times (#8547)", {
  con <- local_con(timezone_out = "Etc/GMT+8", tz_out_convert = "force")

  dbExecute(
    con,
    "CREATE TABLE IF NOT EXISTS test( DATE_TIME TIMESTAMP );"
  )

  dbExecute(
    con,
    "INSERT INTO test(DATE_TIME) VALUES ('1975-01-01 00:00:00'),('1975-01-01 15:27:00');"
  )

  res <- dbGetQuery(con, "SELECT * FROM test;")
  expect_equal(
    res[[1]],
    as.POSIXct(
      c("1975-01-01 00:00:00", "1975-01-01 15:27:00"),
      tz = "Etc/GMT+8"
    )
  )
})

test_that("POSIXct with local time zone", {
  con <- local_con(timezone_out = "")

  df1 <- data.frame(
    a = structure(1745781814.84963, class = c("POSIXct", "POSIXt"))
  )
  rel <- rel_from_df(con, df1)
  expect_equal(rel_to_altrep(rel), df1)

  # With extra class
  df2 <- data.frame(
    a = structure(1745781814.84963, class = c("foo", "POSIXct", "POSIXt"))
  )
  rel <- rel_from_df(con, df2, strict = FALSE)
  expect_equal(rel_to_altrep(rel), df1)

  expect_error(rel_from_df(con, df2), "convert")
})

test_that("POSIXct with local time zone and existing but empty attribute", {
  con <- local_con(timezone_out = "")

  df1 <- data.frame(
    a = structure(1745781814.84963, class = c("POSIXct", "POSIXt"))
  )
  rel <- rel_from_df(con, df1)
  expect_equal(rel_to_altrep(rel), df1)

  # With extra class
  df2 <- data.frame(
    a = structure(1745781814.84963, class = c("foo", "POSIXct", "POSIXt"))
  )
  rel <- rel_from_df(con, df2, strict = FALSE)
  expect_equal(rel_to_altrep(rel), df1)

  expect_error(rel_from_df(con, df2), "convert")
})

test_that("TIMESTAMPTZ values preserve UTC instants regardless of input offset (#184)", {
  con <- local_con()

  # No ICU needed: offset literals parse without it. The tzone label
  # depends on the build (a binary with icu built in labels with its
  # default zone), so compare instants only; labeling is pinned below
  dbExecute(con, "CREATE TABLE x (a TIMESTAMPTZ)")
  dbExecute(
    con,
    "INSERT INTO x VALUES (TIMESTAMPTZ '2024-01-10 13:03:12-08:00')"
  )
  dbExecute(
    con,
    "INSERT INTO x VALUES (TIMESTAMPTZ '2024-01-10 13:03:12-05:00')"
  )

  out <- dbReadTable(con, "x")$a
  # -08:00 → 21:03:12 UTC, -05:00 → 18:03:12 UTC
  expect_equal(
    out,
    as.POSIXct(c("2024-01-10 21:03:12", "2024-01-10 18:03:12"), tz = "UTC"),
    ignore_attr = TRUE
  )
})

test_that("TIMESTAMPTZ without icu falls back to tzone \"UTC\" (#184)", {
  # allow_extensions = FALSE makes icu absent deterministically,
  # whatever a shared extension store contains -- unless the binary
  # links icu statically, where absence cannot be produced at all
  con <- local_con(drv = duckdb(allow_extensions = FALSE))
  skip_if_builtin_icu(con)

  dbExecute(con, "CREATE TABLE x (a TIMESTAMPTZ)")
  dbExecute(
    con,
    "INSERT INTO x VALUES (TIMESTAMPTZ '2024-01-10 13:03:12-08:00')"
  )

  out <- dbReadTable(con, "x")$a
  expect_equal(out, as.POSIXct("2024-01-10 21:03:12", tz = "UTC"))

  # The ALTREP path queries the live session and falls back the same way
  out2 <- as.data.frame(rel_to_altrep(rel_from_table(con, "x")))$a
  expect_equal(attr(out2, "tzone"), "UTC")

  # The TimeZone setting itself lives in icu: without the extension,
  # setting any zone fails, 'UTC' included
  expect_error(dbExecute(con, "SET TimeZone = 'UTC'"), "icu")
})

test_that("TIMESTAMPTZ_NS is labeled with the session TimeZone, like TIMESTAMPTZ", {
  # Without icu the session falls back to a UTC label, which `timezone_out`
  # does not change: the label is the session's, not the connection's.
  con <- local_con(
    drv = duckdb(allow_extensions = FALSE),
    timezone_out = "Pacific/Tahiti"
  )
  skip_if_builtin_icu(con)

  sql <- "SELECT
    TIMESTAMPTZ '2024-01-10 13:03:12-08:00' AS us,
    '2024-01-10 13:03:12-08:00'::TIMESTAMPTZ_NS AS ns"
  res <- suppressWarnings(dbGetQuery(con, sql))
  expect_equal(attr(res$us, "tzone"), "UTC")
  expect_equal(attr(res$ns, "tzone"), "UTC")
  expect_equal(res$ns, res$us)

  # The ALTREP path labels it the same way
  rel <- rel_from_sql(con, sql)
  out <- suppressWarnings(as.data.frame(rel_to_altrep(rel)))
  expect_equal(attr(out$ns, "tzone"), "UTC")
})

test_that("TIMESTAMPTZ tzone attribute follows session TimeZone setting (#184)", {
  skip_if_no_icu()

  con <- local_con()

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/Los_Angeles'")

  res <- dbGetQuery(con, "SELECT TIMESTAMPTZ '2024-01-10 13:03:12-08:00' AS a")
  expect_equal(attr(res$a, "tzone"), "America/Los_Angeles")
  # 13:03:12 -08:00 is 21:03:12 UTC = 13:03:12 in Los Angeles (PST)
  expect_equal(
    res$a,
    as.POSIXct("2024-01-10 13:03:12", tz = "America/Los_Angeles")
  )
})

test_that("TIMESTAMPTZ session TimeZone is also picked up by ALTREP relations (#184)", {
  skip_if_no_icu()

  con <- local_con()

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/Los_Angeles'")

  dbExecute(con, "CREATE TABLE x (a TIMESTAMPTZ)")
  dbExecute(
    con,
    "INSERT INTO x VALUES (TIMESTAMPTZ '2024-01-10 13:03:12-08:00')"
  )

  out <- as.data.frame(rel_to_altrep(rel_from_table(con, "x")))
  expect_equal(attr(out$a, "tzone"), "America/Los_Angeles")
  expect_equal(
    out$a,
    as.POSIXct("2024-01-10 13:03:12", tz = "America/Los_Angeles")
  )
})

test_that("TIMESTAMP (no TZ) is unaffected by session TimeZone (#184)", {
  skip_if_no_icu()

  con <- local_con()

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/Los_Angeles'")

  res <- dbGetQuery(con, "SELECT TIMESTAMP '2024-01-10 13:03:12' AS a")
  # Plain TIMESTAMP keeps the connection-level `timezone_out`
  expect_equal(attr(res$a, "tzone"), "UTC")
  expect_equal(res$a, as.POSIXct("2024-01-10 13:03:12", tz = "UTC"))
})

test_that("TIMESTAMPTZ label without icu stays UTC under a non-UTC local time zone (#184)", {
  withr::local_timezone("Pacific/Tahiti")

  con <- local_con(drv = duckdb(allow_extensions = FALSE))
  skip_if_builtin_icu(con)

  res <- dbGetQuery(con, "SELECT TIMESTAMPTZ '2024-01-10 13:03:12-08:00' AS a")
  expect_equal(attr(res$a, "tzone"), "UTC")
  expect_equal(res$a, as.POSIXct("2024-01-10 21:03:12", tz = "UTC"))
})

test_that("TIMESTAMPTZ session TimeZone wins over the local time zone (#184)", {
  skip_if_no_icu()
  withr::local_timezone("Pacific/Tahiti")

  con <- local_con()

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/Los_Angeles'")

  res <- dbGetQuery(con, "SELECT TIMESTAMPTZ '2024-01-10 13:03:12-08:00' AS a")
  expect_equal(attr(res$a, "tzone"), "America/Los_Angeles")
  expect_equal(
    res$a,
    as.POSIXct("2024-01-10 13:03:12", tz = "America/Los_Angeles")
  )
})

test_that("TIMESTAMPTZ ignores timezone_out where plain TIMESTAMP follows it (#184)", {
  skip_if_no_icu()

  con <- local_con(timezone_out = "Pacific/Tahiti")

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/Los_Angeles'")

  res <- dbGetQuery(
    con,
    "
    SELECT
      TIMESTAMPTZ '2024-01-10 13:03:12-08:00' AS tstz,
      TIMESTAMP '2024-01-10 13:03:12' AS ts
  "
  )
  expect_equal(attr(res$tstz, "tzone"), "America/Los_Angeles")
  expect_equal(
    res$tstz,
    as.POSIXct("2024-01-10 13:03:12", tz = "America/Los_Angeles")
  )
  # 13:03:12 UTC wall clock rendered in timezone_out (Tahiti is UTC-10)
  expect_equal(attr(res$ts, "tzone"), "Pacific/Tahiti")
  expect_equal(res$ts, as.POSIXct("2024-01-10 03:03:12", tz = "Pacific/Tahiti"))
})

test_that("tz_out_convert = 'force' overrides the session TimeZone for TIMESTAMPTZ (#184)", {
  skip_if_no_icu()

  con <- local_con(timezone_out = "Pacific/Tahiti", tz_out_convert = "force")

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/Los_Angeles'")

  res <- dbGetQuery(con, "SELECT TIMESTAMPTZ '2024-01-10 13:03:12-08:00' AS a")
  # Force relabels the UTC rendering (21:03:12), not the session's (13:03:12)
  expect_equal(attr(res$a, "tzone"), "Pacific/Tahiti")
  expect_equal(res$a, as.POSIXct("2024-01-10 21:03:12", tz = "Pacific/Tahiti"))
})

test_that("tz_out_convert = force handles invalid timestamps during DST transitions", {
  withr::local_timezone("Europe/London")

  # This test reproduces the issue where invalid timestamps during DST transitions
  # cause all timestamps to lose their time component when tz_out_convert = "force"
  con <- local_con(timezone_out = "Europe/London", tz_out_convert = "force")

  # Test with a single valid timestamp
  query1 <- "VALUES ('2025-03-30 00:59:00'::TIMESTAMP);"
  res1 <- dbGetQuery(con, query1)
  expected1 <- as.POSIXct("2025-03-30 00:59:00", tz = "Europe/London")
  expect_equal(res1[[1]], expected1)

  # Test with mixed valid and invalid timestamps
  # 2025-03-30 01:00:00 does not exist in Europe/London (DST transition)
  query2 <- "VALUES ('2025-03-30 00:59:00'::TIMESTAMP), ('2025-03-30 01:00:00'::TIMESTAMP);"
  res2 <- dbGetQuery(con, query2)

  # The first timestamp should remain valid with full time information
  # The second should be NA (not stripped to date only)
  expected2 <- tz_force_one(
    timezone = "Europe/London",
    c(
      as.POSIXct(
        "2025-03-30 00:59:00",
        format = "%Y-%m-%d %H:%M:%OS",
        tzone = "UTC"
      ),
      as.POSIXct(
        "2025-03-30 01:00:00",
        format = "%Y-%m-%d %H:%M:%OS",
        tzone = "UTC"
      )
    )
  )
  expect_equal(res2[[1]], expected2)
})

test_that("POSIXct columns are sent as TIMESTAMPTZ by default (#184)", {
  con <- local_con()

  df <- data.frame(a = as.POSIXct("2024-01-10 13:03:12", tz = "UTC"))
  duckdb_register(con, "df", df)

  expect_equal(
    dbGetQuery(con, "DESCRIBE FROM df")$column_type,
    "TIMESTAMP WITH TIME ZONE"
  )
  expect_equal(dbDataType(con, df$a), "TIMESTAMPTZ")
  # The instant survives, whatever zone labels it on the way back
  expect_equal(dbGetQuery(con, "FROM df")$a, df$a, ignore_attr = TRUE)
})

test_that("posixct = 'timestamp' is the way back to the naive mapping (#2574)", {
  con <- local_con(posixct = "timestamp")

  df <- data.frame(a = as.POSIXct("2024-01-10 13:03:12", tz = "UTC"))
  duckdb_register(con, "df", df)

  expect_equal(dbGetQuery(con, "DESCRIBE FROM df")$column_type, "TIMESTAMP")
  expect_equal(dbDataType(con, df$a), "TIMESTAMP")
})

test_that("the default reaches dbWriteTable() and dbAppendTable() (#2574)", {
  con <- local_con()

  df <- data.frame(a = as.POSIXct("2024-01-10 13:03:12", tz = "UTC"))
  dbWriteTable(con, "t", df)

  expect_equal(
    dbGetQuery(con, "DESCRIBE t")$column_type,
    "TIMESTAMP WITH TIME ZONE"
  )

  dbAppendTable(con, "t", df)
  expect_equal(dbReadTable(con, "t")$a, rep(df$a, 2), ignore_attr = TRUE)
})

test_that("the default reaches nested columns (#2574)", {
  con <- local_con()

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  df <- data.frame(row = 1L)
  df$l <- list(instant)
  df$s <- data.frame(t = instant)
  duckdb_register(con, "df", df)

  types <- dbGetQuery(con, "DESCRIBE FROM df")$column_type
  expect_equal(
    types,
    c(
      "INTEGER",
      "TIMESTAMP WITH TIME ZONE[]",
      "STRUCT(t TIMESTAMP WITH TIME ZONE)"
    )
  )
})

# A type assertion at a UTC session zone passes whatever the nested values
# are, because a naive value read as UTC lands on the same instant. These
# assert values, under a session zone where the two differ by five hours.
test_that("nested values keep the instant at a non-UTC session zone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")

  df <- data.frame(row = 1L)
  df$l <- list(instant)
  df$s <- data.frame(t = instant)
  duckdb_register(con, "df", df)
  expect_equal(
    dbGetQuery(con, "SELECT l[1] AS a FROM df")$a,
    instant,
    ignore_attr = TRUE
  )
  expect_equal(
    dbGetQuery(con, "SELECT s.t AS a FROM df")$a,
    instant,
    ignore_attr = TRUE
  )
})

test_that("nested bound parameters keep the instant too (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")

  # A `POSIXct` one level down has to be sent as TIMESTAMPTZ as well: sent as
  # TIMESTAMP, the cast into the column reads it as a local wall clock and
  # moves it by the session offset
  expect_equal(
    dbGetQuery(con, "SELECT typeof(?) AS t", params = list(list(instant)))$t,
    "TIMESTAMP WITH TIME ZONE[]"
  )
  expect_equal(
    dbGetQuery(
      con,
      "SELECT typeof(?) AS t",
      params = list(data.frame(t = instant))
    )$t,
    "STRUCT(t TIMESTAMP WITH TIME ZONE)"
  )

  dbExecute(con, "CREATE TABLE t (a TIMESTAMPTZ[])")
  dbExecute(con, "INSERT INTO t VALUES (?)", params = list(list(instant)))
  expect_equal(
    dbGetQuery(con, "SELECT a[1] AS a FROM t")$a,
    instant,
    ignore_attr = TRUE
  )
})

# A relation promises the data frame back unchanged, which TIMESTAMPTZ cannot
# keep: it comes back labeled with the session zone. Measured in
# experiments/2026-08-09-rel-from-df-posixct/README.md.
test_that("rel_from_df() stays on TIMESTAMP under the default (#2574)", {
  con <- local_con()

  df <- data.frame(a = as.POSIXct("2024-01-10 13:03:12", tz = "UTC"))
  rel <- rel_from_df(con, df)
  rel_to_table(rel, "main", "t", FALSE)

  expect_equal(dbGetQuery(con, "DESCRIBE t")$column_type, "TIMESTAMP")
  expect_equal(rel_to_altrep(rel), df)
})

test_that("rel_from_df() follows `convert_opts` when the caller passes it (#2574)", {
  con <- local_con()

  df <- data.frame(a = as.POSIXct("2024-01-10 13:03:12", tz = "UTC"))
  rel <- rel_from_df(con, df, convert_opts = con@convert_opts)
  rel_to_table(rel, "main", "t", FALSE)

  expect_equal(
    dbGetQuery(con, "DESCRIBE t")$column_type,
    "TIMESTAMP WITH TIME ZONE"
  )
  expect_equal(as.data.frame(rel)$a, df$a, ignore_attr = TRUE)
})

test_that("the default reaches bound parameters and literals (#2574)", {
  con <- local_con()

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbExecute(con, "CREATE TABLE t (a TIMESTAMPTZ)")
  dbExecute(con, "INSERT INTO t VALUES (?)", params = list(instant))

  expect_equal(dbReadTable(con, "t")$a, instant, ignore_attr = TRUE)

  literal <- dbQuoteLiteral(con, instant)
  expect_match(as.character(literal), "::timestamptz$")
  expect_equal(
    dbGetQuery(con, paste0("SELECT ", literal, " AS a"))$a,
    instant,
    ignore_attr = TRUE
  )
})

test_that("the default round-trips the zone via the session TimeZone (#184)", {
  skip_if_no_icu()

  con <- local_con()

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  df <- data.frame(
    a = as.POSIXct("2000-01-01 12:13:14", tz = "America/New_York")
  )
  dbWriteTable(con, "t", df)

  # Instant *and* label survive, which the TIMESTAMP mapping cannot do
  expect_equal(dbReadTable(con, "t"), df)
})

test_that("a bound POSIXct compares equal to a TIMESTAMPTZ column under a non-UTC session zone (#2574)", {
  skip_if_no_icu()

  con <- local_con()

  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  instant <- as.POSIXct("2000-01-01 12:13:14", tz = "America/New_York")
  dbWriteTable(con, "t", data.frame(a = instant))

  res <- dbGetQuery(con, "SELECT * FROM t WHERE a = ?", params = list(instant))
  expect_equal(nrow(res), 1L)
})

test_that("dbConnect() rejects an unknown posixct value (#2574)", {
  drv <- duckdb()
  on.exit(duckdb_shutdown(drv))

  expect_error(dbConnect(drv, posixct = "nope"), "posixct")
})

test_that("expr_constant() stays on TIMESTAMP with the relational path (#2574)", {
  con <- local_con()

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  rel <- rel_from_df(con, data.frame(a = 1L))
  rel <- rel_project(rel, list(expr_constant(instant, alias = "t", con = con)))
  rel_to_table(rel, "main", "t", FALSE)

  expect_equal(dbGetQuery(con, "DESCRIBE t")$column_type, "TIMESTAMP")
})

# A POSIXct scans as TIMESTAMPTZ, and a cast from that into a naive timestamp
# takes the wall clock in the session zone once icu is loaded. Written into a
# naive column, it must keep the UTC wall clock that `posixct = "timestamp"`
# writes, whether icu is loaded or not.
test_that("dbAppendTable() into naive timestamp columns stores UTC without icu loaded (#2574)", {
  withr::local_timezone("Europe/Berlin")
  con <- local_con()

  dbExecute(con, "CREATE TABLE t (a TIMESTAMP, b TIMESTAMP_NS, c TIMESTAMP_S)")
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbAppendTable(con, "t", data.frame(a = instant, b = instant, c = instant))

  expect_equal(
    unlist(dbGetQuery(
      con,
      "SELECT a::VARCHAR, b::VARCHAR, c::VARCHAR FROM t"
    )),
    rep("2024-01-10 13:03:12", 3),
    ignore_attr = TRUE
  )
})

test_that("dbAppendTable() into naive timestamp columns stores UTC with icu loaded (#2574)", {
  skip_if_no_icu()
  withr::local_timezone("Europe/Berlin")

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")

  dbExecute(con, "CREATE TABLE t (a TIMESTAMP, b TIMESTAMP_NS, z TIMESTAMPTZ)")
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbAppendTable(con, "t", data.frame(a = instant, b = instant, z = instant))

  res <- dbGetQuery(con, "SELECT a::VARCHAR AS a, b::VARCHAR AS b FROM t")
  expect_equal(res$a, "2024-01-10 13:03:12")
  expect_equal(res$b, "2024-01-10 13:03:12")
  # A TIMESTAMPTZ column keeps the instant
  expect_equal(dbReadTable(con, "t")$z, instant, ignore_attr = TRUE)
})

test_that("dbAppendTable() into naive timestamp columns ignores SET TimeZone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  dbExecute(con, "CREATE TABLE t (a TIMESTAMP, b TIMESTAMP_NS, c TIMESTAMP_MS)")
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbAppendTable(con, "t", data.frame(a = instant, b = instant, c = instant))

  expect_equal(
    unlist(dbGetQuery(
      con,
      "SELECT a::VARCHAR, b::VARCHAR, c::VARCHAR FROM t"
    )),
    rep("2024-01-10 13:03:12", 3),
    ignore_attr = TRUE
  )
})

test_that("dbWriteTable(field.types =) to naive timestamps ignores SET TimeZone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbWriteTable(
    con,
    "t",
    data.frame(a = instant, b = instant, c = instant, z = instant),
    field.types = c(
      a = "TIMESTAMP",
      b = "TIMESTAMP_NS",
      c = "datetime",
      z = "TIMESTAMPTZ"
    )
  )

  expect_equal(
    dbGetQuery(con, "DESCRIBE t")$column_type,
    c("TIMESTAMP", "TIMESTAMP_NS", "TIMESTAMP", "TIMESTAMP WITH TIME ZONE")
  )
  expect_equal(
    unlist(dbGetQuery(
      con,
      "SELECT a::VARCHAR, b::VARCHAR, c::VARCHAR FROM t"
    )),
    rep("2024-01-10 13:03:12", 3),
    ignore_attr = TRUE
  )
  expect_equal(dbReadTable(con, "t")$z, instant, ignore_attr = TRUE)
})

test_that("dbWriteTable(append = TRUE) into a naive timestamp column ignores SET TimeZone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  dbExecute(con, "CREATE TABLE t (a TIMESTAMP)")
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbWriteTable(con, "t", data.frame(a = instant), append = TRUE)

  expect_equal(
    dbGetQuery(con, "SELECT a::VARCHAR AS a FROM t")$a,
    "2024-01-10 13:03:12"
  )
})

test_that("dbCreateTable() and dbAppendTable() into a naive timestamp column ignore SET TimeZone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  df <- data.frame(a = instant, z = instant)
  dbCreateTable(con, "t", c(a = "TIMESTAMP", z = "TIMESTAMPTZ"))
  dbAppendTable(con, "t", df)

  expect_equal(
    dbGetQuery(con, "SELECT a::VARCHAR AS a FROM t")$a,
    "2024-01-10 13:03:12"
  )
  expect_equal(dbReadTable(con, "t")$z, instant, ignore_attr = TRUE)
})

test_that("convert_opts without posixct falls back to the default everywhere (#2574)", {
  con <- local_con()
  con@convert_opts$posixct <- NULL

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  duckdb_register(con, "df", data.frame(a = instant))

  expect_equal(
    dbGetQuery(con, "DESCRIBE FROM df")$column_type,
    "TIMESTAMP WITH TIME ZONE"
  )
  expect_equal(dbDataType(con, instant), "TIMESTAMPTZ")
  expect_match(dbQuoteLiteral(con, instant), "::timestamptz$")
})

test_that("convert_opts with a missing posixct falls back to the default everywhere (#2574)", {
  con <- local_con()
  con@convert_opts$posixct <- NA_character_

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  duckdb_register(con, "df", data.frame(a = instant))

  expect_equal(
    dbGetQuery(con, "DESCRIBE FROM df")$column_type,
    "TIMESTAMP WITH TIME ZONE"
  )
  expect_equal(dbDataType(con, instant), "TIMESTAMPTZ")
  expect_match(dbQuoteLiteral(con, instant), "::timestamptz$")
})

# UTC+14, so 13:03:12 UTC is 03:03:12 on the next day there
test_that("dbAppendTable() into nested naive timestamps ignores SET TimeZone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'Pacific/Kiritimati'")

  dbExecute(
    con,
    "CREATE TABLE t (s STRUCT(a TIMESTAMP), l TIMESTAMP[], m MAP(VARCHAR, TIMESTAMP))"
  )
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  df <- data.frame(row = 1L)
  df$s <- data.frame(a = instant)
  df$l <- list(c(instant, instant))
  df$m <- list(data.frame(key = "k", value = instant))
  df$row <- NULL
  dbAppendTable(con, "t", df)

  expect_equal(
    unlist(dbGetQuery(
      con,
      "SELECT s.a::VARCHAR, l[2]::VARCHAR, m['k']::VARCHAR FROM t"
    )),
    rep("2024-01-10 13:03:12", 3),
    ignore_attr = TRUE
  )
})

test_that("dbAppendTable() into DATE and TIME ignores SET TimeZone, VARCHAR takes its offset (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'Pacific/Kiritimati'")

  dbExecute(con, "CREATE TABLE t (d DATE, t TIME, v VARCHAR)")
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbAppendTable(con, "t", data.frame(d = instant, t = instant, v = instant))

  expect_equal(
    unlist(dbGetQuery(con, "SELECT d::VARCHAR, t::VARCHAR, v FROM t")),
    c("2024-01-10", "13:03:12", "2024-01-11 03:03:12+14"),
    ignore_attr = TRUE
  )
})

test_that("dbWriteTable(append = TRUE) into DATE and nested naive timestamps ignores SET TimeZone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'Pacific/Kiritimati'")

  dbExecute(con, "CREATE TABLE t (d DATE, s STRUCT(a TIMESTAMP_NS))")
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  df <- data.frame(d = instant)
  df$s <- data.frame(a = instant)
  dbWriteTable(con, "t", df, append = TRUE)

  expect_equal(
    unlist(dbGetQuery(con, "SELECT d::VARCHAR, s.a::VARCHAR FROM t")),
    c("2024-01-10", "2024-01-10 13:03:12"),
    ignore_attr = TRUE
  )
})

test_that("dbWriteTable(field.types =) to DATE, TIME and nested naive timestamps ignores SET TimeZone (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'Pacific/Kiritimati'")

  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  df <- data.frame(d = instant, t = instant)
  df$l <- list(c(instant, instant))
  dbWriteTable(
    con,
    "t",
    df,
    field.types = c(d = "date", t = "TIME", l = "TIMESTAMP[]")
  )

  expect_equal(
    unlist(dbGetQuery(
      con,
      "SELECT d::VARCHAR, t::VARCHAR, l[1]::VARCHAR FROM t"
    )),
    c("2024-01-10", "13:03:12", "2024-01-10 13:03:12"),
    ignore_attr = TRUE
  )
})

test_that("a nested target with naive and zoned timestamps takes the session zone for the naive one (#2574)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "LOAD icu")
  dbExecute(con, "SET TimeZone = 'Pacific/Kiritimati'")

  dbExecute(con, "CREATE TABLE t (s STRUCT(a TIMESTAMP, z TIMESTAMPTZ))")
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  df <- data.frame(row = 1L)
  df$s <- data.frame(a = instant, z = instant)
  df$row <- NULL
  dbAppendTable(con, "t", df)

  # The zoned field keeps the instant, so the column scans as `TIMESTAMPTZ`,
  # and the naive field takes the wall clock in the session zone
  expect_equal(
    dbGetQuery(con, "SELECT s.a::VARCHAR AS a FROM t")$a,
    "2024-01-11 03:03:12"
  )
  expect_equal(
    dbGetQuery(con, "SELECT epoch(s.z) AS z FROM t")$z,
    as.numeric(instant)
  )
})

test_that("only a POSIXct going into a naive temporal type scans naive (#2574)", {
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  value <- data.frame(
    a = instant,
    b = instant,
    c = 1L,
    d = instant,
    e = instant
  )
  value$s <- data.frame(x = instant)
  target_types <- c(
    a = "TIMESTAMP",
    b = "TIMESTAMP WITH TIME ZONE",
    c = "DATE",
    d = "STRUCT(date INTEGER)",
    e = "TIME_NS",
    s = "STRUCT(x TIMESTAMP_MS)"
  )

  expect_equal(
    duckdb_posixct_naive_columns(value, target_types),
    c("a", "s")
  )
})

test_that("dbConnect() sets the session TimeZone to UTC (#2646)", {
  skip_if_no_icu()

  # Installed before the connection opens, so the alignment finds it
  setup <- local_con()
  dbExecute(setup, "INSTALL icu")

  # A machine zone that is not UTC, which icu would default to
  withr::local_timezone("America/New_York")
  con <- local_con()

  # Whatever zone the machine is on, a fresh connection starts on UTC
  expect_equal(
    dbGetQuery(con, "SELECT current_setting('TimeZone') AS tz")$tz,
    "UTC"
  )
  expect_true(
    dbGetQuery(
      con,
      "SELECT loaded FROM duckdb_extensions() WHERE extension_name = 'icu'"
    )$loaded
  )

  # Which is the zone a naive TIMESTAMP is read in, so one round-trips
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbExecute(con, "CREATE TABLE t (a TIMESTAMP)")
  dbAppendTable(con, "t", data.frame(a = instant))
  expect_equal(dbReadTable(con, "t")$a, instant, ignore_attr = TRUE)
  expect_equal(
    nrow(dbGetQuery(
      con,
      "SELECT * FROM t WHERE a = ?",
      params = list(instant)
    )),
    1L
  )
})

test_that("the alignment is a default, and `SET TimeZone` still wins (#2646)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")
  dbExecute(con, "SET TimeZone = 'America/New_York'")

  expect_equal(
    dbGetQuery(con, "SELECT current_setting('TimeZone') AS tz")$tz,
    "America/New_York"
  )

  # And a bound `POSIXct` stops matching a naive column once it does:
  # the write keeps the UTC wall clock, but the parameter is a TIMESTAMPTZ
  # that the comparison casts in the session zone
  instant <- as.POSIXct("2024-01-10 13:03:12", tz = "UTC")
  dbExecute(con, "CREATE TABLE t (a TIMESTAMP)")
  dbAppendTable(con, "t", data.frame(a = instant))
  expect_equal(
    dbGetQuery(con, "SELECT a::VARCHAR AS a FROM t")$a,
    "2024-01-10 13:03:12"
  )
  expect_equal(
    nrow(dbGetQuery(
      con,
      "SELECT * FROM t WHERE a = ?",
      params = list(instant)
    )),
    0L
  )
})

test_that("a connection still opens where icu cannot be loaded (#2646)", {
  con <- local_con(drv = duckdb(allow_extensions = FALSE))

  # The alignment asks `duckdb_extensions()` first and gives up quietly,
  # rather than reaching for a setting that would try to autoload icu
  expect_true(dbIsValid(con))
  expect_equal(dbGetQuery(con, "SELECT 1 AS a")$a, 1)
})

test_that("a TimeZone named in duckdb(config =) is kept (#2646)", {
  skip_if_no_icu()

  con <- local_con()
  dbExecute(con, "INSTALL icu")

  con <- local_con(drv = duckdb(config = list(TimeZone = "Asia/Tokyo")))
  expect_equal(
    dbGetQuery(con, "SELECT current_setting('TimeZone') AS tz")$tz,
    "Asia/Tokyo"
  )
})

test_that("a TimeZone named in dbConnect(config =) on a live instance is kept (#2646)", {
  skip_if_no_icu()

  drv <- duckdb()
  setup <- local_con(drv = drv)
  dbExecute(setup, "INSTALL icu")

  # The instance exists already and cannot take the setting,
  # so the session does
  con <- dbConnect(drv, config = list(TimeZone = "Europe/Paris"))
  withr::defer(dbDisconnect(con))
  expect_equal(
    dbGetQuery(con, "SELECT current_setting('TimeZone') AS tz")$tz,
    "Europe/Paris"
  )
})

test_that("SET GLOBAL TimeZone survives later connections (#2646)", {
  skip_if_no_icu()

  drv <- duckdb()
  first <- local_con(drv = drv)
  dbExecute(first, "INSTALL icu")
  dbExecute(first, "LOAD icu")
  dbExecute(first, "SET GLOBAL TimeZone = 'Asia/Tokyo'")

  # A session `SET TimeZone = 'UTC'` on the next connection would mask
  # the global choice, so the alignment leaves that connection alone
  con <- dbConnect(drv)
  withr::defer(dbDisconnect(con))
  expect_equal(
    dbGetQuery(con, "SELECT current_setting('TimeZone') AS tz")$tz,
    "Asia/Tokyo"
  )

  # Until the global setting goes back to its default
  dbExecute(first, "RESET GLOBAL TimeZone")
  again <- dbConnect(drv)
  withr::defer(dbDisconnect(again))
  expect_equal(
    dbGetQuery(again, "SELECT current_setting('TimeZone') AS tz")$tz,
    "UTC"
  )
})

test_that("a connection opens and leaves icu alone where it is not installed (#2646)", {
  skip_if_no_icu()

  dir <- withr::local_tempdir()
  drv <- duckdb(
    config = list(
      extension_directory = dir,
      secret_directory = file.path(dir, "secrets"),
      autoload_known_extensions = "FALSE"
    ),
    allow_extensions = TRUE
  )
  con <- local_con(drv = drv)
  skip_if_builtin_icu(con)

  # Nothing was installed under `dir`, so nothing was loaded or set
  expect_true(dbIsValid(con))
  expect_false(icu_loaded(con))
  expect_equal(
    dbGetQuery(
      con,
      "SELECT installed FROM duckdb_extensions() WHERE extension_name = 'icu'"
    )$installed,
    FALSE
  )
})
