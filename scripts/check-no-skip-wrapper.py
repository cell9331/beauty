#!/usr/bin/env python3
"""Mutation-test the mandatory wrapper's exact-once and ordering contract."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


MAX_WRAPPER_BYTES = 65_536
EXPECTED_OPT_IN_TESTS = (
    "testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture",
    "testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload",
    "testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload",
    "testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade",
    "testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope",
    "testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope",
    "testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds",
    "testAuthorizedPairSupportsFullScleraExpansionFromFrozenFocalAnchor",
    "testAuthorizedCalibratedLuminancePairThroughLiveVisionAndPublicFacade",
)
EXPECTED_OPT_IN_ENV = (
    "BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1",
    "PHASE60_REQUIRE_LOCAL_EVIDENCE=1",
    'PHASE59_TEETH_BUNDLE="${teeth_bundle}"',
    "PHASE63_REQUIRE_LOCAL_EVIDENCE=1",
    'PHASE62_SCLERA_BUNDLE="${sclera_bundle}"',
)
EXPECTED_BUNDLE_OVERRIDES = (
    'readonly teeth_bundle="${PHASE59_TEETH_BUNDLE:-${repository_root}/example-images/local-retouch-review/teeth-evidence-20260805}"',
    'readonly sclera_bundle="${PHASE62_SCLERA_BUNDLE:-${repository_root}/example-images/local-retouch-review/evidence-pair-current}"',
)
ORDERED_PATTERNS = (
    ("archive", r'python3\s+"\$\{repository_root\}/scripts/archive-legacy-ui\.py"\s+verify\b'),
    ("boundary-self", r'bash\s+"\$\{repository_root\}/scripts/check-sdk-only-boundary\.sh"\s*\\?\s+--self-test\b'),
    ("boundary-live", r'bash\s+"\$\{repository_root\}/scripts/check-sdk-only-boundary\.sh"\s*\\?\s+--post-archive\b'),
    ("decision-self", r'python3\s+"\$\{decision_checker\}"\s+--self-test\s+--repo-root\s+"\$\{repository_root\}"'),
    ("decision-live", r'python3\s+"\$\{decision_checker\}"\s+--live\s+--repo-root\s+"\$\{repository_root\}"'),
    ("backend-neutral", r'bash\s+"\$\{repository_root\}/scripts/check-backend-neutral-contract\.sh"'),
    ("metal-runtime", r'bash\s+"\$\{repository_root\}/scripts/check-metal-runtime\.sh"'),
    ("metal-features", r'bash\s+"\$\{repository_root\}/scripts/check-metal-feature-passes\.sh"'),
    ("backend-configuration", r'bash\s+"\$\{repository_root\}/scripts/check-backend-configuration\.sh"'),
    ("parity-run", r'bash\s+"\$\{repository_root\}/scripts/check-backend-parity\.sh"\s+>"\$\{parity_record\}"'),
    ("parity-reduce", r'bash\s+"\$\{repository_root\}/scripts/check-backend-parity\.sh"\s+--validate-record\s+"\$\{parity_record\}"'),
    ("consumer", r'bash\s+"\$\{repository_root\}/scripts/check-swiftpm-consumer\.sh"'),
    ("oracle", r'bash\s+"\$\{repository_root\}/scripts/check-cpu-reference-oracles\.sh"'),
    ("capture", r'python3\s+"\$\{transcript_checker\}"\s+capture\b'),
    ("swift-child", r'swift\s+test\s+--package-path\s+BeautySDK\b'),
    ("reduce", r'python3\s+"\$\{transcript_checker\}"\s+"\$\{checker_arguments\[@\]\}"'),
)


def validate_source(source: str) -> list[str]:
    reasons: list[str] = []
    if not source.startswith("#!/usr/bin/env bash\n") or "set -euo pipefail" not in source:
        reasons.append("wrapper.shell-contract")

    positions: list[int] = []
    for identity, pattern in ORDERED_PATTERNS:
        matches = list(re.finditer(pattern, source, re.MULTILINE))
        if len(matches) != 1:
            reasons.append(f"wrapper.count.{identity}")
        else:
            positions.append(matches[0].start())
            line_end = source.find("\n", matches[0].end())
            line = source[matches[0].start():line_end if line_end >= 0 else len(source)]
            if identity in {"decision-self", "decision-live", "swift-child"} and "&" in line:
                reasons.append(f"wrapper.concurrent.{identity}")
    if len(positions) == len(ORDERED_PATTERNS) and positions != sorted(positions):
        reasons.append("wrapper.order")

    for identity in EXPECTED_OPT_IN_TESTS:
        if source.count(f'"{identity}"') != 1:
            reasons.append("wrapper.opt-in-identity")
            break
    for assignment in EXPECTED_OPT_IN_ENV:
        if source.count(assignment) != 1:
            reasons.append("wrapper.opt-in-environment")
            break
    for assignment in EXPECTED_BUNDLE_OVERRIDES:
        if source.count(assignment) != 1:
            reasons.append("wrapper.fixture-override")
            break
    if source.count('echo "no_skip_swiftpm_passed opt_in_tests=9 skipped_tests=0"') != 1:
        reasons.append("wrapper.aggregate-output")
    return sorted(set(reasons))


def load_wrapper(path: Path) -> str:
    try:
        if path.is_symlink() or not path.is_file():
            raise ValueError
        raw = path.read_bytes()
        if not raw or len(raw) > MAX_WRAPPER_BYTES:
            raise ValueError
        return raw.decode("utf-8")
    except (OSError, UnicodeError, ValueError):
        raise RuntimeError("wrapper.input-invalid") from None


def self_test(source: str) -> tuple[int, int]:
    if validate_source(source):
        raise RuntimeError("wrapper.baseline-invalid")

    mutations = (
        source + '\npython3 "${decision_checker}" --self-test --repo-root "${repository_root}"\n',
        source.replace("--live --repo-root", "--disabled --repo-root", 1),
        (
            'python3 "${decision_checker}" --live --repo-root "${repository_root}"\n'
            + source.replace("--live --repo-root", "--disabled --repo-root", 1)
        ),
        source + "\nswift test --package-path BeautySDK\n",
        source.replace(EXPECTED_OPT_IN_TESTS[0], "removed-opt-in", 1),
        source.replace(EXPECTED_OPT_IN_TESTS[-1], "removed-upper-eyelid-opt-in", 1),
        source.replace("opt_in_tests=9 skipped_tests=0", "opt_in_tests=8 skipped_tests=0", 1),
        source.replace(EXPECTED_OPT_IN_ENV[0], "REMOVED_OPT_IN=1", 1),
        source.replace("${PHASE59_TEETH_BUNDLE:-", "${REMOVED_TEETH_BUNDLE:-", 1),
        source.replace(
            'python3 "${decision_checker}" --self-test --repo-root "${repository_root}"',
            'python3 "${decision_checker}" --self-test --repo-root "${repository_root}" &',
            1,
        ),
        (
            source.replace("archive-legacy-ui.py\" verify", "archive-legacy-ui.py\" inspect", 1)
            + '\npython3 "${repository_root}/scripts/archive-legacy-ui.py" verify --output x\n'
        ),
        source + '\nbash "${repository_root}/scripts/check-backend-neutral-contract.sh"\n',
        (
            'bash "${repository_root}/scripts/check-cpu-reference-oracles.sh"\n'
            + source.replace("check-cpu-reference-oracles.sh", "removed-cpu-oracle.sh", 1)
        ),
    )
    rejected = sum(bool(validate_source(mutated)) for mutated in mutations)
    if rejected != len(mutations):
        raise RuntimeError("wrapper.mutation-accepted")
    return len(mutations), rejected


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--wrapper", required=True)
    args = parser.parse_args()
    if not args.self_test:
        parser.error("choose --self-test")
    try:
        checks, rejected = self_test(load_wrapper(Path(args.wrapper).resolve()))
        result = {
            "checks": checks,
            "mode": "self-test",
            "mutation_rejections": rejected,
            "status": "pass",
        }
        status = 0
    except RuntimeError as error:
        result = {
            "mode": "self-test",
            "reason_count": 1,
            "reasons": [str(error)],
            "status": "fail",
        }
        status = 1
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))
    return status


if __name__ == "__main__":
    raise SystemExit(main())
