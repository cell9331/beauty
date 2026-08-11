#!/usr/bin/env python3
"""Fail-closed Phase 62 evidence, compatibility, privacy, and scope checker."""

from __future__ import annotations

import argparse
import copy
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Callable


THREATS = tuple(f"T-62-{index:02d}" for index in range(1, 9))
EXPECTED_TASKS = tuple(f"62-{plan:02d}-{task:02d}" for plan in range(1, 6) for task in range(1, 3))
PHASE_RELATIVE = Path(".planning/phases/62-sclera-evidence-and-admission-contract")
LEDGER_RELATIVE = Path(
    ".planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/"
    "54-EVIDENCE-DECISIONS.json"
)
PARAMETERS_RELATIVE = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
RESOLVER_RELATIVE = Path("BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift")
PRESETS_RELATIVE = Path("BeautySDK/Sources/BeautyResources/Resources/Presets")
RENDERER_RELATIVE = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
DEMO_RELATIVE = Path("BeautyDemo/BeautyDemo")
PRIVATE_RUNNER_RELATIVE = PHASE_RELATIVE / "62-private-evidence-runner.js"
EVIDENCE_EXPORT_RELATIVE = PHASE_RELATIVE / "62-authorized-sclera-evidence-export.js"
BASELINE_COMMIT = "5793d1b"

ROOT_KEYS = frozenset({"schema_version", "feature_decisions", "reviews", "aggregates"})
DECISION_KEYS = frozenset({
    "feature", "status", "reasons", "eligible_count", "reviewed_count",
    "accepted_count", "rejected_count", "naturalness_weight",
})
REVIEW_KEYS = frozenset({
    "fixture_id", "feature", "polarity", "target_present", "mask_coverage",
    "protected_leakage", "naturalness", "structure_changed", "decision", "reason_code",
})
AGGREGATE_KEYS = frozenset({
    "feature", "eligible_count", "reviewed_count", "accepted_count",
    "rejected_count", "naturalness_weight",
})
OPEN_COUNTS = {
    "eligible_count": 2,
    "reviewed_count": 2,
    "accepted_count": 2,
    "rejected_count": 0,
    "naturalness_weight": 2,
}
CLOSED_COUNTS = {
    "eligible_count": 0,
    "reviewed_count": 0,
    "accepted_count": 0,
    "rejected_count": 0,
    "naturalness_weight": 0,
}
FEATURE_ORDER = ("teeth_whitening", "sclera_redness", "upper_eyelid_fullness")
EXPECTED_OPEN_REVIEWS = (
    {
        "fixture_id": "teeth_fixture_001",
        "feature": "teeth_whitening",
        "polarity": "positive",
        "target_present": True,
        "mask_coverage": 4,
        "protected_leakage": False,
        "naturalness": 4,
        "structure_changed": False,
        "decision": "accept",
        "reason_code": "none",
    },
    {
        "fixture_id": "teeth_fixture_002",
        "feature": "teeth_whitening",
        "polarity": "negative",
        "target_present": False,
        "mask_coverage": 1,
        "protected_leakage": False,
        "naturalness": 4,
        "structure_changed": False,
        "decision": "accept",
        "reason_code": "none",
    },
    {
        "fixture_id": "sr_fixture_001",
        "feature": "sclera_redness",
        "polarity": "positive",
        "target_present": True,
        "mask_coverage": 4,
        "protected_leakage": False,
        "naturalness": 4,
        "structure_changed": False,
        "decision": "accept",
        "reason_code": "none",
    },
    {
        "fixture_id": "sr_fixture_002",
        "feature": "sclera_redness",
        "polarity": "negative",
        "target_present": False,
        "mask_coverage": 1,
        "protected_leakage": False,
        "naturalness": 4,
        "structure_changed": False,
        "decision": "accept",
        "reason_code": "none",
    },
)


ROOT = Path.cwd()
PHASE_DIR = ROOT / PHASE_RELATIVE


def configure_root(root: Path) -> None:
    global ROOT, PHASE_DIR
    ROOT = root.resolve()
    PHASE_DIR = ROOT / PHASE_RELATIVE


def read_text(relative: Path) -> str:
    try:
        return (ROOT / relative).read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return ""


def read_json(relative: Path) -> object:
    try:
        return json.loads(read_text(relative))
    except json.JSONDecodeError:
        return None


