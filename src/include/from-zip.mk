duckdb.tar: $(DUCKDB_R_PREBUILT_ARCHIVE)
	pwd
	echo $(DUCKDB_R_PREBUILT_ARCHIVE)
	ls -l $(SOURCES) || true
	tar -xmvf $(DUCKDB_R_PREBUILT_ARCHIVE)
	ls -l $(SOURCES) || true
	rm -f Makevars.duckdb
