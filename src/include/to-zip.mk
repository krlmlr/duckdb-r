duckdb.tar: $(SOURCES)
	if [ -n "$(DUCKDB_R_PREBUILT_ARCHIVE)" ]; then tar -cvf $(DUCKDB_R_PREBUILT_ARCHIVE) $(SOURCES); fi
	rm -f Makevars.duckdb
