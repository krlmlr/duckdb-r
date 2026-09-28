# array errors with more than one dimention

    Code
      dbGetQuery(con, "FROM tbl")
    Condition
      Error in `duckdb_result()`:
      ! Nested arrays cannot be returned to R as column data.
      i Context: duckdb_r_allocate

# array errors with convert option array = 'none'

    Code
      dbGetQuery(con, "FROM tbl")
    Condition
      Error in `duckdb_result()`:
      ! Use `dbConnect(array = "matrix")` to enable arrays to be returned to R.
      i Context: duckdb_r_allocate

# array errors with default convert option array

    Code
      dbGetQuery(con, "FROM tbl")
    Condition
      Error in `duckdb_result()`:
      ! Use `dbConnect(array = "matrix")` to enable arrays to be returned to R.
      i Context: duckdb_r_allocate

# array errors when writing matrix of complex numbers

    Code
      dbWriteTable(con, "tbl", df)
    Condition
      Error in `.local()`:
      ! {"exception_type":"Binder","exception_message":"No function matches the given name and argument types 'r_dataframe_scan(POINTER, \"map_list_of\" := INTEGER_LITERAL, \"experimental\" := INTEGER_LITERAL, \"integer64\" := INTEGER_LITERAL)'. You might need to add explicit type casts.\n\tCandidate functions:\n\tr_dataframe_scan(col0 POINTER, /, *, integer64 BOOLEAN, experimental BOOLEAN, map_list_of BOOLEAN)\n","name":"r_dataframe_scan","candidates":"r_dataframe_scan(col0 POINTER, /, *, integer64 BOOLEAN, experimental BOOLEAN, map_list_of BOOLEAN)","call":"r_dataframe_scan(POINTER, \"map_list_of\" := INTEGER_LITERAL, \"experimental\" := INTEGER_LITERAL, \"integer64\" := INTEGER_LITERAL)","schema":"main","catalog":"system","error_subtype":"NO_MATCHING_FUNCTION"}
      i Context: rapi_register_df

