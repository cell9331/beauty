#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly teeth_bundle="${repository_root}/example-images/local-retouch-review/teeth-evidence-20260805"
readonly sclera_bundle="${repository_root}/example-images/local-retouch-review/evidence-pair-current"
readonly transcript_checker="${repository_root}/scripts/check-no-skip-transcript.py"
readonly transcript_maximum_bytes=$((16 * 1024 * 1024))
readonly transcript_maximum_lines=200000
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

if [[ "${1:-}" == "--self-test" ]]; then
  [[ "$#" -eq 1 ]] || exit 2
  exec python3 "${transcript_checker}" self-test
fi
[[ "$#" -eq 0 ]] || exit 2

for command_name in python3 swift git; do
  command -v "${command_name}" >/dev/null || {
    echo "no_skip_preflight_failed"
    exit 1
  }
done

if ! python3 "${repository_root}/scripts/archive-legacy-ui.py" verify \
  --output "${repository_root}/archives/legacy-ui" >/dev/null 2>&1; then
  echo "no_skip_archive_verification_failed"
  exit 1
fi
echo "no_skip_archive_verified"

if ! bash "${repository_root}/scripts/check-sdk-only-boundary.sh" \
  --post-archive >/dev/null 2>&1; then
  echo "no_skip_sdk_boundary_failed"
  exit 1
fi
echo "no_skip_sdk_boundary_verified"

if ! bash "${repository_root}/scripts/check-swiftpm-consumer.sh" >/dev/null 2>&1; then
  echo "no_skip_swiftpm_consumer_failed"
  exit 1
fi
echo "no_skip_swiftpm_consumer_verified"

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
  python3 "${transcript_checker}" capture \
    --output "${transcript}" \
    --max-bytes "${transcript_maximum_bytes}" \
    --max-lines "${transcript_maximum_lines}" \
    -- env \
      BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS=1 \
      PHASE60_REQUIRE_LOCAL_EVIDENCE=1 \
      PHASE59_TEETH_BUNDLE="${teeth_bundle}" \
      PHASE63_REQUIRE_LOCAL_EVIDENCE=1 \
      PHASE62_SCLERA_BUNDLE="${sclera_bundle}" \
      swift test --package-path BeautySDK
)
test_status=$?
set -e

[[ "${test_status}" -ne 3 ]] || {
  echo "no_skip_transcript_oversized"
  exit 1
}

[[ "${test_status}" -eq 0 ]] || {
  echo "no_skip_swiftpm_failed"
  exit 1
}

checker_arguments=(check --input "${transcript}")
for test_name in "${expected_opt_in_tests[@]}"; do
  checker_arguments+=(--expected "${test_name}")
done
python3 "${transcript_checker}" "${checker_arguments[@]}" || {
  echo "no_skip_transcript_accounting_failed"
  exit 1
}

echo "no_skip_swiftpm_passed opt_in_tests=8 skipped_tests=0"
