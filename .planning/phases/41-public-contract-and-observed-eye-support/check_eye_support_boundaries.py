#!/usr/bin/env python3
"""Fail-closed Phase 41 public-contract and observed-eye boundary gate.

Exit zero means every selected check ran and passed. Search commands classify
rg status 0 as matches to classify, status 1 as a clean no-match, and every
other status (including a missing executable) as a blocking tool error.
"""

from __future__ import annotations

import argparse
import dataclasses
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, Iterable, Sequence


BASELINE_COMMIT = "f1c28fa"
PHASE_DIR = Path(".planning/phases/41-public-contract-and-observed-eye-support")
SOURCE_ROOT = "BeautySDK/Sources"
GENERATED_ROOTS = (
    "example-images/output",
    "example-images/gallery",
    "example-images/.gallery-staging",
    "example-images/.gallery-quarantine",
)
EYE_FIELDS = (
    "eyeHeight",
    "eyeLength",
    "upperEyelidLift",
    "pupilSize",
    "gazeCorrection",
    "lowerEyelidDrop",
    "eyeTilt",
    "innerCornerOpen",
    "outerCornerOpen",
    "eyeSymmetry",
)
INTERNAL_MODULES = (
    "BeautyCore",
    "BeautyDetection",
    "BeautyEffects",
    "BeautyRender",
    "BeautyResources",
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
    """Classify rg status 0/1/>1 without ever turning tool errors into clean scans."""
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
    except Exception as error:  # every live check fails closed at its boundary
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
    command = ["rg", "-n", "--no-heading", "--color", "never", pattern, *scopes]
    outcome = run_search(command, root, runner)
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


def check_paths(root: Path) -> Result:
    files = (
        "BeautySDK/Package.swift",
        "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
        "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift",
        "BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift",
        "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
        "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
        str(PHASE_DIR / "check_eye_support_boundaries.py"),
        ".gitignore",
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
    eye_counts = {field: names.count(field) for field in EYE_FIELDS}
    exact_eyes = all(count == 1 for count in eye_counts.values())
    ok = len(fields) == 48 and len(numeric) == 47 and names.count("filterId") == 1 and exact_eyes
    return Result(
        "public BeautyParameters inventory",
        ok,
        f"stored={len(fields)}; numeric={len(numeric)}; filterId={names.count('filterId')}; eye_fields={sum(count == 1 for count in eye_counts.values())}/10",
    )


def check_public_geometry(root: Path, runner: Runner = default_runner) -> Result:
    pattern = (
        r"(?:public|@_spi).*?(?:BeautyObservedEye|BeautyEyeSemantic|EyeSupport|EyeGeometry|"
        r"FaceGeometry|WarpControlPoint|SIMD[234]|landmark|DetectionProvider|WarpProvider|"
        r"(?:eye|pupil|contour).*(?:support|coordinate|point|bounds))"
    )

    def classified(line: str) -> bool:
        return (
            "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift:" in line
            and "@_spi(Testing) public final class SDKTestingFaceDetectionProvider" in line
        )

    return rg_scan(root, "public/SPI eye geometry", pattern, (SOURCE_ROOT,), classified, runner)


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


def _match_path(line: str) -> str:
    return line.split(":", 1)[0]


def check_codable_persistence(root: Path, runner: Runner = default_runner) -> Result:
    pattern = (
        r"Codable|Encodable|Decodable|UserDefaults|FileManager|CoreData|SwiftData|"
        r"NSKeyedArchiver|JSONEncoder|PropertyListEncoder|\.write\("
    )

    def classified(line: str) -> bool:
        path = _match_path(line)
        if path in APPROVED_CODABLE_PATHS and re.search(r"\b(?:Codable|Encodable|Decodable)\b", line):
            return True
        if path == "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift":
            return "intentionally has no Codable or diagnostic representation" in line
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
        r"BeautyObservedEye|BeautyEyeSemantic|observedEyeSupport|leftEyeSupport|rightEyeSupport|"
        r"(?:eye|pupil|contour).*(?:coordinate|point|bounds|support)|"
        r"(?:coordinate|point|bounds|support).*(?:eye|pupil|contour)"
    )
    sink = r"print\(|debugPrint|Logger|os_log|message:|metrics\[|metadata:|description|errorDescription"
    pattern = rf"(?:{sink}).*(?:{raw})|(?:{raw}).*(?:{sink})"
    return rg_scan(root, "raw eye diagnostic leakage", pattern, (SOURCE_ROOT,), runner=runner)


def check_network(root: Path, runner: Runner = default_runner) -> Result:
    pattern = r"URLSession|import Network|CloudKit|Alamofire|RevenueCat|https?://|WebSocket|NWConnection"
    return rg_scan(root, "network/cloud active-source paths", pattern, (SOURCE_ROOT,), runner=runner)


def check_commercial(root: Path, runner: Runner = default_runner) -> Result:
    pattern = r"StoreKit|Payment|purchase\(|entitlement|RevenueCat|subscription|VIP|paywall|checkout"
    return rg_scan(root, "commercial active-source paths", pattern, (SOURCE_ROOT,), runner=runner)


def check_imports(root: Path, runner: Runner = default_runner) -> Result:
    pattern = r"^import (?:" + "|".join(INTERNAL_MODULES) + r")$"
    return rg_scan(
        root,
        "Demo/renderer facade-only imports",
        pattern,
        ("BeautyDemo", "BeautySDK/Sources/BeautyExampleRenderer"),
        runner=runner,
    )


def check_artifacts(root: Path) -> Result:
    for relative in GENERATED_ROOTS:
        candidate = root / relative
        if candidate.is_symlink():
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
        representative = f"{relative}/representative.png"
        completed = default_runner(["git", "check-ignore", "-q", representative], root)
        if completed.returncode == 1:
            not_ignored.append(representative)
        elif completed.returncode != 0:
            ignore_errors += 1
    errors = int(bool(tracked_error or staged_error or other_error)) + ignore_errors
    ok = (
        tracked_ok
        and staged_ok
        and other_ok
        and not tracked
        and not staged
        and not untracked
        and not not_ignored
        and errors == 0
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
        ("public/SPI eye geometry", lambda: check_public_geometry(root)),
        ("Codable/persistence allowlist", lambda: check_codable_persistence(root)),
        ("raw eye diagnostic leakage", lambda: check_diagnostics(root)),
        ("network/cloud active-source paths", lambda: check_network(root)),
        ("commercial active-source paths", lambda: check_commercial(root)),
        ("Demo/renderer facade-only imports", lambda: check_imports(root)),
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
            "GIT_AUTHOR_NAME": "Phase 41 Self Test",
            "GIT_AUTHOR_EMAIL": "phase41@example.invalid",
            "GIT_COMMITTER_NAME": "Phase 41 Self Test",
            "GIT_COMMITTER_EMAIL": "phase41@example.invalid",
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
        ".gitignore",
        "\n".join(f"{relative}/" for relative in GENERATED_ROOTS) + "\n",
    )
    git(root, "add", "BeautySDK/Package.swift", "BeautyDemo/App.swift", ".gitignore")
    committed = git(root, "commit", "-q", "-m", "fixture baseline")
    if committed.returncode != 0:
        raise RuntimeError("could not create baseline fixture")
    resolved = git(root, "rev-parse", "HEAD")
    if resolved.returncode != 0:
        raise RuntimeError("could not resolve baseline fixture")
    return resolved.stdout.strip()


def build_source_fixture(root: Path) -> Path:
    write_fixture(
        root,
        "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift",
        "package struct BeautyObservedEyeSupport: Equatable, Sendable {}\n",
    )
    return root / "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift"


def self_test() -> list[Result]:
    results: list[Result] = []

    def fake(code: int, stdout: str = "", stderr: str = "") -> Runner:
        return lambda command, cwd: subprocess.CompletedProcess(command, code, stdout, stderr)

    states = (
        ("no-match", run_search(("rg", "x"), Path("."), fake(1)).state == "no-match"),
        ("match", run_search(("rg", "x"), Path("."), fake(0, "fixture:1:guard\n")).state == "matches"),
        ("exit 2", run_search(("rg", "x"), Path("."), fake(2, stderr="boom")).state == "error"),
        ("tool missing", run_search(("rg", "x"), Path("."), fake(127, stderr="missing")).state == "error"),
        ("runner exception", run_search(("rg", "x"), Path("."), lambda _c, _d: (_ for _ in ()).throw(OSError("missing"))).state == "error"),
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

    with tempfile.TemporaryDirectory(prefix="phase41-path-") as temporary:
        root = Path(temporary)
        outside = root.parent / f"{root.name}-outside.txt"
        outside.write_text("outside", encoding="utf-8")
        (root / "escape").symlink_to(outside)
        try:
            safe_path(root, "escape")
            escaped = False
        except RuntimeError:
            escaped = True
        outside.unlink(missing_ok=True)
        results.append(Result("self-test path escape failure", escaped, "escaping_symlink_rejected=1"))

    if not shutil.which("git"):
        results.append(Result("self-test git fixtures", False, "git_missing=1"))
    else:
        with tempfile.TemporaryDirectory(prefix="phase41-baseline-") as temporary:
            root = Path(temporary)
            baseline = build_baseline_fixture(root)
            results.append(Result("self-test baseline positive", check_baseline(root, baseline).ok, "clean_baseline_accepted=1"))
            manifest = root / "BeautySDK/Package.swift"
            manifest.write_text("// dependency mutation\n", encoding="utf-8")
            results.append(Result("self-test manifest drift failure", not check_baseline(root, baseline).ok, "manifest_mutation_rejected=1"))
            manifest.write_text("// fixture manifest\n", encoding="utf-8")
            demo = root / "BeautyDemo/App.swift"
            demo.write_text("// Demo mutation\n", encoding="utf-8")
            results.append(Result("self-test Demo drift failure", not check_baseline(root, baseline).ok, "demo_mutation_rejected=1"))
            demo.write_text("// fixture Demo\n", encoding="utf-8")
            write_fixture(root, "BeautyDemo/Untracked.swift", "// untracked Demo mutation\n")
            results.append(Result("self-test untracked Demo failure", not check_baseline(root, baseline).ok, "untracked_demo_rejected=1"))

        with tempfile.TemporaryDirectory(prefix="phase41-artifact-") as temporary:
            root = Path(temporary)
            build_baseline_fixture(root)
            results.append(Result("self-test artifact positive", check_artifacts(root).ok, "ignored_roots_accepted=1"))
            tracked_path = "example-images/output/tracked.png"
            write_fixture(root, tracked_path, "fixture")
            git(root, "add", "-f", tracked_path)
            git(root, "commit", "-q", "-m", "tracked artifact")
            results.append(Result("self-test tracked artifact failure", not check_artifacts(root).ok, "tracked_artifact_rejected=1"))

        with tempfile.TemporaryDirectory(prefix="phase41-staged-") as temporary:
            root = Path(temporary)
            build_baseline_fixture(root)
            staged_path = "example-images/gallery/staged.png"
            write_fixture(root, staged_path, "fixture")
            git(root, "add", "-f", staged_path)
            results.append(Result("self-test staged artifact failure", not check_artifacts(root).ok, "staged_artifact_rejected=1"))

        with tempfile.TemporaryDirectory(prefix="phase41-untracked-") as temporary:
            root = Path(temporary)
            build_baseline_fixture(root)
            (root / ".gitignore").write_text("", encoding="utf-8")
            write_fixture(root, "example-images/.gallery-quarantine/untracked.png", "fixture")
            results.append(Result("self-test nonignored untracked artifact failure", not check_artifacts(root).ok, "untracked_artifact_rejected=1"))

    if not shutil.which("rg"):
        results.append(Result("self-test source mutation fixtures", False, "rg_missing=1"))
    else:
        with tempfile.TemporaryDirectory(prefix="phase41-source-") as temporary:
            root = Path(temporary)
            source = build_source_fixture(root)
            clean_checks = (
                check_public_geometry(root),
                check_codable_persistence(root),
                check_diagnostics(root),
                check_network(root),
                check_commercial(root),
            )
            results.append(Result("self-test source scans positive", all(item.ok for item in clean_checks), f"clean_scans={sum(item.ok for item in clean_checks)}/5"))
            mutations: tuple[tuple[str, str, Callable[[Path], Result]], ...] = (
                ("public support", "public struct EyeSupport {}\n", check_public_geometry),
                ("Codable support", "package struct EyeSupport: Codable {}\n", check_codable_persistence),
                ("persistence", "let saved = UserDefaults.standard.set(observedEyeSupport, forKey: \"eye\")\n", check_codable_persistence),
                ("diagnostic", "print(observedEyeSupport)\n", check_diagnostics),
                ("network", "let task = URLSession.shared\n", check_network),
                ("commercial", "import StoreKit\n", check_commercial),
            )
            for name, mutation, checker in mutations:
                build_source_fixture(root)
                source.write_text(source.read_text(encoding="utf-8") + mutation, encoding="utf-8")
                results.append(Result(f"self-test {name} mutation failure", not checker(root).ok, "mutation_rejected=1"))

    return results


def print_results(mode: str, results: Sequence[Result]) -> int:
    print(f"Phase 41 eye-support boundary checker — mode={mode}")
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
