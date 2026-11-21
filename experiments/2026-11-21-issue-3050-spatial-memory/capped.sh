#!/bin/bash
# Runs one command under an outer memory cap and a time cap, and reports its
# peak RSS, wall time and outcome.
#
# Usage: capped.sh <label> <command> [args ...]
# CAP_BYTES (default 8 GiB) is the cgroup v1 memory limit, CAP_SECONDS
# (default 900) the timeout. The command's output goes to stdout as is,
# followed by a line "RESULT <label> ...".
#
# The cap is a child of this shell's cgroup v1 memory cgroup, so the kernel's
# OOM killer kills only the command once it passes CAP_BYTES, never the
# container.
#
# Handbook: none; supports duckdb/duckdb-r#3050.

set -u
label=$1
shift
cap=${CAP_BYTES:-$((8 * 1024 * 1024 * 1024))}
secs=${CAP_SECONDS:-900}

parent=/sys/fs/cgroup/memory$(awk -F: '$2 == "memory" { print $3 }' /proc/self/cgroup)
cg=$parent/repro3050-$$
mkdir "$cg"
echo "$cap" >"$cg/memory.limit_in_bytes"
echo "$cap" >"$cg/memory.memsw.limit_in_bytes" 2>/dev/null || true

tfile=$(mktemp)
(
  echo "$BASHPID" >"$cg/cgroup.procs"
  exec /usr/bin/time -v -o "$tfile" timeout -k 10 "$secs" "$@"
)
status=$?

rss_kb=$(awk -F': ' '/Maximum resident set size/ { print $2 }' "$tfile")
wall=$(awk -F': ' '/Elapsed \(wall clock\)/ { print $2 }' "$tfile")
sig=$(grep -o 'terminated by signal [0-9]*' "$tfile")
ooms=$(awk '/oom_kill / { print $2 }' "$cg/memory.oom_control")
cg_peak=$(cat "$cg/memory.max_usage_in_bytes")
rmdir "$cg"
rm -f "$tfile"

if [ "${ooms:-0}" -gt 0 ]; then
  outcome="killed: exceeds cap $((cap / 1024 / 1024)) MiB"
elif [ "$status" -eq 124 ]; then
  outcome="killed: timeout ${secs} s"
elif [ "$status" -ne 0 ]; then
  outcome="error (exit $status${sig:+, $sig})"
else
  outcome="ok"
fi
printf 'RESULT %s | peak RSS %s MiB | cgroup peak %s MiB | wall %s | %s\n' \
  "$label" "$(( ${rss_kb:-0} / 1024 ))" "$((cg_peak / 1024 / 1024))" "${wall:-n/a}" "$outcome"
