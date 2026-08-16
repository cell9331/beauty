#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly package_root="${repository_root}/BeautySDK"
readonly maximum_output_bytes=$((16 * 1024 * 1024))
readonly focused_filter='BeautyRenderTests.BeautyMetalRuntimeTests|BeautyEffectsTests.BeautyMetalBackendTests|BeautyEffectsTests.BeautyBackendContractTests|BeautyEffectsTests.BeautyCPUBackendTests|BeautyCoreTests.BeautyEngineBackendRoutingTests'
readonly expected_focused_tests=26
readonly runtime_source="BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift"
readonly backend_source="BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift"
readonly contract_source="BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift"
readonly runtime_test_source="BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift"
readonly backend_test_source="BeautySDK/Tests/BeautyEffectsTests/BeautyMetalBackendTests.swift"
readonly cpu_source="BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift"
readonly engine_source="BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
readonly parameters_source="BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
readonly configuration_source="BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
readonly manifest_source="BeautySDK/Sources/BeautyResources/Resources/manifest.json"
readonly renderer_source="BeautySDK/Sources/BeautyExampleRenderer/main.swift"
readonly package_manifest="BeautySDK/Package.swift"
readonly authorized_shader="BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"

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
    raise SystemExit("metal runtime root is not a regular directory")

runtime_source = "BeautySDK/Sources/BeautyRender/BeautyMetalRuntime.swift"
backend_source = "BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift"
contract_source = "BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift"
runtime_test_source = "BeautySDK/Tests/BeautyRenderTests/BeautyMetalRuntimeTests.swift"
backend_test_source = "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalBackendTests.swift"
cpu_source = "BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift"
engine_source = "BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
parameters_source = "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
configuration_source = "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
manifest_source = "BeautySDK/Sources/BeautyResources/Resources/manifest.json"
renderer_source = "BeautySDK/Sources/BeautyExampleRenderer/main.swift"
package_manifest = "BeautySDK/Package.swift"
authorized_shader = "BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"

def regular(relative):
    path = root / relative
    resolved = path.resolve()
    if path.is_symlink() or not path.is_file() or resolved != path or root not in resolved.parents:
        raise SystemExit(f"missing or non-regular source: {relative}")
    return path

sources = {
    relative: regular(relative)
    for relative in (
        runtime_source, backend_source, contract_source, runtime_test_source,
        backend_test_source, cpu_source, engine_source, parameters_source,
        configuration_source, manifest_source, renderer_source, package_manifest,
    )
}
text = {relative: path.read_text(encoding="utf-8") for relative, path in sources.items()}
runtime = text[runtime_source]
backend = text[backend_source]
contract = text[contract_source]
tests = text[runtime_test_source] + "\n" + text[backend_test_source]

def without_comments(value):
    value = re.sub(r"/\*.*?\*/", "", value, flags=re.DOTALL)
    return "\n".join(line.split("//", 1)[0] for line in value.splitlines())

runtime_code = without_comments(runtime)
backend_code = without_comments(backend)
implementation = runtime_code + "\n" + backend_code

# Construct sensitive terms so this gate's own source remains a safe, fixed
# aggregate-only artifact and cannot be mistaken for an implementation leak.
alternate_word = "fall" + "back"
repeat_word = "ret" + "ry"
raw_word = "r" + "aw"
mask_word = "m" + "ask"
landmark_word = "land" + "mark"
path_word = "p" + "ath"
fixture_word = "fixt" + "ure"
render_backend_name = "Beauty" + "Render" + "Backend"
render_backend_field = "render" + "Backend"

if re.search(r"\bpublic\s+(?:(?:final|indirect)\s+)?(?:class|struct|enum|protocol)\s+", runtime_code + "\n" + backend_code):
    raise SystemExit("runtime/backend leaked a public declaration")
if render_backend_name in "\n".join(text.values()) or render_backend_field in text[parameters_source] or render_backend_field in text[configuration_source]:
    raise SystemExit("public backend selector drifted into the package")

