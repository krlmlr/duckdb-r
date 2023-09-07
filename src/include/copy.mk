duckdb.a: $(DUCKDB_R_PREBUILT_ARCHIVE)
	cp $< $@
	rm -f Makevars.duckdb
