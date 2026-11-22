# Handbook: handbook/usage/memory/writing/README.md
#' @rdname duckdb_connection-class
#' @inheritParams DBI::dbAppendTable
#' @usage NULL
dbAppendTable__duckdb_connection <- function(
  conn,
  name,
  value,
  ...,
  row.names = NULL
) {
  if (!is.null(row.names)) {
    abort("Can't pass `row.names` to `dbAppendTable()`")
  }

  target_names <- dbListFields(conn, name)

  if (!all(names(value) %in% target_names)) {
    abort(paste0(
      "Column `",
      setdiff(names(value), target_names)[[1]],
      "` does not exist in target table."
    ))
  }

  if (nrow(value)) {
    table_name <- dbQuoteIdentifier(conn, name)

    target_types <- duckdb_target_column_types(conn, name)

    view_name <- sprintf("_duckdb_append_view_%s", duckdb_random_string())
    on.exit(duckdb_unregister(conn, view_name))
    duckdb_register_impl(
      conn,
      view_name,
      value,
      posixct_naive_columns = duckdb_posixct_naive_columns(value, target_types),
      posixct_tz_columns = duckdb_posixct_tz_columns(value, target_types)
    )

    select_exprs <- duckdb_select_exprs_for_target(
      conn,
      names(value),
      target_types
    )

    sql <- paste0(
      "INSERT INTO ",
      table_name,
      "\n",
      "(",
      paste(dbQuoteIdentifier(conn, names(value)), collapse = ", "),
      ")\n",
      "SELECT ",
      paste(select_exprs, collapse = ", "),
      " FROM ",
      view_name
    )

    dbExecute(conn, sql)

    rs_on_connection_updated(
      conn,
      hint = paste0("Updated table'", table_name, "'")
    )
  }

  invisible(nrow(value))
}

# Build a named vector mapping target column names to DuckDB column type strings.
duckdb_target_column_types <- function(conn, name) {
  info <- dbGetQuery(
    conn,
    paste0("DESCRIBE ", dbQuoteIdentifier(conn, name))
  )
  structure(info$column_type, names = info$column_name)
}

# Build SELECT column expressions,
# converting source representations into the target column types where DuckDB cannot implicitly cast (e.g. MAP).
duckdb_select_exprs_for_target <- function(conn, col_names, target_types) {
  vapply(
    col_names,
    function(col_name) {
      quoted <- dbQuoteIdentifier(conn, col_name)
      target_type <- target_types[[col_name]]
      if (!is.null(target_type) && duckdb_is_map_type(target_type)) {
        # `map_from_entries()` builds a MAP from a LIST(STRUCT(key, value)) representation, which matches how MAPs are read back into R.
        paste0("map_from_entries(", quoted, ") AS ", quoted)
      } else {
        as.character(quoted)
      }
    },
    character(1),
    USE.NAMES = FALSE
  )
}

# Returns TRUE if `type` is a top-level DuckDB MAP type,
# e.g. "MAP(VARCHAR, INTEGER)".
# Returns FALSE for nested types such as "MAP(VARCHAR, INTEGER)[]" (array of MAP) or "STRUCT(m MAP(...))".
duckdb_is_map_type <- function(type) {
  grepl("^MAP\\(.*\\)$", type)
}

# The columns of `value` that carry a `POSIXct`, at the top or nested,
# and go into a type in `target_types` that holds a naive temporal type and no zoned one.
# `dbAppendTable()` and `dbWriteTable()` register these to scan as `TIMESTAMP`,
# since the engine's cast from `TIMESTAMPTZ` into a naive type takes the wall clock in the session `TimeZone`
# once icu is loaded, and the UTC one before;
# from `TIMESTAMP` it takes the UTC wall clock either way, as `posixct = "timestamp"` writes it.
# Handbook: handbook/usage/timestamps/README.md
duckdb_posixct_naive_columns <- function(value, target_types) {
  duckdb_posixct_columns_into(value, target_types, "naive")
}

