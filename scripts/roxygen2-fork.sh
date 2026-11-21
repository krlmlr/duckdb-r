#!/bin/bash
# Install roxygen2 from upstream with the `R/` part of a fork branch applied on top, stamped as a `.9100` build.
#
# Usage: scripts/roxygen2-fork.sh [<upstream> [<fork> [<branch>]]]
#   upstream  repository to install, owner/repo (default r-lib/roxygen2)
#   fork      repository holding the branch, owner/repo (default krlmlr/roxygen2)
#   branch    branch whose `R/` changes are applied (default f-sentence-spacing)
#
# commonmark discards the whitespace a line break stands for, so roxygen prose
# written one sentence per line loses the gap between sentences in the text
# help that `?topic` shows. The fork branch keeps it. Why this package
# documents with it, and how to run this by hand, is in
# handbook/contributors/workflow/README.md; CI runs it before every roxygen
# run (.github/workflows/custom/after-install/action.yml for `rcc`,
# .github/workflows/each.yaml for the per-commit legs), so that both document
# with the same build.
#
# Installs into the first library of .libPaths(), over whatever roxygen2 is
# there. Needs git, R, and network access to github.com.
set -euo pipefail

upstream="${1:-r-lib/roxygen2}"
fork="${2:-krlmlr/roxygen2}"
branch="${3:-f-sentence-spacing}"

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

# Upstream at its tip: this is the code that gets installed, so the build
# tracks upstream rather than a fork that may be stale. Depth 50 is enough to
# reach the branch point without fetching years of history.
git clone --depth 50 "https://github.com/${upstream}.git" "$workdir/pkg"
cd "$workdir/pkg"
echo "upstream ${upstream}@$(git rev-parse --short HEAD)"

git fetch --depth 50 "https://github.com/${fork}.git" "$branch"
echo "fork ${fork}@${branch} $(git rev-parse --short FETCH_HEAD)"

# Diff from the branch point, not from the tip's parent: the branch carries
# several commits and a tip-only diff would apply just the last.
if ! base="$(git merge-base HEAD FETCH_HEAD)"; then
  echo "::error title=roxygen2 fork::No common ancestor within 50 commits of ${upstream} and ${fork}@${branch}."
  echo "Rebase the branch on upstream, or raise the fetch depth here."
  exit 1
fi

# Only `R/`. The branch also carries tests, NEWS and a regenerated `man/`,
# none of which this build runs, and all of which are far more likely to
# conflict as upstream moves. The R change is deliberately shaped to keep this
# patch small: one line in `R/markdown.R`, and everything else in a file of its
# own that upstream will never create, because a patch that adds a whole file
# cannot conflict.
git diff "$base" FETCH_HEAD -- R/ >"$workdir/R.patch"

if [ ! -s "$workdir/R.patch" ]; then
  echo "::error title=roxygen2 fork::${fork}@${branch} changes nothing under R/."
  echo "Either the branch has landed upstream and this script should be retired,"
  echo "or the branch name is wrong."
  exit 1
fi

# --3way so the patch still applies when upstream has moved around it. A
# conflict is a hard stop: installing an unpatched roxygen2 would regenerate
# every man/ file without the change, and the diff would look like unrelated
# documentation churn rather than a failed install.
if ! git apply --3way --verbose "$workdir/R.patch"; then
  echo "::error title=roxygen2 fork::Could not apply ${fork}@${branch} onto ${upstream}."
  echo "This is usually an ordinary merge conflict: upstream has changed the same lines."
  echo "Rebase the branch on upstream and push it again."
  exit 1
fi

# Stamp the build. roxygen2 writes its own version into a package's
# Config/roxygen2/version, so this is what makes it visible that the
# documentation was generated with the patch: upstream numbers its development
# builds x.y.z.9000, and this takes the same x.y.z with .9100. Derived from
# upstream's own version so it follows automatically when upstream moves.
Rscript -e '
  d <- read.dcf("DESCRIPTION")
  v <- d[1, "Version"]
  d[1, "Version"] <- sub("^([0-9]+[.][0-9]+[.][0-9]+).*$", "\\1.9100", v)
  write.dcf(d, "DESCRIPTION", keep.white = colnames(d))
  cat("stamped", v, "->", read.dcf("DESCRIPTION")[1, "Version"], "\n")
'

R CMD INSTALL --no-docs .

# Fail here rather than later with a puzzling man/ diff.
Rscript -e '
  v <- as.character(packageVersion("roxygen2"))
  patched <- exists("mdxml_keep_sentence_spacing", envir = asNamespace("roxygen2"), inherits = FALSE)
  cat("roxygen2", v, "patched:", patched, "\n")
  # Assert the whole shape, not just the suffix: a malformed stamp such as
  # "\001.9100" also ends in .9100, which is how an escaping bug in the stamp
  # above once went unnoticed until R refused to install the result.
  if (!grepl("^[0-9]+[.][0-9]+[.][0-9]+[.]9100$", v) || !patched) {
    stop("roxygen2 was not installed from the fork branch.", call. = FALSE)
  }
'
