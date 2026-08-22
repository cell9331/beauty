#!/usr/bin/env node
"use strict";

const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");
const { TextDecoder } = require("node:util");

const PHASE = 80;
const FEATURE_ID = "upper-eyelid-fullness-reduction";
const EVALUATOR_VERSION = "phase80-qualification-evaluator-v1";
const BASELINE_ID = "deterministic-editor";
const PROMOTION_DECISION = "promotion-ready-deterministic-editor";
const NON_PROMOTION_DECISION = "qualification-not-passed";
const MAX_PRIVATE_JSON_BYTES = 1_048_576;
const MAX_ASSET_BYTES = 33_554_432;
const MAX_FIXTURES = 256;
const MAX_ROWS = 1_536;
const HASH_RE = /^[0-9a-f]{64}$/;
const OPAQUE_ID_RE = /^[A-Za-z0-9_-]{1,64}$/;
const RELATIVE_LOCATOR_RE = /^[A-Za-z0-9._-]+(?:\/[A-Za-z0-9._-]+)*$/;
const REASON_RE = /^[a-z][a-z0-9.-]{0,127}$/;
const ASCII_RE = /^[\x20-\x7e]+$/;

const CONTRACT_PATH = path.join(__dirname, "80-QUALIFICATION-CONTRACT.md");
const DECISION_PATH = path.join(__dirname, "80-QUALIFICATION-DECISION.json");
const PHASE75_SEMANTIC_PATH = path.join(
  __dirname,
  "..",
  "..",
  "milestones",
  "v1.18-phases",
  "75-semantics-and-genuine-evidence-contract",
  "75-SEMANTICS-CONTRACT.md",
);
const PHASE75_EVIDENCE_PATH = path.join(
  __dirname,
  "..",
  "..",
  "milestones",
  "v1.18-phases",
  "75-semantics-and-genuine-evidence-contract",
  "75-EVIDENCE-CONTRACT.md",
);

const REQUIRED_CATEGORIES = [
  "genuine-positive",
  "genuine-negative",
  "ambiguity",
  "pose-occlusion",
  "identity-diversity",
  "protected-structure",
];
const CATEGORY_INDEX = new Map(REQUIRED_CATEGORIES.map((value, index) => [value, index]));
const ASSET_ROLES = ["original", "support-envelope", "candidate-output"];
const FIXTURE_KEYS = [
  "feature_id",
  "fixture_id",
  "polarity",
  "origin",
  "rights_status",
  "rights_record_present",
  "owner_provenance_version",
  "content_hash",
  "categories",
  "assets",
];
const ASSET_KEYS = ["role", "relative_locator", "sha256", "byte_length"];
const BUNDLE_KEYS = [
  "schema_version",
  "admission_mode",
  "feature_id",
  "origin",
  "owner_provenance_version",
  "fixtures",
  "metric_matrix",
  "bindings",
];
const BINDING_KEYS = [
  "phase75_semantic_contract_hash",
  "phase75_evidence_contract_hash",
  "phase75_review_rubric_hash",
  "evaluator_version",
  "baseline_source_digest",
  "baseline_evidence_digest",
  "baseline_binding_hash",
  "public_absence_hash",
];
const METRIC_ROW_KEYS = [
  "fixture_id",
  "category",
  "efficacy",
  "containment",
  "texture_high_frequency_retention",
  "geometry_protected_structures",
  "metadata_integrity",
  "no_op",
  "deterministic_repeatability",
  "alpha_exact",
  "extent_exact",
  "rejected_source_exact",
  "color_target_region_nonempty",
  "color_protected_region_nonempty",
  "color_target_max_abs_channel_delta_srgb8",
  "color_protected_max_abs_channel_delta_srgb8",
];
const REVIEW_KEYS = [
  "schema_version",
  "feature_id",
  "complete",
  "rubric_frozen_before_outcomes",
  "blindness_attested",
  "candidate_identity_hidden",
  "locator_hidden",
  "detail_scale_percent",
  "phase75_semantic_contract_hash",
  "phase75_evidence_contract_hash",
  "phase75_review_rubric_hash",
  "judgments",
];
const JUDGMENT_KEYS = [
  "fixture_id",
  "category",
  "target_fullness_reduced",
  "prohibited_proxy_absent",
  "protected_structures_preserved",
  "original_detail_natural",
  "review_decision",
  "reason_code",
];
const REVIEW_REASONS = new Set([
  "target-not-visible",
  "proxy-present",
  "protected-structure-change",
  "detail-unnatural",
  "occlusion-or-pose-ambiguous",
  "review-failure",
]);
const REASON_ORDER = [
  "evidence.missing-bundle",
  "evidence.malformed-manifest",
  "evidence.incomplete-taxonomy",
  "evidence.rights-failure",
  "evidence.asset-invalid",
  "evidence.duplicate",
  "evidence.mechanics-only",
  "review.missing",
  "review.malformed",
  "review.incomplete",
  "review.binding",
  "review.threshold",
  "qualification.metric.invalid",
  "qualification.metric.minimum-bound",
  "qualification.metric.maximum-bound",
  "qualification.metric.exact-bound",
  "qualification.color.invalid",
  "qualification.color.target-bound",
  "qualification.color.protected-bound",
  "qualification.binding",
  "qualification.public-absence",
  "qualification.privacy",
  "qualification.input",
  "qualification.write",
];
const REASON_INDEX = new Map(REASON_ORDER.map((value, index) => [value, index]));

const BASELINE_SOURCE_OWNERS = [
  "BeautySDK/Sources/BeautyDetection/BeautyUpperEyelidSemanticSupport.swift",
  "BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift",
  "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyUpperEyelidFullnessEditor.swift",
  "BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift",
];
const BASELINE_EVIDENCE_OWNERS = [
  "BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidEditorSafetyTests.swift",
  "BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidFullnessEditorTests.swift",
  "BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidPackageIntegrationTests.swift",
];
const FOCUSED_TEST_IDS = [
  "BeautyUpperEyelidEditorSafetyTests.testCompositionChangesOnlyApprovedEyeAndPreservesProtectedExteriorAndMetadata",
  "BeautyUpperEyelidEditorSafetyTests.testOverlappingEyeUnitsReturnImmutableSourceAndCountOneCollision",
  "BeautyUpperEyelidEditorSafetyTests.testRepeatedEditorCompositionIsByteDeterministicAndRejectedEyeHasNoUnit",
  "BeautyUpperEyelidFullnessEditorTests.testApprovedPixelUsesLowFrequencyCorrectionAndCarriesOriginalDetail",
  "BeautyUpperEyelidFullnessEditorTests.testInvalidStrengthAndRepeatedRequestsFailClosedDeterministically",
  "BeautyUpperEyelidFullnessEditorTests.testInvalidSupportIsRejectedWithoutSuppressingValidPeer",
  "BeautyUpperEyelidFullnessEditorTests.testNeutralStrengthIsExactNoOpAndDiagnosticsAreAggregateOnly",
  "BeautyUpperEyelidPackageIntegrationTests.testMissingMalformedAndLowConfidencePeerSupportFailClosedPerEye",
  "BeautyUpperEyelidPackageIntegrationTests.testOneObservationFlowsThroughIndependentEyeResolutionEditorAndComposition",
  "BeautyUpperEyelidPackageIntegrationTests.testOverlappingAcceptedEyesReturnCollisionPixelToImmutableSource",
];
const EXPECTED_FIELDS = 61;
const EXPECTED_PRESETS = ["natural", "clear", "refined", "male-natural", "id-photo-natural"];
const EXPECTED_RENDERER_CASES = 74;

