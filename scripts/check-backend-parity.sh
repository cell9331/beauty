#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly package_root="${repository_root}/BeautySDK"
readonly maximum_output_bytes=$((16 * 1024 * 1024))
readonly focused_filter='BeautyEffectsTests.BeautyBackendParityTests|BeautyEffectsTests.BeautyBackendSafetyParityTests|BeautyEffectsTests.BeautyBackendDeterminismParityTests|BeautyCoreTests.BeautyBackendSelectionConcurrencyTests'
readonly expected_focused_tests=12
temporary_root=""

cleanup() {
  if [[ -n "${temporary_root}" ]]; then rm -rf -- "${temporary_root}"; fi
}
trap cleanup EXIT

run_bounded() {
  local log_path="$1"
  shift
  local -a pipeline_status
  set +e
  "$@" 2>&1 | head -c "${maximum_output_bytes}" >"${log_path}"
  pipeline_status=("${PIPESTATUS[@]}")
  set -e
  return "${pipeline_status[0]}"
}

validate_static_boundary() {
  local root="$1"
  python3 - "$root" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1]).resolve()
if not root.is_dir() or root.is_symlink():
    raise SystemExit("parity root is not regular")

paths = {
    "fixture": "BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift",
    "parity": "BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityTests.swift",
    "safety": "BeautySDK/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift",
    "determinism": "BeautySDK/Tests/BeautyEffectsTests/BeautyBackendDeterminismParityTests.swift",
    "selection": "BeautySDK/Tests/BeautyCoreTests/BeautyBackendSelectionConcurrencyTests.swift",
    "config": "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift",
    "parameters": "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "manifest": "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
    "renderer": "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
    "package": "BeautySDK/Package.swift",
}

def regular(relative):
    path = root / relative
    resolved = path.resolve()
    if path.is_symlink() or not path.is_file() or resolved != path or root not in resolved.parents:
        raise SystemExit(f"missing or non-regular parity source: {relative}")
    return path

files = {name: regular(relative) for name, relative in paths.items()}
text = {name: path.read_text(encoding="utf-8") for name, path in files.items()}
tests = "\n".join(text[name] for name in ("fixture", "parity", "safety", "determinism", "selection"))
implementation = text["fixture"] + text["parity"] + text["safety"] + text["determinism"] + text["selection"]
tests_lower = tests.lower()

for marker in (
    "CPUReferenceFixtureFactory", "BeautyCPUBackend", "BeautyMetalBackend",
    "BeautyBackendRequest", "rgbaBytes", "BeautyBackendParityObservation",
    "kind", "width", "height", "preservesAlpha", "preservesExtent", "namedSRGB",
    "activeMaxChannelDelta", "activeMeanRGBDelta", "maxChannelDelta", "meanRGBDelta",
):
    if marker not in tests:
        raise SystemExit(f"parity marker missing: {marker}")
if "XCTAssertEqual(gpuBytes, cpuBytes)" not in text["parity"]:
    raise SystemExit("exact neutral CPU comparison missing")
if "BeautyBackendSafetyParityTests" not in text["safety"]:
    raise SystemExit("safety suite missing")
for marker in (
    "containment", "protected", "outside", "collision", "noFace", "malformed",
    "rejected", "sibling", "localityEnvelope", "changed.isSubset",
):
    if marker.lower() not in tests_lower:
        raise SystemExit(f"safety marker missing: {marker}")
for marker in ("withThrowingTaskGroup", "request-local", "metalUnavailable", "callCount", "resourceCountersForTesting"):
    if marker.lower() not in tests_lower:
        raise SystemExit(f"determinism/availability marker missing: {marker}")
if "metal_available" not in text["selection"] + text["determinism"] or "metal_unavailable" not in text["selection"] + text["determinism"]:
    raise SystemExit("separate Metal availability markers missing")
if "BeautyBackendExecutionPolicy" not in text["selection"]:
    raise SystemExit("request policy marker missing")
if not re.search(r"activeMaxChannelDelta\s*=\s*8(?!\d)", text["fixture"]) or not re.search(r"activeMeanRGBDelta\s*=\s*5\.0(?!\d)", text["fixture"]):
    raise SystemExit("pinned tolerance weakened or removed")
if "metal_available" not in text["fixture"] + text["selection"]:
    # Keep the accounting vocabulary in the source contract, even though the
    # live script is the aggregate emitter.
    raise SystemExit("available classification marker missing")
if "metal_unavailable" not in text["fixture"] + text["selection"]:
    raise SystemExit("unavailable classification marker missing")

