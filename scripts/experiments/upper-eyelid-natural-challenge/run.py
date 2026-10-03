#!/usr/bin/env python3
"""Run the frozen natural-background challenge in a disposable package copy."""

from __future__ import annotations

import hashlib
import os
from pathlib import Path
import re
import shutil
import signal
import stat
import subprocess
import sys
import tempfile


FROZEN_NAME = "BeautyUpperEyelidNaturalChallengeTests.swift"
FROZEN_SHA256 = "69b6e56f572f3efd88155cb75c2a54e0f66a0af63024127b7aad72bda1dd6008"
FIXTURES = (
    ("upper-eyelid-generated-base.png", "fabc4bac1fe5c71ac4adaef225501c847a913a3144ef8ce31003c6a4fded1f7b"),
    ("upper-eyelid-negative-control.png", "3e0b6a3bd824e22d99632bef861ac647191ff829af8c70ccd6e181e97c815856"),
)
FILTER = "BeautyCoreTests.BeautyUpperEyelidNaturalChallengeTests/testFrozenNaturalBackgroundDome"
CASE_ID = "-[BeautyCoreTests.BeautyUpperEyelidNaturalChallengeTests testFrozenNaturalBackgroundDome]"
MAXIMUM_BYTES = 16 * 1024 * 1024
MAXIMUM_LINES = 200_000


class ExperimentError(Exception):
    """Only closed, locator-free codes may reach stdout."""


class Interrupted(Exception):
    def __init__(self, signum: int):
        self.signum = signum


def require_regular(path: Path, *, directory: bool = False) -> None:
    # Inspect the original path, without resolving away a forbidden link.
    for component in (path, *path.parents):
        if stat.S_ISLNK(component.lstat().st_mode):
            raise ExperimentError("symbolic_link_rejected")
    mode = path.lstat().st_mode
    if not (stat.S_ISDIR(mode) if directory else stat.S_ISREG(mode)):
        raise ExperimentError("non_regular_source")


def verified_bytes(path: Path, digest: str, *, maximum: int = MAXIMUM_BYTES) -> bytes:
    require_regular(path)
    size = path.stat().st_size
    if not 0 < size <= maximum:
        raise ExperimentError("source_size_rejected")
    with path.open("rb") as source:
        data = source.read(maximum + 1)
    if len(data) != size or hashlib.sha256(data).hexdigest() != digest:
        raise ExperimentError("source_digest_rejected")
    return data


def copy_tree(source: Path, destination: Path) -> None:
    require_regular(source, directory=True)
    destination.mkdir()
    for item in sorted(source.iterdir()):
        mode = item.lstat().st_mode
        if stat.S_ISLNK(mode):
            raise ExperimentError("symbolic_link_rejected")
        if item.name == ".build":
            continue
        target = destination / item.name
        if stat.S_ISDIR(mode):
            copy_tree(item, target)
        elif stat.S_ISREG(mode):
            require_regular(item)
            shutil.copyfile(item, target, follow_symlinks=False)
            require_regular(target)
        else:
            raise ExperimentError("non_regular_source")


