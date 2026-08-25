#!/usr/bin/env node
"use strict";

const assert = require("node:assert/strict");
const childProcess = require("node:child_process");
const crypto = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const gate = require("./80-v4-qualification-decision.js");
const repoRoot = path.resolve(__dirname, "../../../..");
const modulePath = path.join(__dirname, "80-v4-qualification-decision.js");
const categories = ["genuine-positive", "genuine-negative", "ambiguity", "pose-occlusion", "identity-diversity", "protected-structure"];
function hash(bytes) { return crypto.createHash("sha256").update(bytes).digest("hex"); }
function tempRoot() { return fs.mkdtempSync(path.join(os.tmpdir(), "beauty-phase80-v4-")); }
function metric(fixture_id, category, applicable, overrides = {}) {
  return {
    fixture_id,
    category,
    target_metrics_applicable: applicable,
    efficacy: applicable ? 0.5 : 0,
    source_central_convexity_srgb8: applicable ? 10 : 0,
    output_central_convexity_srgb8: applicable ? 5 : 0,
    convexity_reduction_ratio: applicable ? 0.5 : 0,
    correction_spatial_range_srgb8: applicable ? 10 : 0,
    target_mean_abs_channel_delta_srgb8: applicable ? 4 : 0,
    containment: 0,
    texture_high_frequency_retention: applicable ? 0.99 : 1,
    geometry_protected_structures: 0,
    boundary_correction_jump_srgb8: applicable ? 2 : 0,
    feather_to_zero: applicable ? 1 : 0,
    metadata_integrity: 1,
    no_op: 0,
    deterministic_repeatability: 1,
    alpha_exact: 1,
    extent_exact: 1,
    rejected_source_exact: 1,
    color_target_region_nonempty: applicable,
    color_protected_region_nonempty: true,
    color_target_max_abs_channel_delta_srgb8: applicable ? 16 : 0,
    color_protected_max_abs_channel_delta_srgb8: 0,
    ...overrides,
  };
}
function completeInputs(root) {
  const bindings = gate.expectedBindings(repoRoot).values;
  const specifications = [
    ["positive_v4", "positive", ["genuine-positive", "identity-diversity", "protected-structure"]],
    ["negative_v4", "negative", ["genuine-negative", "ambiguity", "pose-occlusion"]],
  ];
  const fixtures = specifications.map(([fixtureId, polarity, fixtureCategories], fixtureIndex) => {
    const assets = ["original", "support-envelope", "candidate-output"].map((role, roleIndex) => {
      const bytes = Buffer.from(`v4-unit-${fixtureIndex}-${roleIndex}-${role}`);
      const relative = `assets/${fixtureId}-${role}.bin`;
      const target = path.join(root, relative);
      fs.mkdirSync(path.dirname(target), { recursive: true, mode: 0o700 });
      fs.writeFileSync(target, bytes, { mode: 0o600 });
      return { role, relative_locator: relative, sha256: hash(bytes), byte_length: bytes.length };
    });
    return {
      feature_id: "upper-eyelid-fullness-reduction",
      fixture_id: fixtureId,
      polarity,
      origin: "genuine-captured",
      rights_status: "approved_internal_evaluation",
      rights_record_present: true,
      owner_provenance_version: "authorized-unit-v4",
      content_hash: hash(Buffer.from(`fixture-${fixtureId}`)),
      categories: fixtureCategories,
      assets,
    };
  });
  const bundle = {
    schema_version: 4,
    admission_mode: "genuine-private",
    feature_id: "upper-eyelid-fullness-reduction",
    origin: "genuine-captured",
    owner_provenance_version: "authorized-unit-v4",
    fixtures,
    metric_matrix: fixtures.flatMap((fixture) => fixture.categories.map((category) => metric(fixture.fixture_id, category, fixture.polarity === "positive"))),
    bindings,
  };
  const review = {
    schema_version: 4,
    feature_id: "upper-eyelid-fullness-reduction",
    complete: true,
    rubric_frozen_before_outcomes: true,
    blindness_attested: true,
    candidate_identity_hidden: true,
    locator_hidden: true,
    detail_scale_percent: 100,
    phase75_semantic_contract_hash: bindings.phase75_semantic_contract_hash,
    phase75_evidence_contract_hash: bindings.phase75_evidence_contract_hash,
    review_rubric_hash: bindings.review_rubric_hash,
    judgments: fixtures.flatMap((fixture) => fixture.categories.map((category) => ({
      fixture_id: fixture.fixture_id,
      category,
      target_fullness_reduced: fixture.polarity === "positive",
      relief_shape_flatter: fixture.polarity === "positive",
      uniform_tone_shift_only_absent: true,
      prohibited_proxy_absent: true,
      protected_structures_preserved: true,
      original_detail_natural: true,
      boundary_artifact_absent: true,
      review_decision: "pass",
      reason_code: null,
    }))),
  };
  return { bundle, review };
}

