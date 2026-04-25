Scheduled job: scan all `*-dev` branches (including `broken-*-dev`, excluding
`*-dev-base`) in `krlmlr/duckdb-r` for the earliest commit whose `rcc`
commit-status (set by the "Smoke test: stock R" job in the `rcc` workflow) is
`failure` since 2026-04-11. For each such branch, if no `broken-<sha>-dev`
branch exists yet (full 40-char SHA), create it, fix `testthat::test_local()`
and `R CMD check .`, update snapshots, then cherry-pick all later commits
from the `*-dev` branch and push. Never modify vendored sources
(`src/duckdb/`, `inst/include/cpp11/`, `inst/include/cpp11.hpp`).

---

<!--
## Operation essence (read this first)

Why this skill exists.
  The DuckDB C++ core is vendored hourly into `src/duckdb/` from
  `duckdb/duckdb` (one upstream branch per `*-dev` line — `main` for
  `main-dev`, `v1.5-variegata` for `v1.5-variegata-dev`, `v1.4-andium` for
  `v1.4-andium-dev`). A vendor commit can break R-side glue (`src/*.cpp`,
  `src/include/`), R code (`R/`), or test snapshots
  (`tests/testthat/_snaps/`). We do not rewrite the vendor commit; instead
  we author a parallel `broken-<sha>-dev` branch that starts at the failing
  commit, layers on the necessary R-side fix, and re-applies all later
  commits from the original `*-dev` branch on top. Promoting the green tip
  back into the parent `*-dev` branch is a manual step performed outside
  this skill (today there is no CI/CD that does it automatically; this may
  be automated in the future).

End-to-end workflow.
  1. Refresh `krlmlr/*` remote-tracking refs from scratch — the dev
     branches are force-pushed and any cached state is suspect.
  2. Enumerate `*-dev` branches (excluding `*-dev-base`, `*-dev-old*`,
     `*-dev-broken`) and existing `broken-*-dev` branches in one pass.
  3. For each `*-dev` branch, walk first-parent history oldest-first since
     SINCE and look up each commit's `rcc` commit-status until the earliest
     `failure` is found. Skip the branch if no failure exists or if the
     corresponding `broken-<sha>-dev` is already published.
  4. For every (branch, sha) pair that needs work:
     a. Check out `<sha>` on a new local branch `broken-<sha>-dev`.
     b. Reproduce the breakage locally — install the package
        (`_R_SHLIB_STRIP_=true R CMD INSTALL .`, with `MAKEFLAGS=-j$(nproc)`
        for parallel build), run `testthat::test_local()`, then
        `R CMD check .`. The first build of `src/duckdb/` is heavy
        (10-15 min on cold cache); set generous timeouts. Read the error
        output carefully to classify the failure (compile, link, runtime,
        snapshot, NOTE/WARNING).
     c. Apply the smallest fix in priority order: `patch/` → glue
        (`src/*.cpp`, `src/include/`) → R code (`R/`) → snapshots
        (`tests/testthat/_snaps/`) → tests (`tests/testthat/test-*.R`).
        Stop at the first level that resolves the failure. Never touch
        vendored paths (see Constraints).
     d. `R CMD check .` until clean (`Status: OK` or only pre-existing
        NOTE).
     e. Cherry-pick every remaining commit from the upstream `*-dev`
        branch on top of the fix. Vendor commits apply cleanly by
        construction; non-vendor commits (forward-ports from `main`,
        glue-code repairs already pushed to `*-dev`) must be carried
        forward and may legitimately conflict with our own fix —
        resolve, do not skip.
     f. Push `broken-<sha>-dev` to `krlmlr` with `--force-with-lease`
        and move on to the next pair.

Environment assumptions (current).
  * R 4.x and standard development tooling (gcc/g++, make, git) are
    pre-installed.
  * The `gh` CLI is NOT installed and GitHub Actions build logs are NOT
    accessible from this environment. Failures must be reproduced locally —
    there is no shortcut by reading a CI log.
  * GitHub commit-status lookups should use a GitHub MCP tool when the
    skill is invoked by an agent that has one. As a portable fallback, hit
    `GET /repos/{owner}/{repo}/commits/{sha}/statuses` with `curl` and a
    `GITHUB_TOKEN` (see Step 3); filter for `context == "rcc"`.

