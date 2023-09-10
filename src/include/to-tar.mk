# This file is used from Makevars if $DUCKDB_R_PREBUILT_ARCHIVE is empty
# or does not point to an existing file.
# In the latter case, we create the file after the object files have been built.
duckdb.tar: $(SOURCES)
	echo "Creating .tar file: $(DUCKDB_R_PREBUILT_ARCHIVE)"
	if [ -n "$(DUCKDB_R_PREBUILT_ARCHIVE)" ]; then tar -cv -f "$(DUCKDB_R_PREBUILT_ARCHIVE)" $(SOURCES); fi
	rm -f Makevars.duckdb
