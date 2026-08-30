#!/usr/bin/env python3
"""Read-only verifier for the Phase 90 FACE-01 bounded retry stop path."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


def fail(message: str) -> "NoReturn":
    print(f"FACE01_STOP_ERROR:{message}", file=sys.stderr)
    raise SystemExit(1)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_bytes(root: Path, relative: str) -> bytes:
    path = root / relative
    if not path.is_file() or path.is_symlink():
        fail("required_file_state")
    return path.read_bytes()


def extract_swift_method(source: bytes, method_name: str) -> bytes:
    marker = f"func {method_name}".encode()
    try:
        start = source.index(marker)
        opening = source.index(b"{", start)
    except ValueError:
        fail("oracle_method_missing")
    depth = 0
    for index in range(opening, len(source)):
        byte = source[index]
        if byte == ord("{"):
            depth += 1
        elif byte == ord("}"):
            depth -= 1
            if depth == 0:
                return source[start : index + 1]
    fail("oracle_method_unbalanced")


def capture_red(package_path: str, test_filter: str, cwd: Path) -> str:
    result = subprocess.run(
        ["swift", "test", "--package-path", package_path, "--filter", test_filter],
        cwd=cwd,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode == 0:
        fail("oracle_not_red")
    output = result.stdout + "\n" + result.stderr
    patterns = {
        "source_margin_q16": r"measured source signed margin: (-?\d+)",
        "neutral_margin_q16": r"measured neutral signed margin: (-?\d+)",
        "frozen_sibling_margins_q16": r"measured frozen sibling margins \(faceSmall, faceSlim\): \[([^\]]+)\]",
        "strengthening_sibling_margins_q16": r"measured Phase 90 strengthening margins \(faceVShape, jawSlim, chinTaper\): \[([^\]]+)\]",
        "outside_changed_pixels": r"measured outside changed pixels: (\d+)",
        "outside_absolute_rgb_delta": r"measured outside absolute RGB delta: (\d+)",
        "central_changed_pixels": r"measured central changed pixels: (\d+)",
        "central_absolute_rgb_delta": r"measured central absolute RGB delta: (\d+)",
    }
    aggregate: dict[str, object] = {}
    for key, pattern in patterns.items():
        matches = re.findall(pattern, output)
        if len(matches) != 1:
            fail("red_aggregate_shape")
        value = matches[0]
        if key.endswith("margins_q16"):
            aggregate[key] = [int(item.strip()) for item in value.split(",")]
        else:
            aggregate[key] = int(value)
    canonical = json.dumps(aggregate, sort_keys=True, separators=(",", ":")).encode()
    return base64.b64encode(canonical).decode("ascii")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify immutable FACE-01 RED/rollback state without writing repository data."
    )
    parser.add_argument("--capture-red", action="store_true")
    parser.add_argument("--git-root", default=".")
    parser.add_argument("--provider-path")
    parser.add_argument("--provider-sha256")
    parser.add_argument("--repair-test-path")
    parser.add_argument("--repair-test-sha256")
    parser.add_argument("--oracle-method-name")
    parser.add_argument("--oracle-method-sha256")
    parser.add_argument("--original-red-aggregate-b64")
    parser.add_argument("--swift-package-path", required=False)
    parser.add_argument("--swift-test-filter", required=False)
    parser.add_argument("--attempt-path")
    parser.add_argument("--attempt-prefix-bytes", type=int)
    parser.add_argument("--attempt-prefix-sha256")
    parser.add_argument("--expected-suffix-heading")
    parser.add_argument("--expected-suffix-sections", type=int)
    parser.add_argument("--expected-suffix-fields")
    parser.add_argument("--later-artifact-state", action="append", default=[])
    parser.add_argument("--summary-path")
    parser.add_argument("--expect-summary", choices=["absent", "present"])
    parser.add_argument("--verifier-sha256")
    parser.add_argument("--preserved-preexisting-path", action="append", default=[])
    parser.add_argument("--allowed-diff-path", action="append", default=[])
    parser.add_argument("--expect-status")
    return parser.parse_args()


def require(value: object, name: str) -> object:
    if value is None:
        fail(f"missing_argument_{name}")
    return value


def main() -> None:
    args = parse_args()
    root = Path(args.git_root).resolve()
    package_path = str(require(args.swift_package_path, "swift_package_path"))
    test_filter = str(require(args.swift_test_filter, "swift_test_filter"))
    if args.capture_red:
        print(f"FACE01_RED_CAPTURE={capture_red(package_path, test_filter, root)}")
        return

    provider_path = str(require(args.provider_path, "provider_path"))
    provider = read_bytes(root, provider_path)
    if sha256(provider) != require(args.provider_sha256, "provider_sha256"):
        fail("provider_hash")

    repair_path = str(require(args.repair_test_path, "repair_test_path"))
    repair = read_bytes(root, repair_path)
    if sha256(repair) != require(args.repair_test_sha256, "repair_test_sha256"):
        fail("repair_test_hash")
    method = extract_swift_method(
        repair, str(require(args.oracle_method_name, "oracle_method_name"))
    )
    if sha256(method) != require(args.oracle_method_sha256, "oracle_method_sha256"):
        fail("oracle_method_hash")
    current_red = capture_red(package_path, test_filter, root)
    if current_red != require(args.original_red_aggregate_b64, "original_red_aggregate_b64"):
        fail("red_aggregate_mismatch")

    attempt = read_bytes(root, str(require(args.attempt_path, "attempt_path")))
    prefix_bytes = int(require(args.attempt_prefix_bytes, "attempt_prefix_bytes"))
    if prefix_bytes < 0 or prefix_bytes > len(attempt):
        fail("attempt_prefix_length")
    prefix, suffix = attempt[:prefix_bytes], attempt[prefix_bytes:]
    if sha256(prefix) != require(args.attempt_prefix_sha256, "attempt_prefix_sha256"):
        fail("attempt_prefix_hash")
    heading = str(require(args.expected_suffix_heading, "expected_suffix_heading"))
    suffix_text = suffix.decode("utf-8")
    expected_sections = int(require(args.expected_suffix_sections, "expected_suffix_sections"))
    if suffix_text.count(heading) != expected_sections or not suffix_text.lstrip().startswith(heading):
        fail("attempt_suffix_heading")
    expected_fields = str(require(args.expected_suffix_fields, "expected_suffix_fields")).split(",")
    field_matches = re.findall(r"^- ([a-z0-9_]+): (.+)$", suffix_text, re.MULTILINE)
    if [name for name, _ in field_matches] != expected_fields:
        fail("attempt_suffix_fields")
    if any(not value.strip() for _, value in field_matches):
        fail("attempt_suffix_value")
    if len(re.findall(r"^## ", suffix_text, re.MULTILINE)) != expected_sections:
        fail("attempt_suffix_sections")

    for declaration in args.later_artifact_state:
        if "=" not in declaration:
            fail("later_artifact_declaration")
        relative, state = declaration.split("=", 1)
        path = root / relative
        if state == "absent":
            if path.exists() or path.is_symlink():
                fail("later_artifact_expected_absent")
        elif state.startswith("sha256:"):
            if not path.is_file() or path.is_symlink() or sha256(path.read_bytes()) != state[7:]:
                fail("later_artifact_hash")
        else:
            fail("later_artifact_state")

    summary = root / str(require(args.summary_path, "summary_path"))
    if args.expect_summary == "absent" and (summary.exists() or summary.is_symlink()):
        fail("summary_expected_absent")
    if args.expect_summary == "present" and not summary.is_file():
        fail("summary_expected_present")

    verifier_relative = "scripts/verify-phase90-face01-stop.py"
    verifier = read_bytes(root, verifier_relative)
    if sha256(verifier) != require(args.verifier_sha256, "verifier_sha256"):
        fail("verifier_hash")

    status = subprocess.run(
        ["git", "status", "--porcelain=v1", "--untracked-files=all"],
        cwd=root,
        capture_output=True,
        text=True,
        check=True,
    )
    changed: set[str] = set()
    for line in status.stdout.splitlines():
        path = line[3:]
        if " -> " in path:
            path = path.split(" -> ", 1)[1]
        changed.add(path)
    preserved: set[str] = set()
    for declaration in args.preserved_preexisting_path:
        if "=sha256:" not in declaration:
            fail("preserved_preexisting_declaration")
        relative, digest = declaration.split("=sha256:", 1)
        relative_path = Path(relative)
        if (
            not relative
            or not digest
            or relative_path.is_absolute()
            or ".." in relative_path.parts
            or relative in preserved
        ):
            fail("preserved_preexisting_declaration")
        if sha256(read_bytes(root, relative)) != digest:
            fail("preserved_preexisting_hash")
        preserved.add(relative)
    changed.difference_update(preserved)
    if changed != set(args.allowed_diff_path):
        fail("diff_allowlist")

    expected_status = str(require(args.expect_status, "expect_status"))
    if expected_status != "FACE01_STOP_VERIFIED":
        fail("expected_status")
    print("FACE01_STOP_VERIFIED")


if __name__ == "__main__":
    main()
