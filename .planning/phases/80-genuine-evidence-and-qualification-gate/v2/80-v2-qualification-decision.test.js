#!/usr/bin/env node
"use strict";

const assert = require("node:assert/strict");
const childProcess = require("node:child_process");
const crypto = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const gate = require("./80-v2-qualification-decision.js");
const repoRoot = path.resolve(__dirname, "../../../..");
const modulePath = path.join(__dirname, "80-v2-qualification-decision.js");
const categories = ["genuine-positive", "genuine-negative", "ambiguity", "pose-occlusion", "identity-diversity", "protected-structure"];

function hash(bytes) { return crypto.createHash("sha256").update(bytes).digest("hex"); }
function tempRoot() { return fs.mkdtempSync(path.join(os.tmpdir(), "beauty-phase80-v2-")); }
function metric(fixture_id, category, overrides = {}) {
  return {
    fixture_id, category, efficacy: category === "genuine-positive" ? 0.08 : 0,
    containment: 0, texture_high_frequency_retention: 0.96,
    geometry_protected_structures: 0.02, boundary_correction_jump_srgb8: 5,
    feather_to_zero: 1, metadata_integrity: 1, no_op: 0,
    deterministic_repeatability: 1, alpha_exact: 1, extent_exact: 1,
    rejected_source_exact: 1, color_target_region_nonempty: true,
    color_protected_region_nonempty: true,
    color_target_max_abs_channel_delta_srgb8: 16,
    color_protected_max_abs_channel_delta_srgb8: 0, ...overrides,
  };
}
function completeInputs(root) {
  const bindings = gate.expectedBindings(repoRoot).values;
  const specs = [
    ["positive_v2", "positive", ["genuine-positive", "identity-diversity", "protected-structure"]],
    ["negative_v2", "negative", ["genuine-negative", "ambiguity", "pose-occlusion"]],
  ];
  const fixtures = specs.map(([fixtureId, polarity, fixtureCategories], fixtureIndex) => {
    const assets = ["original", "support-envelope", "candidate-output"].map((role, roleIndex) => {
      const bytes = Buffer.from(`v2-unit-${fixtureIndex}-${roleIndex}-${role}`);
      const relative = `assets/${fixtureId}-${role}.bin`;
      const target = path.join(root, relative);
      fs.mkdirSync(path.dirname(target), { recursive: true, mode: 0o700 });
      fs.writeFileSync(target, bytes, { mode: 0o600 });
      return { role, relative_locator: relative, sha256: hash(bytes), byte_length: bytes.length };
    });
    return {
      feature_id: "upper-eyelid-fullness-reduction", fixture_id: fixtureId,
      polarity, origin: "genuine-captured", rights_status: "approved_internal_evaluation",
      rights_record_present: true, owner_provenance_version: "authorized-unit-v2",
      content_hash: hash(Buffer.from(`fixture-${fixtureId}`)), categories: fixtureCategories, assets,
    };
  });
  const bundle = {
    schema_version: 2, admission_mode: "genuine-private",
    feature_id: "upper-eyelid-fullness-reduction", origin: "genuine-captured",
    owner_provenance_version: "authorized-unit-v2", fixtures,
    metric_matrix: fixtures.flatMap((fixture) => fixture.categories.map((category) => metric(fixture.fixture_id, category))),
    bindings,
  };
  const review = {
    schema_version: 2, feature_id: "upper-eyelid-fullness-reduction", complete: true,
    rubric_frozen_before_outcomes: true, blindness_attested: true,
    candidate_identity_hidden: true, locator_hidden: true, detail_scale_percent: 100,
    phase75_semantic_contract_hash: bindings.phase75_semantic_contract_hash,
    phase75_evidence_contract_hash: bindings.phase75_evidence_contract_hash,
    review_rubric_hash: bindings.review_rubric_hash,
    judgments: fixtures.flatMap((fixture) => fixture.categories.map((category) => ({
      fixture_id: fixture.fixture_id, category,
      target_fullness_reduced: fixture.polarity === "positive",
      prohibited_proxy_absent: true, protected_structures_preserved: true,
      original_detail_natural: true, boundary_artifact_absent: true,
      review_decision: "pass", reason_code: null,
    }))),
  };
  return { bundle, review };
}

test("frozen contract binds v2 source, tests, helper, rubric, and public absence", () => {
  const result = gate.expectedBindings(repoRoot);
  assert.equal(result.valid, true);
  assert.equal(result.values.evaluator_version, "phase80-qualification-evaluator-v2");
  assert.equal(gate.contractRecord().baseline_binding.baseline_id, gate.BASELINE_ID);
});

test("semantic, evidence, source, test, helper, rubric, and public drift fail closed", () => {
  for (const mutation of ["semantic", "evidence", "source", "tests", "helper", "rubric", "public"]) {
    assert.equal(gate.expectedBindings(repoRoot, mutation).valid, false, mutation);
  }
});

test("boundary equality 5 passes while 6 fails", () => {
  const fixture = [{ fixture_id: "v2", categories: ["genuine-positive"] }];
  assert.equal(gate.evaluateMetricMatrix([metric("v2", "genuine-positive")], fixture).passed, true);
  const failed = gate.evaluateMetricMatrix([metric("v2", "genuine-positive", { boundary_correction_jump_srgb8: 6 })], fixture);
  assert.equal(failed.passed, false);
  assert.ok(failed.reasons.includes("qualification.metric.maximum-bound"));
});

test("feather-to-zero is exact and missing v2 boundary fields are invalid", () => {
  const fixture = [{ fixture_id: "v2", categories: ["genuine-positive"] }];
  assert.equal(gate.evaluateMetricMatrix([metric("v2", "genuine-positive", { feather_to_zero: 0 })], fixture).passed, false);
  const missing = metric("v2", "genuine-positive");
  delete missing.boundary_correction_jump_srgb8;
  assert.ok(gate.evaluateMetricMatrix([missing], fixture).reasons.includes("qualification.metric.invalid"));
});

