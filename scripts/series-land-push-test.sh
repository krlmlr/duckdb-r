#!/usr/bin/env bash
# Check scripts/series-land-push.sh, offline, in a checkout whose remotes `origin` and `upstream` name the fork and
# the canonical repository on GitHub while git rewrites both to bare repositories built here, with a stand-in for
# `series-land.sh --status` beside a copy of the script: no network, no fixtures on disk. scripts/series-land-test.sh
# checks --status itself. A pre-receive hook in each repository refuses a branch's update while a marker file says
# the branch is frozen there.
#
#   1. A remote that is not the repository it must be, by its URL or its push URL, is refused; the https and SSH
#      forms are both accepted, in any letter case.
#   2. Nothing is pushed unless --status, run by the script's own bash and asked of `origin` and `upstream`, prints READY with its push line, which
#      names the head and the branch; a --sha that is not that head is refused.
#   3. A head that does not fast-forward the branch on `origin` is refused.
#   4. A landing that does not change NEWS.md, or whose NEWS.md has no section for the version, is refused, and so
#      is a tag of that name that points elsewhere or is lightweight, before anything is pushed.
#   5. A dry run pushes nothing, and prints the tag's message.
#   6. A push the freeze refuses fails the run, names scripts/series-unfreeze.sh, and tags nothing.
#   7. A run moves the branch on both remotes, then tags the head with the NEWS.md section and pushes the same tag
#      object to both; a rerun writes nothing, and a tag one remote lacks is pushed there as the same object.
#   8. A release's version is tagged `.9900`.
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
export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=push.negotiate GIT_CONFIG_VALUE_0=false

# --- the fixture -------------------------------------------------------------
#
# `main` at C0 on both repositories and the landing C1..C3 above it, the bump C3 with its NEWS.md section, on the
# fork as `main-land-dev`; a commit X beside it. The checkout the script runs in holds none of it.

CANON=$SCRATCH/canonical.git
FORK=$SCRATCH/fork.git
BUILD=$SCRATCH/build
WORK=$SCRATCH/work
git init -q --bare -b main "$CANON"
git init -q --bare -b main "$FORK"
git init -q -b main "$WORK"
git -C "$WORK" remote add origin git@github.com:krlmlr/duckdb-r.git
git -C "$WORK" remote add upstream https://github.com/duckdb/duckdb-r
git -C "$WORK" config url."$FORK".insteadOf git@github.com:krlmlr/duckdb-r.git
git -C "$WORK" config url."$CANON".insteadOf https://github.com/duckdb/duckdb-r

