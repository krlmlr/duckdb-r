#!/usr/bin/env bash
# Lift the freeze of a canonical branch on the canonical repository and the fork, before the landing's push
# (.claude/skills/series-land/SKILL.md, step 6): scripts/series-freeze.sh --unfreeze, whose header has the rest.
#
# Usage:
#   scripts/series-unfreeze.sh <B> [--remote upstream|origin] [--dry-run]
exec "$(dirname "$0")/series-freeze.sh" --unfreeze "$@"
