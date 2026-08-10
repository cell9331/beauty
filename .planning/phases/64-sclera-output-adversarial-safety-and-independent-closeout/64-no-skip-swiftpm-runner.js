"use strict";

const path = require("node:path");
const { TextDecoder } = require("node:util");
const { spawnSync } = require("node:child_process");

const SCHEMA = "phase64-no-skip-swiftpm-v1";
const ROOT = path.resolve(__dirname, "..", "..", "..");
const MAX_OUTPUT_BYTES = 64 * 1024 * 1024;
const FULL_SUITE_TIMEOUT_MILLISECONDS = 30 * 60 * 1000;
const PHASE59_RUNNER = path.join(
  ROOT,
  ".planning/phases/59-teeth-evidence-and-admission-contract/59-private-evidence-runner.js",
);
const PHASE62_RUNNER = path.join(
  ROOT,
  ".planning/phases/62-sclera-evidence-and-admission-contract/62-private-evidence-runner.js",
);
const TeethRunner = require(PHASE59_RUNNER);
const ScleraRunner = require(PHASE62_RUNNER);

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

function decodeOutput(value) {
  if (typeof value === "string") return value;
  if (!Buffer.isBuffer(value)) throw new Error("child_output_type_invalid");
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(value);
  } catch (_) {
    throw new Error("child_output_utf8_invalid");
  }
}

function normalizeTestIdentity(raw) {
  let candidate = raw.trim();
  const objc = candidate.match(/^-\[([^\s\]]+)\s+([^\]]+)\]$/);
  if (objc) {
    const suite = objc[1].split(".").pop();
    candidate = `${suite}.${objc[2]}`;
  } else {
    candidate = candidate.replaceAll("/", ".");
  }
  return OPT_IN_TESTS.find((identity) => (
    candidate === identity || candidate.endsWith(`.${identity}`)
  )) || null;
}

function parseXCTestSummary(transcript) {
  if (typeof transcript !== "string") throw new Error("xctest_transcript_type_invalid");
  const allTests = [...transcript.matchAll(/^Test Suite 'All tests' (passed|failed) at .*$/gm)];
  if (allTests.length !== 1 || allTests[0][1] !== "passed") {
    throw new Error("xctest_all_tests_summary_invalid");
  }
  const swiftTestingSummaries = [...transcript.matchAll(
    /^(?:✔|✘)\s+Test run with (\d+) tests? (passed|failed) after .*$/gmu,
  )];
  if (swiftTestingSummaries.length > 1 || swiftTestingSummaries.some((row) => (
    Number(row[1]) !== 0 || row[2] !== "passed"
  ))) {
    throw new Error("xctest_second_test_run_summary_forbidden");
  }

  const summaries = [...transcript.matchAll(
    /^\s*Executed\s+(\d+)\s+tests?,\s+with\s+(\d+)\s+failures?\s+\((\d+)\s+unexpected\)(?:,\s+(\d+)\s+tests?\s+skipped)?\s+in\s+[^\n]+$/gm,
  )];
  if (summaries.length !== 1) throw new Error("xctest_executed_summary_invalid");
  const executed = Number(summaries[0][1]);
  const failed = Number(summaries[0][2]);
  const unexpected = Number(summaries[0][3]);
  const summarySkipped = Number(summaries[0][4] || 0);
  if (![executed, failed, unexpected, summarySkipped].every(Number.isSafeInteger)) {
    throw new Error("xctest_counts_invalid");
  }
  if (executed <= 0 || failed !== 0 || unexpected !== 0) {
    throw new Error("xctest_outcome_not_clean");
  }

  const testCases = [...transcript.matchAll(
    /^Test Case '([^']+)' (passed|failed|skipped)(?: \([^\n]*\))?\.?$/gm,
  )];
  if (testCases.length !== executed) throw new Error("xctest_case_count_inconsistent");
  const skipped = testCases.filter((row) => row[2] === "skipped").length;
  const observedFailed = testCases.filter((row) => row[2] === "failed").length;
  if (skipped !== summarySkipped || skipped !== 0 || observedFailed !== failed) {
    throw new Error("xctest_case_outcome_inconsistent");
  }

  const optInResults = new Map(OPT_IN_TESTS.map((identity) => [identity, []]));
  for (const row of testCases) {
    const identity = normalizeTestIdentity(row[1]);
    if (identity) optInResults.get(identity).push(row[2]);
  }
  for (const identity of OPT_IN_TESTS) {
    const results = optInResults.get(identity);
    if (results.length !== 1 || results[0] !== "passed") {
      throw new Error("xctest_opt_in_identity_invalid");
    }
  }

  return {
    schema: SCHEMA,
    status: "pass",
    executed_tests: executed,
    failed_tests: failed,
    skipped_tests: skipped,
    opt_in_tests_executed: OPT_IN_TESTS.length,
  };
}

