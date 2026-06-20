# Vendoring as an Agentic Loop — Design Plan

Status: **proposal / plan** (not yet implemented).
Target repo for implementation: `krlmlr/duckdb-r` (the CI/CD fork; see
[`BRANCHES.md`](../BRANCHES.md)). Source-of-truth CI/CD lives in
`duckdb/duckdb-r@main` and is forward-ported.
Author context: drafted on branch `claude/vibrant-ride-i4b5r2`.

This document proposes a re-architecture of the DuckDB-R vendoring pipeline as
a **modular agentic loop**: Claude drives the creative steps, while GitHub
Actions runs the predictable, parallelisable work and serves as the single
**ground truth** for build results. It builds directly on the existing system
documented in [`BRANCHES.md`](../BRANCHES.md) and
[`scripts/VENDORING.md`](VENDORING.md), and supersedes parts of the
three repair skills in `.claude/skills/`.

---

## 1. Where we are today (baseline)

| Concern | Today | Mechanism |
|---|---|---|
| **Vendor** upstream C++ into `*-dev` | hourly, commit-by-commit, ≤30/run | `vendor.yaml` → `scripts/vendor-one.sh ./duckdb --commits 30` |
| **Trigger** per-commit CI | fire-and-forget dispatch, no cap | `each.yaml` → `scripts/each-rcc.sh` → `gh workflow run rcc -f ref=<sha>` |
| **Build / smoke-test** a commit | one independent `rcc` run per commit | `R-CMD-check.yaml` (job *Smoke test: stock R*) |
| **Record** the result marker | commit-status `rcc` = pending/success/failure | `R-CMD-check-status.yaml` (via `workflow_run`) |
| **Harvest** logs to ground truth | **delayed**, 4×/day | `rcc-logs.yaml` → `scripts/rcc-logs.sh` → orphan branch `rcc` (`runs2.ndjson`, `logs2/<sha>.log`) |
| **Repair** a red commit | fork `broken-<sha>-dev`, amend the failing commit, **cherry-pick (replay) the whole tail**, force-push | skill `rcc-smoke-fix.md` |
| **Advance** a repaired branch | cherry-pick next 30 vendor commits, matched by vendored upstream SHA | skill `advance-green-dev.md` |
| **Self-heal** transient breaks | squash (window 1) / transient patch (≥2) | skill `rcc-smoke-fix-self-heal.md` |
| **Promote / publish** | r-universe builds `.dev` **directly from `*-dev`** (bleeding edge); promotion to `-dev-base`/stable is **manual** | `BRANCHES.md` patch-release flow |

### Pain points this plan addresses

1. **Latency to ground truth.** Build logs land on the `rcc` branch only on the
   4×/day `rcc-logs.yaml` schedule — long after a run completes. The loop wants
   results *right after completion*.
2. **r-universe coupled to bleeding edge.** Because r-universe publishes from
   `*-dev`, any red tip breaks the published `.dev` package. There is no
   decoupled "known-green" source.
3. **Replay cost & branch sprawl.** `broken-<sha>-dev` forks plus full-tail
   cherry-picks create parallel histories and re-run CI on commits that were
   already green.
4. **No bounded backlog.** Nothing caps how far `*-dev` may run ahead of the
   last green build, so the repair debt is unbounded.

---

## 2. Design principles

- **Separation of concerns.** Four orthogonal primitives — *vendor*, *build*,
  *promote*, *repair* — each independently invokable and individually testable.
- **GHA is ground truth, Claude is the brain.** Everything deterministic
  (vendoring, building, status-keeping, promotion) runs in GHA. Claude only
  performs the irreducibly creative step: **repair**. The loop never trusts
  Claude's local build over the GHA marker.
- **Modularity over a monolith.** Each primitive is callable three ways — by
  Claude (tight loop), by a `schedule:` cron, or by an external API call /
  `workflow_dispatch` / `workflow_call`. No primitive assumes who invoked it.
