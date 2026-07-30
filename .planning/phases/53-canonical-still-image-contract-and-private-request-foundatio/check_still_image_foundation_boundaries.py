#!/usr/bin/env python3
"""Fail-closed Phase 53 still-image boundary and edge-inventory checker."""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import subprocess
import sys
from dataclasses import dataclass

ROOT = pathlib.Path(__file__).resolve().parents[3]
SOURCE = ROOT / "BeautySDK" / "Sources"

EDGE_MANIFEST = (
    ("PATH01-CONCURRENCY", "flagged"),
    ("PATH02-UNCLASSIFIED", "automated"),
    ("PATH03-UNCLASSIFIED", "automated"),
    ("PATH04-BOUNDARY", "automated"),
    ("PATH04-ADJACENCY", "automated"),
    ("PATH04-EMPTY", "automated"),
    ("PATH04-ORDERING", "automated"),
    ("PATH04-PRECISION", "automated"),
    ("PATH04-CONCURRENCY", "flagged"),
    ("PATH05-CONCURRENCY", "flagged"),
    ("PATH06-ADJACENCY", "automated"),
    ("PATH06-EMPTY", "automated"),
    ("PATH06-ORDERING", "automated"),
    ("PATH07-ADJACENCY", "automated"),
    ("PATH07-EMPTY", "automated"),
    ("PATH07-ORDERING", "automated"),
)

EXPECTED_IDS = {row[0] for row in EDGE_MANIFEST}
EXPECTED_FLAGGED = {"PATH01-CONCURRENCY", "PATH04-CONCURRENCY", "PATH05-CONCURRENCY"}


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: str
    should_exist: bool


def validate_manifest(rows: tuple[tuple[str, str], ...] = EDGE_MANIFEST) -> None:
    ids = [row[0] for row in rows]
    if len(ids) != len(set(ids)):
        raise AssertionError("duplicate edge ID")
    if set(ids) != EXPECTED_IDS:
        raise AssertionError("missing or extra edge ID")
    automated = {edge for edge, kind in rows if kind == "automated"}
    flagged = {edge for edge, kind in rows if kind == "flagged"}
    if flagged != EXPECTED_FLAGGED:
        raise AssertionError("flagged assumptions changed")
    if len(rows) != 16 or len(automated) != 13 or len(flagged) != 3:
        raise AssertionError("edge equality must remain 16 = 13 automated + 3 flagged")


def classify_rg(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise RuntimeError(f"rg command error rc={returncode}: {stderr.strip()}")


def run_rg(pattern: str, paths: list[pathlib.Path]) -> tuple[str, str]:
    command = ["rg", "-n", "--hidden", "--glob", "*.swift", pattern, *map(str, paths)]
    completed = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, check=False)
    return classify_rg(completed.returncode, completed.stdout, completed.stderr), completed.stdout


def active_source_rules() -> tuple[Rule, ...]:
    forbidden = (
        r"public\s+.*(Canonical|ObservedLip|RequestContext|Mask|Pupil|Sclera|Vein)",
        r"@_spi\([^)]*\).*?(Canonical|ObservedLip|RequestContext|Mask|Pupil|Sclera|Vein)",
        r"(Codable|CodingKey).*?(canonical|landmark|lip|teeth|pupil|sclera|eyelid|mask|vein)",
        r"(teethWhitening|scleraRednessReduction|upperEyelidFullnessReduction)",
        r"CGColorSpaceCreateDeviceRGB",
    )
    return tuple(Rule(f"forbidden-{index}", pattern, False) for index, pattern in enumerate(forbidden))


def check_live() -> list[str]:
    validate_manifest()
    if not SOURCE.is_dir():
        raise RuntimeError(f"missing active source path: {SOURCE}")

    failures: list[str] = []
    for rule in active_source_rules():
        classification, output = run_rg(rule.pattern, [SOURCE])
        if classification == "match" and not rule.should_exist:
            failures.append(f"{rule.name}:\n{output.rstrip()}")

    # These are deliberately absent in Wave 0 and make live mode RED until the
    # owner plans implement them. Missing paths are never treated as clean.
    required = [
        SOURCE / "BeautyCore" / "Models" / "BeautyCanonicalStillImage.swift",
        SOURCE / "BeautySDK" / "BeautyStillImageCanonicalizer.swift",
        SOURCE / "BeautySDK" / "BeautyStillImageRequestContext.swift",
    ]
    for path in required:
        if not path.is_file():
            failures.append(f"missing required production path: {path.relative_to(ROOT)}")

    engine = SOURCE / "BeautySDK" / "BeautyEngine.swift"
    text = engine.read_text(encoding="utf-8")
    pixel_section = text[text.index("public func processResult(\n        pixelBuffer"):text.index("/// Returns an SDK-created image")]
    if re.search(r"canonical|localRetouch|RequestContext|ObservedLip", pixel_section, re.IGNORECASE):
        failures.append("pixel-buffer route contains local-foundation activation")
    return failures


def self_test() -> None:
    validate_manifest()
    cases = 0
    for returncode, stdout, stderr, expected in [
        (0, "hit\n", "", "match"),
        (1, "", "", "clean"),
    ]:
        assert classify_rg(returncode, stdout, stderr) == expected
        cases += 1
    for returncode in (2, 127):
        try:
            classify_rg(returncode, "", "command failed")
        except RuntimeError:
            cases += 1
        else:
            raise AssertionError("rg command error was silently classified")

    for mutation_name, mutation in [
        ("PATH02-UNCLASSIFIED", EDGE_MANIFEST + (("PATH02-UNCLASSIFIED-EXTRA", "automated"),)),
        ("PATH03-UNCLASSIFIED", tuple(row for row in EDGE_MANIFEST if row[0] != "PATH03-UNCLASSIFIED")),
    ]:
        try:
            validate_manifest(mutation)
        except AssertionError:
            print(f"PASS mutation {mutation_name} fails closed")
            cases += 1
        else:
            raise AssertionError(f"{mutation_name} mutation was silently accepted")
    print(json.dumps({"status": "pass", "selfTestCases": cases, "total": 16, "automated": 13, "flagged": 3}, sort_keys=True))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    failures = check_live()
    if failures:
        print("FAIL still-image foundation boundaries")
        print("\n".join(failures))
        return 1
    print("PASS still-image foundation boundaries")
    return 0


if __name__ == "__main__":
    sys.exit(main())
