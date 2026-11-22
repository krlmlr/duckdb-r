#!/usr/bin/env bash
# Fast-forward a READY landing's branch on `upstream` and `origin`, and tag it from NEWS.md, with one command run by
# the maintainer (.claude/skills/series-land/SKILL.md, step 6).
#
# The fast-forward is the one write a landing makes outside the fork's pull requests, and the maintainer makes it
# from his own checkout, whose remotes `origin` and `upstream` must be the fork, krlmlr/duckdb-r, and the canonical
# repository, duckdb/duckdb-r, over https or SSH. The freeze is not this script's: scripts/series-unfreeze.sh lifts
# it beforehand, and a push it still refuses fails the run, which names that script.
#
#   1. Run `scripts/series-land.sh <L> --status` against those remotes, and refuse unless it prints READY. That is
#      every check the landing has before its push: every commit passed, the landing's shape and its bump, the base
#      it stands on, and the bump's alpha stamp against upstream's pointer, which reads the network. The head and the
#      branch `<B>` it lands on are the ones its push line names; --sha, if given, must be that head.
#   2. Fetch `<B>` from `origin` into a temporary ref, deleted on exit: the head must fast-forward it there too.
#   3. Prepare the tag, and refuse before anything is pushed if it cannot be made: the annotated tag `v<version>` of
#      DESCRIPTION's version at the head, `v<version>.9900` for a release's version, with the message
#      `duckdb <tag version>`, a blank line, and the section `# duckdb <version>` of NEWS.md at the head, read the way
#      series-land.sh's tag commands read it (handbook/operations/releases/versioning/README.md). The landing must
#      change NEWS.md, unless `<B>` on `upstream` is the head already, and the section must not be empty. A tag of
#      that name on either remote, or in the checkout, must be an annotated tag of the head.
#   4. Push `<sha>:refs/heads/<B>` to `upstream`, then to `origin`, each skipped where `<B>` is the head already: a
#      plain push, which git refuses unless it fast-forwards.
#   5. Once both have `<B>` at the head, create the tag in the checkout, or take the one a remote or the checkout has
#      already, and push that same tag object to each remote that lacks it.
#   6. Print `git ls-remote` of both `<B>` refs and of the tag.
#
# --dry-run runs every check, prints the tag's message, and prints the writes it would make in place of making them;
# `--status` itself fetches into the remote-tracking refs as it always does. A rerun after a failure picks up where
# it stopped.
#
# Usage:
#   scripts/series-land-push.sh <L> [--sha <sha>] [--dry-run]
#   <L> is the series that lands, `main` or `v2.0-cyanoptera`, whose `<L>-land-dev` is on `origin`.
#
# scripts/series-land-push-test.sh runs this in a checkout whose remotes' URLs git rewrites to local bare
# repositories (`url.<path>.insteadOf`), with a stand-in for series-land.sh beside it.
#
# Nothing here locks out a concurrent writer: a push to `<B>` by someone else between the check and the push makes
# this plain push fail rather than overwrite it.

if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ] || { [ "${BASH_VERSINFO[0]}" -eq 4 ] && [ "${BASH_VERSINFO[1]}" -lt 4 ]; }; then
  echo "Error: series-land-push.sh needs bash 4.4 or newer, not ${BASH_VERSION:-this shell}; on macOS, install it with Homebrew" >&2
  exit 1
fi
set -euo pipefail
shopt -s inherit_errexit

usage='usage: series-land-push.sh <L> [--sha <sha>] [--dry-run]'
argerr() { echo "$usage" >&2; exit 2; }

want='' dry=''
args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --sha) [ $# -ge 2 ] || argerr; want=$2; shift 2 ;;
    --dry-run) dry=1; shift ;;
    -h | --help) echo "$usage"; exit 0 ;;
    -*) argerr ;;
    *) args+=("$1"); shift ;;
  esac
