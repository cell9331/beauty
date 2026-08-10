"use strict";

const SCHEMA = "phase64-no-skip-swiftpm-v1";

const OPT_IN_TESTS = Object.freeze([
  "VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture",
  "VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload",
  "VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload",
  "BeautyEngineGeometryFacadeTests.testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade",
  "BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope",
  "BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope",
  "BeautyTeethWhiteningRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds",
  "BeautyScleraRednessRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds",
]);

function parseXCTestSummary() {
  throw new Error("not_implemented");
}

function classifyChildResult() {
  throw new Error("not_implemented");
}

function discoverPrivateBundles() {
  throw new Error("not_implemented");
}

function positiveTranscript() {
  const rows = OPT_IN_TESTS.map((identity) => {
    const separator = identity.indexOf(".");
    const suite = identity.slice(0, separator);
    const method = identity.slice(separator + 1);
    return `Test Case '-[FixtureModule.${suite} ${method}]' passed (0.001 seconds).`;
  });
  return Buffer.from([
    "Test Suite 'Selected tests' started at 2026-08-10 00:00:00.000.",
    ...rows,
    "Test Suite 'All tests' passed at 2026-08-10 00:00:00.010.",
    "\t Executed 644 tests, with 0 failures (0 unexpected) in 0.010 (0.020) seconds",
  ].join("\n"), "utf8");
}

function runSelfTests() {
  const firstLocator = "/private/first-sentinel-bundle";
  const secondLocator = "/private/second-sentinel-bundle";
  const positive = classifyChildResult({
    status: 0,
    stdout: positiveTranscript(),
    stderr: Buffer.alloc(0),
  }, [firstLocator]);
  if (JSON.stringify(positive) !== JSON.stringify({
    schema: SCHEMA,
    status: "pass",
    executed_tests: 644,
    failed_tests: 0,
    skipped_tests: 0,
    opt_in_tests_executed: 8,
  })) {
    throw new Error("self_test_positive_aggregate_invalid");
  }

  let mutationRejections = 0;
  const reject = (callback) => {
    try {
      callback();
    } catch (_) {
      mutationRejections += 1;
      return;
    }
    throw new Error("self_test_mutation_not_rejected");
  };
  const child = (stdout = positiveTranscript(), overrides = {}) => ({
    status: 0,
    stdout,
    stderr: Buffer.alloc(0),
    ...overrides,
  });
  const replace = (pattern, replacement) => Buffer.from(
    positiveTranscript().toString("utf8").replace(pattern, replacement),
    "utf8",
  );

  reject(() => classifyChildResult(child(undefined, { status: 1 }), [firstLocator]));
  reject(() => classifyChildResult(child(undefined, { error: new Error("spawn") }), [firstLocator]));
  reject(() => classifyChildResult(child(undefined, { error: Object.assign(new Error("timeout"), { code: "ETIMEDOUT" }) }), [firstLocator]));
  reject(() => classifyChildResult(child(undefined, { error: Object.assign(new Error("maxBuffer"), { code: "ENOBUFS" }) }), [firstLocator]));
  reject(() => classifyChildResult(child(replace(/Test Suite 'All tests'[\s\S]*$/, "")), [firstLocator]));
  reject(() => classifyChildResult(child(Buffer.concat([positiveTranscript(), Buffer.from("\n"), positiveTranscript()])), [firstLocator]));
  reject(() => classifyChildResult(child(replace("Executed 644 tests", "Executed banana tests")), [firstLocator]));
  reject(() => classifyChildResult(child(replace("Executed 644 tests", "Executed 0 tests")), [firstLocator]));
  reject(() => classifyChildResult(child(replace("with 0 failures", "with 1 failure")), [firstLocator]));
  reject(() => classifyChildResult(child(replace("with 0 failures (0 unexpected)", "with 0 failures (0 unexpected), 1 test skipped")), [firstLocator]));
  reject(() => classifyChildResult(child(replace(/^Test Case .*\n/m, "")), [firstLocator]));
  reject(() => classifyChildResult(child(replace(/^(Test Case .*\n)/m, "$1$1")), [firstLocator]));
  reject(() => classifyChildResult(child(replace(" passed (0.001 seconds).", " failed (0.001 seconds).")), [firstLocator]));
  reject(() => {
    const first = classifyChildResult(child(), [secondLocator]);
    const second = classifyChildResult(
      child(Buffer.concat([positiveTranscript(), Buffer.from(`\n${secondLocator}\n`)])),
      [secondLocator],
    );
    if (JSON.stringify(first) === JSON.stringify(second)) throw new Error("isolation_cross_contamination");
  });

  if (mutationRejections !== 14) throw new Error("self_test_count_invalid");
  return mutationRejections;
}

function runFullSuite() {
  throw new Error("not_implemented");
}

function fixedRunAggregate(status, aggregate = {}) {
  return {
    schema: SCHEMA,
    status,
    executed_tests: aggregate.executed_tests || 0,
    failed_tests: aggregate.failed_tests || 0,
    skipped_tests: aggregate.skipped_tests || 0,
    opt_in_tests_executed: aggregate.opt_in_tests_executed || 0,
  };
}

function main() {
  try {
    const argv = process.argv.slice(2);
    if (argv.length !== 1) throw new Error("runner_usage");
    if (argv[0] === "--self-test") {
      process.stdout.write(`${JSON.stringify({
        schema: SCHEMA,
        status: "pass",
        mutation_rejections: runSelfTests(),
      })}\n`);
    } else if (argv[0] === "--run") {
      process.stdout.write(`${JSON.stringify(runFullSuite())}\n`);
    } else {
      throw new Error("runner_usage");
    }
  } catch (_) {
    process.stdout.write(`${JSON.stringify(fixedRunAggregate("fail"))}\n`);
    process.exitCode = 1;
  }
}

if (require.main === module) main();

module.exports = {
  OPT_IN_TESTS,
  parseXCTestSummary,
  classifyChildResult,
  discoverPrivateBundles,
  runSelfTests,
  runFullSuite,
};
