#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

fail() {
    echo "SDK boundary check failed: $*" >&2
    return 1
}

validate_taxonomy() {
    local root="$1"
    python3 - "$root" <<'PY'
import os
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
taxonomy_path = root / "docs/SDK_EFFECT_TAXONOMY.md"
parameters_path = root / "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
if not taxonomy_path.is_file() or taxonomy_path.is_symlink():
    raise SystemExit("taxonomy owner is missing or symlinked")
if not parameters_path.is_file() or parameters_path.is_symlink():
    raise SystemExit("BeautyParameters source is missing or symlinked")

taxonomy = taxonomy_path.read_text(encoding="utf-8")
source = parameters_path.read_text(encoding="utf-8")
for token in (
    "implemented", "partial", "future", "visual layout", "application lifecycle",
    "SDK_PARAMETER_INVENTORY_BEGIN", "SDK_PARAMETER_INVENTORY_END",
    "SDK_LEGACY_TAXONOMY_BEGIN", "SDK_LEGACY_TAXONOMY_END",
):
    if token not in taxonomy:
        raise SystemExit(f"taxonomy is missing boundary token: {token}")

source_fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):", source, re.MULTILINE)
if len(source_fields) != 61 or len(set(source_fields)) != 61:
    raise SystemExit(f"expected exact 61-field BeautyParameters source, found {len(source_fields)}")
inventory = taxonomy.split("<!-- SDK_PARAMETER_INVENTORY_BEGIN -->", 1)[1].split(
    "<!-- SDK_PARAMETER_INVENTORY_END -->", 1
)[0]
documented_fields = re.findall(r"`([A-Za-z][A-Za-z0-9]*)`", inventory)
if set(documented_fields) != set(source_fields) or len(documented_fields) != 61:
    missing = sorted(set(source_fields) - set(documented_fields))
    extra = sorted(set(documented_fields) - set(source_fields))
    raise SystemExit(
        f"taxonomy public inventory differs from BeautyParameters: missing={missing}, extra={extra}"
    )

expected = [
    ("3D塑颜", "对称", "future", "—"), ("3D塑颜", "上下", "future", "—"),
    ("3D塑颜", "左右", "future", "—"), ("3D塑颜", "倾斜", "future", "—"),
    ("比例", "小头", "partial", "faceSmall"), ("比例", "头包脸", "future", "—"),
    ("比例", "颅顶", "future", "—"), ("比例", "额头", "future", "—"),
    ("比例", "中庭", "future", "—"), ("比例", "人中", "future", "—"),
    ("比例", "下庭", "future", "—"), ("比例", "短脸", "future", "—"),
    ("脸型", "脸宽", "implemented", "faceSlim"), ("脸型", "小脸", "implemented", "faceSmall"),
    ("脸型", "面部流畅", "implemented", "faceContourSmooth"),
    ("脸型", "太阳穴", "implemented", "templeFullness"),
    ("脸型", "颧骨", "implemented", "cheekboneSlim"),
    ("脸型", "下巴长短", "implemented", "chinLength"),
    ("脸型", "去双下巴", "future", "—"), ("脸型", "去双下巴 Pro", "future", "—"),
    ("脸型", "尖下巴", "implemented", "chinTaper"), ("脸型", "V脸", "implemented", "faceVShape"),
    ("脸型", "下颌角", "implemented", "jawSlim"), ("脸型", "下颌线", "implemented", "jawSlim"),
    ("脸型", "发际线", "future", "—"),
    ("眼睛", "大小", "implemented", "eyeSize"), ("眼睛", "上下", "implemented", "eyeYPosition"),
    ("眼睛", "眼高", "implemented", "eyeHeight"), ("眼睛", "长度", "implemented", "eyeLength"),
    ("眼睛", "眼距", "implemented", "eyeDistance"), ("眼睛", "去脂", "future", "—"),
    ("眼睛", "提肌", "implemented", "upperEyelidLift"),
    ("眼睛", "眼瞳大小", "implemented", "pupilSize"),
    ("眼睛", "眼神矫正", "implemented", "gazeCorrection"),
    ("眼睛", "眼睑下至", "implemented", "lowerEyelidDrop"),
    ("眼睛", "眼尾上扬", "implemented", "eyeTailLift"),
    ("眼睛", "倾斜", "implemented", "eyeTilt"),
    ("眼睛", "祛红血丝", "implemented", "scleraRednessReduction"),
    ("眼睛", "内眼角", "implemented", "innerCornerOpen"),
    ("眼睛", "外眼角", "implemented", "outerCornerOpen"),
    ("眼睛", "对称", "implemented", "eyeSymmetry"),
    ("嘴唇", "大小", "implemented", "mouthSize"), ("嘴唇", "宽度", "implemented", "mouthWidth"),
    ("嘴唇", "上下", "implemented", "mouthYPosition"), ("嘴唇", "倾斜", "implemented", "mouthTilt"),
    ("嘴唇", "左右", "implemented", "mouthXPosition"),
    ("嘴唇", "M唇", "implemented", "lipPeakDefinition"),
    ("嘴唇", "丰唇", "implemented", "lipPlump"), ("嘴唇", "微笑", "implemented", "smile"),
    ("嘴唇", "白牙", "implemented", "teethWhitening"),
    ("鼻子", "大小", "implemented", "noseSlim"), ("鼻子", "提升", "implemented", "noseTipLift"),
    ("鼻子", "鼻翼", "implemented", "noseWingSlim"),
    ("鼻子", "山根", "implemented", "noseRootNarrowing"),
    ("鼻子", "鼻梁", "implemented", "noseBridge"), ("鼻子", "鼻尖", "implemented", "noseTipSize"),
    ("眉毛", "上下", "implemented", "eyebrowYPosition"),
    ("眉毛", "粗细", "implemented", "eyebrowThickness"),
    ("眉毛", "长短", "implemented", "eyebrowLength"),
    ("眉毛", "间距", "implemented", "eyebrowSpacing"),
    ("眉毛", "眉头间距", "implemented", "eyebrowHeadSpacing"),
    ("眉毛", "倾斜", "implemented", "eyebrowTilt"),
    ("眉毛", "眉峰", "implemented", "eyebrowPeakDefinition"),
]