- **Indistinguishable markers.** The new build path produces the *same* commit
  statuses (context `rcc`) and the *same* `rcc`-branch records as today, so
  every existing consumer (the skills, dashboards, `advance-green-dev`) keeps
  working unchanged.
- **Bounded work.** Normal batches are ≤25 commits. The bleeding edge may run
  at most **25 commits ahead of its first failing build**, capping repair debt.

---

## 3. Target architecture

### 3.1 Branch model — decouple the r-universe source

Introduce a new **`*-green` branch** per release line as the *only* thing
r-universe builds from. (Decision: a dedicated branch, distinct from
`*-dev-base`, which keeps its current meaning in the release flow.)

```
duckdb/duckdb (upstream)
      │  vendor (bounded)
      ▼
krlmlr/duckdb-r@*-dev          ← bleeding edge; may be red, but ≤25 commits
      │                          ahead of its first failing build (the frontier)
      │  deterministic promotion (GHA): fast-forward to the
      │  longest all-green contiguous prefix
      ▼
krlmlr/duckdb-r@*-green        ← ALWAYS green; r-universe publishes .dev from HERE
```

Mapping (illustrative, mirror for every active line):

| Line | bleeding edge (`*-dev`) | green source (`*-green`, NEW) | published as |
|---|---|---|---|
| main | `main-dev` | `main-green` | `duckdb.dev` |
| v1.5 | `v1.5-variegata-dev` | `v1.5-variegata-green` | `duckdb.1.5.dev` |
| v1.4 | `v1.4-andium-dev` | `v1.4-andium-green` | `duckdb.1.4.dev` |

Invariants:

- `*-green` is always a **first-parent ancestor** of `*-dev`.
- Every commit reachable from `*-green` has `rcc` status `success`.
- The **frontier** = the first commit after `*-green`'s tip on `*-dev` whose
  `rcc` status is not `success` (red or, transiently, absent). The distance
  `green-tip … frontier` must stay ≤ 25; the vendor primitive refuses to extend
  `*-dev` beyond that until the frontier is repaired.

> r-universe repointing (`*-dev` → `*-green`) is a config change in the
> r-universe org's package registry, done once per line at rollout (see §7).

### 3.2 The four primitives

```
 ┌──────────────┐   ┌─────────────────────────┐   ┌────────────────────┐
 │ A. VENDOR     │──►│ B. BUILD (sharded matrix)│──►│ C. PROMOTE (green) │
 │ append ≤N     │   │ build+test, write status │   │ ff *-green to the  │
 │ vendor commits│   │ + log to `rcc` branch    │   │ green prefix (GHA) │
 │ to *-dev      │   │ SYNCHRONOUSLY            │   │                    │
 └──────────────┘   └─────────────────────────┘   └────────────────────┘
        ▲                       │ frontier is red                │
        │                       ▼                                │
        │             ┌────────────────────┐                     │
        └─────────────│ D. REPAIR (Claude)  │◄────────────────────┘
                      │ amend/squash IN     │
                      │ PLACE on *-dev,     │
                      │ force-push          │
                      └────────────────────┘
```

#### A. Vendor primitive *(extends `vendor-one.sh` / `vendor.yaml`)*

- Input: `(dev-branch, upstream-branch, budget)`.
- Effect: append ≤ budget vendor commits to `*-dev`, re-apply `patch/`, push.
- **New guard:** before appending, compute the frontier distance; if `*-dev`
  is already ≥25 commits ahead of its first failing build, **do not vendor more
  commits** — emit a status and stop. This is the bound from §3.1.
- Unchanged: commit-message format, `duckdb/duckdb@<sha>` marker, patch-drop
  behaviour.

#### B. Build primitive — synchronous **sharded matrix** CI *(NEW: `rcc-matrix.yaml`)*

Replaces fire-and-forget dispatch (`each-rcc.sh`) **and** the 4×/day harvest
(`rcc-logs.yaml`). One workflow that, given a branch and a set of commits:

1. **Plan step** enumerates the target commits (default: every commit between
   `*-green` tip and `*-dev` tip lacking a current `rcc` success), orders them
   first-parent oldest-first, and partitions them into **shards** (see §4).
