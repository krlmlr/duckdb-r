duckdb.tar: $(DUCKDB_R_PREBUILT_ARCHIVE)
	ls -l $(SOURCES) || true
	ls -lR
	rm -f Makevars.duckdb
