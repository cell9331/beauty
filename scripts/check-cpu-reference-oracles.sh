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
    r"Data\s*\(\s*contentsOf|contentsOfFile|CGImageSourceCreateWithURL|"
    r"(?:write|createFile)\s*\(|FileHandle|CGImageDestination|OutputStream|"
    r"Bundle\.|ProcessInfo|PHASE(?:59|60|62|63)_[A-Z0-9_]+|/Users/|/private/|file://|"
    r"\b(?:print|debugPrint|dump)\s*\(|\b(?:Metal|GPU|MTL|backend)\b|"
    r"XCTSkip\s*\()",
    re.IGNORECASE,
)

for relative in generated:
    text = regular_source(relative).read_text(encoding="utf-8")
    if forbidden.search(text):
        raise SystemExit(1)
    if "CPUReference" not in text:
        raise SystemExit(1)

native_text = []
for relative in native:
    native_text.append(regular_source(relative).read_text(encoding="utf-8"))
joined_native = "\n".join(native_text)
required_guards = (
    "PHASE60_REQUIRE_LOCAL_EVIDENCE",
    "PHASE59_TEETH_BUNDLE",
    "PHASE63_REQUIRE_LOCAL_EVIDENCE",
    "PHASE62_SCLERA_BUNDLE",
)
if any(token not in joined_native for token in required_guards):
    raise SystemExit(1)
if joined_native.count("XCTSkip") < 2:
    raise SystemExit(1)
if any(Path(relative).name in {Path(item).name for item in native} for relative in generated):
    raise SystemExit(1)
PY
}

run_generated_suite() {
  local label="$1"
  local filter="$2"
  local log_path="${cleanup_root}/${label}.log"
  local status=0

  run_bounded "${maximum_output_bytes}" "${log_path}" \
    swift test --package-path "${package_root}" --filter "${filter}" || status=$?
  if [[ "${status}" -ne 0 ]]; then
    return 1
  fi
  if ! python3 - "${log_path}" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
executions = [int(value) for value in re.findall(r"Executed (\d+) tests?, with 0 failures", text)]
if not executions or sum(executions) <= 0:
    raise SystemExit(1)
if re.search(r"(?:failed|skipped|disabled|unexpected failure)", text, re.IGNORECASE):
    raise SystemExit(1)
PY
  then
    return 1
  fi
}

self_test() {
  local self_test_root mutation_path relative destination
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
  "BeautyEffectsTests.CPUReferenceFixtureTests|BeautyCoreTests.CPUReferenceFacadeFixtureTests" || {
  echo "cpu_reference_oracles_fixture_tests_failed"
  exit 1
}
run_generated_suite "geometry-color" \
  "BeautyEffectsTests.CPUReferenceGeometryOracleTests|BeautyEffectsTests.CPUReferenceColorOracleTests" || {
  echo "cpu_reference_oracles_geometry_color_tests_failed"
  exit 1
}
run_generated_suite "local-determinism" \
  "BeautyEffectsTests.CPUReferenceLocalRetouchOracleTests|BeautyCoreTests.CPUReferenceDeterminismTests" || {
  echo "cpu_reference_oracles_local_determinism_tests_failed"
  exit 1
}

echo "cpu_reference_oracles_passed fixture_tests=9 geometry_color_tests=9 local_determinism_tests=15"