hook() { # <bare repository> <name>: refuses a branch's update while $SCRATCH/frozen-<name> exists
  cat > "$1/hooks/pre-receive" <<EOF
#!/bin/bash
while read -r _ _ ref; do
  case "\$ref" in refs/heads/*) [ ! -e "$SCRATCH/frozen-$2" ] || { echo "frozen" >&2; exit 1; } ;; esac
done
EOF
  chmod +x "$1/hooks/pre-receive"
}
hook "$CANON" upstream
hook "$FORK" origin

# The copy of the script, beside a stand-in for series-land.sh that logs its arguments and answers with
# $SCRATCH/status and the exit status in $SCRATCH/status.rc. Its shebang names no shell, as /bin/bash names one too
# old on macOS: the script must run it with its own bash.
mkdir -p "$SCRATCH/scripts"
cp "$HERE/series-land-push.sh" "$SCRATCH/scripts/"
cat > "$SCRATCH/scripts/series-land.sh" <<EOF
#!/nonexistent/bash
echo "\$*" >> "$SCRATCH/status.log"
cat "$SCRATCH/status"
exit "\$(cat "$SCRATCH/status.rc")"
EOF
chmod +x "$SCRATCH/scripts/series-land.sh"
says() { # <exit status> <line>...: what --status prints
  echo "$1" > "$SCRATCH/status.rc"
  shift
  printf '%s\n' "$@" > "$SCRATCH/status"
}
ready() { # <head> <branch>: READY, as --status prints it
  says 0 "x-land-dev: 3 of 3 commits above x-land-green passed" \
    "READY: every commit has passed, and $2 (abc) fast-forwards to it:" \
    "  git push upstream $1:refs/heads/$2" \
    "Then tag it on upstream once $2 has it, with NEWS.md's section below the subject if there is one:" \
    "  git fetch -q upstream +refs/heads/$2:refs/remotes/upstream/$2 &&"
}

git init -q -b main "$BUILD"
cd "$BUILD"
git config commit.gpgsign false
c() { # <file> <version> <subject> [<NEWS.md heading>]
  printf 'Package: duckdb\nVersion: %s\n' "$2" > DESCRIPTION
  [ -z "${4:-}" ] || printf '# duckdb (development version)\n\n# %s\n\n## Features\n\n- %s.\n\n# duckdb 2.0.0\n\n- Old.\n' "$4" "$1" > NEWS.md
  echo "$1" > "$1.txt"
  git add -A
  git commit -qm "$3"
  git rev-parse HEAD
}
C0=$(c seed 2.0.0.9000 "chore: seed" "duckdb 2.0.0.9000")
C1=$(c one 2.0.0.9000.1 "vendor: one")
C2=$(c two 2.0.0.9000.2 "vendor: two")
C3=$(c three 2.0.99.9000 "chore: Bump version to 2.0.99.9000" "duckdb 2.0.99.9000 (2026-11-21)")
git checkout -q -b beside "$C0"
X=$(c beside 2.0.0.9001 "fix: beside")
git checkout -q -b nonews "$C2"
N1=$(c three 2.0.99.9000 "chore: Bump version to 2.0.99.9000")
git checkout -q -b nosection "$C2"
N2=$(c three 2.0.99.9000 "chore: Bump version to 2.0.99.9000" "duckdb 2.0.99.9001")
git checkout -q -b line "$C0"
R1=$(c rone 2.0.0.9000.1 "vendor: one")
R2=$(c rbump 2.0.1 "chore: Bump version to 2.0.1" "duckdb 2.0.1")
git checkout -q main
git push -q "$CANON" "$C0:refs/heads/main" "$C0:refs/heads/v2.0-cyanoptera"
git push -q "$FORK" "$C0:refs/heads/main" "$C3:refs/heads/main-land-dev" "$C0:refs/heads/v2.0-cyanoptera" \
  "$R2:refs/heads/v2.0-cyanoptera-land-dev"
: "$C1" "$R1"

heads() { echo "$(git ls-remote "$CANON" refs/heads/main | cut -f1) $(git ls-remote "$FORK" refs/heads/main | cut -f1)"; }
tags() { echo "$(git ls-remote --refs "$CANON" 'refs/tags/*' | cut -f1 | tr '\n' ' ')/ $(git ls-remote --refs "$FORK" 'refs/tags/*' | cut -f1 | tr '\n' ' ')/ $(git -C "$WORK" tag | tr '\n' ' ')"; }
land() { (cd "$WORK" && "$SCRATCH/scripts/series-land-push.sh" "$@" 2>&1); }
section() { git show "$C3:NEWS.md" | awk '/^# duckdb 2.0.99.9000/ {f = 1; next} /^# duckdb / {f = 0} f'; }
ready "$C3" main

# --- 1. the remotes ----------------------------------------------------------
echo "1. the remotes"
git -C "$WORK" remote set-url origin https://github.com/someone/duckdb-r.git
st=0; out=$(land main --dry-run) || st=$?
is "another fork is refused" "$st" 1
has "  and named" "$out" "remote 'origin' is 'https://github.com/someone/duckdb-r.git', not github.com/krlmlr/duckdb-r"
git -C "$WORK" remote set-url origin git@github.com:krlmlr/duckdb-r.git
git -C "$WORK" remote set-url --push upstream git@github.com:krlmlr/duckdb-r.git
st=0; out=$(land main --dry-run) || st=$?
is "a push URL elsewhere is refused" "$st" 1
has "  and named" "$out" "remote 'upstream' pushes to 'git@github.com:krlmlr/duckdb-r.git'"
git -C "$WORK" config --unset remote.upstream.pushurl
git -C "$WORK" remote rename upstream canonical
st=0; out=$(land main --dry-run) || st=$?
is "a missing remote is refused" "$st" 1
has "  and named" "$out" "remote 'upstream' is 'missing'"
git -C "$WORK" remote rename canonical upstream
: > "$SCRATCH/status.log"
st=0; out=$(land main --dry-run) || st=$?
is "https for upstream and SSH for origin are accepted" "$st" 0
is "--status is asked of origin and upstream" "$(cat "$SCRATCH/status.log")" "main --status --remote origin --canonical upstream"
git -C "$WORK" config url."$FORK".insteadOf git@github.com:KrlMlr/DuckDB-R.git
git -C "$WORK" remote set-url origin git@github.com:KrlMlr/DuckDB-R.git
st=0; out=$(land main --dry-run) || st=$?
is "a URL in another letter case is accepted" "$st" 0
git -C "$WORK" remote set-url origin git@github.com:krlmlr/duckdb-r.git
git -C "$WORK" config --unset-all url."$FORK".insteadOf
git -C "$WORK" config url."$FORK".insteadOf git@github.com:krlmlr/duckdb-r.git

# --- 2. READY ----------------------------------------------------------------
echo "2. READY"
says 1 "main-land-dev: 2 of 3 commits above main-land-green passed" "NOT READY: the bump stamps v2.1.0-alpha1, but upstream's newest alpha is v2.1.0-alpha2"
st=0; out=$(land main --dry-run) || st=$?
is "NOT READY is refused" "$st" 1
has "  showing why" "$out" "  | NOT READY: the bump stamps"
has "  and saying so" "$out" "does not print READY; nothing is pushed"
says 0 "main-land-dev: 2 of 3 commits above main-land-green passed" "  first not passed: abc (pending)"
st=0; out=$(land main --dry-run) || st=$?
is "a pending landing is refused" "$st" 1
ready "$C3" main
st=0; out=$(land main --dry-run --sha "$C2") || st=$?
is "a --sha that is not READY's head is refused" "$st" 1
has "  and named" "$out" "is not the head READY names, $C3"
ready "$C2" main
st=0; out=$(land main --dry-run) || st=$?
is "a READY head that main-land-dev has left is refused" "$st" 1
has "  and named" "$out" "main-land-dev on origin is $C3, not READY's $C2"
ready "$C3" main
is "nothing moved" "$(heads)" "$C0 $C0"
is "temporary refs are gone afterwards" "$(git -C "$WORK" for-each-ref refs/series-land-push)" ""

# --- 3. the fork's branch ----------------------------------------------------
echo "3. the fork's branch"
git push -q -f "$FORK" "$X:refs/heads/main"
st=0; out=$(land main --dry-run) || st=$?
is "a head that does not fast-forward origin's main is refused" "$st" 1
has "  and named" "$out" "does not fast-forward main on origin"
git push -q -f "$FORK" "$C0:refs/heads/main"

# --- 4. the tag's prerequisites ----------------------------------------------
echo "4. the tag's prerequisites"
git push -q -f "$FORK" "$N1:refs/heads/main-land-dev"
ready "$N1" main
st=0; out=$(land main --dry-run) || st=$?
is "a landing that does not change NEWS.md is refused" "$st" 1
has "  and named" "$out" "does not change NEWS.md"
git push -q -f "$FORK" "$N2:refs/heads/main-land-dev"
ready "$N2" main
st=0; out=$(land main --dry-run) || st=$?
is "a NEWS.md without the version's section is refused" "$st" 1
has "  and named" "$out" "no section '# duckdb 2.0.99.9000'"
git push -q -f "$FORK" "$C3:refs/heads/main-land-dev"
ready "$C3" main
git tag -a v2.0.99.9000 -m "elsewhere" "$C2"
git push -q "$CANON" refs/tags/v2.0.99.9000
git tag -d v2.0.99.9000 >/dev/null
st=0; out=$(land main) || st=$?
is "a tag elsewhere on upstream is refused" "$st" 1
has "  and named" "$out" "v2.0.99.9000 on upstream is $C2, not an annotated tag of $C3"
is "  before anything moved" "$(heads)" "$C0 $C0"
git push -q "$CANON" :refs/tags/v2.0.99.9000
git push -q "$FORK" "$C3:refs/tags/v2.0.99.9000"
st=0; out=$(land main) || st=$?
is "a lightweight tag on origin is refused" "$st" 1
has "  and named" "$out" "v2.0.99.9000 on origin is a lightweight tag"
git push -q "$FORK" :refs/tags/v2.0.99.9000
git -C "$WORK" tag -a v2.0.99.9000 -m "here" "$C2"
st=0; out=$(land main) || st=$?
is "a local tag elsewhere is refused" "$st" 1
has "  and named" "$out" "the local tag v2.0.99.9000 is not an annotated tag of $C3"
git -C "$WORK" tag -d v2.0.99.9000 >/dev/null
is "  with nothing moved" "$(heads)" "$C0 $C0"

# --- 5. a dry run ------------------------------------------------------------
echo "5. a dry run"
st=0; out=$(land main --dry-run) || st=$?
is "succeeds" "$st" 0
has "prints the range" "$out" "$C0..$C3, 3 commits"
has "prints the tag's subject" "$out" "  | duckdb 2.0.99.9000"
has "and its section" "$out" "  | - three."
has "would push upstream" "$out" "would run: git push upstream $C3:refs/heads/main"
has "would push origin" "$out" "would run: git push origin $C3:refs/heads/main"
has "would tag" "$out" "would run: git tag -a v2.0.99.9000"
has "would push the tag" "$out" "would run: git push origin refs/tags/v2.0.99.9000:refs/tags/v2.0.99.9000"
is "nothing moved" "$(heads)" "$C0 $C0"
is "no tag anywhere" "$(tags)" "/ / "

# --- 6. a frozen branch ------------------------------------------------------
echo "6. a frozen branch"
touch "$SCRATCH/frozen-origin"
st=0; out=$(land main) || st=$?
rm "$SCRATCH/frozen-origin"
is "fails" "$st" 1
has "  naming the unfreeze" "$out" "origin refused the push; if main is frozen there, lift it first with 'scripts/series-unfreeze.sh main'"
is "  after upstream moved" "$(heads)" "$C3 $C0"
is "  and tags nothing" "$(tags)" "/ / "

# --- 7. the run --------------------------------------------------------------
echo "7. a run"
st=0; out=$(land main --sha "${C3:0:12}") || st=$?
is "succeeds" "$st" 0
has "  skipping upstream, which has it" "$out" "upstream: main is already at $C3"
is "moves main on both" "$(heads)" "$C3 $C3"
obj=$(git -C "$WORK" rev-parse -q --verify refs/tags/v2.0.99.9000 || true)
is "tags the head here" "$(git -C "$WORK" rev-parse -q --verify 'v2.0.99.9000^{commit}' || true)" "$C3"
is "  annotated" "$(git -C "$WORK" cat-file -t "${obj:-HEAD}" 2>/dev/null || true)" tag
is "  with the subject and the NEWS.md section" "$(git -C "$WORK" tag -l --format='%(contents)' v2.0.99.9000)" \
  "$(printf 'duckdb 2.0.99.9000\n\n%s\n' "$(section)" | git stripspace)"
is "  pushed to both as the same object" "$(tags)" "$obj / $obj / v2.0.99.9000 "
has "prints the confirmation" "$out" "$C3	refs/heads/main"
st=0; out=$(land main) || st=$?
is "a rerun succeeds" "$st" 0
has "  pushing no branch" "$out" "origin: main is already at $C3"
has "  and no tag" "$out" "origin: v2.0.99.9000 is already there"
git push -q "$FORK" :refs/tags/v2.0.99.9000
git -C "$WORK" tag -d v2.0.99.9000 >/dev/null
st=0; out=$(land main) || st=$?
is "a tag only upstream has" "$st" 0
is "  reaches origin as the same object" "$(tags)" "$obj / $obj / "

# --- 8. a release ------------------------------------------------------------
echo "8. a release"
ready "$R2" v2.0-cyanoptera
st=0; out=$(land v2.0-cyanoptera) || st=$?
is "lands" "$st" 0
is "  on both" "$(git ls-remote "$CANON" refs/heads/v2.0-cyanoptera | cut -f1) $(git ls-remote "$FORK" refs/heads/v2.0-cyanoptera | cut -f1)" "$R2 $R2"
is "  tagged .9900" "$(git ls-remote "$CANON" 'refs/tags/v2.0.1.9900^{}' | cut -f1) $(git ls-remote "$FORK" 'refs/tags/v2.0.1.9900^{}' | cut -f1)" "$R2 $R2"
is "  with that subject" "$(git -C "$WORK" tag -l --format='%(contents:subject)' v2.0.1.9900)" "duckdb 2.0.1.9900"
st=0; out=$(land feature) || st=$?
is "a series that is no line's is refused" "$st" 2

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
