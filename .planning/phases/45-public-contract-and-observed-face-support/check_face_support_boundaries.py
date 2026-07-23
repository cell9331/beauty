#!/usr/bin/env python3
"""Fail-closed Phase 45 public-contract and observed-face boundary gate.

Exit zero means every selected check ran and passed. Search commands classify
rg status 0 as matches to classify, status 1 as a clean no-match, and every
other status (including a missing executable) as a blocking tool error.
Matched source text and raw coordinate-bearing payloads are never printed.
"""

from __future__ import annotations

import argparse
import dataclasses
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, Iterable, Mapping, Sequence


BASELINE_COMMIT = "9aedd6b40a7c033ac86cea2c75e06bac138cf9ef"
PHASE_DIR = Path(".planning/phases/45-public-contract-and-observed-face-support")
SOURCE_ROOT = "BeautySDK/Sources"
FACE_FIELDS = (
    "faceContourSmooth",
    "templeFullness",
    "cheekboneSlim",
    "chinTaper",
)
PRESET_HASHES = {
    "BeautySDK/Sources/BeautyResources/Resources/Presets/clear.json":
        "58327c8ef8cc8323d4a6e4d98754d8c9bf797b348804ca2a308c4c39e00856f8",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/id-photo-natural.json":
        "d6d2d3e5872ae0aa25823c4d76e07057ecdfa336818cd116509627995941c609",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/male-natural.json":
        "1c6e632e8740602fa662c42e41cf9709eec29b3138bf58df43fad40d8b5d0c08",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/natural.json":
        "bd102ec3643f1625d561af66fd0e7fb67c33fe5061720600907ed3fd931a08da",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/refined.json":
        "67f238fddf8d9dc08bc8b24121af25d11f9caf8a85b905cf83a47b0dff675722",
}
GENERATED_ROOTS = (
    "example-images/output",
    "example-images/gallery",
    "example-images/.gallery-staging",
    "example-images/.gallery-quarantine",
)
INTERNAL_MODULES = (
    "BeautyCore",
    "BeautyDetection",
    "BeautyEffects",
    "BeautyRender",
    "BeautyResources",
)
FORBIDDEN_MODEL_SUFFIXES = (
    ".mlmodel",
    ".mlmodelc",
    ".mlpackage",
    ".tflite",
    ".onnx",
)
RESOURCE_MANIFEST_PATHS = (
    "BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift",
    "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
)


@dataclasses.dataclass(frozen=True)
class Result:
    name: str
    ok: bool
    detail: str


@dataclasses.dataclass(frozen=True)
class SearchResult:
    state: str  # matches, no-match, error
    lines: tuple[str, ...]
    detail: str


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


def run_search(
    command: Sequence[str],
    cwd: Path,
    runner: Runner = default_runner,
) -> SearchResult:
    """Classify rg status 0/1/>1 without treating tool failures as clean."""
    try:
        completed = runner(command, cwd)
    except Exception as error:
        return SearchResult("error", (), f"runner exception: {type(error).__name__}")
    if completed.returncode == 0:
        lines = tuple(line for line in completed.stdout.splitlines() if line.strip())
        return SearchResult("matches", lines, f"matches={len(lines)}")
    if completed.returncode == 1:
        return SearchResult("no-match", (), "matches=0")
    diagnostic = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
    return SearchResult("error", (), f"exit={completed.returncode}; diagnostic={diagnostic[:160]}")


def locate_repo(start: Path) -> Path:
    resolved = start.resolve(strict=True)
    for candidate in (resolved, *resolved.parents):
        if (candidate / ".git").exists() and (candidate / "BeautySDK/Package.swift").is_file():
            return candidate
    raise RuntimeError("repository root not found")


def safe_path(root: Path, relative: str, *, directory: bool = False) -> Path:
    relative_path = Path(relative)
    if relative_path.is_absolute() or ".." in relative_path.parts:
        raise RuntimeError(f"unsafe repository-relative path: {relative}")
    resolved_root = root.resolve(strict=True)
    candidate = root / relative_path
    current = root
    for component in relative_path.parts:
        current = current / component
        if current.is_symlink():
            raise RuntimeError(f"symlinked required path rejected: {relative}")
    try:
        resolved = candidate.resolve(strict=True)
    except (FileNotFoundError, RuntimeError) as error:
        raise RuntimeError(f"missing or unresolvable required path: {relative}") from error
    if resolved == resolved_root or resolved_root not in resolved.parents:
        raise RuntimeError(f"required path escapes repository: {relative}")
    if directory and not candidate.is_dir():
        raise RuntimeError(f"required directory is not a directory: {relative}")
    if not directory and not candidate.is_file():
        raise RuntimeError(f"required file is not a regular file: {relative}")
    return candidate


