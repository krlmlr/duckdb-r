# Mirrors

The copy of the fork's branches in `duckdb/duckdb-r`:
what it carries, why it is kept, and how each ref gets there.
The fork, `krlmlr/duckdb-r`, is the canonical repository and releases the package
([`model/`](/handbook/branches/model/README.md)),
so every copy here goes one way, from the fork to `duckdb/duckdb-r`, and never back.

**`duckdb/duckdb-r` is a downstream copy.**
It carries `main`, every release branch and its `-lts` companion, each series' `<S>-green`, and the release tags,
each at the fork's tip, so that the links, installs and services that name it keep working:
`duckdb.r-universe.dev` builds every base flavor from it
([`flavors/`](/handbook/branches/flavors/README.md)),
`pak::pak("duckdb/duckdb-r")` installs from it, and the pkgdown site deploys from it.
Nothing is written there first:
a pull request, a landing, a forward merge and a tag all happen in the fork, and the copy takes the result.

**A copy has one motion: it takes the fork's tip by a plain push.**
A plain push only fast-forwards, so git refuses anything else,
and a refusal means that `duckdb/duckdb-r` holds a commit the fork lacks.
That is a finding to read and bring into the fork through a pull request, never a push to force.
The maintainer pushes the branches and tags after each merge, landing and release, from a checkout of the fork:

```sh
C=git@github.com:duckdb/duckdb-r.git   # the copy
git fetch origin
for b in main v2.0-cyanoptera; do      # the branches the merge, landing or release moved
  git push "$C" "refs/remotes/origin/$b:refs/heads/$b"
done
git push "$C" --tags                   # tags only add; an existing tag is never moved
```

**The series loop copies `<S>-green` itself.**
r-universe reads ownership from the URL of the branch it builds,
so a `duckdb.*` flavor built from `krlmlr/duckdb-r` is published as krlmlr's,
and the universe that ought to own the package carries an entry pointing out of it
([`flavors/`](/handbook/branches/flavors/README.md)).
Copying green to `duckdb/duckdb-r` is what lets `duckdb.r-universe.dev` name it for every base flavor
and the fork's universe name the fork,
so no package is configured in two places.
Only `<S>-green` travels:
the buffer and `-dev` are working branches nothing installs.
A `-fwd-green` is a rebuild published from the fork's own universe to verify a cutover before it happens;
it travels with the rest, and it is deleted in `duckdb/duckdb-r` with the fork's `-fwd` refs once the swap has made its tip `<S>-green`
([`series-forward`](/.claude/skills/series-forward/SKILL.md)).
[`scripts/series-advance.sh`](/scripts/series-advance.sh) pushes it plainly beside the fork's own green,
to the remote `upstream` unless told otherwise,
which is what a `gh` clone of the fork calls the repository it was forked from.
The exception is a cutover, which moves green onto a lineage the old green is no ancestor of:
[`scripts/series-cutover.sh`](/scripts/series-cutover.sh) forces that copy itself, under a lease and after the swap,
and only where the copy it replaces is the fork's green or under a pin in the fork
([`model/`](/handbook/branches/model/README.md)), so the move loses no history.

**The scripts still read `main` and the release branches from the copy.**
Every script that takes `--canonical` reads the branches there and copies green there,
because `duckdb/duckdb-r` was canonical when they were written
([`operations/vendoring/series-loop/`](/handbook/operations/vendoring/series-loop/README.md)).
A read is right only while the copy is level with the fork,
so the push above follows every merge into `main` or a release branch,
and the [`series-land`](/.claude/skills/series-land/SKILL.md) blocks, which still write to `duckdb/duckdb-r`,
wait for the tooling to be retargeted.

**No app moves a branch of the fork.**
The fork's `main` and release branches were once Pull-app mirrors of `duckdb/duckdb-r`, hard-reset on every sync,
and the configuration in `.github/pull.yml` is gone with that direction.
Pull without a configuration file hard-resets a fork's default branch to its parent's,
so the app is uninstalled from the fork, or the fork deselected in its installation, rather than left without one.
A commit merged into the fork is therefore kept, and the copy is what has to keep up.

*To deepen: retarget the scripts' canonical remote to the fork, so that a stale copy can no longer feed a stale read.*
