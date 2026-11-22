#!/usr/bin/env bash
# Fast-forward a landing's branch onto `<L>-land-dev` in both repositories, with one command run by the maintainer
# (.claude/skills/series-land/SKILL.md, step 6).
#
# The fast-forward is the one write a landing makes outside the fork's pull requests, and the maintainer makes it
# from his own checkout. That checkout need not hold the landing nor name the repositories as remotes, so every ref
# is addressed by URL and fetched into temporary refs under refs/series-land-push/, deleted on exit:
#
#   1. Fetch `<L>-land-dev` from the fork and `<B>` from the canonical repository and the fork. The landing head is
#      the fork's `<L>-land-dev` tip, or the commit --sha names, which must be on it. It must descend from both `<B>`
#      tips, or nothing is pushed; the range above the canonical `<B>` and its count are printed.
#   2. Check what `series-land.sh <L> --status` checks before it prints READY, and refuse otherwise: the landing head
#      is the `<L>-land-dev` tip; above `<B>` it is the base's own commits, then `vendor:` commits, then the version
#      bump `chore: Bump version to <version>` last and nowhere else; and every commit of that range has a `success`
#      record on the fork's `rcc2` store. The bump's alpha stamp is not checked here, nor the copied `each-rcc (fork)`
#      statuses step 6 reads on the landing's pull request. --no-check skips this step, for a store that cannot be
#      fetched or a --sha below the tip; `--status` is then the check, read beforehand.
#   3. For the canonical repository, then the fork, unless `<B>` is already the landing head there: disable an active
#      repository ruleset named `freeze <B>`, push `<sha>:refs/heads/<B>`, a plain push that git refuses unless it fast-forwards,
#      and enable the ruleset again. A trap enables it on the way out too, whether the push succeeded or not.
#   4. Copy the version tag: `v<version>` of DESCRIPTION at the landing head, `v<version>.9900` for a release's version
#      (handbook/operations/releases/versioning/README.md). If the fork has it, pointing at the landing head, the same
#      annotated tag object is pushed to the canonical repository; a lightweight tag is refused. If not, nothing is tagged here: the command that
#      dispatches tag-version.yaml in the fork is printed, and a rerun of this script, which then pushes no branch,
#      copies the tag.
#   5. Print `git ls-remote` of both `<B>` refs and of the tag.
#
# --dry-run fetches into the temporary refs and runs every check, reads the rulesets, and prints the writes it would
# make in place of making them.
#
# Usage:
#   scripts/series-land-push.sh <L> [--onto <B>] [--sha <sha>] [--dry-run] [--no-check]
#   <L> is the series that lands, `main` or `v2.0-cyanoptera`, whose `<L>-land-dev` is on the fork.
#   --onto names the branch it lands on, its `releases_from`, by default <L> itself.
#
# Environment variables:
#   SERIES_LAND_PUSH_CANONICAL_URL - default git@github.com:duckdb/duckdb-r.git
#   SERIES_LAND_PUSH_FORK_URL      - default git@github.com:krlmlr/duckdb-r.git
#   SERIES_LAND_PUSH_CANONICAL     - the canonical repository for `gh api`, default duckdb/duckdb-r
#   SERIES_LAND_PUSH_FORK          - the fork for `gh api`, default krlmlr/duckdb-r
#   RCC_BRANCH                     - the store's branch, default rcc2
# scripts/series-land-push-test.sh runs this against local bare repositories and a stand-in for `gh`.
#
# It runs under bash 3.2, macOS's /bin/bash: no `inherit_errexit`, associative arrays or `mapfile`, and `sed -E`.
#
# Nothing here locks out a concurrent writer: between the fast-forward check and the push, a push by someone else to
# `<B>` is refused by the freeze, or, while it is lifted, makes this plain push fail rather than overwrite it.

set -euo pipefail

usage='usage: series-land-push.sh <L> [--onto <B>] [--sha <sha>] [--dry-run] [--no-check]'
argerr() { echo "$usage" >&2; exit 2; }

onto='' want='' dry='' check=1
args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --onto) [ $# -ge 2 ] || argerr; onto=$2; shift 2 ;;
    --sha) [ $# -ge 2 ] || argerr; want=$2; shift 2 ;;
    --dry-run) dry=1; shift ;;
    --no-check) check=''; shift ;;
    -h | --help) echo "$usage"; exit 0 ;;
    -*) argerr ;;
    *) args+=("$1"); shift ;;
  esac
