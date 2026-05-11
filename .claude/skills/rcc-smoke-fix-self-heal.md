Sub-skill of `rcc-smoke-fix`. Invoke only when, while walking
`*-dev` commits oldest-first, you observe a `success` for `rcc` on a
commit **later** than the earliest `failure` without anyone having
fixed it. The break is transient — upstream "self-heals" — and the
default single-commit workflow would double-record the fix.

Two strategies, gated on window width:

| Width  | Strategy        | Audit trail                                                       |
|--------|-----------------|-------------------------------------------------------------------|
| 1 commit | Squash       | Amended commit replaces both `FIRST_FAIL` and `HEAL_AT`; both upstream messages quoted. |
| ≥ 2    | Transient patch | `patch/NNNN-transient-*.patch` added at `FIRST_FAIL`, removed at `HEAL_AT`. |

## Detect

Continue the Step 3 walk forward from `$FIRST_FAIL`:

```bash
HEAL_AT=""; LAST_FAIL="$FIRST_FAIL"; seen=0
while IFS= read -r SHA; do
  if [[ "$seen" == 0 ]]; then
    [[ "$SHA" == "$FIRST_FAIL" ]] && seen=1
    continue
  fi
  STATUS=$(lookup_rcc_status "$SHA")
  if is_rcc_failure "$STATUS"; then LAST_FAIL="$SHA"; continue; fi
  if [[ "$STATUS" == "success" ]]; then HEAL_AT="$SHA"; break; fi
  # pending/none/error → cannot prove self-heal
  HEAL_AT=""; break
done <<< "$COMMITS_OLDEST_FIRST"

[[ -z "$HEAL_AT" ]] && exit 0   # fall back to default workflow
WINDOW=$(git rev-list --count --first-parent "${FIRST_FAIL}^..${LAST_FAIL}")
```

If any intermediate commit's `rcc` status is `pending`/`none`/`error`,
`HEAL_AT` stays empty — do not invent CI data; fall back to the default
single-commit workflow.

## Classify (informs strategy choice)

- **Vendored library broken** — `src/duckdb/...` errors in the log,
  upstream-internal symbols. Usually heals via a follow-up vendor
  commit ⇒ window 1 ⇒ squash.
- **Call sites incompatible** — `src/*.cpp`, `src/include/`, `R/`,
  `tests/` references a renamed/removed API. Heals via a forward-port
  on `*-dev` ⇒ either width.

Quick separator on the log fetched in Step 4b:
`grep -E '(^|/)src/duckdb/' <log>` vs `grep -E '(^|/)src/[^d]' <log>`.

## Strategy A — Squash (`$WINDOW == 1`)

Apply `HEAL_AT`'s tree, collapse onto `FIRST_FAIL`'s parent, commit
with both upstream messages quoted:

```bash
git cherry-pick --no-commit "$HEAL_AT"
git reset --soft "${FIRST_FAIL}^"

FIRST_MSG=$(git log -1 --format=%B "$FIRST_FAIL")
HEAL_MSG=$(git log -1 --format=%B "$HEAL_AT")
git commit -m "${FIRST_MSG}

Combined upstream commit ${HEAL_AT}
-----------------------------------
${FIRST_FAIL} fails in isolation; ${HEAL_AT} restores consistency.
Vendored together to avoid a transient build break.

Original message of ${HEAL_AT}
------------------------------
${HEAL_MSG}"
```

In the cherry-pick loop (Step 4g of the main skill), **skip** `HEAL_AT`.

## Strategy B — Transient patch (`$WINDOW >= 2`)

Add `patch/NNNN-transient-<short>.patch` with this header:

```
# Transient: <short symptom>
# Introduced  : <FIRST_FAIL>
# Removed at  : <HEAL_AT>
# Upstream    : <PR URL or "none">
```

Apply with `patch -p1 -i patch/NNNN-...`, fold into the `FIRST_FAIL`
amend (Step 4f of the main skill).

In Step 4g, when cherry-picking `HEAL_AT`:

```bash
git cherry-pick --no-commit "$HEAL_AT"
git rm patch/*-transient-*.patch
git checkout "$HEAL_AT" -- src/duckdb/   # resync vendored tree
HEAL_MSG=$(git log -1 --format=%B "$HEAL_AT")
git commit -m "${HEAL_MSG}

Removed transient patch — vendored tree is now self-consistent."
```

For a **call-site** self-heal (no `src/duckdb/` change), store the
reverse glue/R diff in `patch/transient-glue/<short>.patch` (audit-only,
not applied by the build).

## Hard rules

- Squash only when `$WINDOW == 1`. Wider windows ⇒ transient patch.
- Transient patches MUST name `FIRST_FAIL`, `HEAL_AT`, upstream link in
  their header, and MUST be deleted at `HEAL_AT`. Never carry one past
  its documented `HEAL_AT`.
- Both upstream commit messages MUST appear verbatim in a squashed
  commit; do not paraphrase.
- Missing CI data (`pending`/`none`) ⇒ no self-heal claim; fall back.
