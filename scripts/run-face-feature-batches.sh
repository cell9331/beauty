#!/usr/bin/env bash
set -euo pipefail

readonly repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly manifest="${repo_root}/scripts/face-feature-batch-manifest.json"
readonly comparator="${repo_root}/scripts/compare-face-feature-batches.swift"
readonly path_helper="${repo_root}/scripts/face-feature-path-helper.py"
readonly boundary_test="${repo_root}/scripts/test-face-feature-batch-boundaries.py"
input_dir="${repo_root}/example-images/input"
output_root="${repo_root}/example-images/output/face-feature-batches"
report_path="${repo_root}/example-images/local-test-records/face-feature-batch-report.json"
preflight_only=0
self_test_cleanup=0
self_test_boundaries=0

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
  --self-test-cleanup  Exercise fail-closed cleanup ownership without rendering
  --self-test-boundaries  Exercise stale-report and path-alias failure handling
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
    --self-test-cleanup)
      self_test_cleanup=1
      shift
      ;;
    --self-test-boundaries)
      self_test_boundaries=1
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

admit_report_destination() {
  local admitted_report
  if ! admitted_report="$(python3 - "$repo_root" "$input_dir" "$output_root" "$report_path" <<'PY'
import os
import stat
import sys

repo, input_raw, output_raw, report_raw = sys.argv[1:]

def absolute(raw):
    if not raw or any(ch in raw for ch in ("\n", "\r", "\0")):
        raise ValueError
    if ".." in raw.replace("\\", "/").split("/"):
        raise ValueError
    return os.path.normpath(os.path.abspath(raw))

def contains(parent, child):
    try:
        return os.path.commonpath((parent, child)) == parent
    except ValueError:
        return False

def no_symlink_components(path):
    current = os.path.sep
    for component in path.split(os.path.sep)[1:]:
        current = os.path.join(current, component)
        if os.path.lexists(current) and stat.S_ISLNK(os.lstat(current).st_mode):
            raise ValueError

def require_creatable_parent(path):
    no_symlink_components(path)
    ancestor = path
    while not os.path.exists(ancestor):
        parent = os.path.dirname(ancestor)
        if parent == ancestor:
            raise ValueError
        ancestor = parent
    metadata = os.lstat(ancestor)
    if not stat.S_ISDIR(metadata.st_mode) or not os.access(ancestor, os.W_OK | os.X_OK):
        raise ValueError

repo = absolute(repo)
input_path = absolute(input_raw)
output_path = absolute(output_raw)
report = absolute(report_raw)
report_parent = os.path.dirname(report)
require_creatable_parent(report_parent)
no_symlink_components(report)
if os.path.lexists(report) and not stat.S_ISREG(os.lstat(report).st_mode):
    raise ValueError
if contains(input_path, report) or contains(output_path, report):
    raise ValueError
if contains(report_parent, input_path) or contains(report_parent, output_path):
    raise ValueError
print(report)
PY
)"; then
    echo "report_path_admission_failed" >&2
    return 1
  fi
  [[ -n "$admitted_report" ]] || return 1
  if [[ "$admitted_report" == "$repo_root"/* ]] &&
      ! git -C "$repo_root" check-ignore -q --no-index "$admitted_report"; then
    echo "report_not_owner_local" >&2
    return 1
  fi
  if ! path_operation validate-file-destination "$admitted_report" >/dev/null; then
    echo "report_path_admission_failed" >&2
    return 1
  fi
  report_path="$admitted_report"
}

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
  if ! path_operation validate-existing-directory "$admitted_input" >/dev/null ||
      ! path_operation validate-directory "$admitted_output" >/dev/null ||
      ! path_operation validate-file-destination "$admitted_report" >/dev/null; then
    echo "path_admission_failed" >&2
    return 1
  fi

  input_dir="$admitted_input"
  output_root="$admitted_output"
  report_path="$admitted_report"
}

live_cases_path=""
retained_root=""
repeat_root=""
temporary_workspace=""
publication_temp=""
paths_admitted=0
inventory_admitted=0
report_finalized=0
report_destination_admitted=0
retain_first_attempt=0
failure_reason="preflight_failure"

path_operation() {
  python3 "$path_helper" "$@"
}

ensure_directory() {
  path_operation ensure-directory "$1" >/dev/null
}

make_temporary_file() {
  path_operation temp-file "$1" "$2" "$3"
}

make_temporary_directory() {
  path_operation temp-directory "$1" "$2"
}

atomic_write_stdin() {
  path_operation atomic-write-stdin "$1"
}

verify_direct_child_parent() {
  local candidate="$1"
  local parent="$2"
  local expected_kind="$3"
  python3 - "$candidate" "$parent" "$expected_kind" <<'PY'
import os
import stat
import sys

candidate = os.path.normpath(os.path.abspath(sys.argv[1]))
parent = os.path.normpath(os.path.abspath(sys.argv[2]))
expected_kind = sys.argv[3]
if os.path.dirname(candidate) != parent:
    raise SystemExit(1)

current = os.path.sep
for component in parent.split(os.path.sep)[1:]:
    current = os.path.join(current, component)
    metadata = os.lstat(current)
    if stat.S_ISLNK(metadata.st_mode):
        raise SystemExit(1)
before = os.stat(parent, follow_symlinks=False)
if not stat.S_ISDIR(before.st_mode):
    raise SystemExit(1)

exists = os.path.lexists(candidate)
if expected_kind == "absent":
    if exists:
        raise SystemExit(1)
elif not exists:
    raise SystemExit(1)
else:
    child = os.lstat(candidate)
    if stat.S_ISLNK(child.st_mode):
        raise SystemExit(1)
    if expected_kind == "directory" and not stat.S_ISDIR(child.st_mode):
        raise SystemExit(1)
    if expected_kind == "file" and not stat.S_ISREG(child.st_mode):
        raise SystemExit(1)

after = os.stat(parent, follow_symlinks=False)
if (before.st_dev, before.st_ino) != (after.st_dev, after.st_ino):
    raise SystemExit(1)
PY
}

safe_remove_attempt() {
  local candidate="$1"
  local parent="$2"
  local prefix="$3"
  [[ -z "$candidate" ]] && return 0
  path_operation remove-tree "$candidate" "$parent" "$prefix"
}

safe_remove_temporary_file() {
  local candidate="$1"
  [[ -n "$candidate" ]] || return 0
  path_operation remove-file "$candidate"
}

cleanup_before_publication() {
  local failed=0
  if safe_remove_temporary_file "$live_cases_path"; then
    live_cases_path=""
  else
    failed=1
  fi
  if safe_remove_attempt "$repeat_root" "$(dirname "${repeat_root:-/}")" "beauty_repeat_attempt_"; then
    repeat_root=""
  else
    failed=1
  fi
  if safe_remove_attempt "$temporary_workspace" "$(dirname "${temporary_workspace:-/}")" "beauty_batch_workspace_"; then
    temporary_workspace=""
  else
    failed=1
  fi
  return "$failed"
}

cleanup_temporary_files() {
  local failed=0
  cleanup_before_publication || failed=1
  if safe_remove_temporary_file "$publication_temp"; then
    publication_temp=""
  else
    failed=1
  fi
  if ((retain_first_attempt == 0)) && [[ -n "$retained_root" ]]; then
    if safe_remove_attempt "$retained_root" "$output_root" "attempt_"; then
      retained_root=""
    else
      failed=1
    fi
  fi
  return "$failed"
}

if ((self_test_cleanup == 1)); then
  python3 "$path_helper" --self-test
  temporary_parent="$(python3 -c 'import os,tempfile; print(os.path.realpath(tempfile.gettempdir()))')"
  cleanup_test_root="$(make_temporary_directory "$temporary_parent" "beauty_cleanup_self_test_")"
  repeat_root="$(make_temporary_file "$cleanup_test_root" "not_a_directory_" "")"
  if cleanup_before_publication 2>/dev/null; then
    echo "cleanup_self_test=FAIL unexpected_success" >&2
    exit 1
  fi
  [[ -f "$repeat_root" && "$report_finalized" == 0 && "$retain_first_attempt" == 0 ]] || {
    echo "cleanup_self_test=FAIL publication_not_blocked" >&2
    exit 1
  }
  safe_remove_temporary_file "$repeat_root"
  repeat_root=""
  safe_remove_attempt "$cleanup_test_root" "$temporary_parent" "beauty_cleanup_self_test_"
  echo "cleanup_self_test=PASS forced_failure=1 publication_blocked=1 parent_swap_timing=1 outside_preserved=1"
  exit 0
fi

if ((self_test_boundaries == 1)); then
  [[ -f "$boundary_test" && ! -L "$boundary_test" ]] || exit 1
  python3 "$boundary_test"
  exit
fi

publish_failure_envelope() {
  local reason="$1"
  local quiet="${2:-}"
  local admitted_live=0
  local admitted_selected=0
  local admitted_semantic=0
  ((inventory_admitted == 0)) || {
    admitted_live=75
    admitted_selected=65
    admitted_semantic=8
  }
  admit_report_destination >/dev/null
  ensure_directory "$(dirname "$report_path")"
  if ! python3 - "$reason" "$admitted_live" "$admitted_selected" "$admitted_semantic" <<'PY' |
import json
import sys

reason, live, selected, semantic = sys.argv[1:]
allowed = {
    "preflight_failure", "build_failure", "render_failure", "compare_failure",
    "report_failure", "determinism_failure", "cleanup_failure", "publication_failure"
}
if reason not in allowed:
    reason = "publication_failure"
document = {
    "counts": {
        "liveRendererCases": int(live),
        "selectedCases": int(selected),
        "semanticDirections": int(semantic),
    },
    "reason": reason,
    "schemaVersion": "beauty.face-feature-batch-runner.failure.1",
    "status": "infrastructure_failure",
}
json.dump(document, sys.stdout, ensure_ascii=True, indent=2, sort_keys=True)
sys.stdout.write("\n")
PY
    atomic_write_stdin "$report_path"; then
    return 1
  fi
  admit_report_destination >/dev/null
  verify_direct_child_parent "$report_path" "$(dirname "$report_path")" file
  report_finalized=1
  if [[ "$quiet" != "quiet" ]]; then
    echo "semantic_report=infrastructure_failure reason=${reason}" >&2
  fi
}

on_exit() {
  local status=$?
  trap - EXIT HUP INT TERM
  if ! cleanup_temporary_files; then
    status=2
    failure_reason="cleanup_failure"
    report_finalized=0
  fi
  if ((status != 0 && report_finalized == 0 && preflight_only == 0 &&
        report_destination_admitted == 1)); then
    publish_failure_envelope "$failure_reason" || true
    exit 2
  fi
  if ((status != 0 && preflight_only == 0 &&
        (status != 3 || report_finalized != 1))); then
    exit 2
  fi
  exit "$status"
}
trap on_exit EXIT
trap 'exit 130' HUP INT TERM

validate_inventory() {
  if ! swift "$comparator" --self-test >/dev/null 2>&1; then
    echo "semantic_contract_admission_failed" >&2
    return 1
  fi

  local temporary_parent
  temporary_parent="$(python3 -c 'import os,tempfile; print(os.path.realpath(tempfile.gettempdir()))')"
  live_cases_path="$(make_temporary_file "$temporary_parent" "beauty-live-cases." ".json")"
  verify_direct_child_parent "$live_cases_path" "$(dirname "$live_cases_path")" file
  if ! "$renderer" --list-cases 2>/dev/null | atomic_write_stdin "$live_cases_path"; then
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

[[ -f "$path_helper" && ! -L "$path_helper" ]] || {
  echo "path_helper_admission_failed" >&2
  exit 2
}
if ! admit_report_destination; then
  exit 2
fi
report_destination_admitted=1
if ! admit_paths; then
  exit 2
fi
paths_admitted=1
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
inventory_admitted=1

if ((preflight_only == 1)); then
  echo "preflight=PASS live=75 selected=65 semantic=8"
  exit 0
fi

failure_reason="render_failure"
publish_failure_envelope "render_failure" "quiet"
report_finalized=0
admit_paths
ensure_directory "$output_root"
admit_paths
retained_root="$(make_temporary_directory "$output_root" "attempt_")"
verify_direct_child_parent "$retained_root" "$output_root" directory
temporary_parent="$(python3 -c 'import os,tempfile; print(os.path.realpath(tempfile.gettempdir()))')"
temporary_workspace="$(make_temporary_directory "$temporary_parent" "beauty_batch_workspace_")"
verify_direct_child_parent "$temporary_workspace" "$(dirname "$temporary_workspace")" directory
repeat_root="$(make_temporary_directory "$temporary_parent" "beauty_repeat_attempt_")"
verify_direct_child_parent "$repeat_root" "$(dirname "$repeat_root")" directory
[[ "$repeat_root" != "$repo_root" && "$repeat_root" != "$repo_root"/* ]] || exit 2
first_report="$(make_temporary_file "$temporary_workspace" "first_" ".json")"
repeat_report="$(make_temporary_file "$temporary_workspace" "repeat_" ".json")"
verify_direct_child_parent "$first_report" "$temporary_workspace" file
verify_direct_child_parent "$repeat_report" "$temporary_workspace" file

manifest_rows() {
  python3 - "$manifest" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    manifest = json.load(handle)
for batch in manifest["batches"]:
    for case_id in batch["cases"]:
        print(f"{batch['id']}\t{case_id}")
PY
}

render_attempt() {
  local attempt_root="$1"
  local render_failures=0
  local rendered_units=0

  render_one() {
    local batch_id="$1"
    local case_id="$2"
    local batch_root="${attempt_root}/${batch_id}"
    local case_root="${batch_root}/${case_id}"
    verify_direct_child_parent "$attempt_root" "$(dirname "$attempt_root")" directory
    ensure_directory "$batch_root"
    verify_direct_child_parent "$batch_root" "$attempt_root" directory
    ensure_directory "$case_root"
    verify_direct_child_parent "$case_root" "$batch_root" directory
    if "$renderer" \
        --input "${input_dir}/portraits" \
        --output "$case_root" \
        --case "$case_id" \
        --backend cpu \
        >/dev/null 2>&1; then
      rendered_units=$((rendered_units + 1))
    else
      render_failures=$((render_failures + 1))
      echo "render_failed ${batch_id}/${case_id}" >&2
    fi
    safe_remove_temporary_file "${case_root}/beauty-example-renderer-report.json"
  }

  render_one control "geometryBaseline_noop"
  while IFS=$'\t' read -r batch_id case_id; do
    [[ -n "$batch_id" && -n "$case_id" ]] || continue
    render_one "$batch_id" "$case_id"
  done < <(manifest_rows)

  echo "render_attempt complete=${rendered_units} failures=${render_failures}"
  ((render_failures == 0 && rendered_units == 66))
}

compare_class=""
compare_attempt() {
  local attempt_root="$1"
  local temporary_report="$2"
  local attempt_id
  local comparator_status
  attempt_id="$(basename "$attempt_root")"

  set +e
  swift "$comparator" \
    --input "$input_dir" \
    --run-root "$attempt_root" \
    --manifest "$manifest" \
    --report "$temporary_report" \
    --attempt-id "$attempt_id" \
    >/dev/null 2>&1
  comparator_status=$?
  set -e

  case "$comparator_status" in
    0) compare_class="semantic_pass" ;;
    2) compare_class="semantic_fail" ;;
    *) compare_class="infrastructure_failure"; return 1 ;;
  esac

  python3 - "$temporary_report" "$compare_class" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    report = json.load(handle)
payload = report.get("stablePayload")
expected_status = sys.argv[2]
if not isinstance(payload, dict) or payload.get("verdict") != expected_status:
    raise SystemExit(1)
if len(payload.get("batches", [])) != 5 or len(payload.get("mechanicalCases", [])) != 65:
    raise SystemExit(1)
if len(payload.get("semanticDirections", [])) != 8:
    raise SystemExit(1)
if any(row.get("missingOutputCount") != 0 for row in payload["batches"]):
    raise SystemExit(1)
if any(row.get("missingOutputCount") != 0 for row in payload["mechanicalCases"]):
    raise SystemExit(1)
digest = report.get("stablePayloadDigest")
if not isinstance(digest, str) or len(digest) != 64 or any(ch not in "0123456789abcdef" for ch in digest):
    raise SystemExit(1)
PY
}

first_render_summary="$(render_attempt "$retained_root")" || exit 2
repeat_render_summary="$(render_attempt "$repeat_root")" || exit 2
[[ "$first_render_summary" == "render_attempt complete=66 failures=0" &&
   "$repeat_render_summary" == "render_attempt complete=66 failures=0" ]] || exit 2

failure_reason="compare_failure"
compare_attempt "$retained_root" "$first_report" || exit 2
first_class="$compare_class"
compare_attempt "$repeat_root" "$repeat_report" || exit 2
repeat_class="$compare_class"

failure_reason="determinism_failure"
[[ "$first_class" == "$repeat_class" ]] || exit 2
admit_paths
publication_document="$(python3 - "$first_report" "$repeat_report" "$first_class" <<'PY'
import hashlib
import json
import sys

first_path, repeat_path, status = sys.argv[1:]
with open(first_path, encoding="utf-8") as handle:
    first = json.load(handle)
with open(repeat_path, encoding="utf-8") as handle:
    repeat = json.load(handle)

first_payload = first.get("stablePayload")
repeat_payload = repeat.get("stablePayload")
first_bytes = json.dumps(first_payload, ensure_ascii=False, separators=(",", ":"), sort_keys=True).encode("utf-8")
repeat_bytes = json.dumps(repeat_payload, ensure_ascii=False, separators=(",", ":"), sort_keys=True).encode("utf-8")
if first_bytes != repeat_bytes:
    raise SystemExit(1)
if first.get("stablePayloadDigest") != repeat.get("stablePayloadDigest"):
    raise SystemExit(1)
if first_payload.get("verdict") != status or repeat_payload.get("verdict") != status:
    raise SystemExit(1)
reconciliation_digest = hashlib.sha256(first_bytes).hexdigest()
if first["stablePayloadDigest"] != reconciliation_digest:
    raise SystemExit(1)

document = {
    "schemaVersion": "beauty.face-feature-batch-runner.semantic.1",
    "stableSemanticPayload": first_payload,
    "stableSemanticPayloadDigest": first["stablePayloadDigest"],
    "stableSemanticReconciliationDigest": reconciliation_digest,
    "status": status,
}
encoded = json.dumps(document, ensure_ascii=True, indent=2, sort_keys=True) + "\n"
folded = encoded.lower()
for forbidden in ("/users/", "file://", "../", ".jpg", ".jpeg", ".png", "transcript"):
    if forbidden in folded:
        raise SystemExit(1)
sys.stdout.write(encoded)
PY
)"

failure_reason="compare_failure"
if ! swift "$comparator" \
  --verify-run-inventory \
  --input "$input_dir" \
  --run-root "$retained_root" \
  --manifest "$manifest" \
  --attempt-id "$(basename "$retained_root")" \
  >/dev/null 2>&1; then
  exit 2
fi
failure_reason="cleanup_failure"
cleanup_before_publication || exit 2
failure_reason="publication_failure"
printf '%s' "$publication_document" | atomic_write_stdin "$report_path"
unset publication_document
admit_report_destination
verify_direct_child_parent "$report_path" "$(dirname "$report_path")" file
report_finalized=1
retain_first_attempt=1

echo "semantic_report=${first_class} batches=5 cases=65 directions=8 attempts=2"
if [[ "$first_class" == "semantic_pass" ]]; then
  exit 0
fi
exit 3
