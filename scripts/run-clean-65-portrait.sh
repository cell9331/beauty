#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
phase="$root/.planning/phases/95-compatibility-and-sdk-only-closeout"
report="$phase/95-CLEAN-65-REPORT.json"
runner="$root/scripts/run-face-feature-batches.sh"
manifest="$root/scripts/face-feature-batch-manifest.json"

active=(chinTaper gazeCorrection eyebrowHeadSpacingPositive eyebrowHeadSpacingNegative \
  noseBridge noseRootNarrowing mouthWidthNegative)

usage() { echo "Usage: $0 --self-test|--prepare|--run|--classify|--report"; }

load_registration() {
  local admitted
  admitted="$(python3 - "$root" "$phase/95-ROI-REGISTRATION.json" <<'PY'
import hashlib, importlib.util, json, pathlib, re, sys
root, binding = map(pathlib.Path, sys.argv[1:])
if binding.is_symlink() or not binding.is_file(): raise SystemExit("registration_missing")
record = json.loads(binding.read_text())
if record.get("schema") != "phase95-portrait-registration-v1" or record.get("status") != "registered":
    raise SystemExit("registration_invalid")
for key, name in (("manifest_sha256", "scripts/face-feature-batch-manifest.json"),):
    if hashlib.sha256((root/name).read_bytes()).hexdigest() != record.get(key):
        raise SystemExit("registration_identity_mismatch")
for key in ("contracts_sha256", "source_sha256"):
    if not re.fullmatch("[0-9a-f]{64}", record.get(key, "")): raise SystemExit("registration_invalid")
    print(record[key])
# The original registration preserves its historical comparator identity.
# Current execution is bound by the reviewed surface successor admission.
spec = importlib.util.spec_from_file_location("phase95_evidence", root / "scripts/phase95-closeout-evidence.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
admission = module.root_admission(root)
print(admission["measurement_identity"])
PY
)" || return 2
  BEAUTY_PHASE95_ROI_DIGEST="$(printf '%s\n' "$admitted" | sed -n '1p')"
  BEAUTY_PHASE95_SOURCE_DIGEST="$(printf '%s\n' "$admitted" | sed -n '2p')"
  BEAUTY_PHASE95_ROOT_MEASUREMENT_IDENTITY="$(printf '%s\n' "$admitted" | sed -n '3p')"
  export BEAUTY_PHASE95_ROI_DIGEST BEAUTY_PHASE95_SOURCE_DIGEST BEAUTY_PHASE95_ROOT_MEASUREMENT_IDENTITY
}

self_test() {
  python3 - "$manifest" "$runner" "$root/scripts/compare-face-feature-batches.swift" <<'PY'
import json, pathlib, sys
manifest = json.loads(pathlib.Path(sys.argv[1]).read_text())
runner = pathlib.Path(sys.argv[2]); comparator = pathlib.Path(sys.argv[3])
cases = [c for b in manifest["batches"] for c in b["cases"]]
expected = {"chinTaper_0p25", "gazeCorrection_0p25", "eyebrowHeadSpacing_plus0p25",
            "eyebrowHeadSpacing_minus0p25", "noseBridge_0p30", "noseRootNarrowing_0p25",
            "mouthWidth_minus0p35"}
checks = [len(manifest["batches"]) == 5, len(cases) == 65,
          len(set(cases)) == 65, runner.is_file(), manifest.get("schemaVersion") ==
          "beauty.face-feature-batch-manifest.semantic.1", "geometryBaseline_noop" not in cases,
          expected <= set(cases), all(isinstance(b.get("cases"), list) for b in manifest["batches"]),
          all(isinstance(c, str) and c for c in cases), pathlib.Path(sys.argv[1]).is_file(),
          not runner.is_symlink(), "faceContourSmooth_0p25" in cases,
          len(expected) == 7, len({b["id"] for b in manifest["batches"]}) == 5,
          all("cases" in b and "id" in b for b in manifest["batches"]), comparator.is_file()]
if len(checks) != 16 or not all(checks): raise SystemExit("clean65_self_test_failure")
print('{"status":"clean65_self_test_pass","discovered":16,"executed":16,"passed":16,"failed":0,"skipped":0}')
PY
}

prepare() {
  # The underlying runner creates fresh owned attempts and atomically replaces
  # its report. Do not recursively erase previous owner-local evidence.
  "$runner" --preflight-only
}

run_batches() {
  load_registration
  local report_path="$root/example-images/local-test-records/face-feature-batch-report.json"
  if [[ "${BEAUTY_PHASE95_MANAGED_PROCESS_GROUP:-}" == "1" ]]; then
    # The reviewed outer gate owns wall/monotonic deadlines and group cleanup.
    # Do not create a nested session that can survive its supervisor.
    exec "$runner" --report "$report_path"
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout 900 "$runner" --report "$report_path"
  elif command -v timeout >/dev/null 2>&1; then
    timeout 900 "$runner" --report "$report_path"
  else
    python3 - "$runner" "$report_path" <<'PY'
import os
import signal
import subprocess
import sys

runner, report = sys.argv[1:]
try:
    process = subprocess.Popen([runner, "--report", report], start_new_session=True)
    completed = process.wait(timeout=900)
except subprocess.TimeoutExpired:
    try:
        os.killpg(process.pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait(timeout=5)
    raise SystemExit(124)
raise SystemExit(completed)
PY
  fi
}

classify() {
  load_registration
  python3 - "$root" "$report" <<'PY'
import json, pathlib, subprocess, sys
root, dst = map(pathlib.Path, sys.argv[1:])
result = subprocess.run(["swift", str(root / "scripts/compare-face-feature-batches.swift"),
    "--classify-phase95", "--manifest", str(root / "scripts/face-feature-batch-manifest.json"),
    "--report", str(root / "example-images/local-test-records/face-feature-batch-report.json")],
    stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=120)
if result.returncode:
    raise SystemExit("clean65_classification_failed")
out = json.loads(result.stdout)
if dst.is_symlink() or any(p.is_symlink() for p in dst.parents):
    raise SystemExit("clean65_destination_failed")
dst.write_text(json.dumps(out, indent=2, sort_keys=True)+"\n")
print(json.dumps({"status":out["status"], "comparison_count":out["comparison_count"]}))
PY
}

case "${1:-}" in
  --self-test) self_test;;
  --prepare) prepare;;
  --run) run_batches;;
  --classify) classify;;
  --report) test -f "$report" && cat "$report";;
  *) usage >&2; exit 2;;
esac
