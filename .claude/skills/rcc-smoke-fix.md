Scheduled job: scan all `*-dev` branches (including `broken-*-dev`) in
`krlmlr/duckdb-r` for the earliest commit whose `rcc`
commit-status (set by the "Smoke test: stock R" job in the `rcc` workflow) is
`failure` since 2026-04-11. For each such branch, if no `broken-<sha>-dev`
branch exists yet (full 40-char SHA), create it, fix `testthat::test_local()` and
`rcmdcheck::rcmdcheck()`, update snapshots, then cherry-pick all later commits from
the `*-dev` branch and push.

`broken-*-dev` branches are NOT terminal: a `broken-<X>-dev` branch is itself
a `*-dev` branch and is scanned the same way. Its existence means only that
`<X>` on the parent `*-dev` was repaired at one point — every later
cherry-picked commit on `broken-<X>-dev` is still subject to `rcc` and can
re-break. When a new failure appears in the cherry-picked region of
`broken-<X>-dev`, derive a fresh `broken-<newsha>-dev` from that failing
commit. The "skip if `broken-<sha>-dev` exists" check applies to the failing
SHA, not to the branch being scanned.

Cherry-pick conflicts are not
generally expected, but new patches may need to be introduced because the
upstream vendoring process **deletes `patch/*.patch` files that no longer
apply**. Never edit vendored sources (`src/duckdb/`, `inst/include/cpp11/`,
`inst/include/cpp11.hpp`) by hand; editing `patch/` will produce expected,
committable changes under `src/duckdb/`.

---

<!--
## Operation essence (read this first)

Why this skill exists.
  The DuckDB C++ core is vendored hourly into `src/duckdb/` from
  `duckdb/duckdb` (one upstream branch per `*-dev` line — `main` for
  `main-dev`, `v1.5-variegata` for `v1.5-variegata-dev`, `v1.4-andium` for
  `v1.4-andium-dev`). A vendor commit can break R-side glue (`src/*.cpp`,
  `src/include/`), R code (`R/`), or test snapshots
  (`tests/testthat/_snaps/`). We do not rewrite the upstream vendor commit;
  instead we author a parallel `broken-<sha>-dev` branch whose first commit
  is an **amended replacement** of the failing `<sha>` (same parent;
  original vendor message kept verbatim and a short R-side fix note
  appended; vendor diff plus R-side fix folded in). All later commits from
  the original `*-dev` branch are then cherry-picked on top. The result is
  a continuous "vendor + repair" history with no extra fix commit, which
  preserves continuity and keeps cherry-picks clean. Promoting the green
  tip back into the parent `*-dev` branch is a manual step performed
  outside this skill (today there is no CI/CD that does it automatically;
  this may be automated in the future).

End-to-end workflow.
  1. Refresh `krlmlr/*` remote-tracking refs from scratch — the dev
     branches are force-pushed and any cached state is suspect.
  2. Enumerate `*-dev` branches and existing `broken-*-dev` branches in
     one pass.
  3. For each `*-dev` branch, walk first-parent history oldest-first since
     SINCE and look up each commit's `rcc` commit-status until the earliest
     `failure` is found. Skip the branch if no failure exists or if the
     corresponding `broken-<sha>-dev` is already published.
  4. For every (branch, sha) pair that needs work:
     a. Check out `<sha>` on a new local branch `broken-<sha>-dev`.
     b. Reproduce the breakage locally — install the package
        (`_R_SHLIB_STRIP_=true R CMD INSTALL .`, with `MAKEFLAGS=-j$(nproc)`
        for parallel build), run `testthat::test_local()`, then
        `rcmdcheck::rcmdcheck()` (which builds the package tarball and
        checks it). The first build of `src/duckdb/` is heavy (10-15 min on cold
        cache); set generous timeouts. Read the error output carefully
        to classify the failure (compile, link, runtime, snapshot,
        NOTE/WARNING).
     c. Apply the smallest fix in priority order: `patch/` → glue
        (`src/*.cpp`, `src/include/`) → R code (`R/`) → snapshots
        (`tests/testthat/_snaps/`) → tests (`tests/testthat/test-*.R`).
        Stop at the first level that resolves the failure. Never edit
        vendored paths by hand — but expect `src/duckdb/` to change as a
        downstream effect when a `patch/` file is added or modified (the
        patch is applied to the vendored tree); commit those derived
        changes alongside the patch.
     d. `rcmdcheck::rcmdcheck()` until clean (`Status: OK` or only
        pre-existing NOTE).
     e. Cherry-pick every remaining commit from the upstream `*-dev`
        branch on top of the fix. Vendor commits apply cleanly by
        construction; non-vendor commits (forward-ports from `main`,
        glue-code repairs already pushed to `*-dev`) must be carried
        forward and may legitimately conflict with our own fix —
        resolve, do not skip. The most common failure
        is a previously-added `patch/*.patch` file that the vendoring
        process **deleted** in this commit because it no longer
        applied: restore an updated version of the dropped patch, or
        write a new one (next available number; keep existing numbers
        stable), apply it with `patch -p1 -i patch/<file>.patch`, and
        amend the cherry-picked commit (append a short R-side fix note
        to its message).
     f. When the loop is done the branch is already fully published;
        move on to the next pair.


     f. Push `broken-<sha>-dev` to `krlmlr` with `--force-with-lease`
        and move on to the next pair.

