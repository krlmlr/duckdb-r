Scheduled job: advance every **green** `broken-<sha>-dev` branch in
`krlmlr/duckdb-r` by cherry-picking the next batch (default 30) of commits from
its corresponding non-broken `*-dev` branch. "Green" means the branch tip's
`rcc` commit-status (set by the "Smoke test: stock R" job in the `rcc`
workflow) is `success`. The corresponding `*-dev` branch is found **by the
vendored upstream commit**: the branch whose history contains a vendor commit
referencing the same `duckdb/duckdb@<sha>` that the broken tip vendors — not by
merge distance and not by the SHA embedded in the broken branch name.

This is the catch-up counterpart to `rcc-smoke-fix.md`. That skill *creates and
repairs* `broken-<sha>-dev` branches from the earliest failing commit; this one
keeps an already-repaired (green) `broken-<sha>-dev` branch moving forward,
batch by batch, until it either catches up with its parent `*-dev` line or hits
a commit that breaks `rcc` (at which point `rcc-smoke-fix.md` takes over,
because the tip is no longer green and this skill skips it).

Skip a branch when:
  * its tip's `rcc` status is not `success` (failing/pending — leave it to
    `rcc-smoke-fix.md`);
  * its tip is already fully contained in (an ancestor of) some non-broken
    `*-dev` branch — it has been promoted upstream, nothing to advance;
  * no non-broken `*-dev` branch vendors the same `duckdb/duckdb@<sha>` as the
    tip — the link can't be established;
  * the branch is already up to date with its corresponding `*-dev` branch
    (no commits remain after the matching vendor commit).

Cherry-pick conflicts are not expected here: the carried commits are
overwhelmingly vendor snapshots that apply cleanly by construction. If one does
conflict, **abort and report** — do not resolve or `--skip`. A conflict means
the upstream `*-dev` line diverged from the broken line in a way this mechanical
catch-up cannot safely reconcile; hand it to a human / `rcc-smoke-fix.md`.

---

<!--
## Operation essence (read this first)

Why this skill exists.
  The DuckDB C++ core is vendored hourly into `src/duckdb/` from
  `duckdb/duckdb` (one upstream branch per `*-dev` line — `main` for
  `main-dev`, `v1.5-variegata` for `v1.5-variegata-dev`, `v1.4-andium` for
  `v1.4-andium-dev`). When a vendor commit breaks the R package,
  `rcc-smoke-fix.md` forks a `broken-<sha>-dev` branch, repairs the failing
  commit, and cherry-picks the then-remaining commits on top. Time passes; the
  parent `*-dev` line keeps receiving new hourly vendor commits. The repaired
  `broken-<sha>-dev` branch then lags behind. This skill closes that gap: it
  takes a green `broken-<sha>-dev` tip and replays the next slice of its
  parent's history onto it.

The matching rule (the crux).
  A `broken-<sha>-dev` branch is a parallel re-vendoring of one upstream
  `*-dev` line, so its commit SHAs do NOT match the parent's. The durable link
  between the two lines is the **upstream duckdb commit they vendor**. Every
  catch-up step is anchored on it:
    1. Read the duckdb SHA the broken tip vendors (`duckdb/duckdb@<DUCK>` in the
       latest `vendor: Update vendored sources ...` commit reachable from the
       tip).
    2. Find the non-broken `*-dev` branch whose history has a vendor commit for
       the same `<DUCK>`. That commit `V` is the broken tip's mirror point on
       the parent line.
    3. The work to carry forward is the commits that come after `V` on that
       `*-dev` branch (capped at the batch size).
  The SHA embedded in the branch name (`broken-<sha>-dev`) is the originally
  failing commit; it is NOT used for matching here and is often no longer
  reachable from any current `*-dev` branch.

End-to-end workflow.
  1. Refresh `krlmlr/*` remote-tracking refs from scratch (dev branches are
     force-pushed; cached state is suspect).
  2. Enumerate non-broken `*-dev` branches and `broken-*-dev` branches.
  3. For each `broken-*-dev` branch, gate on tip `rcc` == success, on
     not-already-contained-upstream, and on a vendored-commit match to a parent
     `*-dev` branch.
  4. Compute the next BATCH commits after the mirror point `V` on the parent.
  5. Dry-run: cherry-pick them onto the tip in a DETACHED HEAD; require a clean
     apply. Only then move the branch ref to the verified tip and push.
  6. Report a per-branch summary.

Why a bounded batch.
  Keeping each run to BATCH (default 30) commits bounds the work, keeps the push
  reviewable, and lets `each.yaml` run per-commit CI on the newly pushed
  commits before the next scheduled run continues from the new tip. Across runs
  the branch advances incrementally. If a carried commit breaks `rcc`, the tip
  stops being green and this skill steps aside on the next run.

