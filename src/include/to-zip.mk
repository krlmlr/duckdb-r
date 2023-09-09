duckdb.tar: $(SOURCES)
	if [ -n "$(DUCKDB_R_PREBUILT_ARCHIVE)" ]; then tar -cv --force-local -f "$(DUCKDB_R_PREBUILT_ARCHIVE)" $(SOURCES); fi
	rm -f Makevars.duckdb
