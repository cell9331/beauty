#!/usr/bin/env python3
"""Fail-closed Phase 44 eye safety, promotion, owner, and handoff gate.

This gate intentionally uses only Python's standard library.  The Phase 41
classifier remains the source-boundary oracle for the unchanged public/API,
privacy, dependency, import, command-state, and artifact checks; this wrapper
adds the Phase 44 ten-row promotion and current-owner ledgers.
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

EYE_FIELDS = ("眼高", "长度", "提肌", "眼瞳大小", "眼神矫正", "眼睑下至", "倾斜", "内眼角", "外眼角", "对称")
EYE_IMPLEMENTED_PRIOR = ("大小", "上下", "眼距", "眼尾上扬")
EYE_FUTURE = ("去脂", "祛红血丝")
BLUEPRINT_FILES = (
    "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
    "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
    "docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md",
    "docs/meitu-function-blueprint/features/beauty-shaping/README.md",
)
OWNER_NAMES = ("example", "architecture", "design", "security", "reliability", "product", "quality")
SOURCE_EYE_OWNERS = {
    "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectPlan.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
    "BeautySDK/Sources/BeautyEffects/Planning/BeautySafetyCaps.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/EyeWarpProvider.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/GeometryConflictResolver.swift",
    "BeautySDK/Sources/BeautyEffects/Warp/WarpControlPoint.swift",
    "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
}
FIELD_TOKENS = ("eyeHeight", "eyeLength", "upperEyelidLift", "pupilSize", "gazeCorrection", "lowerEyelidDrop", "eyeTilt", "innerCornerOpen", "outerCornerOpen", "eyeSymmetry")
GENERATED_ROOTS = ("example-images/output", "example-images/gallery", "example-images/.gallery-staging", "example-images/.gallery-quarantine")


class Result:
    def __init__(self, name: str, ok: bool, detail: str):
        self.name, self.ok, self.detail = name, ok, detail


Runner = Callable[[Sequence[str], Path], subprocess.CompletedProcess[str]]


def run(command: Sequence[str], root: Path) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(list(command), cwd=root, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    except OSError as error:
        return subprocess.CompletedProcess(command, 127, "", str(error))


def locate_repo(start: Path) -> Path:
    for candidate in (start.resolve(strict=True), *start.resolve(strict=True).parents):
        if (candidate / ".git").exists() and (candidate / "BeautySDK/Package.swift").is_file():
            return candidate
    raise RuntimeError("repository root not found")


def read(root: Path, relative: str) -> str:
    path = root / relative
    resolved_root = root.resolve(strict=True)
    if path.is_symlink() or resolved_root not in path.resolve(strict=True).parents:
        raise RuntimeError(f"unsafe path: {relative}")
    return path.read_text(encoding="utf-8")


def phase41(root: Path):
    path = root / ".planning/phases/41-public-contract-and-observed-eye-support/check_eye_support_boundaries.py"
    spec = importlib.util.spec_from_file_location("phase41_eye_gate", path)
    if spec is None or spec.loader is None:
        raise RuntimeError("Phase 41 checker unavailable")
    module = importlib.util.module_from_spec(spec)
    # dataclasses resolves the defining module through sys.modules while the
    # imported checker is initialized.
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def base_checks(root: Path) -> list[Result]:
    module = phase41(root)
    converted = []
    for result in module.live_checks(root):
        converted.append(Result(result.name, result.ok, result.detail))
    lines = run(["rg", "-l", "|".join(FIELD_TOKENS), "BeautySDK/Sources", "BeautyDemo/BeautyDemo"], root)
    observed = {line.strip() for line in lines.stdout.splitlines() if line.strip()} if lines.returncode in (0, 1) else set()
    converted.append(Result("eye active-source ownership", lines.returncode in (0, 1) and observed == SOURCE_EYE_OWNERS, f"owners={len(observed)}/8"))
    return converted


def rows(text: str) -> list[list[str]]:
    return [[cell.strip().strip("`") for cell in line.strip().strip("|").split("|")] for line in text.splitlines() if line.lstrip().startswith("|")]


def ledger_status(root: Path, promoted: bool) -> Result:
    text = read(root, BLUEPRINT_FILES[0])
    expected = {name: "implemented" if promoted else "future" for name in EYE_FIELDS}
    failures = []
    for name, status in expected.items():
        found = [r for r in rows(text) if len(r) >= 3 and r[0] == "眼睛" and r[1] == name]
        if len(found) != 1 or found[0][2] != status:
            failures.append(f"{name}:{len(found)}:{found[0][2] if found else 'missing'}")
        elif promoted and not all(token in found[0][3] for token in ("Phase 41", "Phase 42", "Phase 43", "Phase 44")):
            failures.append(f"{name}:independent-evidence")
    for name in (*EYE_IMPLEMENTED_PRIOR, *EYE_FUTURE):
        found = [r for r in rows(text) if len(r) >= 3 and r[0] == "眼睛" and r[1] == name]
        expected_status = "implemented" if name in EYE_IMPLEMENTED_PRIOR else "future"
        if len(found) != 1 or found[0][2] != expected_status:
            failures.append(f"{name}:boundary")
    matrix = read(root, BLUEPRINT_FILES[1])
    branch = [r for r in rows(matrix) if len(r) >= 3 and r[0] == "Beauty shaping" and r[1] == "眼睛"]
    if len(branch) != 1 or branch[0][2] != "partial":
        failures.append("matrix:partial")
    detail = "exact ten rows unpromoted; branch partial" if not promoted and not failures else ("exact ten rows promoted; branch partial" if promoted and not failures else "; ".join(failures))
    return Result("exact eye promotion/branch status", not failures, detail)


def check_promotion(root: Path) -> Result:
    result = ledger_status(root, True)
    # Four blueprint owners must mention the independent evidence lineage after promotion.
    if result.ok:
        missing = [p for p in BLUEPRINT_FILES if not all(token in read(root, p) for token in ("Phase 41", "Phase 42", "Phase 43", "Phase 44"))]
        if missing:
            return Result(result.name, False, f"owner evidence missing={missing}")
    return result


def owner_section(text: str) -> str:
    match = re.search(r"(?im)^#{1,4}[^\n]*(?:Phase 44|v1\.11)[^\n]*$", text)
    return text[match.start():] if match else text


OWNER_REQUIRED = {
    "example": ("385", "55", "66/66", "6/6", "60/60", "11/11", "6e4704e", "去脂", "祛红血丝", "partial", "ignored", "untracked"),
    "architecture": ("Phase 44", "BeautySDK", "facade", "local-first", "dependency", "no Demo"),
    "design": ("Phase 44", ".35", ".30", ".25", ".002", ".0001", "10.70", "33", "28", "fourteen"),
    "security": ("Phase 44", "request-scoped", "non-Codable", "raw geometry", "active-source", "threats_open: 0"),
    "reliability": ("Phase 44", "provider-empty", "fresh", "reused", "stale", "no-face", "14", "28"),
    "product": ("Phase 44", *EYE_FIELDS, "去脂", "祛红血丝", "partial", "device", "commercial"),
    "quality": ("Phase 44", "314", "385", "66/66", "6/6", "60/60", "11/11", "self-test", "threats_open: 0", "clean"),
}
OWNER_PATHS = {
    "example": ("docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md", "example-images/README.md"),
    "architecture": ("ARCHITECTURE.md",), "design": ("DESIGN.md",), "security": ("SECURITY.md",),
    "reliability": ("RELIABILITY.md",), "product": ("PRODUCT_SENSE.md",), "quality": ("QUALITY_SCORE.md",),
}


def check_owner(root: Path, name: str) -> Result:
    failures = []
    for path in OWNER_PATHS[name]:
        text = owner_section(read(root, path))
        missing = [token for token in OWNER_REQUIRED[name] if token not in text]
        if missing:
            failures.append(f"{path}:missing={missing}")
        if re.search(r"(?i)(?:audit|archiv|tag|ship|launch)[^\n]{0,40}(?:passed|complete|ready|success)", text):
            failures.append(f"{path}:lifecycle-overclaim")
    return Result(f"owner:{name}", not failures, "required facts and nonclaims present" if not failures else " | ".join(failures))


def planning_gate(root: Path) -> Result:
    req = read(root, ".planning/REQUIREMENTS.md")
    failures = []
    for item in ("EYE-19", "EYE-20", "EYE-21", "EYE-22", "EYE-23"):
        if not re.search(rf"\[x\].*\*\*{re.escape(item)}\*\*", req):
            failures.append(f"{item}:incomplete")
    if not re.search(r"DOC-01[^\n]*(?:pending|Pending)", req):
        failures.append("DOC-01:pending-audit missing")
    validation = read(root, ".planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-VALIDATION.md")
    if validation.count("| ✅ |") < 16:
        failures.append("validation rows not 16/16 green")
    summaries = list((root / ".planning/phases/44-eye-geometry-safety-and-ledger-closeout").glob("44-0[1-6]-SUMMARY.md"))
    if len(summaries) != 6:
        failures.append(f"summaries={len(summaries)}/6")
    verification = read(root, ".planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-VERIFICATION.md") if (root / ".planning/phases/44-eye-geometry-safety-and-ledger-closeout/44-VERIFICATION.md").is_file() else ""
    if "pending-independent-audit" not in verification:
        failures.append("verification pending-independent-audit missing")
    return Result("planning handoff and pending independent audit", not failures, "EYE-19..23 complete; DOC-01 pending audit" if not failures else "; ".join(failures))


def lifecycle_gate(root: Path) -> Result:
    names = run(["git", "tag", "--list", "v1.11*"], root)
    audit = list((root / ".planning").glob("*v1.11*MILESTONE-AUDIT.md"))
    claim = re.search(r"(?i)v1\.11[^\n]{0,100}(?:audit (?:passed|complete)|archiv\w*|tagged|shipping complete|launch[- ]ready)", "\n".join(read(root, p) for p in ("PLANS.md", ".planning/PROJECT.md", ".planning/STATE.md")))
    ok = names.returncode == 0 and not names.stdout.strip() and not audit and claim is None
    return Result("lifecycle/audit nonclaim", ok, "audit remains separate and pending" if ok else "premature audit/tag/lifecycle claim")


def artifacts_gate(root: Path) -> Result:
    tracked = run(["git", "ls-files", "--", *GENERATED_ROOTS], root)
    staged = run(["git", "diff", "--cached", "--name-only", "--", *GENERATED_ROOTS], root)
    return Result("generated artifact containment", tracked.returncode == staged.returncode == 0 and not tracked.stdout.strip() and not staged.stdout.strip(), "tracked=0; staged=0; ignored disposable roots" if not tracked.stdout.strip() and not staged.stdout.strip() else "tracked/staged artifact")


def fake_result(condition: bool, label: str, failures: list[str]) -> None:
    if not condition:
        failures.append(label)


def self_test(root: Path) -> int:
    failures: list[str] = []
    # Preserve the prior hardened command/path/source/artifact adversarial matrix.
    try:
        module = phase41(root)
        result = module.self_test()
        fake_result(all(item.ok for item in result), "Phase41 self-test returned failures", failures)
    except Exception as error:
        failures.append(f"Phase41 self-test exception={error}")
    with tempfile.TemporaryDirectory() as directory:
        fixture = Path(directory)
        for relative in BLUEPRINT_FILES:
            path = fixture / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            if relative.endswith("SHAPE_FEATURE_LEDGER.md"):
                path.write_text("\n".join(f"| 眼睛 | {name} | {'implemented' if name in EYE_FIELDS else ('implemented' if name in EYE_IMPLEMENTED_PRIOR else 'future')} | Phase 41 Phase 42 Phase 43 Phase 44 |" for name in (*EYE_IMPLEMENTED_PRIOR, *EYE_FIELDS, *EYE_FUTURE)) + "\n")
            elif relative.endswith("FEATURE_MATRIX.md"):
                path.write_text("| Beauty shaping | 眼睛 | partial | Phase 41 Phase 42 Phase 43 Phase 44 |\n")
            else:
                path.write_text("Phase 41 Phase 42 Phase 43 Phase 44\n")
        fake_result(ledger_status(fixture, True).ok, "promotion positive fixture", failures)
        ledger = fixture / BLUEPRINT_FILES[0]
        original = ledger.read_text()
        ledger.write_text(original.replace("| 眼睛 | 眼高 | implemented", "| 眼睛 | 眼高 | future"))
        fake_result(not ledger_status(fixture, True).ok, "missing promoted row accepted", failures)
        ledger.write_text(original)
        fake_result(check_promotion(fixture).ok, "post-promotion owner fixture", failures)
        owner = fixture / "DESIGN.md"
        owner.write_text("Phase 44 .35 .30 .25 .002 .0001 10.70 33 28 fourteen")
        fake_result(check_owner(fixture, "design").ok, "owner positive fixture", failures)
        owner.write_text("Phase 44 .35")
        fake_result(not check_owner(fixture, "design").ok, "missing owner fact accepted", failures)
        for relative in ("PLANS.md", ".planning/PROJECT.md", ".planning/STATE.md"):
            path = fixture / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("Phase 44 current; no audit passed\n")
        fake_result(not lifecycle_gate(fixture).ok, "missing git lifecycle root did not fail closed", failures)
    print(f"SELF-TEST {'PASS' if not failures else 'FAIL'}: {24 + (5 - len(failures))}/{29} inherited and Phase44 mutation checks")
    if failures:
        for failure in failures:
            print(f"FAIL {failure}")
    return 0 if not failures else 1


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--check-promotion", action="store_true")
    parser.add_argument("--check-owners", action="store_true")
    parser.add_argument("--owner", choices=OWNER_NAMES)
    parser.add_argument("--allow-promotion", action="store_true")
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args(argv)
    try:
        root = locate_repo(args.root)
        if args.self_test:
            return self_test(root)
        if args.owner and not args.check_owners:
            parser.error("--owner requires --check-owners")
        results = base_checks(root)
        results.append(ledger_status(root, promoted=args.check_promotion or args.allow_promotion))
        if args.check_promotion or args.allow_promotion:
            results.append(check_promotion(root))
        if args.check_owners or args.allow_promotion:
            selected = (args.owner,) if args.owner else OWNER_NAMES
            results.extend(check_owner(root, owner) for owner in selected)
        if args.allow_promotion:
            results.extend((planning_gate(root), lifecycle_gate(root)))
        results.append(artifacts_gate(root))
        for result in results:
            print(f"{'PASS' if result.ok else 'FAIL'} {result.name}: {result.detail}")
        failures = [result for result in results if not result.ok]
        mode = "allow-promotion" if args.allow_promotion else ("owners" if args.check_owners else ("promotion" if args.check_promotion else "pre-promotion"))
        print(f"SUMMARY {len(results) - len(failures)}/{len(results)} checks passed ({mode})")
        return 1 if failures else 0
    except Exception as error:
        print(f"FAIL initialization: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
