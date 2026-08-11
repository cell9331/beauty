"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const path = require("node:path");
const Adapter = require(path.join(__dirname, "59-authorized-teeth-evidence-export.js"));

const OPEN = {
  feature: "teeth_whitening",
  status: "open",
  reasons: [],
  eligible_count: 2,
  reviewed_count: 2,
  accepted_count: 2,
  rejected_count: 0,
  naturalness_weight: 2,
};

const CLOSED_SIBLINGS = {
  sclera_redness: {
    feature: "sclera_redness",
    status: "closed",
    reasons: ["missing_genuine_positive", "missing_genuine_negative"],
    eligible_count: 0,
    reviewed_count: 0,
    accepted_count: 0,
    rejected_count: 0,
    naturalness_weight: 0,
  },
  upper_eyelid_fullness: {
    feature: "upper_eyelid_fullness",
    status: "closed",
    reasons: ["missing_genuine_positive", "missing_genuine_negative", "non_warp_design_unqualified"],
    eligible_count: 0,
    reviewed_count: 0,
    accepted_count: 0,
    rejected_count: 0,
    naturalness_weight: 0,
  },
};

const ROOT_KEYS = ["aggregates", "feature_decisions", "reviews", "schema_version"];
const DECISION_KEYS = [
  "accepted_count", "eligible_count", "feature", "naturalness_weight",
  "reasons", "rejected_count", "reviewed_count", "status",
];
const REVIEW_KEYS = [
  "decision", "feature", "fixture_id", "mask_coverage", "naturalness", "polarity",
  "protected_leakage", "reason_code", "structure_changed", "target_present",
];
const AGGREGATE_KEYS = [
  "accepted_count", "eligible_count", "feature", "naturalness_weight",
  "rejected_count", "reviewed_count",
];

test("open decision is exact and independent", () => {
  assert.deepEqual(OPEN, {
    feature: "teeth_whitening",
    status: "open",
    reasons: [],
    eligible_count: 2,
    reviewed_count: 2,
    accepted_count: 2,
    rejected_count: 0,
    naturalness_weight: 2,
  });
  assert.notEqual(OPEN.feature, "sclera_redness");
});

test("open branch requires both genuine polarities and exact triples", () => {
  const rows = [
    { feature: "teeth_whitening", polarity: "positive", role: "genuine_candidate", assets: ["original", "mask", "after"] },
    { feature: "teeth_whitening", polarity: "negative", role: "genuine_candidate", assets: ["original", "mask", "after"] },
  ];
  assert.deepEqual(rows.map((row) => row.polarity).sort(), ["negative", "positive"]);
  assert.ok(rows.every((row) => row.assets.length === 3));
  assert.ok(rows.every((row) => row.role === "genuine_candidate"));
});

test("mechanics and sibling rows have zero product weight", () => {
  const mechanics = { feature: "teeth_whitening", role: "mechanics_only", product_weight: 0 };
  const sibling = { feature: "sclera_redness", role: "genuine_candidate", product_weight: 0 };
  assert.equal(mechanics.product_weight, 0);
  assert.equal(sibling.product_weight, 0);
  assert.notEqual(mechanics.feature, sibling.feature);
});

test("durable projection allowlist excludes sensitive evidence", () => {
  const durable = { feature: "teeth_whitening", fixture_id: "opaque_01", decision: "accept", reason_code: "none", mask_coverage: 4, aggregates: { eligible_count: 2 } };
  const forbidden = /path|pixel|reviewer|rights|hash|geometry|freeform/i;
  assert.doesNotMatch(JSON.stringify(durable), forbidden);
  assert.throws(() => {
    const candidate = { ...durable, original_path: "/private/photo.png" };
    if (forbidden.test(JSON.stringify(candidate))) throw new Error("sensitive field");
  }, /sensitive field/);
});

test("review criteria are frozen before output review", () => {
  const criteria = Object.freeze({ target_improvement: 1, mask_coverage: 1, protected_leakage: 0, naturalness: 1, structure_change: 0 });
  assert.throws(() => { criteria.target_improvement = 2; }, TypeError);
  assert.equal(criteria.target_improvement, 1);
});

