#!/bin/bash
# Runs repro.R per duckdb version and data source, and query.sql in the
# DuckDB CLI per engine version, one run at a time under capped.sh,
# and writes each run's output to out/<name>.txt.
#
# Usage: measure.sh <name> r <library> [repro.R args ...]
#        measure.sh <name> cli <duckdb binary> <sql file>
# A SQL file runs from DATA, and the JSON profiles it writes there are
# summarized by profile-summary.py.
# DATA names the directory with geodata.parquet and dataindex.parquet,
# which `repro.R write=<dir>` writes.
#
# Handbook: none; supports duckdb/duckdb-r#3050.

set -u
here=$(cd "$(dirname "$0")" && pwd)
name=$1
kind=$2
target=$3
shift 3
mkdir -p "$here/out"
out=$here/out/$name.txt

{
  echo "## $name: $kind $(basename "$target") $*"
  if [ "$kind" = r ]; then
    R_LIBS=$target "$here/capped.sh" "$name" Rscript "$here/repro.R" data="$DATA" "$@" 2>&1 |
      grep -v -e 'storing downloaded extensions' -e 'persists across sessions' -e '^ℹ'
  else
    # The 2.0 CLI switches to an "agent mode" output when it sees these.
    (cd "$DATA" && rm -f ./*.json &&
      env -u AI_AGENT -u CLAUDECODE "$here/capped.sh" "$name" "$target" -c ".read $here/$1" 2>&1 &&
      shopt -s nullglob && python3 -I "$here/profile-summary.py" ./*.json)
  fi
  echo
} | tee "$out"
