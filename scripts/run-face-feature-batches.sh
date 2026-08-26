#!/usr/bin/env bash
set -euo pipefail

readonly repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly manifest="${repo_root}/scripts/face-feature-batch-manifest.json"
readonly comparator="${repo_root}/scripts/compare-face-feature-batches.swift"
input_dir="${repo_root}/example-images/input"
output_root="${repo_root}/example-images/output/face-feature-batches"
report_path="${repo_root}/example-images/local-test-records/face-feature-batch-report.json"
preflight_only=0

usage() {
  cat <<'EOF'
Usage: run-face-feature-batches.sh [options]

Runs the current public-facade facial-feature cases in deterministic batches,
writes watermarked PNGs, compares them against the input and neutral control,
and writes an aggregate JSON record without persisting private fixture paths.

Options:
  --input <dir>     Portrait input root (default: example-images/input)
  --output <dir>    Ignored output root (default: example-images/output/face-feature-batches)
  --report <file>   Local aggregate record (default: example-images/local-test-records/face-feature-batch-report.json)
  --preflight-only  Validate paths and exact 75/65/8 inventories without rendering
  --help            Show this message
EOF
}

while (($# > 0)); do
  case "$1" in
    --input)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      input_dir="$2"
      shift 2
      ;;
    --output)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      output_root="$2"
      shift 2
      ;;
    --report)
      [[ $# -ge 2 ]] || { usage >&2; exit 2; }
      report_path="$2"
      shift 2
      ;;
    --preflight-only)
      preflight_only=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

admit_paths() {
  local admitted
  if ! admitted="$(python3 - "$repo_root" "$input_dir" "$output_root" "$report_path" <<'PY'
import os
import stat
import sys

repo, input_raw, output_raw, report_raw = sys.argv[1:]

def reject_ambiguous(raw):
    if not raw or any(ch in raw for ch in ("\n", "\r", "\0")):
        raise ValueError
    if ".." in raw.replace("\\", "/").split("/"):
        raise ValueError

def absolute(raw):
    reject_ambiguous(raw)
    return os.path.normpath(os.path.abspath(raw))

def no_symlink_components(path):
    current = os.path.sep
    for component in path.split(os.path.sep)[1:]:
        current = os.path.join(current, component)
        if not os.path.lexists(current):
            continue
        if stat.S_ISLNK(os.lstat(current).st_mode):
            raise ValueError

def require_creatable_directory(path):
    no_symlink_components(path)
    if os.path.exists(path):
        if not os.path.isdir(path) or not os.access(path, os.W_OK | os.X_OK):
            raise ValueError
        return
    ancestor = path
    while not os.path.exists(ancestor):
        parent = os.path.dirname(ancestor)
        if parent == ancestor:
            raise ValueError
        ancestor = parent
    if not os.path.isdir(ancestor) or not os.access(ancestor, os.W_OK | os.X_OK):
        raise ValueError

def contains(parent, child):
    try:
        return os.path.commonpath((parent, child)) == parent
    except ValueError:
        return False

repo = absolute(repo)
input_path = absolute(input_raw)
output_path = absolute(output_raw)
report_path = absolute(report_raw)
report_parent = os.path.dirname(report_path)

no_symlink_components(input_path)
if not os.path.isdir(input_path):
    raise ValueError
portrait_root = os.path.join(input_path, "portraits")
no_symlink_components(portrait_root)
if not os.path.isdir(portrait_root):
    raise ValueError

fixture_count = 0
for root, directories, files in os.walk(portrait_root, followlinks=False):
    no_symlink_components(root)
    for name in directories + files:
        candidate = os.path.join(root, name)
        if stat.S_ISLNK(os.lstat(candidate).st_mode):
            raise ValueError
    for name in files:
        candidate = os.path.join(root, name)
        if not stat.S_ISREG(os.lstat(candidate).st_mode):
            raise ValueError
        if os.path.splitext(name)[1].lower() not in (".jpg", ".jpeg", ".png"):
            raise ValueError
        fixture_count += 1
if fixture_count == 0:
    raise ValueError

require_creatable_directory(output_path)
require_creatable_directory(report_parent)
no_symlink_components(report_path)
if os.path.exists(report_path) and not stat.S_ISREG(os.lstat(report_path).st_mode):
    raise ValueError

if contains(input_path, output_path) or contains(output_path, input_path):
    raise ValueError
if contains(input_path, report_path) or contains(output_path, report_path):
    raise ValueError
if contains(report_parent, input_path) or contains(report_parent, output_path):
    raise ValueError

print(input_path)
print(output_path)
print(report_path)
PY
)"; then
    echo "path_admission_failed" >&2
    return 1
  fi

  local admitted_input admitted_output admitted_report
  admitted_input="$(printf '%s\n' "$admitted" | sed -n '1p')"
  admitted_output="$(printf '%s\n' "$admitted" | sed -n '2p')"
  admitted_report="$(printf '%s\n' "$admitted" | sed -n '3p')"
  [[ -n "$admitted_input" && -n "$admitted_output" && -n "$admitted_report" ]] || {
    echo "path_admission_failed" >&2
    return 1
  }

  if [[ "$admitted_output" == "$repo_root"/* ]] &&
      ! git -C "$repo_root" check-ignore -q --no-index "$admitted_output"; then
    echo "output_not_owner_local" >&2
    return 1
  fi
  if [[ "$admitted_report" == "$repo_root"/* ]] &&
      ! git -C "$repo_root" check-ignore -q --no-index "$admitted_report"; then
    echo "report_not_owner_local" >&2
    return 1
  fi

  input_dir="$admitted_input"
  output_root="$admitted_output"
  report_path="$admitted_report"
}

live_cases_path=""
cleanup_temporary_files() {
  if [[ -n "$live_cases_path" && -f "$live_cases_path" ]]; then
    rm -f -- "$live_cases_path"
  fi
}
trap cleanup_temporary_files EXIT HUP INT TERM

validate_inventory() {
  if ! swift "$comparator" --self-test >/dev/null 2>&1; then
    echo "semantic_contract_admission_failed" >&2
    return 1
  fi

  live_cases_path="$(mktemp "${TMPDIR:-/tmp}/beauty-live-cases.XXXXXXXX.json")"
  if ! "$renderer" --list-cases >"$live_cases_path" 2>/dev/null; then
    echo "renderer_inventory_failed" >&2
    return 1
  fi

  if ! python3 - "$manifest" "$live_cases_path" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    manifest = json.load(handle)
with open(sys.argv[2], encoding="utf-8") as handle:
    live_document = json.load(handle)

live = live_document.get("cases")
if not isinstance(live, list) or len(live) != 75 or len(set(live)) != 75:
    raise SystemExit(1)
if not all(isinstance(case, str) and case for case in live):
    raise SystemExit(1)

expected_batches = [("face-shape", 11), ("eyes", 19), ("eyebrows", 13), ("nose", 7), ("mouth", 15)]
batches = manifest.get("batches")
if not isinstance(batches, list) or [(row.get("id"), len(row.get("cases", []))) for row in batches] != expected_batches:
    raise SystemExit(1)
selected = [case for batch in batches for case in batch["cases"]]
control = manifest.get("control", {}).get("id")
if len(selected) != 65 or len(set(selected)) != 65 or control != "geometryBaseline_noop" or control in selected:
    raise SystemExit(1)
if any(case not in live for case in [control, *selected]):
    raise SystemExit(1)

expected_contracts = [
    ("faceContourSmooth_0p25", "contourContinuityGain"),
    ("chinTaper_0p25", "centerlineTaper"),
    ("gazeCorrection_0p25", "pupilToOwnEyeCenter"),
    ("eyebrowHeadSpacing_plus0p25", "innerBrowHeadGap"),
    ("eyebrowHeadSpacing_minus0p25", "innerBrowHeadGap"),
    ("noseBridge_0p30", "bridgeDefinitionGain"),
    ("noseRootNarrowing_0p25", "rootWidthContraction"),
    ("mouthWidth_minus0p35", "mouthWidthContraction"),
]
contracts = manifest.get("semanticContracts")
if not isinstance(contracts, list) or [(row.get("caseID"), row.get("metric")) for row in contracts] != expected_contracts:
    raise SystemExit(1)
if len({row[0] for row in expected_contracts}) != 8:
    raise SystemExit(1)
PY
  then
    echo "inventory_admission_failed" >&2
    return 1
  fi
}

admit_paths
[[ -f "$manifest" && ! -L "$manifest" && -f "$comparator" && ! -L "$comparator" ]] || {
  echo "validation_source_admission_failed" >&2
  exit 2
}

if ! swift build --package-path "${repo_root}/BeautySDK" --product BeautyExampleRenderer >/dev/null 2>&1; then
  echo "renderer_build_failed" >&2
  exit 2
fi
readonly renderer="${repo_root}/BeautySDK/.build/debug/BeautyExampleRenderer"
[[ -x "$renderer" && ! -L "$renderer" ]] || { echo "renderer_admission_failed" >&2; exit 2; }
validate_inventory

if ((preflight_only == 1)); then
  echo "preflight=PASS live=75 selected=65 semantic=8"
  exit 0
fi

mkdir -p -- "$output_root"
admit_paths
run_root="$(mktemp -d "${output_root}/attempt_XXXXXXXX")"
attempt_id="$(basename "$run_root")"

render_failures=0
render_case() {
  local batch_id="$1"
  local case_id="$2"
  local case_root="${run_root}/${batch_id}/${case_id}"
  mkdir -p -- "$case_root"
  if ! "$renderer" \
      --input "$input_dir" \
      --output "$case_root" \
      --case "$case_id" \
      --backend cpu \
      >/dev/null 2>&1; then
    render_failures=$((render_failures + 1))
    echo "render_failed ${batch_id}/${case_id}" >&2
  fi
}

render_case control "geometryBaseline_noop"
while IFS=$'\t' read -r batch_id case_id; do
  [[ -n "$batch_id" && -n "$case_id" ]] || continue
  render_case "$batch_id" "$case_id"
done < <(python3 - "$manifest" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    manifest = json.load(handle)
for batch in manifest["batches"]:
    for case_id in batch["cases"]:
        print(f"{batch['id']}\t{case_id}")
PY
)

if ((render_failures > 0)); then
  echo "render_failures=${render_failures}" >&2
  exit 2
fi

set +e
swift "$comparator" \
  --input "$input_dir" \
  --run-root "$run_root" \
  --manifest "$manifest" \
  --report "$report_path" \
  --attempt-id "$attempt_id" \
  >/dev/null 2>&1
compare_status=$?
set -e
exit "$compare_status"
