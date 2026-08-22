"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const CONTRACT_PATH = path.join(__dirname, "75-EVIDENCE-CONTRACT.md");
const REQUIRED_CATEGORIES = [
  "genuine-positive",
  "genuine-negative",
  "ambiguity",
  "pose-occlusion",
  "identity-diversity",
  "protected-structure",
];
const METRIC_IDS = [
  "efficacy",
  "containment",
  "texture-high-frequency-retention",
  "geometry-protected-structures",
  "metadata-integrity",
  "no-op",
  "deterministic-repeatability",
];
const FAILURE_STATES = [
  "missing-bundle",
  "rights-failure",
  "incomplete-taxonomy",
  "malformed-manifest",
  "review-failure",
  "privacy-export-failure",
];
const FROZEN_METRICS = [
  { id: "efficacy", direction: "minimum", threshold: 0.1, tolerance: 0.02 },
  { id: "containment", direction: "maximum", threshold: 0, tolerance: 0 },
  { id: "texture-high-frequency-retention", direction: "minimum", threshold: 0.98, tolerance: 0.02 },
  { id: "geometry-protected-structures", direction: "maximum", threshold: 0.01, tolerance: 0.01 },
  { id: "metadata-integrity", direction: "exact", threshold: 1, tolerance: 0 },
  { id: "no-op", direction: "maximum", threshold: 0, tolerance: 0 },
  { id: "deterministic-repeatability", direction: "exact", threshold: 1, tolerance: 0 },
];

function records() {
  const source = fs.readFileSync(CONTRACT_PATH, "utf8");
  const match = source.match(
    /<!-- CANONICAL_EVIDENCE_RECORDS_BEGIN -->\n```json\n([\s\S]*?)\n```\n<!-- CANONICAL_EVIDENCE_RECORDS_END -->/,
  );
  assert.ok(match, "evidence contract must contain one canonical JSON record block");
  return JSON.parse(match[1]);
}

function contractErrors(value) {
  const errors = [];
  if (value.manifest_schema.required_categories.join(",") !== REQUIRED_CATEGORIES.join(",")) {
    errors.push("taxonomy");
  }
  if (value.manifest_schema.rights_status !== "approved_internal_evaluation") errors.push("rights");
  if (JSON.stringify(value.metrics) !== JSON.stringify(FROZEN_METRICS)) errors.push("metrics");
  if (value.review.mode !== "blinded-original-detail") errors.push("review");
  return errors;
}

test("evidence contract freezes exact bundle categories and rights provenance", () => {
  const value = records();
  assert.equal(value.version, 1);
  assert.equal(value.feature_id, "upper-eyelid-fullness-reduction");
  assert.deepEqual(value.manifest_schema.required_categories, REQUIRED_CATEGORIES);
  assert.deepEqual(value.manifest_schema.required_fixture_keys, [
    "feature_id", "fixture_id", "polarity", "rights_status", "rights_record_id",
    "owner_provenance_version", "content_hash", "asset_roles", "categories",
  ]);
  assert.equal(value.manifest_schema.rights_status, "approved_internal_evaluation");
  assert.equal(value.admission.generated_fixture_weight, 0);
  assert.equal(value.admission.requires_genuine_positive, true);
  assert.equal(value.admission.requires_genuine_negative, true);
});

test("each required category rejects an independent completeness mutation", () => {
  const value = records();
  for (const category of REQUIRED_CATEGORIES) {
    const mutated = structuredClone(value);
    mutated.manifest_schema.required_categories = mutated.manifest_schema.required_categories
      .filter((candidate) => candidate !== category);
    assert.ok(contractErrors(mutated).includes("taxonomy"), category);
  }
});

test("frozen metrics and review rules reject threshold or review mutations", () => {
  const value = records();
  assert.deepEqual(value.metrics, FROZEN_METRICS);
  for (const metric of value.metrics) {
    assert.deepEqual(Object.keys(metric).sort(), ["direction", "id", "threshold", "tolerance"]);
    const mutated = structuredClone(value);
    mutated.metrics.find((candidate) => candidate.id === metric.id).threshold += 0.001;
    assert.notDeepEqual(mutated, value, metric.id);
    assert.ok(contractErrors(mutated).includes("metrics"), "threshold mutation must invalidate the frozen rubric");
  }
  const reviewMutation = structuredClone(value);
  reviewMutation.review.mode = "unblinded";
  assert.ok(contractErrors(reviewMutation).includes("review"));
});

test("durable output and failure states are exact and privacy-safe", () => {
  const value = records();
  assert.deepEqual(value.durable_output.allowlist, [
    "contract_hash", "manifest_hash", "fixture_ids", "aggregate_metrics", "reason_counts", "decision",
  ]);
  assert.deepEqual(value.failure_states, FAILURE_STATES);
  assert.equal(value.review.reviewer_sees_private_locator, false);
  assert.equal(value.review.reviewer_sees_candidate_identity, false);
  assert.equal(value.review.freeform_text, false);
});
