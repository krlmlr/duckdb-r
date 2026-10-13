# duckplyr (1.2.1)

* GitHub: <https://github.com/tidyverse/duckplyr>
* Email: <mailto:kirill@cynkra.com>
* GitHub mirror: <https://github.com/cran/duckplyr>

Run `revdepcheck::revdep_details(, "duckplyr")` for more info

## Newly broken

*   checking tests ... ERROR
     ```
     ...
        30. │ └─handlers[[1L]](cnd)
        31. │   └─duckdb:::rethrow_error_from_rapi(e, call)
        32. │     └─rlang::abort(msg, class = "duckdb_error", call = call, !!!fields)
        33. │       └─rlang:::signal_abort(cnd, .file)
        34. │         └─base::signalCondition(cnd)
        35. ├─dbplyr (local) `<fn>`(`<dckdb_rr>`)
        36. │ └─cli::cli_abort(msg, parent = cnd)
        37. │   └─rlang::abort(...)
        38. │     └─rlang:::signal_abort(cnd, .file)
        39. │       └─base::signalCondition(cnd)
        40. └─dbplyr (local) `<fn>`(`<rlng_rrr>`)
        41.   └─cli::cli_abort(msg, parent = cnd, call = call, .envir = env)
        42.     └─rlang::abort(...)
       
       [ FAIL 2 | WARN 0 | SKIP 654 | PASS 2582 ]
       Error:
       ! Test failures.
       
       🛠: 2565
       🔨: 1348
       🦆: 1217
       add_count, anti_join, anti_join.data.frame, arrange, arrange.data.frame, compute, count, count.data.frame, cross_join, distinct, distinct.data.frame, do, eval, filter, filter.data.frame, filter_out, full_join, group_by, group_indices, group_keys, group_map, group_modify, group_nest, group_size, group_split, group_trim, head, inner_join, inner_join.data.frame, intersect, left_join, left_join.data.frame, mutate, mutate.data.frame, n_groups, nest_by, nest_join, pull, reframe, relocate, rename, rename_with, right_join, rows_append, rows_delete, rows_insert, rows_patch, rows_update, rows_upsert, rowwise, select, select.data.frame, semi_join, semi_join.data.frame, setdiff, setequal, slice, slice_head, slice_head.data.frame, slice_sample, slice_tail, summarise, summarise.data.frame, symdiff, transmute, ungroup, union_all
       
       00:01:47.625288
       Execution halted
     ```

