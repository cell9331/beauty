#!/usr/bin/env python3
"""Fail-closed Phase 40 source, promotion, owner, and artifact boundary gate."""

from __future__ import annotations

import argparse
import dataclasses
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, Sequence


FIELDS = (
    "mouthYPosition", "mouthTilt", "mouthXPosition", "lipPeakDefinition", "lipPlump",
)
PUBLIC_FIELDS = (
    "skinSmoothing", "skinWhitening", "skinRosy", "skinSharpen", "brightness", "contrast",
    "saturation", "temperature", "tint", "exposure", "highlight", "shadow", "faceSlim",
    "faceSmall", "faceVShape", "jawSlim", "chinLength", "eyeSize", "eyeDistance",
    "eyeYPosition", "eyeTailLift", "noseSlim", "noseWingSlim", "noseTipSize", "noseBridge",
    "noseRootNarrowing", "noseTipLift", "mouthSize", "mouthWidth", "smile", "mouthYPosition",
    "mouthTilt", "mouthXPosition", "lipPeakDefinition", "lipPlump", "lipColor", "filterId",
    "filterIntensity",
)
SOURCE_OWNERS = {
    "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift",
    "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
}
GENERATED_ROOTS = (
    "example-images/output", "example-images/gallery",
    "example-images/.gallery-staging", "example-images/.gallery-quarantine",
)
LIFECYCLE_CLAIM = re.compile(
    r"v1\.10.{0,80}(audit (passed|complete)|archiv(ed|e complete)|tagged|cleanup complete|launch[- ]ready|shipping complete)",
    re.IGNORECASE,
)


@dataclasses.dataclass(frozen=True)
class Result:
    name: str
    ok: bool
    detail: str


Runner = Callable[[Sequence[str], Path], subprocess.CompletedProcess[str]]


def run(command: Sequence[str], root: Path) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(command, cwd=root, text=True, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, check=False)
    except OSError as error:
        return subprocess.CompletedProcess(command, 127, "", str(error))


def locate_repo(start: Path) -> Path:
    resolved = start.resolve(strict=True)
    for candidate in (resolved, *resolved.parents):
        if (candidate / ".git").exists() and (candidate / "BeautySDK/Package.swift").is_file():
            return candidate
    raise RuntimeError(f"repository root not found from {start}")


def read(root: Path, relative: str) -> str:
    candidate = root / relative
    resolved = candidate.resolve(strict=True)
    root_resolved = root.resolve(strict=True)
    if candidate.is_symlink() or root_resolved not in resolved.parents:
        raise RuntimeError(f"unsafe required path: {relative}")
    return candidate.read_text(encoding="utf-8")


def search_lines(command: Sequence[str], root: Path, runner: Runner = run) -> tuple[str, ...]:
    completed = runner(command, root)
    if completed.returncode not in (0, 1):
        diagnostic = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
        raise RuntimeError(f"command failed ({completed.returncode}): {' '.join(command)}: {diagnostic}")
    return tuple(line for line in completed.stdout.splitlines() if line.strip())


def git_lines(command: Sequence[str], root: Path, runner: Runner = run) -> tuple[str, ...]:
    completed = runner(command, root)
    if completed.returncode != 0:
        diagnostic = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
        raise RuntimeError(f"git command failed ({completed.returncode}): {' '.join(command)}: {diagnostic}")
    return tuple(line for line in completed.stdout.splitlines() if line.strip())


def check_required_paths(root: Path) -> Result:
    required = (
        "BeautySDK/Package.swift",
        "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
        "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift",
        "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
        "BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift",
        "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
        "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
        "docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md",
        ".gitignore",
    )
    for relative in required:
        read(root, relative)
    return Result("path/scope containment", True, f"{len(required)} regular contained files")


def check_manifest(root: Path) -> Result:
    text = read(root, "BeautySDK/Package.swift")
    forbidden = [token for token in (".package(", ".binaryTarget(", ".plugin(", "url:") if token in text]
    return Result("dependency boundary", not forbidden, "no external dependency declaration" if not forbidden else str(forbidden))


def check_inventory(root: Path) -> Result:
    text = read(root, "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
    fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):\s*([^\n]+)$", text, re.MULTILINE)
    names = [name for name, _ in fields]
    numeric = [name for name, kind in fields if kind.strip() == "Float"]
    ok = tuple(names) == PUBLIC_FIELDS and len(numeric) == 37 and names.count("filterId") == 1
    return Result("public compatibility inventory", ok,
                  f"stored={len(fields)}, numeric={len(numeric)}, filterId={names.count('filterId')}, new={len(set(FIELDS) & set(names))}/5")


