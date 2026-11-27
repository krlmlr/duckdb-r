# Whether the verdict store can be retired

**A historical record.**
This run was measured on 2026-08-09 against workflows that have since been removed:
`rcc-logs.yaml` and `rcc-consolidate.yaml` both went in #2815,
and `rcc-logs.sh` and `rcc-consolidate.sh` now run by hand
(see [`operations/ci/per-commit/store/`](/handbook/operations/ci/per-commit/store/README.md)).
[`run.sh`](run.sh) cannot be re-run as-is:
measurement 1 counts dispatches of a workflow that no longer exists, so there is nothing left to dispatch,
and measurement 3's premise that nothing is pruned without a run of `rcc-consolidate.yaml` no longer holds,
since consolidation is now a script someone runs from a checkout.
Neither read reports that the workflow is gone.
GitHub still registers `rcc-logs.yaml` as active, with its old runs (165 on 2026-11-21),
so a re-run of measurement 1 prints those stale counts rather than failing.
Only the `rcc-consolidate.yaml` read returns 404, and the script then prints "workflow not found".
Measurement 2, the writer check and the cost of the branch itself still run.

*What it measured:* the three things D6 asked for before the `rcc2` store was cut —
whether the gap it alone covers had ever been felt,
whether the commit status D6 would read instead agrees with the record it would replace,
and what keeping the branch costs in the meantime.
Plus the one thing D6 said to settle with the cut rather than after it:
whether anything but the `each-rcc` leg writes the `rcc` context.

*When and on what:* 2026-08-09 17:11 UTC, against `krlmlr/duckdb-r`,
with `rcc2` at cf4802b and the six live series at the refs the run prints.
`duckdb/duckdb-r` could not answer any of it:
both store workflows then carried `if: github.repository == 'krlmlr/duckdb-r'`,
so every run of them there was skipped,
and the series refs, the `each-rcc` runs and the store live in the fork besides.

*What it supports:* D6 and question 6 of
[`plan/PLAN-vendoring-simplification.md`](/plan/PLAN-vendoring-simplification.md),
as they stood on 2026-08-09.
D6 was declined on 2026-10-15 and the store stays.
The decline rests on the session's proxy refusing GraphQL, which this run hit too (section 2),
and on a REST read costing one call per commit, which this run worked around rather than weighed.
So the verdict below is the one this run reached on 2026-08-09, not the plan's;
what still stands is the record a later weighing of D6 starts from.
The store's own page describes the branch this weighs but does not lean on these numbers.

[`run.sh`](run.sh) reads the API and fetches the fork's refs.
It force-updates the local `refs/remotes/$REMOTE/*` it fetches,
pulls the whole `rcc2` branch (about 220 MB at the time),
and keeps its scratch files under `$OUT`;
it never pushes and never dispatches a workflow.
The full output of the run described here is
[`measured-2026-08-09.txt`](measured-2026-08-09.txt).

The counts move between runs, and that is not noise:
a run was deciding commits while this one was measuring,
so in-flight totals and `pending` counts differ
between two passes minutes apart.
Nothing below turns on those figures to the unit.

## 1. The gap had never been felt — over one day

A `workflow_dispatch` of `rcc-logs.yaml` was a firing saying it needed the store and found it incomplete.
There had been two, ever, both by `krlmlr`:

```
  total: 2   since 2026-08-08: 1
  2026-08-08T09:58:23Z  run 31251750340  by krlmlr  success
  2026-08-07T13:05:27Z  run 31181036396  by krlmlr  success
```

Neither was a firing that needed the store.
Both predate #2578, which merged at 2026-08-08T14:46:49Z,
and the later one is the verification dispatch that PR's own body names —
run 31251750340, dispatched *before* changing anything
to confirm the route the skill was about to depend on.
So the count since the schedule stopped was **zero**.
The workflow had 118 runs in all;
the script reads only the first page of 100, newest first,
and of those 76 are `schedule`,
22 are `push` (the workflow exercising itself on a change to its own paths),
and 2 are the dispatches above.
The run does not print timestamps for the `schedule` runs,
so it does not show when the last of them fired.

**The number was right and the window was not.**
Zero dispatches is what question 6 wanted,
but it had only been possible to dispatch-and-not for **1.1 days**.
Question 6 asked for a full cycle, and this was not one.

## 2. The replacement agreed, everywhere it was asked

Two answers per commit in `<S>-green..<S>-dev`, over all six live series:
a record via [`scripts/rcc-decided.sh`](/scripts/rcc-decided.sh),
which is what selection reads,
and an `rcc` commit status of `success` or `failure`,
which is what D6 would have read instead.
`pending` and absent are undecided on both sides.

```
  main: 0 in flight
  main-fwd: 409 in flight
  v1.4-andium: 0 in flight
  v1.4-andium-fwd: 1 in flight
  v1.5-variegata: 0 in flight
  v1.5-variegata-fwd: 10 in flight
  total: 420 commits
  status side:     372 none      23 pending      25 success
  decided by status: 25   by record: 25
  disagreements:
    (no lines above means the two answers agree on every commit in flight)
```

No status without a record, no record without a status,
and — checked beyond what D6 needs — no commit where the two name a different state.

**On its own this is a thin sample.**
The range is bounded by `-green`, so 395 of the 420 were simply not built yet;
25 decided commits is not a go signal.
So the run asks the same question of the sample the range cannot give:
the store's 250 newest records, every one of them decided by construction,
each a chance for a record to exist where a status does not.

```
  agree: 250   disagree: 0   (of 250)
```

That is the direction that would break D6 — a record the status read cannot see —
and it did not happen in 250 consecutive verdicts.