Environment assumptions (current).
  * R 4.x and standard development tooling (gcc/g++, make, git, `curl`,
    `jq`) are pre-installed.
  * GitHub Actions build logs and run results are available on the
    **orphan branch `rcc`** in `krlmlr/duckdb-r` — no token required.
    Fetch them before starting a local rebuild (see Step 4b).
  * When the orphan branch index does not cover a SHA, fall back to `gh`
    (run `gh auth status` first; skip the fallback if it fails). Do not
    use `curl` or read environment variables to check authentication.
  * A GitHub MCP tool may also be used for commit-status lookups when the
    agent provides one.

Fetching CI build logs from the `rcc` orphan branch.
  The harness (`scripts/rcc-logs.sh`) stores GitHub Actions results and
  logs on the `rcc` orphan branch of `krlmlr/duckdb-r`. Layout:
  `runs2.ndjson` holds one `{commit, status, run}` record per line keyed
  by commit SHA (only `completed` runs are recorded; pending commits are
  skipped and retried next harness run); `logs2/<sha>.log` holds the
  last 10 000 lines of the combined run log for each failed run. Before
  running a slow local `R CMD INSTALL`, read `logs2/<sha>.log` directly
  (see Step 4b). Most diagnostics point straight at the file and line,
  allowing the agent to draft a targeted fix and potentially skip the
  10–15 min cold-cache C++ rebuild. The local install +
  `testthat::test_local()` + `rcmdcheck::rcmdcheck()` cycle remains the
  authoritative final gate — logs only short-circuit triage, they do
  not replace verification.
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

## Step 2 — Collect all branches and existing `broken-*` branches in one pass

```bash
# All krlmlr remote-tracking branches that end in -dev. Deliberately INCLUDES
# broken-*-dev branches — they are scanned for later failures in their
# cherry-picked region and treated identically to upstream *-dev branches.
DEV_BRANCHES=$(git branch -r \
  | grep -oP 'krlmlr/\K\S+' \
  | grep -E '\-dev$' \
  | sort)

# All broken-*-dev branches already on krlmlr (to skip re-doing work)
BROKEN_BRANCHES=$(git branch -r \
  | grep -oP 'krlmlr/\K\S+' \
  | grep -E '^broken-.*-dev$')

echo "=== Dev branches ===" && echo "$DEV_BRANCHES"
echo "=== Broken branches (existing) ===" && echo "$BROKEN_BRANCHES"
```

## Step 3 — For each `*-dev` branch, find the earliest failing commit

Iterate over every entry in `$DEV_BRANCHES`. For each `$BRANCH`:

```bash
SINCE="2026-04-11"
REPO="krlmlr/duckdb-r"

# Commits on this branch since SINCE, oldest-first (first-parent only)
COMMITS_OLDEST_FIRST=$(git log "krlmlr/$BRANCH" \
  --first-parent --since="$SINCE" --format="%H" --reverse)
```

Cache the orphan-branch run index once (no token required):

```bash
RCC_NDJSON=$(git show krlmlr/rcc:runs2.ndjson 2>/dev/null || true)
```

Define helpers. `lookup_rcc_status` reads from the cached `$RCC_NDJSON`
first; falls back to `gh` only when the SHA is absent and `gh auth status`
succeeds. Do not use `curl` or check environment variables.