done
[ ${#args[@]} -eq 1 ] || argerr
L=${args[0]}
B=${onto:-$L}
for b in "$L" "$B"; do
  [[ $b =~ ^(main|v[0-9]+\.[0-9]+-[a-z]+)$ ]] || { echo "Error: not a serving series or its branch: '$b'" >&2; exit 2; }
done

canon_url=${SERIES_LAND_PUSH_CANONICAL_URL:-git@github.com:duckdb/duckdb-r.git}
fork_url=${SERIES_LAND_PUSH_FORK_URL:-git@github.com:krlmlr/duckdb-r.git}
canon_repo=${SERIES_LAND_PUSH_CANONICAL:-duckdb/duckdb-r}
fork_repo=${SERIES_LAND_PUSH_FORK:-krlmlr/duckdb-r}
rcc=${RCC_BRANCH:-rcc2}

git rev-parse --git-dir >/dev/null
tmp=refs/series-land-push
restore=()   # "<repo> <ruleset id>" of every freeze lifted and not yet put back

enable() { # <repo> <id>
  gh api -X PUT "repos/$1/rulesets/$2" -f enforcement=active --silent
}
cleanup() {
  local r failed=''
  # A second Ctrl-C must not skip the restore.
  trap '' INT TERM
  for r in ${restore[@]+"${restore[@]}"}; do
    # shellcheck disable=SC2086
    enable $r || { failed=1; echo "Error: could not enable ruleset ${r#* } on ${r%% *} again; enable it by hand" >&2; }
  done
  git for-each-ref --format='delete %(refname)' "$tmp/" | git update-ref --stdin 2>/dev/null || true
  [ -z "$failed" ]
}
trap cleanup EXIT
trap 'exit 130' INT TERM

run() { # <command>...: run it, or print it on a dry run
  if [ -n "$dry" ]; then echo "  would run: $*"; else "$@"; fi
}

# --- 1. the refs, and the fast-forward ---------------------------------------
git fetch -q --no-tags "$fork_url" "+refs/heads/$L-land-dev:$tmp/land-dev" "+refs/heads/$B:$tmp/fork"
git fetch -q --no-tags "$canon_url" "+refs/heads/$B:$tmp/canonical"
dev=$(git rev-parse "$tmp/land-dev")
if [ -n "$want" ]; then
  sha=$(git rev-parse -q --verify "$want^{commit}") ||
    { echo "Error: $want is not a commit on $L-land-dev ($fork_url)" >&2; exit 1; }
  git merge-base --is-ancestor "$sha" "$dev" ||
    { echo "Error: $want is not on $L-land-dev, which is at $dev" >&2; exit 1; }
  [ "$sha" = "$dev" ] || echo "Note: $L-land-dev has moved above $sha, to $dev; pushing $sha"
else
  sha=$dev
fi
canon=$(git rev-parse "$tmp/canonical")
fork=$(git rev-parse "$tmp/fork")
for side in canonical fork; do
  git merge-base --is-ancestor "$tmp/$side" "$sha" ||
    { echo "Error: $sha does not fast-forward $B on the $side repository ($(git rev-parse "$tmp/$side"))" >&2; exit 1; }
done
n=$(git rev-list --count "$canon..$sha")
echo "Landing $L onto $B: $canon..$sha, $n commits"
git log --oneline --first-parent -n 3 "$canon..$sha" | sed 's/^/  /'
[ "$n" -le 3 ] || echo "  ..."

# --- 2. every commit passed --------------------------------------------------
if [ -n "$check" ]; then
  [ "$sha" = "$dev" ] ||
    { echo "Error: $sha is not the $L-land-dev tip $dev; --no-check pushes it once --status has printed READY for it" >&2; exit 1; }
  # The shape out_of_place in scripts/series-land.sh accepts, with the `vendor:` prefix of scripts/series-lib.sh.
  bump_subject='chore: Bump version to '
  seen='' last=''
  while IFS=' ' read -r c subj; do
    [ -z "$last" ] || { echo "Error: $L-land-dev carries a commit after the version bump: $c $subj" >&2; exit 1; }
    case "$subj" in
      vendor:*) seen=1 ;;
      "$bump_subject"*)
        [ -n "$seen" ] || { echo "Error: the version bump $c has no vendor commit under it" >&2; exit 1; }
        last=1 ;;
      *) [ -z "$seen" ] || { echo "Error: $L-land-dev carries a commit out of place: $c $subj" >&2; exit 1; } ;;
    esac
  done < <(git log --reverse --first-parent --format='%h %s' "$canon..$sha")
  # Once `<B>` is the bump, a rerun only copies the tag, as --status prints READY again then.
  [ -n "$last" ] || [ "$canon" = "$sha" ] || { echo "Error: $L-land-dev does not end on the version bump" >&2; exit 1; }
  git fetch -q --no-tags "$fork_url" "+refs/heads/$rcc:$tmp/rcc"
  bad=0
  while IFS= read -r c; do
    st=$(git show "$tmp/rcc:runs2.d/${c:0:2}/$c.ndjson" 2>/dev/null |
      sed -nE 's/.*"status":[^}]*"state": *"([a-z]+)".*/\1/p' | head -n 1 || true)
    [ "$st" = success ] || { bad=$((bad + 1)); [ "$bad" -gt 5 ] || echo "  not passed: ${c:0:10} (${st:-missing})" >&2; }
  done < <(git rev-list --first-parent "$canon..$sha")
  [ "$bad" -eq 0 ] ||
    { echo "Error: $bad of $n commits have no success record on $rcc; read 'scripts/series-land.sh $L --status'" >&2; exit 1; }
  echo "All $n commits passed on $rcc, and $L-land-dev ends on its version bump."
