#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly package_root="${repository_root}/BeautySDK"
readonly maximum_output_bytes=$((16 * 1024 * 1024))
readonly focused_filter='BeautyEffectsTests.BeautyBackendParityTests|BeautyEffectsTests.BeautyBackendSafetyParityTests|BeautyEffectsTests.BeautyBackendDeterminismParityTests|BeautyCoreTests.BeautyBackendSelectionConcurrencyTests'
readonly unavailable_filter='BeautyCoreTests.BeautyBackendSelectionConcurrencyTests'
readonly expected_focused_tests=13
readonly expected_unavailable_tests=2
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
    "local_foundation": "BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift",
    "engine": "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
    "metal_pass": "BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift",
    "metal_backend": "BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift",
    "shader": "BeautySDK/Sources/BeautyRender/Shaders/Warp.metal",
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

def swift_declaration_tokens(source):
    """Return declaration-significant Swift tokens, excluding comments and strings."""
    tokens = []
    index = 0
    while index < len(source):
        if source[index].isspace():
            index += 1
            continue
        if source.startswith("//", index):
            newline = source.find("\n", index + 2)
            index = len(source) if newline < 0 else newline + 1
            continue
        if source.startswith("/*", index):
            index += 2
            depth = 1
            while index < len(source) and depth:
                if source.startswith("/*", index):
                    depth += 1
                    index += 2
                elif source.startswith("*/", index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
            if depth:
                raise SystemExit("unterminated Swift block comment")
            continue
        raw_hashes = 0
        while index + raw_hashes < len(source) and source[index + raw_hashes] == "#":
            raw_hashes += 1
        quote = index + raw_hashes
        if quote < len(source) and source[quote] == '"':
            multiline = source.startswith('"""', quote) and quote + 3 < len(source) and source[quote + 3] in "\r\n"
            opening_length = 3 if multiline else 1
            closing = ('"""' if multiline else '"') + ("#" * raw_hashes)
            cursor = quote + opening_length
            while cursor < len(source):
                if source[cursor] == "\\":
                    if raw_hashes == 0:
                        cursor += 2
                        continue
                    escaped = cursor + 1 + raw_hashes
                    if source[cursor + 1:escaped] == ("#" * raw_hashes) and escaped < len(source) and source[escaped] in {'"', "\\", "("}:
                        cursor = escaped + 1
                        continue
                if source.startswith(closing, cursor):
                    index = cursor + len(closing)
                    break
                cursor += 1
            else:
                raise SystemExit("unterminated Swift string literal")
            continue
        if source[index].isalpha() or source[index] == "_":
            end = index + 1
            while end < len(source) and (source[end].isalnum() or source[end] == "_"):
                end += 1
            tokens.append(source[index:end])
            index = end
            continue
        if source[index] in "@<>{}:,()[]?!.=":
            tokens.append(source[index])
        index += 1
    return tokens

def has_named_sendable_conformance(source, type_name):
    tokens = swift_declaration_tokens(source)
    for index, token in enumerate(tokens):
        if token != type_name or index == 0 or tokens[index - 1] not in {"class", "extension"}:
            continue
        end = index + 1
        while end < len(tokens) and tokens[end] != "{":
            end += 1
        header = tokens[index + 1:end]
        if ":" in header:
            inheritance = header[header.index(":") + 1:]
            if "where" in inheritance:
                inheritance = inheritance[:inheritance.index("where")]
            if "Sendable" in inheritance:
                return True
    return False

engine_contract = """/// A stateful, intentionally non-`Sendable` processing engine.
///
/// Callers must serialize all `process`, `processResult`, and `reset` access to the same instance.
/// Independent `BeautyEngine` instances may execute concurrently.
public final class BeautyEngine"""
if text["engine"].count(engine_contract) != 1:
    raise SystemExit("exact BeautyEngine class-level caller-serialization contract missing")
source_root = root / "BeautySDK/Sources"
for candidate in source_root.rglob("*.swift"):
    if candidate.is_symlink() or not candidate.is_file() or root not in candidate.resolve().parents:
        raise SystemExit(f"non-regular Swift source in parity boundary: {candidate.relative_to(root)}")
    if has_named_sendable_conformance(candidate.read_text(encoding="utf-8"), "BeautyEngine"):
        raise SystemExit(f"BeautyEngine Sendable conformance remains: {candidate.relative_to(root)}")

selection_case_name = "func testBoundedIndependentEngineInstancesMayExecuteConcurrently() async throws"
selection_case_start = text["selection"].find(selection_case_name)
selection_case_end = text["selection"].find("\n    func ", selection_case_start + len(selection_case_name))
if selection_case_start < 0:
    raise SystemExit("bounded independent-engine concurrency case missing")
if selection_case_end < 0:
    selection_case_end = len(text["selection"])
selection_case = text["selection"][selection_case_start:selection_case_end]
for marker in ("withThrowingTaskGroup", "for index in 0..<6", "let engine = try BeautyEngine", "recorder.callCount"):
    if selection_case.count(marker) != 1:
        raise SystemExit(f"bounded independent-engine concurrency evidence missing: {marker}")
if text["selection"].count("withThrowingTaskGroup") != 1:
    raise SystemExit("unexpected additional BeautyEngine concurrency evidence")

serialized_case_name = "func testConcurrentCallersUseSerializingHarnessBeforeAccessingOneEngine() async throws"
serialized_case_start = text["local_foundation"].find(serialized_case_name)
serialized_case_end = text["local_foundation"].find("\n    func ", serialized_case_start + len(serialized_case_name))
if serialized_case_start < 0 or serialized_case_end < 0:
    raise SystemExit("caller-side serialized shared-engine case missing")
serialized_case = text["local_foundation"][serialized_case_start:serialized_case_end]
for marker in ("caller-side serialization boundary", "withThrowingTaskGroup", "harness.invoke"):
    if marker not in serialized_case:
        raise SystemExit(f"caller-side serialization evidence missing: {marker}")
if "let engine" in serialized_case:
    raise SystemExit("serialized caller-wrapper case directly accesses BeautyEngine")

nonclaim_case_name = "func testConcurrencyContractRequiresCallerSerializationForOneEngineInstance()"
nonclaim_case_start = text["local_foundation"].find(nonclaim_case_name)
nonclaim_case_end = text["local_foundation"].find("\n    func ", nonclaim_case_start + len(nonclaim_case_name))
if nonclaim_case_start < 0 or nonclaim_case_end < 0:
    raise SystemExit("same-engine concurrency nonclaim case missing")
nonclaim_case = text["local_foundation"][nonclaim_case_start:nonclaim_case_end]
if 'XCTAssertFalse(flags.contains("same-engine-parallel-safe"))' not in nonclaim_case:
    raise SystemExit("same-engine parallel-safety claim is not rejected")

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
geometry_case_start = text["safety"].find(
    "func testGeometryContainmentPreservesOutsideProtectedAndAlphaBytes() throws"
)
geometry_case_end = text["safety"].find("\n    func ", geometry_case_start + 1)
if geometry_case_start < 0 or geometry_case_end < 0:
    raise SystemExit("geometry safety provenance case missing")
geometry_case = text["safety"][geometry_case_start:geometry_case_end]
for marker in (
    "let sharedFaceObservation = BeautyFaceObservation(",
    "BeautyFaceGeometryAdapter.makeGeometry(from: sharedFaceObservation)",
    "selectedFaceSupport: sharedFaceObservation",
    "XCTAssertEqual(request.selectedFaceSupport, sharedFaceObservation)",
):
    if geometry_case.count(marker) != 1:
        raise SystemExit(f"geometry safety observation provenance missing: {marker}")
for marker in ("withThrowingTaskGroup", "request-local", "metalUnavailable", "callCount", "resourceCountersForTesting"):
    if marker.lower() not in tests_lower:
        raise SystemExit(f"determinism/availability marker missing: {marker}")
if "metal_available" not in text["selection"] + text["determinism"] or "metal_unavailable" not in text["selection"] + text["determinism"]:
    raise SystemExit("separate Metal availability markers missing")
if "BeautyBackendExecutionPolicy" not in text["selection"]:
    raise SystemExit("request policy marker missing")
if not re.search(r"activeMaxChannelDelta\s*=\s*8(?!\d)", text["fixture"]) or not re.search(r"activeMeanRGBDelta\s*=\s*5\.0(?!\d)", text["fixture"]):
    raise SystemExit("pinned tolerance weakened or removed")
if not re.search(r"stillImageMaxChannelDelta\s*=\s*2(?!\d)", text["fixture"]) or not re.search(r"stillImageMeanRGBDelta\s*=\s*0\.75(?!\d)", text["fixture"]):
    raise SystemExit("tight still-image tolerance weakened or removed")
still_case_name = "func testGeneratedOpaqueSRGBStillImageColorAndLipRowsMatchCPUWithinTightTolerance() throws"
still_case_start = text["parity"].find(still_case_name)
still_case_end = text["parity"].find("\n    func ", still_case_start + len(still_case_name))
if still_case_start < 0 or still_case_end < 0:
    raise SystemExit("still-image CPU/Metal parity case missing")
still_case = text["parity"][still_case_start:still_case_end]
for marker in (
    "stillImageColorPlanMatrix()", "inputKind: .stillImage",
    "gpuImage.colorSpace?.name, CGColorSpace.sRGB",
    "stillImageMaxChannelDelta", "stillImageMeanRGBDelta",
):
    if marker not in still_case:
        raise SystemExit(f"still-image parity marker missing: {marker}")
for marker in (
    '"still-global-coefficients"', '"still-highlight-shadow-selective"',
    '"still-lip-hard-rectangle"',
):
    if marker not in text["fixture"]:
        raise SystemExit(f"still-image parity row missing: {marker}")
for marker in (
    "package enum BeautyMetalColorInputKind", "case stillImage = 1", "inputKind.rawValue",
):
    if marker not in text["metal_pass"]:
        raise SystemExit(f"Metal color input-kind marker missing: {marker}")
for marker in (
    "inputKind: .pixelBuffer", "inputKind: .stillImage", "isStillImage ? 0.20 : 0.22",
    "isStillImage ? 0.14 : 0.16", "isStillImage ? 0.16 : 0.18",
    "highlightLift: strengths.highlight * 0.08",
    "shadowLift: strengths.shadow * 0.08",
    "smoothing: isStillImage ? 0",
):
    if marker not in text["metal_backend"]:
        raise SystemExit(f"still-image Metal adapter marker missing: {marker}")
for marker in (
    "parameters.inputKind == 1", "float3(0.2126, 0.7152, 0.0722)",
    "parameters.lipCenterY * dimensions.y", "cropCoverage = overlap.x * overlap.y",
    "rgb.r + min(parameters.lipStrength, 0.5f) * 0.18f",
):
    if marker not in text["shader"]:
        raise SystemExit(f"still-image Metal kernel marker missing: {marker}")
if "metal_available" not in text["fixture"] + text["selection"]:
    # Keep the accounting vocabulary in the source contract, even though the
    # live script is the aggregate emitter.
    raise SystemExit("available classification marker missing")
if "metal_unavailable" not in text["fixture"] + text["selection"]:
    raise SystemExit("unavailable classification marker missing")
required_execution = re.compile(
    r"catch\s+BeautyError\.metalUnavailable\s*\{\s*"
    r"if\s+requiresMetalExecution\s*\{\s*"
    r"XCTFail\(\"Metal parity execution was required after the availability probe\"\)",
    re.DOTALL,
)
if "BEAUTYSDK_REQUIRE_METAL_PARITY_EXECUTION" not in text["fixture"] or not required_execution.search(text["fixture"]):
    raise SystemExit("required Metal execution failure sentinel missing")

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
if len(parameters) != 62 or len(set(parameters)) != 62:
    raise SystemExit("BeautyParameters inventory changed")
if "BeautyRenderBackend" in text["parameters"]:
    raise SystemExit("backend selector leaked into parameters")
if "\.package(" in text["package"] or re.search(r"https?://", text["package"]):
    raise SystemExit("package dependency drifted")
if len(re.findall(r"^\s*RenderCase\(", text["renderer"], re.MULTILINE)) != 75:
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
required_metal_cases = (
    "BeautyBackendDeterminismParityTests testBoundedConcurrentCPUAndMetalRequestsRemainRequestLocal",
    "BeautyBackendDeterminismParityTests testRepeatedGeneratedRequestsAreByteIdenticalAndResourceClean",
    "BeautyBackendParityTests testGeneratedActivePixelBufferMatrixMatchesCPUWithinPinnedTolerance",
    "BeautyBackendParityTests testGeneratedNeutralPixelBufferIsStructurallyAndByteIdentical",
    "BeautyBackendParityTests testGeneratedNoFacePlanIsExactNeutralBytes",
    "BeautyBackendParityTests testGeneratedOpaqueSRGBStillImageColorAndLipRowsMatchCPUWithinTightTolerance",
    "BeautyBackendParityTests testGeneratedStillImagePreservesTranslatedExtentAndMetadata",
    "BeautyBackendSafetyParityTests testCompositionCollisionAndRejectedUnitRemainAggregateAndSourceBound",
    "BeautyBackendSafetyParityTests testGeometryContainmentPreservesOutsideProtectedAndAlphaBytes",
    "BeautyBackendSafetyParityTests testNoFaceMalformedAndRejectedLocalUnitsDoNotEraseColorSibling",
    "BeautyBackendSafetyParityTests testTranslatedStillImagePreservesContainmentExtentAndFiniteBoundedDeltas",
)
for case in required_metal_cases:
    pattern = rf"Test Case '-\[[^.]+\.{re.escape(case)}\]' passed"
    if not re.search(pattern, text):
        raise SystemExit(f"Metal execution evidence missing: {case}")
if re.search(r"\b(?:skipped|disabled|unexpected failure)\b", text, re.IGNORECASE):
    raise SystemExit("focused skip or unexpected failure")
PY
}

