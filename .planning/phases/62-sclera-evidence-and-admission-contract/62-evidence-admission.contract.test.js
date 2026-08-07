"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const ROOT = path.resolve(__dirname, "..", "..", "..");
const CORE = require(path.join(
  ROOT,
  ".planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-evidence-core.js",
));
const LEDGER_PATH = path.join(
  ROOT,
  ".planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-EVIDENCE-DECISIONS.json",
);
const ADAPTER = require(path.join(__dirname, "62-authorized-sclera-evidence-export.js"));
const RUNNER = require(path.join(__dirname, "62-private-evidence-runner.js"));

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

function acceptedReview(targetPresent) {
  return {
    target_present: targetPresent,
    mask_coverage: targetPresent ? 4 : 1,
    protected_leakage: false,
    naturalness: 4,
    structure_changed: false,
    decision: "accept",
    reason_code: "none",
  };
}

function localManifest() {
  return {
    schema_version: 1,
    fixtures: [
      {
        fixture_id: "sclera_fixture_001",
        feature: "sclera_redness",
        polarity: "positive",
        expected_target_present: true,
        rights_status: "approved_internal_evaluation",
        rights_record_id: "approved_sclera_001",
        assets: {
          original: "fixture_001/original.png",
          mask: "fixture_001/mask.png",
          after: "fixture_001/after.png",
        },
        review: acceptedReview(true),
      },
      {
        fixture_id: "sclera_fixture_002",
        feature: "sclera_redness",
        polarity: "negative",
        expected_target_present: false,
        rights_status: "approved_internal_evaluation",
        rights_record_id: "approved_sclera_002",
        assets: {
          original: "fixture_002/original.png",
          mask: "fixture_002/mask.png",
          after: "fixture_002/after.png",
        },
        review: acceptedReview(false),
      },
    ],
  };
}

function withTemporaryBundle(callback) {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "phase62-contract-"));
  try {
    for (const fixture of ["fixture_001", "fixture_002"]) {
      fs.mkdirSync(path.join(directory, fixture));
      for (const asset of ["original.png", "mask.png", "after.png"]) {
        fs.writeFileSync(path.join(directory, fixture, asset), Buffer.from([1, 2, 3]));
      }
    }
    const manifest = localManifest();
    fs.writeFileSync(path.join(directory, "manifest.json"), JSON.stringify(manifest));
    return callback(directory, manifest);
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
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

test("private locator keys reject absolute, traversal, platform, drive, and NUL forms", () => {
  assert.equal(RUNNER.safeRelativeKey("fixture_001/original.png"), true);
  assert.equal(ADAPTER.safeRelativeKey("fixture_002/after.png"), true);
  for (const value of [
    "/private/original.png", "../original.png", "fixture/../original.png",
    "fixture\\original.png", "C:/original.png", "fixture/\0original.png", "./original.png",
  ]) {
    assert.equal(RUNNER.safeRelativeKey(value), false, value);
    assert.equal(ADAPTER.safeRelativeKey(value), false, value);
  }
});

test("discovery shape requires two distinct sclera identities and both polarities", () => {
  const valid = localManifest();
  assert.equal(RUNNER.manifestShape(valid), true);
  const mutations = [
    (value) => { value.fixtures[0].feature = "teeth_whitening"; },
    (value) => { value.fixtures[1].fixture_id = value.fixtures[0].fixture_id; },
    (value) => { value.fixtures[1].polarity = "positive"; },
    (value) => { value.fixtures.pop(); },
  ];
  for (const mutate of mutations) {
    const candidate = structuredClone(valid);
    mutate(candidate);
    assert.equal(RUNNER.manifestShape(candidate), false);
  }
});

test("local fixed review rejects extra prose, invalid scores, leakage, and target drift", () => {
  assert.doesNotThrow(() => ADAPTER.validateReview(acceptedReview(true), true));
  const mutations = [
    (value) => { value[["review", "er_note"].join("")] = "not durable"; },
    (value) => { value.mask_coverage = 0; },
    (value) => { value.naturalness = 6; },
    (value) => { value.protected_leakage = true; },
    (value) => { value.target_present = false; },
  ];
  for (const mutate of mutations) {
    const candidate = acceptedReview(true);
    mutate(candidate);
    assert.throws(() => ADAPTER.validateReview(candidate, true));
  }
});

test("adapter rejects mechanics-only, incomplete, wrong-rights, and linked inputs without ledger writes", () => {
  const canonicalBefore = fs.readFileSync(LEDGER_PATH);
  withTemporaryBundle((directory, manifest) => {
    const mechanics = structuredClone(manifest);
    mechanics.fixtures[0].evidence_role = "mechanics_only";
    fs.writeFileSync(path.join(directory, "manifest.json"), JSON.stringify(mechanics));
    assert.throws(() => ADAPTER.loadCanonicalInput(directory), /local_manifest_fixture_invalid/);

    const wrongRights = structuredClone(manifest);
    wrongRights.fixtures[0].rights_status = "unknown";
    fs.writeFileSync(path.join(directory, "manifest.json"), JSON.stringify(wrongRights));
    assert.throws(() => ADAPTER.loadCanonicalInput(directory), /local_manifest_fixture_invalid/);

    fs.writeFileSync(path.join(directory, "manifest.json"), JSON.stringify(manifest));
    fs.rmSync(path.join(directory, "fixture_001", "mask.png"));
    assert.throws(() => ADAPTER.loadCanonicalInput(directory), /local_asset_missing/);
    fs.symlinkSync("after.png", path.join(directory, "fixture_001", "mask.png"));
    assert.throws(() => ADAPTER.loadCanonicalInput(directory), /local_asset_missing/);
  });
  assert.deepEqual(fs.readFileSync(LEDGER_PATH), canonicalBefore);
});

test("bounded nofollow reader rejects symlinks, empty files, and over-limit files", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "phase62-bounds-"));
  try {
    const regular = path.join(directory, "regular.bin");
    const empty = path.join(directory, "empty.bin");
    const linked = path.join(directory, "linked.bin");
    fs.writeFileSync(regular, Buffer.from([1, 2, 3]));
    fs.writeFileSync(empty, Buffer.alloc(0));
    fs.symlinkSync("regular.bin", linked);
    assert.deepEqual(RUNNER.readBoundedRegular(regular, 3), Buffer.from([1, 2, 3]));
    assert.throws(() => RUNNER.readBoundedRegular(regular, 2));
    assert.throws(() => RUNNER.readBoundedRegular(empty, 3));
    assert.throws(() => RUNNER.readBoundedRegular(linked, 3));
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
});

