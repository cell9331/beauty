"use strict";

const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");

const ROOT = path.resolve(__dirname, "..", "..", "..");
const CORE_PATH = path.join(
  ROOT,
  ".planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-core.js",
);
const TEETH_ADAPTER_PATH = path.join(
  ROOT,
  ".planning/phases/59-teeth-evidence-and-admission-contract/59-authorized-teeth-evidence-export.js",
);
const ReviewCore = require(CORE_PATH);
const TeethAdapter = require(TEETH_ADAPTER_PATH);

const ASSET_FIELDS = ["original", "mask", "after"];
const OPAQUE_ID = /^[A-Za-z0-9_-]{1,64}$/;
const MANIFEST_KEYS = ["fixtures", "schema_version"];
const FIXTURE_KEYS = [
  "assets", "expected_target_present", "feature", "fixture_id", "polarity",
  "review", "rights_record_id", "rights_status",
];
const REVIEW_KEYS = [
  "decision", "mask_coverage", "naturalness", "protected_leakage",
  "reason_code", "structure_changed", "target_present",
];
const ASSET_KEYS = ["after", "mask", "original"];

function fail(code) {
  throw new Error(code);
}

function exactKeys(value, expected) {
  return value && typeof value === "object" && !Array.isArray(value)
    && JSON.stringify(Object.keys(value).sort()) === JSON.stringify(expected);
}

function safeRelativeKey(value) {
  return typeof value === "string"
    && value.length > 0
    && value.length <= 256
    && !path.posix.isAbsolute(value)
    && !value.includes("\\")
    && !value.includes("\0")
    && !value.includes(":")
    && value.split("/").every((component) => component && component !== "." && component !== "..");
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function opaqueRightsID(fixtureID) {
  const projection = crypto.createHash("sha256").update(fixtureID, "utf8").digest("hex").slice(0, 32);
  return `sr_${projection}`;
}

function parseArguments(argv) {
  const options = {};
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === "--verify-only") options.verifyOnly = true;
    else if (["--output", "--verify-ledger"].includes(value)) {
      if (!argv[index + 1]) fail(`${value.slice(2)}_missing`);
      options[value.slice(2).replace("-", "")] = argv[++index];
    } else {
      fail("unsupported_argument");
    }
  }
  return options;
}

function resolveBundle(options = {}) {
  const environmentBundle = process.env.PHASE62_SCLERA_BUNDLE;
  if (process.env.PHASE62_REQUIRE_LOCAL_EVIDENCE === "1" && !environmentBundle) {
    fail("local_evidence_environment_required");
  }
  const bundle = environmentBundle || options.bundle;
  let valid = false;
  try {
    valid = Boolean(bundle && path.isAbsolute(bundle)
      && fs.statSync(bundle, { throwIfNoEntry: false })?.isDirectory());
  } catch (_) {
    valid = false;
  }
  if (!valid) fail("local_evidence_bundle_invalid");
  return bundle;
}

function validateReview(review, expectedTarget) {
  if (!exactKeys(review, REVIEW_KEYS)) fail("local_review_shape_invalid");
  if (review.target_present !== expectedTarget
    || !Number.isInteger(review.mask_coverage) || review.mask_coverage < 1 || review.mask_coverage > 5
    || typeof review.protected_leakage !== "boolean"
    || !Number.isInteger(review.naturalness) || review.naturalness < 1 || review.naturalness > 5
    || typeof review.structure_changed !== "boolean"
    || !["accept", "reject"].includes(review.decision)
    || typeof review.reason_code !== "string") {
    fail("local_review_value_invalid");
  }
  if (review.decision === "accept"
    && (review.reason_code !== "none" || review.protected_leakage || review.structure_changed)) {
    fail("local_review_acceptance_invalid");
  }
}

function expectedLocalAssets(fixtureDirectory, originalExtension) {
  return {
    original: `${fixtureDirectory}/original${originalExtension}`,
    mask: `${fixtureDirectory}/mask.png`,
    after: `${fixtureDirectory}/after.png`,
  };
}

