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
    expected_features = {"teeth_whitening", "sclera_redness", "upper_eyelid_fullness"}
    if decisions is None or set(decisions) != expected_features:
        errors.append("ledger.decision_identity")
    if aggregates is None or set(aggregates) != expected_features:
        errors.append("ledger.aggregate_identity")
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
    expected_review_count = 4 if sclera_open else 2
    if not isinstance(reviews, list) or len(reviews) != expected_review_count:
        errors.append("ledger.review_count")
    elif any(not isinstance(row, dict) or set(row) != REVIEW_KEYS for row in reviews):
        errors.append("ledger.review_schema")
    else:
        features = [row.get("feature") for row in reviews]
        expected_order = ["teeth_whitening", "teeth_whitening"]
        if sclera_open:
            expected_order += ["sclera_redness", "sclera_redness"]
        if features != expected_order:
            errors.append("ledger.review_order")
        grouped = {
            feature: [row for row in reviews if row.get("feature") == feature]
            for feature in expected_features
        }
        for feature, rows in grouped.items():
            expected = 2 if feature == "teeth_whitening" or (feature == "sclera_redness" and sclera_open) else 0
            if len(rows) != expected:
                errors.append(f"ledger.review_identity.{feature}")
            if rows and {row.get("polarity") for row in rows} != {"positive", "negative"}:
                errors.append(f"ledger.review_polarity.{feature}")
    return sorted(set(errors))


def privacy_schema_errors(document: object) -> list[str]:
    errors = decision_errors(document, sclera_open=False)
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
        required = (
            "public var scleraRednessReduction: Float",
            "scleraRednessReduction: Float = 0",
            "self.scleraRednessReduction = Self.clampUnit(scleraRednessReduction)",
            "decodeFloatIfPresent(.scleraRednessReduction)",
        )
        if any(token not in source for token in required):
            errors.append("model.sclera_plumbing")
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
        if body.count("normalized.teethWhitening > 0") != 1:
            errors.append("admission.teeth_direct")
        if body.count("normalized.scleraRednessReduction > 0") != 1:
            errors.append("admission.sclera_direct")
        if "opaqueDemandCount" not in body:
            errors.append("admission.opaque_count")
    else:
        if body.count("normalized.teethWhitening > 0") != 1 or body.count("opaqueDemandCount: 1") != 1:
            errors.append("admission.teeth_baseline")
        if "scleraRednessReduction" in body:
            errors.append("admission.premature_sclera")
    forbidden = (
        "skinWhitening", "brightness", "eyeSize", "upperEyelidLift", "lipColor",
        "eyes.redness", "祛红血丝", "去脂", "bloodshot", "sclera_redness",
    )
    for token in forbidden:
        if token in body:
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
    combined = "\n".join(files.values())
    for token in (
        "scleraRednessReduction", "ScleraRedness", "ScleraProvider", "ScleraMask",
        "Bloodshot", "bloodshot_reduction", "guardedSclera",
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
        return decision_errors(values["ledger"], sclera_open=False)
    if threat_id == "T-62-02":
        return contract_errors(str(values["contract"]))
    if threat_id == "T-62-03":
        return model_errors(str(values["parameters"]), sclera_open=False) + admission_errors(str(values["resolver"]), sclera_open=False)
    if threat_id == "T-62-04":
        return model_errors(str(values["parameters"]), sclera_open=False) + preset_errors()
    if threat_id == "T-62-05":
        return admission_errors(str(values["resolver"]), sclera_open=False) + demo_errors(str(values["demo"]))
    if threat_id == "T-62-06":
        return privacy_schema_errors(values["ledger"])
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

    mutated = copy.deepcopy(ledger)
    mutated["feature_decisions"][1]["status"] = "open"
    assert_rejected("T-62-01", lambda: decision_errors(mutated, sclera_open=False))

    assert_rejected(
        "T-62-02",
        lambda: contract_errors(str(inputs["contract"]).replace("review_frozen: true", "review_frozen: false")),
    )

    assert_rejected(
        "T-62-03",
        lambda: model_errors(
            str(inputs["parameters"]).replace(
                "public var teethWhitening: Float",
                "public var teethWhitening: Float\n    public var scleraRednessReduction: Float",
            ),
            sclera_open=False,
        ),
    )

    altered_parameters = str(inputs["parameters"]).replace(
        "public var teethWhitening: Float",
        "public var renamedTeethWhitening: Float",
    )
    assert_rejected("T-62-04", lambda: model_errors(altered_parameters, sclera_open=False))

    altered_resolver = str(inputs["resolver"]).replace(
        "normalized.teethWhitening > 0",
        "normalized.teethWhitening > 0 || normalized.skinWhitening > 0",
    )
    assert_rejected("T-62-05", lambda: admission_errors(altered_resolver, sclera_open=False))

    mutated = copy.deepcopy(ledger)
    mutated["reviews"][0]["reviewer_note"] = "opaque"
    assert_rejected("T-62-06", lambda: privacy_schema_errors(mutated))

    assert_rejected(
        "T-62-07",
        lambda: production_errors({"Synthetic.swift": "struct ScleraProvider {}"}),
    )

    missing_task_plans = list(inputs["plans"])
    missing_task_plans[-1] = re.sub(
        r'<task id="62-05-02".*?</task>',
        "",
        missing_task_plans[-1],
        flags=re.DOTALL,
    )
    assert_rejected(
        "T-62-08",
        lambda: lifecycle_errors(missing_task_plans, inputs["inventory"], str(inputs["validation"])),
    )

    emit("pass", mode="self-test", check_count=8, mutation_rejections=8)
    return 0


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
            errors = decision_errors(read_json(LEDGER_RELATIVE), sclera_open=False)
            mode = "decision"
            count = 1
        elif args.privacy:
            errors = privacy_schema_errors(read_json(LEDGER_RELATIVE))
            mode = "privacy"
            count = 1
        else:
            count, errors = all_errors()
            mode = "closed" if args.closed else "live"
        emit("pass" if not errors else "fail", mode=mode, check_count=count, failures=errors)
        return 0 if not errors else 1
    except (AssertionError, OSError, subprocess.SubprocessError):
        emit("fail", mode="self-test" if args.self_test else "error", check_count=0, failures=["checker.internal_failure"])
        return 1


if __name__ == "__main__":
    sys.exit(main())
