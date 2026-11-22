#!/usr/bin/env bash
# Check scripts/series-freeze.sh and scripts/series-unfreeze.sh, offline, against a stand-in for `gh api` that keeps
# each repository's rulesets in a file: no network, no fixtures on disk.
#
#   1. Freezing creates `freeze <B>` on both repositories where neither has one, active, with no bypass list and the
#      three rules, targeting the branch alone.
#   2. Unfreezing disables it on both, deletes nothing, and a second unfreeze has nothing to do.
#   3. Freezing again reuses the ruleset, written whole: a bypass list added since is gone.
#   4. --remote acts on one repository, --dry-run writes nothing, an organization's ruleset of the same name is left
#      alone, two of the repository's own are refused, and a branch no series lands on is refused.
#
# Usage:
#   scripts/series-freeze-test.sh
#
# Environment variables:
#   KEEP - if non-empty, do not delete the scratch directory

set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
SCRATCH=$(mktemp -d)
[ -n "${KEEP:-}" ] || trap 'rm -rf "$SCRATCH"' EXIT
[ -z "${KEEP:-}" ] || echo "scratch: $SCRATCH"

pass=0
fail=0
ok() { pass=$((pass + 1)); echo "  ok   $1"; }
no() { fail=$((fail + 1)); echo "  FAIL $1"; }
is() { if [ "$2" = "$3" ]; then ok "$1"; else no "$1"; echo "         actual: $2"; echo "       expected: $3"; fi; }
has() { case "$2" in *"$3"*) ok "$1" ;; *) no "$1"; echo "       missing: $3"; echo "            in: $2" ;; esac; }

