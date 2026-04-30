#!/bin/bash
# Collect results and failure logs for all *completed* GitHub Actions runs
# of the "rcc" workflow. In-flight runs (queued / in_progress) are ignored
# so that the stored data only ever reflects confirmed results.
#
# Output layout (under $OUT_DIR, default ".") :
#   runs.json          - summary array of all completed runs
#   runs.ndjson        - one {id, commit, state} record per line
#   runs/<id>.json     - per-run metadata
#   runs/<id>.log      - last $LOG_TAIL lines of the combined run log,
#                        only for runs whose conclusion indicates a
#                        failure. Logs older than ~90 days are no longer
#                        retained by GitHub; in that case the file
#                        contains a short marker instead.
#
# The script is idempotent: per-run metadata is rewritten only when it
# changes, and failure logs are fetched only when the file does not yet
# exist. This keeps git history clean and avoids re-downloading large logs
# for runs that were already captured.
#
# Environment variables:
#   GH_TOKEN  - GitHub token with actions:read (required)
#   OUT_DIR   - destination directory (default: current directory)
#   WORKFLOW  - workflow file name or id (default: R-CMD-check.yaml,
#               whose `name:` is "rcc")
#   LOG_TAIL  - number of trailing log lines to keep per failed run
#               (default: 10000)
#   PER_PAGE  - API page size (default: 100)
#
# Requires: gh, jq, unzip.

set -euo pipefail

OUT_DIR="${OUT_DIR:-.}"
WORKFLOW="${WORKFLOW:-R-CMD-check.yaml}"
LOG_TAIL="${LOG_TAIL:-10000}"
PER_PAGE="${PER_PAGE:-100}"

mkdir -p "${OUT_DIR}/runs"

all_ndjson="$(mktemp)"
runs_ndjson="$(mktemp)"
trap 'rm -f "${all_ndjson}" "${runs_ndjson}"' EXIT

echo "Fetching workflow runs for ${WORKFLOW}..."
gh api --paginate \
  "repos/{owner}/{repo}/actions/workflows/${WORKFLOW}/runs?per_page=${PER_PAGE}" \
  --jq '.workflow_runs[] | {
          id,
          name,
          head_branch,
          head_sha,
          event,
          status,
          conclusion,
          run_attempt,
          run_number,
          run_started_at,
          created_at,
          updated_at,
          html_url,
          display_title,
          actor: (.actor.login // null),
          triggering_actor: (.triggering_actor.login // null)
        }' \
  | jq -c . \
  > "${all_ndjson}"

total="$(wc -l < "${all_ndjson}" | tr -d ' ')"

# Drop in-flight runs: only keep runs whose result is confirmed.
jq -c 'select(.status == "completed")' "${all_ndjson}" > "${runs_ndjson}"
completed="$(wc -l < "${runs_ndjson}" | tr -d ' ')"
echo "Runs reported: ${total} (completed: ${completed})"

# Sort newest first, used by every output.
sorted_ndjson="$(mktemp)"
trap 'rm -f "${all_ndjson}" "${runs_ndjson}" "${sorted_ndjson}"' EXIT
jq -s 'sort_by(.created_at) | reverse | .[]' "${runs_ndjson}" \
  | jq -c . > "${sorted_ndjson}"

# Combined per-run metadata index.
jq -s '.' "${sorted_ndjson}" > "${OUT_DIR}/runs.json"

# Mapping from run id to head commit and conclusion, one record per line.
jq -c '{id, commit: .head_sha, state: (.conclusion // "unknown")}' \
  "${sorted_ndjson}" > "${OUT_DIR}/runs.ndjson"

is_failure_conclusion() {
  case "$1" in
    failure|timed_out|startup_failure|action_required) return 0 ;;
    *) return 1 ;;
  esac
}

fetched=0
skipped=0
expired=0

while IFS= read -r run; do
  id="$(jq -r '.id' <<<"${run}")"
  conclusion="$(jq -r '.conclusion // ""' <<<"${run}")"

  metafile="${OUT_DIR}/runs/${id}.json"
  new_meta="$(jq '.' <<<"${run}")"
  if [ ! -f "${metafile}" ] || ! diff -q <(printf '%s\n' "${new_meta}") "${metafile}" >/dev/null 2>&1; then
    printf '%s\n' "${new_meta}" > "${metafile}"
  fi

  if ! is_failure_conclusion "${conclusion}"; then
    continue
  fi

  logfile="${OUT_DIR}/runs/${id}.log"
  if [ -f "${logfile}" ]; then
    skipped=$((skipped + 1))
    continue
  fi

  echo "Fetching logs for run ${id} (conclusion: ${conclusion})"
  tmp_zip="$(mktemp --suffix=.zip)"
  ok=1
  gh api \
    -H 'Accept: application/vnd.github+json' \
    -H 'X-GitHub-Api-Version: 2022-11-28' \
    "repos/{owner}/{repo}/actions/runs/${id}/logs" \
    > "${tmp_zip}" 2>/dev/null || ok=0

  if [ "${ok}" = "1" ] && [ -s "${tmp_zip}" ]; then
    tmp_dir="$(mktemp -d)"
    if unzip -q "${tmp_zip}" -d "${tmp_dir}" 2>/dev/null; then
      # Concatenate every per-step log file inside the archive (in path
      # order, which corresponds to job/step order) and keep only the
      # final $LOG_TAIL lines.
      find "${tmp_dir}" -type f -name '*.txt' -print0 \
        | sort -z \
        | xargs -0 -r cat 2>/dev/null \
        | tail -n "${LOG_TAIL}" \
        > "${logfile}" || true
      if [ ! -s "${logfile}" ]; then
        printf 'logs archive contained no text\n' > "${logfile}"
      fi
      fetched=$((fetched + 1))
    else
      printf 'logs archive could not be unzipped\n' > "${logfile}"
      expired=$((expired + 1))
    fi
    rm -rf "${tmp_dir}"
  else
    printf 'logs unavailable (likely expired or access denied)\n' > "${logfile}"
    expired=$((expired + 1))
  fi
  rm -f "${tmp_zip}"
done < "${runs_ndjson}"

echo "Logs fetched: ${fetched}, already had: ${skipped}, unavailable: ${expired}"
echo "Done."
