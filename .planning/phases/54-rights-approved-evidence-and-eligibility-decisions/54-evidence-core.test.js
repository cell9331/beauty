"use strict";

const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");

const CORE_PATH = path.join(__dirname, "54-evidence-core.js");
if (!fs.existsSync(CORE_PATH)) {
  throw new Error("RED_MISSING_ARTIFACT:54-evidence-core.js");
}
const core = require(CORE_PATH);

const FEATURE_ORDER = [
  "teeth_whitening",
  "sclera_redness",
  "upper_eyelid_fullness",
];
const REVIEW_REASONS = [
  "none",
  "target_mismatch",
  "insufficient_mask_coverage",
  "protected_leakage",
  "unnatural_result",
  "texture_loss",
  "structure_change",
  "unsupported_input",
];
const GATE_REASONS = [
  "missing_genuine_positive",
  "missing_genuine_negative",
  "incomplete_asset_triple",
  "unapproved_fixture",
  "review_incomplete",
  "review_rejected",
  "non_warp_design_unqualified",
];
const ASSET_KEYS = [
  "assets/p-original.png",
  "assets/p-mask.png",
  "assets/p-after.png",
  "assets/n-original.jpg",
  "assets/n-mask.png",
  "assets/n-after.jpg",
];

function fixture(id, polarity, overrides = {}) {
  const prefix = polarity === "positive" ? "p" : "n";
  return {
    fixture_id: id,
    feature: "teeth_whitening",
    polarity,
    expected_target_present: polarity === "positive",
    polarity_predeclared: true,
    rights_status: "approved_internal_evaluation",
    rights_record_id: `right_${id}`,
    evidence_role: "genuine_candidate",
    assets: {
      original: `assets/${prefix}-original.${prefix === "p" ? "png" : "jpg"}`,
      mask: `assets/${prefix}-mask.png`,
      after: `assets/${prefix}-after.${prefix === "p" ? "png" : "jpg"}`,
    },
    ...overrides,
  };
}

function manifest(feature = "teeth_whitening", rows) {
  const fixtures = rows || [fixture("case_positive", "positive"), fixture("case_negative", "negative")];
  return {
    schema_version: 1,
    feature,
    fixtures: fixtures.map((row) => ({ ...row, feature })),
  };
}

function review(row, overrides = {}) {
  return {
    fixture_id: row.fixture_id,
    target_present: row.expected_target_present,
    mask_coverage: row.polarity === "positive" ? 4 : 1,
    protected_leakage: false,
    naturalness: 4,
    structure_changed: false,
    decision: "accept",
    reason_code: "none",
    ...overrides,
  };
}

function issuedReview(snapshot, row, overrides = {}) {
  return core.createReview(snapshot, review(row, overrides));
}

function issuedReviews(snapshot) {
  return snapshot.selected_rows.map((row) => issuedReview(snapshot, row));
}

function authorizationRegistryFor(value = manifest()) {
  return core.createTrustedAuthorizationRegistry({
    schema_version: 1,
    grants: value.fixtures
      .filter((row) => row.rights_status === "approved_internal_evaluation"
        && row.evidence_role === "genuine_candidate")
      .map((row) => ({
        rights_record_id: row.rights_record_id,
        fixture_id: row.fixture_id,
        feature: row.feature,
        polarity: row.polarity,
        permitted_use: "internal_product_evaluation",
        evidence_classification: "genuine_candidate",
      })),
  });
}

function snapshotFor(value = manifest(), keys = ASSET_KEYS, registry = authorizationRegistryFor(value)) {
  const snapshot = core.createReviewSnapshot(value, keys, registry);
  assert.equal(snapshot.valid, true);
  return snapshot;
}

function validation(value) {
  const result = core.validateManifest(value);
  assert.equal(typeof result, "object");
  return result;
}

