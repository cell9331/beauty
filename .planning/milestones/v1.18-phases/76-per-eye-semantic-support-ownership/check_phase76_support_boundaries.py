#!/usr/bin/env python3
"""Phase-76 compatibility, ownership, privacy, and mutation gate.

The checker emits only normalized identifiers and counts. It intentionally does
not print source matches, fixture values, raw pixels, masks, landmarks, or
filesystem paths.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


PHASE = "76"
PARAMETERS = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
PACKAGE = Path("BeautySDK/Package.swift")
RENDERER = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
MANIFEST = Path("BeautySDK/Sources/BeautyResources/Resources/manifest.json")
SUPPORT = Path("BeautySDK/Sources/BeautyDetection/BeautyUpperEyelidSemanticSupport.swift")
DETECTOR = Path("BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift")
SUPPORT_TEST = Path("BeautySDK/Tests/BeautyDetectionTests/UpperEyelidSemanticSupportTests.swift")
DETECTOR_TEST = Path("BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift")
COMPOSITION_TEST = Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidSupportCompositionTests.swift")
COORDINATE_TEST = Path("BeautySDK/Tests/BeautyDetectionTests/CoordinateMapperTests.swift")
VALIDATION = Path(".planning/phases/76-per-eye-semantic-support-ownership/76-VALIDATION.md")

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
THREATS = [f"T-76-{index:02d}" for index in range(1, 9)]


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


def compatibility_errors(root: Path) -> list[str]:
    errors: list[str] = []
    parameters = read(root, PARAMETERS)
    if public_fields(parameters) != FIELDS:
        errors.append("compat.parameters.fields")
    if coding_keys(parameters) != FIELDS:
        errors.append("compat.parameters.coding-keys")

    manifest = json_read(root, MANIFEST)
    if not isinstance(manifest, dict) or manifest.get("schemaVersion") != 1:
        errors.append("compat.manifest.schema")
    else:
        presets = manifest.get("presets")
        expected = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
        if not isinstance(presets, list) or [row.get("id") for row in presets if isinstance(row, dict)] != expected:
            errors.append("compat.manifest.presets")

    render_ids = re.findall(r'^\s*id: "([^"]+)"', read(root, RENDERER), re.MULTILINE)
    if len(render_ids) != 74 or len(set(render_ids)) != 74:
        errors.append("compat.renderer.cases")

    package = read(root, PACKAGE)
    if ".package(" in package or "upperEyelidFullness" in package or "upper-eyelid-fullness" in package:
        errors.append("compat.package.graph")
    for label, text in {
        "parameters": parameters,
        "package": package,
        "renderer": read(root, RENDERER),
        "manifest": read(root, MANIFEST),
    }.items():
        if re.search(r"upperEyelidFullness|upper-eyelid-fullness|upper_eyelid_fullness|fullnessReduction", text, re.IGNORECASE):
            errors.append(f"absence.public.{label}")
    return sorted(set(errors))


def method_body(source: str) -> str:
    match = re.search(
        r"package mutating func detectWithUpperEyelidSupport[\s\S]*?\n    \}\n\n    package mutating func resetTracking",
        source,
    )
    return match.group(0) if match else ""


def support_errors(root: Path, support: str | None = None, detector: str | None = None) -> list[str]:
    support = read(root, SUPPORT) if support is None else support
    detector = read(root, DETECTOR) if detector is None else detector
    errors: list[str] = []
    method = method_body(detector)
    required_support = [
        "BeautyUpperEyelidSemanticRequest", "BeautyUpperEyelidSemanticApproval",
        "BeautyUpperEyelidEyeOutcome", "BeautyUpperEyelidSupportResolution",
        "typealias SemanticOwner = @Sendable",
        "guard approval.approved else", "contains(approval.hardEnvelope, point: point)",
        "Set<Int>()", "return .sourceExactNoOp", "CustomReflectable",
    ]
    for token in required_support:
        if token not in support:
            errors.append(f"support.missing.{token.replace(' ', '-').replace('(', '').replace(')', '')}")
    if re.search(r"\bCoordinateMapper\s*\(", support) or "CIImage" in support or re.search(r"\b(?:struct|enum|class)\s+\w+[^\n]*:\s*[^\n]*Codable", support):
        errors.append("support.owns-conversion-or-persistence")
    if "[left, right]" not in support:
        errors.append("support.side-isolation")
    if not method:
        errors.append("route.method-missing")
    else:
        if method.count("let detection = detect(") != 1:
            errors.append("route.detector-call-count")
        if method.count("BeautyUpperEyelidSemanticSupportOwner.resolve(") != 1:
            errors.append("route.owner-call-count")
        for token in [
            "detection.observations.first", "selectedObservationID", ".localSupport",
            "VisionFaceDetectionWithUpperEyelidSupportResult",
        ]:
            if token not in method:
                errors.append(f"route.missing.{token.replace('.', '-')}")
    if "VisionFaceDetector(" in support:
        errors.append("route.provider-reentrancy")

    privacy_region = ""
    if "extension BeautyUpperEyelidEyeOutcome" in support:
        privacy_region += support.split("extension BeautyUpperEyelidEyeOutcome", 1)[1].split(
            "\npackage struct BeautyUpperEyelidSupportResolution", 1
        )[0]
    if "extension BeautyUpperEyelidSupportResolution" in support:
        privacy_region += support.split("extension BeautyUpperEyelidSupportResolution", 1)[1].split(
            "\npackage enum BeautyUpperEyelidSemanticSupportOwner", 1
        )[0]
    for token in ['"pixelIndices"', '"hardEnvelope"', "CoordinatePoint", "file://", "/private/"]:
        if token in privacy_region:
            errors.append(f"privacy.diagnostic.{token.replace('/', '-')}")
    return sorted(set(errors))


def test_errors(root: Path) -> list[str]:
    errors: list[str] = []
    support_test = read(root, SUPPORT_TEST)
    detector_test = read(root, DETECTOR_TEST)
    composition_test = read(root, COMPOSITION_TEST)
    coordinate_test = read(root, COORDINATE_TEST)
    for token in [
        "semanticOwnerUnavailable", "sourceExactNoOp", "duplicatePixel", "outOfBoundsMask",
        "outsideHardEnvelope", "NonFiniteConfidence", "requestedObservations",
    ]:
        if token not in support_test:
            errors.append(f"tests.support.{token}")
    for token in [
        "invocationCount, 1", "callCount, 1", "selectedObservationID", "request.eyeEnvelope",
        "MalformedMappedEyeSupport", "supportResolution.supportedEyeCount",
    ]:
        if token not in detector_test:
            errors.append(f"tests.route.{token.replace('.', '-')}")
    for token in [
        "SourceExact", "collisionPixelCount", "changedPixelCount", "rgba8Data",
        "metadata", "BeautyUpperEyelidSupportResolution",
    ]:
        if token not in composition_test or token == "collisionPixelCount" and composition_test.count(token) < 2:
            errors.append(f"tests.composition.{token.replace(' ', '-')}")
    for token in [".up", ".down", ".left", ".right", "isInputMirrored"]:
        if token not in coordinate_test:
            errors.append(f"tests.mapper.{token.replace('.', '')}")
    return sorted(set(errors))


def validation_errors(root: Path) -> list[str]:
    text = read(root, VALIDATION)
    errors: list[str] = []
    for task in ["76-01-01", "76-01-02", "76-02-01", "76-02-02"]:
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
    return sorted(set(
        compatibility_errors(root)
        + support_errors(root)
        + test_errors(root)
        + validation_errors(root)
    ))


def self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    rejected = 0
    detector = read(root, DETECTOR)
    support = read(root, SUPPORT)
    composition = read(root, COMPOSITION_TEST)

    mutations = [
        ("T-76-01", detector, detector.replace("let detection = detect(", "let detection = disabledDetect(", 1), "route.detector-call-count"),
        ("T-76-02", support, support.replace("[left, right]", "[left, left]", 1), "support.side-isolation"),
        ("T-76-03", support, support.replace("guard approval.approved else", "guard approval.reason == .approved else", 1), "support.missing.guard-approval.approved-else"),
        ("T-76-04", support, support.replace("return .sourceExactNoOp", "return .supported"), "support.missing.return-.sourceExactNoOp"),
        ("T-76-05", support, support.replace("contains(approval.hardEnvelope, point: point)", "true", 1), "support.missing.containsapproval.hardEnvelope,-point:-point"),
        ("T-76-06", detector, detector.replace("purpose: .localSupport", "purpose: .geometry", 1), "route.missing.-localSupport"),
        ("T-76-07", composition, composition.replace("collisionPixelCount", "collisionCount"), "tests.composition.collisionPixelCount"),
        ("T-76-08", support, support.replace('"pixelCount": pixelIndices.count', '"pixelCount": "CoordinatePoint"', 1), "privacy.diagnostic.CoordinatePoint"),
    ]
    for threat, original, mutated, expected in mutations:
        if mutated == original:
            errors.append(f"{threat}.mutation-not-applied")
            continue
        if threat == "T-76-01":
            found = "route.detector-call-count" in support_errors(root, detector=mutated)
        elif threat == "T-76-02":
            found = "support.side-isolation" in support_errors(root, support=mutated)
        elif threat == "T-76-03":
            found = "support.missing.guard-approval.approved-else" in support_errors(root, support=mutated)
        elif threat == "T-76-04":
            found = "support.missing.return-.sourceExactNoOp" in support_errors(root, support=mutated)
        elif threat == "T-76-05":
            found = "support.missing.containsapproval.hardEnvelope,-point:-point" in support_errors(root, support=mutated)
        elif threat == "T-76-06":
            found = "route.missing.-localSupport" in support_errors(root, detector=mutated)
        elif threat == "T-76-07":
            found = "tests.composition.collisionPixelCount" in test_errors_with_composition(root, mutated)
        else:
            found = "privacy.diagnostic.CoordinatePoint" in support_errors(root, support=mutated)
        if found:
            rejected += 1
        else:
            errors.append(f"{threat}.mutation-accepted")
    return sorted(set(errors)), rejected


def test_errors_with_composition(root: Path, composition: str) -> list[str]:
    original = read(root, COMPOSITION_TEST)
    temporary = root / ".phase76-composition-mutation-not-written"
    # Keep the mutation in memory; the helper only varies the source text.
    errors = []
    for token in ["SourceExact", "collisionPixelCount", "changedPixelCount", "rgba8Data", "metadata", "BeautyUpperEyelidSupportResolution"]:
        if token not in composition:
            errors.append(f"tests.composition.{token.replace(' ', '-')}")
    del original, temporary
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
