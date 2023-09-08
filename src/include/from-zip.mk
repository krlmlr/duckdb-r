duckdb.tar: $(DUCKDB_R_PREBUILT_ARCHIVE)
	ls -l $(SOURCES) || true
	rm -f Makevars.duckdb
