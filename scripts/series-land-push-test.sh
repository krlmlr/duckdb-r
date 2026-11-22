#!/usr/bin/env bash
# Check scripts/series-land-push.sh, offline, against two bare repositories built here standing in for the canonical
# repository and the fork, and a stand-in for `gh api` that keeps their rulesets: no network, no fixtures on disk.
# A pre-receive hook in each refuses an update of `main` while its `freeze main` ruleset is active, as GitHub does.
#
#   1. A landing that does not descend from `main` on either repository is refused, with nothing written.
#   2. A commit without a success record on the store, missing or failed, is refused, and --no-check pushes past it.
#      A --sha below the version bump, a commit out of place and a landing that does not end on the bump are refused
#      with --no-check too. The base's own commits below the first vendor commit, and a vendor commit under the older
#      `Update vendored sources` subject, are in place.
#   3. A dry run writes nothing: no ref, no tag, no ruleset.
#   4. A run moves `main` on both repositories, lifts each freeze only around its push, and puts it back.
#   5. The fork's annotated tag reaches the canonical repository as the same object; without it, the tagging
#      command is printed and a rerun copies the tag without pushing a branch.
#   6. A push refused for another reason still puts the freeze back, and so does a disable that GitHub applied but
#      `gh` reported as failed. An organization's ruleset of the same name is left alone.
#   7. A lightweight tag on the fork, or a different tag of the same name upstream, is refused.
#   8. --onto lands `<L>-land-dev` on another branch, which no ruleset freezes.
#
# Usage:
#   scripts/series-land-push-test.sh
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

export GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.invalid
export GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.invalid
unset RCC_BRANCH
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=push.negotiate GIT_CONFIG_VALUE_0=false

# --- the fixture -------------------------------------------------------------
#
# `main` at C0 on both repositories, the landing B1..C3 above it on the fork as `main-land-dev`: the base's own
# commit B1, the vendor commit C1 under the older subject, the vendor commit C2 and the bump C3; a commit X beside it,
# and the store's records on the fork's `rcc2`. The script runs in a repository with no remotes at all.

CANON=$SCRATCH/canonical.git
FORK=$SCRATCH/fork.git
GH=$SCRATCH/gh
BUILD=$SCRATCH/build
WORK=$SCRATCH/work
mkdir -p "$GH" "$SCRATCH/bin"
git init -q --bare -b main "$CANON"
git init -q --bare -b main "$FORK"
git init -q -b main "$WORK"

# The rulesets of each repository, as `gh api repos/<repo>/rulesets` lists them: its freeze first, then an
# organization's ruleset of the same name that the script must not touch, then another of its own.
ruleset() { # <file> <id> <enforcement>
  printf '[{"id":%s,"name":"freeze main","source_type":"Repository","enforcement":"%s"},%s,%s]\n' "$2" "$3" \
    '{"id":9,"name":"freeze main","source_type":"Organization","enforcement":"disabled"}' \
    '{"id":7,"name":"main","source_type":"Repository","enforcement":"active"}' > "$1"
}
hook() { # <bare repository> <its rulesets' file name>
  cat > "$1/hooks/pre-receive" <<EOF
#!/bin/bash
while read -r old new ref; do
  [ ! -e "$SCRATCH/reject" ] || { echo "rejected by a rule" >&2; exit 1; }
  if [ "\$ref" = refs/heads/main ] &&
    jq -e '.[] | select(.id != 9 and .name == "freeze main" and .enforcement == "active")' "$GH/$2.json" >/dev/null 2>&1; then
    echo "frozen" >&2; exit 1
  fi
done
EOF
  chmod +x "$1/hooks/pre-receive"
}
hook "$CANON" duckdb_duckdb-r
hook "$FORK" krlmlr_duckdb-r