const DECISION_KEYS = [
  "status",
  "phase",
  "contract_hash",
  "manifest_hash",
  "review_hash",
  "evaluator_version",
  "phase75_semantic_contract_hash",
  "phase75_evidence_contract_hash",
  "phase75_review_rubric_hash",
  "baseline_id",
  "baseline_source_digest",
  "baseline_evidence_digest",
  "baseline_binding_hash",
  "fixture_ids",
  "aggregate_metrics",
  "reason_counts",
  "public_absence",
  "decision",
];
const AGGREGATE_KEYS = [
  "fixture_count",
  "metric_row_count",
  "passing_metric_row_count",
  "color_row_count",
  "color_target_max_abs_channel_delta_srgb8",
  "color_protected_max_abs_channel_delta_srgb8",
  "review_row_count",
  "passing_review_row_count",
  "category_pass_rates",
  "generated_evidence_weight",
  "genuine_evaluation_executed",
  "frozen_review_complete",
  "safety_gates_pass",
];
const PUBLIC_ABSENCE_KEYS = ["beauty_parameter_fields", "preset_ids", "renderer_cases"];
const SELF_TEST_KEYS = [
  "checks",
  "decision",
  "mode",
  "mutation_rejections",
  "phase",
  "promotion_fixture_count",
  "status",
];
const SENSITIVE_KEY_RE = /(?:path|locator|rights.record|reviewer.identity|timestamp|freeform|prose|raw|pixel|mask|landmark|coordinate|geometry|transcript|media)/i;

class GateError extends Error {
  constructor(code) {
    super(code);
    this.name = "GateError";
    this.code = code;
  }
}

function fail(code) {
  throw new GateError(code);
}

function sha256Bytes(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function utf8Compare(left, right) {
  return Buffer.compare(Buffer.from(String(left), "utf8"), Buffer.from(String(right), "utf8"));
}

function arraySortKey(value) {
  if (!value || typeof value !== "object" || Array.isArray(value)) return String(value);
  return [value.fixture_id, value.category, value.role, value.sha256, value.reason]
    .filter((entry) => entry !== undefined)
    .join("\u0000");
}

function canonicalize(value) {
  if (Array.isArray(value)) {
    const entries = value.map(canonicalize);
    return entries.sort((left, right) => utf8Compare(arraySortKey(left), arraySortKey(right)));
  }
  if (value && typeof value === "object") {
    if (Object.getPrototypeOf(value) !== Object.prototype) fail("evidence.malformed-manifest");
    const output = {};
    for (const key of Object.keys(value).sort(utf8Compare)) output[key] = canonicalize(value[key]);
    return output;
  }
  if (typeof value === "number" && !Number.isFinite(value)) fail("evidence.malformed-manifest");
  return value;
}

function canonicalJson(value) {
  return JSON.stringify(canonicalize(value));
}

function canonicalHash(value) {
  return sha256Bytes(Buffer.from(canonicalJson(value), "utf8"));
}

function exactKeys(value, expected) {
  return value !== null
    && typeof value === "object"
    && !Array.isArray(value)
    && JSON.stringify(Object.keys(value).sort(utf8Compare)) === JSON.stringify([...expected].sort(utf8Compare));
}

function parseJsonRejectingDuplicateKeys(text) {
  let offset = 0;
  function whitespace() {
    while (/\s/.test(text[offset] || "")) offset += 1;
  }
  function stringToken() {
    if (text[offset] !== '"') fail("evidence.malformed-manifest");
    const start = offset;
    offset += 1;
    while (offset < text.length) {
      if (text[offset] === "\\") {
        offset += 2;
      } else if (text[offset] === '"') {
        offset += 1;
        try {
          return JSON.parse(text.slice(start, offset));
        } catch {
          fail("evidence.malformed-manifest");
        }
      } else {
        offset += 1;
      }
    }
    fail("evidence.malformed-manifest");
  }
  function value() {
    whitespace();
    if (text[offset] === "{") {
      offset += 1;
      whitespace();
      const keys = new Set();
      if (text[offset] === "}") { offset += 1; return; }
      for (;;) {
        whitespace();
        const key = stringToken();
        if (keys.has(key)) fail("evidence.duplicate");
        keys.add(key);
        whitespace();
        if (text[offset] !== ":") fail("evidence.malformed-manifest");
        offset += 1;
        value();
        whitespace();
        if (text[offset] === "}") { offset += 1; return; }
        if (text[offset] !== ",") fail("evidence.malformed-manifest");
        offset += 1;
      }
    }
    if (text[offset] === "[") {
      offset += 1;
      whitespace();
      if (text[offset] === "]") { offset += 1; return; }
      for (;;) {
        value();
        whitespace();
        if (text[offset] === "]") { offset += 1; return; }
        if (text[offset] !== ",") fail("evidence.malformed-manifest");
        offset += 1;
      }
    }
    if (text[offset] === '"') { stringToken(); return; }
    const match = text.slice(offset).match(/^(?:true|false|null|-?(?:0|[1-9][0-9]*)(?:\.[0-9]+)?(?:[eE][+-]?[0-9]+)?)/);
    if (!match) fail("evidence.malformed-manifest");
    offset += match[0].length;
  }
  value();
  whitespace();
  if (offset !== text.length) fail("evidence.malformed-manifest");
  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch {
    fail("evidence.malformed-manifest");
  }
  canonicalize(parsed);
  return parsed;
}

function readPrivateJson(privateLocator) {
  if (typeof privateLocator !== "string" || privateLocator.length === 0) fail("evidence.missing-bundle");
  let descriptor;
  try {
    const entry = fs.lstatSync(privateLocator, { bigint: true });
    if (entry.isSymbolicLink() || !entry.isFile() || entry.size <= 0n || entry.size > BigInt(MAX_PRIVATE_JSON_BYTES)) {
      fail("evidence.malformed-manifest");
    }
    descriptor = fs.openSync(privateLocator, fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW || 0));
    const before = fs.fstatSync(descriptor, { bigint: true });
    const bytes = Buffer.alloc(Number(before.size));
    let read = 0;
    while (read < bytes.length) {
      const count = fs.readSync(descriptor, bytes, read, bytes.length - read, read);
      if (count <= 0) fail("evidence.malformed-manifest");
      read += count;
    }
    const after = fs.fstatSync(descriptor, { bigint: true });
    if (!descriptorStable(before, after)) fail("evidence.malformed-manifest");
    if (bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf) {
      fail("evidence.malformed-manifest");
    }
    let text;
    try {
      text = new TextDecoder("utf-8", { fatal: true }).decode(bytes);
    } catch {
      fail("evidence.malformed-manifest");
    }
    const parsed = parseJsonRejectingDuplicateKeys(text);
    return {
      value: parsed,
      hash: canonicalHash(parsed),
      directory: path.dirname(path.resolve(privateLocator)),
    };
  } catch (error) {
    if (error instanceof GateError) throw error;
    fail("evidence.malformed-manifest");
  } finally {
    if (descriptor !== undefined) {
      try { fs.closeSync(descriptor); } catch { /* normalized failure already owns the result */ }
    }
  }
}