```bash
is_rcc_failure() {
  case "$1" in
    failure|timed_out|startup_failure|action_required) return 0 ;;
    *) return 1 ;;
  esac
}

# Check once whether `gh` is usable; cache the result.
GH_OK=0
gh auth status &>/dev/null && GH_OK=1

lookup_rcc_status() {
  local sha="$1"
  # Primary: orphan branch index (instant, no auth needed).
  # runs2.ndjson is keyed by commit SHA and only contains completed runs;
  # use the run conclusion so it lines up with is_rcc_failure().
  local conclusion
  conclusion=$(jq -r --arg sha "$sha" \
    'select(.commit == $sha) | .run.conclusion // empty' \
    <<< "$RCC_NDJSON" | head -1)
  [[ -n "$conclusion" ]] && { echo "$conclusion"; return; }

  # Fallback: gh CLI (only when authenticated). Returns the commit-status
  # state, which uses a smaller vocabulary (success|failure|pending|error)
  # but still triggers is_rcc_failure() on "failure".
  if [[ "$GH_OK" == "1" ]]; then
    gh api "repos/$REPO/commits/$sha/statuses" \
      | jq -r '[.[] | select(.context == "rcc")] | first | .state // "none"'
  else
    echo "none"
  fi
}
```

Walk the commits oldest-first, stop at the first failure. Use `pipefail`
so a failed status lookup is not silently swallowed:

```bash
set -o pipefail

FIRST_FAIL=""
while IFS= read -r SHA; do
  STATUS=$(lookup_rcc_status "$SHA")
  echo "$BRANCH  ${SHA}  $STATUS"
  if is_rcc_failure "$STATUS"; then
    FIRST_FAIL="$SHA"
    break
  fi
done <<< "$COMMITS_OLDEST_FIRST"

# Existence check comes AFTER finding the earliest failure.
# Checking inside the loop would short-circuit on a later already-fixed commit
# before reaching an earlier failure that still has no fix branch.
if [[ -z "$FIRST_FAIL" ]]; then
  echo "$BRANCH: no rcc failure — skip"
elif echo "$BROKEN_BRANCHES" | grep -qxF "broken-${FIRST_FAIL}-dev"; then
  echo "$BRANCH: broken-${FIRST_FAIL}-dev already exists — skip"
else
  echo "NEEDS_FIX  $BRANCH  $FIRST_FAIL"
fi
```

Collect all `NEEDS_FIX  <branch>  <sha>` lines. Process them in order.

## Step 3a — Look ahead for self-healing

For each `NEEDS_FIX` pair, continue walking `$COMMITS_OLDEST_FIRST`
forward from `$FIRST_FAIL` and check whether `rcc` returns to `success`
without manual intervention on this branch. This happens when two
adjacent upstream commits form one logically consistent change but were
vendored as separate steps, leaving a transient break between them. The
goal here is only to characterise the **first** failing window — later
breakages on the same branch are scanned separately on their own
`broken-*-dev` branch (the recursion rule in the header).

```bash
HEAL_AT=""
LAST_FAIL="$FIRST_FAIL"
seen_fail=0
while IFS= read -r SHA; do
  if [[ "$seen_fail" == 0 ]]; then
    [[ "$SHA" == "$FIRST_FAIL" ]] && seen_fail=1
    continue
  fi
  STATUS=$(lookup_rcc_status "$SHA")
  if is_rcc_failure "$STATUS"; then
    LAST_FAIL="$SHA"
    continue
  fi
  if [[ "$STATUS" == "success" ]]; then
    HEAL_AT="$SHA"
    break
  fi
  # pending / none / error from runs2.ndjson: cannot prove a self-heal
  HEAL_AT=""
  break
done <<< "$COMMITS_OLDEST_FIRST"

if [[ -n "$HEAL_AT" ]]; then
  WINDOW=$(git rev-list --count --first-parent \
    "${FIRST_FAIL}^..${LAST_FAIL}")
  echo "SELF_HEAL  $BRANCH  fail=$FIRST_FAIL  last_fail=$LAST_FAIL  heal=$HEAL_AT  window=$WINDOW"
else
  echo "PERSISTENT  $BRANCH  fail=$FIRST_FAIL"
fi
```

- `HEAL_AT` empty → failure persists to HEAD (or the index is
  incomplete): use the standard single-commit fix workflow
  (Step 4 unmodified).
- `HEAL_AT` set → failure is transient: Step 4c-bis picks between a
  **squash** and a **transient patch** strategy based on `$WINDOW`.

## Step 4 — Create, fix, and push a `broken-*` branch

Repeat for each `NEEDS_FIX` pair `($BRANCH, $SHA)`:

### 4a. Check out the failing commit on the new fix branch

```bash
FIX_BRANCH="broken-${SHA}-dev"
git checkout -B "$FIX_BRANCH" "$SHA"
```