2. **Matrix step** — one leg per shard. Each leg, for each commit in its shard
   *in chronological order*:
   - checks out the commit, builds from source + runs the smoke test,
   - sets the `rcc` commit-status (pending→success/failure), **and**
   - **pushes its `{commit,status,run}` record + log tail to the `rcc` branch
     immediately on completion** (append `runs2.ndjson`, write
     `logs2/<sha>.log`), using a `git pull --rebase` retry loop so concurrent
     shard pushes serialise cleanly (the orphan branch is append-only, so
     conflicts auto-merge).
3. Markers are **byte-compatible** with today's (context `rcc`, same ndjson
   schema, same `logs2/<sha>.log` layout).

Invocation (all three supported — the workflow doesn't care who called it):

- **Claude tight loop:** `workflow_dispatch` with an explicit commit range,
  then wait on run completion and read the `rcc` branch.
- **Scheduled:** `schedule:` cron replaces the hourly each + 4×/day harvest.
- **From another workflow / API:** `workflow_call` (e.g. invoked by the vendor
  primitive right after it pushes) or `repository_dispatch` from an external
  API caller.

> **ccache is mandatory here** (see §4): consecutive vendor commits change only
> a handful of the ~1700 `src/duckdb/` files, so within a shard the second and
> later builds are mostly cache hits. The `DUCKDB_R_USE_SYSTEM_LIB` fast path
> from `AGENTS.md` is *not* usable — we are validating that each commit builds
> *from source* — so ccache is the substitute for that speed-up.

#### C. Promote primitive — deterministic green advance *(NEW: `promote-green.yaml` + `scripts/promote-green.sh`)*

A pure function of commit statuses; **no building, no judgement, fully in GHA**:

- Walk `*-dev` first-parent from the `*-green` tip forward.
- Advance a cursor while each commit's `rcc` status is `success`.
- Fast-forward `*-green` to the last such commit and push.
- Stop at the first non-success commit (the frontier) — never skip it.

Idempotent and safe to run on any trigger (post-build `workflow_call`, cron, or
Claude). Because `*-green` only ever fast-forwards along `*-dev`, r-universe
always sees a clean, buildable, monotonically advancing history.

#### D. Repair primitive — agentic, **in place** *(evolves `rcc-smoke-fix.md`)*

When the frontier is red, Claude repairs it **directly on `*-dev`**, not on a
`broken-<sha>-dev` fork:

- Reproduce locally (triage from `logs2/<sha>.log` first; full `R CMD INSTALL`
  to confirm), apply the smallest fix in the existing priority order
  (`patch/` → glue → `R/` → snapshots → tests).
- **Amend or squash the fix into the failing commit itself**, then let
  `git rebase` carry the descendants forward mechanically (their *content* is
  unchanged — adjacent vendor commits are independent snapshots — so no replay
  / re-derivation is needed). Force-push `*-dev` (allowed; `*-dev` is
  unprotected per `BRANCHES.md`).
- The self-heal cases (squash window 1 / transient patch ≥2) from
  `rcc-smoke-fix-self-heal.md` carry over unchanged, now applied in place.

This is the "fix by amending/squashing the failing run and **not replaying the
rest**" model. See §6 for the hybrid transition away from `broken-<sha>-dev`.

### 3.3 The loop / orchestration

Each iteration (driven by Claude, or by a chained set of GHA triggers):

```
1. VENDOR   A: append ≤budget commits to *-dev, respecting the ≤25 bound.
2. BUILD    B: synchronously build all commits lacking a green status;
               wait for ground truth on the `rcc` branch.
3. PROMOTE  C: fast-forward *-green over the all-green prefix.
4. REPAIR?  if a red frontier exists:
              D: amend/squash it in place, force-push *-dev;
              GOTO 2 — but only for the rewritten range (new SHAs only).
            else: iteration done.
```

The loop terminates an iteration when `*-green == *-dev` (fully caught up) or
when the bound is hit and the frontier still needs human/Claude attention.
Ground truth is *always* re-read from GHA between steps; Claude never advances
`*-green` on the strength of a local build.

---

## 4. Scaling the matrix beyond 256 jobs (force-push / large backlogs)

GitHub caps a matrix at **256 jobs per workflow run**. Normal batches (≤25
commits) fit one shard trivially. The hard case is a **force-push** (a repair
deep in history, or a rebase) that rewrites hundreds–thousands of descendant
SHAs, all of which lose their `rcc` status and must be (re)built. Strategy, in
priority order:

1. **Sharded sequential build + ccache (primary).** Partition the ordered
   commit list into `S` contiguous shards with `S ≤ 256`. Each matrix leg
   builds its shard's commits *in chronological order* reusing a warm ccache;
   after the shard's first (cold-ish) build, the rest are mostly cache hits
   because consecutive vendor commits touch few files. Choose shard size so
   wall-clock per shard is bounded (target ≈30–60 min); `S = ceil(N / shard)`.
   Each commit still emits its own status + log the moment it finishes.

2. **Persistent / shared ccache layer.** Restore ccache via `actions/cache`
   (key on compiler + flags; content-addressed so identical translation units
   hit regardless of commit), and/or a ccache **secondary storage**
   (`--secondary-storage`, e.g. an HTTP/S3 cache) so the cache survives across
   shards *and* across runs. This is what makes 255+ rebuilt commits affordable
   after a force-push: nearly every `.o` is already cached from the pre-rewrite
   history (same content, new commit SHA → same ccache hash).

3. **Only-missing-status filtering + frontier-first.** Never rebuild blindly.
   Build only commits without a current `rcc=success`. Order shards so the
   **frontier region** (the next ≤25 commits past `*-green`) is built *first*,
   so promotion can advance immediately; backfill the rest in later shards/runs.

4. **Multi-run continuation (overflow).** If `N` still exceeds
   `256 × shard_size`, the plan step builds the first `256 × shard_size`
   commits and re-dispatches itself (`workflow_call`/`repository_dispatch`) for
   the remainder, advancing as `*-green` moves. This makes the matrix CI handle
   arbitrarily large backlogs across runs without exceeding the per-run cap.

5. **(Optional) coarse bisection to *locate* failures only.** For locating the
   *next* break far ahead of the frontier, a sampled (every-k-th) build can find
   the first red region cheaply. But promotion needs a *contiguous* green prefix,
   so the prefix itself must be built fully; sampling only helps scheduling, not
   promotion.

Open implementation choice: `actions/cache` vs a self-hosted ccache server vs
S3 secondary storage. See §8 Q1.

---

## 5. Modularity & invocation matrix

| Primitive | Claude (tight loop) | Scheduled (cron) | API / chained GHA |
|---|---|---|---|
| A Vendor | dispatch + wait | hourly (as today) | `workflow_call` from orchestrator |
| B Build | dispatch range + wait, read `rcc` branch | cron (replaces each + harvest) | `workflow_call` after vendor; `repository_dispatch` |
| C Promote | dispatch + read tip | cron (frequent, cheap) | `workflow_call` after build |
| D Repair | Claude does the work | n/a (needs Claude) | triggered by a "frontier red" signal (status / issue / `repository_dispatch`) |

Each primitive reads its inputs from ground truth (git refs + `rcc` branch) and
writes only its own outputs, so any subset can run in any order without a shared
orchestrator. A "tight loop" is just Claude calling A→B→C→(D)→B… ; a
"hands-off" mode is the same primitives wired by GHA triggers, with D raised to
Claude only when a red frontier is detected.

---

## 6. Migration / transition (hybrid)

Decision: **hybrid** — stand up the new model without breaking the existing
`broken-<sha>-dev` skills during transition.

- **Phase 0 — additive plumbing.** Add `rcc-matrix.yaml`, `promote-green.yaml`,
  `scripts/promote-green.sh`, and create `*-green` branches at the current
  `*-dev-base` tips. Run the new build path **in parallel** with the existing
  `each`/`rcc-logs` path; verify markers are byte-identical. r-universe stays on
  `*-dev` for now.
- **Phase 1 — cut over reads.** Point the matrix build at the orphan-branch
  push, confirm `advance-green-dev.md` and `rcc-smoke-fix.md` still read correct
  status. Repoint r-universe `.dev` packages to `*-green` (one line at a time,
  starting with the least critical, e.g. v1.4).
- **Phase 2 — cut over repair.** Switch the repair primitive to in-place
  amend/squash on `*-dev`. Keep `broken-<sha>-dev` + `advance-green-dev`
  available as a fallback until in-place repair has handled several real breaks.
- **Phase 3 — retire the async path.** Remove fire-and-forget dispatch and the
  4×/day harvest once the matrix path is authoritative. Fold the surviving
  repair logic into a single updated skill; archive `advance-green-dev.md`
  (catch-up becomes automatic promotion) and the fork-specific parts of
  `rcc-smoke-fix.md`.

Roll back at any phase by reverting r-universe to `*-dev` and re-enabling the
async workflows; the branch model and markers are unchanged, so no data is lost.

---

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Concurrent shard pushes clobber the `rcc` branch | append-only ndjson + per-file logs + `git pull --rebase` retry loop (already proven in `rcc-logs.sh`) |
| ccache cold after a force-push → slow recovery | persistent/secondary ccache keyed by content (§4.2); content is mostly unchanged across the rewrite |
| Matrix > 256 jobs | sharding + multi-run continuation (§4.1, §4.4) |
| In-place force-push on `*-dev` races with hourly vendor | single concurrency group across A/D per line; vendor guard refuses while a repair is open |
| r-universe build of `*-green` still fails despite green `rcc` | `rcc` smoke test must be a faithful subset of the r-universe build env; add an r-universe-parity check to the smoke job before cut-over |
| Promotion advances over a *transiently* green commit | promote only on `success`; self-heal handling (squash/transient) runs in repair before promotion |
| Bound (≤25) too tight/loose | make it a workflow input / repo variable; default 25 |

---

## 8. Open questions (for implementation)

1. **ccache backend:** `actions/cache` (simple, 10 GB/repo limit, eviction) vs a
   self-hosted ccache server vs S3 secondary storage (durable, no eviction, more
   setup). Which fits the krlmlr Actions budget?
2. **Shard sizing:** fixed commits-per-shard, or adaptive to keep wall-clock
   ≈30–60 min/shard? Initial guess: 8–12 commits/shard.
3. **`*-green` bootstrap point:** create from current `*-dev-base`, or from the
   latest already-green `*-dev` commit per line?
4. **r-universe parity:** how closely must the `rcc` smoke job mirror the
   r-universe build matrix to guarantee `*-green` is installable there?
5. **Repair trigger in hands-off mode:** GitHub issue, a dedicated commit
   status, or `repository_dispatch` to wake a Claude session?
6. **Bound semantics:** is the ≤25 measured in commits, or should tagged
   upstream releases always be allowed through regardless of distance?

---

## 9. Concrete first deliverables (Phase 0)

1. `scripts/promote-green.sh` — deterministic green fast-forward (pure git +
   `rcc` status reads from the orphan branch).
2. `.github/workflows/promote-green.yaml` — wraps (1); `schedule` +
   `workflow_call` + `workflow_dispatch`.
3. `.github/workflows/rcc-matrix.yaml` — plan + sharded matrix build with ccache
   and immediate per-commit `rcc`-branch push.
4. Vendor guard: add the ≤25-ahead-of-frontier check to `vendor-one.sh` /
   `vendor.yaml`.
5. Create `*-green` branches; document the model in `BRANCHES.md` and
   `scripts/VENDORING.md`.
6. Parallel-run validation harness comparing new vs old markers byte-for-byte.

Items (1)–(2) are the smallest useful slice and have no dependency on the matrix
work, so they can land first and be exercised against today's `rcc` markers.