def run_child(command: list[str], cwd: Path, environment: dict[str, str]) -> tuple[int, bytes]:
    # Keep child output bounded and private. In particular, do not stream a
    # compiler/framework transcript or an underlying filesystem exception.
    child = subprocess.Popen(command, cwd=cwd, env=environment,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                             start_new_session=True)
    transcript = bytearray()
    lines = 0
    try:
        assert child.stdout is not None
        while chunk := child.stdout.read(8192):
            lines += chunk.count(b"\n")
            if len(transcript) + len(chunk) > MAXIMUM_BYTES or lines > MAXIMUM_LINES:
                raise ExperimentError("transcript_limit_exceeded")
            transcript.extend(chunk)
        return child.wait(), bytes(transcript)
    finally:
        # Cover interrupted builds and their xctest children before deleting
        # the temporary tree containing the two authorized private fixtures.
        try:
            os.killpg(child.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            child.wait(timeout=5)
        except subprocess.TimeoutExpired:
            try:
                os.killpg(child.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            child.wait()
        if child.stdout is not None:
            child.stdout.close()


def summarize(data: bytes) -> tuple[int, int, int, bool, str]:
    text = data.decode("utf-8", errors="replace")
    events = re.findall(r"^Test Case '([^']+)' (started|passed|failed|skipped)\b", text, re.MULTILINE)
    summaries = re.findall(
        r"^\s*Executed (\d+) tests?, with (?:(\d+) tests? skipped and )?(\d+) failures?",
        text, re.MULTILINE,
    )
    tests = max((int(item[0]) for item in summaries), default=0)
    failures = max((int(item[2]) for item in summaries), default=0)
    skipped = max((int(item[1] or 0) for item in summaries), default=0)
    if any(event == "skipped" for _, event in events) or re.search(
        r"\b[1-9]\d* tests? skipped\b|\bTest .+ skipped:", text
    ):
        skipped = max(1, skipped)
    starts = [(name, event) for name, event in events if event == "started"]
    finishes = [(name, event) for name, event in events if event != "started"]
    outcome = finishes[0][1] if len(finishes) == 1 else "not_executed"
    valid = (
        starts == [(CASE_ID, "started")]
        and len(finishes) == 1 and finishes[0][0] == CASE_ID
        and bool(summaries) and all(int(item[0]) == 1 for item in summaries)
        and skipped == 0
        and ((outcome == "passed" and failures == 0) or (outcome == "failed" and failures > 0))
    )
    return tests, failures, skipped, valid, outcome


def failure_codes(data: bytes) -> tuple[list[int], list[str]]:
    """Only frozen source line numbers and known fixture error names escape."""
    text = data.decode("utf-8", errors="replace")
    lines = sorted({int(item) for item in re.findall(
        re.escape(FROZEN_NAME) + r":(\d+)(?::\d+)?: error:", text
    )})
    known = {"invalidName", "unreadable", "symbolicLink", "invalidResource", "oversized",
             "digestMismatch", "undecodable", "invalidGeometry", "invalidSource",
             "invalidOutputDirectory"}
    failures = [line for line in text.splitlines() if "error:" in line and CASE_ID in line]
    errors = sorted({code for code in known for line in failures
                     if re.search(r"\b" + re.escape(code) + r"\b", line)})
    return lines, errors


def run() -> int:
    if len(sys.argv) != 1:
        raise ExperimentError("unexpected_arguments")
    experiment = Path(os.path.abspath(__file__)).parent
    repository = experiment.parents[2]
    require_regular(experiment, directory=True)
    frozen = verified_bytes(experiment / FROZEN_NAME, FROZEN_SHA256, maximum=256 * 1024)
    package = repository / "BeautySDK"
    require_regular(package, directory=True)
    require_regular(package / "Package.swift")
    if (package / "Tests/BeautyCoreTests" / FROZEN_NAME).exists():
        raise ExperimentError("challenge_already_in_active_tests")
    swift = shutil.which("swift")
    git = shutil.which("git")
    if swift is None or git is None:
        raise ExperimentError("required_command_unavailable")

    # Foundation shortens existing /private/tmp paths to /tmp when the frozen
    # loader standardizes them. /tmp is a symlink and is correctly rejected by
    # that loader. Keep its bytes/security rule intact; use the ignored local
    # build area, with a fresh package and scratch directory, instead.
    temporary_parent = package / ".build"
    if not temporary_parent.exists():
        temporary_parent.mkdir()
    require_regular(temporary_parent, directory=True)
    ignored = subprocess.run([git, "-C", str(repository), "check-ignore", "-q", "--",
                              "BeautySDK/.build/"],
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if ignored.returncode != 0:
        raise ExperimentError("temporary_directory_not_ignored")
    with tempfile.TemporaryDirectory(prefix="natural-challenge-", dir=temporary_parent) as temporary:
        root = Path(temporary)
        copied_package = root / "BeautySDK"
        copied_package.mkdir()
        shutil.copyfile(package / "Package.swift", copied_package / "Package.swift", follow_symlinks=False)
        require_regular(copied_package / "Package.swift")
        copy_tree(package / "Sources", copied_package / "Sources")
        copy_tree(package / "Tests", copied_package / "Tests")
        test = copied_package / "Tests/BeautyCoreTests" / FROZEN_NAME
        if test.exists():
            raise ExperimentError("challenge_already_in_active_tests")
        test.write_bytes(frozen)
        portraits = root / "example-images/input/portraits"
        portraits.mkdir(parents=True)
        for name, digest in FIXTURES:
            if len(name) <= 4 or not name.endswith(".png") or "/" in name or "\\" in name:
                raise ExperimentError("fixture_name_rejected")
            relative = Path("example-images/input/portraits") / name
            ignored = subprocess.run([git, "-C", str(repository), "check-ignore", "-q", "--", str(relative)],
                                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if ignored.returncode != 0:
                raise ExperimentError("fixture_not_ignored")
            data = verified_bytes(repository / relative, digest)
            copied = portraits / name
            copied.write_bytes(data)
            verified_bytes(copied, digest)

        environment = os.environ.copy()
        environment["BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS"] = "1"
        environment.pop("NATURAL_LID_OUTPUT", None)
        environment.pop("BEAUTYSDK_UPPER_EYELID_FIXTURE", None)
        print("natural_challenge_started isolated=1 frozen_sha256=" + FROZEN_SHA256, flush=True)
        status, transcript = run_child(
            [swift, "test", "--package-path", str(copied_package),
             "--scratch-path", str(root / "build"), "--filter", FILTER],
            root, environment,
        )
        tests, failures, skipped, valid, outcome = summarize(transcript)
        shell_status = status if status >= 0 else 128 - status
        print(f"natural_challenge_result tests={tests} failures={failures} skipped={skipped} "
              f"valid_execution={int(valid)} outcome={outcome} swift_exit={shell_status}")
        lines, errors = failure_codes(transcript)
        if lines or errors:
            print("natural_challenge_diagnostics assertion_lines=" + ",".join(map(str, lines))
                  + " fixture_errors=" + ",".join(errors))
        if shell_status != 0:
            return shell_status
        if not valid or outcome != "passed":
            raise ExperimentError("test_execution_not_successful")
        return 0


def main() -> int:
    def interrupt(signum: int, _frame: object) -> None:
        raise Interrupted(signum)

    signal.signal(signal.SIGINT, interrupt)
    signal.signal(signal.SIGTERM, interrupt)
    try:
        return run()
    except Interrupted as interruption:
        print("natural_challenge_interrupted")
        return 128 + interruption.signum
    except ExperimentError as error:
        print("natural_challenge_error code=" + str(error))
        return 2
    except Exception:
        # Never expose an OS/decoder exception containing a private locator.
        print("natural_challenge_error code=io_or_internal_failure")
        return 2


if __name__ == "__main__":
    sys.exit(main())
