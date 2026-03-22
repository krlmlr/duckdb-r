# Branch Overview

This document summarises the branches in this repository that are ahead of `main`, covering what they contain, their likely purpose, and whether they could be merged.

All commit counts and file lists reflect the state at the time of writing (March 2026).

---

## Active / Continuously Updated

### `v1.5-variegata-dev` — 45 commits ahead

**Contents:** Exclusively automated `vendor:` commits that vendor-update the DuckDB C++ core from the upstream `duckdb/duckdb` repository to the v1.5 "variegata" development line.

**Purpose:** Staging branch for the next major DuckDB version. The vendoring automation pushes here instead of directly to `main` so that CI can validate the upstream commits before promotion.

**Files changed:** `R/version.R` and bulk changes under `src/duckdb/` (C++ source, unity-build files). 158 files, ~2 800 insertions / 773 deletions.

**Merge-ability:** ✅ Intended to be merged (or rebased/squashed) into `main` when the v1.5 release is ready. The commits are purely mechanical vendor updates with no manual changes. The only prerequisite is passing CI on this branch.

---

### `rwasm` — 14 commits ahead (last activity: Sep 2025)

**Contents:** Adds WebAssembly (WASM) build support for the R package. Key changes:
- `configure` / `Makevars` / `Makevars.in`: conditional compilation flags for `WASM_LOADABLE_EXTENSIONS`, thread-disabled builds, and a custom platform string.
- `src/duckdb/src/main/extension/extension_load.cpp`: upstream patch for WASM loadable extensions (sourced from `duckdb-wasm`).
- `DESCRIPTION` / `NEWS.md`: version bump to `1.4.0.9004`.
- `revdep/`: results from reverse-dependency checks.

**Purpose:** Experimental port of DuckDB-R to WebAssembly, enabling DuckDB to run in the browser (e.g. via webR). Supports both persistent and in-memory databases, loadable extensions, and a no-threads build variant.

**Files changed:** 9 files, 149 insertions / 7 deletions.

**Merge-ability:** ⚠️ Probably not ready to merge as-is. The `configure` / `Makevars` changes need careful review to avoid breaking native builds, and the upstream `extension_load.cpp` patch should ideally be accepted upstream first. The version bump commit would create a conflict. Coordination with the `duckdb-wasm` project is needed.

---

## Experimental CI / Build Infrastructure

### `acache` — 18 commits ahead (last activity: Sep 2023)

**Contents:** Prototype of a prebuilt-archive cache for DuckDB compilation. Adds a `DUCKDB_R_PREBUILT_ARCHIVE` environment variable: when set and the file exists, `src/Makevars` uses `include/copy.mk` (copies the prebuilt `.so`) instead of `include/sources.mk` (full compilation). Also parallelises the CI build step.

**Files changed:** 13 files (Makevars, CI workflow, `rconfigure.py`, `.gitignore`).

**Merge-ability:** ❌ Not ready. Several commits are explicitly tagged `REVERT ME:`. This was an experiment to speed up CI by caching compilation artefacts; it was superseded by the `bcache` branch and never stabilised.

---

### `bcache` — 73 commits ahead (last activity: Sep 2023)

**Contents:** More advanced binary-cache implementation for CI. Adds `include/to-tar.mk`, `include/from-tar.mk`, and `include/to-tar-win.mk` to pack/unpack compiled object files into a tarball, avoiding full recompilation across CI runs. Includes cross-platform fixes (Windows `--force-local`, avoidance of `realpath` on macOS, quote handling) and a large number of iteration/tweak commits.

**Files changed:** 13 files (Makevars, CI workflows, new makefile fragments).

**Merge-ability:** ❌ Not ready. The high commit count (73) is largely iterative debugging; many commits have poor messages (single digits `1`–`7`, `Bump`, `Wat`). The work was in-progress when it stalled. Would need to be cleaned up / squashed before consideration.

---

### `ccache` — 9 commits ahead (last activity: Sep 2023)

