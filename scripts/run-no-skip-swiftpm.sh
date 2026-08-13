#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly teeth_bundle="${repository_root}/example-images/local-retouch-review/teeth-evidence-20260805"
readonly sclera_bundle="${repository_root}/example-images/local-retouch-review/evidence-pair-current"
readonly expected_opt_in_tests=(
  "testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture"
  "testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload"
  "testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload"
  "testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade"
  "testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope"
  "testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope"
  "testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds"
  "testAuthorizedPairSupportsFullScleraExpansionFromFrozenFocalAnchor"
)

for command_name in swift rg git; do
  command -v "${command_name}" >/dev/null || {
    echo "no_skip_preflight_failed"
    exit 1
  }
done

for bundle in "${teeth_bundle}" "${sclera_bundle}"; do
  [[ -f "${bundle}/manifest.json" ]] || {
    echo "no_skip_private_bundle_unavailable"
    exit 1
  }
  git -C "${repository_root}" check-ignore -q "${bundle}" || {
    echo "no_skip_private_bundle_not_ignored"
    exit 1
  }
done

transcript="$(mktemp "${TMPDIR:-/tmp}/beauty-no-skip.XXXXXX")"
trap 'rm -f "${transcript}"' EXIT

set +e
(
  cd "${repository_root}"
  BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 \
  PHASE60_REQUIRE_LOCAL_EVIDENCE=1 \
  PHASE59_TEETH_BUNDLE="${teeth_bundle}" \
  PHASE63_REQUIRE_LOCAL_EVIDENCE=1 \
  PHASE62_SCLERA_BUNDLE="${sclera_bundle}" \
    swift test --package-path BeautySDK
) 2>&1 | tee "${transcript}"
test_status=${PIPESTATUS[0]}
set -e

[[ "${test_status}" -eq 0 ]] || {
  echo "no_skip_swiftpm_failed"
  exit 1
}

if rg -q "Test Case '.*' skipped|tests? skipped" "${transcript}"; then
  echo "no_skip_unexpected_skip"
  exit 1
fi

for test_name in "${expected_opt_in_tests[@]}"; do
  [[ "$(rg -c "${test_name}.*passed" "${transcript}")" -eq 1 ]] || {
    echo "no_skip_opt_in_identity_failed"
    exit 1
  }
done

rg -q "Test Suite 'All tests' passed" "${transcript}" || {
  echo "no_skip_aggregate_missing"
  exit 1
}

echo "no_skip_swiftpm_passed opt_in_tests=8 skipped_tests=0"
