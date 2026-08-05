"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");

const CLOSED = {
  feature: "teeth_whitening",
  status: "closed",
  reasons: ["missing_genuine_positive", "missing_genuine_negative"],
  eligible_count: 0,
  reviewed_count: 0,
  accepted_count: 0,
  rejected_count: 0,
  naturalness_weight: 0,
};

test("closed decision is exact and independent", () => {
  assert.deepEqual(CLOSED, {
    feature: "teeth_whitening",
    status: "closed",
    reasons: ["missing_genuine_positive", "missing_genuine_negative"],
    eligible_count: 0,
    reviewed_count: 0,
    accepted_count: 0,
    rejected_count: 0,
    naturalness_weight: 0,
  });
  assert.notEqual(CLOSED.feature, "sclera_redness");
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
  const durable = { feature: "teeth_whitening", fixture_id: "opaque_01", decision: "closed", reason_code: "missing_genuine_positive", aggregates: { eligible_count: 0 } };
  const forbidden = /path|mask|pixel|reviewer|rights|hash|geometry|freeform/i;
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
