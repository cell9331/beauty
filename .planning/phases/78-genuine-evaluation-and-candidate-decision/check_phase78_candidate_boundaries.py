#!/usr/bin/env python3
"""Phase-78 candidate admission, privacy, and exact-absence gate.

The checker emits only normalized reasons and counts. It never prints source
matches, private manifests, image-derived values, or filesystem paths.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path


PHASE = "78"
PHASE_DIR = Path(".planning/phases/78-genuine-evaluation-and-candidate-decision")
SCRIPT = PHASE_DIR / "78-candidate-decision.js"
TEST = PHASE_DIR / "78-candidate-decision.test.js"
CONTEXT = PHASE_DIR / "78-CONTEXT.md"
PLAN_01 = PHASE_DIR / "78-01-PLAN.md"
PLAN_02 = PHASE_DIR / "78-02-PLAN.md"
REVIEW = PHASE_DIR / "78-REVIEW.md"
VALIDATION = PHASE_DIR / "78-VALIDATION.md"
PARAMETERS = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
PACKAGE = Path("BeautySDK/Package.swift")
RENDERER = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
MANIFEST = Path("BeautySDK/Sources/BeautyResources/Resources/manifest.json")
PHASE77_CHECKER = Path(".planning/phases/77-deterministic-fullness-editor/check_phase77_editor_boundaries.py")

FIELDS = [
    "skinSmoothing", "skinWhitening", "skinRosy", "skinSharpen", "brightness",
    "contrast", "saturation", "temperature", "tint", "exposure", "highlight",
    "shadow", "faceSlim", "faceSmall", "faceVShape", "jawSlim", "chinLength",
    "faceContourSmooth", "templeFullness", "cheekboneSlim", "chinTaper", "eyeSize",
    "eyeDistance", "eyeYPosition", "eyeTailLift", "eyeHeight", "eyeLength",
    "upperEyelidLift", "pupilSize", "gazeCorrection", "lowerEyelidDrop", "eyeTilt",
    "innerCornerOpen", "outerCornerOpen", "eyeSymmetry", "eyebrowYPosition",
    "eyebrowThickness", "eyebrowLength", "eyebrowSpacing", "eyebrowHeadSpacing",
    "eyebrowTilt", "eyebrowPeakDefinition", "noseSlim", "noseWingSlim", "noseTipSize",
    "noseBridge", "noseRootNarrowing", "noseTipLift", "mouthSize", "mouthWidth",
    "smile", "mouthYPosition", "mouthTilt", "mouthXPosition", "lipPeakDefinition",
    "lipPlump", "lipColor", "filterId", "filterIntensity", "teethWhitening",
    "scleraRednessReduction",
]


def read(root: Path, relative: Path) -> str:
    try:
        return (root / relative).read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return ""


def json_read(root: Path, relative: Path) -> object:
    try:
        return json.loads(read(root, relative))
    except json.JSONDecodeError:
        return None


def public_fields(source: str) -> list[str]:
    head = source.split("enum CodingKeys", 1)[0]
    return re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9_]*):", head, re.MULTILINE)


def coding_keys(source: str) -> list[str]:
    match = re.search(r"enum CodingKeys: String, CodingKey \{(?P<body>[\s\S]*?)\n\s*\}", source)
    return re.findall(r"^\s*case ([A-Za-z][A-Za-z0-9_]*)\s*$", match.group("body"), re.MULTILINE) if match else []


def absence_errors(root: Path) -> list[str]:
    errors: list[str] = []
    parameters = read(root, PARAMETERS)
    if public_fields(parameters) != FIELDS:
        errors.append("absence.parameters.fields")
    if coding_keys(parameters) != FIELDS:
        errors.append("absence.parameters.coding-keys")
    manifest = json_read(root, MANIFEST)
    if not isinstance(manifest, dict) or manifest.get("schemaVersion") != 1:
        errors.append("absence.resource-manifest")
    elif [row.get("id") for row in manifest.get("presets", []) if isinstance(row, dict)] != [
        "natural", "clear", "refined", "male-natural", "id-photo-natural",
    ]:
        errors.append("absence.presets")
    renderer_ids = re.findall(r'^\s*id: "([^"]+)"', read(root, RENDERER), re.MULTILINE)
    if len(renderer_ids) != 74 or len(set(renderer_ids)) != 74:
        errors.append("absence.renderer.cases")
    for label, text in {
        "parameters": parameters,
        "package": read(root, PACKAGE),
        "renderer": read(root, RENDERER),
        "manifest": read(root, MANIFEST),
    }.items():
        if re.search(r"upperEyelidFullness|upper-eyelid-fullness|upper_eyelid_fullness|fullnessReduction|去脂", text, re.IGNORECASE):
            errors.append(f"absence.public.{label}")
    return sorted(set(errors))


def script_errors(source: str) -> list[str]:
    errors: list[str] = []
    required = {
        "evaluator.handoff": "75-private-evidence-evaluator.js",
        "evidence.missing-bundle": "evidence.missing-bundle",
        "evidence.metadata-only": "aggregate.aggregate_metrics?.mechanics_only === true",
        "decision.mechanics-only": "mechanics-only-not-promotion",
        "comparator.model-rights": "model_rights_status",
        "comparator.data-rights": "data_rights_status",
        "comparator.redistribution-rights": "redistribution_rights_status",
        "comparator.bounded-map": "bounded_additive_map",
        "comparator.safety": "all_safety_gates_pass",
        "comparator.superiority": "materially_outperforms_baseline",
        "evaluation.frozen-review": "evaluation.missing-frozen-results",
        "evaluation.proxy": "prohibited_proxy_absent",
        "evaluation.protected": "protected_structures_preserved",
        "privacy.output-check": "outputIsSafe",
        "privacy.reason-counts": "reason_counts",
        "privacy.aggregate": "aggregate_metrics",
        "decision.missing-guard": "if (!manifestPath)",
        "decision.no-public": "deterministic-editor",
    }
    for reason, token in required.items():
        if token not in source:
            errors.append(reason)
    if "const DURABLE_KEYS" not in source or '"contract_hash"' not in source or '"fixture_ids"' not in source:
        errors.append("privacy.durable-allowlist")
    if "const REPORT_KEYS" not in source or "phase: PHASE" not in source:
        errors.append("report.fixed-shape")
    return sorted(set(errors))


def test_errors(source: str) -> list[str]:
    errors: list[str] = []
    for token in [
        "evidence.missing-bundle",
        "evidence.metadata-only-mechanics",
        "deterministic-editor",
        "not-admitted",
        "model-rights-failure",
        "unbounded-additive-map",
        "safety-gate-failure",
        "evaluation.missing-frozen-results",
        "pixels",
        "private_locator",
        "mutation rejection",
    ]:
        if token not in source:
            errors.append(f"tests.missing.{token.replace('-', '_')}")
    if source.count('test("') != 6:
        errors.append("tests.case-count")
    return sorted(set(errors))


def artifact_errors(root: Path) -> list[str]:
    errors: list[str] = []
    context = read(root, CONTEXT)
    plan_01 = read(root, PLAN_01)
    plan_02 = read(root, PLAN_02)
    review = read(root, REVIEW)
    validation = read(root, VALIDATION)
    for token in ["No rights-approved private genuine bundle", "mechanics-only-not-promotion", "61/5/74"]:
        if token not in context:
            errors.append(f"context.{token.replace('/', '-').replace(' ', '-').lower()}")
    for token in ["78-01-01", "78-01-02", "ALG-02", "QUAL-01", "QUAL-02", "Phase-75"]:
        if token not in plan_01:
            errors.append(f"plan01.{token.lower()}")
    for token in ["78-02-01", "78-02-02", "run-no-skip-swiftpm.sh", "exact 61/5/74"]:
        if token not in plan_02:
            errors.append(f"plan02.{token.replace('/', '-').lower()}")
    if "PASSED" not in review or "mechanics-only-not-promotion" not in review:
        errors.append("review.incomplete")
    for token in [
        "78-01-01", "78-01-02", "78-02-01", "78-02-02",
        "--self-test", "--live", "run-no-skip-swiftpm.sh",
        "mechanics-only-not-promotion", "797/0/0",
    ]:
        if token not in validation:
            errors.append(f"validation.{token.replace('/', '-').replace(' ', '-').lower()}")
    return sorted(set(errors))


def phase77_errors(root: Path) -> list[str]:
    try:
        result = subprocess.run(
            ["python3", str(root / PHASE77_CHECKER), "--live", "--repo-root", str(root)],
            cwd=root,
            check=False,
            capture_output=True,
            text=True,
            timeout=20,
        )
    except (OSError, subprocess.SubprocessError):
        return ["absence.phase77-checker"]
    return [] if result.returncode == 0 else ["absence.phase77-compatibility"]


def live_errors(root: Path) -> list[str]:
    return sorted(set(
        absence_errors(root)
        + script_errors(read(root, SCRIPT))
        + test_errors(read(root, TEST))
        + artifact_errors(root)
        + phase77_errors(root)
    ))


def self_test(root: Path) -> tuple[list[str], int]:
    source = read(root, SCRIPT)
    mutations = [
        ("T-78-01", "evidence.missing-bundle", "evidence.bundle-present", "evidence.missing-bundle"),
        ("T-78-02", "aggregate.aggregate_metrics?.mechanics_only === true", "aggregate.aggregate_metrics?.mechanics_only === false", "evidence.metadata-only"),
        ("T-78-03", "model_rights_status", "model_rights", "comparator.model-rights"),
        ("T-78-04", "data_rights_status", "data_rights", "comparator.data-rights"),
        ("T-78-05", "bounded_additive_map", "bounded_map", "comparator.bounded-map"),
        ("T-78-06", "all_safety_gates_pass", "safety_gates_pass", "comparator.safety"),
        ("T-78-07", "outputIsSafe", "outputSafety", "privacy.output-check"),
        ("T-78-08", "mechanics-only-not-promotion", "promotion-ready", "decision.mechanics-only"),
    ]
    errors: list[str] = []
    rejected = 0
    for threat, old, new, expected in mutations:
        mutated = source.replace(old, new)
        if mutated == source:
            errors.append(f"{threat}.mutation-not-applied")
            continue
        if expected in script_errors(mutated):
            rejected += 1
        else:
            errors.append(f"{threat}.mutation-accepted")
    return sorted(set(errors)), rejected


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()
    root = Path(args.repo_root).resolve()
    if args.self_test:
        errors, rejected = self_test(root)
        print(json.dumps({
            "checks": 8,
            "mode": "self-test",
            "mutation_rejections": rejected,
            "phase": PHASE,
            "reason_count": len(errors),
            "reasons": errors,
            "status": "pass" if not errors and rejected == 8 else "fail",
        }, sort_keys=True, separators=(",", ":")))
        return 0 if not errors and rejected == 8 else 1
    if args.live:
        errors = live_errors(root)
        print(json.dumps({
            "checks": 5,
            "mode": "live",
            "mutation_rejections": 0,
            "phase": PHASE,
            "reason_count": len(errors),
            "reasons": errors,
            "status": "pass" if not errors else "fail",
        }, sort_keys=True, separators=(",", ":")))
        return 0 if not errors else 1
    parser.error("choose --self-test or --live")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
