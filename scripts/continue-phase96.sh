#!/usr/bin/env bash
# Resumable Phase 96/95 closeout driver.
# It owns only transient batch output and the semantic report.  Code changes
# remain an explicit hook so this script cannot silently rewrite the SDK.
set -Eeuo pipefail

# Phase 96 was absorbed into 95-03. Keep this local helper fail-closed so
# historical commands cannot recreate child transcripts or rerun stale gates.
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Phase 96 is superseded; see .planning/V1.22-CURRENT.md"
  exit 0
fi
echo "phase96_superseded: do not run this historical driver" >&2
exit 2

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
driver="$root/scripts/run-clean-65-portrait.sh"
report="$root/example-images/local-test-records/face-feature-batch-report.json"
logdir="$root/.planning/phases/96-repair-portrait-semantic-controls-exposed-by-phase-95-closeo/attempt-logs"
max_attempts="${GSD_MAX_ATTEMPTS:-10}"
sleep_seconds="${GSD_RETRY_SECONDS:-2}"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: GSD_MAX_ATTEMPTS=10 GSD_FIX_HOOK='...' $0"
  exit 0
fi

mkdir -p "$logdir"
trap 'status=$?; jobs -pr | xargs -r kill 2>/dev/null || true; exit "$status"' EXIT INT TERM

run_gate() {
  echo "[phase96] self-test $(date '+%H:%M:%S')"
  "$driver" --self-test
  echo "[phase96] focused Swift tests $(date '+%H:%M:%S')"
  swift test --package-path "$root/BeautySDK" --filter \
    'ChinTaperRepairTests|MouthNegativeFieldTests|NoseRepairFieldTests|EyebrowWarpProviderTests|BeautyGeometryEffectPipelineTests'
  echo "[phase96] prepare batch workspace $(date '+%H:%M:%S')"
  "$driver" --prepare
  echo "[phase96] run 65-case batch; renderer/comparator output is intentionally quiet $(date '+%H:%M:%S')"
  "$driver" --run
  echo "[phase96] batch completed $(date '+%H:%M:%S')"
}

for ((attempt=1; attempt<=max_attempts; attempt++)); do
  log="$logdir/attempt-${attempt}.log"
  set +e
  echo "[phase96] attempt=$attempt/$max_attempts log=$log"
  run_gate 2>&1 | tee "$log"
  code=$?
  set -e

  if [[ $code -eq 0 ]] && [[ -f "$report" ]] && \
     jq -e '.stableSemanticPayload.verdict == "semantic_pass" and (.stableSemanticPayload.mechanicalCases|length) == 65' "$report" >/dev/null; then
    echo "phase96_gate=PASS attempts=$attempt"
    exit 0
  fi

  reason="gate_exit_${code}"
  if [[ -f "$report" ]]; then
    reason="$(jq -r '.stableSemanticPayload.verdict // .status // "invalid_report"' "$report" 2>/dev/null || echo invalid_report)"
  fi
  echo "phase96_gate=RETRY attempt=$attempt reason=$reason log=$log" >&2

  # Optional project-owned repair command. It must be supplied explicitly;
  # the default is diagnostic-only and therefore safe to resume unattended.
  if [[ -n "${GSD_FIX_HOOK:-}" ]]; then
    bash -lc "$GSD_FIX_HOOK" >>"$log" 2>&1 || true
  fi
  (( attempt < max_attempts )) && sleep "$sleep_seconds"
done

echo "phase96_gate=BLOCKED attempts=$max_attempts logs=$logdir" >&2
exit 1