def read(root: Path, relative: str) -> str:
    return safe_path(root, relative).read_text(encoding="utf-8")


def result_from_exception(name: str, operation: Callable[[], Result]) -> Result:
    try:
        return operation()
    except Exception as error:
        return Result(name, False, f"blocking_error={type(error).__name__}")


def git_lines(root: Path, command: Sequence[str]) -> tuple[bool, tuple[str, ...], str]:
    completed = default_runner(command, root)
    if completed.returncode != 0:
        detail = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
        return False, (), f"exit={completed.returncode}; diagnostic={detail[:160]}"
    lines = tuple(line for line in completed.stdout.splitlines() if line.strip())
    return True, lines, ""


def rg_scan(
    root: Path,
    name: str,
    pattern: str,
    scopes: Iterable[str],
    classifier: Callable[[str], bool] | None = None,
    runner: Runner = default_runner,
) -> Result:
    outcome = run_search(
        ["rg", "-n", "--no-heading", "--color", "never", pattern, *scopes],
        root,
        runner,
    )
    if outcome.state == "error":
        return Result(name, False, f"scan_error; {outcome.detail}")
    if outcome.state == "no-match":
        return Result(name, True, "classified=0; unclassified=0")
    allowed = classifier or (lambda _line: False)
    classified = sum(1 for line in outcome.lines if allowed(line))
    unclassified = len(outcome.lines) - classified
    return Result(
        name,
        unclassified == 0,
        f"classified={classified}; unclassified={unclassified}",
    )


def _match_path(line: str) -> str:
    return line.split(":", 1)[0]


def check_paths(root: Path) -> Result:
    files = (
        "BeautySDK/Package.swift",
        "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
        "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift",
        "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift",
        "BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift",
        "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
        str(PHASE_DIR / "check_face_support_boundaries.py"),
        ".gitignore",
        *RESOURCE_MANIFEST_PATHS,
        *PRESET_HASHES.keys(),
    )
    directories = (
        SOURCE_ROOT,
        "BeautyDemo",
        "BeautySDK/Sources/BeautyCore",
        "BeautySDK/Sources/BeautyDetection",
        "BeautySDK/Sources/BeautyEffects",
        "BeautySDK/Sources/BeautyRender",
        "BeautySDK/Sources/BeautyResources",
        "BeautySDK/Sources/BeautySDK",
        "BeautySDK/Sources/BeautyExampleRenderer",
    )
    for relative in files:
        safe_path(root, relative)
    for relative in directories:
        safe_path(root, relative, directory=True)
    return Result("path/scope containment", True, f"files={len(files)}; source_roots={len(directories)}")


def check_baseline(root: Path, baseline: str = BASELINE_COMMIT) -> Result:
    exists = default_runner(["git", "cat-file", "-e", f"{baseline}^{{commit}}"], root)
    if exists.returncode != 0:
        return Result("manifest/Demo baseline", False, "baseline_missing=1")
    ok, changed, error = git_lines(
        root,
        ["git", "diff", "--name-only", baseline, "--", "BeautySDK/Package.swift", "BeautyDemo"],
    )
    other_ok, untracked, other_error = git_lines(
        root,
        ["git", "ls-files", "--others", "--exclude-standard", "--", "BeautyDemo"],
    )
    passed = ok and other_ok and not changed and not untracked
    return Result(
        "manifest/Demo baseline",
        passed,
        f"baseline={baseline}; changed={len(changed)}; untracked={len(untracked)}; errors={int(bool(error or other_error))}",
    )