function assertInvalid(value, label) {
  const result = validation(value);
  assert.equal(result.valid, false, label);
  assert.ok(Array.isArray(result.reasons) && result.reasons.length > 0, `${label}: fixed reasons required`);
  const serialized = JSON.stringify(result);
  assert.doesNotMatch(serialized, /Users|private|right_case|assets\//i, `${label}: errors must be redacted`);
}

function clone(value) {
  return structuredClone(value);
}

function deepFrozen(value) {
  if (value === null || typeof value !== "object") return true;
  return Object.isFrozen(value) && Object.values(value).every(deepFrozen);
}

function assertReviewInvalid(snapshot, candidate, label) {
  const result = core.validateReview(snapshot, candidate);
  assert.equal(result.valid, false, label);
  assert.ok(Array.isArray(result.reasons) && result.reasons.length > 0, `${label}: reason required`);
}

function acceptedFeature(feature = "teeth_whitening") {
  const value = manifest(feature);
  const snap = snapshotFor(value);
  const reviews = issuedReviews(snap);
  const decision = core.evaluateFeature(snap, reviews, feature === "upper_eyelid_fullness"
    ? { feature, reviewed: true, decision: "qualified", method_class: "independent_nonwarp" }
    : undefined);
  return { value, snap, reviews, decision };
}

function unevaluatedFeature(feature = "teeth_whitening") {
  const value = manifest(feature);
  const snap = snapshotFor(value);
  return {
    value,
    snap,
    reviews: issuedReviews(snap),
    design_qualification: feature === "upper_eyelid_fullness"
      ? { feature, reviewed: true, decision: "qualified", method_class: "independent_nonwarp" }
      : undefined,
  };
}

test("constants freeze the Phase 54 enum and safety inventories", () => {
  assert.ok(deepFrozen(core.constants));
  assert.deepEqual(core.constants.features, FEATURE_ORDER);
  assert.deepEqual(core.constants.review_reasons, REVIEW_REASONS);
  assert.deepEqual(core.constants.gate_reasons, GATE_REASONS);
  assert.equal(core.constants.max_rows, 64);
  assert.equal(core.constants.max_manifest_bytes, 65_536);
  assert.equal(core.constants.max_asset_bytes, 16 * 1024 * 1024);
  assert.equal(core.constants.max_decoded_dimension, 4096);
});

test("core-owned baseline snapshots remain branded, frozen, and deterministically closed", () => {
  const expected = {
    teeth_whitening: ["missing_genuine_positive"],
    sclera_redness: ["missing_genuine_positive", "incomplete_asset_triple"],
    upper_eyelid_fullness: ["missing_genuine_positive", "non_warp_design_unqualified"],
  };
  for (const feature of FEATURE_ORDER) {
    const snapshot = core.createClosedSnapshot(feature);
    assert.ok(deepFrozen(snapshot));
    assert.deepEqual(core.evaluateFeature(snapshot, []).reasons, expected[feature]);
    assert.throws(() => core.evaluateFeature(clone(snapshot), []), /feature_snapshot_invalid/);
  }
  assert.throws(() => core.createClosedSnapshot("unsupported"), /feature_invalid/);
});

test("bundle accepts one complete genuine approved positive and negative", () => {
  const result = validation(manifest());
  assert.equal(result.valid, true);
  const snap = snapshotFor();
  assert.equal(snap.ready, true);
  assert.deepEqual(snap.selected_rows.map((row) => row.fixture_id), ["case_negative", "case_positive"]);
});

test("trusted authorization is independent and bound to record fixture feature polarity use and classification", () => {
  const approved = manifest();
  const registry = authorizationRegistryFor(approved);
  assert.ok(deepFrozen(registry));

  const mutations = [
    ["invented rights record", (value) => { value.fixtures[0].rights_record_id = "invented_rights"; }],
    ["mismatched fixture", (value) => { value.fixtures[0].fixture_id = "invented_fixture"; }],
    ["mismatched feature", (value) => {
      value.feature = "sclera_redness";
      for (const row of value.fixtures) row.feature = "sclera_redness";
    }],
    ["mismatched polarity", (value) => {
      value.fixtures[0].polarity = "negative";
      value.fixtures[0].expected_target_present = false;
    }],
    ["reused grant", (value) => {
      value.fixtures[1].rights_record_id = value.fixtures[0].rights_record_id;
    }],
  ];
  for (const [label, mutate] of mutations) {
    const value = clone(approved);
    mutate(value);
    const snapshot = core.createReviewSnapshot(value, ASSET_KEYS, registry);
    assert.equal(snapshot.valid, true, label);
    assert.equal(snapshot.ready, false, label);
    assert.ok(snapshot.reasons.includes("unapproved_fixture"), label);
    assert.ok(snapshot.selected_rows.length < value.fixtures.length, label);
  }

  const selfPromoted = manifest("teeth_whitening", [fixture("promoted", "positive", {
    rights_record_id: "invented_rights",
    evidence_role: "genuine_candidate",
  })]);
  const selfPromotedSnapshot = core.createReviewSnapshot(selfPromoted, ASSET_KEYS.slice(0, 3), registry);
  assert.equal(selfPromotedSnapshot.ready, false);
  assert.deepEqual(selfPromotedSnapshot.selected_rows, []);
  assert.ok(selfPromotedSnapshot.reasons.includes("unapproved_fixture"));

  assert.deepEqual(
    core.createReviewSnapshot(approved, ASSET_KEYS, clone(registry)).reasons,
    ["authorization_registry_invalid"],
    "a manifest cannot manufacture a trusted registry by copying its shape",
  );
});

test("trusted authorization registry rejects duplicate and malformed grants", () => {
  const base = authorizationRegistryFor(manifest());
  assert.throws(() => core.createTrustedAuthorizationRegistry({
    schema_version: 1,
    grants: [base.grants[0], { ...base.grants[1], rights_record_id: base.grants[0].rights_record_id }],
  }), /authorization_registry_invalid/);
  for (const [field, value] of [
    ["permitted_use", "commercial_release"],
    ["evidence_classification", "synthetic"],
  ]) {
    const grant = { ...base.grants[0], [field]: value };
    assert.throws(
      () => core.createTrustedAuthorizationRegistry({ schema_version: 1, grants: [grant] }),
      /authorization_registry_invalid/,
    );
  }
});

test("path mutations reject absolute traversal dot backslash colon NUL and empty keys", () => {
  const mutations = [
    "/absolute.png",
    "../escape.png",
    "assets/../escape.png",
    "./assets/p.png",
    "assets/./p.png",
    "assets\\p.png",
    "volume:p.png",
    "assets/p\0.png",
    "",
  ];
  for (const [index, candidate] of mutations.entries()) {
    const value = manifest();
    value.fixtures[0].assets.original = candidate;
    assertInvalid(value, `unsafe path ${index}`);
    assert.equal(core.normalizeRelativeAssetKey(candidate).valid, false);
  }
});

test("identity mutations reject duplicate invalid empty and over-64 opaque IDs", () => {
  const invalidIDs = ["", "space id", "slash/id", "a".repeat(65)];
  for (const candidate of invalidIDs) {
    const value = manifest();
    value.fixtures[0].fixture_id = candidate;
    assertInvalid(value, "invalid opaque ID");
  }
  const duplicate = manifest();
  duplicate.fixtures[1].fixture_id = duplicate.fixtures[0].fixture_id;
  assertInvalid(duplicate, "duplicate opaque ID");
});

test("asset identity rejects duplicate normalized keys basename collisions exact-key mismatch and no directory", () => {
  const duplicate = manifest();
  duplicate.fixtures[1].assets.mask = duplicate.fixtures[0].assets.mask;
  assertInvalid(duplicate, "duplicate declared asset key");

  const value = manifest();
  const registry = authorizationRegistryFor(value);
  const snap = core.createReviewSnapshot(value, [
    ...ASSET_KEYS,
    "other/p-original.png",
  ], registry);
  assert.equal(snap.valid, false, "basename collision is not repaired into an alias");

  const mismatch = core.createReviewSnapshot(value, ASSET_KEYS.map((key) => `bundle/${key}`), registry);
  assert.equal(mismatch.ready, false, "selected-root-relative keys must match exactly");
  assert.ok(mismatch.reasons.includes("incomplete_asset_triple"));

  const absent = core.createReviewSnapshot(value, [], registry);
  assert.equal(absent.ready, false, "no selected directory closes readiness");
});

test("incomplete asset rows stay closed and never count as eligible in evaluation or export", () => {
  const oneAssetMissing = ASSET_KEYS.filter((key) => key !== "assets/p-after.png");
  const snapshot = snapshotFor(manifest(), oneAssetMissing);
  assert.equal(snapshot.ready, false);
  assert.deepEqual(snapshot.reasons, ["incomplete_asset_triple"]);
  assert.equal(snapshot.product_counts.positive, 0, "incomplete positive is not presented as eligible");
  assert.equal(snapshot.product_counts.negative, 1, "polarity ledger remains intact");
  assert.equal(snapshot.product_counts.eligible, 1, "only the complete negative row is eligible");
  const decision = core.evaluateFeature(snapshot, []);
  assert.equal(decision.status, "closed");
  assert.deepEqual(decision.reasons, ["incomplete_asset_triple"]);
  assert.equal(decision.eligible_count, 1);

  const inputs = FEATURE_ORDER.map((feature) => ({
    snapshot: snapshotFor(manifest(feature), []),
    reviews: [],
    design_qualification: feature === "upper_eyelid_fullness"
      ? { feature, reviewed: true, decision: "qualified", method_class: "independent_nonwarp" }
      : undefined,
  }));
  const durable = core.buildDurableExport(inputs);
  assert.deepEqual(durable.feature_decisions.map((row) => row.status), ["closed", "closed", "closed"]);
  assert.deepEqual(durable.feature_decisions.map((row) => row.eligible_count), [0, 0, 0]);
  assert.deepEqual(durable.aggregates.map((row) => row.eligible_count), [0, 0, 0]);
  assert.deepEqual(durable.reviews, []);
});

test("manifest mutations reject unsupported enums mixed features missing rights and undeclared polarity", () => {
  const mutations = [
    ["feature", "unsupported_feature"],
    ["polarity", "uncertain"],
    ["rights_status", "unknown"],
    ["evidence_role", "unknown"],
  ];
  for (const [field, candidate] of mutations) {
    const value = manifest();
    value.fixtures[0][field] = candidate;
    if (field === "feature") value.feature = candidate;
    assertInvalid(value, `unsupported ${field}`);
  }
  const mixed = manifest();
  mixed.fixtures[1].feature = "sclera_redness";
  assertInvalid(mixed, "mixed feature manifest");

  const missingRights = manifest();
  delete missingRights.fixtures[0].rights_record_id;
  assertInvalid(missingRights, "missing rights record");

  const undeclared = manifest();
  undeclared.fixtures[0].polarity_predeclared = false;
  assertInvalid(undeclared, "polarity not predeclared");
});

test("completeness mutations reject missing triple members but valid partial polarity bundles close", () => {
  for (const member of ["original", "mask", "after"]) {
    const value = manifest();
    delete value.fixtures[0].assets[member];
    assertInvalid(value, `missing ${member}`);
  }

  for (const polarity of ["positive", "negative"]) {
    const only = manifest("teeth_whitening", [fixture(`only_${polarity}`, polarity)]);
    const result = validation(only);
    assert.equal(result.valid, true, `missing ${polarity === "positive" ? "negative" : "positive"} is structurally valid`);
    const snap = snapshotFor(only, polarity === "positive" ? ASSET_KEYS.slice(0, 3) : ASSET_KEYS.slice(3));
    assert.equal(snap.ready, false);
    assert.ok(snap.reasons.includes(polarity === "positive" ? "missing_genuine_negative" : "missing_genuine_positive"));
  }
});

test("manifest budgets reject over 64 rows and oversized serialized input", () => {
  const many = manifest("teeth_whitening", Array.from({ length: 65 }, (_, index) =>
    fixture(`row_${index}`, index % 2 ? "positive" : "negative")));
  assertInvalid(many, "over 64 rows");

  const oversized = manifest();
  oversized.padding = "x".repeat(65_536);
  assertInvalid(oversized, "oversized manifest");
});

test("roles and rights exclude mechanics synthetic AI disabled parked historical and rejected rows", () => {
  const excluded = [
    ["mechanics_only", "mechanics_only"],
    ["approved_internal_evaluation", "synthetic"],
    ["approved_internal_evaluation", "ai_generated"],
    ["approved_internal_evaluation", "disabled"],
    ["approved_internal_evaluation", "parked"],
    ["approved_internal_evaluation", "historical"],
    ["rejected", "genuine_candidate"],
  ];
  for (const [rights, role] of excluded) {
    const value = manifest();
    value.fixtures[0].rights_status = rights;
    value.fixtures[0].evidence_role = role;
    const snap = snapshotFor(value, ASSET_KEYS);
    assert.equal(snap.valid, true, `${rights}/${role} remains a tooling-valid row`);
    assert.equal(
      snap.review_rows.some((row) => row.fixture_id === "case_positive"),
      rights !== "rejected",
      `${rights}/${role} respects the local-review rights boundary`,
    );
    assert.equal(snap.selected_rows.some((row) => row.fixture_id === "case_positive"), false);
    assert.equal(snap.excluded_counts.rows, 1);
    assert.equal(snap.product_counts.eligible, 1);
    assert.equal(snap.product_counts.naturalness_weight, 0);
  }
});

test("portrait authorization alone never supplies a positive or product row", () => {
  const authorized = fixture("portrait_001", "positive", {
    expected_target_present: true,
    evidence_role: "historical",
  });
  const value = manifest("teeth_whitening", [authorized, fixture("case_negative", "negative")]);
  const snap = snapshotFor(value, ASSET_KEYS);
  assert.equal(snap.ready, false);
  assert.equal(snap.product_counts.positive, 0);
  assert.ok(snap.reasons.includes("missing_genuine_positive"));

  const qualifiedNegative = manifest("teeth_whitening", [
    fixture("portrait_001", "negative"),
  ]);
  const negativeSnap = snapshotFor(qualifiedNegative, ASSET_KEYS.slice(3));
  assert.equal(negativeSnap.product_counts.negative, 1);
  assert.equal(negativeSnap.product_counts.positive, 0);
  assert.equal(negativeSnap.ready, false);
});

test("snapshot copies stable-sorts and deeply freezes pre-review policy and rows", () => {
  const source = manifest("teeth_whitening", [fixture("z_positive", "positive"), fixture("a_negative", "negative")]);
  const keys = [
    "assets/p-original.png", "assets/p-mask.png", "assets/p-after.png",
    "assets/n-original.jpg", "assets/n-mask.png", "assets/n-after.jpg",
  ];
  const before = clone(source);
  const snap = snapshotFor(source, keys);
  assert.deepEqual(source, before, "snapshot creation cannot mutate input");
  assert.deepEqual(snap.selected_rows.map((row) => row.fixture_id), ["a_negative", "z_positive"]);
  assert.ok(deepFrozen(snap));
  source.fixtures[0].polarity = "negative";
  source.fixtures[0].expected_target_present = false;
  source.fixtures[0].assets.original = "changed.png";
  assert.equal(snap.selected_rows[1].polarity, "positive");
  assert.equal(snap.selected_rows[1].expected_target_present, true);
  assert.equal(snap.selected_rows[1].assets.original, "assets/p-original.png");
});

test("review set rejects duplicate missing and extra reviews", () => {
  const snap = snapshotFor();
  const reviews = issuedReviews(snap);
  assert.equal(core.evaluateFeature(snap, reviews).status, "open");
  assert.throws(() => core.evaluateFeature(snap, reviews.slice(1)), /review/i);
  assert.throws(() => core.evaluateFeature(snap, [...reviews, reviews[0]]), /review/i);
  assert.throws(() => core.evaluateFeature(snap, [...reviews, { ...reviews[0], fixture_id: "extra_case" }]), /review/i);
});

test("review schema rejects unsupported enum reason unset fields and score bounds", () => {
  const snap = snapshotFor();
  const row = snap.selected_rows.find((candidate) => candidate.polarity === "positive");
  const base = review(row);
  for (const [field, value] of [
    ["mask_coverage", 0],
    ["mask_coverage", 6],
    ["mask_coverage", 4.5],
    ["naturalness", 0],
    ["naturalness", 6],
    ["naturalness", 4.5],
    ["decision", "maybe"],
    ["reason_code", "unknown_reason"],
  ]) {
    assertReviewInvalid(snap, { ...base, [field]: value }, `${field}=${value}`);
  }
  for (const field of [
    "target_present", "mask_coverage", "protected_leakage", "naturalness",
    "structure_changed", "decision", "reason_code",
  ]) {
    const candidate = { ...base };
    delete candidate[field];
    assertReviewInvalid(snap, candidate, `unset ${field}`);
  }
});

test("review decision and reason compatibility is exact", () => {
  const snap = snapshotFor();
  const row = snap.selected_rows[0];
  assertReviewInvalid(snap, review(row, { decision: "reject", reason_code: "none" }), "reject needs reason");
  assertReviewInvalid(snap, review(row, { decision: "accept", reason_code: "texture_loss" }), "accept needs none");
});

test("positive frozen predicate rejects target coverage leakage naturalness structure and decision failures", () => {
  const snap = snapshotFor();
  const row = snap.selected_rows.find((candidate) => candidate.polarity === "positive");
  assert.equal(core.rowPasses(row, review(row)), true);
  const failures = [
    { target_present: false, decision: "reject", reason_code: "target_mismatch" },
    { mask_coverage: 3, decision: "reject", reason_code: "insufficient_mask_coverage" },
    { protected_leakage: true, decision: "reject", reason_code: "protected_leakage" },
    { naturalness: 3, decision: "reject", reason_code: "unnatural_result" },
    { structure_changed: true, decision: "reject", reason_code: "structure_change" },
    { decision: "reject", reason_code: "unsupported_input" },
  ];
  for (const mutation of failures) assert.equal(core.rowPasses(row, review(row, mutation)), false);
});

test("negative frozen predicate confirms predeclared absence or challenge and common safety rules", () => {
  const snap = snapshotFor();
  const row = snap.selected_rows.find((candidate) => candidate.polarity === "negative");
  assert.equal(core.rowPasses(row, review(row)), true);
  assert.equal(core.rowPasses(row, review(row, {
    target_present: !row.expected_target_present,
    decision: "reject",
    reason_code: "target_mismatch",
  })), false);
  assert.equal(core.rowPasses(row, review(row, {
    protected_leakage: true,
    decision: "reject",
    reason_code: "protected_leakage",
  })), false);
  assert.equal(core.rowPasses(row, review(row, {
    naturalness: 3,
    decision: "reject",
    reason_code: "unnatural_result",
  })), false);
  assert.equal(core.rowPasses(row, review(row, {
    structure_changed: true,
    decision: "reject",
    reason_code: "structure_change",
  })), false);
});

test("all selected genuine rows must pass without mechanics denominator or naturalness contamination", () => {
  const value = manifest("teeth_whitening", [
    fixture("case_positive", "positive"),
    fixture("case_negative", "negative"),
    fixture("tooling_row", "positive", {
      rights_status: "mechanics_only",
      evidence_role: "mechanics_only",
      assets: {
        original: "assets/tool-original.png",
        mask: "assets/tool-mask.png",
        after: "assets/tool-after.png",
      },
    }),
  ]);
  const snap = snapshotFor(value, [...ASSET_KEYS, "assets/tool-original.png", "assets/tool-mask.png", "assets/tool-after.png"]);
  const mechanicsRow = snap.review_rows.find((row) => row.fixture_id === "tooling_row");
  assert.ok(mechanicsRow, "mechanics row remains available to the local reviewer");
  assert.equal(core.validateReview(snap, review(mechanicsRow)).valid, true);
  const reviews = issuedReviews(snap);
  const accepted = core.evaluateFeature(snap, reviews);
  assert.equal(accepted.status, "open");
  assert.equal(accepted.eligible_count, 2);
  assert.equal(accepted.reviewed_count, 2);
  assert.equal(accepted.naturalness_weight, 2);

  reviews[0] = issuedReview(snap, snap.selected_rows[0], {
    decision: "reject", reason_code: "unsupported_input",
  });
  const rejected = core.evaluateFeature(snap, reviews);
  assert.equal(rejected.status, "closed");
  assert.ok(rejected.reasons.includes("review_rejected"));
});

test("three feature reducers isolate rows counts reviews reasons and status", () => {
  const teeth = acceptedFeature("teeth_whitening");
  const sclera = acceptedFeature("sclera_redness");
  const eyelid = acceptedFeature("upper_eyelid_fullness");
  assert.deepEqual([teeth.decision.feature, sclera.decision.feature, eyelid.decision.feature], FEATURE_ORDER);
  assert.throws(() => core.evaluateFeature(teeth.snap, sclera.reviews), /review|feature/i);

  const scleraBefore = clone(sclera.decision);
  teeth.reviews[0] = issuedReview(teeth.snap, teeth.snap.selected_rows[0], {
    decision: "reject", reason_code: "unsupported_input",
  });
  const teethAfter = core.evaluateFeature(teeth.snap, teeth.reviews);
  assert.equal(teethAfter.status, "closed");
  assert.deepEqual(core.evaluateFeature(sclera.snap, sclera.reviews), scleraBefore);
});

test("mutable and frozen review arrays cannot be borrowed across direct feature evaluation", () => {
  for (const freeze of [false, true]) {
    const teeth = unevaluatedFeature("teeth_whitening");
    const sclera = unevaluatedFeature("sclera_redness");
    const reviews = freeze ? Object.freeze(teeth.reviews) : teeth.reviews;
    assert.equal(core.evaluateFeature(teeth.snap, reviews).status, "open");
    assert.throws(
      () => core.evaluateFeature(sclera.snap, reviews),
      /review_feature_invalid/,
      `${freeze ? "frozen" : "mutable"} arrays retain feature provenance`,
    );
  }
});

test("durable export preserves mutable and frozen review provenance before allowlist copying", () => {
  for (const freeze of [false, true]) {
    const inputs = FEATURE_ORDER.map((feature) => unevaluatedFeature(feature));
    const borrowed = freeze ? Object.freeze(inputs[0].reviews) : inputs[0].reviews;
    inputs[0].reviews = borrowed;
    inputs[1].reviews = borrowed;
    assert.throws(
      () => core.buildDurableExport(inputs.map(({ snap, reviews, design_qualification }) => ({
        snapshot: snap,
        reviews,
        design_qualification,
      }))),
      /review_feature_invalid/,
      `${freeze ? "frozen" : "mutable"} source provenance survives export copying`,
    );
  }
});

test("cloned review carriers lose issuance and cannot satisfy sibling or source snapshots", () => {
  const inputs = FEATURE_ORDER.map((feature) => unevaluatedFeature(feature));
  const cloned = Object.freeze(inputs[0].reviews.map((row) => Object.freeze({ ...row })));
  assert.throws(() => core.evaluateFeature(inputs[0].snap, cloned), /review_feature_invalid/);
  for (const input of inputs) input.reviews = cloned.map((row) => Object.freeze({ ...row }));
  assert.throws(
    () => core.buildDurableExport(inputs.map(({ snap, reviews, design_qualification }) => ({
      snapshot: snap,
      reviews,
      design_qualification,
    }))),
    /review_feature_invalid/,
  );
});

test("issued review carriers are bound to one exact snapshot and cannot survive same-feature replacement", () => {
  const first = unevaluatedFeature("teeth_whitening");
  const replacementManifest = manifest("teeth_whitening", [
    fixture("case_positive", "positive", {
      rights_record_id: "replacement_positive_right",
      assets: {
        original: "replacement/p-original.png",
        mask: "replacement/p-mask.png",
        after: "replacement/p-after.png",
      },
    }),
    fixture("case_negative", "negative", {
      rights_record_id: "replacement_negative_right",
      assets: {
        original: "replacement/n-original.jpg",
        mask: "replacement/n-mask.png",
        after: "replacement/n-after.jpg",
      },
    }),
  ]);
  const replacementKeys = replacementManifest.fixtures.flatMap((row) => Object.values(row.assets));
  const secondSnapshot = snapshotFor(replacementManifest, replacementKeys);
  assert.throws(
    () => core.evaluateFeature(secondSnapshot, first.reviews),
    /review_feature_invalid/,
  );
  const secondReviews = issuedReviews(secondSnapshot);
  assert.equal(core.evaluateFeature(secondSnapshot, secondReviews).status, "open");
});

test("fabricated ready snapshots cannot open direct evaluation or durable export", () => {
  const teeth = unevaluatedFeature("teeth_whitening");
  const fabricatedSnapshots = [
    clone(teeth.snap),
    Object.assign(clone(teeth.snap), { ready: false, reasons: [] }),
    Object.assign(clone(teeth.snap), {
      product_counts: { positive: 1, negative: 1, eligible: 999, naturalness_weight: 0 },
    }),
    Object.assign(clone(teeth.snap), { selected_rows: [], review_rows: [] }),
  ];
  for (const fabricated of fabricatedSnapshots) {
    assert.throws(
      () => core.evaluateFeature(fabricated, fabricated.selected_rows.length === 0 ? [] : teeth.reviews),
      /feature_snapshot_invalid/,
    );
  }

  const inputs = FEATURE_ORDER.map((feature) => unevaluatedFeature(feature));
  inputs[1].snap = clone(inputs[1].snap);
  assert.throws(
    () => core.buildDurableExport(inputs.map(({ snap, reviews, design_qualification }) => ({
      snapshot: snap,
      reviews,
      design_qualification,
    }))),
    /feature_snapshot_invalid/,
  );
});

test("sibling positive or negative cannot satisfy a feature-local missing polarity", () => {
  const teethOnlyNegative = manifest("teeth_whitening", [fixture("teeth_negative", "negative")]);
  const scleraOnlyPositive = manifest("sclera_redness", [fixture("sclera_positive", "positive")]);
  const teethSnap = snapshotFor(teethOnlyNegative, ASSET_KEYS.slice(3));
  const scleraSnap = snapshotFor(scleraOnlyPositive, ASSET_KEYS.slice(0, 3));
  assert.ok(teethSnap.reasons.includes("missing_genuine_positive"));
  assert.ok(scleraSnap.reasons.includes("missing_genuine_negative"));
  assert.equal(teethSnap.product_counts.positive, 0);
  assert.equal(scleraSnap.product_counts.negative, 0);
});

test("upper eyelid evidence and credible independent non-warp design are a conjunction", () => {
  const missingEvidence = manifest("upper_eyelid_fullness", [fixture("lid_negative", "negative")]);
  const snap = snapshotFor(missingEvidence, ASSET_KEYS.slice(3));
  const qualified = { feature: "upper_eyelid_fullness", reviewed: true, decision: "qualified", method_class: "independent_nonwarp" };
  const closedEvidence = core.evaluateFeature(snap, [], qualified);
  assert.equal(closedEvidence.status, "closed");
  assert.ok(closedEvidence.reasons.includes("missing_genuine_positive"));
  assert.ok(!closedEvidence.reasons.includes("non_warp_design_unqualified"));

  const complete = acceptedFeature("upper_eyelid_fullness");
  const unreviewed = core.evaluateFeature(complete.snap, complete.reviews, {
    feature: "upper_eyelid_fullness", reviewed: false, decision: "qualified", method_class: "independent_nonwarp",
  });
  assert.equal(unreviewed.status, "closed");
  assert.ok(unreviewed.reasons.includes("non_warp_design_unqualified"));

  const bothMissing = core.evaluateFeature(snap, [], {
    feature: "upper_eyelid_fullness", reviewed: false, decision: "unqualified", method_class: "independent_nonwarp",
  });
  assert.deepEqual(bothMissing.reasons, ["missing_genuine_positive", "non_warp_design_unqualified"]);
});

test("upper eyelid invalidated warp and geometry smoothing dark-circle eye-bag substitutes never qualify", () => {
  const complete = acceptedFeature("upper_eyelid_fullness");
  const rejectedClasses = [
    "invalidated_interior_warp",
    "eye_geometry_proxy",
    "brow_geometry_proxy",
    "aperture_proxy",
    "global_smoothing_proxy",
    "dark_circle_proxy",
    "eye_bag_proxy",
  ];
  for (const method_class of rejectedClasses) {
    const result = core.evaluateFeature(complete.snap, complete.reviews, {
      feature: "upper_eyelid_fullness", reviewed: true, decision: "qualified", method_class,
    });
    assert.equal(result.status, "closed", method_class);
    assert.ok(result.reasons.includes("non_warp_design_unqualified"), method_class);
  }
  assert.equal(complete.decision.status, "open");
});

test("export constructs exact allowlists and stable deterministic bytes", () => {
  const inputs = FEATURE_ORDER.map((feature) => acceptedFeature(feature));
  const richInputs = inputs.map(({ snap, reviews }) => ({
    snapshot: snap,
    reviews,
    design_qualification: snap.feature === "upper_eyelid_fullness"
      ? { feature: snap.feature, reviewed: true, decision: "qualified", method_class: "independent_nonwarp", timestamp: "forbidden_time" }
      : undefined,
  }));
  const durable = core.buildDurableExport(richInputs);
  assert.deepEqual(Object.keys(durable), ["schema_version", "feature_decisions", "reviews", "aggregates"]);
  assert.deepEqual(durable.feature_decisions.map((row) => row.feature), FEATURE_ORDER);
  assert.deepEqual(durable.reviews.map((row) => `${row.feature}:${row.fixture_id}`), [
    "teeth_whitening:case_negative", "teeth_whitening:case_positive",
    "sclera_redness:case_negative", "sclera_redness:case_positive",
    "upper_eyelid_fullness:case_negative", "upper_eyelid_fullness:case_positive",
  ]);
  const reviewKeys = [
    "fixture_id", "feature", "polarity", "target_present", "mask_coverage",
    "protected_leakage", "naturalness", "structure_changed", "decision", "reason_code",
  ];
  for (const row of durable.reviews) assert.deepEqual(Object.keys(row), reviewKeys);

  const first = core.serializeDurableExport(richInputs);
  const second = core.serializeDurableExport(richInputs);
  assert.equal(first, second);
  assert.equal(first, `${JSON.stringify(durable, null, 2)}\n`);
  assert.ok(first.endsWith("\n") && !first.endsWith("\n\n"));
  assert.ok(!first.includes("\r"));
});

test("export rejects time session event arguments and recursively excludes privacy sentinels", () => {
  assert.equal(core.buildDurableExport.length, 1);
  assert.equal(core.serializeDurableExport.length, 1);
  const inputs = FEATURE_ORDER.map((feature) => acceptedFeature(feature));
  const sentinels = [
    "dataset", "generated_at", "timestamp", "event", "metadata", "reviewer",
    "notes", "freeform", "filename", "path", "directory", "rights",
    "documentation", "retention", "original", "mask", "after", "media",
    "blob", "coordinates", "landmarks", "pupils", "descriptors", "raw_geometry",
    "raw_error",
  ];
  const rich = inputs.map(({ snap, reviews }) => ({
    snapshot: snap,
    reviews,
    design_qualification: snap.feature === "upper_eyelid_fullness"
      ? Object.assign({ feature: snap.feature, reviewed: true, decision: "qualified", method_class: "independent_nonwarp" }, Object.fromEntries(sentinels.map((key) => [key, `SENTINEL_${key}`])))
      : undefined,
  }));
  for (const { snap, reviews } of inputs) {
    const candidate = Object.assign(
      {},
      reviews[0],
      Object.fromEntries(sentinels.map((key) => [key, `SENTINEL_${key}`])),
    );
    assert.throws(() => core.createReview(snap, candidate), /review_invalid/);
  }
  const serialized = core.serializeDurableExport(rich);
  for (const key of sentinels) {
    assert.ok(!serialized.includes(`SENTINEL_${key}`), `forbidden sentinel ${key}`);
    assert.ok(!serialized.includes(`"${key}"`), `forbidden key ${key}`);
  }
});