host_imports = "|".join(re.escape(term) for term in (
    "UI" + "Kit", "Swift" + "UI", "AV" + "Capture", "UI" + "Application",
    "NS" + "Application", "App" + "Delegate", "Net" + "work",
))
runtime_imports = "|".join(re.escape(term) for term in (
    "URL" + "Session", "NW" + "Connection", "Process" + "Info",
))
facade_imports = "|".join(re.escape(term) for term in (
    "Beauty" + "SDK", "Beauty" + "ExampleRenderer",
))
for forbidden in (
    r"\b(?:" + host_imports + r")\b",
    r"\b(?:" + runtime_imports + r")\b",
    r"\b(?:" + facade_imports + r")\b",
):
    if re.search(forbidden, runtime_code + "\n" + backend_code, re.IGNORECASE):
        raise SystemExit("host, capture, network, or facade dependency entered the runtime")
if re.search(r"\b" + re.escape(alternate_word) + r"\b|\b" + re.escape(repeat_word) + r"\b", implementation, re.IGNORECASE):
    raise SystemExit("runtime/backend contains an alternate execution branch")
if "BeautyCPUBackend" in backend_code or re.search(r"\.cpu\b", backend_code):
    raise SystemExit("Metal executor contains a CPU execution path")

diagnostic_header = contract.split("package struct BeautyBackendDiagnostics", 1)[1].split("package init", 1)[0]
diagnostic_field = re.compile(
    r"\b(?:var|let)\s+\w*(?:" + "|".join(
        re.escape(term) for term in (
            raw_word,
            mask_word,
            landmark_word,
            "coordinate",
            path_word,
            fixture_word,
            "texture",
            "framework",
        )
    ) + r")\w*",
    re.IGNORECASE,
)
if diagnostic_field.search(diagnostic_header):
    raise SystemExit("private runtime data entered aggregate diagnostics")

required_runtime_markers = (
    "package final class BeautyMetalRuntime", "MTLCreateSystemDefaultDevice",
    "makeCommandQueue", "MTLTextureDescriptor", "storageMode = .private",
    "usage = [.shaderRead, .shaderWrite]", "dispatchThreads", "waitForCompletion",
    "commandStatusProvider", "maximumPixelCount", "alignedRowBytes",
    "width <= Int32.max", "height <= Int32.max", "defer", "tracked(",
    "createdResource()", "releasedResource()", "resourceCountersForTesting",
)
for marker in required_runtime_markers:
    if marker not in runtime:
        raise SystemExit(f"runtime marker missing: {marker}")
if runtime.count("defer { counters.releasedResource() }") < 3:
    raise SystemExit("request cleanup markers are incomplete")
if "commandBuffer.commit()" not in runtime or "commandBuffer.status" not in runtime:
    raise SystemExit("command synchronization markers are incomplete")

if "package final class BeautyMetalBackend" not in backend or "BeautyMetalRuntime" not in backend:
    raise SystemExit("package Metal executor ownership is missing")
if "package final class BeautyMetalRuntime" not in runtime:
    raise SystemExit("package Metal runtime ownership is missing")
if "BeautyMetalRuntimeTests" not in tests or "BeautyMetalBackendTests" not in tests:
    raise SystemExit("focused Metal test ownership is missing")
if tests.count("resourceCountersForTesting") < 4:
    raise SystemExit("cleanup behavior is not exercised by focused tests")

parameter_fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", text[parameters_source], re.MULTILINE)
if len(parameter_fields) != 61 or len(set(parameter_fields)) != 61:
    raise SystemExit("BeautyParameters inventory changed")
configuration_fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", text[configuration_source], re.MULTILINE)
if len(configuration_fields) != 10 or len(set(configuration_fields)) != 10:
    raise SystemExit("BeautyConfiguration inventory changed")
package_text = text[package_manifest]
if re.search(r"\.package\s*\(|https?://", package_text):
    raise SystemExit("package dependency drifted")
manifest = json.loads(text[manifest_source])
if [item.get("id") for item in manifest.get("presets", [])] != [
    "natural", "clear", "refined", "male-natural", "id-photo-natural"
]:
    raise SystemExit("preset inventory changed")
if len(re.findall(r"^\s*RenderCase\(", text[renderer_source], re.MULTILINE)) != 74:
    raise SystemExit("renderer case inventory changed")

metal_sources = []
for candidate in (root / "BeautySDK").rglob("*"):
    if candidate.is_file() and not candidate.is_symlink() and candidate.suffix.lower() == ".metal":
        relative = candidate.relative_to(root).as_posix()
        if ".build/" not in relative:
            metal_sources.append(relative)
