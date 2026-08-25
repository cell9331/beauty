#!/usr/bin/env python3
"""Independent aggregate-only preflight for Phase-80 candidate v3."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import struct
import subprocess
from pathlib import Path
from typing import Any

PHASE = 80
VERSION = "phase80-qualification-evaluator-v3"
BASELINE = "single-sign-feathered-contour-editor-v3"
NON_PROMOTION = "qualification-not-passed"
CONTRACT_HASH = "aa3b6c2eb4b8ea8c4bd3812266b854c4ace00b3c78fb89dacbdaa70e7dff483a"
CONTRACT_FILE_HASH = "3006fea83e585d8c3086e590b14069f30fe3cacd29531a4aea7c48c98cd60d2a"
EVALUATOR_HASH = "7c2c94e13be4bd1b711aa4d927d1ff28cb1ae547394edab306922ce94b8ccdab"
EVALUATOR_TEST_HASH = "18f04b8ec6d00b35150661192c0edb5236c4314936051be17cc1628206acff95"
SOURCE_DIGEST = "94cdded98e18f8485116bb618f5bcc94f5778820196f7b687b0ca530ac380e52"
EVIDENCE_DIGEST = "c2f1073e5dc44ceb846570b0a85e75c706d671f366dac410a6257eeca2630653"
RUBRIC_HASH = "f6ef7e128e86e299e74f1b3bfd88aa333de50cc6171f1866a03b8f878c270393"
V2_CONTRACT_HASH = "26089df35213f15c58d56b99b814b7a6b0927e854299ed1617d8898d206188eb"
V2_EVALUATOR_HASH = "8edcd411b74dd226d97fce3b8da6576fcb3eb18b93234f20302b690473a2a80d"
V2_TEST_HASH = "15f9044afd724e7728f47f4e7df48e449319158fed1028e99a349f80f8ca4249"
V1_CONTRACT_HASH = "d3387b500c2e44e1d2b580845e1944f19ad77ccd85acb39162fbc186afb6b72e"
V1_EVALUATOR_HASH = "e1d94b4ac6531678483ad57a61a2a00b3b40d06aac6a0c51d6f565e63e1452a6"
V1_TEST_HASH = "b190add22925114f62947b8cbcb7b3766a63fd0ffde9f1f8730d622b4528a80c"

PD = Path(".planning/phases/80-genuine-evidence-and-qualification-gate")
V3 = PD / "v3"
CONTRACT = V3 / "80-V3-QUALIFICATION-CONTRACT.md"
EVALUATOR = V3 / "80-v3-qualification-decision.js"
EVALUATOR_TEST = V3 / "80-v3-qualification-decision.test.js"
SOURCE_OWNERS = (
    Path("BeautySDK/Sources/BeautyDetection/BeautyUpperEyelidSemanticSupport.swift"),
    Path("BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift"),
    Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyUpperEyelidFullnessEditor.swift"),
    Path("BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift"),
)
EVIDENCE_OWNERS = (
    Path("BeautySDK/Tests/BeautyDetectionTests/UpperEyelidSemanticSupportTests.swift"),
    Path("BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidEditorSafetyTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidFullnessEditorTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidPackageIntegrationTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidSupportCompositionTests.swift"),
)


class GateError(Exception):
    pass


def sha256(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def read(root: Path, relative: Path) -> bytes:
    target = root / relative
    try:
        if target.is_symlink() or not target.is_file():
            raise GateError("qualification.binding")
        return target.read_bytes()
    except OSError:
        raise GateError("qualification.binding") from None


def extract_record(text: str) -> dict[str, Any]:
    prefix = "<!-- CANONICAL_V3_QUALIFICATION_RECORDS_BEGIN -->\n```json\n"
    suffix = "\n```\n<!-- CANONICAL_V3_QUALIFICATION_RECORDS_END -->"
    start = text.find(prefix)
    finish = text.find(suffix, start + len(prefix))
    if start < 0 or finish < 0:
        raise GateError("qualification.binding")
    try:
        value = json.loads(text[start + len(prefix):finish])
    except (json.JSONDecodeError, UnicodeError):
        raise GateError("qualification.binding") from None
    if not isinstance(value, dict):
        raise GateError("qualification.binding")
    return value


def array_key(value: Any) -> bytes:
    if not isinstance(value, dict):
        return str(value).encode()
    return "\0".join(str(value[k]) for k in ("fixture_id", "category", "role", "sha256", "reason") if k in value).encode()


def canonicalize(value: Any) -> Any:
    if isinstance(value, list):
        return sorted((canonicalize(entry) for entry in value), key=array_key)
    if isinstance(value, dict):
        return {key: canonicalize(value[key]) for key in sorted(value, key=lambda item: item.encode())}
    if isinstance(value, float) and not math.isfinite(value):
        raise GateError("qualification.binding")
    return value


def canonical_hash(value: Any) -> str:
    return sha256(json.dumps(canonicalize(value), ensure_ascii=False, separators=(",", ":")).encode())


def owner_digest(root: Path, owners: tuple[Path, ...]) -> str:
    digest = hashlib.sha256()
    for owner in owners:
        content = read(root, owner)
        name = owner.as_posix().encode()
        digest.update(struct.pack(">I", len(name)))
        digest.update(name)
        digest.update(struct.pack(">Q", len(content)))
        digest.update(content)
    return digest.hexdigest()


def run_node(root: Path, mode: str) -> tuple[dict[str, Any], int]:
    try:
        child = subprocess.run(
            ["node", str(EVALUATOR), mode, "--repo-root", "."],
            cwd=root,
            capture_output=True,
            text=True,
            timeout=30,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        raise GateError("qualification.binding") from None
    if child.stderr or not child.stdout or len(child.stdout.encode()) > 1_048_576:
        raise GateError("qualification.binding")
    try:
        output = json.loads(child.stdout)
    except json.JSONDecodeError:
        raise GateError("qualification.binding") from None
    if not isinstance(output, dict):
        raise GateError("qualification.binding")
    return output, child.returncode


def check(root: Path) -> dict[str, Any]:
    files = (
        (CONTRACT, CONTRACT_FILE_HASH),
        (EVALUATOR, EVALUATOR_HASH),
        (EVALUATOR_TEST, EVALUATOR_TEST_HASH),
        (PD / "v2/80-V2-QUALIFICATION-CONTRACT.md", V2_CONTRACT_HASH),
        (PD / "v2/80-v2-qualification-decision.js", V2_EVALUATOR_HASH),
        (PD / "v2/80-v2-qualification-decision.test.js", V2_TEST_HASH),
        (PD / "80-QUALIFICATION-CONTRACT.md", V1_CONTRACT_HASH),
        (PD / "80-qualification-decision.js", V1_EVALUATOR_HASH),
        (PD / "80-qualification-decision.test.js", V1_TEST_HASH),
    )
    checks = 0
    for relative, expected in files:
        if sha256(read(root, relative)) != expected:
            raise GateError("qualification.binding")
        checks += 1
    record = extract_record(read(root, CONTRACT).decode())
    if canonical_hash(record) != CONTRACT_HASH:
        raise GateError("qualification.binding")
    checks += 1
    baseline = record.get("baseline_binding", {})
    if (
        record.get("version") != 3
        or record.get("evaluator_version") != VERSION
        or record.get("review_rubric_hash") != RUBRIC_HASH
        or canonical_hash(record.get("review_rubric")) != RUBRIC_HASH
        or baseline.get("baseline_id") != BASELINE
        or baseline.get("qualification_strength") != 1
        or baseline.get("center_contour_delta_srgb8") != -10
        or baseline.get("absolute_channel_safety_cap_srgb8") != 16
        or baseline.get("implementation_commit") != "94400c0eb845812c630fb2992928da99401f012e"
        or baseline.get("baseline_source_digest") != SOURCE_DIGEST
        or baseline.get("baseline_evidence_digest") != EVIDENCE_DIGEST
        or baseline.get("v2_helper_digest") != V2_EVALUATOR_HASH
        or baseline.get("v1_safety_helper_digest") != V1_EVALUATOR_HASH
        or baseline.get("focused_test_count") != 25
        or baseline.get("focused_test_status") != "pass"
        or record.get("metric_matrix", {}).get("inapplicable_target_metrics_receive_no_credit") is not True
        or record.get("metric_matrix", {}).get("applicability_is_bound_to_fixture_polarity") is not True
    ):
        raise GateError("qualification.binding")
    checks += 1
    if owner_digest(root, SOURCE_OWNERS) != SOURCE_DIGEST or owner_digest(root, EVIDENCE_OWNERS) != EVIDENCE_DIGEST:
        raise GateError("qualification.binding")
    checks += 2
    self_test, self_status = run_node(root, "--self-test")
    if self_status or self_test.get("status") != "pass" or self_test.get("decision") != NON_PROMOTION or self_test.get("promotion_fixture_count") != 0:
        raise GateError("qualification.binding")
    checks += 1
    preflight, preflight_status = run_node(root, "--decision")
    if (
        preflight_status == 0
        or preflight.get("status") != "fail"
        or preflight.get("decision") != NON_PROMOTION
        or preflight.get("public_absence") != {"beauty_parameter_fields": 61, "preset_ids": 5, "renderer_cases": 74}
        or preflight.get("reason_counts") != {"evidence.missing-bundle": 1, "review.missing": 1}
    ):
        raise GateError("qualification.binding")
    checks += 1
    return {
        "baseline_id": BASELINE,
        "checks": checks,
        "contract_hash": CONTRACT_HASH,
        "decision": NON_PROMOTION,
        "evaluator_version": VERSION,
        "external_v3_input_present": False,
        "phase": PHASE,
        "public_absence": {"beauty_parameter_fields": 61, "preset_ids": 5, "renderer_cases": 74},
        "status": "gate-ready",
        "v1_v2_artifacts_immutable": True,
    }


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--repo-root", required=True)
    try:
        args = parser.parse_args()
        if args.repo_root != ".":
            raise GateError("qualification.input")
        print(json.dumps(check(Path(".").resolve()), sort_keys=True, separators=(",", ":")))
        return 0
    except (GateError, UnicodeError, ValueError):
        print(json.dumps({"decision": NON_PROMOTION, "phase": PHASE, "reason": "qualification.binding", "status": "fail"}, sort_keys=True, separators=(",", ":")))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
