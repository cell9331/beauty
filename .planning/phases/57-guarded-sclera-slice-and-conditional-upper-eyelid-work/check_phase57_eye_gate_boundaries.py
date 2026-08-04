#!/usr/bin/env python3
"""Fail-closed Phase 57 eye-retouch absence and proxy-boundary checker."""

from __future__ import annotations

import argparse
import contextlib
import copy
import hashlib
import io
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile


ROOT = pathlib.Path(__file__).resolve().parents[3]
PHASE_NAME = "57-guarded-sclera-slice-and-conditional-upper-eyelid-work"
THREAT_IDS = tuple(f"T-57-{index:02d}" for index in range(1, 9))
RULES = {
    "T-57-01": "R57-AUTH",
    "T-57-02": "R57-SCLERA",
    "T-57-03": "R57-EYELID",
    "T-57-04": "R57-PROXY",
    "T-57-05": "R57-DEMO",
    "T-57-06": "R57-PRIVACY",
    "T-57-07": "R57-LEDGER",
    "T-57-08": "R57-COMPAT",
}
DECISION_KEYS = (
    "feature", "status", "reasons", "eligible_count", "reviewed_count",
    "accepted_count", "rejected_count", "naturalness_weight",
)
AGGREGATE_KEYS = (
    "feature", "eligible_count", "reviewed_count", "accepted_count",
    "rejected_count", "naturalness_weight",
)
FEATURE_ORDER = (
    "teeth_whitening", "sclera_redness", "upper_eyelid_fullness",
)
ZERO_KEYS = (
    "eligible_count", "reviewed_count", "accepted_count", "rejected_count",
    "naturalness_weight",
)
EXPECTED_DECISIONS = {
    "sclera_redness": {
        "feature": "sclera_redness",
        "status": "closed",
        "reasons": ["missing_genuine_positive", "missing_genuine_negative"],
        "eligible_count": 0,
        "reviewed_count": 0,
        "accepted_count": 0,
        "rejected_count": 0,
        "naturalness_weight": 0,
    },
    "upper_eyelid_fullness": {
        "feature": "upper_eyelid_fullness",
        "status": "closed",
        "reasons": [
            "missing_genuine_positive", "missing_genuine_negative",
            "non_warp_design_unqualified",
        ],
        "eligible_count": 0,
        "reviewed_count": 0,
        "accepted_count": 0,
        "rejected_count": 0,
        "naturalness_weight": 0,
    },
}
SCLERA_TOKENS = (
    "scleraRedness", "sclera_redness", "scleraWhitening", "scleraWhite",
    "scleraBrightness", "whitenSclera", "eyeRedness", "redEye",
    "conjunctivaRedness", "conjunctivalRedness", "conjunctivaWhitening",
    "conjunctivalWhitening", "ocularRedness", "ocularWhitening",
    "bloodshotReduction", "bloodshotEyeCorrection",
)
SCLERA_TOKEN_PATTERN = "(?:" + "|".join(map(re.escape, SCLERA_TOKENS)) + ")"
SCLERA_PATTERN = rf"(?i)\b{SCLERA_TOKEN_PATTERN}[A-Za-z0-9_]*\b"
SCLERA_ALIAS_PATTERN = (
    rf"(?is){SCLERA_TOKEN_PATTERN}"
    r".{0,160}(?:skinWhitening|brightness|skinColor|eyeHeight|upperEyelidLift|"
    r"teethWhitening|upperEyelidFullnessReduction|opaque|composition|mechanics)|"
    r"(?:skinWhitening|brightness|skinColor|eyeHeight|upperEyelidLift|teethWhitening|"
    r"upperEyelidFullnessReduction|opaque|composition|mechanics).{0,160}"
    rf"{SCLERA_TOKEN_PATTERN}"
)
EYELID_TOKENS = (
    "upperEyelidFullness", "upperLidFullness", "eyelidFullness", "lidFullness",
    "upperEyelidFat", "upperLidFat", "eyelidFat", "lidFat",
    "removeUpperEyelidFat", "removeEyelidFat", "removeUpperLidFat", "removeLidFat",
    "upperEyelidDefatting", "upperLidDefatting", "eyelidDefatting", "lidDefatting",
    "defatUpperEyelid", "defatEyelid", "defatUpperLid", "defatLid",
    "upper_eyelid_fullness", "upper_lid_fullness", "eyelid_fat", "lid_fat",
)
EYELID_TOKEN_PATTERN = "(?:" + "|".join(map(re.escape, EYELID_TOKENS)) + ")"
EYELID_PATTERN = rf"(?i)\b{EYELID_TOKEN_PATTERN}[A-Za-z0-9_]*\b"
EYELID_IDENTITY_PATTERN = (
    rf"(?:{EYELID_TOKEN_PATTERN}[A-Za-z0-9_]*|去脂|eyes\.fat)"
)
PROXY_PATTERN = (
    r"(?i)\b(?:eyeHeight|upperEyelidLift|eyebrowYPosition|"
    r"brow(?:Translation|Movement|Lift|Warp)|eyeAperture|eyeSize|eyeWarp|"
    r"verticalEyeWarp|interiorEyeWarp|eyeVerticalWarp|eyeInteriorWarp|"
    r"skinSmoothing|globalSmoothing|darkCircle(?:Removal)?|"
    r"eyeBag(?:Removal)?|scleraRednessReduction|teethWhitening|"
    r"opaque(?:Composition|Scenario|Mechanics|Demand|Unit)|"
    r"compositionScenario)[A-Za-z0-9_]*\b"
)
EXPECTED_PRESETS = (
    "clear.json", "id-photo-natural.json", "male-natural.json", "natural.json",
    "refined.json",
)
EXPECTED_MATRIX_ROW = "| Beauty shaping | 眼睛 | partial | `BeautyEffects` | `BeautyDetection` observed eye contours/pupils, `BeautyRender` unified warp | Four prior controls plus `eyeHeight`, `eyeLength`, `upperEyelidLift`, `pupilSize`, `gazeCorrection`, `lowerEyelidDrop`, signed `eyeTilt`, `innerCornerOpen`, `outerCornerOpen`, and `eyeSymmetry`; fourteen geometry rows implemented. | `去脂` and `祛红血丝` remain future local retouch/color slices. | Phases 29-30 cover four prior rows; Phase 41 contract/support, Phase 42 provider behavior, Phase 43 public output, and Phase 44 exact safety/privacy/boundary evidence independently cover the ten new rows. | Uses SDK domain `eyes`; branch remains partial solely because the two retouch rows are future. |"
EXPECTED_LID_ROW = "| `眼睛` | 去脂 | future | None. | Needs local retouch/segmentation design; no cloud AI by default. |"
EXPECTED_SCLERA_ROW = "| `眼睛` | 祛红血丝 | future | None. | Needs local color/segmentation retouch design. |"
EVIDENCE_REQUIREMENTS = (
    "SCLERA-01", "SCLERA-02", "SCLERA-03", "SCLERA-04", "SCLERA-05",
    "SCLERA-06", "LID-02", "LID-03", "LID-04", "LID-05",
)
EVIDENCE_FRONTMATTER_KEYS = (
    "phase", "status", "security_standard", "block_on", "requirements",
)
EVIDENCE_COMMON_SECTIONS = (
    "# Phase 57 Closed Eye-Gates Evidence",
    "## Immutable Decision Projections",
    "## Requirement Dispositions",
    "## Exact Invariants",
    "## Task and HIGH Results",
    "## Decision Coverage",
    "## Privacy Allowlist and Nonclaims",
)
EXPECTED_VALIDATED_EVIDENCE_SHA256 = (
    "a0e6c1ef927165927f61de6f18fd6c07028156e8da4f6313bfc5eb4e11e0fa68"
)
EXPECTED_EVIDENCE_DECISION_ROWS = (
    (
        "`sclera_redness`", "`closed`",
        "`missing_genuine_positive`, `missing_genuine_negative`",
        "`0 / 0 / 0 / 0 / 0`",
    ),
    (
        "`upper_eyelid_fullness`", "`closed`",
        "`missing_genuine_positive`, `missing_genuine_negative`, `non_warp_design_unqualified`",
        "`0 / 0 / 0 / 0 / 0`",
    ),
)
EXPECTED_EVIDENCE_DISPOSITION_ROWS = (
    ("SCLERA-01", "`false_branch_exact_absence`", "No public, Codable, Testing, admission, provider, renderer, preset, saved-output, or active Demo route."),
    ("SCLERA-02", "`not_applicable_closed_gate`", "No per-eye support, envelope, scoring, feathering, or re-clipping implementation claim."),
    ("SCLERA-03", "`not_applicable_closed_gate`", "No protected-region containment or safety-result claim."),
    ("SCLERA-04", "`not_applicable_closed_gate`", "No redness effectiveness or naturalness-result claim."),
    ("SCLERA-05", "`not_applicable_closed_gate`", "No classifier, abstention, or peer-eye-isolation implementation claim."),
    ("SCLERA-06", "`no_promotion`", "Facade, output, evidence, privacy, regression, Demo, and ledger owners agree that no product route is promoted."),
    ("LID-02", "`closed_branch_exact_absence`", "No field, provider, renderer, preset, admission, saved-output, or active Demo route."),
    ("LID-03", "`not_applicable_closed_gate`", "No qualified non-warp effect or identity/detail-preservation claim."),
    ("LID-04", "`proxy_rejection_enforced`", "Existing eye geometry, brow, smoothing, dark-circle, eye-bag, aperture, and warp domains remain independent and cannot represent `去脂`."),
    ("LID-05", "`not_applicable_closed_gate`", "No admitted facade, naturalness, output, privacy, or promotion claim."),
)
EXPECTED_EVIDENCE_TASK_ROWS = (
    ("`57-01-01`", "passed — SDK, facade, compatibility, and proxy-domain exact absence"),
    ("`57-01-02`", "passed — disabled Demo rows, ledgers, and initial HIGH checker"),
    ("`57-02-01`", "passed — exact independent Phase 54 parser; 65 mutation/input cases"),
    ("`57-02-02`", "passed — complete sclera production and synonym matrix; 32 cases"),
    ("`57-03-01`", "passed — 27 upper-eyelid activation/synonym cases and 19 candidate-to-proxy cases"),
    ("`57-03-02`", "passed — 19 Demo, 33 privacy/evidence/output, 7 ledger, and 18 compatibility/scanner cases; focused SDK 101/101 and Demo 29/29"),
    ("`57-04-01`", "passed — final focused/full regression, traceability, validation, evidence, and owner closeout"),
)
EXPECTED_EVIDENCE_HIGH_ROWS = tuple(
    (f"T-57-{index:02d}", result)
    for index, result in enumerate((
        "passed — 65 exact-authority cases",
        "passed — 32 whole-production sclera cases",
        "passed — 27 whole-production upper-eyelid cases",
        "passed — 19 bidirectional proxy-relation and proxy-only-control cases",
        "passed — 19 disabled-Demo and active-route cases",
        "passed — 33 structural lifecycle, privacy, contradiction, and fixed-output cases",
        "passed — 7 future/future/partial promotion and borrowing cases",
        "passed — 18 compatibility/evidence/scanner cases plus final regression",
    ), start=1)
)