IMPORTANT: Keep the `-dev` suffix in the fix branch name. It ensures that each
intermediate commit is checked on CI/CD via `each.yaml`.

### 4b. Fetch CI log, then install and run tests; collect failures

**First**, fetch the build log from the `rcc` orphan branch. This is fast
and usually pinpoints the failure before any local compilation.

The orphan branch layout (produced by `scripts/rcc-logs.sh`) is:

```
runs2.ndjson     – one {commit, status, run} record per line, keyed by
                   commit SHA (only completed runs; pending commits are
                   absent and retried on the next harness invocation)
logs2/<sha>.log  – last 10 000 lines of the combined run log,
                   only for runs with a failure conclusion
```

```bash
# Fetch the rcc orphan branch (do this once; re-use across multiple SHAs)
git fetch krlmlr rcc

# Show the tail of the failure log (logs are keyed by full commit SHA;
# no run-id intermediate)
git show "krlmlr/rcc:logs2/${SHA}.log" 2>/dev/null | tail -60
```

If you also want the run metadata (run id, html_url, conclusion, etc.):

```bash
git show krlmlr/rcc:runs2.ndjson \
  | jq -c --arg sha "$SHA" 'select(.commit == $sha) | .run' \
  | head -1
```

If the log identifies the root cause clearly (compiler error, link error,
failing test + message), draft the targeted fix and proceed to Step 4c
directly, skipping the slow `R CMD INSTALL` of `src/duckdb/`. If the log
is absent or inconclusive, fall back to a full local build:

```bash
set -o pipefail
export MAKEFLAGS="-j$(nproc)"
_R_SHLIB_STRIP_=true R CMD INSTALL . 2>&1 | tail -20
Rscript -e 'testthat::test_local(stop_on_failure = FALSE)' 2>&1
```

`pipefail` is required so that a failing `R CMD INSTALL` propagates its
non-zero exit status through the `tail` pipe. The last 20 lines are
typically enough to diagnose a build failure; if they aren't, drop the pipe
and re-run for the full log.

The first build of `src/duckdb/` from a cold cache takes **10–15 minutes**
— set generous timeouts. Subsequent rebuilds are incremental and much
faster. If only `R/`, `tests/`, `man/`, or `tests/testthat/_snaps/`
change, the C++ rebuild is skipped entirely.

Note: spurious changes to `src/*.dd` (dependency-tracking files) caused by a
Makefile bug should be discarded with `git checkout -- src/*.dd` rather than
fixed; see `AGENTS.md` for the root cause.

When a failure is in a test gated by `requireNamespace()` (e.g. `arrow`,
`DBItest`, `dbplyr`) and that Suggests dependency is missing from the local
library, install it with `install.packages("foo")` — leave `repos=` unset
first, so the env-configured default (Posit P3M binary builds for the
current Linux release) is used; that's much faster than a CRAN source
compile. If the default repo can't serve the package (404, mirror down,
unsupported R version), fall back to an explicit `repos=` (e.g.
`"https://cloud.r-project.org"`) and retry — but only after the default
has actually failed.

### 4c. Fix issues — allowed modifications and priority order

Classify the failure before picking a fix; the classification also
drives the self-healing strategy in Step 4c-bis.

- **Vendored library broken** — the DuckDB C++ core does not even
  build cleanly: compile/link errors with files under `src/duckdb/...`
  in the diagnostic, or unresolved symbols inside the core. Fix lives
  in `patch/` (priority 1 below). Self-heal of this class typically
  arrives as a follow-up vendor commit, so the squash strategy is
  natural when the window is 1.
- **Call sites incompatible** — the core builds, but `src/*.cpp`,
  `src/include/*.hpp`, `R/`, or `tests/` reference a DuckDB API that
  was renamed, removed, or reshaped. Fix lives in glue or R code
  (priorities 2–5 below). Self-heal of this class typically arrives
  as a forward-ported glue/R commit on `*-dev`, so either a squash
  (window 1) or a transient patch (wider) applies.

Quick check: `grep -E '(^|/)src/duckdb/' <log>` vs
`grep -E '(^|/)src/(rapi|database|...)' <log>` on the failure log
fetched in Step 4b separates the two cleanly in most cases. When the
log shows a runtime/test failure rather than a build error, the failure
is almost always "call sites incompatible" (the build linked fine but
behaviour changed).

**Never edit by hand** any of the following vendored / auto-generated paths:

