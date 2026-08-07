#!/usr/bin/env python3
"""Fail-closed Phase 60 teeth-provider boundary checker.

Output is deliberately fixed and aggregate-only. Source snippets, paths,
subprocess stderr, geometry, pixels, and private evidence details are never
printed.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Callable


THREAT_IDS = tuple(f"T-60-{index:02d}" for index in range(1, 9))
PHASE_DIR = Path(".planning/phases/60-teeth-provider-and-production-integration")
PROVIDER_RELATIVE = Path(
    "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningProvider.swift"
)
TRANSFORM_RELATIVE = Path(
    "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningTransform.swift"
)
ENGINE_RELATIVE = Path("BeautySDK/Sources/BeautySDK/BeautyEngine.swift")
TESTING_RELATIVE = Path("BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift")
PROVIDER_TEST_RELATIVE = Path(
    "BeautySDK/Tests/BeautyEffectsTests/BeautyTeethWhiteningProviderTests.swift"
)
ENGINE_TEST_RELATIVE = Path(
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineTeethWhiteningIntegrationTests.swift"
)
PRIVATE_TEST_RELATIVE = Path(
    "BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift"
)
DEMO_MODEL_RELATIVE = Path("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift")


class CheckFailure(Exception):
    pass


@dataclass(frozen=True)
class CheckResult:
    checks: int
    failures: tuple[str, ...]


class Snapshot:
    def __init__(self, root: Path):
        self.root = root.resolve()
        self._cache: dict[Path, str] = {}

    def text(self, relative: Path, required: bool = True) -> str:
        if relative in self._cache:
            return self._cache[relative]
        path = self.root / relative
        try:
            value = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError):
            if required:
                raise CheckFailure("required_source_unavailable")
            value = ""
        self._cache[relative] = value
        return value

    def swift_sources(self, relative_root: Path) -> dict[Path, str]:
        root = self.root / relative_root
        if not root.is_dir():
            raise CheckFailure("source_boundary_unavailable")
        result: dict[Path, str] = {}
        try:
            paths = sorted(root.rglob("*.swift"))
        except OSError as error:
            raise CheckFailure("source_discovery_failed") from error
        if not paths:
            raise CheckFailure("source_boundary_empty")
        for path in paths:
            try:
                result[path.relative_to(self.root)] = path.read_text(encoding="utf-8")
            except (OSError, UnicodeError) as error:
                raise CheckFailure("source_read_failed") from error
        return result


def require_tokens(text: str, tokens: tuple[str, ...], threat: str) -> CheckResult:
    missing = tuple(token for token in tokens if token not in text)
    return CheckResult(len(tokens), (threat,) if missing else ())


def forbid_patterns(text: str, patterns: tuple[str, ...], threat: str) -> CheckResult:
    found = any(re.search(pattern, text, flags=re.IGNORECASE | re.MULTILINE) for pattern in patterns)
    return CheckResult(len(patterns), (threat,) if found else ())


def check_t60_01(snapshot: Snapshot) -> CheckResult:
    provider = snapshot.text(PROVIDER_RELATIVE)
    engine = snapshot.text(ENGINE_RELATIVE)
    required = require_tokens(
        engine,
        (
            "BeautyTeethWhiteningProvider.makeResult",
            "requestContext.canonicalImage",
            "requestContext.selectedFaceObservation",
            "resolveStillImageGeometry",
        ),
        "T-60-01",
    )
    forbidden = forbid_patterns(
        provider,
        (
            r"VNDetectFaceLandmarksRequest",
            r"VisionFaceDetector",
            r"faceDetector\s*\.\s*detect",
            r"canonicalize\s*\(",
            r"FaceGeometry",
            r"faceBounds",
            r"\bcache\b",
        ),
        "T-60-01",
    )
    failures = set(required.failures + forbidden.failures)
    return CheckResult(required.checks + forbidden.checks, tuple(sorted(failures)))


def check_t60_02(snapshot: Snapshot) -> CheckResult:
    provider = snapshot.text(PROVIDER_RELATIVE)
    tests = snapshot.text(PROVIDER_TEST_RELATIVE)
    required = require_tokens(
        provider + "\n" + tests,
        (
            "lipSupport.outer",
            "lipSupport.inner",
            "minimumStrongAreaRatio",
            "maximumStrongAreaRatio",
            "strongThreshold",
            "fixedStrongPixelCount",
            "adaptiveStrongPixelCount",
            "connectedCandidates",
            "NoAcceptedSeed",
            "SelfIntersecting",
        ),
        "T-60-02",
    )
    forbidden = forbid_patterns(
        provider,
        (r"synthetic", r"fallback", r"seedIndices\s*=\s*region", r"return\s+fixed\s*//\s*unsafe"),
        "T-60-02",
    )
    failures = set(required.failures + forbidden.failures)
    return CheckResult(required.checks + forbidden.checks, tuple(sorted(failures)))


def check_t60_03(snapshot: Snapshot) -> CheckResult:
    provider = snapshot.text(PROVIDER_RELATIVE)
    tests = snapshot.text(PROVIDER_TEST_RELATIVE)
    required = require_tokens(
        provider + "\n" + tests,
        (
            "hardEnvelope",
            "constrainToHardEnvelope",
            "finalMask = constrainToHardEnvelope",
            "boxBlur",
            "droppedFixedStrongPixelCount",
            "PostFilterHardReclip",
            "ProtectedLipTongueGumBracesHairAndSkin",
            "changedOutsideUnionPixelCount",
        ),
        "T-60-03",
    )
    forbidden = forbid_patterns(
        provider,
        (r"boxBlur[^\n]+\n\s*return\s+blur", r"isInsideHardEnvelope:\s*false"),
        "T-60-03",
    )
    failures = set(required.failures + forbidden.failures)
    return CheckResult(required.checks + forbidden.checks, tuple(sorted(failures)))


def check_t60_04(snapshot: Snapshot) -> CheckResult:
    transform = snapshot.text(TRANSFORM_RELATIVE)
    tests = snapshot.text(PROVIDER_TEST_RELATIVE)
    required = require_tokens(
        transform + "\n" + tests,
        (
            "maximumEffectiveStrength",
            "yellowNeutralizationFactor",
            "1.45",
            "0.62",
            "0.08",
            "0.14",
            "0.018",
            "0.045",
            "already-light",
            "LightlyWarm",
            "ReducesMaterialYellow",
            "SourceOnly",
        ),
        "T-60-04",
    )
    forbidden = forbid_patterns(
        transform,
        (
            r"\boutput\b",
            r"CIImage",
            r"CIColorControls",
            r"saturation\s*=\s*0",
            r"public\s+(?:struct|enum|class|func|var|let)",
            r"@_spi",
        ),
        "T-60-04",
    )
    failures = set(required.failures + forbidden.failures)
    return CheckResult(required.checks + forbidden.checks, tuple(sorted(failures)))


def check_t60_05(snapshot: Snapshot) -> CheckResult:
    provider = snapshot.text(PROVIDER_RELATIVE)
    engine = snapshot.text(ENGINE_RELATIVE)
    composition = snapshot.text(
        Path("BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift")
    )
    required = require_tokens(
        provider + "\n" + engine + "\n" + composition,
        (
            "owner.makeUnit",
            "BeautyLocalRetouchCompositionOwner",
            "compositionOwner.compose",
            "sourceBinding",
            "collisionPixelCount",
            "claimIndex - groupStart == 1",
            "isInsideHardEnvelope",
        ),
        "T-60-05",
    )
    return required


def check_t60_06(snapshot: Snapshot) -> CheckResult:
    engine = snapshot.text(ENGINE_RELATIVE)
    tests = snapshot.text(ENGINE_TEST_RELATIVE)
    pixel_start = engine.find("public func processResult(\n        pixelBuffer")
    pixel_end = engine.find("/// Returns an SDK-created image", pixel_start)
    reset_start = engine.find("public func reset()")
    reset_end = engine.find("public var resetCountForTesting", reset_start)
    if min(pixel_start, pixel_end, reset_start, reset_end) < 0:
        return CheckResult(2, ("T-60-06",))
    forbidden = forbid_patterns(
        engine[pixel_start:pixel_end] + engine[reset_start:reset_end],
        (r"BeautyTeethWhiteningProvider", r"BeautyLocalRetouchCompositionOwner"),
        "T-60-06",
    )
    required = require_tokens(
        tests,
        (
            "ValidMalformedValidRequestSequenceRetainsNoProviderState",
            "IndependentParallelRequestsKeepProviderAndSourceOwnershipIsolated",
            "PixelBufferAndResetPerformZeroTeethProviderWork",
            "retainedMappedCoordinateCount",
        ),
        "T-60-06",
    )
    failures = set(required.failures + forbidden.failures)
    return CheckResult(required.checks + forbidden.checks, tuple(sorted(failures)))


def tracked_phase_privacy_text(snapshot: Snapshot) -> str:
    paths: set[Path] = set()
    for command in (
        ["git", "ls-files", "-z"],
        ["git", "diff", "--cached", "--name-only", "-z"],
    ):
        try:
            result = subprocess.run(
                command,
                cwd=snapshot.root,
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
            )
        except (OSError, subprocess.CalledProcessError) as error:
            raise CheckFailure("privacy_inventory_failed") from error
        for raw in result.stdout.split(b"\0"):
            if not raw:
                continue
            try:
                relative = Path(raw.decode("utf-8"))
            except UnicodeDecodeError as error:
                raise CheckFailure("privacy_inventory_decode_failed") from error
            if relative == PHASE_DIR or PHASE_DIR in relative.parents:
                paths.add(relative)
    texts: list[str] = []
    for relative in sorted(paths):
        path = snapshot.root / relative
        if path.suffix.lower() not in {".md", ".json", ".py", ".js"}:
            continue
        try:
            texts.append(path.read_text(encoding="utf-8"))
        except (OSError, UnicodeError) as error:
            raise CheckFailure("privacy_source_failed") from error
    return "\n".join(texts)


def check_t60_07(snapshot: Snapshot) -> CheckResult:
    provider = snapshot.text(PROVIDER_RELATIVE)
    transform = snapshot.text(TRANSFORM_RELATIVE)
    private_test = snapshot.text(PRIVATE_TEST_RELATIVE)
    phase_text = tracked_phase_privacy_text(snapshot)
    required = require_tokens(
        private_test,
        (
            "PHASE60_REQUIRE_LOCAL_EVIDENCE",
            "PHASE59_TEETH_BUNDLE",
            "phase60_private_evidence_opt_in",
            "private_common_bounds_failed",
            "private_positive_bounds_failed",
            "private_negative_bounds_failed",
        ),
        "T-60-07",
    )
    forbidden_source = forbid_patterns(
        provider + "\n" + transform,
        (
            r"CustomStringConvertible",
            r"CustomReflectable",
            r"\bCodable\b",
            r"\bEncodable\b",
            r"\bDecodable\b",
            r"\bprint\s*\(",
            r"\bLogger\b",
            r"metrics\s*\[",
            r"@_spi",
            r"public\s+(?:struct|enum|class|func|var|let)",
        ),
        "T-60-07",
    )
    forbidden_phase = forbid_patterns(
        phase_text,
        (
            r"/Users/",
            r"fixture_00[12]",
            r"Tooth-(?:white|yellow)",
            r"[a-f0-9]{64}",
            r"reviewer(?:_id| identity| name)",
        ),
        "T-60-07",
    )
    failures = set(required.failures + forbidden_source.failures + forbidden_phase.failures)
    return CheckResult(
        required.checks + forbidden_source.checks + forbidden_phase.checks,
        tuple(sorted(failures)),
    )


def check_t60_08(snapshot: Snapshot) -> CheckResult:
    sdk_sources = snapshot.swift_sources(Path("BeautySDK/Sources"))
    demo_sources = snapshot.swift_sources(Path("BeautyDemo/BeautyDemo"))
    demo_model = snapshot.text(DEMO_MODEL_RELATIVE)
    package = snapshot.text(Path("BeautySDK/Package.swift"))
    provider = snapshot.text(PROVIDER_RELATIVE)
    combined_sdk = "\n".join(sdk_sources.values())
    combined_demo = "\n".join(demo_sources.values())
    required = require_tokens(
        demo_model,
        (
            'unsupported("lips.teeth"',
            'unsupported("eyes.redness"',
            'unsupported("eyes.fat"',
        ),
        "T-60-08",
    )
    forbidden = forbid_patterns(
        combined_demo + "\n" + provider + "\n" + package,
        (
            r"teethWhitening\s*[:=]",
            r"scleraRednessReduction",
            r"upperEyelidFullnessReduction",
            r"VNDetectFaceLandmarksRequest",
            r"CoreML|MLModel",
            r"URLSession|NWConnection|Network\.framework",
            r"\.package\s*\(",
        ),
        "T-60-08",
    )
    sibling_forbidden = forbid_patterns(
        combined_sdk,
        (r"scleraRednessReduction", r"upperEyelidFullnessReduction"),
        "T-60-08",
    )
    failures = set(required.failures + forbidden.failures + sibling_forbidden.failures)
    return CheckResult(
        required.checks + forbidden.checks + sibling_forbidden.checks,
        tuple(sorted(failures)),
    )


CHECKS: dict[str, Callable[[Snapshot], CheckResult]] = {
    "T-60-01": check_t60_01,
    "T-60-02": check_t60_02,
    "T-60-03": check_t60_03,
    "T-60-04": check_t60_04,
    "T-60-05": check_t60_05,
    "T-60-06": check_t60_06,
    "T-60-07": check_t60_07,
    "T-60-08": check_t60_08,
}


def evaluate(snapshot: Snapshot, threats: tuple[str, ...]) -> CheckResult:
    checks = 0
    failures: set[str] = set()
    for threat in threats:
        if threat not in CHECKS:
            raise CheckFailure("unknown_threat")
        result = CHECKS[threat](snapshot)
        checks += result.checks
        failures.update(result.failures)
    return CheckResult(checks, tuple(sorted(failures)))


def write_fixture(root: Path) -> None:
    files = {
        PROVIDER_RELATIVE: """
