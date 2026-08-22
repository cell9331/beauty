#!/usr/bin/env python3
"""Bind the current v1.18 public-absence branch to the Phase-78 machine decision.

The archived Phase-78 module is execution input, not mutable Markdown evidence.
This gate emits only fixed aggregate fields and normalized reason identifiers.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import re
import subprocess
from pathlib import Path
from typing import Any, Callable


PHASE = 78
BRANCH = "public-absence"
MECHANICS_DECISION = "mechanics-only-not-promotion"
PROMOTION_DECISIONS = {"promotion-ready-baseline", "promotion-ready-comparator"}
DECISIONS = {MECHANICS_DECISION, *PROMOTION_DECISIONS}
HASH_RE = re.compile(r"^[0-9a-f]{64}$")
OPAQUE_ID_RE = re.compile(r"^[A-Za-z0-9_-]{1,64}$")
REASON_RE = re.compile(r"^[a-z][a-z0-9.-]{0,127}$")
SENSITIVE_KEY_RE = re.compile(
    r"(?:path|locator|pixel|mask|landmark|coordinate|geometry|raw|private|"
    r"biometric|descriptor|prose|output)",
    re.IGNORECASE,
)

PHASE78_MODULE = Path(
    ".planning/milestones/v1.18-phases/"
    "78-genuine-evaluation-and-candidate-decision/78-candidate-decision.js"
)
PHASE75_CONTRACT = Path(
    ".planning/milestones/v1.18-phases/"
    "75-semantics-and-genuine-evidence-contract/75-EVIDENCE-CONTRACT.md"
)
PARAMETERS = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
RENDERER = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
RESOURCE_MANIFEST = Path("BeautySDK/Sources/BeautyResources/Resources/manifest.json")
PACKAGE = Path("BeautySDK/Package.swift")
SDK_FACADE = Path("BeautySDK/Sources/BeautySDK")

TOP_LEVEL_KEYS = {
    "status",
    "phase",
    "contract_hash",
    "manifest_hash",
    "fixture_ids",
    "aggregate_metrics",
    "reason_counts",
    "decision",
}
METRIC_KEYS = {
    "baseline",
    "baseline_disposition",
    "comparator",
    "comparator_disposition",
    "fixture_count",
    "genuine_evaluation_executed",
    "frozen_review_complete",
    "safety_gates_pass",
}
EXPECTED_FIELDS = [
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
EXPECTED_PRESETS = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
EXPECTED_RENDERER_IDS_HASH = "6d94e0f3a755932a7b1f257830068a42f855b2ec4fcc143dc8bf9ec3d624d251"
FORBIDDEN_PUBLIC_IDENTITIES = [
    "uppereyelidfullness", "upperlidfullness", "eyelidfullness", "lidfullness",
    "uppereyelidfatreduction", "upperlidfatreduction", "eyelidfatreduction",
    "lidfatreduction", "uppereyelidfatremoval", "upperlidfatremoval",
    "eyelidfatremoval", "lidfatremoval", "uppereyeliddefatting",
    "upperliddefatting", "eyeliddefatting", "liddefatting",
    "upper_eyelid_fullness", "upper_lid_fullness", "eyelid_fullness",
    "lid_fullness", "remove_upper_eyelid_fat", "remove_eyelid_fat",
    "remove_upper_lid_fat", "remove_lid_fat", "eyes.fat", "去脂",
]


class GateError(Exception):
    """A normalized, privacy-safe gate failure."""


def fail(reason: str) -> None:
    raise GateError(reason)


def read_regular(root: Path, relative: Path) -> str:
    candidate = root / relative
    try:
        if candidate.is_symlink() or not candidate.is_file():
            fail("decision.input-missing")
        return candidate.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        fail("decision.input-unreadable")


def node_json_normalized(value: Any) -> Any:
    if isinstance(value, float) and math.isfinite(value) and value.is_integer():
        return int(value)
    if isinstance(value, list):
        return [node_json_normalized(entry) for entry in value]
    if isinstance(value, dict):
        return {key: node_json_normalized(entry) for key, entry in value.items()}
    return value


def expected_contract_hash(root: Path) -> str:
    contract = read_regular(root, PHASE75_CONTRACT)
    match = re.search(
        r"<!-- CANONICAL_EVIDENCE_RECORDS_BEGIN -->\n```json\n([\s\S]*?)\n```\n"
        r"<!-- CANONICAL_EVIDENCE_RECORDS_END -->",
        contract,
    )
    if match is None:
        fail("decision.contract-records-missing")
    try:
        records = node_json_normalized(json.loads(match.group(1)))
    except (json.JSONDecodeError, TypeError, ValueError):
        fail("decision.contract-records-malformed")
    canonical = json.dumps(records, ensure_ascii=False, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def execute_phase78(root: Path) -> str:
    module = root / PHASE78_MODULE
    if module.is_symlink() or not module.is_file():
        fail("decision.program-missing")
    # Use the archived module's exported decision function so nested machine JSON
    # is serialized without the historical CLI's nested-key replacer bug.
    expression = (
        "const p=require('node:path');"
        "const gate=require(p.resolve(process.argv[1]));"
        "process.stdout.write(JSON.stringify(gate.decide()));"
    )
    try:
        child = subprocess.run(
            ["node", "-e", expression, str(module)],
            cwd=root,
            check=False,
            capture_output=True,
            text=True,
            timeout=20,
        )
    except (OSError, subprocess.SubprocessError):
        fail("decision.program-failure")
    if child.returncode != 0 or child.stderr or not child.stdout:
        fail("decision.program-failure")
    if len(child.stdout.encode("utf-8")) > 65_536:
        fail("decision.output-oversize")
    return child.stdout


def privacy_safe(value: Any) -> bool:
    if isinstance(value, dict):
        return all(
            isinstance(key, str)
            and not SENSITIVE_KEY_RE.search(key)
            and privacy_safe(entry)
            for key, entry in value.items()
        )
    if isinstance(value, list):
        return all(privacy_safe(entry) for entry in value)
    if isinstance(value, str):
        return (
            "/" not in value
            and "\\" not in value
            and "\n" not in value
            and "\r" not in value
            and not SENSITIVE_KEY_RE.search(value)
        )
    return value is None or isinstance(value, (bool, int, float))


def parse_decision_output(raw: str, contract_hash: str) -> dict[str, Any]:
    if not raw or not raw.strip():
        fail("decision.output-missing")
    if len(raw.encode("utf-8")) > 65_536:
        fail("decision.output-oversize")
    try:
        report = json.loads(raw)
    except (json.JSONDecodeError, TypeError, UnicodeError):
        fail("decision.output-json")
    if not isinstance(report, dict) or set(report) != TOP_LEVEL_KEYS:
        fail("decision.schema")
    if not privacy_safe(report):
        fail("decision.privacy")
    if report["status"] not in {"pass", "fail"} or report["phase"] != PHASE:
        fail("decision.identity")
    if not isinstance(report["contract_hash"], str) or not HASH_RE.fullmatch(report["contract_hash"]):
        fail("decision.contract-hash")
    if report["contract_hash"] != contract_hash:
        fail("decision.contract-hash")
    manifest_hash = report["manifest_hash"]
    if manifest_hash is not None and (not isinstance(manifest_hash, str) or not HASH_RE.fullmatch(manifest_hash)):
        fail("decision.manifest-hash")

    fixture_ids = report["fixture_ids"]
    if (
        not isinstance(fixture_ids, list)
        or any(not isinstance(value, str) or not OPAQUE_ID_RE.fullmatch(value) for value in fixture_ids)
        or fixture_ids != sorted(set(fixture_ids))
    ):
        fail("decision.fixture-ids")

    metrics = report["aggregate_metrics"]
    if not isinstance(metrics, dict) or set(metrics) != METRIC_KEYS:
        fail("decision.metrics-schema")
    if metrics["baseline"] != "deterministic-editor" or metrics["baseline_disposition"] != "mechanics-only":
        fail("decision.baseline-binding")
    if metrics["comparator"] != "optional-additive-map":
        fail("decision.comparator-binding")
    if metrics["comparator_disposition"] not in {"not-admitted", "admitted-superior"}:
        fail("decision.comparator-binding")
    if type(metrics["fixture_count"]) is not int or metrics["fixture_count"] < 0:
        fail("decision.fixture-count")
    if metrics["fixture_count"] != len(fixture_ids):
        fail("decision.fixture-count")
    for key in ["genuine_evaluation_executed", "frozen_review_complete", "safety_gates_pass"]:
        if type(metrics[key]) is not bool:
            fail("decision.metrics-type")

    reason_counts = report["reason_counts"]
    if (
        not isinstance(reason_counts, dict)
        or not reason_counts
        or any(not isinstance(key, str) or not REASON_RE.fullmatch(key) for key in reason_counts)
        or any(type(value) is not int or value <= 0 for value in reason_counts.values())
    ):
        fail("decision.reasons")
    if report["decision"] not in DECISIONS:
        fail("decision.value")
    if report["status"] == "fail" and report["decision"] != MECHANICS_DECISION:
        fail("decision.status-binding")
    if report["status"] == "pass" and report["decision"] not in PROMOTION_DECISIONS:
        fail("decision.status-binding")
    return report


def select_current_branch(report: dict[str, Any]) -> str:
    metrics = report["aggregate_metrics"]
    if report["status"] != "fail" or report["decision"] != MECHANICS_DECISION:
        fail("decision.current-branch")
    if report["manifest_hash"] is not None or report["fixture_ids"]:
        fail("decision.no-bundle-binding")
    if report["reason_counts"] != {"evidence.missing-bundle": 1}:
        fail("decision.no-bundle-reason")
    if metrics != {
        "baseline": "deterministic-editor",
        "baseline_disposition": "mechanics-only",
        "comparator": "optional-additive-map",
        "comparator_disposition": "not-admitted",
        "fixture_count": 0,
        "genuine_evaluation_executed": False,
        "frozen_review_complete": False,
        "safety_gates_pass": False,
    }:
        fail("decision.no-bundle-metrics")
    return BRANCH


def renderer_ids_hash(renderer_ids: list[str]) -> str:
    encoded = json.dumps(renderer_ids, separators=(",", ":"))
    return hashlib.sha256(encoded.encode("utf-8")).hexdigest()


def public_absence_errors(root: Path) -> list[str]:
    parameters = read_regular(root, PARAMETERS)
    renderer = read_regular(root, RENDERER)
    manifest_text = read_regular(root, RESOURCE_MANIFEST)
    package = read_regular(root, PACKAGE)
    errors: list[str] = []

    parameter_head = parameters.split("enum CodingKeys", 1)[0]
    fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9_]*):", parameter_head, re.MULTILINE)
    if fields != EXPECTED_FIELDS:
        errors.append("absence.parameters.fields")
    coding_match = re.search(r"enum CodingKeys: String, CodingKey \{(?P<body>[\s\S]*?)\n\s*\}", parameters)
    coding_keys = (
        re.findall(r"^\s*case ([A-Za-z][A-Za-z0-9_]*)\s*$", coding_match.group("body"), re.MULTILINE)
        if coding_match
        else []
    )
    if coding_keys != EXPECTED_FIELDS:
        errors.append("absence.parameters.coding-keys")

    try:
        manifest = json.loads(manifest_text)
    except json.JSONDecodeError:
        manifest = None
    preset_ids = (
        [row.get("id") for row in manifest.get("presets", []) if isinstance(row, dict)]
        if isinstance(manifest, dict) and manifest.get("schemaVersion") == 1
        else []
    )
    if preset_ids != EXPECTED_PRESETS:
        errors.append("absence.presets")

    renderer_ids = re.findall(r'^\s*id: "([^"]+)"', renderer, re.MULTILINE)
    if (
        len(renderer_ids) != 74
        or len(set(renderer_ids)) != 74
        or renderer_ids_hash(renderer_ids) != EXPECTED_RENDERER_IDS_HASH
    ):
        errors.append("absence.renderer.cases")

    facade_sources = []
    facade_root = root / SDK_FACADE
    if facade_root.is_symlink() or not facade_root.is_dir():
        errors.append("absence.facade")
    else:
        for source in sorted(facade_root.rglob("*.swift")):
            if source.is_symlink() or not source.is_file():
                errors.append("absence.facade")
                continue
            try:
                facade_sources.append(source.read_text(encoding="utf-8"))
            except (OSError, UnicodeError):
                errors.append("absence.facade")
    exposed_text = "\n".join([parameters, renderer, manifest_text, package, *facade_sources]).lower()
    if any(identity in exposed_text for identity in FORBIDDEN_PUBLIC_IDENTITIES):
        errors.append("absence.public-or-spi-route")
    return sorted(set(errors))


def live_result(root: Path) -> dict[str, Any]:
    contract_hash = expected_contract_hash(root)
    report = parse_decision_output(execute_phase78(root), contract_hash)
    branch = select_current_branch(report)
    errors = public_absence_errors(root)
    if errors:
        fail(errors[0])
    return {
        "branch": branch,
        "contract_hash": contract_hash,
        "decision": report["decision"],
        "fields": 61,
        "mode": "live",
        "phase": PHASE,
        "presets": 5,
        "reason": "evidence.missing-bundle",
        "renderer_cases": 74,
        "status": "pass",
    }


def expect_rejected(action: Callable[[], Any]) -> bool:
    try:
        action()
    except GateError:
        return True
    return False


def self_test(root: Path) -> dict[str, Any]:
    contract_hash = expected_contract_hash(root)
    raw = execute_phase78(root)
    report = parse_decision_output(raw, contract_hash)
    if select_current_branch(report) != BRANCH or public_absence_errors(root):
        fail("decision.self-test-baseline")

    replacement = copy.deepcopy(report)
    replacement["decision"] = "promotion-ready-baseline"
    missing_decision = copy.deepcopy(report)
    del missing_decision["decision"]
    invalid_hash = copy.deepcopy(report)
    invalid_hash["contract_hash"] = "0" * 64
    missing_reason = copy.deepcopy(report)
    missing_reason["reason_counts"] = {"candidate.baseline-selected": 1}
    sensitive = copy.deepcopy(report)
    sensitive["private_locator"] = "forbidden"

    mutations: list[Callable[[], Any]] = [
        lambda: parse_decision_output(json.dumps(replacement), contract_hash),
        lambda: parse_decision_output('{"status":', contract_hash),
        lambda: parse_decision_output("", contract_hash),
        lambda: parse_decision_output(json.dumps(missing_decision), contract_hash),
        lambda: parse_decision_output(json.dumps(invalid_hash), contract_hash),
        lambda: select_current_branch(parse_decision_output(json.dumps(missing_reason), contract_hash)),
        lambda: parse_decision_output(json.dumps(sensitive), contract_hash),
    ]
    rejected = sum(expect_rejected(mutation) for mutation in mutations)
    if rejected != len(mutations):
        fail("decision.self-test-mutation")
    return {
        "branch": BRANCH,
        "checks": 7,
        "decision": MECHANICS_DECISION,
        "mode": "self-test",
        "mutation_rejections": rejected,
        "phase": PHASE,
        "status": "pass",
    }


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--live", action="store_true")
    modes.add_argument("--self-test", action="store_true")
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()
    root = Path(args.repo_root).resolve()
    try:
        result = self_test(root) if args.self_test else live_result(root)
    except GateError as error:
        result = {
            "mode": "self-test" if args.self_test else "live",
            "phase": PHASE,
            "reason_count": 1,
            "reasons": [str(error)],
            "status": "fail",
        }
        print(json.dumps(result, sort_keys=True, separators=(",", ":")))
        return 1
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
