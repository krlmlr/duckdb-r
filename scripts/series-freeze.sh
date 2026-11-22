#!/usr/bin/env bash
# Freeze a canonical branch for a landing, or lift the freeze, on the canonical repository and the fork: the ruleset
# `freeze <B>` with no bypass list stops every update, pull requests and admins included
# (.claude/skills/series-land/SKILL.md, steps 1 and 6).
#
# Freezing creates the ruleset where the repository has none of that name, and otherwise writes the existing one
# whole, active, so that a freeze edited or disabled since is the freeze again: target the branch, enforcement
# `active`, no bypass actors, and the rules `update`, `deletion` and `non_fast_forward`. Unfreezing, which
# scripts/series-unfreeze.sh runs, disables it and deletes nothing, so the next freeze reuses it; where there is
# none, it has nothing to do. Each change is read back: the enforcement, and `never` for the caller's bypass.
# Only the repository's own rulesets count, never one an organization applies.
#
# Usage:
#   scripts/series-freeze.sh <B> [--remote upstream|origin] [--dry-run] [--unfreeze]
#   <B> is the branch, `main` or a release branch such as `v2.0-cyanoptera`.
#   --remote acts on one repository alone: `upstream` is duckdb/duckdb-r, `origin` krlmlr/duckdb-r; both by default.
#   --dry-run reads the rulesets and prints the writes it would make.
#
# scripts/series-freeze-test.sh runs this and scripts/series-unfreeze.sh against a stand-in for `gh`.

if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  echo "Error: $(basename "$0") needs bash 4 or newer, not ${BASH_VERSION:-this shell}; on macOS, install it with Homebrew" >&2
  exit 1
fi
set -euo pipefail
shopt -s inherit_errexit

usage="usage: $(basename "$0") <B> [--remote upstream|origin] [--dry-run]"
argerr() { echo "$usage" >&2; exit 2; }

only='' dry='' unfreeze=''
args=()
while [ $# -gt 0 ]; do
  case "$1" in
    --remote) [ $# -ge 2 ] || argerr; only=$2; shift 2 ;;
    --dry-run) dry=1; shift ;;
    --unfreeze) unfreeze=1; shift ;;
    -h | --help) echo "$usage"; exit 0 ;;
    -*) argerr ;;
    *) args+=("$1"); shift ;;
  esac
done
[ ${#args[@]} -eq 1 ] || argerr
B=${args[0]}
[[ $B =~ ^(main|v[0-9]+\.[0-9]+-[a-z]+)$ ]] || { echo "Error: not a branch a series lands on: '$B'" >&2; exit 2; }
case "$only" in
  '') remotes=(upstream origin) ;;
  upstream | origin) remotes=("$only") ;;
  *) argerr ;;
esac

repo_of() { # <remote>
  case "$1" in upstream) echo duckdb/duckdb-r ;; origin) echo krlmlr/duckdb-r ;; esac
}

body=$(cat <<JSON
{
  "name": "freeze $B",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {"ref_name": {"include": ["refs/heads/$B"], "exclude": []}},
  "rules": [
    {"type": "update", "parameters": {"update_allows_fetch_and_merge": false}},
    {"type": "deletion"},
    {"type": "non_fast_forward"}
  ]
}
JSON
)

for r in "${remotes[@]}"; do
  repo=$(repo_of "$r")
  found=$(gh api --paginate "repos/$repo/rulesets?includes_parents=false" \
    --jq ".[] | select(.source_type == \"Repository\" and .name == \"freeze $B\") | \"\(.id) \(.enforcement)\"")
  [ "$(grep -c . <<<"$found" || true)" -le 1 ] ||
    { echo "Error: $repo has more than one ruleset named 'freeze $B': ${found//$'\n'/, }" >&2; exit 1; }
  id=${found%% *} state=${found#* }
  if [ -n "$unfreeze" ]; then
    if [ -z "$found" ]; then echo "$r ($repo): no freeze of $B"; continue; fi
    if [ "$state" = disabled ]; then echo "$r ($repo): freeze $B ($id) is already lifted"; continue; fi
    echo "$r ($repo): lifting freeze $B ($id)"
    [ -n "$dry" ] && { echo "  would run: gh api -X PUT repos/$repo/rulesets/$id -f enforcement=disabled"; continue; }
    gh api -X PUT "repos/$repo/rulesets/$id" -f enforcement=disabled --silent
    want=disabled
  else
    if [ -z "$found" ]; then
      echo "$r ($repo): creating freeze $B"
      [ -n "$dry" ] && { echo "  would run: gh api -X POST repos/$repo/rulesets --input -"; continue; }
      id=$(gh api -X POST "repos/$repo/rulesets" --input - --jq .id <<<"$body")
    else
      echo "$r ($repo): writing freeze $B ($id, $state) whole, active"
      [ -n "$dry" ] && { echo "  would run: gh api -X PUT repos/$repo/rulesets/$id --input -"; continue; }
      gh api -X PUT "repos/$repo/rulesets/$id" --input - --silent <<<"$body"
    fi
    want=active
  fi
  read -r got bypass < <(gh api "repos/$repo/rulesets/$id" --jq '[.enforcement, .current_user_can_bypass] | @tsv')
  [ "$got" = "$want" ] || { echo "Error: freeze $B ($id) on $repo reads back as '$got', not $want" >&2; exit 1; }
  [ "$want" = disabled ] || [ "$bypass" = never ] ||
    { echo "Error: freeze $B ($id) on $repo lets the caller bypass it: '$bypass'" >&2; exit 1; }
  echo "  $want"
done
