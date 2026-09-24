#!/usr/bin/env python3
"""Append-only verification of the owner-directed FACE-01 synthetic mechanics scope."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
QUAL = ROOT / ".planning/qualifications/v1.23-synthetic"
CONTRACT = QUAL / "CONTRACT.md"
SOURCES = [
    "ae25e9f0bb0e6ddb2353d7a9396f313a84772e3e8ca73164f3ffb51913af5706",
    "c73333a64de22e8259602138615368ad1da35e419db141475341762d944fe7d9",
]
INPUT = ROOT / "example-images/input/mechanics-only"
SOURCE_NAMES = ("v123-contour-uneven-ai.png", "v123-contour-smooth-ai.png")
ACTIVE = [
    "chinTaper_0p25", "gazeCorrection_0p25", "eyebrowHeadSpacing_plus0p25",
    "eyebrowHeadSpacing_minus0p25", "noseBridge_0p30",
    "noseRootNarrowing_0p25", "mouthWidth_minus0p35",
]
FAILURES = [
    "neutral_direction", "neutral_target_signal", "outside_locality",
    "protected_region", "sibling_alias", "source_direction", "source_target_signal",
]


def module(name: str, path: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    if spec is None or spec.loader is None:
        raise ValueError("module_missing")
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


evidence = module("v123_closeout_evidence", "scripts/phase95-closeout-evidence.py")


def sha(path: Path) -> str:
    return evidence.sha(path)


def identity() -> dict:
    if INPUT.is_symlink() or not INPUT.is_dir():
        raise ValueError("input_missing")
    if {path.name for path in INPUT.iterdir()} != set(SOURCE_NAMES):
        raise ValueError("input_inventory")
    for name, expected in zip(SOURCE_NAMES, SOURCES):
        path = INPUT / name
        if path.is_symlink() or not path.is_file() or sha(path) != expected:
            raise ValueError("input_stale")
    values = {
        "source_input_digest": evidence.snapshot(ROOT)["input_digest"],
        "contract_sha256": sha(CONTRACT),
        "source_sha256": SOURCES,
    }
    return {"schema": "v123-synthetic-identity-v1",
            "input_digest": evidence.digest(values), **values}


def attempt_path(value: str) -> Path:
    if not re.fullmatch(r"attempt-[0-9]{8}T[0-9]{6}Z-[0-9a-f]{8}", value):
        raise ValueError("attempt_id_invalid")
    path = QUAL / value
    if not path.is_dir() or any(p.is_symlink() for p in (path, *path.parents)):
        raise ValueError("attempt_missing")
    return path


def completion(attempt_id: str) -> dict:
    current = identity()
    attempt = attempt_path(attempt_id)
    generated_path = attempt / "GENERATED.json"
    gates_path = attempt / "GATES.json"
    review_path = attempt / "REVIEW.json"
    generated = evidence.load(generated_path)
    gates = evidence.load(gates_path)
    review = evidence.load(review_path)
    evidence.fields(generated,
        "schema status source_input_digest contract_sha256 source_sha256 "
        "probe_sha256 runner_sha256 input_count render_invocations probe_self_tests "
        "changed_pixels neutral_identical repeat_identical alpha_identical effectiveness_credit")
    evidence.need(
        generated["schema"] == "v123-generated-portrait-run-v1"
        and generated["status"] == "pass"
        and generated["source_input_digest"] == current["source_input_digest"]
        and generated["contract_sha256"] == current["contract_sha256"]
        and generated["source_sha256"] == SOURCES
        and generated["probe_sha256"] == sha(ROOT / "scripts/check-v123-generated-portraits.swift")
        and generated["runner_sha256"] == sha(ROOT / "scripts/run-v123-generated-portraits.py")
        and type(generated["input_count"]) is int and generated["input_count"] == 2
        and type(generated["render_invocations"]) is int and generated["render_invocations"] == 3
        and type(generated["probe_self_tests"]) is int and generated["probe_self_tests"] == 4
        and type(generated["changed_pixels"]) is list
        and len(generated["changed_pixels"]) == 2
        and all(type(n) is int and n > 0 for n in generated["changed_pixels"])
        and generated["neutral_identical"] is True
        and generated["repeat_identical"] is True
        and generated["alpha_identical"] is True
        and generated["effectiveness_credit"] is False,
        "generated_invalid")
    evidence.fields(gates, "schema status source_input_digest focused portrait no_skip")
    evidence.need(gates["schema"] == "v123-synthetic-gates-v1"
                  and gates["status"] == "pass"
                  and gates["source_input_digest"] == current["source_input_digest"],
                  "gates_invalid")
    evidence.fields(gates["focused"], "executed failed source_input_digest")
    evidence.need(gates["focused"] == {
        "executed": 8, "failed": 0,
        "source_input_digest": current["source_input_digest"]}, "focused_invalid")
    evidence.fields(gates["no_skip"],
                    "executed failed skipped opt_in_tests source_input_digest archive_first")
    evidence.need(
        type(gates["no_skip"]["executed"]) is int
        and gates["no_skip"]["executed"] >= 8
        and gates["no_skip"]["failed"] == 0
        and gates["no_skip"]["skipped"] == 0
        and gates["no_skip"]["opt_in_tests"] == 8
        and gates["no_skip"]["archive_first"] is True
        and gates["no_skip"]["source_input_digest"] == current["source_input_digest"],
        "no_skip_invalid")
    evidence.fields(gates["portrait"],
        "source_input_digest case_count reconciled_attempts active_pass face01_verdict "
        "face01_failure_reasons face01_effectiveness_credit stable_payload_sha256")
    evidence.need(
        gates["portrait"]["source_input_digest"] == current["source_input_digest"]
        and gates["portrait"]["case_count"] == 65
        and gates["portrait"]["reconciled_attempts"] == 2
        and gates["portrait"]["active_pass"] == ACTIVE
        and gates["portrait"]["face01_verdict"] == "semantic_fail"
        and gates["portrait"]["face01_failure_reasons"] == FAILURES
        and gates["portrait"]["face01_effectiveness_credit"] is False
        and isinstance(gates["portrait"]["stable_payload_sha256"], str)
        and re.fullmatch(r"[0-9a-f]{64}", gates["portrait"]["stable_payload_sha256"]) is not None,
        "portrait_invalid")
    evidence.fields(review,
        "schema status reviewer_agent_id input_digest generated_sha256 gates_sha256 "
        "claim findings")
    evidence.need(
        review["schema"] == "v123-synthetic-independent-review-v1"
        and review["status"] == "pass"
        and evidence.reviewer(review["reviewer_agent_id"])
        and review["input_digest"] == current["input_digest"]
        and review["generated_sha256"] == sha(generated_path)
        and review["gates_sha256"] == sha(gates_path)
        and review["claim"] == "synthetic-mechanics-only"
        and review["findings"] == [],
        "review_missing_or_stale")
    result = {
        **current,
        "schema": "v123-synthetic-complete-v1", "status": "complete",
        "phase_complete": True, "claim": "synthetic-mechanics-only",
        "effectiveness_credit": False, "attempt_id": attempt_id,
        "evidence": {name: sha(attempt / name) for name in
                     ("GENERATED.json", "GATES.json", "REVIEW.json")},
    }
    evidence.need(identity() == current, "inputs_changed")
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("identity", "finalize", "verify"))
    parser.add_argument("--attempt")
    args = parser.parse_args()
    if args.command == "identity":
        if args.attempt is not None:
            raise ValueError("invalid_arguments")
        print(json.dumps(identity(), sort_keys=True))
        return
    if args.attempt is None:
        raise ValueError("attempt_missing")
    result = completion(args.attempt)
    destination = attempt_path(args.attempt) / "COMPLETE.json"
    if args.command == "finalize":
        evidence.publish(destination, result)
    else:
        evidence.need(evidence.load(destination) == result, "completion_stale")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, TypeError, KeyError, evidence.GateError):
        print("v123_synthetic_closeout_failed", file=sys.stderr)
        raise SystemExit(1)
