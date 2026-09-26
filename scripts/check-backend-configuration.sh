#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly package_root="${repository_root}/BeautySDK"
readonly maximum_output_bytes=$((16 * 1024 * 1024))
readonly expected_focused_tests=20

temporary_root=""
cleanup() {
  if [[ -n "${temporary_root}" ]]; then
    rm -rf -- "${temporary_root}"
  fi
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
  python3 - "${root}" <<'PY'
from pathlib import Path
import json
import re
import sys

root = Path(sys.argv[1]).resolve()
if not root.is_dir() or root.is_symlink():
    raise SystemExit("backend configuration root is not a regular directory")

paths = {
    "configuration": "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift",
    "factory": "BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift",
    "engine": "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
    "canonicalizer": "BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift",
    "configuration_tests": "BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift",
    "routing_tests": "BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift",
    "parameters": "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "manifest": "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
    "renderer": "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
    "package": "BeautySDK/Package.swift",
}

def regular(relative):
    path = root / relative
    resolved = path.resolve()
    if path.is_symlink() or not path.is_file() or resolved != path or root not in resolved.parents:
        raise SystemExit(f"missing or non-regular source: {relative}")
    return path

files = {name: regular(relative) for name, relative in paths.items()}
text = {name: path.read_text(encoding="utf-8") for name, path in files.items()}

def code(value):
    value = re.sub(r"/\*.*?\*/", "", value, flags=re.DOTALL)
    return "\n".join(line.split("//", 1)[0] for line in value.splitlines())

configuration = code(text["configuration"])
factory = code(text["factory"])
engine = code(text["engine"])
canonicalizer = code(text["canonicalizer"])
implementation = factory + "\n" + engine

if re.search(r"\bpublic\s+(?:(?:final|indirect)\s+)?(?:class|struct|enum|protocol)\s+BeautyBackend", factory):
    raise SystemExit("backend factory leaked a public declaration")
if "public enum BeautyRenderBackend" not in configuration:
    raise SystemExit("public backend enum is missing")
if len(re.findall(r"^\s*case\s+(?:cpu|gpu)\b", configuration, re.MULTILINE)) != 2:
    raise SystemExit("backend enum must expose exactly cpu and gpu cases")
if not re.search(r"case\s+cpu\b", configuration) or not re.search(r"case\s+gpu\b", configuration):
    raise SystemExit("backend enum cases are incomplete")
for marker in (
    "Still-image input must be exact-opaque, finite,",
    "bounded RGB; unsupported alpha fails before detection",
    "still-image output is materialized in the named sRGB color space",
):
    if marker not in text["configuration"]:
        raise SystemExit(f"public GPU still-image policy marker missing: {marker}")
for marker in (
    "public var renderBackend: BeautyRenderBackend",
    "renderBackend: BeautyRenderBackend = .cpu",
    "BeautyRenderBackend.self",
    "forKey: .renderBackend",
    "?? .cpu",
):
    if marker not in configuration:
        raise SystemExit(f"configuration marker missing: {marker}")

if "package enum BeautyBackendFactory" not in factory:
    raise SystemExit("package backend factory is missing")
if factory.count("case .cpu") != 1 or factory.count("case .gpu") != 1:
    raise SystemExit("factory does not have exactly one closed CPU/GPU branch")
for marker in (
    "configuration.renderBackend",
    "BeautyCPUBackend()",
    "BeautyMetalBackend",
    "metalFactory",
    "configuration.maximumInputPixelCount",
    "policy: .cpu",
    "policy: .metal",
):
    if marker not in factory:
        raise SystemExit(f"factory marker missing: {marker}")
if re.search(r"\b(?:fallback|retry|alternate|recover)\b", implementation, re.IGNORECASE):
    raise SystemExit("backend selection contains fallback/retry behavior")

if "BeautyBackendFactory.select" not in engine or "backendPolicy" not in engine:
    raise SystemExit("engine does not retain factory selection and policy")
if engine.count("policy: backendPolicy") != 3:
    raise SystemExit("not all backend request routes propagate backendPolicy")
if "package init(" not in engine or "backendExecutor" not in engine:
    raise SystemExit("package-only injected executor seam is missing")
if "public init(" not in engine:
    raise SystemExit("public engine initializer is missing")

metal_preflight = "preflightOpaqueBoundedRGBForMetalStillImage"
for marker in (
    f"package func {metal_preflight}",
    "inputColorSpace.model == .rgb",
    "inputColorSpace.supportsOutput",
    "CGColorSpaceUsesExtendedRange(inputColorSpace) == false",
    'filterName: "CIAreaMinimum"',
    'filterName: "CIAreaMaximum"',
    "minimum.allSatisfy(\\.isFinite)",
    "maximum.allSatisfy(\\.isFinite)",
    "minimum[3] == 1",
    "maximum[3] == 1",
):
    if marker not in canonicalizer:
        raise SystemExit(f"Metal opaque/RGB preflight marker missing: {marker}")
still_signature = "public func processResult(\n        image: CIImage,"
still_start = engine.find(still_signature)
still_end = engine.find("\n    private func legacyStillImageResult", still_start)
if still_start < 0 or still_end < 0:
    raise SystemExit("still-image facade boundary is missing")
still_facade = engine[still_start:still_end]
metal_guard = "if backendPolicy == .metal {"
guard_index = still_facade.find(metal_guard)
preflight_index = still_facade.find(metal_preflight)
ordered_markers = (
    "BeautySDKResources.validate",
    "BeautyEffectResolver.localRetouchAdmission",
    "legacyStillImageResult",
    "resolveStillImageGeometry",
)
if guard_index < 0 or preflight_index < guard_index:
    raise SystemExit("Metal still-image preflight is not guarded by the selected policy")
last_index = preflight_index
for marker in ordered_markers:
    index = still_facade.find(marker)
    if index <= last_index:
        raise SystemExit(f"Metal still-image preflight ordering drifted before: {marker}")
    last_index = index

if "renderBackend" in text["parameters"]:
    raise SystemExit("backend policy leaked into BeautyParameters")
parameters = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", text["parameters"], re.MULTILINE)
configuration_fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", text["configuration"], re.MULTILINE)
if len(parameters) != 66 or len(set(parameters)) != 66:
    raise SystemExit("BeautyParameters inventory changed")
if len(configuration_fields) != 11 or len(set(configuration_fields)) != 11:
    raise SystemExit("BeautyConfiguration inventory must be 11 fields")

if "BeautyRenderBackend" not in text["configuration_tests"]:
    raise SystemExit("configuration regression coverage is missing")
for marker in (
    "BeautyBackendFactory",
    "metalUnavailable",
    "testPublicGPUConstructionIsExplicitlyAvailableOrTypedUnavailable",
    "lastPolicy",
):
    if marker not in text["routing_tests"]:
        raise SystemExit(f"routing regression marker missing: {marker}")
transparent_name = "func testGPUStillImageRejectsTransparencyBeforeBackendExecution() throws"
transparent_start = text["routing_tests"].find(transparent_name)
transparent_end = text["routing_tests"].find("\n    func ", transparent_start + len(transparent_name))
if transparent_start < 0 or transparent_end < 0:
    raise SystemExit("transparent GPU fail-closed regression is missing")
transparent_regression = text["routing_tests"][transparent_start:transparent_end]
for marker in (
    "[51, 102, 153, 254]",
    "BeautyParameters(faceSlim: 0.4)",
    "XCTAssertEqual(error as? BeautyError, .invalidInput)",
    "XCTAssertEqual(executor.callCount, 0)",
):
    if marker not in transparent_regression:
        raise SystemExit(f"transparent GPU fail-closed assertion missing: {marker}")
p3_name = "func testOpaqueDisplayP3GPUStillImagePreservesRawCarrierAndMetadata() throws"
p3_start = text["routing_tests"].find(p3_name)
p3_end = text["routing_tests"].find("\n    func ", p3_start + len(p3_name))
if p3_start < 0 or p3_end < 0:
    raise SystemExit("opaque Display-P3 GPU regression is missing")
p3_regression = text["routing_tests"][p3_start:p3_end]
for marker in (
    "CGColorSpace.displayP3",
    "orientation: .left",
    "isInputMirrored: true",
    "XCTAssertEqual(executor.lastMetadata, metadata)",
    "XCTAssertEqual(executor.lastStillImageExtent, rawExtent)",
    "XCTAssertEqual(executor.lastStillImageColorSpaceName, CGColorSpace.displayP3)",
):
    if marker not in p3_regression:
        raise SystemExit(f"opaque Display-P3 GPU assertion missing: {marker}")
regression_name = "func testPublicRawRoutesPreserveNonUpAndMirroredMetadata() throws"
regression_start = text["routing_tests"].find(regression_name)
if regression_start < 0:
    raise SystemExit("raw metadata routing regression is missing")
regression_end = text["routing_tests"].find("\n    func ", regression_start + len(regression_name))
if regression_end < 0:
    regression_end = len(text["routing_tests"])
regression = text["routing_tests"][regression_start:regression_end]
for marker in (
    "orientation: .right",
    "isInputMirrored: true",
    "XCTAssertEqual(executor.lastMetadata, pixelBufferMetadata)",
    "XCTAssertEqual(executor.lastMetadata, stillImageMetadata)",
):
    if marker not in regression:
        raise SystemExit(f"raw metadata routing assertion missing: {marker}")
if re.search(r"\b(?:XCTSkip|UI(Image|Kit)|NS(Image|Application)|URLSession|FileManager)\b", text["configuration_tests"] + text["routing_tests"], re.IGNORECASE):
    raise SystemExit("configuration tests contain UI, path, or skip behavior")

if re.search(r"\.package\s*\(|https?://", text["package"]):
    raise SystemExit("package dependency drifted")
manifest = json.loads(text["manifest"])
if [item.get("id") for item in manifest.get("presets", [])] != [
    "natural", "clear", "refined", "male-natural", "id-photo-natural"
]:
    raise SystemExit("preset inventory changed")
if len(re.findall(r"^\s*RenderCase\(", text["renderer"], re.MULTILINE)) != 82:
    raise SystemExit("renderer case inventory changed")

for forbidden in ("UIKit", "SwiftUI", "AVCapture", "UIApplication", "NSApplication", "URLSession", "Network"):
    if re.search(r"\b" + re.escape(forbidden) + r"\b", implementation, re.IGNORECASE):
        raise SystemExit("UI, device, or network dependency entered backend routing")

print("backend_configuration_static_boundary_passed")
PY
}