def check_source_classification(root: Path) -> Result:
    lines = search_lines(["rg", "-l", "|".join(FIELDS), "BeautySDK/Sources", "BeautyDemo/BeautyDemo"], root)
    observed = set(lines)
    unknown = sorted(observed - SOURCE_OWNERS)
    missing = sorted(SOURCE_OWNERS - observed)
    return Result("new-field active-source classification", not unknown and not missing,
                  f"owners={len(observed)}" if not unknown and not missing else f"unknown={unknown}, missing={missing}")


def check_imports(root: Path) -> Result:
    lines = search_lines([
        "rg", "-n", "^import (BeautyCore|BeautyDetection|BeautyEffects|BeautyRender|BeautyResources)$",
        "BeautyDemo/BeautyDemo", "BeautyDemo/BeautyDemoTests", "BeautySDK/Sources/BeautyExampleRenderer",
    ], root)
    return Result("Demo/renderer facade-only imports", not lines, "clean no-match" if not lines else " | ".join(lines[:5]))


def check_public_geometry(root: Path) -> Result:
    lines = search_lines([
        "rg", "-n", "-U", r"(?s)(public|@_spi)[^{;]{0,240}(FaceGeometry|WarpControlPoint|SIMD[234]|outerLips|innerLips|upperLips|lowerLips|\blandmark\b|\bsupport\b|\bbounds\b|DetectionProvider|WarpProvider)",
        "BeautySDK/Sources",
    ], root)
    unknown = [line for line in lines if not ("BeautyEngineTestingSupport.swift" in line and "SDKTestingFaceDetectionProvider" in line)]
    return Result("public/SPI raw geometry", not unknown,
                  f"{len(lines)} testing-SPI line classified" if not unknown else " | ".join(unknown[:5]))


def check_remote_and_commercial(root: Path) -> Result:
    patterns = {
        "network/cloud active source": "URLSession|import Network|CloudKit|Alamofire|RevenueCat|https?://|WebSocket|NWConnection",
        "commercial active source": "StoreKit|Payment|purchase\\(|entitlement|RevenueCat|subscription|VIP|paywall|checkout",
    }
    failures: list[str] = []
    for name, pattern in patterns.items():
        lines = search_lines(["rg", "-n", pattern, "BeautySDK/Sources", "BeautyDemo/BeautyDemo"], root)
        if lines:
            failures.append(f"{name}: {' | '.join(lines[:3])}")
    return Result("network/cloud/commercial boundaries", not failures, "clean no-match" if not failures else " || ".join(failures))


def check_diagnostic_privacy(root: Path) -> Result:
    pattern = r'(message:|metrics\[).*?(outerLips|innerLips|upperLips|lowerLips|landmark|coordinate|control.?point|SIMD|bounds|/private/|file://|mouthYPosition|mouthTilt|mouthXPosition|lipPeakDefinition|lipPlump)'
    lines = search_lines(["rg", "-n", "-i", pattern, "BeautySDK/Sources"], root)
    return Result("active diagnostic privacy", not lines, "clean no-match" if not lines else " | ".join(lines[:5]))


def check_privacy_manifest_disposition(root: Path) -> Result:
    manifests = tuple((root / "BeautySDK").rglob("PrivacyInfo.xcprivacy")) + tuple((root / "BeautyDemo").rglob("PrivacyInfo.xcprivacy"))
    security = read(root, "SECURITY.md")
    tokens = ("found no existing privacy manifest", "explicitly defers adding `PrivacyInfo.xcprivacy`", "future collection")
    ok = not manifests and all(token in security for token in tokens)
    return Result("privacy-manifest disposition", ok,
                  "no manifest; explicit local-first deferral and reopen triggers" if ok else f"manifests={len(manifests)}, tokens={sum(t in security for t in tokens)}/3")


