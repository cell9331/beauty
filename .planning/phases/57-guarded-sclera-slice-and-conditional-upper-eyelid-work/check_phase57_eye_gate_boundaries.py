#!/usr/bin/env python3
"""Fail-closed Phase 57 eye-retouch absence and proxy-boundary checker."""

from __future__ import annotations

import argparse
import copy
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
SCLERA_PATTERN = (
    r"(?i)\b(?:sclera(?:RednessReduction|_redness|Whitening|White|Brightness)|"
    r"whitenSclera|eyeRednessReduction|redEyeReduction|"
    r"conjunctiva(?:l)?(?:RednessReduction|Whitening)|"
    r"ocular(?:RednessReduction|Whitening)|"
    r"bloodshot(?:Reduction|EyeCorrection))[A-Za-z0-9_]*\b"
)
SCLERA_ALIAS_PATTERN = (
    r"(?is)(?:sclera(?:RednessReduction|_redness|Whitening|White|Brightness)|"
    r"eyeRednessReduction|redEyeReduction|conjunctiva(?:l)?(?:RednessReduction|Whitening)|"
    r"ocular(?:RednessReduction|Whitening)|bloodshot(?:Reduction|EyeCorrection))"
    r".{0,160}(?:skinWhitening|brightness|skinColor|eyeHeight|upperEyelidLift|"
    r"teethWhitening|upperEyelidFullnessReduction|opaque|composition|mechanics)|"
    r"(?:skinWhitening|brightness|skinColor|eyeHeight|upperEyelidLift|teethWhitening|"
    r"upperEyelidFullnessReduction|opaque|composition|mechanics).{0,160}"
    r"(?:sclera(?:RednessReduction|_redness|Whitening|White|Brightness)|"
    r"eyeRednessReduction|redEyeReduction|conjunctiva(?:l)?(?:RednessReduction|Whitening)|"
    r"ocular(?:RednessReduction|Whitening)|bloodshot(?:Reduction|EyeCorrection))"
)
EYELID_PATTERN = (
    r"(?i)\b(?:upperEyelidFullness(?:Reduction|Removal)|"
    r"upperLidFullness(?:Reduction|Removal)|"
    r"eyelidFullness(?:Reduction|Removal)|lidFullness(?:Reduction|Removal)|"
    r"upperEyelidFat(?:Reduction|Removal)|upperLidFat(?:Reduction|Removal)|"
    r"eyelidFat(?:Reduction|Removal)|lidFat(?:Reduction|Removal)|"
    r"remove(?:Upper)?EyelidFat|removeUpperLidFat|removeLidFat|"
    r"(?:upperEyelid|upperLid|eyelid|lid)Defatting|"
    r"defat(?:Upper)?Eyelid|defatUpperLid|defatLid|"
    r"upper_eyelid_fullness|upper_lid_fullness|eyelid_fat|lid_fat)"
    r"[A-Za-z0-9_]*\b"
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


def configure_root(root: pathlib.Path) -> None:
    global ROOT, PHASE, PACKAGE, SOURCES, PARAMETERS, MANIFEST, PRESETS, RENDERER
    global RESOLVER, ADMISSION, ENGINE, TESTING_SUPPORT, DEMO_ROOT
    global PARAMETER_TEST, RESOURCE_TEST, RENDERER_TEST, FOUNDATION_TEST
    global DEMO_SOURCE, DEMO_CONTROL, DEMO_PANEL, DEMO_STORE, DEMO_TEST
    global FEATURE_MATRIX, SHAPE_LEDGER, DECISIONS, INVENTORY

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
    DECISIONS = ROOT / ".planning" / "phases" / "54-rights-approved-evidence-and-eligibility-decisions" / "54-EVIDENCE-DECISIONS.json"
    INVENTORY = PHASE / "57-THREAT-INVENTORY.json"


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
        DECISIONS, INVENTORY,
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

    candidate = f"(?:{SCLERA_PATTERN.replace('(?i)', '')}|{EYELID_PATTERN.replace('(?i)', '')})"
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
        resolver = " ".join(read_text(RESOLVER).split())
        preset_names = tuple(sorted(path.name for path in PRESETS.glob("*.json")))
    except (OSError, UnicodeError):
        return {"R57-COMPAT"}
    if len(extract_coding_keys(parameters)) != 59:
        return {"R57-COMPAT"}
    if len(expected_renderer_ids(renderer_test)) != 72 or preset_names != EXPECTED_PRESETS:
        return {"R57-COMPAT"}
    if "return .none" not in resolver:
        return {"R57-COMPAT"}
    required_anchors = (
        (parameter_test, "testPhase57ClosedEyeRetouchGatesKeepPublicAndCodableSurfaceExact"),
        (resource_test, "testPhase57ClosedEyeRetouchGatesAddNoPresetKeyOrResource"),
        (renderer_test, "testPhase57ClosedEyeRetouchGatesKeepRendererAndSavedOutputSurfaceExact"),
        (foundation_test, "testPhase57ClosedEyeRetouchGatesKeepLiteralNoneAndStillEntriesInactive"),
        (foundation_test, "testPhase57PixelBufferResetAndOpaqueMechanicsStayOutsideEyeCandidates"),
    )
    return {"R57-COMPAT"} if any(anchor not in text for text, anchor in required_anchors) else set()


def demo_failures() -> set[str]:
    try:
        source = read_text(DEMO_SOURCE)
        boundary = "\n".join(read_text(path) for path in (DEMO_CONTROL, DEMO_PANEL, DEMO_STORE))
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
    if "testPhase57ClosedEyeRetouchGatesPreserveDisabledRowsAndProxyIndependence" not in test:
        return {"R57-DEMO"}
    if re.search(SCLERA_PATTERN, boundary) or re.search(EYELID_PATTERN, boundary):
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
        "package let upperEyelidFullnessReduction = {target}\n",
        "// {target} aliases upperEyelidFullnessReduction\n",
        "package func upperEyelidFullnessReduction() {{ _ = {target} }}\n",
        "// route upperEyelidFullnessReduction maps to {target}\n",
        "// evidence: {target} proves upperEyelidFullnessReduction\n",
    )
    neutral_root = SOURCES / "NeutralPhase57Proxy"
    for index, target in enumerate(relation_targets):
        form = relation_forms[index % len(relation_forms)]
        cases += assert_added_file_rules(
            neutral_root / f"Relation{index}.swift",
            form.format(target=target),
            expected,
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
                    total += assert_mutation(fixture, threat, lambda: replace_once(DEMO_SOURCE, 'unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)', 'supported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free, controlID: .eyeSize)'))
                elif threat == "T-57-06":
                    document = read_json(INVENTORY)
                    document["portrait_path"] = "redacted"
                    total += assert_mutation(fixture, threat, lambda: INVENTORY.write_text(json.dumps(document), encoding="utf-8"))
                elif threat == "T-57-07":
                    total += assert_mutation(fixture, threat, lambda: replace_once(SHAPE_LEDGER, EXPECTED_LID_ROW, EXPECTED_LID_ROW.replace("future", "implemented")))
                elif threat == "T-57-08":
                    missing = PARAMETERS
                    total += assert_mutation(fixture, threat, missing.unlink)
                    try:
                        classify_rg(2, "", "scanner failed")
                    except ScannerFailure:
                        total += 1
                    else:
                        raise AssertionError("scanner failure was not classified")
    finally:
        configure_root(original_root)
    print(f"self-test status=passed threats={len(selected)} cases={total}")
    return 0


def emit(mode: str, failures: set[str]) -> int:
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