validate_unavailable_log() {
  local log_path="$1"
  python3 - "$log_path" "$expected_unavailable_tests" <<'PY'
from pathlib import Path
import re
import sys
text = Path(sys.argv[1]).read_text(encoding="utf-8")
expected = int(sys.argv[2])
executions = [(int(value), int(failures)) for value, failures in re.findall(r"Executed (\d+) tests?, with (\d+) failures?", text)]
if not executions or executions[-1][0] != expected or max(value for value, _ in executions) != expected:
    raise SystemExit("unavailable count mismatch")
if any(failures != 0 for _, failures in executions):
    raise SystemExit("unavailable coverage failure")
required_cases = (
    "testFactorySeparatesAvailableAndUnavailableMetal",
    "testBoundedIndependentEngineInstancesMayExecuteConcurrently",
)
for case in required_cases:
    pattern = rf"Test Case '-\[BeautyCoreTests\.BeautyBackendSelectionConcurrencyTests {case}\]' passed"
    if not re.search(pattern, text):
        raise SystemExit(f"typed unavailable evidence missing: {case}")
for forbidden_suite in (
    "BeautyBackendParityTests",
    "BeautyBackendSafetyParityTests",
    "BeautyBackendDeterminismParityTests",
):
    if re.search(rf"Test (?:Suite|Case) '[^']*{re.escape(forbidden_suite)}", text):
        raise SystemExit(f"GPU parity suite ran while Metal was unavailable: {forbidden_suite}")
if re.search(r"\b(?:skipped|disabled|unexpected failure)\b", text, re.IGNORECASE):
    raise SystemExit("unavailable coverage skip or unexpected failure")
PY
}