test("frozen v4 binding owns relief source, evidence, v3 history, rubric, and absence", () => {
  const result = gate.expectedBindings(repoRoot);
  const baseline = gate.contractRecord().baseline_binding;
  assert.equal(result.valid, true);
  assert.equal(result.values.evaluator_version, gate.VERSION);
  assert.equal(baseline.minimum_source_convexity_srgb8, 3.5);
  assert.equal(baseline.relief_compression_gain, 1.5);
  assert.equal(baseline.focused_test_count, 30);
});

test("all nine authority mutations fail closed", () => {
  for (const mutation of ["semantic", "evidence", "source", "tests", "helper-v3", "contract-v3", "test-v3", "rubric", "public"]) {
    assert.equal(gate.expectedBindings(repoRoot, mutation).valid, false, mutation);
  }
});

test("positive relief row passes exact frozen boundaries", () => {
  const fixtures = [{ fixture_id: "p", polarity: "positive", categories: ["genuine-positive"] }];
  const result = gate.evaluateMetricMatrix([metric("p", "genuine-positive", true, {
    source_central_convexity_srgb8: 10,
    output_central_convexity_srgb8: 6.5,
    convexity_reduction_ratio: 0.35,
    efficacy: 0.35,
    correction_spatial_range_srgb8: 6,
    target_mean_abs_channel_delta_srgb8: 3,
    boundary_correction_jump_srgb8: 5,
  })], fixtures);
  assert.equal(result.passed, true);
});

test("uniform correction range and weak mean change fail v4", () => {
  const fixtures = [{ fixture_id: "p", polarity: "positive", categories: ["genuine-positive"] }];
  const result = gate.evaluateMetricMatrix([metric("p", "genuine-positive", true, {
    correction_spatial_range_srgb8: 5.99,
    target_mean_abs_channel_delta_srgb8: 2.99,
  })], fixtures);
  assert.equal(result.passed, false);
  assert.ok(result.reasons.includes("qualification.relief.uniform"));
});

test("weak or inconsistent convexity reduction fails v4", () => {
  const fixtures = [{ fixture_id: "p", polarity: "positive", categories: ["genuine-positive"] }];
  for (const overrides of [
    { output_central_convexity_srgb8: 6.51, convexity_reduction_ratio: 0.349, efficacy: 0.349 },
    { output_central_convexity_srgb8: 5, convexity_reduction_ratio: 0.7, efficacy: 0.7 },
    { output_central_convexity_srgb8: -0.1, convexity_reduction_ratio: 1, efficacy: 1 },
  ]) {
    const result = gate.evaluateMetricMatrix([metric("p", "genuine-positive", true, overrides)], fixtures);
    assert.equal(result.passed, false);
    assert.ok(result.reasons.includes("qualification.relief.minimum"));
  }
});

test("positive source must carry the frozen convexity cue", () => {
  const fixtures = [{ fixture_id: "p", polarity: "positive", categories: ["genuine-positive"] }];
  const result = gate.evaluateMetricMatrix([metric("p", "genuine-positive", true, {
    source_central_convexity_srgb8: 3.49,
    output_central_convexity_srgb8: 1.745,
  })], fixtures);
  assert.equal(result.passed, false);
  assert.ok(result.reasons.includes("qualification.relief.minimum"));
});