def configure_root(root: pathlib.Path) -> None:
    global ROOT, PHASE, PACKAGE, SOURCES, PARAMETERS, MANIFEST, PRESETS, RENDERER
    global RESOLVER, ADMISSION, ENGINE, TESTING_SUPPORT, DEMO_ROOT
    global PARAMETER_TEST, RESOURCE_TEST, RENDERER_TEST, FOUNDATION_TEST
    global DEMO_SOURCE, DEMO_CONTROL, DEMO_PANEL, DEMO_STORE, DEMO_TEST
    global FEATURE_MATRIX, SHAPE_LEDGER, PRODUCT_SENSE, SECURITY, RELIABILITY
    global QUALITY_SCORE, REQUIREMENTS, DECISIONS, INVENTORY, EVIDENCE, VALIDATION

    ROOT = root.resolve()
    PHASE = ROOT / ".planning" / "phases" / PHASE_NAME
    PACKAGE = ROOT / "BeautySDK" / "Package.swift"
    SOURCES = ROOT / "BeautySDK" / "Sources"
    PARAMETERS = SOURCES / "BeautyCore" / "Models" / "BeautyParameters.swift"
    MANIFEST = SOURCES / "BeautyResources" / "Resources" / "manifest.json"
    PRESETS = SOURCES / "BeautyResources" / "Resources" / "Presets"
    RENDERER = SOURCES / "BeautyExampleRenderer" / "main.swift"
    RESOLVER = SOURCES / "BeautyEffects" / "Planning" / "BeautyEffectResolver.swift"
    ADMISSION = SOURCES / "BeautyEffects" / "Planning" / "BeautyLocalRetouchAdmission.swift"
    ENGINE = SOURCES / "BeautySDK" / "BeautyEngine.swift"
    TESTING_SUPPORT = SOURCES / "BeautySDK" / "BeautyEngineTestingSupport.swift"
    PARAMETER_TEST = ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" / "BeautyParametersTests.swift"
    RESOURCE_TEST = ROOT / "BeautySDK" / "Tests" / "BeautyResourcesTests" / "BeautyResourceCatalogTests.swift"
    RENDERER_TEST = ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" / "BeautyRendererOutputRegressionTests.swift"
    FOUNDATION_TEST = ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" / "BeautyEngineLocalRetouchFoundationTests.swift"
    DEMO_SOURCE = ROOT / "BeautyDemo" / "BeautyDemo" / "Editor" / "MeituEditorToolModels.swift"
    DEMO_ROOT = ROOT / "BeautyDemo" / "BeautyDemo"
    DEMO_CONTROL = ROOT / "BeautyDemo" / "BeautyDemo" / "Panel" / "BeautyControlDescriptor.swift"
    DEMO_PANEL = ROOT / "BeautyDemo" / "BeautyDemo" / "Editor" / "MeituEditorToolPanelView.swift"
    DEMO_STORE = ROOT / "BeautyDemo" / "BeautyDemo" / "State" / "BeautyParameterStore.swift"
    DEMO_TEST = ROOT / "BeautyDemo" / "BeautyDemoTests" / "BeautyDemoViewStateTests.swift"
    FEATURE_MATRIX = ROOT / "docs" / "meitu-function-blueprint" / "FEATURE_MATRIX.md"
    SHAPE_LEDGER = ROOT / "docs" / "meitu-function-blueprint" / "SHAPE_FEATURE_LEDGER.md"
    PRODUCT_SENSE = ROOT / "PRODUCT_SENSE.md"
    SECURITY = ROOT / "SECURITY.md"
    RELIABILITY = ROOT / "RELIABILITY.md"
    QUALITY_SCORE = ROOT / "QUALITY_SCORE.md"
    REQUIREMENTS = ROOT / ".planning" / "REQUIREMENTS.md"
    DECISIONS = ROOT / ".planning" / "phases" / "54-rights-approved-evidence-and-eligibility-decisions" / "54-EVIDENCE-DECISIONS.json"
    INVENTORY = PHASE / "57-THREAT-INVENTORY.json"
    EVIDENCE = PHASE / "57-CLOSED-EYE-GATES-EVIDENCE.md"
    VALIDATION = PHASE / "57-VALIDATION.md"


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


def expected_inventory() -> dict[str, object]:
    rows = (
        ("T-57-01", ["Spoofing", "Tampering"], "57-02-01", ["exact_phase54_dual_authority", "independent_closed_reasons_and_zero_counts"]),
        ("T-57-02", ["Elevation of Privilege", "Tampering"], "57-02-02", ["no_sclera_candidate_or_alias", "no_sclera_provider_renderer_preset_admission_or_output_route"]),
        ("T-57-03", ["Elevation of Privilege", "Tampering"], "57-03-01", ["no_upper_eyelid_candidate_or_alias", "no_upper_eyelid_provider_renderer_preset_admission_or_output_route"]),
        ("T-57-04", ["Elevation of Privilege", "Tampering"], "57-03-01", ["candidate_proxy_coupling_rejected", "legitimate_proxy_only_domains_preserved"]),
        ("T-57-05", ["Tampering"], "57-01-02+57-03-02", ["exact_disabled_demo_rows", "no_control_binding_store_processor_reset_or_availability_route"]),
        ("T-57-06", ["Information Disclosure"], "57-03-02", ["fixed_rule_only_output", "no_sensitive_eye_support_review_or_pixel_payload"]),
        ("T-57-07", ["Tampering", "Repudiation"], "57-03-02", ["exact_future_future_partial_ledgers", "no_sibling_or_teeth_borrowing"]),
        ("T-57-08", ["Tampering", "Denial of Service"], "57-03-02+57-04-01", ["exact_59_5_72_facade_and_evidence_owners", "missing_malformed_and_scanner_fail_closed"]),
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
                "gates": gates,
            }
            for threat_id, stride, owner, gates in rows
        ],
    }


def required_paths() -> tuple[pathlib.Path, ...]:
    return (
        PACKAGE, SOURCES, PARAMETERS, MANIFEST, PRESETS, RENDERER, RESOLVER,
        ADMISSION, ENGINE, TESTING_SUPPORT, PARAMETER_TEST,
        RESOURCE_TEST, RENDERER_TEST, FOUNDATION_TEST, DEMO_SOURCE, DEMO_CONTROL,
        DEMO_PANEL, DEMO_STORE, DEMO_TEST, FEATURE_MATRIX, SHAPE_LEDGER,
        PRODUCT_SENSE, SECURITY, RELIABILITY, QUALITY_SCORE, REQUIREMENTS,
        DECISIONS, INVENTORY, EVIDENCE, VALIDATION,
    )