for forbidden in ("XCTSkip", "FileManager", "URLSession", "UIKit", "SwiftUI", "AVCapture", "UIApplication", "NSApplication", "Network", "sleep(", "Thread.sleep"):
    if forbidden in implementation:
        raise SystemExit(f"forbidden parity scope/output marker: {forbidden}")
if re.search(r"\b(?:print|debugPrint)\s*\(", implementation):
    raise SystemExit("raw diagnostic output entered parity tests")
if re.search(r"\b(?:while\s+true|repeat\s*\{)", implementation):
    raise SystemExit("unbounded parity loop entered tests")
if re.search(r"\bpublic\s+(?:class|struct|enum|protocol)\b", implementation):
    raise SystemExit("public parity API drifted into test targets")

parameters = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", text["parameters"], re.MULTILINE)
if len(parameters) != 61 or len(set(parameters)) != 61:
    raise SystemExit("BeautyParameters inventory changed")
if "BeautyRenderBackend" in text["parameters"]:
    raise SystemExit("backend selector leaked into parameters")
if "\.package(" in text["package"] or re.search(r"https?://", text["package"]):
    raise SystemExit("package dependency drifted")
if len(re.findall(r"^\s*RenderCase\(", text["renderer"], re.MULTILINE)) != 74:
    raise SystemExit("renderer inventory changed")
print("backend_parity_static_boundary_passed")
PY
}

validate_focused_log() {
  local log_path="$1"
  python3 - "$log_path" "$expected_focused_tests" <<'PY'
from pathlib import Path
import re
import sys
text = Path(sys.argv[1]).read_text(encoding="utf-8")
expected = int(sys.argv[2])
executions = [(int(value), int(failures)) for value, failures in re.findall(r"Executed (\d+) tests?, with (\d+) failures?", text)]
if not executions or executions[-1][0] != expected or max(value for value, _ in executions) != expected:
    raise SystemExit("focused count mismatch")
if any(failures != 0 for _, failures in executions):
    raise SystemExit("focused failure")
for suite in ("BeautyBackendParityTests", "BeautyBackendSafetyParityTests", "BeautyBackendDeterminismParityTests", "BeautyBackendSelectionConcurrencyTests"):
    if suite not in text: raise SystemExit(f"suite missing: {suite}")
if re.search(r"\b(?:skipped|disabled|unexpected failure)\b", text, re.IGNORECASE):
    raise SystemExit("focused skip or unexpected failure")
PY
}

probe_availability() {
  local log_path="$1"
  if run_bounded "$log_path" swift -e 'import Metal; print(MTLCreateSystemDefaultDevice() == nil ? "metal_unavailable" : "metal_available")'; then
    local value
    value="$(tr -d '[:space:]' <"$log_path")"
    [[ "$value" == "metal_available" || "$value" == "metal_unavailable" ]] && { printf '%s' "$value"; return; }
  fi
  printf '%s' "metal_unavailable"
}

self_test() {
  temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-backend-parity-self-test.XXXXXX")"
  cp -R -- "$package_root" "$temporary_root/BeautySDK"
  validate_static_boundary "$temporary_root"
  local mutation_path="$temporary_root/BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityTests.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("XCTAssertEqual(gpuBytes, cpuBytes)", "XCTAssertEqual(gpuBytes.count, cpuBytes.count)", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "cpu_oracle_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendParityTests.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("activeMaxChannelDelta = 8", "activeMaxChannelDelta = 80", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "tolerance_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("changed.isSubset(of: envelope)", "true", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "safety_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift"
  printf '\nlet rawOutput = FileManager.default\n' >>"$mutation_path"
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "raw_output_mutation_failed" >&2; return 1; fi
  echo "backend_parity_self_test_passed"
}

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  self_test
  exit $?
fi
[[ "$#" -eq 0 ]] || exit 2
for command_name in python3 swift; do command -v "$command_name" >/dev/null || exit 1; done
validate_static_boundary "$repository_root" >/dev/null || { echo "backend_parity_static_boundary_failed"; exit 1; }
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-backend-parity.XXXXXX")"
run_bounded "$temporary_root/focused.log" swift test --package-path "$package_root" --filter "$focused_filter" || { echo "backend_parity_focused_tests_failed"; exit 1; }
validate_focused_log "$temporary_root/focused.log" || { echo "backend_parity_focused_accounting_failed"; exit 1; }
availability="$(probe_availability "$temporary_root/availability.log")"
if [[ "$availability" == "metal_available" ]]; then metal_available=1; metal_unavailable=0; else metal_available=0; metal_unavailable=1; fi
echo "backend_parity_preflight_passed"
echo "focused_tests=${expected_focused_tests}"
echo "metal_available=${metal_available}"
echo "metal_unavailable=${metal_unavailable}"
