#!/usr/bin/env python3
"""Capture current-tree FACE-01, 65-case, and no-skip aggregate evidence."""
from __future__ import annotations

import importlib.util
import json
import os
from pathlib import Path
import re
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
PHASE = ROOT / ".planning/phases/95-compatibility-and-sdk-only-closeout"
ACTIVE = (
    "chinTaper_0p25", "gazeCorrection_0p25", "eyebrowHeadSpacing_plus0p25",
    "eyebrowHeadSpacing_minus0p25", "noseBridge_0p30",
    "noseRootNarrowing_0p25", "mouthWidth_minus0p35",
)


def module(name: str, path: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    if spec is None or spec.loader is None:
        raise ValueError("module_missing")
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


evidence = module("v123_evidence", "scripts/phase95-closeout-evidence.py")
gate = module("v123_gate", "scripts/phase95-genuine-gate.py")


def focused(before: str) -> dict:
    code, transcript = gate.bounded(
        ["swift", "test", "--package-path", "BeautySDK", "--filter", "FaceContourSmooth"],
        600,
    )
    if code:
        raise ValueError("focused_failed")
    content = transcript.decode("utf-8", errors="strict")
    matched = re.findall(
        r"Test Suite 'Selected tests' passed[^\n]*\n\s*Executed (\d+) tests?, with 0 failures",
        content,
    )
    if matched != ["8"]:
        raise ValueError("focused_count")
    del transcript
    return {"executed": 8, "failed": 0, "source_input_digest": before}


def no_skip(before: str) -> dict:
    code, transcript = gate.bounded(["bash", "scripts/run-no-skip-swiftpm.sh"], 1800)
    if code:
        raise ValueError("no_skip_failed")
    counts = gate.counts(transcript)
    del transcript
    if counts["opt_in_tests"] != 8 or counts["skipped"] != 0 or counts["failed"] != 0:
        raise ValueError("no_skip_count")
    return {**counts, "source_input_digest": before, "archive_first": True}


def portrait(before: str) -> dict:
    registration = evidence.load(PHASE / "95-ROI-REGISTRATION.json")
    admission = evidence.root_admission(ROOT)
    previous = {name: os.environ.get(name) for name in (
        "BEAUTY_PHASE95_ROI_DIGEST", "BEAUTY_PHASE95_SOURCE_DIGEST",
        "BEAUTY_PHASE95_ROOT_MEASUREMENT_IDENTITY",
    )}
    os.environ.update({
        "BEAUTY_PHASE95_ROI_DIGEST": registration["contracts_sha256"],
        "BEAUTY_PHASE95_SOURCE_DIGEST": registration["source_sha256"],
        "BEAUTY_PHASE95_ROOT_MEASUREMENT_IDENTITY": admission["measurement_identity"],
    })
    try:
        with tempfile.TemporaryDirectory(
                prefix="beauty-v123-report-",
                dir=ROOT / "example-images/local-test-records") as report_dir, \
                tempfile.TemporaryDirectory(
                    prefix="beauty-v123-output-",
                    dir=ROOT / "example-images/output") as output_dir:
            report = Path(report_dir) / "report.json"
            command = ["bash", "scripts/run-face-feature-batches.sh",
                       "--input", str(ROOT / "example-images/input"),
                       "--output", output_dir, "--report", str(report)]
            code, transcript = gate.bounded(command, 1200)
            del transcript
            if code != 3 or not report.is_file():
                raise ValueError("portrait_run")
            value = evidence.load(report)
    finally:
        for name, prior in previous.items():
            if prior is None:
                os.environ.pop(name, None)
            else:
                os.environ[name] = prior
    if (value.get("schemaVersion") != "beauty.face-feature-batch-runner.semantic.1"
            or value.get("status") != "semantic_fail"
            or value.get("stableSemanticPayloadDigest")
            != value.get("stableSemanticReconciliationDigest")):
        raise ValueError("portrait_report")
    payload = value["stableSemanticPayload"]
    if len(payload["mechanicalCases"]) != 65 or len(payload["semanticDirections"]) != 8:
        raise ValueError("portrait_inventory")
    directions = {row["caseID"]: row for row in payload["semanticDirections"]}
    if set(directions) != set(ACTIVE) | {"faceContourSmooth_0p25"}:
        raise ValueError("portrait_inventory")
    if any(directions[name]["verdict"] != "semantic_pass" for name in ACTIVE):
        raise ValueError("active_direction_failed")
    face = directions["faceContourSmooth_0p25"]
    if face["verdict"] != "semantic_fail":
        raise ValueError("face01_unexpected")
    return {
        "source_input_digest": before,
        "case_count": 65,
        "reconciled_attempts": 2,
        "active_pass": list(ACTIVE),
        "face01_verdict": face["verdict"],
        "face01_failure_reasons": face["failureReasonCodes"],
        "face01_effectiveness_credit": False,
        "stable_payload_sha256": value["stableSemanticPayloadDigest"],
    }


def main() -> None:
    if sys.argv[1:]:
        raise ValueError("invalid_arguments")
    before = evidence.snapshot(ROOT)["input_digest"]
    result = {
        "schema": "v123-synthetic-gates-v1",
        "status": "pass",
        "source_input_digest": before,
        "focused": focused(before),
        "portrait": portrait(before),
        "no_skip": no_skip(before),
    }
    if evidence.snapshot(ROOT)["input_digest"] != before:
        raise ValueError("inputs_changed")
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, UnicodeError,
            evidence.GateError, json.JSONDecodeError):
        print("v123_synthetic_gates_failed", file=sys.stderr)
        raise SystemExit(1)