def check_lifecycle_and_archive(root: Path) -> Result:
    audit_files = list((root / ".planning").glob("*v1.10*MILESTONE-AUDIT.md")) + list((root / ".planning").glob("v1.10-MILESTONE-AUDIT.md"))
    tags = git_lines(["git", "tag", "--list", "v1.10"], root)
    archive_changes = git_lines(["git", "diff", "--name-only", "bc34c10..HEAD", "--", ".planning/milestones"], root)
    claim_pattern = LIFECYCLE_CLAIM.pattern
    claim_lines = search_lines(["rg", "-n", "-i", claim_pattern, "ARCHITECTURE.md", "DESIGN.md", "SECURITY.md", "RELIABILITY.md", "PRODUCT_SENSE.md", "QUALITY_SCORE.md", "PLANS.md", ".planning/PROJECT.md", ".planning/STATE.md"], root)
    ok = not audit_files and not tags and not archive_changes and not claim_lines
    return Result("lifecycle/archive nonclaim", ok,
                  "no audit artifact, tag, archive mutation, or lifecycle success claim" if ok else f"audit={audit_files}, tags={tags}, archive={archive_changes}, claims={claim_lines[:3]}")


def expected_row_statuses(allow_promotion: bool) -> dict[str, str]:
    if allow_promotion:
        return {"上下": "implemented", "倾斜": "implemented", "左右": "implemented", "M唇": "implemented", "丰唇": "implemented", "白牙": "future"}
    return {"上下": "future", "倾斜": "future", "左右": "future", "M唇": "future", "丰唇": "partial", "白牙": "future"}


def table_rows(text: str) -> list[list[str]]:
    return [
        [cell.strip().strip("`") for cell in line.strip().strip("|").split("|")]
        for line in text.splitlines()
        if line.lstrip().startswith("|")
    ]