def read_text(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def read_json(path: pathlib.Path) -> object:
    return json.loads(read_text(path))


def extract_coding_keys(text: str) -> tuple[str, ...]:
    match = re.search(r"enum CodingKeys[^\{]*\{(.*?)\n\s*\}", text, re.DOTALL)
    if match is None:
        return ()
    return tuple(re.findall(r"^\s*case\s+([A-Za-z][A-Za-z0-9]*)\s*$", match.group(1), re.MULTILINE))


def expected_renderer_ids(text: str) -> tuple[str, ...]:
    match = re.search(r"expectedRendererCaseIDs\s*=\s*\[(.*?)\n\s*\]", text, re.DOTALL)
    return () if match is None else tuple(re.findall(r'"([^"]+)"', match.group(1)))


def authority_failures() -> set[str]:
    try:
        document = read_json(DECISIONS)
    except (OSError, UnicodeError, json.JSONDecodeError):
        return {"R57-AUTH"}
    if (
        not isinstance(document, dict)
        or tuple(document) != ("schema_version", "feature_decisions", "reviews", "aggregates")
    ):
        return {"R57-AUTH"}
    if type(document.get("schema_version")) is not int or document.get("schema_version") != 1:
        return {"R57-AUTH"}
    if document.get("reviews") != []:
        return {"R57-AUTH"}
    rows = document.get("feature_decisions")
    aggregates = document.get("aggregates")
    if (
        not isinstance(rows, list)
        or len(rows) != len(FEATURE_ORDER)
        or not isinstance(aggregates, list)
        or len(aggregates) != len(FEATURE_ORDER)
    ):
        return {"R57-AUTH"}
    row_features = tuple(row.get("feature") if isinstance(row, dict) else None for row in rows)
    aggregate_features = tuple(
        row.get("feature") if isinstance(row, dict) else None for row in aggregates
    )
    if row_features != FEATURE_ORDER or aggregate_features != FEATURE_ORDER:
        return {"R57-AUTH"}

    candidate_family = re.compile(
        r"(?i)sclera|conjunct|ocular|bloodshot|upper.?eyelid|upper.?lid|lid.?fat|lid.?full",
    )
    candidate_rows = [
        row for row in rows
        if isinstance(row, dict)
        and isinstance(row.get("feature"), str)
        and candidate_family.search(row["feature"])
    ]
    if tuple(row.get("feature") for row in candidate_rows) != FEATURE_ORDER[1:]:
        return {"R57-AUTH"}

    for row in rows:
        if not isinstance(row, dict) or tuple(row) != DECISION_KEYS:
            return {"R57-AUTH"}
        if type(row.get("status")) is not str:
            return {"R57-AUTH"}
        reasons = row.get("reasons")
        if type(reasons) is not list or any(type(reason) is not str for reason in reasons):
            return {"R57-AUTH"}
        if any(type(row.get(key)) is not int for key in ZERO_KEYS):
            return {"R57-AUTH"}
    for row in aggregates:
        if not isinstance(row, dict) or tuple(row) != AGGREGATE_KEYS:
            return {"R57-AUTH"}
        if any(type(row.get(key)) is not int for key in ZERO_KEYS):
            return {"R57-AUTH"}

    for feature, expected in EXPECTED_DECISIONS.items():
        matching = [row for row in rows if isinstance(row, dict) and row.get("feature") == feature]
        if len(matching) != 1 or tuple(matching[0]) != DECISION_KEYS or matching[0] != expected:
            return {"R57-AUTH"}
        row = matching[0]
        if type(row["reasons"]) is not list or any(type(row[key]) is not int for key in ZERO_KEYS):
            return {"R57-AUTH"}
        expected_aggregate = {key: value for key, value in expected.items() if key != "status" and key != "reasons"}
        if [item for item in aggregates if isinstance(item, dict) and item.get("feature") == feature] != [expected_aggregate]:
            return {"R57-AUTH"}
    return set()


def classified_live_failures() -> set[str]:
    try:
        return live_failures()
    except (
        OSError, UnicodeError, ValueError, KeyError, TypeError,
        ScannerFailure, AssertionError, json.JSONDecodeError,
        subprocess.SubprocessError,
    ):
        return {"R57-AUTH", "R57-COMPAT"}


def source_failures() -> set[str]:
    failures: set[str] = set()
    try:
        if run_rg(SCLERA_PATTERN, (SOURCES,)) == "match":
            failures.add("R57-SCLERA")
        if run_rg(EYELID_PATTERN, (SOURCES,)) == "match":
            failures.add("R57-EYELID")
        source_files = tuple(sorted(SOURCES.rglob("*.swift")))
        source_text = "\n".join(read_text(path) for path in source_files)
        supplemental_text = "\n".join(
            [read_text(PACKAGE), read_text(MANIFEST)]
            + [read_text(path) for path in sorted(PRESETS.glob("*.json"))]
            + [read_text(path) for path in sorted(DEMO_ROOT.rglob("*.swift"))]
        )
    except (OSError, UnicodeError, ScannerFailure):
        return {"R57-SCLERA", "R57-EYELID", "R57-COMPAT"}

    if re.search(SCLERA_PATTERN, supplemental_text):
        failures.add("R57-SCLERA")
    if re.search(EYELID_PATTERN, supplemental_text):
        failures.add("R57-EYELID")
    if re.search(SCLERA_ALIAS_PATTERN, f"{source_text}\n{supplemental_text}"):
        failures.add("R57-SCLERA")

    candidate = (
        rf"(?:{SCLERA_TOKEN_PATTERN}[A-Za-z0-9_]*|{EYELID_IDENTITY_PATTERN})"
    )
    relation = re.compile(
        rf"(?:{candidate}.{{0,200}}{PROXY_PATTERN.replace('(?i)', '')}|{PROXY_PATTERN.replace('(?i)', '')}.{{0,200}}{candidate})",
        re.IGNORECASE | re.DOTALL,
    )
    if relation.search(source_text):
        failures.add("R57-PROXY")
    return failures


def compatibility_failures() -> set[str]:
    try:
        parameters = read_text(PARAMETERS)
        parameter_test = read_text(PARAMETER_TEST)
        resource_test = read_text(RESOURCE_TEST)
        renderer_test = read_text(RENDERER_TEST)
        foundation_test = read_text(FOUNDATION_TEST)
        resolver_source = read_text(RESOLVER)
        resolver = " ".join(resolver_source.split())
        manifest = read_json(MANIFEST)
        renderer_source = read_text(RENDERER)
        preset_names = tuple(sorted(path.name for path in PRESETS.glob("*.json")))
    except (OSError, UnicodeError, json.JSONDecodeError):
        return {"R57-COMPAT"}
    stored = tuple(re.findall(
        r"^\s*public var\s+([A-Za-z][A-Za-z0-9]*)\s*:", parameters, re.MULTILINE,
    ))
    if len(stored) != 59 or extract_coding_keys(parameters) != stored or stored.count("filterId") != 1:
        return {"R57-COMPAT"}
    expected_ids = expected_renderer_ids(renderer_test)
    renderer_ids = tuple(re.findall(r'\bid:\s*"([^"]+)"', renderer_source))
    manifest_ids = tuple(
        row.get("id") for row in manifest.get("presets", [])
        if isinstance(row, dict)
    ) if isinstance(manifest, dict) else ()
    if (
        len(expected_ids) != 72
        or len(set(expected_ids)) != 72
        or renderer_ids != expected_ids
        or preset_names != EXPECTED_PRESETS
        or manifest_ids != ("natural", "clear", "refined", "male-natural", "id-photo-natural")
    ):
        return {"R57-COMPAT"}
    if (
        re.search(
            r"localRetouchAdmission\s*\(\s*parameters:[^\)]*\)[^{]*\{\s*"
            r"_\s*=\s*parameters\s*return\s+\.none\s*\}",
            resolver_source,
            re.DOTALL,
        ) is None
        or "return .none" not in resolver
    ):
        return {"R57-COMPAT"}
    required_anchors = {
        parameter_test: (
            "testPhase57ClosedEyeRetouchGatesKeepPublicAndCodableSurfaceExact",
            "XCTAssertEqual(stored.count, 59)",
            "XCTAssertEqual(coding, stored)",
            "XCTAssertEqual(encoded.count, 58)",
            'Set(stored).subtracting(["filterId"])',
            "XCTAssertEqual(Mirror(reflecting: shippedDomains).children.count, 59)",
        ),
        resource_test: (
            "testPhase57ClosedEyeRetouchGatesAddNoPresetKeyOrResource",
            'let expectedIDs = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]',
            "XCTAssertEqual(presets.count, 5)",
            "XCTAssertEqual(Mirror(reflecting: preset.parameters).children.count, 59)",
        ),
        renderer_test: (
            "testPhase57ClosedEyeRetouchGatesKeepRendererAndSavedOutputSurfaceExact",
            "XCTAssertEqual(Self.expectedRendererCaseIDs.count, 72)",
            "XCTAssertEqual(Set(Self.expectedRendererCaseIDs).count, 72)",
            '"skinSmoothing_0p50", "eyeHeight_0p25", "upperEyelidLift_0p25"',
            'XCTAssertEqual(source.components(separatedBy: "engine.processResult(").count - 1, 1)',
        ),
        foundation_test: (
            "testPhase57ClosedEyeRetouchGatesKeepLiteralNoneAndStillEntriesInactive",
            "testPhase57PixelBufferResetAndOpaqueMechanicsStayOutsideEyeCandidates",
            "XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionCount, 0)",
            "XCTAssertEqual(SDKTestingLocalRetouchFoundationHarness.productionAdmissionNames, [])",
            "XCTAssertEqual(resultOutput.warnings, [])",
            "XCTAssertEqual(resultOutput.detectionSummary, .notRun)",
            "XCTAssertEqual(harness.localProviderCount, 0)",
            'XCTAssertEqual(harness.pixelBufferSummaryAvailability, "notRun")',
            "XCTAssertEqual(harness.compositionObservation.compositionInvocationCount, 0)",
        ),
    }
    if any(
        anchor not in text
        for text, anchors in required_anchors.items()
        for anchor in anchors
    ):
        return {"R57-COMPAT"}
    return set()


def demo_failures() -> set[str]:
    try:
        source = read_text(DEMO_SOURCE)
        demo_files = tuple(sorted(DEMO_ROOT.rglob("*.swift")))
        demo_text = {path: read_text(path) for path in demo_files}
        test = read_text(DEMO_TEST)
    except (OSError, UnicodeError):
        return {"R57-DEMO"}
    required = (
        'unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)',
        'unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)',
    )
    if any(source.count(row) != 1 for row in required):
        return {"R57-DEMO"}
    if source.index(required[0]) >= source.index(required[1]):
        return {"R57-DEMO"}
    test_anchors = (
        "testPhase57ClosedEyeRetouchGatesPreserveDisabledRowsAndProxyIndependence",
        '"eyes.fat", "eyes.liftMuscle", "eyes.pupil", "eyes.gaze", "eyes.lowerLid"',
        '"eyes.tailLift", "eyes.tilt", "eyes.redness", "eyes.innerCorner"',
        'XCTAssertEqual(fat.title, "去脂")',
        'XCTAssertEqual(fat.systemImageName, "minus.circle")',
        "XCTAssertEqual(fat.badge, .free)",
        "XCTAssertFalse(fat.isSupported)",
        "XCTAssertNil(fat.controlID)",
        'XCTAssertEqual(redness.title, "祛红血丝")',
        'XCTAssertEqual(redness.systemImageName, "drop")',
        "XCTAssertEqual(redness.badge, .free)",
        "XCTAssertFalse(redness.isSupported)",
        "XCTAssertNil(redness.controlID)",
        'XCTAssertEqual(fat.unavailableReason, "v1.1 暂未实现该美图参考功能")',
        'XCTAssertEqual(redness.unavailableReason, "v1.1 暂未实现该美图参考功能")',
        '"eyes.size": .eyeSize',
        '"eyes.upDown": .eyeYPosition',
        '"eyes.distance": .eyeDistance',
        '"eyes.tailLift": .eyeTailLift',
    )
    if any(anchor not in test for anchor in test_anchors):
        return {"R57-DEMO"}
    if test.count("XCTAssertNil(fat.controlID)") != 2 or test.count("XCTAssertNil(redness.controlID)") != 2:
        return {"R57-DEMO"}
    identity = re.compile(r"(?i)eyes\.(?:fat|redness)\b|去脂|祛红血丝")
    for path, text in demo_text.items():
        residual = text
        if path == DEMO_SOURCE:
            for row in required:
                residual = residual.replace(row, "", 1)
        if (
            identity.search(residual)
            or re.search(SCLERA_PATTERN, residual)
            or re.search(EYELID_PATTERN, residual)
        ):
            return {"R57-DEMO"}
    return set()


def ledger_failures() -> set[str]:
    try:
        matrix = read_text(FEATURE_MATRIX)
        ledger = read_text(SHAPE_LEDGER)
    except (OSError, UnicodeError):
        return {"R57-LEDGER"}
    if matrix.count(EXPECTED_MATRIX_ROW) != 1:
        return {"R57-LEDGER"}
    if ledger.count(EXPECTED_LID_ROW) != 1 or ledger.count(EXPECTED_SCLERA_ROW) != 1:
        return {"R57-LEDGER"}
    return set()


def inventory_failures() -> set[str]:
    try:
        document = read_json(INVENTORY)
    except (OSError, UnicodeError, json.JSONDecodeError):
        return {"R57-PRIVACY", "R57-COMPAT"}
    failures = set()
    if document != expected_inventory():
        failures.add("R57-COMPAT")
    forbidden = re.compile(
        r"portrait|file.?path|sha|hash|grant|rights|reviewer|pupil|iris|landmark|"
        r"coordinate|mask|vein|pixel|digest|raw.?output|source.?match",
        re.IGNORECASE,
    )
    def unsafe(value: object) -> bool:
        if isinstance(value, dict):
            return any(forbidden.search(str(key)) or unsafe(item) for key, item in value.items())
        if isinstance(value, list):
            return any(unsafe(item) for item in value)
        return False
    if unsafe(document):
        failures.add("R57-PRIVACY")
    return failures


def parse_evidence_frontmatter(text: str) -> tuple[dict[str, object], str] | None:
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        return None
    try:
        closing = lines.index("---", 1)
    except ValueError:
        return None
    if closing <= 1:
        return None

    parsed: dict[str, object] = {}
    for line in lines[1:closing]:
        match = re.fullmatch(r"([a-z_]+):\s*(.+)", line)
        if match is None:
            return None
        key, raw = match.groups()
        if key in parsed or key not in EVIDENCE_FRONTMATTER_KEYS:
            return None
        if key == "phase":
            if re.fullmatch(r"[0-9]+", raw) is None:
                return None
            parsed[key] = int(raw)
        elif key == "requirements":
            requirement_match = re.fullmatch(r"\[([^\]]*)\]", raw)
            if requirement_match is None:
                return None
            parsed[key] = tuple(
                item.strip() for item in requirement_match.group(1).split(",")
                if item.strip()
            )
        else:
            parsed[key] = raw
    if tuple(parsed) != EVIDENCE_FRONTMATTER_KEYS:
        return None
    body = "\n".join(lines[closing + 1:])
    if re.search(
        r"(?m)^---\s*$\n(?:phase|status|security_standard|block_on|requirements)\s*:",
        body,
    ):
        return None
    return parsed, body


def has_affirmative_eye_candidate_claim(text: str) -> bool:
    candidate = (
        r"(?:sclera(?:[ _-]+redness(?:[ _-]+reduction)?|Redness(?:Reduction)?)|"
        r"conjunctiva(?:l)?[ _-]+redness|ocular[ _-]+redness|祛红血丝|"
        r"upper[- _]eyelid(?:[- _]+fullness(?:[- _]+reduction)?|Fullness(?:Reduction)?)|"
        r"upper_eyelid_fullness|去脂)"
    )
    status = (
        r"(?:active|enabled|available|open|implemented|promoted|released|shipped|production-ready|"
        r"release-ready|launch-ready|ready\s+for\s+(?:release|shipping|launch))"
    )
    direct = re.compile(
        rf"(?i){candidate}.{{0,64}}\b(?:is|are|was|were|has|have)\s+"
        rf"(?!not\b|never\b)(?:been\s+)?{status}\b"
    )
    active = re.compile(rf"(?i)\b{status}\b.{{0,64}}{candidate}")
    table_fragment = re.compile(
        rf"(?i)(?:{candidate}.{{0,160}}\b{status}\b|\b{status}\b.{{0,160}}{candidate})"
    )
    if any(line.startswith("|") and table_fragment.search(line) for line in text.splitlines()):
        return True
    for sentence in re.split(r"[.!?\n]+", text):
        if direct.search(sentence):
            return True
        match = active.search(sentence)
        if match is not None:
            prefix = sentence[max(0, match.start() - 16):match.start()]
            if re.search(r"(?i)\b(?:not|never|no)\s*$", prefix) is None:
                return True
    return False


def evidence_section(body: str, heading: str) -> str | None:
    marker = f"{heading}\n"
    if body.count(marker) != 1:
        return None
    remainder = body.split(marker, 1)[1]
    match = re.search(r"(?m)^##\s+", remainder)
    return remainder if match is None else remainder[:match.start()]


def evidence_tables(section: str) -> tuple[tuple[tuple[str, ...], ...], ...] | None:
    tables: list[tuple[tuple[str, ...], ...]] = []
    current: list[tuple[str, ...]] = []
    for line in section.splitlines():
        if line.startswith("|") and line.endswith("|"):
            current.append(tuple(cell.strip() for cell in line[1:-1].split("|")))
        elif current:
            tables.append(tuple(current))
            current = []
    if current:
        tables.append(tuple(current))
    for table in tables:
        if len(table) < 3 or any(cell != "---" for cell in table[1]):
            return None
        width = len(table[0])
        if any(len(row) != width for row in table):
            return None
    return tuple(tables)


def exact_evidence_tables(body: str) -> bool:
    decision = evidence_section(body, "## Immutable Decision Projections")
    dispositions = evidence_section(body, "## Requirement Dispositions")
    results = evidence_section(body, "## Task and HIGH Results")
    if decision is None or dispositions is None or results is None:
        return False
    decision_tables = evidence_tables(decision)
    disposition_tables = evidence_tables(dispositions)
    result_tables = evidence_tables(results)
    return (
        decision_tables == ((
            ("Feature", "Status", "Ordered reasons", "Eligible / reviewed / accepted / rejected / naturalness weight"),
            ("---", "---", "---", "---"),
            *EXPECTED_EVIDENCE_DECISION_ROWS,
        ),)
        and disposition_tables == ((
            ("Requirement", "Final disposition", "Validated outcome"),
            ("---", "---", "---"),
            *EXPECTED_EVIDENCE_DISPOSITION_ROWS,
        ),)
        and result_tables == (
            (
                ("Task", "Final result"),
                ("---", "---"),
                *EXPECTED_EVIDENCE_TASK_ROWS,
            ),
            (
                ("HIGH gate", "Final machine result"),
                ("---", "---"),
                *EXPECTED_EVIDENCE_HIGH_ROWS,
            ),
        )
    )


def evidence_failures() -> set[str]:
    try:
        text = read_text(EVIDENCE)
    except (OSError, UnicodeError):
        return {"R57-COMPAT"}
    parsed = parse_evidence_frontmatter(text)
    if parsed is None:
        return {"R57-PRIVACY", "R57-COMPAT"}
    frontmatter, body = parsed
    status = frontmatter.get("status")
    if (
        frontmatter.get("phase") != 57
        or status not in ("draft", "validated")
        or frontmatter.get("security_standard") != "OWASP ASVS Level 1"
        or frontmatter.get("block_on") != "HIGH"
        or frontmatter.get("requirements") != EVIDENCE_REQUIREMENTS
    ):
        return {"R57-COMPAT"}

    required_dispositions = (
        "SCLERA-01 | `false_branch_exact_absence`",
        "SCLERA-02 | `not_applicable_closed_gate`",
        "SCLERA-03 | `not_applicable_closed_gate`",
        "SCLERA-04 | `not_applicable_closed_gate`",
        "SCLERA-05 | `not_applicable_closed_gate`",
        "SCLERA-06 | `no_promotion`",
        "LID-02 | `closed_branch_exact_absence`",
        "LID-03 | `not_applicable_closed_gate`",
        "LID-04 | `proxy_rejection_enforced`",
        "LID-05 | `not_applicable_closed_gate`",
    )
    required_invariants = (
        "`sclera_redness` | `closed`",
        "`upper_eyelid_fullness` | `closed`",
        "`0 / 0 / 0 / 0 / 0`",
        "`59 / 5 / 72`",
        "literal `.none`",
        "`eyes.redness` / `祛红血丝`",
        "`eyes.fat` / `去脂`",
        "`祛红血丝 = future`",
        "`去脂 = future`",
        "`眼睛 = partial`",
    )
    required_ids = tuple(
        [
            "57-01-01", "57-01-02", "57-02-01", "57-02-02",
            "57-03-01", "57-03-02", "57-04-01",
        ]
        + list(THREAT_IDS)
        + [f"D-57-{index:02d}" for index in range(1, 21)]
    )
    if (
        any(body.count(section) != 1 for section in EVIDENCE_COMMON_SECTIONS)
        or any(item not in body for item in required_dispositions)
        or any(item not in body for item in required_invariants)
        or any(identifier not in body for identifier in required_ids)
        or not exact_evidence_tables(body)
        or has_affirmative_eye_candidate_claim(body)
    ):
        return {"R57-PRIVACY", "R57-COMPAT"}

    if (
        status == "validated"
        and hashlib.sha256(body.encode("utf-8")).hexdigest()
        != EXPECTED_VALIDATED_EVIDENCE_SHA256
    ):
        # Final evidence is an exact aggregate-only document. Any unrecognized
        # paragraph, bullet, quote, or table cell fails closed before it can
        # retain request-local support or contradict a closed decision.
        return {"R57-PRIVACY", "R57-COMPAT"}

    if status == "draft":
        if body.count("## Pending Final Automated Evidence") != 1:
            return {"R57-COMPAT"}
        if "57-04-01` | pending" not in body or body.count("Final regression: pending") != 1:
            return {"R57-COMPAT"}
    else:
        if (
            body.count("## Final Automated Evidence") != 1
            or re.search(r"(?im)^\s*(?:[-*]\s*)?.*\bpending\b", body)
        ):
            return {"R57-COMPAT"}

    privacy_payload = re.compile(
        r"(?im)^\s*(?:[-*]\s*)?(?:portrait(?:_path)?|file(?:_name|_path)?|"
        r"sha(?:256)?|hash|grant|rights(?:_record)?|reviewer|image|media|"
        r"eye|pupil|iris|landmark|coordinates?|mask|vein(?:_descriptor)?|"
        r"pixels?|digest|raw_?(?:match|error)|freeform(?:_payload)?)\s*[:=|]"
    )
    if (
        re.search(r"/(?:Users|private|Volumes|home)/", text, re.IGNORECASE)
        or re.search(r"\b[a-f0-9]{64}\b|\.(?:jpg|jpeg|png|heic)\b", text, re.IGNORECASE)
        or privacy_payload.search(text)
    ):
        return {"R57-PRIVACY"}
    return set()


def validation_lifecycle_failures() -> set[str]:
    try:
        validation = read_text(VALIDATION)
        requirements = read_text(REQUIREMENTS)
    except (OSError, UnicodeError):
        return {"R57-COMPAT"}
    evidence = parse_evidence_frontmatter(read_text(EVIDENCE))
    if evidence is None:
        return {"R57-COMPAT"}
    status = evidence[0]["status"]
    task_ids = (
        "57-01-01", "57-01-02", "57-02-01", "57-02-02",
        "57-03-01", "57-03-02", "57-04-01",
    )
    if any(
        len(re.findall(rf"(?m)^\| `{re.escape(task)}` \|", validation)) != 1
        for task in task_ids
    ):
        return {"R57-COMPAT"}
    if status == "draft":
        if "status: draft" not in validation or "nyquist_compliant: false" not in validation:
            return {"R57-COMPAT"}
        for requirement in EVIDENCE_REQUIREMENTS:
            if f"- [ ] **{requirement}**" not in requirements or f"| {requirement} | Phase 57 | Pending |" not in requirements:
                return {"R57-COMPAT"}
    else:
        if "status: validated" not in validation or "nyquist_compliant: true" not in validation:
            return {"R57-COMPAT"}
        dispositions = {
            "SCLERA-01": "false_branch_exact_absence",
            "SCLERA-02": "not_applicable_closed_gate",
            "SCLERA-03": "not_applicable_closed_gate",
            "SCLERA-04": "not_applicable_closed_gate",
            "SCLERA-05": "not_applicable_closed_gate",
            "SCLERA-06": "no_promotion",
            "LID-02": "closed_branch_exact_absence",
            "LID-03": "not_applicable_closed_gate",
            "LID-04": "proxy_rejection_enforced",
            "LID-05": "not_applicable_closed_gate",
        }
        for requirement, disposition in dispositions.items():
            if f"- [x] **{requirement}**" not in requirements or f"| {requirement} | Phase 57 | Complete — `{disposition}` |" not in requirements:
                return {"R57-COMPAT"}
    return set()


def live_failures() -> set[str]:
    failures: set[str] = set()
    if any(not path.exists() for path in required_paths()):
        return {"R57-COMPAT"}
    failures.update(authority_failures())
    failures.update(source_failures())
    failures.update(compatibility_failures())
    failures.update(demo_failures())
    failures.update(ledger_failures())
    failures.update(inventory_failures())
    failures.update(evidence_failures())
    failures.update(validation_lifecycle_failures())
    return failures


def copy_fixture(destination: pathlib.Path) -> None:
    files = tuple(path for path in required_paths() if path.is_file())
    directories = (SOURCES, PRESETS)
    for directory in directories:
        target = destination / directory.relative_to(ROOT)
        shutil.copytree(directory, target, dirs_exist_ok=True)
    for source in files:
        target = destination / source.relative_to(ROOT)
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def replace_once(path: pathlib.Path, old: str, new: str) -> None:
    text = read_text(path)
    if text.count(old) != 1:
        raise AssertionError("mutation anchor is not unique")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def assert_mutation(root: pathlib.Path, threat: str, mutate) -> int:
    mutate()
    failures = live_failures()
    expected = RULES[threat]
    if expected not in failures:
        raise AssertionError(f"{threat} did not produce {expected}")
    return 1


def assert_file_mutation(
    relative_path: str,
    original: str,
    replacement: str,
    expected_rule: str,
) -> int:
    path = ROOT / relative_path
    baseline = read_text(path)
    if baseline.count(original) != 1:
        raise AssertionError("mutation anchor is not unique")
    path.write_text(baseline.replace(original, replacement, 1), encoding="utf-8")
    try:
        if expected_rule not in classified_live_failures():
            raise AssertionError("live mutation accepted")
    finally:
        path.write_text(baseline, encoding="utf-8")
    return 1


def assert_file_rules(
    relative_path: str,
    original: str,
    replacement: str,
    expected_rules: tuple[str, ...],
) -> int:
    path = ROOT / relative_path
    baseline = read_text(path)
    if baseline.count(original) != 1:
        raise AssertionError("mutation anchor is not unique")
    path.write_text(baseline.replace(original, replacement, 1), encoding="utf-8")
    try:
        failures = classified_live_failures()
        if not set(expected_rules).issubset(failures):
            raise AssertionError("live relation mutation accepted")
    finally:
        path.write_text(baseline, encoding="utf-8")
    return 1


def assert_added_file(path: pathlib.Path, contents: str, expected_rule: str) -> int:
    if path.exists():
        raise AssertionError("added-file fixture already exists")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(contents, encoding="utf-8")
    try:
        if expected_rule not in classified_live_failures():
            raise AssertionError("neutral-file mutation accepted")
    finally:
        path.unlink()
    return 1


def assert_added_file_rules(
    path: pathlib.Path,
    contents: str,
    expected_rules: tuple[str, ...],
) -> int:
    if path.exists():
        raise AssertionError("added-file fixture already exists")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(contents, encoding="utf-8")
    try:
        failures = classified_live_failures()
        if not set(expected_rules).issubset(failures):
            raise AssertionError("neutral-file relation mutation accepted")
    finally:
        path.unlink()
    return 1


def assert_clean_added_file(path: pathlib.Path, contents: str) -> int:
    if path.exists():
        raise AssertionError("clean control fixture already exists")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(contents, encoding="utf-8")
    try:
        if classified_live_failures():
            raise AssertionError("legitimate proxy-only control rejected")
    finally:
        path.unlink()
    return 1


def assert_sclera_surface_failures() -> int:
    cases = 0
    mutations = (
        (
            "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
            "    public var skinSmoothing: Float",
            "    public var scleraRednessReduction: Float\n    public var skinSmoothing: Float",
        ),
        (
            "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
            "        case skinSmoothing",
            "        case scleraRednessReduction\n        case skinSmoothing",
        ),
        (
            "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
            "        skinSmoothing: Float = 0,",
            "        scleraRednessReduction: Float = 0,\n        skinSmoothing: Float = 0,",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift",
            "    public static let productionAdmissionNames: [String] = []",
            '    public static let productionAdmissionNames = ["sclera_redness"]',
        ),
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift",
            "    package static let none = BeautyLocalRetouchAdmission(opaqueDemandCount: 0)",
            "    package static let scleraRednessReduction = BeautyLocalRetouchAdmission(opaqueDemandCount: 1)\n    package static let none = BeautyLocalRetouchAdmission(opaqueDemandCount: 0)",
        ),
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
            "struct BeautyRetainedMaskIteration",
            "struct ScleraRednessReductionProvider {}\n\nstruct BeautyRetainedMaskIteration",
        ),
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
            "        return .none",
            "        // scleraRednessReduction production admission\n        return BeautyLocalRetouchAdmission(opaqueDemandCount: 1)",
        ),
        (
            "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
            '        id: "skinWhitening_0p50",',
            '        id: "scleraRednessReduction_savedOutput",',
        ),
        (
            "BeautySDK/Sources/BeautyResources/Resources/Presets/natural.json",
            '  "parameters": {',
            '  "parameters": {\n    "ocularRednessReduction": 0.5,',
        ),
        (
            "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
            '  "presets": [',
            '  "scleraWhiteningResource": "model",\n  "presets": [',
        ),
        (
            "BeautySDK/Package.swift",
            '        .target(name: "BeautyCore"),',
            '        .target(name: "ConjunctivalRednessReductionModel"),\n        .target(name: "BeautyCore"),',
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
            "import Foundation",
            "import Foundation\n// bloodshotEyeCorrection network storage model route",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
            "    private var resetGeneration: UInt64 = 0",
            "    private var scleraRednessReductionRealtimeReset: UInt64 = 0\n    private var resetGeneration: UInt64 = 0",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
            "import CoreVideo",
            "import CoreVideo\n// eyeRednessReduction pixelBuffer route",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift",
            "    private let invocationLock = NSLock()",
            "    // opaque composition mechanics alias scleraRednessReduction\n    private let invocationLock = NSLock()",
        ),
        (
            "BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift",
            'unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)',
            'supported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free, controlID: .skinWhitening) // scleraRednessReduction',
        ),
    )
    for relative_path, original, replacement in mutations:
        cases += assert_file_mutation(
            relative_path, original, replacement, "R57-SCLERA",
        )

    neutral_families = (
        ("Direct.swift", "package var scleraRedness: Float = 0\n"),
        ("ConjunctivaDirect.swift", "package var conjunctivaRedness: Float = 0\n"),
        ("ConjunctivalDirect.swift", "package var conjunctivalRedness: Float = 0\n"),
        ("OcularDirect.swift", "package var ocularRedness: Float = 0\n"),
        ("EyeDirect.swift", "package var eyeRedness: Float = 0\n"),
        ("RedEyeDirect.swift", "package var redEye: Float = 0\n"),
        ("Canonical.swift", "package func scleraRednessReduction() {}\n"),
        ("EyeRed.swift", "package func eyeRednessReduction() {}\n"),
        ("RedEye.swift", "package func redEyeReduction() {}\n"),
        ("Conjunctiva.swift", "package func conjunctivaRednessReduction() {}\n"),
        ("Conjunctival.swift", "package func conjunctivalRednessReduction() {}\n"),
        ("Ocular.swift", "package func ocularRednessReduction() {}\n"),
        ("Bloodshot.swift", "package func bloodshotEyeCorrection() {}\n"),
        ("Whitening.swift", "package func scleraWhitening() {}\n"),
    )
    neutral_root = SOURCES / "NeutralPhase57"
    for filename, contents in neutral_families:
        cases += assert_added_file(neutral_root / filename, contents, "R57-SCLERA")

    alias_targets = (
        "skinWhitening", "brightness", "skinColor", "eyeHeight",
        "upperEyelidLift", "teethWhitening",
        "upperEyelidFullnessReduction", "opaqueCompositionMechanics",
    )
    for index, target in enumerate(alias_targets):
        cases += assert_added_file(
            neutral_root / f"Alias{index}.swift",
            f"package func scleraRednessReductionAlias() {{ _ = \"{target}\" }}\n",
            "R57-SCLERA",
        )
    return cases