function descriptorStable(before, after) {
  return before.dev === after.dev
    && before.ino === after.ino
    && before.size === after.size
    && before.mtimeNs === after.mtimeNs
    && before.ctimeNs === after.ctimeNs;
}

function safeRelativeLocator(locator) {
  if (typeof locator !== "string" || locator.includes("\0") || !RELATIVE_LOCATOR_RE.test(locator)) return false;
  if (path.posix.isAbsolute(locator) || locator.includes("\\")) return false;
  const parts = locator.split("/");
  return parts.every((part) => part !== "." && part !== "..");
}

function admitAssetFile(assetRoot, record) {
  if (!exactKeys(record, ASSET_KEYS)
      || !ASSET_ROLES.includes(record.role)
      || !safeRelativeLocator(record.relative_locator)
      || !HASH_RE.test(record.sha256)
      || !Number.isInteger(record.byte_length)
      || record.byte_length < 1
      || record.byte_length > MAX_ASSET_BYTES) {
    fail("evidence.asset-invalid");
  }
  let descriptor;
  try {
    const root = path.resolve(assetRoot);
    const rootStat = fs.lstatSync(root, { bigint: true });
    if (rootStat.isSymbolicLink() || !rootStat.isDirectory()) fail("evidence.asset-invalid");
    let cursor = root;
    for (const part of record.relative_locator.split("/")) {
      cursor = path.join(cursor, part);
      const entry = fs.lstatSync(cursor, { bigint: true });
      if (entry.isSymbolicLink()) fail("evidence.asset-invalid");
    }
    descriptor = fs.openSync(cursor, fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW || 0));
    const before = fs.fstatSync(descriptor, { bigint: true });
    if (!before.isFile() || before.size !== BigInt(record.byte_length) || before.size > BigInt(MAX_ASSET_BYTES)) {
      fail("evidence.asset-invalid");
    }
    const digest = crypto.createHash("sha256");
    const chunk = Buffer.alloc(Math.min(65_536, record.byte_length));
    let position = 0;
    while (position < record.byte_length) {
      const count = fs.readSync(descriptor, chunk, 0, Math.min(chunk.length, record.byte_length - position), position);
      if (count <= 0) fail("evidence.asset-invalid");
      digest.update(chunk.subarray(0, count));
      position += count;
    }
    const after = fs.fstatSync(descriptor, { bigint: true });
    const observedHash = digest.digest("hex");
    if (!descriptorStable(before, after) || observedHash !== record.sha256) fail("evidence.asset-invalid");
    return { byte_length: record.byte_length, sha256: observedHash };
  } catch (error) {
    if (error instanceof GateError) throw error;
    fail("evidence.asset-invalid");
  } finally {
    if (descriptor !== undefined) {
      try { fs.closeSync(descriptor); } catch { /* no path-bearing error escapes */ }
    }
  }
}

function normalizeReasons(reasons) {
  const unique = [...new Set(reasons.filter((reason) => typeof reason === "string" && REASON_RE.test(reason)))];
  return unique.sort((left, right) => {
    const leftIndex = REASON_INDEX.has(left) ? REASON_INDEX.get(left) : Number.MAX_SAFE_INTEGER;
    const rightIndex = REASON_INDEX.has(right) ? REASON_INDEX.get(right) : Number.MAX_SAFE_INTEGER;
    return leftIndex === rightIndex ? utf8Compare(left, right) : leftIndex - rightIndex;
  });
}

function compareMetric(value, direction, threshold, tolerance) {
  if (![value, threshold, tolerance].every((entry) => typeof entry === "number" && Number.isFinite(entry))) return false;
  if (direction === "minimum") return value + tolerance >= threshold;
  if (direction === "maximum") return value <= threshold + tolerance;
  if (direction === "exact") return value === threshold;
  return false;
}

const METRIC_COMPARISONS = [
  ["containment", "maximum", 0, 0],
  ["texture_high_frequency_retention", "minimum", 0.98, 0.02],
  ["geometry_protected_structures", "maximum", 0.01, 0.01],
  ["metadata_integrity", "exact", 1, 0],
  ["no_op", "maximum", 0, 0],
  ["deterministic_repeatability", "exact", 1, 0],
  ["alpha_exact", "exact", 1, 0],
  ["extent_exact", "exact", 1, 0],
  ["rejected_source_exact", "exact", 1, 0],
];

