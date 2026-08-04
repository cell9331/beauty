#!/usr/bin/env python3
"""Fail-closed Phase 58 zero-admission milestone closeout checker."""

from __future__ import annotations

import argparse
import hashlib
import io
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[3]
PHASE_NAME = "58-combined-facade-safety-ledger-and-audit-closeout"
THREAT_IDS = tuple(f"T-58-{index:02d}" for index in range(1, 9))
RULES = {
    "T-58-01": "R58-AUTH",
    "T-58-02": "R58-PRIVACY",
    "T-58-03": "R58-LIFETIME",
    "T-58-04": "R58-COMPAT",
    "T-58-05": "R58-OUTPUT",
    "T-58-06": "R58-PROMOTION",
    "T-58-07": "R58-PHASE57",
    "T-58-08": "R58-EVIDENCE",
}
FEATURES = ("teeth_whitening", "sclera_redness", "upper_eyelid_fullness")
ZERO_KEYS = (
    "eligible_count", "reviewed_count", "accepted_count", "rejected_count",
    "naturalness_weight",
)
EXPECTED_REASONS = {
    "teeth_whitening": ["missing_genuine_positive", "missing_genuine_negative"],
    "sclera_redness": ["missing_genuine_positive", "missing_genuine_negative"],
    "upper_eyelid_fullness": [
        "missing_genuine_positive", "missing_genuine_negative",
        "non_warp_design_unqualified",
    ],
}
EXPECTED_DISPOSITIONS = {
    "SAFE-01": "privacy_boundary_enforced",
    "SAFE-02": "request_local_nonretention_enforced",
    "SAFE-03": "closed_set_noop_compatibility_enforced",
    "OUT-01": "not_applicable_zero_admitted_features_exact_absence",
    "OUT-02": "not_applicable_zero_admitted_pair_exact_absence",
    "OUT-03": "full_automated_audit_and_independent_verification",
    "OUT-04": "zero_row_promotion",
}
TASK_IDS = (
    "58-01-01", "58-01-02", "58-02-01", "58-02-02",
    "58-03-01", "58-03-02", "58-04-01",
)
PHASE57_CHECKER_SHA256 = (
    "13246e8c2e49dc6a569ee1d72dcc0eb302cf550f2769837a2221854bc470d428"
)
PHASE57_REVISION = "4125b75"
PHASE57_SELF_TEST_TOTALS = {
    "T-57-01": 65,
    "T-57-02": 68,
    "T-57-03": 90,
    "T-57-04": 143,
    "T-57-05": 23,
    "T-57-06": 81,
    "T-57-07": 7,
    "T-57-08": 42,
}
PHASE57_CURRENT_MODES = (
    ("decision", (0, "mode=decision status=passed rules=none\n")),
    ("sclera", (0, "mode=sclera status=passed rules=none\n")),
    ("eyelid", (0, "mode=eyelid status=passed rules=none\n")),
    (None, (1, "mode=live status=blocked rules=R57-COMPAT\n")),
)
# Keep one exact candidate inventory for every Phase 58 source, output, and
# Demo scan. These identities are copied from the closed Phase 56/57 ledgers;
# adding a new spelling here is an intentional audit-contract change.
TEETH_IDENTITIES = (
    "teethWhitening", "teethWhite", "toothWhitening", "teethBrightness",
    "enamelWhitening", "enamelWhite", "enamelBrightness",
    "dentitionWhitening", "dentitionWhite", "dentitionBrightness",
    "whitenTeeth",
    "teeth_whitening", "teeth_white", "tooth_whitening", "teeth_brightness",
    "enamel_whitening", "enamel_white", "enamel_brightness",
    "dentition_whitening", "dentition_white", "dentition_brightness",
    "whiten_teeth",
)
SCLERA_IDENTITIES = (
    "scleraRedness", "scleraRednessReduction", "scleraWhitening", "scleraWhite",
    "scleraBrightness", "whitenSclera", "eyeRedness", "eyeRednessReduction",
    "redEye", "redEyeReduction", "conjunctivaRedness",
    "conjunctivaRednessReduction", "conjunctivalRedness",
    "conjunctivalRednessReduction", "conjunctivaWhitening",
    "conjunctivalWhitening", "ocularRedness", "ocularRednessReduction",
    "ocularWhitening", "bloodshotReduction", "bloodshotEyeCorrection",
    "sclera_redness", "sclera_redness_reduction", "sclera_whitening",
    "sclera_white", "sclera_brightness", "whiten_sclera", "eye_redness",
    "eye_redness_reduction", "red_eye", "red_eye_reduction",
    "conjunctiva_redness", "conjunctiva_redness_reduction",
    "conjunctival_redness", "conjunctival_redness_reduction",
    "conjunctiva_whitening", "conjunctival_whitening", "ocular_redness",
    "ocular_redness_reduction", "ocular_whitening", "bloodshot_reduction",
    "bloodshot_eye_correction",
)
EYELID_IDENTITIES = (
    "upperEyelidFullness", "upperLidFullness", "eyelidFullness", "lidFullness",
    "upperEyelidFullnessReduction", "upperLidFullnessReduction",
    "eyelidFullnessReduction", "lidFullnessReduction",
    "upperEyelidFullnessRemoval", "upperLidFullnessRemoval",
    "eyelidFullnessRemoval", "lidFullnessRemoval", "upperEyelidFat",
    "upperLidFat", "eyelidFat", "lidFat", "upperEyelidFatReduction",
    "upperLidFatReduction", "eyelidFatReduction", "lidFatReduction",
    "upperEyelidFatRemoval", "upperLidFatRemoval", "eyelidFatRemoval",
    "lidFatRemoval", "removeUpperEyelidFat", "removeEyelidFat",
    "removeUpperLidFat", "removeLidFat", "upperEyelidDefatting",
    "upperLidDefatting", "eyelidDefatting", "lidDefatting",
    "defatUpperEyelid", "defatEyelid", "defatUpperLid", "defatLid",
    "upper_eyelid_fullness", "upper_lid_fullness", "eyelid_fullness",
    "lid_fullness", "upper_eyelid_fullness_reduction",
    "upper_lid_fullness_reduction", "eyelid_fullness_reduction",
    "lid_fullness_reduction", "upper_eyelid_fullness_removal",
    "upper_lid_fullness_removal", "eyelid_fullness_removal",
    "lid_fullness_removal", "upper_eyelid_fat", "upper_lid_fat",
    "eyelid_fat", "lid_fat", "upper_eyelid_fat_reduction",
    "upper_lid_fat_reduction", "eyelid_fat_reduction", "lid_fat_reduction",
    "upper_eyelid_fat_removal", "upper_lid_fat_removal",
    "eyelid_fat_removal", "lid_fat_removal", "remove_upper_eyelid_fat",
    "remove_eyelid_fat", "remove_upper_lid_fat", "remove_lid_fat",
    "upper_eyelid_defatting", "upper_lid_defatting", "eyelid_defatting",
    "lid_defatting", "defat_upper_eyelid", "defat_eyelid", "defat_upper_lid",
    "defat_lid",
)
OWNED_IDENTITIES = ("lips.teeth", "eyes.redness", "eyes.fat", "白牙", "祛红血丝", "去脂")
CANDIDATE_IDENTITIES = TEETH_IDENTITIES + SCLERA_IDENTITIES + EYELID_IDENTITIES + OWNED_IDENTITIES
CANDIDATE_PATTERN = r"(?i)(?:" + "|".join(map(re.escape, CANDIDATE_IDENTITIES)) + r")[A-Za-z0-9_]*"
SENSITIVE_PATTERN = (
    r"retainedScleraMask|persistedScleraMask|rawLandmarks|reviewerIdentity|"
    r"fixturePath|imageDigest|rawScannerError|publicSupportCoordinates"
)
LIFETIME_FORBIDDEN_PATTERN = (
    r"Phase58CooperativeAbort|claimsCooperativeAbort|abortSDKWork|"
    r"TD013Resolved|genericResultSendabilityResolved|publicResultIsSendable|"
    r"globalSupportCache|staticRequestContext|persistedRequestSupport|"
    r"crossRequestMaskStore|retainedAnatomyObservation|rawRequestFailureOutput"
)
EXPECTED_PRESETS = (
    "clear.json", "id-photo-natural.json", "male-natural.json", "natural.json",
    "refined.json",
)
DEMO_DISABLED_ROWS = (
    'unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)',
    'unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)',
    'unsupported("lips.teeth", title: "白牙", icon: "sparkles")',
)
SHAPE_FUTURE_ROWS = (
    "| `眼睛` | 去脂 | future | None. | Needs local retouch/segmentation design; no cloud AI by default. |",
    "| `眼睛` | 祛红血丝 | future | None. | Needs local color/segmentation retouch design. |",
    "| `嘴唇` | 白牙 | future | None. | Needs local teeth segmentation/retouch design. |",
)
MATRIX_PARTIAL_PREFIXES = (
    "| Beauty shaping | 眼睛 | partial |",
    "| Beauty shaping | 嘴唇 | partial |",
)
PRIVACY_FORBIDDEN_PATTERN = (
    r"publicRawLandmarks|spiSupportCoordinates|codableRequestMask|"
    r"persistedScleraMask|networkReviewerPayload|loggedPupilPosition|"
    r"metricVeinDescriptor|trackedImageBytes|durableFixturePath|"
    r"durableImageDigest|durableSourceToken|rawScannerError|rawSourceMatch"
)

# Names carrying anatomy/support payloads are denied by default when they
# cross a public/SPI, Codable, persistence, network, logging, or metrics
# boundary. Fixed aggregate counters are the only explicit exceptions.
PRIVACY_PAYLOAD_TOKENS = re.compile(
    r"(?i)(?:landmark|support|geometry|point|observation|mask|vein|pupil|"
    r"sclera|eyelid|teeth|anatomy)"
)
PRIVACY_ALLOWED_NAMES = {
    "aggregateSupportValueID", "detectionAvailability", "detectionReasons",
    "compositionObservation", "SDKTestingLocalCompositionObservation",
    # Public shaping controls are not support payloads.
    "upperEyelidLift", "pupilSize", "lowerEyelidDrop",
}
PRIVACY_DECLARATION_PATTERN = re.compile(
    r"(?im)^\s*(?P<visibility>(?:@_spi\([^)]*\)\s*)?(?:public|package|private|internal)?\s*)"
    r"(?:private\(set\)\s+)?(?:var|let)\s+(?P<name>[A-Za-z][A-Za-z0-9_]*)"
)
PRIVACY_CODABLE_PATTERN = re.compile(
    r"(?is)\b(?:struct|class)\s+[A-Za-z][A-Za-z0-9_]*\s*:[^{]*\bCodable\b[^{}]*\{(?P<body>[^{}]*)\}"
)

MUTATION_TEST_MODE = False


