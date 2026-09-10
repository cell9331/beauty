#!/usr/bin/env python3
"""Phase 93 bounded gate. Child transcripts are never durable evidence."""
import argparse
import collections
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import selectors
import signal
import stat
import subprocess
import sys
import time


class GateError(Exception):
    pass


def require(condition, status="invalid_record"):
    if not condition:
        raise GateError(status)


def discover(output, methods):
    found = re.findall(r"^([A-Za-z0-9_]+\.[A-Za-z0-9_]+/test[A-Za-z0-9_]+)$", output, re.M)
    require(methods and len(set(methods)) == len(methods), "discovery_failure")
    require(all(found.count(method) == 1 for method in methods), "discovery_failure")
    return list(methods)


def classify(output, code, method, allowed=(), required=()):
    require(code in (0, 1), "child_failure")
    require(set(allowed) <= set(FAILURE_IDS.get(method, ())), "assertion_failure")
    identity = method.replace("/", " ")
    starts = re.findall(r"^Test Case '-\[([^\]]+)\]' started\.$", output, re.M)
    endings = re.findall(r"^Test Case '-\[([^\]]+)\]' (passed|failed|skipped) \([0-9.]+ seconds\)\.$", output, re.M)
    require(starts == [identity] and len(endings) == 1 and endings[0][0] == identity, "completion_failure")
    require(len(re.findall(r"^Test Case ", output, re.M)) == 2, "completion_failure")
    verdict = endings[0][1]
    require(verdict != "skipped" and not re.search(r"\bskipped\b", output, re.I), "skip_failure")
    issues = [line for line in output.splitlines() if re.search(r"\berror:|XCTAssert\w* failed|XCTFail failed", line)]
    ids = []
    for line in issues:
        match = re.fullmatch(r".+:\d+: error: -\[([^\]]+)\] : (?:XCTAssert\w*|XCTFail) failed(?:.*?) - (P93_[A-Z0-9_]+)", line)
        require(match is not None and match[1] == identity and match[2] in allowed, "assertion_failure")
        ids.append(match[2])
    require(len(ids) == len(set(ids)) and set(required) <= set(ids), "assertion_failure")
    # XCTest can print the same summary for the enclosing selected suite. All
    # summaries must agree; the trailing Swift Testing zero-test line is ignored.
    summaries = re.findall(r"Executed (\d+) tests?, with (\d+) failures? \((\d+) unexpected\)", output)
    require(summaries and all(tuple(map(int, row)) == (1, len(ids), 0) for row in summaries), "completion_failure")
    require((verdict == "passed" and code == 0 and not ids)
            or (verdict == "failed" and code == 1 and bool(ids)), "exit_mismatch")
    return {"discovered": 1, "passed": int(verdict == "passed"),
            "failed": int(verdict == "failed"), "skipped": 0, "assertions": ids}


def admit_begin(events, attempt):
    require(type(attempt) is int and attempt in (1, 2), "attempt_limit")
    starts = [e for e in events if e["event"] == "begin"]
    ends = [e for e in events if e["event"] == "finish"]
    require([e["attempt"] for e in starts] == list(range(1, len(starts) + 1)), "attempt_order")
    require(len(starts) == attempt - 1 and len(ends) == attempt - 1, "attempt_order")
    if attempt == 2:
        require(ends[0]["attempt"] == 1 and ends[0]["status"] == "failed"
                and ends[0]["category"] == "semantic_signal"
                and ends[0]["rollback"] == "provider_restored", "attempt_order")
    return attempt


def admit_child(code, output, timed_out=False, overflow=False, residue=False):
    require(not timed_out, "child_timeout")
    require(not overflow and len(output) <= 8 * 1024 * 1024, "capture_overflow")
    require(not residue, "cleanup_failure")
    require(code == 0, "child_failure")
    try:
        return output.decode("utf-8", errors="strict")
    except UnicodeError:
        raise GateError("child_encoding") from None


ROOT = Path(__file__).resolve().parent.parent
PHASE = ".planning/phases/93-distinct-nose-bridge-and-root-repairs/"
GATE = "scripts/check-phase93-nose-repair.py"
ADAPTER = "BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift"
PROVIDER = "BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift"
SPI = "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift"
REGRESSION = "BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift"
PROVIDER_TEST = "BeautySDK/Tests/BeautyEffectsTests/NoseWarpProviderTests.swift"
FIXTURE = "BeautySDK/Tests/BeautyCoreTests/NoseRepairFixture.swift"
REG_TEST = "BeautySDK/Tests/BeautyCoreTests/NoseFixtureRegistrationTests.swift"
METRIC_TEST = "BeautySDK/Tests/BeautyCoreTests/NoseSemanticMetricTests.swift"
PIXEL_TEST = "BeautySDK/Tests/BeautyCoreTests/BeautyEngineNoseRepairTests.swift"
FIELD_TEST = "BeautySDK/Tests/BeautyEffectsTests/NoseRepairFieldTests.swift"
OWNED_ORIGINALS = [ADAPTER, PROVIDER, REGRESSION, PROVIDER_TEST]
NEW_TESTS = [FIXTURE, REG_TEST, METRIC_TEST, PIXEL_TEST, FIELD_TEST]
MUTABLE_SDK = set(OWNED_ORIGINALS + NEW_TESTS + [SPI])
REGISTRATION = ["BeautyCoreTests.NoseFixtureRegistrationTests/" + name for name in (
    "testSourceAnatomyRegistersIndependently", "testAdapterMatchesSourceRootAndBridge",
    "testMissingNoseAndCanonicalControl")]
REG_METHOD = "BeautyEffectsTests.FaceShapeWarpProviderTests/testFaceGeometryAdapterKeepsLegacyNoseAndAddsExplicitRootAndTipSupports"
METRICS = ["BeautyCoreTests.NoseSemanticMetricTests/" + name for name in (
    "testBridgeMetricLiteralScaleAndPolarity", "testRootMetricHalfCentroidPolarity",
    "testMetricAdmissionRejectsInvalidDenominatorsAndDimensions", "testSemanticConjunctionRejectsProxyOnlyChanges")]
PUBLIC = ["BeautyCoreTests.BeautyEngineNoseRepairTests/" + name for name in (
    "testNOSE01FrozenBridgeSemanticContract", "testNOSE02FrozenRootSemanticContract",
    "testNoseNeutralMetadataOrientationAndDeterminism", "testNoseMissingSupportIsSourceExact",
    "testNoseValidInvalidValidRecoveryIsRedacted", "testNoseCombinedFieldsPreserveProtectedPixels")]
