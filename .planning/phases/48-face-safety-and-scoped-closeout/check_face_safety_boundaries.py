#!/usr/bin/env python3
"""Fail-closed Phase 48 face safety, promotion, owner, and handoff gate.

The Phase 45 classifier remains the source/API/privacy/dependency/artifact
oracle. This standard-library wrapper adds the final Phase 48 active-source,
cap, convergence, exact-row promotion, current-owner, and lifecycle contracts.
"""

from __future__ import annotations

import argparse
import importlib.util
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, Sequence


TARGET_ROWS = ("面部流畅", "太阳穴", "颧骨", "尖下巴")
PRIOR_ROWS = ("脸宽", "小脸", "下巴长短", "V脸", "下颌角", "下颌线")
FUTURE_ROWS = ("去双下巴", "去双下巴 Pro", "发际线")
BLUEPRINT_FILES = (
    "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
    "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
    "docs/meitu-function-blueprint/features/beauty-shaping/face-shape/README.md",
    "docs/meitu-function-blueprint/features/beauty-shaping/README.md",
)
FIELD_TOKENS = (
    "faceContourSmooth",
    "templeFullness",
    "cheekboneSlim",
    "chinTaper",
)
SOURCE_FACE_OWNERS = {
    "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/ChinWarpProvider.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift",
    "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
}
CAPS = "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift"
RESOLVER = "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift"
GENERATED_ROOTS = (
    "example-images/output",
    "example-images/gallery",
    "example-images/.gallery-staging",
    "example-images/.gallery-quarantine",
)
OWNER_NAMES = (
    "example",
    "architecture",
    "design",
    "security",
    "reliability",
    "product",
    "quality",
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
}
OWNER_REQUIRED = {
    "example": (
        "Phase 48", "413/413", "59", "18/18", "49/49", "6/6", "4/4",
        *TARGET_ROWS, *FUTURE_ROWS, "partial", "ignored", "untracked",
    ),
    "architecture": (
        "Phase 48", "BeautySDK", "facade", "local-first", "dependency", "no Demo",
    ),
    "design": (
        "Phase 48", "0.25", "11.70", "37", "0.5", "nine",
    ),
    "security": (
        "Phase 48", "request-scoped", "non-Codable", "raw geometry",
        "active-source", "threats_open: 0",
    ),
    "reliability": (
        "Phase 48", "provider-empty", "fresh", "reused", "stale", "no-face", "37",
    ),
    "product": (
        "Phase 48", *TARGET_ROWS, *FUTURE_ROWS, "partial", "device", "commercial",
    ),
    "quality": (
        "Phase 48", "375", "413", "18/18", "49/49", "6/6", "4/4",
        "self-test", "threats_open: 0", "clean",
    ),
}


class Result:
    def __init__(self, name: str, ok: bool, detail: str):
        self.name, self.ok, self.detail = name, ok, detail


Runner = Callable[[Sequence[str], Path], subprocess.CompletedProcess[str]]