def assert_eyelid_surface_failures() -> int:
    cases = 0
    mutations = (
        (
            "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
            "    public var skinSmoothing: Float",
            "    public var upperEyelidFullnessReduction: Float\n    public var skinSmoothing: Float",
        ),
        (
            "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
            "        case skinSmoothing",
            "        case upperEyelidFullnessReduction\n        case skinSmoothing",
        ),
        (
            "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
            "        skinSmoothing: Float = 0,",
            "        upperEyelidFullnessReduction: Float = 0,\n        skinSmoothing: Float = 0,",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift",
            "    public static let productionAdmissionNames: [String] = []",
            '    public static let productionAdmissionNames = ["upper_eyelid_fullness"]',
        ),
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift",
            "    package static let none = BeautyLocalRetouchAdmission(opaqueDemandCount: 0)",
            "    package static let upperEyelidFullnessReduction = BeautyLocalRetouchAdmission(opaqueDemandCount: 1)\n    package static let none = BeautyLocalRetouchAdmission(opaqueDemandCount: 0)",
        ),
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
            "struct BeautyRetainedMaskIteration",
            "struct UpperEyelidFullnessReductionProvider {}\n\nstruct BeautyRetainedMaskIteration",
        ),
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
            "        return .none",
            "        // lidFullnessReduction production admission\n        return BeautyLocalRetouchAdmission(opaqueDemandCount: 1)",
        ),
        (
            "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
            '        id: "skinWhitening_0p50",',
            '        id: "upperLidFullnessRemoval_savedOutput",',
        ),
        (
            "BeautySDK/Sources/BeautyResources/Resources/Presets/natural.json",
            '  "parameters": {',
            '  "parameters": {\n    "eyelidFatReduction": 0.5,',
        ),
        (
            "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
            '  "presets": [',
            '  "upperEyelidDefattingResource": "model",\n  "presets": [',
        ),
        (
            "BeautySDK/Package.swift",
            '        .target(name: "BeautyCore"),',
            '        .target(name: "LidFatReductionModel"),\n        .target(name: "BeautyCore"),',
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
            "import Foundation",
            "import Foundation\n// eyelidFullnessRemoval network storage model route",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
            "    private var resetGeneration: UInt64 = 0",
            "    private var removeUpperEyelidFatRealtimeReset: UInt64 = 0\n    private var resetGeneration: UInt64 = 0",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
            "import CoreVideo",
            "import CoreVideo\n// defatUpperEyelid pixelBuffer route",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift",
            "    private let invocationLock = NSLock()",
            "    // opaque composition scenario route upperLidFatRemoval\n    private let invocationLock = NSLock()",
        ),
        (
            "BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift",
            'unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)',
            'supported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free, controlID: .eyeHeight) // upperEyelidFullnessReduction',
        ),
    )
    for relative_path, original, replacement in mutations:
        cases += assert_file_mutation(
            relative_path, original, replacement, "R57-EYELID",
        )

    neutral_families = (
        ("UpperEyelidFullnessDirect.swift", "package var upperEyelidFullness: Float = 0\n"),
        ("UpperLidFullnessDirect.swift", "package var upperLidFullness: Float = 0\n"),
        ("EyelidFullnessDirect.swift", "package var eyelidFullness: Float = 0\n"),
        ("LidFullnessDirect.swift", "package var lidFullness: Float = 0\n"),
        ("UpperEyelidFatDirect.swift", "package var upperEyelidFat: Float = 0\n"),
        ("UpperLidFatDirect.swift", "package var upperLidFat: Float = 0\n"),
        ("EyelidFatDirect.swift", "package var eyelidFat: Float = 0\n"),
        ("LidFatDirect.swift", "package var lidFat: Float = 0\n"),
        ("Canonical.swift", "package func upperEyelidFullnessReduction() {}\n"),
        ("UpperLidFull.swift", "package func upperLidFullnessRemoval() {}\n"),
        ("EyelidFull.swift", "package func eyelidFullnessReduction() {}\n"),
        ("LidFull.swift", "package func lidFullnessRemoval() {}\n"),
        ("UpperEyelidFat.swift", "package func upperEyelidFatReduction() {}\n"),
        ("UpperLidFat.swift", "package func upperLidFatRemoval() {}\n"),
        ("EyelidFat.swift", "package func eyelidFatReduction() {}\n"),
        ("LidFat.swift", "package func lidFatRemoval() {}\n"),
        ("Remove.swift", "package func removeUpperEyelidFat() {}\n"),
        ("Defatting.swift", "package func upperEyelidDefatting() {}\n"),
        ("Defat.swift", "package func defatUpperEyelid() {}\n"),
    )
    neutral_root = SOURCES / "NeutralPhase57Eyelid"
    for filename, contents in neutral_families:
        cases += assert_added_file(neutral_root / filename, contents, "R57-EYELID")
    return cases


