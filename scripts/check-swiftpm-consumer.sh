#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly fixture_root="${repository_root}/IntegrationTests/BeautySDKConsumer"
readonly manifest_path="${fixture_root}/Package.swift"
readonly source_path="${fixture_root}/Sources/BeautySDKConsumer/main.swift"
readonly expected_output='beauty_sdk_consumer_smoke_passed width=4 height=3 rgba_bytes=48'
readonly maximum_build_output_bytes=$((16 * 1024 * 1024))
readonly maximum_runtime_output_bytes=$((1 * 1024 * 1024))
readonly maximum_runtime_output_lines=200000

fail() {
    echo "swiftpm_consumer_check_failed" >&2
    return 1
}

validate_static_boundary() {
    local root="$1"
    local manifest="${root}/Package.swift"
    local source="${root}/Sources/BeautySDKConsumer/main.swift"
    local dump_directory dump_path

    if ! [[ -d "$root" && ! -L "$root" ]]; then return 1; fi
    if ! [[ -f "$manifest" && ! -L "$manifest" ]]; then return 1; fi
    if ! [[ -f "$source" && ! -L "$source" ]]; then return 1; fi

    if ! python3 - "$root" "$manifest" "$source" <<'PY'
import json
from pathlib import Path
import re
import sys

root = Path(sys.argv[1]).resolve()
manifest = Path(sys.argv[2]).resolve()
source = Path(sys.argv[3]).resolve()

if sorted((root / "Sources").rglob("*.swift")) != [source]:
    raise SystemExit(1)

source_text = source.read_text(encoding="utf-8")
manifest_text = manifest.read_text(encoding="utf-8")
allowed_imports = {"BeautySDK", "CoreGraphics", "CoreImage", "Foundation", "ImageIO"}
imports = re.findall(r"^\s*import\s+([A-Za-z_][A-Za-z0-9_.]*)\s*$", source_text, re.MULTILINE)
if "BeautySDK" not in imports or any(module not in allowed_imports for module in imports):
    raise SystemExit(1)

forbidden = re.compile(
    r"@testable|@_spi|BeautyCore|BeautyDetection|BeautyEffects|BeautyRender|"
    r"BeautyResources|Demo|Xcode|simulator|device|xcodeproj|xcworkspace|"
    r"SwiftUI|UIKit",
    re.IGNORECASE,
)
if forbidden.search(source_text) or forbidden.search(manifest_text):
    raise SystemExit(1)

path_dependencies = re.findall(
    r"\.package\s*\(\s*path\s*:\s*\"([^\"]+)\"\s*\)", manifest_text
)
if path_dependencies != ["../../BeautySDK"]:
    raise SystemExit(1)
if len(re.findall(r"\.package\s*\(", manifest_text)) != 1:
    raise SystemExit(1)
if re.search(r"\.package\s*\(\s*(?!path\s*:)", manifest_text):
    raise SystemExit(1)
PY
    then
        return 1
    fi

    dump_directory="$(mktemp -d "${TMPDIR:-/tmp}/beauty-consumer-dump.XXXXXX")"
    dump_path="${dump_directory}/package.json"
    if ! swift package dump-package --package-path "$root" >"$dump_path" 2>/dev/null; then
        rm -rf "$dump_directory"
        return 1
    fi
    if ! python3 - "$dump_path" "$root" <<'PY'
import json
from pathlib import Path
import sys

package = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
root = Path(sys.argv[2]).resolve()
expected_dependency = (root / "../../BeautySDK").resolve()

dependencies = package.get("dependencies")
if not isinstance(dependencies, list) or len(dependencies) != 1:
    raise SystemExit(1)
file_system = dependencies[0].get("fileSystem")
if not isinstance(file_system, list) or len(file_system) != 1:
    raise SystemExit(1)
dependency = file_system[0]
if Path(dependency.get("path", "")).resolve() != expected_dependency:
    raise SystemExit(1)

targets = package.get("targets")
if not isinstance(targets, list) or len(targets) != 1:
    raise SystemExit(1)
target = targets[0]
if target.get("name") != "BeautySDKConsumer" or target.get("type") != "executable":
    raise SystemExit(1)
target_dependencies = target.get("dependencies")
if not isinstance(target_dependencies, list) or len(target_dependencies) != 1:
    raise SystemExit(1)
product = target_dependencies[0].get("product")
if not isinstance(product, list) or product[:2] != ["BeautySDK", "BeautySDK"]:
    raise SystemExit(1)
PY
    then
        rm -rf "$dump_directory"
        return 1
    fi
    rm -rf "$dump_directory"
}

