#!/usr/bin/env python3
"""Fail-closed Phase 37 source, status, promotion, and artifact boundary gate.

Exit zero means every selected check ran and passed.  Search commands classify
rg's exit status explicitly: 0 is a match set to inspect, 1 is a clean
no-match result, and every other status (including an absent executable) is a
blocking tool error.
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


PHASE_DIR = Path(".planning/phases/37-nose-safety-boundary-and-branch-closeout")
GENERATED_ROOTS = (
    "example-images/output",
    "example-images/gallery",
    "example-images/.gallery-staging",
    "example-images/.gallery-quarantine",
)
INTERNAL_MODULES = ("BeautyCore", "BeautyDetection", "BeautyEffects", "BeautyRender", "BeautyResources")
NOSE_FIELDS = (
    "noseSlim",
    "noseWingSlim",
    "noseTipSize",
    "noseBridge",
    "noseRootNarrowing",
    "noseTipLift",
)
NOSE_ROWS = ("大小", "提升", "鼻翼", "山根", "鼻梁", "鼻尖")


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
            list(command), cwd=cwd, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, check=False,
        )
    except OSError as error:
        return subprocess.CompletedProcess(command, 127, "", str(error))


def run_search(command: Sequence[str], cwd: Path, runner: Runner = default_runner) -> SearchResult:
    completed = runner(command, cwd)
    if completed.returncode == 0:
        lines = tuple(line for line in completed.stdout.splitlines() if line.strip())
        return SearchResult("matches", lines, f"{len(lines)} classified match line(s)")
    if completed.returncode == 1:
        return SearchResult("no-match", (), "clean no-match")
    error = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
    return SearchResult("error", (), f"exit {completed.returncode}: {error}")


def locate_repo(start: Path) -> Path:
    resolved = start.resolve(strict=True)
    for candidate in (resolved, *resolved.parents):
        if (candidate / ".git").exists() and (candidate / "BeautySDK/Package.swift").is_file():
            return candidate
    raise RuntimeError(f"repository root not found from {start}")


def safe_file(root: Path, relative: str) -> Path:
    candidate = root / relative
    resolved_root = root.resolve(strict=True)
    try:
        resolved = candidate.resolve(strict=True)
    except (FileNotFoundError, RuntimeError) as error:
        raise RuntimeError(f"missing or unresolvable required file {relative}: {error}") from error
    if resolved == resolved_root or resolved_root not in resolved.parents:
        raise RuntimeError(f"required path escapes repository: {relative} -> {resolved}")
    if candidate.is_symlink():
        raise RuntimeError(f"required file must not be a symlink: {relative}")
    return candidate


def read(root: Path, relative: str) -> str:
    return safe_file(root, relative).read_text(encoding="utf-8")


def result_from_exception(name: str, operation: Callable[[], Result]) -> Result:
    try:
        return operation()
    except Exception as error:  # fail closed at the check boundary
        return Result(name, False, f"blocking error: {error}")


def check_paths(root: Path) -> Result:
    required = (
        "BeautySDK/Package.swift",
        "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
        "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
        "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
        "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
        ".gitignore",
    )
    for relative in required:
        safe_file(root, relative)
    return Result("path/scope containment", True, f"{len(required)} required files are contained regular paths")


def check_manifest(root: Path) -> Result:
    text = read(root, "BeautySDK/Package.swift")
    forbidden = (".package(", ".binaryTarget(", ".plugin(", "url:")
    found = [token for token in forbidden if token in text]
    expected_targets = {
        "BeautyCore", "BeautyDetection", "BeautyRender", "BeautyResources",
        "BeautyEffects", "BeautySDK", "BeautyExampleRenderer", "BeautySDKTests",
        "BeautyCoreTests", "BeautyDetectionTests", "BeautyEffectsTests",
        "BeautyRenderTests", "BeautyResourcesTests",
    }
    target_names = set(re.findall(r"(?:name:\s*|\.target\(name:\s*|\.testTarget\(name:\s*|\.executableTarget\(\s*name:\s*)\"([^\"]+)\"", text))
    missing = sorted(expected_targets - target_names)
    extra = sorted(target_names - expected_targets - {"BeautySDK"})
    ok = not found and not missing and not extra and text.count(".library(name: \"BeautySDK\"") == 1
    detail = f"dependencies=0; expected targets={len(expected_targets)}"
    if not ok:
        detail = f"forbidden={found}, missing={missing}, extra={extra}"
    return Result("package/dependency compatibility", ok, detail)


def check_public_inventory(root: Path) -> Result:
    text = read(root, "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
    fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9]*):\s*([^\n]+)$", text, re.MULTILINE)
    names = [name for name, _ in fields]
    numeric = [name for name, type_name in fields if type_name.strip() == "Float"]
    expected = set(NOSE_FIELDS)
    ok = len(fields) == 33 and len(numeric) == 32 and names.count("filterId") == 1 and expected <= set(names)
    return Result(
        "public BeautyParameters inventory",
        ok,
        f"stored={len(fields)}, numeric={len(numeric)}, filterId={names.count('filterId')}, sixNose={len(expected & set(names))}/6",
    )


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
        return Result(name, False, f"scan error ({outcome.detail})")
    if outcome.state == "no-match":
        return Result(name, True, outcome.detail)
    allowed = classifier or (lambda _line: False)
    unclassified = [line for line in outcome.lines if not allowed(line)]
    if unclassified:
        return Result(name, False, "unclassified match: " + " | ".join(unclassified[:5]))
    return Result(name, True, f"{len(outcome.lines)} known guard/document literal match(es) classified")


def check_imports(root: Path) -> Result:
    pattern = r"^import (?:" + "|".join(INTERNAL_MODULES) + r")$"
    return rg_scan(
        root, "Demo/renderer facade-only imports", pattern,
        ("BeautyDemo/BeautyDemo", "BeautyDemo/BeautyDemoTests", "BeautySDK/Sources/BeautyExampleRenderer"),
    )


def check_public_geometry(root: Path) -> Result:
    pattern = r"(?:public|@_spi).*?(?:FaceGeometry|WarpControlPoint|SIMD[234]|landmark|\b(?:support|supports|bounds)\b|DetectionProvider|WarpProvider)"

    def known_testing_spi(line: str) -> bool:
        return "BeautyEngineTestingSupport.swift" in line and "SDKTestingFaceDetectionProvider" in line

    return rg_scan(root, "public/SPI raw geometry", pattern, ("BeautySDK/Sources",), known_testing_spi)


def check_network(root: Path) -> Result:
    pattern = r"URLSession|import Network|CloudKit|Alamofire|RevenueCat|https?://|WebSocket|NWConnection"

    def classified(line: str) -> bool:
        # Static disabled capability copy is not an execution path.
        return "BeautyCategoryModels.swift" in line and any(token in line for token in ("not included", "unavailable", "disabled"))

    return rg_scan(root, "network/cloud active-source paths", pattern, ("BeautySDK/Sources", "BeautyDemo/BeautyDemo"), classified)


def check_commercial(root: Path) -> Result:
    pattern = r"StoreKit|Payment|purchase\(|entitlement|RevenueCat|subscription|VIP|paywall|checkout"

    def classified(line: str) -> bool:
        return any(path in line for path in ("BeautyCategoryModels.swift", "MeituHomeModels.swift")) and any(
            token in line.lower() for token in ("not included", "unavailable", "disabled", "static")
        )

    return rg_scan(root, "commercial active-source paths", pattern, ("BeautySDK/Sources", "BeautyDemo/BeautyDemo"), classified)


def check_diagnostics(root: Path) -> Result:
    pattern = r"(?:message:|metrics\[|metadata:).*?(?:coordinate|landmark|support|bounds|control.?point|image.?bytes|detector object|provider type|file.?path)"
    return rg_scan(root, "diagnostic raw-data leakage", pattern, ("BeautySDK/Sources", "BeautyDemo/BeautyDemo"))


def check_privacy(root: Path) -> Result:
    manifests = list(root.glob("BeautySDK/**/PrivacyInfo.xcprivacy")) + list(root.glob("BeautyDemo/**/PrivacyInfo.xcprivacy"))
    return Result(
        "privacy-manifest disposition",
        not manifests,
        "current no-collection/no-required-reason behavior retains the documented zero-manifest disposition"
        if not manifests else f"unexpected manifest(s): {[str(path.relative_to(root)) for path in manifests]}",
    )


def git_lines(root: Path, command: Sequence[str]) -> tuple[bool, tuple[str, ...], str]:
    completed = default_runner(command, root)
    if completed.returncode != 0:
        return False, (), completed.stderr.strip() or f"exit {completed.returncode}"
    return True, tuple(line for line in completed.stdout.splitlines() if line.strip()), ""


def check_artifacts(root: Path) -> Result:
    tracked_ok, tracked, tracked_error = git_lines(root, ["git", "ls-files", "--", *GENERATED_ROOTS])
    staged_ok, staged, staged_error = git_lines(root, ["git", "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS])
    ignored = []
    for relative in ("example-images/output/representative.png", "example-images/gallery/representative.png"):
        completed = default_runner(["git", "check-ignore", "-q", relative], root)
        if completed.returncode != 0:
            ignored.append(relative)
    ok = tracked_ok and staged_ok and not tracked and not staged and not ignored
    detail = (
        "tracked=0, staged=0, representative output/gallery paths ignored"
        if ok else f"tracked={tracked}, staged={staged}, notIgnored={ignored}, errors={tracked_error or staged_error}"
    )
    return Result("generated artifact containment", ok, detail)


def check_archive_worktree(root: Path) -> Result:
    ok, lines, error = git_lines(root, ["git", "status", "--porcelain=v1", "--", ".planning/milestones", ".worktrees"])
    return Result("archive/worktree immutability", ok and not lines, "no active changes" if ok and not lines else f"{error or lines}")


def ledger_rows(text: str) -> list[list[str]]:
    rows: list[list[str]] = []
    for line in text.splitlines():
        if not line.startswith("|") or "鼻子" not in line:
            continue
        columns = [column.strip().strip("`") for column in line.strip().strip("|").split("|")]
        if len(columns) >= 3 and columns[0] == "鼻子" and columns[2] in {"implemented", "partial", "future"}:
            rows.append(columns)
    return rows


def default_status_checks(root: Path) -> list[Result]:
    ledger = read(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md")
    rows = ledger_rows(ledger)
    statuses = {row[1]: row[2] for row in rows}
    ledger_ok = len(rows) == 6 and statuses.get("提升") == "future" and statuses.get("山根") == "partial"
    matrix = read(root, "docs/meitu-function-blueprint/FEATURE_MATRIX.md")
    branch_rows = [line for line in matrix.splitlines() if line.startswith("|") and "| 鼻子 |" in line]
    branch_ok = len(branch_rows) == 1 and "| partial |" in branch_rows[0]
    return [
        Result("default second-level status guard", ledger_ok, f"rows={len(rows)}, 提升={statuses.get('提升')}, 山根={statuses.get('山根')}"),
        Result("default branch status guard", branch_ok, f"nose matrix rows={len(branch_rows)}, required=partial"),
    ]


OWNER_SPECS: dict[str, tuple[str, tuple[str, ...]]] = {
    "nose README": ("docs/meitu-function-blueprint/features/beauty-shaping/nose/README.md", ("Status: `implemented`", "noseRootNarrowing", "noseTipLift", "252/252", "SDK-core", "device", "commercial", "packaging", "launch")),
    "beauty-shaping README": ("docs/meitu-function-blueprint/features/beauty-shaping/README.md", ("`鼻子`", "implemented", "noseRootNarrowing", "noseTipLift", "SDK-core", "device", "commercial")),
    "example validation": ("docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md", ("Phase 37", "252/252", "12/12", "6/6", "2/2", "37-NOSE-SAFETY-EVIDENCE.md", "implemented", "device", "commercial", "packaging", "launch")),
    "example README": ("example-images/README.md", ("Phase 37", "0.25", "37-NOSE-SAFETY-EVIDENCE.md", "ignored", "untracked", "device", "commercial")),
    "ARCHITECTURE": ("ARCHITECTURE.md", ("Phase 37", "six", "facade", "package-internal", "noseRootNarrowing", "noseTipLift")),
    "DESIGN": ("DESIGN.md", ("Phase 37", "0.25", "six", "provider", "convergence")),
    "root SECURITY": ("SECURITY.md", ("Phase 37", "33", "32 numeric", "threats_open: 0", "public/SPI", "artifact")),
    "RELIABILITY": ("RELIABILITY.md", ("Phase 37", "0.25", "six", "provider-empty", "transition", "convergence")),
    "PRODUCT_SENSE": ("PRODUCT_SENSE.md", ("Phase 37", "山根", "提升", "SDK-core", "252/252", "device", "commercial", "packaging", "launch")),
    "QUALITY_SCORE": ("QUALITY_SCORE.md", ("Phase 37", "228/228", "252/252", "threats_open: 0", "six-row", "SDK-core")),
    "PROJECT": (".planning/PROJECT.md", ("Phase 37", "228/228", "252/252", "threats_open: 0", "milestone audit", "pending")),
    "ROADMAP": (".planning/ROADMAP.md", ("Phase 37", "4/4", "Complete", "$gsd-audit-milestone")),
    "STATE": (".planning/STATE.md", ("Phase: 37", "Plan: 4 of 4", "COMPLETE", "$gsd-audit-milestone")),
    "PLANS": ("PLANS.md", ("Phase 37", "228/228", "252/252", "threats_open: 0", "$gsd-audit-milestone")),
    "phase validation": (str(PHASE_DIR / "37-VALIDATION.md"), ("status: passed", "37-01-01", "37-02-02", "37-03-02", "37-04-02", "✅ passed")),
    "phase verification": (str(PHASE_DIR / "37-VERIFICATION.md"), ("status: passed", "score: 6/6", "228/228", "252/252", "threats_open: 0", "$gsd-audit-milestone")),
    "phase security": (str(PHASE_DIR / "37-SECURITY.md"), ("review: ASVS L1", "threats_open: 0", "T37-01", "T37-08", "high", "closed")),
    "safety evidence": (str(PHASE_DIR / "37-NOSE-SAFETY-EVIDENCE.md"), ("NOSE-10", "NOSE-11", "NOSE-12", "NOSE-13", "228/228", "252/252", "12/12", "6/6", "2/2", "noseRootNarrowing", "noseTipLift", "independent")),
}


def check_promotion_ledger(root: Path) -> Result:
    rows = ledger_rows(read(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md"))
    labels = [row[1] for row in rows]
    status_ok = len(rows) == 6 and set(labels) == set(NOSE_ROWS) and all(row[2] == "implemented" for row in rows)
    root_rows = [row for row in rows if row[1] == "山根"]
    lift_rows = [row for row in rows if row[1] == "提升"]
    evidence_ok = bool(root_rows and lift_rows and "noseRootNarrowing" in " ".join(root_rows[0]) and "noseBridge" in " ".join(root_rows[0]) and "noseTipLift" in " ".join(lift_rows[0]) and "noseTipSize" in " ".join(lift_rows[0]))
    return Result("promotion six-row ledger", status_ok and evidence_ok, f"rows={len(rows)}, implemented={sum(row[2] == 'implemented' for row in rows)}, labels={labels}")


def check_promotion_matrix(root: Path) -> Result:
    text = read(root, "docs/meitu-function-blueprint/FEATURE_MATRIX.md")
    rows = [line for line in text.splitlines() if line.startswith("|") and "| 鼻子 |" in line]
    required = (*NOSE_FIELDS, *NOSE_ROWS, "implemented", "SDK-core", "Demo", "device", "commercial", "packaging", "launch")
    ok = len(rows) == 1 and all(token in rows[0] for token in required)
    return Result("promotion branch matrix", ok, f"nose rows={len(rows)}, required tokens={sum(token in rows[0] for token in required) if rows else 0}/{len(required)}")


def check_requirements(root: Path) -> Result:
    text = read(root, ".planning/REQUIREMENTS.md")
    ids = ("NOSE-10", "NOSE-11", "NOSE-12", "NOSE-13", "NOSE-14", "DOC-01")
    checklist = all(re.search(rf"- \[x\] \*\*{re.escape(req)}\*\*", text) for req in ids)
    trace = all(re.search(rf"\| {re.escape(req)} \| Phase 37 \| Complete \|", text) for req in ids)
    return Result("promotion requirements checklist/traceability", checklist and trace, f"checklist={checklist}, traceability={trace}")


def check_owner_specs(root: Path) -> list[Result]:
    results: list[Result] = []
    for name, (relative, tokens) in OWNER_SPECS.items():
        try:
            text = read(root, relative)
            missing = [token for token in tokens if token not in text]
            results.append(Result(f"promotion owner: {name}", not missing, "all required facts present" if not missing else f"missing {missing}"))
        except Exception as error:
            results.append(Result(f"promotion owner: {name}", False, f"blocking error: {error}"))
    return results


def check_lifecycle_nonclaims(root: Path) -> Result:
    audit_candidates = list((root / ".planning").glob("*v1.9*MILESTONE-AUDIT.md")) + list((root / ".planning").glob("v1.9-MILESTONE-AUDIT.md"))
    scoped = "\n".join(
        read(root, relative)
        for relative in (".planning/PROJECT.md", ".planning/STATE.md", "PLANS.md", str(PHASE_DIR / "37-VERIFICATION.md"))
    )
    forbidden = re.findall(r"(?i)(?:v1\.9|Phase 37).{0,80}(?:audit passed|archived|tagged|shipped|launch ready|packaging passed)", scoped)
    ok = not audit_candidates and not forbidden
    return Result("promotion lifecycle boundary", ok, "audit artifact absent; audit/archive/tag/shipping claims remain pending" if ok else f"artifacts={audit_candidates}, claims={forbidden[:3]}")


def common_checks(root: Path) -> list[Result]:
    operations = (
        ("path/scope containment", lambda: check_paths(root)),
        ("package/dependency compatibility", lambda: check_manifest(root)),
        ("public BeautyParameters inventory", lambda: check_public_inventory(root)),
        ("public/SPI raw geometry", lambda: check_public_geometry(root)),
        ("Demo/renderer facade-only imports", lambda: check_imports(root)),
        ("network/cloud active-source paths", lambda: check_network(root)),
        ("commercial active-source paths", lambda: check_commercial(root)),
        ("diagnostic raw-data leakage", lambda: check_diagnostics(root)),
        ("privacy-manifest disposition", lambda: check_privacy(root)),
        ("generated artifact containment", lambda: check_artifacts(root)),
        ("archive/worktree immutability", lambda: check_archive_worktree(root)),
    )
    return [result_from_exception(name, operation) for name, operation in operations]


def promotion_checks(root: Path) -> list[Result]:
    operations = (
        ("promotion six-row ledger", lambda: check_promotion_ledger(root)),
        ("promotion branch matrix", lambda: check_promotion_matrix(root)),
        ("promotion requirements checklist/traceability", lambda: check_requirements(root)),
    )
    results = [result_from_exception(name, operation) for name, operation in operations]
    results.extend(check_owner_specs(root))
    results.append(result_from_exception("promotion lifecycle boundary", lambda: check_lifecycle_nonclaims(root)))
    return results


def write_fixture(root: Path, relative: str, text: str) -> None:
    path = root / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def build_promotion_fixture(root: Path) -> None:
    ledger_lines = []
    for label, field, nonalias in (
        ("大小", "noseSlim", "independent"),
        ("提升", "noseTipLift", "noseTipSize independent"),
        ("鼻翼", "noseWingSlim", "independent"),
        ("山根", "noseRootNarrowing", "noseBridge independent"),
        ("鼻梁", "noseBridge", "independent"),
        ("鼻尖", "noseTipSize", "independent"),
    ):
        ledger_lines.append(f"| `鼻子` | {label} | implemented | {field} Phase 37 {nonalias} | SDK-core |")
    write_fixture(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", "\n".join(ledger_lines))
    matrix_tokens = " ".join((*NOSE_FIELDS, *NOSE_ROWS, "SDK-core Demo device commercial packaging launch"))
    write_fixture(root, "docs/meitu-function-blueprint/FEATURE_MATRIX.md", f"| Beauty shaping | 鼻子 | implemented | BeautyEffects | {matrix_tokens} |\n")
    for _name, (relative, tokens) in OWNER_SPECS.items():
        write_fixture(root, relative, "\n".join(tokens) + "\n")
    requirements = []
    for req in ("NOSE-10", "NOSE-11", "NOSE-12", "NOSE-13", "NOSE-14", "DOC-01"):
        requirements.append(f"- [x] **{req}**: complete")
        requirements.append(f"| {req} | Phase 37 | Complete | evidence |")
    write_fixture(root, ".planning/REQUIREMENTS.md", "\n".join(requirements))


def self_test() -> list[Result]:
    results: list[Result] = []

    def fake(code: int, stdout: str = "", stderr: str = "") -> Runner:
        return lambda command, cwd: subprocess.CompletedProcess(command, code, stdout, stderr)

    states = (
        ("no-match", run_search(("rg", "x"), Path("."), fake(1)).state == "no-match"),
        ("classified match", run_search(("rg", "x"), Path("."), fake(0, "guard literal\n")).state == "matches"),
        ("command error", run_search(("rg", "x"), Path("."), fake(2, stderr="boom")).state == "error"),
        ("missing tool", run_search(("rg", "x"), Path("."), fake(127, stderr="missing")).state == "error"),
    )
    for name, passed in states:
        results.append(Result(f"self-test search {name}", passed, "classified exactly"))

    with tempfile.TemporaryDirectory(prefix="phase37-default-") as temporary:
        root = Path(temporary)
        write_fixture(root, "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", "\n".join(
            f"| `鼻子` | {label} | {status} | evidence | note |"
            for label, status in (("大小", "implemented"), ("提升", "future"), ("鼻翼", "implemented"), ("山根", "partial"), ("鼻梁", "implemented"), ("鼻尖", "implemented"))
        ))
        write_fixture(root, "docs/meitu-function-blueprint/FEATURE_MATRIX.md", "| Beauty shaping | 鼻子 | partial | evidence |\n")
        positive = default_status_checks(root)
        results.append(Result("self-test default status positive", all(item.ok for item in positive), "future/partial/partial accepted"))
        ledger_path = root / "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md"
        ledger_path.write_text(ledger_path.read_text().replace("| future |", "| implemented |", 1))
        results.append(Result("self-test default premature promotion", not all(item.ok for item in default_status_checks(root)), "premature row rejected"))

    with tempfile.TemporaryDirectory(prefix="phase37-promotion-") as temporary:
        root = Path(temporary)
        build_promotion_fixture(root)
        positive = promotion_checks(root)
        results.append(Result("self-test allow-promotion positive", all(item.ok for item in positive), f"{len(positive)} owner/status/lifecycle checks passed"))

        # One deterministic failure for every promotion owner/status contract.
        mutations: list[tuple[str, str, str]] = [
            ("ledger", "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", "noseRootNarrowing"),
            ("matrix", "docs/meitu-function-blueprint/FEATURE_MATRIX.md", "noseTipLift"),
            ("requirements", ".planning/REQUIREMENTS.md", "- [x] **NOSE-13**"),
        ]
        mutations.extend((name, relative, tokens[0]) for name, (relative, tokens) in OWNER_SPECS.items())
        for name, relative, token in mutations:
            build_promotion_fixture(root)
            path = root / relative
            original = path.read_text(encoding="utf-8")
            if token not in original:
                results.append(Result(f"self-test promotion failure {name}", False, f"fixture token absent: {token}"))
                continue
            path.write_text(original.replace(token, "[BROKEN]", 1), encoding="utf-8")
            failed = not all(item.ok for item in promotion_checks(root))
            results.append(Result(f"self-test promotion failure {name}", failed, "single-owner mutation rejected"))

        build_promotion_fixture(root)
        write_fixture(root, ".planning/v1.9-MILESTONE-AUDIT.md", "status: passed\n")
        results.append(Result("self-test premature audit artifact", not check_lifecycle_nonclaims(root).ok, "audit artifact rejected"))

    with tempfile.TemporaryDirectory(prefix="phase37-path-") as temporary:
        root = Path(temporary)
        outside = root.parent / f"{root.name}-outside.txt"
        outside.write_text("outside", encoding="utf-8")
        link = root / "escape"
        link.symlink_to(outside)
        try:
            safe_file(root, "escape")
            rejected = False
        except RuntimeError:
            rejected = True
        finally:
            outside.unlink(missing_ok=True)
        results.append(Result("self-test path/scope error", rejected, "escaping symlink rejected"))

    if shutil.which("git"):
        with tempfile.TemporaryDirectory(prefix="phase37-artifact-") as temporary:
            root = Path(temporary)
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            write_fixture(root, ".gitignore", "")
            write_fixture(root, "example-images/output/tracked.png", "not-a-real-png")
            subprocess.run(["git", "add", "example-images/output/tracked.png"], cwd=root, check=True)
            artifact = check_artifacts(root)
            results.append(Result("self-test tracked/staged artifact failure", not artifact.ok, "staged generated artifact rejected"))
    else:
        results.append(Result("self-test tracked/staged artifact failure", False, "git missing"))

    return results


def print_results(mode: str, results: Sequence[Result]) -> int:
    print(f"Phase 37 nose safety boundary checker — mode={mode}")
    for item in results:
        print(f"{'PASS' if item.ok else 'FAIL'}: {item.name}: {item.detail}")
    passed = sum(item.ok for item in results)
    print(f"RESULT: {passed}/{len(results)} checks passed")
    return 0 if passed == len(results) else 1


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--self-test", action="store_true", help="run deterministic positive and adversarial fixtures")
    group.add_argument("--allow-promotion", action="store_true", help="replace only the default status guard with the full promotion-owner contract")
    parser.add_argument("--repo-root", type=Path, help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    if args.self_test:
        return print_results("self-test", self_test())
    try:
        root = locate_repo(args.repo_root or Path(__file__).parent)
    except Exception as error:
        return print_results("startup", [Result("repository discovery", False, str(error))])
    results = common_checks(root)
    if args.allow_promotion:
        results.extend(promotion_checks(root))
        mode = "allow-promotion"
    else:
        results.extend(default_status_checks(root))
        mode = "default/pre-promotion"
    return print_results(mode, results)


if __name__ == "__main__":
    sys.exit(main())