def assert_proxy_relation_failures() -> int:
    cases = 0
    expected = ("R57-EYELID", "R57-PROXY")
    actual_mutations = (
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
            "import BeautyCore",
            "import BeautyCore\n// upperEyelidFullnessReduction aliases eyeHeight",
        ),
        (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
            "import BeautyDetection",
            "import BeautyDetection\n// upperEyelidLift maps to lidFullnessRemoval",
        ),
        (
            "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift",
            "    private let invocationLock = NSLock()",
            "    // opaqueCompositionScenario evidence for upperEyelidFullnessReduction\n    private let invocationLock = NSLock()",
        ),
    )
    for relative_path, original, replacement in actual_mutations:
        cases += assert_file_rules(relative_path, original, replacement, expected)

    relation_targets = (
        "eyeHeight", "upperEyelidLift", "eyebrowYPosition", "browTranslation",
        "browMovement", "eyeAperture", "verticalEyeWarp", "interiorEyeWarp",
        "skinSmoothing", "globalSmoothing", "darkCircleRemoval",
        "eyeBagRemoval", "scleraRednessReduction", "teethWhitening",
        "opaqueCompositionScenario",
    )
    relation_forms = (
        "// assignment: {candidate} = {target}\n",
        "// forwarding: {candidate} forwards to {target}\n",
        "// comment: {target} implements {candidate}\n",
        "// mapping: {candidate} maps to {target}\n",
        "// route: {candidate} uses {target}\n",
        "// evidence: {target} proves {candidate}\n",
    )
    neutral_root = SOURCES / "NeutralPhase57Proxy"
    for target_index, target in enumerate(relation_targets):
        cases += assert_added_file_rules(
            neutral_root / f"CanonicalRelation{target_index}.swift",
            f"package let upperEyelidFullness = {target}\n",
            expected,
        )
    for identity_index, identity in enumerate(("去脂", "eyes.fat")):
        for target_index, target in enumerate(relation_targets):
            for form_index, form in enumerate(relation_forms):
                cases += assert_added_file_rules(
                    neutral_root / (
                        f"OwnedIdentity{identity_index}_{target_index}_{form_index}.swift"
                    ),
                    form.format(candidate=identity, target=target),
                    ("R57-PROXY",),
                )

    cases += assert_clean_added_file(
        neutral_root / "ProxyOnly.swift",
        "package struct ProxyOnly {\n"
        "  let eyeHeight: Float\n  let upperEyelidLift: Float\n"
        "  let eyebrowYPosition: Float\n  let browTranslation: Float\n"
        "  let eyeAperture: Float\n  let verticalEyeWarp: Float\n"
        "  let skinSmoothing: Float\n  let darkCircleRemoval: Float\n"
        "  let eyeBagRemoval: Float\n}\n",
    )
    return cases


