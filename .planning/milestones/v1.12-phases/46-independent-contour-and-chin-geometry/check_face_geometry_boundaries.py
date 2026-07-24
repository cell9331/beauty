#!/usr/bin/env python3
"""Fail-closed Phase 46 contour/chin geometry boundary checker.

The checker has three modes:

* default: require the complete live Phase 46 provider/routing boundary;
* ``--pre-implementation``: require the Phase 45 boundary and prove that the
  Phase 46 named production emissions are still absent;
* ``--self-test``: mutate an isolated repository for every rule family.

Search status 0 means that every match must be classified, status 1 means a
clean no-match, and every other status is a blocking command failure. Raw
matched source text is never printed.
"""

from __future__ import annotations

import argparse
import dataclasses
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, Iterable, Mapping, Sequence


PACKAGE_HASH = "6f03b078816ad1f7a426e3f70d4f57503f3152e9"
PREDECESSOR_HASH = "7f7cb4ad0ec7463e065ad7b88c6858c0fceb10c4"
RESOURCE_INVENTORY_HASH = "be4c47139da4ce35409f4070fdeda71de23b2c81357b7ea30dd0d4d41dedc998"
PINNED_FILE_HASHES = {
    "BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift":
        "4f1ca10a8e4c6d42a9523145a2543b604aca82b8",
    "BeautySDK/Sources/BeautyResources/Resources/manifest.json":
        "1386786aaa364b3f59e2203a0c4e86c63d567e50",
    "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md":
        "9bdffc4a03b68b4988f8fd3ec23a8a73fe9ca258",
    "docs/meitu-function-blueprint/FEATURE_MATRIX.md":
        "da12d69d1e0b07208092470552d82a3f32deb07d",
    "docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md":
        "66ac67ecff7f1dff206f269e917562932d4d6fb7",
}
PHASE_DIR = Path(".planning/phases/46-independent-contour-and-chin-geometry")
PREDECESSOR = Path(
    ".planning/phases/45-public-contract-and-observed-face-support/"
    "check_face_support_boundaries.py"
)
SOURCE_ROOT = "BeautySDK/Sources"
FACE_PROVIDER = "BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift"
CHIN_PROVIDER = "BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift"
RESOLVER = "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift"
CAPS = "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift"
RENDERER = "BeautySDK/Sources/BeautyExampleRenderer"
FACE_FIELDS = (
    "faceSlim",
    "faceSmall",
    "faceVShape",
    "jawSlim",
    "faceContourSmooth",
    "templeFullness",
    "cheekboneSlim",
)
CHIN_FIELDS = ("chinLength", "chinTaper")
NEW_FIELDS = ("faceContourSmooth", "templeFullness", "cheekboneSlim", "chinTaper")
GENERATED_ROOTS = (
    "example-images/output",
    "example-images/gallery",
    "example-images/.gallery-staging",
    "example-images/.gallery-quarantine",
)
RESOURCE_ROOT = "BeautySDK/Sources/BeautyResources"
MODEL_SUFFIXES = (".mlmodel", ".mlmodelc", ".mlpackage", ".tflite", ".onnx")
INTERNAL_MODULES = (
    "BeautyCore",
    "BeautyDetection",
    "BeautyEffects",
    "BeautyRender",
    "BeautyResources",
)


class BoundaryCheckFailure(RuntimeError):
    """A missing path, unsafe path, command error, or unclassified match."""


@dataclasses.dataclass(frozen=True)
class Result:
    name: str
    ok: bool
    detail: str


@dataclasses.dataclass(frozen=True)
class ClassifiedSearch:
    state: str
    matches: int
    classified: int
    unclassified: int


Runner = Callable[[Sequence[str], Path], subprocess.CompletedProcess[str]]


