#!/usr/bin/env python3
"""Phase-79 failing-branch, compatibility, backend, and docs gate.

Only normalized reasons and counts are printed. Internal mechanics are allowed;
public activation and decision bypass are not.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path


PHASE = "79"
BASELINE_COMMIT = "cd312d0"
PHASE_DIR = Path(".planning/phases/79-conditional-productization-and-sdk-only-closeout")
PHASE78_VERIFICATION = Path(".planning/phases/78-genuine-evaluation-and-candidate-decision/78-VERIFICATION.md")
CONTEXT = PHASE_DIR / "79-CONTEXT.md"
PLAN_01 = PHASE_DIR / "79-01-PLAN.md"
PLAN_02 = PHASE_DIR / "79-02-PLAN.md"
REVIEW = PHASE_DIR / "79-REVIEW.md"
VALIDATION = PHASE_DIR / "79-VALIDATION.md"
PARAMETERS = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
PACKAGE = Path("BeautySDK/Package.swift")
RENDERER = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
MANIFEST = Path("BeautySDK/Sources/BeautyResources/Resources/manifest.json")
TAXONOMY = Path("docs/SDK_EFFECT_TAXONOMY.md")
PRODUCT = Path("PRODUCT_SENSE.md")
DOCS_README = Path("docs/README.md")

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


def absence_errors(
    root: Path,
    parameters_override: str | None = None,
    renderer_override: str | None = None,
    package_override: str | None = None,
    manifest_override: str | None = None,
) -> list[str]:
    parameters = parameters_override if parameters_override is not None else read(root, PARAMETERS)
    renderer = renderer_override if renderer_override is not None else read(root, RENDERER)
    package = package_override if package_override is not None else read(root, PACKAGE)
    manifest_text = manifest_override if manifest_override is not None else read(root, MANIFEST)
    errors: list[str] = []
    if public_fields(parameters) != FIELDS:
        errors.append("absence.parameters.fields")
    if coding_keys(parameters) != FIELDS:
        errors.append("absence.parameters.coding-keys")
    manifest = json.loads(manifest_text) if manifest_text else None
    if not isinstance(manifest, dict) or manifest.get("schemaVersion") != 1:
        errors.append("absence.resource-manifest")
    elif [row.get("id") for row in manifest.get("presets", []) if isinstance(row, dict)] != [
        "natural", "clear", "refined", "male-natural", "id-photo-natural",
    ]:
        errors.append("absence.presets")
    renderer_ids = re.findall(r'^\s*id: "([^"]+)"', renderer, re.MULTILINE)
    if len(renderer_ids) != 74 or len(set(renderer_ids)) != 74:
        errors.append("absence.renderer.cases")
    if ".package(" in package or re.search(r"upperEyelidFullness|upper-eyelid-fullness|fullnessReduction|去脂", package, re.IGNORECASE):
        errors.append("absence.package.graph")
    for label, text in {
        "parameters": parameters,
        "renderer": renderer,
        "manifest": manifest_text,
    }.items():
        if re.search(r"upperEyelidFullness|upper-eyelid-fullness|upper_eyelid_fullness|fullnessReduction|去脂", text, re.IGNORECASE):
            errors.append(f"absence.public.{label}")
    return sorted(set(errors))


def decision_errors(verification: str) -> list[str]:
    errors: list[str] = []
    required = {
        "decision.recommendation": "decision: mechanics-only-not-promotion",
        "decision.no-public": "no public field or renderer case",
        "decision.private-bundle": "no rights-approved genuine positives",
    }
    for reason, token in required.items():
        if token not in verification:
            errors.append(reason)
    return sorted(set(errors))


def taxonomy_errors(taxonomy: str) -> list[str]:
    errors: list[str] = []
    required = {
        "taxonomy.fullness-future": "| 眼睛 | 去脂 | future | — |",
        "taxonomy.eyes-partial": "`眼睛` is partial",
        "taxonomy.no-public": "Appearance in this document never creates a public API",
        "taxonomy.mechanics-decision": "mechanics-only-not-promotion",
    }
    for reason, token in required.items():
        if token not in taxonomy:
            errors.append(reason)
    return sorted(set(errors))


def backend_errors(text: str) -> list[str]:
    required = {
        "backend.cpu": ".cpu",
        "backend.gpu": ".gpu",
        "backend.unavailable": ".metalUnavailable",
        "backend.no-fallback": "no CPU fallback",
        "backend.alpha": "alpha",
        "backend.extent": "extent",
        "backend.named-srgb": "named sRGB",
        "backend.deterministic": "deterministic",
        "backend.request-local": "request-local",
    }
    return sorted(reason for reason, token in required.items() if token not in text)


def docs_errors(root: Path) -> list[str]:
    product = read(root, PRODUCT)
    readme = read(root, DOCS_README)
    errors: list[str] = []
    for reason, token in {
        "docs.product-decision": "mechanics-only-not-promotion",
        "docs.product-absence": "61-field",
        "docs.product-no-device": "release readiness",
        "docs.readme-audit": "Last audited: 2026-08-22",
        "docs.readme-sdk-only": "active repository is SDK-only",
    }.items():
        if token not in (product if reason.startswith("docs.product") else readme):
            errors.append(reason)
    return sorted(set(errors))


def source_diff_errors(root: Path, changed_output: str | None = None) -> list[str]:
    if changed_output is not None:
        return ["source.production-diff"] if changed_output.strip() else []
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only", BASELINE_COMMIT, "--", "BeautySDK/Sources", "BeautySDK/Package.swift"],
            cwd=root, check=False, capture_output=True, text=True, timeout=20,
        )
    except (OSError, subprocess.SubprocessError):
        return ["source.diff-scan"]
    if result.returncode != 0:
        return ["source.diff-scan"]
    return ["source.production-diff"] if result.stdout.strip() else []


def artifact_errors(root: Path) -> list[str]:
    errors: list[str] = []
    context = read(root, CONTEXT)
    plan_01 = read(root, PLAN_01)
    plan_02 = read(root, PLAN_02)
    review = read(root, REVIEW)
    validation = read(root, VALIDATION)
    for token in ["mechanics-only-not-promotion", "exactly 61", "future", "SDK-only"]:
        if token not in context:
            errors.append(f"context.{token.replace(' ', '-')}")
    for token in ["79-01-01", "SAFE-03", "COMPAT-01", "COMPAT-02", "BACKEND-01", "PROMOTE-01"]:
        if token not in plan_01:
            errors.append(f"plan01.{token.lower()}")
    for token in ["79-02-01", "79-02-02", "DOCS-01", "run-no-skip-swiftpm.sh"]:
        if token not in plan_02:
            errors.append(f"plan02.{token.lower()}")
    if "PASSED" not in review or "failing branch" not in review:
        errors.append("review.incomplete")
    for token in ["79-01-01", "79-02-01", "79-02-02", "797/0/0", "61/5/74", "mechanics-only-not-promotion"]:
        if token not in validation:
            errors.append(f"validation.{token.replace('/', '-')}")
    return sorted(set(errors))


def live_errors(root: Path) -> list[str]:
    backend_text = "\n".join([
        read(root, Path("DESIGN.md")),
        read(root, Path("RELIABILITY.md")),
        read(root, Path("SECURITY.md")),
        read(root, Path("BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift")),
        read(root, Path("BeautySDK/Sources/BeautySDK/BeautyBackendFactory.swift")),
        read(root, Path("BeautySDK/Sources/BeautyEffects/Backend/BeautyBackendContract.swift")),
        read(root, Path("BeautySDK/Sources/BeautyEffects/Backend/BeautyMetalBackend.swift")),
    ])
    return sorted(set(
        absence_errors(root)
        + decision_errors(read(root, PHASE78_VERIFICATION))
        + taxonomy_errors(read(root, TAXONOMY))
        + backend_errors(backend_text)
        + docs_errors(root)
        + source_diff_errors(root)
        + artifact_errors(root)
    ))


def self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    rejected = 0
    parameters = read(root, PARAMETERS)
    renderer = read(root, RENDERER)
    package = read(root, PACKAGE)
    taxonomy = read(root, TAXONOMY)
    verification = read(root, PHASE78_VERIFICATION)
    backend_text = "\n".join([
        read(root, Path("DESIGN.md")),
        read(root, Path("RELIABILITY.md")),
        read(root, Path("SECURITY.md")),
    ])
    mutations = [
        ("T-79-01", decision_errors(verification), verification.replace("decision: mechanics-only-not-promotion", "decision: promotion-ready", 1), "decision.recommendation", "decision"),
        ("T-79-02", absence_errors(root), None, "absence.parameters.fields", "parameters"),
        ("T-79-03", absence_errors(root), None, "absence.renderer.cases", "renderer"),
        ("T-79-04", absence_errors(root), None, "absence.package.graph", "package"),
        ("T-79-05", taxonomy_errors(taxonomy), taxonomy.replace("| 眼睛 | 去脂 | future |", "| 眼睛 | 去脂 | implemented |", 1), "taxonomy.fullness-future", "taxonomy"),
        ("T-79-06", backend_errors(backend_text), backend_text.replace(".metalUnavailable", ".metalFallback"), "backend.unavailable", "backend"),
        ("T-79-07", backend_errors(backend_text), backend_text.replace("named sRGB", "device RGB"), "backend.named-srgb", "backend"),
        ("T-79-08", source_diff_errors(root), "BeautySDK/Sources/Injected.swift", "source.production-diff", "source"),
    ]
    for threat, _, mutated, expected, kind in mutations:
        if kind == "parameters":
            mutated = parameters.replace("enum CodingKeys", "public var phase79Placeholder: Double = 0\n\n    enum CodingKeys", 1)
            found = expected in absence_errors(root, parameters_override=mutated)
        elif kind == "renderer":
            mutated = renderer.replace('id: "', 'id: "phase79-added",\n        id: "', 1)
            found = expected in absence_errors(root, renderer_override=mutated)
        elif kind == "package":
            mutated = f".package(url: \"https://example.invalid\")\n{package}"
            found = expected in absence_errors(root, package_override=mutated)
        elif kind == "taxonomy":
            found = expected in taxonomy_errors(mutated)
        elif kind == "backend":
            found = expected in backend_errors(mutated)
        elif kind == "source":
            found = expected in source_diff_errors(root, changed_output=mutated)
        else:
            found = expected in decision_errors(mutated)
        if found:
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
            "checks": 8,
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