def assert_demo_surface_failures() -> int:
    cases = 0
    fat = 'unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)'
    redness = 'unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)'
    mutations = (
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", fat, "", "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", fat, fat.replace("eyes.fat", "eyes.fat.renamed"), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", fat, fat.replace("去脂", "眼睑塑形"), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", fat, fat.replace("minus.circle", "eye"), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", fat, fat.replace(", badge: .free", ""), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", fat, 'supported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free, controlID: .eyeSize)', "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", redness, "", "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", redness, redness.replace("eyes.redness", "eyes.redness.renamed"), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", redness, redness.replace("祛红血丝", "眼白提亮"), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", redness, redness.replace("drop", "eye"), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", redness, redness.replace(", badge: .free", ""), "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", redness, 'supported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free, controlID: .brightness)', "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Panel/BeautyControlDescriptor.swift", "enum BeautyControlID: String, CaseIterable, Hashable, Sendable {\n    case skinSmoothing", "enum BeautyControlID: String, CaseIterable, Hashable, Sendable {\n    case upperEyelidFullnessReduction\n    case skinSmoothing", "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift", "        let range = selectedTool.controlID", "        let upperEyelidFullnessReduction = selectedTool.controlID\n        let range = selectedTool.controlID", "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift", "    case custom", "    case scleraRednessReduction\n    case custom", "R57-DEMO"),
        ("BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift", "    func reset(_ controlID: BeautyControlID) {", "    // eyes.fat reset mapping\n    func reset(_ controlID: BeautyControlID) {", "R57-DEMO"),
        ("BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift", "        XCTAssertFalse(fat.isSupported)", "        XCTAssertTrue(fat.isSupported)", "R57-DEMO"),
        ("BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift", "        XCTAssertFalse(redness.isSupported)\n        XCTAssertNil(redness.controlID)", "        XCTAssertFalse(redness.isSupported)\n        XCTAssertEqual(redness.controlID, .brightness)", "R57-DEMO"),
    )
    for index, mutation in enumerate(mutations):
        try:
            cases += assert_file_mutation(*mutation)
        except AssertionError as error:
            raise AssertionError(f"Demo mutation {index} failed closed-check") from error

    baseline = read_text(DEMO_SOURCE)
    fat_line = f"                {fat},"
    redness_line = f"                {redness},"
    if baseline.count(fat_line) != 1 or baseline.count(redness_line) != 1:
        raise AssertionError("Demo reorder anchors are not unique")
    reordered = baseline.replace(fat_line + "\n", "", 1)
    reordered = reordered.replace(redness_line, redness_line + "\n" + fat_line, 1)
    DEMO_SOURCE.write_text(reordered, encoding="utf-8")
    try:
        if "R57-DEMO" not in classified_live_failures():
            raise AssertionError("Demo row reorder accepted")
        cases += 1
    finally:
        DEMO_SOURCE.write_text(baseline, encoding="utf-8")

    neutral_demo = DEMO_ROOT / "NeutralPhase57Demo"
    neutral_routes = (
        ("FatID.swift", '("eyes.fat", BeautyControlID.eyeHeight)\n'),
        ("FatTitle.swift", '("去脂", BeautyControlID.upperEyelidLift)\n'),
        ("RednessID.swift", '("eyes.redness", BeautyControlID.brightness)\n'),
        ("RednessTitle.swift", '("祛红血丝", BeautyControlID.skinWhitening)\n'),
    )
    for filename, contents in neutral_routes:
        cases += assert_added_file(neutral_demo / filename, contents, "R57-DEMO")
    return cases