def default_runner(command: Sequence[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            list(command),
            cwd=cwd,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
    except OSError as error:
        return subprocess.CompletedProcess(command, 127, "", str(error))


def run_checked(
    command: Sequence[str],
    cwd: Path,
    *,
    expected: Iterable[int] = (0,),
    runner: Runner = default_runner,
) -> subprocess.CompletedProcess[str]:
    """Run one command and reject exceptions or every unexpected exit."""
    try:
        completed = runner(command, cwd)
    except Exception as error:
        raise BoundaryCheckFailure(f"runner exception: {type(error).__name__}") from error
    if completed.returncode not in set(expected):
        diagnostic = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
        raise BoundaryCheckFailure(
            f"unexpected exit {completed.returncode}: {diagnostic[:160]}"
        )
    return completed


def classify_rg(
    root: Path,
    pattern: str,
    scopes: Sequence[str],
    *,
    classifier: Callable[[str], bool] | None = None,
    runner: Runner = default_runner,
) -> ClassifiedSearch:
    """Classify every rg match; status 1 alone is a clean no-match."""
    completed = run_checked(
        ("rg", "-n", "--no-heading", "--color", "never", pattern, *scopes),
        root,
        expected=(0, 1),
        runner=runner,
    )
    if completed.returncode == 1:
        return ClassifiedSearch("no-match", 0, 0, 0)
    lines = tuple(line for line in completed.stdout.splitlines() if line.strip())
    allowed = classifier or (lambda _line: False)
    classified = sum(1 for line in lines if allowed(line))
    unclassified = len(lines) - classified
    if unclassified:
        raise BoundaryCheckFailure(f"unclassified matches: {unclassified}")
    return ClassifiedSearch("matches", len(lines), classified, 0)


def locate_repo(start: Path) -> Path:
    resolved = start.resolve(strict=True)
    for candidate in (resolved, *resolved.parents):
        if (candidate / ".git").exists() and (candidate / "BeautySDK/Package.swift").is_file():
            return candidate
    raise BoundaryCheckFailure("repository root not found")


def safe_path(root: Path, relative: str | Path, *, directory: bool = False) -> Path:
    relative_path = Path(relative)
    if relative_path.is_absolute() or ".." in relative_path.parts:
        raise BoundaryCheckFailure("unsafe repository-relative path")
    resolved_root = root.resolve(strict=True)
    current = root
    for component in relative_path.parts:
        current = current / component
        if current.is_symlink():
            raise BoundaryCheckFailure("symlinked required path")
    candidate = root / relative_path
    try:
        resolved = candidate.resolve(strict=True)
    except (FileNotFoundError, RuntimeError) as error:
        raise BoundaryCheckFailure("missing or unresolvable required path") from error
    if resolved == resolved_root or resolved_root not in resolved.parents:
        raise BoundaryCheckFailure("required path escapes repository")
    if directory and not candidate.is_dir():
        raise BoundaryCheckFailure("required directory is not a directory")
    if not directory and not candidate.is_file():
        raise BoundaryCheckFailure("required file is not a regular file")
    return candidate


def read(root: Path, relative: str | Path) -> str:
    return safe_path(root, relative).read_text(encoding="utf-8")


def hash_file(root: Path, relative: str | Path) -> str:
    return hashlib.sha1(f"blob {safe_path(root, relative).stat().st_size}\0".encode() +
                        safe_path(root, relative).read_bytes()).hexdigest()


def result(name: str, operation: Callable[[], str]) -> Result:
    try:
        return Result(name, True, operation())
    except Exception as error:
        return Result(name, False, f"blocking_error={type(error).__name__}")


def git_lines(root: Path, *arguments: str) -> tuple[str, ...]:
    completed = run_checked(("git", *arguments), root)
    return tuple(line for line in completed.stdout.splitlines() if line.strip())


def check_paths(root: Path) -> str:
    files = (
        "BeautySDK/Package.swift",
        PREDECESSOR,
        FACE_PROVIDER,
        CHIN_PROVIDER,
        RESOLVER,
        CAPS,
        "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
        "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift",
        "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
        "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
        "docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md",
        ".gitignore",
        *PINNED_FILE_HASHES.keys(),
    )
    directories = (
        SOURCE_ROOT,
        "BeautyDemo",
        RENDERER,
        RESOURCE_ROOT,
    )
    for relative in files:
        safe_path(root, relative)
    for relative in directories:
        safe_path(root, relative, directory=True)
    return f"files={len(files)}; roots={len(directories)}"


def check_pins(
    root: Path,
    *,
    package_hash: str = PACKAGE_HASH,
    predecessor_hash: str = PREDECESSOR_HASH,
    pinned_hashes: Mapping[str, str] = PINNED_FILE_HASHES,
    resource_inventory_hash: str = RESOURCE_INVENTORY_HASH,
) -> str:
    expected = {
        "BeautySDK/Package.swift": package_hash,
        str(PREDECESSOR): predecessor_hash,
        **pinned_hashes,
    }
    mismatches = sum(hash_file(root, path) != digest for path, digest in expected.items())
    resource_paths = "\n".join(git_lines(root, "ls-files", "--", RESOURCE_ROOT))
    if resource_paths:
        resource_paths += "\n"
    inventory = hashlib.sha256(resource_paths.encode("utf-8")).hexdigest()
    if inventory != resource_inventory_hash:
        mismatches += 1
    if mismatches:
        raise BoundaryCheckFailure("pinned manifest/checker/resource/ledger drift")
    return f"pinned={len(expected)}; inventory=1"


def check_exposure(root: Path, *, runner: Runner = default_runner) -> str:
    pattern = (
        r"^\s*(?:public|package|@_spi[^\n]*public)\s+"
        r"(?:struct|class|enum|protocol|typealias)\s+"
        r"(?:BeautyFaceSemanticSupport|FaceGeometry|FaceShapeWarpFieldEmissions|"
        r"ChinWarpFieldEmissions|FaceShapeWarpProvider|ChinWarpProvider|"
        r"WarpControlPoint(?:Result|Provider)?)\b"
    )
    scan = classify_rg(root, pattern, (SOURCE_ROOT,), runner=runner)
    return f"unclassified={scan.unclassified}"


def check_storage(root: Path, *, runner: Runner = default_runner) -> str:
    subject = (
        r"BeautyObservedFaceSupport|BeautyFaceSemanticSupport|observedFaceSupport|"
        r"faceContourSmooth|templeFullness|cheekboneSlim|chinTaper"
    )
    storage = (
        r"Codable|Encodable|Decodable|UserDefaults|FileManager|CoreData|SwiftData|"
        r"NSKeyedArchiver|JSONEncoder|PropertyListEncoder|NSCache|static\s+var|\.write\("
    )

    def allowed(line: str) -> bool:
        path = line.split(":", 1)[0]
        return (
            path == "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift"
            and ("has no Codable" in line or "non-Codable" in line)
        )

    first = classify_rg(
        root,
        rf"(?:{subject}).*(?:{storage})|(?:{storage}).*(?:{subject})",
        (SOURCE_ROOT,),
        classifier=allowed,
        runner=runner,
    )
    return f"classified={first.classified}; unclassified=0"


def check_diagnostics(root: Path, *, runner: Runner = default_runner) -> str:
    tokens = r"contour|median|apex|index|coordinate|bounds|displacement|provider"
    pattern = rf'"[^"\n]*(?:{tokens})[^"\n]*"'

    def allowed(line: str) -> bool:
        path = line.split(":", 1)[0]
        approved_paths = {
            "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift",
            "BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift",
            "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift",
            "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPointProvider.swift",
        }
        approved_literals = (
            "contourCount:",
            "medianLineCount:",
            '"contourCount"',
            '"medianLineCount"',
            "observedFaceContourCount:",
            "observedFaceMedianLineCount:",
            "missing_face_contour",
        )
        return path in approved_paths and any(token in line for token in approved_literals)

    scan = classify_rg(
        root,
        pattern,
        (SOURCE_ROOT,),
        classifier=allowed,
        runner=runner,
    )
    return f"classified={scan.classified}; unclassified=0"


def check_supply_chain(root: Path, *, runner: Runner = default_runner) -> str:
    pattern = (
        r"URLSession|import Network|CloudKit|Alamofire|RevenueCat|https?://|"
        r"WebSocket|NWConnection|import CoreML|MLModel|"
        r"VNGeneratePersonSegmentationRequest|VNGenerateForegroundInstanceMaskRequest|"
        r"personSegmentation|semanticFaceModel"
    )
    scan = classify_rg(root, pattern, (SOURCE_ROOT,), runner=runner)
    tracked = git_lines(root, "ls-files", "--", "BeautySDK")
    untracked = git_lines(root, "ls-files", "--others", "--exclude-standard", "--", "BeautySDK")
    models = tuple(
        path for path in (*tracked, *untracked)
        if path.lower().endswith(MODEL_SUFFIXES)
    )
    if models:
        raise BoundaryCheckFailure("semantic model path")
    return f"source_unclassified={scan.unclassified}; models=0"


def check_imports(root: Path, *, runner: Runner = default_runner) -> str:
    pattern = r"^import (?:" + "|".join(INTERNAL_MODULES) + r")$"
    scan = classify_rg(
        root,
        pattern,
        ("BeautyDemo", RENDERER),
        runner=runner,
    )
    return f"unclassified={scan.unclassified}"


def check_renderer_scope(root: Path, *, runner: Runner = default_runner) -> str:
    pattern = r"\b(?:" + "|".join(NEW_FIELDS) + r")\b"
    scan = classify_rg(root, pattern, (RENDERER,), runner=runner)
    return f"renderer_field_matches={scan.matches}"


def check_artifacts(root: Path) -> str:
    for relative in GENERATED_ROOTS:
        if (root / relative).is_symlink():
            raise BoundaryCheckFailure("symlinked generated root")
    tracked = git_lines(root, "ls-files", "--", *GENERATED_ROOTS)
    staged = git_lines(root, "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS)
    untracked = git_lines(
        root, "ls-files", "--others", "--exclude-standard", "--", *GENERATED_ROOTS
    )
    not_ignored = 0
    for relative in GENERATED_ROOTS:
        completed = run_checked(
            ("git", "check-ignore", "-q", f"{relative}/representative.png"),
            root,
            expected=(0, 1),
        )
        not_ignored += int(completed.returncode == 1)
    if tracked or staged or untracked or not_ignored:
        raise BoundaryCheckFailure("generated output/gallery artifact escaped")
    return "tracked=0; staged=0; nonignored_untracked=0; ignored_roots=4/4"


def check_ledger(root: Path) -> str:
    ledger = read(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md")
    scoped = ("面部流畅", "太阳穴", "颧骨", "尖下巴")
    deferred = ("去双下巴", "去双下巴 Pro", "发际线")
    for label in (*scoped, *deferred):
        pattern = rf"^\| `脸型` \| {re.escape(label)} \| future \|"
        if len(re.findall(pattern, ledger, re.MULTILINE)) != 1:
            raise BoundaryCheckFailure("face ledger row drift")
    matrix = read(root, "docs/meitu-function-blueprint/FEATURE_MATRIX.md")
    branch = read(
        root,
        "docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md",
    )
    if len(re.findall(r"^\| Beauty shaping \| 脸型 \| partial \|", matrix, re.MULTILINE)) != 1:
        raise BoundaryCheckFailure("branch matrix drift")
    if "Status: `partial`" not in branch:
        raise BoundaryCheckFailure("face branch status drift")
    return "future_rows=7/7; branch_partial=2/2"


def _struct_fields(text: str, type_name: str) -> tuple[str, ...]:
    matches = re.findall(
        rf"struct\s+{re.escape(type_name)}\b[^{{]*\{{(.*?)\n\}}",
        text,
        re.DOTALL,
    )
    if len(matches) != 1:
        raise BoundaryCheckFailure("named emission type cardinality")
    return tuple(re.findall(r"^\s*let\s+([A-Za-z][A-Za-z0-9]*):", matches[0], re.MULTILINE))


def check_pre_implementation_absence(root: Path, *, runner: Runner = default_runner) -> str:
    pattern = (
        r"\b(?:FaceShapeWarpFieldEmissions|ChinWarpFieldEmissions)\b|"
        r"\bfunc\s+fieldEmissions\s*\("
    )
    scan = classify_rg(
        root,
        pattern,
        (FACE_PROVIDER, CHIN_PROVIDER),
        runner=runner,
    )
    return f"named_production_emissions={scan.matches}"


def check_named_ownership(root: Path) -> str:
    face = read(root, FACE_PROVIDER)
    chin = read(root, CHIN_PROVIDER)
    if _struct_fields(face, "FaceShapeWarpFieldEmissions") != FACE_FIELDS:
        raise BoundaryCheckFailure("face named ownership/order drift")
    if _struct_fields(chin, "ChinWarpFieldEmissions") != CHIN_FIELDS:
        raise BoundaryCheckFailure("chin named ownership/order drift")
    if len(re.findall(r"\bfunc\s+fieldEmissions\s*\(", face)) != 1:
        raise BoundaryCheckFailure("face fieldEmissions cardinality")
    if len(re.findall(r"\bfunc\s+fieldEmissions\s*\(", chin)) != 1:
        raise BoundaryCheckFailure("chin fieldEmissions cardinality")
    return "face_fields=7/7; chin_fields=2/2; methods=2/2"


def check_convergence(root: Path) -> str:
    matches = re.findall(r"for\s+_\s+in\s+0\.\.<37\b", read(root, RESOLVER))
    if len(matches) != 1:
        raise BoundaryCheckFailure("exact 37-removal convergence missing or duplicated")
    scan = classify_rg(
        root,
        r"for\s+_\s+in\s+0\.\.<37\b",
        (SOURCE_ROOT,),
        classifier=lambda line: line.split(":", 1)[0] == RESOLVER,
    )
    if scan.matches != 1:
        raise BoundaryCheckFailure("global convergence cardinality")
    return "exact_0_to_37=1"


def check_provisional_caps(root: Path) -> str:
    text = read(root, CAPS)
    if "provisional" not in text.lower():
        raise BoundaryCheckFailure("provisional cap wording missing")
    missing = sum(
        not re.search(rf"\b{re.escape(field)}\s*:\s*Float\s*=", text)
        for field in NEW_FIELDS
    )
    if missing:
        raise BoundaryCheckFailure("new cap declaration missing")
    return "provisional_wording=1; caps=4/4"


def check_predecessor_execution(
    root: Path,
    *,
    runner: Runner = default_runner,
) -> str:
    completed = run_checked(
        (sys.executable, str(PREDECESSOR)),
        root,
        runner=runner,
    )
    if "RESULT:" not in completed.stdout:
        raise BoundaryCheckFailure("predecessor checker omitted result")
    return "phase45_checker=pass"


def _base_operations(
    root: Path,
    *,
    pin_overrides: Mapping[str, object] | None = None,
    run_predecessor: bool = True,
) -> tuple[tuple[str, Callable[[], str]], ...]:
    overrides = dict(pin_overrides or {})
    operations: list[tuple[str, Callable[[], str]]] = [
        ("path/scope containment", lambda: check_paths(root)),
        ("pinned manifest/checker/resource/ledger boundary", lambda: check_pins(root, **overrides)),
        ("public/package/SPI geometry exposure", lambda: check_exposure(root)),
        ("Codable/persistence/cache/static support", lambda: check_storage(root)),
        ("raw geometry diagnostic literals", lambda: check_diagnostics(root)),
        ("dependency/resource/model/network scope", lambda: check_supply_chain(root)),
        ("Demo/renderer facade-only imports", lambda: check_imports(root)),
        ("renderer/downstream evidence scope", lambda: check_renderer_scope(root)),
        ("generated artifact containment", lambda: check_artifacts(root)),
        ("future-row and branch ledger boundary", lambda: check_ledger(root)),
    ]
    if run_predecessor:
        operations.append(
            ("Phase 45 live boundary", lambda: check_predecessor_execution(root))
        )
    return tuple(operations)


def pre_implementation_checks(root: Path) -> list[Result]:
    operations = _base_operations(root) + (
        ("named production emissions absent", lambda: check_pre_implementation_absence(root)),
    )
    return [result(name, operation) for name, operation in operations]


def live_checks(root: Path) -> list[Result]:
    operations = _base_operations(root) + (
        ("exact nine-field named ownership", lambda: check_named_ownership(root)),
        ("exact 37-removal convergence", lambda: check_convergence(root)),
        ("provisional cap wording", lambda: check_provisional_caps(root)),
    )
    return [result(name, operation) for name, operation in operations]


def write_fixture(root: Path, relative: str | Path, text: str) -> None:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def fixture_git(root: Path, *arguments: str) -> subprocess.CompletedProcess[str]:
    environment = os.environ.copy()
    environment.update(
        {
            "GIT_AUTHOR_NAME": "Phase 46 Self Test",
            "GIT_AUTHOR_EMAIL": "phase46@example.invalid",
            "GIT_COMMITTER_NAME": "Phase 46 Self Test",
            "GIT_COMMITTER_EMAIL": "phase46@example.invalid",
        }
    )
    return subprocess.run(
        ("git", *arguments),
        cwd=root,
        env=environment,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def build_fixture(root: Path) -> dict[str, object]:
    fixture_git(root, "init", "-q")
    write_fixture(root, "BeautySDK/Package.swift", "// local targets only\n")
    write_fixture(root, PREDECESSOR, "print('RESULT: 1/1 checks passed')\n")
    write_fixture(
        root,
        "BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift",
        "public struct BeautyResourceManifest {}\n",
    )
    write_fixture(root, "BeautySDK/Sources/BeautyResources/Resources/manifest.json", "{}\n")
    write_fixture(
        root,
        "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
        "\n".join(f"public var {field}: Float" for field in NEW_FIELDS) + "\n",
    )
    write_fixture(
        root,
        "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift",
        "package struct BeautyObservedFaceSupport {}\n"
        'let description = "contourCount: 11, medianLineCount: 3"\n',
    )
    write_fixture(
        root,
        "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift",
        "struct WarpControlPoint {}\n"
        "struct BeautyFaceSemanticSupport {}\n"
        "struct FaceGeometry {}\n",
    )
    write_fixture(
        root,
        FACE_PROVIDER,
        "struct FaceShapeWarpFieldEmissions {\n"
        + "".join(f"    let {field}: [WarpControlPoint]\n" for field in FACE_FIELDS)
        + "}\n"
        "struct FaceShapeWarpProvider {\n"
        "    func fieldEmissions() -> FaceShapeWarpFieldEmissions { fatalError() }\n"
        "}\n",
    )
    write_fixture(
        root,
        CHIN_PROVIDER,
        "struct ChinWarpFieldEmissions {\n"
        + "".join(f"    let {field}: [WarpControlPoint]\n" for field in CHIN_FIELDS)
        + "}\n"
        "struct ChinWarpProvider {\n"
        "    func fieldEmissions() -> ChinWarpFieldEmissions { fatalError() }\n"
        "}\n",
    )
    write_fixture(root, RESOLVER, "for _ in 0..<37 { break }\n")
    write_fixture(
        root,
        CAPS,
        "// Provisional Phase 46 caps; Phase 48 owns final calibration.\n"
        + "".join(f"static let {field}: Float = 0.25\n" for field in NEW_FIELDS),
    )
    write_fixture(root, "BeautySDK/Sources/BeautyExampleRenderer/main.swift", "import BeautySDK\n")
    write_fixture(root, "BeautyDemo/App.swift", "import BeautySDK\n")
    ledger_rows = "".join(
        f"| `脸型` | {field} | future | None. | Deferred. |\n"
        for field in ("面部流畅", "太阳穴", "颧骨", "尖下巴", "去双下巴", "去双下巴 Pro", "发际线")
    )
    write_fixture(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", ledger_rows)
    write_fixture(
        root,
        "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
        "| Beauty shaping | 脸型 | partial | BeautyEffects |\n",
    )
    write_fixture(
        root,
        "docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md",
        "Status: `partial`\n",
    )
    write_fixture(
        root,
        ".gitignore",
        "".join(f"{relative}/\n" for relative in GENERATED_ROOTS),
    )
    fixture_git(root, "add", ".")
    fixture_git(root, "commit", "-q", "-m", "fixture")
    pinned_paths = {
        path: hash_file(root, path)
        for path in PINNED_FILE_HASHES
    }
    resource_paths = "\n".join(git_lines(root, "ls-files", "--", RESOURCE_ROOT)) + "\n"
    return {
        "package_hash": hash_file(root, "BeautySDK/Package.swift"),
        "predecessor_hash": hash_file(root, PREDECESSOR),
        "pinned_hashes": pinned_paths,
        "resource_inventory_hash": hashlib.sha256(resource_paths.encode()).hexdigest(),
    }


def self_test() -> list[Result]:
    results: list[Result] = []

    def fake(code: int, stdout: str = "", stderr: str = "") -> Runner:
        return lambda command, cwd: subprocess.CompletedProcess(command, code, stdout, stderr)

    search_cases = (
        ("rg no-match", lambda: classify_rg(Path("."), "x", ("fixture",), runner=fake(1)).state == "no-match"),
        ("rg classified", lambda: classify_rg(
            Path("."), "x", ("fixture",),
            classifier=lambda line: line == "fixture:1:x",
            runner=fake(0, "fixture:1:x\n"),
        ).classified == 1),
        ("rg unclassified", lambda: _must_fail(
            lambda: classify_rg(Path("."), "x", ("fixture",), runner=fake(0, "fixture:1:x\n"))
        )),
        ("rg exit 2", lambda: _must_fail(
            lambda: classify_rg(Path("."), "x", ("fixture",), runner=fake(2, stderr="boom"))
        )),
        ("command missing", lambda: _must_fail(
            lambda: run_checked(("missing",), Path("."), runner=fake(127, stderr="missing"))
        )),
        ("runner exception", lambda: _must_fail(
            lambda: run_checked(
                ("boom",),
                Path("."),
                runner=lambda _command, _cwd: (_ for _ in ()).throw(OSError("boom")),
            )
        )),
    )
    for name, operation in search_cases:
        results.append(Result(f"self-test {name}", bool(operation()), "rejected_or_classified=1"))

    with tempfile.TemporaryDirectory(prefix="phase46-path-") as temporary:
        root = Path(temporary)
        results.append(Result(
            "self-test missing path",
            _must_fail(lambda: safe_path(root, "missing")),
            "missing_rejected=1",
        ))
        outside = root.parent / f"{root.name}-outside"
        outside.write_text("outside", encoding="utf-8")
        (root / "escape").symlink_to(outside)
        results.append(Result(
            "self-test repository escape",
            _must_fail(lambda: safe_path(root, "escape")),
            "escape_rejected=1",
        ))
        outside.unlink(missing_ok=True)

    if not shutil.which("git") or not shutil.which("rg"):
        results.append(Result("self-test fixture tools", False, "git_or_rg_missing=1"))
        return results

    mutations: tuple[tuple[str, str, str, Callable[[Path], str]], ...] = (
        ("package pin", "BeautySDK/Package.swift", "// dependency mutation\n", check_pins),
        (
            "exposure",
            "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift",
            "package struct WarpControlPoint {}\n",
            check_exposure,
        ),
        (
            "persistence",
            "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift",
            "let saved = UserDefaults.standard.set(observedFaceSupport, forKey: \"face\")\n",
            check_storage,
        ),
        (
            "diagnostic",
            "BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift",
            "let message = \"provider contour apex index displacement\"\n",
            check_diagnostics,
        ),
        (
            "network",
            "BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift",
            "let session = URLSession.shared\n",
            check_supply_chain,
        ),
        (
            "Demo import",
            "BeautyDemo/App.swift",
            "import BeautyEffects\n",
            check_imports,
        ),
        (
            "renderer case",
            "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
            "let caseName = \"chinTaper\"\n",
            check_renderer_scope,
        ),
        (
            "ledger row",
            "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
            "| `脸型` | 面部流畅 | implemented | borrowed |\n",
            check_ledger,
        ),
        (
            "named ownership",
            FACE_PROVIDER,
            "struct FaceShapeWarpFieldEmissions {\n    let faceSlim: [WarpControlPoint]\n}\n"
            "struct FaceShapeWarpProvider { func fieldEmissions() {} }\n",
            check_named_ownership,
        ),
        ("convergence", RESOLVER, "for _ in 0..<28 { break }\n", check_convergence),
        (
            "provisional wording",
            CAPS,
            "".join(f"static let {field}: Float = 0.25\n" for field in NEW_FIELDS),
            check_provisional_caps,
        ),
    )
    for name, relative, mutation, checker in mutations:
        with tempfile.TemporaryDirectory(prefix=f"phase46-{name.replace(' ', '-')}-") as temporary:
            root = Path(temporary)
            pins = build_fixture(root)
            path = root / relative
            path.write_text(mutation, encoding="utf-8")
            if checker is check_pins:
                passed = _must_fail(lambda: checker(root, **pins))
            else:
                passed = _must_fail(lambda: checker(root))
            results.append(Result(f"self-test {name} mutation", passed, "mutation_rejected=1"))

    with tempfile.TemporaryDirectory(prefix="phase46-model-") as temporary:
        root = Path(temporary)
        build_fixture(root)
        write_fixture(root, "BeautySDK/Sources/Models/face.mlmodel", "fixture")
        results.append(Result(
            "self-test model mutation",
            _must_fail(lambda: check_supply_chain(root)),
            "model_rejected=1",
        ))

    with tempfile.TemporaryDirectory(prefix="phase46-artifact-") as temporary:
        root = Path(temporary)
        build_fixture(root)
        write_fixture(root, "example-images/output/tracked.png", "fixture")
        fixture_git(root, "add", "-f", "example-images/output/tracked.png")
        results.append(Result(
            "self-test artifact mutation",
            _must_fail(lambda: check_artifacts(root)),
            "artifact_rejected=1",
        ))

    with tempfile.TemporaryDirectory(prefix="phase46-positive-") as temporary:
        root = Path(temporary)
        pins = build_fixture(root)
        checks = [
            result(name, operation)
            for name, operation in _base_operations(
                root,
                pin_overrides=pins,
                run_predecessor=False,
            )
        ] + [
            result("ownership", lambda: check_named_ownership(root)),
            result("convergence", lambda: check_convergence(root)),
            result("caps", lambda: check_provisional_caps(root)),
        ]
        results.append(Result(
            "self-test clean live corpus",
            all(item.ok for item in checks),
            f"clean_checks={sum(item.ok for item in checks)}/{len(checks)}",
        ))

    predecessor_errors = (
        ("predecessor exit", fake(2, stderr="boom")),
        ("predecessor missing result", fake(0, stdout="clean\n")),
    )
    for name, runner in predecessor_errors:
        results.append(Result(
            f"self-test {name}",
            _must_fail(lambda runner=runner: check_predecessor_execution(Path("."), runner=runner)),
            "unexpected_predecessor_result_rejected=1",
        ))
    return results


def _must_fail(operation: Callable[[], object]) -> bool:
    try:
        operation()
    except Exception:
        return True
    return False


def print_results(mode: str, results: Sequence[Result]) -> int:
    print(f"Phase 46 face-geometry boundary checker — mode={mode}")
    for item in results:
        print(f"{'PASS' if item.ok else 'FAIL'}: {item.name}: {item.detail}")
    passed = sum(item.ok for item in results)
    print(f"RESULT: {passed}/{len(results)} checks passed")
    return 0 if results and passed == len(results) else 1


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--pre-implementation", action="store_true")
    parser.add_argument("--repo-root", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    if args.self_test:
        return print_results("self-test", self_test())
    try:
        root = locate_repo(args.repo_root or Path(__file__).parent)
    except Exception as error:
        return print_results(
            "startup",
            [Result("repository discovery", False, f"blocking_error={type(error).__name__}")],
        )
    if args.pre_implementation:
        return print_results("pre-implementation", pre_implementation_checks(root))
    return print_results("live", live_checks(root))


if __name__ == "__main__":
    sys.exit(main())