- `src/duckdb/` (vendored DuckDB C++ core) — note: `src/duckdb/` WILL change
  as a downstream effect of editing `patch/` (the patch is applied to the
  vendored tree); those derived changes are expected and must be committed
  with the patch (see priority 1 below). It is only direct edits that are
  forbidden.
- `inst/include/cpp11/`, `inst/include/cpp11.hpp` (vendored cpp11 from
  `krlmlr/cpp11`)
- `scripts/vendor.sh`, `scripts/vendor-one.sh`, `scripts/lts.sh`,
  `scripts/lts.patch` (vendoring + flavor automation)

The flavor files (`DESCRIPTION`'s `Package:` field, `R/duckdb-package.R`,
`src/include/rapi.hpp` for `DUCKDB_PACKAGE_NAME`,
`inst/include/duckdb_types.hpp`, `tests/testthat.R`) are managed by
`scripts/lts.sh` and should not be hand-edited; if they look wrong, re-run
`scripts/lts.sh <flavor>` rather than patching by hand.

Everything else — including `patch/` — may be changed.

Apply fixes in this priority order (stop at the first level that resolves
the failure):

1. **`patch/`** — R-specific patches to the DuckDB C++ core. Prefer adjusting
   or adding a patch here when the C++ API changed in a way that breaks
   compilation, linking, or warning policy. Assign the next available
   number; do not renumber existing patches. Send the same change as a PR
   to `duckdb/duckdb` so it can eventually be retired.

   Apply a new or edited patch with `patch -p1 -i patch/<file>.patch` so
   that `src/duckdb/` reflects the patched state the build expects. The
   resulting modifications under `src/duckdb/` are the expected downstream
   effect of the patch and must be committed together with the patch
   file.

2. **Glue code** (`src/*.cpp`, `src/include/`, `src/*.dd`) — adapt the R↔C++
   bridge to a changed DuckDB API before touching any R-level code. New
   string constants and `Rf_install()` symbols belong in
   `RStrings::RStrings()` in `src/utils.cpp` and `struct RStrings` in
   `src/include/rapi.hpp` (see `AGENTS.md`).

3. **R code** (`R/`) — update high-level R functions, fix argument handling,
   etc. After changes, regenerate documentation:
   `Rscript -e 'roxygen2::roxygenize()'`.

4. **Snapshots** (`tests/testthat/_snaps/`) — accept updated snapshots only
   after the underlying behaviour is confirmed correct:

   ```bash
   Rscript -e 'testthat::snapshot_accept()'
   ```

   Or for a single test file: `testthat::snapshot_accept("test-name")`.

5. **Tests** (`tests/testthat/test-*.R`) — change test code **only as a last
   resort**, e.g. when the test itself was testing a now-removed
   C++-level detail. Do not weaken assertions; adapt them to the new
   correct behaviour.

Other common fixes:

| Symptom                            | Fix                                              |
|------------------------------------|--------------------------------------------------|
| Missing export / namespace error   | `Rscript -e 'roxygen2::roxygenize()'`            |
| `cpp11::cpp_register()` out of date| `Rscript -e 'cpp11::cpp_register()'`             |
| NOTE / WARNING in `rcmdcheck` output| Fix in `R/`, `man/`, or `patch/`                 |
| Compiler warning in vendored code  | New file under `patch/` (do **not** suppress)    |

After any change, re-run:

```bash
Rscript -e 'testthat::test_local(stop_on_failure = FALSE)' 2>&1
```

Iterate until all tests pass.

### 4c-bis. Self-healing strategies (only when `HEAL_AT` is set)

If Step 3a recorded a `HEAL_AT`, pick a strategy by window width:

| `$WINDOW` | Strategy        | Audit trail                                                                                  |
|-----------|-----------------|----------------------------------------------------------------------------------------------|
| `1`       | Squash          | One amended vendor commit replaces both `FIRST_FAIL` and `HEAL_AT`; both upstream messages quoted. |
| `≥ 2`     | Transient patch | `patch/NNNN-transient-*.patch` introduced at `FIRST_FAIL`, deleted at `HEAL_AT`.             |

Pick **squash** only when `HEAL_AT` is the immediate next first-parent
commit after `FIRST_FAIL`. For anything wider, prefer the transient
patch — squashing more than two upstream commits hides too much of
upstream's authored history and breaks the "one vendor commit per
upstream commit" invariant that the rest of this skill assumes.

