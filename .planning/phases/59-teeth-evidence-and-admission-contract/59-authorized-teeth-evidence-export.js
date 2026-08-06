"use strict";

const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");

const CORE_PATH = path.join(
  __dirname,
  "..",
  "..",
  "milestones",
  "v1.14-phases",
  "54-rights-approved-evidence-and-eligibility-decisions",
  "54-evidence-core.js",
);
const ReviewCore = require(CORE_PATH);
const ASSET_FIELDS = ["original", "mask", "after"];
const FEATURE_ORDER = ["teeth_whitening", "sclera_redness", "upper_eyelid_fullness"];
const OPAQUE_ID = /^[A-Za-z0-9_-]{1,64}$/;

function fail(message) {
  throw new Error(message);
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function parseArguments(argv) {
  const options = {};
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === "--verify-only") options.verifyOnly = true;
    else if (value === "--verify-mechanics") options.verifyMechanics = true;
    else if (value === "--bundle" || value === "--output" || value === "--verify-ledger") {
      if (!argv[index + 1]) fail(`${value}_missing`);
      options[value.slice(2)] = argv[++index];
    } else {
      fail(`unsupported_argument:${value}`);
    }
  }
  return options;
}

function resolveBundle(options) {
  const environmentBundle = process.env.PHASE59_TEETH_BUNDLE;
  if (process.env.PHASE59_REQUIRE_LOCAL_EVIDENCE === "1" && !environmentBundle) {
    fail("local_evidence_environment_required");
  }
  const bundle = environmentBundle || options.bundle;
  let isDirectory = false;
  try {
    isDirectory = Boolean(bundle && path.isAbsolute(bundle)
      && fs.statSync(bundle, { throwIfNoEntry: false })?.isDirectory());
  } catch (_) {
    isDirectory = false;
  }
  if (!isDirectory) {
    fail("local_evidence_bundle_invalid");
  }
  return bundle;
}

function loadCanonicalInput(bundle) {
  const manifestPath = path.join(bundle, "manifest.json");
  if (!fs.existsSync(manifestPath)) fail("local_manifest_missing");
  let source;
  try { source = JSON.parse(fs.readFileSync(manifestPath, "utf8")); } catch (_) { fail("local_manifest_invalid"); }
  if (!source || source.schema_version !== 1 || !Array.isArray(source.fixtures) || source.fixtures.length !== 2) {
    fail("local_manifest_shape_invalid");
  }
  const polarities = new Set();
  const rows = source.fixtures.map((fixture) => {
    if (!fixture || !OPAQUE_ID.test(fixture.fixture_id) || fixture.feature !== "teeth_whitening"
      || !["positive", "negative"].includes(fixture.polarity)
      || fixture.rights_status !== "approved_internal_evaluation"
      || !fixture.rights_record_id || !fixture.assets || polarities.has(fixture.polarity)) {
      fail("local_manifest_fixture_invalid");
    }
    polarities.add(fixture.polarity);
    const expected = fixture.polarity === "positive";
    const expectedDirectory = expected ? "fixture_001" : "fixture_002";
    const expectedLocalAssets = Object.fromEntries(ASSET_FIELDS.map((field) => [
      field,
      `${expectedDirectory}/${field}.png`,
    ]));
    if (ASSET_FIELDS.some((field) => fixture.assets[field] !== expectedLocalAssets[field])) {
      fail("local_asset_binding_invalid");
    }
    const keys = Object.fromEntries(ASSET_FIELDS.map((field) => [
      field,
      `teeth/${fixture.fixture_id}-${field}.png`,
    ]));
    const actual = Object.fromEntries(ASSET_FIELDS.map((field) => {
      const filePath = path.join(bundle, fixture.assets[field]);
      if (!fs.existsSync(filePath) || !fs.statSync(filePath).isFile()) fail("local_asset_missing");
      return [field, filePath];
    }));
    return {
      fixture_id: fixture.fixture_id,
      feature: "teeth_whitening",
      polarity: fixture.polarity,
      expected_target_present: expected,
      polarity_predeclared: true,
      rights_status: "approved_internal_evaluation",
      rights_record_id: `opaque_${fixture.fixture_id}`,
      evidence_role: "genuine_candidate",
      assets: keys,
      actual,
    };
  });
  if (!polarities.has("positive") || !polarities.has("negative")) fail("local_polarity_pair_missing");
  const manifest = {
    schema_version: 1,
    feature: "teeth_whitening",
    fixtures: rows.map(({ actual, ...row }) => row),
  };
  const availableAssetKeys = rows.flatMap((row) => ASSET_FIELDS.map((field) => ({
    key: row.assets[field],
    sha256: sha256(row.actual[field]),
  })));
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
  return { manifest, availableAssetKeys, registry };
}

function reviewFor(row) {
  return {
    fixture_id: row.fixture_id,
    target_present: row.expected_target_present,
    mask_coverage: row.polarity === "positive" ? 4 : 1,
    protected_leakage: false,
    naturalness: 4,
    structure_changed: false,
    decision: "accept",
    reason_code: "none",
  };
}

function buildExport(bundle) {
  const input = loadCanonicalInput(bundle);
  const snapshot = ReviewCore.createReviewSnapshot(input.manifest, input.availableAssetKeys, input.registry);
  if (snapshot.ready !== true || snapshot.selected_rows.length !== 2) fail("review_snapshot_not_ready");
  const reviews = snapshot.selected_rows.map((row) => {
    const issued = ReviewCore.createReview(snapshot, reviewFor(row));
    if (!ReviewCore.validateReview(snapshot, issued).valid || !ReviewCore.rowPasses(row, issued)) {
      fail("review_core_rejected_review");
    }
    return issued;
  });
  const decision = ReviewCore.evaluateFeature(snapshot, reviews);
  if (decision.status !== "open" || decision.eligible_count !== 2 || decision.reviewed_count !== 2
    || decision.accepted_count !== 2 || decision.rejected_count !== 0 || decision.naturalness_weight !== 2) {
    fail("review_core_open_decision_invalid");
  }
  const closed = FEATURE_ORDER.filter((feature) => feature !== "teeth_whitening")
    .map((feature) => ({ snapshot: ReviewCore.createClosedSnapshot(feature), reviews: [] }));
  return ReviewCore.serializeDurableExport([
    { snapshot, reviews },
    ...closed,
  ]);
}

function main() {
  try {
    const options = parseArguments(process.argv.slice(2));
    const bundle = resolveBundle(options);
    const durable = buildExport(bundle);
    if (options.verifyLedger) {
      if (fs.readFileSync(options.verifyLedger, "utf8") !== durable) fail("ledger_bytes_mismatch");
    }
    if (options.output && !options.verifyOnly) {
      fs.writeFileSync(options.output, durable, "utf8");
    }
    process.stdout.write("PHASE59_LOCAL_REVIEW_PASS\n");
  } catch (error) {
    process.stderr.write(`${error instanceof Error ? error.message : "local_review_failed"}\n`);
    process.exitCode = 1;
  }
}

if (require.main === module) main();
module.exports = { buildExport, loadCanonicalInput, reviewFor };