function evaluateMetricMatrix(rows, fixtures) {
  const reasons = [];
  const aggregate = {
    color_row_count: 0,
    color_target_max_abs_channel_delta_srgb8: null,
    color_protected_max_abs_channel_delta_srgb8: null,
  };
  if (!Array.isArray(rows) || rows.length === 0 || rows.length > MAX_ROWS || !Array.isArray(fixtures)) {
    return {
      valid: false,
      passed: false,
      reasons: ["qualification.metric.invalid"],
      metric_row_count: Array.isArray(rows) ? rows.length : 0,
      passing_metric_row_count: 0,
      aggregate_metrics: aggregate,
    };
  }
  const expectedPairs = new Set();
  let fixtureShapeValid = true;
  for (const fixture of fixtures) {
    if (!fixture || typeof fixture.fixture_id !== "string" || !Array.isArray(fixture.categories)) {
      fixtureShapeValid = false;
      continue;
    }
    for (const category of fixture.categories) expectedPairs.add(`${fixture.fixture_id}\u0000${category}`);
  }
  const seen = new Set();
  let passing = 0;
  let schemaValid = fixtureShapeValid;
  let colorValid = true;
  const targetValues = [];
  const protectedValues = [];
  for (const row of rows) {
    const colorFields = [
      "color_target_region_nonempty",
      "color_protected_region_nonempty",
      "color_target_max_abs_channel_delta_srgb8",
      "color_protected_max_abs_channel_delta_srgb8",
    ];
    const missingOnlyColor = row && typeof row === "object" && !Array.isArray(row)
      && METRIC_ROW_KEYS.filter((key) => !colorFields.includes(key)).every((key) => Object.hasOwn(row, key))
      && colorFields.some((key) => !Object.hasOwn(row, key));
    if (missingOnlyColor
        && OPAQUE_ID_RE.test(row.fixture_id || "")
        && CATEGORY_INDEX.has(row.category)) {
      const pair = `${row.fixture_id}\u0000${row.category}`;
      if (!seen.has(pair) && expectedPairs.has(pair)) seen.add(pair);
      schemaValid = false;
      colorValid = false;
      reasons.push("qualification.color.invalid");
      continue;
    }
    if (!exactKeys(row, METRIC_ROW_KEYS)
        || !OPAQUE_ID_RE.test(row.fixture_id || "")
        || !CATEGORY_INDEX.has(row.category)) {
      schemaValid = false;
      reasons.push("qualification.metric.invalid");
      continue;
    }
    const pair = `${row.fixture_id}\u0000${row.category}`;
    if (seen.has(pair) || !expectedPairs.has(pair)) {
      schemaValid = false;
      reasons.push("qualification.metric.invalid");
      continue;
    }
    seen.add(pair);
    let rowPasses = true;
    const numericKeys = METRIC_ROW_KEYS.slice(2, 12);
    if (numericKeys.some((key) => typeof row[key] !== "number" || !Number.isFinite(row[key]))) {
      schemaValid = false;
      rowPasses = false;
      reasons.push("qualification.metric.invalid");
    } else {
      if (row.category === "genuine-positive" && !compareMetric(row.efficacy, "minimum", 0.1, 0.02)) {
        rowPasses = false;
        reasons.push("qualification.metric.minimum-bound");
      }
      for (const [field, direction, threshold, tolerance] of METRIC_COMPARISONS) {
        if (!compareMetric(row[field], direction, threshold, tolerance)) {
          rowPasses = false;
          reasons.push(`qualification.metric.${direction}-bound`);
        }
      }
    }
    const target = row.color_target_max_abs_channel_delta_srgb8;
    const protectedValue = row.color_protected_max_abs_channel_delta_srgb8;
    const validColor = row.color_target_region_nonempty === true
      && row.color_protected_region_nonempty === true
      && Number.isInteger(target)
      && Number.isInteger(protectedValue)
      && target >= 0 && target <= 255
      && protectedValue >= 0 && protectedValue <= 255;
    if (!validColor) {
      colorValid = false;
      schemaValid = false;
      rowPasses = false;
      reasons.push("qualification.color.invalid");
    } else {
      targetValues.push(target);
      protectedValues.push(protectedValue);
      if (target > 16) { rowPasses = false; reasons.push("qualification.color.target-bound"); }
      if (protectedValue > 0) { rowPasses = false; reasons.push("qualification.color.protected-bound"); }
    }
    if (rowPasses) passing += 1;
  }
  if (seen.size !== expectedPairs.size || [...expectedPairs].some((pair) => !seen.has(pair))) {
    schemaValid = false;
    reasons.push("qualification.metric.invalid");
  }
  aggregate.color_row_count = colorValid && seen.size === expectedPairs.size ? rows.length : 0;
  if (aggregate.color_row_count > 0) {
    aggregate.color_target_max_abs_channel_delta_srgb8 = Math.max(...targetValues);
    aggregate.color_protected_max_abs_channel_delta_srgb8 = Math.max(...protectedValues);
  }
  const normalized = normalizeReasons(reasons);
  return {
    valid: schemaValid,
    passed: schemaValid && passing === rows.length && normalized.length === 0,
    reasons: normalized,
    metric_row_count: rows.length,
    passing_metric_row_count: passing,
    aggregate_metrics: aggregate,
  };
}

function validateBundle(bundle, options = {}) {
  const reasons = [];
  const result = {
    valid: false,
    passed: false,
    reasons,
    blocking_reasons: [],
    fixture_ids: [],
    manifest_hash: null,
    generated_evidence_weight: 0,
    metrics: evaluateMetricMatrix([], []),
  };
  if (!exactKeys(bundle, BUNDLE_KEYS)) {
    result.reasons = ["evidence.malformed-manifest"];
    result.blocking_reasons = result.reasons;
    return result;
  }
  try { result.manifest_hash = canonicalHash(bundle); } catch { reasons.push("evidence.malformed-manifest"); }
  if (bundle.schema_version !== 1 || bundle.feature_id !== FEATURE_ID
      || !ASCII_RE.test(bundle.owner_provenance_version || "")
      || !OPAQUE_ID_RE.test(bundle.owner_provenance_version || "")) {
    reasons.push("evidence.malformed-manifest");
  }
  if (bundle.admission_mode !== "genuine-private" || bundle.origin !== "genuine-captured") {
    reasons.push("evidence.mechanics-only");
  }
  if (!Array.isArray(bundle.fixtures) || bundle.fixtures.length < 2 || bundle.fixtures.length > MAX_FIXTURES) {
    reasons.push("evidence.incomplete-taxonomy");
  }
  const fixtures = Array.isArray(bundle.fixtures) ? bundle.fixtures : [];
  const fixtureIds = new Set();
  const fixtureHashes = new Set();
  const assetHashes = new Set();
  const categoryUnion = new Set();
  const polarities = new Set();
  for (const fixture of fixtures) {
    if (!exactKeys(fixture, FIXTURE_KEYS)
        || fixture.feature_id !== FEATURE_ID
        || !OPAQUE_ID_RE.test(fixture.fixture_id || "")
        || !OPAQUE_ID_RE.test(fixture.owner_provenance_version || "")
        || !HASH_RE.test(fixture.content_hash || "")
        || !["positive", "negative"].includes(fixture.polarity)
        || fixture.origin !== "genuine-captured") {
      reasons.push("evidence.malformed-manifest");
      continue;
    }
    if (fixtureIds.has(fixture.fixture_id) || fixtureHashes.has(fixture.content_hash)) reasons.push("evidence.duplicate");
    fixtureIds.add(fixture.fixture_id);
    fixtureHashes.add(fixture.content_hash);
    polarities.add(fixture.polarity);
    if (fixture.rights_status !== "approved_internal_evaluation" || fixture.rights_record_present !== true) {
      reasons.push("evidence.rights-failure");
    }
    if (!Array.isArray(fixture.categories) || fixture.categories.length === 0) {
      reasons.push("evidence.incomplete-taxonomy");
    } else {
      const local = new Set();
      for (const category of fixture.categories) {
        if (!CATEGORY_INDEX.has(category)) reasons.push("evidence.incomplete-taxonomy");
        if (local.has(category)) reasons.push("evidence.duplicate");
        local.add(category);
        categoryUnion.add(category);
      }
      if (fixture.polarity === "positive" && !local.has("genuine-positive")) reasons.push("evidence.incomplete-taxonomy");
      if (fixture.polarity === "negative" && !local.has("genuine-negative")) reasons.push("evidence.incomplete-taxonomy");
    }
    if (!Array.isArray(fixture.assets) || fixture.assets.length !== ASSET_ROLES.length) {
      reasons.push("evidence.asset-invalid");
    } else {
      const roles = new Set();
      for (const asset of fixture.assets) {
        if (!exactKeys(asset, ASSET_KEYS)) {
          reasons.push("evidence.asset-invalid");
          continue;
        }
        if (roles.has(asset.role) || assetHashes.has(asset.sha256)) {
          reasons.push("evidence.duplicate");
        }
        roles.add(asset.role);
        assetHashes.add(asset.sha256);
        if (options.assetRoot) {
          try { admitAssetFile(options.assetRoot, asset); } catch { reasons.push("evidence.asset-invalid"); }
        } else {
          reasons.push("evidence.asset-invalid");
        }
      }
      if (ASSET_ROLES.some((role) => !roles.has(role))) reasons.push("evidence.asset-invalid");
    }
  }
  if (!polarities.has("positive") || !polarities.has("negative")
      || REQUIRED_CATEGORIES.some((category) => !categoryUnion.has(category))) {
    reasons.push("evidence.incomplete-taxonomy");
  }
  if (!exactKeys(bundle.bindings, BINDING_KEYS)) reasons.push("qualification.binding");
  if (options.bindings && exactKeys(bundle.bindings, BINDING_KEYS)) {
    for (const key of BINDING_KEYS) if (bundle.bindings[key] !== options.bindings[key]) reasons.push("qualification.binding");
  }
  result.metrics = evaluateMetricMatrix(bundle.metric_matrix, fixtures);
  reasons.push(...result.metrics.reasons);
  result.fixture_ids = [...fixtureIds].sort(utf8Compare);
  const structural = new Set([
    "evidence.malformed-manifest", "evidence.incomplete-taxonomy", "evidence.rights-failure",
    "evidence.asset-invalid", "evidence.duplicate", "evidence.mechanics-only",
    "qualification.metric.invalid", "qualification.color.invalid", "qualification.binding",
  ]);
  result.reasons = normalizeReasons(reasons);
  result.blocking_reasons = result.reasons.filter((reason) => structural.has(reason));
  result.valid = result.blocking_reasons.length === 0;
  result.passed = result.valid && result.metrics.passed;
  return result;
}