Environment assumptions (current).
  * R 4.x and standard tooling (git, `jq`, optionally `gh`) are pre-installed.
    This skill does NOT build the package — it is purely a git/CI operation.
  * GitHub Actions results are available on the **orphan branch `rcc`** in
    `krlmlr/duckdb-r` (no token required): `runs2.ndjson` holds one
    `{commit, status, run}` record per line keyed by commit SHA. Use it for the
    tip `rcc`-status gate, exactly as `rcc-smoke-fix.md` does. Fall back to `gh`
    only when a SHA is absent and `gh auth status` succeeds; a GitHub MCP tool
    may be used when the agent provides one.
-->

---

## Step 1 — Refresh local mirror of krlmlr/duckdb-r (always, force-reset)

```bash
if ! git remote get-url krlmlr &>/dev/null 2>&1; then
  git remote add krlmlr https://github.com/krlmlr/duckdb-r.git
fi
# Hard-reset: throw away any cached remote-tracking state
git fetch krlmlr --force --prune --tags
```

## Step 2 — Enumerate non-broken `*-dev` and `broken-*-dev` branches

```bash
# Non-broken parents: every krlmlr branch ending in -dev that is NOT broken-*.
NONBROKEN_DEV=$(git branch -r \
  | grep -oP 'krlmlr/\K\S+' \
  | grep -E '\-dev$' \
  | grep -vE '^broken-' \
  | sort)

# The branches this skill advances.
BROKEN_DEV=$(git branch -r \
  | grep -oP 'krlmlr/\K\S+' \
  | grep -E '^broken-.*-dev$' \
  | sort)

echo "=== Non-broken *-dev ===" && echo "$NONBROKEN_DEV"
echo "=== broken-*-dev ==="      && echo "$BROKEN_DEV"
```

## Step 3 — `rcc`-status helper (shared with `rcc-smoke-fix.md`)

Cache the orphan-branch run index once; look up a commit's `rcc` conclusion
from it, falling back to `gh` only when the SHA is absent and `gh` is
authenticated. Do not use `curl` or inspect environment variables.

```bash
git fetch krlmlr rcc
RCC_NDJSON=$(git show krlmlr/rcc:runs2.ndjson 2>/dev/null || true)
GH_OK=0; gh auth status &>/dev/null && GH_OK=1
REPO="krlmlr/duckdb-r"

lookup_rcc_status() {
  local sha="$1" conclusion
  conclusion=$(jq -r --arg sha "$sha" \
    'select(.commit == $sha) | .run.conclusion // empty' \
    <<< "$RCC_NDJSON" | head -1)
  [[ -n "$conclusion" ]] && { echo "$conclusion"; return; }
  if [[ "$GH_OK" == "1" ]]; then
    gh api "repos/$REPO/commits/$sha/statuses" \
      | jq -r '[.[] | select(.context == "rcc")] | first | .state // "none"'
  else
    echo "none"
  fi
}
```

## Step 4 — For each `broken-*-dev` branch, decide and advance

`BATCH` is the number of commits carried per run. Process each branch
independently; a skip/abort on one must not stop the others.