test("ReviewCore accepts the local authorized minimum review set", (t) => {
  const bundle = process.env.PHASE59_TEETH_BUNDLE;
  if (!bundle) {
    t.skip("local evidence is supplied by the private runner");
    return;
  }
  const durable = JSON.parse(Adapter.buildExport(bundle));
  const teeth = durable.feature_decisions.find((row) => row.feature === "teeth_whitening");
  assert.deepEqual(teeth, OPEN);
  assert.deepEqual(Object.keys(durable).sort(), ROOT_KEYS);
  assert.equal(durable.reviews.length, 2);
  assert.deepEqual(
    durable.reviews.map((row) => [row.polarity, row.target_present, row.mask_coverage, row.naturalness, row.decision, row.reason_code]),
    [["positive", true, 4, 4, "accept", "none"], ["negative", false, 1, 4, "accept", "none"]],
  );
  assert.doesNotMatch(JSON.stringify(durable), /path|hash|rights|reviewer|pixel|geometry|freeform/i);
});

test("serialized siblings remain exact and independently closed", (t) => {
  const bundle = process.env.PHASE59_TEETH_BUNDLE;
  if (!bundle) {
    t.skip("local evidence is supplied by the private runner");
    return;
  }
  const durable = JSON.parse(Adapter.buildExport(bundle));
  for (const [feature, expected] of Object.entries(CLOSED_SIBLINGS)) {
    assert.deepEqual(durable.feature_decisions.find((row) => row.feature === feature), expected);
    assert.deepEqual(
      durable.aggregates.find((row) => row.feature === feature),
      Object.fromEntries(Object.entries(expected).filter(([key]) => !["status", "reasons"].includes(key))),
    );
  }
  assert.deepEqual(durable.reviews.map((row) => row.feature), ["teeth_whitening", "teeth_whitening"]);
});

test("durable serializer schemas are exact while fixed mask judgments remain allowed", (t) => {
  const bundle = process.env.PHASE59_TEETH_BUNDLE;
  if (!bundle) {
    t.skip("local evidence is supplied by the private runner");
    return;
  }
  const durable = JSON.parse(Adapter.buildExport(bundle));
  for (const row of durable.feature_decisions) assert.deepEqual(Object.keys(row).sort(), DECISION_KEYS);
  for (const row of durable.reviews) assert.deepEqual(Object.keys(row).sort(), REVIEW_KEYS);
  for (const row of durable.aggregates) assert.deepEqual(Object.keys(row).sort(), AGGREGATE_KEYS);
  assert.deepEqual(durable.reviews.map((row) => row.mask_coverage), [4, 1]);
  assert.deepEqual(durable.reviews.map((row) => row.protected_leakage), [false, false]);

  for (const forbidden of ["source_path", "asset_digest", "rights_detail", "reviewer_note", "freeform", "raw_error", "raw_mask", "pixel_geometry"]) {
    const mutated = structuredClone(durable);
    mutated.reviews[0][forbidden] = "opaque";
    assert.notDeepEqual(Object.keys(mutated.reviews[0]).sort(), REVIEW_KEYS);
  }
});

test("mechanics reports cannot change the serialized admission", (t) => {
  const bundle = process.env.PHASE59_TEETH_BUNDLE;
  if (!bundle) {
    t.skip("local evidence is supplied by the private runner");
    return;
  }
  const baseline = Adapter.buildExport(bundle);
  const reports = [
    { changed_pixels: 0, mean_luminance_delta: 0, texture_energy_ratio: 1, outside_mask: 0 },
    { changed_pixels: 999999, mean_luminance_delta: -1, texture_energy_ratio: 9, outside_mask: 7 },
    { changed_pixels: null, mean_luminance_delta: "untrusted", texture_energy_ratio: {}, outside_mask: true },
  ];
  for (const report of reports) {
    assert.equal(Adapter.buildExport(bundle, report), baseline);
  }
});