else
  echo "Not checked: the records on $rcc; 'scripts/series-land.sh $L --status' must have printed READY for $sha."
fi

# --- 3. the fast-forward, with the freeze lifted -----------------------------
push_branch() { # <repo> <url> <current>
  local repo=$1 url=$2 cur=$3 ids id
  if [ "$cur" = "$sha" ]; then echo "$repo: $B is already at $sha"; return; fi
  ids=$(gh api --paginate "repos/$repo/rulesets?includes_parents=false" \
    --jq ".[] | select(.source_type == \"Repository\" and .name == \"freeze $B\" and .enforcement == \"active\") | .id")
  [[ $ids =~ ^[0-9]*$ ]] || { echo "Error: more than one active freeze ruleset for $B on $repo: $ids" >&2; exit 1; }
  for id in $ids; do
    echo "$repo: lifting ruleset $id, freeze $B"
    # Recorded first: a disable GitHub applied but gh reports as failed is restored all the same.
    [ -n "$dry" ] || restore+=("$repo $id")
    run gh api -X PUT "repos/$repo/rulesets/$id" -f enforcement=disabled --silent
  done
  echo "$repo: $B ${cur:0:10} -> ${sha:0:10}"
  run git push "$url" "$sha:refs/heads/$B"
  for id in $ids; do
    echo "$repo: restoring ruleset $id, freeze $B"
    run gh api -X PUT "repos/$repo/rulesets/$id" -f enforcement=active --silent
    restore=()
  done
}
push_branch "$canon_repo" "$canon_url" "$canon"
push_branch "$fork_repo" "$fork_url" "$fork"

# --- 4. the tag --------------------------------------------------------------
v=$(git show "$sha:DESCRIPTION" | sed -n 's/^Version: *//p' | tr -d '\r')
t=v$v
[[ ! $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || t=v$v.9900
if [ -n "$(git ls-remote "$fork_url" "refs/tags/$t")" ]; then
  git fetch -q --no-tags "$fork_url" "+refs/tags/$t:$tmp/tag"
  [ "$(git cat-file -t "$tmp/tag")" = tag ] ||
    { echo "Error: $t on the fork is a lightweight tag; tag-version.yaml writes an annotated one" >&2; exit 1; }
  [ "$(git rev-parse "$tmp/tag^{commit}")" = "$sha" ] ||
    { echo "Error: $t on the fork points at $(git rev-parse "$tmp/tag^{commit}"), not $sha" >&2; exit 1; }
  obj=$(git rev-parse "$tmp/tag")
  have=$(git ls-remote "$canon_url" "refs/tags/$t" | cut -f1)
  if [ "$have" = "$obj" ]; then
    echo "$canon_repo: $t is already there"
  elif [ -n "$have" ]; then
    echo "Error: $t on $canon_repo is $have, not the fork's $obj" >&2; exit 1
  else
    echo "$canon_repo: copying $t ($obj) from the fork"
    run git push "$canon_url" "$obj:refs/tags/$t"
  fi
else
  echo "The fork has no $t; nothing is tagged here. Tag it in the fork, then rerun this script to copy the tag:"
  echo "  gh workflow run tag-version.yaml --repo $fork_repo --ref $B -f commit=$sha"
  echo "  (until tag-version.yaml is on $B, --ref names a branch that carries it)"
fi

# --- 5. what the repositories hold now ---------------------------------------
if [ -n "$dry" ]; then echo "Dry run: nothing was written. Now:"; fi
for u in "$canon_url" "$fork_url"; do
  echo "$u:"
  git ls-remote "$u" "refs/heads/$B" "refs/tags/$t" "refs/tags/$t^{}" | sed 's/^/  /'
done