When CI build logs become available (forward-looking).
  Once the harness can fetch GitHub Actions logs, augment Step 4b: before
  the local rebuild, fetch the failed `rcc / Smoke test: stock R` run for
  `<sha>` and read the tail. Most diagnostics point straight at the file
  and line, allowing the agent to draft a targeted fix and skip the slow
  initial full `R CMD INSTALL` of `src/duckdb/`. The local install +
  `testthat::test_local()` + `R CMD check .` cycle remains the
  authoritative final gate — logs only short-circuit triage, they do not
  replace verification.
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
# All krlmlr remote-tracking branches that end in -dev,
# excluding -dev-base, -dev-old*, -dev-broken.
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

The `\-dev$` anchor naturally drops `*-dev-base`, `*-dev-old`, `*-dev-old-2`,
and `*-dev-broken` while keeping every active line (`main-dev`,
`v1.5-variegata-dev`, `v1.4-andium-dev`, …).

## Step 3 — For each `*-dev` branch, find the earliest failing commit

Iterate over every entry in `$DEV_BRANCHES`. For each `$BRANCH`:

```bash
SINCE="2026-04-11"
REPO="krlmlr/duckdb-r"

# Commits on this branch since SINCE, oldest-first (first-parent only)
COMMITS_OLDEST_FIRST=$(git log "krlmlr/$BRANCH" \
  --first-parent --since="$SINCE" --format="%H" --reverse)
```

For each `$SHA` in that list, look up the `rcc` commit-status — use whichever
tool is available in the current environment:

- **GitHub MCP** (preferred when invoked by an agent that exposes one): query
  the commit-statuses endpoint for `$REPO` at `$SHA` and pick the entry whose
  `context == "rcc"`.
- **`gh` CLI** (when available locally):
  `gh api "repos/$REPO/commits/$SHA/statuses" | jq -r '[.[] | select(.context == "rcc")] | first | .state // "none"'`
- **Plain HTTPS** (portable, no `gh` needed):
  `curl -fsSL -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$REPO/commits/$SHA/statuses" | jq -r '[.[] | select(.context == "rcc")] | first | .state // "none"'`

Walk the commits oldest-first, stop at the first `failure`:

