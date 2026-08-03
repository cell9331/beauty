#!/usr/bin/env python3
"""Fail-closed Phase 56 closed-teeth, privacy, Demo, and compatibility checker."""

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
PHASE_NAME = "56-independent-teeth-whitening-slice"
THREAT_IDS = tuple(f"T-56-{index:02d}" for index in range(1, 8))
CANDIDATE_NAMES = (
    "teethWhitening",
    "teethWhite",
    "toothWhitening",
    "teethBrightness",
)
EXPECTED_PRESETS = (
    "natural",
    "clear",
    "refined",
    "male-natural",
    "id-photo-natural",
)
DECISION_KEYS = (
    "feature",
    "status",
    "reasons",
    "eligible_count",
    "reviewed_count",
    "accepted_count",
    "rejected_count",
    "naturalness_weight",
)
ZERO_VALUE_KEYS = (
    "eligible_count",
    "reviewed_count",
    "accepted_count",
    "rejected_count",
    "naturalness_weight",
)
EXPECTED_TEETH_DECISION = {
    "feature": "teeth_whitening",
    "status": "closed",
    "reasons": ["missing_genuine_positive", "missing_genuine_negative"],
    "eligible_count": 0,
    "reviewed_count": 0,
    "accepted_count": 0,
    "rejected_count": 0,
    "naturalness_weight": 0,
}


def configure_root(root: pathlib.Path) -> None:
    global ROOT, PHASE, PACKAGE, SOURCES, PARAMETERS, MANIFEST, PRESETS, RENDERER
    global RESOLVER, ADMISSION, ENGINE, TESTING_SUPPORT, PARAMETER_TEST
    global RESOURCE_TEST, RENDERER_TEST, FOUNDATION_TEST, DEMO_SOURCE, DEMO_CATEGORY
    global DEMO_CONTROL, DEMO_PANEL, DEMO_TEST, FEATURE_MATRIX, SHAPE_LEDGER
    global DECISIONS, INVENTORY

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
    DEMO_CATEGORY = ROOT / "BeautyDemo" / "BeautyDemo" / "Panel" / "BeautyCategoryModels.swift"
    DEMO_CONTROL = ROOT / "BeautyDemo" / "BeautyDemo" / "Panel" / "BeautyControlDescriptor.swift"
    DEMO_PANEL = ROOT / "BeautyDemo" / "BeautyDemo" / "Editor" / "MeituEditorToolPanelView.swift"
    DEMO_TEST = ROOT / "BeautyDemo" / "BeautyDemoTests" / "BeautyDemoViewStateTests.swift"
    FEATURE_MATRIX = ROOT / "docs" / "meitu-function-blueprint" / "FEATURE_MATRIX.md"
    SHAPE_LEDGER = ROOT / "docs" / "meitu-function-blueprint" / "SHAPE_FEATURE_LEDGER.md"
    DECISIONS = ROOT / ".planning" / "phases" / "54-rights-approved-evidence-and-eligibility-decisions" / "54-EVIDENCE-DECISIONS.json"
    INVENTORY = PHASE / "56-THREAT-INVENTORY.json"


configure_root(ROOT)


class ScannerFailure(RuntimeError):
    """An external scanner outcome was neither a match nor a clean result."""


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
        ("T-56-01", ["Spoofing", "Tampering"], ["exact_phase54_teeth_authority", "closed_reasons_and_zero_counts"]),
        ("T-56-02", ["Elevation of Privilege", "Tampering"], ["no_public_spi_or_codable_teeth_surface", "no_production_provider_renderer_or_preset_route"]),
        ("T-56-03", ["Elevation of Privilege", "Tampering"], ["literal_empty_production_admission", "no_alias_or_inert_route"]),
        ("T-56-04", ["Tampering"], ["exact_disabled_demo_taxonomy", "no_control_slider_processor_or_reset_mapping"]),
        ("T-56-05", ["Information Disclosure"], ["fixed_rule_only_checker_output", "no_sensitive_portrait_support_or_review_payload"]),
        ("T-56-06", ["Tampering", "Repudiation"], ["exact_future_teeth_ledger", "exact_partial_lips_branch_without_sibling_borrowing"]),
        ("T-56-07", ["Tampering", "Denial of Service"], ["exact_59_5_72_compatibility", "missing_parse_and_scanner_fail_closed"]),
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
                "gates": gates,
            }
            for threat_id, stride, gates in rows
        ],
    }


