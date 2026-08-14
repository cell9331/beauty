#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly package_root="${repository_root}/BeautySDK"
readonly test_root="${package_root}/Tests"
readonly maximum_output_bytes=$((16 * 1024 * 1024))
readonly generated_sources=(
  "BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureFactory.swift"
  "BeautySDK/Tests/BeautyEffectsTests/CPUReferenceMetrics.swift"
  "BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureTests.swift"
  "BeautySDK/Tests/BeautyEffectsTests/CPUReferenceGeometryOracleTests.swift"
  "BeautySDK/Tests/BeautyEffectsTests/CPUReferenceColorOracleTests.swift"
  "BeautySDK/Tests/BeautyEffectsTests/CPUReferenceLocalRetouchOracleTests.swift"
  "BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureFactory.swift"
  "BeautySDK/Tests/BeautyCoreTests/CPUReferenceFacadeFixtureTests.swift"
  "BeautySDK/Tests/BeautyCoreTests/CPUReferenceDeterminismTests.swift"
)
readonly native_fixture_sources=(
  "BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift"
  "BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift"
)
suite_package_root="${package_root}"

cleanup_root=""

cleanup() {
  if [[ -n "${cleanup_root}" ]]; then
    rm -rf -- "${cleanup_root}"
  fi
}

trap cleanup EXIT

run_bounded() {
  local maximum_bytes="$1"
  local log_path="$2"
  shift 2
  local -a pipeline_status
  set +e
  "$@" 2>&1 | head -c "${maximum_bytes}" >"${log_path}"
  pipeline_status=("${PIPESTATUS[@]}")
  set -e
  return "${pipeline_status[0]}"
}

validate_static_boundary() {
  local root="$1"
  python3 - "${root}" "${generated_sources[@]}" "--native" "${native_fixture_sources[@]}" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1]).resolve()
arguments = sys.argv[2:]
native_marker = arguments.index("--native")
generated = arguments[:native_marker]
native = arguments[native_marker + 1:]

if not root.is_dir() or root.is_symlink():
    raise SystemExit(1)

def regular_source(relative):
    path = root / relative
    resolved = path.resolve()
    if path.suffix != ".swift" or path.is_symlink() or not path.is_file():
        raise SystemExit(1)
    if resolved != path or root not in resolved.parents:
        raise SystemExit(1)
    if not str(resolved).startswith(str(root / "BeautySDK" / "Tests") + "/"):
        raise SystemExit(1)
    return path

forbidden = re.compile(
    r"(?:example-images|local-retouch-review|archives/|\.(?:png|jpe?g|heic)\b|"
    r"Data\s*\(\s*contentsOf|String\s*\(\s*contentsOfFile|contentsOfFile|"
    r"CIImage\s*\(\s*contentsOf|CGImageSourceCreateWithURL|"
    r"(?:URL|FilePath)\s*\(|FileManager|ImageIO|"
    r"(?:write|createFile)\s*\(|FileHandle|CGImageDestination|OutputStream|"
    r"Bundle\.|ProcessInfo|PHASE(?:59|60|62|63)_[A-Z0-9_]+|file://|"
    r"(?<![A-Za-z0-9_])/(?:tmp|var|Users|private)(?:/|\b)|"
    r"\b(?:print|debugPrint|dump)\s*\(|"
    r"\b(?:Metal|MetalKit|MTL[A-Za-z0-9_]*|GPUImage|GPU[A-Za-z0-9_]*|"
    r"UIKit|SwiftUI|UIView[A-Za-z0-9_]*|UIImage|UIApplication|NSApplication|"
    r"AppDelegate|Demo[A-Za-z0-9_]*|application[A-Za-z0-9_]*)\b|"
    r"XCTSkip\s*\()",
    re.IGNORECASE,
)

for relative in generated:
    text = regular_source(relative).read_text(encoding="utf-8")
    if forbidden.search(text):
        raise SystemExit(1)
    if "CPUReference" not in text:
        raise SystemExit(1)

native_requirements = {
    "BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift": (
        "PHASE60_REQUIRE_LOCAL_EVIDENCE",
        "PHASE59_TEETH_BUNDLE",
    ),
    "BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift": (
        "PHASE63_REQUIRE_LOCAL_EVIDENCE",
        "PHASE62_SCLERA_BUNDLE",
    ),
}
if set(native) != set(native_requirements):
    raise SystemExit(1)
for relative, required_guards in native_requirements.items():
    text = regular_source(relative).read_text(encoding="utf-8")
    if any(text.count(token) != 1 for token in required_guards):
        raise SystemExit(1)
    if text.count("XCTSkip") != 1:
        raise SystemExit(1)
if any(Path(relative).name in {Path(item).name for item in native} for relative in generated):
    raise SystemExit(1)
PY
}

run_generated_suite() {
  local label="$1"
  local filter="$2"
  local expected_count="$3"
  local expected_suites="$4"
  local log_path="${cleanup_root}/${label}.log"
  local status=0

  run_bounded "${maximum_output_bytes}" "${log_path}" \
    swift test --package-path "${suite_package_root}" --filter "${filter}" || status=$?
  if [[ "${status}" -ne 0 ]]; then
    return 1
  fi
  if ! python3 - "${log_path}" "${expected_count}" "${expected_suites}" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
expected = int(sys.argv[2])
expected_suites = sys.argv[3].split("|")
executions = [int(value) for value in re.findall(r"Executed (\d+) tests?, with 0 failures", text)]
if not executions or max(executions) != expected or executions[-1] != expected:
    raise SystemExit(1)
if any(suite not in text for suite in expected_suites):
    raise SystemExit(1)
if re.search(r"(?:failed|skipped|disabled|unexpected failure)", text, re.IGNORECASE):
    raise SystemExit(1)
Path(sys.argv[1] + ".count").write_text(str(executions[-1]), encoding="utf-8")
PY
  then
    return 1
  fi
}

