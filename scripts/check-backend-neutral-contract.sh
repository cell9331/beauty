#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly package_root="${repository_root}/BeautySDK"
readonly maximum_output_bytes=$((16 * 1024 * 1024))
readonly backend_sources=(
  "BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift"
  "BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift"
  "BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
)
readonly schema_sources=(
  "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
  "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
  "BeautySDK/Sources/BeautyResources/Resources/manifest.json"
  "BeautySDK/Sources/BeautyExampleRenderer/main.swift"
  "BeautySDK/Package.swift"
)

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
    raise SystemExit("backend-neutral root is not a regular directory")

backend_sources = (
    "BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift",
    "BeautySDK/Sources/BeautyEffects/Backend/BeautyCPUBackend.swift",
    "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
)
schema_sources = (
    "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift",
    "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
    "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
    "BeautySDK/Package.swift",
)

def regular(relative):
    path = root / relative
    resolved = path.resolve()
    if path.is_symlink() or not path.is_file() or resolved != path or root not in resolved.parents:
        raise SystemExit(f"missing or non-regular source: {relative}")
    return path

backend_text = {relative: regular(relative).read_text(encoding="utf-8") for relative in backend_sources}
schema_text = {relative: regular(relative).read_text(encoding="utf-8") for relative in schema_sources}
engine = backend_text[backend_sources[2]]
cpu = backend_text[backend_sources[1]]
contract = backend_text[backend_sources[0]]
parameters = schema_text[schema_sources[0]]
configuration = schema_text[schema_sources[1]]
package = schema_text[schema_sources[4]]

if "BeautyColorEffectPipeline.apply" in engine:
    raise SystemExit("facade directly dispatches a retained pipeline")
if len(re.findall(r"BeautyBackendRequest", engine)) < 3 or len(re.findall(r"backendExecutor\.execute", engine)) != 3:
    raise SystemExit("facade does not dispatch both input families through one executor")
if "BeautyCPUBackend" not in cpu or "BeautyBackendExecutor" not in cpu:
    raise SystemExit("CPU executor declaration is missing")
if not re.search(r"package protocol\s+BeautyBackendExecutor", contract):
    raise SystemExit("backend executor protocol is not package-only")
if re.search(r"\b(public|open)\s+(?:enum|struct|class|protocol)\s+\w*Backend", "\n".join(backend_text.values())):
    raise SystemExit("public backend declaration drifted into Phase 70")

def without_comments(text):
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return "\n".join(line.split("//", 1)[0] for line in text.splitlines())

executable_backend = without_comments("\n".join((engine, cpu)))
for forbidden in (
    r"\b(?:fallback|retry|alternateBackend|backendFallback)\b",
    r"\b(?:MTL\w*|GPU\w*)\b",
    r"\b(?:Metal|MetalKit|UIKit|SwiftUI|URLSession|Network)\b",
    r"\b(?:AppDelegate|UIApplication|NSApplication|Demo[A-Za-z0-9_]*)\b",
):
    if re.search(forbidden, executable_backend, re.IGNORECASE):
        raise SystemExit(f"out-of-scope backend token: {forbidden}")
diagnostic_header = contract.split("package struct BeautyBackendDiagnostics", 1)[1].split(
    "package init", 1
)[0]
if re.search(r"\b(?:public\s+)?(?:var|let)\s+\w*(?:raw|mask|landmark|coordinate|path|fixture)\w*", diagnostic_header, re.IGNORECASE):
    raise SystemExit("raw/private diagnostic field drifted into the contract")
if "BeautyBackendDiagnostics" not in contract:
    raise SystemExit("bounded diagnostics are missing")

parameter_fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", parameters, re.MULTILINE)
if len(parameter_fields) != 61 or len(set(parameter_fields)) != 61:
    raise SystemExit("BeautyParameters inventory is not exactly 61 fields")
if "renderBackend" in parameters or "renderBackend" in configuration or "BeautyRenderBackend" in configuration:
    raise SystemExit("public backend configuration drifted into Phase 70")