block = taxonomy.split("<!-- SDK_LEGACY_TAXONOMY_BEGIN -->", 1)[1].split(
    "<!-- SDK_LEGACY_TAXONOMY_END -->", 1
)[0]
actual = []
for line in block.splitlines():
    if not line.startswith("|") or line.startswith("| ---") or line.startswith("| Group"):
        continue
    columns = [column.strip() for column in line.strip().strip("|").split("|")]
    if len(columns) != 5:
        raise SystemExit(f"malformed taxonomy row: {line}")
    mapping = columns[3].strip("`")
    actual.append((columns[0], columns[1], columns[2], mapping))
if actual != expected:
    raise SystemExit("legacy taxonomy rows/status/mappings differ from the exact SDK authority")
PY
}

validate_pre_archive() {
    local root="$1"
    validate_taxonomy "$root" || return 1
    python3 - "$root" <<'PY'
import os
from pathlib import Path
import stat
import sys

root = Path(sys.argv[1])
roots = ("BeautyDemo", "meituxiuxiu")
excluded_names = {".DS_Store"}
excluded_components = {".build", ".cache", "cache", "caches", "Caches", "__pycache__", "xcuserdata"}
expected_pngs = {*(f"IMG_{number:04d}.PNG" for number in range(856, 871)),
                 *(f"home/IMG_{number:04d}.PNG" for number in range(871, 875))}
expected_reference_text = {
    "FUNCTION_MAP.md", "HOME_MAP.md", "html/README.md", "html/editor.html",
    "html/home.html", "html/offline-check.mjs", "html/styles.css",
}

included = {}
for name in roots:
    source = root / name
    if source.is_symlink() or not source.is_dir() or source.resolve() != source:
        raise SystemExit(f"pre-archive source is missing, symlinked, or non-exact: {name}")
    paths = []
    for directory, directory_names, file_names in os.walk(source, topdown=True, followlinks=False):
        directory_names.sort()
        file_names.sort()
        for child in list(directory_names):
            path = Path(directory) / child
            if path.is_symlink():
                raise SystemExit(f"source symlink is forbidden: {path.relative_to(root)}")
        directory_names[:] = [
            child for child in directory_names
            if child not in excluded_components and child not in excluded_names
        ]
        for filename in file_names:
            path = Path(directory) / filename
            relative = path.relative_to(source).as_posix()
            if path.is_symlink():
                raise SystemExit(f"source symlink is forbidden: {path.relative_to(root)}")
            if filename in excluded_names or filename.endswith(".xcuserstate"):
                continue
            if not path.is_file():
                raise SystemExit(f"source contains a non-regular entry: {path.relative_to(root)}")
            paths.append(relative)
    included[name] = set(paths)
if not included["BeautyDemo"]:
    raise SystemExit("BeautyDemo live inventory is empty")
pngs = {path for path in included["meituxiuxiu"] if path.lower().endswith(".png")}
text = included["meituxiuxiu"] - pngs
if pngs != expected_pngs or text != expected_reference_text:
    raise SystemExit(
        f"meituxiuxiu exact inventory differs: missing_png={sorted(expected_pngs-pngs)}, "
        f"extra_png={sorted(pngs-expected_pngs)}, missing_text={sorted(expected_reference_text-text)}, "
        f"extra_text={sorted(text-expected_reference_text)}"
    )
PY
    [ "$?" -eq 0 ] || return 1
    python3 "$root/scripts/archive-legacy-ui.py" create --output "$root/archives/legacy-ui" --dry-run >/dev/null || return 1
    echo "PRE-ARCHIVE SDK BOUNDARY PASSED"
}