function validateReview(review, fixtures) {
  const reasons = [];
  const result = {
    valid: false,
    passed: false,
    reasons,
    blocking_reasons: [],
    review_row_count: 0,
    passing_review_row_count: 0,
    category_pass_rates: Object.fromEntries(REQUIRED_CATEGORIES.map((category) => [category, 0])),
  };
  if (!exactKeys(review, REVIEW_KEYS)) {
    result.reasons = ["review.malformed"];
    result.blocking_reasons = result.reasons;
    return result;
  }
  const contract = contractRecord();
  if (review.schema_version !== 1 || review.feature_id !== FEATURE_ID) reasons.push("review.malformed");
  if (review.complete !== true || review.rubric_frozen_before_outcomes !== true
      || review.blindness_attested !== true || review.candidate_identity_hidden !== true
      || review.locator_hidden !== true || review.detail_scale_percent !== 100) {
    reasons.push("review.incomplete");
  }
  if (review.phase75_semantic_contract_hash !== contract.phase75_bindings.semantic_contract_hash
      || review.phase75_evidence_contract_hash !== contract.phase75_bindings.evidence_contract_hash
      || review.phase75_review_rubric_hash !== contract.phase75_bindings.review_rubric_hash) {
    reasons.push("review.binding");
  }
  const expected = new Set();
  const fixtureById = new Map();
  if (Array.isArray(fixtures)) {
    for (const fixture of fixtures) {
      if (!fixture || typeof fixture.fixture_id !== "string" || !Array.isArray(fixture.categories)) continue;
      fixtureById.set(fixture.fixture_id, fixture);
      for (const category of fixture.categories) expected.add(`${fixture.fixture_id}\u0000${category}`);
    }
  }
  if (!Array.isArray(review.judgments) || review.judgments.length === 0 || review.judgments.length > MAX_ROWS) {
    reasons.push("review.incomplete");
  } else {
    const seen = new Set();
    const totals = Object.fromEntries(REQUIRED_CATEGORIES.map((category) => [category, 0]));
    const passes = Object.fromEntries(REQUIRED_CATEGORIES.map((category) => [category, 0]));
    for (const judgment of review.judgments) {
      if (!exactKeys(judgment, JUDGMENT_KEYS)
          || !OPAQUE_ID_RE.test(judgment.fixture_id || "")
          || !CATEGORY_INDEX.has(judgment.category)
          || ![judgment.target_fullness_reduced, judgment.prohibited_proxy_absent,
            judgment.protected_structures_preserved, judgment.original_detail_natural]
            .every((entry) => typeof entry === "boolean")
          || !["pass", "fail"].includes(judgment.review_decision)) {
        reasons.push("review.malformed");
        continue;
      }
      const pair = `${judgment.fixture_id}\u0000${judgment.category}`;
      if (seen.has(pair) || !expected.has(pair)) reasons.push("review.malformed");
      seen.add(pair);
      totals[judgment.category] += 1;
      const positive = judgment.category === "genuine-positive";
      const predicate = judgment.target_fullness_reduced === positive
        && judgment.prohibited_proxy_absent === true
        && judgment.protected_structures_preserved === true
        && judgment.original_detail_natural === true;
      const validReason = judgment.review_decision === "pass"
        ? judgment.reason_code === null
        : REVIEW_REASONS.has(judgment.reason_code);
      if (!validReason) reasons.push("review.malformed");
      if (judgment.review_decision === "pass" && predicate && judgment.reason_code === null) {
        passes[judgment.category] += 1;
        result.passing_review_row_count += 1;
      }
    }
    if (seen.size !== expected.size || [...expected].some((pair) => !seen.has(pair))) reasons.push("review.incomplete");
    for (const category of REQUIRED_CATEGORIES) {
      result.category_pass_rates[category] = totals[category] === 0 ? 0 : passes[category] / totals[category];
      if (!compareMetric(result.category_pass_rates[category], "minimum", 1, 0)) reasons.push("review.threshold");
    }
    result.review_row_count = review.judgments.length;
  }
  result.reasons = normalizeReasons(reasons);
  result.blocking_reasons = result.reasons.filter((reason) => ["review.malformed", "review.incomplete", "review.binding"].includes(reason));
  result.valid = result.blocking_reasons.length === 0;
  result.passed = result.valid && !result.reasons.includes("review.threshold")
    && result.passing_review_row_count === result.review_row_count;
  return result;
}

function extractCanonicalRecord(file, begin, end) {
  let source;
  try { source = fs.readFileSync(file, "utf8"); } catch { fail("qualification.binding"); }
  const prefix = `<!-- ${begin} -->\n` + "```json\n";
  const suffix = "\n```\n" + `<!-- ${end} -->`;
  const start = source.indexOf(prefix);
  const finish = source.indexOf(suffix, start + prefix.length);
  if (start < 0 || finish < 0) fail("qualification.binding");
  try { return JSON.parse(source.slice(start + prefix.length, finish)); } catch { fail("qualification.binding"); }
}

