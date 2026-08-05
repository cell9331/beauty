#!/usr/bin/env python3
"""Fail-closed Phase 59 evidence, privacy, and exact-boundary checker."""

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
PHASE_NAME = "59-teeth-evidence-and-admission-contract"
THREAT_IDS = tuple(f"T-59-{index:02d}" for index in range(1, 9))
DECISION_KEYS = (
    "feature", "status", "reasons", "eligible_count", "reviewed_count",
    "accepted_count", "rejected_count", "naturalness_weight",
)
EXPECTED_DECISION = {
    "feature": "teeth_whitening",
    "status": "closed",
    "reasons": ["missing_genuine_positive", "missing_genuine_negative"],
    "eligible_count": 0,
    "reviewed_count": 0,
    "accepted_count": 0,
    "rejected_count": 0,
    "naturalness_weight": 0,
}
FORBIDDEN_DURABLE_KEY = re.compile(
    r"(?:portrait|filename|filepath|path|sha|hash|media|mask|pixel|coordinate|"
    r"landmark|reviewer|rights|digest|raw.?error|source.?match)", re.IGNORECASE,
)
FORBIDDEN_PRODUCTION = re.compile(
    r"scleraRednessReduction|upperEyelidFullness|upperEyelidReduction|去脂|"
    r"(?:teeth|tooth|enamel|dentition)[A-Za-z0-9_]*(?:Provider|Mask|Renderer|Transform|Output)",
)
FORBIDDEN_DEMO = re.compile(r"(?m)^\s*(?:(?<!un)supported\(|available\(|controlID:\s*\.)[^\n]*(?:teeth|去脂|祛红血丝)", re.IGNORECASE)


def configure_root(root: pathlib.Path) -> None:
    global ROOT, PHASE, DECISIONS, CONTRACT, INVENTORY, RESOLVER, SOURCES, DEMO_MODELS, DEMO_TEST
    ROOT = root.resolve()
    PHASE = ROOT / ".planning" / "phases" / PHASE_NAME
    DECISIONS = ROOT / ".planning" / "milestones" / "v1.14-phases" / "54-rights-approved-evidence-and-eligibility-decisions" / "54-EVIDENCE-DECISIONS.json"
    CONTRACT = PHASE / "59-EVIDENCE-ADMISSION-CONTRACT.md"
    INVENTORY = PHASE / "59-THREAT-INVENTORY.json"
    RESOLVER = ROOT / "BeautySDK" / "Sources" / "BeautyEffects" / "Planning" / "BeautyEffectResolver.swift"
    SOURCES = ROOT / "BeautySDK" / "Sources"
    DEMO_MODELS = ROOT / "BeautyDemo" / "BeautyDemo" / "Editor" / "MeituEditorToolModels.swift"
    DEMO_TEST = ROOT / "BeautyDemo" / "BeautyDemoTests" / "BeautyDemoViewStateTests.swift"


configure_root(ROOT)


class ScannerFailure(RuntimeError):
    pass