run_consumer() {
    local scratch build_log runtime_log bin_path build_status runtime_status
    scratch="$(mktemp -d "${TMPDIR:-/tmp}/beauty-consumer-check.XXXXXX")"
    scratch="$(cd "$scratch" && pwd -P)"
    trap "rm -rf -- '${scratch}'" EXIT
    mkdir -p "${scratch}/build"
    build_log="${scratch}/build.log"
    runtime_log="${scratch}/runtime.log"

    build_status=0
    swift build \
        --package-path "$fixture_root" \
        --scratch-path "${scratch}/build" \
        >"$build_log" 2>&1 || build_status=$?
    if ! [[ "$build_status" -eq 0 ]]; then return 1; fi
    if ! [[ "$(wc -c <"$build_log")" -le "$maximum_build_output_bytes" ]]; then return 1; fi

    bin_path="$(swift build \
        --package-path "$fixture_root" \
        --scratch-path "${scratch}/build" \
        --show-bin-path 2>/dev/null)"
    if ! [[ "$bin_path" == "${scratch}/build/"* ]]; then return 1; fi
    if ! [[ -x "${bin_path}/BeautySDKConsumer" && ! -L "${bin_path}/BeautySDKConsumer" ]]; then return 1; fi

    runtime_status=0
    "${bin_path}/BeautySDKConsumer" >"$runtime_log" 2>&1 || runtime_status=$?
    if ! [[ "$runtime_status" -eq 0 ]]; then return 1; fi
    if ! [[ "$(wc -c <"$runtime_log")" -le "$maximum_runtime_output_bytes" ]]; then return 1; fi
    if ! [[ "$(wc -l <"$runtime_log")" -le "$maximum_runtime_output_lines" ]]; then return 1; fi
    if ! cmp -s "$runtime_log" <(printf '%s\n' "$expected_output"); then return 1; fi
    echo "swiftpm_consumer_check_passed"
}

self_test() {
    local self_test_root mutation_root
    self_test_root="$(mktemp -d "${TMPDIR:-/tmp}/beauty-consumer-self-test.XXXXXX")"
    trap "rm -rf -- '${self_test_root}'" EXIT
    mutation_root="${self_test_root}/fixture"
    mkdir -p "${mutation_root}/Sources/BeautySDKConsumer"
    mkdir -p "${self_test_root}/BeautySDK"
    cp "$manifest_path" "${mutation_root}/Package.swift"
    cp "$source_path" "${mutation_root}/Sources/BeautySDKConsumer/main.swift"
    cp "${repository_root}/BeautySDK/Package.swift" "${self_test_root}/BeautySDK/Package.swift"

    validate_static_boundary "$mutation_root"

    sed 's/import BeautySDK/import BeautyCore/' \
        "${mutation_root}/Sources/BeautySDKConsumer/main.swift" \
        >"${mutation_root}/Sources/BeautySDKConsumer/mutated.swift"
    mv "${mutation_root}/Sources/BeautySDKConsumer/mutated.swift" \
        "${mutation_root}/Sources/BeautySDKConsumer/main.swift"
    if validate_static_boundary "$mutation_root"; then
        echo "swiftpm_consumer_check_failed" >&2
        return 1
    fi

    cp "$manifest_path" "${mutation_root}/Package.swift"
    sed 's/\.product(name: "BeautySDK", package: "BeautySDK")/.product(name: "BeautyCore", package: "BeautySDK")/' \
        "${mutation_root}/Package.swift" >"${mutation_root}/Package.mutated.swift"
    mv "${mutation_root}/Package.mutated.swift" "${mutation_root}/Package.swift"
    if validate_static_boundary "$mutation_root"; then
        echo "swiftpm_consumer_check_failed" >&2
        return 1
    fi

    cp "$manifest_path" "${mutation_root}/Package.swift"
    sed 's/\.package(path: "..\/..\/BeautySDK")/.package(url: "https:\/\/example.invalid\/BeautySDK.git", from: "1.0.0")/' \
        "${mutation_root}/Package.swift" >"${mutation_root}/Package.mutated.swift"
    mv "${mutation_root}/Package.mutated.swift" "${mutation_root}/Package.swift"
    if validate_static_boundary "$mutation_root"; then
        echo "swiftpm_consumer_check_failed" >&2
        return 1
    fi

    echo "swiftpm_consumer_static_self_test_passed"
}

case "${1:-}" in
    --self-test)
        [[ "$#" -eq 1 ]] || exit 2
        self_test
        ;;
    "")
        validate_static_boundary "$fixture_root"
        run_consumer
        ;;
    *)
        exit 2
        ;;
esac
