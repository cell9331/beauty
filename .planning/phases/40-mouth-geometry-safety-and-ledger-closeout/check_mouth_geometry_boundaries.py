#!/usr/bin/env python3
"""Fail-closed Phase 40 source, promotion, owner, and artifact boundary gate."""

from __future__ import annotations

import argparse
import dataclasses
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, Sequence


FIELDS = (
    "mouthYPosition", "mouthTilt", "mouthXPosition", "lipPeakDefinition", "lipPlump",
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


def command_lines(command: Sequence[str], root: Path, runner: Runner = run) -> tuple[str, ...]:
    completed = runner(command, root)
    if completed.returncode not in (0, 1):
        diagnostic = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
        raise RuntimeError(f"command failed ({completed.returncode}): {' '.join(command)}: {diagnostic}")
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
    ok = len(fields) == 38 and len(numeric) == 37 and names.count("filterId") == 1 and set(FIELDS) <= set(names)
    return Result("public compatibility inventory", ok,
                  f"stored={len(fields)}, numeric={len(numeric)}, filterId={names.count('filterId')}, new={len(set(FIELDS) & set(names))}/5")


def check_source_classification(root: Path) -> Result:
    lines = command_lines(["rg", "-l", "|".join(FIELDS), "BeautySDK/Sources", "BeautyDemo/BeautyDemo"], root)
    observed = set(lines)
    unknown = sorted(observed - SOURCE_OWNERS)
    missing = sorted(SOURCE_OWNERS - observed)
    return Result("new-field active-source classification", not unknown and not missing,
                  f"owners={len(observed)}" if not unknown and not missing else f"unknown={unknown}, missing={missing}")


def check_imports(root: Path) -> Result:
    lines = command_lines([
        "rg", "-n", "^import (BeautyCore|BeautyDetection|BeautyEffects|BeautyRender|BeautyResources)$",
        "BeautyDemo/BeautyDemo", "BeautyDemo/BeautyDemoTests", "BeautySDK/Sources/BeautyExampleRenderer",
    ], root)
    return Result("Demo/renderer facade-only imports", not lines, "clean no-match" if not lines else " | ".join(lines[:5]))


def check_public_geometry(root: Path) -> Result:
    lines = command_lines([
        "rg", "-n", "(public|@_spi).*?(FaceGeometry|WarpControlPoint|SIMD[234]|outerLips|innerLips|upperLips|lowerLips|DetectionProvider|WarpProvider)",
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
        lines = command_lines(["rg", "-n", pattern, "BeautySDK/Sources", "BeautyDemo/BeautyDemo"], root)
        if lines:
            failures.append(f"{name}: {' | '.join(lines[:3])}")
    return Result("network/cloud/commercial boundaries", not failures, "clean no-match" if not failures else " || ".join(failures))


def expected_row_statuses(allow_promotion: bool) -> dict[str, str]:
    if allow_promotion:
        return {"上下": "implemented", "倾斜": "implemented", "左右": "implemented", "M唇": "implemented", "丰唇": "implemented", "白牙": "future"}
    return {"上下": "future", "倾斜": "future", "左右": "future", "M唇": "future", "丰唇": "partial", "白牙": "future"}


def check_promotion(root: Path, allow_promotion: bool) -> Result:
    ledger = read(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md")
    failures = []
    for row, status in expected_row_statuses(allow_promotion).items():
        if f"| `嘴唇` | {row} | {status} |" not in ledger:
            failures.append(f"{row}!={status}")
    matrix = read(root, "docs/meitu-function-blueprint/FEATURE_MATRIX.md")
    parent = read(root, "docs/meitu-function-blueprint/features/beauty-shaping/README.md")
    lips = read(root, "docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md")
    if "| Beauty shaping | 嘴唇 | partial |" not in matrix:
        failures.append("matrix branch not partial")
    if "| `嘴唇` | partial |" not in parent:
        failures.append("parent branch not partial")
    if "Status: `partial`" not in lips:
        failures.append("lips branch not partial")
    if allow_promotion:
        owner_text = "\n".join((matrix, parent, lips))
        for token in (*FIELDS, "Phase 40", "白牙"):
            if token not in owner_text:
                failures.append(f"owner token missing: {token}")
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
        ".planning/REQUIREMENTS.md": ("[x] **MOUTH-16**", "[x] **DOC-01**"),
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
    phase_dir = ".planning/phases/40-mouth-geometry-safety-and-ledger-closeout"
    for relative, token in (("40-SECURITY.md", "threats_open: 0"), ("40-VALIDATION.md", "nyquist_compliant: true"), ("40-VERIFICATION.md", "status: passed")):
        if token not in read(root, f"{phase_dir}/{relative}"):
            failures.append(f"{relative}: missing {token}")
    return Result("current-owner closeout", not failures, "all contract/planning owners agree" if not failures else " | ".join(failures))


def check_artifacts(root: Path) -> Result:
    tracked = command_lines(["git", "ls-files", "--", *GENERATED_ROOTS], root)
    staged = command_lines(["git", "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS], root)
    ignore_failures = []
    for relative in ("example-images/output/.phase40-probe.png", "example-images/gallery/.phase40-probe.png"):
        completed = run(["git", "check-ignore", "-q", relative], root)
        if completed.returncode != 0:
            ignore_failures.append(relative)
    ok = not tracked and not staged and not ignore_failures
    return Result("generated artifact containment", ok,
                  "ignored, untracked, unstaged" if ok else f"tracked={tracked}, staged={staged}, ignore={ignore_failures}")


def self_test() -> int:
    assert expected_row_statuses(False)["丰唇"] == "partial"
    assert expected_row_statuses(True)["丰唇"] == "implemented"
    assert expected_row_statuses(True)["白牙"] == "future"
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        clean: Runner = lambda _command, _root: subprocess.CompletedProcess([], 1, "", "")
        error: Runner = lambda _command, _root: subprocess.CompletedProcess([], 2, "", "boom")
        assert command_lines(["rg"], root, clean) == ()
        try:
            command_lines(["rg"], root, error)
        except RuntimeError:
            pass
        else:
            raise AssertionError("command errors must fail closed")
    print("SELF-TEST PASS: promotion states and command no-match/error classification")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--allow-promotion", action="store_true")
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args()
    if args.self_test:
        return self_test()
    try:
        root = locate_repo(args.root)
        operations = (
            lambda: check_required_paths(root), lambda: check_manifest(root), lambda: check_inventory(root),
            lambda: check_source_classification(root), lambda: check_imports(root), lambda: check_public_geometry(root),
            lambda: check_remote_and_commercial(root), lambda: check_promotion(root, args.allow_promotion),
            lambda: check_closeout_owners(root, args.allow_promotion), lambda: check_artifacts(root),
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
