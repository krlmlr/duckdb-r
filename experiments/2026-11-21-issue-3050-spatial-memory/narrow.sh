#!/bin/bash
# Profiles one year's query (2024 unless given) per duckdb version and
# per variation, one run at a time under capped.sh, and keeps per run
# the engine's peak buffer memory and peak temporary directory size,
# the top-N aggregate's line from the profile, and the RESULT line.
#
# Usage: narrow.sh <section> ; LIBS names the libraries to compare, as
# "<label>=<path> ...", and DATA the Parquet directory (unused by the
# registered runs, which repro.R builds itself).
# Writes out/narrow-<section>.txt.
#
# Handbook: none; supports duckdb/duckdb-r#3050.

set -u
here=$(cd "$(dirname "$0")" && pwd)
section=$1
out=$here/out/narrow-$section.txt
: >"$out"

one() {
  local args="$*"
  for lv in $LIBS; do
    local label=${lv%%=*} lib=${lv#*=}
    {
      echo "## $label $args"
      R_LIBS=$lib "$here/capped.sh" "$label $args" Rscript "$here/repro.R" \
        data="$DATA" explain=analyze "$@" 2>&1 |
        grep -E -e '^peak buffer' -e '^year' -e 'arg_min_nulls_last|TOP_N|WINDOW|STREAMING_LIMIT|LIMIT' \
          -e '^RESULT' -e 'Error|rror:' |
        sed -E 's/^ +//'
      echo
    } | tee -a "$out"
  done
}

case $section in
k)
  for k in 5000 4000 3000 2049 2048 2000 1000 300 100; do one years=2024 k=$k; done
  ;;
threads)
  for t in 1 2 4; do one years=2024 set.threads=$t; done
  ;;
variants)
  for v in no_limit no_order no_argmin no_order_limit; do one years=2024 variant=$v; done
  one years=2024 set.preserve_insertion_order=false
  one years=2024 source=parquet
  ;;
size)
  for f in 0.1 0.25 0.5; do
    one years=2024 n_ref=$(awk "BEGIN { print int(70000 * $f) }") n_obs=$(awk "BEGIN { print int(26000 * $f) }")
  done
  ;;
esac