GH=$SCRATCH/gh
mkdir -p "$GH" "$SCRATCH/bin"
# The stand-in for `gh`: lists with `--paginate ...rulesets?includes_parents=false --jq`, creates with
# `-X POST ... --input -`, writes whole with `-X PUT .../<id> --input -`, sets with `-X PUT .../<id> -f enforcement=`,
# and reads one with `.../<id> --jq`; each call is logged.
cat > "$SCRATCH/bin/gh" <<EOF
#!/bin/bash
echo "\$*" >> "$GH/log"
[ "\$1" = api ] || exit 1
shift
file() { local r=\${1#repos/}; r=\${r%%/rulesets*}; echo "$GH/\${r/\//_}.json"; }
if [ "\$1" = --paginate ]; then
  jq -r "\$4" "\$(file "\$2")"
elif [ "\$1" = -X ] && [ "\$2" = POST ]; then
  f=\$(file "\$3"); new=\$(cat)
  id=\$(( \$(jq '[(map(.id) | max), 100] | max' "\$f") + 1 ))
  jq --argjson b "\$new" --argjson id "\$id" '. + [\$b + {id: \$id, source_type: "Repository"}]' "\$f" > "\$f.new"; mv "\$f.new" "\$f"
  jq -r "\$7" <<<"{\"id\": \$id}"
elif [ "\$1" = -X ] && [ "\$4" = --input ]; then
  f=\$(file "\$3"); id=\${3##*/}; new=\$(cat)
  jq --argjson b "\$new" --argjson id "\$id" 'map(if .id == \$id then . + \$b else . end)' "\$f" > "\$f.new"; mv "\$f.new" "\$f"
elif [ "\$1" = -X ]; then
  f=\$(file "\$3"); id=\${3##*/}
  jq --argjson id "\$id" --arg e "\${5#enforcement=}" 'map(if .id == \$id then .enforcement = \$e else . end)' "\$f" > "\$f.new"; mv "\$f.new" "\$f"
else
  f=\$(file "\$1"); id=\${1##*/}
  jq -r --argjson id "\$id" '.[] | select(.id == \$id) | . + {current_user_can_bypass: (if (.bypass_actors // []) == [] then "never" else "always" end)}' "\$f" | jq -r "\$3"
fi
EOF
chmod +x "$SCRATCH/bin/gh"
export PATH="$SCRATCH/bin:$PATH"

org='{"id":9,"name":"freeze main","source_type":"Organization","enforcement":"disabled"}'
other='{"id":7,"name":"main","source_type":"Repository","enforcement":"active"}'
echo "[$org,$other]" > "$GH/duckdb_duckdb-r.json"
echo "[$other]" > "$GH/krlmlr_duckdb-r.json"
freeze() { "$HERE/series-freeze.sh" "$@" 2>&1; }
unfreeze() { "$HERE/series-unfreeze.sh" "$@" 2>&1; }
mine() { # <file>: the freeze of main, id and enforcement
  jq -r '.[] | select(.source_type == "Repository" and .name == "freeze main") | "\(.id) \(.enforcement)"' "$GH/$1.json"
}

echo "1. freeze"
st=0; out=$(freeze main) || st=$?
is "succeeds" "$st" 0
is "creates it upstream" "$(mine duckdb_duckdb-r)" "101 active"
is "and on the fork" "$(mine krlmlr_duckdb-r)" "101 active"
is "  with no bypass, the three rules, on the branch" \
  "$(jq -c '.[] | select(.id == 101) | [.bypass_actors, [.rules[].type], .conditions.ref_name.include, .target]' "$GH/duckdb_duckdb-r.json")" \
  '[[],["update","deletion","non_fast_forward"],["refs/heads/main"],"branch"]'
is "leaves the organization's ruleset alone" "$(jq -r '.[0].enforcement' "$GH/duckdb_duckdb-r.json")" disabled

echo "2. unfreeze"
st=0; out=$(unfreeze main) || st=$?
is "succeeds" "$st" 0
is "disables it on both" "$(mine duckdb_duckdb-r) $(mine krlmlr_duckdb-r)" "101 disabled 101 disabled"
st=0; out=$(unfreeze main) || st=$?
is "a second unfreeze succeeds" "$st" 0
has "  with nothing to do" "$out" "is already lifted"
st=0; out=$(unfreeze v2.0-cyanoptera) || st=$?
is "a branch never frozen succeeds" "$st" 0
has "  with nothing to do" "$out" "no freeze of v2.0-cyanoptera"

echo "3. freeze again"
jq 'map(if .id == 101 then .bypass_actors = [{"actor_id": 5}] else . end)' "$GH/duckdb_duckdb-r.json" > "$GH/x"
mv "$GH/x" "$GH/duckdb_duckdb-r.json"
st=0; out=$(freeze main) || st=$?
is "succeeds" "$st" 0
is "reuses the ruleset, active" "$(mine duckdb_duckdb-r)" "101 active"
is "  written whole" "$(jq -c '.[] | select(.id == 101) | .bypass_actors' "$GH/duckdb_duckdb-r.json")" "[]"

echo "4. the options"
: > "$GH/log"
st=0; out=$(unfreeze main --remote origin) || st=$?
is "--remote origin" "$(mine duckdb_duckdb-r) $(mine krlmlr_duckdb-r)" "101 active 101 disabled"
has "  names only the fork" "$out" "origin (krlmlr/duckdb-r)"
is "  calls gh only for it" "$(grep -c duckdb/duckdb-r "$GH/log" || true)" 0
: > "$GH/log"
st=0; out=$(freeze main --dry-run) || st=$?
is "--dry-run succeeds" "$st" 0
has "  printing the write" "$out" "would run: gh api -X PUT repos/krlmlr/duckdb-r/rulesets/101 --input -"
is "  writing nothing" "$(grep -c -- '-X' "$GH/log" || true)" 0
is "  so the fork stays lifted" "$(mine krlmlr_duckdb-r)" "101 disabled"
jq '. + [{"id": 300, "name": "freeze main", "source_type": "Repository", "enforcement": "active"}]' "$GH/krlmlr_duckdb-r.json" > "$GH/x"
mv "$GH/x" "$GH/krlmlr_duckdb-r.json"
st=0; out=$(freeze main --remote origin) || st=$?
is "two freezes of one branch are refused" "$st" 1
has "  and named" "$out" "more than one ruleset named 'freeze main'"
st=0; out=$(freeze feature) || st=$?
is "a branch no series lands on is refused" "$st" 2
st=0; out=$(freeze main --remote elsewhere) || st=$?
is "an unknown remote is refused" "$st" 2

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