def rows_by_feature(rows: object) -> dict[str, dict[str, object]] | None:
    if not isinstance(rows, list):
        return None
    result: dict[str, dict[str, object]] = {}
    for row in rows:
        if not isinstance(row, dict) or not isinstance(row.get("feature"), str):
            return None
        feature = str(row["feature"])
        if feature in result:
            return None
        result[feature] = row
    return result


def exact_decision(feature: str, *, opened: bool) -> dict[str, object]:
    if feature == "upper_eyelid_fullness":
        return {
            "feature": feature,
            "status": "closed",
            "reasons": [
                "missing_genuine_positive",
                "missing_genuine_negative",
                "non_warp_design_unqualified",
            ],
            **CLOSED_COUNTS,
        }
    if opened:
        return {"feature": feature, "status": "open", "reasons": [], **OPEN_COUNTS}
    return {
        "feature": feature,
        "status": "closed",
        "reasons": ["missing_genuine_positive", "missing_genuine_negative"],
        **CLOSED_COUNTS,
    }


def decision_errors(document: object, *, sclera_open: bool = False) -> list[str]:
    errors: list[str] = []
    if not isinstance(document, dict) or set(document) != ROOT_KEYS or document.get("schema_version") != 1:
        return ["ledger.root_schema"]
    decisions = rows_by_feature(document.get("feature_decisions"))
    aggregates = rows_by_feature(document.get("aggregates"))
    expected_features = set(FEATURE_ORDER)
    if decisions is None or set(decisions) != expected_features:
        errors.append("ledger.decision_identity")
    elif [row.get("feature") for row in document["feature_decisions"]] != list(FEATURE_ORDER):
        errors.append("ledger.decision_order")
    if aggregates is None or set(aggregates) != expected_features:
        errors.append("ledger.aggregate_identity")
    elif [row.get("feature") for row in document["aggregates"]] != list(FEATURE_ORDER):
        errors.append("ledger.aggregate_order")
    if decisions is not None and set(decisions) == expected_features:
        expected = {
            "teeth_whitening": exact_decision("teeth_whitening", opened=True),
            "sclera_redness": exact_decision("sclera_redness", opened=sclera_open),
            "upper_eyid_fullness": exact_decision("upper_eyelid_fullness", opened=False),
        }
        for feature in expected_features:
            lookup = "upper_eyid_fullness" if feature == "upper_eyelid_fullness" else feature
            if decisions.get(feature) != expected[lookup]:
                errors.append(f"ledger.decision.{feature}")
    if aggregates is not None and set(aggregates) == expected_features:
        for feature in expected_features:
            opened = feature == "teeth_whitening" or (feature == "sclera_redness" and sclera_open)
            counts = OPEN_COUNTS if opened else CLOSED_COUNTS
            if aggregates.get(feature) != {"feature": feature, **counts}:
                errors.append(f"ledger.aggregate.{feature}")
    reviews = document.get("reviews")
    expected_reviews = list(EXPECTED_OPEN_REVIEWS if sclera_open else EXPECTED_OPEN_REVIEWS[:2])
    if not isinstance(reviews, list) or len(reviews) != len(expected_reviews):
        errors.append("ledger.review_count")
    elif any(not isinstance(row, dict) or set(row) != REVIEW_KEYS for row in reviews):
        errors.append("ledger.review_schema")
    else:
        if reviews != expected_reviews:
            errors.append("ledger.review_exact")
        fixture_ids = [row.get("fixture_id") for row in reviews]
        if len(set(fixture_ids)) != len(fixture_ids):
            errors.append("ledger.review_identity")
    return sorted(set(errors))


def privacy_schema_errors(document: object) -> list[str]:
    errors = decision_errors(document, sclera_open=True)
    if not isinstance(document, dict):
        return sorted(set(errors + ["privacy.document_shape"]))
    for row in document.get("feature_decisions", []):
        if not isinstance(row, dict) or set(row) != DECISION_KEYS:
            errors.append("privacy.decision_keys")
    for row in document.get("reviews", []):
        if not isinstance(row, dict) or set(row) != REVIEW_KEYS:
            errors.append("privacy.review_keys")
    for row in document.get("aggregates", []):
        if not isinstance(row, dict) or set(row) != AGGREGATE_KEYS:
            errors.append("privacy.aggregate_keys")
    forbidden_key = re.compile(
        r"(?:path|locator|digest|hash|rights|reviewer|identity|support|raw_mask|geometry|coordinate|pixel|metric|error|freeform|note)",
        re.IGNORECASE,
    )

    def walk(value: object) -> None:
        if isinstance(value, dict):
            for key, child in value.items():
                if forbidden_key.search(str(key)):
                    errors.append("privacy.forbidden_key")
                walk(child)
        elif isinstance(value, list):
            for child in value:
                walk(child)

    walk(document)
    return sorted(set(errors))


