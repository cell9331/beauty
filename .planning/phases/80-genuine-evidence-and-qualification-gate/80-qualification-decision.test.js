#!/usr/bin/env node
"use strict";

const assert = require("node:assert/strict");
const childProcess = require("node:child_process");
const crypto = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const test = require("node:test");

const modulePath = path.join(__dirname, "80-qualification-decision.js");
const gate = require(modulePath);

const CATEGORIES = [
  "genuine-positive",
  "genuine-negative",
  "ambiguity",
  "pose-occlusion",
  "identity-diversity",
  "protected-structure",
];

function hash(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function temporaryRoot() {
  return fs.mkdtempSync(path.join(os.tmpdir(), "beauty-phase80-mechanics-"));
}

function writePrivate(root, relative, bytes) {
  const target = path.join(root, relative);
  fs.mkdirSync(path.dirname(target), { recursive: true, mode: 0o700 });
  fs.writeFileSync(target, bytes, { mode: 0o600 });
  fs.chmodSync(target, 0o600);
  return target;
}

function assetRecord(role, locator, bytes) {
  return {
    role,
    relative_locator: locator,
    sha256: hash(bytes),
    byte_length: bytes.length,
  };
}

function mechanicsBundle(overrides = {}) {
  return {
    schema_version: 1,
    admission_mode: "mechanics-only",
    feature_id: "upper-eyelid-fullness-reduction",
    origin: "mechanics-only",
    owner_provenance_version: "mechanics-v1",
    fixtures: [],
    metric_matrix: [],
    bindings: {},
    ...overrides,
  };
}

function metricRow(overrides = {}) {
  return {
    fixture_id: "mechanics_row",
    category: "genuine-positive",
    efficacy: 0.08,
    containment: 0,
    texture_high_frequency_retention: 0.96,
    geometry_protected_structures: 0.02,
    metadata_integrity: 1,
    no_op: 0,
    deterministic_repeatability: 1,
    alpha_exact: 1,
    extent_exact: 1,
    rejected_source_exact: 1,
    color_target_region_nonempty: true,
    color_protected_region_nonempty: true,
    color_target_max_abs_channel_delta_srgb8: 16,
    color_protected_max_abs_channel_delta_srgb8: 0,
    ...overrides,
  };
}

function invalidReview(overrides = {}) {
  return {
    schema_version: 1,
    feature_id: "upper-eyelid-fullness-reduction",
    complete: false,
    rubric_frozen_before_outcomes: false,
    blindness_attested: false,
    candidate_identity_hidden: false,
    locator_hidden: false,
    detail_scale_percent: 50,
    phase75_semantic_contract_hash: "0".repeat(64),
    phase75_evidence_contract_hash: "0".repeat(64),
    phase75_review_rubric_hash: "0".repeat(64),
    judgments: [],
    ...overrides,
  };
}

test("canonical JSON is byte-identical across object and schema-array permutations", () => {
  const first = {
    metric_matrix: [
      { fixture_id: "b", category: "pose-occlusion", value: 2 },
      { fixture_id: "a", category: "genuine-positive", value: 1 },
    ],
    nested: { z: true, a: 1 },
  };
  const second = {
    nested: { a: 1, z: true },
    metric_matrix: [...first.metric_matrix].reverse(),
  };
  assert.equal(gate.canonicalJson(first), gate.canonicalJson(second));
  assert.equal(gate.canonicalHash(first), gate.canonicalHash(second));
});

test("private JSON rejects BOM, duplicate keys, non-UTF8, oversize, and non-finite values", () => {
  const root = temporaryRoot();
  try {
    const cases = [
      ["bom.json", Buffer.from("\ufeff{}")],
      ["duplicate.json", Buffer.from('{"a":1,"a":2}')],
      ["utf8.json", Buffer.from([0xc3, 0x28])],
      ["nonfinite.json", Buffer.from('{"value":1e999}')],
      ["oversize.json", Buffer.alloc(gate.MAX_PRIVATE_JSON_BYTES + 1, 0x20)],
    ];
    for (const [name, bytes] of cases) {
      const file = writePrivate(root, name, bytes);
      assert.throws(() => gate.readPrivateJson(file), /^(?!.*beauty-phase80)/);
    }
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("bundle null, empty, zero-fixture, and single-fixture inputs fail closed", () => {
  const probes = [
    null,
    {},
    mechanicsBundle(),
    mechanicsBundle({ fixtures: [{ fixture_id: "one" }] }),
  ];
  for (const probe of probes) {
    const result = gate.validateBundle(probe);
    assert.equal(result.valid, false);
    assert.notEqual(result.reasons.length, 0);
  }
});

test("generated, AI-generated, and mechanics-only origins retain evidence weight zero", () => {
  for (const origin of ["generated", "ai-generated", "mechanics-only"]) {
    const result = gate.validateBundle(mechanicsBundle({ origin }));
    assert.equal(result.valid, false);
    assert.equal(result.generated_evidence_weight, 0);
    assert.ok(result.reasons.includes("evidence.mechanics-only"));
  }
});

test("bundle rejects near-match categories, duplicate categories, polarity mismatch, and borrowed rows", () => {
  const fixture = {
    feature_id: "upper-eyelid-fullness-reduction",
    fixture_id: "invalid_fixture",
    polarity: "positive",
    origin: "genuine-captured",
    rights_status: "rejected",
    rights_record_present: false,
    owner_provenance_version: "owner-v1",
    content_hash: "1".repeat(64),
    categories: ["genuine-positive", "genuine-positive", "pose_occlusion"],
    assets: [],
  };
  const result = gate.validateBundle(mechanicsBundle({
    admission_mode: "genuine-private",
    origin: "genuine-captured",
    fixtures: [fixture, { ...fixture, fixture_id: "duplicate_hash" }],
    metric_matrix: [metricRow({ fixture_id: "invalid_fixture", category: "genuine-negative" })],
  }));
  assert.equal(result.valid, false);
  assert.ok(result.reasons.includes("evidence.duplicate"));
  assert.ok(result.reasons.includes("evidence.incomplete-taxonomy"));
  assert.ok(result.reasons.includes("evidence.rights-failure"));
});

test("asset admission accepts a bounded regular descriptor with matching digest", () => {
  const root = temporaryRoot();
  try {
    const bytes = Buffer.from("mechanics-only-byte-fixture");
    writePrivate(root, "assets/original.bin", bytes);
    const admitted = gate.admitAssetFile(
      root,
      assetRecord("original", "assets/original.bin", bytes),
    );
    assert.deepEqual(admitted, { byte_length: bytes.length, sha256: hash(bytes) });
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("asset admission rejects traversal, absolute, backslash, NUL, and malformed locators without echo", () => {
  const root = temporaryRoot();
  try {
    const bytes = Buffer.from("x");
    for (const locator of ["../secret", "/absolute", "folder\\file", "nul\0file", "a/../b", "./file"]) {
      assert.throws(
        () => gate.admitAssetFile(root, assetRecord("original", locator, bytes)),
        (error) => error.code === "evidence.asset-invalid" && !error.message.includes(locator),
      );
    }
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("asset admission rejects parent and leaf symlinks, non-regular files, size, and digest mismatch", () => {
  const root = temporaryRoot();
  try {
    const bytes = Buffer.from("mechanics-byte");
    writePrivate(root, "real/file.bin", bytes);
    fs.symlinkSync(path.join(root, "real"), path.join(root, "linked-parent"));
    fs.symlinkSync(path.join(root, "real/file.bin"), path.join(root, "leaf-link"));
    fs.mkdirSync(path.join(root, "directory"));
    const cases = [
      assetRecord("original", "linked-parent/file.bin", bytes),
      assetRecord("original", "leaf-link", bytes),
      { ...assetRecord("original", "directory", bytes), byte_length: 1 },
      { ...assetRecord("original", "real/file.bin", bytes), byte_length: bytes.length + 1 },
      { ...assetRecord("original", "real/file.bin", bytes), sha256: "0".repeat(64) },
    ];
    for (const record of cases) {
      assert.throws(() => gate.admitAssetFile(root, record), /evidence\.asset-invalid/);
    }
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("descriptor stability guard rejects identity, size, and modification changes", () => {
  const stable = { dev: 1, ino: 2, size: 3, mtimeNs: 4n, ctimeNs: 5n };
  assert.equal(gate.descriptorStable(stable, { ...stable }), true);
  for (const changed of [
    { ...stable, ino: 3 },
    { ...stable, size: 4 },
    { ...stable, mtimeNs: 6n },
    { ...stable, ctimeNs: 7n },
  ]) {
    assert.equal(gate.descriptorStable(stable, changed), false);
  }
});

test("minimum, maximum, and exact scalar comparisons pass equality and reject beyond tolerance", () => {
  assert.equal(gate.compareMetric(0.08, "minimum", 0.1, 0.02), true);
  assert.equal(gate.compareMetric(0.079, "minimum", 0.1, 0.02), false);
  assert.equal(gate.compareMetric(0.02, "maximum", 0.01, 0.01), true);
  assert.equal(gate.compareMetric(0.021, "maximum", 0.01, 0.01), false);
  assert.equal(gate.compareMetric(1, "exact", 1, 0), true);
  assert.equal(gate.compareMetric(0.999, "exact", 1, 0), false);
});

test("color target equality 16 passes and 17 fails with only target-bound reason", () => {
  const pass = gate.evaluateMetricMatrix([metricRow()], [{ fixture_id: "mechanics_row", categories: ["genuine-positive"] }]);
  assert.equal(pass.reasons.includes("qualification.color.target-bound"), false);
  const fail = gate.evaluateMetricMatrix([metricRow({ color_target_max_abs_channel_delta_srgb8: 17 })], [{ fixture_id: "mechanics_row", categories: ["genuine-positive"] }]);
  assert.deepEqual(fail.reasons.filter((value) => value.startsWith("qualification.color.")), ["qualification.color.target-bound"]);
});

test("color protected equality 0 passes and 1 fails with only protected-bound reason", () => {
  const pass = gate.evaluateMetricMatrix([metricRow()], [{ fixture_id: "mechanics_row", categories: ["genuine-positive"] }]);
  assert.equal(pass.reasons.includes("qualification.color.protected-bound"), false);
  const fail = gate.evaluateMetricMatrix([metricRow({ color_protected_max_abs_channel_delta_srgb8: 1 })], [{ fixture_id: "mechanics_row", categories: ["genuine-positive"] }]);
  assert.deepEqual(fail.reasons.filter((value) => value.startsWith("qualification.color.")), ["qualification.color.protected-bound"]);
});

test("color missing, empty, fractional, out-of-range, and non-finite inputs normalize to invalid", () => {
  const probes = [
    { color_target_max_abs_channel_delta_srgb8: undefined },
    { color_target_region_nonempty: false },
    { color_protected_region_nonempty: false },
    { color_target_max_abs_channel_delta_srgb8: 1.5 },
    { color_protected_max_abs_channel_delta_srgb8: 256 },
    { color_target_max_abs_channel_delta_srgb8: Number.POSITIVE_INFINITY },
  ];
  for (const overrides of probes) {
    const row = metricRow(overrides);
    if (overrides.color_target_max_abs_channel_delta_srgb8 === undefined) {
      delete row.color_target_max_abs_channel_delta_srgb8;
    }
    const result = gate.evaluateMetricMatrix([row], [{ fixture_id: "mechanics_row", categories: ["genuine-positive"] }]);
    assert.deepEqual(result.reasons.filter((value) => value.startsWith("qualification.color.")), ["qualification.color.invalid"]);
  }
});

test("metric rows cannot lend success to another fixture or category", () => {
  const fixtures = [
    { fixture_id: "a", categories: ["genuine-positive", "identity-diversity"] },
    { fixture_id: "b", categories: ["genuine-negative"] },
  ];
  const rows = [
    metricRow({ fixture_id: "a", category: "genuine-positive" }),
    metricRow({ fixture_id: "a", category: "identity-diversity", containment: 1 }),
    metricRow({ fixture_id: "b", category: "genuine-negative" }),
  ];
  const result = gate.evaluateMetricMatrix(rows, fixtures);
  assert.equal(result.passing_metric_row_count, 2);
  assert.ok(result.reasons.includes("qualification.metric.maximum-bound"));
});

test("duplicate, missing, extra, and undeclared metric rows are rejected before aggregation", () => {
  const fixtures = [{ fixture_id: "a", categories: ["genuine-positive"] }];
  for (const rows of [
    [metricRow({ fixture_id: "a" }), metricRow({ fixture_id: "a" })],
    [],
    [metricRow({ fixture_id: "a" }), metricRow({ fixture_id: "b" })],
  ]) {
    const result = gate.evaluateMetricMatrix(rows, fixtures);
    assert.equal(result.valid, false);
    assert.ok(result.reasons.includes("qualification.metric.invalid"));
  }
});

test("aggregate color output contains only row count and two scalar maxima", () => {
  const result = gate.evaluateMetricMatrix(
    [metricRow({ fixture_id: "b", color_target_max_abs_channel_delta_srgb8: 3 }), metricRow({ fixture_id: "a", color_target_max_abs_channel_delta_srgb8: 16 })],
    [{ fixture_id: "a", categories: ["genuine-positive"] }, { fixture_id: "b", categories: ["genuine-positive"] }],
  );
  assert.deepEqual(
    Object.keys(result.aggregate_metrics).filter((key) => key.startsWith("color_")),
    ["color_row_count", "color_target_max_abs_channel_delta_srgb8", "color_protected_max_abs_channel_delta_srgb8"],
  );
  assert.equal(result.aggregate_metrics.color_target_max_abs_channel_delta_srgb8, 16);
  assert.doesNotMatch(JSON.stringify(result.aggregate_metrics), /pixel|mask|region/i);
});

test("review rejects incomplete, post-outcome, unblinded, non-100-detail, and binding-invalid records", () => {
  const fixtures = [{ fixture_id: "a", categories: ["genuine-positive"] }];
  const result = gate.validateReview(invalidReview(), fixtures);
  assert.equal(result.valid, false);
  assert.ok(result.reasons.includes("review.incomplete"));
  assert.ok(result.reasons.includes("review.binding"));
});

test("review rejects duplicate, missing, extra, category-borrowed, prose, and identity-bearing judgments", () => {
  const fixtures = [{ fixture_id: "a", categories: ["genuine-positive"] }];
  const badJudgment = {
    fixture_id: "a",
    category: "genuine-negative",
    target_fullness_reduced: true,
    prohibited_proxy_absent: true,
    protected_structures_preserved: true,
    original_detail_natural: true,
    review_decision: "pass",
    reason_code: null,
    reviewer_identity: "forbidden",
    prose: "forbidden",
  };
  const result = gate.validateReview(invalidReview({ judgments: [badJudgment, badJudgment] }), fixtures);
  assert.equal(result.valid, false);
  assert.ok(result.reasons.includes("review.malformed"));
});

test("review threshold equality 1.0 passes scalar comparison and below 1.0 fails", () => {
  assert.equal(gate.compareMetric(1, "minimum", 1, 0), true);
  assert.equal(gate.compareMetric(0.999, "minimum", 1, 0), false);
});

test("output allowlist rejects sensitive keys, path-like values, timestamps, prose, and row data", () => {
  const base = gate.failureDecision(["evidence.missing-bundle"]);
  assert.equal(gate.outputIsSafe(base), true);
  for (const mutation of [
    { ...base, private_locator: "opaque" },
    { ...base, note: "freeform prose" },
    { ...base, timestamp: "2026-01-01" },
    { ...base, fixture_ids: ["folder/file"] },
    { ...base, aggregate_metrics: { ...base.aggregate_metrics, pixels: [1] } },
  ]) {
    assert.equal(gate.outputIsSafe(mutation), false);
  }
});

test("missing external inputs produce deterministic sanitized non-promotion and nonzero CLI status", () => {
  const repoRoot = path.resolve(__dirname, "../../..");
  const args = [modulePath, "--decision", "--repo-root", "."];
  const env = { ...process.env };
  delete env.BEAUTY_PHASE80_BUNDLE_MANIFEST;
  delete env.BEAUTY_PHASE80_REVIEW_RECORD;
  const first = childProcess.spawnSync(process.execPath, args, { encoding: "utf8", env, cwd: repoRoot });
  const second = childProcess.spawnSync(process.execPath, args, { encoding: "utf8", env, cwd: repoRoot });
  assert.notEqual(first.status, 0);
  assert.equal(first.stdout, second.stdout);
  const report = JSON.parse(first.stdout);
  assert.equal(report.decision, "qualification-not-passed");
  assert.deepEqual(report.reason_counts, { "evidence.missing-bundle": 1, "review.missing": 1 });
  assert.equal(gate.outputIsSafe(report), true);
});

test("CLI accepts only fixed flags and never accepts a private locator argument", () => {
  for (const args of [
    ["--bundle", "/private/input"],
    ["--review", "/private/review"],
    ["--decision", "--repo-root", ".", "extra"],
  ]) {
    const child = childProcess.spawnSync(process.execPath, [modulePath, ...args], { encoding: "utf8" });
    assert.notEqual(child.status, 0);
    assert.doesNotMatch(child.stdout + child.stderr, /\/private\/input|\/private\/review/);
  }
});

test("malformed review environment input normalizes to review.malformed without locator disclosure", () => {
  const repoRoot = path.resolve(__dirname, "../../..");
  const root = temporaryRoot();
  try {
    const malformed = writePrivate(root, "private-review.json", Buffer.from('{"broken":'));
    const child = childProcess.spawnSync(
      process.execPath,
      [modulePath, "--decision", "--repo-root", "."],
      {
        cwd: repoRoot,
        encoding: "utf8",
        env: { ...process.env, BEAUTY_PHASE80_REVIEW_RECORD: malformed },
      },
    );
    assert.notEqual(child.status, 0);
    const report = JSON.parse(child.stdout);
    assert.deepEqual(report.reason_counts, { "review.malformed": 1 });
    assert.doesNotMatch(child.stdout + child.stderr, /private-review|beauty-phase80-mechanics/);
  } finally {
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test("invalid external input cannot replace an existing decision artifact", () => {
  const repoRoot = path.resolve(__dirname, "../../..");
  const decisionPath = path.join(__dirname, "80-QUALIFICATION-DECISION.json");
  const sentinel = Buffer.from('{"sentinel":true}\n');
  fs.writeFileSync(decisionPath, sentinel, { mode: 0o600 });
  try {
    const child = childProcess.spawnSync(process.execPath, [modulePath, "--write-decision", "--repo-root", "."], {
      encoding: "utf8",
      cwd: repoRoot,
      env: { ...process.env, BEAUTY_PHASE80_BUNDLE_MANIFEST: "", BEAUTY_PHASE80_REVIEW_RECORD: "" },
    });
    assert.notEqual(child.status, 0);
    assert.deepEqual(fs.readFileSync(decisionPath), sentinel);
  } finally {
    fs.rmSync(decisionPath, { force: true });
  }
});

test("mechanics-only decision is deterministic and can never reach promotion constant", () => {
  const first = gate.buildDecision({ bundle: mechanicsBundle(), review: invalidReview(), repoRoot: path.resolve(__dirname, "../../..") });
  const second = gate.buildDecision({ bundle: mechanicsBundle(), review: invalidReview(), repoRoot: path.resolve(__dirname, "../../..") });
  assert.deepEqual(first, second);
  assert.equal(first.report.aggregate_metrics.generated_evidence_weight, 0);
  assert.notEqual(first.report.decision, "promotion-ready-deterministic-editor");
  assert.equal(first.inputComplete, false);
});

test("decision bindings fail closed under semantic, evidence, rubric, baseline, and public-absence mutation", () => {
  const repoRoot = path.resolve(__dirname, "../../..");
  for (const mutation of ["semantic", "evidence", "rubric", "source", "public"]) {
    const result = gate.verifyBindings(repoRoot, { mutation });
    assert.equal(result.valid, false);
    assert.ok(result.reasons.some((reason) => reason.startsWith("qualification.")));
  }
});

test("self-test reports only aggregate non-promotion mechanics", () => {
  const repoRoot = path.resolve(__dirname, "../../..");
  const child = childProcess.spawnSync(
    process.execPath,
    [modulePath, "--self-test", "--repo-root", "."],
    { encoding: "utf8", cwd: repoRoot },
  );
  assert.equal(child.status, 0);
  const report = JSON.parse(child.stdout);
  assert.equal(report.status, "pass");
  assert.equal(report.decision, "qualification-not-passed");
  assert.equal(report.promotion_fixture_count, 0);
  assert.equal(gate.outputIsSafe(report), true);
});