PROVIDERS = ["BeautyEffectsTests.NoseWarpProviderTests/" + name for name in (
    "testNoseSlimMovesSidePointsTowardNoseCenterWithCappedStrength",
    "testNoseProviderOutputIsDeterministicAndClampedForAllCurrentFields",
    "testNoseWingSlimCreatesLowerNosePointsWithCappedStrength",
    "testNoseTipSizeCreatesTipRegionPointsWithCappedStrength",
    "testNoseTipSizePreservesOppositeSignedDirections",
    "testNoseBridgeCreatesUpperBridgePointsWithCappedStrength",
    "testNoseRootNarrowingProducesSymmetricHorizontalBoundedVectors",
    "testNoseTipLiftProducesDeterministicVerticalUpwardBoundedVectors",
    "testNewNoseVectorsDoNotAliasLegacyBridgeOrSignedTipSize",
    "testMalformedRootSupportsFailClosedWithoutLegacySubstitution",
    "testMalformedTipSupportsFailClosedWithoutLegacySubstitution",
    "testNewNoseFieldsDoNotDependOnLegacyNoseCenterGuard",
    "testLegacyFieldEmissionsUseEachHelpersActualPrerequisites",
    "testIndependentFieldEmissionsIncludeStrengthAndDisplacementGuards",
    "testMissingNoseInputsReturnSkipReason", "testNOSE11SixFieldEmissionEligibilityAndSiblingIsolationMatrix")]
FIELDS = ["BeautyEffectsTests.NoseRepairFieldTests/" + name for name in (
    "testBridgeDisplacementScalesAtQuarterHalfAndCap", "testRootPairRemainsAtomicAndIndependent",
    "testFinalFloatFieldBudgetAndDenseMap", "testRendererCutoffAndMalformedBoundsFailClosed",
    "testReusedAndCombinedStrengthsRemainExact", "testLegacySiblingVectorsRemainByteIdentical")]
CENTERED_IDS = ("P93_CENTERED_BRIDGE_EMPTY", "P93_CENTERED_BRIDGE_TOTAL_FOUR", "P93_CENTERED_BRIDGE_SANITIZED_ZERO")
# Each new regression has one final Boolean predicate with this fixed ID.
# Every prerequisite/safety assertion without this ID must already be GREEN.
FAILURE_IDS = {
    REGISTRATION[1]: ("P93_ROOT_PLACEMENT",),
    PUBLIC[0]: ("P93_SEM_BRIDGE",), PUBLIC[1]: ("P93_SEM_ROOT",),
    PROVIDERS[12]: CENTERED_IDS,
    FIELDS[0]: ("P93_BRIDGE_SCALING",),
    FIELDS[2]: ("P93_FIELD_BUDGET",),
    FIELDS[3]: ("P93_RENDERER_CUTOFF",),
    FIELDS[4]: ("P93_REUSED_SCALING",),
}
COMPAT_CLASSES = ("BeautyParametersTests", "BeautyPresetTests", "BeautyEngineMetadataCompatibilityTests",
                  "CPUReferenceGeometryOracleTests", "BeautyExampleRendererProcessTests",
                  "BeautyRendererOutputRegressionTests", "BeautyEffectResolverTests",
                  "GeometryConflictResolverTests", "MissingLandmarkDegradationTests",
                  "CoordinateMapperTests", "FaceObservationMappingTests")
EVIDENCE = {PHASE + "93-" + name for name in (
    "BASELINE.json", "REGISTRATION.json", "RED.json", "PROVIDER-RED.json", "CHECKS.json", "ATTEMPTS.md")}
LEDGER_HEADER = "# Phase 93 shared attempt ledger\n\nRegistration is not pixel efficacy. Maximum candidates: 2.\n\n"
PROGRESS = {"discovered": 0, "passed": 0, "failed": 0, "skipped": 0}
CURRENT_METHOD = None
CURRENT_IDS = []


def child(args, timeout=60, allow_failure=False):
    """Drain both pipes with a shared 8 MiB cap and kill the entire child group."""
    proc = subprocess.Popen(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            start_new_session=True)
    output = bytearray()
    deadline = time.monotonic() + timeout
    selector = selectors.DefaultSelector()
    for pipe in (proc.stdout, proc.stderr):
        os.set_blocking(pipe.fileno(), False)
        selector.register(pipe, selectors.EVENT_READ)
    try:
        while selector.get_map():
            require(time.monotonic() < deadline, "child_timeout")
            for key, _ in selector.select(min(0.1, max(0, deadline - time.monotonic()))):
                chunk = os.read(key.fileobj.fileno(), 65536)
                if not chunk:
                    selector.unregister(key.fileobj)
                else:
                    require(len(output) + len(chunk) <= 8 * 1024 * 1024, "capture_overflow")
                    output.extend(chunk)
        proc.wait(timeout=max(0.01, deadline - time.monotonic()))
        text = admit_child(0 if allow_failure else proc.returncode, bytes(output))
        return proc.returncode, text
    finally:
        if proc.poll() is None:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()
        # Descendants may retain pipes after the leader exits.
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        selector.close()
        proc.stdout.close()
        proc.stderr.close()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def safe_path(relative, writing=False):
    require(relative and not Path(relative).is_absolute()
            and all(p not in ("", ".", "..") for p in relative.split("/")), "unsafe_path")
    if writing:
        require(relative in EVIDENCE, "unsafe_path")
    path = ROOT
    parts = relative.split("/")
    for index, part in enumerate(parts):
        path = path / part
        if path.exists() or path.is_symlink():
            mode = path.lstat().st_mode
            require(not stat.S_ISLNK(mode), "unsafe_path")
            require(stat.S_ISDIR(mode) if index < len(parts) - 1 else stat.S_ISREG(mode), "unsafe_path")
        else:
            require(writing and index == len(parts) - 1, "gate_not_ready")
    return path


def read_bytes(relative):
    path = safe_path(relative)
    require(path.stat().st_size <= 8 * 1024 * 1024, "capture_overflow")
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
    with os.fdopen(fd, "rb") as stream:
        data = stream.read(8 * 1024 * 1024 + 1)
    require(len(data) <= 8 * 1024 * 1024, "capture_overflow")
    return data