test("privacy classifier rejects local locator, reviewer prose, and in-memory digest", () => {
  const locator = ["/Us", "ers/test/", "Down", "loads/private-sclera.png"].join("");
  const prose = ["review", "er_note"].join("") + ": private judgment";
  const digest = "d".repeat(64);
  assert.equal(RUNNER.containsSensitiveContent(locator, "PLANS.md"), true);
  assert.equal(RUNNER.containsSensitiveContent(prose, "PLANS.md"), true);
  assert.equal(RUNNER.containsSensitiveContent(`opaque ${digest}`, "PLANS.md", new Set([digest])), true);
  assert.equal(RUNNER.containsSensitiveContent("aggregate-only closed evidence policy", "PLANS.md"), false);
});

test("NUL inventories and candidate selection fail on malformed or ambiguous input", () => {
  assert.deepEqual(RUNNER.parseNulInventory(Buffer.from("one/manifest.json\0two/file.png\0")), [
    "one/manifest.json", "two/file.png",
  ]);
  for (const inventory of ["one\0two", "one\0one\0", "../one\0", "one\\two\0"]) {
    assert.throws(() => RUNNER.parseNulInventory(inventory));
  }
  assert.equal(RUNNER.selectSingleCandidate(["one"]), "one");
  assert.throws(() => RUNNER.selectSingleCandidate([]), /missing/);
  assert.throws(() => RUNNER.selectSingleCandidate(["one", "two"]), /ambiguous/);
});

test("child classification rejects execution errors, nonzero status, and private output", () => {
  assert.doesNotThrow(() => RUNNER.classifyChildResult({ status: 0, stdout: "fixed", stderr: "" }));
  assert.throws(() => RUNNER.classifyChildResult({ status: 1, stdout: "", stderr: "" }));
  assert.throws(() => RUNNER.classifyChildResult({ status: 0, stdout: "", stderr: "", error: new Error("spawn") }));
  assert.throws(() => RUNNER.classifyChildResult(
    { status: 0, stdout: "private-value", stderr: "" },
    ["private-value"],
  ));
});

test("structured privacy seeds and runner self-test reject all private schema mutations", () => {
  for (const pieces of [
    ["source", "_path"], ["asset", "_digest"], ["rights", "_detail"],
    ["reviewer", "_identity"], ["raw", "_support"], ["raw", "_mask"],
    ["pixel", "_geometry"], ["raw", "_metric"], ["raw", "_error"],
  ]) {
    assert.equal(RUNNER.containsSensitiveContent(`${pieces.join("")}: private`, "active.json"), true);
  }
  const result = spawnSync(process.execPath, [
    path.join(__dirname, "62-private-evidence-runner.js"), "--self-test",
  ], { cwd: ROOT, encoding: "utf8" });
  assert.equal(result.status, 0);
  assert.equal(result.stderr, "");
  assert.deepEqual(JSON.parse(result.stdout), { status: "pass", mutation_rejections: 16 });
});

test("closed privacy command returns only fixed aggregate output without a bundle", () => {
  const result = spawnSync(process.execPath, [
    path.join(__dirname, "62-private-evidence-runner.js"), "--scan-tracked-staged", "--closed",
  ], { cwd: ROOT, encoding: "utf8" });
  assert.equal(result.status, 0);
  assert.equal(result.stderr, "");
  const output = JSON.parse(result.stdout);
  assert.deepEqual(Object.keys(output).sort(), ["status", "tracked_file_count"]);
  assert.equal(output.status, "pass");
  assert.ok(Number.isInteger(output.tracked_file_count) && output.tracked_file_count > 0);
});