def configure_root(root: pathlib.Path) -> None:
    global ROOT, PHASE, PACKAGE, SOURCES, PARAMETERS, MANIFEST, PRESETS, RENDERER
    global RESOLVER, ENGINE, TESTING_SUPPORT, FOUNDATION_TEST, COMPOSITION_TEST, CANONICAL_TEST
    global PARAMETER_TEST, RESOURCE_TEST, RENDERER_TEST, DEMO_SOURCE, DEMO_TEST
    global DEMO_ROOT, DECISIONS, FEATURE_MATRIX, SHAPE_LEDGER, PHASE57_CHECKER
    global PHASE57_VERIFICATION, PHASE57_EVIDENCE, PHASE57_VALIDATION
    global PHASE57_INVENTORY, INVENTORY, EVIDENCE

    ROOT = root.resolve()
    PHASE = ROOT / ".planning" / "phases" / PHASE_NAME
    PACKAGE = ROOT / "BeautySDK" / "Package.swift"
    SOURCES = ROOT / "BeautySDK" / "Sources"
    PARAMETERS = SOURCES / "BeautyCore" / "Models" / "BeautyParameters.swift"
    MANIFEST = SOURCES / "BeautyResources" / "Resources" / "manifest.json"
    PRESETS = SOURCES / "BeautyResources" / "Resources" / "Presets"
    RENDERER = SOURCES / "BeautyExampleRenderer" / "main.swift"
    RESOLVER = SOURCES / "BeautyEffects" / "Planning" / "BeautyEffectResolver.swift"
    ENGINE = SOURCES / "BeautySDK" / "BeautyEngine.swift"
    TESTING_SUPPORT = SOURCES / "BeautySDK" / "BeautyEngineTestingSupport.swift"
    FOUNDATION_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" /
        "BeautyEngineLocalRetouchFoundationTests.swift"
    )
    COMPOSITION_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" /
        "BeautyEngineLocalRetouchCompositionTests.swift"
    )
    CANONICAL_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" /
        "BeautyCanonicalStillImageTests.swift"
    )
    PARAMETER_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" /
        "BeautyParametersTests.swift"
    )
    RESOURCE_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyResourcesTests" /
        "BeautyResourceCatalogTests.swift"
    )
    RENDERER_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" /
        "BeautyRendererOutputRegressionTests.swift"
    )
    DEMO_SOURCE = ROOT / "BeautyDemo" / "BeautyDemo" / "Editor" / "MeituEditorToolModels.swift"
    DEMO_ROOT = ROOT / "BeautyDemo" / "BeautyDemo"
    DEMO_TEST = ROOT / "BeautyDemo" / "BeautyDemoTests" / "BeautyDemoViewStateTests.swift"
    DECISIONS = (
        ROOT / ".planning" / "phases" /
        "54-rights-approved-evidence-and-eligibility-decisions" /
        "54-EVIDENCE-DECISIONS.json"
    )
    FEATURE_MATRIX = ROOT / "docs" / "meitu-function-blueprint" / "FEATURE_MATRIX.md"
    SHAPE_LEDGER = ROOT / "docs" / "meitu-function-blueprint" / "SHAPE_FEATURE_LEDGER.md"
    PHASE57_CHECKER = (
        ROOT / ".planning" / "phases" /
        "57-guarded-sclera-slice-and-conditional-upper-eyelid-work" /
        "check_phase57_eye_gate_boundaries.py"
    )
    PHASE57_VERIFICATION = PHASE57_CHECKER.with_name("57-VERIFICATION.md")
    PHASE57_EVIDENCE = PHASE57_CHECKER.with_name("57-CLOSED-EYE-GATES-EVIDENCE.md")
    PHASE57_VALIDATION = PHASE57_CHECKER.with_name("57-VALIDATION.md")
    PHASE57_INVENTORY = PHASE57_CHECKER.with_name("57-THREAT-INVENTORY.json")
    INVENTORY = PHASE / "58-THREAT-INVENTORY.json"
    EVIDENCE = PHASE / "58-CLOSEOUT-EVIDENCE.md"


configure_root(ROOT)


class ScannerFailure(RuntimeError):
    """An external scanner returned neither match nor clean."""


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


def read_text(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def read_json(path: pathlib.Path) -> object:
    return json.loads(read_text(path))


def extract_coding_keys(text: str) -> tuple[str, ...]:
    match = re.search(r"enum CodingKeys[^\{]*\{(.*?)\n\s*\}", text, re.DOTALL)
    if match is None:
        return ()
    return tuple(re.findall(
        r"^\s*case\s+([A-Za-z][A-Za-z0-9]*)\s*$", match.group(1), re.MULTILINE,
    ))


def expected_renderer_ids(text: str) -> tuple[str, ...]:
    match = re.search(r"expectedRendererCaseIDs\s*=\s*\[(.*?)\n\s*\]", text, re.DOTALL)
    return () if match is None else tuple(re.findall(r'"([^"]+)"', match.group(1)))


def expected_inventory() -> dict[str, object]:
    rows = (
        (
            "T-58-01", ["Tampering", "Elevation of Privilege"], "58-02-02",
            ["exact_phase54_authority", "literal_empty_admission"],
        ),
        (
            "T-58-02", ["Information Disclosure"], "58-02-02",
            ["no_sensitive_support_payload", "fixed_aggregate_output"],
        ),
        (
            "T-58-03", ["Information Disclosure", "Tampering"], "58-02-01",
            ["request_local_nonretention", "publication_discard_without_abort_claim"],
        ),
        (
            "T-58-04", ["Tampering", "Denial of Service"], "58-02-02",
            ["canonical_noop_and_typed_error", "exact_59_5_72_facades_and_nonstill"],
        ),
        (
            "T-58-05", ["Spoofing", "Repudiation"], "58-02-02",
            ["exact_out01_out02_absence", "feature_neutral_mechanics_nonclaim"],
        ),
        (
            "T-58-06", ["Repudiation", "Elevation of Privilege"], "58-02-02",
            ["exact_three_disabled_demo_rows", "zero_row_ledger_promotion"],
        ),
        (
            "T-58-07", ["Tampering"], "58-03-01",
            ["frozen_phase57_lifecycle", "completed_owner_equality"],
        ),
        (
            "T-58-08", ["Information Disclosure", "Denial of Service"], "58-03-02",
            ["strict_evidence_and_scanner", "final_owner_and_gate_equality"],
        ),
    )
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
                "owner": owner,
                "final_rerun_owner": "58-04-01",
                "gates": gates,
            }
            for threat_id, stride, owner, gates in rows
        ],
    }


def authority_failures() -> set[str]:
    document = read_json(DECISIONS)
    if (
        not isinstance(document, dict)
        or tuple(document) != ("schema_version", "feature_decisions", "reviews", "aggregates")
        or type(document.get("schema_version")) is not int
        or document.get("schema_version") != 1
        or document.get("reviews") != []
    ):
        return {RULES["T-58-01"]}
    decisions = document.get("feature_decisions")
    aggregates = document.get("aggregates")
    if not isinstance(decisions, list) or not isinstance(aggregates, list):
        return {RULES["T-58-01"]}
    if [row.get("feature") for row in decisions] != list(FEATURES):
        return {RULES["T-58-01"]}
    if [row.get("feature") for row in aggregates] != list(FEATURES):
        return {RULES["T-58-01"]}
    for feature, decision, aggregate in zip(FEATURES, decisions, aggregates):
        if tuple(decision) != (
            "feature", "status", "reasons", "eligible_count", "reviewed_count",
            "accepted_count", "rejected_count", "naturalness_weight",
        ):
            return {RULES["T-58-01"]}
        if tuple(aggregate) != (
            "feature", "eligible_count", "reviewed_count", "accepted_count",
            "rejected_count", "naturalness_weight",
        ):
            return {RULES["T-58-01"]}
        if decision.get("status") != "closed" or decision.get("reasons") != EXPECTED_REASONS[feature]:
            return {RULES["T-58-01"]}
        if any(type(decision.get(key)) is not int or decision.get(key) != 0 for key in ZERO_KEYS):
            return {RULES["T-58-01"]}
        if any(type(aggregate.get(key)) is not int or aggregate.get(key) != 0 for key in ZERO_KEYS):
            return {RULES["T-58-01"]}
        if aggregate.get("feature") != feature:
            return {RULES["T-58-01"]}
    resolver = " ".join(read_text(RESOLVER).split())
    literal_none = (
        "package static func localRetouchAdmission( parameters: BeautyParameters ) -> "
        "BeautyLocalRetouchAdmission { _ = parameters return .none }"
    )
    if literal_none not in resolver:
        return {RULES["T-58-01"]}
    if run_rg(CANDIDATE_PATTERN, (SOURCES,)) == "match":
        return {RULES["T-58-01"]}
    supplemental = "\n".join(
        [read_text(PACKAGE), read_text(MANIFEST)]
        + [read_text(path) for path in sorted(PRESETS.glob("*.json"))]
    )
    if re.search(CANDIDATE_PATTERN, supplemental):
        return {RULES["T-58-01"]}
    return set()