def sha(relative):
    return digest(read_bytes(relative))


def encode(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)


def no_duplicates(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, "invalid_record")
        result[key] = value
    return result


def load(name):
    return json.loads(read_bytes(PHASE + "93-" + name + ".json"), object_pairs_hook=no_duplicates)


def write_once(name, value):
    path = safe_path(PHASE + "93-" + name + ".json", writing=True)
    require(not path.exists(), "binding_exists")
    data = (encode(value) + "\n").encode()
    require(len(data) <= 8 * 1024 * 1024, "capture_overflow")
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "wb") as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())


def git(*args):
    return child(["git", *args])[1].strip()


def hashes(paths):
    return {p: sha(p) for p in sorted(paths)}


def check_hashes(expected):
    require(isinstance(expected, dict) and expected, "invalid_record")
    for path, value in expected.items():
        require(isinstance(value, str) and re.fullmatch("[0-9a-f]{64}", value), "invalid_record")
        require(sha(path) == value, "hash_drift")


def sdk_files():
    # Include untracked additions but omit SwiftPM output and ignored private inputs.
    listed = git("ls-files", "--cached", "--others", "--exclude-standard", "--", "BeautySDK")
    return set(listed.splitlines())


def remove_function(source, name):
    match = re.search(r"(?m)^    (?:private )?(?:static )?func " + re.escape(name) + r"\(", source)
    require(match is not None, "source_scope")
    opening = source.index("{", match.start())
    depth = 1
    end = opening + 1
    while depth and end < len(source):
        depth += (source[end] == "{") - (source[end] == "}")
        end += 1
    require(depth == 0, "source_scope")
    return source[:match.start()] + source[end:], source[match.start():end]


def blob_bytes(baseline, path):
    entry = baseline["originals"][path]
    require(re.fullmatch("[0-9a-f]{40}", entry["blob"]), "invalid_record")
    # Source text has one terminal newline; git() strips it, so use child directly.
    value = child(["git", "cat-file", "blob", entry["blob"]])[1].encode()
    require(digest(value) == entry["sha256"], "baseline_drift")
    return value


def initialize():
    require(not (ROOT / (PHASE + "93-BASELINE.json")).exists(), "binding_exists")
    head = git("rev-parse", "HEAD")
    require(git("branch", "--show-current") == "main", "source_scope")
    originals = {}
    for path in OWNED_ORIGINALS + [SPI]:
        blob = git("rev-parse", head + ":" + path)
        original = child(["git", "cat-file", "blob", blob])[1].encode()
        if path != SPI:
            require(read_bytes(path) == original, "owned_source_dirty")
        originals[path] = {"blob": blob, "sha256": digest(original)}
    tracked = set(git("ls-files").splitlines())
    frozen = {p for p in tracked if (p.startswith("BeautySDK/") and p not in MUTABLE_SDK)
              or (p.startswith("scripts/") and p != GATE)}
    # Config/state/PLANS/orchestrator runtime are explicit non-owned exceptions.
    dirty = child(["git", "status", "--porcelain=v1", "--untracked-files=all"])[1]
    dirty_hashes = {}
    for row in dirty.splitlines():
        path = row[3:]
        if path not in MUTABLE_SDK and path != GATE and not path.startswith(PHASE):
            dirty_hashes[digest(path.encode())] = sha(path)
    value = {"schema": 1, "phase": 93, "head": head, "gate": sha(GATE),
             "originals": originals, "frozen": hashes(frozen), "sdk_inventory": sorted(sdk_files() - set(NEW_TESTS)),
             "fixture": hashes([FIXTURE, SPI]), "dirty": dirty_hashes,
             "provider_baseline": {"discovered": 16, "passed": 16, "failed": 0, "skipped": 0,
                                   "provenance": "orchestrator_before_execution"}}
    source_scope(value)
    write_once("BASELINE", value)


def source_scope(baseline):
    original = blob_bytes(baseline, ADAPTER).decode()
    current = read_bytes(ADAPTER).decode()
    corrected = original.replace("point(bounds, x: 0.44, y: 0.48)", "point(bounds, x: 0.44, y: 0.30)")
    corrected = corrected.replace("point(bounds, x: 0.56, y: 0.48)", "point(bounds, x: 0.56, y: 0.30)")
    require(current in (original, corrected), "source_scope")
    old_spi = blob_bytes(baseline, SPI).decode()
    new_spi = read_bytes(SPI).decode()
    # Only the two declared cases and their explicitly delimited provider branch.
    new_spi = new_spi.replace("    case phase93RegisteredNose\n    case phase93MissingNose\n", "")
    new_spi, count = re.subn(r"(?ms)^            // Phase93 nose fixture begin\n.*?^            // Phase93 nose fixture end\n", "", new_spi)
    require(count == 1 and new_spi == old_spi, "source_scope")
    before = blob_bytes(baseline, REGRESSION).decode()
    after = before.replace("SIMD2<Float>(0.476, 0.488)", "SIMD2<Float>(0.476, 0.380)")
    after = after.replace("SIMD2<Float>(0.524, 0.488)", "SIMD2<Float>(0.524, 0.380)")
    require(read_bytes(REGRESSION).decode() in (before, after), "source_scope")
    before_provider = blob_bytes(baseline, PROVIDER).decode()
    after_provider = read_bytes(PROVIDER).decode()
    # New private helpers are restricted to a phase93-prefixed namespace and
    # may only be called inside the two repaired helper bodies / each other.
    for name in ("bridgePoints", "rootNarrowingPoints"):
        before_provider, _ = remove_function(before_provider, name)
        after_provider, _ = remove_function(after_provider, name)
    helpers = re.findall(r"(?m)^    private func (phase93[A-Za-z0-9_]+)\(", after_provider)
    for name in helpers:
        after_provider, _ = remove_function(after_provider, name)
    require(not re.search(r"\bphase93\w+\b", after_provider)
            and before_provider.split() == after_provider.split(), "source_scope")
    original_tests = blob_bytes(baseline, PROVIDER_TEST).decode()
    current_tests = read_bytes(PROVIDER_TEST).decode()
    if current_tests != original_tests:
        old_rest, old_method = remove_function(original_tests, PROVIDERS[12].split("/")[1])
        new_rest, new_method = remove_function(current_tests, PROVIDERS[12].split("/")[1])
        require(old_rest == new_rest, "source_scope")
        expected = old_method.replace("XCTAssertFalse(emissions.noseBridge.isEmpty)",
            'XCTAssertTrue(emissions.noseBridge.isEmpty, "P93_CENTERED_BRIDGE_EMPTY")')
        expected = expected.replace("XCTAssertEqual(emissions.points.count, 5)",
            'XCTAssertEqual(emissions.points.count, 4, "P93_CENTERED_BRIDGE_TOTAL_FOUR")')
        expected = expected.replace("XCTAssertEqual(sanitized.noseBridge, requested.noseBridge)",
            'XCTAssertEqual(sanitized.noseBridge, 0, "P93_CENTERED_BRIDGE_SANITIZED_ZERO")')
        require(new_method == expected, "source_scope")


