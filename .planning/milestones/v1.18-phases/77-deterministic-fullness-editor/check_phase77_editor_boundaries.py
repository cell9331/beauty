#!/usr/bin/env python3
"""Phase-77 deterministic-editor compatibility, safety, and mutation gate."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


PHASE = "77"
PARAMETERS = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
PACKAGE = Path("BeautySDK/Package.swift")
RENDERER = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
MANIFEST = Path("BeautySDK/Sources/BeautyResources/Resources/manifest.json")
EDITOR = Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyUpperEyelidFullnessEditor.swift")
EDITOR_TEST = Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidFullnessEditorTests.swift")
SAFETY_TEST = Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidEditorSafetyTests.swift")
VALIDATION = Path(".planning/phases/77-deterministic-fullness-editor/77-VALIDATION.md")
THREATS = [f"T-77-{index:02d}" for index in range(1, 9)]
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


def public_fields(source: str) -> list[str]:
    return re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9_]*):", source.split("enum CodingKeys", 1)[0], re.MULTILINE)


def coding_keys(source: str) -> list[str]:
    match = re.search(r"enum CodingKeys: String, CodingKey \{(?P<body>[\s\S]*?)\n\s*\}", source)
    return re.findall(r"^\s*case ([A-Za-z][A-Za-z0-9_]*)\s*$", match.group("body"), re.MULTILINE) if match else []


def compatibility_errors(root: Path) -> list[str]:
    errors: list[str] = []
    parameters = read(root, PARAMETERS)
    if public_fields(parameters) != FIELDS:
        errors.append("compat.parameters.fields")
    if coding_keys(parameters) != FIELDS:
        errors.append("compat.parameters.coding-keys")
    try:
        manifest = json.loads(read(root, MANIFEST))
    except json.JSONDecodeError:
        manifest = None
    expected_presets = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
    if not isinstance(manifest, dict) or manifest.get("schemaVersion") != 1:
        errors.append("compat.manifest.schema")
    elif [row.get("id") for row in manifest.get("presets", []) if isinstance(row, dict)] != expected_presets:
        errors.append("compat.manifest.presets")
    render_ids = re.findall(r'^\s*id: "([^"]+)"', read(root, RENDERER), re.MULTILINE)
    if len(render_ids) != 74 or len(set(render_ids)) != 74:
        errors.append("compat.renderer.cases")
    package = read(root, PACKAGE)
    for label, text in {
        "parameters": parameters,
        "package": package,
        "renderer": read(root, RENDERER),
        "manifest": read(root, MANIFEST),
    }.items():
        if re.search(r"upperEyelidFullness|upper-eyelid-fullness|upper_eyelid_fullness|fullnessReduction", text, re.IGNORECASE):
            errors.append(f"absence.public.{label}")
    if ".package(" in package:
        errors.append("compat.package.graph")
    return sorted(set(errors))


def editor_errors(root: Path, editor: str | None = None, editor_test: str | None = None, safety_test: str | None = None) -> list[str]:
    editor = read(root, EDITOR) if editor is None else editor
    editor_test = read(root, EDITOR_TEST) if editor_test is None else editor_test
    safety_test = read(root, SAFETY_TEST) if safety_test is None else safety_test
    errors: list[str] = []
    for token in [
        "BeautyUpperEyelidFullnessEditor", "BeautyCanonicalStillImage", "lowFrequency",
        "Int(sample.red) - lowFrequency.red", "let correction = lowFrequencyCorrection",
        "let lowFrequency = sourceLayout.lowFrequency(at: pixelIndex)", "let reconstructedRed", "guard request.strength > 0 else",
        "maximumAbsoluteChannelDelta", "min(max(raw, -maximumAbsoluteChannelDelta), maximumAbsoluteChannelDelta)",
        "proposalsByEye", "makeUnits(using owner",
    ]:
        if token not in editor:
            errors.append(f"editor.missing.{token.replace(' ', '-').replace('(', '').replace(')', '')}")
    if "BeautyEngine" in editor or "CIFilter" in editor or "CIContext" in editor or "Warp" in editor:
        errors.append("editor.forbidden-route")
    if re.search(r"^\s*public\s+", editor, re.MULTILINE):
        errors.append("editor.public-surface")
    if '"rgba8Data"' in editor or '"pixelIndices"' in editor or '"CoordinatePoint"' in editor:
        errors.append("editor.privacy-diagnostic")
    for token in [
        "testApprovedPixelUsesLowFrequencyCorrectionAndCarriesOriginalDetail",
        "maximumAbsoluteChannelDelta", "proposalsByEye", "UInt8(sourcePixel.red + correction.red)",
        "testInvalidStrengthAndRepeatedRequestsFailClosedDeterministically",
    ]:
        if token not in editor_test:
            errors.append(f"tests.editor.{token.replace(' ', '-')}")
    for token in [
        "changedOutsideUnionPixelCount", "collisionPixelCount", "protected pixel",
        "rgba8Data", "metadata", "makeUnits(using: owner)", "sourceBytes",
    ]:
        if token not in safety_test:
            errors.append(f"tests.safety.{token.replace(' ', '-')}")
    return sorted(set(errors))


def validation_errors(root: Path) -> list[str]:
    text = read(root, VALIDATION)
    errors: list[str] = []
    for task in ["77-01-01", "77-01-02", "77-02-01", "77-02-02"]:
        if task not in text:
            errors.append(f"validation.task.{task}")
    for threat in THREATS:
        if threat not in text:
            errors.append(f"validation.threat.{threat}")
    for command in ["swift test", "--self-test", "--live", "run-no-skip-swiftpm.sh"]:
        if command not in text:
            errors.append(f"validation.command.{command.replace(' ', '-')}")
    return sorted(set(errors))


def live_errors(root: Path) -> list[str]:
    return sorted(set(compatibility_errors(root) + editor_errors(root) + validation_errors(root)))


def self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    rejected = 0
    editor = read(root, EDITOR)
    editor_test = read(root, EDITOR_TEST)
    safety_test = read(root, SAFETY_TEST)
    parameters = read(root, PARAMETERS)
    mutations = [
        ("T-77-01", editor, editor.replace("let lowFrequency = sourceLayout.lowFrequency(at: pixelIndex)", "let lowFrequency = RGB(red: 0, green: 0, blue: 0)", 1), "editor.missing.let-lowFrequency-=-sourceLayout.lowFrequencyat:-pixelIndex"),
        ("T-77-02", editor, editor.replace("Int(sample.red) - lowFrequency.red", "Int(sample.red)", 1), "editor.missing.Intsample.red---lowFrequency.red"),
        ("T-77-03", editor, editor.replace("min(max(raw, -maximumAbsoluteChannelDelta), maximumAbsoluteChannelDelta)", "raw", 1), "editor.missing.minmaxraw,--maximumAbsoluteChannelDelta,-maximumAbsoluteChannelDelta"),
        ("T-77-04", editor, editor.replace("guard request.strength > 0 else", "guard request.strength >= 0 else", 1), "editor.missing.guard-request.strength->-0-else"),
        ("T-77-05", safety_test, safety_test.replace("changedOutsideUnionPixelCount", "changedOutsideUnion", 1), "tests.safety.changedOutsideUnionPixelCount"),
        ("T-77-06", safety_test, safety_test.replace("collisionPixelCount", "collisionCount"), "tests.safety.collisionPixelCount"),
        ("T-77-07", parameters, parameters.replace("public var skinSmoothing:", "public var phase77Field:", 1), "compat.parameters.fields"),
        ("T-77-08", editor, editor.replace("proposalPixelCount:", '\"rgba8Data\":', 1), "editor.privacy-diagnostic"),
    ]
    for threat, original, mutated, expected in mutations:
        if mutated == original:
            errors.append(f"{threat}.mutation-not-applied")
            continue
        if threat == "T-77-01":
            found = "editor.missing.let-lowFrequency-=-sourceLayout.lowFrequencyat:-pixelIndex" in editor_errors(root, editor=mutated)
        elif threat == "T-77-02":
            found = "editor.missing.Intsample.red---lowFrequency.red" in editor_errors(root, editor=mutated)
        elif threat == "T-77-03":
            found = "editor.missing.minmaxraw,--maximumAbsoluteChannelDelta,-maximumAbsoluteChannelDelta" in editor_errors(root, editor=mutated)
        elif threat == "T-77-04":
            found = "editor.missing.guard-request.strength->-0-else" in editor_errors(root, editor=mutated)
        elif threat == "T-77-05":
            found = "tests.safety.changedOutsideUnionPixelCount" in editor_errors(root, safety_test=mutated)
        elif threat == "T-77-06":
            found = "tests.safety.collisionPixelCount" in editor_errors(root, safety_test=mutated)
        elif threat == "T-77-07":
            found = "compat.parameters.fields" in compatibility_errors_with_parameters(root, mutated)
        else:
            found = "editor.privacy-diagnostic" in editor_errors(root, editor=mutated)
        if found:
            rejected += 1
        else:
            errors.append(f"{threat}.mutation-accepted")
    return sorted(set(errors)), rejected


def compatibility_errors_with_parameters(root: Path, parameters: str) -> list[str]:
    errors: list[str] = []
    if public_fields(parameters) != FIELDS:
        errors.append("compat.parameters.fields")
    if coding_keys(parameters) != FIELDS:
        errors.append("compat.parameters.coding-keys")
    return errors


def emit(mode: str, errors: list[str], mutation_rejections: int = 0) -> int:
    payload = {
        "phase": PHASE,
        "mode": mode,
        "status": "pass" if not errors else "fail",
        "checks": 5 if mode == "live" else 8,
        "mutation_rejections": mutation_rejections,
        "reason_count": len(errors),
        "reasons": sorted(set(errors)),
    }
    print(json.dumps(payload, sort_keys=True, separators=(",", ":")))
    return 0 if not errors else 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path("."))
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--live", action="store_true")
    args = parser.parse_args()
    root = args.repo_root.resolve()
    if args.self_test:
        errors, rejected = self_test(root)
        if rejected != len(THREATS):
            errors.append("self-test.mutation-count")
        return emit("self-test", errors, rejected)
    return emit("live", live_errors(root))


if __name__ == "__main__":
    sys.exit(main())