validate_post_archive() {
    local root="$1"
    validate_taxonomy "$root" || return 1
    python3 - "$root" <<'PY'
from pathlib import Path
import hashlib
import os
import re
import stat
import subprocess
import sys

root = Path(sys.argv[1])
for name in ("BeautyDemo", "meituxiuxiu"):
    if (root / name).exists() or (root / name).is_symlink():
        raise SystemExit(f"retired legacy source was restored: {name}/")

current_text_files = (
    "AGENTS.md", "ARCHITECTURE.md", "DESIGN.md", "FRONTEND.md",
    "PRODUCT_SENSE.md", "QUALITY_SCORE.md", "SECURITY.md", "RELIABILITY.md",
    "PLANS.md", "docs/README.md", "docs/SDK_EFFECT_TAXONOMY.md",
    ".planning/PROJECT.md", ".planning/REQUIREMENTS.md", ".planning/ROADMAP.md",
    ".planning/STATE.md", ".planning/codebase/ARCHITECTURE.md",
    ".planning/codebase/CONCERNS.md", ".planning/codebase/CONVENTIONS.md",
    ".planning/codebase/INTEGRATIONS.md", ".planning/codebase/STACK.md",
    ".planning/codebase/STRUCTURE.md", ".planning/codebase/TESTING.md",
    "scripts/run-no-skip-swiftpm.sh",
)
for relative in current_text_files:
    path = root / relative
    if not path.is_file() or path.is_symlink():
        raise SystemExit(f"current text owner missing or symlinked: {relative}")

required_boundary_markers = (
    "AGENTS.md", "ARCHITECTURE.md", "FRONTEND.md", "PRODUCT_SENSE.md",
    "QUALITY_SCORE.md", ".planning/PROJECT.md", "docs/README.md",
    ".planning/codebase/ARCHITECTURE.md", ".planning/codebase/CONCERNS.md",
    ".planning/codebase/CONVENTIONS.md", ".planning/codebase/INTEGRATIONS.md",
    ".planning/codebase/STACK.md", ".planning/codebase/STRUCTURE.md",
    ".planning/codebase/TESTING.md",
)
for relative in required_boundary_markers:
    path = root / relative
    text = path.read_text(encoding="utf-8")
    if re.search(r"SDK[- ]only", text, re.IGNORECASE) is None or "SwiftPM" not in text:
        raise SystemExit(f"current owner lacks SDK-only/SwiftPM boundary: {relative}")

def current_fragment(relative):
    text = (root / relative).read_text(encoding="utf-8")
    if relative == "ARCHITECTURE.md":
        return text.split("## 11. 决策记录", 1)[0]
    if relative == "SECURITY.md":
        return text.split("## 16. Security Decision Log", 1)[0]
    if relative == "RELIABILITY.md":
        return text.split("## 20. Reliability Decision Log", 1)[0]
    if relative == "PRODUCT_SENSE.md":
        return text.split("## 12. Product Decision Log", 1)[0]
    if relative == "QUALITY_SCORE.md":
        prefix, separator, remainder = text.partition("### 3.1 Phase 4 Final Verification")
        if separator:
            _, section_four, tail = remainder.partition("## 4. Product Domain Scorecard")
            text = prefix + ("\n## 4. Product Domain Scorecard" + tail if section_four else "")
        return text.split("## 15. Quality Decision Log", 1)[0]
    if relative == "PLANS.md":
        prefix = text.split("## 3A. Historical Lifecycle Ledger", 1)[0]
        if "## 5. Tech Debt" in text:
            return prefix + "\n## 5. Tech Debt" + text.split("## 5. Tech Debt", 1)[1]
        return prefix
    if relative == ".planning/PROJECT.md":
        return text.split("## Last Completed Milestone", 1)[0]
    return text

forbidden = re.compile(
    r"xcodebuild|xcrun\s+simctl|platform\s*=\s*iOS Simulator|\.xcodeproj\b|"
    r"\.xcworkspace\b|\.xcscheme\b|\.xctestplan\b|-scheme\s+BeautyDemo|"
    r"BeautyDemoTests|XCUIApplication|XCUIDevice|XCUIScreen|import\s+SwiftUI"
)
for relative in current_text_files:
    path = root / relative
    if not path.is_file():
        raise SystemExit(f"active owner is missing: {relative}")
    match = forbidden.search(current_fragment(relative))
    if match:
        raise SystemExit(f"stale app/Xcode/UI dependency in {relative}: {match.group(0)}")

ignored_prefixes = (".git/", ".planning/milestones/", ".planning/phases/")

def is_ignored_build_tree(path, relative):
    """Prune only real, gitignored directories whose exact name is .build."""
    if path.name != ".build":
        return False
    result = subprocess.run(
        ["git", "-C", str(root), "check-ignore", "-q", "--no-index", "--", relative + "/"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
    )
    if result.returncode not in (0, 1):
        raise SystemExit(
            f"git check-ignore failed for generated build tree {relative}: "
            f"{result.stderr.decode('utf-8', errors='replace').strip()}"
        )
    return result.returncode == 0

def swift_tokens(text):
    """Tokenize enough Swift syntax to inspect declarations without trivia."""
    tokens = []
    index = 0
    length = len(text)
    while index < length:
        character = text[index]
        if character.isspace():
            index += 1
            continue
        if text.startswith("//", index):
            newline = text.find("\n", index + 2)
            index = length if newline == -1 else newline + 1
            continue
        if text.startswith("/*", index):
            index += 2
            depth = 1
            while index < length and depth:
                if text.startswith("/*", index):
                    depth += 1
                    index += 2
                elif text.startswith("*/", index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
            if depth:
                raise SystemExit("unterminated Swift block comment")
            continue
        # Skip ordinary, multiline, and raw Swift string literals.  A source
        # string is trivia for this guard: declarations inside it are not code.
        raw_hashes = 0
        while index + raw_hashes < length and text[index + raw_hashes] == "#":
            raw_hashes += 1
        quote = index + raw_hashes
        if quote < length and text[quote] == '"':
            def find_closing(search_from, closing):
                cursor = search_from
                while cursor < length:
                    # In an extended (raw) string, only a hash-qualified
                    # escape consumes the following quote.  An ordinary
                    # backslash is literal text and must not hide a real
                    # quote/hash terminator (for example: #"abc\"#).
                    # Ordinary strings retain their usual one-character
                    # escape behavior.
                    if text[cursor] == "\\":
                        if raw_hashes == 0:
                            cursor += 2
                        else:
                            escaped = cursor + 1 + raw_hashes
                            if (
                                escaped < length
                                and text[cursor + 1:escaped] == ("#" * raw_hashes)
                                and text[escaped] in {'"', "\\", "("}
                            ):
                                cursor = escaped + 1
                            else:
                                cursor += 1
                    elif text.startswith(closing, cursor):
                        return cursor
                    else:
                        cursor += 1
                return None

            # Swift only treats a triple-quote prefix as a multiline literal
            # when its content begins on the following line.  Otherwise the
            # same bytes are a valid single-line raw literal: #"""# contains
            # one quote and #"""ok"""# contains two quotes around "ok".
            # First look for a real multiline terminator, then fall back to
            # the single-line delimiter.  If neither exists, fail closed.
            multiline = text.startswith('"""', quote) and quote + 3 < length and text[quote + 3] in "\r\n"
            opening_length = 3 if multiline else 1
            closing = ('"""' if multiline else '"') + ('#' * raw_hashes)
            end = find_closing(quote + opening_length, closing)
            if end is None and multiline:
                end = find_closing(quote + 1, '"' + ('#' * raw_hashes))
            if end is None:
                raise SystemExit("unterminated Swift string literal")
            index = end + len(closing)
            continue
        if character == "`":
            end = text.find("`", index + 1)
            if end == -1:
                raise SystemExit("unterminated Swift escaped identifier")
            tokens.append(text[index + 1:end])
            index = end + 1
            continue
        if character.isalpha() or character == "_":
            end = index + 1
            while end < length and (text[end].isalnum() or text[end] == "_"):
                end += 1
            tokens.append(text[index:end])
            index = end
            continue
        if character.isdigit():
            end = index + 1
            while end < length and (text[end].isalnum() or text[end] in "._"):
                end += 1
            tokens.append(text[index:end])
            index = end
            continue
        if character in "@<>{}:,()[]?!.=":
            tokens.append(character)
            index += 1
            continue
        # Operators and other punctuation cannot make a valid declaration
        # look like it has an Output: Sendable clause, but retaining them keeps
        # the token stream structurally faithful for the header scan.
        tokens.append(character)
        index += 1
    return tokens


def find_unconditional_beauty_result_sendability(text):
    tokens = swift_tokens(text)
    declaration_kinds = {"struct", "class", "enum", "extension"}
    for index, token in enumerate(tokens):
        if token != "BeautyResult" or index == 0 or tokens[index - 1] not in declaration_kinds:
            continue
        header_end = index + 1
        while header_end < len(tokens) and tokens[header_end] != "{":
            header_end += 1
        header = tokens[index + 1:header_end]
        unchecked = any(
            header[position:position + 3] == ["@", "unchecked", "Sendable"]
            for position in range(max(0, len(header) - 2))
        )
        if not unchecked:
            continue
        conditional = any(
            header[position:position + 4] == ["where", "Output", ":", "Sendable"]
            for position in range(max(0, len(header) - 3))
        )
        if not conditional:
            return True
    return False


for directory, directory_names, file_names in os.walk(root, topdown=True, followlinks=False):
    relative_directory = Path(directory).relative_to(root).as_posix()
    prefix = "" if relative_directory == "." else relative_directory + "/"
    if any(prefix.startswith(ignored) for ignored in ignored_prefixes):
        directory_names[:] = []
        continue
    kept_directories = []
    for name in directory_names:
        path = Path(directory) / name
        relative = path.relative_to(root).as_posix()
        mode = path.lstat().st_mode
        if stat.S_ISLNK(mode):
            raise SystemExit(f"symlink is forbidden in active repository roots: {relative}")
        child_prefix = relative + "/"
        if any(child_prefix.startswith(ignored) for ignored in ignored_prefixes):
            continue
        if stat.S_ISDIR(mode) and is_ignored_build_tree(path, relative):
            continue
        if path.suffix in {".xcodeproj", ".xcworkspace"}:
            raise SystemExit(f"active Xcode artifact remains: {relative}")
        kept_directories.append(name)
    directory_names[:] = kept_directories
    for name in file_names:
        path = Path(directory) / name
        relative = path.relative_to(root).as_posix()
        mode = path.lstat().st_mode
        if stat.S_ISLNK(mode):
            raise SystemExit(f"symlink is forbidden in active repository roots: {relative}")
        if not stat.S_ISREG(mode):
            raise SystemExit(f"non-regular entry is forbidden in active repository roots: {relative}")
        if path.name == "project.pbxproj" or path.suffix in {".xcscheme", ".xctestplan"}:
            raise SystemExit(f"active Xcode/UI-test artifact remains: {relative}")
        if path.suffix == ".swift":
            text = path.read_text(encoding="utf-8", errors="replace")
            if re.search(r"^\s*import\s+SwiftUI\b", text, re.MULTILINE):
                raise SystemExit(f"active SwiftUI source remains: {relative}")
            ui_test = re.search(r"\b(?:XCUIApplication|XCUIDevice|XCUIScreen)\b", text)
            if ui_test:
                raise SystemExit(f"active UI-test dependency remains in {relative}: {ui_test.group(0)}")
            # BeautyResult may only promise Sendable conditionally.  Parse
            # Swift tokens so comments and strings cannot manufacture a where
            # clause or hide the trivia between @unchecked and Sendable.
            if find_unconditional_beauty_result_sendability(text):
                raise SystemExit(
                    f"unconditional generic BeautyResult Sendable conformance remains: {relative}"
                )

tracked = subprocess.run(
    ["git", "-C", str(root), "ls-files", "-z"], check=True, stdout=subprocess.PIPE
).stdout.split(b"\0")
binary_extensions = {".png", ".jpg", ".jpeg", ".gif", ".webp", ".heic", ".heif", ".tif", ".tiff", ".bmp", ".mov", ".mp4"}
for item in tracked:
    if not item:
        continue
    relative = item.decode("utf-8")
    if Path(relative).suffix.lower() in binary_extensions:
        raise SystemExit(f"tracked generated/restored media is forbidden: {relative}")

allowed_metal = {"BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"}
expected_metal_sha256 = {
    "BeautySDK/Sources/BeautyRender/Shaders/Warp.metal":
        "c95ff274a6d5eb70bffac981b876441fc7981d175be21d1d16e05e4fc81035a6",
}
actual_metal = {
    path.relative_to(root).as_posix()
    for path in (root / "BeautySDK/Sources").rglob("*.metal")
}
if actual_metal != allowed_metal:
    raise SystemExit(
        f"v1.16 Metal source inventory drift: missing={sorted(allowed_metal-actual_metal)}, "
        f"extra={sorted(actual_metal-allowed_metal)}"
    )
for relative, expected_digest in expected_metal_sha256.items():
    path = root / relative
    if not path.is_file() or path.is_symlink():
        raise SystemExit(f"v1.16 retained Metal source is missing or symlinked: {relative}")
    actual_digest = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual_digest != expected_digest:
        raise SystemExit(f"v1.16 retained Metal source content drift: {relative}")
backend_pattern = re.compile(r"BeautyRenderBackend|renderBackend|\bcase\s+gpu\b|\bcase\s+\.gpu\b")
allowed_backend_paths = {
    "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift",
    "BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift",
    "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
    "BeautySDK/Tests/BeautyCoreTests/BeautyConfigurationTests.swift",
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineBackendRoutingTests.swift",
    "BeautySDK/Tests/BeautyCoreTests/BeautyBackendSelectionConcurrencyTests.swift",
}
for base in (root / "BeautySDK/Sources", root / "BeautySDK/Tests"):
    if not base.exists():
        continue
    for path in base.rglob("*.swift"):
        match = backend_pattern.search(path.read_text(encoding="utf-8", errors="replace"))
        if match and path.relative_to(root).as_posix() not in allowed_backend_paths:
            raise SystemExit(f"v1.16 GPU API/backend drift in {path.relative_to(root)}: {match.group(0)}")
PY
    [ "$?" -eq 0 ] || return 1
    echo "POST-ARCHIVE SDK BOUNDARY PASSED"
}

expect_failure() {
    if "$@" >/dev/null 2>&1; then
        fail "self-test mutation unexpectedly passed: $*"
    fi
}

write_post_owner() {
    local path="$1"
    mkdir -p "$(dirname "$path")"
    printf '%s\n' '# Current SDK-only contract' 'SwiftPM is the only active validation surface.' > "$path"
}

self_test() {
    local fixture
    fixture="$(mktemp -d "${TMPDIR:-/tmp}/sdk-boundary-self-test.XXXXXX")"
    fixture="$(cd "$fixture" && pwd -P)"
    trap 'rm -rf "$fixture"' EXIT
    mkdir -p "$fixture/scripts" "$fixture/docs" "$fixture/BeautySDK/Sources/BeautyCore/Models"
    cp "$PROJECT_ROOT/docs/SDK_EFFECT_TAXONOMY.md" "$fixture/docs/SDK_EFFECT_TAXONOMY.md"
    cp "$PROJECT_ROOT/BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift" \
        "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
    printf '%s\n' \
        'public struct BeautyResult<Output> {}' \
        'extension BeautyResult: Sendable where Output: Sendable {}' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    mkdir -p "$fixture/BeautyDemo" "$fixture/meituxiuxiu/home" "$fixture/meituxiuxiu/html"
    printf '%s\n' 'import Foundation' > "$fixture/BeautyDemo/Demo.swift"
    local number padded
    for number in $(seq 856 870); do
        printf -v padded '%04d' "$number"
        printf 'PNG%s' "$number" > "$fixture/meituxiuxiu/IMG_${padded}.PNG"
    done
    for number in $(seq 871 874); do
        printf -v padded '%04d' "$number"
        printf 'PNG%s' "$number" > "$fixture/meituxiuxiu/home/IMG_${padded}.PNG"
    done
    local path
    for path in FUNCTION_MAP.md HOME_MAP.md html/README.md html/editor.html html/home.html html/offline-check.mjs html/styles.css; do
        mkdir -p "$(dirname "$fixture/meituxiuxiu/$path")"
        printf '%s\n' 'reference' > "$fixture/meituxiuxiu/$path"
    done
    printf '%s\n' 'import sys' 'sys.exit(0)' > "$fixture/scripts/archive-legacy-ui.py"
    validate_pre_archive "$fixture" >/dev/null
    rm "$fixture/meituxiuxiu/IMG_0856.PNG"
    expect_failure validate_pre_archive "$fixture"
    printf 'PNG856' > "$fixture/meituxiuxiu/IMG_0856.PNG"
    ln -s Demo.swift "$fixture/BeautyDemo/link"
    expect_failure validate_pre_archive "$fixture"
    rm "$fixture/BeautyDemo/link"
    cp "$fixture/docs/SDK_EFFECT_TAXONOMY.md" "$fixture/docs/taxonomy.saved"
    python3 - "$fixture/docs/SDK_EFFECT_TAXONOMY.md" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
path.write_text(path.read_text(encoding="utf-8").replace("| 眉毛 | 眉峰 |", "| 眉毛 | missing |", 1), encoding="utf-8")
PY
    expect_failure validate_pre_archive "$fixture"
    mv "$fixture/docs/taxonomy.saved" "$fixture/docs/SDK_EFFECT_TAXONOMY.md"

    rm -rf "$fixture/BeautyDemo" "$fixture/meituxiuxiu"
    local owner
    for owner in AGENTS.md ARCHITECTURE.md DESIGN.md FRONTEND.md SECURITY.md RELIABILITY.md PRODUCT_SENSE.md QUALITY_SCORE.md PLANS.md \
        docs/README.md .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md .planning/STATE.md \
        .planning/codebase/ARCHITECTURE.md .planning/codebase/CONCERNS.md .planning/codebase/CONVENTIONS.md \
        .planning/codebase/INTEGRATIONS.md .planning/codebase/STACK.md .planning/codebase/STRUCTURE.md \
        .planning/codebase/TESTING.md scripts/run-no-skip-swiftpm.sh; do
        write_post_owner "$fixture/$owner"
    done
    mkdir -p "$fixture/BeautySDK/Sources/BeautyRender/Shaders" "$fixture/BeautySDK/Tests" \
        "$fixture/.planning/milestones/old" "$fixture/archives/legacy-ui"
    cp "$PROJECT_ROOT/BeautySDK/Sources/BeautyRender/Shaders/Warp.metal" \
        "$fixture/BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"
    printf '%s\n' 'historical: xcodebuild -project BeautyDemo/BeautyDemo.xcodeproj' > "$fixture/.planning/milestones/old/history.md"
    printf '%s\n' 'historical BeautyDemo restoration only' > "$fixture/archives/legacy-ui/README.md"
    printf '%s\n' '**/.build/' > "$fixture/.gitignore"
    git -C "$fixture" init -q
    git -C "$fixture" config user.email boundary@test.invalid
    git -C "$fixture" config user.name 'Boundary Self Test'
    git -C "$fixture" add .
    git -C "$fixture" commit -qm fixture
    validate_post_archive "$fixture" >/dev/null
    printf '%s\n' 'public struct BeautyResult<Output>: @unchecked Sendable {}' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    expect_failure validate_post_archive "$fixture"
    printf '%s\n' 'public struct BeautyResult<Output>: @unchecked /* trivia gap */ Sendable {}' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    expect_failure validate_post_archive "$fixture"
    printf '%s\n' 'extension BeautyResult /* where Output: Sendable */: @unchecked Sendable {}' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    expect_failure validate_post_archive "$fixture"
    printf '%s\n' \
        'let first = #"abc\"#' \
        'public struct BeautyResult<Output>: @unchecked Sendable {}' \
        'let second = #"ok"#' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    expect_failure validate_post_archive "$fixture"
    printf '%s\n' \
        'let first = #"""#' \
        'public struct BeautyResult<Output>: @unchecked Sendable {}' \
        'let second = #"""ok"""#' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    expect_failure validate_post_archive "$fixture"
    printf '%s\n' \
        'public struct BeautyResult<Output> {}' \
        'extension BeautyResult: Sendable where Output: Sendable {}' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    validate_post_archive "$fixture" >/dev/null
    printf '%s\n' \
        'public struct BeautyResult<Output> {}' \
        'extension BeautyResult: @unchecked Sendable where Output: Sendable {}' \
        > "$fixture/BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift"
    validate_post_archive "$fixture" >/dev/null
    local ignored_build_external
    ignored_build_external="$(mktemp -d "${TMPDIR:-/tmp}/sdk-boundary-ignored-build.XXXXXX")"
    mkdir -p "$ignored_build_external/release" "$ignored_build_external/debug" \
        "$fixture/.codex/skills/example/.build" "$fixture/.planning/spikes/example/.build"
    ln -s "$ignored_build_external/release" "$fixture/.codex/skills/example/.build/release"
    ln -s "$ignored_build_external/debug" "$fixture/.planning/spikes/example/.build/debug"
    validate_post_archive "$fixture" >/dev/null
    rm -rf "$ignored_build_external"
    mkdir "$fixture/BeautyDemo"
    expect_failure validate_post_archive "$fixture"
    rmdir "$fixture/BeautyDemo"
    mkdir "$fixture/Restored.xcodeproj"
    expect_failure validate_post_archive "$fixture"
    rmdir "$fixture/Restored.xcodeproj"
    printf '%s\n' 'test plan' > "$fixture/Restored.xctestplan"
    expect_failure validate_post_archive "$fixture"
    rm "$fixture/Restored.xctestplan"
    printf '%s\n' 'import XCTest' 'let app = XCUIApplication()' > "$fixture/BeautySDK/Tests/RestoredUITests.swift"
    expect_failure validate_post_archive "$fixture"
    rm "$fixture/BeautySDK/Tests/RestoredUITests.swift"
    printf '%s\n' 'import SwiftUI' > "$fixture/BeautySDK/Sources/RestoredView.swift"
    expect_failure validate_post_archive "$fixture"
    rm "$fixture/BeautySDK/Sources/RestoredView.swift"
    printf '%s\n' 'xcodebuild -project Legacy.xcodeproj' >> "$fixture/ARCHITECTURE.md"
    expect_failure validate_post_archive "$fixture"
    write_post_owner "$fixture/ARCHITECTURE.md"
    for path in docs/README.md .planning/PROJECT.md .planning/codebase/INTEGRATIONS.md scripts/run-no-skip-swiftpm.sh; do
        cp "$fixture/$path" "$fixture/$path.saved"
        printf '%s\n' 'xcodebuild -project Legacy.xcodeproj' >> "$fixture/$path"
        expect_failure validate_post_archive "$fixture"
        mv "$fixture/$path.saved" "$fixture/$path"
    done
    local external_tree
    external_tree="$(mktemp -d "${TMPDIR:-/tmp}/sdk-boundary-external.XXXXXX")"
    printf '%s\n' 'import SwiftUI' > "$external_tree/RestoredView.swift"
    ln -s "$external_tree" "$fixture/BeautySDK/Sources/LinkedTree"
    expect_failure validate_post_archive "$fixture"
    rm "$fixture/BeautySDK/Sources/LinkedTree"
    printf '%s\n' 'forbidden test plan' > "$external_tree/Restored.xctestplan"
    ln -s "$external_tree/Restored.xctestplan" "$fixture/BeautySDK/Sources/LinkedPlan"
    expect_failure validate_post_archive "$fixture"
    rm "$fixture/BeautySDK/Sources/LinkedPlan"
    rm -rf "$external_tree"
    printf 'PNG' > "$fixture/generated.png"
    git -C "$fixture" add generated.png
    expect_failure validate_post_archive "$fixture"
    git -C "$fixture" rm -q --cached generated.png
    rm "$fixture/generated.png"
    printf '%s\n' '// drift' > "$fixture/BeautySDK/Sources/BeautyRender/Shaders/NewPass.metal"
    expect_failure validate_post_archive "$fixture"
    rm "$fixture/BeautySDK/Sources/BeautyRender/Shaders/NewPass.metal"
    printf '%s\n' '// modified existing pass' >> "$fixture/BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"
    expect_failure validate_post_archive "$fixture"
    cp "$PROJECT_ROOT/BeautySDK/Sources/BeautyRender/Shaders/Warp.metal" \
        "$fixture/BeautySDK/Sources/BeautyRender/Shaders/Warp.metal"
    printf '%s\n' 'enum BeautyRenderBackend { case gpu }' > "$fixture/BeautySDK/Sources/Backend.swift"
    expect_failure validate_post_archive "$fixture"
    rm "$fixture/BeautySDK/Sources/Backend.swift"
    rm -rf "$fixture"
    trap - EXIT
    echo "SDK BOUNDARY SELF-TEST PASSED"
}

usage() {
    echo "Usage: $0 --self-test | --pre-archive | --post-archive" >&2
    exit 2
}

case "${1:-}" in
    --self-test)
        [ "$#" -eq 1 ] || usage
        self_test
        ;;
    --pre-archive)
        [ "$#" -eq 1 ] || usage
        validate_pre_archive "$PROJECT_ROOT"
        ;;
    --post-archive)
        [ "$#" -eq 1 ] || usage
        validate_post_archive "$PROJECT_ROOT"
        ;;
    *)
        usage
        ;;
esac
