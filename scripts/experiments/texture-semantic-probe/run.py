#!/usr/bin/env python3
"""Run the frozen, intentionally rejected texture-semantic spike.

The external temporary package consumes BeautySDK without changing its sources
or normal tests. Only aggregate outcome markers leave the temporary build.
A nonzero effect/protection result is preserved, never changed to success.
"""
import json
import hashlib
import os
from pathlib import Path
import re
import selectors
import shutil
import signal
import subprocess
import sys
import tempfile
import time

FROZEN_SHA256 = "a535def54fb100b7e9591a488ff09ee0c15ce3d52f296b1b81ae133de3e27b62"
CASES = {
    "testDifferentMaterialScenesHaveIdenticalAutomaticInputsAndOutputs",
    "testUnmaskedBaselineMeetsTextureDirectionButFailsObjectProtection",
    "testRejectedPeriodicTextureCandidatePreservesObjectButStopsSkinEffect",
    "testExplicitMaskSuppliesMissingInformationAndPassesJointContract",
}


def run_child(command, environment):
    child = subprocess.Popen(command, env=environment, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, start_new_session=True)
    selector = selectors.DefaultSelector()
    selector.register(child.stdout, selectors.EVENT_READ)
    transcript = bytearray()
    deadline = time.monotonic() + 600
    try:
        while selector.get_map():
            if time.monotonic() >= deadline:
                raise TimeoutError()
            for key, _ in selector.select(timeout=0.2):
                chunk = os.read(key.fd, 8192)
                if not chunk:
                    selector.unregister(key.fileobj)
                    continue
                transcript.extend(chunk)
                if len(transcript) > 16 * 1024 * 1024:
                    raise ValueError("output_limit")
        status = child.wait(timeout=max(0.01, deadline - time.monotonic()))
        return status, transcript.decode("utf-8", errors="replace")
    finally:
        selector.close()
        if child.poll() is None:
            os.killpg(child.pid, signal.SIGKILL)
        child.wait()
        child.stdout.close()


def main():
    if len(sys.argv) != 1:
        print("texture_semantic_probe_invalid_arguments")
        return 2
    experiment = Path(__file__).resolve().parent
    repository = experiment.parents[2]
    source = experiment / "TextureSemanticProbeTests.swift"
    if source.is_symlink() or not source.is_file():
        print("texture_semantic_probe_source_unavailable")
        return 2
    if hashlib.sha256(source.read_bytes()).hexdigest() != FROZEN_SHA256:
        print("texture_semantic_probe_frozen_source_mismatch")
        return 2
    with tempfile.TemporaryDirectory(prefix="beauty-texture-semantic-") as directory:
        package = Path(directory)
        tests = package / "Tests" / "TextureSemanticProbeTests"
        tests.mkdir(parents=True)
        shutil.copyfile(source, tests / source.name)
        dependency = json.dumps(str(repository / "BeautySDK"))
        (package / "Package.swift").write_text(f'''// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "TextureSemanticProbe",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: {dependency})],
    targets: [.testTarget(name: "TextureSemanticProbeTests", dependencies: [
        .product(name: "BeautySDK", package: "BeautySDK")
    ])]
)
''')
        environment = os.environ.copy()
        environment["CLANG_MODULE_CACHE_PATH"] = str(package / "module-cache")
        # Stream-bounded output and a deadline; no compiler transcript persists.
        try:
            status, transcript = run_child(
                ["swift", "test", "--package-path", str(package)], environment,
            )
        except (OSError, ValueError, TimeoutError, subprocess.TimeoutExpired):
            print("texture_semantic_probe_execution_failed")
            return 2
        summaries = re.findall(
            r"Executed (\d+) tests?, with (?:(\d+) tests? skipped and )?(\d+) failures?",
            transcript,
        )
        if not summaries:
            print("texture_semantic_probe_no_test_result")
            return 2
        count, skipped, failures = summaries[-1]
        tests_count, skipped, failures = int(count), int(skipped or 0), int(failures)
        finished = re.findall(
            r"Test Case '-\[TextureSemanticProbeTests\.BeautySkinTextureSemanticFeasibilityTests (\w+)\]' (passed|failed|skipped)",
            transcript,
        )
        if (tests_count != 4 or skipped != 0 or len(finished) != 4
                or {name for name, _ in finished} != CASES
                or any(outcome == "skipped" for _, outcome in finished)
                or (status == 0) != (failures == 0)):
            print("texture_semantic_probe_execution_accounting_failed")
            return 2
        print(f"texture_semantic_probe tests={tests_count} failures={failures} skipped={skipped} exit={status}")
        for marker in transcript.splitlines():
            if re.fullmatch(r"texture_semantic_[a-z_]+(?: [a-z_]+=(?:[a-z_]+|[0-9]+))+", marker):
                # These fixed code-owned aggregate markers contain no payload.
                print(marker.replace("joint=pass", "local_joint=pass"))
        print("texture_semantic_probe acceptance=rejected" if failures else
              "texture_semantic_probe inspect_joint_predicates")
        return status


if __name__ == "__main__":
    raise SystemExit(main())