function loadCanonicalInput(bundle) {
  let source;
  try {
    source = JSON.parse(fs.readFileSync(path.join(bundle, "manifest.json"), "utf8"));
  } catch (_) {
    fail("local_manifest_invalid");
  }
  if (!exactKeys(source, MANIFEST_KEYS) || source.schema_version !== 1
    || !Array.isArray(source.fixtures) || source.fixtures.length !== 2) {
    fail("local_manifest_shape_invalid");
  }

  const fixtureIDs = new Set();
  const polarities = new Set();
  const rows = source.fixtures.map((fixture) => {
    if (!exactKeys(fixture, FIXTURE_KEYS) || !OPAQUE_ID.test(fixture.fixture_id)
      || fixtureIDs.has(fixture.fixture_id) || fixture.feature !== "sclera_redness"
      || !["positive", "negative"].includes(fixture.polarity)
      || polarities.has(fixture.polarity)
      || fixture.rights_status !== "approved_internal_evaluation"
      || !OPAQUE_ID.test(fixture.rights_record_id)
      || !exactKeys(fixture.assets, ASSET_KEYS)) {
      fail("local_manifest_fixture_invalid");
    }
    fixtureIDs.add(fixture.fixture_id);
    polarities.add(fixture.polarity);
    const expectedTarget = fixture.polarity === "positive";
    if (fixture.expected_target_present !== expectedTarget) fail("local_target_predeclaration_invalid");
    validateReview(fixture.review, expectedTarget);

    const original = fixture.assets.original;
    const extension = typeof original === "string" ? path.posix.extname(original).toLowerCase() : "";
    if (![".png", ".jpg", ".jpeg"].includes(extension)) fail("local_original_extension_invalid");
    const directory = expectedTarget ? "fixture_001" : "fixture_002";
    const expected = expectedLocalAssets(directory, extension);
    if (ASSET_FIELDS.some((field) => fixture.assets[field] !== expected[field])) {
      fail("local_asset_binding_invalid");
    }

    const logical = {
      original: `sclera/${fixture.fixture_id}-original${extension}`,
      mask: `sclera/${fixture.fixture_id}-mask.png`,
      after: `sclera/${fixture.fixture_id}-after.png`,
    };
    if (new Set(Object.values(logical).map((key) => path.posix.basename(key))).size !== 3) {
      fail("logical_asset_basename_ambiguous");
    }
    const actual = {};
    for (const field of ASSET_FIELDS) {
      if (!safeRelativeKey(fixture.assets[field])) fail("local_asset_key_invalid");
      const filePath = path.join(bundle, fixture.assets[field]);
      let stat;
      try { stat = fs.lstatSync(filePath); } catch (_) { stat = null; }
      if (!stat?.isFile() || stat.size < 1) fail("local_asset_missing");
      actual[field] = filePath;
    }
    return {
      fixture_id: fixture.fixture_id,
      feature: "sclera_redness",
      polarity: fixture.polarity,
      expected_target_present: expectedTarget,
      polarity_predeclared: true,
      rights_status: "approved_internal_evaluation",
      rights_record_id: opaqueRightsID(fixture.fixture_id),
      evidence_role: "genuine_candidate",
      assets: logical,
      actual,
      review: fixture.review,
    };
  });
  if (!polarities.has("positive") || !polarities.has("negative")) fail("local_polarity_pair_missing");

  const manifest = {
    schema_version: 1,
    feature: "sclera_redness",
    fixtures: rows.map(({ actual, review, ...row }) => row),
  };
  const availableAssetKeys = rows.flatMap((row) => ASSET_FIELDS.map((field) => ({
    key: row.assets[field],
    sha256: sha256(row.actual[field]),
  })));
  if (new Set(availableAssetKeys.map((asset) => path.posix.basename(asset.key))).size !== 6) {
    fail("logical_asset_basename_ambiguous");
  }
  const registry = ReviewCore.createTrustedAuthorizationRegistry({
    schema_version: 1,
    grants: rows.map((row) => ({
      rights_record_id: row.rights_record_id,
      fixture_id: row.fixture_id,
      feature: row.feature,
      polarity: row.polarity,
      expected_target_present: row.expected_target_present,
      permitted_use: "internal_product_evaluation",
      evidence_classification: "genuine_candidate",
      assets: Object.fromEntries(ASSET_FIELDS.map((field) => [field, {
        key: row.assets[field],
        sha256: availableAssetKeys.find((asset) => asset.key === row.assets[field]).sha256,
      }])),
    })),
  });
  return { manifest, availableAssetKeys, registry, localReviews: rows.map((row) => ({
    fixture_id: row.fixture_id,
    ...row.review,
  })) };
}