def private_result_errors(
    returncode: int,
    stdout: str,
    stderr: str,
    *,
    expected_keys: frozenset[str],
) -> list[str]:
    errors: list[str] = []
    if returncode != 0:
        errors.append("privacy.runner_exit")
    if stderr:
        errors.append("privacy.runner_stderr")
    if not stdout.endswith("\n") or stdout.count("\n") != 1:
        errors.append("privacy.runner_output_lines")
    try:
        payload = json.loads(stdout)
    except json.JSONDecodeError:
        payload = None
    if not isinstance(payload, dict) or set(payload) != expected_keys:
        errors.append("privacy.runner_output_schema")
    elif payload.get("status") != "pass":
        errors.append("privacy.runner_status")
    return sorted(set(errors))


def private_scan_errors(*, closed: bool = False) -> list[str]:
    errors: list[str] = []
    runner = ROOT / PRIVATE_RUNNER_RELATIVE
    commands = (
        (
            ["--scan-tracked-staged", "--closed"] if closed else ["--scan-tracked-staged"],
            frozenset({"status", "tracked_file_count"}),
        ),
        (["--self-test"], frozenset({"status", "mutation_rejections"})),
    )
    for arguments, expected_keys in commands:
        try:
            result = subprocess.run(
                ["node", str(runner), *arguments],
                cwd=ROOT,
                check=False,
                capture_output=True,
                text=True,
                timeout=30,
            )
        except (OSError, subprocess.SubprocessError):
            errors.append("privacy.runner_execution")
            continue
        errors.extend(private_result_errors(
            result.returncode,
            result.stdout,
            result.stderr,
            expected_keys=expected_keys,
        ))
        if arguments[0] == "--scan-tracked-staged" and not errors:
            try:
                payload = json.loads(result.stdout)
            except json.JSONDecodeError:
                payload = None
            if not isinstance(payload, dict) or not isinstance(payload.get("tracked_file_count"), int) \
                    or payload["tracked_file_count"] < 1:
                errors.append("privacy.runner_tracked_count")
        if arguments[0] == "--self-test" and not errors:
            try:
                payload = json.loads(result.stdout)
            except json.JSONDecodeError:
                payload = None
            if not isinstance(payload, dict) or payload.get("mutation_rejections") != 16:
                errors.append("privacy.runner_mutation_count")
    return sorted(set(errors))


def private_verification_errors() -> list[str]:
    errors: list[str] = []
    runner = ROOT / PRIVATE_RUNNER_RELATIVE
    commands = (
        ["--verify-bundle"],
        [
            "--",
            "node",
            str(ROOT / EVIDENCE_EXPORT_RELATIVE),
            "--verify-ledger",
            str(ROOT / LEDGER_RELATIVE),
        ],
    )
    for arguments in commands:
        try:
            result = subprocess.run(
                ["node", str(runner), *arguments],
                cwd=ROOT,
                check=False,
                capture_output=True,
                text=True,
                timeout=150,
            )
        except (OSError, subprocess.SubprocessError):
            errors.append("evidence.private_execution")
            continue
        result_errors = private_result_errors(
            result.returncode,
            result.stdout,
            result.stderr,
            expected_keys=frozenset({"status"}),
        )
        errors.extend(f"evidence.{rule}" for rule in result_errors)
    return sorted(set(errors))


def public_fields(source: str) -> list[str]:
    head = source.split("enum CodingKeys", maxsplit=1)[0]
    return re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9_]*):", head, re.MULTILINE)


def coding_keys(source: str) -> list[str]:
    match = re.search(r"enum CodingKeys: String, CodingKey \{(?P<body>.*?)\n\s*\}", source, re.DOTALL)
    if match is None:
        return []
    return re.findall(r"^\s*case ([A-Za-z][A-Za-z0-9_]*)\s*$", match.group("body"), re.MULTILINE)