test("target color equality 16 passes while 17 fails", () => {
  const fixture = [{ fixture_id: "v2", categories: ["genuine-positive"] }];
  assert.equal(gate.evaluateMetricMatrix([metric("v2", "genuine-positive")], fixture).passed, true);
  assert.ok(gate.evaluateMetricMatrix([metric("v2", "genuine-positive", { color_target_max_abs_channel_delta_srgb8: 17 })], fixture).reasons.includes("qualification.color.target-bound"));
});

test("complete independent rows and boundary review can reach only the v2 promotion constant", () => {
  const root = tempRoot();
  try {
    const { bundle, review } = completeInputs(root);
    const result = gate.buildDecision({ bundle, review, assetRoot: root, repoRoot });
    assert.equal(result.inputComplete, true);
    assert.equal(result.report.status, "pass");
    assert.equal(result.report.decision, "promotion-ready-feathered-editor-v2");
    assert.equal(result.report.aggregate_metrics.boundary_correction_jump_max_srgb8, 5);
    assert.equal(gate.outputIsSafe(result.report), true);
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});

test("visible boundary artifact fails the frozen human rubric", () => {
  const root = tempRoot();
  try {
    const { bundle, review } = completeInputs(root);
    review.judgments[0].boundary_artifact_absent = false;
    review.judgments[0].review_decision = "fail";
    review.judgments[0].reason_code = "boundary-artifact";
    const result = gate.validateReview(review, bundle.fixtures);
    assert.equal(result.valid, true);
    assert.equal(result.passed, false);
    assert.ok(result.reasons.includes("review.threshold"));
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});

test("v1 evaluator and baseline bindings cannot be borrowed", () => {
  const root = tempRoot();
  try {
    const { bundle } = completeInputs(root);
    bundle.bindings.evaluator_version = "phase80-qualification-evaluator-v1";
    bundle.bindings.baseline_source_digest = "8b928769e5921975880d714d01db39ceb0853f3313dce2e51da6909826a390d2";
    const result = gate.validateBundle(bundle, { assetRoot: root, bindings: gate.expectedBindings(repoRoot).values });
    assert.equal(result.valid, false);
    assert.ok(result.reasons.includes("qualification.binding"));
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});

test("duplicate or category-borrowed rows fail before aggregate credit", () => {
  const fixtures = [{ fixture_id: "a", categories: ["genuine-positive"] }, { fixture_id: "b", categories: ["genuine-negative"] }];
  const rows = [metric("a", "genuine-positive"), metric("a", "genuine-positive")];
  const result = gate.evaluateMetricMatrix(rows, fixtures);
  assert.equal(result.valid, false);
  assert.ok(result.reasons.includes("qualification.metric.invalid"));
});

test("sanitized output rejects private keys and path-like fixture identifiers", () => {
  const base = gate.failureDecision(["evidence.missing-bundle"]);
  assert.equal(gate.outputIsSafe(base), true);
  assert.equal(gate.outputIsSafe({ ...base, private_locator: "secret" }), false);
  assert.equal(gate.outputIsSafe({ ...base, fixture_ids: ["folder/file"] }), false);
  assert.equal(gate.outputIsSafe({ ...base, aggregate_metrics: { ...base.aggregate_metrics, pixels: [1] } }), false);
});

test("missing private inputs are deterministic non-promotion and never written", () => {
  const env = { ...process.env };
  delete env.BEAUTY_PHASE80_V2_BUNDLE_MANIFEST;
  delete env.BEAUTY_PHASE80_V2_REVIEW_RECORD;
  const args = [modulePath, "--decision", "--repo-root", "."];
  const first = childProcess.spawnSync(process.execPath, args, { cwd: repoRoot, encoding: "utf8", env });
  const second = childProcess.spawnSync(process.execPath, args, { cwd: repoRoot, encoding: "utf8", env });
  assert.notEqual(first.status, 0);
  assert.equal(first.stdout, second.stdout);
  const report = JSON.parse(first.stdout);
  assert.equal(report.decision, "qualification-not-passed");
  assert.deepEqual(report.reason_counts, { "evidence.missing-bundle": 1, "review.missing": 1 });
});

test("CLI accepts fixed flags only and does not echo private arguments", () => {
  const child = childProcess.spawnSync(process.execPath, [modulePath, "--bundle", "/private/input"], { cwd: repoRoot, encoding: "utf8" });
  assert.notEqual(child.status, 0);
  assert.doesNotMatch(child.stdout + child.stderr, /\/private\/input/);
});

test("contract rubric hash includes the boundary-artifact field and reason", () => {
  const contract = gate.contractRecord();
  assert.equal(gate.reviewRubricHash(contract), contract.review_rubric_hash);
  assert.ok(contract.review_rubric.fixed_fields.includes("boundary_artifact_absent"));
  assert.ok(contract.review_rubric.reason_codes.includes("boundary-artifact"));
});

test("all six frozen categories remain required", () => {
  assert.deepEqual([...gate.contractRecord().bundle_schema.required_categories].sort(), [...categories].sort());
});

test("self-test is aggregate-only non-promotion", () => {
  const child = childProcess.spawnSync(process.execPath, [modulePath, "--self-test", "--repo-root", "."], { cwd: repoRoot, encoding: "utf8" });
  assert.equal(child.status, 0);
  const report = JSON.parse(child.stdout);
  assert.equal(report.status, "pass");
  assert.equal(report.decision, "qualification-not-passed");
  assert.equal(report.promotion_fixture_count, 0);
  assert.equal(gate.outputIsSafe(report), true);
});