def privacy_failures() -> set[str]:
    source_files = tuple(sorted(SOURCES.rglob("*.swift")))
    source_text = "\n".join(read_text(path) for path in source_files)
    testing_support = read_text(TESTING_SUPPORT)
    if any(marker not in testing_support for marker in (
        "@_spi(Testing) public struct SDKTestingLocalResult",
        "public let aggregateSupportValueID: Int?",
        "public let detectionAvailability: String?",
        "public let detectionReasons: [String]",
        "@_spi(Testing) public struct SDKTestingLocalCompositionObservation",
        "public let collisionPixelCount: Int",
    )):
        return {RULES["T-58-02"]}
    durable_text = "\n".join((
        read_text(FOUNDATION_TEST), read_text(COMPOSITION_TEST), read_text(EVIDENCE),
    ))
    if re.search(PRIVACY_FORBIDDEN_PATTERN, source_text, re.IGNORECASE):
        return {RULES["T-58-02"]}
    if re.search(PRIVACY_FORBIDDEN_PATTERN, durable_text, re.IGNORECASE):
        return {RULES["T-58-02"]}
    for match in PRIVACY_DECLARATION_PATTERN.finditer(source_text):
        name = match.group("name")
        visibility = match.group("visibility").lower()
        if name in PRIVACY_ALLOWED_NAMES or not PRIVACY_PAYLOAD_TOKENS.search(name):
            continue
        # Package-private request-local support is allowed. Any public/SPI
        # declaration, or durable-boundary prefix, is a forbidden payload.
        lowered = name.lower()
        durable_prefix = lowered.startswith((
            "raw", "public", "spi", "codable", "persisted", "network",
            "logged", "metric", "durable", "tracked",
        ))
        if "public" in visibility or "@_spi" in visibility or durable_prefix:
            return {RULES["T-58-02"]}
    for match in PRIVACY_CODABLE_PATTERN.finditer(source_text):
        for declaration in re.finditer(
            r"\b(?:var|let)\s+([A-Za-z][A-Za-z0-9_]*)", match.group("body")
        ):
            name = declaration.group(1)
            if name not in PRIVACY_ALLOWED_NAMES and PRIVACY_PAYLOAD_TOKENS.search(name):
                return {RULES["T-58-02"]}
    boundary_patterns = (
        r"(?is)(?:public|@_spi\([^)]*\)).{0,120}(?:raw(?:Landmarks|Pixels)|"
        r"(?:sclera|eyelid|teeth|pupil|vein)[A-Za-z0-9_]*(?:Mask|Coordinates|Geometry))",
        r"(?is)(?:UserDefaults|FileManager|write\s*\(|URLSession|URLRequest).{0,160}"
        r"(?:landmark|pupil|sclera|eyelid|teeth|mask|vein|reviewer|digest|sourceToken)",
        r"(?is)(?:print|logger|metric|warning).{0,120}"
        r"(?:rawLandmark|pupilPosition|scleraMask|eyelidMask|teethGeometry|veinDescriptor)",
    )
    if any(re.search(pattern, source_text) for pattern in boundary_patterns):
        return {RULES["T-58-02"]}
    evidence = read_text(EVIDENCE)
    if re.search(SENSITIVE_PATTERN, evidence):
        return {RULES["T-58-02"]}
    if re.search(
        r"(?im)^\s*(?:[-*]\s*)?(?:raw|fixture|image|reviewer|source)[A-Za-z _-]*"
        r"(?:path|digest|token|match|error|identity|bytes?)\s*[:=|]",
        evidence,
    ):
        return {RULES["T-58-02"]}
    required = (
        "Durable output is limited to fixed requirement, task, threat, rule, disposition,",
        "raw error, or scanner text",
        "testPhase58NoFaceAndMissingSupportPublishOnlyAllowlistedAggregateReasons",
        "testPhase58FeatureNeutralCompositionPublishesOnlySixAggregateCounters",
    )
    combined = evidence + read_text(FOUNDATION_TEST) + read_text(COMPOSITION_TEST)
    if any(marker not in combined for marker in required):
        return {RULES["T-58-02"]}
    forbidden_suffixes = {".png", ".jpg", ".jpeg", ".heic", ".tiff", ".mlmodel", ".bin"}
    if any(path.suffix.lower() in forbidden_suffixes for path in PHASE.rglob("*")):
        return {RULES["T-58-02"]}
    return set()


def swift_test_function_bodies(source: str) -> dict[str, str]:
    """Return XCTest bodies with comments removed for non-vacuous checks."""
    without_comments = re.sub(
        r"//[^\n]*|/\*.*?\*/", "", source, flags=re.DOTALL
    )
    result: dict[str, str] = {}
    for match in re.finditer(
        r"\bfunc\s+(test[A-Za-z0-9_]+)\s*\([^)]*\)[^{]*\{", without_comments
    ):
        depth = 1
        index = match.end()
        while index < len(without_comments) and depth:
            character = without_comments[index]
            if character == "{":
                depth += 1
            elif character == "}":
                depth -= 1
            index += 1
        if depth == 0:
            result[match.group(1)] = without_comments[match.end():index - 1]
    return result


def lifetime_failures() -> set[str]:
    foundation = read_text(FOUNDATION_TEST)
    composition = read_text(COMPOSITION_TEST)
    support = read_text(
        SOURCES / "BeautySDK" / "BeautyEngineTestingSupport.swift"
    )
    required_foundation_methods = (
        "testValidInvalidValidDoesNotReuseRequestSupport",
        "testIndependentEngineValuesDoNotCrossPayloads",
        "testSameHarnessParallelInvocationsSerializeCompleteRequestTransactions",
        "testPhase58CanceledCallerDiscardsCompletedPublicationThenFreshRequestPublishes",
        "testPhase58CompleteRequestLocalLifecycleRetainsNoSupportBetweenTransactions",
        "testPhase58NoFaceAndMissingSupportPublishOnlyAllowlistedAggregateReasons",
    )
    required_foundation_fragments = (
        "supportSequence: [.available(valueID: 101), .available(valueID: 202)]",
        "publication.cancel()",
        "XCTAssertEqual(canceledOutcome, .discarded)",
        "XCTAssertEqual(fresh.aggregateSupportValueID, 202)",
        "let expectedValueIDs = Set(1...32)",
        "Self.assertNoRetainedRequestSupport(harness)",
    )
    required_composition = (
        "testValidInvalidValidRequestsResetEveryCompositionObservation",
        "testThrownRequestClearsObservationBeforeThirdValidRequest",
        "testAbsentAndMalformedLocalWorkPreserveUnrelatedBrightnessAndFilterContinuation",
        "testPhase58ThrownMiddleRequestResetsCountersAndFreshRequestContinuesUnrelatedEffects",
        "XCTAssertEqual(harness.compositionObservation, SDKTestingLocalCompositionObservation())",
        "XCTAssertEqual(harness.compositionObservation.changedOutsideUnionPixelCount, 0)",
    )
    foundation_bodies = swift_test_function_bodies(foundation)
    composition_bodies = swift_test_function_bodies(composition)
    if any(
        method not in foundation_bodies or foundation_bodies[method].count("XCTAssert") < 1
        for method in required_foundation_methods
    ):
        return {RULES["T-58-03"]}
    if any(
        not any(marker in body for body in foundation_bodies.values())
        for marker in required_foundation_fragments
    ):
        return {RULES["T-58-03"]}
    composition_methods = tuple(
        marker for marker in required_composition if marker.startswith("test")
    )
    if any(
        method not in composition_bodies or composition_bodies[method].count("XCTAssert") < 1
        for method in composition_methods
    ):
        return {RULES["T-58-03"]}
    if any(
        not any(marker in body for body in composition_bodies.values())
        for marker in required_composition if marker.startswith("XCTAssert")
    ):
        return {RULES["T-58-03"]}

    result_segment = support.split(
        "@_spi(Testing) public struct SDKTestingLocalResult", 1
    )[1].split("package final class BeautyLocalRetouchTestingHooks", 1)[0]
    result_labels = re.findall(r"public let ([A-Za-z0-9_]+):", result_segment)
    if result_labels != [
        "output", "width", "height", "aggregateSupportValueID",
        "detectionAvailability", "detectionReasons",
    ]:
        return {RULES["T-58-03"]}

    observation_segment = support.split(
        "@_spi(Testing) public struct SDKTestingLocalCompositionObservation", 1
    )[1].split("@_spi(Testing) public enum SDKTestingLocalSupportFixture", 1)[0]
    observation_labels = re.findall(r"public let ([A-Za-z0-9_]+):", observation_segment)
    if observation_labels != [
        "width", "height", "compositionInvocationCount", "sourceBindingMatched",
        "acceptedUnitCount", "rejectedUnitCount", "ownedPixelCount",
        "changedPixelCount", "changedOutsideUnionPixelCount", "collisionPixelCount",
    ]:
        return {RULES["T-58-03"]}

    serialization_markers = (
        "private let invocationLock = NSLock()",
        "invocationLock.lock()\n        defer { invocationLock.unlock() }",
    )
    if any(marker not in support for marker in serialization_markers):
        return {RULES["T-58-03"]}

    scanned = "\n".join((support, foundation, composition, read_text(EVIDENCE)))
    if (
        re.search(LIFETIME_FORBIDDEN_PATTERN, scanned, re.IGNORECASE)
        or run_rg(LIFETIME_FORBIDDEN_PATTERN, (SOURCES,)) == "match"
    ):
        return {RULES["T-58-03"]}
    return set()


def compatibility_failures() -> set[str]:
    parameters = read_text(PARAMETERS)
    stored = tuple(re.findall(
        r"^\s*public var\s+([A-Za-z][A-Za-z0-9]*)\s*:", parameters, re.MULTILINE,
    ))
    if (
        len(stored) != 59
        or len(set(stored)) != 59
        or stored.count("filterId") != 1
        or extract_coding_keys(parameters) != stored
    ):
        return {RULES["T-58-04"]}

    manifest = read_json(MANIFEST)
    preset_names = tuple(sorted(path.name for path in PRESETS.glob("*.json")))
    manifest_ids = tuple(
        row.get("id") for row in manifest.get("presets", [])
        if isinstance(row, dict)
    ) if isinstance(manifest, dict) else ()
    if (
        preset_names != EXPECTED_PRESETS
        or manifest_ids != ("natural", "clear", "refined", "male-natural", "id-photo-natural")
    ):
        return {RULES["T-58-04"]}

    renderer_test = read_text(RENDERER_TEST)
    expected_ids = expected_renderer_ids(renderer_test)
    renderer_ids = tuple(re.findall(r'\bid:\s*"([^"]+)"', read_text(RENDERER)))
    if len(expected_ids) != 72 or len(set(expected_ids)) != 72 or renderer_ids != expected_ids:
        return {RULES["T-58-04"]}

    engine = read_text(ENGINE)
    if len(re.findall(r"public func process\(\s*image:\s*CIImage", engine)) != 1:
        return {RULES["T-58-04"]}
    if len(re.findall(r"public func processResult\(\s*image:\s*CIImage", engine)) != 1:
        return {RULES["T-58-04"]}
    if ".package(" in read_text(PACKAGE):
        return {RULES["T-58-04"]}

    owners = {
        CANONICAL_TEST: (
            "testCarrierOwnsOneZeroOriginUpSRGBRGBA8Raster",
            "testAllEightOrientationsAndMirrorVariantsNormalizeIdentically",
            "testDisplayP3ConvertsToSRGBWithoutTopologyIdentityClaim",
            "testPartialAndZeroAlphaFailBeforeVisionWithoutCompositingOrForcingOpaque",
            "testMalformedOrientationAndUnsupportedColorSemanticsFailBeforeVision",
        ),
        FOUNDATION_TEST: (
            "testPhase58ZeroAdmissionConjunctionPreservesBothFacadesAndCanonicalNoOp",
            "let processOutput = try engine.process(",
            "let resultOutput = try engine.processResult(",
            "testPixelBufferOverloadsAndResetPerformZeroLocalFoundationWork",
            "XCTAssertEqual(error as? BeautyError, .unsupportedPixelFormat)",
        ),
        COMPOSITION_TEST: (
            "testPhase58FeatureNeutralCompositionPublishesOnlySixAggregateCounters",
            "XCTAssertEqual(counters.count, 6)",
        ),
        PARAMETER_TEST: (
            "testPhase58ZeroAdmissionKeepsExact59FieldSourceCodingAndEncodedShape",
            "XCTAssertEqual(stored.count, 59)",
        ),
        RESOURCE_TEST: (
            "testPhase58ZeroAdmissionKeepsExactFivePresetSourcesAndNoCandidateKeys",
            "XCTAssertEqual(presets.count, 5)",
        ),
        RENDERER_TEST: (
            "testPhase58ZeroAdmissionKeepsExact72RendererCasesAndNoOutputRoute",
            "XCTAssertEqual(Self.expectedRendererCaseIDs.count, 72)",
            "XCTAssertEqual(Set(Self.expectedRendererCaseIDs).count, 72)",
        ),
    }
    for path, markers in owners.items():
        source = read_text(path)
        if any(source.count(marker) < 1 for marker in markers):
            return {RULES["T-58-04"]}
    if run_rg(CANDIDATE_PATTERN, (SOURCES,)) == "match":
        return {RULES["T-58-04"]}
    return set()


