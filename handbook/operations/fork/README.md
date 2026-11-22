# Working from the fork

Where development happens now that it has moved from `duckdb/duckdb-r` to the maintainer's fork, `krlmlr/duckdb-r`:
what lives in each repository, the one write a landing makes to both, and how a landing's branch is frozen in each.
The fork's own branches and the series refs are [`branches/`](/handbook/branches/README.md)'s.

**Work happens in the fork.**
Issues and pull requests are opened in `krlmlr/duckdb-r`,
and the maintainer's open ones in `duckdb/duckdb-r` move there as
[krlmlr/duckdb-r#194](https://github.com/krlmlr/duckdb-r/pull/194) tracks, which is still open.
`rcc` runs on pull requests in both repositories, each on its own, except that the fork skips one against a release branch,
and the per-commit builds run in the fork alone ([`ci/workflows/`](/handbook/operations/ci/workflows/README.md)).

**A landing's fast-forward is the exception, made on both repositories with one local command.**
A series landing ends by fast-forwarding `<B>` onto `<L>-land-dev` ([`series-land`](/.claude/skills/series-land/SKILL.md), step 6),
and the maintainer runs `scripts/series-land-push.sh` from his own checkout, with `origin` the fork and `upstream` `duckdb/duckdb-r`.
It goes ahead only where `series-land.sh <L> --status` prints `READY`,
pushes the same commit to `<B>` in both, so `<B>` has one SHA in either repository,
and then creates the annotated tag `v<version>` from the `NEWS.md` section the landing brings and pushes that one tag object to both.
Its header says what it checks and what it refuses,
and which version takes which tag is [`releases/versioning/`](/handbook/operations/releases/versioning/README.md)'s.
It is provisional: the script is proposed in [krlmlr/duckdb-r#263](https://github.com/krlmlr/duckdb-r/pull/263).

**A landing's branch is frozen in both repositories by one script, and unfrozen by another.**
`scripts/series-freeze.sh <B>` freezes `<B>` in `duckdb/duckdb-r` and in the fork with a ruleset named `freeze <B>`,
creating it where there is none and making the existing one active otherwise,
and `scripts/series-unfreeze.sh <B>` disables it before the push and deletes nothing.
The freeze is not restored after the landing.
While it is active, a pull request into `<B>` cannot merge either.
It has no bypass actors, because sessions push with the maintainer's token, and a bypass would let any session past the freeze.
On the fork's `main` it is the ruleset `freeze main`, id `27849787`, which the scripts reuse.
Both scripts are provisional, proposed in [krlmlr/duckdb-r#263](https://github.com/krlmlr/duckdb-r/pull/263).

**The Pull app is gone.**
A pull request drops its configuration with the pages that describe it, [krlmlr/duckdb-r#264](https://github.com/krlmlr/duckdb-r/pull/264).
