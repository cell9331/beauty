#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly package_root="${repository_root}/BeautySDK"
readonly maximum_output_bytes=$((16 * 1024 * 1024))
readonly focused_filter='BeautyEffectsTests.BeautyMetalColorPassTests|BeautyEffectsTests.BeautyMetalGeometryPassTests|BeautyEffectsTests.BeautyMetalBackendTests|BeautyEffectsTests.BeautyMetalLocalRetouchPassTests|BeautyRenderTests.BeautyMetalRuntimeTests'
readonly expected_focused_tests=32
readonly pass_source="BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift"
readonly runtime_source="BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift"
readonly shader_source="BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"
readonly backend_source="BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift"
readonly contract_source="BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift"
readonly color_test_source="BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift"
readonly runtime_test_source="BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift"
readonly backend_test_source="BeautySDK/Tests/BeautyEffectsTests/BeautyMetalBackendTests.swift"
readonly geometry_test_source="BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift"
readonly local_retouch_test_source="BeautySDK/Tests/BeautyEffectsTests/BeautyMetalLocalRetouchPassTests.swift"
readonly parameters_source="BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
readonly configuration_source="BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
readonly manifest_source="BeautySDK/Sources/BeautyResources/Resources/manifest.json"
readonly renderer_source="BeautySDK/Sources/BeautyExampleRenderer/main.swift"
readonly package_manifest="BeautySDK/Package.swift"

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
  python3 - "${root}" <<'PY'
from pathlib import Path
import json
import re
import sys

root = Path(sys.argv[1]).resolve()
if not root.is_dir() or root.is_symlink():
    raise SystemExit("feature-pass root is not a regular directory")