def check_public_inventory(root: Path) -> Result:
    text = read(root, "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
    fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):\s*([^\n]+)$", text, re.MULTILINE)
    names = [name for name, _type_name in fields]
    numeric = [name for name, type_name in fields if type_name.strip() == "Float"]
    counts = {field: names.count(field) for field in FACE_FIELDS}
    ok = (
        len(fields) == 52
        and len(numeric) == 51
        and names.count("filterId") == 1
        and all(count == 1 for count in counts.values())
    )
    return Result(
        "public BeautyParameters inventory",
        ok,
        f"stored={len(fields)}; numeric={len(numeric)}; filterId={names.count('filterId')}; face_fields={sum(count == 1 for count in counts.values())}/4",
    )


def check_public_geometry(root: Path, runner: Runner = default_runner) -> Result:
    pattern = (
        r"(?:public|@_spi).*?(?:BeautyObservedFaceSupport|BeautyFaceSemanticSupport|"
        r"observedFaceSupport|ObservedFaceSupport|FaceSemanticSupport|"
        r"(?:faceContour|medianLine).*(?:CoordinatePoint|SIMD[234]|coordinate|point|bounds|support))"
    )
    return rg_scan(root, "public/SPI face geometry", pattern, (SOURCE_ROOT,), runner=runner)


APPROVED_CODABLE_PATHS = {
    "BeautySDK/Sources/BeautyCore/Diagnostics/BeautyErrorContext.swift",
    "BeautySDK/Sources/BeautyCore/Diagnostics/BeautyValidationWarning.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyFilterDefinition.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyFrame.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyInputMetadata.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyLogLevel.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift",
    "BeautySDK/Sources/BeautyCore/Models/BeautyRenderQuality.swift",
    "BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift",
}


def check_codable_persistence(root: Path, runner: Runner = default_runner) -> Result:
    pattern = (
        r"Codable|Encodable|Decodable|UserDefaults|FileManager|CoreData|SwiftData|"
        r"NSKeyedArchiver|JSONEncoder|PropertyListEncoder|NSCache|\.write\("
    )

    def classified(line: str) -> bool:
        path = _match_path(line)
        if path in APPROVED_CODABLE_PATHS and re.search(r"\b(?:Codable|Encodable|Decodable)\b", line):
            return True
        if path == "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift":
            return (
                "intentionally has no Codable or diagnostic representation" in line
                or "has no Codable representation" in line
            )
        if path == "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift":
            return "never become part of the public or Codable surface" in line
        if path == "BeautySDK/Sources/BeautyExampleRenderer/main.swift":
            return "FileManager" in line or "png.write(to: destination, options: .atomic)" in line
        if path == "BeautySDK/Sources/BeautyRender/Shaders/Warp.metal":
            return "output.write(input.read(gid), gid);" in line
        return False

    return rg_scan(
        root,
        "Codable/persistence allowlist",
        pattern,
        (SOURCE_ROOT,),
        classified,
        runner,
    )


def check_diagnostics(root: Path, runner: Runner = default_runner) -> Result:
    raw = (
        r"BeautyObservedFaceSupport|BeautyFaceSemanticSupport|BeautyFaceObservation|"
        r"VisionDetectionObservation|observedFaceSupport|beautyFaceObservation|"
        r"faceObservation|visionDetectionObservation|detectionObservation|"
        r"(?:faceContour|medianLine).*(?:coordinate|point|bounds|support)|"
        r"(?:coordinate|point|bounds|support).*(?:faceContour|medianLine)"
    )
    sink = (
        r"print\(|debugPrint|Logger|os_log|message:|metrics\[|metadata:|"
        r"description|errorDescription|\\\(|String\((?:describing|reflecting):"
    )

    def classified(line: str) -> bool:
        path = _match_path(line)
        if path == "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift":
            return any(
                token in line
                for token in (
                    '"BeautyObservedFaceSupport(contourCount:',
                    '"observedFaceSupportAvailable:',
                    '"observedFaceContourCount:',
                    '"observedFaceMedianLineCount:',
                )
            )
        if path == "BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift":
            return any(
                token in line
                for token in (
                    '"observedFaceSupportAvailable:',
                    '"observedFaceContourCount:',
                    '"observedFaceMedianLineCount:',
                )
            )
        return False

    return rg_scan(
        root,
        "raw face diagnostic leakage",
        rf"(?:{sink}).*(?:{raw})|(?:{raw}).*(?:{sink})",
        (SOURCE_ROOT,),
        classified,
        runner=runner,
    )