def required_paths() -> tuple[pathlib.Path, ...]:
    return (
        PACKAGE, PARAMETERS, MANIFEST, PRESETS, RENDERER, RESOLVER, ADMISSION,
        ENGINE, TESTING_SUPPORT, PARAMETER_TEST, RESOURCE_TEST, RENDERER_TEST,
        FOUNDATION_TEST, DEMO_SOURCE, DEMO_CATEGORY, DEMO_CONTROL, DEMO_PANEL,
        DEMO_TEST, FEATURE_MATRIX, SHAPE_LEDGER, DECISIONS, INVENTORY,
    )


def read_json(path: pathlib.Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def extract_coding_keys(text: str) -> tuple[str, ...]:
    match = re.search(r"enum CodingKeys[^\{]*\{(.*?)\n\s*\}", text, re.DOTALL)
    if match is None:
        return ()
    return tuple(re.findall(r"^\s*case\s+([A-Za-z][A-Za-z0-9]*)\s*$", match.group(1), re.MULTILINE))


def expected_renderer_ids(test_text: str) -> tuple[str, ...]:
    match = re.search(
        r"expectedRendererCaseIDs\s*=\s*\[(.*?)\n\s*\]",
        test_text,
        re.DOTALL,
    )
    if match is None:
        return ()
    return tuple(re.findall(r'"([^"]+)"', match.group(1)))


def privacy_inventory_failure(document: object) -> bool:
    forbidden = re.compile(
        r"portrait|filename|filepath|path|sha|hash|grant|rights|reviewer|"
        r"landmark|coordinate|mask|pixel|digest|raw.?error|source.?match",
        re.IGNORECASE,
    )

    def contains_forbidden_key(value: object) -> bool:
        if isinstance(value, dict):
            return any(forbidden.search(str(key)) or contains_forbidden_key(item) for key, item in value.items())
        if isinstance(value, list):
            return any(contains_forbidden_key(item) for item in value)
        return False

    return contains_forbidden_key(document)


def decision_failures() -> set[str]:
    try:
        document = read_json(DECISIONS)
    except (OSError, json.JSONDecodeError, UnicodeError):
        return {"R56-GATE"}

    if not isinstance(document, dict):
        return {"R56-GATE"}
    rows = document.get("feature_decisions")
    if not isinstance(rows, list):
        return {"R56-GATE"}

    exact_rows = [
        row for row in rows
        if isinstance(row, dict) and row.get("feature") == "teeth_whitening"
    ]
    teeth_like_rows = [
        row for row in rows
        if isinstance(row, dict)
        and isinstance(row.get("feature"), str)
        and re.search(r"teeth|tooth", row["feature"], re.IGNORECASE)
    ]
    if len(exact_rows) != 1 or teeth_like_rows != exact_rows:
        return {"R56-GATE"}

    row = exact_rows[0]
    if tuple(row) != DECISION_KEYS:
        return {"R56-GATE"}
    if row != EXPECTED_TEETH_DECISION:
        return {"R56-GATE"}
    if type(row["status"]) is not str:
        return {"R56-GATE"}
    if (
        type(row["reasons"]) is not list
        or any(type(reason) is not str for reason in row["reasons"])
        or any(type(row[key]) is not int for key in ZERO_VALUE_KEYS)
    ):
        return {"R56-GATE"}
    return set()


def gate_failures() -> set[str]:
    return decision_failures()


def compatibility_failures() -> set[str]:
    failures: set[str] = set()
    parameter_text = PARAMETERS.read_text(encoding="utf-8")
    stored = tuple(re.findall(r"^\s*public var\s+([A-Za-z][A-Za-z0-9]*)\s*:", parameter_text, re.MULTILINE))
    if len(stored) != 59 or extract_coding_keys(parameter_text) != stored or stored.count("filterId") != 1:
        failures.add("R56-COMPATIBILITY")

    manifest = read_json(MANIFEST)
    preset_ids = tuple(row.get("id") for row in manifest.get("presets", []))
    preset_files = tuple(sorted(path.name for path in PRESETS.glob("*.json")))
    if preset_ids != EXPECTED_PRESETS or preset_files != tuple(sorted(f"{item}.json" for item in EXPECTED_PRESETS)):
        failures.add("R56-COMPATIBILITY")

    expected_ids = expected_renderer_ids(RENDERER_TEST.read_text(encoding="utf-8"))
    renderer_ids = tuple(re.findall(r'\bid:\s*"([^"]+)"', RENDERER.read_text(encoding="utf-8")))
    if len(expected_ids) != 72 or len(set(expected_ids)) != 72 or renderer_ids != expected_ids:
        failures.add("R56-COMPATIBILITY")
    return failures


def production_failures() -> set[str]:
    failures: set[str] = set()
    pattern = "|".join(map(re.escape, CANDIDATE_NAMES))
    if run_rg(pattern, (SOURCES,)) == "match":
        failures.add("R56-PUBLIC")

    resolver_text = RESOLVER.read_text(encoding="utf-8")
    admission_text = ADMISSION.read_text(encoding="utf-8")
    if re.search(
        r"localRetouchAdmission\s*\(\s*parameters:[^\)]*\)[^{]*\{\s*"
        r"_\s*=\s*parameters\s*return\s+\.none\s*\}",
        resolver_text,
        re.DOTALL,
    ) is None:
        failures.add("R56-ADMISSION")
    if "opaqueDemandCount: 0" not in admission_text or "opaqueDemandCount == 0" not in admission_text:
        failures.add("R56-ADMISSION")

    required_test_anchors = {
        PARAMETER_TEST: "testPhase56ClosedTeethGateKeepsPublicAndCodableSurfaceExact",
        RESOURCE_TEST: "testPhase56ClosedTeethGateAddsNoPresetKeyOrResource",
        RENDERER_TEST: "testPhase56ClosedTeethGateKeepsRendererAndSavedOutputSurfaceExact",
        FOUNDATION_TEST: "testPhase56ClosedTeethGateKeepsLiteralNoneAndBothStillEntriesInactive",
    }
    if any(anchor not in path.read_text(encoding="utf-8") for path, anchor in required_test_anchors.items()):
        failures.add("R56-SPECS")
    if "productionAdmissionNames: [String] = []" not in TESTING_SUPPORT.read_text(encoding="utf-8"):
        failures.add("R56-ADMISSION")
    return failures


def demo_failures() -> set[str]:
    failures: set[str] = set()
    demo_text = DEMO_SOURCE.read_text(encoding="utf-8")
    expected_row = 'unsupported("lips.teeth", title: "白牙", icon: "sparkles")'
    if demo_text.count(expected_row) != 1 or re.search(r'\bsupported\("lips\.teeth"', demo_text):
        failures.add("R56-DEMO")
    if "testPhase56ClosedTeethGatePreservesDisabledTaxonomyWithoutControlOrResetRoute" not in DEMO_TEST.read_text(encoding="utf-8"):
        failures.add("R56-DEMO")

    category_text = DEMO_CATEGORY.read_text(encoding="utf-8")
    if not re.search(
        r"id:\s*\.teeth,\s*title:\s*\"Teeth\",\s*availability:\s*\.disabled\(\s*"
        r"badge:\s*\"Not in v1\",\s*reason:\s*\"Teeth whitening is not included in v1\.\"",
        category_text,
        re.DOTALL,
    ):
        failures.add("R56-DEMO")

    control_text = DEMO_CONTROL.read_text(encoding="utf-8")
    panel_text = DEMO_PANEL.read_text(encoding="utf-8")
    if any(name in control_text + panel_text for name in CANDIDATE_NAMES):
        failures.add("R56-DEMO")
    return failures


def ledger_failures() -> set[str]:
    failures: set[str] = set()
    matrix = FEATURE_MATRIX.read_text(encoding="utf-8")
    ledger = SHAPE_LEDGER.read_text(encoding="utf-8")
    if (
        "| Beauty shaping | 嘴唇 | partial |" not in matrix
        or "the branch remains partial solely because `白牙` is future" not in matrix
        or "| `嘴唇` | 白牙 | future | None. |" not in ledger
    ):
        failures.add("R56-LEDGER")
    return failures


def live_failures() -> set[str]:
    if any(not path.exists() for path in required_paths()):
        return {"R56-REQUIRED"}

    failures: set[str] = set()
    try:
        inventory = read_json(INVENTORY)
    except (OSError, json.JSONDecodeError):
        return {"R56-INVENTORY"}
    if inventory != expected_inventory():
        failures.add("R56-INVENTORY")
    if privacy_inventory_failure(inventory):
        failures.add("R56-PRIVACY")

    failures.update(gate_failures())
    failures.update(compatibility_failures())
    failures.update(production_failures())
    failures.update(demo_failures())
    failures.update(ledger_failures())
    return failures


def copy_live_fixture(source_root: pathlib.Path, destination_root: pathlib.Path) -> None:
    shutil.copytree(source_root / "BeautySDK" / "Sources", destination_root / "BeautySDK" / "Sources")
    shutil.copy2(source_root / "BeautySDK" / "Package.swift", destination_root / "BeautySDK" / "Package.swift")
    for relative in (
        "BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift",
        "BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift",
        "BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift",
        "BeautySDK/Tests/BeautyResourcesTests/BeautyResourceCatalogTests.swift",
        "BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift",
    ):
        destination = destination_root / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_root / relative, destination)
    shutil.copytree(source_root / "BeautyDemo" / "BeautyDemo", destination_root / "BeautyDemo" / "BeautyDemo")
    for relative in (
        "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
        "docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md",
        ".planning/phases/54-rights-approved-evidence-and-eligibility-decisions/54-EVIDENCE-DECISIONS.json",
        f".planning/phases/{PHASE_NAME}/56-THREAT-INVENTORY.json",
    ):
        destination = destination_root / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source_root / relative, destination)


