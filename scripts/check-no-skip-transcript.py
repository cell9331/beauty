#!/usr/bin/env python3
"""Bound and validate the mixed XCTest/Swift Testing transcript."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from typing import Optional, Sequence


DEFAULT_MAX_BYTES = 16 * 1024 * 1024
DEFAULT_MAX_LINES = 200_000


class TranscriptError(RuntimeError):
    pass


def validate_transcript(data: bytes, expected_tests: Sequence[str]) -> None:
    if len(data) > DEFAULT_MAX_BYTES or data.count(b"\n") > DEFAULT_MAX_LINES:
        raise TranscriptError("transcript exceeds its byte/line ceiling")
    text = data.decode("utf-8", errors="replace")

    if re.search(r"Test Case '.*?' skipped", text):
        raise TranscriptError("XCTest skip event detected")
    for skipped in re.finditer(r"\b(\d+) tests? skipped\b", text, re.IGNORECASE):
        if int(skipped.group(1)) != 0:
            raise TranscriptError("nonzero skipped-test summary detected")
    if re.search(r"(?:^|\n).*\bTest .+ skipped:\s*", text):
        raise TranscriptError("Swift Testing skip/disabled event detected")

    xctest_summaries = re.findall(
        r"Test Suite 'All tests' (passed|failed).*?\n\s*Executed (\d+) tests?, with (\d+) failures?",
        text,
    )
    if len(xctest_summaries) != 1:
        raise TranscriptError("expected exactly one XCTest all-tests aggregate")
    status, executed_text, failures_text = xctest_summaries[0]
    if status != "passed" or int(executed_text) <= 0 or int(failures_text) != 0:
        raise TranscriptError("XCTest aggregate is failed, empty, or contradictory")

    swift_testing_started = len(re.findall(r"Test run started", text))
    swift_testing_summaries = re.findall(
        r"Test run with (\d+) tests? in (\d+) suites? (passed|failed)",
        text,
    )
    if swift_testing_started or swift_testing_summaries:
        if swift_testing_started != 1 or len(swift_testing_summaries) != 1:
            raise TranscriptError("Swift Testing runner accounting is ambiguous")
        _, _, swift_status = swift_testing_summaries[0]
        if swift_status != "passed":
            raise TranscriptError("Swift Testing runner failed")

    for test_name in expected_tests:
        if len(re.findall(re.escape(test_name) + r".*passed", text)) != 1:
            raise TranscriptError(f"opt-in identity count differs from one: {test_name}")


def run_bounded(
    output: Path,
    command: Sequence[str],
    maximum_bytes: int,
    maximum_lines: int,
) -> int:
    child = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    assert child.stdout is not None
    byte_count = 0
    line_count = 0
    overflow = False
    with output.open("wb") as transcript:
        while True:
            chunk = child.stdout.read(8192)
            if not chunk:
                break
            byte_count += len(chunk)
            line_count += chunk.count(b"\n")
            if byte_count > maximum_bytes or line_count > maximum_lines:
                overflow = True
                child.terminate()
                break
            transcript.write(chunk)
            sys.stdout.buffer.write(chunk)
            sys.stdout.buffer.flush()
    if overflow:
        try:
            child.wait(timeout=5)
        except subprocess.TimeoutExpired:
            child.kill()
            child.wait()
        return 3
    return child.wait()


def self_test() -> None:
    xctest_pass = b"""Test Case 'Suite.testOptIn' passed (0.001 seconds)\nTest Suite 'All tests' passed at 2026-08-14 00:00:00.000.\n\t Executed 1 test, with 0 failures (0 unexpected) in 0.001 seconds\n"""
    swift_pass = b"""\xe2\x97\x87 Test run started.\n\xe2\x9c\x94 Test run with 0 tests in 0 suites passed after 0.001 seconds.\n"""
    validate_transcript(xctest_pass + swift_pass, ("testOptIn",))

    rejected = {
        "XCTest failure": xctest_pass.replace(b"passed at", b"failed at"),
        "XCTest skip": xctest_pass.replace(b"passed (", b"skipped ("),
        "Swift Testing failure": xctest_pass + swift_pass.replace(b"passed after", b"failed after"),
        "Swift Testing skip": xctest_pass + b"\xe2\x9e\x9c Test skippedProbe() skipped: \"probe\"\n" + swift_pass,
        "Swift Testing disabled": xctest_pass + b"\xe2\x9e\x9c Test disabledProbe() skipped: \"disabled\"\n" + swift_pass,
        "duplicate aggregate": xctest_pass + xctest_pass + swift_pass,
        "contradictory aggregate": xctest_pass + xctest_pass.replace(b"passed at", b"failed at") + swift_pass,
        "missing Swift Testing summary": xctest_pass + b"\xe2\x97\x87 Test run started.\n",
    }
    for description, fixture in rejected.items():
        try:
            validate_transcript(fixture, ("testOptIn",))
        except TranscriptError:
            continue
        raise TranscriptError(f"self-test accepted {description}")

    with tempfile.TemporaryDirectory(prefix="no-skip-transcript-self-test-") as directory:
        output = Path(directory) / "oversize.log"
        status = run_bounded(
            output,
            (sys.executable, "-c", "print('x' * 4096)"),
            maximum_bytes=128,
            maximum_lines=10,
        )
        if status != 3:
            raise TranscriptError("self-test did not reject byte overflow")
        output.unlink()
        status = run_bounded(
            output,
            (sys.executable, "-c", "print('x\\n' * 32)"),
            maximum_bytes=4096,
            maximum_lines=4,
        )
        if status != 3:
            raise TranscriptError("self-test did not reject line overflow")
    print("NO-SKIP TRANSCRIPT SELF-TEST PASSED")


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command_name", required=True)
    capture = subparsers.add_parser("capture")
    capture.add_argument("--output", type=Path, required=True)
    capture.add_argument("--max-bytes", type=int, default=DEFAULT_MAX_BYTES)
    capture.add_argument("--max-lines", type=int, default=DEFAULT_MAX_LINES)
    capture.add_argument("child_command", nargs=argparse.REMAINDER)
    check = subparsers.add_parser("check")
    check.add_argument("--input", type=Path, required=True)
    check.add_argument("--expected", action="append", default=[])
    subparsers.add_parser("self-test")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    arguments = parse_arguments(argv)
    try:
        if arguments.command_name == "capture":
            command = list(arguments.child_command)
            if command and command[0] == "--":
                command = command[1:]
            if not command or arguments.max_bytes <= 0 or arguments.max_lines <= 0:
                raise TranscriptError("capture requires a command and positive bounds")
            return run_bounded(arguments.output, command, arguments.max_bytes, arguments.max_lines)
        if arguments.command_name == "check":
            validate_transcript(arguments.input.read_bytes(), arguments.expected)
            return 0
        self_test()
        return 0
    except (OSError, TranscriptError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