def check_network(root: Path, runner: Runner = default_runner) -> Result:
    pattern = r"URLSession|import Network|CloudKit|Alamofire|RevenueCat|https?://|WebSocket|NWConnection"
    return rg_scan(root, "network/cloud active-source paths", pattern, (SOURCE_ROOT,), runner=runner)


def check_imports(root: Path, runner: Runner = default_runner) -> Result:
    pattern = r"^import (?:" + "|".join(INTERNAL_MODULES) + r")$"
    return rg_scan(
        root,
        "Demo/renderer facade-only imports",
        pattern,
        ("BeautyDemo", "BeautySDK/Sources/BeautyExampleRenderer"),
        runner=runner,
    )


def check_models(root: Path, runner: Runner = default_runner) -> Result:
    pattern = (
        r"import CoreML|MLModel|VNGeneratePersonSegmentationRequest|"
        r"VNGenerateForegroundInstanceMaskRequest|personSegmentation|semanticFaceModel"
    )
    source_result = rg_scan(
        root,
        "semantic model/resource active paths",
        pattern,
        (SOURCE_ROOT,),
        runner=runner,
    )
    tracked_ok, tracked, tracked_error = git_lines(root, ["git", "ls-files", "--", "BeautySDK"])
    other_ok, untracked, other_error = git_lines(
        root,
        ["git", "ls-files", "--others", "--exclude-standard", "--", "BeautySDK"],
    )
    models = tuple(
        path for path in (*tracked, *untracked)
        if path.lower().endswith(FORBIDDEN_MODEL_SUFFIXES)
    )
    errors = int(bool(tracked_error or other_error))
    ok = source_result.ok and tracked_ok and other_ok and not models and errors == 0
    return Result(
        "semantic model/resource prohibition",
        ok,
        f"source_unclassified={int(not source_result.ok)}; model_paths={len(models)}; errors={errors}",
    )


def check_resource_manifests(root: Path, baseline: str = BASELINE_COMMIT) -> Result:
    exists = default_runner(["git", "cat-file", "-e", f"{baseline}^{{commit}}"], root)
    if exists.returncode != 0:
        return Result("resource-manifest baseline", False, "baseline_missing=1")
    ok, changed, error = git_lines(
        root,
        ["git", "diff", "--name-only", baseline, "--", *RESOURCE_MANIFEST_PATHS],
    )
    tracked_ok, tracked, tracked_error = git_lines(
        root,
        ["git", "ls-files", "--", "BeautySDK"],
    )
    other_ok, untracked, other_error = git_lines(
        root,
        ["git", "ls-files", "--others", "--exclude-standard", "--", "BeautySDK"],
    )
    manifest_paths = tuple(
        path for path in (*tracked, *untracked)
        if "manifest" in Path(path).name.lower()
    )
    unexpected = tuple(path for path in manifest_paths if path not in RESOURCE_MANIFEST_PATHS)
    errors = int(bool(error or tracked_error or other_error))
    passed = (
        ok and tracked_ok and other_ok
        and not changed and not unexpected and errors == 0
        and set(RESOURCE_MANIFEST_PATHS).issubset(set(tracked))
    )
    return Result(
        "resource-manifest baseline",
        passed,
        f"changed={len(changed)}; unexpected={len(unexpected)}; required={sum(path in tracked for path in RESOURCE_MANIFEST_PATHS)}/{len(RESOURCE_MANIFEST_PATHS)}; errors={errors}",
    )