**Squash strategy** (`STRATEGY=squash`, `$WINDOW == 1`). After Step 4a
the HEAD of `broken-${FIRST_FAIL}-dev` is `FIRST_FAIL`. Apply
`HEAL_AT`'s tree on top, then collapse onto `FIRST_FAIL`'s parent and
recommit with a constructed message that names both upstream SHAs:

```bash
STRATEGY=squash

git cherry-pick --no-commit "$HEAL_AT"
# (resolve any conflicts here; they are uncommon because both commits
# are usually vendor-only, but a non-vendor commit at HEAL_AT may
# conflict with the build state of FIRST_FAIL.)
git reset --soft "${FIRST_FAIL}^"

FIRST_MSG=$(git log -1 --format=%B "$FIRST_FAIL")
HEAL_MSG=$(git log -1 --format=%B "$HEAL_AT")

git commit -m "${FIRST_MSG}

Combined upstream commit ${HEAL_AT}
-----------------------------------
The build fails when ${FIRST_FAIL} is taken on its own; upstream
${HEAL_AT} restores consistency. Vendored together here to avoid a
transient build break — both commits would otherwise have been
vendored as separate steps.

Original message of ${HEAL_AT}
------------------------------
${HEAL_MSG}"
```

In Step 4g, **skip** `HEAL_AT` when iterating `REMAINING` — its tree
is already in the amended commit.

**Transient patch strategy** (`STRATEGY=transient`, `$WINDOW >= 2`).
Add a numbered patch whose header documents the exact window:

```
# Transient: <short symptom, e.g. "missing ExpressionFilter ctor">
# Introduced  : <FIRST_FAIL>
# Removed at  : <HEAL_AT>
# Upstream    : <PR URL or "none">
#
# This patch repairs a transient inconsistency between two adjacent
# upstream vendor commits. Do not keep it past <HEAL_AT>; the vendored
# tree there is self-consistent.
```

Pick the next available `patch/NNNN-...` number; name the file
`NNNN-transient-<short>.patch`. Apply with
`patch -p1 -i patch/NNNN-transient-<short>.patch` and commit the
derived `src/duckdb/` changes together with the patch into the
`FIRST_FAIL` amend (Step 4f).

In Step 4g, when the cherry-pick reaches `HEAL_AT`, remove the
transient patch in the same commit and append a removal note:

```bash
git cherry-pick --no-commit "$HEAL_AT"
git rm patch/*-transient-*.patch
# Re-sync the vendored tree to HEAL_AT exactly, so the patch removal
# does not leave the patched-state diff behind in src/duckdb/.
git checkout "$HEAL_AT" -- src/duckdb/
HEAL_MSG=$(git log -1 --format=%B "$HEAL_AT")
git commit -m "${HEAL_MSG}

Removed transient patch
-----------------------
patch/NNNN-transient-<short>.patch is no longer needed: the vendored
tree at this commit is self-consistent against the R-side glue."
```

For a **call-site** self-heal the same shape applies, but the
"transient patch" is a small glue/R diff folded into the `FIRST_FAIL`
amend and reverted at `HEAL_AT`. Store the reverse-diff next to the
forward diff in `patch/transient-glue/<short>.patch` (audit-only —
not applied by the build) so the audit trail is reproducible even
when no `src/duckdb/` change is involved.

If `lookup_rcc_status` returned `none`/`pending` for any commit
between `FIRST_FAIL` and the candidate `HEAL_AT`, the self-heal is
unproven — Step 3a will have left `HEAL_AT` empty and you will not
reach this section. Do not "fill in" missing CI data by hand.

### 4d. Final check

Use `rcmdcheck::rcmdcheck()` to build the package tarball and check it:

```bash
set -o pipefail
Rscript -e 'rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"), error_on = "warning")' 2>&1 | tail -20
```

Must show `Status: OK` or at most `1 NOTE` (pre-existing CRAN notes are
fine). Fix any new ERRORs or new WARNINGs.

### 4e. Format edited sources

Mirror the `format-suggest.yaml` GHA workflow (`.github/workflows/style/`):
auto-format any C/C++ and R sources before committing, gated on the
presence of the corresponding config file in the repo.

```bash
# C/C++: clang-format if .clang-format exists in repo root
if [ -f .clang-format ]; then
  shopt -s nullglob
  clang-format -i src/*.{c,cc,cpp,h,hpp}
  shopt -u nullglob
fi

# R: Posit Air if air.toml exists in repo root
if [ -f air.toml ]; then
  air format .
fi
```

`clang-format` and `air` are preinstalled.

Re-run `R CMD INSTALL` after formatting.