def authorities():
    base = load("BASELINE")
    require(base["schema"] == 1 and base["phase"] == 93 and sha(GATE) == base["gate"], "hash_drift")
    check_hashes(base["frozen"])
    check_hashes(base["fixture"])
    require(sdk_files() - set(NEW_TESTS) == set(base["sdk_inventory"]), "source_inventory")
    source_scope(base)
    for name in ("REGISTRATION", "RED", "PROVIDER-RED"):
        if (ROOT / (PHASE + "93-" + name + ".json")).exists():
            binding = load(name)
            require(binding["phase"] == 93 and binding["gate"] == base["gate"], "hash_drift")
            check_hashes(binding["immutable"])
    return base


def events():
    path = ROOT / (PHASE + "93-ATTEMPTS.md")
    if not path.exists():
        require(not path.is_symlink(), "unsafe_path")
        return []
    data = read_bytes(PHASE + "93-ATTEMPTS.md").decode()
    require(data.startswith(LEDGER_HEADER), "ledger_failure")
    rows = data[len(LEDGER_HEADER):].splitlines()
    result = []
    previous = digest(LEDGER_HEADER.encode())
    for row in rows:
        require(row.startswith("<!-- ") and row.endswith(" -->"), "ledger_failure")
        event = json.loads(row[5:-4], object_pairs_hook=no_duplicates)
        require(event["phase"] == 93 and event["previous"] == previous
                and event["sequence"] == len(result) + 1, "ledger_failure")
        require(event["event"] in ("begin", "finish", "receipt", "freeze", "failure"), "ledger_failure")
        previous = digest(row.encode())
        result.append(event)
    return result


def append(event):
    prior = events()
    path = safe_path(PHASE + "93-ATTEMPTS.md", writing=True)
    old = read_bytes(PHASE + "93-ATTEMPTS.md").decode() if path.exists() else LEDGER_HEADER
    previous = digest(old.splitlines()[-1].encode()) if prior else digest(LEDGER_HEADER.encode())
    event = dict(event, phase=93, previous=previous, sequence=len(prior) + 1)
    row = "<!-- " + encode(event) + " -->\n"
    fd = os.open(path, os.O_WRONLY | os.O_APPEND | os.O_CREAT | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "w") as stream:
        if not prior and not old[len(LEDGER_HEADER):] and path.stat().st_size == 0:
            stream.write(LEDGER_HEADER)
        stream.write(row)
        stream.flush()
        os.fsync(stream.fileno())


def identity():
    paths = [GATE, ADAPTER, PROVIDER, SPI, REGRESSION, PROVIDER_TEST]
    paths += [p for p in NEW_TESTS if (ROOT / p).exists()]
    return hashes(paths)


def receipt(kind, results, extra=None):
    counts = {key: sum(row[key] for row in results) for key in ("discovered", "passed", "failed", "skipped")}
    value = {"event": "receipt", "kind": kind, "identity": identity(), "counts": counts,
             "assertions": [a for row in results for a in row["assertions"]], "extra": extra or {}}
    append(value)
    return value


def latest(kind, current=True):
    matches = [e for e in events() if e["event"] == "receipt" and e["kind"] == kind]
    require(matches, "gate_not_ready")
    result = matches[-1]
    if current:
        require(result["identity"] == identity(), "stale_receipt")
    return result


def prepare():
    child(["swift", "build", "--package-path", "BeautySDK", "--build-tests"], 600)
    return child(["swift", "test", "--package-path", "BeautySDK", "list"], 600)[1]


def run_methods(methods, expected=None, listing=None, records=False):
    global CURRENT_METHOD, CURRENT_IDS
    listing = prepare() if listing is None else listing
    discover(listing, methods)
    PROGRESS.update(discovered=len(methods), passed=0, failed=0, skipped=0)
    results = []
    aggregates = {}
    for method in methods:
        CURRENT_METHOD = method
        CURRENT_IDS = []
        code, output = child(["swift", "test", "--package-path", "BeautySDK", "--skip-build",
                              "--filter", "^" + re.escape(method) + "$"], 60, allow_failure=True)
        allowed = FAILURE_IDS.get(method, ()) if expected else ()
        required = allowed if expected == "old-root-red" or (expected == "baseline-red" and method == PROVIDERS[12]) else ()
        CURRENT_IDS = sorted(set(re.findall(r"\bP93_[A-Z0-9_]+\b", output)) & set(FAILURE_IDS.get(method, ())))
        try:
            result = classify(output, code, method, allowed, required)
        except GateError:
            PROGRESS["failed"] += 1
            raise
        for key in ("passed", "failed", "skipped"):
            PROGRESS[key] += result[key]
        if records and method in PUBLIC[:2]:
            aggregates[method] = semantic_record(output, method, result)
        results.append(result)
    return results, aggregates


def registration(expect):
    base = authorities()
    if expect == "old-root-red":
        require(sha(ADAPTER) == base["originals"][ADAPTER]["sha256"], "source_scope")
        require(not [e for e in events() if e["event"] == "begin"], "attempt_order")
        methods = REGISTRATION
    else:
        require(sha(ADAPTER) != base["originals"][ADAPTER]["sha256"], "source_scope")
        require(any(e["event"] == "begin" for e in events()), "attempt_order")
        methods = REGISTRATION + [REG_METHOD]
    result, _ = run_methods(methods, expected=expect if expect == "old-root-red" else None)
    return receipt("registration_" + expect, result)