test("negative no-request row passes only with exact relief inapplicability", () => {
  const fixtures = [{ fixture_id: "n", polarity: "negative", categories: ["genuine-negative"] }];
  const result = gate.evaluateMetricMatrix([metric("n", "genuine-negative", false)], fixtures);
  assert.equal(result.passed, true);
  assert.equal(result.aggregate_metrics.inapplicable_target_row_count, 1);
  assert.equal(result.aggregate_metrics.applicable_target_row_count, 0);
});

test("negative rows cannot fabricate relief or target credit", () => {
  const fixtures = [{ fixture_id: "n", polarity: "negative", categories: ["genuine-negative"] }];
  for (const mutation of [
    { target_metrics_applicable: true, color_target_region_nonempty: true, feather_to_zero: 1 },
    { source_central_convexity_srgb8: 4 },
    { convexity_reduction_ratio: 0.5, efficacy: 0.5 },
    { correction_spatial_range_srgb8: 8 },
    { target_mean_abs_channel_delta_srgb8: 4 },
  ]) {
    const result = gate.evaluateMetricMatrix([metric("n", "genuine-negative", false, mutation)], fixtures);
    assert.equal(result.passed, false);
    assert.ok(result.reasons.includes("qualification.applicability"));
  }
});

test("positive rows cannot hide target relief as inapplicable", () => {
  const fixtures = [{ fixture_id: "p", polarity: "positive", categories: ["genuine-positive"] }];
  const result = gate.evaluateMetricMatrix([metric("p", "genuine-positive", false)], fixtures);
  assert.equal(result.passed, false);
  assert.ok(result.reasons.includes("qualification.applicability"));
});

test("common protection and texture bounds are exact", () => {
  const fixtures = [{ fixture_id: "p", polarity: "positive", categories: ["genuine-positive"] }];
  for (const overrides of [
    { containment: 0.001 },
    { texture_high_frequency_retention: 0.979 },
    { geometry_protected_structures: 0.001 },
    { color_protected_max_abs_channel_delta_srgb8: 1 },
  ]) {
    const result = gate.evaluateMetricMatrix([metric("p", "genuine-positive", true, overrides)], fixtures);
    assert.equal(result.passed, false);
    assert.ok(result.reasons.includes("qualification.metric.common-bound"));
  }
});