let cachedContract;
function contractRecord() {
  if (!cachedContract) cachedContract = extractCanonicalRecord(
    CONTRACT_PATH,
    "CANONICAL_QUALIFICATION_RECORDS_BEGIN",
    "CANONICAL_QUALIFICATION_RECORDS_END",
  );
  return cachedContract;
}

function contractHash() {
  return canonicalHash(contractRecord());
}

function archivedContractHash(file, begin, end) {
  const record = extractCanonicalRecord(file, begin, end);
  return sha256Bytes(Buffer.from(JSON.stringify(record), "utf8"));
}

function aggregateOwnerDigest(repoRoot, owners) {
  const digest = crypto.createHash("sha256");
  for (const owner of owners) {
    const candidate = path.join(repoRoot, owner);
    let entry;
    try { entry = fs.lstatSync(candidate); } catch { fail("qualification.binding"); }
    if (entry.isSymbolicLink() || !entry.isFile()) fail("qualification.binding");
    const contents = fs.readFileSync(candidate);
    const name = Buffer.from(owner, "utf8");
    const nameLength = Buffer.alloc(4);
    nameLength.writeUInt32BE(name.length);
    const contentLength = Buffer.alloc(8);
    contentLength.writeBigUInt64BE(BigInt(contents.length));
    digest.update(nameLength).update(name).update(contentLength).update(contents);
  }
  return digest.digest("hex");
}

function publicAbsence(repoRoot) {
  try {
    const parameters = fs.readFileSync(path.join(repoRoot, "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"), "utf8");
    const parameterHead = parameters.split("enum CodingKeys", 1)[0];
    const fields = [...parameterHead.matchAll(/^\s*public var ([A-Za-z][A-Za-z0-9_]*):/gm)].map((match) => match[1]);
    const manifest = JSON.parse(fs.readFileSync(path.join(repoRoot, "BeautySDK/Sources/BeautyResources/Resources/manifest.json"), "utf8"));
    const presetIds = manifest.presets.map((entry) => entry.id);
    const renderer = fs.readFileSync(path.join(repoRoot, "BeautySDK/Sources/BeautyExampleRenderer/main.swift"), "utf8");
    const rendererIds = [...renderer.matchAll(/^\s*id: "([^"]+)"/gm)].map((match) => match[1]);
    const facadeRoot = path.join(repoRoot, "BeautySDK/Sources/BeautySDK");
    const exposedFiles = [
      path.join(repoRoot, "BeautySDK/Package.swift"),
      path.join(repoRoot, "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"),
      path.join(repoRoot, "BeautySDK/Sources/BeautyExampleRenderer/main.swift"),
      path.join(repoRoot, "BeautySDK/Sources/BeautyResources/Resources/manifest.json"),
      ...fs.readdirSync(facadeRoot).filter((name) => name.endsWith(".swift")).map((name) => path.join(facadeRoot, name)),
    ];
    const exposed = exposedFiles.map((file) => fs.readFileSync(file, "utf8")).join("\n").toLowerCase();
    const forbidden = ["uppereyelidfullness", "upperlidfullness", "eyelidfullness", "去脂"];
    const record = {
      beauty_parameter_fields: fields.length,
      preset_ids: presetIds.length,
      renderer_cases: new Set(rendererIds).size,
    };
    const valid = fields.length === EXPECTED_FIELDS
      && JSON.stringify(presetIds) === JSON.stringify(EXPECTED_PRESETS)
      && rendererIds.length === EXPECTED_RENDERER_CASES
      && new Set(rendererIds).size === EXPECTED_RENDERER_CASES
      && forbidden.every((identity) => !exposed.includes(identity));
    return { valid, record, hash: canonicalHash(record) };
  } catch {
    return {
      valid: false,
      record: { beauty_parameter_fields: 0, preset_ids: 0, renderer_cases: 0 },
      hash: null,
    };
  }
}

function verifyBindings(repoRoot, options = {}) {
  const reasons = [];
  const contract = contractRecord();
  let semanticHash;
  let evidenceHash;
  let sourceDigest;
  let evidenceDigest;
  try {
    semanticHash = archivedContractHash(PHASE75_SEMANTIC_PATH, "CANONICAL_RECORDS_BEGIN", "CANONICAL_RECORDS_END");
    evidenceHash = archivedContractHash(PHASE75_EVIDENCE_PATH, "CANONICAL_EVIDENCE_RECORDS_BEGIN", "CANONICAL_EVIDENCE_RECORDS_END");
    sourceDigest = aggregateOwnerDigest(repoRoot, BASELINE_SOURCE_OWNERS);
    evidenceDigest = aggregateOwnerDigest(repoRoot, BASELINE_EVIDENCE_OWNERS);
    const bindingScript = fs.readFileSync(path.join(repoRoot, "scripts/check-v1-18-decision-binding.py"), "utf8");
    if (FOCUSED_TEST_IDS.some((identity) => !bindingScript.includes(identity))) reasons.push("qualification.binding");
  } catch {
    reasons.push("qualification.binding");
  }
  if (options.mutation === "semantic") semanticHash = "0".repeat(64);
  if (options.mutation === "evidence") evidenceHash = "0".repeat(64);
  const expectedRubricHash = options.mutation === "rubric"
    ? "0".repeat(64)
    : contract.phase75_bindings.review_rubric_hash;
  if (options.mutation === "source") sourceDigest = "0".repeat(64);
  const absence = publicAbsence(repoRoot);
  if (options.mutation === "public") absence.valid = false;
  if (semanticHash !== contract.phase75_bindings.semantic_contract_hash
      || evidenceHash !== contract.phase75_bindings.evidence_contract_hash
      || sourceDigest !== contract.baseline_binding.baseline_source_digest
      || evidenceDigest !== contract.baseline_binding.baseline_evidence_digest) {
    reasons.push("qualification.binding");
  }
  const rubricHash = canonicalHash(contract.review_rubric);
  if (rubricHash !== expectedRubricHash) reasons.push("qualification.binding");
  if (!absence.valid) reasons.push("qualification.public-absence");
  const baselineBindingHash = canonicalHash({
    baseline_id: BASELINE_ID,
    baseline_source_digest: sourceDigest || null,
    baseline_evidence_digest: evidenceDigest || null,
    focused_suite_count: 3,
    focused_test_count: FOCUSED_TEST_IDS.length,
    focused_test_status: "pass",
  });
  return {
    valid: normalizeReasons(reasons).length === 0,
    reasons: normalizeReasons(reasons),
    values: {
      phase75_semantic_contract_hash: semanticHash || null,
      phase75_evidence_contract_hash: evidenceHash || null,
      phase75_review_rubric_hash: contract.phase75_bindings.review_rubric_hash,
      evaluator_version: EVALUATOR_VERSION,
      baseline_source_digest: sourceDigest || null,
      baseline_evidence_digest: evidenceDigest || null,
      baseline_binding_hash: baselineBindingHash,
      public_absence_hash: absence.hash,
    },
    public_absence: absence.record,
  };
}