def output_failures() -> set[str]:
    if run_rg(CANDIDATE_PATTERN, (SOURCES,)) == "match":
        return {RULES["T-58-05"]}
    supplemental = "\n".join(
        [read_text(PACKAGE), read_text(MANIFEST)]
        + [read_text(path) for path in sorted(PRESETS.glob("*.json"))]
    )
    if re.search(CANDIDATE_PATTERN, supplemental):
        return {RULES["T-58-05"]}

    demo_parts = []
    for path in sorted(DEMO_ROOT.rglob("*.swift")):
        text = read_text(path)
        if path == DEMO_SOURCE:
            for row in DEMO_DISABLED_ROWS:
                text = text.replace(row, "", 1)
        demo_parts.append(text)
    if re.search(
        r"(?i)eyes\.(?:fat|redness)|lips\.teeth|白牙|祛红血丝|去脂|" +
        CANDIDATE_PATTERN.replace("(?i)", ""),
        "\n".join(demo_parts),
    ):
        return {RULES["T-58-05"]}

    owned_text = "\n".join(read_text(path) for path in sorted(SOURCES.rglob("*.swift")))
    if re.search(
        r"visibleCandidateOutput|candidateSavedOutputHelper|candidateGalleryRoute|"
        r"candidateReviewRoute|combinedTeethScleraRequest|featureNamedOpaqueMechanics",
        owned_text,
        re.IGNORECASE,
    ):
        return {RULES["T-58-05"]}
    evidence = read_text(EVIDENCE)
    required = (
        "| OUT-01 | `not_applicable_zero_admitted_features_exact_absence` |",
        "| OUT-02 | `not_applicable_zero_admitted_pair_exact_absence` |",
        "Phase 55 composition remains feature-neutral",
        "candidate, admitted,\n  pair, output, saved-output helper, gallery, and review surfaces are empty",
    )
    if any(marker not in evidence for marker in required):
        return {RULES["T-58-05"]}
    if re.search(
        r"OUT-(?:01|02).{0,100}(?:implemented positive branch|admitted feature route|"
        r"visible output passed|product effect passed|passed positive branch)|"
        r"Phase 55.{0,100}(?:product evidence|feature effectiveness|naturalness passed)",
        evidence,
        re.IGNORECASE | re.DOTALL,
    ):
        return {RULES["T-58-05"]}
    return set()


def promotion_failures() -> set[str]:
    demo = read_text(DEMO_SOURCE)
    if any(demo.count(row) != 1 for row in DEMO_DISABLED_ROWS):
        return {RULES["T-58-06"]}
    demo_test = read_text(DEMO_TEST)
    demo_markers = (
        "testPhase58ZeroPromotionPreservesExactlyThreeDisabledLocalRetouchRows",
        "XCTAssertEqual(candidates.count, 3)",
        "XCTAssertFalse(tool.isSupported)",
        "XCTAssertNil(tool.controlID)",
        "XCTAssertNil(panel.selectedTool.controlID)",
        "XCTAssertTrue(candidates.allSatisfy { $0.controlID == nil })",
        "XCTAssertEqual(store.parametersSnapshot, before)",
    )
    if any(marker not in demo_test for marker in demo_markers):
        return {RULES["T-58-06"]}
    shape = read_text(SHAPE_LEDGER)
    matrix = read_text(FEATURE_MATRIX)
    if any(shape.count(row) != 1 for row in SHAPE_FUTURE_ROWS):
        return {RULES["T-58-06"]}
    if any(matrix.count(row) != 1 for row in MATRIX_PARTIAL_PREFIXES):
        return {RULES["T-58-06"]}
    evidence = read_text(EVIDENCE)
    if evidence.count("| OUT-04 | `zero_row_promotion` | promoted rows `0` |") != 1:
        return {RULES["T-58-06"]}
    if evidence.count("admitted and promoted sets are exactly empty") != 1:
        return {RULES["T-58-06"]}
    return set()


def _phase57_subprocess(arguments: tuple[str, ...], root: pathlib.Path) -> tuple[int, str, str]:
    """Run a frozen checker mode while retaining no subprocess diagnostics."""
    completed = subprocess.run(
        [sys.executable, str(root / PHASE57_CHECKER.relative_to(ROOT)), *arguments],
        cwd=root,
        text=True,
        capture_output=True,
        check=False,
    )
    return completed.returncode, completed.stdout, completed.stderr


def _phase57_git_blob() -> bytes:
    completed = subprocess.run(
        ["git", "show", f"{PHASE57_REVISION}:{PHASE57_CHECKER.relative_to(ROOT)}"],
        cwd=ROOT,
        capture_output=True,
        check=False,
    )
    if completed.returncode != 0 or completed.stderr or not completed.stdout:
        raise RuntimeError("frozen checker blob unavailable")
    return completed.stdout


def _git_repository_available(root: pathlib.Path) -> bool:
    completed = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "--git-dir"],
        capture_output=True,
        text=True,
        check=False,
    )
    return completed.returncode == 0 and not completed.stderr and bool(completed.stdout.strip())


def _extract_phase57_revision(destination: pathlib.Path) -> pathlib.Path:
    """Extract a verified Git revision read-only into a disposable root."""
    completed = subprocess.run(
        ["git", "archive", PHASE57_REVISION],
        cwd=ROOT,
        capture_output=True,
        check=False,
    )
    if completed.returncode != 0 or completed.stderr or not completed.stdout:
        raise RuntimeError("verified revision unavailable")
    with tarfile.open(fileobj=io.BytesIO(completed.stdout), mode="r:") as archive:
        members = archive.getmembers()
        _validate_phase57_archive_members(members)
        archive.extractall(destination, members=members)
    return destination


def _validate_phase57_archive_members(members: list[tarfile.TarInfo]) -> None:
    for member in members:
        name = pathlib.PurePosixPath(member.name)
        if name.is_absolute() or ".." in name.parts:
            raise RuntimeError("unsafe revision member")
        if member.issym() or member.islnk():
            raise RuntimeError("unsafe revision link member")


def assert_archive_member_safety() -> int:
    for member in (
        tarfile.TarInfo("phase/checker.py"),
        tarfile.TarInfo("../outside"),
    ):
        if member.name.startswith(".."):
            expected = "unsafe revision member"
        else:
            member.type = tarfile.SYMTYPE
            member.linkname = "/outside"
            expected = "unsafe revision link member"
        try:
            _validate_phase57_archive_members([member])
        except RuntimeError as error:
            if str(error) != expected:
                raise AssertionError("unexpected archive safety error") from error
        else:
            raise AssertionError("unsafe archive member accepted")
    hard_link = tarfile.TarInfo("phase/fixture.py")
    hard_link.type = tarfile.LNKTYPE
    hard_link.linkname = "../../outside"
    try:
        _validate_phase57_archive_members([hard_link])
    except RuntimeError as error:
        if str(error) != "unsafe revision link member":
            raise AssertionError("unexpected hard-link safety error") from error
    else:
        raise AssertionError("unsafe hard-link member accepted")
    return 3


def _phase57_pretransition_ok() -> bool:
    with tempfile.TemporaryDirectory(prefix="phase58-phase57-verified-") as temporary:
        fixture = _extract_phase57_revision(pathlib.Path(temporary))
        checker = fixture / PHASE57_CHECKER.relative_to(ROOT)
        # The frozen checker executes a full mutation matrix per threat. Run
        # the eight independent modes concurrently so this adapter remains a
        # bounded audit step while still requiring every exact denominator.
        processes = {
            threat: subprocess.Popen(
                [sys.executable, str(checker), "--self-test", "--only", threat],
                cwd=fixture,
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )
            for threat in PHASE57_SELF_TEST_TOTALS
        }
        results = {threat: process.communicate() for threat, process in processes.items()}
        total = 0
        for threat, expected_total in PHASE57_SELF_TEST_TOTALS.items():
            process = processes[threat]
            stdout, stderr = results[threat]
            expected = f"self-test status=passed threats=1 cases={expected_total}\n"
            if (process.returncode, stdout, stderr) != (0, expected, ""):
                return False
            total += expected_total
        if total != 519:
            return False
        return checker.is_file()


def _phase57_current_modes_ok() -> bool:
    for mode, expected in PHASE57_CURRENT_MODES:
        arguments = () if mode is None else (f"--{mode}",)
        code, stdout, stderr = _phase57_subprocess(arguments, ROOT)
        if (code, stdout, stderr) != (expected[0], expected[1], ""):
            return False
    return True


