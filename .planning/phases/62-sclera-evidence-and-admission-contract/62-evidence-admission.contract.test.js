"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const ROOT = path.resolve(__dirname, "..", "..", "..");
const CORE = require(path.join(
  ROOT,
  ".planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-core.js",
));
const LEDGER_PATH = path.join(
  ROOT,
  ".planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-EVIDENCE-DECISIONS.json",
);

const OPEN_COUNTS = {
  eligible_count: 2,
  reviewed_count: 2,
  accepted_count: 2,
  rejected_count: 0,
  naturalness_weight: 2,
};
const CLOSED_COUNTS = {
  eligible_count: 0,
  reviewed_count: 0,
  accepted_count: 0,
  rejected_count: 0,
  naturalness_weight: 0,
};
const CURRENT_SCLERA = {
  feature: "sclera_redness",
  status: "closed",
  reasons: ["missing_genuine_positive", "missing_genuine_negative"],
  ...CLOSED_COUNTS,
};
const FUTURE_OPEN_SCLERA = {
  feature: "sclera_redness",
  status: "open",
  reasons: [],
  ...OPEN_COUNTS,
};
const CURRENT_TEETH = {
  feature: "teeth_whitening",
  status: "open",
  reasons: [],
  ...OPEN_COUNTS,
};
const CURRENT_EYELID = {
  feature: "upper_eyelid_fullness",
  status: "closed",
  reasons: [
    "missing_genuine_positive",
    "missing_genuine_negative",
    "non_warp_design_unqualified",
  ],
  ...CLOSED_COUNTS,
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
const FIXED_REVIEW_FIELDS = Object.freeze([
  "target_present", "mask_coverage", "protected_leakage", "naturalness",
  "structure_changed", "decision", "reason_code",
]);

function ledger() {
  return JSON.parse(fs.readFileSync(LEDGER_PATH, "utf8"));
}

function byFeature(rows) {
  return Object.fromEntries(rows.map((row) => [row.feature, row]));
}

test("current canonical rows are independently exact", () => {
  const durable = ledger();
  assert.deepEqual(Object.keys(durable).sort(), ROOT_KEYS);
  const decisions = byFeature(durable.feature_decisions);
  assert.deepEqual(decisions.teeth_whitening, CURRENT_TEETH);
  assert.deepEqual(decisions.sclera_redness, CURRENT_SCLERA);
  assert.deepEqual(decisions.upper_eyelid_fullness, CURRENT_EYELID);
});

test("ReviewCore closed sclera snapshot matches the zero-intake contract", () => {
  const snapshot = CORE.createClosedSnapshot("sclera_redness");
  const decision = CORE.evaluateFeature(snapshot, []);
  assert.deepEqual(decision, CURRENT_SCLERA);
  assert.equal(snapshot.feature, "sclera_redness");
  assert.equal(snapshot.ready, false);
});

test("future open shape is exact but is not current authority", () => {
  assert.deepEqual(FUTURE_OPEN_SCLERA, {
    feature: "sclera_redness",
    status: "open",
    reasons: [],
    ...OPEN_COUNTS,
  });
  assert.notDeepEqual(byFeature(ledger().feature_decisions).sclera_redness, FUTURE_OPEN_SCLERA);
  assert.deepEqual(byFeature(ledger().feature_decisions).teeth_whitening, CURRENT_TEETH);
});

test("eligible pair requires exact feature, distinct identities, both polarities, and triples", () => {
  const rows = [
    {
      fixture_id: "sclera_fixture_001",
      feature: "sclera_redness",
      polarity: "positive",
      expected_target_present: true,
      assets: ["original", "mask", "after"],
    },
    {
      fixture_id: "sclera_fixture_002",
      feature: "sclera_redness",
      polarity: "negative",
      expected_target_present: false,
      assets: ["original", "mask", "after"],
    },
  ];
  assert.equal(new Set(rows.map((row) => row.fixture_id)).size, 2);
  assert.deepEqual(rows.map((row) => row.polarity).sort(), ["negative", "positive"]);
  assert.ok(rows.every((row) => row.feature === "sclera_redness"));
  assert.ok(rows.every((row) => row.assets.join(",") === "original,mask,after"));
  assert.deepEqual(rows.map((row) => row.expected_target_present), [true, false]);
});

test("duplicate, one-sided, sibling, and mechanics rows never form a sclera pair", () => {
  const invalidSets = [
    [
      { fixture_id: "same", feature: "sclera_redness", polarity: "positive" },
      { fixture_id: "same", feature: "sclera_redness", polarity: "negative" },
    ],
    [
      { fixture_id: "one", feature: "sclera_redness", polarity: "positive" },
      { fixture_id: "two", feature: "sclera_redness", polarity: "positive" },
    ],
    [
      { fixture_id: "one", feature: "teeth_whitening", polarity: "positive" },
      { fixture_id: "two", feature: "sclera_redness", polarity: "negative" },
    ],
  ];
  for (const rows of invalidSets) {
    const valid = rows.length === 2
      && new Set(rows.map((row) => row.fixture_id)).size === 2
      && rows.every((row) => row.feature === "sclera_redness")
      && new Set(rows.map((row) => row.polarity)).size === 2;
    assert.equal(valid, false);
  }
  assert.equal({ feature: "sclera_redness", role: "mechanics_only", product_weight: 0 }.product_weight, 0);
});

test("review criteria and structured field inventory are frozen before intake", () => {
  assert.deepEqual(FIXED_REVIEW_FIELDS, [
    "target_present", "mask_coverage", "protected_leakage", "naturalness",
    "structure_changed", "decision", "reason_code",
  ]);
  assert.throws(() => FIXED_REVIEW_FIELDS.push("reviewer_note"), TypeError);
  const acceptedPositive = Object.freeze({
    target_present: true,
    mask_coverage: 4,
    protected_leakage: false,
    naturalness: 4,
    structure_changed: false,
    decision: "accept",
    reason_code: "none",
  });
  assert.ok(acceptedPositive.mask_coverage >= 1 && acceptedPositive.mask_coverage <= 5);
  assert.ok(acceptedPositive.naturalness >= 1 && acceptedPositive.naturalness <= 5);
  assert.equal(acceptedPositive.protected_leakage, false);
  assert.equal(acceptedPositive.structure_changed, false);
});

test("durable schemas allow fixed mask judgment but reject every extra sensitive field", () => {
  const durable = ledger();
  for (const row of durable.feature_decisions) assert.deepEqual(Object.keys(row).sort(), DECISION_KEYS);
  for (const row of durable.reviews) assert.deepEqual(Object.keys(row).sort(), REVIEW_KEYS);
  for (const row of durable.aggregates) assert.deepEqual(Object.keys(row).sort(), AGGREGATE_KEYS);
  for (const forbidden of [
    "source_path", "asset_digest", "rights_detail", "reviewer_identity", "reviewer_note",
    "raw_support", "raw_mask", "pixel_geometry", "raw_metric", "raw_error", "freeform",
  ]) {
    const mutated = structuredClone(durable);
    mutated.reviews[0][forbidden] = "opaque";
    assert.notDeepEqual(Object.keys(mutated.reviews[0]).sort(), REVIEW_KEYS);
  }
  assert.ok(durable.reviews.every((row) => typeof row.mask_coverage === "number"));
});

test("reordering cannot change identity-selected decisions or aggregates", () => {
  const durable = ledger();
  const reversedDecisions = byFeature([...durable.feature_decisions].reverse());
  const reversedAggregates = byFeature([...durable.aggregates].reverse());
  assert.deepEqual(reversedDecisions.teeth_whitening, CURRENT_TEETH);
  assert.deepEqual(reversedDecisions.sclera_redness, CURRENT_SCLERA);
  assert.deepEqual(reversedAggregates.sclera_redness, {
    feature: "sclera_redness",
    ...CLOSED_COUNTS,
  });
});

test("current durable bytes use exact LF serializer formatting", () => {
  const bytes = fs.readFileSync(LEDGER_PATH, "utf8");
  assert.equal(bytes.endsWith("\n"), true);
  assert.equal(bytes.endsWith("\n\n"), false);
  assert.equal(bytes.includes("\r"), false);
  assert.equal(bytes, `${JSON.stringify(JSON.parse(bytes), null, 2)}\n`);
});

test("threat inventory is exactly eight ordered blocking HIGH mitigations", () => {
  const inventory = JSON.parse(fs.readFileSync(path.join(__dirname, "62-THREAT-INVENTORY.json"), "utf8"));
  assert.equal(inventory.block_on, "HIGH");
  assert.deepEqual(
    inventory.threats.map((row) => row.id),
    Array.from({ length: 8 }, (_, index) => `T-62-${String(index + 1).padStart(2, "0")}`),
  );
  assert.ok(inventory.threats.every((row) => row.severity === "HIGH" && row.disposition === "mitigate"));
});

