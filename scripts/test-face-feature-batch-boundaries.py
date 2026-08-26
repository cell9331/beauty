#!/usr/bin/env python3
"""Adversarial runner probes that persist only aggregate outcomes."""

import json
import os
import subprocess
import sys
import tempfile


REPO_ROOT = os.path.realpath(os.path.join(os.path.dirname(__file__), ".."))
RUNNER = os.path.join(REPO_ROOT, "scripts", "run-face-feature-batches.sh")
HELPER = os.path.join(REPO_ROOT, "scripts", "face-feature-path-helper.py")


class BoundaryTestError(Exception):
    pass


def helper(*arguments, stdin=None):
    result = subprocess.run(
        [sys.executable, HELPER, *arguments],
        input=stdin,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if result.returncode != 0:
        raise BoundaryTestError()
    return result.stdout.decode("utf-8").strip()


def ensure_directory(path):
    helper("ensure-directory", path)


def atomic_write(path, data):
    helper("atomic-write-stdin", path, stdin=data)


def invoke(input_path, output_path, report_path):
    return subprocess.run(
        [
            "bash", RUNNER,
            "--input", input_path,
            "--output", output_path,
            "--report", report_path,
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    ).returncode


def require_failure_envelope(path):
    with open(path, encoding="utf-8") as handle:
        report = json.load(handle)
    if (
        report != {
            "counts": {
                "liveRendererCases": 0,
                "selectedCases": 0,
                "semanticDirections": 0,
            },
            "reason": "preflight_failure",
            "schemaVersion": "beauty.face-feature-batch-runner.failure.1",
            "status": "infrastructure_failure",
        }
    ):
        raise BoundaryTestError()


def require_documentation_contract():
    documents = [
        "example-images/README.md",
        "SECURITY.md",
        "RELIABILITY.md",
        "QUALITY_SCORE.md",
        "PLANS.md",
    ]
    combined = []
    for relative_path in documents:
        with open(os.path.join(REPO_ROOT, relative_path), encoding="utf-8") as handle:
            text = handle.read()
        if "cleanup_failure" not in text:
            raise BoundaryTestError()
        combined.append(text)
    joined = "\n".join(combined)
    if "removed on every exit" in joined:
        raise BoundaryTestError()
    if "remediation" not in joined or "could not be verified" not in joined:
        raise BoundaryTestError()


def main():
    temporary_parent = os.path.realpath(tempfile.gettempdir())
    root = tempfile.mkdtemp(prefix="beauty_runner_boundary_", dir=temporary_parent)
    root = os.path.realpath(root)
    try:
        safe_report_parent = os.path.join(root, "records")
        safe_report = os.path.join(safe_report_parent, "report.json")
        ensure_directory(safe_report_parent)
        missing_input = os.path.join(root, "missing-input")
        output = os.path.join(root, "output")

        for stale_status in ("semantic_pass", "semantic_fail"):
            atomic_write(
                safe_report,
                json.dumps({"status": stale_status}, sort_keys=True).encode("utf-8"),
            )
            if invoke(missing_input, output, safe_report) != 2:
                raise BoundaryTestError()
            require_failure_envelope(safe_report)

        input_root = os.path.join(root, "input")
        portraits = os.path.join(input_root, "portraits")
        ensure_directory(portraits)
        fixture = os.path.join(portraits, "Portrait_A.jpg")
        fixture_bytes = bytes([0xFF, 0xD8, 0xFF, 0xD9])
        atomic_write(fixture, fixture_bytes)
        if invoke(input_root, output, fixture) != 2:
            raise BoundaryTestError()
        with open(fixture, "rb") as handle:
            if handle.read() != fixture_bytes:
                raise BoundaryTestError()

        real_parent = os.path.join(root, "real-records")
        ensure_directory(real_parent)
        real_report = os.path.join(real_parent, "report.json")
        stale_bytes = b'{"status":"semantic_pass"}'
        atomic_write(real_report, stale_bytes)
        linked_parent = os.path.join(root, "linked-records")
        os.symlink(real_parent, linked_parent)
        if invoke(input_root, output, os.path.join(linked_parent, "report.json")) != 2:
            raise BoundaryTestError()
        with open(real_report, "rb") as handle:
            if handle.read() != stale_bytes:
                raise BoundaryTestError()
        helper("remove-file", linked_parent)

        invalid_report = os.path.join(root, "invalid-report")
        ensure_directory(invalid_report)
        if invoke(input_root, output, invalid_report) != 2:
            raise BoundaryTestError()
        if not os.path.isdir(invalid_report):
            raise BoundaryTestError()

        require_documentation_contract()
        print(
            "runner_boundary_self_test=PASS stale_pass=1 stale_fail=1 "
            "alias_preserved=1 symlink_parent_preserved=1 invalid_report=1 docs=5"
        )
    finally:
        helper(
            "remove-tree",
            root,
            temporary_parent,
            "beauty_runner_boundary_",
        )


if __name__ == "__main__":
    try:
        main()
    except (BoundaryTestError, OSError, ValueError, json.JSONDecodeError):
        print("runner_boundary_self_test=FAIL", file=sys.stderr)
        raise SystemExit(1)