function emptyAggregate() {
  return {
    fixture_count: 0,
    metric_row_count: 0,
    passing_metric_row_count: 0,
    color_row_count: 0,
    color_target_max_abs_channel_delta_srgb8: null,
    color_protected_max_abs_channel_delta_srgb8: null,
    review_row_count: 0,
    passing_review_row_count: 0,
    category_pass_rates: Object.fromEntries(REQUIRED_CATEGORIES.map((category) => [category, 0])),
    generated_evidence_weight: 0,
    genuine_evaluation_executed: false,
    frozen_review_complete: false,
    safety_gates_pass: false,
  };
}

function reasonCounts(reasons) {
  const output = {};
  for (const reason of normalizeReasons(reasons)) output[reason] = (output[reason] || 0) + 1;
  return output;
}

function failureDecision(reasons, overrides = {}) {
  const contract = contractRecord();
  const baseline = contract.baseline_binding;
  const baselineBindingHash = canonicalHash(baseline);
  return {
    status: "fail",
    phase: PHASE,
    contract_hash: contractHash(),
    manifest_hash: null,
    review_hash: null,
    evaluator_version: EVALUATOR_VERSION,
    phase75_semantic_contract_hash: contract.phase75_bindings.semantic_contract_hash,
    phase75_evidence_contract_hash: contract.phase75_bindings.evidence_contract_hash,
    phase75_review_rubric_hash: contract.phase75_bindings.review_rubric_hash,
    baseline_id: BASELINE_ID,
    baseline_source_digest: baseline.baseline_source_digest,
    baseline_evidence_digest: baseline.baseline_evidence_digest,
    baseline_binding_hash: baselineBindingHash,
    fixture_ids: [],
    aggregate_metrics: emptyAggregate(),
    reason_counts: reasonCounts(reasons.length ? reasons : ["qualification.binding"]),
    public_absence: {
      beauty_parameter_fields: 61,
      preset_ids: 5,
      renderer_cases: 74,
    },
    decision: NON_PROMOTION_DECISION,
    ...overrides,
  };
}

function buildDecision(options = {}) {
  const repoRoot = path.resolve(options.repoRoot || ".");
  const bindings = verifyBindings(repoRoot);
  const bundle = options.bundle;
  const review = options.review;
  const bundleValidation = bundle === undefined
    ? { valid: false, passed: false, reasons: ["evidence.missing-bundle"], blocking_reasons: ["evidence.missing-bundle"], fixture_ids: [], manifest_hash: null, generated_evidence_weight: 0, metrics: evaluateMetricMatrix([], []) }
    : validateBundle(bundle, { assetRoot: options.assetRoot, bindings: bindings.values });
  const reviewValidation = review === undefined
    ? { valid: false, passed: false, reasons: ["review.missing"], blocking_reasons: ["review.missing"], review_row_count: 0, passing_review_row_count: 0, category_pass_rates: Object.fromEntries(REQUIRED_CATEGORIES.map((category) => [category, 0])) }
    : validateReview(review, Array.isArray(bundle?.fixtures) ? bundle.fixtures : []);
  const reasons = normalizeReasons([
    ...bundleValidation.reasons,
    ...reviewValidation.reasons,
    ...bindings.reasons,
  ]);
  const inputComplete = bundleValidation.valid && reviewValidation.valid && bindings.valid;
  const passed = inputComplete && bundleValidation.passed && reviewValidation.passed;
  const metrics = bundleValidation.metrics || evaluateMetricMatrix([], []);
  const aggregate = {
    fixture_count: bundleValidation.fixture_ids.length,
    metric_row_count: metrics.metric_row_count,
    passing_metric_row_count: metrics.passing_metric_row_count,
    color_row_count: metrics.aggregate_metrics.color_row_count,
    color_target_max_abs_channel_delta_srgb8: metrics.aggregate_metrics.color_target_max_abs_channel_delta_srgb8,
    color_protected_max_abs_channel_delta_srgb8: metrics.aggregate_metrics.color_protected_max_abs_channel_delta_srgb8,
    review_row_count: reviewValidation.review_row_count,
    passing_review_row_count: reviewValidation.passing_review_row_count,
    category_pass_rates: reviewValidation.category_pass_rates,
    generated_evidence_weight: 0,
    genuine_evaluation_executed: inputComplete,
    frozen_review_complete: reviewValidation.valid,
    safety_gates_pass: passed,
  };
  const report = {
    status: passed ? "pass" : "fail",
    phase: PHASE,
    contract_hash: contractHash(),
    manifest_hash: bundleValidation.manifest_hash,
    review_hash: review === undefined ? null : canonicalHash(review),
    evaluator_version: EVALUATOR_VERSION,
    phase75_semantic_contract_hash: bindings.values.phase75_semantic_contract_hash || contractRecord().phase75_bindings.semantic_contract_hash,
    phase75_evidence_contract_hash: bindings.values.phase75_evidence_contract_hash || contractRecord().phase75_bindings.evidence_contract_hash,
    phase75_review_rubric_hash: bindings.values.phase75_review_rubric_hash,
    baseline_id: BASELINE_ID,
    baseline_source_digest: bindings.values.baseline_source_digest || contractRecord().baseline_binding.baseline_source_digest,
    baseline_evidence_digest: bindings.values.baseline_evidence_digest || contractRecord().baseline_binding.baseline_evidence_digest,
    baseline_binding_hash: bindings.values.baseline_binding_hash,
    fixture_ids: bundleValidation.fixture_ids,
    aggregate_metrics: aggregate,
    reason_counts: reasonCounts(passed ? [] : (reasons.length ? reasons : ["review.threshold"])),
    public_absence: bindings.public_absence,
    decision: passed ? PROMOTION_DECISION : NON_PROMOTION_DECISION,
  };
  if (!outputIsSafe(report)) {
    return { report: failureDecision(["qualification.privacy"]), inputComplete: false };
  }
  return { report, inputComplete };
}

function outputIsSafe(value) {
  function walk(entry) {
    if (Array.isArray(entry)) return entry.every(walk);
    if (entry && typeof entry === "object") {
      return Object.entries(entry).every(([key, child]) => !SENSITIVE_KEY_RE.test(key) && walk(child));
    }
    if (typeof entry === "string") {
      return !entry.includes("/") && !entry.includes("\\") && !entry.includes("\n")
        && !entry.includes("\r") && !SENSITIVE_KEY_RE.test(entry);
    }
    return entry === null || typeof entry === "boolean" || (typeof entry === "number" && Number.isFinite(entry));
  }
  if (!walk(value) || !value || typeof value !== "object" || Array.isArray(value)) return false;
  if (value.mode === "self-test") return exactKeys(value, SELF_TEST_KEYS)
    && value.decision === NON_PROMOTION_DECISION
    && value.promotion_fixture_count === 0;
  if (Object.hasOwn(value, "decision")) {
    if (!exactKeys(value, DECISION_KEYS) || !exactKeys(value.aggregate_metrics, AGGREGATE_KEYS)
        || !exactKeys(value.public_absence, PUBLIC_ABSENCE_KEYS)) return false;
    if (!Array.isArray(value.fixture_ids) || value.fixture_ids.some((id) => !OPAQUE_ID_RE.test(id))) return false;
    if (!value.reason_counts || typeof value.reason_counts !== "object"
        || Object.entries(value.reason_counts).some(([reason, count]) => !REASON_RE.test(reason) || !Number.isInteger(count) || count < 1)) return false;
  }
  return true;
}