def freeze_registration():
    base = authorities()
    starts = [e for e in events() if e["event"] == "begin"]
    require(len(starts) == 1 and starts[0]["attempt"] == 1, "attempt_order")
    result = registration("green")
    immutable = hashes([GATE, FIXTURE, SPI, REG_TEST, REGRESSION, ADAPTER])
    write_once("REGISTRATION", {"phase": 93, "gate": base["gate"], "immutable": immutable,
                               "baseline": sha(PHASE + "93-BASELINE.json"), "counts": result["counts"],
                               "new_registration_count": 3, "regression_count": 1,
                               "radius_envelopes": 2, "pixel_efficacy": "unmeasured", "attempt": 1})
    append({"event": "freeze", "kind": "registration", "binding": sha(PHASE + "93-REGISTRATION.json")})
    return result


# Public tests print exactly one JSON object after P93_NOSE_AGGREGATE. Values
# are extrema over BOTH source and neutral comparisons, never raw samples.
# This declared wire contract is shared with 93-02, not inferred from output.
AGG_KEYS = {"case", "comparisons", "source_changed", "neutral_changed", "source_rgb", "neutral_rgb",
            "source_margin", "neutral_margin", "sibling_margin", "outside_changed", "outside_rgb",
            "protected_changed", "protected_rgb", "background_changed", "background_rgb",
            "watermark_changed", "watermark_rgb", "repeated", "verdict", "siblings"}
SIBLING_KEYS = {"noseSlim_0p35", "noseWingSlim_0p35", "noseTipSize_plus0p30",
                "noseTipSize_minus0p30", "noseTipLift_0p25"}


def semantic_record(output, method, result):
    records = re.findall(r"^P93_NOSE_AGGREGATE (.+)$", output, re.M)
    require(len(records) == 1, "aggregate_failure")
    row = json.loads(records[0], object_pairs_hook=no_duplicates)
    require(set(row) == AGG_KEYS, "aggregate_failure")
    bridge = method == PUBLIC[0]
    require(row["case"] == ("bridge" if bridge else "root"), "aggregate_failure")
    for key in AGG_KEYS - {"case", "verdict", "siblings"}:
        require(type(row[key]) is int and abs(row[key]) <= 2**53 - 1, "aggregate_failure")
        if key not in ("source_margin", "neutral_margin"):
            require(row[key] >= 0, "aggregate_failure")
    require(row["comparisons"] == (6 if bridge else 5) and row["repeated"] == 1, "aggregate_failure")
    require(type(row["siblings"]) is dict and set(row["siblings"]) == SIBLING_KEYS, "aggregate_failure")
    require(all(type(v) is str and re.fullmatch("[0-9a-f]{64}", v) for v in row["siblings"].values()), "aggregate_failure")
    protection = (row["outside_changed"] <= 128 and row["outside_rgb"] <= 512
                  and row["protected_changed"] <= 64 and row["protected_rgb"] <= 256
                  and all(row[k] == 0 for k in ("background_changed", "background_rgb", "watermark_changed", "watermark_rgb")))
    # Protection errors are infrastructure/safety stops, never an efficacy RED.
    require(protection, "protection_failure")
    passed = (min(row["source_changed"], row["neutral_changed"]) >= 500
              and min(row["source_rgb"], row["neutral_rgb"]) >= 2000
              and min(row["source_margin"], row["neutral_margin"], row["sibling_margin"]) >= 16)
    require(row["verdict"] == ("pass" if passed else "semantic_red")
            and result["passed"] == int(passed), "aggregate_failure")
    return row


def bound_registration():
    base = authorities()
    binding = load("REGISTRATION")
    require(binding["baseline"] == sha(PHASE + "93-BASELINE.json"), "hash_drift")
    require(binding["counts"] == {"discovered": 4, "passed": 4, "failed": 0, "skipped": 0}, "invalid_record")
    return base


def metrics():
    bound_registration()
    result, _ = run_methods(METRICS)
    return receipt("metrics", result)


def lifecycle():
    bound_registration()
    result, _ = run_methods(PUBLIC[2:])
    return receipt("lifecycle", result)


def red():
    base = bound_registration()
    require(sha(PROVIDER) == base["originals"][PROVIDER]["sha256"], "baseline_drift")
    registration("green")
    metrics()
    lifecycle()
    result, aggregates = run_methods(PUBLIC[:2], expected="semantic-red", records=True)
    return receipt("red", result, aggregates)


def freeze_red():
    base = bound_registration()
    require(sha(PROVIDER) == base["originals"][PROVIDER]["sha256"], "baseline_drift")
    result = latest("red")
    for gate in ("registration_green", "metrics", "lifecycle"):
        require(latest(gate)["counts"]["failed"] == 0, "gate_not_ready")
    require(len(result["extra"]) == 2, "aggregate_failure")
    siblings = [r["siblings"] for r in result["extra"].values()]
    require(siblings[0] == siblings[1], "sibling_drift")
    write_once("RED", {"phase": 93, "gate": base["gate"],
                       "registration": sha(PHASE + "93-REGISTRATION.json"),
                       "immutable": hashes([GATE, FIXTURE, SPI, REG_TEST, REGRESSION, ADAPTER, METRIC_TEST, PIXEL_TEST]),
                       "provider_baseline": sha(PROVIDER), "counts": result["counts"],
                       "aggregates": result["extra"], "siblings": siblings[0],
                       "verdicts": {k: "baseline_pass" if v["verdict"] == "pass" else "semantic_red"
                                    for k, v in result["extra"].items()}})
    append({"event": "freeze", "kind": "red", "binding": sha(PHASE + "93-RED.json")})
    return result


def provider(expect):
    base = bound_registration()
    red_binding = load("RED")
    require(red_binding["registration"] == sha(PHASE + "93-REGISTRATION.json"), "hash_drift")
    if expect == "baseline-red":
        require(sha(PROVIDER) == base["originals"][PROVIDER]["sha256"], "baseline_drift")
    else:
        load("PROVIDER-RED")
    result, _ = run_methods(PROVIDERS + FIELDS, expected="baseline-red" if expect == "baseline-red" else None)
    if expect == "baseline-red":
        require(any(row["failed"] for row in result[16:]), "missing_regression_red")
    record = receipt("provider_" + expect, result)
    if expect == "baseline-red":
        write_once("PROVIDER-RED", {"phase": 93, "gate": base["gate"],
                                   "red": sha(PHASE + "93-RED.json"),
                                   "immutable": hashes([PROVIDER_TEST, FIELD_TEST]),
                                   "counts": record["counts"], "assertions": record["assertions"]})
    return record