```bash
FIRST_FAIL=""
while IFS= read -r SHA; do
  STATUS=$(... look up rcc state for $SHA ...)
  echo "$BRANCH  ${SHA}  $STATUS"
  if [[ "$STATUS" == "failure" ]]; then
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

## Step 4 — Create, fix, and push a `broken-*` branch

Repeat for each `NEEDS_FIX` pair `($BRANCH, $SHA)`:

### 4a. Check out the failing commit on the new fix branch

```bash
FIX_BRANCH="broken-${SHA}-dev"
git checkout -B "$FIX_BRANCH" "$SHA"
```

IMPORTANT: Keep the `-dev` suffix in the fix branch name. It ensures that each
intermediate commit is checked on CI/CD via `each.yaml`.

### 4b. Install and run tests; collect failures

```bash
export MAKEFLAGS="-j$(nproc)"
_R_SHLIB_STRIP_=true R CMD INSTALL . 2>&1 | tail -20
Rscript -e 'testthat::test_local(stop_on_failure = FALSE)' 2>&1
```

Read the output carefully. The first build of `src/duckdb/` from a cold cache
takes **10–15 minutes** — set generous timeouts. Subsequent rebuilds are
incremental and much faster. If only `R/`, `tests/`, `man/`, or
`tests/testthat/_snaps/` change, the C++ rebuild is skipped entirely.

Note: spurious changes to `src/*.dd` (dependency-tracking files) caused by a
Makefile bug should be discarded with `git checkout -- src/*.dd` rather than
fixed; see `AGENTS.md` for the root cause.

### 4c. Fix issues — allowed modifications and priority order

**Never modify** any of the following vendored / auto-generated paths:

- `src/duckdb/` (vendored DuckDB C++ core)
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
| NOTE / WARNING in R CMD check      | Fix in `R/`, `man/`, or `patch/`                 |
| Compiler warning in vendored code  | New file under `patch/` (do **not** suppress)    |

After any change, re-run:

```bash
Rscript -e 'testthat::test_local(stop_on_failure = FALSE)' 2>&1
```

Iterate until all tests pass.

### 4d. Final check

```bash
R CMD check . --no-manual --as-cran 2>&1 | tail -20
```

Must show `Status: OK` or at most `1 NOTE` (pre-existing CRAN notes are
fine). Fix any new ERRORs or new WARNINGs.

### 4e. Commit the fix

```bash
SHORT=$(git rev-parse --short=12 "$SHA")
git add -- R/ tests/ man/ NAMESPACE src/*.cpp src/include/ src/*.dd patch/
# Only if there are staged changes:
git diff --cached --quiet || \
  git commit -m "fix: R-side fix for failing rcc at ${SHORT}"
```

Never `git add` paths under `src/duckdb/`, `inst/include/cpp11/`, or any
flavor file managed by `scripts/lts.sh`.

### 4f. Cherry-pick all remaining commits from `*-dev`

```bash
# Commits on the *-dev branch that come *after* the failing commit
REMAINING=$(git log "${SHA}..krlmlr/${BRANCH}" \
  --first-parent --format="%H" --reverse)

for C in $REMAINING; do
  git cherry-pick "$C" --allow-empty
done
```

Most of these commits are vendor-only and apply cleanly. However, the range
**may include non-vendor commits**: forward-ports from `duckdb/duckdb-r@main`
(glue, R code, CI/CD, cpp11), or later glue-code repairs that were pushed
directly to the `*-dev` branch. That is expected and correct — those
fixes address *subsequent* breakages that were introduced after our fix
point and must be carried forward.

Conflict handling:

- Conflict on `src/duckdb/`, `inst/include/cpp11/`, or `inst/include/cpp11.hpp`:
  should never happen; stop and report.
- Conflict on any other file (glue, `patch/`, `R/`, tests, snapshots): the
  cherry-picked commit is a fix commit whose change overlaps with our own
  fix. Resolve by accepting the cherry-picked version
  (`git checkout --theirs`) or by merging manually, then
  `git cherry-pick --continue`. Do **not** use `--skip` unless the commit
  is genuinely a no-op after our fix.

After all cherry-picks, re-run the final check:

```bash
R CMD check . --no-manual --as-cran 2>&1 | tail -20
```

to confirm the fully-assembled branch is clean.

### 4g. Push the fix branch

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

- **Never** modify `src/duckdb/`, `inst/include/cpp11/`,
  `inst/include/cpp11.hpp`, or any `scripts/vendor*.sh` /
  `scripts/lts.{sh,patch}` file. `patch/` **may** be modified.
- **Never** hand-edit flavor files (`DESCRIPTION` `Package:` field,
  `R/duckdb-package.R`, `src/include/rapi.hpp`'s `DUCKDB_PACKAGE_NAME`,
  `inst/include/duckdb_types.hpp`, `tests/testthat.R`); they are produced
  by `scripts/lts.sh` and should match per-branch.
- **Never** suppress C++ warnings via `#pragma clang diagnostic ignored` or
  similar. Add a `patch/` file that fixes the underlying issue (see
  `AGENTS.md`). CRAN rejects packages that silence warnings.
- **Never** amend commits that have already been pushed.
- **Commit status to check**: context `rcc` (not the full check-run name).
- **Branch target**: all pushes go to the `krlmlr` remote
  (`krlmlr/duckdb-r`) to a branch named `broken-<sha>-dev` (full 40-char
  SHA). The `-dev` suffix is required so `each.yaml` triggers per-commit
  CI on the new branch.
- **Branch scope**: only `*-dev` branches that match `\-dev$` (`main-dev`,
  `v1.5-variegata-dev`, `v1.4-andium-dev`, …); never touch `*-dev-base`,
  `*-dev-old`, `*-dev-broken`.
- Branches being force-pushed to: always use the freshly-fetched
  `krlmlr/*` ref; never rely on any previously-checked-out state.
- **Reproduce locally, do not guess.** GitHub Actions logs are not
  reachable from this environment yet, so every fix must be validated by a
  local `R CMD INSTALL` + `testthat::test_local()` + `R CMD check .` cycle.
  The first `R CMD INSTALL` is slow (10–15 min); do not abort it.
- **Tooling fallback**: if `gh` is not installed, query the
  `/repos/<owner>/<repo>/commits/<sha>/statuses` endpoint via `curl` with
  `GITHUB_TOKEN`, or via a GitHub MCP tool when the agent provides one.