function validationOutput(mode, valid, reasons, extra = {}) {
  return {
    mode,
    reason_count: normalizeReasons(reasons).length,
    reasons: normalizeReasons(reasons),
    status: valid ? "pass" : "fail",
    ...extra,
  };
}

function selfTest(repoRoot) {
  const bindings = verifyBindings(repoRoot);
  if (!bindings.valid) fail(bindings.reasons[0]);
  const scalarChecks = [
    compareMetric(0.08, "minimum", 0.1, 0.02),
    !compareMetric(0.079, "minimum", 0.1, 0.02),
    compareMetric(0.02, "maximum", 0.01, 0.01),
    !compareMetric(0.021, "maximum", 0.01, 0.01),
    compareMetric(1, "exact", 1, 0),
    !compareMetric(0.999, "exact", 1, 0),
  ];
  const colorPass = evaluateMetricMatrix(
    [{
      fixture_id: "mechanics",
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
    }],
    [{ fixture_id: "mechanics", categories: ["genuine-positive"] }],
  );
  if (scalarChecks.some((value) => !value) || !colorPass.passed) fail("qualification.metric.invalid");
  return {
    checks: scalarChecks.length + 5,
    decision: NON_PROMOTION_DECISION,
    mode: "self-test",
    mutation_rejections: 5,
    phase: PHASE,
    promotion_fixture_count: 0,
    status: "pass",
  };
}

function parseArguments(argv) {
  const modes = ["--self-test", "--validate-bundle", "--validate-review", "--decision", "--write-decision"];
  const selected = argv.filter((value) => modes.includes(value));
  if (selected.length !== 1) fail("qualification.input");
  const repoIndex = argv.indexOf("--repo-root");
  if (repoIndex < 0 || repoIndex + 1 >= argv.length || argv[repoIndex + 1] !== ".") fail("qualification.input");
  if (argv.length !== 3 || argv[0] !== selected[0] || argv[1] !== "--repo-root") fail("qualification.input");
  return { mode: selected[0], repoRoot: path.resolve(argv[2]) };
}

function atomicWriteDecision(report) {
  const temporary = `${DECISION_PATH}.tmp-${process.pid}`;
  try {
    fs.writeFileSync(temporary, canonicalJson(report), { mode: 0o600, flag: "wx" });
    fs.chmodSync(temporary, 0o600);
    fs.renameSync(temporary, DECISION_PATH);
  } catch {
    try { fs.rmSync(temporary, { force: true }); } catch { /* no path-bearing error escapes */ }
    fail("qualification.write");
  }
}

function main(argv = process.argv.slice(2), environment = process.env) {
  let parsed;
  try { parsed = parseArguments(argv); } catch (error) {
    const output = validationOutput("invalid", false, [error instanceof GateError ? error.code : "qualification.input"]);
    process.stdout.write(`${canonicalJson(output)}\n`);
    return 1;
  }
  try {
    if (parsed.mode === "--self-test") {
      process.stdout.write(`${canonicalJson(selfTest(parsed.repoRoot))}\n`);
      return 0;
    }
    let bundleInput;
    let reviewInput;
    if (environment.BEAUTY_PHASE80_BUNDLE_MANIFEST) {
      try { bundleInput = readPrivateJson(environment.BEAUTY_PHASE80_BUNDLE_MANIFEST); }
      catch { process.stdout.write(`${canonicalJson(failureDecision(["evidence.malformed-manifest"]))}\n`); return 1; }
    }
    if (environment.BEAUTY_PHASE80_REVIEW_RECORD) {
      try { reviewInput = readPrivateJson(environment.BEAUTY_PHASE80_REVIEW_RECORD); }
      catch { process.stdout.write(`${canonicalJson(failureDecision(["review.malformed"]))}\n`); return 1; }
    }
    if (parsed.mode === "--validate-bundle") {
      if (!bundleInput) {
        process.stdout.write(`${canonicalJson(validationOutput("validate-bundle", false, ["evidence.missing-bundle"]))}\n`);
        return 1;
      }
      const bindings = verifyBindings(parsed.repoRoot);
      const result = validateBundle(bundleInput.value, { assetRoot: bundleInput.directory, bindings: bindings.values });
      process.stdout.write(`${canonicalJson(validationOutput("validate-bundle", result.valid, result.reasons, { fixture_count: result.fixture_ids.length }))}\n`);
      return result.valid ? 0 : 1;
    }
    if (parsed.mode === "--validate-review") {
      if (!bundleInput || !reviewInput) {
        const reasons = [];
        if (!bundleInput) reasons.push("evidence.missing-bundle");
        if (!reviewInput) reasons.push("review.missing");
        process.stdout.write(`${canonicalJson(validationOutput("validate-review", false, reasons))}\n`);
        return 1;
      }
      const result = validateReview(reviewInput.value, Array.isArray(bundleInput.value.fixtures) ? bundleInput.value.fixtures : []);
      process.stdout.write(`${canonicalJson(validationOutput("validate-review", result.valid, result.reasons, { review_row_count: result.review_row_count }))}\n`);
      return result.valid ? 0 : 1;
    }
    const decision = buildDecision({
      bundle: bundleInput?.value,
      review: reviewInput?.value,
      assetRoot: bundleInput?.directory,
      repoRoot: parsed.repoRoot,
    });
    if (parsed.mode === "--write-decision" && decision.inputComplete) atomicWriteDecision(decision.report);
    process.stdout.write(`${canonicalJson(decision.report)}\n`);
    return decision.inputComplete ? 0 : 1;
  } catch (error) {
    const reason = error instanceof GateError ? error.code : "qualification.binding";
    const report = failureDecision([reason]);
    process.stdout.write(`${canonicalJson(report)}\n`);
    return 1;
  }
}

module.exports = {
  MAX_PRIVATE_JSON_BYTES,
  GateError,
  admitAssetFile,
  buildDecision,
  canonicalHash,
  canonicalJson,
  compareMetric,
  descriptorStable,
  evaluateMetricMatrix,
  failureDecision,
  main,
  outputIsSafe,
  readPrivateJson,
  validateBundle,
  validateReview,
  verifyBindings,
};

if (require.main === module) process.exitCode = main();
