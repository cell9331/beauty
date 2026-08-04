#!/usr/bin/env python3
"""Fail-closed Phase 58 zero-admission milestone closeout checker."""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import sys
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
CANDIDATE_PATTERN = (
    r"teethWhitening|scleraRednessReduction|upperEyelidFullnessReduction"
)
SENSITIVE_PATTERN = (
    r"retainedScleraMask|persistedScleraMask|rawLandmarks|reviewerIdentity|"
    r"fixturePath|imageDigest|rawScannerError|publicSupportCoordinates"
)


def configure_root(root: pathlib.Path) -> None:
    global ROOT, PHASE, SOURCES, RESOLVER, FOUNDATION_TEST, COMPOSITION_TEST
    global PARAMETER_TEST, RESOURCE_TEST, RENDERER_TEST, DEMO_SOURCE, DEMO_TEST
    global DECISIONS, FEATURE_MATRIX, SHAPE_LEDGER, PHASE57_CHECKER
    global PHASE57_VERIFICATION, INVENTORY, EVIDENCE

    ROOT = root.resolve()
    PHASE = ROOT / ".planning" / "phases" / PHASE_NAME
    SOURCES = ROOT / "BeautySDK" / "Sources"
    RESOLVER = SOURCES / "BeautyEffects" / "Planning" / "BeautyEffectResolver.swift"
    FOUNDATION_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" /
        "BeautyEngineLocalRetouchFoundationTests.swift"
    )
    COMPOSITION_TEST = (
        ROOT / "BeautySDK" / "Tests" / "BeautyCoreTests" /
        "BeautyEngineLocalRetouchCompositionTests.swift"
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
    return set()


def privacy_failures() -> set[str]:
    if run_rg(SENSITIVE_PATTERN, (SOURCES,)) == "match":
        return {RULES["T-58-02"]}
    evidence = read_text(EVIDENCE)
    if re.search(SENSITIVE_PATTERN, evidence):
        return {RULES["T-58-02"]}
    required = (
        "Durable output is limited to fixed requirement, task, threat, rule, disposition,",
        "raw error, or scanner text",
    )
    if any(marker not in evidence for marker in required):
        return {RULES["T-58-02"]}
    return set()


def lifetime_failures() -> set[str]:
    source = read_text(FOUNDATION_TEST)
    required = (
        "testPhase58CanceledCallerDiscardsCompletedPublicationThenFreshRequestPublishes",
        "supportSequence: [.available(valueID: 101), .available(valueID: 202)]",
        "publication.cancel()",
        "XCTAssertEqual(canceledOutcome, .discarded)",
        "XCTAssertEqual(fresh.aggregateSupportValueID, 202)",
        "XCTAssertEqual(harness.retainedRequestOwnerCount, 0)",
    )
    forbidden = ("Phase58CooperativeAbort", "TD-013 resolved", "claimsCooperativeAbort")
    if any(marker not in source for marker in required) or any(marker in source for marker in forbidden):
        return {RULES["T-58-03"]}
    return set()


def compatibility_failures() -> set[str]:
    owners = {
        FOUNDATION_TEST: (
            "testPhase58ZeroAdmissionConjunctionPreservesBothFacadesAndCanonicalNoOp",
            "let processOutput = try engine.process(",
            "let resultOutput = try engine.processResult(",
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
        ),
    }
    for path, markers in owners.items():
        source = read_text(path)
        if any(source.count(marker) < 1 for marker in markers):
            return {RULES["T-58-04"]}
    return set()


def output_failures() -> set[str]:
    if run_rg(CANDIDATE_PATTERN, (SOURCES,)) == "match":
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
    return set()


def promotion_failures() -> set[str]:
    demo = read_text(DEMO_SOURCE)
    rows = (
        'unsupported("lips.teeth", title: "白牙", icon: "sparkles")',
        'unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)',
        'unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)',
    )
    if any(demo.count(row) != 1 for row in rows):
        return {RULES["T-58-06"]}
    demo_test = read_text(DEMO_TEST)
    if "testPhase58ZeroPromotionPreservesExactlyThreeDisabledLocalRetouchRows" not in demo_test:
        return {RULES["T-58-06"]}
    shape = read_text(SHAPE_LEDGER)
    shape_rows = (
        "| `眼睛` | 去脂 | future | None. |",
        "| `眼睛` | 祛红血丝 | future | None. |",
        "| `嘴唇` | 白牙 | future | None. |",
    )
    matrix = read_text(FEATURE_MATRIX)
    if any(shape.count(row) != 1 for row in shape_rows):
        return {RULES["T-58-06"]}
    if matrix.count("| Beauty shaping | 眼睛 | partial |") != 1:
        return {RULES["T-58-06"]}
    if matrix.count("| Beauty shaping | 嘴唇 | partial |") != 1:
        return {RULES["T-58-06"]}
    if "| OUT-04 | `zero_row_promotion` | promoted rows `0` |" not in read_text(EVIDENCE):
        return {RULES["T-58-06"]}
    return set()


def phase57_failures() -> set[str]:
    digest = hashlib.sha256(PHASE57_CHECKER.read_bytes()).hexdigest()
    verification = read_text(PHASE57_VERIFICATION)
    if digest != PHASE57_CHECKER_SHA256:
        return {RULES["T-58-07"]}
    required = (
        "status: passed", "score: 12/12 must-haves verified",
        "Aggregate 519/519", "65 / 68 / 90 / 143 / 23 / 81 / 7 / 42",
        "Human Verification Required\n\nNone.",
    )
    if any(marker not in verification for marker in required):
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
    if frontmatter["phase"] != "58" or frontmatter["status"] not in {"draft", "validated"}:
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
        SOURCES, FOUNDATION_TEST, COMPOSITION_TEST, PARAMETER_TEST, RESOURCE_TEST,
        RENDERER_TEST, DEMO_SOURCE, DEMO_TEST, DECISIONS, FEATURE_MATRIX,
        SHAPE_LEDGER, PHASE57_CHECKER, PHASE57_VERIFICATION, INVENTORY, EVIDENCE,
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


def self_test(only: str | None) -> int:
    selected = THREAT_IDS if only is None else (only,)
    original_root = ROOT
    cases = 0
    try:
        for threat in selected:
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


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=pathlib.Path)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--only", choices=THREAT_IDS)
    arguments = parser.parse_args()
    if arguments.root is not None:
        configure_root(arguments.root)
    if arguments.only is not None and not arguments.self_test:
        parser.error("--only requires --self-test")
    mode = "self-test" if arguments.self_test else "live"
    try:
        if arguments.self_test:
            return self_test(arguments.only)
        return emit(mode, classified_failures())
    except Exception:
        return emit(mode, {RULES["T-58-08"]})


if __name__ == "__main__":
    sys.exit(main())
