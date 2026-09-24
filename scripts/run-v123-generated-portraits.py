#!/usr/bin/env python3
"""Owner-local generated portrait mechanics check; emits aggregates only."""
from __future__ import annotations

import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "example-images/input/mechanics-only"
SOURCES = (
    ("v123-contour-uneven-ai.png", "ae25e9f0bb0e6ddb2353d7a9396f313a84772e3e8ca73164f3ffb51913af5706"),
    ("v123-contour-smooth-ai.png", "c73333a64de22e8259602138615368ad1da35e419db141475341762d944fe7d9"),
)
PROBE = ROOT / "scripts/check-v123-generated-portraits.swift"
CONTRACT = ROOT / ".planning/qualifications/v1.23-synthetic/CONTRACT.md"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run(args: list[str], timeout: int) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(args, cwd=ROOT, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, text=True, timeout=timeout)
    if result.returncode:
        raise ValueError("child_failed")
    return result


def source_identity() -> str:
    path = ROOT / "scripts/phase95-closeout-evidence.py"
    spec = importlib.util.spec_from_file_location("v123_source_snapshot", path)
    if spec is None or spec.loader is None:
        raise ValueError("snapshot_unavailable")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.snapshot(ROOT)["input_digest"]


def main() -> None:
    if sys.argv[1:]:
        raise ValueError("invalid_arguments")
    if not PROBE.is_file() or not CONTRACT.is_file() or INPUT.is_symlink():
        raise ValueError("input_missing")
    expected = {name for name, _ in SOURCES}
    if {p.name for p in INPUT.iterdir()} != expected:
        raise ValueError("fixture_inventory")
    for name, sha in SOURCES:
        path = INPUT / name
        if not path.is_file() or path.is_symlink() or digest(path) != sha:
            raise ValueError("fixture_identity")
        run(["git", "check-ignore", "-q", "--no-index", str(path)], 10)
    before = source_identity()
    self_test = json.loads(run(["swift", str(PROBE), "--self-test"], 120).stdout)
    if self_test != {"status": "pass", "self_tests": 4}:
        raise ValueError("probe_self_test")
    run(["swift", "build", "--package-path", "BeautySDK", "--product", "BeautyExampleRenderer"], 300)
    renderer = ROOT / "BeautySDK/.build/debug/BeautyExampleRenderer"
    if not renderer.is_file():
        raise ValueError("renderer_missing")
    with tempfile.TemporaryDirectory(prefix="beauty-v123-generated-") as raw:
        temporary = Path(raw)
        outputs = [temporary / name for name in ("neutral", "candidate", "repeat")]
        cases = ("geometryBaseline_noop", "faceContourSmooth_0p25", "faceContourSmooth_0p25")
        for output, case in zip(outputs, cases):
            output.mkdir()
            run([str(renderer), "--input", str(INPUT), "--output", str(output),
                 "--case", case, "--backend", "cpu", "--no-watermark"], 120)
            expected_files = {f"{Path(name).stem}__{case}.png" for name, _ in SOURCES}
            expected_files.add("beauty-example-renderer-report.json")
            if {p.name for p in output.iterdir()} != expected_files:
                raise ValueError("render_inventory")
        arguments = ["swift", str(PROBE)]
        for name, _ in SOURCES:
            stem = Path(name).stem
            arguments.extend((
                str(INPUT / name),
                str(outputs[0] / f"{stem}__geometryBaseline_noop.png"),
                str(outputs[1] / f"{stem}__faceContourSmooth_0p25.png"),
                str(outputs[2] / f"{stem}__faceContourSmooth_0p25.png"),
            ))
        probe = json.loads(run(arguments, 120).stdout)
    if (probe.get("schema") != "v123-generated-portrait-mechanics-v1"
            or probe.get("status") != "pass" or probe.get("input_count") != 2
            or probe.get("source_sha256") != [sha for _, sha in SOURCES]
            or probe.get("effectiveness_credit") is not False
            or not all(type(n) is int and n > 0 for n in probe.get("changed_pixels", []))
            or len(probe["changed_pixels"]) != 2):
        raise ValueError("probe_invalid")
    result = {
        "schema": "v123-generated-portrait-run-v1",
        "status": "pass",
        "source_input_digest": before,
        "contract_sha256": digest(CONTRACT),
        "source_sha256": [sha for _, sha in SOURCES],
        "probe_sha256": digest(PROBE),
        "runner_sha256": digest(Path(__file__)),
        "input_count": 2,
        "render_invocations": 3,
        "probe_self_tests": 4,
        "changed_pixels": probe["changed_pixels"],
        "neutral_identical": True,
        "repeat_identical": True,
        "alpha_identical": True,
        "effectiveness_credit": False,
    }
    if source_identity() != before:
        raise ValueError("inputs_changed")
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError,
            subprocess.TimeoutExpired):
        print("v123_generated_portraits_failed", file=sys.stderr)
        raise SystemExit(1)