```bash
BATCH=30
SUMMARY=()

for B in $BROKEN_DEV; do
  H=$(git rev-parse "krlmlr/$B")          # broken-branch tip

  # 4a. Gate: the tip must be green on rcc. Failing/pending => rcc-smoke-fix's job.
  STATUS=$(lookup_rcc_status "$H")
  if [[ "$STATUS" != "success" ]]; then
    SUMMARY+=("skip  $B  (tip rcc=$STATUS)"); continue
  fi

  # 4b. Gate: skip if the tip is already contained in a non-broken *-dev branch
  #     (it was promoted upstream — nothing to advance).
  contained=""
  for D in $NONBROKEN_DEV; do
    if git merge-base --is-ancestor "$H" "krlmlr/$D"; then contained="$D"; break; fi
  done
  if [[ -n "$contained" ]]; then
    SUMMARY+=("skip  $B  (already contained in $contained)"); continue
  fi

  # 4c. Vendored upstream duckdb SHA at the tip: the latest vendor commit
  #     reachable from H.
  DUCK=$(git log "$H" -1 --format=%s \
           --grep='vendor: Update vendored sources to duckdb/duckdb@' \
         | grep -oP 'duckdb/duckdb@\K[0-9a-f]{40}')
  if [[ -z "$DUCK" ]]; then
    SUMMARY+=("skip  $B  (no vendor commit found at tip)"); continue
  fi

  # 4d. Corresponding parent = the non-broken *-dev branch whose history vendors
  #     the SAME duckdb commit. This is the matching rule. Expect exactly one
  #     match (an upstream commit lives on a single upstream line); if more than
  #     one matches, stop and report rather than guess.
  MATCH_BRANCH=""; MATCH_VENDOR=""; n_match=0
  for D in $NONBROKEN_DEV; do
    V=$(git log "krlmlr/$D" -1 --format=%H --grep="duckdb/duckdb@$DUCK")
    if [[ -n "$V" ]]; then MATCH_BRANCH="$D"; MATCH_VENDOR="$V"; n_match=$((n_match+1)); fi
  done
  if [[ "$n_match" -eq 0 ]]; then
    SUMMARY+=("skip  $B  (no parent vendors duckdb@${DUCK:0:10})"); continue
  elif [[ "$n_match" -gt 1 ]]; then
    SUMMARY+=("STOP  $B  (duckdb@${DUCK:0:10} vendored by $n_match parents — ambiguous)"); continue
  fi

  # 4e. The next BATCH commits after the mirror point V on the parent line,
  #     oldest-first, first-parent only.
  mapfile -t NEXT < <(git rev-list --reverse --first-parent \
                        "$MATCH_VENDOR..krlmlr/$MATCH_BRANCH" | head -n "$BATCH")
  if [[ "${#NEXT[@]}" -eq 0 ]]; then
    SUMMARY+=("skip  $B  (up to date with $MATCH_BRANCH)"); continue
  fi

  echo "=== $B: advancing from $MATCH_BRANCH, ${#NEXT[@]} commits (tip vendors duckdb@${DUCK:0:10}) ==="
  git --no-pager log --format='  %h %s' -n "${#NEXT[@]}" --reverse \
      "$MATCH_VENDOR..krlmlr/$MATCH_BRANCH" 2>/dev/null | head -n "${#NEXT[@]}"

  # 4f. Dry-run in a DETACHED HEAD: the commits must apply cleanly before
  #     anything is published.
  git checkout --detach "$H"
  if git cherry-pick "${NEXT[@]}"; then
    NEWTIP=$(git rev-parse HEAD)
    # 4g. Publish: fast-forward the branch ref to the verified tip and push.
    #     The carried commits are new (re-vendored on the broken line), layered
    #     on top of H, so this is a fast-forward of B.
    git branch -f "$B" "$NEWTIP"
    git push krlmlr "$B" --force-with-lease
    SUMMARY+=("advanced  $B  (+${#NEXT[@]} from $MATCH_BRANCH -> ${NEWTIP:0:10})")
  else
    git cherry-pick --abort
    SUMMARY+=("ABORT  $B  (cherry-pick conflict — hand to rcc-smoke-fix / human)")
  fi
done

printf '%s\n' "${SUMMARY[@]}"
```

## Step 5 — Report

Emit a one-line-per-branch summary, e.g.:

```text
advanced  broken-<sha40>-dev  (+30 from main-dev -> 99b1b3d07)
skip      broken-<sha40>-dev  (tip rcc=failure)
skip      broken-<sha40>-dev  (already contained in v1.5-variegata-dev)
skip      broken-<sha40>-dev  (up to date with v1.5-variegata-dev)
ABORT     broken-<sha40>-dev  (cherry-pick conflict — hand to rcc-smoke-fix / human)
```

---

## Constraints (hard rules)

- **Only advance green branches.** The tip's `rcc` commit-status (context
  `rcc`, not the full check-run name) must be `success`. Failing or pending
  tips belong to `rcc-smoke-fix.md`.
- **Match by vendored commit, never by name or distance.** The corresponding
  `*-dev` branch is the one whose history vendors the same `duckdb/duckdb@<sha>`
  the broken tip vendors. Do not use the SHA embedded in the branch name, and
  do not fall back to merge-base distance — that was an earlier wrong heuristic.
- **Skip fully-contained branches.** If the tip is an ancestor of any
  non-broken `*-dev` branch, it has been promoted upstream; do nothing.
- **Bounded batch.** Carry at most `BATCH` (default 30) commits per run, taken
  oldest-first with `--first-parent` from the mirror point.
- **Dry-run before publish.** Verify the cherry-pick in a detached HEAD; only
  move the branch ref and push after a clean apply.
- **Never resolve or skip a conflict.** A conflicting cherry-pick aborts the
  branch and is reported; mechanical catch-up does not reconcile divergence.
- **Never build, never edit sources.** This skill is git/CI only. It does not
  run `R CMD INSTALL`, touch `src/duckdb/`, `inst/include/cpp11*`, `patch/`,
  flavor files, or any tracked source — all changes come solely from
  cherry-picked parent commits.
- **Branch target & suffix.** Push to the `krlmlr` remote, to the same
  `broken-<sha>-dev` branch (`--force-with-lease`). The `-dev` suffix is
  required so `each.yaml` runs per-commit CI on the newly pushed commits.
- **Always use freshly-fetched `krlmlr/*` refs;** never rely on previously
  checked-out state.
- **Tooling.** Prefer the `rcc` orphan branch (`runs2.ndjson`) for status — no
  auth needed. Fall back to `gh` only when a SHA is absent and `gh auth status`
  succeeds; a GitHub MCP tool may be used when provided. Do not use `curl` or
  inspect environment variables for authentication.