def check_semantic_scope(root: Path, runner: Runner = default_runner) -> Result:
    pattern = (
        r"\b(?:doubleChin|doubleChinPro|foreheadHairline|faceHairline|"
        r"removeDoubleChin|submentalSupport|hairlineSupport)\b|去双下巴|发际线"
    )
    source = rg_scan(
        root,
        "deferred semantic rows in active SDK",
        pattern,
        (SOURCE_ROOT,),
        runner=runner,
    )
    ledger = read(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md")
    required = ("| `脸型` | 去双下巴 | future |", "| `脸型` | 去双下巴 Pro | future |", "| `脸型` | 发际线 | future |")
    future_rows = sum(token in ledger for token in required)
    return Result(
        "deferred semantic-row scope",
        source.ok and future_rows == len(required),
        f"active_unclassified={int(not source.ok)}; future_rows={future_rows}/{len(required)}",
    )


def _iter_keys(value: object) -> Iterable[str]:
    if isinstance(value, dict):
        for key, nested in value.items():
            yield str(key)
            yield from _iter_keys(nested)
    elif isinstance(value, list):
        for nested in value:
            yield from _iter_keys(nested)


def check_presets(
    root: Path,
    expected_hashes: Mapping[str, str] = PRESET_HASHES,
) -> Result:
    hashes_ok = 0
    keys_absent = 0
    for relative, expected in expected_hashes.items():
        path = safe_path(root, relative)
        payload = path.read_bytes()
        if hashlib.sha256(payload).hexdigest() == expected:
            hashes_ok += 1
        parsed = json.loads(payload.decode("utf-8"))
        keys = set(_iter_keys(parsed))
        if not keys.intersection(FACE_FIELDS):
            keys_absent += 1
    count = len(expected_hashes)
    return Result(
        "bundled preset byte/key neutrality",
        count == 5 and hashes_ok == count and keys_absent == count,
        f"hashes={hashes_ok}/{count}; missing_new_keys={keys_absent}/{count}",
    )


def check_artifacts(root: Path) -> Result:
    for relative in GENERATED_ROOTS:
        if (root / relative).is_symlink():
            return Result("generated artifact containment", False, "symlinked_generated_root=1")
    tracked_ok, tracked, tracked_error = git_lines(root, ["git", "ls-files", "--", *GENERATED_ROOTS])
    staged_ok, staged, staged_error = git_lines(
        root,
        ["git", "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS],
    )
    other_ok, untracked, other_error = git_lines(
        root,
        ["git", "ls-files", "--others", "--exclude-standard", "--", *GENERATED_ROOTS],
    )
    not_ignored: list[str] = []
    ignore_errors = 0
    for relative in GENERATED_ROOTS:
        completed = default_runner(["git", "check-ignore", "-q", f"{relative}/representative.png"], root)
        if completed.returncode == 1:
            not_ignored.append(relative)
        elif completed.returncode != 0:
            ignore_errors += 1
    errors = int(bool(tracked_error or staged_error or other_error)) + ignore_errors
    ok = (
        tracked_ok and staged_ok and other_ok
        and not tracked and not staged and not untracked and not not_ignored and errors == 0
    )
    return Result(
        "generated artifact containment",
        ok,
        f"tracked={len(tracked)}; staged={len(staged)}; nonignored_untracked={len(untracked)}; representatives_not_ignored={len(not_ignored)}; errors={errors}",
    )


def live_checks(root: Path, baseline: str = BASELINE_COMMIT) -> list[Result]:
    operations = (
        ("path/scope containment", lambda: check_paths(root)),
        ("manifest/Demo baseline", lambda: check_baseline(root, baseline)),
        ("public BeautyParameters inventory", lambda: check_public_inventory(root)),
        ("public/SPI face geometry", lambda: check_public_geometry(root)),
        ("Codable/persistence allowlist", lambda: check_codable_persistence(root)),
        ("raw face diagnostic leakage", lambda: check_diagnostics(root)),
        ("network/cloud active-source paths", lambda: check_network(root)),
        ("Demo/renderer facade-only imports", lambda: check_imports(root)),
        ("semantic model/resource prohibition", lambda: check_models(root)),
        ("resource-manifest baseline", lambda: check_resource_manifests(root, baseline)),
        ("deferred semantic-row scope", lambda: check_semantic_scope(root)),
        ("bundled preset byte/key neutrality", lambda: check_presets(root)),
        ("generated artifact containment", lambda: check_artifacts(root)),
    )
    return [result_from_exception(name, operation) for name, operation in operations]


def write_fixture(root: Path, relative: str, text: str) -> None:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def git(root: Path, *args: str) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env.update(
        {
            "GIT_AUTHOR_NAME": "Phase 45 Self Test",
            "GIT_AUTHOR_EMAIL": "phase45@example.invalid",
            "GIT_COMMITTER_NAME": "Phase 45 Self Test",
            "GIT_COMMITTER_EMAIL": "phase45@example.invalid",
        }
    )
    return subprocess.run(
        ["git", *args],
        cwd=root,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def build_baseline_fixture(root: Path) -> str:
    git(root, "init", "-q")
    write_fixture(root, "BeautySDK/Package.swift", "// fixture manifest\n")
    write_fixture(root, "BeautyDemo/App.swift", "// fixture Demo\n")
    write_fixture(
        root,
        "BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift",
        "// fixture resource manifest type\n",
    )
    write_fixture(
        root,
        "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
        "{}\n",
    )
    write_fixture(
        root,
        ".gitignore",
        "\n".join(f"{relative}/" for relative in GENERATED_ROOTS) + "\n",
    )
    git(
        root,
        "add",
        "BeautySDK/Package.swift",
        "BeautyDemo/App.swift",
        ".gitignore",
        *RESOURCE_MANIFEST_PATHS,
    )
    committed = git(root, "commit", "-q", "-m", "fixture baseline")
    if committed.returncode != 0:
        raise RuntimeError("could not create baseline fixture")
    resolved = git(root, "rev-parse", "HEAD")
    if resolved.returncode != 0:
        raise RuntimeError("could not resolve baseline fixture")
    return resolved.stdout.strip()


def build_source_fixture(root: Path) -> Path:
    source = "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift"
    write_fixture(
        root,
        source,
        "package struct BeautyObservedFaceSupport: Equatable, Sendable {}\n"
        "/// This value intentionally has no Codable or diagnostic representation.\n",
    )
    write_fixture(root, "BeautySDK/Sources/BeautyExampleRenderer/main.swift", "// facade-only fixture\n")
    write_fixture(root, "BeautyDemo/App.swift", "import BeautySDK\n")
    return root / source


def build_preset_fixture(root: Path) -> dict[str, str]:
    expected: dict[str, str] = {}
    for index, relative in enumerate(PRESET_HASHES):
        payload = json.dumps({"id": f"preset-{index}", "parameters": {"faceSlim": 0.1}}, sort_keys=True) + "\n"
        write_fixture(root, relative, payload)
        expected[relative] = hashlib.sha256(payload.encode("utf-8")).hexdigest()
    return expected


def self_test() -> list[Result]:
    results: list[Result] = []

    def fake(code: int, stdout: str = "", stderr: str = "") -> Runner:
        return lambda command, cwd: subprocess.CompletedProcess(command, code, stdout, stderr)

    states = (
        ("no-match", run_search(("rg", "x"), Path("."), fake(1)).state == "no-match"),
        ("match", run_search(("rg", "x"), Path("."), fake(0, "fixture:1:guard\n")).state == "matches"),
        ("exit 2", run_search(("rg", "x"), Path("."), fake(2, stderr="boom")).state == "error"),
        ("tool missing", run_search(("rg", "x"), Path("."), fake(127, stderr="missing")).state == "error"),
        (
            "runner exception",
            run_search(
                ("rg", "x"),
                Path("."),
                lambda _c, _d: (_ for _ in ()).throw(OSError("missing")),
            ).state == "error",
        ),
    )
    for name, passed in states:
        results.append(Result(f"self-test search {name}", passed, "state_classified=1"))

    allowed = rg_scan(
        Path("."),
        "fixture classified",
        "guard",
        ("fixture",),
        classifier=lambda line: line == "fixture:1:guard",
        runner=fake(0, "fixture:1:guard\n"),
    )
    rejected = rg_scan(
        Path("."),
        "fixture unclassified",
        "guard",
        ("fixture",),
        runner=fake(0, "fixture:1:guard\n"),
    )
    scan_error = rg_scan(Path("."), "fixture error", "guard", ("fixture",), runner=fake(2, stderr="boom"))
    results.extend(
        (
            Result("self-test classified allowlist", allowed.ok, "known_literal_accepted=1"),
            Result("self-test unclassified failure", not rejected.ok, "unknown_literal_rejected=1"),
            Result("self-test scan error failure", not scan_error.ok, "tool_error_rejected=1"),
        )
    )

    with tempfile.TemporaryDirectory(prefix="phase45-path-") as temporary:
        root = Path(temporary)
        root.resolve(strict=True)
        try:
            safe_path(root, "missing")
            missing = False
        except RuntimeError:
            missing = True
        outside = root.parent / f"{root.name}-outside.txt"
        outside.write_text("outside", encoding="utf-8")
        (root / "escape").symlink_to(outside)
        try:
            safe_path(root, "escape")
            escaped = False
        except RuntimeError:
            escaped = True
        outside.unlink(missing_ok=True)
        results.extend(
            (
                Result("self-test missing path failure", missing, "missing_path_rejected=1"),
                Result("self-test path escape failure", escaped, "escaping_symlink_rejected=1"),
            )
        )

    if not shutil.which("git"):
        results.append(Result("self-test git fixtures", False, "git_missing=1"))
    else:
        with tempfile.TemporaryDirectory(prefix="phase45-baseline-") as temporary:
            root = Path(temporary)
            baseline = build_baseline_fixture(root)
            results.append(Result("self-test baseline positive", check_baseline(root, baseline).ok, "clean_baseline_accepted=1"))
            manifest = root / "BeautySDK/Package.swift"
            manifest.write_text("// dependency mutation\n", encoding="utf-8")
            results.append(Result("self-test dependency baseline failure", not check_baseline(root, baseline).ok, "manifest_mutation_rejected=1"))
            manifest.write_text("// fixture manifest\n", encoding="utf-8")
            demo = root / "BeautyDemo/App.swift"
            demo.write_text("// Demo mutation\n", encoding="utf-8")
            results.append(Result("self-test Demo baseline failure", not check_baseline(root, baseline).ok, "demo_mutation_rejected=1"))
            demo.write_text("// fixture Demo\n", encoding="utf-8")
            write_fixture(root, "BeautyDemo/Untracked.swift", "// untracked Demo mutation\n")
            results.append(Result("self-test untracked Demo failure", not check_baseline(root, baseline).ok, "untracked_demo_rejected=1"))

        with tempfile.TemporaryDirectory(prefix="phase45-preset-") as temporary:
            root = Path(temporary)
            expected = build_preset_fixture(root)
            results.append(Result("self-test preset positive", check_presets(root, expected).ok, "clean_presets_accepted=1"))
            first = next(iter(expected))
            path = root / first
            path.write_text(path.read_text(encoding="utf-8") + " ", encoding="utf-8")
            results.append(Result("self-test preset hash failure", not check_presets(root, expected).ok, "hash_mutation_rejected=1"))
            expected = build_preset_fixture(root)
            parsed = json.loads((root / first).read_text(encoding="utf-8"))
            parsed["parameters"]["chinTaper"] = 0
            (root / first).write_text(json.dumps(parsed) + "\n", encoding="utf-8")
            expected[first] = hashlib.sha256((root / first).read_bytes()).hexdigest()
            results.append(Result("self-test preset key failure", not check_presets(root, expected).ok, "key_mutation_rejected=1"))

        with tempfile.TemporaryDirectory(prefix="phase45-model-") as temporary:
            root = Path(temporary)
            baseline = build_baseline_fixture(root)
            build_source_fixture(root)
            results.append(Result("self-test model scan positive", check_models(root).ok, "clean_model_scope_accepted=1"))
            write_fixture(root, "BeautySDK/Sources/Models/face.mlmodel", "fixture")
            results.append(Result("self-test model path failure", not check_models(root).ok, "model_path_rejected=1"))
            (root / "BeautySDK/Sources/Models/face.mlmodel").unlink()
            results.append(Result("self-test resource manifest positive", check_resource_manifests(root, baseline).ok, "clean_manifests_accepted=1"))
            manifest = root / RESOURCE_MANIFEST_PATHS[1]
            manifest.write_text('{"resource": "mutation"}\n', encoding="utf-8")
            results.append(Result("self-test resource manifest drift failure", not check_resource_manifests(root, baseline).ok, "manifest_drift_rejected=1"))
            manifest.write_text("{}\n", encoding="utf-8")
            write_fixture(root, "BeautySDK/Sources/BeautyResources/Resources/semantic-manifest.json", "{}\n")
            results.append(Result("self-test resource manifest addition failure", not check_resource_manifests(root, baseline).ok, "manifest_addition_rejected=1"))

        with tempfile.TemporaryDirectory(prefix="phase45-artifact-") as temporary:
            root = Path(temporary)
            build_baseline_fixture(root)
            results.append(Result("self-test artifact positive", check_artifacts(root).ok, "ignored_roots_accepted=1"))
            tracked_path = "example-images/output/tracked.png"
            write_fixture(root, tracked_path, "fixture")
            git(root, "add", "-f", tracked_path)
            git(root, "commit", "-q", "-m", "tracked artifact")
            results.append(Result("self-test tracked artifact failure", not check_artifacts(root).ok, "tracked_artifact_rejected=1"))

    if not shutil.which("rg"):
        results.append(Result("self-test source mutation fixtures", False, "rg_missing=1"))
    else:
        with tempfile.TemporaryDirectory(prefix="phase45-source-") as temporary:
            root = Path(temporary)
            build_baseline_fixture(root)
            source = build_source_fixture(root)
            clean_checks = (
                check_public_geometry(root),
                check_codable_persistence(root),
                check_diagnostics(root),
                check_network(root),
                check_imports(root),
                check_models(root),
            )
            results.append(
                Result(
                    "self-test source scans positive",
                    all(item.ok for item in clean_checks),
                    f"clean_scans={sum(item.ok for item in clean_checks)}/{len(clean_checks)}",
                )
            )
            mutations: tuple[tuple[str, str, Callable[[Path], Result]], ...] = (
                ("public support", "public struct BeautyObservedFaceSupport {}\n", check_public_geometry),
                ("Codable support", "package struct FaceSupport: Codable {}\n", check_codable_persistence),
                ("persistence", "let saved = UserDefaults.standard.set(observedFaceSupport, forKey: \"face\")\n", check_codable_persistence),
                ("diagnostic", "print(observedFaceSupport)\n", check_diagnostics),
                ("carrier interpolation", "let leaked = \"\\(faceObservation)\"\n", check_diagnostics),
                ("carrier logging", "debugPrint(visionDetectionObservation)\n", check_diagnostics),
                ("network", "let task = URLSession.shared\n", check_network),
                ("model source", "import CoreML\n", check_models),
            )
            original = source.read_text(encoding="utf-8")
            for name, mutation, checker in mutations:
                source.write_text(original + mutation, encoding="utf-8")
                results.append(Result(f"self-test {name} mutation failure", not checker(root).ok, "mutation_rejected=1"))
            source.write_text(original, encoding="utf-8")
            demo = root / "BeautyDemo/App.swift"
            demo.write_text("import BeautyDetection\n", encoding="utf-8")
            results.append(Result("self-test Demo import mutation failure", not check_imports(root).ok, "internal_import_rejected=1"))

        with tempfile.TemporaryDirectory(prefix="phase45-semantic-") as temporary:
            root = Path(temporary)
            build_source_fixture(root)
            write_fixture(
                root,
                "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
                "| `脸型` | 去双下巴 | future |\n"
                "| `脸型` | 去双下巴 Pro | future |\n"
                "| `脸型` | 发际线 | future |\n",
            )
            results.append(Result("self-test semantic scope positive", check_semantic_scope(root).ok, "future_rows_accepted=1"))
            source = root / "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift"
            source.write_text(source.read_text(encoding="utf-8") + "let doubleChin = true\n", encoding="utf-8")
            results.append(Result("self-test semantic scope failure", not check_semantic_scope(root).ok, "semantic_row_rejected=1"))

    return results


def print_results(mode: str, results: Sequence[Result]) -> int:
    print(f"Phase 45 face-support boundary checker — mode={mode}")
    for result in results:
        print(f"{'PASS' if result.ok else 'FAIL'}: {result.name}: {result.detail}")
    passed = sum(result.ok for result in results)
    print(f"RESULT: {passed}/{len(results)} checks passed")
    return 0 if results and passed == len(results) else 1


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true", help="run deterministic positive and adversarial fixtures")
    parser.add_argument("--repo-root", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    if args.self_test:
        return print_results("self-test", self_test())
    try:
        root = locate_repo(args.repo_root or Path(__file__).parent)
    except Exception as error:
        return print_results("startup", [Result("repository discovery", False, f"blocking_error={type(error).__name__}")])
    return print_results("live", live_checks(root))


if __name__ == "__main__":
    sys.exit(main())