paths = {
    "pass": "BeautySDK/Sources/BeautyRender/BeautyMetalPass.swift",
    "runtime": "BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift",
    "shader": "BeautySDK/Sources/BeautyRender/Shaders/Warp.metal",
    "backend": "BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift",
    "contract": "BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift",
    "color_tests": "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalColorPassTests.swift",
    "runtime_tests": "BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift",
    "backend_tests": "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalBackendTests.swift",
    "geometry_tests": "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift",
    "local_retouch_tests": "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalLocalRetouchPassTests.swift",
    "parameters": "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "configuration": "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift",
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
implementation = text["pass"] + text["runtime"] + text["backend"]

def code(value):
    value = re.sub(r"/\*.*?\*/", "", value, flags=re.DOTALL)
    return "\n".join(line.split("//", 1)[0] for line in value.splitlines())

pass_code = code(text["pass"])
runtime_code = code(text["runtime"])
backend_code = code(text["backend"])
shader = text["shader"]

alternate = "fall" + "back"
retry = "ret" + "ry"
render_backend = "Beauty" + "Render" + "Backend"
render_field = "render" + "Backend"
forbidden_host = "|".join(re.escape(value) for value in (
    "UI" + "Kit", "Swift" + "UI", "AV" + "Capture", "UI" + "Application",
    "NS" + "Application", "Net" + "work", "URL" + "Session",
))
if re.search(r"\bpublic\s+(?:(?:final|indirect)\s+)?(?:class|struct|enum|protocol)\s+", implementation):
    raise SystemExit("feature-pass implementation leaked a public declaration")
if render_backend in "\n".join(text.values()) or render_field in text["parameters"] or render_field in text["configuration"]:
    raise SystemExit("public backend selector drifted into the feature-pass scope")
if re.search(r"\b(?:" + forbidden_host + r")\b", implementation, re.IGNORECASE):
    raise SystemExit("host, UI, capture, or network dependency entered feature passes")
if re.search(r"\b(?:" + re.escape(alternate) + r"|" + re.escape(retry) + r")\b", implementation, re.IGNORECASE):
    raise SystemExit("feature-pass implementation contains alternate execution")
if "BeautyCPUBackend" in backend_code or re.search(r"\.cpu\b", backend_code):
    raise SystemExit("Metal backend contains a CPU alternate path")

for marker in (
    "package enum BeautyMetalPass", "BeautyMetalColorParameters",
    "BeautyMetalGeometryParameters", "BeautyMetalComposedRetouchParameters",
    "maximumPointCount", "isFinite", "BeautyError.invalidInput",
):
    if marker not in pass_code:
        raise SystemExit(f"pass payload marker missing: {marker}")
for marker in (
    "dispatchThreads", "MTLTextureDescriptor", "storageMode = .private",
    "usage = [.shaderRead, .shaderWrite]", "defer", "tracked(",
    "createdResource()", "releasedResource()", "passes:",
):
    if marker not in runtime_code:
        raise SystemExit(f"runtime graph marker missing: {marker}")
if runtime_code.count("defer") < 13 or runtime_code.count("tracked(") < 8:
    raise SystemExit("request cleanup tracking is incomplete")
for kernel in ("beauty_warp_placeholder", "beauty_color_pass", "beauty_geometry_pass", "beauty_local_retouch_pass"):
    if f"kernel void {kernel}" not in shader:
        raise SystemExit(f"shader kernel missing: {kernel}")
if "clamp(rgb, 0.0f, 1.0f)" not in shader:
    raise SystemExit("shader output bound is missing")
if "CGColorSpace(name: CGColorSpace.sRGB)" not in backend_code:
    raise SystemExit("named sRGB materialization is missing")
if "bgraToRgba" not in backend_code or "rgbaToBgra" not in backend_code:
    raise SystemExit("pixel-buffer channel bridge is missing")
for marker in ("BeautyFaceGeometryAdapter.makeGeometry", "BeautyGeometryEffectPipeline.controlPoints", "maximumPointCount"):
    if marker not in backend_code:
        raise SystemExit(f"geometry adapter marker missing: {marker}")
for marker in ("constant BeautyMetalWarpPoint", "pointCount", "beauty_falloff_weight", "beauty_clamp_point", "input.read"):
    if marker not in shader:
        raise SystemExit(f"geometry shader marker missing: {marker}")

diagnostics = text["contract"].split("package struct BeautyBackendDiagnostics", 1)[1].split("package init", 1)[0]
privacy_terms = ["r" + "aw", "m" + "ask", "land" + "mark", "coordinate", "p" + "ath", "fixt" + "ure", "texture", "framework"]
privacy_pattern = r"\b(?:var|let)\s+\w*(?:" + "|".join(privacy_terms) + r")\w*"
if re.search(privacy_pattern, diagnostics, re.IGNORECASE):
    raise SystemExit("raw request data entered aggregate diagnostics")
for term in (
    "XCT" + "Skip", "UI" + "Image", "NS" + "Image", "URL" + "(",
    "File" + "Manager", "print" + "(", "debug" + "Print" + "(",
    "/" + "private/", "/" + "Users/",
):
    if term in text["color_tests"]:
        raise SystemExit(f"private/UI/test artifact entered color suite: {term}")
    if term in text["geometry_tests"]:
        raise SystemExit(f"private/UI/test artifact entered geometry suite: {term}")
    if term in text["local_retouch_tests"]:
        raise SystemExit(f"private/UI/test artifact entered local-retouch suite: {term}")

parameters = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", text["parameters"], re.MULTILINE)
configuration = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", text["configuration"], re.MULTILINE)
if len(parameters) != 61 or len(set(parameters)) != 61:
    raise SystemExit("BeautyParameters inventory changed")
if len(configuration) != 10 or len(set(configuration)) != 10:
    raise SystemExit("BeautyConfiguration inventory changed")
if re.search(r"\.package\s*\(|https?://", text["package"]):
    raise SystemExit("package dependency drifted")
manifest = json.loads(text["manifest"])
if [item.get("id") for item in manifest.get("presets", [])] != ["natural", "clear", "refined", "male-natural", "id-photo-natural"]:
    raise SystemExit("preset inventory changed")
if len(re.findall(r"^\s*RenderCase\(", text["renderer"], re.MULTILINE)) != 74:
    raise SystemExit("renderer case inventory changed")

metal_sources = sorted(
    candidate.relative_to(root).as_posix()
    for candidate in (root / "BeautySDK").rglob("*")
    if candidate.is_file() and not candidate.is_symlink() and candidate.suffix.lower() == ".metal" and ".build/" not in candidate.relative_to(root).as_posix()
)
if metal_sources != [paths["shader"]]:
    raise SystemExit("Metal shader inventory changed")
if "BeautyMetalColorPassTests" not in text["color_tests"]:
    raise SystemExit("generated color suite is missing")
if "testGeneratedCombinedSaturationAndSkinSmoothingMatchesCPU" not in text["color_tests"]:
    raise SystemExit("combined saturation and skin-smoothing regression is missing")
if "BeautyMetalGeometryPassTests" not in text["geometry_tests"]:
    raise SystemExit("generated geometry suite is missing")
if "BeautyMetalLocalRetouchPassTests" not in text["local_retouch_tests"]:
    raise SystemExit("generated local-retouch suite is missing")
for marker in (
    "compositionSummary", "hasCanonicalCarrier", "composedRetouch",
    "BeautyLocalRetouchCompositionOwner", "BeautyLocalRetouchCompositionSummary",
):
    if marker not in backend_code and marker not in text["local_retouch_tests"]:
        raise SystemExit(f"composition ownership marker missing: {marker}")
if "BeautyLocalRetouchCompositionOwner" not in text["local_retouch_tests"]:
    raise SystemExit("composition owner coverage is missing")
sys.stdout.write("metal_feature_passes_static_boundary_passed\n")
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
executions = [(int(value), int(failures)) for value, failures in re.findall(r"Executed (\d+) tests?, with (\d+) failures?", text)]
if not executions or executions[-1][0] != expected or max(value for value, _ in executions) != expected:
    raise SystemExit(1)
if any(failures != 0 for _, failures in executions):
    raise SystemExit(1)
for suite in ("BeautyMetalColorPassTests", "BeautyMetalGeometryPassTests", "BeautyMetalBackendTests", "BeautyMetalLocalRetouchPassTests", "BeautyMetalRuntimeTests"):
    if suite not in text: raise SystemExit(1)
if re.search(r"\b(?:skipped|disabled|unexpected failure)\b", text, re.IGNORECASE): raise SystemExit(1)
PY
}