def read_json(path: pathlib.Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def exact_threat_inventory(document: object) -> bool:
    if not isinstance(document, dict) or document.get("schema_version") != 1:
        return False
    if document.get("security_standard") != "OWASP ASVS Level 1" or document.get("block_on") != "HIGH":
        return False
    threats = document.get("threats")
    if not isinstance(threats, list) or tuple(row.get("id") for row in threats) != THREAT_IDS:
        return False
    return all(
        isinstance(row, dict)
        and row.get("severity") == "HIGH"
        and row.get("disposition") == "mitigate"
        and isinstance(row.get("gates"), list)
        and row.get("gates")
        for row in threats
    )


def decision_failures(document: object | None = None) -> set[str]:
    try:
        value = read_json(DECISIONS) if document is None else document
    except (OSError, UnicodeError, json.JSONDecodeError):
        return {"T-59-01"}
    if not isinstance(value, dict):
        return {"T-59-01"}
    rows = value.get("feature_decisions")
    if not isinstance(rows, list):
        return {"T-59-01"}
    teeth = [row for row in rows if isinstance(row, dict) and row.get("feature") == "teeth_whitening"]
    teeth_like = [row for row in rows if isinstance(row, dict) and isinstance(row.get("feature"), str) and re.search(r"teeth|tooth", row["feature"], re.IGNORECASE)]
    if len(teeth) != 1 or teeth_like != teeth:
        return {"T-59-01"}
    row = teeth[0]
    if tuple(row.keys()) != DECISION_KEYS or row != EXPECTED_DECISION:
        return {"T-59-01"}
    aggregates = value.get("aggregates")
    if not isinstance(aggregates, list) or not any(item == {"feature": "teeth_whitening", "eligible_count": 0, "reviewed_count": 0, "accepted_count": 0, "rejected_count": 0, "naturalness_weight": 0} for item in aggregates):
        return {"T-59-01"}
    return set()


def privacy_failures() -> set[str]:
    try:
        durable = json.dumps(read_json(DECISIONS), sort_keys=True)
        inventory = json.dumps(read_json(INVENTORY), sort_keys=True)
    except (OSError, UnicodeError, json.JSONDecodeError):
        return {"T-59-07"}
    return {"T-59-07"} if FORBIDDEN_DURABLE_KEY.search(durable) or FORBIDDEN_DURABLE_KEY.search(inventory) else set()


def production_failures() -> set[str]:
    try:
        text = "\n".join(path.read_text(encoding="utf-8") for path in SOURCES.rglob("*.swift"))
        resolver = RESOLVER.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return {"T-59-05"}
    if FORBIDDEN_PRODUCTION.search(text):
        return {"T-59-05"}
    # A scalar/admission seam is permitted; provider/render/output vocabulary is not.
    if re.search(r"teethWhitening\s*(?:Provider|Mask|Renderer|Transform|Output)", resolver):
        return {"T-59-04"}
    return set()


def demo_failures() -> set[str]:
    try:
        source = DEMO_MODELS.read_text(encoding="utf-8")
        tests = DEMO_TEST.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return {"T-59-06"}
    if FORBIDDEN_DEMO.search(source) or "XCTAssertNil(teeth.controlID)" not in tests:
        return {"T-59-06"}
    return set()


def live_failures() -> set[str]:
    failures = set()
    try:
        if not CONTRACT.is_file() or not INVENTORY.is_file():
            failures.add("T-59-08")
        else:
            contract = CONTRACT.read_text(encoding="utf-8")
            if not re.search(r"phase:\s*59", contract) or not re.search(r"decision:\s*closed", contract):
                failures.add("T-59-03")
            if not exact_threat_inventory(read_json(INVENTORY)):
                failures.add("T-59-08")
        failures.update(decision_failures())
        failures.update(privacy_failures())
        failures.update(production_failures())
        failures.update(demo_failures())
    except (OSError, UnicodeError, json.JSONDecodeError, TypeError, KeyError, ScannerFailure):
        failures.add("T-59-08")
    return failures


def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise ScannerFailure("unclassified scanner outcome")


def copy_live_fixture(source_root: pathlib.Path, destination_root: pathlib.Path) -> None:
    def ignore(directory: str, names: list[str]) -> set[str]:
        ignored = {".git", ".build", "DerivedData", "build"}
        return {name for name in names if name in ignored}
    shutil.copytree(source_root, destination_root, ignore=ignore)


def assert_mutation(root: pathlib.Path, relative: str, old: str, new: str, expected: str) -> None:
    path = root / relative
    original = path.read_text(encoding="utf-8")
    if old not in original:
        raise AssertionError(f"mutation anchor missing: {relative}")
    path.write_text(original.replace(old, new, 1), encoding="utf-8")
    try:
        if expected not in live_failures():
            raise AssertionError(f"mutation accepted: {expected}")
    finally:
        path.write_text(original, encoding="utf-8")


def self_test() -> int:
    cases = 0
    assert classify_rg(0, "match", "") == "match"
    assert classify_rg(1, "", "") == "clean"
    cases += 2
    for code in (2, 127):
        try:
            classify_rg(code, "", "scanner failure")
        except ScannerFailure:
            cases += 1
    baseline_inventory = read_json(INVENTORY)
    assert exact_threat_inventory(baseline_inventory)
    cases += 1
    for index in range(len(THREAT_IDS)):
        mutated = copy.deepcopy(baseline_inventory)
        mutated["threats"][index]["gates"] = []
        assert not exact_threat_inventory(mutated)
        cases += 1

    with tempfile.TemporaryDirectory(prefix="beauty-phase59-checker-") as temporary:
        fixture_root = pathlib.Path(temporary) / "repo"
        copy_live_fixture(ROOT, fixture_root)
        configure_root(fixture_root)
        try:
            assert live_failures() == set(), live_failures()
            cases += 1
            decision = read_json(DECISIONS)
            forged = copy.deepcopy(decision)
            forged["feature_decisions"][0]["status"] = "open"
            assert "T-59-01" in decision_failures(forged)
            cases += 1
            assert_mutation(fixture_root, f".planning/phases/{PHASE_NAME}/59-EVIDENCE-ADMISSION-CONTRACT.md", "decision: closed", "decision: open", "T-59-03")
            cases += 1
            assert_mutation(fixture_root, "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift", "import BeautyCore", "import BeautyCore\n// scleraRednessReduction", "T-59-05")
            cases += 1
            assert_mutation(fixture_root, "BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift", 'unsupported("lips.teeth"', 'supported("lips.teeth"', "T-59-06")
            cases += 1
            assert_mutation(fixture_root, f".planning/phases/{PHASE_NAME}/59-THREAT-INVENTORY.json", '"schema_version": 1', '"portrait_path": "/private/sensitive",\n  "schema_version": 1', "T-59-07")
            cases += 1
        finally:
            configure_root(ROOT)
    return cases


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--decision", action="store_true")
    parser.add_argument("--evidence-gate", action="store_true")
    parser.add_argument("--privacy", action="store_true")
    parser.add_argument("--repo-root", type=pathlib.Path)
    args = parser.parse_args()
    if args.repo_root is not None:
        configure_root(args.repo_root)
    try:
        if args.self_test:
            print(json.dumps({"mutationCaseCount": self_test(), "status": "pass"}, sort_keys=True))
            return 0
        if args.decision:
            failures = decision_failures()
        elif args.evidence_gate:
            failures = decision_failures()
            if not CONTRACT.is_file() or not INVENTORY.is_file():
                failures.add("T-59-08")
            else:
                contract = CONTRACT.read_text(encoding="utf-8")
                if not re.search(r"phase:\s*59", contract) or not re.search(r"decision:\s*closed", contract):
                    failures.add("T-59-03")
                if not exact_threat_inventory(read_json(INVENTORY)):
                    failures.add("T-59-08")
        elif args.privacy:
            failures = privacy_failures()
        else:
            failures = live_failures()
        if failures:
            print(json.dumps({"failedRuleIds": sorted(failures), "status": "fail"}, sort_keys=True))
            return 1
        print(json.dumps({"highThreatIds": THREAT_IDS, "status": "pass"}, sort_keys=True))
        return 0
    except (OSError, UnicodeError, json.JSONDecodeError, TypeError, KeyError, AssertionError, ScannerFailure):
        print(json.dumps({"failedRuleIds": ["T-59-08"], "status": "fail"}, sort_keys=True))
        return 1


if __name__ == "__main__":
    sys.exit(main())