def pixels():
    bound_registration()
    binding = load("RED")
    result, aggregates = run_methods(PUBLIC[:2], expected="semantic-red", records=True)
    require(all(a["siblings"] == binding["siblings"] for a in aggregates.values()), "sibling_drift")
    record = receipt("pixels", result, aggregates)
    require(record["counts"]["failed"] == 0, "semantic_signal")
    return record


def restore_original(base, paths):
    # These are the only rollback writes, and only after baseline admission.
    require(set(paths) <= {ADAPTER, PROVIDER}, "rollback_failure")
    source_scope(base)
    for path in paths:
        value = blob_bytes(base, path)
        fd = os.open(safe_path(path), os.O_WRONLY | os.O_TRUNC | os.O_NOFOLLOW)
        with os.fdopen(fd, "wb") as stream:
            stream.write(value)
            stream.flush()
            os.fsync(stream.fileno())
        require(sha(path) == base["originals"][path]["sha256"], "rollback_failure")


def begin(attempt):
    base = authorities()
    prior = events()
    admit_begin(prior, attempt)
    if attempt == 1:
        old = latest("registration_old-root-red", current=False)
        # Registration tests may now include the new regression expectation.
        for p in [FIXTURE, SPI, REG_TEST, ADAPTER, PROVIDER]:
            require(sha(p) == old["identity"][p], "hash_drift")
        require(old["counts"] == {"discovered": 3, "passed": 2, "failed": 1, "skipped": 0}, "gate_not_ready")
        require(sha(ADAPTER) == base["originals"][ADAPTER]["sha256"], "attempt_order")
    else:
        bound_registration()
        load("RED")
        load("PROVIDER-RED")
        require(sha(PROVIDER) == base["originals"][PROVIDER]["sha256"], "rollback_failure")
    append({"event": "begin", "attempt": attempt, "identity": identity(),
            "independent_review": "pending", "timestamp": int(time.time())})


def finish(attempt, status):
    base = authorities()
    prior = events()
    starts = [e for e in prior if e["event"] == "begin"]
    ends = [e for e in prior if e["event"] == "finish"]
    require(len(starts) == attempt and len(ends) == attempt - 1 and starts[-1]["attempt"] == attempt, "attempt_order")
    before = identity()
    counts = {"discovered": 0, "passed": 0, "failed": 0, "skipped": 0}
    category = "registration_prerequisite"
    failures = [e for e in prior[starts[-1]["sequence"]:] if e["event"] == "failure"]
    if failures:
        category = failures[-1]["category"]
        counts = failures[-1]["counts"]
    gates = ("provider_green", "registration_green", "metrics", "pixels", "lifecycle")
    complete = []
    try:
        complete = [latest(g) for g in gates]
    except GateError:
        if status == "passed":
            raise
    if complete:
        counts = {k: sum(e["counts"][k] for e in complete) for k in counts}
        require(counts["discovered"] == 36 and counts["skipped"] == 0, "completion_failure")
        category = "passed" if counts["failed"] == 0 else "semantic_signal"
        require(all(e["counts"]["failed"] == 0 for e in complete if e["kind"] != "pixels"), "safety_failure")
        require(all(e["category"] == "semantic_signal" for e in failures), "safety_failure")
    if status == "passed":
        require(category == "passed", "gate_not_ready")
        rollback = "retained"
    elif category == "semantic_signal" and attempt == 1:
        restore_original(base, [PROVIDER])
        rollback = "provider_restored"
    else:
        require(status == "failed", "invalid_record")
        restore_original(base, [ADAPTER, PROVIDER])
        rollback = "production_restored"
    append({"event": "finish", "attempt": attempt, "status": status, "category": category,
            "identity": before, "counts": counts, "rollback": rollback,
            "restored": hashes([ADAPTER, PROVIDER]), "independent_review": "pending", "timestamp": int(time.time())})


def accepted():
    authorities()
    ends = [e for e in events() if e["event"] == "finish"]
    successes = [e for e in ends if e["status"] == "passed"]
    require(len(successes) == 1 and ends[-1] == successes[0], "gate_not_ready")
    require(successes[0]["identity"] == identity(), "stale_receipt")
    return successes[0]


def compatibility():
    accepted()
    provider("green")
    registration("green")
    metrics()
    pixels()
    lifecycle()
    listing = prepare()
    methods = []
    for cls in COMPAT_CLASSES:
        found = re.findall(r"^([A-Za-z0-9_]+\." + cls + r"/test[A-Za-z0-9_]+)$", listing, re.M)
        require(found and len(found) == len(set(found)), "discovery_failure")
        methods.extend(found)
    result, _ = run_methods(methods, listing=listing)
    record = receipt("compatibility", result, {"classes": len(COMPAT_CLASSES), "focused": 36})
    checks_publish()
    return record


def checks_publish():
    value = {"phase": 93, "gate": sha(GATE), "identity": identity(),
             "receipts": [e for e in events() if e["event"] == "receipt"
                          and e["kind"] in ("compatibility", "checks", "design", "owners")
                          and e["identity"] == identity()]}
    path = safe_path(PHASE + "93-CHECKS.json", writing=True)
    # Checks is the one cumulative receipt, not an immutable baseline binding.
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, "w") as stream:
        stream.write(encode(value) + "\n")
        stream.flush()
        os.fsync(stream.fileno())


SCRIPT_CHECKS = (
    (["swift", "scripts/compare-face-feature-batches.swift", "--self-test"], 600,
     (r"semantic_validation_self_test=PASS mutations=576 inventories=5/65/8",)),
    (["python3", "scripts/test-face-feature-batch-boundaries.py"], 120,
     (r"runner_boundary_self_test=PASS", r"report_cleanup=6")),
    (["bash", "-n", "scripts/run-face-feature-batches.sh"], 120, ()),
    (["bash", "scripts/run-face-feature-batches.sh", "--preflight-only"], 120,
     (r"preflight=PASS", r"live=75", r"selected=65", r"semantic=8")),
    (["bash", "scripts/check-backend-neutral-contract.sh"], 600,
     (r"backend_neutral_static_boundary_passed", r"backend_neutral_contract_passed focused_tests=24 cpu_reference_tests=41")),
    (["python3", "scripts/archive-legacy-ui.py", "verify", "--output", "archives/legacy-ui"], 120,
     (r"VERIFIED BeautyDemo:", r"VERIFIED meituxiuxiu:")),
    (["bash", "scripts/check-sdk-only-boundary.sh", "--post-archive"], 120, (r"POST-ARCHIVE SDK BOUNDARY PASSED",)),
    (["git", "diff", "--check"], 120, ()),
)