configuration_fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", configuration, re.MULTILINE)
if len(configuration_fields) != 10 or len(set(configuration_fields)) != 10:
    raise SystemExit("BeautyConfiguration inventory changed")
if ".package(" in package or "http://" in package or "https://" in package:
    raise SystemExit("package dependency drifted into Phase 70")

manifest = json.loads(schema_text[schema_sources[2]])
if [item.get("id") for item in manifest.get("presets", [])] != [
    "natural", "clear", "refined", "male-natural", "id-photo-natural"
]:
    raise SystemExit("preset inventory changed")
if len(re.findall(r"^\s*RenderCase\(", schema_text[schema_sources[3]], re.MULTILINE)) != 74:
    raise SystemExit("renderer case inventory changed")

print("backend_neutral_static_boundary_passed")
PY
}

run_focused_suite() {
  local log_path="$1"
  local status=0
  run_bounded "${log_path}" \
    swift test --package-path "${package_root}" \
      --filter 'BeautyEffectsTests.BeautyBackendContractTests|BeautyEffectsTests.BeautyCPUBackendTests|BeautyCoreTests.BeautyEngineBackendRoutingTests' || status=$?
  [[ "${status}" -eq 0 ]] || return 1
  python3 - "${log_path}" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text(encoding="utf-8")
executions = [int(value) for value in re.findall(r"Executed (\d+) tests?, with 0 failures", text)]
if not executions or executions[-1] != 11 or max(executions) != 11:
    raise SystemExit(1)
for suite in ("BeautyBackendContractTests", "BeautyCPUBackendTests", "BeautyEngineBackendRoutingTests"):
    if suite not in text:
        raise SystemExit(1)
if re.search(r"(?:failed|skipped|disabled|unexpected failure)", text, re.IGNORECASE):
    raise SystemExit(1)
PY
}

self_test() {
  temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-backend-neutral-self-test.XXXXXX")"
  cp -R -- "${package_root}" "${temporary_root}/BeautySDK"
  validate_static_boundary "${temporary_root}"

  local mutation_path="${temporary_root}/BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
  printf '\nlet fallback = true\n' >>"${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_neutral_fallback_mutation_self_test_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautySDK/BeautyEngine.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift"
  printf '\npublic var renderBackend: String?\n' >>"${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_neutral_public_schema_mutation_self_test_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautyCore/Models/BeautyConfiguration.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift"
  python3 - "${mutation_path}" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
path.write_text(text.replace("package let changedPixelCount: Int", "package let rawMask: Int", 1), encoding="utf-8")
PY
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_neutral_privacy_mutation_self_test_failed" >&2
    return 1
  fi
  cp -- "${package_root}/Sources/BeautyEffects/Backend/BeautyBackendContract.swift" "${mutation_path}"

  mutation_path="${temporary_root}/BeautySDK/Sources/BeautySDK/BeautyEngine.swift"
  printf '\nlet direct = BeautyColorEffectPipeline.apply\n' >>"${mutation_path}"
  if validate_static_boundary "${temporary_root}" >/dev/null 2>&1; then
    echo "backend_neutral_direct_dispatch_mutation_self_test_failed" >&2
    return 1
  fi
  echo "backend_neutral_contract_self_test_passed"
}

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  self_test
  exit $?
fi
[[ "$#" -eq 0 ]] || exit 2
for command_name in python3 swift; do
  command -v "${command_name}" >/dev/null || {
    echo "backend_neutral_contract_preflight_failed"
    exit 1
  }
done

validate_static_boundary "${repository_root}" || {
  echo "backend_neutral_contract_static_boundary_failed"
  exit 1
}
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-backend-neutral.XXXXXX")"
run_focused_suite "${temporary_root}/focused.log" || {
  echo "backend_neutral_contract_focused_tests_failed"
  exit 1
}
bash "${repository_root}/scripts/check-cpu-reference-oracles.sh" >/dev/null || {
  echo "backend_neutral_contract_cpu_reference_failed"
  exit 1
}
echo "backend_neutral_contract_passed focused_tests=11 cpu_reference_tests=41"