self_test() {
  local self_test_root mutation_path relative destination mutation
  self_test_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-cpu-oracles-self-test.XXXXXX")"
  cleanup_root="${self_test_root}"
  for relative in "${generated_sources[@]}" "${native_fixture_sources[@]}"; do
    destination="${self_test_root}/${relative}"
    mkdir -p "$(dirname -- "${destination}")"
    cp -- "${repository_root}/${relative}" "${destination}"
  done
  validate_static_boundary "${self_test_root}"
  mutation_path="${self_test_root}/${generated_sources[0]}"
  printf '\nprint("forbidden")\n' >>"${mutation_path}"
  if validate_static_boundary "${self_test_root}"; then
    echo "cpu_reference_oracles_self_test_failed" >&2
    return 1
  fi
  for mutation in \
      'CIImage(contentsOf: URL(fileURLWithPath: "/private/portrait.png"))' \
      'let absoluteFixture = "/tmp/generated-fixture.png"' \
      'let device: MTLDevice? = nil' \
      'import MetalKit' \
      'import UIKit' \
      'let demoApplication = Application.shared'; do
    cp -- "${repository_root}/${generated_sources[0]}" "${mutation_path}"
    printf '\n%s\n' "${mutation}" >>"${mutation_path}"
    if validate_static_boundary "${self_test_root}"; then
      echo "cpu_reference_oracles_scope_mutation_self_test_failed" >&2
      return 1
    fi
  done
  cp -- "${repository_root}/${generated_sources[0]}" "${mutation_path}"
  mutation_path="${self_test_root}/${native_fixture_sources[0]}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("PHASE60_REQUIRE_LOCAL_EVIDENCE", "PHASE60_REMOVED", 1)
path.write_text(text, encoding="utf-8")
PY
  if validate_static_boundary "${self_test_root}"; then
    echo "cpu_reference_oracles_native_guard_self_test_failed" >&2
    return 1
  fi
  cp -R -- "${package_root}" "${self_test_root}/BeautySDK"
  mutation_path="${self_test_root}/BeautySDK/Tests/BeautyEffectsTests/CPUReferenceFixtureTests.swift"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
old = "testRepeatedConstructionHasIdenticalBytesAndMetrics"
new = "renamedRepeatedConstructionHasIdenticalBytesAndMetrics"
if old not in text:
    raise SystemExit(1)
path.write_text(text.replace(old, new, 1), encoding="utf-8")
PY
  suite_package_root="${self_test_root}/BeautySDK"
  if run_generated_suite "mutation" \
      "BeautyEffectsTests.CPUReferenceFixtureTests|BeautyCoreTests.CPUReferenceFacadeFixtureTests" 15 \
      "CPUReferenceFixtureTests|CPUReferenceFacadeFixtureTests"; then
    echo "cpu_reference_oracles_count_self_test_failed" >&2
    return 1
  fi
  echo "cpu_reference_oracles_self_test_passed"
}

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  self_test
  exit $?
fi
[[ "$#" -eq 0 ]] || exit 2

for command_name in python3 swift; do
  command -v "${command_name}" >/dev/null || {
    echo "cpu_reference_oracles_preflight_failed"
    exit 1
  }
done

validate_static_boundary "${repository_root}" || {
  echo "cpu_reference_oracles_static_boundary_failed"
  exit 1
}
echo "cpu_reference_oracles_static_boundary_verified"

cleanup_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-cpu-oracles.XXXXXX")"
run_generated_suite "fixtures" \
  "BeautyEffectsTests.CPUReferenceFixtureTests|BeautyCoreTests.CPUReferenceFacadeFixtureTests" 15 \
  "CPUReferenceFixtureTests|CPUReferenceFacadeFixtureTests" || {
  echo "cpu_reference_oracles_fixture_tests_failed"
  exit 1
}
run_generated_suite "geometry-color" \
  "BeautyEffectsTests.CPUReferenceGeometryOracleTests|BeautyEffectsTests.CPUReferenceColorOracleTests" 10 \
  "CPUReferenceGeometryOracleTests|CPUReferenceColorOracleTests" || {
  echo "cpu_reference_oracles_geometry_color_tests_failed"
  exit 1
}
run_generated_suite "local-determinism" \
  "BeautyEffectsTests.CPUReferenceLocalRetouchOracleTests|BeautyCoreTests.CPUReferenceDeterminismTests" 16 \
  "CPUReferenceLocalRetouchOracleTests|CPUReferenceDeterminismTests" || {
  echo "cpu_reference_oracles_local_determinism_tests_failed"
  exit 1
}

fixture_count="$(<"${cleanup_root}/fixtures.log.count")"
geometry_color_count="$(<"${cleanup_root}/geometry-color.log.count")"
local_determinism_count="$(<"${cleanup_root}/local-determinism.log.count")"
echo "cpu_reference_oracles_passed fixture_tests=${fixture_count} geometry_color_tests=${geometry_color_count} local_determinism_tests=${local_determinism_count}"