def _phase57_owner_failures() -> bool:
    """Validate Phase 57's completed owners after the Phase 58 transition."""
    verification = read_text(PHASE57_VERIFICATION)
    evidence = read_text(PHASE57_EVIDENCE)
    validation = read_text(PHASE57_VALIDATION)
    inventory = read_json(PHASE57_INVENTORY)
    roadmap = read_text(ROOT / ".planning" / "ROADMAP.md")
    state = read_text(ROOT / ".planning" / "STATE.md")
    requirements = read_text(ROOT / ".planning" / "REQUIREMENTS.md")

    verification_markers = (
        "status: passed", "score: 12/12 must-haves verified", "Aggregate 519/519",
        "65 / 68 / 90 / 143 / 23 / 81 / 7 / 42", "exact 44-sclera and\n74-upper-eyelid inventories",
        "Human Verification Required\n\nNone.",
    )
    if any(verification.count(marker) < 1 for marker in verification_markers):
        return False
    if evidence.count("status: validated") != 1 or evidence.count("# Phase 57 Closed Eye-Gates Evidence") != 1:
        return False
    dispositions = (
        ("SCLERA-01", "false_branch_exact_absence"),
        ("SCLERA-02", "not_applicable_closed_gate"),
        ("SCLERA-03", "not_applicable_closed_gate"),
        ("SCLERA-04", "not_applicable_closed_gate"),
        ("SCLERA-05", "not_applicable_closed_gate"),
        ("SCLERA-06", "no_promotion"),
        ("LID-02", "closed_branch_exact_absence"),
        ("LID-03", "not_applicable_closed_gate"),
        ("LID-04", "proxy_rejection_enforced"),
        ("LID-05", "not_applicable_closed_gate"),
    )
    if any(evidence.count(f"{identifier} | `{value}`") != 1 for identifier, value in dispositions):
        return False
    if any(evidence.count(f"| T-57-{index:02d} | passed") != 1 for index in range(1, 9)):
        return False
    if not (
        validation.count("status: validated") == 1
        and validation.count("nyquist_compliant: true") == 1
        and all(validation.count(f"| `57-{phase}-{task:02d}` |") == 1 for phase, task in (("01", 1), ("01", 2), ("02", 1), ("02", 2), ("03", 1), ("03", 2), ("04", 1)))
        and all(re.search(rf"(?m)^\| `57-{phase}-{task:02d}` \|.*\| passed \|$", validation) for phase, task in (("01", 1), ("01", 2), ("02", 1), ("02", 2), ("03", 1), ("03", 2), ("04", 1)))
    ):
        return False
    if not isinstance(inventory, dict) or inventory.get("schema_version") != 1 or inventory.get("security_standard") != "OWASP ASVS Level 1" or inventory.get("block_on") != "HIGH":
        return False
    rows = inventory.get("threats")
    if not isinstance(rows, list) or len(rows) != 8:
        return False
    expected_ids = [f"T-57-{index:02d}" for index in range(1, 9)]
    if [row.get("id") for row in rows] != expected_ids or any(row.get("severity") != "HIGH" or row.get("disposition") != "mitigate" for row in rows):
        return False
    if roadmap.count("- [x] **Phase 57:") != 1 or roadmap.count("**Plans**: 4/4 plans executed") != 1:
        return False
    # Phase 58 lifecycle owners must agree across roadmap and state; a
    # checklist/metric contradiction blocks the completed-state adapter.
    if (
        roadmap.count("- [x] `58-04-PLAN.md`") != 1
        or roadmap.count("**Plans**: 4/4 executed") != 1
        or state.count("total_plans: 27") != 1
        or state.count("completed_plans: 27") != 1
        or state.count("Total plans completed: 27") != 1
        or state.count("| 53-58 | 27 |") != 1
        or state.count("| 58 | 4 |") != 1
    ):
        return False
    if state.count("current_phase: 58") != 1 or state.count("current_phase_name: Combined Facade, Safety, Ledger, and Audit Closeout") != 1 or state.count("status: executing") != 1:
        return False
    requirement_ids = ("SCLERA-01", "SCLERA-02", "SCLERA-03", "SCLERA-04", "SCLERA-05", "SCLERA-06", "LID-02", "LID-03", "LID-04", "LID-05")
    if any(requirements.count(f"- [x] **{identifier}**") != 1 for identifier in requirement_ids):
        return False
    if any(requirements.count(f"| {identifier} | Phase 57 | Complete") != 1 for identifier in requirement_ids):
        return False
    root_anchors = {
        ROOT / "PRODUCT_SENSE.md": ("### v1.14 Phase 57 Closed Eye-Retouch Acceptance", "The independent Phase 54 sclera and upper-eyelid rows remain closed."),
        ROOT / "SECURITY.md": ("### Phase 57 Closed Eye-Retouch Security Boundary", "The exact Phase 54 `sclera_redness` and `upper_eyelid_fullness` rows are the sole independent authorities."),
        ROOT / "RELIABILITY.md": ("### Phase 57 Closed Eye-Retouch Reliability Closeout", "Authority, fixture, parser, scanner, and evidence lifecycle handling is deterministic and fail closed."),
        ROOT / "QUALITY_SCORE.md": ("### v1.14 Phase 57 Closed Eye-Retouch Evidence Score", "Exact traceability passes 7/7 task rows"),
        ROOT / "PLANS.md": ("| Phase 57 final closed eye-gate closeout |", "the checker passes 519 aggregate cases with per-threat totals `65 / 68 / 90 / 143 / 23 / 81 / 7 / 42`"),
    }
    return all(all(read_text(path).count(marker) == 1 for marker in markers) for path, markers in root_anchors.items())


def phase57_failures() -> set[str]:
    try:
        repository_available = _git_repository_available(ROOT)
        if not repository_available and not MUTATION_TEST_MODE:
            return {RULES["T-58-07"]}
        digest = hashlib.sha256(PHASE57_CHECKER.read_bytes()).hexdigest()
        if digest != PHASE57_CHECKER_SHA256:
            return {RULES["T-58-07"]}
        if repository_available and PHASE57_CHECKER.read_bytes() != _phase57_git_blob():
            return {RULES["T-58-07"]}
        if not _phase57_current_modes_ok() or not _phase57_owner_failures():
            return {RULES["T-58-07"]}
        # Non-Git roots are accepted only from explicit self-test mutation
        # fixtures; live and lifecycle modes always require the 519-case proof.
        if repository_available and not _phase57_pretransition_ok():
            return {RULES["T-58-07"]}
    except Exception:
        return {RULES["T-58-07"]}
    return set()


def parse_frontmatter(text: str) -> dict[str, str]:
    match = re.match(r"\A---\n(.*?)\n---\n", text, re.DOTALL)
    if match is None:
        raise ValueError("missing frontmatter")
    result: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            raise ValueError("malformed frontmatter")
        key, value = line.split(":", 1)
        if key in result:
            raise ValueError("duplicate frontmatter key")
        result[key] = value.strip()
    return result


def evidence_failures() -> set[str]:
    if read_json(INVENTORY) != expected_inventory():
        return {RULES["T-58-08"]}
    evidence = read_text(EVIDENCE)
    frontmatter = parse_frontmatter(evidence)
    expected_keys = ("phase", "status", "security_standard", "block_on", "requirements")
    if tuple(frontmatter) != expected_keys:
        return {RULES["T-58-08"]}
    if frontmatter["phase"] != "58" or frontmatter["status"] != "validated":
        return {RULES["T-58-08"]}
    if frontmatter["security_standard"] != "OWASP ASVS Level 1":
        return {RULES["T-58-08"]}
    if frontmatter["block_on"] != "HIGH":
        return {RULES["T-58-08"]}
    if frontmatter["requirements"] != "[SAFE-01, SAFE-02, SAFE-03, OUT-01, OUT-02, OUT-03, OUT-04]":
        return {RULES["T-58-08"]}
    sections = (
        "# Phase 58 Zero-Admission Closeout Evidence",
        "## Requirement Dispositions", "## Task Results", "## HIGH Results",
        "## Exact Invariants", "## Final Automated Evidence",
        "## Decision Coverage", "## Privacy Allowlist and Nonclaims",
        "## Owner Equality", "## Pending Final Lifecycle",
    )
    if any(evidence.count(section) != 1 for section in sections):
        return {RULES["T-58-08"]}
    for requirement, disposition in EXPECTED_DISPOSITIONS.items():
        if evidence.count(f"| {requirement} | `{disposition}` |") != 1:
            return {RULES["T-58-08"]}
    if any(evidence.count(f"| `{task}` |") != 1 for task in TASK_IDS):
        return {RULES["T-58-08"]}
    if any(evidence.count(f"| {threat} |") != 1 for threat in THREAT_IDS):
        return {RULES["T-58-08"]}
    if "D-58-01 through D-58-20" not in evidence:
        return {RULES["T-58-08"]}
    expected_task_status = {
        "58-01-01": "passed", "58-01-02": "passed", "58-02-01": "passed",
        "58-02-02": "passed", "58-03-01": "passed", "58-03-02": "passed",
        "58-04-01": "passed",
    }
    # The required lifecycle section retains its historical "Pending" heading
    # as a schema anchor; validated evidence must reject pending result prose,
    # not the section name itself.
    pending_scan = re.sub(r"(?im)^## Pending Final Lifecycle$", "", evidence)
    if frontmatter["status"] == "validated" and re.search(r"(?im)\bpending\b", pending_scan):
        return {RULES["T-58-08"]}
    for task, status in expected_task_status.items():
        if evidence.count(f"| `{task}` | {status} |") != 1:
            return {RULES["T-58-08"]}
    if "Phase 58 checker `251 / 0 / 0`; per-HIGH `80 / 33 / 37 / 34 / 28 / 31 / 4 / 4`" not in evidence:
        return {RULES["T-58-08"]}
    if "Phase 58 aggregate `276 / 0 / 0`; per-HIGH `80 / 33 / 37 / 34 / 28 / 31 / 25 / 8`" not in evidence:
        return {RULES["T-58-08"]}
    if "frozen pre-transition self-test `519 / 0 / 0`" not in evidence:
        return {RULES["T-58-08"]}
    if re.search(r"(?im)^\| (?:code review/fix|independent verifier|separate milestone audit) \| passed \|", evidence):
        return {RULES["T-58-08"]}
    if re.search(r"(?i)(?:implemented|active in production|production-ready|release-ready|launch-ready|promoted feature|shipped feature)", evidence):
        return {RULES["T-58-08"]}
    if re.search(r"(?im)(?:rawScannerError|raw scanner|stderr|traceback|subprocess output|scanner output|/Users/|/private/)", evidence):
        return {RULES["T-58-08"]}
    return set()


CHECKS = {
    "T-58-01": authority_failures,
    "T-58-02": privacy_failures,
    "T-58-03": lifetime_failures,
    "T-58-04": compatibility_failures,
    "T-58-05": output_failures,
    "T-58-06": promotion_failures,
    "T-58-07": phase57_failures,
    "T-58-08": evidence_failures,
}


def classified_failures(
    only: str | None = None,
    force_scanner_error: str | None = None,
) -> set[str]:
    selected = THREAT_IDS if only is None else (only,)
    failures: set[str] = set()
    for threat in selected:
        try:
            if force_scanner_error == threat:
                classify_rg(2, "", "private scanner failure")
            failures.update(CHECKS[threat]())
        except Exception:
            failures.add(RULES[threat])
    return failures


def fixture_paths() -> tuple[pathlib.Path, ...]:
    return (
        PACKAGE, SOURCES, FOUNDATION_TEST, COMPOSITION_TEST, CANONICAL_TEST,
        PARAMETER_TEST, RESOURCE_TEST, RENDERER_TEST, DEMO_ROOT, DEMO_TEST,
        DECISIONS, FEATURE_MATRIX,
        SHAPE_LEDGER, PHASE57_CHECKER, PHASE57_VERIFICATION, PHASE57_EVIDENCE,
        PHASE57_VALIDATION, PHASE57_INVENTORY, INVENTORY, EVIDENCE,
        ROOT / "PRODUCT_SENSE.md", ROOT / "SECURITY.md", ROOT / "RELIABILITY.md",
        ROOT / "QUALITY_SCORE.md", ROOT / "PLANS.md",
        ROOT / ".planning" / "ROADMAP.md", ROOT / ".planning" / "STATE.md",
        ROOT / ".planning" / "REQUIREMENTS.md",
    )


def copy_fixture(destination: pathlib.Path) -> None:
    for source in fixture_paths():
        relative = source.relative_to(ROOT)
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        if source.is_dir():
            shutil.copytree(source, target, dirs_exist_ok=True)
        else:
            shutil.copy2(source, target)


