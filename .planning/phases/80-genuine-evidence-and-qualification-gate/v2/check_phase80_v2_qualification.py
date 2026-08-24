#!/usr/bin/env python3
"""Independent aggregate-only preflight for Phase-80 candidate v2."""

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
NON_PROMOTION = "qualification-not-passed"
BASELINE = "brow-to-lid-feathered-editor-v2"
VERSION = "phase80-qualification-evaluator-v2"
CONTRACT_HASH = "5f44d44f35a241b2baf204360063d0158b774e2e294e826dc07bd3bba0242b74"
CONTRACT_FILE_HASH = "7c72480e97f707bea9c599017ed583a33be4c1bc3a7da6f6cb301c26f10327e9"
EVALUATOR_HASH = "da77d16b10be4c51c00fbbdf920c8bc317e842ccf320039ba0bee23c5ba06266"
EVALUATOR_TEST_HASH = "f5b9553a2ab4a3c47c8eb7edca929a4e5502c8523045728cdcb2dc41d4c1ff50"
SOURCE_DIGEST = "10d279d28b30a3ef5cbd6d1e34597b74e5e12aaf83fb4b65889a1a920187efb3"
EVIDENCE_DIGEST = "c00ec162b7e9ca2f6d0cdf4b4ed07a5ae9986e4b336655c549aca251e6fd84cf"
RUBRIC_HASH = "0c9b80f45647c26b3e3707a4987ba9acc9c763343852dc6bb434199bf405f534"
V1_CONTRACT_HASH = "d3387b500c2e44e1d2b580845e1944f19ad77ccd85acb39162fbc186afb6b72e"
V1_EVALUATOR_HASH = "e1d94b4ac6531678483ad57a61a2a00b3b40d06aac6a0c51d6f565e63e1452a6"
V1_TEST_HASH = "b190add22925114f62947b8cbcb7b3766a63fd0ffde9f1f8730d622b4528a80c"

PHASE_DIR = Path(".planning/phases/80-genuine-evidence-and-qualification-gate")
V2_DIR = PHASE_DIR / "v2"
CONTRACT = V2_DIR / "80-V2-QUALIFICATION-CONTRACT.md"
EVALUATOR = V2_DIR / "80-v2-qualification-decision.js"
EVALUATOR_TEST = V2_DIR / "80-v2-qualification-decision.test.js"
V1_CONTRACT = PHASE_DIR / "80-QUALIFICATION-CONTRACT.md"
V1_EVALUATOR = PHASE_DIR / "80-qualification-decision.js"
V1_TEST = PHASE_DIR / "80-qualification-decision.test.js"

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


def read_regular(root: Path, relative: Path) -> bytes:
    target = root / relative
    try:
        if target.is_symlink() or not target.is_file():
            raise GateError("qualification.binding")
        return target.read_bytes()
    except (OSError, ValueError):
        raise GateError("qualification.binding") from None


def extract_record(text: str) -> dict[str, Any]:
    prefix = "<!-- CANONICAL_V2_QUALIFICATION_RECORDS_BEGIN -->\n```json\n"
    suffix = "\n```\n<!-- CANONICAL_V2_QUALIFICATION_RECORDS_END -->"
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
    return "\0".join(str(value[key]) for key in ("fixture_id", "category", "role", "sha256", "reason") if key in value).encode()


def canonicalize(value: Any) -> Any:
    if isinstance(value, list):
        return sorted((canonicalize(entry) for entry in value), key=array_key)
    if isinstance(value, dict):
        return {key: canonicalize(value[key]) for key in sorted(value, key=lambda item: item.encode())}
    if isinstance(value, float) and not math.isfinite(value):
        raise GateError("qualification.binding")
    return value


def canonical_hash(value: Any) -> str:
    encoded = json.dumps(canonicalize(value), ensure_ascii=False, separators=(",", ":")).encode()
    return sha256(encoded)