# The counterpart for a type that holds a zoned temporal type and no naive one.
# `dbAppendTable()` and `dbWriteTable()` register these to scan as `TIMESTAMPTZ`
# whatever `dbConnect(posixct = )` says,
# since the cast from `TIMESTAMP` into a zoned type reads the wall clock in the session `TimeZone`.
duckdb_posixct_tz_columns <- function(value, target_types) {
  duckdb_posixct_columns_into(value, target_types, "zoned")
}

duckdb_posixct_columns_into <- function(value, target_types, kind) {
  col_names <- intersect(names(value), names(target_types))
  match <- vapply(
    col_names,
    function(col_name) {
      identical(duckdb_temporal_type_kind(target_types[[col_name]]), kind) &&
        duckdb_has_posixct(value[[col_name]])
    },
    logical(1)
  )
  col_names[match]
}

# Returns TRUE if `type`, as `DESCRIBE` or `typeof()` spell it,
# holds `TIMESTAMP`, `TIMESTAMP_S`, `TIMESTAMP_MS`, `TIMESTAMP_NS`, `DATE` or `TIME`, at the top or nested,
# and none of `TIMESTAMP WITH TIME ZONE`, `TIME WITH TIME ZONE` or `TIME_NS`,
# which only a `TIMESTAMPTZ` casts into.
duckdb_is_naive_temporal_type <- function(type) {
  identical(duckdb_temporal_type_kind(type), "naive")
}

# Classifies the temporal types that `type`, as `DESCRIBE` or `typeof()` spell it, holds at the top or nested:
# "naive" for `TIMESTAMP`, `TIMESTAMP_S`, `TIMESTAMP_MS`, `TIMESTAMP_NS`, `DATE` or `TIME` only,
# "zoned" for `TIMESTAMP WITH TIME ZONE` or `TIME WITH TIME ZONE` only
# (`TIMESTAMPTZ` and `TIMETZ` as aliases),
# and NA for none or a mix.
# A `TIME_NS` counts as neither but keeps a type from being "naive",
# since the engine casts no `TIMESTAMP` into it.
duckdb_temporal_type_kind <- function(type) {
  # A quoted field name holds no type
  bare <- gsub('"([^"]|"")*"', "", type)
  # A type ends at a comma, a parenthesis, a bracket or the end,
  # where a field name such as `date` in `STRUCT(date INTEGER)` is followed by its type
  type_pattern <- function(names) {
    paste0("(?<![A-Za-z0-9_])(", names, ")(?=$|[,)[])")
  }
  zoned <- grepl("WITH TIME ZONE", bare, fixed = TRUE) ||
    grepl(type_pattern("TIMESTAMPTZ|TIMETZ"), bare, perl = TRUE)
  # `TIMESTAMP WITH TIME ZONE` is followed by a space, so it does not count as naive
  naive <- grepl(
    type_pattern("TIMESTAMP(_S|_MS|_NS)?|DATE|TIME"),
    bare,
    perl = TRUE
  )
  time_ns <- grepl(type_pattern("TIME_NS"), bare, perl = TRUE)
  if (naive && !zoned && !time_ns) {
    "naive"
  } else if (zoned && !naive) {
    "zoned"
  } else {
    NA_character_
  }
}

# Returns TRUE if `x` is a `POSIXct` or a `POSIXlt`, or a data frame or list that holds one at any depth.
duckdb_has_posixct <- function(x) {
  if (inherits(x, c("POSIXct", "POSIXlt"))) {
    return(TRUE)
  }
  if (!is.list(x)) {
    return(FALSE)
  }
  for (elt in x) {
    if (duckdb_has_posixct(elt)) {
      return(TRUE)
    }
  }
  FALSE
}

#' @rdname duckdb_connection-class
#' @export
setMethod(
  "dbAppendTable",
  "duckdb_connection",
  dbAppendTable__duckdb_connection
)
