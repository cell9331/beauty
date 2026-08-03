#!/usr/bin/env python3
"""Fail-closed Phase 55 composition, privacy, scope, and compatibility checker."""

from __future__ import annotations

import argparse
import copy
import json
import pathlib
import re
import subprocess
import sys
from dataclasses import dataclass, replace


ROOT = pathlib.Path(__file__).resolve().parents[3]
PHASE = ROOT / ".planning" / "phases" / "55-original-pixel-composition-and-failure-isolation-core"
PACKAGE = ROOT / "BeautySDK" / "Package.swift"
SOURCE_ROOT = ROOT / "BeautySDK" / "Sources"
DEMO_ROOT = ROOT / "BeautyDemo" / "BeautyDemo"
PARAMETERS = SOURCE_ROOT / "BeautyCore" / "Models" / "BeautyParameters.swift"
MANIFEST = SOURCE_ROOT / "BeautyResources" / "Resources" / "manifest.json"
PRESET_ROOT = SOURCE_ROOT / "BeautyResources" / "Resources" / "Presets"
RENDERER = SOURCE_ROOT / "BeautyExampleRenderer" / "main.swift"
ENGINE = SOURCE_ROOT / "BeautySDK" / "BeautyEngine.swift"
TESTING_SUPPORT = SOURCE_ROOT / "BeautySDK" / "BeautyEngineTestingSupport.swift"
ADMISSION = SOURCE_ROOT / "BeautyEffects" / "Planning" / "BeautyLocalRetouchAdmission.swift"
RESOLVER = SOURCE_ROOT / "BeautyEffects" / "Planning" / "BeautyEffectResolver.swift"
COMPOSITION = SOURCE_ROOT / "BeautyEffects" / "Render" / "BeautyLocalRetouchComposition.swift"
CANONICAL = SOURCE_ROOT / "BeautyCore" / "Models" / "BeautyCanonicalStillImage.swift"
UNIT_TEST = ROOT / "BeautySDK" / "Tests" / "BeautyEffectsTests" / "BeautyLocalRetouchCompositionTests.swift"
FACADE_TEST = ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" / "BeautyEngineLocalRetouchCompositionTests.swift"
INVENTORY = PHASE / "55-THREAT-INVENTORY.json"

THREAT_IDS = tuple(f"T-55-{index:02d}" for index in range(1, 8))
EXPECTED_SUMMARY_FIELDS = (
    "acceptedUnitCount",
    "rejectedUnitCount",
    "ownedPixelCount",
    "changedPixelCount",
    "changedOutsideUnionPixelCount",
    "collisionPixelCount",
)
CANDIDATE_NAMES = (
    "teethWhitening",
    "scleraRednessReduction",
    "upperEyelidFullnessReduction",
)
EXPECTED_TARGETS = {
    "BeautyCore",
    "BeautyDetection",
    "BeautyRender",
    "BeautyResources",
    "BeautyEffects",
    "BeautySDK",
    "BeautyExampleRenderer",
    "BeautySDKTests",
    "BeautyCoreTests",
    "BeautyDetectionTests",
    "BeautyEffectsTests",
    "BeautyRenderTests",
    "BeautyResourcesTests",
}
EXPECTED_PRESETS = (
    "natural",
    "clear",
    "refined",
    "male-natural",
    "id-photo-natural",
)
EXPECTED_RENDERER_IDS = (
    "skinSmoothing_0p50", "skinWhitening_0p50", "skinRosy_0p40",
    "skinSharpen_0p40", "brightness_plus0p25", "contrast_plus0p25",
    "filter_softClean_0p50", "filter_warmLight_0p50", "skinCombo_0p50",
    "geometryBaseline_noop", "faceShapeCombo_0p35", "faceSlim_0p35",
    "faceSmall_0p35", "chinLength_plus0p30", "chinLength_minus0p30",
    "faceVShape_0p35", "jawSlim_0p35", "faceContourSmooth_0p25",
    "templeFullness_0p25", "cheekboneSlim_0p25", "chinTaper_0p25",
    "eyeSize_0p35", "eyeDistance_plus0p25", "eyeDistance_minus0p25",
    "eyeYPosition_plus0p20", "eyeYPosition_minus0p20", "eyeTailLift_0p25",
    "eyeHeight_0p25", "eyeLength_0p25", "upperEyelidLift_0p25",
    "pupilSize_0p25", "gazeCorrection_0p25", "lowerEyelidDrop_0p25",
    "eyeTilt_plus0p25", "eyeTilt_minus0p25", "innerCornerOpen_0p25",
    "outerCornerOpen_0p25", "eyeSymmetry_0p25", "eyebrowYPosition_plus0p25",
    "eyebrowYPosition_minus0p25", "eyebrowThickness_plus0p25",
    "eyebrowThickness_minus0p25", "eyebrowLength_plus0p25",
    "eyebrowLength_minus0p25", "eyebrowSpacing_plus0p25",
    "eyebrowSpacing_minus0p25", "eyebrowHeadSpacing_plus0p25",
    "eyebrowHeadSpacing_minus0p25", "eyebrowTilt_plus0p25",
    "eyebrowTilt_minus0p25", "eyebrowPeakDefinition_0p25", "noseSlim_0p35",
    "noseWingSlim_0p35", "noseTipSize_plus0p30", "noseTipSize_minus0p30",
    "noseBridge_0p30", "noseRootNarrowing_0p25", "noseTipLift_0p25",
    "mouthSize_plus0p35", "mouthSize_minus0p35", "mouthWidth_plus0p35",
    "mouthWidth_minus0p35", "smile_0p50", "lipColor_0p50",
    "mouthYPosition_plus0p25", "mouthYPosition_minus0p25",
    "mouthTilt_plus0p25", "mouthTilt_minus0p25", "mouthXPosition_plus0p25",
    "mouthXPosition_minus0p25", "lipPeakDefinition_0p25", "lipPlump_0p25",
)