done
[ ${#args[@]} -eq 1 ] || argerr
L=${args[0]}
[[ $L =~ ^(main|v[0-9]+\.[0-9]+-[a-z]+)$ ]] || { echo "Error: not a serving series: '$L'" >&2; exit 2; }

# Is each remote's URL, and its push URL if it has one, the repository it must be? Read as configured, before git
# rewrites it, in the https or SSH form, in any letter case.
remote_is() { # <remote> <owner/repo>
  local u re="^(https://github\.com/|git@github\.com:|ssh://git@github\.com/)$2(\.git)?/?$"
  u=$(git config --get "remote.$1.url" || true)
  [[ ${u,,} =~ $re ]] || { echo "Error: remote '$1' is '${u:-missing}', not github.com/$2" >&2; return 1; }
  for u in $(git config --get-all "remote.$1.pushurl" || true); do
    [[ ${u,,} =~ $re ]] || { echo "Error: remote '$1' pushes to '$u', not github.com/$2" >&2; return 1; }
  done
}
git rev-parse --git-dir >/dev/null
remote_is upstream duckdb/duckdb-r
remote_is origin krlmlr/duckdb-r

tmp=refs/series-land-push
trap 'git for-each-ref --format="delete %(refname)" "$tmp/" | git update-ref --stdin 2>/dev/null || true' EXIT

run() { # <command>...: run it, or print it on a dry run
  if [ -n "$dry" ]; then echo "  would run: $*"; else "$@"; fi
}

# --- 1. READY ----------------------------------------------------------------
st=0
status=$("$(dirname "$0")/series-land.sh" "$L" --status --remote origin --canonical upstream 2>&1) || st=$?
push_re='^  git push upstream ([0-9a-f]{40}):refs/heads/(main|v[0-9]+\.[0-9]+-[a-z]+)$'
sha='' B=''
while IFS= read -r line; do
  [[ $line =~ $push_re ]] && { sha=${BASH_REMATCH[1]}; B=${BASH_REMATCH[2]}; break; }
done <<<"$status"
if [ "$st" -ne 0 ] || ! grep -q '^READY' <<<"$status" || [ -z "$sha" ]; then
  # Its own words first, the last of them where it said much, so that an error of its own is not hidden.
  printf '%s\n' "$status" | tail -n 20 | sed 's/^/  | /' >&2
  echo "Error: 'scripts/series-land.sh $L --status' does not print READY (exit status $st); nothing is pushed" >&2
  exit 1
fi
printf '%s\n' "$status" | sed -n '1,/^READY/p' | sed 's/^/  | /'

# --- 2. the fork's branch ----------------------------------------------------
git fetch -q --no-tags upstream "+refs/heads/$B:$tmp/upstream"
git fetch -q --no-tags origin "+refs/heads/$B:$tmp/origin" "+refs/heads/$L-land-dev:$tmp/land-dev"
[ "$(git rev-parse "$tmp/land-dev")" = "$sha" ] ||
  { echo "Error: $L-land-dev on origin is $(git rev-parse "$tmp/land-dev"), not READY's $sha; read --status again" >&2; exit 1; }
if [ -n "$want" ]; then
  [ "$(git rev-parse -q --verify "$want^{commit}" 2>/dev/null || true)" = "$sha" ] ||
    { echo "Error: $want is not the head READY names, $sha; read --status again" >&2; exit 1; }
fi
canon=$(git rev-parse "$tmp/upstream")
fork=$(git rev-parse "$tmp/origin")
for side in upstream origin; do
  git merge-base --is-ancestor "$tmp/$side" "$sha" ||
    { echo "Error: $sha does not fast-forward $B on $side ($(git rev-parse "$tmp/$side"))" >&2; exit 1; }
done
echo "Landing $L onto $B: $canon..$sha, $(git rev-list --count "$canon..$sha") commits"

# --- 3. the tag, prepared before anything is pushed --------------------------
v=$(git show "$sha:DESCRIPTION" | tr -d '\r' | sed -n 's/^Version: *//p')
[[ $v =~ ^[0-9]+(\.[0-9]+){2,4}$ ]] || { echo "Error: DESCRIPTION at $sha has no version: '$v'" >&2; exit 1; }
tv=$v
[[ ! $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || tv=$v.9900
t=v$tv
if [ "$canon" != "$sha" ] && git diff --quiet "$canon" "$sha" -- NEWS.md; then
  echo "Error: the landing does not change NEWS.md, which the tag's message is read from" >&2; exit 1
fi
section=$(git show "$sha:NEWS.md" 2>/dev/null | tr -d '\r' |
  awk -v h="# duckdb $v" 'index($0, h) == 1 && ($0 == h || substr($0, length(h) + 1, 1) == " ") {f = 1; next} /^# duckdb / {f = 0} f')
[ -n "$(tr -d '[:space:]' <<<"$section")" ] ||
  { echo "Error: NEWS.md at $sha has no section '# duckdb $v' for the tag's message" >&2; exit 1; }
message=$(printf 'duckdb %s\n\n%s\n' "$tv" "$section")

# Where the tag stands now: <remote>'s tag object, or empty. A tag that is not an annotated tag of the head is refused.
tag_on() { # <remote>
  local lines obj peeled
  lines=$(git ls-remote "$1" "refs/tags/$t" "refs/tags/$t^{}")
  obj=$(awk -v r="refs/tags/$t" '$2 == r { print $1 }' <<<"$lines")
  peeled=$(awk -v r="refs/tags/$t^{}" '$2 == r { print $1 }' <<<"$lines")
  [ -n "$obj" ] || return 0
  [ "$peeled" = "$sha" ] ||
    { echo "Error: $t on $1 is ${peeled:-a lightweight tag of $obj}, not an annotated tag of $sha" >&2; return 1; }
  echo "$obj"
}
canon_tag=$(tag_on upstream)
fork_tag=$(tag_on origin)
local_tag=$(git rev-parse -q --verify "refs/tags/$t" || true)
if [ -n "$local_tag" ]; then
  # shellcheck disable=SC2015
  [ "$(git cat-file -t "$local_tag")" = tag ] && [ "$(git rev-parse "$local_tag^{commit}")" = "$sha" ] ||
    { echo "Error: the local tag $t is not an annotated tag of $sha; delete it with 'git tag -d $t'" >&2; exit 1; }
fi
tag_obj=''
for o in "$canon_tag" "$fork_tag" "$local_tag"; do
  [ -z "$o" ] || [ -z "$tag_obj" ] || [ "$o" = "$tag_obj" ] ||
    { echo "Error: $t differs between upstream (${canon_tag:-none}), origin (${fork_tag:-none}) and here (${local_tag:-none})" >&2; exit 1; }
  [ -n "$tag_obj" ] || tag_obj=$o
done
if [ -n "$tag_obj" ]; then
  echo "Tag $t: $tag_obj, as it already stands"
else
  echo "Tag $t, with the message:"
  printf '%s\n' "$message" | sed 's/^/  | /'
fi

# --- 4. the fast-forward -----------------------------------------------------
push_branch() { # <remote> <current>
  if [ "$2" = "$sha" ]; then echo "$1: $B is already at $sha"; return; fi
  echo "$1: $B ${2:0:10} -> ${sha:0:10}"
  run git push "$1" "$sha:refs/heads/$B" ||
    { echo "Error: $1 refused the push; if $B is frozen there, lift it first with 'scripts/series-unfreeze.sh $B'" >&2; exit 1; }
}
push_branch upstream "$canon"
push_branch origin "$fork"

# --- 5. the tag, once both branches have the head ----------------------------
src=refs/tags/$t
if [ -z "$tag_obj" ]; then
  if [ -n "$dry" ]; then
    echo "  would run: git tag -a $t --cleanup=whitespace -F - $sha"
  else
    printf '%s\n' "$message" | git tag -a "$t" --cleanup=whitespace -F - "$sha"
    echo "Tagged $t: $(git rev-parse "refs/tags/$t")"
  fi
elif [ -z "$local_tag" ]; then
  # A tag only a remote has: fetched into a temporary ref, and the same object pushed from there.
  from=origin
  [ -z "$canon_tag" ] || from=upstream
  git fetch -q --no-tags "$from" "+refs/tags/$t:$tmp/tag"
  src=$tmp/tag
fi
for r in upstream origin; do
  if [ "$r" = upstream ]; then have=$canon_tag; else have=$fork_tag; fi
  if [ -n "$have" ]; then echo "$r: $t is already there"; else run git push "$r" "$src:refs/tags/$t"; fi
done

# --- 6. what the repositories hold now ---------------------------------------
if [ -n "$dry" ]; then echo "Dry run: nothing was pushed. Now:"; fi
for r in upstream origin; do
  echo "$r ($(git config --get "remote.$r.url")):"
  git ls-remote "$r" "refs/heads/$B" "refs/tags/$t" "refs/tags/$t^{}" | sed 's/^/  /'
done
