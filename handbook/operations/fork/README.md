# Working from the fork

Where development happens now that it has moved from `duckdb/duckdb-r` to the maintainer's fork, `krlmlr/duckdb-r`:
what lives in each repository, the one write a landing makes to both, how a version tag is written, and how the fork's `main` is frozen.
The fork's own branches and the series refs are [`branches/`](/handbook/branches/README.md)'s.

**Work happens in the fork.**
Issues and pull requests are opened in `krlmlr/duckdb-r`,
and the maintainer's open ones in `duckdb/duckdb-r` move there as
[krlmlr/duckdb-r#194](https://github.com/krlmlr/duckdb-r/pull/194) tracks, which is still open.
`rcc` runs on pull requests in both repositories, each on its own, except that the fork skips one against a release branch,
and the per-commit builds run in the fork alone ([`ci/workflows/`](/handbook/operations/ci/workflows/README.md)).

**A landing's fast-forward is the exception, made on both repositories with one local command.**
A series landing ends by fast-forwarding `<B>` onto `<L>-land-dev` ([`series-land`](/.claude/skills/series-land/SKILL.md), step 6),
and the maintainer pushes it to `<B>` in `duckdb/duckdb-r` and in the fork alike, from his own checkout,
with `scripts/series-land-push.sh`, whose header says what it checks and what it refuses.
The same commit is pushed to both, so `<B>` has one SHA in either repository.
It is provisional: the script is proposed in [krlmlr/duckdb-r#263](https://github.com/krlmlr/duckdb-r/pull/263).

**The version tag is written in the fork, and a rerun of the same command copies it.**
The "Tag version" workflow, `.github/workflows/tag-version.yaml`, runs `scripts/tag-version.sh` in the fork.
`series-land-push.sh` copies the tag only once the fork has it:
a first run pushes `<B>` and prints the command that dispatches the workflow in the fork,
and a rerun after that run pushes no branch and copies the annotated tag object to `duckdb/duckdb-r`,
so the copy keeps the tag's SHA as well as the commit it points to.
Which version takes which tag, and the tag's message, are [`releases/versioning/`](/handbook/operations/releases/versioning/README.md)'s.
The workflow is provisional: it is proposed in [duckdb/duckdb-r#3070](https://github.com/duckdb/duckdb-r/pull/3070),
and is not on `main` yet.

**The fork's `main` stays frozen, and the freeze is lifted only for the landing's push.**
The ruleset `freeze main` on `krlmlr/duckdb-r`, id `27849787`, stops every update, deletion and non-fast-forward of `refs/heads/main`,
and while it is active a pull request into the fork's `main` cannot merge either.
It has no bypass actors, because sessions push with the maintainer's token, and a bypass would let any session past the freeze.
`series-land-push.sh` lifts it for the push and restores it, as it does every active ruleset named `freeze <B>` in either repository, found by name rather than by id.
`duckdb/duckdb-r` instead creates its freeze for each landing and deletes it at the end
([`series-land`](/.claude/skills/series-land/SKILL.md), steps 1 and 7);
the fork's stays, and was created by the maintainer in this shape:

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

**The Pull app is gone.**
A pull request drops its configuration, [krlmlr/duckdb-r#264](https://github.com/krlmlr/duckdb-r/pull/264).