function classifyChildResult(child, forbiddenValues = []) {
  if (!child || typeof child !== "object") throw new Error("child_result_invalid");
  if (child.error) {
    if (child.error.code === "ETIMEDOUT") throw new Error("child_timeout");
    if (child.error.code === "ENOBUFS") throw new Error("child_output_oversized");
    throw new Error("child_spawn_failed");
  }
  if (child.status !== 0) throw new Error("child_exit_nonzero");
  const stdout = decodeOutput(child.stdout);
  const stderr = decodeOutput(child.stderr);
  const combined = `${stdout}\n${stderr}`;
  for (const value of forbiddenValues) {
    if (typeof value === "string" && value.length > 0 && combined.includes(value)) {
      throw new Error("private_locator_leak");
    }
  }
  const aggregate = parseXCTestSummary(combined);
  const exactKeys = [
    "schema", "status", "executed_tests", "failed_tests", "skipped_tests",
    "opt_in_tests_executed",
  ];
  if (JSON.stringify(Object.keys(aggregate)) !== JSON.stringify(exactKeys)) {
    throw new Error("aggregate_keys_invalid");
  }
  return aggregate;
}

function discoverPrivateBundles() {
  const teeth = TeethRunner.discoverBundle();
  TeethRunner.assertIgnoredBundle(teeth);
  const sclera = ScleraRunner.discoverBundle();
  ScleraRunner.assertIgnoredBundle(sclera);
  return Object.freeze({ teeth, sclera });
}

function positiveTranscript() {
  const rows = OPT_IN_TESTS.map((identity) => {
    const separator = identity.indexOf(".");
    const suite = identity.slice(0, separator);
    const method = identity.slice(separator + 1);
    return `Test Case '-[FixtureModule.${suite} ${method}]' passed (0.001 seconds).`;
  });
  const ordinaryRows = Array.from({ length: 636 }, (_, index) => (
    `Test Case '-[FixtureModule.OrdinaryTests testCase${index}]' passed (0.001 seconds).`
  ));
  return Buffer.from([
    "Test Suite 'Selected tests' started at 2026-08-10 00:00:00.000.",
    ...ordinaryRows,
    ...rows,
    "Test Suite 'BeautySDKPackageTests.xctest' passed at 2026-08-10 00:00:00.009.",
    "\t Executed 644 tests, with 0 failures (0 unexpected) in 0.009 (0.019) seconds",
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
  const firstIdentitySeparator = OPT_IN_TESTS[0].indexOf(".");
  const firstOptInSuite = OPT_IN_TESTS[0].slice(0, firstIdentitySeparator);
  const firstOptInMethod = OPT_IN_TESTS[0].slice(firstIdentitySeparator + 1);
  const firstOptInRow = `Test Case '-[FixtureModule.${firstOptInSuite} ${firstOptInMethod}]' passed (0.001 seconds).\n`;
  const failedFirstOptInRow = firstOptInRow.replace(" passed ", " failed ");

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
  reject(() => classifyChildResult(child(replace(firstOptInRow, "")), [firstLocator]));
  reject(() => classifyChildResult(child(replace(firstOptInRow, "$&$&")), [firstLocator]));
  reject(() => classifyChildResult(child(replace(firstOptInRow, failedFirstOptInRow)), [firstLocator]));
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
  const bundles = discoverPrivateBundles();
  const childEnvironment = {
    ...process.env,
    BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS: "1",
    PHASE60_REQUIRE_LOCAL_EVIDENCE: "1",
    PHASE63_REQUIRE_LOCAL_EVIDENCE: "1",
    PHASE59_TEETH_BUNDLE: bundles.teeth,
    PHASE62_SCLERA_BUNDLE: bundles.sclera,
  };
  const child = spawnSync("swift", ["test", "--package-path", "BeautySDK"], {
    cwd: ROOT,
    env: childEnvironment,
    encoding: "buffer",
    timeout: FULL_SUITE_TIMEOUT_MILLISECONDS,
    maxBuffer: MAX_OUTPUT_BYTES,
    windowsHide: true,
  });
  const relativeComponents = Object.values(bundles).flatMap((bundle) => {
    const relative = path.relative(ROOT, bundle).split(path.sep).join("/");
    return [bundle, relative, ...relative.split("/").filter((piece) => piece.length >= 4)];
  });
  return classifyChildResult(child, [...new Set(relativeComponents)]);
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