### 4f. Fold the fix into the failing commit (amend)

The fix must be **amended into the failing commit itself**, so the tip of
`broken-<sha>-dev` is a single-commit-deep replacement of `<sha>` (same
parent, vendor diff + R-side fix) rather than a two-commit chain.
Cherry-picks then layer cleanly on top, and the branch keeps a
continuous "vendor + repair" history without an explicit "fix" commit.

The amended commit message **keeps the original vendor message intact**
and **appends** a short note documenting the R-side finding (what broke,
why, what was changed). Append-only: do not rewrite or shorten the
upstream-authored portion.

```bash
git add -- R/ tests/ man/ NAMESPACE src/*.cpp src/include/ src/*.dd patch/
# Also stage `src/duckdb/` if (and only if) you modified `patch/` and the
# patch was applied to the vendored tree:
git diff --cached --name-only -- patch/ | grep -q . && \
  git add -- src/duckdb/
# Only if there are staged changes: amend, preserving the original
# vendor message and appending a short fix note. Replace <DETAILS>
# with 1-5 lines describing the upstream API change and the R-side
# adaptation (e.g. "Handle new EXPRESSION_FILTER kind in
# TransformFilterExpression — upstream PR #22005 unified
# ConstantFilter into ExpressionFilter.").
ORIG_MSG=$(git log -1 --format=%B)
git diff --cached --quiet || \
  git commit --amend -m "${ORIG_MSG}

R-side fix
----------
<DETAILS>"
```

This rewrites the local `broken-<sha>-dev` HEAD only — the original
`<sha>` on `krlmlr/main-dev` (or whichever upstream) is untouched, so the
"never amend pushed commits" rule still holds: the amend produces a new
commit on a new, never-before-pushed branch.

Never `git add` paths under `inst/include/cpp11/` or any flavor file
managed by `scripts/lts.sh`. `src/duckdb/` should only appear in the
amended commit when it carries the downstream effect of a `patch/`
change.

### 4g. Cherry-pick all remaining commits from `*-dev`

```bash
# Commits on the *-dev branch that come *after* the failing commit.
REMAINING=$(git log "${SHA}..krlmlr/${BRANCH}" \
  --first-parent --format="%H" --reverse)

for C in $REMAINING; do
  if [[ "$C" == "$HEAL_AT" && "$STRATEGY" == "squash" ]]; then
    # HEAL_AT's tree was already folded into the FIRST_FAIL amend
    # (Step 4c-bis, squash strategy). Skip it here.
    continue
  fi
  git cherry-pick "$C" --allow-empty
  if [[ "$C" == "$HEAL_AT" && "$STRATEGY" == "transient" ]]; then
    # Remove the transient patch and re-sync src/duckdb/ to HEAL_AT's
    # tree exactly (Step 4c-bis, transient patch strategy).
    git rm patch/*-transient-*.patch 2>/dev/null || true
    git checkout "$HEAL_AT" -- src/duckdb/
    git add -- src/duckdb/ patch/
    HEAL_MSG=$(git log -1 --format=%B "$HEAL_AT")
    git commit --amend -m "${HEAL_MSG}

Removed transient patch
-----------------------
The transient patch added at ${FIRST_FAIL} is no longer needed: the
vendored tree at this commit is self-consistent."
  fi
done
```

Most of these commits are vendor-only and apply cleanly. However, the range
**may include non-vendor commits**: forward-ports from `duckdb/duckdb-r@main`
(glue, R code, CI/CD, cpp11), or later glue-code repairs that were pushed
directly to the `*-dev` branch. That is expected and correct — those
fixes address *subsequent* breakages that were introduced after our fix
point and must be carried forward.

Conflict handling:

- Conflict on `inst/include/cpp11/` or `inst/include/cpp11.hpp`: should
  never happen; stop and report.
- Conflict on `src/duckdb/`: usually means our `patch/` change
  overlaps with a later vendor commit. Stop the cherry-pick,
  a subsequent vendoring process will pick up the state.
- Conflict on any other file (glue, `patch/`, `R/`, tests, snapshots): the
  cherry-picked commit is a fix commit whose change overlaps with our own
  fix. Resolve by accepting the cherry-picked version
  (`git checkout --theirs`) or by merging manually, then
  `git cherry-pick --continue`. Do **not** use `--skip` unless the commit
  is genuinely a no-op after our fix.

The cherry-pick is purely mechanical, CI/CD will catch any resulting breakage.

### 4h. Push the fix branch