# The stand-in for `gh`: `api --paginate repos/<o>/<r>/rulesets?includes_parents=false --jq <filter>` lists, and
# `api -X PUT repos/<o>/<r>/rulesets/<id> -f enforcement=<e> --silent` sets one; each call is logged. With
# $GH/flaky present, a disable is applied and then reported as failed, as a timeout after GitHub acted would.
cat > "$SCRATCH/bin/gh" <<EOF
#!/bin/bash
echo "\$*" >> "$GH/log"
[ "\$1" = api ] || exit 1
shift
if [ "\$1" = -X ]; then
  path=\$3 e=\${5#enforcement=}
  repo=\${path#repos/}; repo=\${repo%/rulesets/*}; id=\${path##*/}
  f="$GH/\${repo/\//_}.json"
  jq --argjson id "\$id" --arg e "\$e" 'map(if .id == \$id then .enforcement = \$e else . end)' "\$f" > "\$f.new"
  mv "\$f.new" "\$f"
  [ "\$e" != disabled ] || [ ! -e "$GH/flaky" ] || { echo "HTTP 502" >&2; exit 1; }
else
  [ "\$1" = --paginate ] || exit 1
  repo=\${2#repos/}; repo=\${repo%/rulesets?includes_parents=false}
  jq -r "\$4" "$GH/\${repo/\//_}.json"
fi
EOF
chmod +x "$SCRATCH/bin/gh"
export PATH="$SCRATCH/bin:$PATH"
export SERIES_LAND_PUSH_CANONICAL_URL=$CANON SERIES_LAND_PUSH_FORK_URL=$FORK

git init -q -b main "$BUILD"
cd "$BUILD"
git config commit.gpgsign false
c() { # <file> <version> <subject>
  printf 'Package: duckdb\nVersion: %s\n' "$2" > DESCRIPTION; echo "$1" > "$1.txt"; git add -A; git commit -qm "$3"; git rev-parse HEAD
}
C0=$(c seed 2.0.0.9000 "chore: seed")
B1=$(c base 2.0.0.9000 "test: the base's own")
C1=$(c one 2.0.0.9000.1 "chore: Update vendored sources to duckdb/duckdb@0123456789abcdef0123456789abcdef01234567")
C2=$(c two 2.0.0.9000.2 "vendor: two")
C3=$(c three 2.0.99.9000 "chore: Bump version to 2.0.99.9000")
git checkout -q -b beside "$C0"
X=$(c beside 2.0.0.9001 "fix: beside")
git checkout -q main
git push -q "$CANON" "$C0:refs/heads/main"
git push -q "$FORK" "$C0:refs/heads/main" "$C3:refs/heads/main-land-dev"

ruleset "$GH/duckdb_duckdb-r.json" 101 active
ruleset "$GH/krlmlr_duckdb-r.json" 202 active

record() { # <commit> <state>: the store's record of <commit>, on the fork's rcc2
  mkdir -p "$SCRATCH/store/runs2.d/${1:0:2}"
  printf '{"commit":"%s","status":{"context":"rcc","state":"%s"}}\n' "$1" "$2" > "$SCRATCH/store/runs2.d/${1:0:2}/$1.ndjson"
  git -C "$SCRATCH/store" add -A
  git -C "$SCRATCH/store" commit -qm "$1 $2"
  git -C "$SCRATCH/store" push -q -f "$FORK" HEAD:refs/heads/rcc2
}
git init -q -b rcc2 "$SCRATCH/store"
record "$B1" success; record "$C1" success; record "$C3" success

heads() { echo "$(git ls-remote "$CANON" refs/heads/main | cut -f1) $(git ls-remote "$FORK" refs/heads/main | cut -f1)"; }
rules() { echo "$(jq -r '.[0].enforcement' "$GH/duckdb_duckdb-r.json") $(jq -r '.[0].enforcement' "$GH/krlmlr_duckdb-r.json")"; }
land() { (cd "$WORK" && "$HERE/series-land-push.sh" "$@" 2>&1); }

# --- 1. a landing that does not fast-forward ---------------------------------
echo "1. the fast-forward check"
ruleset "$GH/duckdb_duckdb-r.json" 101 disabled
git push -q "$CANON" "$X:refs/heads/main"
ruleset "$GH/duckdb_duckdb-r.json" 101 active
st=0; out=$(land main --no-check) || st=$?
is "refused off the canonical main" "$st" 1
has "  names the side" "$out" "does not fast-forward main on the canonical repository"
is "  nothing moved" "$(heads)" "$X $C0"
is "  no ruleset touched" "$(rules)" "active active"
st=0; out=$(land main --sha "$X" --no-check) || st=$?
is "a --sha off main-land-dev is refused" "$st" 1
ruleset "$GH/duckdb_duckdb-r.json" 101 disabled
git push -q -f "$CANON" "$C0:refs/heads/main"
ruleset "$GH/duckdb_duckdb-r.json" 101 active
is "refs are under refs/series-land-push only while it runs" "$(git -C "$WORK" for-each-ref)" ""

# --- 2. the records ----------------------------------------------------------
echo "2. the store's records"
st=0; out=$(land main --dry-run) || st=$?
is "a commit without a record is refused" "$st" 1
has "  and named" "$out" "not passed: ${C2:0:10} (missing)"
record "$C2" failure
st=0; out=$(land main --dry-run) || st=$?
is "a failed commit is refused" "$st" 1
has "  and named" "$out" "not passed: ${C2:0:10} (failure)"
has "  counted" "$out" "1 of 4 commits"
st=0; out=$(land main --dry-run --no-check) || st=$?
is "--no-check passes it" "$st" 0
has "  and says so" "$out" "Not checked"
record "$C2" success
st=0; out=$(land main --dry-run --sha "$C2") || st=$?
is "a --sha below the bump is refused" "$st" 1
has "  as not the tip" "$out" "is not the main-land-dev tip"
st=0; out=$(land main --dry-run --sha "$C2" --no-check) || st=$?
is "  with --no-check too" "$st" 1
# A landing whose bump has a stray commit under it, and one that does not end on a bump, both pushed in turn as
# main-land-dev.
git checkout -q -b stray "$C2"
S1=$(c stray 2.0.0.9000.2 "fix: stray")
S2=$(c three 2.0.99.9000 "chore: Bump version to 2.0.99.9000")
git checkout -q main
git push -q -f "$FORK" "$S2:refs/heads/main-land-dev"
st=0; out=$(land main --dry-run --no-check) || st=$?
is "a commit out of place is refused with --no-check" "$st" 1
has "  and named" "$out" "carries a commit out of place: ${S1:0:7}"
git push -q -f "$FORK" "$C2:refs/heads/main-land-dev"
st=0; out=$(land main --dry-run --no-check) || st=$?
is "a landing without its bump is refused with --no-check" "$st" 1
has "  and named" "$out" "does not end on the version bump"
git push -q -f "$FORK" "$C3:refs/heads/main-land-dev"

# --- 3. a dry run ------------------------------------------------------------
echo "3. a dry run"
: > "$GH/log"
st=0; out=$(land main --dry-run) || st=$?
is "succeeds" "$st" 0
has "prints the range" "$out" "$C0..$C3, 4 commits"
has "checks the records" "$out" "All 4 commits passed"
has "would lift the canonical freeze" "$out" "would run: gh api -X PUT repos/duckdb/duckdb-r/rulesets/101 -f enforcement=disabled"
has "would push" "$out" "would run: git push $CANON $C3:refs/heads/main"
has "would lift the fork's freeze" "$out" "repos/krlmlr/duckdb-r/rulesets/202"
has "prints the tagging command" "$out" "gh workflow run tag-version.yaml --repo krlmlr/duckdb-r --ref main -f commit=$C3"
is "nothing moved" "$(heads)" "$C0 $C0"
is "no ruleset touched" "$(rules)" "active active"
is "gh only read" "$(grep -c -- '-X PUT' "$GH/log" || true)" 0

# --- 6. a push refused after the freeze is lifted ----------------------------
echo "6. a refused push"
touch "$SCRATCH/reject"
st=0; out=$(land main) || st=$?
rm "$SCRATCH/reject"
is "fails" "$st" 1
is "nothing moved" "$(heads)" "$C0 $C0"
is "the freeze is back" "$(rules)" "active active"
touch "$GH/flaky"
st=0; out=$(land main) || st=$?
rm "$GH/flaky"
is "a disable reported as failed fails" "$st" 1
is "  nothing moved" "$(heads)" "$C0 $C0"
is "  the freeze is back" "$(rules)" "active active"
is "  the organization's ruleset untouched" "$(jq -r '.[1].enforcement' "$GH/duckdb_duckdb-r.json")" disabled

# --- 4. the run --------------------------------------------------------------
echo "4. a run"
: > "$GH/log"
st=0; out=$(land main --sha "${C3:0:12}") || st=$?
is "succeeds" "$st" 0
is "moves main on both" "$(heads)" "$C3 $C3"
is "puts both freezes back" "$(rules)" "active active"
is "lifts and restores in order" "$(grep -- '-X PUT' "$GH/log" | sed 's/.*rulesets\/\([0-9]*\) -f enforcement=\([a-z]*\).*/\1 \2/' | tr '\n' ' ')" \
  "101 disabled 101 active 202 disabled 202 active "
has "prints the confirmation" "$out" "$C3	refs/heads/main"
st=0; out=$(land main) || st=$?
is "a rerun succeeds" "$st" 0
has "  and pushes nothing" "$out" "duckdb/duckdb-r: main is already at $C3"

# --- 5. the tag --------------------------------------------------------------
echo "5. the tag"
git tag -a v2.0.99.9000 -m "duckdb 2.0.99.9000" "$C3"
git push -q "$FORK" refs/tags/v2.0.99.9000
obj=$(git rev-parse v2.0.99.9000)
: > "$GH/log"
st=0; out=$(land main) || st=$?
is "a rerun copies the tag" "$st" 0
is "  as the same tag object" "$(git ls-remote "$CANON" refs/tags/v2.0.99.9000 | cut -f1)" "$obj"
is "  pointing at the landing" "$(git ls-remote "$CANON" 'refs/tags/v2.0.99.9000^{}' | cut -f1)" "$C3"
is "  without touching a ruleset" "$(grep -c -- '-X PUT' "$GH/log" || true)" 0
st=0; out=$(land main) || st=$?
has "a second rerun finds it there" "$out" "v2.0.99.9000 is already there"
is "no tag is created in the working repository" "$(git -C "$WORK" tag)" ""

# --- 7. tags that are refused ------------------------------------------------
echo "7. refused tags"
git push -q "$CANON" :refs/tags/v2.0.99.9000
git tag -a -f v2.0.99.9000 -m "duckdb 2.0.99.9000, another" "$C3" >/dev/null
git push -q "$CANON" refs/tags/v2.0.99.9000
st=0; out=$(land main) || st=$?
is "a different tag upstream is refused" "$st" 1
has "  and named" "$out" "v2.0.99.9000 on duckdb/duckdb-r is $(git rev-parse v2.0.99.9000), not the fork's $obj"
git push -q "$CANON" :refs/tags/v2.0.99.9000
git push -q -f "$FORK" "$C3:refs/tags/v2.0.99.9000"
st=0; out=$(land main) || st=$?
is "a lightweight tag on the fork is refused" "$st" 1
has "  and named" "$out" "is a lightweight tag"
is "  and not copied" "$(git ls-remote "$CANON" refs/tags/v2.0.99.9000)" ""

# --- 8. --onto ---------------------------------------------------------------
echo "8. --onto"
git push -q -f "$FORK" "$obj:refs/tags/v2.0.99.9000"
git push -q "$CANON" "$C0:refs/heads/v2.0-cyanoptera"
git push -q "$FORK" "$C0:refs/heads/v2.0-cyanoptera"
: > "$GH/log"
st=0; out=$(land main --onto v2.0-cyanoptera) || st=$?
is "lands main-land-dev on the other branch" "$st" 0
is "  moving it on both" "$(git ls-remote "$CANON" refs/heads/v2.0-cyanoptera | cut -f1) $(git ls-remote "$FORK" refs/heads/v2.0-cyanoptera | cut -f1)" "$C3 $C3"
is "  lifting no freeze of main" "$(grep -c -- '-X PUT' "$GH/log" || true)" 0
has "  from where it stood" "$out" "duckdb/duckdb-r: v2.0-cyanoptera ${C0:0:10} -> ${C3:0:10}"
has "  and copies the tag" "$out" "copying v2.0.99.9000 ($obj)"
st=0; out=$(land main --onto feature) || st=$?
is "a branch that is no line's is refused" "$st" 2

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