validate_focused_log() {
  local log_path="$1"
  python3 - "${log_path}" "${expected_focused_tests}" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
expected = int(sys.argv[2])
executions = [(int(value), int(failures)) for value, failures in re.findall(
    r"Executed (\d+) tests?, with (\d+) failures?", text
)]
if not executions or executions[-1][0] != expected or max(value for value, _ in executions) != expected:
    raise SystemExit(1)
if any(failures != 0 for _, failures in executions):
    raise SystemExit(1)
for suite in ("BeautyConfigurationTests", "BeautyEngineBackendRoutingTests"):
    if suite not in text:
        raise SystemExit(1)
if re.search(r"\b(?:skipped|disabled|unexpected failure)\b", text, re.IGNORECASE):
    raise SystemExit(1)
PY
}

probe_availability() {
  local log_path="$1"
  if run_bounded "${log_path}" swift -e 'import Metal; print(MTLCreateSystemDefaultDevice() == nil ? "metal_unavailable" : "metal_available")'; then
    local value
    value="$(tr -d '[:space:]' <"${log_path}")"
    case "${value}" in
      metal_available|metal_unavailable)
        printf '%s' "${value}"
        return 0
        ;;
    esac
  fi
  printf '%s' "metal_unavailable"
}

self_test() {
  temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-backend-configuration-self-test.XXXXXX")"
  cp -R -- "${package_root}" "${temporary_root}/BeautySDK"
  validate_static_boundary "${temporary_root}"

  local mutation_path="${temporary_root}/BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
value = value.replace("decodeIfPresent(\n                BeautyRenderBackend.self,", "decodeIfPresent(\n                String.self,", 1)
path.write_text(value, encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_default_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautyCore/Models/BeautyConfiguration.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
value = value.replace("case .gpu:", "case .cpu:", 1)
path.write_text(value, encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_gpu_branch_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautySDK/BeautyBackendFactory.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
value = value.replace("policy: backendPolicy,", "", 1)
path.write_text(value, encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_policy_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautySDK/BeautyEngine.swift" "${mutation_path}"

  printf '\nlet fallback = true\n' >>"${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_fallback_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautySDK/BeautyEngine.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
start_marker = "    func testPublicRawRoutesPreserveNonUpAndMirroredMetadata() throws {"
end_marker = "\n    func testInjectedTerminalFailureEscapesWithoutFallback()"
start = value.index(start_marker)
end = value.index(end_marker, start)
path.write_text(value[:start] + value[end + 1:], encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_raw_metadata_test_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift" "${mutation_path}"

  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
value = value.replace("            orientation: .right,\n", "", 1)
path.write_text(value, encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_raw_orientation_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift" "${mutation_path}"

  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
value = value.replace("            isInputMirrored: true,\n", "", 1)
path.write_text(value, encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_raw_mirror_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift" "${mutation_path}"

  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
value = value.replace("        XCTAssertEqual(executor.lastMetadata, stillImageMetadata)\n", "", 1)
path.write_text(value, encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_raw_mirror_assertion_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift" \
    "${temporary_root}/BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
  cp -- "${package_root}/Sources/BeautyCore/Models/BeautyConfiguration.swift" "${mutation_path}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
needle = "Still-image input must be exact-opaque, finite,"
if needle not in value:
    raise SystemExit(1)
path.write_text(value.replace(needle, "Still-image input must be opaque, finite,", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_gpu_policy_doc_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautyCore/Models/BeautyConfiguration.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
  cp -- "${package_root}/Sources/BeautySDK/BeautyEngine.swift" "${mutation_path}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
needle = ".preflightOpaqueBoundedRGBForMetalStillImage("
if needle not in value:
    raise SystemExit(1)
path.write_text(value.replace(needle, ".removedMetalStillImagePreflight(", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_metal_preflight_order_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautySDK/BeautyEngine.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift"
  cp -- "${package_root}/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift" "${mutation_path}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
needle = "minimum[3] == 1,"
if needle not in value:
    raise SystemExit(1)
path.write_text(value.replace(needle, "minimum[3] >= 0,", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_exact_opacity_mutation_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift"
  cp -- "${package_root}/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift" "${mutation_path}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
value = path.read_text(encoding="utf-8")
needle = "        XCTAssertEqual(executor.callCount, 0)\n"
if needle not in value:
    raise SystemExit(1)
path.write_text(value.replace(needle, "", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_configuration_prebackend_rejection_mutation_failed" >&2
    return 1
  fi
  echo "backend_configuration_self_test_passed"
}

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  self_test
  exit $?
fi
[[ "$#" -eq 0 ]] || exit 2
for command_name in python3 swift; do
  command -v "${command_name}" >/dev/null || exit 1
done

validate_static_boundary "${repository_root}" >/dev/null || {
  echo "backend_configuration_static_boundary_failed"
  exit 1
}

temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-backend-configuration.XXXXXX")"
run_bounded "${temporary_root}/focused.log" \
  swift test --package-path "${package_root}" \
  --filter 'BeautyCoreTests.BeautyConfigurationTests|BeautyCoreTests.BeautyEngineBackendRoutingTests' || {
    echo "backend_configuration_focused_tests_failed"
    exit 1
  }
validate_focused_log "${temporary_root}/focused.log" || {
  echo "backend_configuration_focused_accounting_failed"
  exit 1
}

availability="$(probe_availability "${temporary_root}/availability.log")"
if [[ "${availability}" == "metal_available" ]]; then
  metal_available=1
  metal_unavailable=0
else
  metal_available=0
  metal_unavailable=1
fi
echo "backend_configuration_preflight_passed"
echo "focused_tests=${expected_focused_tests}"
echo "metal_available=${metal_available}"
echo "metal_unavailable=${metal_unavailable}"