validate_result_record() {
  local record_path="$1"
  python3 - "$record_path" "$expected_focused_tests" "$expected_unavailable_tests" <<'PY'
from pathlib import Path
import sys

lines = [line.strip() for line in Path(sys.argv[1]).read_text(encoding="utf-8").splitlines() if line.strip()]
available = f"backend_parity_preflight_passed metal_available=1 metal_unavailable=0 parity_executed=1 focused_tests={sys.argv[2]} unavailable_tests=0"
unavailable = f"backend_parity_unavailable_verified metal_available=0 metal_unavailable=1 parity_executed=0 focused_tests=0 unavailable_tests={sys.argv[3]}"
if len(lines) != 1 or lines[0] not in (available, unavailable):
    raise SystemExit("invalid or mixed backend parity result record")
print(lines[0])
PY
}

probe_availability() {
  local log_path="$1"
  if run_bounded "$log_path" swift -e 'import Metal; print(MTLCreateSystemDefaultDevice() == nil ? "metal_unavailable" : "metal_available")'; then
    local value
    value="$(tr -d '[:space:]' <"$log_path")"
    [[ "$value" == "metal_available" || "$value" == "metal_unavailable" ]] && { printf '%s' "$value"; return; }
  fi
  return 1
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
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("stillImageMaxChannelDelta = 2", "stillImageMaxChannelDelta = 20", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "still_image_tolerance_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("isStillImage ? 0.14 : 0.16", "isStillImage ? 0.16 : 0.16", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "still_image_coefficient_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("cropCoverage = overlap.x * overlap.y", "cropCoverage = 1.0f", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "still_image_lip_crop_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Sources/BeautyRender/Shaders/Warp.metal" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("changed.isSubset(of: envelope)", "true", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "safety_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift" "$mutation_path"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace(
    "selectedFaceSupport: sharedFaceObservation",
    "selectedFaceSupport: BeautyFaceObservation()",
    1,
), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "observation_handoff_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift" "$mutation_path"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace(
    "XCTAssertEqual(request.selectedFaceSupport, sharedFaceObservation)",
    "XCTAssertNotNil(request.selectedFaceSupport)",
    1,
), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "observation_proof_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendSafetyParityTests.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace(
    "Callers must serialize all `process`, `processResult`, and `reset` access to the same instance.",
    "Callers may overlap access to the same instance.",
    1,
), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "engine_serialization_contract_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Sources/BeautySDK/BeautyEngine.swift" "$mutation_path"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("public final class BeautyEngine {", "public final class BeautyEngine: @unchecked Sendable {", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "engine_sendable_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Sources/BeautySDK/BeautyEngine.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Sources/BeautySDK/BeautyEngine+Sendable.swift"
  printf 'extension BeautyEngine: Sendable {}\n' >"$mutation_path"
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "engine_extension_sendable_mutation_failed" >&2; return 1; fi
  rm -- "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Sources/BeautySDK/BeautyEngineTrivia.swift"
  printf '%s\n' \
    '// extension BeautyEngine: Sendable {}' \
    'let fakeEngineConformance = "extension BeautyEngine: @unchecked Sendable {}"' \
    >"$mutation_path"
  validate_static_boundary "$temporary_root" >/dev/null || { echo "engine_sendable_trivia_false_positive" >&2; return 1; }
  rm -- "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Tests/BeautyCoreTests/BeautyBackendSelectionConcurrencyTests.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace(
    "testBoundedIndependentEngineInstancesMayExecuteConcurrently",
    "testSharedEngineMayExecuteConcurrently",
    1,
), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "independent_engine_evidence_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyCoreTests/BeautyBackendSelectionConcurrencyTests.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace(
    'XCTAssertFalse(flags.contains("same-engine-parallel-safe"))',
    'XCTAssertTrue(flags.contains("same-engine-parallel-safe"))',
    1,
), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "same_engine_parallel_claim_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift" "$mutation_path"
  mutation_path="$temporary_root/BeautySDK/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift"
  python3 - "$mutation_path" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
path.write_text(value.replace("if requiresMetalExecution {", "if false {", 1), encoding="utf-8")
PY
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "required_execution_mutation_failed" >&2; return 1; fi
  cp -- "$package_root/Tests/BeautyEffectsTests/BeautyBackendParityFixtureFactory.swift" "$mutation_path"
  printf '\nlet rawOutput = FileManager.default\n' >>"$mutation_path"
  if validate_static_boundary "$temporary_root" >/dev/null 2>&1; then echo "raw_output_mutation_failed" >&2; return 1; fi
  local record_path="$temporary_root/result.record"
  printf '%s\n' "backend_parity_preflight_passed metal_available=1 metal_unavailable=0 parity_executed=1 focused_tests=${expected_focused_tests} unavailable_tests=0" >"$record_path"
  validate_result_record "$record_path" >/dev/null
  printf '%s\n' "backend_parity_unavailable_verified metal_available=0 metal_unavailable=1 parity_executed=0 focused_tests=0 unavailable_tests=${expected_unavailable_tests}" >"$record_path"
  validate_result_record "$record_path" >/dev/null
  printf '%s\n' "backend_parity_preflight_passed metal_available=0 metal_unavailable=1 parity_executed=0 focused_tests=${expected_focused_tests} unavailable_tests=0" >"$record_path"
  if validate_result_record "$record_path" >/dev/null 2>&1; then echo "unavailable_as_parity_mutation_failed" >&2; return 1; fi
  printf '%s\n%s\n' \
    "backend_parity_preflight_passed metal_available=1 metal_unavailable=0 parity_executed=1 focused_tests=${expected_focused_tests} unavailable_tests=0" \
    "backend_parity_unavailable_verified metal_available=0 metal_unavailable=1 parity_executed=0 focused_tests=0 unavailable_tests=${expected_unavailable_tests}" >"$record_path"
  if validate_result_record "$record_path" >/dev/null 2>&1; then echo "mixed_result_record_mutation_failed" >&2; return 1; fi
  run_bounded "$temporary_root/unavailable.log" swift test --package-path "$package_root" --filter "$unavailable_filter" || { echo "unavailable_coverage_self_test_failed" >&2; return 1; }
  validate_unavailable_log "$temporary_root/unavailable.log" || { echo "unavailable_accounting_self_test_failed" >&2; return 1; }
  echo "backend_parity_self_test_passed"
}

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  self_test
  exit $?
fi
if [[ "${1:-}" == "--validate-record" ]]; then
  [[ "$#" -eq 2 ]] || exit 2
  validate_result_record "$2"
  exit $?
fi
[[ "$#" -eq 0 ]] || exit 2
for command_name in python3 swift; do command -v "$command_name" >/dev/null || exit 1; done
validate_static_boundary "$repository_root" >/dev/null || { echo "backend_parity_static_boundary_failed"; exit 1; }
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-backend-parity.XXXXXX")"
availability="$(probe_availability "$temporary_root/availability.log")" || { echo "backend_parity_availability_probe_failed"; exit 1; }
if [[ "$availability" == "metal_available" ]]; then
  run_bounded "$temporary_root/focused.log" env BEAUTYSDK_REQUIRE_METAL_PARITY_EXECUTION=1 swift test --package-path "$package_root" --filter "$focused_filter" || { echo "backend_parity_focused_tests_failed"; exit 1; }
  validate_focused_log "$temporary_root/focused.log" || { echo "backend_parity_focused_accounting_failed"; exit 1; }
  echo "backend_parity_preflight_passed metal_available=1 metal_unavailable=0 parity_executed=1 focused_tests=${expected_focused_tests} unavailable_tests=0"
else
  run_bounded "$temporary_root/unavailable.log" swift test --package-path "$package_root" --filter "$unavailable_filter" || { echo "backend_parity_unavailable_tests_failed"; exit 1; }
  validate_unavailable_log "$temporary_root/unavailable.log" || { echo "backend_parity_unavailable_accounting_failed"; exit 1; }
  echo "backend_parity_unavailable_verified metal_available=0 metal_unavailable=1 parity_executed=0 focused_tests=0 unavailable_tests=${expected_unavailable_tests}"
fi
