#!/usr/bin/env python3
"""Fail-closed Phase 63 guarded sclera production boundary checker."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass, replace
from pathlib import Path

THREATS = tuple(f"T-63-{index:02d}" for index in range(1, 9))
PHASE = Path(".planning/phases/63-guarded-per-eye-sclera-production-integration")


@dataclass(frozen=True)
class Snapshot:
    exact_open_one_request: bool
    actual_per_eye_support: bool
    prescore_protection: bool
    post_feather_reclip: bool
    immutable_bounded_transform: bool
    shared_owner_recovery: bool
    private_aggregate_privacy: bool
    deferred_scope_absent: bool

    def value(self, threat: str) -> bool:
        return getattr(self, {
            "T-63-01": "exact_open_one_request",
            "T-63-02": "actual_per_eye_support",
            "T-63-03": "prescore_protection",
            "T-63-04": "post_feather_reclip",
            "T-63-05": "immutable_bounded_transform",
            "T-63-06": "shared_owner_recovery",
            "T-63-07": "private_aggregate_privacy",
            "T-63-08": "deferred_scope_absent",
        }[threat])


def read_required(root: Path, relative: str) -> str:
    path = root / relative
    if not path.is_file():
        raise RuntimeError("required_source_missing")
    return path.read_text(encoding="utf-8")


def has_all(text: str, needles: tuple[str, ...]) -> bool:
    return all(needle in text for needle in needles)


def live_snapshot(root: Path) -> Snapshot:
    provider = read_required(root, "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift")
    transform = read_required(root, "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift")
    engine = read_required(root, "BeautySDK/Sources/BeautySDK/BeautyEngine.swift")
    hooks = read_required(root, "BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift")
    tests = read_required(root, "BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift")
    integration = read_required(root, "BeautySDK/Tests/BeautyCoreTests/BeautyEngineScleraRednessIntegrationTests.swift")
    private_test = read_required(root, "BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift")
    ledger = read_required(root, ".planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-EVIDENCE-DECISIONS.json")
    renderer = read_required(root, "BeautySDK/Sources/BeautyExampleRenderer/main.swift")

    exact_open = '"feature": "sclera_redness"' in ledger and '"status": "open"' in ledger
    one_request = engine.count("BeautyScleraRednessProvider.makeResult(") == 1 and "VNDetectFaceLandmarksRequest" not in provider
    t1 = exact_open and one_request and has_all(engine, ("observedEyeSupport", "observedEyeOrder"))
    t2 = has_all(provider, ("eyeOrder == .canonical", "pupil.count == 1", "duplicateSide", "sorted")) and has_all(tests, ("testMissingOrMalformedPeerAbstainsOnlyThatEye", "testPupilMustBeExactlyOneFiniteContainedPlausibleSample"))
    t3 = has_all(provider, ("hardEnvelope", "contourMargin", "pupilExclusion", "highlightExclusion", "lashExclusion", "beforeRednessScore"))
    t4 = has_all(provider, ("boxBlur", "constrainToHardEnvelope", "isInsideHardEnvelope: true")) and "testHardEnvelopeExcludesPupilHighlightsLashMarginSkinAndExteriorAfterFeather" in tests
    t5 = has_all(transform, ("redExcess", "sourceLuminance", "toNearestOrAwayFromZero")) and has_all(provider, ("softWeightQ16", "BeautyScleraRednessTransform.target")) and "outputData" not in provider
    t6 = has_all(engine, ("hasDirectScleraIntent", "compositionOwner", "providerResult.units")) and has_all(integration, ("testTeethScleraAndBothActivateIndependentlyButShareOneOwner", "testInvalidOrderNoFaceAndUnsafeEyesAbstainWithoutStaleReuse", "testIndependentParallelRequestsKeepPerEyeStateIsolated")) and "SDKTestingScleraProviderObservation" in hooks
    t7 = has_all(private_test, ("PHASE63_REQUIRE_LOCAL_EVIDENCE", "changedOutsideReviewedMask == 0", "meanRedExcessAfter < measurement.meanRedExcessBefore")) and "PHASE62_SCLERA_BUNDLE" in private_test
    forbidden_renderer = "scleraRednessReduction_1p00"
    t8 = forbidden_renderer not in renderer and has_all(integration, ("testPixelBufferResetAndOpaqueTestingDemandPerformZeroScleraWork",)) and all(token not in provider + transform for token in ("URLSession", "VNDetectFaceLandmarksRequest", "MLModel", "public "))
    return Snapshot(t1, t2, t3, t4, t5, t6, t7, t8)


def scan_privacy(root: Path) -> None:
    runner = root / ".planning/phases/62-sclera-evidence-and-admission-contract/62-private-evidence-runner.js"
    child = subprocess.run(
        ["node", str(runner), "--scan-tracked-staged"],
        cwd=root,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        timeout=30,
        check=False,
    )
    if child.returncode != 0 or '"status":"pass"' not in child.stdout:
        raise RuntimeError("privacy_scan_failed")


def run_self_test() -> int:
    baseline = Snapshot(*(True for _ in THREATS))
    rejected = 0
    fields = tuple(Snapshot.__dataclass_fields__)
    for threat, field in zip(THREATS, fields):
        mutation = replace(baseline, **{field: False})
        if mutation.value(threat):
            raise RuntimeError("mutation_not_rejected")
        rejected += 1
    if rejected != 8:
        raise RuntimeError("mutation_count_invalid")
    return rejected


def emit(status: str, **extra: object) -> None:
    print(json.dumps({"status": status, **extra}, separators=(",", ":"), sort_keys=True))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--provider", action="store_true")
    parser.add_argument("--integration", action="store_true")
    parser.add_argument("--privacy", action="store_true")
    parser.add_argument("--threat", choices=THREATS)
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()
    modes = sum(bool(value) for value in (args.self_test, args.live, args.provider, args.integration, args.privacy, args.threat))
    if modes != 1:
        emit("fail")
        return 2
    try:
        if args.self_test:
            emit("pass", mutation_rejections=run_self_test())
            return 0
        root = Path(args.repo_root).resolve()
        if args.privacy:
            scan_privacy(root)
            emit("pass")
            return 0
        snapshot = live_snapshot(root)
        selected = THREATS
        if args.provider:
            selected = ("T-63-02", "T-63-03", "T-63-04", "T-63-05")
        elif args.integration:
            selected = ("T-63-01", "T-63-02", "T-63-06", "T-63-08")
        elif args.threat:
            selected = (args.threat,)
        failed = [threat for threat in selected if not snapshot.value(threat)]
        if failed:
            emit("fail", failed=failed)
            return 1
        if args.live:
            scan_privacy(root)
        emit("pass", checked=len(selected))
        return 0
    except Exception:
        emit("fail")
        return 1


if __name__ == "__main__":
    sys.exit(main())