test("complete independent genuine schema can reach only v4 promotion", () => {
  const root = tempRoot();
  try {
    const { bundle, review } = completeInputs(root);
    const result = gate.buildDecision({ bundle, review, assetRoot: root, repoRoot });
    assert.equal(result.inputComplete, true);
    assert.equal(result.report.status, "pass");
    assert.equal(result.report.decision, "promotion-ready-relief-flattening-editor-v4");
    assert.equal(result.report.aggregate_metrics.applicable_target_row_count, 3);
    assert.equal(result.report.aggregate_metrics.inapplicable_target_row_count, 3);
    assert.equal(result.report.aggregate_metrics.convexity_reduction_ratio_min, 0.5);
    assert.equal(gate.outputIsSafe(result.report), true);
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});

test("v1 v2 and v3 bindings cannot be borrowed", () => {
  const root = tempRoot();
  try {
    for (const version of ["phase80-qualification-evaluator-v1", "phase80-qualification-evaluator-v2", "phase80-qualification-evaluator-v3"]) {
      const { bundle } = completeInputs(root);
      bundle.bindings.evaluator_version = version;
      const result = gate.validateBundle(bundle, { assetRoot: root, bindings: gate.expectedBindings(repoRoot).values });
      assert.equal(result.valid, false);
      assert.ok(result.reasons.includes("qualification.binding"));
    }
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});

test("v3 metric rows cannot masquerade as v4", () => {
  const fixtures = [{ fixture_id: "p", polarity: "positive", categories: ["genuine-positive"] }];
  const row = metric("p", "genuine-positive", true);
  delete row.convexity_reduction_ratio;
  const result = gate.evaluateMetricMatrix([row], fixtures);
  assert.equal(result.valid, false);
  assert.ok(result.reasons.includes("qualification.metric.invalid"));
});

test("review rejects visible target without flatter relief", () => {
  const root = tempRoot();
  try {
    const { bundle, review } = completeInputs(root);
    review.judgments[0].relief_shape_flatter = false;
    review.judgments[0].review_decision = "fail";
    review.judgments[0].reason_code = "relief-shape-not-flatter";
    const result = gate.validateReview(review, bundle.fixtures);
    assert.equal(result.valid, true);
    assert.equal(result.passed, false);
    assert.ok(result.reasons.includes("review.threshold"));
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});

test("review independently rejects uniform tone-shift-only output", () => {
  const root = tempRoot();
  try {
    const { bundle, review } = completeInputs(root);
    review.judgments[0].uniform_tone_shift_only_absent = false;
    review.judgments[0].review_decision = "fail";
    review.judgments[0].reason_code = "uniform-tone-shift-only";
    const result = gate.validateReview(review, bundle.fixtures);
    assert.equal(result.valid, true);
    assert.equal(result.passed, false);
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});

test("output allowlist rejects private keys rows and path-like ids", () => {
  const base = gate.failureDecision(["evidence.missing-bundle"]);
  assert.equal(gate.outputIsSafe(base), true);
  assert.equal(gate.outputIsSafe({ ...base, private_locator: "secret" }), false);
  assert.equal(gate.outputIsSafe({ ...base, fixture_ids: ["folder/file"] }), false);
  assert.equal(gate.outputIsSafe({ ...base, aggregate_metrics: { ...base.aggregate_metrics, pixels: [1] } }), false);
});

test("missing private inputs are deterministic sanitized non-promotion", () => {
  const env = { ...process.env };
  delete env.BEAUTY_PHASE80_V4_BUNDLE_MANIFEST;
  delete env.BEAUTY_PHASE80_V4_REVIEW_RECORD;
  const args = [modulePath, "--decision", "--repo-root", "."];
  const first = childProcess.spawnSync(process.execPath, args, { cwd: repoRoot, encoding: "utf8", env });
  const second = childProcess.spawnSync(process.execPath, args, { cwd: repoRoot, encoding: "utf8", env });
  assert.notEqual(first.status, 0);
  assert.equal(first.stdout, second.stdout);
  const report = JSON.parse(first.stdout);
  assert.equal(report.decision, "qualification-not-passed");
  assert.deepEqual(report.reason_counts, { "evidence.missing-bundle": 1, "review.missing": 1 });
});

test("CLI never accepts or echoes a private locator argument", () => {
  const child = childProcess.spawnSync(process.execPath, [modulePath, "--bundle", "/private/input"], { cwd: repoRoot, encoding: "utf8" });
  assert.notEqual(child.status, 0);
  assert.doesNotMatch(child.stdout + child.stderr, /\/private\/input/);
});

test("rubric hash binds flatter relief uniform-tone rejection and 100-percent detail", () => {
  const contract = gate.contractRecord();
  assert.equal(gate.reviewRubricHash(), contract.review_rubric_hash);
  assert.ok(contract.review_rubric.fixed_fields.includes("relief_shape_flatter"));
  assert.ok(contract.review_rubric.fixed_fields.includes("uniform_tone_shift_only_absent"));
  assert.equal(contract.review_schema.detail_scale_percent, 100);
});

test("self-test is aggregate-only and non-promotable", () => {
  const child = childProcess.spawnSync(process.execPath, [modulePath, "--self-test", "--repo-root", "."], { cwd: repoRoot, encoding: "utf8" });
  assert.equal(child.status, 0);
  const report = JSON.parse(child.stdout);
  assert.equal(report.status, "pass");
  assert.equal(report.decision, "qualification-not-passed");
  assert.equal(report.promotion_fixture_count, 0);
  assert.equal(gate.outputIsSafe(report), true);
});
