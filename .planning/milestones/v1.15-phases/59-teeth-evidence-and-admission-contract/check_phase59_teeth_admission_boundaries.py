#!/usr/bin/env python3
"""Fail-closed Phase 59 exact-open evidence and admission checker."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import pathlib
import re
import subprocess
import sys
from collections.abc import Callable


ROOT = pathlib.Path(__file__).resolve().parents[3]
PHASE_NAME = "59-teeth-evidence-and-admission-contract"
THREAT_IDS = tuple(f"T-59-{index:02d}" for index in range(1, 9))
REQUIREMENTS = ("SEQ-01", "EVID-07", "TEETH-07", "TEETH-08")

ROOT_KEYS = ("schema_version", "feature_decisions", "reviews", "aggregates")
DECISION_KEYS = (
    "feature", "status", "reasons", "eligible_count", "reviewed_count",
    "accepted_count", "rejected_count", "naturalness_weight",
)
REVIEW_KEYS = (
    "fixture_id", "feature", "polarity", "target_present", "mask_coverage",
    "protected_leakage", "naturalness", "structure_changed", "decision", "reason_code",
)
AGGREGATE_KEYS = (
    "feature", "eligible_count", "reviewed_count", "accepted_count",
    "rejected_count", "naturalness_weight",
)

EXPECTED_DECISIONS = {
    "teeth_whitening": {
        "feature": "teeth_whitening", "status": "open", "reasons": [],
        "eligible_count": 2, "reviewed_count": 2, "accepted_count": 2,
        "rejected_count": 0, "naturalness_weight": 2,
    },
    "sclera_redness": {
        "feature": "sclera_redness", "status": "closed",
        "reasons": ["missing_genuine_positive", "missing_genuine_negative"],
        "eligible_count": 0, "reviewed_count": 0, "accepted_count": 0,
        "rejected_count": 0, "naturalness_weight": 0,
    },
    "upper_eyelid_fullness": {
        "feature": "upper_eyelid_fullness", "status": "closed",
        "reasons": [
            "missing_genuine_positive", "missing_genuine_negative",
            "non_warp_design_unqualified",
        ],
        "eligible_count": 0, "reviewed_count": 0, "accepted_count": 0,
        "rejected_count": 0, "naturalness_weight": 0,
    },
}
EXPECTED_REVIEWS = {
    ("teeth_whitening", "positive", "teeth_fixture_001"): {
        "fixture_id": "teeth_fixture_001", "feature": "teeth_whitening",
        "polarity": "positive", "target_present": True, "mask_coverage": 4,
        "protected_leakage": False, "naturalness": 4,
        "structure_changed": False, "decision": "accept", "reason_code": "none",
    },
    ("teeth_whitening", "negative", "teeth_fixture_002"): {
        "fixture_id": "teeth_fixture_002", "feature": "teeth_whitening",
        "polarity": "negative", "target_present": False, "mask_coverage": 1,
        "protected_leakage": False, "naturalness": 4,
        "structure_changed": False, "decision": "accept", "reason_code": "none",
    },
}
EXPECTED_AGGREGATES = {
    feature: {key: value for key, value in row.items() if key not in {"status", "reasons"}}
    for feature, row in EXPECTED_DECISIONS.items()
}

EXPECTED_PARAMETER_FIELDS = (
    "skinSmoothing", "skinWhitening", "skinRosy", "skinSharpen",
    "brightness", "contrast", "saturation", "temperature", "tint", "exposure",
    "highlight", "shadow", "faceSlim", "faceSmall", "faceVShape", "jawSlim",
    "chinLength", "faceContourSmooth", "templeFullness", "cheekboneSlim", "chinTaper",
    "eyeSize", "eyeDistance", "eyeYPosition", "eyeTailLift", "eyeHeight", "eyeLength",
    "upperEyelidLift", "pupilSize", "gazeCorrection", "lowerEyelidDrop", "eyeTilt",
    "innerCornerOpen", "outerCornerOpen", "eyeSymmetry", "eyebrowYPosition",
    "eyebrowThickness", "eyebrowLength", "eyebrowSpacing", "eyebrowHeadSpacing",
    "eyebrowTilt", "eyebrowPeakDefinition", "noseSlim", "noseWingSlim", "noseTipSize",
    "noseBridge", "noseRootNarrowing", "noseTipLift", "mouthSize", "mouthWidth",
    "smile", "mouthYPosition", "mouthTilt", "mouthXPosition", "lipPeakDefinition",
    "lipPlump", "lipColor", "filterId", "filterIntensity", "teethWhitening",
)

EXPECTED_RENDERER_CASES = (
    "skinSmoothing_0p50", "skinWhitening_0p50", "skinRosy_0p40", "skinSharpen_0p40",
    "brightness_plus0p25", "contrast_plus0p25", "filter_softClean_0p50",
    "filter_warmLight_0p50", "skinCombo_0p50", "geometryBaseline_noop",
    "faceShapeCombo_0p35", "faceSlim_0p35", "faceSmall_0p35", "chinLength_plus0p30",
    "chinLength_minus0p30", "faceVShape_0p35", "jawSlim_0p35",
    "faceContourSmooth_0p25", "templeFullness_0p25", "cheekboneSlim_0p25",
    "chinTaper_0p25", "eyeSize_0p35", "eyeDistance_plus0p25",
    "eyeDistance_minus0p25", "eyeYPosition_plus0p20", "eyeYPosition_minus0p20",
    "eyeTailLift_0p25", "eyeHeight_0p25", "eyeLength_0p25", "upperEyelidLift_0p25",
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
    "mouthYPosition_plus0p25", "mouthYPosition_minus0p25", "mouthTilt_plus0p25",
    "mouthTilt_minus0p25", "mouthXPosition_plus0p25", "mouthXPosition_minus0p25",
    "lipPeakDefinition_0p25", "lipPlump_0p25",
)

EXPECTED_PRESET_HASHES = {
    "clear.json": "58327c8ef8cc8323d4a6e4d98754d8c9bf797b348804ca2a308c4c39e00856f8",
    "id-photo-natural.json": "d6d2d3e5872ae0aa25823c4d76e07057ecdfa336818cd116509627995941c609",
    "male-natural.json": "1c6e632e8740602fa662c42e41cf9709eec29b3138bf58df43fad40d8b5d0c08",
    "natural.json": "bd102ec3643f1625d561af66fd0e7fb67c33fe5061720600907ed3fd931a08da",
    "refined.json": "67f238fddf8d9dc08bc8b24121af25d11f9caf8a85b905cf83a47b0dff675722",
}

EXPECTED_THREATS = {
    "T-59-01": ["canonical open decision", "exact counts", "closed sibling preservation"],
    "T-59-02": ["frozen criteria", "exact structured reviews", "serializer provenance"],
    "T-59-03": ["open evidence branch", "trailing scalar", "one opaque demand"],
    "T-59-04": ["append-only compatibility", "legacy decode", "neutral presets"],
    "T-59-05": ["teeth-only admission", "alias rejection", "sclera/去脂 absence"],
    "T-59-06": ["schema allowlist", "disabled Demo taxonomy", "tracked/staged privacy"],
    "T-59-07": ["no provider", "no renderer output", "no realtime/model/network"],
    "T-59-08": ["owner synchronization", "17-task lifecycle", "fail-closed scanner"],
}

SENSITIVE_KEY = re.compile(
    r"(?:^|_)(?:path|filepath|filename|sha256|hash|digest|rights|reviewer|freeform|"
    r"raw_error|raw_mask|geometry|pixel|coordinate|landmark|media|scanner_match)(?:$|_)",
    re.IGNORECASE,
)
SENSITIVE_VALUE = re.compile(
    r"(?:/(?:Users|private|var|tmp)/|[A-Fa-f0-9]{64}|(?:reviewer|freeform|raw error)\s*[:=])",
    re.IGNORECASE,
)
FORBIDDEN_ALIAS = re.compile(
    r"\b(?:teethWhite|toothWhitening|teethBrightness|scleraRednessReduction|"
    r"upperEyelidFullnessReduction)\b|去脂"
)
FORBIDDEN_DOWNSTREAM = re.compile(
    r"(?i)(?:teeth|tooth|enamel|dentition)[A-Za-z0-9_]*"
    r"(?:Provider|Mask|Transform|Renderer|Output|Realtime|PixelBuffer|Model|Network)"
)


def configure_root(root: pathlib.Path) -> None:
    global ROOT, PHASE, DECISIONS, CONTRACT, VALIDATION, INVENTORY, PRIVATE_RUNNER
    global PARAMETERS, RESOLVER, SOURCES, PRESETS, RENDERER, DEMO_SOURCES, DEMO_MODELS
    ROOT = root.resolve()
    PHASE = ROOT / ".planning" / "phases" / PHASE_NAME
    DECISIONS = ROOT / ".planning" / "milestones" / "v1.14-phases" / "54-rights-approved-evidence-and-eligibility-decisions" / "54-EVIDENCE-DECISIONS.json"
    CONTRACT = PHASE / "59-EVIDENCE-ADMISSION-CONTRACT.md"
    VALIDATION = PHASE / "59-VALIDATION.md"
    INVENTORY = PHASE / "59-THREAT-INVENTORY.json"
    PRIVATE_RUNNER = PHASE / "59-private-evidence-runner.js"
    PARAMETERS = ROOT / "BeautySDK" / "Sources" / "BeautyCore" / "Models" / "BeautyParameters.swift"
    RESOLVER = ROOT / "BeautySDK" / "Sources" / "BeautyEffects" / "Planning" / "BeautyEffectResolver.swift"
    SOURCES = ROOT / "BeautySDK" / "Sources"
    PRESETS = ROOT / "BeautySDK" / "Sources" / "BeautyResources" / "Resources" / "Presets"
    RENDERER = ROOT / "BeautySDK" / "Sources" / "BeautyExampleRenderer" / "main.swift"
    DEMO_SOURCES = ROOT / "BeautyDemo" / "BeautyDemo"
    DEMO_MODELS = DEMO_SOURCES / "Editor" / "MeituEditorToolModels.swift"


configure_root(ROOT)


class ScannerFailure(RuntimeError):
    pass


def read_json(path: pathlib.Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def exact_key_set(value: object, expected: tuple[str, ...]) -> bool:
    return isinstance(value, dict) and set(value) == set(expected)


def rows_by_identity(rows: object, identity: Callable[[dict[str, object]], object]) -> dict[object, dict[str, object]] | None:
    if not isinstance(rows, list) or not all(isinstance(row, dict) for row in rows):
        return None
    keyed: dict[object, dict[str, object]] = {}
    for row in rows:
        key = identity(row)
        if key in keyed:
            return None
        keyed[key] = row
    return keyed


def decision_errors(document: object) -> list[str]:
    if not isinstance(document, dict) or document.get("schema_version") != 1:
        return ["root"]
    rows = rows_by_identity(document.get("feature_decisions"), lambda row: row.get("feature"))
    aggregates = rows_by_identity(document.get("aggregates"), lambda row: row.get("feature"))
    errors: list[str] = []
    if rows is None or set(rows) != set(EXPECTED_DECISIONS):
        errors.append("decision-identities")
    else:
        for feature, expected in EXPECTED_DECISIONS.items():
            if not exact_key_set(rows[feature], DECISION_KEYS) or rows[feature] != expected:
                errors.append(f"decision-{feature}")
    if aggregates is None or set(aggregates) != set(EXPECTED_AGGREGATES):
        errors.append("aggregate-identities")
    else:
        for feature, expected in EXPECTED_AGGREGATES.items():
            if not exact_key_set(aggregates[feature], AGGREGATE_KEYS) or aggregates[feature] != expected:
                errors.append(f"aggregate-{feature}")
    return errors


def review_errors(document: object) -> list[str]:
    if not isinstance(document, dict):
        return ["root"]
    rows = rows_by_identity(
        document.get("reviews"),
        lambda row: (row.get("feature"), row.get("polarity"), row.get("fixture_id")),
    )
    if rows is None or set(rows) != set(EXPECTED_REVIEWS):
        return ["review-identities"]
    errors = []
    for identity, expected in EXPECTED_REVIEWS.items():
        if not exact_key_set(rows[identity], REVIEW_KEYS) or rows[identity] != expected:
            errors.append(f"review-{identity[1]}")
    return errors


def privacy_schema_errors(document: object) -> list[str]:
    if not exact_key_set(document, ROOT_KEYS):
        return ["root-schema"]
    errors = decision_errors(document) + review_errors(document)
    for key, value in walk(document):
        if key is not None and SENSITIVE_KEY.search(key):
            errors.append("sensitive-key")
        if isinstance(value, str) and SENSITIVE_VALUE.search(value):
            errors.append("sensitive-value")
    return errors


def walk(value: object, key: str | None = None):
    yield key, value
    if isinstance(value, dict):
        for child_key, child in value.items():
            yield from walk(child, str(child_key))
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)


def model_errors(source: str) -> list[str]:
    prefix, marker, remainder = source.partition("    enum CodingKeys: String, CodingKey {")
    coding, end_marker, _ = remainder.partition("\n    }")
    init_match = re.search(r"public init\(\n(?P<body>.*?)\n    \) \{", source, re.DOTALL)
    properties = tuple(re.findall(r"(?m)^    public var ([A-Za-z0-9_]+):", prefix))
    coding_keys = tuple(re.findall(r"(?m)^        case ([A-Za-z0-9_]+)$", coding))
    init_labels = tuple(re.findall(r"(?m)^        ([A-Za-z0-9_]+):", init_match.group("body") if init_match else ""))
    errors = []
    if not marker or not end_marker or properties != EXPECTED_PARAMETER_FIELDS:
        errors.append("stored-order")
    if coding_keys != EXPECTED_PARAMETER_FIELDS:
        errors.append("coding-order")
    if init_labels != EXPECTED_PARAMETER_FIELDS:
        errors.append("initializer-order")
    required = (
        "public var teethWhitening: Float",
        "teethWhitening: Float = 0",
        "self.teethWhitening = Self.clampUnit(teethWhitening)",
        "teethWhitening: try container.decodeFloatIfPresent(.teethWhitening)",
        "teethWhitening: teethWhitening",
    )
    for snippet in required:
        if source.count(snippet) != 1:
            errors.append("teeth-seam")
    if len(properties) != 60 or properties[-1:] != ("teethWhitening",):
        errors.append("field-count")
    return errors


def admission_body(source: str) -> str:
    match = re.search(
        r"package static func localRetouchAdmission\(.*?\n    \}\n\n    package static func resolve\(",
        source,
        re.DOTALL,
    )
    return match.group(0) if match else ""


def admission_errors(source: str) -> list[str]:
    body = admission_body(source)
    required_counts = {
        "parameters.normalized()": 1,
        "normalized.teethWhitening > 0": 1,
        "BeautyLocalRetouchAdmission(opaqueDemandCount: 1)": 1,
        ": .none": 1,
    }
    errors = [name for name, count in required_counts.items() if body.count(name) != count]
    if body.count("teethWhitening") != 1 or FORBIDDEN_ALIAS.search(body):
        errors.append("alias-or-sibling")
    for forbidden in (
        "skinWhitening", "brightness", "contrast", "lipColor", "mouth", "eye",
        "Testing", "Provider", "Mask", "Renderer", "Output", "opaqueDemandCount: 2",
    ):
        if forbidden in body:
            errors.append("forbidden-input")
    return errors


def preset_errors(contents: dict[str, bytes] | None = None) -> list[str]:
    if contents is None:
        try:
            contents = {path.name: path.read_bytes() for path in PRESETS.glob("*.json")}
        except OSError:
            return ["preset-read"]
    if set(contents) != set(EXPECTED_PRESET_HASHES):
        return ["preset-inventory"]
    errors = []
    for name, expected_hash in EXPECTED_PRESET_HASHES.items():
        data = contents[name]
        if hashlib.sha256(data).hexdigest() != expected_hash:
            errors.append(f"preset-hash-{name}")
        try:
            parameters = json.loads(data).get("parameters", {})
        except (UnicodeDecodeError, json.JSONDecodeError, AttributeError):
            errors.append(f"preset-json-{name}")
            continue
        if any(key in parameters for key in ("teethWhitening", "scleraRednessReduction", "upperEyelidFullnessReduction")):
            errors.append(f"preset-local-retouch-{name}")
    return errors


def renderer_errors(source: str) -> list[str]:
    case_ids = tuple(re.findall(r'(?m)\bid: "([A-Za-z0-9_]+)"', source))
    errors = []
    if case_ids != EXPECTED_RENDERER_CASES or len(set(case_ids)) != 72:
        errors.append("renderer-inventory")
    if source.count("engine.processResult(") != 1:
        errors.append("renderer-output-owner")
    if re.search(r"teethWhitening|teethWhite|toothWhitening|teethBrightness|scleraRednessReduction|upperEyelidFullnessReduction|去脂", source):
        errors.append("renderer-local-retouch")
    if FORBIDDEN_DOWNSTREAM.search(source):
        errors.append("renderer-downstream")
    return errors


def demo_errors(model_source: str, all_source: str) -> list[str]:
    expected_rows = (
        'unsupported("lips.teeth", title: "白牙", icon: "sparkles")',
        'unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)',
        'unsupported("eyes.redness", title: "祛红血丝", icon: "drop", badge: .free)',
    )
    errors = [row for row in expected_rows if model_source.count(row) != 1]
    for identifier in ("lips.teeth", "eyes.fat", "eyes.redness"):
        if model_source.count(identifier) != 1:
            errors.append("demo-row-count")
    if re.search(r'(?m)^\s*supported\("(?:lips\.teeth|eyes\.fat|eyes\.redness)"', model_source):
        errors.append("demo-activation")
    if re.search(r"teethWhitening|scleraRednessReduction|upperEyelidFullnessReduction", all_source):
        errors.append("demo-mapping")
    return errors


def production_errors(files: dict[str, str] | None = None) -> list[str]:
    if files is None:
        try:
            files = {str(path.relative_to(SOURCES)): path.read_text(encoding="utf-8") for path in SOURCES.rglob("*.swift")}
        except (OSError, UnicodeError):
            return ["source-read"]
    errors = []
    allowed_teeth_files = {
        "BeautyCore/Models/BeautyParameters.swift",
        "BeautyEffects/Planning/BeautyEffectResolver.swift",
    }
    for relative, source in files.items():
        if "teethWhitening" in source and relative not in allowed_teeth_files:
            errors.append("teeth-surface")
        if FORBIDDEN_DOWNSTREAM.search(source):
            errors.append("teeth-downstream")
        if re.search(r"scleraRednessReduction|upperEyelidFullnessReduction|去脂", source):
            errors.append("sibling-surface")
    return errors


def exact_threat_inventory(document: object) -> bool:
    if not isinstance(document, dict) or set(document) != {"schema_version", "security_standard", "block_on", "threats"}:
        return False
    if document.get("schema_version") != 1 or document.get("security_standard") != "OWASP ASVS Level 1" or document.get("block_on") != "HIGH":
        return False
    threats = document.get("threats")
    if not isinstance(threats, list) or len(threats) != len(THREAT_IDS):
        return False
    for row, threat_id in zip(threats, THREAT_IDS):
        if row != {
            "id": threat_id,
            "severity": "HIGH",
            "disposition": "mitigate",
            "gates": EXPECTED_THREATS[threat_id],
        }:
            return False
    return True


def owner_errors(contract: str, validation: str, inventory: object) -> list[str]:
    errors = []
    for pattern in (r"phase:\s*59", r"decision:\s*open", r"status:\s*admitted-intent-only"):
        if not re.search(pattern, contract):
            errors.append("contract-frontmatter")
    for requirement in REQUIREMENTS:
        if requirement not in contract or requirement not in validation:
            errors.append("requirement")
    required_nonclaims = ("no provider", "no renderer output", "no Demo mapping", "no product promotion")
    lowered = contract.lower()
    for claim in required_nonclaims:
        if claim.lower() not in lowered:
            errors.append("nonclaim")
    task_ids = re.findall(r"\| `((?:59-(?:0[1-9])-(?:0[1-3])))` \|", validation)
    expected_tasks = (
        "59-01-01", "59-01-02", "59-01-03", "59-02-01", "59-02-02",
        "59-03-01", "59-03-02", "59-04-01", "59-04-02", "59-05-01",
        "59-05-02", "59-06-01", "59-06-02", "59-07-01", "59-07-02",
        "59-08-01", "59-09-01",
    )
    if tuple(task_ids) != expected_tasks or "Task count equality target: **17" not in validation:
        errors.append("task-lifecycle")
    if not exact_threat_inventory(inventory):
        errors.append("threat-inventory")
    return errors


def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise ScannerFailure("unclassified scanner outcome")


def classify_private_scan(returncode: int, stdout: str, stderr: str) -> bool:
    if returncode != 0 or stderr or len(stdout.strip().splitlines()) != 1:
        return False
    if "/" in stdout or "\\" in stdout:
        return False
    try:
        value = json.loads(stdout)
    except json.JSONDecodeError:
        return False
    return (
        isinstance(value, dict)
        and set(value) == {"status", "tracked_file_count"}
        and value.get("status") == "pass"
        and type(value.get("tracked_file_count")) is int
        and value["tracked_file_count"] > 0
    )


def private_scan_errors() -> list[str]:
    try:
        result = subprocess.run(
            ["node", str(PRIVATE_RUNNER), "--scan-tracked-staged"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return ["privacy-runner"]
    return [] if classify_private_scan(result.returncode, result.stdout, result.stderr) else ["privacy-runner"]


def load_text(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


def load_all_demo_source() -> str:
    return "\n".join(load_text(path) for path in sorted(DEMO_SOURCES.rglob("*.swift")))


def load_all_source_files() -> dict[str, str]:
    return {str(path.relative_to(SOURCES)): load_text(path) for path in sorted(SOURCES.rglob("*.swift"))}


def threat_check(threat_id: str, *, invoke_private: bool = True) -> tuple[int, list[str]]:
    try:
        document = read_json(DECISIONS)
        if threat_id == "T-59-01":
            errors = decision_errors(document)
            return 6, errors
        if threat_id == "T-59-02":
            errors = review_errors(document)
            contract = load_text(CONTRACT)
            for phrase in ("criteria frozen before review", "Phase 54 serializer", "structured reviews"):
                if phrase.lower() not in contract.lower():
                    errors.append("review-contract")
            return 5, errors
        if threat_id == "T-59-03":
            errors = decision_errors(document)
            errors += model_errors(load_text(PARAMETERS))
            errors += admission_errors(load_text(RESOLVER))
            return 10, errors
        if threat_id == "T-59-04":
            errors = model_errors(load_text(PARAMETERS)) + preset_errors()
            return 9, errors
        if threat_id == "T-59-05":
            errors = admission_errors(load_text(RESOLVER)) + production_errors(load_all_source_files())
            return 12, errors
        if threat_id == "T-59-06":
            errors = privacy_schema_errors(document)
            errors += demo_errors(load_text(DEMO_MODELS), load_all_demo_source())
            if invoke_private:
                errors += private_scan_errors()
            return 12, errors
        if threat_id == "T-59-07":
            errors = renderer_errors(load_text(RENDERER)) + production_errors(load_all_source_files())
            return 8, errors
        if threat_id == "T-59-08":
            errors = owner_errors(load_text(CONTRACT), load_text(VALIDATION), read_json(INVENTORY))
            return 8, errors
    except (OSError, UnicodeError, json.JSONDecodeError, TypeError, KeyError):
        return 1, ["missing-or-invalid"]
    return 0, ["unknown-threat"]


def failures_for(threat_ids: tuple[str, ...], *, invoke_private: bool = True) -> tuple[int, list[str]]:
    count = 0
    failures = []
    for threat_id in threat_ids:
        check_count, errors = threat_check(threat_id, invoke_private=invoke_private)
        count += check_count
        if check_count <= 0 or errors:
            failures.append(threat_id)
    return count, failures


def changed_value(value: object) -> object:
    if type(value) is bool:
        return not value
    if type(value) is int:
        return value + 1
    if isinstance(value, str):
        return value + "_mutated"
    if isinstance(value, list):
        return [*value, "unexpected"]
    return None


def assert_rejected(validator: Callable[[object], list[str]], document: object) -> None:
    if not validator(document):
        raise AssertionError("mutation accepted")


def self_test() -> int:
    cases = 0
    document = read_json(DECISIONS)
    assert not decision_errors(document)
    assert not review_errors(document)
    assert not privacy_schema_errors(document)
    cases += 3

    for list_name, keys, validator in (
        ("feature_decisions", DECISION_KEYS, decision_errors),
        ("reviews", REVIEW_KEYS, review_errors),
        ("aggregates", AGGREGATE_KEYS, decision_errors),
    ):
        for row_index, row in enumerate(document[list_name]):
            for key in keys:
                deleted = copy.deepcopy(document)
                del deleted[list_name][row_index][key]
                assert_rejected(validator, deleted)
                changed = copy.deepcopy(document)
                changed[list_name][row_index][key] = changed_value(row[key])
                assert_rejected(validator, changed)
                cases += 2
            extra = copy.deepcopy(document)
            extra[list_name][row_index]["unexpected"] = 1
            assert_rejected(validator, extra)
            cases += 1
        duplicated = copy.deepcopy(document)
        duplicated[list_name].append(copy.deepcopy(duplicated[list_name][0]))
        assert_rejected(validator, duplicated)
        missing = copy.deepcopy(document)
        missing[list_name].pop()
        assert_rejected(validator, missing)
        cases += 2

    for key in ROOT_KEYS:
        deleted = copy.deepcopy(document)
        del deleted[key]
        assert_rejected(privacy_schema_errors, deleted)
        cases += 1
    for sensitive_key, sensitive_value in (
        ("portrait_path", "opaque"), ("asset_digest", "opaque"),
        ("rights_detail", "opaque"), ("reviewer_note", "opaque"),
        ("freeform", "opaque"), ("raw_error", "opaque"),
        ("raw_mask", "opaque"), ("pixel_geometry", "opaque"),
    ):
        mutated = copy.deepcopy(document)
        mutated["reviews"][0][sensitive_key] = sensitive_value
        assert_rejected(privacy_schema_errors, mutated)
        cases += 1

    parameter_source = load_text(PARAMETERS)
    assert not model_errors(parameter_source)
    cases += 1
    for old, new in (
        ("public var teethWhitening: Float", "public var teethWhiteningAlias: Float"),
        ("case teethWhitening", "case teethWhiteningAlias"),
        ("teethWhitening: Float = 0", "teethWhiteningAlias: Float = 0"),
        ("self.teethWhitening = Self.clampUnit(teethWhitening)", "self.teethWhitening = Self.clampSigned(teethWhitening)"),
        ("teethWhitening: try container.decodeFloatIfPresent(.teethWhitening)", "teethWhitening: try container.decodeFloatIfPresent(.skinWhitening)"),
        ("teethWhitening: teethWhitening", "teethWhiteningAlias: teethWhitening"),
    ):
        assert model_errors(parameter_source.replace(old, new, 1))
        cases += 1
    assert model_errors(parameter_source.replace("    public var teethWhitening: Float\n", "", 1))
    assert model_errors(parameter_source.replace("    public var teethWhitening: Float\n", "    public var teethWhitening: Float\n    public var teethWhiteningAlias: Float\n", 1))
    cases += 2

    resolver_source = load_text(RESOLVER)
    assert not admission_errors(resolver_source)
    cases += 1
    resolver_body = admission_body(resolver_source)
    for old, new in (
        ("normalized.teethWhitening > 0", "normalized.skinWhitening > 0"),
        ("opaqueDemandCount: 1", "opaqueDemandCount: 2"),
        ("parameters.normalized()", "parameters"),
        (": .none", ": BeautyLocalRetouchAdmission(opaqueDemandCount: 1)"),
        ("normalized.teethWhitening > 0", "normalized.teethWhite > 0"),
        ("normalized.teethWhitening > 0", "normalized.scleraRednessReduction > 0"),
        ("normalized.teethWhitening > 0", "normalized.lipColor > 0"),
        ("normalized.teethWhitening > 0", "Testing.enabled || normalized.teethWhitening > 0"),
    ):
        mutated_body = resolver_body.replace(old, new, 1)
        assert mutated_body != resolver_body
        assert admission_errors(resolver_source.replace(resolver_body, mutated_body, 1))
        cases += 1

    renderer_source = load_text(RENDERER)
    assert not renderer_errors(renderer_source)
    cases += 1
    for old, new in (
        ('id: "skinSmoothing_0p50"', 'id: "teethWhitening_0p50"'),
        ("engine.processResult(", "engine.processResult(\n// engine.processResult("),
        ("import BeautySDK", "import BeautySDK\n// teethWhitening: 0.5"),
    ):
        assert renderer_errors(renderer_source.replace(old, new, 1))
        cases += 1

    preset_contents = {path.name: path.read_bytes() for path in PRESETS.glob("*.json")}
    assert not preset_errors(preset_contents)
    cases += 1
    for name in sorted(preset_contents):
        mutated = dict(preset_contents)
        mutated[name] += b" "
        assert preset_errors(mutated)
        cases += 1
    missing_preset = dict(preset_contents)
    missing_preset.pop(next(iter(missing_preset)))
    assert preset_errors(missing_preset)
    cases += 1

    model_source = load_text(DEMO_MODELS)
    all_demo = load_all_demo_source()
    assert not demo_errors(model_source, all_demo)
    cases += 1
    for identifier in ("lips.teeth", "eyes.fat", "eyes.redness"):
        assert demo_errors(model_source.replace(f'unsupported("{identifier}"', f'supported("{identifier}"', 1), all_demo)
        cases += 1
    assert demo_errors(model_source, all_demo + "\nteethWhitening")
    cases += 1

    inventory = read_json(INVENTORY)
    assert exact_threat_inventory(inventory)
    cases += 1
    for index in range(len(THREAT_IDS)):
        for key in ("id", "severity", "disposition", "gates"):
            mutated = copy.deepcopy(inventory)
            mutated["threats"][index][key] = changed_value(mutated["threats"][index][key])
            assert not exact_threat_inventory(mutated)
            cases += 1

    contract = load_text(CONTRACT)
    validation = load_text(VALIDATION)
    assert not owner_errors(contract, validation, inventory)
    cases += 1
    for old, new in (
        ("decision: open", "decision: closed"),
        ("status: admitted-intent-only", "status: promoted"),
        ("Task count equality target: **17", "Task count equality target: **16"),
    ):
        if old in contract:
            assert owner_errors(contract.replace(old, new, 1), validation, inventory)
        else:
            assert owner_errors(contract, validation.replace(old, new, 1), inventory)
        cases += 1

    assert classify_rg(0, "match", "") == "match"
    assert classify_rg(1, "", "") == "clean"
    cases += 2
    for returncode, stdout, stderr in ((2, "", "error"), (127, "", "error"), (1, "noise", "")):
        try:
            classify_rg(returncode, stdout, stderr)
        except ScannerFailure:
            cases += 1
        else:
            raise AssertionError("scanner failure accepted")
    assert classify_private_scan(0, '{"status":"pass","tracked_file_count":1}\n', "")
    cases += 1
    for returncode, stdout, stderr in (
        (1, '{"status":"fail","tracked_file_count":1}\n', ""),
        (0, '{"status":"pass","tracked_file_count":0}\n', ""),
        (0, '{"status":"pass","tracked_file_count":1,"matches":[]}\n', ""),
        (0, '{"status":"pass","tracked_file_count":1}\n/path', ""),
        (0, '{"status":"pass","tracked_file_count":1}\n', "raw"),
    ):
        assert not classify_private_scan(returncode, stdout, stderr)
        cases += 1

    if cases < 180:
        raise AssertionError("mutation matrix incomplete")
    return cases


def emit(status: str, *, check_count: int, failures: list[str] | None = None, threat_id: str | None = None) -> int:
    payload: dict[str, object] = {"checkCount": check_count, "status": status}
    if failures:
        payload["failedRuleIds"] = sorted(set(failures))
    if threat_id is not None:
        payload["ruleId"] = threat_id
    print(json.dumps(payload, sort_keys=True))
    return 0 if status == "pass" else 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--decision", action="store_true")
    parser.add_argument("--evidence-gate", action="store_true")
    parser.add_argument("--privacy", action="store_true")
    parser.add_argument("--threat")
    parser.add_argument("--repo-root", type=pathlib.Path)
    args = parser.parse_args()
    if args.repo_root is not None:
        configure_root(args.repo_root)
    try:
        if args.self_test:
            count = self_test()
            print(json.dumps({"mutationCaseCount": count, "status": "pass"}, sort_keys=True))
            return 0
        if args.threat is not None:
            if args.threat not in THREAT_IDS:
                return emit("fail", check_count=0, failures=["T-59-08"])
            count, failures = failures_for((args.threat,))
            if failures and failures != [args.threat]:
                return emit("fail", check_count=count, failures=[args.threat], threat_id=args.threat)
            return emit("fail" if failures else "pass", check_count=count, failures=failures, threat_id=args.threat)
        if args.decision:
            selected = ("T-59-01", "T-59-02")
        elif args.evidence_gate:
            selected = ("T-59-01", "T-59-02", "T-59-03")
        elif args.privacy:
            selected = ("T-59-06",)
        else:
            selected = THREAT_IDS
        count, failures = failures_for(selected)
        return emit("fail" if failures else "pass", check_count=count, failures=failures)
    except (OSError, UnicodeError, json.JSONDecodeError, TypeError, KeyError, AssertionError, ScannerFailure):
        return emit("fail", check_count=0, failures=["T-59-08"])


if __name__ == "__main__":
    sys.exit(main())