def run(command: Sequence[str], root: Path) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(
            list(command),
            cwd=root,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
    except OSError as error:
        return subprocess.CompletedProcess(command, 127, "", str(error))


def locate_repo(start: Path) -> Path:
    resolved = start.resolve(strict=True)
    for candidate in (resolved, *resolved.parents):
        if (candidate / ".git").exists() and (candidate / "BeautySDK/Package.swift").is_file():
            return candidate
    raise RuntimeError("repository root not found")


def safe_path(root: Path, relative: str, *, directory: bool = False) -> Path:
    relative_path = Path(relative)
    if relative_path.is_absolute() or ".." in relative_path.parts:
        raise RuntimeError("unsafe repository-relative path")
    resolved_root = root.resolve(strict=True)
    current = root
    for component in relative_path.parts:
        current = current / component
        if current.is_symlink():
            raise RuntimeError("symlinked required path")
    candidate = root / relative_path
    resolved = candidate.resolve(strict=True)
    if resolved == resolved_root or resolved_root not in resolved.parents:
        raise RuntimeError("required path escapes repository")
    if directory and not candidate.is_dir():
        raise RuntimeError("required directory is not a directory")
    if not directory and not candidate.is_file():
        raise RuntimeError("required file is not a regular file")
    return candidate


def read(root: Path, relative: str) -> str:
    return safe_path(root, relative).read_text(encoding="utf-8")


def phase45(root: Path):
    checker = safe_path(
        root,
        ".planning/phases/45-public-contract-and-observed-face-support/"
        "check_face_support_boundaries.py",
    )
    spec = importlib.util.spec_from_file_location("phase45_face_gate", checker)
    if spec is None or spec.loader is None:
        raise RuntimeError("Phase 45 checker unavailable")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def base_checks(root: Path) -> list[Result]:
    converted = []
    for item in phase45(root).live_checks(root):
        converted.append(Result(item.name, item.ok, item.detail))
    return converted


def active_source_gate(root: Path, runner: Runner = run) -> Result:
    command = (
        "rg", "-l", "|".join(FIELD_TOKENS),
        "BeautySDK/Sources", "BeautyDemo/BeautyDemo",
    )
    completed = runner(command, root)
    if completed.returncode not in (0, 1):
        return Result("face active-source ownership", False, f"command_error={completed.returncode}")
    observed = {line.strip() for line in completed.stdout.splitlines() if line.strip()}
    ok = completed.returncode == 0 and observed == SOURCE_FACE_OWNERS
    return Result(
        "face active-source ownership",
        ok,
        f"owners={len(observed)}/{len(SOURCE_FACE_OWNERS)}; unclassified={len(observed - SOURCE_FACE_OWNERS)}",
    )


def final_source_gate(root: Path) -> Result:
    caps = read(root, CAPS)
    resolver = read(root, RESOLVER)
    failures: list[str] = []
    for field in FIELD_TOKENS:
        if len(re.findall(rf"static let {field}: Float = 0\.25\b", caps)) != 1:
            failures.append(f"{field}:cap")
    if "provisional" in caps.lower():
        failures.append("provisional-wording")
    if resolver.count("0..<37") != 1:
        failures.append("convergence-loop")
    for field in FIELD_TOKENS:
        if resolver.count(field) < 5:
            failures.append(f"{field}:resolver-ownership")
    return Result(
        "final cap and exact convergence source",
        not failures,
        "caps=4/4; loop=0..<37; fields=4/4" if not failures else "; ".join(failures),
    )


def table_rows(text: str) -> list[list[str]]:
    return [
        [cell.strip().strip("`") for cell in line.strip().strip("|").split("|")]
        for line in text.splitlines()
        if line.lstrip().startswith("|")
    ]


def ledger_status(root: Path, promoted: bool) -> Result:
    ledger = read(root, BLUEPRINT_FILES[0])
    failures: list[str] = []
    expected = {
        **{name: "implemented" for name in PRIOR_ROWS},
        **{name: ("implemented" if promoted else "future") for name in TARGET_ROWS},
        **{name: "future" for name in FUTURE_ROWS},
    }
    for name, status in expected.items():
        found = [
            row for row in table_rows(ledger)
            if len(row) >= 4 and row[0] == "脸型" and row[1] == name
        ]
        if len(found) != 1 or found[0][2] != status:
            failures.append(f"{name}:{len(found)}:{found[0][2] if found else 'missing'}")
        elif promoted and name in TARGET_ROWS:
            if not all(token in found[0][3] for token in ("Phase 45", "Phase 46", "Phase 47", "Phase 48")):
                failures.append(f"{name}:evidence-lineage")
        elif name in FUTURE_ROWS and not any(
            token in " ".join(found[0][3:])
            for token in ("local", "segmentation", "resource", "semantic", "commercial")
        ):
            failures.append(f"{name}:blocker")

    matrix = read(root, BLUEPRINT_FILES[1])
    branch = [
        row for row in table_rows(matrix)
        if len(row) >= 3 and row[0] == "Beauty shaping" and row[1] == "脸型"
    ]
    if len(branch) != 1 or branch[0][2] != "partial":
        failures.append("matrix:partial")
    for relative in BLUEPRINT_FILES[2:]:
        if "partial" not in read(root, relative):
            failures.append(f"{relative}:partial")
    detail = (
        "exact four rows promoted; three deferred; branch partial"
        if promoted and not failures
        else "exact four rows unpromoted; three deferred; branch partial"
        if not failures
        else "; ".join(failures)
    )
    return Result("exact face promotion/branch status", not failures, detail)


def check_promotion(root: Path) -> Result:
    status = ledger_status(root, True)
    if not status.ok:
        return status
    missing = [
        relative for relative in BLUEPRINT_FILES
        if not all(token in read(root, relative) for token in ("Phase 45", "Phase 46", "Phase 47", "Phase 48"))
    ]
    return Result(
        status.name,
        not missing,
        status.detail if not missing else f"owner evidence missing={missing}",
    )


def owner_section(text: str) -> str:
    match = re.search(r"(?im)^#{1,4}[^\n]*(?:Phase 48|v1\.12)[^\n]*$", text)
    return text[match.start():] if match else text


def check_owner(root: Path, name: str) -> Result:
    failures: list[str] = []
    for relative in OWNER_PATHS[name]:
        section = owner_section(read(root, relative))
        missing = [token for token in OWNER_REQUIRED[name] if token not in section]
        if missing:
            failures.append(f"{relative}:missing={missing}")
        if re.search(
            r"(?i)v1\.12[^\n]{0,80}(?:audit passed|audit complete|archived|tagged|shipping complete|launch-ready)",
            section,
        ):
            failures.append(f"{relative}:lifecycle-overclaim")
    return Result(
        f"owner:{name}",
        not failures,
        "required facts and nonclaims present" if not failures else " | ".join(failures),
    )


def planning_gate(root: Path) -> Result:
    requirements = read(root, ".planning/REQUIREMENTS.md")
    failures: list[str] = []
    for identifier in ("SAFE-01", "SAFE-02", "SAFE-03"):
        if not re.search(rf"\[x\].*\*\*{identifier}\*\*", requirements):
            failures.append(f"{identifier}:incomplete")
    if not re.search(r"\[ \].*\*\*DOC-01\*\*[^\n]*(?:pending|Pending)", requirements):
        failures.append("DOC-01:pending-independent-audit")
    phase_dir = root / ".planning/phases/48-face-safety-and-scoped-closeout"
    summaries = list(phase_dir.glob("48-0[1-6]-SUMMARY.md"))
    if len(summaries) != 6:
        failures.append(f"summaries={len(summaries)}/6")
    validation = read(
        root,
        ".planning/phases/48-face-safety-and-scoped-closeout/48-VALIDATION.md",
    )
    if validation.count("| passed |") < 14 or "nyquist_compliant: true" not in validation:
        failures.append("validation:not-final")
    verification = read(
        root,
        ".planning/phases/48-face-safety-and-scoped-closeout/48-VERIFICATION.md",
    )
    if "pending-independent-audit" not in verification:
        failures.append("verification:handoff")
    review = read(
        root,
        ".planning/phases/48-face-safety-and-scoped-closeout/48-REVIEW.md",
    )
    security = read(
        root,
        ".planning/phases/48-face-safety-and-scoped-closeout/48-SECURITY.md",
    )
    if "status: clean" not in review:
        failures.append("review:not-clean")
    if "threats_open: 0" not in security:
        failures.append("security:open")
    return Result(
        "planning handoff and pending independent audit",
        not failures,
        "SAFE-01..03 complete; DOC-01 pending independent audit"
        if not failures else "; ".join(failures),
    )


def lifecycle_gate(root: Path) -> Result:
    tags = run(("git", "tag", "--list", "v1.12*"), root)
    audits = list((root / ".planning").glob("*v1.12*MILESTONE-AUDIT.md"))
    owners = "\n".join(read(root, relative) for relative in (
        "PLANS.md", ".planning/PROJECT.md", ".planning/STATE.md",
    ))
    claim = re.search(
        r"(?i)v1\.12[^\n]{0,100}(?:audit passed|audit complete|archived as|tagged v1\.12|shipping complete|launch-ready)",
        owners,
    )
    ok = tags.returncode == 0 and not tags.stdout.strip() and not audits and claim is None
    return Result(
        "lifecycle/audit nonclaim",
        ok,
        "independent audit remains separate and pending" if ok else "premature audit/tag/lifecycle claim",
    )


def artifacts_gate(root: Path, runner: Runner = run) -> Result:
    commands = (
        ("git", "ls-files", "--", *GENERATED_ROOTS),
        ("git", "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS),
        ("git", "ls-files", "--others", "--exclude-standard", "--", *GENERATED_ROOTS),
    )
    results = [runner(command, root) for command in commands]
    ok = all(item.returncode == 0 and not item.stdout.strip() for item in results)
    return Result(
        "generated artifact containment",
        ok,
        "tracked=0; staged=0; nonignored_untracked=0"
        if ok else "tracked/staged/nonignored artifact or command error",
    )


def live_checks(root: Path, promoted: bool) -> list[Result]:
    results = base_checks(root)
    results.extend((
        active_source_gate(root),
        final_source_gate(root),
        ledger_status(root, promoted),
        artifacts_gate(root),
    ))
    return results


def write_fixture(root: Path, relative: str, text: str) -> Path:
    target = root / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(text, encoding="utf-8")
    return target


def build_status_fixture(root: Path, promoted: bool) -> None:
    rows = []
    for name in (*PRIOR_ROWS, *TARGET_ROWS, *FUTURE_ROWS):
        status = "implemented" if name in PRIOR_ROWS or (promoted and name in TARGET_ROWS) else "future"
        evidence = (
            "Phase 45 Phase 46 Phase 47 Phase 48"
            if name in TARGET_ROWS and promoted
            else "local semantic segmentation resource commercial blocker"
            if name in FUTURE_ROWS
            else "prior evidence"
        )
        rows.append(f"| 脸型 | {name} | {status} | {evidence} | scoped |")
    write_fixture(root, BLUEPRINT_FILES[0], "\n".join(rows) + "\n")
    write_fixture(
        root,
        BLUEPRINT_FILES[1],
        "| Beauty shaping | 脸型 | partial | Phase 45 Phase 46 Phase 47 Phase 48 |\n",
    )
    for relative in BLUEPRINT_FILES[2:]:
        write_fixture(root, relative, "partial Phase 45 Phase 46 Phase 47 Phase 48\n")


def build_source_fixture(root: Path) -> None:
    caps = "\n".join(f"static let {field}: Float = 0.25" for field in FIELD_TOKENS)
    resolver = "0..<37\n" + "\n".join((field + "\n") * 5 for field in FIELD_TOKENS)
    write_fixture(root, CAPS, caps + "\n")
    write_fixture(root, RESOLVER, resolver)


def self_test(root: Path) -> int:
    failures: list[str] = []
    checks = 0

    def require(condition: bool, label: str) -> None:
        nonlocal checks
        checks += 1
        if not condition:
            failures.append(label)

    try:
        for item in phase45(root).self_test():
            require(item.ok, f"inherited:{item.name}")
    except Exception as error:
        failures.append(f"Phase45 self-test exception={type(error).__name__}")

    with tempfile.TemporaryDirectory(prefix="phase48-status-") as temporary:
        fixture = Path(temporary)
        build_status_fixture(fixture, False)
        require(ledger_status(fixture, False).ok, "pre-promotion positive")
        build_status_fixture(fixture, True)
        require(check_promotion(fixture).ok, "promotion positive")
        ledger = fixture / BLUEPRINT_FILES[0]
        original = ledger.read_text(encoding="utf-8")
        for name in TARGET_ROWS:
            ledger.write_text(
                original.replace(f"| 脸型 | {name} | implemented", f"| 脸型 | {name} | future"),
                encoding="utf-8",
            )
            require(not ledger_status(fixture, True).ok, f"promotion mutation accepted:{name}")
        ledger.write_text(original, encoding="utf-8")
        for name in FUTURE_ROWS:
            ledger.write_text(
                original.replace(f"| 脸型 | {name} | future", f"| 脸型 | {name} | implemented"),
                encoding="utf-8",
            )
            require(not ledger_status(fixture, True).ok, f"future mutation accepted:{name}")
        ledger.write_text(original, encoding="utf-8")
        matrix = fixture / BLUEPRINT_FILES[1]
        clean_matrix = matrix.read_text(encoding="utf-8")
        matrix.write_text(clean_matrix.replace("partial", "implemented"), encoding="utf-8")
        require(not ledger_status(fixture, True).ok, "branch completion accepted")
        matrix.write_text(clean_matrix, encoding="utf-8")
        face_owner = fixture / BLUEPRINT_FILES[2]
        face_owner.write_text(
            face_owner.read_text(encoding="utf-8").replace("Phase 47", "removed"),
            encoding="utf-8",
        )
        require(not check_promotion(fixture).ok, "evidence-lineage mutation accepted")

    with tempfile.TemporaryDirectory(prefix="phase48-source-") as temporary:
        fixture = Path(temporary)
        build_source_fixture(fixture)
        require(final_source_gate(fixture).ok, "source positive")
        cap_path = fixture / CAPS
        clean_caps = cap_path.read_text(encoding="utf-8")
        cap_path.write_text(clean_caps.replace("0.25", "0.24", 1), encoding="utf-8")
        require(not final_source_gate(fixture).ok, "cap mutation accepted")
        cap_path.write_text(clean_caps + "// provisional\n", encoding="utf-8")
        require(not final_source_gate(fixture).ok, "provisional wording accepted")
        cap_path.write_text(clean_caps, encoding="utf-8")
        resolver_path = fixture / RESOLVER
        clean_resolver = resolver_path.read_text(encoding="utf-8")
        resolver_path.write_text(clean_resolver.replace("0..<37", "0..<36"), encoding="utf-8")
        require(not final_source_gate(fixture).ok, "loop mutation accepted")

        exact_output = "\n".join(sorted(SOURCE_FACE_OWNERS)) + "\n"
        good_runner: Runner = lambda command, cwd: subprocess.CompletedProcess(command, 0, exact_output, "")
        extra_runner: Runner = lambda command, cwd: subprocess.CompletedProcess(
            command, 0, exact_output + "BeautyDemo/BeautyDemo/Unexpected.swift\n", "",
        )
        error_runner: Runner = lambda command, cwd: subprocess.CompletedProcess(command, 2, "", "error")
        require(active_source_gate(fixture, good_runner).ok, "active-source positive")
        require(not active_source_gate(fixture, extra_runner).ok, "unclassified owner accepted")
        require(not active_source_gate(fixture, error_runner).ok, "source command error accepted")

    with tempfile.TemporaryDirectory(prefix="phase48-owner-") as temporary:
        fixture = Path(temporary)
        for name in OWNER_NAMES:
            for relative in OWNER_PATHS[name]:
                write_fixture(
                    fixture,
                    relative,
                    f"## Phase 48\n{' '.join(OWNER_REQUIRED[name])}\n",
                )
            require(check_owner(fixture, name).ok, f"owner positive:{name}")
            owner_path = fixture / OWNER_PATHS[name][0]
            clean = owner_path.read_text(encoding="utf-8")
            token = OWNER_REQUIRED[name][-1]
            owner_path.write_text(clean.replace(token, "removed-token", 1), encoding="utf-8")
            require(not check_owner(fixture, name).ok, f"owner mutation accepted:{name}")
            owner_path.write_text(clean, encoding="utf-8")

    with tempfile.TemporaryDirectory(prefix="phase48-artifact-") as temporary:
        fixture = Path(temporary)
        subprocess.run(("git", "init", "-q"), cwd=fixture, check=True)
        require(artifacts_gate(fixture).ok, "artifact positive")
        tracked = write_fixture(fixture, "example-images/output/tracked.png", "fixture")
        subprocess.run(("git", "add", "-f", str(tracked.relative_to(fixture))), cwd=fixture, check=True)
        require(not artifacts_gate(fixture).ok, "tracked artifact accepted")

    print(
        f"SELF-TEST {'PASS' if not failures else 'FAIL'}: "
        f"{checks - len(failures)}/{checks} inherited and Phase48 mutation checks"
    )
    for failure in failures:
        print(f"FAIL {failure}")
    return 0 if not failures else 1


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--check-promotion", action="store_true")
    parser.add_argument("--check-owners", action="store_true")
    parser.add_argument("--owner", choices=OWNER_NAMES)
    parser.add_argument("--allow-promotion", action="store_true")
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args(argv)
    if args.owner and not args.check_owners:
        parser.error("--owner requires --check-owners")
    try:
        root = locate_repo(args.root)
        if args.self_test:
            return self_test(root)
        promoted = args.check_promotion or args.check_owners or args.allow_promotion
        results = live_checks(root, promoted)
        if args.check_promotion or args.allow_promotion:
            results.append(check_promotion(root))
        if args.check_owners or args.allow_promotion:
            selected = (args.owner,) if args.owner else OWNER_NAMES
            results.extend(check_owner(root, name) for name in selected)
        if args.allow_promotion:
            results.extend((planning_gate(root), lifecycle_gate(root)))
        for item in results:
            print(f"{'PASS' if item.ok else 'FAIL'} {item.name}: {item.detail}")
        failures = [item for item in results if not item.ok]
        mode = (
            "allow-promotion" if args.allow_promotion
            else "owners" if args.check_owners
            else "promotion" if args.check_promotion
            else "pre-promotion"
        )
        print(f"SUMMARY {len(results) - len(failures)}/{len(results)} checks passed ({mode})")
        return 1 if failures else 0
    except Exception as error:
        print(f"FAIL initialization: {type(error).__name__}: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