if sorted(metal_sources) != [authorized_shader]:
    raise SystemExit("Metal shader/resource inventory changed")

for candidate in (root / "BeautySDK").rglob("BeautyMetalRuntime.swift"):
    if candidate.is_file() and candidate.relative_to(root).as_posix() != runtime_source:
        raise SystemExit("Metal runtime moved outside BeautyRender")
for candidate in (root / "BeautySDK").rglob("BeautyMetalBackend.swift"):
    if candidate.is_file() and candidate.relative_to(root).as_posix() != backend_source:
        raise SystemExit("Metal executor moved outside BeautyEffects")

print("metal_runtime_static_boundary_passed")
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
if not executions or max(value for value, _ in executions) != expected or executions[-1][0] != expected:
    raise SystemExit(1)
if any(failures != 0 for _, failures in executions):
    raise SystemExit(1)
for suite in (
    "BeautyMetalRuntimeTests", "BeautyMetalBackendTests", "BeautyBackendContractTests",
    "BeautyCPUBackendTests", "BeautyEngineBackendRoutingTests",
):
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
  local mutation_path
  temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-metal-runtime-self-test.XXXXXX")"
  cp -R -- "${package_root}" "${temporary_root}/BeautySDK"
  validate_static_boundary "${temporary_root}"

  mutation_path="${temporary_root}/${runtime_source}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
needle = "defer { counters.releasedResource() }"
if needle not in text:
    raise SystemExit(1)
path.write_text(text.replace(needle, "", 1), encoding="utf-8")
PY
if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "metal_runtime_cleanup_mutation_self_test_failed" >&2
    return 1
  fi

  cp -- "${package_root}/Sources/BeautyRender/BeautyMetalRuntime.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${configuration_source}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text += "\npublic var " + "render" + "Backend: String?\n"
path.write_text(text, encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "metal_runtime_public_schema_mutation_self_test_failed" >&2
    return 1
  fi

  cp -- "${package_root}/Sources/BeautyCore/Models/BeautyConfiguration.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${backend_source}"
  printf '\nlet alternate = "fall%s"\n' 'back' >>"${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "metal_runtime_alternate_path_mutation_self_test_failed" >&2
    return 1
  fi

  cp -- "${package_root}/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${contract_source}"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
if "package let changedPixelCount: Int" not in text:
    raise SystemExit(1)
path.write_text(text.replace("package let changedPixelCount: Int", "package let raw" + "Mask: Int", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "metal_runtime_diagnostic_mutation_self_test_failed" >&2
    return 1
  fi

  cp -- "${package_root}/Sources/BeautyEffects/Backend/BeautyBackendContract.swift" "${mutation_path}"
  mutation_path="${temporary_root}/${runtime_source}"
  mkdir -p "${temporary_root}/BeautySDK/Sources/BeautyEffects/Unexpected"
  cp -- "${mutation_path}" "${temporary_root}/BeautySDK/Sources/BeautyEffects/Unexpected/BeautyMetalRuntime.swift"
  rm -- "${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "metal_runtime_target_mutation_self_test_failed" >&2
    return 1
  fi
  echo "metal_runtime_self_test_passed"
}

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  self_test
  exit $?
fi
[[ "$#" -eq 0 ]] || exit 2

for command_name in python3 swift; do
  command -v "${command_name}" >/dev/null || {
    echo "metal_runtime_preflight_failed"
    exit 1
  }
done

validate_static_boundary "${repository_root}" >/dev/null || {
  echo "metal_runtime_static_boundary_failed"
  exit 1
}

temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-metal-runtime.XXXXXX")"
availability="$(probe_availability "${temporary_root}/availability.log")"
run_bounded "${temporary_root}/focused.log" \
  swift test --package-path "${package_root}" --filter "${focused_filter}" || {
  echo "metal_runtime_focused_tests_failed"
  exit 1
}
validate_focused_log "${temporary_root}/focused.log" || {
  echo "metal_runtime_focused_accounting_failed"
  exit 1
}

if [[ "${availability}" == "metal_available" ]]; then
  metal_available=1
  metal_unavailable=0
else
  metal_available=0
  metal_unavailable=1
fi
echo "metal_runtime_preflight_passed"
echo "metal_available=${metal_available}"
echo "metal_unavailable=${metal_unavailable}"
echo "focused_tests=${expected_focused_tests}"
echo "failures=0"
echo "skips=0"
