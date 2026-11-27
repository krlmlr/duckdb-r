# A Polars frame as a DuckDB table

*What it measures:* what it takes to scan a Polars frame from DuckDB without either package knowing about the other,
what the type mapping does,
and what filter pushdown into Polars is worth, in rows crossing the boundary and not only in seconds.

*When and on what:* 2026-08-08, duckdb 1.5.5.9012
(this repository, built against the prebuilt libduckdb v1.5.5 via `DUCKDB_R_USE_SYSTEM_LIB=1`),
polars 1.14.0.9000 (r-universe, built from source), nanoarrow 0.9.0, R 4.5.3, Linux.
Not repeated on the v1.5.6, v2.0 or v2.1 engines.
All three keep `arrow_scan`, `arrow_scan_dumb` and the view-type gate the record turns on
(vendored `src/duckdb/src/function/table/arrow.cpp`).
In the v2.1 engine the gate is `TableHasUnfilterableTypes()`, whose comment says one such column turns pushdown off for the table.

*What it supports:* [`plan/PLAN-polars-source.md`](/plan/PLAN-polars-source.md),
and the frame library entry in [`usage/integrations/`](/handbook/usage/integrations/README.md).
[`2026-09-28-frame-libraries/`](/experiments/2026-09-28-frame-libraries/README.md) measures the other direction,
a query result taken into Polars, and does not overlap with this record.

Run [`polars.R`](polars.R); the recorded run is [`polars.md`](polars.md), rendered with `reprex::reprex(si = TRUE)`.

No C++ was changed to measure this.
The unexported `rapi_register_arrow()` takes five R closures: an exporter, three expression factories, and a schema exporter.
Nothing in the C++ requires them to build *Arrow* expressions,
so the filter that DuckDB pushes down can be assembled as a Polars expression instead.

What the run compresses to:

* **Polars is already reachable, and duckdb needs to know nothing about it.**
  polars registers `as_nanoarrow_array_stream()` for its eager and lazy frames alike,
  so closures built on nanoarrow export a Polars frame without naming the package.
  That matters, because polars is not on CRAN, and its tests could not run there.
* **The schema needs a detour.**
  polars does *not* register `infer_nanoarrow_schema()`,
  so the schema has to be taken from a zero-row stream (`x$head(0)`) rather than asked for directly.
* **The string type decides whether filters are pushed at all.**
  Polars exports `string_view` by default, and `arrow_scan` disables filter pushdown for the whole table when any column has a view type.
  So a Polars frame with a string column silently gets the safe behavior:
  DuckDB applies the filter itself, and the plan shows a `FILTER` above the scan.
  The same frame without the string column has the filter pushed into a producer that may not be able to apply it,
  and the query fails when it cannot.
  The exporter controls this: `polars_compat_level = "oldest"` turns `string_view` into `large_utf8`, and pushdown comes back.
  A design that relies on the view type for safety is relying on an accident.
* **The filter translates.**
  Mapping the glue's expression factories onto Polars is about fifteen lines:
  comparisons, `and_kleene`/`or_kleene`, `is_null`, `invert`, `pl$col` for a column reference and `pl$lit` for a scalar.
  Measured working: `>`, a two-sided range, `IN`, and `IS NOT NULL`.
  The glue expands `IN` into a balanced tree of equalities (`TransformInExpression()` in [`src/register.cpp`](/src/register.cpp)).
* **Type fidelity is the nanoarrow mapping, plus list columns.**
  Against `r_dataframe_scan`, a Polars source agrees on logical, integer, double, character, `Date` and `difftime`.
  Unlike the plain nanoarrow route, it also takes bare list columns,
  which `as_polars_df()` converts to a Polars list dtype and DuckDB reads back as `INTEGER[]`.
  It differs on `factor` (`VARCHAR`, losing the `ENUM`)
  and `POSIXct` (`TIMESTAMP WITH TIME ZONE` rather than naive `TIMESTAMP`),
  and differed on `integer64` (`BIGINT` rather than `DOUBLE`)
  until [#2819](https://github.com/duckdb/duckdb-r/pull/2819) made `r_dataframe_scan` write `BIGINT` as well.
  The mapping through Arrow is [`usage/arrow-types/`](/handbook/usage/arrow-types/README.md)'s.
* **The export is not the bottleneck.**
  Summing a column of a five-million-row frame takes 0.014 s through `r_dataframe_scan`,
  0.015 s through an eager Polars producer, and 0.016 s through a lazy one.
* **What the pushdown changes is the volume, not the clock.**
  The source is ten numeric columns and two million rows, on disk as an 89 MB Parquet file,
  and the query needs one column and ten rows.
  With the filter pushed, the producer exports 10 rows × 1 column.
  With one string column added, which is all it takes to disable pushdown, it exports 2,000,000 rows × 1 column for the same answer.
  Elapsed time moves much less than the volume does:
  0.018 s with the filter pushed and 0.027 s without, with DuckDB's own `read_parquet` at 0.006 s.
  Polars is fast enough that 200,000 times the data is still cheap at this size.
  Correctness depends on the producer declaring only the pushdown it can apply, not on pushdown itself;
  what pushdown adds is the volume.