def owner_digest(root: Path, owners: tuple[Path, ...]) -> str:
    digest = hashlib.sha256()
    for owner in owners:
        content = read_regular(root, owner)
        name = owner.as_posix().encode()
        digest.update(struct.pack(">I", len(name)))
        digest.update(name)
        digest.update(struct.pack(">Q", len(content)))
        digest.update(content)
    return digest.hexdigest()


def run_node(root: Path, *arguments: str) -> dict[str, Any]:
    try:
        child = subprocess.run(
            ["node", str(EVALUATOR), *arguments, "--repo-root", "."],
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
    output["_exit"] = child.returncode
    return output


def check(root: Path) -> dict[str, Any]:
    checks = 0
    expected_files = (
        (CONTRACT, CONTRACT_FILE_HASH),
        (EVALUATOR, EVALUATOR_HASH),
        (EVALUATOR_TEST, EVALUATOR_TEST_HASH),
        (V1_CONTRACT, V1_CONTRACT_HASH),
        (V1_EVALUATOR, V1_EVALUATOR_HASH),
        (V1_TEST, V1_TEST_HASH),
    )
    for relative, expected in expected_files:
        if sha256(read_regular(root, relative)) != expected:
            raise GateError("qualification.binding")
        checks += 1

    record = extract_record(read_regular(root, CONTRACT).decode())
    if canonical_hash(record) != CONTRACT_HASH:
        raise GateError("qualification.binding")
    checks += 1
    baseline = record.get("baseline_binding", {})
    if (
        record.get("version") != 2
        or record.get("evaluator_version") != VERSION
        or record.get("review_rubric_hash") != RUBRIC_HASH
        or baseline.get("baseline_id") != BASELINE
        or baseline.get("baseline_source_digest") != SOURCE_DIGEST
        or baseline.get("baseline_evidence_digest") != EVIDENCE_DIGEST
        or baseline.get("v1_helper_digest") != V1_EVALUATOR_HASH
        or baseline.get("implementation_commit") != "4cf736c860c1b3baddc84310cbcdb58d0a535d0d"
        or baseline.get("focused_suite_count") != 5
        or baseline.get("focused_test_count") != 25
        or baseline.get("focused_test_status") != "pass"
    ):
        raise GateError("qualification.binding")
    checks += 1
    if canonical_hash(record.get("review_rubric")) != RUBRIC_HASH:
        raise GateError("qualification.binding")
    checks += 1
    if owner_digest(root, SOURCE_OWNERS) != SOURCE_DIGEST:
        raise GateError("qualification.binding")
    checks += 1
    if owner_digest(root, EVIDENCE_OWNERS) != EVIDENCE_DIGEST:
        raise GateError("qualification.binding")
    checks += 1

    self_test = run_node(root, "--self-test")
    if (
        self_test.pop("_exit") != 0
        or self_test.get("status") != "pass"
        or self_test.get("decision") != NON_PROMOTION
        or self_test.get("promotion_fixture_count") != 0
    ):
        raise GateError("qualification.binding")
    checks += 1
    preflight = run_node(root, "--decision")
    if (
        preflight.pop("_exit") == 0
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
        "external_v2_input_present": False,
        "phase": PHASE,
        "public_absence": {"beauty_parameter_fields": 61, "preset_ids": 5, "renderer_cases": 74},
        "status": "gate-ready",
        "v1_artifacts_immutable": True,
    }


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--repo-root", required=True)
    try:
        args = parser.parse_args()
        if args.repo_root != ".":
            raise GateError("qualification.input")
        output = check(Path(".").resolve())
        print(json.dumps(output, sort_keys=True, separators=(",", ":")))
        return 0
    except (GateError, UnicodeError, ValueError):
        print(json.dumps({"decision": NON_PROMOTION, "phase": PHASE, "reason": "qualification.binding", "status": "fail"}, sort_keys=True, separators=(",", ":")))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