class ScannerFailure(RuntimeError):
    """An external scanner outcome was neither match nor clean."""


def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise ScannerFailure("unclassified scanner outcome")


def run_rg(pattern: str, paths: tuple[pathlib.Path, ...], glob: str = "*.swift") -> str:
    completed = subprocess.run(
        ["rg", "--hidden", "--glob", glob, pattern, *map(str, paths)],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    return classify_rg(completed.returncode, completed.stdout, completed.stderr)


def expected_inventory() -> dict[str, object]:
    rows = [
        ("T-55-01", ["Spoofing", "Tampering"], ["exact_source_storage_binding", "foreign_byte_equal_carrier_rejection"]),
        ("T-55-02", ["Tampering", "Denial of Service"], ["checked_dimension_count_index_offset_arithmetic", "bounded_unit_and_claim_totals"]),
        ("T-55-03", ["Tampering"], ["prefilter_duplicate_index_rejection", "duplicate_token_rejection", "all_permutation_equality"]),
        ("T-55-04", ["Tampering"], ["two_and_three_owner_collision_to_source", "one_count_per_collision_pixel", "no_priority_resolution"]),
        ("T-55-05", ["Information Disclosure"], ["package_only_non_codable_mechanics", "aggregate_only_testing_observation", "no_stable_output_digest"]),
        ("T-55-06", ["Tampering", "Information Disclosure"], ["valid_invalid_valid_nonretention", "pixel_buffer_zero_work", "reset_zero_work"]),
        ("T-55-07", ["Elevation of Privilege", "Tampering"], ["exact_empty_production_admission", "exact_59_5_72_compatibility", "no_candidate_demo_dependency_route"]),
    ]
    return {
        "schema_version": 1,
        "security_standard": "OWASP ASVS Level 1",
        "block_on": "HIGH",
        "threats": [
            {
                "id": threat_id,
                "stride": stride,
                "severity": "HIGH",
                "disposition": "mitigate",
                "gates": gates,
            }
            for threat_id, stride, gates in rows
        ],
    }


def validate_inventory(document: object) -> bool:
    return document == expected_inventory()


def required_common_paths() -> tuple[pathlib.Path, ...]:
    return (
        PACKAGE, PARAMETERS, MANIFEST, RENDERER, ENGINE, TESTING_SUPPORT,
        ADMISSION, RESOLVER, UNIT_TEST, FACADE_TEST, INVENTORY,
    )


def extract_coding_keys(text: str) -> tuple[str, ...]:
    match = re.search(r"enum CodingKeys[^\{]*\{(.*?)\n\s*\}", text, re.DOTALL)
    if match is None:
        return ()
    return tuple(re.findall(r"^\s*case\s+([A-Za-z][A-Za-z0-9]*)\s*$", match.group(1), re.MULTILINE))


def package_let_fields(text: str, start: str, end: str) -> tuple[str, ...]:
    start_index = text.find(start)
    end_index = text.find(end, start_index + len(start)) if start_index >= 0 else -1
    if start_index < 0 or end_index < 0:
        return ()
    return tuple(re.findall(r"^\s*package let\s+([A-Za-z][A-Za-z0-9]*)\s*:", text[start_index:end_index], re.MULTILINE))


def public_let_fields(text: str, start: str, end: str) -> tuple[str, ...]:
    start_index = text.find(start)
    end_index = text.find(end, start_index + len(start)) if start_index >= 0 else -1
    if start_index < 0 or end_index < 0:
        return ()
    return tuple(re.findall(r"^\s*public let\s+([A-Za-z][A-Za-z0-9]*)\s*:", text[start_index:end_index], re.MULTILINE))


def engine_section(text: str, start: str, end: str) -> str:
    start_index = text.find(start)
    end_index = text.find(end, start_index + len(start)) if start_index >= 0 else -1
    if start_index < 0 or end_index < 0:
        return ""
    return text[start_index:end_index]


def common_failures() -> set[str]:
    failures: set[str] = set()
    if any(not path.is_file() for path in required_common_paths()):
        return {"R55-REQUIRED"}

    try:
        inventory = json.loads(INVENTORY.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {"R55-INVENTORY"}
    if not validate_inventory(inventory):
        failures.add("R55-INVENTORY")

    package_text = PACKAGE.read_text(encoding="utf-8")
    targets = set(re.findall(r"(?:executableTarget|testTarget|target)\s*\(\s*name:\s*\"([^\"]+)\"", package_text))
    products = tuple(re.findall(r"\.(?:library|executable)\s*\(\s*name:\s*\"([^\"]+)\"", package_text))
    resources = tuple(re.findall(r"\.process\(\"([^\"]+)\"\)", package_text))
    if (
        targets != EXPECTED_TARGETS
        or products != ("BeautySDK", "BeautyExampleRenderer")
        or resources != ("Shaders", "Resources")
        or re.search(r"\.package\s*\(", package_text)
    ):
        failures.add("R55-PACKAGE")

    parameter_text = PARAMETERS.read_text(encoding="utf-8")
    stored = tuple(re.findall(r"^\s*public var\s+([A-Za-z][A-Za-z0-9]*)\s*:", parameter_text, re.MULTILINE))
    coding = extract_coding_keys(parameter_text)
    if len(stored) != 59 or coding != stored or stored.count("filterId") != 1:
        failures.add("R55-FIELDS")

    try:
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        failures.add("R55-PRESETS")
    else:
        preset_ids = tuple(row.get("id") for row in manifest.get("presets", []))
        preset_files = tuple(sorted(path.name for path in PRESET_ROOT.glob("*.json")))
        if preset_ids != EXPECTED_PRESETS or preset_files != tuple(sorted(f"{name}.json" for name in EXPECTED_PRESETS)):
            failures.add("R55-PRESETS")

    renderer_ids = tuple(re.findall(r"\bid:\s*\"([^\"]+)\"", RENDERER.read_text(encoding="utf-8")))
    if renderer_ids != EXPECTED_RENDERER_IDS:
        failures.add("R55-RENDERER")

    resolver_text = RESOLVER.read_text(encoding="utf-8")
    admission_text = ADMISSION.read_text(encoding="utf-8")
    resolver_match = re.search(
        r"localRetouchAdmission\s*\(\s*parameters:[^\)]*\)[^{]*\{\s*_\s*=\s*parameters\s*return\s+\.none\s*\}",
        resolver_text,
        re.DOTALL,
    )
    if resolver_match is None or "opaqueDemandCount: 0" not in admission_text or "opaqueDemandCount == 0" not in admission_text:
        failures.add("R55-ADMISSION")

    candidate_pattern = "|".join(map(re.escape, CANDIDATE_NAMES))
    if run_rg(candidate_pattern, (SOURCE_ROOT, DEMO_ROOT)) == "match":
        failures.add("R55-CANDIDATE")
    if run_rg(r"BeautyLocalRetouchComposition|localRetouchComposition", (DEMO_ROOT,)) == "match":
        failures.add("R55-DEMO")

    model_suffixes = {".mlmodel", ".mlpackage", ".mlmodelc", ".onnx", ".tflite", ".pt"}
    if any(path.is_file() and path.suffix.lower() in model_suffixes for path in (ROOT / "BeautySDK").rglob("*")):
        failures.add("R55-MODEL")

    engine_text = ENGINE.read_text(encoding="utf-8")
    pixel_section = engine_section(
        engine_text,
        "public func processResult(\n        pixelBuffer",
        "/// Returns an SDK-created image",
    )
    reset_section = engine_section(engine_text, "public func reset()", "public var resetCountForTesting")
    if not pixel_section or not reset_section or re.search(r"Composition|\bcompose", pixel_section + reset_section):
        failures.add("R55-REALTIME")

    unit_text = UNIT_TEST.read_text(encoding="utf-8")
    unit_anchors = (
        "RED_MISSING_ARTIFACT:BeautyLocalRetouchComposition.swift",
        "32_768", "65_536", "UInt32.max", "standaloneA", "standaloneB",
        "standaloneC", "independentlyMergedABC", "DuplicateRawIndex",
        "DuplicateOpaqueUnitToken", "TwoAndThreeOwnerCollision",
        "EveryPermutation", "OpaqueWholePairSubunitAndFutureBandAbstentionMatrix",
        "ValidInvalidValid", "changedOutsideUnionPixelCount",
    )
    if any(anchor not in unit_text for anchor in unit_anchors):
        failures.add("R55-UNIT-SPECS")
    if "referenceBlend" not in unit_text or "independentlyMergedABC" not in unit_text:
        failures.add("R55-ORACLE")

    facade_text = FACADE_TEST.read_text(encoding="utf-8")
    facade_anchors = (
        "testExactRequestContextSourceComposesOnce",
        "testOpaqueObservationIsAggregateOnlyAndDigestFree",
        "BothExistingCIImageEntries", "sourceBindingMatched", "invocationCount",
        "BrightnessAndFilterContinuation", "ValidInvalidValid", "PixelBufferAndReset",
        "productionAdmissionCount", "changedOutsideUnionPixelCount",
    )
    if any(anchor not in facade_text for anchor in facade_anchors):
        failures.add("R55-FACADE-SPECS")
    return failures


def wave0_failures() -> set[str]:
    failures = common_failures()
    if failures:
        return failures
    support_text = TESTING_SUPPORT.read_text(encoding="utf-8")
    expected_absence = (
        not COMPOSITION.exists(),
        "SDKTestingLocalRetouchCompositionScenario" not in support_text,
        "SDKTestingLocalRetouchCompositionResult" not in support_text,
    )
    if expected_absence != (True, True, True):
        failures.add("R55-WAVE0-STATE")
    return failures


def source_binding_failures() -> set[str]:
    failures = common_failures()
    if not COMPOSITION.is_file() or not CANONICAL.is_file():
        failures.add("R55-COMPOSITION")
        return failures

    source_text = COMPOSITION.read_text(encoding="utf-8")
    canonical_text = CANONICAL.read_text(encoding="utf-8")
    required_source_anchors = (
        "package ", "BeautyCanonicalStillImage", "pixelSourceBinding",
        "ObjectIdentifier", "maximumUnitCount = 8", "effectiveUnitLimit",
        "maximumClaimsPerUnit", "multipliedReportingOverflow",
        "addingReportingOverflow", "issuedTokens", "tokenFrequency",
        "rawIndices", "isInsideHardEnvelope",
    )
    required_canonical_anchors = (
        "BeautyCanonicalPixelSourceBinding", "ObjectIdentifier(storage)",
        "pixelSourceBinding", "width: width", "height: height",
        "rowBytes: rowBytes", "byteCount: storage.rgba8Data.count",
    )
    if any(anchor not in source_text for anchor in required_source_anchors):
        failures.add("R55-SOURCE-BINDING")
    if any(anchor not in canonical_text for anchor in required_canonical_anchors):
        failures.add("R55-CANONICAL-BINDING")
    if re.search(r"\b(public|open)\b|@_spi|\bCodable\b", source_text):
        failures.add("R55-CORE-ACCESS")
    if re.search(r"URLSession|NWConnection|UserDefaults|FileHandle|NSKeyedArchiver|\bprint\s*\(|Logger\.", source_text):
        failures.add("R55-PRIVACY")

    unit_text = UNIT_TEST.read_text(encoding="utf-8")
    production_test_anchors = (
        "import BeautyEffects", "BeautyLocalRetouchCompositionOwner",
        "testProductionExactCarrierBindingAndCheckedOffsetsRejectForeignWorkLocally",
        "testProductionIssuanceCapsDuplicateTokensAndRawDuplicatesPreserveValidSibling",
        "XCTAssertNotEqual(source.pixelSourceBinding, foreignSource.pixelSourceBinding)",
    )
    if any(anchor not in unit_text for anchor in production_test_anchors):
        failures.add("R55-SOURCE-TESTS")
    return failures


def composition_failures() -> set[str]:
    failures = source_binding_failures()
    if failures:
        return failures
    source_text = COMPOSITION.read_text(encoding="utf-8")
    required_anchors = (
        "rgba8Data", "sourceData", "acceptedClaims.sort", "claimsAreInDeterministicOrder",
        "effectiveWeightQ16", "65_536", "32_768", "collisionPixelCount",
        "if changedPixelCount == 0", "throw BeautyError.invalidInput",
    )
    if any(anchor not in source_text for anchor in required_anchors):
        failures.add("R55-CORE-ANCHORS")
    if re.search(r"\b(Float|Double)\b|CIFilter|CIColor|sequential|priority|maxWeight|lastWrite", source_text, re.IGNORECASE):
        failures.add("R55-DETERMINISM")
    if re.search(r"source\s*:\s*outputData", source_text):
        failures.add("R55-ORIGINAL-SOURCE")
    if "Dictionary(grouping: units)" in source_text:
        failures.add("R55-UNIT-BOUNDS")

    unit_text = UNIT_TEST.read_text(encoding="utf-8")
    production_anchors = (
        "testQ16LiteralBlendAndAlpha",
        "testHardReclipZeroWeightAndOutsideUnionIdentity",
        "testStandaloneMergedFusedAndPermutedOutputs",
        "testProductionTwoAndThreeOwnerCollisionToSourceIsCountedOnce",
        "testProductionOpaqueFailureMatrixPreservesEveryAcceptedSibling",
        "testProductionEmptyAndValidInvalidValidCallsRetainNoState",
        "pixelSourceBinding, source.pixelSourceBinding",
        "oversizedInput",
    )
    if any(anchor not in unit_text for anchor in production_anchors):
        failures.add("R55-PRODUCTION-ORACLES")
    return failures


def privacy_failures() -> set[str]:
    failures = composition_failures()
    if failures:
        return failures

    source_text = COMPOSITION.read_text(encoding="utf-8")
    summary_fields = package_let_fields(
        source_text,
        "package struct BeautyLocalRetouchCompositionSummary",
        "package struct BeautyLocalRetouchCompositionResult",
    )
    result_fields = package_let_fields(
        source_text,
        "package struct BeautyLocalRetouchCompositionResult",
        "package final class BeautyLocalRetouchCompositionOwner",
    )
    if summary_fields != EXPECTED_SUMMARY_FIELDS or result_fields != ("canonicalImage", "summary"):
        failures.add("R55-SUMMARY-SHAPE")
    if re.search(
        r"\b(Codable|CustomStringConvertible|CustomDebugStringConvertible)\b|"
        r"\b(description|debugDescription|digest)\b|"
        r"\b(teeth|sclera|eyelid|pupil|landmark|coordinate|mask)\b",
        source_text,
        re.IGNORECASE,
    ):
        failures.add("R55-CORE-PRIVACY")
    return failures


def live_failures() -> set[str]:
    failures = composition_failures()
    if failures:
        return failures

    source_text = COMPOSITION.read_text(encoding="utf-8")
    required_anchors = (
        "package ", "BeautyCanonicalStillImage", "rgba8Data",
        "multipliedReportingOverflow", "addingReportingOverflow",
        "isInsideHardEnvelope", "65_536", "32_768", "collisionPixelCount",
    )
    if any(anchor not in source_text for anchor in required_anchors):
        failures.add("R55-CORE-ANCHORS")
    support_text = TESTING_SUPPORT.read_text(encoding="utf-8")
    engine_text = ENGINE.read_text(encoding="utf-8")
    if "SDKTestingLocalCompositionScenario" not in support_text or "SDKTestingLocalCompositionObservation" not in support_text:
        failures.add("R55-FACADE-SEAM")
    observation_fields = public_let_fields(
        support_text,
        "public struct SDKTestingLocalCompositionObservation",
        "public enum SDKTestingLocalSupportFixture",
    )
    expected_observation_fields = (
        "width", "height", "compositionInvocationCount", "sourceBindingMatched",
        *EXPECTED_SUMMARY_FIELDS,
    )
    if observation_fields != expected_observation_fields or "outputDigest" in support_text:
        failures.add("R55-SPI-PRIVACY")
    composition_spi = "\n".join(
        line for line in support_text.splitlines()
        if "SDKTestingLocalComposition" in line
        or any(field in line for field in (
            "acceptedUnitCount", "rejectedUnitCount", "ownedPixelCount",
            "changedPixelCount", "changedOutsideUnionPixelCount", "collisionPixelCount",
            "sourceBindingMatched", "invocationCount",
        ))
    )
    if re.search(r"pixelIndex|coordinate|mask|token|owner|bytes?|digest|path|rawError", composition_spi, re.IGNORECASE):
        failures.add("R55-SPI-PRIVACY")
    if "BeautyLocalRetouchComposition" not in engine_text + support_text:
        failures.add("R55-ORPHAN")
    if not re.search(
        r"BeautyLocalRetouchCompositionOwner\s*\(\s*source:\s*requestContext\.canonicalImage\s*\)",
        engine_text,
        re.DOTALL,
    ) or "compositionOwner.compose(units)" not in engine_text:
        failures.add("R55-ORPHAN")
    return failures


@dataclass(frozen=True)
class SyntheticContract:
    required_files: frozenset[str]
    source: str
    spi: str
    candidates: str
    package_targets: frozenset[str]
    has_external_dependency: bool
    demo: str
    realtime: str
    stored_fields: tuple[str, ...]
    coding_keys: tuple[str, ...]
    presets: tuple[str, ...]
    renderer_ids: tuple[str, ...]
    facade: str
    unit_specs: str
    summary_fields: tuple[str, ...]
    result_fields: tuple[str, ...]
    scanner_state: str = "clean"


def synthetic_baseline() -> SyntheticContract:
    fields = tuple([f"field{index}" for index in range(58)] + ["filterId"])
    return SyntheticContract(
        required_files=frozenset({"source", "unit", "facade", "inventory"}),
        source="package struct Core pixelSourceBinding ObjectIdentifier maximumUnitCount effectiveUnitLimit maximumClaimsPerUnit multipliedReportingOverflow addingReportingOverflow issuedTokens tokenFrequency rawIndices isInsideHardEnvelope collisionPixelCount rgba8Data 65_536 32_768",
        spi="Scenario Result sourceBindingMatched invocationCount acceptedUnitCount rejectedUnitCount ownedPixelCount changedPixelCount changedOutsideUnionPixelCount collisionPixelCount",
        candidates="",
        package_targets=frozenset(EXPECTED_TARGETS),
        has_external_dependency=False,
        demo="",
        realtime="",
        stored_fields=fields,
        coding_keys=fields,
        presets=EXPECTED_PRESETS,
        renderer_ids=EXPECTED_RENDERER_IDS,
        facade="BeautyLocalRetouchComposition ValidInvalidValid PixelBufferAndReset",
        unit_specs="DuplicateRawIndex DuplicateOpaqueUnitToken TwoAndThreeOwnerCollision EveryPermutation",
        summary_fields=EXPECTED_SUMMARY_FIELDS,
        result_fields=("canonicalImage", "summary"),
    )


def synthetic_failures(contract: SyntheticContract) -> set[str]:
    failures: set[str] = set()
    if contract.required_files != frozenset({"source", "unit", "facade", "inventory"}): failures.add("R55-REQUIRED")
    if contract.scanner_state != "clean": failures.add("R55-SCANNER")
    if re.search(r"\bpublic\b|@_spi|Codable", contract.source): failures.add("R55-CORE-ACCESS")
    if re.search(r"URLSession|UserDefaults|FileHandle|Logger", contract.source): failures.add("R55-PRIVACY")
    if re.search(r"pixelIndex|mask|token|owner|byte|digest|path|rawError", contract.spi, re.IGNORECASE): failures.add("R55-SPI-PRIVACY")
    if contract.candidates: failures.add("R55-CANDIDATE")
    if contract.package_targets != EXPECTED_TARGETS or contract.has_external_dependency: failures.add("R55-PACKAGE")
    if contract.demo: failures.add("R55-DEMO")
    if contract.realtime: failures.add("R55-REALTIME")
    if len(contract.stored_fields) != 59 or contract.coding_keys != contract.stored_fields: failures.add("R55-FIELDS")
    if contract.presets != EXPECTED_PRESETS: failures.add("R55-PRESETS")
    if contract.renderer_ids != EXPECTED_RENDERER_IDS: failures.add("R55-RENDERER")
    if "BeautyLocalRetouchComposition" not in contract.facade: failures.add("R55-ORPHAN")
    if "ValidInvalidValid" not in contract.facade or "PixelBufferAndReset" not in contract.facade: failures.add("R55-FACADE-SPECS")
    if any(anchor not in contract.unit_specs for anchor in ("DuplicateRawIndex", "DuplicateOpaqueUnitToken", "TwoAndThreeOwnerCollision", "EveryPermutation")): failures.add("R55-UNIT-SPECS")
    if any(anchor not in contract.source for anchor in ("pixelSourceBinding", "ObjectIdentifier", "maximumUnitCount", "effectiveUnitLimit", "maximumClaimsPerUnit", "multipliedReportingOverflow", "addingReportingOverflow", "issuedTokens", "tokenFrequency", "rawIndices", "isInsideHardEnvelope", "collisionPixelCount", "rgba8Data", "65_536", "32_768")): failures.add("R55-CORE-ANCHORS")
    if contract.summary_fields != EXPECTED_SUMMARY_FIELDS or contract.result_fields != ("canonicalImage", "summary"): failures.add("R55-SUMMARY-SHAPE")
    if re.search(r"\b(teeth|sclera|eyelid|pupil|landmark|coordinate|mask|digest)\b", contract.source, re.IGNORECASE): failures.add("R55-CORE-PRIVACY")
    if "Dictionary(grouping: units)" in contract.source: failures.add("R55-UNIT-BOUNDS")
    return failures


def self_test() -> int:
    cases = 0
    assert classify_rg(0, "match\n", "") == "match"; cases += 1
    assert classify_rg(1, "", "") == "clean"; cases += 1
    for returncode in (2, 127):
        try:
            classify_rg(returncode, "", "failure")
        except ScannerFailure:
            cases += 1
        else:
            raise AssertionError("unclassified subprocess outcome accepted")

    baseline_inventory = expected_inventory()
    assert validate_inventory(baseline_inventory); cases += 1
    for index, threat_id in enumerate(THREAT_IDS):
        mutation = copy.deepcopy(baseline_inventory)
        mutation["threats"][index]["gates"] = mutation["threats"][index]["gates"][:-1]
        assert not validate_inventory(mutation), threat_id
        cases += 1

    baseline = synthetic_baseline()
    assert synthetic_failures(baseline) == set(); cases += 1
    mutations = (
        (replace(baseline, required_files=frozenset({"source", "unit", "facade"})), "R55-REQUIRED"),
        (replace(baseline, scanner_state="error"), "R55-SCANNER"),
        (replace(baseline, source=baseline.source + " public"), "R55-CORE-ACCESS"),
        (replace(baseline, source=baseline.source + " URLSession"), "R55-PRIVACY"),
        (replace(baseline, spi=baseline.spi + " outputDigest"), "R55-SPI-PRIVACY"),
        (replace(baseline, candidates="teethWhitening"), "R55-CANDIDATE"),
        (replace(baseline, package_targets=baseline.package_targets | {"Extra"}), "R55-PACKAGE"),
        (replace(baseline, has_external_dependency=True), "R55-PACKAGE"),
        (replace(baseline, demo="BeautyLocalRetouchComposition"), "R55-DEMO"),
        (replace(baseline, realtime="compose"), "R55-REALTIME"),
        (replace(baseline, stored_fields=baseline.stored_fields[:-1]), "R55-FIELDS"),
        (replace(baseline, coding_keys=tuple(reversed(baseline.coding_keys))), "R55-FIELDS"),
        (replace(baseline, presets=baseline.presets[:-1]), "R55-PRESETS"),
        (replace(baseline, renderer_ids=baseline.renderer_ids[:-1]), "R55-RENDERER"),
        (replace(baseline, facade="ValidInvalidValid PixelBufferAndReset"), "R55-ORPHAN"),
        (replace(baseline, facade="BeautyLocalRetouchComposition PixelBufferAndReset"), "R55-FACADE-SPECS"),
        (replace(baseline, unit_specs=baseline.unit_specs.replace("EveryPermutation", "")), "R55-UNIT-SPECS"),
        (replace(baseline, summary_fields=baseline.summary_fields[:-1]), "R55-SUMMARY-SHAPE"),
        (replace(baseline, result_fields=("canonicalImage", "summary", "digest")), "R55-SUMMARY-SHAPE"),
        (replace(baseline, source=baseline.source + " teeth"), "R55-CORE-PRIVACY"),
        (replace(baseline, source=baseline.source + " Dictionary(grouping: units)"), "R55-UNIT-BOUNDS"),
    )
    for mutation, expected_rule in mutations:
        assert expected_rule in synthetic_failures(mutation), expected_rule
        cases += 1

    for anchor in (
        "pixelSourceBinding", "ObjectIdentifier", "maximumUnitCount",
        "effectiveUnitLimit", "maximumClaimsPerUnit",
        "multipliedReportingOverflow", "addingReportingOverflow",
        "issuedTokens", "tokenFrequency", "rawIndices",
    ):
        mutation = replace(baseline, source=baseline.source.replace(anchor, ""))
        assert "R55-CORE-ANCHORS" in synthetic_failures(mutation), anchor
        cases += 1

    print(json.dumps({"highThreatIds": THREAT_IDS, "mutationCaseCount": cases, "status": "pass"}, sort_keys=True))
    return 0


def emit(mode: str, failures: set[str]) -> int:
    if failures:
        print(json.dumps({"failedRuleIds": sorted(failures), "mode": mode, "status": "fail"}, sort_keys=True))
        return 1
    payload: dict[str, object] = {
        "highThreatIds": THREAT_IDS,
        "mode": mode,
        "status": "pass",
    }
    if mode == "wave0-red":
        payload["expectedRedRuleIds"] = ("W55-01", "W55-02", "W55-03")
    print(json.dumps(payload, sort_keys=True))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--self-test", action="store_true")
    group.add_argument("--expect-wave0-red", action="store_true")
    group.add_argument("--source-binding", action="store_true")
    group.add_argument("--composition", action="store_true")
    group.add_argument("--privacy", action="store_true")
    group.add_argument("--facade", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            return self_test()
        if args.expect_wave0_red:
            return emit("wave0-red", wave0_failures())
        if args.source_binding:
            return emit("source-binding", source_binding_failures())
        if args.composition:
            return emit("composition", composition_failures())
        if args.privacy:
            return emit("privacy", privacy_failures())
        if args.facade:
            return emit("facade", live_failures())
        return emit("live", live_failures())
    except (OSError, ValueError, KeyError, TypeError, ScannerFailure, AssertionError):
        return emit("internal", {"R55-UNCLASSIFIED"})


if __name__ == "__main__":
    sys.exit(main())