def assert_evidence_text_mutation(original: str, replacement: str, expected_rule: str) -> int:
    baseline = read_text(EVIDENCE)
    if baseline.count(original) != 1:
        raise AssertionError("evidence mutation anchor is not unique")
    EVIDENCE.write_text(baseline.replace(original, replacement, 1), encoding="utf-8")
    try:
        if expected_rule not in classified_live_failures():
            raise AssertionError("evidence mutation accepted")
    finally:
        EVIDENCE.write_text(baseline, encoding="utf-8")
    return 1


def assert_evidence_and_privacy_failures() -> int:
    cases = 0
    title = "# Phase 57 Closed Eye-Gates Evidence"
    baseline = read_text(EVIDENCE)
    is_draft = "status: draft" in baseline
    status_anchor = "status: draft" if is_draft else "status: validated"
    opposite_status = "status: validated" if is_draft else "status: draft"
    lifecycle_anchor = (
        "Final regression: pending" if is_draft else "## Final Automated Evidence"
    )
    lifecycle_replacement = (
        "Final regression: passed" if is_draft else "## Pending Final Automated Evidence"
    )
    structural = (
        (status_anchor, opposite_status, "R57-COMPAT"),
        (status_anchor, status_anchor.replace(":", "", 1), "R57-COMPAT"),
        (status_anchor, f"{status_anchor}\n{status_anchor}", "R57-COMPAT"),
        ("block_on: HIGH", "block_on HIGH", "R57-COMPAT"),
        ("## Immutable Decision Projections", "", "R57-COMPAT"),
        ("## Exact Invariants", "## Exact Invariants\n\n## Exact Invariants", "R57-COMPAT"),
        (lifecycle_anchor, lifecycle_replacement, "R57-COMPAT"),
        (title, title + "\n\nUpper-eyelid fullness reduction is implemented and shipped.", "R57-PRIVACY"),
        (title, title + "\n\nSclera redness reduction is production-ready.", "R57-PRIVACY"),
        (title, title + "\n\nSclera redness reduction is active in production.", "R57-PRIVACY"),
        (title, title + "\n\nSclera redness reduction is enabled.", "R57-PRIVACY"),
        (title, title + "\n\nUpper-eyelid fullness reduction is available.", "R57-PRIVACY"),
        (title, title + "\n\nUpper-eyelid fullness reduction is open.", "R57-PRIVACY"),
        (title, title + "\n\n| sclera_redness | open |", "R57-PRIVACY"),
        (title, title + "\n\n| upper_eyelid_fullness | enabled |", "R57-PRIVACY"),
        (
            "| `sclera_redness` | `closed` | `missing_genuine_positive`, `missing_genuine_negative` | `0 / 0 / 0 / 0 / 0` |",
            "| `sclera_redness` | `closed` | `missing_genuine_positive`, `missing_genuine_negative` | `0 / 0 / 0 / 0 / 0` |\n"
            "| `sclera_redness` | `open` | None | `1 / 1 / 1 / 0 / 1` |",
            "R57-PRIVACY",
        ),
        (
            "| `upper_eyelid_fullness` | `closed` | `missing_genuine_positive`, `missing_genuine_negative`, `non_warp_design_unqualified` | `0 / 0 / 0 / 0 / 0` |",
            "| `upper_eyelid_fullness` | `closed` | `missing_genuine_positive`, `missing_genuine_negative`, `non_warp_design_unqualified` | `0 / 0 / 0 / 0 / 0` |\n"
            "| `upper_eyelid_fullness` | `available` | None | `1 / 1 / 1 / 0 / 1` |",
            "R57-PRIVACY",
        ),
    )
    for index, (original, replacement, expected) in enumerate(structural):
        try:
            cases += assert_evidence_text_mutation(original, replacement, expected)
        except AssertionError as error:
            raise AssertionError(f"Evidence structural mutation {index} failed closed-check") from error

    sensitive_payloads = (
        "portrait_path: /Users/subject/portrait",
        "hash: " + "a" * 64,
        "grant: internal",
        "rights_record: internal",
        "reviewer: person",
        "image: portrait.png",
        "media: local",
        "eye: support",
        "pupil: 1,2",
        "iris: protected",
        "landmark: 1,2",
        "coordinate: 1,2",
        "mask: encoded",
        "vein_descriptor: raw",
        "pixel: 42",
        "digest: stable",
        "raw_match: source-line",
        "raw_error: scanner-detail",
        "freeform_payload: private",
    )
    for payload in sensitive_payloads:
        cases += assert_evidence_text_mutation(title, f"{title}\n\n{payload}", "R57-PRIVACY")

    sensitive_families = (
        "pupil coordinates were (12, 34)",
        "iris support was retained",
        "landmark points were observed",
        "mask bytes were captured",
        "pixel samples were retained",
        "reviewer identity was recorded",
        "raw scanner output was preserved",
        "portrait path was /private/tmp/subject",
        "output digest was captured",
        "vein descriptors were retained",
    )
    shapes = (
        "Observed {payload}.",
        "- Observed {payload}.",
        "> Observed {payload}.",
        "| private observation | {payload} |",
    )
    for family in sensitive_families:
        for shape in shapes:
            cases += assert_evidence_text_mutation(
                title,
                f"{title}\n\n{shape.format(payload=family)}",
                "R57-PRIVACY",
            )

    validated = baseline if not is_draft else (
        baseline.replace("status: draft", "status: validated", 1)
        .replace("## Pending Final Automated Evidence", "## Final Automated Evidence", 1)
        .replace("pending", "passed")
    )
    EVIDENCE.write_text(validated, encoding="utf-8")
    try:
        if evidence_failures():
            raise AssertionError("structurally valid final evidence rejected")
        cases += 1
        EVIDENCE.write_text(validated.replace("status: validated", "status: draft", 1), encoding="utf-8")
        if "R57-COMPAT" not in evidence_failures():
            raise AssertionError("final-to-draft lifecycle downgrade accepted")
        cases += 1
    finally:
        EVIDENCE.write_text(baseline, encoding="utf-8")

    emit_cases = (
        (set(), 0, "mode=live status=passed rules=none\n"),
        ({"R57-PRIVACY"}, 1, "mode=live status=blocked rules=R57-PRIVACY\n"),
        ({"private source match"}, 1, "mode=live status=blocked rules=R57-COMPAT\n"),
    )
    for failures, expected_code, expected_output in emit_cases:
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            actual_code = emit("live", failures)
        if actual_code != expected_code or output.getvalue() != expected_output:
            raise AssertionError("checker output escaped fixed rule allowlist")
        cases += 1
    return cases


def assert_ledger_surface_failures() -> int:
    mutations = (
        ("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", EXPECTED_LID_ROW, EXPECTED_LID_ROW.replace("future", "implemented"), "R57-LEDGER"),
        ("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", EXPECTED_SCLERA_ROW, EXPECTED_SCLERA_ROW.replace("future", "implemented"), "R57-LEDGER"),
        ("docs/meitu-function-blueprint/FEATURE_MATRIX.md", EXPECTED_MATRIX_ROW, EXPECTED_MATRIX_ROW.replace("| partial |", "| implemented |"), "R57-LEDGER"),
        ("docs/meitu-function-blueprint/FEATURE_MATRIX.md", "branch remains partial solely because the two retouch rows are future", "branch closes using sibling evidence", "R57-LEDGER"),
        ("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", "Needs local retouch/segmentation design; no cloud AI by default.", "Borrow teeth and sclera composition evidence.", "R57-LEDGER"),
        ("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", "| `眼睛` | 去脂 | future |", "| `眼睛` | 眼高 | future |", "R57-LEDGER"),
        ("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md", "Needs local color/segmentation retouch design.", "Borrow upper-eyelid evidence.", "R57-LEDGER"),
    )
    cases = 0
    for mutation in mutations:
        cases += assert_file_mutation(*mutation)
    return cases


def assert_missing_fixture(path: pathlib.Path, expected_rule: str) -> int:
    moved = path.with_name(f"{path.name}.missing")
    path.rename(moved)
    try:
        if expected_rule not in classified_live_failures():
            raise AssertionError("missing fixture accepted")
    finally:
        moved.rename(path)
    return 1


def assert_unreadable_fixture(path: pathlib.Path, expected_rule: str) -> int:
    moved = path.with_name(f"{path.name}.saved")
    path.rename(moved)
    path.mkdir()
    try:
        if expected_rule not in classified_live_failures():
            raise AssertionError("unreadable fixture accepted")
    finally:
        path.rmdir()
        moved.rename(path)
    return 1


def assert_compatibility_and_scanner_failures() -> int:
    evidence = read_text(EVIDENCE)
    evidence_status = "status: validated" if "status: validated" in evidence else "status: draft"
    opposite_status = "status: draft" if evidence_status == "status: validated" else "status: validated"
    mutations = (
        ("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift", "    public var skinSmoothing: Float", "    public var skinSmoothingRenamed: Float", "R57-COMPAT"),
        ("BeautySDK/Sources/BeautyResources/Resources/manifest.json", '"id": "natural"', '"id": "natural-renamed"', "R57-COMPAT"),
        ("BeautySDK/Sources/BeautyExampleRenderer/main.swift", 'id: "skinSmoothing_0p50"', 'id: "skinSmoothing_removed"', "R57-COMPAT"),
        ("BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift", "        return .none", "        return BeautyLocalRetouchAdmission(opaqueDemandCount: 0)", "R57-COMPAT"),
        ("BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift", "XCTAssertEqual(Mirror(reflecting: shippedDomains).children.count, 59)", "XCTAssertGreaterThanOrEqual(Mirror(reflecting: shippedDomains).children.count, 59)", "R57-COMPAT"),
        ("BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift", "testPhase57ClosedEyeRetouchGatesAddNoPresetKeyOrResource", "testPhase57WeakenedPresetInventory", "R57-COMPAT"),
        ("BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift", '"skinSmoothing_0p50", "eyeHeight_0p25", "upperEyelidLift_0p25"', '"skinSmoothing_0p50", "eyeHeight_0p25"', "R57-COMPAT"),
        ("BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift", "testPhase57ClosedEyeRetouchGatesKeepLiteralNoneAndStillEntriesInactive", "testPhase57WeakenedStillEntries", "R57-COMPAT"),
        (f".planning/phases/{PHASE_NAME}/57-VALIDATION.md", "| `57-03-02` | 2 |", "| `57-03-02-weakened` | 2 |", "R57-COMPAT"),
        (f".planning/phases/{PHASE_NAME}/57-CLOSED-EYE-GATES-EVIDENCE.md", evidence_status, opposite_status, "R57-COMPAT"),
    )
    cases = 0
    for mutation in mutations:
        cases += assert_file_mutation(*mutation)
    for path in (PARAMETERS, DECISIONS, EVIDENCE, VALIDATION):
        cases += assert_missing_fixture(path, "R57-COMPAT")
    cases += assert_unreadable_fixture(EVIDENCE, "R57-COMPAT")
    for code in (2, 127):
        try:
            classify_rg(code, "", "scanner failed")
        except ScannerFailure:
            cases += 1
        else:
            raise AssertionError("unclassified scanner return accepted")

    original = run_rg
    try:
        globals()["run_rg"] = lambda *_args, **_kwargs: (_ for _ in ()).throw(
            subprocess.SubprocessError("private scanner failure")
        )
        if classified_live_failures() != {"R57-AUTH", "R57-COMPAT"}:
            raise AssertionError("unclassified subprocess was not fail closed")
        cases += 1
    finally:
        globals()["run_rg"] = original
    return cases