def review(name, status_key):
    data = read_bytes(PHASE + "93-" + name + ".md").decode()
    require(len(re.findall(r"(?m)^" + status_key + r": passed\s*$", data)) == 1
            and re.search(r"(?m)^blockers: 0\s*$", data), "review_pending")
    for path in [ADAPTER, PROVIDER, METRIC_TEST, PIXEL_TEST]:
        require(sha(path) in data, "review_hash_drift")
    return sha(PHASE + "93-" + name + ".md")


def owner_sections(paths):
    accepted_result = accepted()
    for path in paths:
        text = read_bytes(path).decode()
        headings = list(re.finditer(r"(?mi)^##? .*Phase\s*93[^\n]*$", text))
        # PLANS owns its existing A-...-phase-93 entry rather than a new section.
        if path == "PLANS.md":
            require("A-2026-09-10-phase-93-registration-disposition" in text, "owner_failure")
            section = text.split("A-2026-09-10-phase-93-registration-disposition", 1)[1].split("## 4. Completed", 1)[0]
        else:
            require(len(headings) == 1, "owner_failure")
            section = text[headings[0].end():].split("\n## ", 1)[0]
        require("93-CHECKS.json" in section and "owner-local" in section
                and "Phase 95" in section and "independent" in section, "owner_failure")
        require(not re.search(r"(?i)(?:raw pixels|landmarks|coordinates)\s*[:=]\s*\[", section), "owner_failure")
        if path == "QUALITY_SCORE.md":
            require(str(accepted_result["attempt"]) in section and "36" in section, "owner_failure")


def closeout(stage):
    accepted()
    latest("compatibility")
    review_hash = review("REVIEW", "code_review_status")
    if stage == "checks":
        for args, timeout, patterns in SCRIPT_CHECKS:
            output = child(args, timeout)[1]
            require(all(re.search(pattern, output) for pattern in patterns), "script_schema_failure")
        record = receipt("checks", [{"discovered": 8, "passed": 8, "failed": 0, "skipped": 0, "assertions": []}],
                         {"review": review_hash, "mutations": 576, "cleanup": 6, "live": 75, "selected": 65, "semantic": 8})
    else:
        latest("checks")
        owners = ["DESIGN.md", "PRODUCT_SENSE.md", "RELIABILITY.md"]
        if stage == "owners":
            owners += ["SECURITY.md", "QUALITY_SCORE.md", "docs/SDK_EFFECT_TAXONOMY.md", "PLANS.md"]
            for index in [1, 6, 7]:
                args, timeout, patterns = SCRIPT_CHECKS[index]
                output = child(args, timeout)[1]
                require(all(re.search(p, output) for p in patterns), "script_schema_failure")
        owner_sections(owners)
        goal = "pending"
        if (ROOT / (PHASE + "93-VERIFICATION.md")).exists():
            review("VERIFICATION", "goal_verification_status")
            goal = "passed"
        record = receipt(stage, [{"discovered": len(owners), "passed": len(owners), "failed": 0, "skipped": 0, "assertions": []}],
                         {"owners": hashes(owners), "goal_verification": goal, "review": review_hash})
    authorities()
    checks_publish()
    return record


