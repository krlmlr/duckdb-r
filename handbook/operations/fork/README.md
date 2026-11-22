# Working from the fork

Where development happens now that it has moved from `duckdb/duckdb-r` to the maintainer's fork, `krlmlr/duckdb-r`:
what lives in each repository, which way a ref travels between them, how a version tag is written, and how the fork's `main` is frozen.
The fork's own branches, the series refs and the mirrors, are [`branches/`](/handbook/branches/README.md)'s.

**Work lives in the fork.**
Issues and pull requests are opened in `krlmlr/duckdb-r`,
and the open ones in `duckdb/duckdb-r` move there as
[krlmlr/duckdb-r#194](https://github.com/krlmlr/duckdb-r/pull/194) tracks, which is still open.
Each repository runs CI on its own pull requests,
and the per-commit builds run in the fork alone ([`ci/workflows/`](/handbook/operations/ci/workflows/README.md)).

**The fork leads, and `duckdb/duckdb-r` takes the same object.**
A ref is written in the fork first and copied to `duckdb/duckdb-r` unchanged, so its SHA is the same in both.
For a branch the copy is a plain push of the fork's tip, so it lands only as a fast-forward:
the landing `a1a93d5bee` (`2.0.99.9000`) went to the fork's `main` first,
and `duckdb/duckdb-r`'s `main` takes it by a fast-forward push of the same commit.

**A version tag is the annotated tag object itself, pushed on.**
It is created in the fork, and the copy names it by its ref:

```sh
tag=v2.0.99.9001                            # the tag to copy
git fetch origin "refs/tags/$tag:refs/tags/$tag"
git push git@github.com:duckdb/duckdb-r.git "refs/tags/$tag"
```

Git sends the tag object rather than a new tag, so the copy keeps the tag's SHA as well as the commit it points to.
Which version takes which tag, and the tag's message, are [`releases/versioning/`](/handbook/operations/releases/versioning/README.md)'s.

**The tag is written by the "Tag version" workflow, dispatched in the fork.**
`.github/workflows/tag-version.yaml` runs `scripts/tag-version.sh` on the branch it is dispatched on,
and its header says what it takes and what it refuses.
It is provisional: both files are proposed in [duckdb/duckdb-r#3070](https://github.com/duckdb/duckdb-r/pull/3070),
and are not on `main` yet.

**The fork's `main` is frozen for a landing as `duckdb/duckdb-r`'s is.**
A ruleset `freeze main` on `krlmlr/duckdb-r` stops every update, deletion and non-fast-forward of `refs/heads/main`,
and while it is active a pull request into the fork's `main` cannot merge either
([`series-land`](/.claude/skills/series-land/SKILL.md), step 1, freezes the branch in `duckdb/duckdb-r`).
It has no bypass actors, because sessions push with the maintainer's token, and a bypass would let any session past the freeze.
It is provisional: the ruleset is not created yet, and the maintainer creates it with this call:

```sh
gh api -X POST repos/krlmlr/duckdb-r/rulesets --input - <<EOF
{
  "name": "freeze main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {"ref_name": {"include": ["refs/heads/main"], "exclude": []}},
  "rules": [
    {"type": "update", "parameters": {"update_allows_fetch_and_merge": false}},
    {"type": "deletion"},
    {"type": "non_fast_forward"}
  ]
}
EOF
```

**Lifting and restoring the freeze are the maintainer's steps.**
Each is one call, with `<id>` the ruleset's id from `gh api repos/krlmlr/duckdb-r/rulesets`:

```sh
gh api -X PUT repos/krlmlr/duckdb-r/rulesets/<id> -f enforcement=disabled   # lift
gh api -X PUT repos/krlmlr/duckdb-r/rulesets/<id> -f enforcement=active     # restore
```