self_test() {
  local mutation_path
  temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-metal-feature-self-test.XXXXXX")"
  cp -R -- "${package_root}" "${temporary_root}/BeautySDK"
  validate_static_boundary "${temporary_root}"

  mutation_path="${temporary_root}/${runtime_source}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
needle = "defer { counters.releasedResource() }"
if needle not in value: raise SystemExit(1)
path.write_text(value.replace(needle, "", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then echo "cleanup_mutation_failed" >&2; return 1; fi

  cp -- "${package_root}/Sources/BeautyRender/BeautyMetalRuntime.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${configuration_source}"
  printf '\npublic var render%s: String?\n' 'Backend' >>"${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then echo "public_schema_mutation_failed" >&2; return 1; fi

  cp -- "${package_root}/Sources/BeautyCore/Models/BeautyConfiguration.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${backend_source}"
  printf '\nlet alternate = "fall%s"\n' 'back' >>"${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then echo "alternate_mutation_failed" >&2; return 1; fi

  cp -- "${package_root}/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift" "${mutation_path}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
needle = "passes.append(.composedRetouch(try BeautyMetalComposedRetouchParameters()))"
if needle not in value: raise SystemExit(1)
path.write_text(value.replace(needle, "", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then echo "source_binding_mutation_failed" >&2; return 1; fi

  cp -- "${package_root}/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${contract_source}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1]); value = path.read_text(encoding="utf-8")
needle = "package let changedPixelCount: Int"
if needle not in value: raise SystemExit(1)
path.write_text(value.replace(needle, "package let " + "raw" + "Mask: Int", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then echo "diagnostic_mutation_failed" >&2; return 1; fi

  cp -- "${package_root}/Sources/BeautyEffects/Backend/BeautyBackendContract.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${pass_source}"
  mkdir -p "${temporary_root}/BeautySDK/Sources/BeautyEffects/Unexpected"
  cp -- "${mutation_path}" "${temporary_root}/BeautySDK/Sources/BeautyEffects/Unexpected/BeautyMetalPass.swift"
  rm -- "${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then echo "target_mutation_failed" >&2; return 1; fi
  echo "metal_feature_passes_self_test_passed"
}

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  self_test
  exit $?
fi
[[ "$#" -eq 0 ]] || exit 2
for command_name in python3 swift; do command -v "${command_name}" >/dev/null || exit 1; done
validate_static_boundary "${repository_root}" >/dev/null || { echo "metal_feature_passes_static_boundary_failed"; exit 1; }
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-metal-feature.XXXXXX")"
run_bounded "${temporary_root}/focused.log" swift test --package-path "${package_root}" --filter "${focused_filter}" || { echo "metal_feature_passes_focused_tests_failed"; exit 1; }
validate_focused_log "${temporary_root}/focused.log" || { echo "metal_feature_passes_focused_accounting_failed"; exit 1; }
availability="metal_unavailable"
if run_bounded "${temporary_root}/availability.log" swift -e 'import Metal; import Foundation; let value = MTLCreateSystemDefaultDevice() == nil ? "metal_unavailable" : "metal_available"; FileHandle.standardOutput.write(Data(value.utf8))'; then
  value="$(tr -d '[:space:]' <"${temporary_root}/availability.log")"
  [[ "${value}" == "metal_available" || "${value}" == "metal_unavailable" ]] && availability="${value}"
fi
if [[ "${availability}" == "metal_available" ]]; then metal_available=1; metal_unavailable=0; else metal_available=0; metal_unavailable=1; fi
echo "metal_feature_passes_preflight_passed"
echo "metal_available=${metal_available}"
echo "metal_unavailable=${metal_unavailable}"
echo "focused_tests=${expected_focused_tests}"
echo "failures=0"
echo "skips=0"