def self_test():
    """All parser/admission mutations are in memory; no Swift child is launched."""
    checks = 0

    def rejects(call):
        nonlocal checks
        try:
            call()
        except GateError:
            checks += 1
            return
        raise GateError("self_test_failure")

    method = "BeautyCoreTests.NoseFixtureRegistrationTests/testSourceAnatomyRegistersIndependently"
    cname, name = method.split(".", 1)[1].split("/")
    start = f"Test Case '-[{method.split('.')[0]}.{cname} {name}]' started.\n"
    passed = start + f"Test Case '-[{method.split('.')[0]}.{cname} {name}]' passed (0.001 seconds).\n"
    passed += "Executed 1 test, with 0 failures (0 unexpected) in 0.001 seconds\n"
    passed += "Test run with 0 tests passed after 0.001 seconds.\n"
    require(discover(method + "\n", [method]) == [method], "self_test_failure")
    require(classify(passed, 0, method)["passed"] == 1, "self_test_failure")
    checks += 2
    for listing in ["", method + "\n" + method, method.replace(name, "testOther")]:
        rejects(lambda listing=listing: discover(listing, [method]))
    for output, code in [("", 0), (passed, 1), (passed + passed, 0),
                         (passed.replace("passed (", "skipped ("), 0),
                         (passed.replace(name, "testOther"), 0),
                         (passed.replace("Executed 1 test", "Executed 0 tests"), 0),
                         (passed.replace("passed (", "unknown ("), 0)]:
        rejects(lambda output=output, code=code: classify(output, code, method))

    def failure(m, ids):
        module, rest = m.split(".", 1)
        cls, test = rest.split("/")
        result = f"Test Case '-[{module}.{cls} {test}]' started.\n"
        for fixed_id in ids:
            result += f"/in-memory.swift:1: error: -[{module}.{cls} {test}] : XCTAssertTrue failed - {fixed_id}\n"
        result += f"Test Case '-[{module}.{cls} {test}]' failed (0.001 seconds).\n"
        result += f"Executed 1 test, with {len(ids)} failures (0 unexpected) in 0.001 seconds\n"
        return result

    centered = "BeautyEffectsTests.NoseWarpProviderTests/testLegacyFieldEmissionsUseEachHelpersActualPrerequisites"
    ids = ("P93_CENTERED_BRIDGE_EMPTY", "P93_CENTERED_BRIDGE_TOTAL_FOUR", "P93_CENTERED_BRIDGE_SANITIZED_ZERO")
    result = classify(failure(centered, ids), 1, centered, ids, ids)
    require(result["failed"] == 1 and result["assertions"] == list(ids), "self_test_failure")
    checks += 1
    for bad_ids in [ids[:2], ids + (ids[0],), ids + ("P93_OTHER",), ("P93_OTHER",)]:
        rejects(lambda bad_ids=bad_ids: classify(failure(centered, bad_ids), 1, centered, ids, ids))
    rejects(lambda: classify(failure(centered, ids), 1, centered))
    rejects(lambda: classify(failure(method, ids), 1, method, ids, ids))
    rejects(lambda: classify(failure(centered, ids).replace("XCTAssertTrue failed", "unknown assertion"), 1, centered, ids, ids))
    rejects(lambda: classify(failure(centered, ids), 0, centered, ids, ids))
    for flag in ["timed_out", "overflow", "residue"]:
        rejects(lambda flag=flag: admit_child(0, b"PASS", **{flag: True}))
    rejects(lambda: admit_child(1, b"PASS"))
    require(admit_child(0, b"PASS") == "PASS", "self_test_failure")
    require(admit_begin([], 1) == 1, "self_test_failure")
    checks += 2
    for events, attempt in [([], 0), ([], 2), ([], 3), ([{"event": "begin", "attempt": 1}], 1),
                            ([{"event": "begin", "attempt": 1}], 2)]:
        rejects(lambda events=events, attempt=attempt: admit_begin(events, attempt))
    prior = [{"event": "begin", "attempt": 1}, {"event": "finish", "attempt": 1,
              "status": "failed", "category": "semantic_signal", "rollback": "provider_restored"}]
    require(admit_begin(prior, 2) == 2, "self_test_failure")
    checks += 1
    for key, value in [("status", "passed"), ("category", "protection_failure"), ("rollback", "retained")]:
        bad = copy.deepcopy(prior)
        bad[-1][key] = value
        rejects(lambda bad=bad: admit_begin(bad, 2))
    rejects(lambda: admit_begin(prior, 3))
    rejects(lambda: no_duplicates([("same", 1), ("same", 2)]))
    rejects(lambda: admit_child(0, b"\xff"))
    rejects(lambda: admit_child(0, b"x" * (8 * 1024 * 1024 + 1)))
    # Hash drift checks use an in-memory source, never a temp fixture/transcript.
    global sha
    original_sha = sha
    try:
        sha = lambda _: "a" * 64
        check_hashes({"fixture": "a" * 64})
        checks += 1
        rejects(lambda: check_hashes({"fixture": "b" * 64}))
        rejects(lambda: check_hashes({"fixture": "not-a-digest"}))
        rejects(lambda: check_hashes({}))
    finally:
        sha = original_sha
    for path in ["../escape", "/absolute", "scripts//empty", "./dot", "not-an-evidence-file"]:
        rejects(lambda path=path: safe_path(path, writing=True))
    # Path nodes are mocked in memory, including symlink parents and leaf files.
    global ROOT
    original_root = ROOT
    class Node:
        def __truediv__(self, _):
            return self
        def exists(self):
            return True
        def is_symlink(self):
            return True
        def lstat(self):
            return type("Mode", (), {"st_mode": stat.S_IFLNK})()
    try:
        ROOT = Node()
        rejects(lambda: safe_path(PHASE + "93-RED.json", writing=True))
    finally:
        ROOT = original_root
    return checks


def main():
    command = "unparsed"
    try:
        class Parser(argparse.ArgumentParser):
            def error(self, message):
                raise GateError("invalid_command")
        parser = Parser(add_help=False)
        parser.add_argument("command", choices=("self-test", "initialize", "registration", "freeze-registration",
            "metrics", "red", "freeze-red", "provider", "pixels", "lifecycle", "begin", "finish",
            "authorities", "compatibility", "closeout"))
        parser.add_argument("--expect", choices=("old-root-red", "green", "baseline-red"))
        parser.add_argument("--attempt", type=int, choices=(1, 2))
        parser.add_argument("--status", choices=("passed", "failed"))
        parser.add_argument("--stage", choices=("checks", "design", "owners"))
        args = parser.parse_args()
        command = args.command
        require(args.expect is None or command in ("registration", "provider"), "invalid_command")
        require(args.attempt is None or command in ("begin", "finish"), "invalid_command")
        require(args.status is None or command == "finish", "invalid_command")
        require(args.stage is None or command == "closeout", "invalid_command")
        result = None
        if command == "self-test":
            count = self_test()
            result = {"counts": {"discovered": count, "passed": count, "failed": 0, "skipped": 0}}
        elif command == "initialize": initialize()
        elif command == "registration":
            require(args.expect in ("old-root-red", "green"), "invalid_command")
            result = registration(args.expect)
        elif command == "freeze-registration": result = freeze_registration()
        elif command == "metrics": result = metrics()
        elif command == "red": result = red()
        elif command == "freeze-red": result = freeze_red()
        elif command == "provider":
            require(args.expect in (None, "green", "baseline-red"), "invalid_command")
            result = provider(args.expect or "green")
        elif command == "pixels": result = pixels()
        elif command == "lifecycle": result = lifecycle()
        elif command == "begin":
            require(args.attempt is not None, "invalid_command")
            begin(args.attempt)
        elif command == "finish":
            require(args.attempt is not None and args.status is not None, "invalid_command")
            finish(args.attempt, args.status)
        elif command == "authorities": authorities()
        elif command == "compatibility": result = compatibility()
        elif command == "closeout":
            require(args.stage is not None, "invalid_command")
            result = closeout(args.stage)
        counts = result["counts"] if result else {"discovered": 0, "passed": 0, "failed": 0, "skipped": 0}
        status = "expected_red" if counts["failed"] else "pass"
        print("PHASE93_GATE status=" + status + " " + " ".join(f"{k}={v}" for k, v in counts.items()))
        return 0
    except Exception as error:
        status = str(error) if isinstance(error, GateError) else "infrastructure_failure"
        require(re.fullmatch("[a-z_]+", status), "invalid_record")
        # Preserve only bounded failure identity/counts, never child text. A
        # damaged ledger/path cannot authorize a replacement or success record.
        if command not in ("self-test", "unparsed", "initialize") and (ROOT / (PHASE + "93-BASELINE.json")).exists():
            try:
                append({"event": "failure", "kind": command, "category": status,
                        "method": CURRENT_METHOD, "assertions": CURRENT_IDS,
                        "counts": dict(PROGRESS), "identity": identity()})
            except Exception:
                pass
        counts = dict(PROGRESS)
        counts["failed"] = max(1, counts["failed"])
        print("PHASE93_GATE status=" + status + " " + " ".join(f"{k}={v}" for k, v in counts.items()))
        return 2


if __name__ == "__main__":
    sys.exit(main())