def threat_owner_path(threat: str) -> pathlib.Path:
    return {
        "T-58-01": DECISIONS,
        "T-58-02": EVIDENCE,
        "T-58-03": FOUNDATION_TEST,
        "T-58-04": PARAMETER_TEST,
        "T-58-05": EVIDENCE,
        "T-58-06": DEMO_SOURCE,
        "T-58-07": PHASE57_VERIFICATION,
        "T-58-08": INVENTORY,
    }[threat]


def mutate_representative(threat: str) -> None:
    if threat == "T-58-01":
        document = read_json(DECISIONS)
        document["feature_decisions"][0]["status"] = "open"
        DECISIONS.write_text(json.dumps(document), encoding="utf-8")
    elif threat == "T-58-02":
        target = SOURCES / "BeautySDK" / "NeutralState.swift"
        target.write_text("public var retainedScleraMask: [UInt8] = []\n", encoding="utf-8")
    elif threat == "T-58-03":
        source = read_text(FOUNDATION_TEST)
        FOUNDATION_TEST.write_text(source + "\n// Phase58CooperativeAbort\n", encoding="utf-8")
    elif threat == "T-58-04":
        source = read_text(PARAMETER_TEST)
        marker = "testPhase58ZeroAdmissionKeepsExact59FieldSourceCodingAndEncodedShape"
        PARAMETER_TEST.write_text(
            source.replace(marker, "testBrokenPhase58ZeroAdmissionShape", 1),
            encoding="utf-8",
        )
    elif threat == "T-58-05":
        target = SOURCES / "BeautyEffects" / "NeutralOutput.swift"
        target.write_text("let teethWhitening = true\n", encoding="utf-8")
    elif threat == "T-58-06":
        source = read_text(DEMO_SOURCE)
        old = 'unsupported("lips.teeth", title: "白牙", icon: "sparkles")'
        DEMO_SOURCE.write_text(source.replace(old, 'supported("lips.teeth", title: "白牙", icon: "sparkles", controlID: .brightness)', 1), encoding="utf-8")
    elif threat == "T-58-07":
        source = read_text(PHASE57_VERIFICATION)
        PHASE57_VERIFICATION.write_text(source.replace("status: passed", "status: gaps_found", 1), encoding="utf-8")
    elif threat == "T-58-08":
        document = read_json(INVENTORY)
        document["threats"][0]["severity"] = "MEDIUM"
        INVENTORY.write_text(json.dumps(document), encoding="utf-8")


def assert_fixture_mutation(threat: str, mutate: object) -> int:
    original_root = ROOT
    global MUTATION_TEST_MODE
    previous_mutation_mode = MUTATION_TEST_MODE
    MUTATION_TEST_MODE = True
    try:
        with tempfile.TemporaryDirectory(prefix="phase58-closeout-") as temporary:
            fixture = pathlib.Path(temporary)
            configure_root(original_root)
            copy_fixture(fixture)
            configure_root(fixture)
            if classified_failures(only=threat):
                raise AssertionError("clean fixture failed")
            mutate()
            if classified_failures(only=threat) != {RULES[threat]}:
                raise AssertionError("mutation accepted")
    finally:
        configure_root(original_root)
        MUTATION_TEST_MODE = previous_mutation_mode
    return 1


def assert_forced_scanner(threat: str) -> int:
    original_root = ROOT
    global MUTATION_TEST_MODE
    previous_mutation_mode = MUTATION_TEST_MODE
    MUTATION_TEST_MODE = True
    try:
        with tempfile.TemporaryDirectory(prefix="phase58-closeout-") as temporary:
            fixture = pathlib.Path(temporary)
            configure_root(original_root)
            copy_fixture(fixture)
            configure_root(fixture)
            if classified_failures(
                only=threat, force_scanner_error=threat
            ) != {RULES[threat]}:
                raise AssertionError("unclassified scanner accepted")
    finally:
        configure_root(original_root)
        MUTATION_TEST_MODE = previous_mutation_mode
    return 1


def mutate_text(path: pathlib.Path, old: str, new: str) -> None:
    source = read_text(path)
    if old not in source:
        raise AssertionError("mutation marker missing")
    path.write_text(source.replace(old, new, 1), encoding="utf-8")


def assert_lifetime_matrix() -> int:
    cases = 0

    foundation_markers = (
        "testValidInvalidValidDoesNotReuseRequestSupport",
        "testIndependentEngineValuesDoNotCrossPayloads",
        "testSameHarnessParallelInvocationsSerializeCompleteRequestTransactions",
        "testPhase58CanceledCallerDiscardsCompletedPublicationThenFreshRequestPublishes",
        "testPhase58CompleteRequestLocalLifecycleRetainsNoSupportBetweenTransactions",
        "testPhase58NoFaceAndMissingSupportPublishOnlyAllowlistedAggregateReasons",
        "let expectedValueIDs = Set(1...32)",
        "XCTAssertEqual(canceledOutcome, .discarded)",
        "XCTAssertEqual(fresh.aggregateSupportValueID, 202)",
    )
    for index, marker in enumerate(foundation_markers):
        cases += assert_fixture_mutation(
            "T-58-03",
            lambda marker=marker, index=index: mutate_text(
                FOUNDATION_TEST, marker, f"removedLifetimeMarker{index}"
            ),
        )

    composition_markers = (
        "testValidInvalidValidRequestsResetEveryCompositionObservation",
        "testThrownRequestClearsObservationBeforeThirdValidRequest",
        "testAbsentAndMalformedLocalWorkPreserveUnrelatedBrightnessAndFilterContinuation",
        "testPhase58ThrownMiddleRequestResetsCountersAndFreshRequestContinuesUnrelatedEffects",
    )
    for index, marker in enumerate(composition_markers):
        cases += assert_fixture_mutation(
            "T-58-03",
            lambda marker=marker, index=index: mutate_text(
                COMPOSITION_TEST, marker, f"removedCompositionMarker{index}"
            ),
        )

    support_file = lambda: SOURCES / "BeautySDK" / "BeautyEngineTestingSupport.swift"
    support_mutations = (
        ("private let invocationLock = NSLock()", "private let alteredLock = NSLock()"),
        ("public let detectionReasons: [String]", "public let anatomyObservation: [String]"),
        ("public let collisionPixelCount: Int", "public let rawPixelIdentity: Int"),
    )
    for old, new in support_mutations:
        cases += assert_fixture_mutation(
            "T-58-03",
            lambda old=old, new=new: mutate_text(support_file(), old, new),
        )

    forbidden_sources = (
        "private static var globalSupportCache = [Int: Any]()\n",
        "private static var staticRequestContext: Any?\n",
        "private var persistedRequestSupport: Any?\n",
        "private var crossRequestMaskStore = [Int: Any]()\n",
        "private var retainedAnatomyObservation: Any?\n",
    )
    for index, payload in enumerate(forbidden_sources):
        cases += assert_fixture_mutation(
            "T-58-03",
            lambda index=index, payload=payload: (
                (SOURCES / "NeutralPhase58" / f"Lifetime{index}.swift").parent.mkdir(
                    parents=True, exist_ok=True
                ),
                (SOURCES / "NeutralPhase58" / f"Lifetime{index}.swift").write_text(
                    payload, encoding="utf-8"
                ),
            ),
        )

    overclaims = (
        "Phase58CooperativeAbort",
        "claimsCooperativeAbort",
        "abortSDKWork",
        "TD013Resolved",
        "genericResultSendabilityResolved",
        "publicResultIsSendable",
        "rawRequestFailureOutput",
    )
    for marker in overclaims:
        cases += assert_fixture_mutation(
            "T-58-03",
            lambda marker=marker: EVIDENCE.write_text(
                read_text(EVIDENCE) + f"\n{marker}\n", encoding="utf-8"
            ),
        )

    for path_getter in (
        lambda: FOUNDATION_TEST,
        lambda: COMPOSITION_TEST,
        support_file,
        lambda: EVIDENCE,
    ):
        cases += assert_fixture_mutation(
            "T-58-03", lambda path_getter=path_getter: path_getter().unlink()
        )
        cases += assert_fixture_mutation(
            "T-58-03",
            lambda path_getter=path_getter: path_getter().write_bytes(b"\xff\xfe"),
        )

    original_root = ROOT
    try:
        with tempfile.TemporaryDirectory(prefix="phase58-closeout-") as temporary:
            fixture = pathlib.Path(temporary)
            configure_root(original_root)
            copy_fixture(fixture)
            configure_root(fixture)
            if classified_failures(
                only="T-58-03", force_scanner_error="T-58-03"
            ) != {RULES["T-58-03"]}:
                raise AssertionError("unclassified scanner accepted")
            cases += 1
    finally:
        configure_root(original_root)

    return cases


def append_text(path: pathlib.Path, payload: str) -> None:
    path.write_text(read_text(path) + payload, encoding="utf-8")


def write_decision_mutation(mutator: object) -> None:
    document = read_json(DECISIONS)
    mutator(document)
    DECISIONS.write_text(json.dumps(document), encoding="utf-8")


def assert_authority_matrix() -> int:
    cases = 0
    document_mutators = [
        lambda document: document.__setitem__("schema_version", 2),
        lambda document: document.__setitem__("schema_version", True),
        lambda document: document.__setitem__("schema_version", None),
        lambda document: document.__setitem__("schema_version", "1"),
        lambda document: document.__setitem__("reviews", [{}]),
        lambda document: document.__setitem__("competing_authority", []),
        lambda document: document["feature_decisions"].reverse(),
        lambda document: document["aggregates"].reverse(),
    ]
    for feature_index, feature in enumerate(FEATURES):
        document_mutators.extend((
            lambda document, index=feature_index: document["feature_decisions"].pop(index),
            lambda document, index=feature_index: document["feature_decisions"].append(
                dict(document["feature_decisions"][index])
            ),
            lambda document, index=feature_index: document["feature_decisions"][index].__setitem__(
                "feature", "renamed_feature"
            ),
            lambda document, index=feature_index: document["feature_decisions"][index].__setitem__(
                "status", "open"
            ),
            lambda document, index=feature_index: document["feature_decisions"][index].__setitem__(
                "reasons", list(reversed(document["feature_decisions"][index]["reasons"]))
            ),
            lambda document, index=feature_index: document["aggregates"].pop(index),
            lambda document, index=feature_index: document["aggregates"].append(
                dict(document["aggregates"][index])
            ),
        ))
        for key in ZERO_KEYS:
            document_mutators.extend((
                lambda document, index=feature_index, key=key: document["feature_decisions"][index].__setitem__(key, 1),
                lambda document, index=feature_index, key=key: document["aggregates"][index].__setitem__(key, 1),
            ))
        document_mutators.extend((
            lambda document, index=feature_index: document["feature_decisions"][index].__setitem__("borrowed_mechanics", True),
            lambda document, index=feature_index: document["aggregates"][index].__setitem__("borrowed_sibling", True),
        ))

    for mutator in document_mutators:
        cases += assert_fixture_mutation(
            "T-58-01", lambda mutator=mutator: write_decision_mutation(mutator)
        )

    cases += assert_fixture_mutation(
        "T-58-01",
        lambda: mutate_text(RESOLVER, "return .none", "return BeautyLocalRetouchAdmission(opaqueDemandCount: 1)"),
    )
    for index, identity in enumerate(CANDIDATE_IDENTITIES):
        candidate = f"let {identity} = true\n"
        cases += assert_fixture_mutation(
            "T-58-01",
            lambda index=index, candidate=candidate: (
                (SOURCES / "NeutralPhase58Authority").mkdir(parents=True, exist_ok=True),
                (SOURCES / "NeutralPhase58Authority" / f"Candidate{index}.swift").write_text(
                    candidate, encoding="utf-8"
                ),
            ),
        )
    cases += assert_fixture_mutation(
        "T-58-01", lambda: append_text(PACKAGE, "\n// teeth_whitening\n")
    )
    cases += assert_fixture_mutation(
        "T-58-01", lambda: append_text(MANIFEST, "\n\"sclera_redness\"\n")
    )
    for path_getter in (lambda: DECISIONS, lambda: RESOLVER, lambda: PACKAGE, lambda: MANIFEST):
        cases += assert_fixture_mutation(
            "T-58-01", lambda path_getter=path_getter: path_getter().unlink()
        )
        cases += assert_fixture_mutation(
            "T-58-01", lambda path_getter=path_getter: path_getter().write_bytes(b"\xff\xfe")
        )
    cases += assert_forced_scanner("T-58-01")
    return cases


