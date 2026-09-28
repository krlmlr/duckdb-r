# Interactive use

What the package shows while you work,
rather than what it returns when you ask:
the query progress display, and the RStudio Connections pane.

**The progress display** is the engine calling back into R.
The C++ side holds the symbol it invokes
(`get_progress_display_sym` in
[`src/include/rapi.hpp`](/src/include/rapi.hpp)),
and [`R/progress_display.R`](/R/progress_display.R) draws it.
The engine calls it every time it polls a running query, whether or not the progress moved,
thousands of times in a query of a few seconds
([#2748](https://github.com/duckdb/duckdb-r/issues/2748)).
The glue sets the engine's own wait, `wait_time`, to zero in [`src/connection.cpp`](/src/connection.cpp).
Throttling is left to the R side.
A query paints nothing in its first half second, so a fast query never paints, and at most one line every half second after that.
Completion bypasses the throttle, so a painted line is cleared when its query completes.
Completion is the engine's call to the display's `Finish()`, which never comes for a query that fails or is interrupted,
and comes with a streamed Arrow result's first chunk, before the reads that report further progress.
Either way the last line painted stays until the next query starts.
Its display is built by `get_progress_display()`, which clears the line, if nothing was printed after it, and restarts the throttle.
The display keeps one state for the session, not one per query.
A query that starts while another connection's stream is still being read clears that stream's line and restarts its throttle too.

**The Connections pane** is RStudio-only and lives in
[`R/Viewer.R`](/R/Viewer.R), adapted from the odbc package's.
It queries `information_schema` to decide which object types the
database actually has, so a database with no views does not advertise
them, and it tells the IDE when a connection closes.

*To deepen: state what turns the progress display on and off, and what
the pane does with a connection the user closes from the IDE.*
