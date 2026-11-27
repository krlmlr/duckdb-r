# Mirrors

The branches the fork carries under a canonical branch's name,
copies of `duckdb/duckdb-r`'s `main` and release branches,
what still reads them, and the one copy that travels the other way.
The series refs beside them are
[`model/`](/handbook/branches/model/README.md)'s.

**Nothing keeps them level any more.**
The Pull app hard-reset each copy onto its canonical tip on a schedule of its own;
it is gone and will not be reactivated
([krlmlr/duckdb-r#262](https://github.com/krlmlr/duckdb-r/pull/262#issuecomment-7082948221)),
and its configuration went with it.
A release branch the fork carries under its canonical name stays where the last sync left it
and moves only when someone pushes it.

**The fork's `main` is a branch of its own now, not a copy.**
It has moved ahead of the canonical `main`, and nothing brings either one level with the other.
No badge reads it, or any other copy:
*ahead* is counted in the canonical repository and the other two in the fork's series refs
([`scripts/series-table.R`](/scripts/series-table.R)).

**The scripts read the canonical branch first and the fork's copy second.**
`main` and the branch a series releases from are fetched from the remote `--canonical` names,
and the fork's copy is the fallback, taken with a word on stderr
([`operations/vendoring/series-loop/`](/handbook/operations/vendoring/series-loop/README.md)).
A fallback onto a release branch's copy reads a tip that only ages from here.
A read of the canonical `main` now misses what the fork's `main` carries beyond it,
and the tooling sync takes the tree it reads verbatim,
so which `main` the scripts should read is open
([krlmlr/duckdb-r#264](https://github.com/krlmlr/duckdb-r/pull/264)).

## The copy that goes the other way

One branch per series travels from the fork *to* the canonical repository:
`<S>-green`, the forward's `<S>-fwd-green` included.
r-universe reads ownership from the URL of the branch it builds,
so a `duckdb.*` flavor built from `krlmlr/duckdb-r` is published as krlmlr's,
and the universe that ought to own the package carries an entry pointing out of it
([`branches/flavors/`](/handbook/branches/flavors/README.md)).
Mirroring green into the canonical repository is what lets
`duckdb.r-universe.dev` name its own repository for every base flavor
and the fork's universe name the fork's,
so no package is configured in two places.

Only `<S>-green`.
The buffer and `-dev` are working branches nothing installs,
and duplicating either is the thing this avoids.
A `-fwd-green` is a rebuild published from the fork's own universe
to verify a cutover before it happens, and nothing publishes its copy here;
it travels with the rest,
and it is deleted here with the fork's `-fwd` refs once the swap has made its tip `<S>-green`
([`series-forward`](/.claude/skills/series-forward/SKILL.md)).

**It is a fast-forward, and a refusal is a finding.**
[`scripts/series-advance.sh`](/scripts/series-advance.sh) pushes it plainly
beside the fork's own green — to the remote `upstream` unless told otherwise,
which is what a `gh` clone of a fork calls what it was forked from —
so git rejects anything that is not a forward,
and the rejection stops the firing rather than being forced:
green is the verified frontier, and two repositories disagreeing about it
is something to read.
The exception is a cutover, which moves green onto the forward lineage
the old green is no ancestor of.
That is the one legitimate non-fast-forward,
so [`scripts/series-cutover.sh`](/scripts/series-cutover.sh) forces the copy itself,
under a lease and after the swap, rather than leaving the next firing to trip on it,
and only where the copy it replaces is the fork's green or under a pin in the fork
([`model/`](/handbook/branches/model/README.md)), so the move loses no history.

Unlike the copies above, this one is ours to push,
and it is the only copy between the two repositories that anything still keeps level.