```bash
git push krlmlr "$FIX_BRANCH" --force-with-lease
```

## Step 5 — Continue

Return to Step 3 / Step 4 for the next `NEEDS_FIX` entry.
When all are processed, report a summary:

```text
Fixed: broken-<sha40>-dev (from main-dev,           cherry-picked N commits)
Fixed: broken-<sha40>-dev (from v1.5-variegata-dev, cherry-picked M commits)
Skipped (already fixed): broken-<sha40>-dev exists
No failure found: v1.4-andium-dev
```

---

## Constraints (hard rules)

- **Never edit by hand** `inst/include/cpp11/`, `inst/include/cpp11.hpp`,
  or any `scripts/vendor*.sh` / `scripts/lts.{sh,patch}` file.
  `src/duckdb/` may not be edited directly either, but it WILL change as
  a downstream effect of editing `patch/` (the patch is applied to the
  vendored tree); those derived changes are expected and must be
  committed alongside the patch. `patch/` itself **may** be edited.
- **Never** hand-edit flavor files (`DESCRIPTION` `Package:` field,
  `R/duckdb-package.R`, `src/include/rapi.hpp`'s `DUCKDB_PACKAGE_NAME`,
  `inst/include/duckdb_types.hpp`, `tests/testthat.R`); they are produced
  by `scripts/lts.sh` and should match per-branch.
- **Never** suppress C++ warnings via `#pragma clang diagnostic ignored` or
  similar. Add a `patch/` file that fixes the underlying issue (see
  `AGENTS.md`). CRAN rejects packages that silence warnings.
- **Never** amend commits that have already been pushed. Step 4f amends
  the failing `<sha>` only on the freshly-created local `broken-<sha>-dev`
  branch (which has not been pushed); the original `<sha>` on the upstream
  `*-dev` branch is left alone.
- **Transient patches** (`patch/NNNN-transient-*.patch`) are only allowed
  when Step 3a observed a self-heal with a specific `HEAL_AT`. The patch
  header MUST name `FIRST_FAIL`, `HEAL_AT`, and the upstream PR (or
  `none`). The patch MUST be removed in the amended `HEAL_AT` cherry-pick
  (Step 4g). Never let a transient patch survive past its `HEAL_AT`;
  either promote it to a permanent `patch/` file (and drop the
  `transient` prefix) or delete it.
- **Squashed vendor commits** (Step 4c-bis) are only allowed when
  `$WINDOW == 1` — i.e., `HEAL_AT` is the immediate next first-parent
  commit after `FIRST_FAIL`. The amended commit message MUST quote
  both upstream messages verbatim under a `Combined upstream commit
  <sha>` block; do not paraphrase upstream wording.
- **Self-heal classification is advisory.** If the orphan-branch index
  returns `none`/`pending`/`error` for any intermediate commit between
  `FIRST_FAIL` and a candidate `HEAL_AT`, treat the window as
  non-self-healing and fall back to the single-commit fix workflow.
  Do not assume CI absence means success.
- **Commit status to check**: context `rcc` (not the full check-run name).
- **Branch target**: all pushes go to the `krlmlr` remote
  (`krlmlr/duckdb-r`) to a branch named `broken-<sha>-dev` (full 40-char
  SHA). The `-dev` suffix is required so `each.yaml` triggers per-commit
  CI on the new branch.
- **Branch scope**: only branches matching `\-dev$`.
- Branches being force-pushed to: always use the freshly-fetched
  `krlmlr/*` ref; never rely on any previously-checked-out state.
- **Triage with CI logs, confirm locally.** GitHub Actions results and
  logs are available on the `rcc` orphan branch of `krlmlr/duckdb-r`
  (see Step 4b for fetch commands). Use these to triage failures before
  starting a slow local build. Every fix must still be validated by a
  local `R CMD INSTALL` + `testthat::test_local()` +
  `rcmdcheck::rcmdcheck()` cycle — logs short-circuit triage but do not
  replace verification. The first cold-cache `R CMD INSTALL` is slow
  (10–15 min); do not abort it.
- **Tooling**: prefer the `rcc` orphan branch (`runs2.ndjson` for status
  metadata, `logs2/<sha>.log` for failure log tails) — no auth needed.
  Fall back to `gh` only when a SHA is absent from `runs2.ndjson`;
  always gate that fallback on `gh auth status` succeeding. Do not use
  `curl` for API calls and do not inspect environment variables to
  decide whether to authenticate. A GitHub MCP tool may be used when
  the agent provides one.
