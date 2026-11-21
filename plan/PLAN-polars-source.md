# Plan: a Polars frame as a SQL table or a relation

**Open.** The frame-library situation as it stands today is [`usage/integrations/`](/handbook/usage/integrations/README.md)'s.
This file is a proposal, and where the two disagree the leaf is right.

The third step toward [#98](https://github.com/duckdb/duckdb-r/issues/98), and the one the issue actually names.
Its author asked for one registration function because they wanted to register "a nanoarrow array or polars DataFrame".
[#642](https://github.com/duckdb/duckdb-r/issues/642) asks the same from the other side.

Measured evidence: [`experiments/2026-08-08-polars-source/`](/experiments/2026-08-08-polars-source/README.md).

## The constraint that shapes everything

polars is not on CRAN.
CRAN would accept it in `Suggests` with an `Additional_repositories` field,
but the check farm would not install it, so its tests would never run there.
Installing it from r-universe means a source build, so CI here does not install it either.
Code that names polars would therefore ship untested.
So the design cannot be "add a Polars method".
It has to be "make registration extensible enough that Polars needs no method here".

That is a stronger requirement than #98 asks for, and it is also the one that makes #98 worth doing.
A generic with one method is a rename.
A generic that a package outside CRAN can implement is an interface.

## What the measurement settled

* Polars is already reachable through nanoarrow.
  polars registers `as_nanoarrow_array_stream()` for eager and lazy frames, so the stream needs no Polars-specific code.
  Scans, projections and `count(*)` measured working through closures built on it.
* It does not register `infer_nanoarrow_schema()`, so the schema has to come from a zero-row stream rather than from the object.
  A generic registration must not assume the schema is askable.
* The filter DuckDB pushes down translates to Polars in about fifteen lines.
  The three expression factories the C++ calls are ordinary R closures that need not build Arrow expressions.
  Comparisons, conjunctions, `IN` and null tests all measured working against a `LazyFrame`.
* Whether DuckDB pushes a filter at all depends on the Arrow *layout* the source exports.
  Polars exports `string_view` by default, and `arrow_scan` disables filter pushdown for the whole table when any column has a view type.
  A Polars frame with a string column is therefore safe by accident, and the same frame without one is not:
  the filter is pushed, the producer that cannot take it fails, and so does the query.
* Pushing the filter changed the volume by five orders of magnitude, 10 rows exported against 2,000,000 for the same answer.
  The elapsed time moved from 0.018 s with the filter pushed to 0.027 s without.
  What keeps a query correct is that the producer's declared capability matches what it can apply, not the pushdown itself.
  The pushdown earns its place by volume, not as a speed-up.

## Decisions

* **No Polars-specific code in this package.**
  Not a method, not a class name, not a `requireNamespace("polars")`.
  Everything Polars needs is the generic interface below.
  What stays here is a test that exercises it with a stub rather than with polars.
* **`duckdb_register()` becomes an S3 generic**, as #98 asks.
  `duckdb_register.data.frame()` keeps today's `r_dataframe_scan` behavior byte for byte.
  `duckdb_register.default()` keeps today's fallback for every other class:
  it runs `as.data.frame()` on the source and registers the result as a data frame,
  which is what `dbWriteTable()` and `dbAppendTable()` rely on when they pass `value` through.
  It takes the Arrow-stream route, below, only for a `nanoarrow_array` and for a class with its own `duckdb_arrow_producer()` method.
  A `nanoarrow_array` therefore moves from `as.data.frame()` to the stream route, and its columns map through Arrow rather than through R.
* **On the Arrow-stream route, only an allowlist, refused by class.**
  That refusal by class is what matches `rel_from_arrow()` ([krlmlr/duckdb-r#226](https://github.com/krlmlr/duckdb-r/pull/226)).
  `duckdb_arrow_producer.default()` builds a stream for a `nanoarrow_array`, over memory, so that the stream never calls R.
  It refuses any other class on R's thread, with an error that names `duckdb_arrow_producer()` as the way in.
  `as_nanoarrow_array_stream()` accepting a class is not enough:
  nanoarrow's reader over an R connection calls R for every batch, and the engine pulls batches on its own threads
  ([`architecture/glue/threading/`](/handbook/architecture/glue/threading/README.md),
  [`usage/memory/writing/`](/handbook/usage/memory/writing/README.md)).
  Only the class's own producer method can promise that its stream does not call R.
  So a Polars frame takes the stream route through the method polars supplies.
  Without that method it keeps the `as.data.frame()` path it takes today.
* **A source opts in by supplying a producer.**
  A second generic, `duckdb_arrow_producer(x)`, returns the closure list plus a capability flag.
  A package that has a query engine, such as polars and in principle arrow, implements it to get the filter.
  The implementing package registers the method from its own `.onLoad()`.
  That is the delayed-registration trick this package uses in the other direction for dbplyr and adbcdrivermanager
  ([`R/s3_register.R`](/R/s3_register.R), [`R/zzz.R`](/R/zzz.R)),
  so no dependency is created either way.
* **The schema comes from a zero-row stream by default.**
  `infer_nanoarrow_schema()` is tried first and the empty-slice route is the fallback,
  because the measurement says a real source does not necessarily have a method.
* **Pushdown capability is declared, never inferred.**
  Not from the Arrow layout, since the `string_view` accident is exactly what a design must not depend on, and not from the class.
  The producer says so, and the C++ binds `arrow_scan` or `arrow_scan_dumb` accordingly.
  Today the glue names `"arrow_scan"` for every registered Arrow source
  (`ArrowScanReplacement()` in [`src/register.cpp`](/src/register.cpp)),
  so binding `arrow_scan_dumb` depends on the nanoarrow scan ([krlmlr/duckdb-r#229](https://github.com/krlmlr/duckdb-r/pull/229)).
* **A producer that declares pushdown must take every filter it is given.**
  The glue degrades only one case on its own:
  an optional filter whose translation throws a C++ `NotImplementedException` becomes a `TRUE` literal
  (`TransformExpression()` and `TransformFilterExpression()` in [`src/register.cpp`](/src/register.cpp)).
  An error raised by an R expression factory, or by the producer applying the filter, fails the query,
  as the recorded run shows for a producer that cannot apply it.
  So a producer that cannot translate some filters declares no pushdown, and DuckDB applies every filter above the scan.
  That costs projection pushdown too, since `arrow_scan_dumb` takes neither, and the producer exports every column.
  Declaring pushdown per filter kind is left open below.
* **The export runs on R's thread; the stream it returns does not.**
  The export call is moved onto the scheduling thread,
  and the batches are pulled by whichever engine thread scans them
  ([`architecture/glue/threading/`](/handbook/architecture/glue/threading/README.md)),
  so the contract requires a stream that does not call R.
  The experiment's producer collects the `LazyFrame` inside the export and hands over the collected frame's stream for that reason:
  a reader that still had R work to do would be asked for it from the wrong thread.
* **The relational side needs one more step.**
  `rel_from_arrow()` ([krlmlr/duckdb-r#226](https://github.com/krlmlr/duckdb-r/pull/226)) picks its closures by class
  and refuses a class outside its arrow-package and nanoarrow routes, so it never calls `duckdb_arrow_producer()`.
  For a Polars frame to be a relation as well as a view, `rel_from_arrow()` has to dispatch to `duckdb_arrow_producer()`
  for a class outside its routes that has a method of its own.
  That is commit 3 below, which depends on krlmlr/duckdb-r#226.

## Commits

Each commit is self-contained and keeps the suite green.
The nanoarrow scan ([krlmlr/duckdb-r#229](https://github.com/krlmlr/duckdb-r/pull/229))
and `rel_from_arrow()` ([krlmlr/duckdb-r#226](https://github.com/krlmlr/duckdb-r/pull/226)) are prerequisites, planned separately under #98.
This plan assumes them rather than restating them, and its own commits start after them.

### 1. feat(register): `duckdb_arrow_producer()`, the extension point

* `R/register.R`: an S3 generic `duckdb_arrow_producer(x, ...)`,
  returning `list(export = , schema = , expr = , col = , lit = , pushdown = )`.
  The default method builds the nanoarrow producer with `pushdown = FALSE` for a `nanoarrow_array`, and refuses any other class.
  It binds `arrow_scan_dumb` for `pushdown = FALSE` through the binding krlmlr/duckdb-r#229 adds.
  A `data.frame` method is *not* added, so the data frame path stays on `r_dataframe_scan`.
* Exported and documented, because a package outside CRAN has to be able to implement it.
  The documentation states the contract: a stream that does not call R, and every filter taken when `pushdown = TRUE`.
* Tests: a stub producer in `tests/testthat/helper-producer.R` that records what it is asked for.
  They assert that the filter and projection arrive as expected,
  that `pushdown = TRUE` reaches `arrow_scan` while `FALSE` reaches `arrow_scan_dumb`,
  and that the default refuses a class outside its allowlist.

### 2. feat(register): make `duckdb_register()` an S3 generic

* `duckdb_register()` becomes `UseMethod("duckdb_register", df)`.
  `duckdb_register.data.frame()` is today's body, unchanged.
  `duckdb_register.default()` resolves a producer through `duckdb_arrow_producer()` and registers it,
  for a `nanoarrow_array` or a class with its own method;
  for any other class it runs today's `as.data.frame()` and registers the result as a data frame.
  `duckdb_unregister()` drops either kind.
* The argument is still named `df`, since renaming it would break callers who name it.
  The documentation says what it now accepts.
* Tests: `duckdb_register()` on a nanoarrow array and on the stub producer,
  on a class that `as.data.frame()` converts as today, the data frame path unchanged, and `duckdb_unregister()` for both.

### 3. feat(relational): let `rel_from_arrow()` take a producer

Depends on krlmlr/duckdb-r#226.
`rel_from_arrow()` keeps its arrow-package and nanoarrow routes.
For a class outside both, it calls `duckdb_arrow_producer()` when the class has a method of its own.
It refuses any other class, as before.
The producer's `pushdown` flag picks the scan, as it does for `duckdb_register()`.
Tests: `rel_from_arrow()` on the stub producer, and the refusal of a class without a method.

### 4. docs: state the extension point and what implements it

`handbook/usage/integrations/README.md` gains the inbound direction for frame libraries.
A package that implements `duckdb_arrow_producer()` is a source, with pushdown if it declares it.
The frame library entry, which takes a result into Polars, data.table and collapse, gets its counterpart.
data.table and collapse operate on data frames and need nothing; Polars is the case that needed an interface.

### 5. A worked producer, outside this repository

The Polars-side method belongs in polars, or in a small bridge package.
This plan's obligation is to make it writable in about forty lines; the experiment's `register_polars_lazy()` is what it looks like.
Filing it as an issue on the polars side, with a link to the experiment, is the last step here.

## Out of scope

* **Adding polars to `Suggests` or to CI.**
  CRAN would not install it, and CI would need a source build.
  The stub producer is what the suite tests.
* **A Polars *writer*.**
  Results already leave as a nanoarrow stream that `polars::as_polars_df()` consumes
  ([`usage/integrations/`](/handbook/usage/integrations/README.md),
  [`experiments/2026-09-28-frame-libraries/`](/experiments/2026-09-28-frame-libraries/README.md)),
  and [#642](https://github.com/duckdb/duckdb-r/issues/642) is answered on that side already.
* **Translating everything DuckDB can push.**
  The measured translation covers comparisons, conjunctions, `IN` and null tests.
  A producer that cannot translate the rest declares no pushdown, as the decision above says.
* **The two prerequisite plans.**
  The nanoarrow scan and `rel_from_arrow()`, both proposed alongside this one under [#98](https://github.com/duckdb/duckdb-r/issues/98).

## Open questions

* Whether `duckdb_arrow_producer()` should be one generic returning a list,
  or several small generics (`duckdb_arrow_export()`, `duckdb_arrow_schema()`, …).
  The list is one dispatch and one thing to document; separate generics are easier to implement partially.
* Whether the capability should be finer than one flag, such as a list of filter kinds the producer takes.
  That would let a producer that translates comparisons but not functions keep the pushdown it can apply.
  It needs the glue to choose per filter, which it does not do today.
* Whether the `string_view` interaction deserves a report upstream.
  A source whose only string column is a view silently loses filter pushdown for every other column too,
  which is a performance cliff nothing announces.
* Whether `duckdb_register()` should refuse a source it cannot replay, or accept it and fail on the second scan with an explanation.
  Same question as the nanoarrow plan's, and it should be answered the same way in both.
