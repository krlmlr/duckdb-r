#' @rdname duckdb_result-class
#' @inheritParams DBI::dbBind
#' @details
#' `dbBind()` does not execute the statement:
#' execution happens at the first use of the result,
#' in `dbFetch()` or `dbGetRowsAffected()`.
#' Consequently, binding parameters and then clearing the result
#' without using it does not execute the statement.
#' The flows in the DBI specification always use the result
#' after binding.
#' @usage NULL
dbBind__duckdb_result <- function(res, params, ...) {
  check_result_open(res)
  # Reset before anything can fail, as before the deferral:
  # a refused `dbBind()` leaves an empty result, not the previous bind.
  res@env$rows_fetched <- 0
  res@env$resultset <- data.frame()
  res@env$pending_params <- NULL

  params <- as.list(params)
  if (!is.null(names(params))) {
    abort("`params` must not be named")
  }

  params <- encode_values(params)

  # The structural checks of `rapi_bind()`, which no longer runs at bind time:
  # parameter count, array parameters, and equal lengths.
  # An error here still surfaces at `dbBind()`,
  # with the class and `context` the glue gives it (`?duckdb_error`).
  rethrow_rapi_bind_check(res@stmt_lst$ref, params)

  if (!res@arrow) {
    # Defer execution to the first use of the result: dbFetch() or
    # dbGetRowsAffected(). Known limitation, per the DBI spec flows:
    # dbBind() + dbClearResult() without using the result does not execute
    # the statement. An explicit dbSendStatement() method
    # (duckdb/duckdb-r#2565) and the plan in duckdb/duckdb-r#2583 will
    # take care of that: warn on dbSendStatement() + dbBind() +
    # dbClearResult(), or eagerly start the work in background threads.
    res@env$resultset <- NULL
    res@env$pending_params <- params
  } else {
    out <- rethrow_rapi_bind(
      res@stmt_lst$ref,
      params,
      duckdb_convert_opts_impl(res@connection@convert_opts, arrow = res@arrow)
    )
    if (length(out) == 1) {
      out <- out[[1]]
    } else if (length(out) == 0) {
      out <- data.frame()
    } else {
      out <- do.call(rbind, out)
    }
    duckdb_post_execute(res, out)
  }
  invisible(res)
}

#' @rdname duckdb_result-class
#' @export
setMethod("dbBind", "duckdb_result", dbBind__duckdb_result)