def model_errors(source: str, *, sclera_open: bool = False) -> list[str]:
    errors: list[str] = []
    fields = public_fields(source)
    keys = coding_keys(source)
    expected_count = 61 if sclera_open else 60
    expected_tail = ["teethWhitening", "scleraRednessReduction"] if sclera_open else ["teethWhitening"]
    if len(fields) != expected_count or len(set(fields)) != expected_count:
        errors.append("model.field_count")
    if fields != keys:
        errors.append("model.coding_order")
    if fields[-len(expected_tail):] != expected_tail:
        errors.append("model.tail_order")
    if sclera_open:
        required = {
            "model.sclera_storage": "public var scleraRednessReduction: Float",
            "model.sclera_default": "scleraRednessReduction: Float = 0",
            "model.sclera_clamp": "self.scleraRednessReduction = Self.clampUnit(scleraRednessReduction)",
            "model.sclera_decode": "decodeFloatIfPresent(.scleraRednessReduction)",
            "model.sclera_normalized_copy": "scleraRednessReduction: scleraRednessReduction",
        }
        for rule, token in required.items():
            if source.count(token) != 1:
                errors.append(rule)
    elif "scleraRednessReduction" in source:
        errors.append("model.premature_sclera")
    return sorted(set(errors))


def function_body(source: str, signature: str) -> str:
    start = source.find(signature)
    if start < 0:
        return ""
    brace = source.find("{", start)
    if brace < 0:
        return ""
    depth = 0
    for index in range(brace, len(source)):
        if source[index] == "{":
            depth += 1
        elif source[index] == "}":
            depth -= 1
            if depth == 0:
                return source[brace + 1:index]
    return ""


def admission_errors(source: str, *, sclera_open: bool = False) -> list[str]:
    errors: list[str] = []
    body = function_body(source, "package static func localRetouchAdmission")
    if not body:
        return ["admission.function_missing"]
    if "let normalized = parameters.normalized()" not in body:
        errors.append("admission.not_normalized")
    if sclera_open:
        if body.count("let normalized = parameters.normalized()") != 1:
            errors.append("admission.normalize_count")
        if body.count("normalized.teethWhitening > 0") != 1:
            errors.append("admission.teeth_direct")
        if body.count("normalized.scleraRednessReduction > 0") != 1:
            errors.append("admission.sclera_direct")
        if body.count("var opaqueDemandCount = 0") != 1:
            errors.append("admission.count_initialization")
        if body.count("opaqueDemandCount += 1") != 2:
            errors.append("admission.count_increment")
        if body.count("BeautyLocalRetouchAdmission(opaqueDemandCount: opaqueDemandCount)") != 1:
            errors.append("admission.count_return")
        if ".none" in body:
            errors.append("admission.branch_suppression")
    else:
        if body.count("normalized.teethWhitening > 0") != 1 or body.count("opaqueDemandCount: 1") != 1:
            errors.append("admission.teeth_baseline")
        if "scleraRednessReduction" in body:
            errors.append("admission.premature_sclera")
    forbidden = (
        "skinWhitening", "brightness", "eyeSize", "upperEyelidLift", "lipColor",
        "teethWhite", "toothWhitening", "teethBrightness", "teeth_whitening",
        "scleraRedness", "scleraWhitening", "scleraBrightness", "whitenSclera",
        "eyeRedness", "eyeRednessReduction", "redEyeReduction",
        "conjunctivaRednessReduction", "ocularRednessReduction", "bloodshotReduction",
        "sclera_redness_reduction", "eyes.redness", "lips.teeth", "eyes.fat",
        "admittedPrivateDemandCount", "productionAdmissionCount",
        "白牙", "祛红血丝", "去脂", "bloodshot", "sclera_redness",
    )
    for token in forbidden:
        escaped = re.escape(token)
        if re.search(rf"(?<![A-Za-z0-9_]){escaped}(?![A-Za-z0-9_])", body):
            errors.append("admission.forbidden_input")
            break
    return sorted(set(errors))


