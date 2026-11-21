# Memory of a spatial LATERAL top-N query on 1.5.6, 2.0.0 and 2.0.1

*What it measures:* peak RSS, wall time and outcome of the query reported in [#3050](https://github.com/duckdb/duckdb-r/issues/3050),
a per-year `LEFT JOIN LATERAL` whose subquery keeps the 5,000 nearest reference points within 2,500 m
(`ST_DWithin()`, `ORDER BY`, `LIMIT`),
on duckdb 1.5.6, 2.0.0 and 2.0.1.
Each version runs it from R with the data registered by `duckdb_register()`, from R reading Parquet,
and in the DuckDB CLI of the same engine.
Then, for one year, the engine's own peak buffer memory and peak temporary directory size
under varying `memory_limit`, `threads`, `LIMIT` k, data size and query shape,
and three reformulations in the CLI that leave out the `LATERAL`, the spatial join, or both.

*When and on what:* 2026-11-21, Linux x86_64 in a container with 15 GB RAM, no swap and 4 cores (Intel Xeon at 2.10 GHz), R 4.5.3.

* duckdb 1.5.6 (engine v1.5.6, `069cc9f9b5`), the Posit Package Manager binary of the 2026-10-02 snapshot.
* duckdb 2.0.0 (engine v2.0.0, `d54cbbe3df`), the Posit Package Manager binary of CRAN's current release.
* duckdb 2.0.1 (engine v2.0.1, `8d78114e90`), built from source at tag `v2.0.1` of duckdb/duckdb-r, which CRAN does not carry yet.
* The DuckDB CLI v1.5.6 from the GitHub release, and v2.0.0 and v2.0.1 from the `duckdb-cli` wheels on PyPI,
  since GitHub has no CLI assets for 2.0; each reports the same engine and source id as the R package.
* spatial `04270fe` on 1.5.6, `a3dbcd1781` on 2.0.0 and `37bff11aea` on 2.0.1, installed from DuckDB's extension repository.

The data are synthetic and fixed by a seed: 70,000 reference points and 26,000 query points (years 2015 to 2024, about 2,600 each)
in a 300 km square in projected metres, clustered in 40 towns, 5% and 15% of them rural.
A query point's 2,500 m neighbourhood holds 830 reference points at the median, about 3,000 at the 90th percentile and up to 6,300;
each year has 150 to 200 query points with more than 4,000.
Unless a run says otherwise, `memory_limit` is 4 GB, `threads` is the default 4, and k is 5,000.
Every run had an outer cap of an 8 GiB cgroup v1 memory limit and a 15-minute timeout.
The cgroup peak counts the page cache, so a run that spills to the temporary directory reaches the cap without its RSS doing so.

* [`repro.R`](repro.R) is the reprex: it builds the data (WKB points packed by hand, no sf), registers or reads them,
  and runs the issue's query per year; `write=<dir>` writes the Parquet files instead,
  and `explain=analyze` profiles one year and prints the operator tree with the engine's peak buffer memory and temporary directory size.
  Its header lists the options.
* [`query.sql`](query.sql) is the same query for every year in the CLI, on the Parquet files.
* [`rewrite.sql`](rewrite.sql) is the query for 2024 without `LATERAL`:
  the spatial join, `ROW_NUMBER()` per query point, `rn <= 5000`, then the aggregates.
  [`pairs.sql`](pairs.sql) materializes the spatial join's pairs into a table and runs the same top-N over it, at k = 5,000 and 4,096.
  [`minimal.sql`](minimal.sql) does that on 3 million synthetic rows with BLOB group keys, without spatial.
* [`capped.sh`](capped.sh) runs one command under the cgroup cap and the timeout and prints a `RESULT` line
  with GNU time's peak RSS, the cgroup's peak, the wall time and the outcome.
  [`measure.sh`](measure.sh) runs one R or CLI configuration through it into `out/<name>.txt`,
  summarizing CLI profiles with [`profile-summary.py`](profile-summary.py);
  [`narrow.sh`](narrow.sh) runs the one-year profiles per section into `out/narrow-<section>.txt`.
* [`out/`](out/) holds every run's output:
  `r-<version>-register.txt`, `r-<version>-parquet.txt` and `cli-<version>.txt` for the main runs,
  `r-<version>-default-limit.txt` and `r-<version>-threads8-default-limit.txt` without a `memory_limit` set,
  `profile-<version>.txt` with the operator tree of 2024,
  `cli-<version>-{rewrite,pairs,minimal}.txt` for the reformulations,
  and `narrow-{limit,threads,default-limit,k,variants,size}.txt` for the one-year profiles.

The Parquet data are not kept; `Rscript repro.R write=<dir>` regenerates them in about two seconds.

*What it supports:* the analysis on [#3050](https://github.com/duckdb/duckdb-r/issues/3050); no handbook leaf.

## Results

All years, 4 threads, `memory_limit` 4 GB; every run returned the same 26,000 rows with `sum(n)` 30,354,639:

* 1.5.6
  * R registered: 1,173 MiB peak RSS, 25 s, ok
  * R Parquet: 1,176 MiB, 25 s, ok
  * CLI: 1,448 MiB, 18 s, ok
* 2.0.0
  * R registered: 1,260 MiB, 78 s, ok, but the cgroup reached 7.6 GiB through spilling; 2024 alone spilled 888 MiB that stayed in temp files
  * R Parquet: 1,264 MiB, 78 s, ok, cgroup at 7.8 GiB
  * CLI: 1,401 MiB, 69 s, ok, cgroup at 7.9 GiB
* 2.0.1
  * R registered: 779 MiB, 27 s, ok
  * R Parquet: 783 MiB, 24 s, ok
  * CLI: 620 MiB, 18 s, ok

No `memory_limit` set, which here the engine sets to 6.3 GiB, 80% of the cgroup cap it detects:
all three versions ran all years in 21 to 24 s at 4 and at 8 threads, 1.5.6 at about 1,160 MiB peak RSS and 2.0.x at 710 to 820 MiB.

One year (2024), the engine's peak buffer memory and peak temporary directory size, and the wall time:

* `memory_limit` at 4 threads (`narrow-limit.txt`)
  * 1.5.6: 2,077 MiB buffer at every limit from 2 GB to 6 GB, no spilling, 4 to 6 s; at 2 GB it uses more than the limit and still succeeds.
  * 2.0.0: at 2 GB `Out of Memory Error: could not allocate block of size 256.0 KiB (1.8 GiB/1.8 GiB used)` after 104 s;
    at 3, 4 and 5 GB the buffer fills the limit and 6.3 to 10.6 GiB spill, 26 to 38 s; at 6 GB 531 MiB and no spilling.
  * 2.0.1: at 2 and 3 GB the buffer fills the limit and 26 to 27 GiB spill, 91 to 149 s; from 4 GB 531 MiB and no spilling.
* `threads` at 4 GB (`narrow-threads.txt`)
  * 1.5.6: 1,075 MiB at 1 thread, about 2,100 MiB at 2 to 8.
  * 2.0.0: 530 MiB at 1 and 2 threads; spills 6.6 GiB at 4 and 43.6 GiB at 8 (219 s).
  * 2.0.1: 530 MiB at 1 to 4 threads; spills 25.4 GiB at 8 (115 s).
* `threads` with no `memory_limit` set, 6.3 GiB (`narrow-default-limit.txt`)
  * 1.5.6: 2,080 to 2,238 MiB at 4, 8 and 16 threads.
  * 2.0.0 and 2.0.1: about 535 MiB at 4 and 8 threads; at 16 threads the buffer fills the 6.4 GiB and 27.8 and 24.3 GiB spill, 101 and 79 s.
* `LIMIT` k at 4 GB and 4 threads (`narrow-k.txt`)
  * 1.5.6 grows smoothly: 195 MiB at k = 100, 1,008 at 1,000, 1,498 at 2,048, 1,886 at 4,096, 2,046 at 4,097, 2,080 at 5,000.
  * 2.0.0 uses a quarter of that up to k = 4,096 (63, 252, 389, 483 MiB),
    then jumps at k = 4,097 to a full buffer and 3.8 GiB spilled, and 6.6 GiB at 5,000.
  * 2.0.1 stays at 532 MiB at 4,097 and 5,000 here, but the jump is the one 8 threads or a 3 GB limit bring back above.
* Query shape at 4 GB and 4 threads (`narrow-variants.txt`)
  * Without `LIMIT`, without `ORDER BY`, or without both, there is no top-N, and no version spills (31 to 562 MiB).
  * `arg_min()` replaced by `NULL` keeps the top-N but no version spills (339 MiB on 2.0.x, 1,020 MiB on 1.5.6).
  * `preserve_insertion_order = false` and reading Parquet instead of registered data change nothing.
* Data size at 4 GB and 4 threads (`narrow-size.txt`): at a half, a quarter and a tenth of the points no version spills,
  since fewer than 4,097 reference points then fall in any neighbourhood.
* All years against one year: each year's query is independent and the peak RSS of all years is that of the worst year;
  at 4 GB and 4 threads on 2.0.0 the years 2015 to 2017 ran in 2 s without spilling and the others in 2 to 27 s with,
  so near the threshold whether a year spills varies between years and runs.

The plans (`profile-<version>.txt`) are the same in shape on all three versions.
The `LATERAL` is decorrelated into a join on the deduplicated query geometries (a `RIGHT_DELIM_JOIN` on 1.5.6,
a materialized CTE `__duckdb_delim_dedup` on 2.0.x), the spatial extension's `SPATIAL_JOIN` produces 3.3 million pairs for 2024,
and the `ORDER BY dist LIMIT 5000` becomes the top-N window elimination's
`HASH_GROUP_BY` with `arg_min_nulls_last(#1, #2, #3)` per query geometry, unnested afterwards.
That aggregate is where the time goes: 4.6 s summed over threads on 1.5.6, 29 to 52 s on 2.0.0 when it spills.

Without the `LATERAL` the problem goes away on every version (`cli-<version>-rewrite.txt`):
the same top-N through `ROW_NUMBER()` over the spatial join, partitioned by the geometry or by `obsid`,
peaks at 233 to 327 MiB on 2.0.x and 728 to 982 MiB on 1.5.6 at 4 GB and 4 threads, with the same results.
The same top-N over the materialized pairs (`pairs.sql`) or over synthetic BLOB-keyed groups (`minimal.sql`)
does not spill either, at k = 5,000 or 4,096.

## Conclusions

* **Reproduced, and an engine regression, not the R glue.**
  The CLI of each engine behaves as the R package does, and Parquet input as registered data does.
* **The trigger is the hash aggregate behind a `LATERAL ... ORDER BY ... LIMIT k` once its per-group top-N heaps exceed 4,096 entries
  and the aggregate runs short of memory.**
  Up to k = 4,096, 2.0 needs a quarter of 1.5.6's memory for this query; beyond, under memory pressure,
  it spills many times the size of its input (4 to 44 GiB for 3.3 million pairs) and runs 10 to 100 times slower,
  or fails with an out-of-memory error at a 2 GB limit.
  1.5.6 needs about 2 GB regardless and never spills, even beyond a 2 GB limit.
  The pressure grows with the thread count, so a machine with more cores than this one reaches it at its default limit,
  as 16 threads did here.
* **2.0.1 moves the threshold but does not remove it.**
  It runs the issue's setting here at 4 threads and 4 GB,
  but spills 24 to 27 GiB at 8 threads and 4 GB, at 3 GB, and at 16 threads with the default limit.
  Its engine changes between 2.0.0 and 2.0.1 include the hash aggregate's sink reservation
  (`UpdateSinkReservation()` in `radix_partitioned_hashtable.cpp`) and the temporary memory manager.
  The aggregate state spilling these feed (`AggregateStateSpilling`, `ShouldExportStates()`) is new in 2.0 and absent from 1.5.6,
  which is the likely place to look; the exact mechanism behind the 4,096 threshold was not traced.
* **The reporter's 20 GB and OOM are not reproduced as RSS here.**
  The process stays at 1.2 to 2.5 GiB, and the excess goes to the temporary directory.
  Which of the two a system shows depends on where that directory lives:
  R's default puts it under `tempdir()`, so a `/tmp` on tmpfs would hold the spill in RAM.
  That is an unverified explanation.
* **Workarounds on 2.0.x:** keep k at 4,096 or below, give the query a higher `memory_limit` or fewer threads,
  or write the query without `LATERAL`, as in [`rewrite.sql`](rewrite.sql).
