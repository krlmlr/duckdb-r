# Timestamps and time zones

How a timestamp crosses between R and the engine:
which zone labels it on the way out, which DuckDB type carries it on the
way in, when an instant can change,
and what the session `TimeZone` setting is.
The behaviour is pinned by
[`tests/testthat/test-timezone.R`](/tests/testthat/test-timezone.R)
and measured across all setting combinations in
[`experiments/2026-08-08-timezone-grid/`](/experiments/2026-08-08-timezone-grid/README.md);
the wider type mapping is
[`types/`](/handbook/usage/types/README.md).

* **Every timestamp crosses as an instant plus a label.**
  Values arrive as epoch seconds in a `POSIXct`,
  and on the default `tz_out_convert = "with"` path
  no setting changes an instant — only the `tzone` label varies.
* **Plain `TIMESTAMP` is labeled with `timezone_out`.**
  The naive wall clock is read as UTC;
  the default label is `"UTC"`, set in
  [`R/dbConnect__duckdb_driver.R`](/R/dbConnect__duckdb_driver.R),
  and `""` leaves the label empty, so R renders the local zone.
* **`TIMESTAMPTZ` is labeled with the session `TimeZone`,
  and `timezone_out` is ignored.**
  DuckDB stores microseconds since the UTC epoch
  and renders them per session, not per column or per row,
  so every `TIMESTAMPTZ` column of a result shares one label
  ([#184](https://github.com/duckdb/duckdb-r/issues/184)).
  A DBI result captures the zone at execute time;
  an ALTREP result captures it earlier, when the data frame is built —
  that corner is [`relational/`](/handbook/usage/relational/README.md)'s.
* **`dbConnect()` sets the session `TimeZone` to `UTC`.**
  Both timestamp types then read a naive wall clock the same way,
  R as UTC and the engine as UTC,
  so a bound or quoted `POSIXct` compared with a `TIMESTAMP` column
  matches the instant that went in ([`R/session-timezone.R`](/R/session-timezone.R)).
  It is a starting point, not a lock: `SET TimeZone` on the connection
  wins, and such a comparison stops matching once it does,
  because only one side of the pair moved.
  A `TimeZone` named in `duckdb(config = )` wins too, and the alignment leaves it alone,
  as it does one set with `SET GLOBAL` on another connection to the same instance:
  a session setting would mask it, so the alignment asks the engine whether the global setting
  holds a chosen value or its default, which SQL cannot tell apart
  (`duckdb_settings()` reports both as `GLOBAL`).
  A `TimeZone` named in the `config` of `dbConnect()` on an instance that exists already,
  which can no longer take it, becomes the new session's.
* **The session `TimeZone` is the icu extension's setting,
  so the alignment reaches exactly as far as icu does.**
  `SET TimeZone` needs icu for any value, `'UTC'` included.
  `dbConnect()` loads an *installed* icu to set it, and installs
  nothing ([`extensions/`](/handbook/usage/extensions/README.md));
  where icu cannot be had, the engine reports `UTC` for want of the
  setting, which is the zone the alignment would have set, so the two
  cases agree on the answer and differ only in how they reach it.
  What the alignment narrows is the state in between, where icu is
  installed but unloaded and the zone changes under a session:
  `SET TimeZone` and `current_setting('TimeZone')` both autoload icu,
  and before the alignment the label went from `UTC` to the machine's
  zone the moment anything touched the setting.
  A session that finds icu installed at connect never sees that switch;
  one that installs icu only after it connected still can
  ([`experiments/2026-08-09-rel-from-df-posixct/`](/experiments/2026-08-09-rel-from-df-posixct/README.md)).
  `duckdb_extensions()` loads nothing, and is how to tell which state
  a session is in.
* **`tz_out_convert = "force"` is the one instant-changing path.**
  It relabels every datetime column in `timezone_out`,
  preserving the UTC-rendered wall clock;
  the session zone plays no role under it,
  and `""` forces into R's local zone.
* **R's local zone enters only where a label is empty** —
  as the display zone for `"with"`,
  as the target zone for `"force"` —
  both spelled `timezone_out = ""`.
* **A `POSIXct` crosses as `TIMESTAMPTZ`, the instant it names.**
  That is what the R value means, and
  `dbConnect(posixct = "timestamp")` is the way back to the older
  mapping, which sent the UTC rendering into a naive `TIMESTAMP`
  column and dropped the R-side zone
  ([#184](https://github.com/duckdb/duckdb-r/issues/184)).
  The setting reaches `dbWriteTable()`, `dbAppendTable()`,
  `duckdb_register()`, bound parameters, `dbDataType()` and
  `dbQuoteLiteral()`, nested columns included.
* **Written into a naive column, a `POSIXct` keeps the UTC wall clock.**
  `dbAppendTable()`, `dbWriteTable(append = TRUE)`, and `dbWriteTable()`
  with `field.types` register a column as `TIMESTAMP`, as
  `posixct = "timestamp"` does, when its target holds
  `TIMESTAMP`, `TIMESTAMP_S`, `TIMESTAMP_MS`, `TIMESTAMP_NS`, `DATE`
  or `TIME` and no zoned type,
  at the top or nested in a `STRUCT`, a `LIST` or a `MAP`.
  They store the UTC wall clock, date or time of day
  whatever the session zone and whether icu is loaded,
  where the engine's cast from `TIMESTAMPTZ` would take them
  in the session `TimeZone` once icu is loaded.
  Two targets take the session zone, and a third takes no `POSIXct` at all.
  A `TIME_NS` fails under either setting:
  the engine casts neither a `TIMESTAMP` nor a `TIMESTAMPTZ` into it.
  A nested target that mixes a naive field with a zoned one
  scans as `dbConnect(posixct = )` says,
  so under the default its naive field gets the session's wall clock,
  and under `posixct = "timestamp"` its zoned field reads the UTC wall clock in the session zone.
  A `VARCHAR` gets the text of a `TIMESTAMPTZ`,
  which carries the session offset, `2024-01-11 03:03:12+14`
  where the older mapping wrote `2024-01-10 13:03:12`.
* **Written into a zoned column, a `POSIXct` keeps the instant under either setting.**
  The same three paths register a column as `TIMESTAMPTZ`
  when its target holds `TIMESTAMP WITH TIME ZONE` or `TIME WITH TIME ZONE`
  and no naive type, at the top or nested,
  also under `posixct = "timestamp"`,
  where the cast from `TIMESTAMP` would read the UTC wall clock in the session `TimeZone`.
  The target type decides only where it is known:
  `duckdb_register()` scans as the setting says;
  a data frame picked up by name stays on `TIMESTAMP` (see below).
* **A bound or quoted `POSIXct` meets a naive column in the session zone.**
  A parameter or a `dbQuoteLiteral()` value is a `TIMESTAMPTZ`,
  so comparing it with a `TIMESTAMP` column casts in the session `TimeZone`,
  and `?::date` gives the date in that zone rather than in UTC;
  both match the older mapping only while the session zone is UTC,
  which is where `dbConnect()` starts it.
  `dbConnect(posixct = "timestamp")` keeps the older behavior,
  or cast the column with `timezone('UTC', …)` in the query.
  The reverse holds for a constant of the relational API:
  `expr_constant()` of a `POSIXct` stays a `TIMESTAMP`
  ([`relational/`](/handbook/usage/relational/README.md)),
  so against a `TIMESTAMPTZ` column, which `dbWriteTable()` now creates by default,
  it compares in the session zone once a user sets `TimeZone`.
* **Two paths stay on `TIMESTAMP` whatever the setting says.**
  A data frame picked up by name under
  `duckdb(environment_scan = TRUE)` follows the connection's `map` and `experimental`
  ([`relational/`](/handbook/usage/relational/README.md)) but not yet its `posixct`,
  which the replacement scan in [`src/register.cpp`](/src/register.cpp) does not pass on.
  `rel_from_df()` declines the setting rather than misses it:
  a relation promises the data frame back unchanged, which a
  `TIMESTAMPTZ` column cannot keep, and what each candidate policy
  costs is measured in
  [`experiments/2026-08-09-rel-from-df-posixct/`](/experiments/2026-08-09-rel-from-df-posixct/README.md).
  A caller who wants the setting there passes `convert_opts`;
  the rest is [`relational/`](/handbook/usage/relational/README.md)'s.
* **A zone survives the round trip only through `TIMESTAMPTZ`,
  and only the session's.**
  Set the session `TimeZone` to the column's zone and the data frame
  comes back identical;
  set it to any other zone and the instant still comes back exact,
  labeled with the session's.
  `posixct = "timestamp"` has no zone to read back at all,
  because the column it writes carries none.
* **In a dbplyr pipeline, `posixct` reaches only the escaped value.**
  `!!` escapes R-side through `dbQuoteLiteral()`, so the literal is
  typed the way the setting says;
  an inline `as.POSIXct("…")` is translated instead
  and casts the string as written, out of the setting's reach.
  The mechanics and the workaround are
  [`integrations/`](/handbook/usage/integrations/README.md)'s
  ([#1064](https://github.com/duckdb/duckdb-r/issues/1064)).
* **`TIMETZ` flattens.**
  Its per-row offsets have no `POSIXct` home
  and drop to `difftime` seconds;
  the verification record behind this leaf,
  [`plan/history/2026-05-timestamptz-icu.md`](/plan/history/2026-05-timestamptz-icu.md),
  carries that scenario and the rest of the history.

*To deepen: extend
[`experiments/2026-08-08-timezone-grid/`](/experiments/2026-08-08-timezone-grid/README.md)
over the writing direction, so the paths `posixct` does reach
are measured across their settings too.*