def assert_decision_document(document: object) -> int:
    baseline = read_text(DECISIONS)
    DECISIONS.write_text(
        json.dumps(document, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    try:
        if "R57-AUTH" not in classified_live_failures():
            raise AssertionError("decision mutation accepted")
    finally:
        DECISIONS.write_text(baseline, encoding="utf-8")
    return 1


def decision_mutation_documents(document: dict[str, object]) -> tuple[object, ...]:
    mutations: list[object] = []

    def row_mutation(feature: str, key: str, value: object) -> None:
        mutation = copy.deepcopy(document)
        row = next(item for item in mutation["feature_decisions"] if item["feature"] == feature)
        row[key] = value
        mutations.append(mutation)

    for feature, expected in EXPECTED_DECISIONS.items():
        row_mutation(feature, "status", "eligible")
        row_mutation(feature, "status", "passed")
        row_mutation(feature, "reasons", expected["reasons"][:-1])
        row_mutation(feature, "reasons", [*expected["reasons"], "borrowed_sibling"])
        row_mutation(feature, "reasons", list(reversed(expected["reasons"])))
        row_mutation(feature, "reasons", "missing_genuine_positive")
        for key in ZERO_KEYS:
            row_mutation(feature, key, 1)
        row_mutation(feature, "eligible_count", False)
        row_mutation(feature, "status", ["closed"])

        renamed = copy.deepcopy(document)
        row = next(item for item in renamed["feature_decisions"] if item["feature"] == feature)
        row["feature"] = f"{feature}_v2"
        mutations.append(renamed)

        duplicate = copy.deepcopy(document)
        row = next(item for item in duplicate["feature_decisions"] if item["feature"] == feature)
        duplicate["feature_decisions"].append(copy.deepcopy(row))
        mutations.append(duplicate)

        missing = copy.deepcopy(document)
        missing["feature_decisions"] = [
            item for item in missing["feature_decisions"] if item["feature"] != feature
        ]
        mutations.append(missing)

        lookalike = copy.deepcopy(document)
        lookalike["feature_decisions"].append({
            **copy.deepcopy(expected),
            "feature": "ocular_redness" if feature == "sclera_redness" else "upper_lid_fat",
        })
        mutations.append(lookalike)

        missing_key = copy.deepcopy(document)
        row = next(item for item in missing_key["feature_decisions"] if item["feature"] == feature)
        del row["naturalness_weight"]
        mutations.append(missing_key)

        extra_key = copy.deepcopy(document)
        row = next(item for item in extra_key["feature_decisions"] if item["feature"] == feature)
        row["borrowed_count"] = 0
        mutations.append(extra_key)

        for key in ZERO_KEYS:
            aggregate_nonzero = copy.deepcopy(document)
            aggregate = next(
                item for item in aggregate_nonzero["aggregates"]
                if item["feature"] == feature
            )
            aggregate[key] = 1
            mutations.append(aggregate_nonzero)

        aggregate_extra = copy.deepcopy(document)
        aggregate = next(item for item in aggregate_extra["aggregates"] if item["feature"] == feature)
        aggregate["status"] = "closed"
        mutations.append(aggregate_extra)

    reordered = copy.deepcopy(document)
    reordered["feature_decisions"].reverse()
    mutations.append(reordered)
    aggregate_reordered = copy.deepcopy(document)
    aggregate_reordered["aggregates"].reverse()
    mutations.append(aggregate_reordered)
    borrowed = copy.deepcopy(document)
    sclera = next(item for item in borrowed["feature_decisions"] if item["feature"] == "sclera_redness")
    eyelid = next(item for item in borrowed["feature_decisions"] if item["feature"] == "upper_eyelid_fullness")
    sclera["reasons"] = eyelid["reasons"]
    mutations.append(borrowed)
    substituted = copy.deepcopy(document)
    substituted["feature_decisions"][1], substituted["feature_decisions"][2] = (
        substituted["feature_decisions"][2], substituted["feature_decisions"][1]
    )
    mutations.append(substituted)
    competing = copy.deepcopy(document)
    competing["feature_decisions"][0] = copy.deepcopy(EXPECTED_DECISIONS["sclera_redness"])
    mutations.append(competing)
    reviews = copy.deepcopy(document)
    reviews["reviews"] = [{"feature": "sclera_redness"}]
    mutations.append(reviews)
    top_level_extra = copy.deepcopy(document)
    top_level_extra["source"] = "competing"
    mutations.append(top_level_extra)
    wrong_schema = copy.deepcopy(document)
    wrong_schema["schema_version"] = True
    mutations.append(wrong_schema)
    wrong_rows = copy.deepcopy(document)
    wrong_rows["feature_decisions"] = {"sclera_redness": EXPECTED_DECISIONS["sclera_redness"]}
    mutations.append(wrong_rows)
    wrong_aggregates = copy.deepcopy(document)
    wrong_aggregates["aggregates"] = None
    mutations.append(wrong_aggregates)
    return tuple(mutations)


def assert_decision_input_failures() -> int:
    cases = 0
    baseline = read_text(DECISIONS)
    document = json.loads(baseline)
    for mutation in decision_mutation_documents(document):
        cases += assert_decision_document(mutation)

    DECISIONS.write_text("{malformed", encoding="utf-8")
    try:
        if authority_failures() != {"R57-AUTH"}:
            raise AssertionError("malformed decision input accepted")
        cases += 1
    finally:
        DECISIONS.write_text(baseline, encoding="utf-8")

    saved = DECISIONS.with_suffix(".json.saved")
    DECISIONS.rename(saved)
    try:
        if "R57-COMPAT" not in classified_live_failures():
            raise AssertionError("missing decision fixture accepted")
        cases += 1
    finally:
        saved.rename(DECISIONS)

    DECISIONS.rename(saved)
    DECISIONS.mkdir()
    try:
        if "R57-AUTH" not in classified_live_failures():
            raise AssertionError("unreadable decision fixture accepted")
        cases += 1
    finally:
        DECISIONS.rmdir()
        saved.rename(DECISIONS)

    try:
        classify_rg(2, "", "scanner failed")
    except ScannerFailure:
        cases += 1
    else:
        raise AssertionError("unclassified scanner outcome accepted")

    original = authority_failures
    try:
        globals()["authority_failures"] = lambda: (_ for _ in ()).throw(ValueError("private"))
        if classified_live_failures() != {"R57-AUTH", "R57-COMPAT"}:
            raise AssertionError("parser exception was not classified")
        cases += 1
    finally:
        globals()["authority_failures"] = original
    return cases


def self_test(only: str | None) -> int:
    selected = THREAT_IDS if only is None else (only,)
    original_root = ROOT
    total = 0
    try:
        for threat in selected:
            with tempfile.TemporaryDirectory(prefix="phase57-eye-gate-") as temporary:
                fixture = pathlib.Path(temporary)
                configure_root(original_root)
                copy_fixture(fixture)
                configure_root(fixture)
                if live_failures():
                    raise AssertionError("clean fixture failed")

                if threat == "T-57-01":
                    total += assert_decision_input_failures()
                elif threat == "T-57-02":
                    total += assert_sclera_surface_failures()
                elif threat == "T-57-03":
                    total += assert_eyelid_surface_failures()
                elif threat == "T-57-04":
                    total += assert_proxy_relation_failures()
                elif threat == "T-57-05":
                    total += assert_demo_surface_failures()
                elif threat == "T-57-06":
                    total += assert_evidence_and_privacy_failures()
                elif threat == "T-57-07":
                    total += assert_ledger_surface_failures()
                elif threat == "T-57-08":
                    total += assert_compatibility_and_scanner_failures()
    finally:
        configure_root(original_root)
    print(f"self-test status=passed threats={len(selected)} cases={total}")
    return 0


def emit(mode: str, failures: set[str]) -> int:
    allowed = set(RULES.values())
    if not failures.issubset(allowed):
        failures = {"R57-COMPAT"}
    if failures:
        print(f"mode={mode} status=blocked rules={','.join(sorted(failures))}")
        return 1
    print(f"mode={mode} status=passed rules=none")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=pathlib.Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--only", choices=THREAT_IDS)
    parser.add_argument("--decision", action="store_true")
    parser.add_argument("--sclera", action="store_true")
    parser.add_argument("--eyelid", action="store_true")
    arguments = parser.parse_args()
    if arguments.root is not None:
        configure_root(arguments.root)
    if arguments.only is not None and not arguments.self_test:
        parser.error("--only requires --self-test")
    if arguments.self_test:
        return self_test(arguments.only)
    if arguments.decision:
        return emit("decision", authority_failures())
    if arguments.sclera:
        return emit("sclera", source_failures() & {"R57-SCLERA"})
    if arguments.eyelid:
        return emit("eyelid", source_failures() & {"R57-EYELID", "R57-PROXY"})
    return emit("live", live_failures())


if __name__ == "__main__":
    sys.exit(main())