function issuedFeatureInput(input) {
  const snapshot = ReviewCore.createReviewSnapshot(input.manifest, input.availableAssetKeys, input.registry);
  if (snapshot.ready !== true || snapshot.selected_rows.length !== 2) fail("review_snapshot_not_ready");
  const reviews = snapshot.selected_rows.map((row) => {
    const local = input.localReviews.find((review) => review.fixture_id === row.fixture_id);
    if (!local) fail("local_review_missing");
    const issued = ReviewCore.createReview(snapshot, local);
    if (!ReviewCore.validateReview(snapshot, issued).valid || !ReviewCore.rowPasses(row, issued)) {
      fail("review_core_rejected_review");
    }
    return issued;
  });
  const decision = ReviewCore.evaluateFeature(snapshot, reviews);
  if (decision.status !== "open" || decision.eligible_count !== 2
    || decision.reviewed_count !== 2 || decision.accepted_count !== 2
    || decision.rejected_count !== 0 || decision.naturalness_weight !== 2) {
    fail("review_core_open_decision_invalid");
  }
  return { snapshot, reviews };
}

function teethFeatureInput(bundle) {
  const input = TeethAdapter.loadCanonicalInput(bundle);
  const snapshot = ReviewCore.createReviewSnapshot(input.manifest, input.availableAssetKeys, input.registry);
  if (snapshot.ready !== true || snapshot.selected_rows.length !== 2) fail("teeth_snapshot_not_ready");
  const reviews = snapshot.selected_rows.map((row) => {
    const issued = ReviewCore.createReview(snapshot, TeethAdapter.reviewFor(row));
    if (!ReviewCore.validateReview(snapshot, issued).valid || !ReviewCore.rowPasses(row, issued)) {
      fail("teeth_review_rejected");
    }
    return issued;
  });
  if (ReviewCore.evaluateFeature(snapshot, reviews).status !== "open") fail("teeth_decision_not_open");
  return { snapshot, reviews };
}

function buildExport(bundle, teethBundle = process.env.PHASE59_TEETH_BUNDLE) {
  if (!teethBundle || !path.isAbsolute(teethBundle)) fail("teeth_bundle_environment_required");
  const teeth = teethFeatureInput(teethBundle);
  const sclera = issuedFeatureInput(loadCanonicalInput(bundle));
  const eyelid = { snapshot: ReviewCore.createClosedSnapshot("upper_eyelid_fullness"), reviews: [] };
  return ReviewCore.serializeDurableExport([teeth, sclera, eyelid]);
}

function main() {
  try {
    const options = parseArguments(process.argv.slice(2));
    const bundle = resolveBundle(options);
    const durable = buildExport(bundle);
    if (options.verifyledger) {
      if (fs.readFileSync(options.verifyledger, "utf8") !== durable) fail("ledger_bytes_mismatch");
    }
    if (options.output && !options.verifyOnly) fs.writeFileSync(options.output, durable, "utf8");
    process.stdout.write("PHASE62_LOCAL_REVIEW_PASS\n");
  } catch (error) {
    process.stderr.write(`${error instanceof Error ? error.message : "local_review_failed"}\n`);
    process.exitCode = 1;
  }
}

if (require.main === module) main();

module.exports = {
  buildExport,
  exactKeys,
  loadCanonicalInput,
  safeRelativeKey,
  validateReview,
};