def assert_mutation(
    fixture_root: pathlib.Path,
    relative_path: str,
    original: str,
    replacement: str,
    expected_rule: str,
) -> None:
    path = fixture_root / relative_path
    baseline = path.read_text(encoding="utf-8")
    if original not in baseline:
        raise AssertionError("mutation anchor absent")
    path.write_text(baseline.replace(original, replacement, 1), encoding="utf-8")
    try:
        if expected_rule not in live_failures():
            raise AssertionError("live mutation accepted")
    finally:
        path.write_text(baseline, encoding="utf-8")


def assert_decision_document(document: object, expected_rule: str = "R56-GATE") -> None:
    baseline = DECISIONS.read_text(encoding="utf-8")
    DECISIONS.write_text(json.dumps(document, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    try:
        if expected_rule not in live_failures():
            raise AssertionError("decision mutation accepted")
    finally:
        DECISIONS.write_text(baseline, encoding="utf-8")


def decision_mutation_documents(document: dict[str, object]) -> tuple[dict[str, object], ...]:
    mutations: list[dict[str, object]] = []

    def append_row_mutation(key: str, value: object) -> None:
        mutation = copy.deepcopy(document)
        mutation["feature_decisions"][0][key] = value
        mutations.append(mutation)

    append_row_mutation("status", "eligible")
    append_row_mutation("status", "passed")
    append_row_mutation("reasons", ["missing_genuine_negative"])
    append_row_mutation("reasons", ["missing_genuine_positive"])
    append_row_mutation("reasons", [*EXPECTED_TEETH_DECISION["reasons"], "borrowed_sibling"])
    append_row_mutation("reasons", list(reversed(EXPECTED_TEETH_DECISION["reasons"])))
    for key in ZERO_VALUE_KEYS:
        append_row_mutation(key, 1)

    renamed = copy.deepcopy(document)
    renamed["feature_decisions"][0]["feature"] = "teeth_whitening_v2"
    mutations.append(renamed)
    duplicate = copy.deepcopy(document)
    duplicate["feature_decisions"].append(copy.deepcopy(EXPECTED_TEETH_DECISION))
    mutations.append(duplicate)
    deleted = copy.deepcopy(document)
    del deleted["feature_decisions"][0]
    mutations.append(deleted)
    extra = copy.deepcopy(document)
    extra["feature_decisions"].append({**EXPECTED_TEETH_DECISION, "feature": "tooth_whitening"})
    mutations.append(extra)
    missing_key = copy.deepcopy(document)
    del missing_key["feature_decisions"][0]["naturalness_weight"]
    mutations.append(missing_key)
    extra_key = copy.deepcopy(document)
    extra_key["feature_decisions"][0]["candidate_count"] = 0
    mutations.append(extra_key)
    wrong_status_type = copy.deepcopy(document)
    wrong_status_type["feature_decisions"][0]["status"] = ["closed"]
    mutations.append(wrong_status_type)
    wrong_reasons_type = copy.deepcopy(document)
    wrong_reasons_type["feature_decisions"][0]["reasons"] = "missing_genuine_positive"
    mutations.append(wrong_reasons_type)
    wrong_count_type = copy.deepcopy(document)
    wrong_count_type["feature_decisions"][0]["eligible_count"] = False
    mutations.append(wrong_count_type)
    wrong_row_shape = copy.deepcopy(document)
    wrong_row_shape["feature_decisions"][0] = ["teeth_whitening"]
    mutations.append(wrong_row_shape)
    wrong_collection_shape = copy.deepcopy(document)
    wrong_collection_shape["feature_decisions"] = {"teeth_whitening": EXPECTED_TEETH_DECISION}
    mutations.append(wrong_collection_shape)
    return tuple(mutations)


def assert_decision_input_failures() -> int:
    cases = 0
    baseline = DECISIONS.read_text(encoding="utf-8")
    document = json.loads(baseline)
    for mutation in decision_mutation_documents(document):
        assert_decision_document(mutation)
        cases += 1

    DECISIONS.write_text("{malformed", encoding="utf-8")
    try:
        assert live_failures() == {"R56-GATE"}
        cases += 1
    finally:
        DECISIONS.write_text(baseline, encoding="utf-8")

    missing = DECISIONS.with_suffix(".json.missing")
    DECISIONS.rename(missing)
    try:
        assert live_failures() == {"R56-REQUIRED"}
        cases += 1
    finally:
        missing.rename(DECISIONS)

    unreadable = DECISIONS.with_suffix(".json.saved")
    DECISIONS.rename(unreadable)
    DECISIONS.mkdir()
    try:
        assert live_failures() == {"R56-GATE"}
        cases += 1
    finally:
        DECISIONS.rmdir()
        unreadable.rename(DECISIONS)
    return cases


def self_test(only: str | None) -> int:
    original_root = ROOT
    cases = 0
    assert classify_rg(0, "match\n", "") == "match"
    assert classify_rg(1, "", "") == "clean"
    cases += 2
    for code in (2, 127):
        try:
            classify_rg(code, "", "scanner failure")
        except ScannerFailure:
            cases += 1
        else:
            raise AssertionError("unclassified scanner accepted")

    baseline_inventory = expected_inventory()
    assert baseline_inventory["security_standard"] == "OWASP ASVS Level 1"
    assert baseline_inventory["block_on"] == "HIGH"
    cases += 1
    for index, threat_id in enumerate(THREAT_IDS):
        mutation = copy.deepcopy(baseline_inventory)
        mutation["threats"][index]["gates"] = mutation["threats"][index]["gates"][:-1]
        assert mutation != baseline_inventory, threat_id
        cases += 1

    mutations = {
        "T-56-02": (
            "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift",
            "public var skinSmoothing: Float", "public var teethWhitening: Float\n    public var skinSmoothing: Float", "R56-PUBLIC",
        ),
        "T-56-03": (
            "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift",
            "return .none", "return BeautyLocalRetouchAdmission(opaqueDemandCount: 1)", "R56-ADMISSION",
        ),
        "T-56-04": (
            "BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift",
            'unsupported("lips.teeth", title: "白牙", icon: "sparkles")',
            'supported("lips.teeth", title: "白牙", icon: "sparkles", controlID: .lipColor)',
            "R56-DEMO",
        ),
        "T-56-05": (
            f".planning/phases/{PHASE_NAME}/56-THREAT-INVENTORY.json",
            '"schema_version": 1,', '"schema_version": 1,\n  "portrait_path": "sensitive",', "R56-PRIVACY",
        ),
        "T-56-06": (
            "docs/meitu-function-blueprint/FEATURE_MATRIX.md",
            "| Beauty shaping | 嘴唇 | partial |", "| Beauty shaping | 嘴唇 | implemented |", "R56-LEDGER",
        ),
        "T-56-07": (
            "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
            'id: "lipPlump_0p25"', 'id: "lipPlumpRemoved_0p25"', "R56-COMPATIBILITY",
        ),
    }
    selected = THREAT_IDS if only is None else (only,)
    with tempfile.TemporaryDirectory(prefix="beauty-phase56-checker-") as temporary:
        fixture_root = pathlib.Path(temporary)
        copy_live_fixture(original_root, fixture_root)
        configure_root(fixture_root)
        try:
            assert live_failures() == set()
            cases += 1
            for threat_id in selected:
                if threat_id == "T-56-01":
                    cases += assert_decision_input_failures()
                else:
                    assert_mutation(fixture_root, *mutations[threat_id])
                    cases += 1

            if only is None:
                missing = fixture_root / "BeautySDK" / "Sources" / "BeautyEffects" / "Planning" / "BeautyLocalRetouchAdmission.swift"
                moved = missing.with_suffix(".swift.missing")
                missing.rename(moved)
                try:
                    assert live_failures() == {"R56-REQUIRED"}
                    cases += 1
                finally:
                    moved.rename(missing)
        finally:
            configure_root(original_root)

    print(json.dumps({
        "highThreatIds": selected,
        "mutationCaseCount": cases,
        "status": "pass",
    }, sort_keys=True))
    return 0


def emit(mode: str, failures: set[str]) -> int:
    if failures:
        print(json.dumps({
            "failedRuleIds": sorted(failures),
            "mode": mode,
            "status": "fail",
        }, sort_keys=True))
        return 1
    print(json.dumps({
        "compatibility": {"fields": 59, "presets": 5, "rendererCases": 72},
        "highThreatIds": THREAT_IDS,
        "mode": mode,
        "status": "pass",
    }, sort_keys=True))
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=pathlib.Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--only", choices=THREAT_IDS)
    parser.add_argument("--decision", action="store_true")
    args = parser.parse_args()
    try:
        if args.root is not None:
            configure_root(args.root)
        if args.only is not None and not args.self_test:
            return emit("arguments", {"R56-UNCLASSIFIED"})
        if args.self_test:
            return self_test(args.only)
        if args.decision:
            return emit("decision", decision_failures())
        return emit("live", live_failures())
    except (OSError, ValueError, KeyError, TypeError, ScannerFailure, AssertionError, json.JSONDecodeError):
        return emit("internal", {"R56-UNCLASSIFIED"})


if __name__ == "__main__":
    sys.exit(main())