def assert_privacy_matrix() -> int:
    cases = 0
    forbidden = (
        "public var publicRawLandmarks: [Float] = []\n",
        "@_spi(Testing) public var spiSupportCoordinates: [Float] { [] }\n",
        "struct Leak: Codable { let codableRequestMask: [UInt8] }\n",
        "private var persistedScleraMask: [UInt8] = []\n",
        "private var networkReviewerPayload: Data?\n",
        "private var loggedPupilPosition: CGPoint?\n",
        "private var metricVeinDescriptor: Double = 0\n",
        "private var trackedImageBytes: Data?\n",
        "private var durableFixturePath: String?\n",
        "private var durableImageDigest: String?\n",
        "private var durableSourceToken: String?\n",
    )
    for index, payload in enumerate(forbidden):
        cases += assert_fixture_mutation(
            "T-58-02",
            lambda index=index, payload=payload: (
                (SOURCES / "NeutralPhase58Privacy").mkdir(parents=True, exist_ok=True),
                (SOURCES / "NeutralPhase58Privacy" / f"Leak{index}.swift").write_text(
                    payload, encoding="utf-8"
                ),
            ),
        )

    boundary_payloads = (
        "public var rawPixels: [UInt8] = []\n",
        "public var publicLandmarkSupport: [Float] = []\n",
        "@_spi(Testing) public var spiPointObservation: [Float] { [] }\n",
        "struct Leak: Codable { let publicGeometryPayload: [Float] }\n",
        "@_spi(Testing) public var scleraCoordinates: [Float] { [] }\n",
        "let persisted = UserDefaults.standard; let pupilPosition = \"private\"\n",
        "let request = URLRequest(url: URL(string: \"https://invalid\")!); let teethGeometry = []\n",
        "print(\"rawLandmark\")\n",
    )
    for index, payload in enumerate(boundary_payloads):
        cases += assert_fixture_mutation(
            "T-58-02",
            lambda index=index, payload=payload: (
                (SOURCES / "NeutralPhase58Privacy").mkdir(parents=True, exist_ok=True),
                (SOURCES / "NeutralPhase58Privacy" / f"Boundary{index}.swift").write_text(
                    payload, encoding="utf-8"
                ),
            ),
        )

    for marker in (
        "durableFixturePath: /private/fixture",
        "durableImageDigest: deadbeef",
        "durableSourceToken: request-1",
        "rawScannerError: private failure",
        "rawSourceMatch: source line",
        "reviewer identity: private",
        "image bytes: 0102",
    ):
        cases += assert_fixture_mutation(
            "T-58-02", lambda marker=marker: append_text(EVIDENCE, f"\n{marker}\n")
        )

    cases += assert_fixture_mutation(
        "T-58-02",
        lambda: (PHASE / "tracked-output.png").write_bytes(b"not-an-image"),
    )
    for path_getter in (lambda: TESTING_SUPPORT, lambda: FOUNDATION_TEST, lambda: COMPOSITION_TEST, lambda: EVIDENCE):
        cases += assert_fixture_mutation(
            "T-58-02", lambda path_getter=path_getter: path_getter().unlink()
        )
        cases += assert_fixture_mutation(
            "T-58-02", lambda path_getter=path_getter: path_getter().write_bytes(b"\xff\xfe")
        )
    cases += assert_forced_scanner("T-58-02")
    return cases


def assert_compatibility_matrix() -> int:
    cases = 0
    mutations = (
        (lambda: PARAMETERS, "public var skinSmoothing:", "var skinSmoothing:"),
        (lambda: PARAMETERS, "case skinSmoothing", "case removedSkinSmoothing"),
        (lambda: ENGINE, "public func process(\n        image: CIImage", "func process(\n        image: CIImage"),
        (lambda: ENGINE, "public func processResult(\n        image: CIImage", "func processResult(\n        image: CIImage"),
        (lambda: CANONICAL_TEST, "testCarrierOwnsOneZeroOriginUpSRGBRGBA8Raster", "testRemovedCarrierContract"),
        (lambda: CANONICAL_TEST, "testAllEightOrientationsAndMirrorVariantsNormalizeIdentically", "testRemovedOrientationContract"),
        (lambda: CANONICAL_TEST, "testDisplayP3ConvertsToSRGBWithoutTopologyIdentityClaim", "testRemovedColorContract"),
        (lambda: FOUNDATION_TEST, "testPhase58ZeroAdmissionConjunctionPreservesBothFacadesAndCanonicalNoOp", "testRemovedNoopContract"),
        (lambda: FOUNDATION_TEST, "testPixelBufferOverloadsAndResetPerformZeroLocalFoundationWork", "testRemovedNonstillContract"),
        (lambda: PARAMETER_TEST, "testPhase58ZeroAdmissionKeepsExact59FieldSourceCodingAndEncodedShape", "testRemovedParameterContract"),
        (lambda: RESOURCE_TEST, "testPhase58ZeroAdmissionKeepsExactFivePresetSourcesAndNoCandidateKeys", "testRemovedPresetContract"),
        (lambda: RENDERER_TEST, "testPhase58ZeroAdmissionKeepsExact72RendererCasesAndNoOutputRoute", "testRemovedRendererContract"),
        (lambda: RENDERER, 'id: "skinSmoothing_0p50"', 'id: "changed_0p50"'),
        (lambda: PACKAGE, "import PackageDescription", "import PackageDescription\n// .package(url: \"https://invalid\")"),
    )
    for path_getter, old, new in mutations:
        cases += assert_fixture_mutation(
            "T-58-04",
            lambda path_getter=path_getter, old=old, new=new: mutate_text(path_getter(), old, new),
        )

    cases += assert_fixture_mutation(
        "T-58-04", lambda: (PRESETS / "natural.json").unlink()
    )
    cases += assert_fixture_mutation(
        "T-58-04", lambda: (PRESETS / "extra.json").write_text("{}", encoding="utf-8")
    )
    cases += assert_fixture_mutation(
        "T-58-04",
        lambda: write_json_mutation(MANIFEST, lambda document: document["presets"].pop()),
    )
    for path_getter in (
        lambda: PARAMETERS, lambda: MANIFEST, lambda: RENDERER, lambda: ENGINE,
        lambda: CANONICAL_TEST, lambda: PARAMETER_TEST, lambda: RESOURCE_TEST,
        lambda: RENDERER_TEST,
    ):
        cases += assert_fixture_mutation(
            "T-58-04", lambda path_getter=path_getter: path_getter().unlink()
        )
        cases += assert_fixture_mutation(
            "T-58-04", lambda path_getter=path_getter: path_getter().write_bytes(b"\xff\xfe")
        )
    cases += assert_forced_scanner("T-58-04")
    return cases


def write_json_mutation(path: pathlib.Path, mutator: object) -> None:
    document = read_json(path)
    mutator(document)
    path.write_text(json.dumps(document), encoding="utf-8")


def assert_output_matrix() -> int:
    cases = 0
    candidates = tuple(
        f"let {identity} = true\n" for identity in CANDIDATE_IDENTITIES
    ) + (
        "let visibleCandidateOutput = true\n", "let candidateSavedOutputHelper = true\n",
        "let candidateGalleryRoute = true\n", "let candidateReviewRoute = true\n",
        "let combinedTeethScleraRequest = true\n", "let featureNamedOpaqueMechanics = true\n",
    )
    for index, payload in enumerate(candidates):
        cases += assert_fixture_mutation(
            "T-58-05",
            lambda index=index, payload=payload: (
                (SOURCES / "NeutralPhase58Output").mkdir(parents=True, exist_ok=True),
                (SOURCES / "NeutralPhase58Output" / f"Route{index}.swift").write_text(
                    payload, encoding="utf-8"
                ),
            ),
        )
    cases += assert_fixture_mutation(
        "T-58-05", lambda: append_text(PACKAGE, "\n// upper_eyelid_fullness\n")
    )
    cases += assert_fixture_mutation(
        "T-58-05", lambda: append_text(MANIFEST, "\n\"teeth_whitening\"\n")
    )
    cases += assert_fixture_mutation(
        "T-58-05", lambda: append_text(PRESETS / "natural.json", "\n\"sclera_redness\"\n")
    )
    cases += assert_fixture_mutation(
        "T-58-05",
        lambda: (
            (DEMO_ROOT / "NeutralPhase58Output.swift").write_text(
                'let route = "lips.teeth"\n', encoding="utf-8"
            )
        ),
    )
    evidence_mutations = (
        ("| OUT-01 | `not_applicable_zero_admitted_features_exact_absence` |", "| OUT-01 | `implemented positive branch` |"),
        ("| OUT-02 | `not_applicable_zero_admitted_pair_exact_absence` |", "| OUT-02 | `passed positive branch` |"),
        ("Phase 55 composition remains feature-neutral", "Phase 55 composition is product evidence"),
        ("candidate, admitted,\n  pair, output, saved-output helper, gallery, and review surfaces are empty", "candidate output exists"),
    )
    for old, new in evidence_mutations:
        cases += assert_fixture_mutation(
            "T-58-05", lambda old=old, new=new: mutate_text(EVIDENCE, old, new)
        )
    for path_getter in (lambda: SOURCES, lambda: PACKAGE, lambda: MANIFEST, lambda: EVIDENCE):
        cases += assert_fixture_mutation(
            "T-58-05", lambda path_getter=path_getter: shutil.rmtree(path_getter()) if path_getter().is_dir() else path_getter().unlink()
        )
        if not path_getter().is_dir():
            cases += assert_fixture_mutation(
                "T-58-05", lambda path_getter=path_getter: path_getter().write_bytes(b"\xff\xfe")
            )
    cases += assert_forced_scanner("T-58-05")
    return cases