package enum BeautyTeethWhiteningProvider {
  static let minimumStrongAreaRatio = 0.015
  static let maximumStrongAreaRatio = 0.94
  static let strongThreshold: Float = 0.15
  static func makeResult(lipSupport: Support, owner: Owner) {
    _ = lipSupport.outer; _ = lipSupport.inner
    let fixedStrongPixelCount = 4
    let adaptiveStrongPixelCount = connectedCandidates.count
    let hardEnvelope = connectedCandidates
    let finalMask = constrainToHardEnvelope(boxBlur(connectedCandidates), hardEnvelope: hardEnvelope)
    let droppedFixedStrongPixelCount = 0
    _ = owner.makeUnit(proposals: [])
  }
  static func connectedCandidates() {}
  static func constrainToHardEnvelope(_ value: Int) -> Int { value }
  static func boxBlur(_ value: Int) -> Int { value }
}
""",
        TRANSFORM_RELATIVE: """
package enum BeautyTeethWhiteningTransform {
  static let maximumEffectiveStrength: Float = 0.62
  static let yellowNeutralizationFactor: Float = 1.45
  // already-light no-op thresholds 0.08 0.14; lifts 0.018 and 0.045
}
""",
        ENGINE_RELATIVE: """
public func processResult(
        pixelBuffer: Buffer
) {}
/// Returns an SDK-created image
func still() {
 let route = resolveStillImageGeometry()
 let requestContext = Context()
 let compositionOwner = BeautyLocalRetouchCompositionOwner(source: requestContext.canonicalImage)
 _ = BeautyTeethWhiteningProvider.makeResult(source: requestContext.canonicalImage, lipSupport: requestContext.selectedFaceObservation, owner: compositionOwner)
 _ = compositionOwner.compose([])
}
public func reset() {}
public var resetCountForTesting = 0
""",
        TESTING_RELATIVE: "aggregate only",
        PROVIDER_TEST_RELATIVE: """
