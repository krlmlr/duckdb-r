# freestiler (0.3.0)

* GitHub mirror: <https://github.com/cran/freestiler>

Run `revdepcheck::revdep_details(, "freestiler")` for more info

## In both

*   checking whether package ‘freestiler’ can be installed ... ERROR
     ```
     Installation failed.
     See ‘<lib>/freestiler.Rcheck/00install.out’ for details.
     ```

## Installation

### Devel

```
[... 141 earlier lines omitted; the full 00install.out is in the check artifact ...]
    |
677 |         let layers = match freestiler_core::file_input::parquet_to_layers(
    |                                             ^^^^^^^^^^ could not find `file_input` in `freestiler_core`
    |
note: found an item that was configured out
   --> freestiler-core/src/lib.rs:9:9
    |
  8 | #[cfg(any(feature = "geoparquet", feature = "duckdb"))]
    |          -------------------------------------------- the item is gated here
...
398 | pub fn generate_pmtiles(
    |        ^^^^^^^^^^^^^^^^

Some errors have detailed explanations: E0308, E0433, E0599.
For more information about an error, try `rustc --explain E0308`.
warning: `freestiler` (lib) generated 3 warnings
error: could not compile `freestiler` (lib) due to 13 previous errors; 6 warnings emitted
make: *** [Makevars:28: rust/target/release/libfreestiler.a] Error 101
ERROR: compilation failed for package ‘freestiler’
* removing ‘/revdepx/out/freestiler.Rcheck/freestiler’


```
### CRAN

```
[... 141 earlier lines omitted; the full 00install.out is in the check artifact ...]
    |
677 |         let layers = match freestiler_core::file_input::parquet_to_layers(
    |                                             ^^^^^^^^^^ could not find `file_input` in `freestiler_core`
    |
note: found an item that was configured out
   --> freestiler-core/src/lib.rs:9:9
    |
  8 | #[cfg(any(feature = "geoparquet", feature = "duckdb"))]
    |          -------------------------------------------- the item is gated here
...
398 | pub fn generate_pmtiles(
    |        ^^^^^^^^^^^^^^^^

Some errors have detailed explanations: E0308, E0433, E0599.
For more information about an error, try `rustc --explain E0308`.
warning: `freestiler` (lib) generated 3 warnings
error: could not compile `freestiler` (lib) due to 13 previous errors; 6 warnings emitted
make: *** [Makevars:28: rust/target/release/libfreestiler.a] Error 101
ERROR: compilation failed for package ‘freestiler’
* removing ‘/revdepx/out/freestiler.Rcheck/freestiler’


```