**Contents:** Adds [ccache](https://ccache.dev/) compiler caching to CI workflows. Modifies `.github/workflows/R-CMD-check.yaml` and `install/action.yml` to install ccache and inject it into the compiler path. Also contains a revert of an unrelated test change.

**Files changed:** 5 files (CI workflows, `.Rbuildignore`, `.gitignore`, one test file).

**Merge-ability:** ⚠️ The ccache integration itself is generally useful but the branch also carries an unrelated test revert. Splitting off the ccache-only changes and rebasing on current `main` would be needed.

---

### `devtest` — 11 commits ahead (last activity: Sep 2023)

**Contents:** Restructures the CI dependency matrix and adds Arrow integration testing. Adds a `dep-matrix/action.yml` reusable action that determines which version of Arrow/ADBC/adbcdrivermanager to install (from binary or source). Also installs ccache earlier in the CI pipeline.

**Files changed:** 4 files (CI workflow files only).

**Merge-ability:** ⚠️ Contains a `REVERT ME: Debug Arrow` commit; not in a mergeable state. The underlying ideas (richer dependency matrix, earlier ccache install) may be worth extracting.

---

### `gcc13` — 4 commits ahead (last activity: Sep 2023)

**Contents:** CI experiment to test DuckDB-R compilation with GCC 13. Adds GCC 13 to the test matrix in `.github/workflows/R-CMD-check.yaml`. Contains two `REVERT ME:` commits (simplify matrix, tmate debugging session).

**Files changed:** 1 file (CI workflow).

**Merge-ability:** ❌ Not mergeable as-is due to `REVERT ME:` commits. The intent (GCC 13 compatibility testing) is valuable but this branch was exploratory and stale.

---

## Feature Experiments

### `f-no-ext` — 4 commits ahead (last activity: Sep 2023)

**Contents:** Experiment to build DuckDB without bundled extensions, relying on the autoloading mechanism instead. `rconfigure.py` sets `extensions = []` and adds `-DDUCKDB_BUILD_LIBRARY`. The `Makevars` / `Makevars.win` and `src/sources.mk` are regenerated accordingly.

**Files changed:** 4 files (rconfigure.py, Makevars, Makevars.win, sources.mk).

**Merge-ability:** ❌ Not ready. This conflicts with the standard release build which bundles extensions. It would require an explicit opt-in mechanism and has been idle since 2023.

---

## CRAN / Release Preparation

### `cran-main` — 15 commits ahead (last activity: Aug 2023)

**Contents:** Infrastructure and documentation for CRAN submissions:
- `RELEASE.md`: step-by-step CRAN release process (reverse dependency checks, WinBuilder, etc.)
- `_pkgdown.yml`: pkgdown site configuration.
- `CMakeLists.txt` / `src/CMakeLists.txt`: dummy CMake files for IDE include-path recognition.
- `.editorconfig`, `.vscode/`: editor configuration.
- `duckdb.Rproj`: RStudio project file.
- `vendor.sh`: vendoring script.
- Minor tweaks to `DESCRIPTION`, `README.md`, `rconfigure.py`, `Makevars.in`, and third-party source newlines.

**Files changed:** ~60 files (mix of infrastructure and third-party EOL fixes).

**Merge-ability:** ⚠️ Most of the useful changes (release docs, pkgdown, editor config) could be merged, but the branch also modifies many third-party source files for EOL normalisation, which would create noise. Best merged selectively or after rebasing to drop the vendored-source changes.

---

## Historical / Archive

### `dev` — 4 commits ahead (last activity: Sep 2023)

**Contents:** Old development branch that tracks upstream DuckDB merges: ASOF join performance, out-of-order chunk aggregation, R CI fix. Also adds a `duckdb_extension_config.cmake` that lists `visualizer`, `parquet`, and `icu` as built-in extensions, and minor test adjustments.

**Files changed:** 4 files (CMake extension config, 3 test files).

**Merge-ability:** ❌ The extension config references a CMake build path that is not used by the R package's standard build. The upstream code changes are already included in the vendored sources of `main`. Not worth merging.

---

### `hannes-main` — 22 commits ahead (no common merge base with `main`)

**Contents:** The earliest bootstrap branch by the original author (Hannes Mühleisen), dating from August 2023. It set up the initial repository from a git-submodule approach, added the first CI workflow (`r.yml`), and established the basic package structure. Later commits on this branch added editor config, `.gitattributes`, dummy CMakeLists.txt, and early vendoring infrastructure that have since been superseded.

**Merge-ability:** ❌ This branch has no merge base with `main`, meaning it predates the current `main` history. Its useful content was already incorporated when the repository was restructured. It is effectively an archive of the initial bootstrap effort.

---

### `gh-pages` — 3 commits ahead (no common merge base with `main`)

**Contents:** The GitHub Pages deployment branch used by `pkgdown` for the documentation site. Contains the rendered HTML/CSS/JS site files. Initialised as an orphan branch.

**Merge-ability:** ❌ Should never be merged into `main`. It is a separate deployment target managed by pkgdown / CI automation.

---

## Summary Table

| Branch | Commits ahead | Last active | Purpose | Merge-able? |
|---|---|---|---|---|
| `v1.5-variegata-dev` | 45 | Mar 2026 | Vendor updates for v1.5 | ✅ When CI passes |
| `rwasm` | 14 | Sep 2025 | WebAssembly port | ⚠️ Needs upstream coordination |
| `bcache` | 73 | Sep 2023 | Binary compilation cache for CI | ❌ Stale, messy history |
| `cran-main` | 15 | Aug 2023 | CRAN release infrastructure | ⚠️ Selectively |
| `acache` | 18 | Sep 2023 | Prebuilt archive cache for CI | ❌ Stale, `REVERT ME` commits |
| `devtest` | 11 | Sep 2023 | Arrow/ADBC CI matrix | ⚠️ Partially, needs cleanup |
| `ccache` | 9 | Sep 2023 | Compiler ccache for CI | ⚠️ Needs rebase + split |
| `f-no-ext` | 4 | Sep 2023 | No-extensions build | ❌ Stale experiment |
| `gcc13` | 4 | Sep 2023 | GCC 13 CI test | ❌ `REVERT ME` commits |
| `dev` | 4 | Sep 2023 | Old upstream merge tracking | ❌ Superseded |
| `hannes-main` | 22 | Aug 2023 | Initial bootstrap | ❌ No merge base |
| `gh-pages` | 3 | — | Pkgdown site | ❌ Deployment branch |