def check_promotion(root: Path, allow_promotion: bool) -> Result:
    ledger = read(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md")
    failures = []
    for row, status in expected_row_statuses(allow_promotion).items():
        matches = [cells for cells in table_rows(ledger) if len(cells) >= 3 and cells[0] == "嘴唇" and cells[1] == row]
        if len(matches) != 1 or matches[0][2] != status:
            failures.append(f"{row}: rows={len(matches)}, status={matches[0][2] if matches else 'missing'}, expected={status}")
    matrix = read(root, "docs/meitu-function-blueprint/FEATURE_MATRIX.md")
    parent = read(root, "docs/meitu-function-blueprint/features/beauty-shaping/README.md")
    lips = read(root, "docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md")
    matrix_rows = [cells for cells in table_rows(matrix) if len(cells) >= 3 and cells[0] == "Beauty shaping" and cells[1] == "嘴唇"]
    parent_rows = [cells for cells in table_rows(parent) if len(cells) >= 2 and cells[0] == "嘴唇"]
    if len(matrix_rows) != 1 or matrix_rows[0][2] != "partial":
        failures.append("matrix branch not partial")
    if len(parent_rows) != 1 or parent_rows[0][1] != "partial":
        failures.append("parent branch not partial")
    if len(re.findall(r"^- Status:\s*`?partial`?\.?\s*$", lips, re.MULTILINE)) != 1:
        failures.append("lips branch not partial")
    if allow_promotion:
        for owner_name, owner_text in (("matrix", matrix), ("parent", parent), ("lips", lips)):
            for token in (*FIELDS, "Phase 40", "白牙"):
                if token not in owner_text:
                    failures.append(f"{owner_name} token missing: {token}")
    return Result("exact promotion/branch status", not failures,
                  "five geometry rows exact; teeth future; branch partial" if not failures else "; ".join(failures))


def check_closeout_owners(root: Path, allow_promotion: bool) -> Result:
    if not allow_promotion:
        return Result("current-owner closeout", True, "deferred in pre-promotion mode")
    required_tokens = {
        "ARCHITECTURE.md": ("v1.10", "mouthYPosition"),
        "DESIGN.md": ("v1.10", "0.25", "fourteen"),
        "SECURITY.md": ("v1.10", "threats_open: 0"),
        "RELIABILITY.md": ("v1.10", "0.5", "lipPlump"),
        "PRODUCT_SENSE.md": ("v1.10", "白牙", "partial"),
        "QUALITY_SCORE.md": ("v1.10", "260"),
        ".planning/PROJECT.md": ("v1.10", "Phase 40"),
        ".planning/REQUIREMENTS.md": ("[x] **MOUTH-12**", "[x] **MOUTH-13**", "[x] **MOUTH-14**", "[x] **MOUTH-15**", "[x] **MOUTH-16**", "[x] **DOC-01**"),
        ".planning/ROADMAP.md": ("| 40. Mouth Geometry Safety and Ledger Closeout | 4/4 | Complete |"),
        ".planning/STATE.md": ("$gsd-audit-milestone", "Phase 40"),
        "PLANS.md": ("Phase 40", "`completed`"),
    }
    failures = []
    for relative, tokens in required_tokens.items():
        text = read(root, relative)
        for token in tokens:
            if token not in text:
                failures.append(f"{relative}: missing {token}")
    requirements = read(root, ".planning/REQUIREMENTS.md")
    for requirement in ("MOUTH-12", "MOUTH-13", "MOUTH-14", "MOUTH-15", "MOUTH-16", "DOC-01"):
        rows = [cells for cells in table_rows(requirements) if len(cells) >= 3 and cells[0] == requirement]
        if len(rows) != 1 or rows[0][1] != "Phase 40" or rows[0][2] != "Complete":
            failures.append(f"traceability {requirement} is not exactly Phase 40/Complete")
    phase_dir = ".planning/phases/40-mouth-geometry-safety-and-ledger-closeout"
    for relative, token in (("40-SECURITY.md", "threats_open: 0"), ("40-VALIDATION.md", "nyquist_compliant: true"), ("40-VERIFICATION.md", "status: passed")):
        if token not in read(root, f"{phase_dir}/{relative}"):
            failures.append(f"{relative}: missing {token}")
    return Result("current-owner closeout", not failures, "all contract/planning owners agree" if not failures else " | ".join(failures))


def check_artifacts(root: Path, runner: Runner = run) -> Result:
    tracked = git_lines(["git", "ls-files", "--", *GENERATED_ROOTS], root, runner)
    staged = git_lines(["git", "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS], root, runner)
    ignore_failures = []
    for relative in ("example-images/output/.phase40-probe.png", "example-images/gallery/.phase40-probe.png"):
        completed = runner(["git", "check-ignore", "-q", relative], root)
        if completed.returncode != 0:
            ignore_failures.append(relative)
    ok = not tracked and not staged and not ignore_failures
    return Result("generated artifact containment", ok,
                  "ignored, untracked, unstaged" if ok else f"tracked={tracked}, staged={staged}, ignore={ignore_failures}")


def self_test(source_root: Path) -> int:
    passed = 0

    def require(condition: bool, label: str) -> None:
        nonlocal passed
        if not condition:
            raise AssertionError(label)
        passed += 1

    positive = (
        check_required_paths(source_root), check_manifest(source_root), check_inventory(source_root),
        check_source_classification(source_root), check_imports(source_root), check_public_geometry(source_root),
        check_remote_and_commercial(source_root), check_diagnostic_privacy(source_root),
        check_privacy_manifest_disposition(source_root), check_promotion(source_root, False),
        check_lifecycle_and_archive(source_root), check_artifacts(source_root),
    )
    for result in positive:
        require(result.ok, f"positive fixture failed {result.name}: {result.detail}")

    no_match: Runner = lambda _command, _root: subprocess.CompletedProcess([], 1, "", "")
    missing_tool: Runner = lambda _command, _root: subprocess.CompletedProcess([], 127, "", "missing")
    require(search_lines(["rg"], source_root, no_match) == (), "rg exit 1 must be a no-match")
    try:
        search_lines(["rg"], source_root, missing_tool)
    except RuntimeError:
        passed += 1
    else:
        raise AssertionError("missing search tool must fail closed")
    try:
        git_lines(["git"], source_root, no_match)
    except RuntimeError:
        passed += 1
    else:
        raise AssertionError("git exit 1 must fail closed")

    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory) / "repo"
        root.mkdir()
        (root / ".git").mkdir()
        for relative in (
            "BeautySDK/Package.swift", "BeautySDK/Sources", "BeautyDemo/BeautyDemo",
            "BeautyDemo/BeautyDemoTests", "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
            "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
            "docs/meitu-function-blueprint/features/beauty-shaping/README.md",
            "docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md", "SECURITY.md", ".gitignore",
        ):
            source = source_root / relative
            destination = root / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            if source.is_dir():
                shutil.copytree(source, destination, dirs_exist_ok=True)
            else:
                shutil.copy2(source, destination)

        package = root / "BeautySDK/Package.swift"
        original_package = package.read_text()
        package.write_text(original_package + "\n// .package(\n")
        require(not check_manifest(root).ok, "dependency mutation must fail")
        package.write_text(original_package)

        model = root / "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
        original_model = model.read_text()
        model.write_text(original_model.replace("public var noseSlim:", "public var arbitraryLegacyReplacement:"))
        require(not check_inventory(root).ok, "exact inventory replacement must fail")
        model.write_text(original_model)

        unknown = root / "BeautySDK/Sources/UnexpectedOwner.swift"
        unknown.write_text("let value = mouthYPosition\n")
        require(not check_source_classification(root).ok, "unclassified owner must fail")
        unknown.unlink()

        demo_leak = root / "BeautyDemo/BeautyDemo/InternalLeak.swift"
        demo_leak.write_text("import BeautyEffects\n")
        require(not check_imports(root).ok, "internal import must fail")
        demo_leak.unlink()

        public_leak = root / "BeautySDK/Sources/BeautySDK/PublicLeak.swift"
        public_leak.write_text("public struct PublicLeak {\n public let bounds: FaceGeometry\n}\n")
        require(not check_public_geometry(root).ok, "multiline public geometry must fail")
        public_leak.unlink()

        network_leak = root / "BeautySDK/Sources/BeautySDK/NetworkLeak.swift"
        network_leak.write_text("let session = URLSession.shared\n")
        require(not check_remote_and_commercial(root).ok, "network path must fail")
        network_leak.unlink()

        diagnostic_leak = root / "BeautySDK/Sources/BeautySDK/DiagnosticLeak.swift"
        diagnostic_leak.write_text('let warning = BeautyValidationWarning(message: "outerLips coordinate")\n')
        require(not check_diagnostic_privacy(root).ok, "diagnostic payload must fail")
        diagnostic_leak.unlink()

        ledger = root / "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md"
        original_ledger = ledger.read_text()
        ledger.write_text(original_ledger + "\n| `嘴唇` | 上下 | implemented | duplicate | contradictory |\n")
        require(not check_promotion(root, False).ok, "duplicate contradictory promotion row must fail")
        ledger.write_text(original_ledger)

        manifest = root / "BeautySDK/PrivacyInfo.xcprivacy"
        manifest.write_text("fixture")
        require(not check_privacy_manifest_disposition(root).ok, "unexpected privacy manifest must fail")
        manifest.unlink()

        require(LIFECYCLE_CLAIM.search("v1.10 audit passed and archived") is not None,
                "premature lifecycle claim classifier must match")
        try:
            stale_closeout = check_closeout_owners(root, True)
        except Exception:
            passed += 1
        else:
            require(not stale_closeout.ok, "stale/missing allow-promotion owners must fail")

        clean_git: Runner = lambda command, _root: subprocess.CompletedProcess(
            command, 0, "", ""
        ) if command[:3] != ["git", "check-ignore", "-q"] else subprocess.CompletedProcess(command, 0, "", "")
        tracked_git: Runner = lambda command, _root: subprocess.CompletedProcess(
            command, 0, "example-images/output/leak.png\n" if command[:2] == ["git", "ls-files"] else "", ""
        ) if command[:3] != ["git", "check-ignore", "-q"] else subprocess.CompletedProcess(command, 0, "", "")
        require(check_artifacts(root, clean_git).ok, "clean artifact fixture must pass")
        require(not check_artifacts(root, tracked_git).ok, "tracked artifact fixture must fail")

        outside = Path(directory) / "outside-package"
        outside.write_text(original_package)
        package.unlink()
        package.symlink_to(outside)
        try:
            check_required_paths(root)
        except RuntimeError:
            passed += 1
        else:
            raise AssertionError("escaping symlink must fail")

    print(f"SELF-TEST PASS: {passed}/{passed} positive, mutation, command, path, owner, lifecycle, and artifact checks")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--allow-promotion", action="store_true")
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args()
    if args.self_test:
        return self_test(locate_repo(args.root))
    try:
        root = locate_repo(args.root)
        operations = (
            lambda: check_required_paths(root), lambda: check_manifest(root), lambda: check_inventory(root),
            lambda: check_source_classification(root), lambda: check_imports(root), lambda: check_public_geometry(root),
            lambda: check_remote_and_commercial(root), lambda: check_diagnostic_privacy(root),
            lambda: check_privacy_manifest_disposition(root), lambda: check_promotion(root, args.allow_promotion),
            lambda: check_closeout_owners(root, args.allow_promotion), lambda: check_artifacts(root),
            lambda: check_lifecycle_and_archive(root),
        )
        results = []
        for operation in operations:
            try:
                results.append(operation())
            except Exception as error:
                results.append(Result("boundary execution", False, str(error)))
        for result in results:
            print(f"{'PASS' if result.ok else 'FAIL'} {result.name}: {result.detail}")
        failures = [result for result in results if not result.ok]
        print(f"SUMMARY {len(results) - len(failures)}/{len(results)} checks passed")
        return 1 if failures else 0
    except Exception as error:
        print(f"FAIL initialization: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
