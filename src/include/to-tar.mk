# This file is used from Makevars if $DUCKDB_R_PREBUILT_ARCHIVE is empty
# or does not point to an existing file.
# In the latter case, we create the file after the object files have been built.
all: duckdb.tar
# The archive also carries the jemalloc objects when this build compiles them,
# and Makevars.jemalloc, which configure reads back on restore to tell whether
# the objects were compiled for the allocator it has just chosen.
duckdb.tar: $(SOURCES)
	if [ -n "$(DUCKDB_R_PREBUILT_ARCHIVE)" ]; then tar -cv -f "$(DUCKDB_R_PREBUILT_ARCHIVE)" $(SOURCES) $(filter $(SOURCES_JEMALLOC),$(OBJECTS)) Makevars.jemalloc; fi
	rm -f Makevars.duckdb