The batched GraphQL query D6 would actually make is in the script,
recovered from `each-plan.sh`'s pre-D1 form (#2440),
and it did not run here:
the token this session held served only a pinned set of GraphQL operations.
That is the refusal the 2026-10-15 decline names.
The REST answer above is the same question by a route every token serves,
at one request per commit instead of one per hundred —
which is why the pre-D1 planner batched, and why D6's read would have had to.

## 3. Keeping it cost 223 MB and about 400 commits a day

```
  commits: 1563
  records: 8453
  logs:    4242
  total      21447 objects    2651.3 MB  (223.0 MB packed)
  oldest record: 2026-04-11T11:43:01Z
  retention window: RCC_RETENTION_DAYS=180 days
  runs of rcc-consolidate.yaml (nothing is pruned without one):
    total: 0
```

`rcc-consolidate.yaml` had **never run** — not once, by anyone, dry or otherwise.
So nothing had been pruned since the cutover minted the branch on 2026-08-05,
and the 1562 commits above the root were 4.0 days of verdicts: about 389 a day.
"Nothing is pruned without one" was true of that workflow on that day;
consolidation now runs by hand, so a run of `run.sh` today cannot count it.

Two things followed that the retention window alone would not tell you.

**A consolidation dispatched that day would have dropped nothing.**
The oldest surviving record was 120 days old against a 180-day window.
Retention was not what was deferred; the squash was.
The whole of what consolidation would have bought then was
1563 commits collapsing to 2.

**The bill is the copy, not the verdicts.**
Records are ~2 KB and there were 8453 of them;
the 223 MB was the 4242 harvested logs,
which is what the branch exists to make readable without an API.

## What the run concluded, on 2026-08-09

The run's verdict at the time was *proceed after a cycle of notice*.
D6 was declined on 2026-10-15 instead, and the store stays (§3.3 of the plan);
the paragraphs below are what the run concluded, not what was done.

Measurement 2 was D6's go/no-go and it said go:
the status read agreed with the record read on every commit either was asked about, states included,
and the `rcc` context on every one of those commits was written by the leg.
Measurement 3 said the standing bill was real, dull and bounded.
Measurement 1 was the only one that did not yet support cutting:
the count was zero, but one day is not the cycle question 6 asked for.

So the run proposed keeping the branch and the leg's publish for one full series cycle,
re-running measurement 1, and cutting if the dispatch count was still zero,
with `series-check.sh` ported off `git show` first, since every outcome needed that.

## The wrinkle was not hypothetical

D6 said the `rcc` context is not the leg's alone,
and to decide with the cut whether the per-commit verdict gets its own.
The fork already contained the answer.

`R-CMD-check.yaml` runs from the branch it checks, so every series ref carries its own copy of the push filter.
On 2026-08-09 all six `-dev` branches carried `main`'s:

```
    v1.5-variegata-dev: [main master release next cran-*]
```

None of those patterns matches a series ref,
so the plan's claim held — nothing but the leg wrote `rcc` on a `*-dev` branch.
The run verifies that twice over:
statically, in the filter on every live series' `-dev`,
and empirically, in all 73 `rcc` status posts across the 420 commits in flight
and every post across the 250 widened commits, each of them `each-rcc / shard N`.

But the claim was a ported commit deep, and it was **already false one ref over**:

```
    v1.4-andium-build: [main master release next cran-* v*.*-*]
      FIRES ON ITSELF via 'v*.*-*' -- a second writer of the rcc context
    on a series ref: 2026-08-06T16:49:08Z  v1.4-andium-build-base  push  head=6e7dd75ce  failure
    on a series ref: 2026-08-06T15:18:29Z  v1.4-andium-build-base  push  head=6e7dd75ce  failure
    on a series ref: 2026-08-06T09:24:01Z  v1.4-andium-build-base  push  head=6e7dd75ce  failure
    on a series ref: 2026-08-06T09:23:58Z  v1.4-andium-build  push  head=6e7dd75ce  failure
    6e7dd75ce2fe15d3e707814edf0d3db5d26ed4c0
      rcc statuses: 11, newest failure (rcc)
      record on rcc2: NO
      in a <S>-green..<S>-dev range now: no
```

`v1.4-andium-build`'s copy of the workflow was from 2026-03-26
and still carried the `v*.*-*` release-branch pattern, which matches its own name.
Four pushes on 2026-08-06, all with head `6e7dd75ce`, started the template check on the buffer refs:
one on `v1.4-andium-build`,
and three on `v1.4-andium-build-base`, whose own copy of the filter the run did not read
but whose name the same pattern matches.
`R-CMD-check-status.yaml` then stamped `rcc=failure` on `6e7dd75ce` —
a **status without a record**, exactly the class D6's read would misread, sitting in the fork.

It was harmless for one reason only, and the run checks it rather than assuming it:
a buffer commit is re-minted when it is consumed onto `-dev`,
so its SHA never enters selection's range.

```
    SHAs shared between (<S>-build-base..<S>-build) and (<S>-green..<S>-dev):
      main: 0 … v1.5-variegata-fwd: 0
```

That is a property of buffer/dev lineage, not of the context.
The `-dev` copies were clean because the port stage keeps them level with `main`;
the buffer was dirty because ports never touched it (F4's stated blind spot).
A `-dev` branch regaining the glob —
a series opened from an old buffer, a forward that replays onto a stale seed —
would put a whole-branch matrix verdict directly into selection's range,
where D6 would have read it as the commit's own.

So the run's answer to D6's wrinkle, on 2026-08-09, was not "decide it with the cut":
give the per-commit verdict its own context **before** any status read goes in.
The 2026-10-15 decline keeps that as one of the constraints a later weighing starts from:
a dedicated `each-rcc` context whose `target_url` names an `each.yaml` run.
