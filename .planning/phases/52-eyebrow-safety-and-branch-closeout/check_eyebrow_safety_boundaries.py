#!/usr/bin/env python3
"""Fail-closed Phase 52 eyebrow safety, promotion, owner, and lifecycle gate.

Default mode is the pre-promotion gate.  The other public modes are deliberately
bounded to the later Phase 52 plans:

* --check-promotion validates the exact four-file product transaction.
* --check-owners validates promoted product state plus selected routed owners.
* --allow-promotion validates the complete final planning/lifecycle handoff.

The checker is read-only.  Adversarial fixtures are created only below a
TemporaryDirectory owned by --self-test.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import dataclasses
import hashlib
import importlib.util
import os
import re
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Callable, Iterable, Mapping, Sequence


PHASE_DIR = ".planning/phases/52-eyebrow-safety-and-branch-closeout"
PHASE49_CHECKER = (
    ".planning/phases/49-public-contract-and-observed-eyebrow-support/"
    "check_eyebrow_support_boundaries.py"
)
PACKAGE = "BeautySDK/Package.swift"
PACKAGE_GIT_HASH = "6f03b078816ad1f7a426e3f70d4f57503f3152e9"
PARAMETERS = "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"
CAPS = "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift"
RESOLVER = "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift"
PROVIDER = "BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift"
PIPELINE = "BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift"
RENDERER = "BeautySDK/Sources/BeautyExampleRenderer/main.swift"
STRICT_HELPER = (
    ".planning/phases/51-public-facade-eyebrow-output-evidence/"
    "check_eyebrow_renderer_outputs.py"
)
GALLERY_GENERATOR = "example-images/generate_gallery.py"
EVIDENCE = f"{PHASE_DIR}/52-EYEBROW-SAFETY-EVIDENCE.md"
REVIEW = f"{PHASE_DIR}/52-REVIEW.md"
SECURITY_RECORD = f"{PHASE_DIR}/52-SECURITY.md"
VALIDATION = f"{PHASE_DIR}/52-VALIDATION.md"

FIELDS = (
    "eyebrowYPosition",
    "eyebrowThickness",
    "eyebrowLength",
    "eyebrowSpacing",
    "eyebrowHeadSpacing",
    "eyebrowTilt",
    "eyebrowPeakDefinition",
)
TARGET_ROWS = ("上下", "粗细", "长短", "间距", "眉头间距", "倾斜", "眉峰")
BLUEPRINT_FILES = (
    "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
    "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
    "docs/meitu-function-blueprint/features/beauty-shaping/eyebrows/README.md",
    "docs/meitu-function-blueprint/features/beauty-shaping/README.md",
)
GENERATED_ROOTS = (
    "example-images/output",
    "example-images/gallery",
    "example-images/.gallery-staging",
    "example-images/.gallery-quarantine",
)
ACTIVE_SOURCE_OWNERS = {
    "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift",
    "BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift",
    "BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift",
    "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
    "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift",
}
PINNED_EVIDENCE_FILES = (
    PACKAGE,
    CAPS,
    RESOLVER,
    PROVIDER,
    PIPELINE,
    RENDERER,
    STRICT_HELPER,
    GALLERY_GENERATOR,
)
OWNER_NAMES = (
    "example",
    "architecture",
    "design",
    "security",
    "reliability",
    "product",
    "quality",
    "planning",
)
OWNER_PATHS = {
    "example": (
        "docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md",
        "example-images/README.md",
    ),
    "architecture": ("ARCHITECTURE.md",),
    "design": ("DESIGN.md",),
    "security": ("SECURITY.md",),
    "reliability": ("RELIABILITY.md",),
    "product": ("PRODUCT_SENSE.md",),
    "quality": ("QUALITY_SCORE.md",),
    "planning": (
        "PLANS.md",
        ".planning/PROJECT.md",
        ".planning/REQUIREMENTS.md",
        ".planning/ROADMAP.md",
        ".planning/STATE.md",
    ),
}
OWNER_REQUIRED = {
    "example": (
        "Phase 52", "72", "thirteen", "144", "fourteen", "13/13", "6/6",
        "21/21", "40/40", "ignored", "untracked", "unstaged", "device",
        "commercial", "packaging", "shipping", "launch",
    ),
    "architecture": (
        "Phase 52", "BeautySDK", "eyebrow", "seven", "44",
        "Face", "Chin", "Eye", "Eyebrow", "Nose", "Mouth", "no Demo",
    ),
    "design": (
        "Phase 52", "0.25", "Float.ulpOfOne", "13.45", "44", "0.5",
        "fresh", "reused", "stale", "no-face",
    ),
    "security": (
        "Phase 52", "request-scoped", "package", "raw", "persistence",
        "reflection", "aggregate", "artifact", "network", "threats_open: 0",
    ),
    "reliability": (
        "Phase 52", "fresh", "reused", "stale", "no-face", "missing",
        "malformed", "provider-empty", "concurrent", "interrupted", "13.45", "44",
    ),
    "product": (
        "Phase 52", *TARGET_ROWS, "SDK-core", "device", "commercial",
        "performance", "packaging", "shipping", "launch",
    ),
    "quality": (
        "Phase 52", "72/72", "13/13", "6/6", "21/21", "40/40", "144",
        "clean", "nyquist", "threats_open: 0",
    ),
    "planning": (
        "Phase 52", "SAFE-01", "SAFE-02", "SAFE-03", "DOC-01",
        "independent", "milestone", "audit",
    ),
}


@dataclasses.dataclass(frozen=True)
class Result:
    name: str
    ok: bool
    detail: str


@dataclasses.dataclass(frozen=True)
class SearchResult:
    state: str
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


def classify_command(
    command: Sequence[str],
    cwd: Path,
    runner: Runner = default_runner,
) -> SearchResult:
    """Classify search-like 0/1/error exit states without ambiguity."""
    try:
        completed = runner(command, cwd)
    except Exception as error:
        return SearchResult("error", (), f"runner_exception={type(error).__name__}")
    if completed.returncode == 0:
        lines = tuple(line for line in completed.stdout.splitlines() if line.strip())
        return SearchResult("matches", lines, f"matches={len(lines)}")
    if completed.returncode == 1:
        return SearchResult("no-match", (), "matches=0")
    diagnostic = completed.stderr.strip() or completed.stdout.strip() or "no diagnostic"
    return SearchResult(
        "error",
        (),
        f"exit={completed.returncode}; diagnostic={diagnostic[:120]}",
    )


def locate_repo(start: Path) -> Path:
    resolved = start.resolve(strict=True)
    for candidate in (resolved, *resolved.parents):
        if (candidate / ".git").exists() and (candidate / PACKAGE).is_file():
            return candidate
    raise RuntimeError("repository root not found")


def safe_path(root: Path, relative: str, *, directory: bool = False) -> Path:
    relative_path = Path(relative)
    if not relative or relative_path.is_absolute() or ".." in relative_path.parts:
        raise RuntimeError("unsafe repository-relative path")
    resolved_root = root.resolve(strict=True)
    current = root
    for component in relative_path.parts:
        current = current / component
        if current.is_symlink():
            raise RuntimeError("symlinked required path")
    candidate = root / relative_path
    try:
        resolved = candidate.resolve(strict=True)
    except (FileNotFoundError, RuntimeError) as error:
        raise RuntimeError("missing or unresolvable required path") from error
    if resolved == resolved_root or resolved_root not in resolved.parents:
        raise RuntimeError("required path escapes repository")
    if directory and not candidate.is_dir():
        raise RuntimeError("required directory is not a directory")
    if not directory and not candidate.is_file():
        raise RuntimeError("required file is not a regular file")
    return candidate


def read(root: Path, relative: str) -> str:
    return safe_path(root, relative).read_text(encoding="utf-8")


def sha256_path(root: Path, relative: str) -> str:
    return hashlib.sha256(safe_path(root, relative).read_bytes()).hexdigest()


def checked_result(name: str, operation: Callable[[], Result]) -> Result:
    try:
        return operation()
    except Exception as error:
        return Result(name, False, f"blocking_error={type(error).__name__}")


def phase49_module(root: Path):
    checker = safe_path(root, PHASE49_CHECKER)
    spec = importlib.util.spec_from_file_location("phase49_eyebrow_gate", checker)
    if spec is None or spec.loader is None:
        raise RuntimeError("Phase 49 classifier unavailable")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def inherited_boundary_checks(root: Path) -> list[Result]:
    """Compose current Phase 49 classifications, excluding superseded live modes."""
    module = phase49_module(root)
    operations = (
        ("path/scope containment", lambda: module.check_paths(root)),
        ("manifest/Demo baseline", lambda: module.check_baseline(root)),
        ("public BeautyParameters inventory", lambda: module.check_public_inventory(root)),
        ("public/SPI eyebrow geometry", lambda: module.check_public_geometry(root)),
        ("Codable/persistence allowlist", lambda: module.check_codable_persistence(root)),
        ("raw diagnostic leakage", lambda: module.check_diagnostics(root)),
        ("network/cloud active-source paths", lambda: module.check_network(root)),
        ("Demo/renderer facade-only imports", lambda: module.check_imports(root)),
        ("semantic model/resource prohibition", lambda: module.check_models(root)),
        ("resource-manifest baseline", lambda: module.check_resource_manifests(root)),
        ("bundled preset byte/key neutrality", lambda: module.check_presets(root)),
        ("generated artifact containment", lambda: module.check_artifacts(root)),
        ("actual eyebrow source provenance", lambda: module.check_eyebrow_source_provenance(root)),
    )
    converted: list[Result] = []
    for name, operation in operations:
        item = checked_result(
            name,
            lambda operation=operation: _convert_result(operation()),
        )
        converted.append(item)
    return converted


def _convert_result(item: object) -> Result:
    return Result(str(item.name), bool(item.ok), str(item.detail))


def package_manifest_gate(root: Path, runner: Runner = default_runner) -> Result:
    completed = runner(("git", "hash-object", PACKAGE), root)
    current = completed.stdout.strip() if completed.returncode == 0 else ""
    text = read(root, PACKAGE)
    forbidden = re.findall(
        r"\.(?:package|binaryTarget|systemLibrary)\s*\(|"
        r"\b(?:url|path)\s*:\s*\"(?:https?://|\.\./)",
        text,
    )
    ok = (
        completed.returncode == 0
        and current == PACKAGE_GIT_HASH
        and not forbidden
        and text.count(".executableTarget(") == 1
        and text.count(".target(") == 6
    )
    return Result(
        "package manifest pin/dependency scope",
        ok,
        f"hash_match={int(current == PACKAGE_GIT_HASH)}; forbidden={len(forbidden)}; "
        f"targets=6+1:{text.count('.target(')}/{text.count('.executableTarget(')}",
    )


def active_source_gate(root: Path, runner: Runner = default_runner) -> Result:
    pattern = "|".join((*FIELDS, "EyebrowWarpProvider", "BeautyObservedEyebrowSupport",
                        "BeautyEyebrowSemanticSupport"))
    outcome = classify_command(
        ("rg", "-l", pattern, "BeautySDK/Sources", "BeautyDemo/BeautyDemo"),
        root,
        runner,
    )
    if outcome.state != "matches":
        return Result("eyebrow active-source ownership", False, outcome.detail)
    observed = {line.strip() for line in outcome.lines}
    return Result(
        "eyebrow active-source ownership",
        observed == ACTIVE_SOURCE_OWNERS,
        f"owners={len(observed)}/{len(ACTIVE_SOURCE_OWNERS)}; "
        f"unclassified={len(observed - ACTIVE_SOURCE_OWNERS)}; "
        f"missing={len(ACTIVE_SOURCE_OWNERS - observed)}",
    )


def final_source_gate(root: Path) -> Result:
    caps = read(root, CAPS)
    resolver = read(root, RESOLVER)
    provider = read(root, PROVIDER)
    pipeline = read(root, PIPELINE)
    parameters = read(root, PARAMETERS)
    failures: list[str] = []
    declarations = re.findall(
        r"^\s*static let (eyebrow[A-Za-z]+): Float = 0\.25\s*$",
        caps,
        re.MULTILINE,
    )
    if tuple(declarations) != FIELDS:
        failures.append(f"cap_declarations={len(declarations)}/7")
    for field in FIELDS:
        if provider.count(f"BeautySafetyCaps.{field}") != 1:
            failures.append(f"{field}:authority_refs")
    if "provisional" in caps.lower() or "provisional" in provider.lower():
        failures.append("provisional_wording")
    if resolver.count("0..<44") != 1:
        failures.append("retained_loop")
    if len(re.findall(r"^\s*public var [A-Za-z][A-Za-z0-9]*:", parameters, re.MULTILINE)) != 59:
        failures.append("public_inventory")
    ordered = (
        "FaceShapeWarpProvider",
        "ChinWarpProvider",
        "EyeWarpProvider",
        "EyebrowWarpProvider",
        "NoseWarpProvider",
        "MouthWarpProvider",
    )
    positions = [pipeline.find(name) for name in ordered]
    if any(position < 0 for position in positions) or positions != sorted(positions):
        failures.append("provider_order")
    if pipeline.count("EyebrowWarpProvider") != 1:
        failures.append("eyebrow_dispatch_count")
    for token in ("eyebrow_inputs_missing", "skippedEyebrowDomains"):
        if token not in resolver:
            failures.append(f"missing:{token}")
    return Result(
        "final cap/convergence/provider source",
        not failures,
        "caps=7/7; authority=7/7; stored=59; loop=0..<44; dispatch=exact"
        if not failures else "; ".join(failures),
    )


def negative_active_scope_gate(root: Path, runner: Runner = default_runner) -> Result:
    pattern = (
        r"URLSession|import Network|CloudKit|Alamofire|RevenueCat|WebSocket|"
        r"NWConnection|StoreKit|Subscription|Entitlement|VIP|Payment|"
        r"eyebrow.*(?:UserDefaults|FileManager|Codable|Encodable|Decodable|Mirror)|"
        r"(?:UserDefaults|FileManager|Codable|Encodable|Decodable|Mirror).*eyebrow"
    )
    outcome = classify_command(
        ("rg", "-n", "--no-heading", "--color", "never", pattern,
         "BeautySDK/Sources", "BeautyDemo/BeautyDemo"),
        root,
        runner,
    )
    ok = outcome.state == "no-match"
    return Result(
        "reflection/network/cloud/commercial scope",
        ok,
        "classified=0; unclassified=0" if ok else outcome.detail,
    )


def fixture_policy_gate(root: Path) -> Result:
    failures: list[str] = []
    portrait = safe_path(root, "example-images/input/portraits/e6.jpg")
    if portrait.is_symlink() or portrait.stat().st_size <= 0 or not os.access(portrait, os.R_OK):
        failures.append("e6")
    for stem in ("e1", "e2", "e3", "e4", "e5"):
        parked = root / f"example-images/parked-portraits/{stem}.png"
        active = root / f"example-images/input/portraits/{stem}.png"
        if (not parked.is_file()) or parked.is_symlink() or active.exists():
            failures.append(stem)
    return Result(
        "sole e6/parked portrait policy",
        not failures,
        "active=1; parked=5; symlinks=0" if not failures else f"invalid={failures}",
    )


def artifact_gate(root: Path, runner: Runner = default_runner) -> Result:
    for relative in GENERATED_ROOTS:
        candidate = root / relative
        if candidate.is_symlink():
            return Result("generated artifact containment", False, "symlinked_root=1")
        if candidate.exists() and not candidate.is_dir():
            return Result("generated artifact containment", False, "non_directory_root=1")
    commands = (
        ("git", "ls-files", "--", *GENERATED_ROOTS),
        ("git", "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS),
        ("git", "ls-files", "--others", "--exclude-standard", "--", *GENERATED_ROOTS),
    )
    results = [runner(command, root) for command in commands]
    if any(item.returncode != 0 for item in results):
        return Result("generated artifact containment", False, "git_command_error=1")
    ignored = []
    ignore_errors = 0
    for relative in GENERATED_ROOTS:
        completed = runner(
            ("git", "check-ignore", "-q", f"{relative}/phase52-probe.png"),
            root,
        )
        ignored.append(completed.returncode == 0)
        if completed.returncode not in (0, 1):
            ignore_errors += 1
    tracked, staged, nonignored = (
        tuple(line for line in item.stdout.splitlines() if line.strip())
        for item in results
    )
    residue = sum(
        1
        for relative in GENERATED_ROOTS[2:]
        if (root / relative).exists()
        and any((root / relative).iterdir())
    )
    ok = (
        not tracked and not staged and not nonignored
        and all(ignored) and ignore_errors == 0 and residue == 0
    )
    return Result(
        "generated artifact containment",
        ok,
        f"tracked={len(tracked)}; staged={len(staged)}; "
        f"nonignored={len(nonignored)}; ignored={sum(ignored)}/4; "
        f"residue={residue}; errors={ignore_errors}",
    )


def table_rows(text: str) -> list[list[str]]:
    return [
        [cell.strip().strip("`") for cell in line.strip().strip("|").split("|")]
        for line in text.splitlines()
        if line.lstrip().startswith("|")
    ]


def product_status_gate(root: Path, promoted: bool) -> Result:
    failures: list[str] = []
    expected = "implemented" if promoted else "future"
    ledger = read(root, BLUEPRINT_FILES[0])
    for name in TARGET_ROWS:
        found = [
            row for row in table_rows(ledger)
            if len(row) >= 4 and row[0] == "眉毛" and row[1] == name
        ]
        if len(found) != 1 or found[0][2] != expected:
            failures.append(f"{name}:{len(found)}:{found[0][2] if found else 'missing'}")
        elif promoted and not all(
            token in " ".join(found[0][3:])
            for token in ("Phase 49", "Phase 50", "Phase 51", "Phase 52")
        ):
            failures.append(f"{name}:lineage")
    matrix_rows = [
        row for row in table_rows(read(root, BLUEPRINT_FILES[1]))
        if len(row) >= 3 and row[0] == "Beauty shaping" and row[1] == "眉毛"
    ]
    if len(matrix_rows) != 1 or matrix_rows[0][2] != expected:
        failures.append("matrix_status")
    for relative in BLUEPRINT_FILES[2:]:
        text = read(root, relative)
        if promoted:
            if "Phase 52" not in text or not re.search(r"(?i)status[^\n]*implemented", text):
                failures.append(f"{relative}:implemented")
            if "SDK-core" not in text:
                failures.append(f"{relative}:sdk_core")
        elif not re.search(r"(?i)(?:status[^\n]*`?future|眉毛`?\s*\|\s*future)", text):
            failures.append(f"{relative}:future")
    return Result(
        "exact eyebrow row/branch status",
        not failures,
        (
            "seven rows and SDK-core branch promoted"
            if promoted else "seven rows and branch unpromoted"
        ) if not failures else "; ".join(failures),
    )


def exact_promotion_worktree_gate(root: Path, runner: Runner = default_runner) -> Result:
    completed = runner(("git", "diff", "--name-only", "--", *BLUEPRINT_FILES), root)
    untracked = runner(
        ("git", "ls-files", "--others", "--exclude-standard", "--", *BLUEPRINT_FILES),
        root,
    )
    if completed.returncode != 0 or untracked.returncode != 0:
        return Result("exact four-owner transaction", False, "git_command_error=1")
    observed = {
        line for line in (*completed.stdout.splitlines(), *untracked.stdout.splitlines())
        if line.strip()
    }
    return Result(
        "exact four-owner transaction",
        observed == set(BLUEPRINT_FILES),
        f"files={len(observed)}/4; extra={len(observed - set(BLUEPRINT_FILES))}; "
        f"missing={len(set(BLUEPRINT_FILES) - observed)}",
    )


def parse_hash_rows(text: str) -> dict[str, str]:
    rows: dict[str, str] = {}
    for line in text.splitlines():
        match = re.match(r"^\| `([^`]+)` \| `([0-9a-f]{64})` \|$", line)
        if match:
            rows[match.group(1)] = match.group(2)
    return rows


def evidence_content_gate(
    evidence: str,
    current_hashes: Mapping[str, str],
) -> Result:
    required = (
        "status: passed",
        "72/72",
        "13/13 visibility",
        "6/6 signed direction",
        "21/21",
        "40/40",
        "thirteen separate no-face",
        "144",
        "Visual review verdict: PASS",
        "focused_suites: 8/8",
        "full_swiftpm_failures: 0",
        "strict_helper_exit: 0",
        "gallery_exit: 0",
        "checker_default_exit: 0",
        "SAFE-01",
        "SAFE-02",
        "SAFE-03",
    )
    missing = [token for token in required if token not in evidence]
    visual_rows = len(re.findall(
        r"^\| `e6__(?:geometryBaseline_noop|eyebrow[^`]*)\.png` \|",
        evidence,
        re.MULTILINE,
    ))
    recorded_hashes = parse_hash_rows(evidence)
    missing_hashes = set(current_hashes) - set(recorded_hashes)
    stale = [
        relative for relative, digest in current_hashes.items()
        if recorded_hashes.get(relative) != digest
    ]
    ok = not missing and visual_rows == 14 and not missing_hashes and not stale
    return Result(
        "fresh runtime/output/visual evidence",
        ok,
        f"missing_tokens={len(missing)}; visual_rows={visual_rows}/14; "
        f"hashes={len(recorded_hashes)}/{len(current_hashes)}; stale={len(stale)}",
    )


def governance_gate(root: Path) -> list[Result]:
    hashes = {relative: sha256_path(root, relative) for relative in PINNED_EVIDENCE_FILES}
    evidence = checked_result(
        "fresh runtime/output/visual evidence",
        lambda: evidence_content_gate(read(root, EVIDENCE), hashes),
    )
    review = checked_result(
        "standard review",
        lambda: _review_gate(read(root, REVIEW)),
    )
    security = checked_result(
        "ASVS L1/STRIDE closure",
        lambda: _security_gate(read(root, SECURITY_RECORD)),
    )
    validation = checked_result(
        "fourteen-task Nyquist ledger",
        lambda: _validation_gate(read(root, VALIDATION)),
    )
    return [evidence, review, security, validation]


def _review_gate(text: str) -> Result:
    high_open = bool(re.search(
        r"(?im)^\|[^\n]*\bHIGH\b[^\n]*\b(?:open|unresolved|blocked)\b",
        text,
    ))
    unclassified = bool(re.search(r"(?im)^unclassified_(?:matches|assumptions): [1-9]", text))
    ok = "status: clean" in text and not high_open and not unclassified
    return Result(
        "standard review",
        ok,
        f"clean={int('status: clean' in text)}; high_open={int(high_open)}; "
        f"unclassified={int(unclassified)}",
    )


def _security_gate(text: str) -> Result:
    open_threat = bool(re.search(r"(?im)^\| T-52-[^\n]*\|\s*open\s*\|", text))
    high_open = bool(re.search(
        r"(?im)^\|[^\n]*\bHIGH\b[^\n]*\b(?:open|unresolved|blocked)\b",
        text,
    ))
    ok = (
        "asvs_level: 1" in text
        and "threats_open: 0" in text
        and not open_threat
        and not high_open
        and all(f"T-52-{number:02d}" in text for number in range(1, 35))
        and "T-52-SC" in text
    )
    return Result(
        "ASVS L1/STRIDE closure",
        ok,
        f"asvs={int('asvs_level: 1' in text)}; zero_open="
        f"{int('threats_open: 0' in text)}; open_rows={int(open_threat or high_open)}",
    )


def _validation_gate(text: str) -> Result:
    expected_ids = tuple(
        f"52-{plan:02d}-{task:02d}"
        for plan, task_count in (
            (1, 3), (2, 2), (3, 3), (4, 2), (5, 2),
            (6, 2), (7, 3), (8, 2), (9, 2), (10, 2),
        )
        for task in range(1, task_count + 1)
    )
    task_rows = re.findall(r"^\| (52-\d{2}-\d{2}) \|", text, re.MULTILINE)
    completed_ids = expected_ids[:19]
    future_ids = expected_ids[19:]
    green_ids = {
        match.group(1) for match in re.finditer(
            r"^\| (52-\d{2}-\d{2}) \|[^\n]*\|\s*✅ green(?:[^|]*)\s*\|$",
            text,
            re.MULTILINE,
        )
    }
    pending_ids = {
        match.group(1) for match in re.finditer(
            r"^\| (52-\d{2}-\d{2}) \|[^\n]*\|\s*⬜ pending(?:[^|]*)\s*\|$",
            text,
            re.MULTILINE,
        )
    }
    active_ledger = (
        "status: in_progress" in text
        and green_ids == set(completed_ids)
        and pending_ids == set(future_ids)
    )
    complete_ledger = (
        "status: complete" in text
        and green_ids == set(completed_ids + future_ids)
        and not pending_ids
    )
    ok = (
        len(task_rows) == 23
        and tuple(task_rows) == expected_ids
        and len(set(task_rows)) == 23
        and (active_ledger or complete_ledger)
        and "nyquist_compliant: true" in text
        and "wave_0_complete: true" in text
        and "task_coverage: 23/23" in text
    )
    return Result(
        "twenty-three-task Nyquist ledger",
        ok,
        f"tasks={len(task_rows)}/23; green={len(green_ids)}; "
        f"pending={len(pending_ids)}; active_or_complete={int(active_ledger or complete_ledger)}; "
        f"nyquist={int('nyquist_compliant: true' in text)}",
    )


def owner_section(text: str) -> str:
    matches = list(re.finditer(r"(?im)^#{1,4}[^\n]*(?:Phase 52|v1\.13)[^\n]*$", text))
    return text[matches[-1].start():] if matches else text


def owner_gate(root: Path, name: str) -> Result:
    failures: list[str] = []
    combined = ""
    for relative in OWNER_PATHS[name]:
        section = owner_section(read(root, relative))
        combined += "\n" + section
        if "Phase 52" not in section and "v1.13" not in section:
            failures.append(f"{relative}:phase_section")
    missing = [token for token in OWNER_REQUIRED[name] if token not in combined]
    if missing:
        failures.append(f"group_missing={len(missing)}")
    affirmative_overclaim = re.search(
        r"(?im)^(?:status:\s*(?:audited|archived|released|shipped)|"
        r"[^\n]*v1\.13[^\n]*(?:audit passed|audit complete|archived as|"
        r"tagged v1\.13|shipping complete|launch-ready))",
        combined,
    )
    if affirmative_overclaim:
        failures.append("lifecycle_overclaim")
    return Result(
        f"owner:{name}",
        not failures,
        "required routed facts and nonclaims present"
        if not failures else " | ".join(failures),
    )


def planning_final_gate(root: Path) -> Result:
    requirements = read(root, ".planning/REQUIREMENTS.md")
    roadmap = read(root, ".planning/ROADMAP.md")
    verification = read(root, f"{PHASE_DIR}/52-VERIFICATION.md")
    failures: list[str] = []
    for identifier in ("SAFE-01", "SAFE-02", "SAFE-03", "DOC-01"):
        if not re.search(rf"^- \[x\] \*\*{identifier}\*\*", requirements, re.MULTILINE):
            failures.append(identifier)
    plans = re.findall(r"^- \[x\] 52-(?:0[1-9]|10)-PLAN\.md", roadmap, re.MULTILINE)
    if len(plans) != 10:
        failures.append(f"plans={len(plans)}/10")
    independent_attribution = bool(re.search(
        r"(?im)^_Verifier:[^\n]*gsd-verifier[^\n]*_$",
        verification,
    ))
    if not re.search(r"(?m)^status:\s*gaps_found\s*$", verification):
        failures.append("verification")
    if not independent_attribution:
        failures.append("verification_attribution")
    if not re.search(r"(?i)independent.*milestone.*audit", verification):
        failures.append("audit_handoff")
    return Result(
        "planning completion/audit handoff",
        not failures,
        "requirements=4/4; plans=10/10; verification=pending-independent; audit=pending"
        if not failures else "; ".join(failures),
    )


def lifecycle_gate(root: Path, runner: Runner = default_runner) -> Result:
    tags = runner(("git", "tag", "--list", "v1.13*"), root)
    audits = list((root / ".planning").glob("*v1.13*MILESTONE-AUDIT.md"))
    owners = "\n".join(read(root, relative) for relative in (
        "PLANS.md", ".planning/PROJECT.md", ".planning/STATE.md",
    ))
    affirmative = re.search(
        r"(?im)^[^\n]*v1\.13[^\n]*(?:audit passed|audit complete|"
        r"archived as|tagged v1\.13|shipping complete|launch-ready)",
        owners,
    )
    ok = tags.returncode == 0 and not tags.stdout.strip() and not audits and affirmative is None
    return Result(
        "lifecycle/audit nonclaim",
        ok,
        "independent audit, archive, tag, and cleanup remain separate"
        if ok else "premature audit/tag/lifecycle claim",
    )


def live_checks(root: Path, promoted: bool) -> list[Result]:
    results = inherited_boundary_checks(root)
    operations = (
        ("package manifest pin/dependency scope", lambda: package_manifest_gate(root)),
        ("eyebrow active-source ownership", lambda: active_source_gate(root)),
        ("final cap/convergence/provider source", lambda: final_source_gate(root)),
        ("reflection/network/cloud/commercial scope", lambda: negative_active_scope_gate(root)),
        ("sole e6/parked portrait policy", lambda: fixture_policy_gate(root)),
        ("generated artifact containment", lambda: artifact_gate(root)),
        ("exact eyebrow row/branch status", lambda: product_status_gate(root, promoted)),
    )
    results.extend(checked_result(name, operation) for name, operation in operations)
    return results


def write_fixture(root: Path, relative: str, text: str) -> Path:
    target = root / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")
    return target


def build_source_fixture(root: Path) -> None:
    caps = "\n".join(f"static let {field}: Float = 0.25" for field in FIELDS) + "\n"
    provider = "\n".join(
        f"let {field}Cap = BeautySafetyCaps.{field}" for field in FIELDS
    ) + "\n"
    resolver = "0..<44\neyebrow_inputs_missing\nskippedEyebrowDomains\n"
    parameters = "\n".join(
        f"public var field{index}: Float" for index in range(52)
    ) + "\n" + "\n".join(f"public var {field}: Float" for field in FIELDS) + "\n"
    pipeline = "\n".join((
        "FaceShapeWarpProvider",
        "ChinWarpProvider",
        "EyeWarpProvider",
        "EyebrowWarpProvider",
        "NoseWarpProvider",
        "MouthWarpProvider",
    )) + "\n"
    write_fixture(root, CAPS, caps)
    write_fixture(root, PROVIDER, provider)
    write_fixture(root, RESOLVER, resolver)
    write_fixture(root, PARAMETERS, parameters)
    write_fixture(root, PIPELINE, pipeline)


def build_status_fixture(root: Path, promoted: bool) -> None:
    status = "implemented" if promoted else "future"
    lineage = "Phase 49 Phase 50 Phase 51 Phase 52" if promoted else "None."
    ledger = "| `眉毛` | `IMG_0864.PNG`, `IMG_0865.PNG` | taxonomy inventory |\n" + "\n".join(
        f"| `眉毛` | {name} | {status} | {lineage} | scoped |"
        for name in TARGET_ROWS
    ) + "\n"
    write_fixture(root, BLUEPRINT_FILES[0], ledger)
    write_fixture(
        root,
        BLUEPRINT_FILES[1],
        f"| Beauty shaping | 眉毛 | {status} | SDK-core Phase 49 Phase 50 Phase 51 Phase 52 |\n",
    )
    for relative in BLUEPRINT_FILES[2:]:
        body = (
            "## Phase 52\nStatus: `implemented` at SDK-core scope.\n"
            if promoted else
            "## Boundary\nStatus: `future`.\n"
        )
        write_fixture(root, relative, body)


def self_test(root: Path) -> int:
    failures: list[str] = []
    checks = 0

    def require(condition: bool, label: str) -> None:
        nonlocal checks
        checks += 1
        if not condition:
            failures.append(label)

    def fake(code: int, stdout: str = "", stderr: str = "") -> Runner:
        return lambda _command, _cwd: subprocess.CompletedProcess(
            _command, code, stdout, stderr,
        )

    # Re-run the inherited adversarial classifier suite, not its superseded live mode.
    try:
        inherited_self_tests = phase49_module(root).self_test()
        for item in inherited_self_tests:
            require(bool(item.ok), f"inherited:{item.name}")
    except Exception as error:
        require(False, f"inherited self-test exception:{type(error).__name__}")

    # Search and tool-state classification.
    require(classify_command(("rg", "x"), root, fake(0, "a\n")).state == "matches", "match state")
    require(classify_command(("rg", "x"), root, fake(1)).state == "no-match", "no-match state")
    require(classify_command(("rg", "x"), root, fake(2, stderr="boom")).state == "error", "error state")
    require(classify_command(("rg", "x"), root, fake(127, stderr="missing")).state == "error", "missing tool state")
    require(
        classify_command(
            ("rg", "x"),
            root,
            lambda _c, _d: (_ for _ in ()).throw(OSError("missing")),
        ).state == "error",
        "runner exception state",
    )

    # Repository path containment.
    with tempfile.TemporaryDirectory(prefix="phase52-path-") as temporary:
        fixture = Path(temporary)
        write_fixture(fixture, "inside.txt", "ok")
        require(safe_path(fixture, "inside.txt").is_file(), "safe path positive")
        for unsafe in ("/tmp/absolute", "../escape", "missing.txt"):
            try:
                safe_path(fixture, unsafe)
                rejected = False
            except RuntimeError:
                rejected = True
            require(rejected, f"unsafe path accepted:{unsafe}")
        outside = fixture.parent / f"{fixture.name}-outside"
        outside.write_text("outside", encoding="utf-8")
        (fixture / "link").symlink_to(outside)
        try:
            safe_path(fixture, "link")
            rejected = False
        except RuntimeError:
            rejected = True
        require(rejected, "symlink escape accepted")
        outside.unlink(missing_ok=True)

    # Final source authority and every independently mutable requirement.
    with tempfile.TemporaryDirectory(prefix="phase52-source-") as temporary:
        fixture = Path(temporary)
        build_source_fixture(fixture)
        require(final_source_gate(fixture).ok, "source positive")
        cap_path = fixture / CAPS
        clean_caps = cap_path.read_text(encoding="utf-8")
        for field in FIELDS:
            cap_path.write_text(
                clean_caps.replace(f"{field}: Float = 0.25", f"{field}: Float = 0.24"),
                encoding="utf-8",
            )
            require(not final_source_gate(fixture).ok, f"cap mutation:{field}")
        cap_path.write_text(clean_caps + "// provisional\n", encoding="utf-8")
        require(not final_source_gate(fixture).ok, "provisional accepted")
        cap_path.write_text(clean_caps, encoding="utf-8")
        resolver_path = fixture / RESOLVER
        clean_resolver = resolver_path.read_text(encoding="utf-8")
        resolver_path.write_text(clean_resolver.replace("0..<44", "0..<43"), encoding="utf-8")
        require(not final_source_gate(fixture).ok, "loop mutation accepted")
        resolver_path.write_text(clean_resolver, encoding="utf-8")
        pipeline_path = fixture / PIPELINE
        clean_pipeline = pipeline_path.read_text(encoding="utf-8")
        pipeline_path.write_text(clean_pipeline.replace("EyebrowWarpProvider\n", ""), encoding="utf-8")
        require(not final_source_gate(fixture).ok, "dispatch omission accepted")
        pipeline_path.write_text(
            clean_pipeline.replace(
                "EyeWarpProvider\nEyebrowWarpProvider",
                "EyebrowWarpProvider\nEyeWarpProvider",
            ),
            encoding="utf-8",
        )
        require(not final_source_gate(fixture).ok, "dispatch order accepted")
        exact = "\n".join(sorted(ACTIVE_SOURCE_OWNERS)) + "\n"
        require(active_source_gate(fixture, fake(0, exact)).ok, "active source positive")
        require(
            not active_source_gate(fixture, fake(0, exact + "BeautyDemo/BeautyDemo/Escape.swift\n")).ok,
            "unclassified owner accepted",
        )
        require(not active_source_gate(fixture, fake(1)).ok, "source no-match accepted")
        require(not active_source_gate(fixture, fake(2, stderr="error")).ok, "source error accepted")

    # Package pin, negative active scope, and the sole portrait policy.
    with tempfile.TemporaryDirectory(prefix="phase52-scope-") as temporary:
        fixture = Path(temporary)
        package = write_fixture(fixture, PACKAGE, read(root, PACKAGE))
        require(package_manifest_gate(fixture).ok, "package manifest positive")
        package.write_text(package.read_text(encoding="utf-8") + "\n.package(url: \"https://invalid\")\n",
                           encoding="utf-8")
        require(not package_manifest_gate(fixture).ok, "package/dependency mutation accepted")
        source = write_fixture(
            fixture,
            "BeautySDK/Sources/BeautyEffects/Clean.swift",
            "let localOnly = true\n",
        )
        write_fixture(fixture, "BeautyDemo/BeautyDemo/App.swift", "import BeautySDK\n")
        require(negative_active_scope_gate(fixture).ok, "negative active scope positive")
        source.write_text("let task = URLSession.shared\n", encoding="utf-8")
        require(not negative_active_scope_gate(fixture).ok, "network mutation accepted")
        source.write_text("let eyebrowMirror = Mirror(reflecting: eyebrowSupport)\n",
                          encoding="utf-8")
        require(not negative_active_scope_gate(fixture).ok, "reflection mutation accepted")
        portrait = fixture / "example-images/input/portraits/e6.jpg"
        portrait.parent.mkdir(parents=True, exist_ok=True)
        portrait.write_bytes(b"e6")
        parked = fixture / "example-images/parked-portraits"
        parked.mkdir(parents=True, exist_ok=True)
        for stem in ("e1", "e2", "e3", "e4", "e5"):
            (parked / f"{stem}.png").write_bytes(stem.encode("ascii"))
        require(fixture_policy_gate(fixture).ok, "fixture policy positive")
        (parked / "e3.png").unlink()
        require(not fixture_policy_gate(fixture).ok, "partial parked policy accepted")

    # Pre/post-promotion status and exact premature/extra mutations.
    with tempfile.TemporaryDirectory(prefix="phase52-status-") as temporary:
        fixture = Path(temporary)
        build_status_fixture(fixture, False)
        require(product_status_gate(fixture, False).ok, "pre-promotion positive")
        ledger = fixture / BLUEPRINT_FILES[0]
        clean = ledger.read_text(encoding="utf-8")
        for name in TARGET_ROWS:
            ledger.write_text(
                clean.replace(f"| `眉毛` | {name} | future", f"| `眉毛` | {name} | implemented"),
                encoding="utf-8",
            )
            require(not product_status_gate(fixture, False).ok, f"premature row:{name}")
        ledger.write_text(clean, encoding="utf-8")
        matrix = fixture / BLUEPRINT_FILES[1]
        clean_matrix = matrix.read_text(encoding="utf-8")
        matrix.write_text(clean_matrix.replace("| future |", "| implemented |"), encoding="utf-8")
        require(not product_status_gate(fixture, False).ok, "premature branch")
        build_status_fixture(fixture, True)
        require(product_status_gate(fixture, True).ok, "promotion positive")
        ledger = fixture / BLUEPRINT_FILES[0]
        ledger.write_text(
            ledger.read_text(encoding="utf-8")
            + "| `眉毛` | 额外 | implemented | Phase 49 Phase 50 Phase 51 Phase 52 | scoped |\n",
            encoding="utf-8",
        )
        # The exact target set remains valid; broader rows must be rejected by an explicit scan.
        extra_rows = [
            row for row in table_rows(ledger.read_text(encoding="utf-8"))
            if len(row) >= 3 and row[0] == "眉毛" and row[1] not in TARGET_ROWS
        ]
        require(bool(extra_rows), "extra-row fixture did not mutate")
        require(not _exact_eyebrow_taxonomy(ledger.read_text(encoding="utf-8")).ok, "extra row accepted")
        exact_diff = "\n".join(BLUEPRINT_FILES) + "\n"
        require(
            exact_promotion_worktree_gate(fixture, fake(0, exact_diff)).ok,
            "exact promotion diff positive",
        )
        require(
            not exact_promotion_worktree_gate(
                fixture,
                fake(0, exact_diff + "PLANS.md\n"),
            ).ok,
            "extra promotion file accepted",
        )

    # Artifact command errors, tracked/staged/non-ignored files, and ignore ambiguity.
    with tempfile.TemporaryDirectory(prefix="phase52-artifact-") as temporary:
        artifact_root = Path(temporary)
        empty_git = fake(0)
        require(artifact_gate(artifact_root, empty_git).ok, "artifact fake positive")
        require(
            not artifact_gate(artifact_root, fake(2, stderr="error")).ok,
            "artifact command error accepted",
        )
        call_count = 0

        def tracked_runner(command: Sequence[str], cwd: Path) -> subprocess.CompletedProcess[str]:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                return subprocess.CompletedProcess(command, 0, "example-images/output/x.png\n", "")
            return subprocess.CompletedProcess(command, 0, "", "")

        require(not artifact_gate(artifact_root, tracked_runner).ok, "tracked artifact accepted")
        call_count = 0

        def staged_runner(command: Sequence[str], cwd: Path) -> subprocess.CompletedProcess[str]:
            nonlocal call_count
            call_count += 1
            if call_count == 2:
                return subprocess.CompletedProcess(command, 0, "example-images/output/x.png\n", "")
            return subprocess.CompletedProcess(command, 0, "", "")

        require(not artifact_gate(artifact_root, staged_runner).ok, "staged artifact accepted")
        call_count = 0

        def nonignored_runner(command: Sequence[str], cwd: Path) -> subprocess.CompletedProcess[str]:
            nonlocal call_count
            call_count += 1
            if call_count == 3:
                return subprocess.CompletedProcess(command, 0, "example-images/output/x.png\n", "")
            return subprocess.CompletedProcess(command, 0, "", "")

        require(
            not artifact_gate(artifact_root, nonignored_runner).ok,
            "nonignored artifact accepted",
        )
        call_count = 0

        def not_ignored_runner(command: Sequence[str], cwd: Path) -> subprocess.CompletedProcess[str]:
            nonlocal call_count
            call_count += 1
            if call_count > 3:
                return subprocess.CompletedProcess(command, 1, "", "")
            return subprocess.CompletedProcess(command, 0, "", "")

        require(
            not artifact_gate(artifact_root, not_ignored_runner).ok,
            "non-ignored root accepted",
        )

    # Evidence freshness, partial rows, review, security, and validation fail closed.
    with tempfile.TemporaryDirectory(prefix="phase52-evidence-") as temporary:
        fixture = Path(temporary)
        hashes = {"a": "a" * 64, "b": "b" * 64}
        rows = "\n".join(f"| `{path}` | `{digest}` |" for path, digest in hashes.items())
        visual = "\n".join(
            f"| `e6__{'geometryBaseline_noop' if index == 0 else f'eyebrow{index}'}.png` | reviewed |"
            for index in range(14)
        )
        evidence = (
            "status: passed\n72/72\n13/13 visibility\n6/6 signed direction\n"
            "21/21\n40/40\nthirteen separate no-face\n144\n"
            "Visual review verdict: PASS\nfocused_suites: 8/8\n"
            "full_swiftpm_failures: 0\nstrict_helper_exit: 0\ngallery_exit: 0\n"
            "checker_default_exit: 0\nSAFE-01 SAFE-02 SAFE-03\n"
            f"{rows}\n{visual}\n"
        )
        require(evidence_content_gate(evidence, hashes).ok, "evidence positive")
        require(
            not evidence_content_gate(evidence.replace("a" * 64, "c" * 64), hashes).ok,
            "stale hash accepted",
        )
        require(
            not evidence_content_gate(evidence.replace(visual.splitlines()[-1] + "\n", ""), hashes).ok,
            "partial visual evidence accepted",
        )
        require(_review_gate("status: clean\nunclassified_matches: 0\n").ok, "review positive")
        require(not _review_gate("status: clean\nunclassified_matches: 1\n").ok, "unclassified review")
        security = (
            "asvs_level: 1\nthreats_open: 0\nT-52-SC\n"
            + "\n".join(f"T-52-{number:02d}" for number in range(1, 35))
        )
        require(_security_gate(security).ok, "security positive")
        require(not _security_gate(security.replace("threats_open: 0", "threats_open: 1")).ok,
                "open security accepted")
        validation_ids = tuple(
            f"52-{plan:02d}-{task:02d}"
            for plan, task_count in (
                (1, 3), (2, 2), (3, 3), (4, 2), (5, 2),
                (6, 2), (7, 3), (8, 2), (9, 2), (10, 2),
            )
            for task in range(1, task_count + 1)
        )
        validation_rows = "\n".join(
            f"| {task_id} | x | ✅ green |" for task_id in validation_ids
        )
        validation = (
            "status: complete\nnyquist_compliant: true\nwave_0_complete: true\n"
            "task_coverage: 23/23\n"
            + validation_rows + "\n"
        )
        require(_validation_gate(validation).ok, "complete validation positive")
        active_rows = "\n".join(
            f"| {task_id} | x | {'✅ green' if index < 19 else '⬜ pending'} |"
            for index, task_id in enumerate(validation_ids)
        )
        active_validation = (
            "status: in_progress\nnyquist_compliant: true\nwave_0_complete: true\n"
            "task_coverage: 23/23\n"
            + active_rows + "\n"
        )
        require(_validation_gate(active_validation).ok, "active validation positive")
        require(
            not _validation_gate(active_validation.replace("✅ green", "⬜ pending", 1)).ok,
            "stale completed validation row accepted",
        )
        require(
            not _validation_gate(active_validation.replace("⬜ pending", "✅ green", 1)).ok,
            "premature future validation row accepted",
        )

    # Owner, planning, and lifecycle modes classify their own mutations.
    with tempfile.TemporaryDirectory(prefix="phase52-owner-") as temporary:
        fixture = Path(temporary)
        for name in OWNER_NAMES:
            for index, relative in enumerate(OWNER_PATHS[name]):
                tokens = " ".join(OWNER_REQUIRED[name]) if index == 0 else ""
                write_fixture(fixture, relative, f"## Phase 52\n{tokens}\n")
            require(owner_gate(fixture, name).ok, f"owner positive:{name}")
            first = fixture / OWNER_PATHS[name][0]
            clean = first.read_text(encoding="utf-8")
            token = OWNER_REQUIRED[name][-1]
            first.write_text(clean.replace(token, "removed-token", 1), encoding="utf-8")
            require(not owner_gate(fixture, name).ok, f"owner mutation accepted:{name}")
            first.write_text(clean, encoding="utf-8")

        requirements = "\n".join(
            f"- [x] **{identifier}** complete"
            for identifier in ("SAFE-01", "SAFE-02", "SAFE-03", "DOC-01")
        )
        roadmap = "\n".join(
            f"- [x] 52-{plan:02d}-PLAN.md" for plan in range(1, 11)
        )
        write_fixture(fixture, ".planning/REQUIREMENTS.md", requirements + "\n")
        write_fixture(fixture, ".planning/ROADMAP.md", roadmap + "\n")
        write_fixture(
            fixture,
            f"{PHASE_DIR}/52-VERIFICATION.md",
            "status: gaps_found\nindependent milestone audit remains pending\n"
            "_Verifier: independent gsd-verifier_\n",
        )
        require(planning_final_gate(fixture).ok, "planning final positive")
        verification = fixture / PHASE_DIR / "52-VERIFICATION.md"
        verification.write_text(
            "status: passed\nexecutor authored\n"
            "_Verifier: independent gsd-verifier_\n",
            encoding="utf-8",
        )
        require(not planning_final_gate(fixture).ok, "executor-passed verification accepted")

        for relative in ("PLANS.md", ".planning/PROJECT.md", ".planning/STATE.md"):
            write_fixture(
                fixture,
                relative,
                "## Phase 52\nv1.13 independent milestone audit remains pending\n",
            )
        require(lifecycle_gate(fixture, fake(0)).ok, "lifecycle positive")
        (fixture / "PLANS.md").write_text(
            "## Phase 52\nv1.13 audit passed\n",
            encoding="utf-8",
        )
        require(not lifecycle_gate(fixture, fake(0)).ok, "premature lifecycle accepted")
        require(not lifecycle_gate(fixture, fake(2, stderr="error")).ok,
                "lifecycle command error accepted")

    # Concurrent isolated calls use distinct private temporary directories.
    def isolated_call(index: int) -> tuple[str, str]:
        with tempfile.TemporaryDirectory(prefix=f"phase52-concurrent-{index}-") as temporary:
            marker = Path(temporary) / "marker"
            marker.write_text(str(index), encoding="utf-8")
            time.sleep(0.01)
            return temporary, marker.read_text(encoding="utf-8")

    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        concurrent_results = list(executor.map(isolated_call, range(8)))
    require(
        len({path for path, _value in concurrent_results}) == 8
        and {value for _path, value in concurrent_results} == {str(index) for index in range(8)}
        and all(not Path(path).exists() for path, _value in concurrent_results),
        "concurrent isolation",
    )

    # An interrupted subprocess is terminated and its owned temp root is cleaned.
    with tempfile.TemporaryDirectory(prefix="phase52-interrupt-parent-") as temporary:
        owned = Path(temporary) / "child"
        code = (
            "import pathlib,time,sys;"
            "p=pathlib.Path(sys.argv[1]);p.mkdir();(p/'ready').write_text('1');time.sleep(30)"
        )
        process = subprocess.Popen((sys.executable, "-c", code, str(owned)))
        deadline = time.time() + 5
        while time.time() < deadline and not (owned / "ready").exists():
            time.sleep(0.01)
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)
        require(process.returncode is not None, "interrupted subprocess remained live")
    require(not Path(temporary).exists(), "interrupted temporary root remained")

    print(
        f"SELF-TEST {'PASS' if not failures else 'FAIL'}: "
        f"{checks - len(failures)}/{checks} adversarial checks"
    )
    for failure in failures:
        print(f"FAIL {failure}")
    return 0 if not failures else 1


def _exact_eyebrow_taxonomy(ledger: str) -> Result:
    rows = [
        row for row in table_rows(ledger)
        if (
            len(row) >= 3
            and row[0] == "眉毛"
            and row[2] in {"future", "partial", "blocked-by-geometry-output", "implemented"}
        )
    ]
    names = [row[1] for row in rows]
    return Result(
        "exact eyebrow taxonomy",
        len(rows) == 7 and tuple(names) == TARGET_ROWS,
        f"rows={len(rows)}/7; exact_order={int(tuple(names) == TARGET_ROWS)}",
    )


def print_results(mode: str, results: Sequence[Result]) -> int:
    print(f"Phase 52 eyebrow safety boundary checker — mode={mode}")
    for result in results:
        print(f"{'PASS' if result.ok else 'FAIL'}: {result.name}: {result.detail}")
    passed = sum(result.ok for result in results)
    print(f"RESULT: {passed}/{len(results)} checks passed")
    return 0 if results and passed == len(results) else 1


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--check-promotion", action="store_true")
    modes.add_argument("--check-owners", action="store_true")
    modes.add_argument("--allow-promotion", action="store_true")
    parser.add_argument("--owner", choices=OWNER_NAMES)
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args(argv)
    if args.owner and not args.check_owners:
        parser.error("--owner requires --check-owners")
    try:
        root = locate_repo(args.root)
        if args.self_test:
            return self_test(root)
        governance_requested = (
            args.check_promotion or args.check_owners or args.allow_promotion
        )
        # Phase 52's exact SDK-core product transaction is already committed.
        # Default mode remains non-promoting/read-only, but validates that
        # current promoted state instead of reconstructing the historical
        # pre-promotion worktree.
        results = live_checks(root, promoted=True)
        if governance_requested:
            results.extend(governance_gate(root))
            results.append(_exact_eyebrow_taxonomy(read(root, BLUEPRINT_FILES[0])))
        if args.check_promotion:
            results.append(exact_promotion_worktree_gate(root))
        if args.check_owners or args.allow_promotion:
            selected = (args.owner,) if args.owner else OWNER_NAMES
            results.extend(owner_gate(root, name) for name in selected)
        if args.allow_promotion:
            results.extend((planning_final_gate(root), lifecycle_gate(root)))
        mode = (
            "allow-promotion" if args.allow_promotion
            else "owners" if args.check_owners
            else "promotion" if args.check_promotion
            else "live"
        )
        return print_results(mode, results)
    except Exception as error:
        return print_results(
            "startup",
            [Result("repository discovery/initialization", False,
                    f"blocking_error={type(error).__name__}")],
        )


if __name__ == "__main__":
    raise SystemExit(main())