NoAcceptedSeed SelfIntersecting PostFilterHardReclip
ProtectedLipTongueGumBracesHairAndSkin changedOutsideUnionPixelCount
LightlyWarm ReducesMaterialYellow SourceOnly already-light
""",
        ENGINE_TEST_RELATIVE: """
ValidMalformedValidRequestSequenceRetainsNoProviderState
IndependentParallelRequestsKeepProviderAndSourceOwnershipIsolated
PixelBufferAndResetPerformZeroTeethProviderWork retainedMappedCoordinateCount
""",
        PRIVATE_TEST_RELATIVE: """
PHASE60_REQUIRE_LOCAL_EVIDENCE PHASE59_TEETH_BUNDLE
phase60_private_evidence_opt_in private_common_bounds_failed
private_positive_bounds_failed private_negative_bounds_failed
""",
        DEMO_MODEL_RELATIVE: """
unsupported("lips.teeth", title: "white")
unsupported("eyes.redness", title: "redness")
unsupported("eyes.fat", title: "fat")
""",
        Path("BeautySDK/Package.swift"): "let package = Package(name: \"BeautySDK\")",
        Path("BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift"): """
sourceBinding collisionPixelCount claimIndex - groupStart == 1 isInsideHardEnvelope
""",
        PHASE_DIR / "60-CONTEXT.md": "aggregate-only phase record",
    }
    for relative, text in files.items():
        path = root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
    (root / "BeautySDK/Sources/Placeholder.swift").write_text("struct Placeholder {}", encoding="utf-8")
    (root / "BeautyDemo/BeautyDemo/Placeholder.swift").write_text("struct Placeholder {}", encoding="utf-8")
    subprocess.run(["git", "init", "-q"], cwd=root, check=True, stdout=subprocess.DEVNULL)
    subprocess.run(["git", "add", "."], cwd=root, check=True, stdout=subprocess.DEVNULL)


def mutate(root: Path, relative: Path, old: str, new: str) -> None:
    path = root / relative
    text = path.read_text(encoding="utf-8")
    if old not in text:
        raise CheckFailure("self_test_anchor_missing")
    path.write_text(text.replace(old, new, 1), encoding="utf-8")


def self_test() -> int:
    mutations = (
        ("T-60-01", PROVIDER_RELATIVE, "package enum", "VNDetectFaceLandmarksRequest\npackage enum"),
        ("T-60-02", PROVIDER_RELATIVE, "minimumStrongAreaRatio", "removedMinimumRatio"),
        (
            "T-60-03",
            PROVIDER_RELATIVE,
            "let finalMask = constrainToHardEnvelope(boxBlur(connectedCandidates), hardEnvelope: hardEnvelope)",
            "let finalMask = boxBlur(connectedCandidates)",
        ),
        ("T-60-04", TRANSFORM_RELATIVE, "1.45", "2.40"),
        ("T-60-05", PROVIDER_RELATIVE, "owner.makeUnit", "owner.removedUnit"),
        ("T-60-06", ENGINE_RELATIVE, ") {}\n/// Returns", ") { BeautyTeethWhiteningProvider.makeResult() }\n/// Returns"),
        ("T-60-07", PHASE_DIR / "60-CONTEXT.md", "aggregate-only", "/Users/example/private.png"),
        ("T-60-08", DEMO_MODEL_RELATIVE, "unsupported(\"lips.teeth\"", "teethWhitening = unsupported(\"lips.teeth\""),
    )
    passed = 0
    with TemporaryDirectory(prefix="phase60-check-") as temporary:
        base = Path(temporary)
        for threat, relative, old, new in mutations:
            case = base / threat
            write_fixture(case)
            clean = evaluate(Snapshot(case), (threat,))
            if clean.failures:
                raise CheckFailure("self_test_clean_fixture_failed")
            mutate(case, relative, old, new)
            changed = evaluate(Snapshot(case), (threat,))
            if threat not in changed.failures:
                raise CheckFailure(f"self_test_mutation_survived:{threat}")
            passed += 1
    return passed


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(add_help=True)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--provider", action="store_true")
    modes.add_argument("--integration", action="store_true")
    modes.add_argument("--live", action="store_true")
    modes.add_argument("--threat", choices=THREAT_IDS)
    parser.add_argument("--repo-root", default=".")
    return parser.parse_args()


def main() -> int:
    arguments = parse_arguments()
    try:
        if arguments.self_test:
            count = self_test()
            print(json.dumps({"mutationCount": count, "status": "pass"}, sort_keys=True))
            return 0
        if arguments.provider:
            threats = ("T-60-02", "T-60-03", "T-60-04", "T-60-05")
        elif arguments.integration:
            threats = ("T-60-01", "T-60-05", "T-60-06", "T-60-08")
        elif arguments.threat:
            threats = (arguments.threat,)
        else:
            threats = THREAT_IDS
        result = evaluate(Snapshot(Path(arguments.repo_root)), threats)
        if result.failures:
            print(json.dumps({"status": "fail", "threats": list(result.failures)}, sort_keys=True))
            return 1
        print(json.dumps({"checkCount": result.checks, "status": "pass"}, sort_keys=True))
        return 0
    except CheckFailure:
        print(json.dumps({"status": "fail", "threats": ["checker_error"]}, sort_keys=True))
        return 1


if __name__ == "__main__":
    sys.exit(main())