def assert_promotion_matrix() -> int:
    cases = 0
    for row in DEMO_DISABLED_ROWS:
        cases += assert_fixture_mutation(
            "T-58-06", lambda row=row: mutate_text(DEMO_SOURCE, row, "")
        )
        cases += assert_fixture_mutation(
            "T-58-06", lambda row=row: mutate_text(DEMO_SOURCE, row, row + "\n" + row)
        )
        cases += assert_fixture_mutation(
            "T-58-06", lambda row=row: mutate_text(DEMO_SOURCE, row, row.replace("unsupported(", "supported("))
        )
    for marker in (
        "testPhase58ZeroPromotionPreservesExactlyThreeDisabledLocalRetouchRows",
        "XCTAssertEqual(candidates.count, 3)",
        "XCTAssertFalse(tool.isSupported)",
        "XCTAssertNil(tool.controlID)",
    ):
        cases += assert_fixture_mutation(
            "T-58-06", lambda marker=marker: mutate_text(DEMO_TEST, marker, "removedPromotionMarker")
        )
    for row in SHAPE_FUTURE_ROWS:
        cases += assert_fixture_mutation(
            "T-58-06", lambda row=row: mutate_text(SHAPE_LEDGER, row, row.replace("future", "implemented"))
        )
    for prefix in MATRIX_PARTIAL_PREFIXES:
        cases += assert_fixture_mutation(
            "T-58-06", lambda prefix=prefix: mutate_text(FEATURE_MATRIX, prefix, prefix.replace("partial", "complete"))
        )
    cases += assert_fixture_mutation(
        "T-58-06", lambda: mutate_text(EVIDENCE, "promoted rows `0`", "promoted rows `1`")
    )
    cases += assert_fixture_mutation(
        "T-58-06", lambda: mutate_text(EVIDENCE, "admitted and promoted sets are exactly empty", "admitted and promoted sets are nonempty")
    )
    for path_getter in (lambda: DEMO_SOURCE, lambda: DEMO_TEST, lambda: SHAPE_LEDGER, lambda: FEATURE_MATRIX, lambda: EVIDENCE):
        cases += assert_fixture_mutation(
            "T-58-06", lambda path_getter=path_getter: path_getter().unlink()
        )
        cases += assert_fixture_mutation(
            "T-58-06", lambda path_getter=path_getter: path_getter().write_bytes(b"\xff\xfe")
        )
    cases += assert_forced_scanner("T-58-06")
    return cases


def assert_phase57_matrix() -> int:
    """Exercise real current Phase 57 owners without touching the frozen checker."""
    cases = 0
    cases += assert_archive_member_safety()
    mutations = (
        (PHASE57_CHECKER, lambda: append_text(PHASE57_CHECKER, "\n# phase58 checker mutation\n")),
        (PHASE57_VERIFICATION, lambda: mutate_text(PHASE57_VERIFICATION, "status: passed", "status: gaps_found")),
        (PHASE57_VERIFICATION, lambda: mutate_text(PHASE57_VERIFICATION, "score: 12/12 must-haves verified", "score: 11/12 must-haves verified")),
        (PHASE57_EVIDENCE, lambda: mutate_text(PHASE57_EVIDENCE, "status: validated", "status: draft")),
        (PHASE57_EVIDENCE, lambda: append_text(PHASE57_EVIDENCE, "\n| T-57-01 | passed | duplicate\n")),
        (PHASE57_VALIDATION, lambda: mutate_text(PHASE57_VALIDATION, "status: validated", "status: draft")),
        (PHASE57_INVENTORY, lambda: write_json_mutation(PHASE57_INVENTORY, lambda document: document["threats"].pop())),
        (ROOT / ".planning" / "STATE.md", lambda: mutate_text(ROOT / ".planning" / "STATE.md", "current_phase: 58", "current_phase: 57")),
        (ROOT / ".planning" / "ROADMAP.md", lambda: mutate_text(ROOT / ".planning" / "ROADMAP.md", "**Plans**: 4/4 plans executed", "**Plans**: 3/4 plans executed")),
        (ROOT / ".planning" / "REQUIREMENTS.md", lambda: mutate_text(ROOT / ".planning" / "REQUIREMENTS.md", "- [x] **SCLERA-01**", "- [ ] **SCLERA-01**")),
    )
    for path, mutation in mutations:
        cases += assert_fixture_mutation("T-58-07", mutation)
    for path in (
        PHASE57_CHECKER, PHASE57_VERIFICATION, PHASE57_EVIDENCE,
        PHASE57_VALIDATION, PHASE57_INVENTORY,
        ROOT / ".planning" / "STATE.md", ROOT / ".planning" / "ROADMAP.md",
    ):
        relative = path.relative_to(ROOT)
        cases += assert_fixture_mutation(
            "T-58-07", lambda relative=relative: (ROOT / relative).unlink()
        )
        cases += assert_fixture_mutation(
            "T-58-07", lambda relative=relative: (ROOT / relative).write_bytes(b"\xff\xfe")
        )
    cases += assert_forced_scanner("T-58-07")
    return cases


def assert_evidence_matrix() -> int:
    """Exercise evidence lifecycle, raw-error, and fixed-output boundaries."""
    cases = 0
    mutations = (
        lambda: mutate_text(EVIDENCE, "status: validated", "status: draft"),
        lambda: mutate_text(EVIDENCE, "## Requirement Dispositions", "## Requirement Dispositions\n## Requirement Dispositions"),
        lambda: mutate_text(EVIDENCE, "| `58-03-01` | passed", "| `58-03-01` | pending"),
        lambda: append_text(EVIDENCE, "\nrawScannerError: hidden\n"),
        lambda: append_text(EVIDENCE, "\n/Users/private/location\n"),
        lambda: append_text(EVIDENCE, "\nfeature output is implemented\n"),
        lambda: write_json_mutation(INVENTORY, lambda document: document["threats"].append(dict(document["threats"][0]))),
    )
    for mutation in mutations:
        cases += assert_fixture_mutation("T-58-08", mutation)
    cases += assert_forced_scanner("T-58-08")
    return cases


def self_test(only: str | None) -> int:
    selected = THREAT_IDS if only is None else (only,)
    original_root = ROOT
    cases = 0
    try:
        for threat in selected:
            complete_matrices = {
                "T-58-01": assert_authority_matrix,
                "T-58-02": assert_privacy_matrix,
                "T-58-03": assert_lifetime_matrix,
                "T-58-04": assert_compatibility_matrix,
                "T-58-05": assert_output_matrix,
                "T-58-06": assert_promotion_matrix,
                "T-58-07": assert_phase57_matrix,
                "T-58-08": assert_evidence_matrix,
            }
            if threat in complete_matrices:
                cases += complete_matrices[threat]()
                continue
            with tempfile.TemporaryDirectory(prefix="phase58-closeout-") as temporary:
                fixture = pathlib.Path(temporary)
                configure_root(original_root)
                copy_fixture(fixture)
                configure_root(fixture)
                if classified_failures(only=threat):
                    raise AssertionError("clean fixture failed")

                mutate_representative(threat)
                if classified_failures(only=threat) != {RULES[threat]}:
                    raise AssertionError("representative mutation accepted")
                cases += 1

            with tempfile.TemporaryDirectory(prefix="phase58-closeout-") as temporary:
                fixture = pathlib.Path(temporary)
                configure_root(original_root)
                copy_fixture(fixture)
                configure_root(fixture)
                threat_owner_path(threat).unlink()
                if classified_failures(only=threat) != {RULES[threat]}:
                    raise AssertionError("missing fixture accepted")
                cases += 1

            with tempfile.TemporaryDirectory(prefix="phase58-closeout-") as temporary:
                fixture = pathlib.Path(temporary)
                configure_root(original_root)
                copy_fixture(fixture)
                configure_root(fixture)
                threat_owner_path(threat).write_bytes(b"\xff\xfe")
                if classified_failures(only=threat) != {RULES[threat]}:
                    raise AssertionError("unreadable fixture accepted")
                cases += 1

            with tempfile.TemporaryDirectory(prefix="phase58-closeout-") as temporary:
                fixture = pathlib.Path(temporary)
                configure_root(original_root)
                copy_fixture(fixture)
                configure_root(fixture)
                if classified_failures(only=threat, force_scanner_error=threat) != {RULES[threat]}:
                    raise AssertionError("unclassified scanner accepted")
                cases += 1
    finally:
        configure_root(original_root)
    print(f"self-test status=passed threats={len(selected)} cases={cases}")
    return 0


def emit(mode: str, failures: set[str]) -> int:
    allowed = set(RULES.values())
    if not failures.issubset(allowed):
        failures = {RULES["T-58-08"]}
    if failures:
        print(f"mode={mode} status=blocked rules={','.join(sorted(failures))}")
        return 1
    print(f"mode={mode} status=passed rules=none")
    return 0


def emit_vision_summary() -> int:
    """Classify final opt-in Vision output without echoing command text."""
    try:
        payload = sys.stdin.read()
        match = re.fullmatch(r"executed=(\d+) skipped=(\d+) failed=(\d+)\n?", payload)
        if match is None:
            raise ValueError("unknown summary")
        executed, skipped, failed = (int(value) for value in match.groups())
        if (executed, skipped, failed) != (6, 0, 0):
            print("mode=vision-summary status=blocked rules=R58-EVIDENCE")
            return 1
        print("mode=vision-summary status=passed executed=6 skipped=0 failed=0")
        return 0
    except Exception:
        print("mode=vision-summary status=blocked rules=R58-EVIDENCE")
        return 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=pathlib.Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--decision", action="store_true")
    parser.add_argument("--lifecycle", action="store_true")
    parser.add_argument("--vision-summary", action="store_true")
    parser.add_argument("--only", choices=THREAT_IDS)
    arguments = parser.parse_args()
    if arguments.root is not None:
        configure_root(arguments.root)
    if arguments.only is not None and not arguments.self_test:
        parser.error("--only requires --self-test")
    if sum(bool(value) for value in (arguments.self_test, arguments.decision, arguments.lifecycle, arguments.vision_summary)) > 1:
        parser.error("checker modes are mutually exclusive")
    if arguments.vision_summary:
        return emit_vision_summary()
    mode = "self-test" if arguments.self_test else "decision" if arguments.decision else "lifecycle" if arguments.lifecycle else "live"
    try:
        if arguments.self_test:
            return self_test(arguments.only)
        if arguments.decision:
            return emit(mode, classified_failures(only="T-58-01"))
        if arguments.lifecycle:
            return emit(mode, classified_failures(only="T-58-07"))
        return emit(mode, classified_failures())
    except Exception:
        return emit(mode, {RULES["T-58-08"]})


if __name__ == "__main__":
    sys.exit(main())