def git_show(relative: Path) -> bytes | None:
    result = subprocess.run(
        ["git", "show", f"{BASELINE_COMMIT}:{relative.as_posix()}"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        timeout=20,
    )
    return result.stdout if result.returncode == 0 else None


def preset_errors() -> list[str]:
    errors: list[str] = []
    directory = ROOT / PRESETS_RELATIVE
    files = sorted(directory.glob("*.json")) if directory.is_dir() else []
    if len(files) != 5:
        return ["preset.inventory"]
    for file in files:
        relative = PRESETS_RELATIVE / file.name
        baseline = git_show(relative)
        try:
            current = file.read_bytes()
            parsed = json.loads(current)
        except (OSError, json.JSONDecodeError):
            errors.append("preset.invalid")
            continue
        if baseline is None or baseline != current:
            errors.append("preset.bytes")
        if "scleraRednessReduction" in json.dumps(parsed, sort_keys=True):
            errors.append("preset.sclera_key")
    return sorted(set(errors))


def renderer_errors(source: str) -> list[str]:
    errors: list[str] = []
    ids = re.findall(r'\bid\s*:\s*"([^"]+)"', source)
    if len(ids) != 73 or len(set(ids)) != 73:
        errors.append("renderer.inventory")
    if ids.count("teethWhitening_1p00") != 1 or "BeautyParameters(teethWhitening: 1)" not in source:
        errors.append("renderer.teeth_baseline")
    if any("sclera" in value.lower() or "redness" in value.lower() for value in ids):
        errors.append("renderer.sclera_case")
    if source.count("engine.processResult(") != 1:
        errors.append("renderer.facade_call")
    return sorted(set(errors))


def demo_source() -> str:
    directory = ROOT / DEMO_RELATIVE
    if not directory.is_dir():
        return ""
    parts: list[str] = []
    for path in sorted(directory.rglob("*.swift")):
        try:
            parts.append(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeError):
            return ""
    return "\n".join(parts)


def demo_errors(source: str) -> list[str]:
    errors: list[str] = []
    exact = (
        'unsupported("lips.teeth", title: "白牙"',
        'unsupported("eyes.redness", title: "祛红血丝"',
        'unsupported("eyes.fat", title: "去脂"',
    )
    if any(source.count(token) != 1 for token in exact):
        errors.append("demo.disabled_rows")
    if "scleraRednessReduction" in source or "case sclera" in source:
        errors.append("demo.sclera_mapping")
    return sorted(set(errors))


def production_errors(files: dict[str, str] | None = None) -> list[str]:
    errors: list[str] = []
    if files is None:
        files = {}
        base = ROOT / "BeautySDK/Sources"
        if not base.is_dir():
            return ["production.source_missing"]
        for path in sorted(base.rglob("*.swift")):
            try:
                files[str(path.relative_to(ROOT))] = path.read_text(encoding="utf-8")
            except (OSError, UnicodeError):
                return ["production.source_unreadable"]
    allowed_scalar_files = {str(PARAMETERS_RELATIVE), str(RESOLVER_RELATIVE)}
    scalar_files = {
        relative for relative, source in files.items()
        if "scleraRednessReduction" in source
    }
    if scalar_files != allowed_scalar_files:
        errors.append("production.sclera_surface")
    combined = "\n".join(files.values())
    for token in (
        "ScleraRedness", "ScleraProvider", "ScleraMask", "ScleraTransform",
        "ScleraRenderer", "Bloodshot", "bloodshot_reduction", "guardedSclera",
        "scleraSupport", "scleraMask", "scleraOutput", "scleraModel", "scleraNetwork",
    ):
        if token in combined:
            errors.append("production.premature_sclera")
            break
    return sorted(set(errors))


def contract_errors(source: str) -> list[str]:
    errors: list[str] = []
    normalized = " ".join(source.lower().split())
    required = (
        "review_frozen: true", "sclera_redness", "visible scleral redness",
        "normal or already-low-redness", "mask coverage", "protected leakage",
        "vessel/detail variation", "naturalness", "structure change",
        "2 / 2 / 2 / 0", "t-62-01 through t-62-08", "phase 63 blocked",
    )
    if any(token not in normalized for token in required):
        errors.append("contract.frozen_criteria")
    if "legacy unguarded sclera mask" not in normalized or "re-clipped" not in normalized:
        errors.append("contract.guarded_derivative")
    return sorted(set(errors))


def lifecycle_errors(plan_texts: list[str], inventory: object, validation: str) -> list[str]:
    errors: list[str] = []
    if len(plan_texts) != 5:
        errors.append("lifecycle.plan_count")
    tasks = tuple(re.findall(r'<task id="([^"]+)"', "\n".join(plan_texts)))
    if tasks != EXPECTED_TASKS:
        errors.append("lifecycle.task_inventory")
    if not isinstance(inventory, dict) or not isinstance(inventory.get("threats"), list):
        errors.append("lifecycle.threat_shape")
    else:
        threats = inventory["threats"]
        if tuple(row.get("id") for row in threats if isinstance(row, dict)) != THREATS:
            errors.append("lifecycle.threat_inventory")
        if len(threats) != 8 or any(
            not isinstance(row, dict)
            or row.get("severity") != "HIGH"
            or row.get("disposition") != "mitigate"
            for row in threats
        ):
            errors.append("lifecycle.threat_disposition")
    validation_rows = re.findall(r"^\| (62-\d{2}-\d{2}) \|", validation, re.MULTILINE)
    if tuple(validation_rows) != EXPECTED_TASKS:
        errors.append("lifecycle.validation_inventory")
    return sorted(set(errors))


def live_inputs() -> dict[str, object]:
    return {
        "ledger": read_json(LEDGER_RELATIVE),
        "contract": read_text(PHASE_RELATIVE / "62-SCLERA-EVIDENCE-ADMISSION-CONTRACT.md"),
        "parameters": read_text(PARAMETERS_RELATIVE),
        "resolver": read_text(RESOLVER_RELATIVE),
        "renderer": read_text(RENDERER_RELATIVE),
        "demo": demo_source(),
        "plans": [
            path.read_text(encoding="utf-8")
            for path in sorted(PHASE_DIR.glob("62-??-PLAN.md"))
        ] if PHASE_DIR.is_dir() else [],
        "inventory": read_json(PHASE_RELATIVE / "62-THREAT-INVENTORY.json"),
        "validation": read_text(PHASE_RELATIVE / "62-VALIDATION.md"),
    }


def threat_errors(threat_id: str, inputs: dict[str, object] | None = None) -> list[str]:
    values = live_inputs() if inputs is None else inputs
    if threat_id == "T-62-01":
        return decision_errors(values["ledger"], sclera_open=True) + private_verification_errors()
    if threat_id == "T-62-02":
        return contract_errors(str(values["contract"])) + decision_errors(values["ledger"], sclera_open=True)
    if threat_id == "T-62-03":
        return (
            decision_errors(values["ledger"], sclera_open=True)
            + model_errors(str(values["parameters"]), sclera_open=True)
            + admission_errors(str(values["resolver"]), sclera_open=True)
        )
    if threat_id == "T-62-04":
        return model_errors(str(values["parameters"]), sclera_open=True) + preset_errors()
    if threat_id == "T-62-05":
        return admission_errors(str(values["resolver"]), sclera_open=True) + demo_errors(str(values["demo"]))
    if threat_id == "T-62-06":
        return privacy_schema_errors(values["ledger"]) + private_scan_errors()
    if threat_id == "T-62-07":
        return production_errors() + renderer_errors(str(values["renderer"]))
    if threat_id == "T-62-08":
        return lifecycle_errors(
            list(values["plans"]),
            values["inventory"],
            str(values["validation"]),
        )
    return ["threat.unknown"]


def all_errors() -> tuple[int, list[str]]:
    inputs = live_inputs()
    errors: list[str] = []
    count = 0
    for threat_id in THREATS:
        owned = threat_errors(threat_id, inputs)
        errors.extend(f"{threat_id}:{rule}" for rule in owned)
        count += 1
    return count, sorted(set(errors))


def assert_rejected(name: str, validator: Callable[[], list[str]]) -> None:
    if not validator():
        raise AssertionError(f"mutation_not_rejected:{name}")


def self_test() -> int:
    inputs = live_inputs()
    ledger = inputs["ledger"]
    if not isinstance(ledger, dict):
        raise AssertionError("baseline_ledger_invalid")
    if decision_errors(ledger, sclera_open=True):
        raise AssertionError("baseline_decision_invalid")
    if private_scan_errors() or private_verification_errors():
        raise AssertionError("baseline_private_scan_invalid")
    mutation_rejections = 0

    def reject(name: str, validator: Callable[[], list[str]]) -> None:
        nonlocal mutation_rejections
        assert_rejected(name, validator)
        mutation_rejections += 1

    def altered(value: object) -> object:
        if isinstance(value, bool):
            return not value
        if isinstance(value, int):
            return value + 1
        if isinstance(value, str):
            return f"{value}_mutated"
        if isinstance(value, list):
            return [*value, "mutated"]
        return "mutated"

    mutated = copy.deepcopy(ledger)
    mutated["schema_version"] = 2
    reject("T-62-01.root", lambda value=mutated: decision_errors(value, sclera_open=True))
    for collection in ("feature_decisions", "reviews", "aggregates"):
        rows = ledger[collection]
        for row_index, row in enumerate(rows):
            for key, value in row.items():
                mutated = copy.deepcopy(ledger)
                mutated[collection][row_index][key] = altered(value)
                reject(
                    f"T-62-01.{collection}.{row_index}.{key}",
                    lambda value=mutated: decision_errors(value, sclera_open=True),
                )
        mutated = copy.deepcopy(ledger)
        mutated[collection] = list(reversed(mutated[collection]))
        reject(
            f"T-62-01.{collection}.order",
            lambda value=mutated: decision_errors(value, sclera_open=True),
        )
        mutated = copy.deepcopy(ledger)
        mutated[collection] = mutated[collection][:-1]
        reject(
            f"T-62-01.{collection}.missing",
            lambda value=mutated: decision_errors(value, sclera_open=True),
        )
        mutated = copy.deepcopy(ledger)
        mutated[collection].append(copy.deepcopy(mutated[collection][0]))
        reject(
            f"T-62-01.{collection}.duplicate",
            lambda value=mutated: decision_errors(value, sclera_open=True),
        )

    reject(
        "T-62-02.frozen",
        lambda: contract_errors(
            str(inputs["contract"]).replace("review_frozen: true", "review_frozen: false")
        ),
    )

    parameters = str(inputs["parameters"])
    for token in (
        "public var scleraRednessReduction: Float",
        "case scleraRednessReduction",
        "scleraRednessReduction: Float = 0",
        "self.scleraRednessReduction = Self.clampUnit(scleraRednessReduction)",
        "decodeFloatIfPresent(.scleraRednessReduction)",
        "scleraRednessReduction: scleraRednessReduction",
    ):
        reject(
            f"T-62-03.model.{token[:12]}",
            lambda value=parameters.replace(token, "MUTATED_TOKEN", 1): model_errors(
                value, sclera_open=True
            ),
        )
    reject(
        "T-62-04.model_order",
        lambda: model_errors(
            parameters.replace(
                "    public var teethWhitening: Float\n    public var scleraRednessReduction: Float",
                "    public var scleraRednessReduction: Float\n    public var teethWhitening: Float",
                1,
            ),
            sclera_open=True,
        ),
    )

    resolver = str(inputs["resolver"])
    for name, changed in (
        ("normalize", resolver.replace("let normalized = parameters.normalized()", "let normalized = parameters")),
        ("teeth", resolver.replace("normalized.teethWhitening > 0", "false", 1)),
        ("sclera", resolver.replace("normalized.scleraRednessReduction > 0", "false", 1)),
        ("increment", resolver.replace("opaqueDemandCount += 1", "opaqueDemandCount += 2", 1)),
        (
            "return",
            resolver.replace(
                "BeautyLocalRetouchAdmission(opaqueDemandCount: opaqueDemandCount)",
                "BeautyLocalRetouchAdmission(opaqueDemandCount: 1)",
                1,
            ),
        ),
    ):
        reject(
            f"T-62-05.{name}",
            lambda value=changed: admission_errors(value, sclera_open=True),
        )
    for token in (
        "skinWhitening", "brightness", "eyeSize", "upperEyelidLift", "lipColor",
        "teethWhite", "toothWhitening", "teethBrightness", "teeth_whitening",
        "scleraRedness", "scleraWhitening", "scleraBrightness", "whitenSclera",
        "eyeRedness", "eyeRednessReduction", "redEyeReduction",
        "conjunctivaRednessReduction", "ocularRednessReduction", "bloodshotReduction",
        "sclera_redness_reduction", "eyes.redness", "lips.teeth", "eyes.fat",
        "admittedPrivateDemandCount", "productionAdmissionCount",
        "白牙", "祛红血丝", "去脂",
    ):
        altered_resolver = resolver.replace(
            "let normalized = parameters.normalized()",
            f"let forbidden = \"{token}\"\n        let normalized = parameters.normalized()",
        )
        reject(
            f"T-62-05.alias.{token}",
            lambda value=altered_resolver: admission_errors(value, sclera_open=True),
        )

    mutated = copy.deepcopy(ledger)
    mutated["reviews"][0]["reviewer_note"] = "opaque"
    reject("T-62-06.schema", lambda: privacy_schema_errors(mutated))
    for name, result in (
        ("runner_nonzero", (1, '{"status":"fail"}\n', "")),
        ("runner_stderr", (0, '{"status":"pass","tracked_file_count":1}\n', "scanner failure")),
        ("runner_malformed", (0, "not-json\n", "")),
        ("runner_extra", (0, '{"status":"pass","tracked_file_count":1,"detail":"private"}\n', "")),
    ):
        reject(
            f"T-62-06.{name}",
            lambda value=result: private_result_errors(
                *value,
                expected_keys=frozenset({"status", "tracked_file_count"}),
            ),
        )

    reject(
        "T-62-07.provider",
        lambda: production_errors({"Synthetic.swift": "struct ScleraProvider {}"}),
    )
    reject(
        "T-62-07.renderer",
        lambda: renderer_errors(str(inputs["renderer"]) + '\nid: "scleraRednessReduction_1p00"'),
    )
    reject(
        "T-62-07.demo",
        lambda: demo_errors(str(inputs["demo"]) + "\ncase scleraRednessReduction"),
    )

    missing_task_plans = list(inputs["plans"])
    missing_task_plans[-1] = re.sub(
        r'<task id="62-05-02".*?</task>',
        "",
        missing_task_plans[-1],
        flags=re.DOTALL,
    )
    reject(
        "T-62-08.task",
        lambda: lifecycle_errors(missing_task_plans, inputs["inventory"], str(inputs["validation"])),
    )
    altered_inventory = copy.deepcopy(inputs["inventory"])
    altered_inventory["threats"][0]["severity"] = "MEDIUM"
    reject(
        "T-62-08.threat",
        lambda: lifecycle_errors(list(inputs["plans"]), altered_inventory, str(inputs["validation"])),
    )
    reject(
        "T-62-08.validation",
        lambda: lifecycle_errors(
            list(inputs["plans"]),
            inputs["inventory"],
            str(inputs["validation"]).replace("| 62-05-02 |", "| missing |", 1),
        ),
    )

    emit("pass", mode="self-test", check_count=8, mutation_rejections=mutation_rejections)
    return 0


def historical_closed_fixture_errors() -> list[str]:
    ledger = read_json(LEDGER_RELATIVE)
    if not isinstance(ledger, dict):
        return ["closed.fixture_source"]
    fixture = copy.deepcopy(ledger)
    fixture["feature_decisions"][1] = exact_decision("sclera_redness", opened=False)
    fixture["reviews"] = fixture["reviews"][:2]
    fixture["aggregates"][1] = {"feature": "sclera_redness", **CLOSED_COUNTS}
    return decision_errors(fixture, sclera_open=False)


def emit(
    status: str,
    *,
    mode: str,
    check_count: int,
    failures: list[str] | None = None,
    threat_id: str | None = None,
    mutation_rejections: int | None = None,
) -> None:
    payload: dict[str, object] = {"status": status, "mode": mode, "check_count": check_count}
    if threat_id is not None:
        payload["threat_id"] = threat_id
    if mutation_rejections is not None:
        payload["mutation_rejections"] = mutation_rejections
    if failures:
        payload["failure_count"] = len(failures)
        payload["rule_ids"] = sorted(set(failures))
    print(json.dumps(payload, sort_keys=True, separators=(",", ":")))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--closed", action="store_true")
    modes.add_argument("--decision", action="store_true")
    modes.add_argument("--privacy", action="store_true")
    modes.add_argument("--live", action="store_true")
    modes.add_argument("--threat", choices=THREATS)
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()
    configure_root(Path(args.repo_root))
    try:
        if args.self_test:
            return self_test()
        if args.threat:
            errors = threat_errors(args.threat)
            emit(
                "pass" if not errors else "fail",
                mode="threat",
                check_count=1,
                failures=errors,
                threat_id=args.threat,
            )
            return 0 if not errors else 1
        if args.decision:
            errors = (
                decision_errors(read_json(LEDGER_RELATIVE), sclera_open=True)
                + private_verification_errors()
            )
            mode = "decision"
            count = 3
        elif args.privacy:
            errors = privacy_schema_errors(read_json(LEDGER_RELATIVE)) + private_scan_errors()
            mode = "privacy"
            count = 3
        elif args.closed:
            errors = historical_closed_fixture_errors()
            mode = "closed"
            count = 1
        else:
            count, errors = all_errors()
            mode = "live"
        emit("pass" if not errors else "fail", mode=mode, check_count=count, failures=errors)
        return 0 if not errors else 1
    except (AssertionError, OSError, subprocess.SubprocessError):
        emit("fail", mode="self-test" if args.self_test else "error", check_count=0, failures=["checker.internal_failure"])
        return 1


if __name__ == "__main__":
    sys.exit(main())
