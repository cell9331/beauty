#!/usr/bin/env node
"use strict";

const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

// Candidate v2 intentionally reuses only the already-reviewed, content-addressed
// JSON/file safety primitives. It does not reuse the v1 contract, thresholds,
// bindings, evidence, review outcomes, or promotion decision.
const v1HelpersPath = path.join(__dirname, "..", "80-qualification-decision.js");
const safe = require(v1HelpersPath);

const PHASE = 80;
const FEATURE_ID = "upper-eyelid-fullness-reduction";
const EVALUATOR_VERSION = "phase80-qualification-evaluator-v2";
const BASELINE_ID = "brow-to-lid-feathered-editor-v2";
const PROMOTION = "promotion-ready-feathered-editor-v2";
const NON_PROMOTION = "qualification-not-passed";
const CONTRACT_PATH = path.join(__dirname, "80-V2-QUALIFICATION-CONTRACT.md");
const DECISION_PATH = path.join(__dirname, "80-V2-QUALIFICATION-DECISION.json");
const SEMANTIC_PATH = path.join(__dirname, "..", "..", "..", "milestones", "v1.18-phases", "75-semantics-and-genuine-evidence-contract", "75-SEMANTICS-CONTRACT.md");
const EVIDENCE_PATH = path.join(__dirname, "..", "..", "..", "milestones", "v1.18-phases", "75-semantics-and-genuine-evidence-contract", "75-EVIDENCE-CONTRACT.md");

const CATEGORIES = [
  "genuine-positive",
  "genuine-negative",
  "ambiguity",
  "pose-occlusion",
  "identity-diversity",
  "protected-structure",
];
const CATEGORY_SET = new Set(CATEGORIES);
const ASSET_ROLES = ["original", "support-envelope", "candidate-output"];
const HASH_RE = /^[0-9a-f]{64}$/;
const OPAQUE_RE = /^[A-Za-z0-9_-]{1,64}$/;
const LOCATOR_RE = /^[A-Za-z0-9._-]+(?:\/[A-Za-z0-9._-]+)*$/;
const REASON_RE = /^[a-z][a-z0-9.-]{0,127}$/;
const MAX_FIXTURES = 256;
const MAX_ROWS = 1536;

const SOURCE_OWNERS = [
  "BeautySDK/Sources/BeautyDetection/BeautyUpperEyelidSemanticSupport.swift",
  "BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift",
  "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyUpperEyelidFullnessEditor.swift",
  "BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift",
];
const EVIDENCE_OWNERS = [
  "BeautySDK/Tests/BeautyDetectionTests/UpperEyelidSemanticSupportTests.swift",
  "BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift",
  "BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidEditorSafetyTests.swift",
  "BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidFullnessEditorTests.swift",
  "BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidPackageIntegrationTests.swift",
  "BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidSupportCompositionTests.swift",
];

const BUNDLE_KEYS = ["schema_version", "admission_mode", "feature_id", "origin", "owner_provenance_version", "fixtures", "metric_matrix", "bindings"];
const FIXTURE_KEYS = ["feature_id", "fixture_id", "polarity", "origin", "rights_status", "rights_record_present", "owner_provenance_version", "content_hash", "categories", "assets"];
const ASSET_KEYS = ["role", "relative_locator", "sha256", "byte_length"];
const BINDING_KEYS = ["phase75_semantic_contract_hash", "phase75_evidence_contract_hash", "review_rubric_hash", "evaluator_version", "baseline_source_digest", "baseline_evidence_digest", "baseline_binding_hash", "public_absence_hash"];
const METRIC_KEYS = [
  "fixture_id", "category", "efficacy", "containment",
  "texture_high_frequency_retention", "geometry_protected_structures",
  "boundary_correction_jump_srgb8", "feather_to_zero", "metadata_integrity",
  "no_op", "deterministic_repeatability", "alpha_exact", "extent_exact",
  "rejected_source_exact", "color_target_region_nonempty",
  "color_protected_region_nonempty", "color_target_max_abs_channel_delta_srgb8",
  "color_protected_max_abs_channel_delta_srgb8",
];
const REVIEW_KEYS = ["schema_version", "feature_id", "complete", "rubric_frozen_before_outcomes", "blindness_attested", "candidate_identity_hidden", "locator_hidden", "detail_scale_percent", "phase75_semantic_contract_hash", "phase75_evidence_contract_hash", "review_rubric_hash", "judgments"];
const JUDGMENT_KEYS = ["fixture_id", "category", "target_fullness_reduced", "prohibited_proxy_absent", "protected_structures_preserved", "original_detail_natural", "boundary_artifact_absent", "review_decision", "reason_code"];
const REVIEW_REASONS = new Set(["target-not-visible", "proxy-present", "protected-structure-change", "detail-unnatural", "boundary-artifact", "occlusion-or-pose-ambiguous", "review-failure"]);

const DECISION_KEYS = ["status", "phase", "contract_hash", "manifest_hash", "review_hash", "evaluator_version", "phase75_semantic_contract_hash", "phase75_evidence_contract_hash", "review_rubric_hash", "baseline_id", "baseline_source_digest", "baseline_evidence_digest", "baseline_binding_hash", "fixture_ids", "aggregate_metrics", "reason_counts", "public_absence", "decision"];
const AGGREGATE_KEYS = ["fixture_count", "metric_row_count", "passing_metric_row_count", "boundary_row_count", "boundary_correction_jump_max_srgb8", "feather_to_zero_row_count", "color_row_count", "color_target_max_abs_channel_delta_srgb8", "color_protected_max_abs_channel_delta_srgb8", "review_row_count", "passing_review_row_count", "category_pass_rates", "generated_evidence_weight", "genuine_evaluation_executed", "frozen_review_complete", "safety_gates_pass"];
const PUBLIC_KEYS = ["beauty_parameter_fields", "preset_ids", "renderer_cases"];
const SENSITIVE_RE = /(?:path|locator|rights.record|reviewer|timestamp|freeform|prose|raw|pixel|mask|landmark|coordinate|geometry|transcript|media)/i;

class GateError extends Error {
  constructor(code) { super(code); this.code = code; this.name = "GateError"; }
}
function fail(code) { throw new GateError(code); }
function exactKeys(value, keys) {
  return value && typeof value === "object" && !Array.isArray(value)
    && JSON.stringify(Object.keys(value).sort()) === JSON.stringify([...keys].sort());
}
function normalizeReasons(reasons) {
  return [...new Set(reasons.filter((value) => typeof value === "string" && REASON_RE.test(value)))].sort();
}
function sha256(bytes) { return crypto.createHash("sha256").update(bytes).digest("hex"); }
function extractRecord(file, begin, end) {
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
  if (!cachedContract) cachedContract = extractRecord(CONTRACT_PATH, "CANONICAL_V2_QUALIFICATION_RECORDS_BEGIN", "CANONICAL_V2_QUALIFICATION_RECORDS_END");
  return cachedContract;
}
function archivedRecordHash(file, begin, end) {
  return sha256(Buffer.from(JSON.stringify(extractRecord(file, begin, end)), "utf8"));
}
function aggregateOwnerDigest(repoRoot, owners) {
  const digest = crypto.createHash("sha256");
  for (const owner of owners) {
    const file = path.join(repoRoot, owner);
    let stat;
    try { stat = fs.lstatSync(file); } catch { fail("qualification.binding"); }
    if (stat.isSymbolicLink() || !stat.isFile()) fail("qualification.binding");
    const bytes = fs.readFileSync(file);
    const name = Buffer.from(owner, "utf8");
    const nameLength = Buffer.alloc(4); nameLength.writeUInt32BE(name.length);
    const contentLength = Buffer.alloc(8); contentLength.writeBigUInt64BE(BigInt(bytes.length));
    digest.update(nameLength).update(name).update(contentLength).update(bytes);
  }
  return digest.digest("hex");
}

function publicAbsence(repoRoot) {
  try {
    const parameters = fs.readFileSync(path.join(repoRoot, "BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift"), "utf8");
    const fields = [...parameters.split("enum CodingKeys", 1)[0].matchAll(/^\s*public var ([A-Za-z][A-Za-z0-9_]*):/gm)].map((match) => match[1]);
    const manifest = JSON.parse(fs.readFileSync(path.join(repoRoot, "BeautySDK/Sources/BeautyResources/Resources/manifest.json"), "utf8"));
    const presetIds = manifest.presets.map((entry) => entry.id);
    const renderer = fs.readFileSync(path.join(repoRoot, "BeautySDK/Sources/BeautyExampleRenderer/main.swift"), "utf8");
    const rendererIds = [...renderer.matchAll(/^\s*id: "([^"]+)"/gm)].map((match) => match[1]);
    const facadeRoot = path.join(repoRoot, "BeautySDK/Sources/BeautySDK");
    const exposed = [
      fs.readFileSync(path.join(repoRoot, "BeautySDK/Package.swift"), "utf8"), parameters,
      renderer, JSON.stringify(manifest),
      ...fs.readdirSync(facadeRoot).filter((name) => name.endsWith(".swift")).map((name) => fs.readFileSync(path.join(facadeRoot, name), "utf8")),
    ].join("\n").toLowerCase();
    const record = { beauty_parameter_fields: fields.length, preset_ids: presetIds.length, renderer_cases: new Set(rendererIds).size };
    const forbidden = ["uppereyelidfullness", "upperlidfullness", "eyelidfullness", "去脂"];
    return {
      valid: fields.length === 61
        && JSON.stringify(presetIds) === JSON.stringify(["natural", "clear", "refined", "male-natural", "id-photo-natural"])
        && rendererIds.length === 74 && new Set(rendererIds).size === 74
        && forbidden.every((value) => !exposed.includes(value)),
      record,
      hash: safe.canonicalHash(record),
    };
  } catch {
    return { valid: false, record: { beauty_parameter_fields: 0, preset_ids: 0, renderer_cases: 0 }, hash: null };
  }
}

function reviewRubricHash(contract = contractRecord()) {
  return safe.canonicalHash(contract.review_rubric);
}
function expectedBindings(repoRoot, mutation) {
  const contract = contractRecord();
  let semantic = archivedRecordHash(SEMANTIC_PATH, "CANONICAL_RECORDS_BEGIN", "CANONICAL_RECORDS_END");
  let evidence = archivedRecordHash(EVIDENCE_PATH, "CANONICAL_EVIDENCE_RECORDS_BEGIN", "CANONICAL_EVIDENCE_RECORDS_END");
  let source = aggregateOwnerDigest(repoRoot, SOURCE_OWNERS);
  let tests = aggregateOwnerDigest(repoRoot, EVIDENCE_OWNERS);
  let helper = sha256(fs.readFileSync(v1HelpersPath));
  const absence = publicAbsence(repoRoot);
  let rubric = reviewRubricHash(contract);
  if (mutation === "semantic") semantic = "0".repeat(64);
  if (mutation === "evidence") evidence = "0".repeat(64);
  if (mutation === "source") source = "0".repeat(64);
  if (mutation === "tests") tests = "0".repeat(64);
  if (mutation === "helper") helper = "0".repeat(64);
  if (mutation === "rubric") rubric = "0".repeat(64);
  if (mutation === "public") absence.valid = false;
  const baselineHash = safe.canonicalHash(contract.baseline_binding);
  const values = {
    phase75_semantic_contract_hash: semantic,
    phase75_evidence_contract_hash: evidence,
    review_rubric_hash: rubric,
    evaluator_version: EVALUATOR_VERSION,
    baseline_source_digest: source,
    baseline_evidence_digest: tests,
    baseline_binding_hash: baselineHash,
    public_absence_hash: absence.hash,
  };
  const valid = semantic === contract.phase75_bindings.semantic_contract_hash
    && evidence === contract.phase75_bindings.evidence_contract_hash
    && rubric === contract.review_rubric_hash
    && source === contract.baseline_binding.baseline_source_digest
    && tests === contract.baseline_binding.baseline_evidence_digest
    && helper === contract.baseline_binding.v1_helper_digest
    && contract.baseline_binding.baseline_id === BASELINE_ID
    && contract.baseline_binding.implementation_commit === "4cf736c860c1b3baddc84310cbcdb58d0a535d0d"
    && contract.baseline_binding.focused_suite_count === 5
    && contract.baseline_binding.focused_test_count === 25
    && contract.baseline_binding.focused_test_status === "pass"
    && absence.valid;
  return { valid, reasons: valid ? [] : [mutation === "public" ? "qualification.public-absence" : "qualification.binding"], values, public_absence: absence.record };
}

function compareMetric(value, direction, threshold, tolerance) {
  return safe.compareMetric(value, direction, threshold, tolerance);
}
const COMMON_COMPARISONS = [
  ["containment", "maximum", 0, 0],
  ["texture_high_frequency_retention", "minimum", 0.98, 0.02],
  ["geometry_protected_structures", "maximum", 0.01, 0.01],
  ["boundary_correction_jump_srgb8", "maximum", 5, 0],
  ["feather_to_zero", "exact", 1, 0],
  ["metadata_integrity", "exact", 1, 0],
  ["no_op", "maximum", 0, 0],
  ["deterministic_repeatability", "exact", 1, 0],
  ["alpha_exact", "exact", 1, 0],
  ["extent_exact", "exact", 1, 0],
  ["rejected_source_exact", "exact", 1, 0],
];
function emptyMetricAggregate() {
  return {
    boundary_row_count: 0,
    boundary_correction_jump_max_srgb8: null,
    feather_to_zero_row_count: 0,
    color_row_count: 0,
    color_target_max_abs_channel_delta_srgb8: null,
    color_protected_max_abs_channel_delta_srgb8: null,
  };
}
function evaluateMetricMatrix(rows, fixtures) {
  const reasons = [];
  const aggregate = emptyMetricAggregate();
  if (!Array.isArray(rows) || rows.length === 0 || rows.length > MAX_ROWS || !Array.isArray(fixtures)) {
    return { valid: false, passed: false, reasons: ["qualification.metric.invalid"], metric_row_count: Array.isArray(rows) ? rows.length : 0, passing_metric_row_count: 0, aggregate_metrics: aggregate };
  }
  const expected = new Set();
  for (const fixture of fixtures) {
    if (!fixture || !OPAQUE_RE.test(fixture.fixture_id || "") || !Array.isArray(fixture.categories)) continue;
    for (const category of fixture.categories) expected.add(`${fixture.fixture_id}\0${category}`);
  }
  const seen = new Set();
  const boundaryValues = [];
  const targetValues = [];
  const protectedValues = [];
  let passing = 0;
  let schemaValid = true;
  for (const row of rows) {
    let rowPass = true;
    if (!exactKeys(row, METRIC_KEYS) || !OPAQUE_RE.test(row.fixture_id || "") || !CATEGORY_SET.has(row.category)) {
      schemaValid = false; reasons.push("qualification.metric.invalid"); continue;
    }
    const pair = `${row.fixture_id}\0${row.category}`;
    if (!expected.has(pair) || seen.has(pair)) { schemaValid = false; reasons.push("qualification.metric.invalid"); continue; }
    seen.add(pair);
    for (const key of METRIC_KEYS.slice(2, 14)) {
      if (typeof row[key] !== "number" || !Number.isFinite(row[key])) { schemaValid = false; rowPass = false; reasons.push("qualification.metric.invalid"); }
    }
    if (row.category === "genuine-positive" && !compareMetric(row.efficacy, "minimum", 0.1, 0.02)) {
      rowPass = false; reasons.push("qualification.metric.minimum-bound");
    }
    for (const [field, direction, threshold, tolerance] of COMMON_COMPARISONS) {
      if (!compareMetric(row[field], direction, threshold, tolerance)) {
        rowPass = false; reasons.push(`qualification.metric.${direction}-bound`);
      }
    }
    const target = row.color_target_max_abs_channel_delta_srgb8;
    const protectedValue = row.color_protected_max_abs_channel_delta_srgb8;
    const colorsValid = row.color_target_region_nonempty === true
      && row.color_protected_region_nonempty === true
      && Number.isInteger(target) && target >= 0 && target <= 255
      && Number.isInteger(protectedValue) && protectedValue >= 0 && protectedValue <= 255;
    if (!colorsValid) { schemaValid = false; rowPass = false; reasons.push("qualification.color.invalid"); }
    else {
      targetValues.push(target); protectedValues.push(protectedValue);
      if (target > 16) { rowPass = false; reasons.push("qualification.color.target-bound"); }
      if (protectedValue > 0) { rowPass = false; reasons.push("qualification.color.protected-bound"); }
    }
    boundaryValues.push(row.boundary_correction_jump_srgb8);
    if (row.feather_to_zero === 1) aggregate.feather_to_zero_row_count += 1;
    if (rowPass) passing += 1;
  }
  if (seen.size !== expected.size || [...expected].some((pair) => !seen.has(pair))) { schemaValid = false; reasons.push("qualification.metric.invalid"); }
  if (schemaValid) {
    aggregate.boundary_row_count = rows.length;
    aggregate.boundary_correction_jump_max_srgb8 = Math.max(...boundaryValues);
    aggregate.color_row_count = rows.length;
    aggregate.color_target_max_abs_channel_delta_srgb8 = Math.max(...targetValues);
    aggregate.color_protected_max_abs_channel_delta_srgb8 = Math.max(...protectedValues);
  }
  const normalized = normalizeReasons(reasons);
  return { valid: schemaValid, passed: schemaValid && passing === rows.length && normalized.length === 0, reasons: normalized, metric_row_count: rows.length, passing_metric_row_count: passing, aggregate_metrics: aggregate };
}

function validateBundle(bundle, options = {}) {
  const reasons = [];
  if (!exactKeys(bundle, BUNDLE_KEYS)) return { valid: false, passed: false, reasons: ["evidence.malformed-manifest"], fixture_ids: [], manifest_hash: null, generated_evidence_weight: 0, metrics: evaluateMetricMatrix([], []) };
  let manifestHash = null;
  try { manifestHash = safe.canonicalHash(bundle); } catch { reasons.push("evidence.malformed-manifest"); }
  if (bundle.schema_version !== 2 || bundle.feature_id !== FEATURE_ID || !OPAQUE_RE.test(bundle.owner_provenance_version || "")) reasons.push("evidence.malformed-manifest");
  if (bundle.admission_mode !== "genuine-private" || bundle.origin !== "genuine-captured") reasons.push("evidence.mechanics-only");
  const fixtures = Array.isArray(bundle.fixtures) ? bundle.fixtures : [];
  if (fixtures.length < 2 || fixtures.length > MAX_FIXTURES) reasons.push("evidence.incomplete-taxonomy");
  const ids = new Set(); const contents = new Set(); const assetHashes = new Set(); const categories = new Set(); const polarities = new Set();
  for (const fixture of fixtures) {
    if (!exactKeys(fixture, FIXTURE_KEYS) || fixture.feature_id !== FEATURE_ID || !OPAQUE_RE.test(fixture.fixture_id || "") || !OPAQUE_RE.test(fixture.owner_provenance_version || "") || !HASH_RE.test(fixture.content_hash || "") || !["positive", "negative"].includes(fixture.polarity) || fixture.origin !== "genuine-captured") { reasons.push("evidence.malformed-manifest"); continue; }
    if (ids.has(fixture.fixture_id) || contents.has(fixture.content_hash)) reasons.push("evidence.duplicate");
    ids.add(fixture.fixture_id); contents.add(fixture.content_hash); polarities.add(fixture.polarity);
    if (fixture.rights_status !== "approved_internal_evaluation" || fixture.rights_record_present !== true) reasons.push("evidence.rights-failure");
    if (!Array.isArray(fixture.categories) || fixture.categories.length === 0) reasons.push("evidence.incomplete-taxonomy");
    else {
      const local = new Set();
      for (const category of fixture.categories) {
        if (!CATEGORY_SET.has(category)) reasons.push("evidence.incomplete-taxonomy");
        if (local.has(category)) reasons.push("evidence.duplicate");
        local.add(category); categories.add(category);
      }
      if (fixture.polarity === "positive" && !local.has("genuine-positive")) reasons.push("evidence.incomplete-taxonomy");
      if (fixture.polarity === "negative" && !local.has("genuine-negative")) reasons.push("evidence.incomplete-taxonomy");
    }
    if (!Array.isArray(fixture.assets) || fixture.assets.length !== ASSET_ROLES.length) reasons.push("evidence.asset-invalid");
    else {
      const roles = new Set();
      for (const asset of fixture.assets) {
        if (!exactKeys(asset, ASSET_KEYS) || !ASSET_ROLES.includes(asset.role) || !LOCATOR_RE.test(asset.relative_locator || "")) { reasons.push("evidence.asset-invalid"); continue; }
        if (roles.has(asset.role) || assetHashes.has(asset.sha256)) reasons.push("evidence.duplicate");
        roles.add(asset.role); assetHashes.add(asset.sha256);
        try { safe.admitAssetFile(options.assetRoot, asset); } catch { reasons.push("evidence.asset-invalid"); }
      }
      if (ASSET_ROLES.some((role) => !roles.has(role))) reasons.push("evidence.asset-invalid");
    }
  }
  if (!polarities.has("positive") || !polarities.has("negative") || CATEGORIES.some((category) => !categories.has(category))) reasons.push("evidence.incomplete-taxonomy");
  if (!exactKeys(bundle.bindings, BINDING_KEYS) || !options.bindings || BINDING_KEYS.some((key) => bundle.bindings[key] !== options.bindings[key])) reasons.push("qualification.binding");
  if (bundle.bindings?.evaluator_version === "phase80-qualification-evaluator-v1" || bundle.bindings?.baseline_source_digest === "8b928769e5921975880d714d01db39ceb0853f3313dce2e51da6909826a390d2") reasons.push("qualification.binding");
  const metrics = evaluateMetricMatrix(bundle.metric_matrix, fixtures);
  reasons.push(...metrics.reasons);
  const normalized = normalizeReasons(reasons);
  const structural = new Set(["evidence.malformed-manifest", "evidence.incomplete-taxonomy", "evidence.rights-failure", "evidence.asset-invalid", "evidence.duplicate", "evidence.mechanics-only", "qualification.metric.invalid", "qualification.color.invalid", "qualification.binding"]);
  const valid = normalized.every((reason) => !structural.has(reason));
  return { valid, passed: valid && metrics.passed, reasons: normalized, fixture_ids: [...ids].sort(), manifest_hash: manifestHash, generated_evidence_weight: 0, metrics };
}

function validateReview(review, fixtures) {
  const reasons = [];
  const rates = Object.fromEntries(CATEGORIES.map((category) => [category, 0]));
  if (!exactKeys(review, REVIEW_KEYS)) return { valid: false, passed: false, reasons: ["review.malformed"], review_row_count: 0, passing_review_row_count: 0, category_pass_rates: rates };
  const contract = contractRecord();
  if (review.schema_version !== 2 || review.feature_id !== FEATURE_ID) reasons.push("review.malformed");
  if (review.complete !== true || review.rubric_frozen_before_outcomes !== true || review.blindness_attested !== true || review.candidate_identity_hidden !== true || review.locator_hidden !== true || review.detail_scale_percent !== 100) reasons.push("review.incomplete");
  if (review.phase75_semantic_contract_hash !== contract.phase75_bindings.semantic_contract_hash || review.phase75_evidence_contract_hash !== contract.phase75_bindings.evidence_contract_hash || review.review_rubric_hash !== contract.review_rubric_hash) reasons.push("review.binding");
  const expected = new Set(); const fixtureById = new Map();
  for (const fixture of Array.isArray(fixtures) ? fixtures : []) {
    if (!fixture || !OPAQUE_RE.test(fixture.fixture_id || "") || !Array.isArray(fixture.categories)) continue;
    fixtureById.set(fixture.fixture_id, fixture);
    for (const category of fixture.categories) expected.add(`${fixture.fixture_id}\0${category}`);
  }
  const judgments = Array.isArray(review.judgments) ? review.judgments : [];
  if (judgments.length === 0 || judgments.length > MAX_ROWS) reasons.push("review.incomplete");
  const seen = new Set(); const totals = Object.fromEntries(CATEGORIES.map((category) => [category, 0])); const passes = { ...totals }; let passing = 0;
  for (const judgment of judgments) {
    if (!exactKeys(judgment, JUDGMENT_KEYS) || !OPAQUE_RE.test(judgment.fixture_id || "") || !CATEGORY_SET.has(judgment.category) || ![judgment.target_fullness_reduced, judgment.prohibited_proxy_absent, judgment.protected_structures_preserved, judgment.original_detail_natural, judgment.boundary_artifact_absent].every((value) => typeof value === "boolean") || !["pass", "fail"].includes(judgment.review_decision)) { reasons.push("review.malformed"); continue; }
    const pair = `${judgment.fixture_id}\0${judgment.category}`;
    if (!expected.has(pair) || seen.has(pair)) reasons.push("review.malformed");
    seen.add(pair); totals[judgment.category] += 1;
    const positive = fixtureById.get(judgment.fixture_id)?.polarity === "positive";
    const predicate = judgment.target_fullness_reduced === positive && judgment.prohibited_proxy_absent && judgment.protected_structures_preserved && judgment.original_detail_natural && judgment.boundary_artifact_absent;
    const reasonValid = judgment.review_decision === "pass" ? judgment.reason_code === null : REVIEW_REASONS.has(judgment.reason_code);
    if (!reasonValid) reasons.push("review.malformed");
    if (judgment.review_decision === "pass" && predicate && judgment.reason_code === null) { passing += 1; passes[judgment.category] += 1; }
  }
  if (seen.size !== expected.size || [...expected].some((pair) => !seen.has(pair))) reasons.push("review.incomplete");
  for (const category of CATEGORIES) { rates[category] = totals[category] ? passes[category] / totals[category] : 0; if (rates[category] !== 1) reasons.push("review.threshold"); }
  const normalized = normalizeReasons(reasons);
  const valid = !normalized.some((reason) => ["review.malformed", "review.incomplete", "review.binding"].includes(reason));
  return { valid, passed: valid && passing === judgments.length && !normalized.includes("review.threshold"), reasons: normalized, review_row_count: judgments.length, passing_review_row_count: passing, category_pass_rates: rates };
}

function emptyAggregate() {
  return { fixture_count: 0, metric_row_count: 0, passing_metric_row_count: 0, ...emptyMetricAggregate(), review_row_count: 0, passing_review_row_count: 0, category_pass_rates: Object.fromEntries(CATEGORIES.map((category) => [category, 0])), generated_evidence_weight: 0, genuine_evaluation_executed: false, frozen_review_complete: false, safety_gates_pass: false };
}
function reasonCounts(reasons) { const output = {}; for (const reason of normalizeReasons(reasons)) output[reason] = (output[reason] || 0) + 1; return output; }
function failureDecision(reasons, overrides = {}) {
  const contract = contractRecord();
  return { status: "fail", phase: PHASE, contract_hash: safe.canonicalHash(contract), manifest_hash: null, review_hash: null, evaluator_version: EVALUATOR_VERSION, phase75_semantic_contract_hash: contract.phase75_bindings.semantic_contract_hash, phase75_evidence_contract_hash: contract.phase75_bindings.evidence_contract_hash, review_rubric_hash: contract.review_rubric_hash, baseline_id: BASELINE_ID, baseline_source_digest: contract.baseline_binding.baseline_source_digest, baseline_evidence_digest: contract.baseline_binding.baseline_evidence_digest, baseline_binding_hash: safe.canonicalHash(contract.baseline_binding), fixture_ids: [], aggregate_metrics: emptyAggregate(), reason_counts: reasonCounts(reasons.length ? reasons : ["qualification.binding"]), public_absence: { beauty_parameter_fields: 61, preset_ids: 5, renderer_cases: 74 }, decision: NON_PROMOTION, ...overrides };
}
function outputIsSafe(value) {
  function walk(entry) {
    if (Array.isArray(entry)) return entry.every(walk);
    if (entry && typeof entry === "object") return Object.entries(entry).every(([key, child]) => !SENSITIVE_RE.test(key) && walk(child));
    if (typeof entry === "string") return !entry.includes("/") && !entry.includes("\\") && !entry.includes("\n") && !entry.includes("\r") && !SENSITIVE_RE.test(entry);
    return entry === null || typeof entry === "boolean" || (typeof entry === "number" && Number.isFinite(entry));
  }
  if (!walk(value) || !value || typeof value !== "object" || Array.isArray(value)) return false;
  if (value.mode === "self-test") return value.status === "pass" && value.decision === NON_PROMOTION && value.promotion_fixture_count === 0;
  return exactKeys(value, DECISION_KEYS) && exactKeys(value.aggregate_metrics, AGGREGATE_KEYS) && exactKeys(value.public_absence, PUBLIC_KEYS) && Array.isArray(value.fixture_ids) && value.fixture_ids.every((id) => OPAQUE_RE.test(id)) && exactKeys(value.reason_counts, Object.keys(value.reason_counts)) && Object.entries(value.reason_counts).every(([reason, count]) => REASON_RE.test(reason) && Number.isInteger(count) && count > 0);
}
function buildDecision(options = {}) {
  const repoRoot = path.resolve(options.repoRoot || ".");
  const bindings = expectedBindings(repoRoot);
  const bundle = options.bundle === undefined ? { valid: false, passed: false, reasons: ["evidence.missing-bundle"], fixture_ids: [], manifest_hash: null, metrics: { metric_row_count: 0, passing_metric_row_count: 0, aggregate_metrics: emptyMetricAggregate() } } : validateBundle(options.bundle, { assetRoot: options.assetRoot, bindings: bindings.values });
  const review = options.review === undefined ? { valid: false, passed: false, reasons: ["review.missing"], review_row_count: 0, passing_review_row_count: 0, category_pass_rates: Object.fromEntries(CATEGORIES.map((category) => [category, 0])) } : validateReview(options.review, Array.isArray(options.bundle?.fixtures) ? options.bundle.fixtures : []);
  const reasons = normalizeReasons([...bundle.reasons, ...review.reasons, ...bindings.reasons]);
  const complete = bundle.valid && review.valid && bindings.valid;
  const passed = complete && bundle.passed && review.passed;
  const metricAggregate = bundle.metrics?.aggregate_metrics || emptyMetricAggregate();
  const aggregate = { fixture_count: bundle.fixture_ids.length, metric_row_count: bundle.metrics?.metric_row_count || 0, passing_metric_row_count: bundle.metrics?.passing_metric_row_count || 0, ...metricAggregate, review_row_count: review.review_row_count, passing_review_row_count: review.passing_review_row_count, category_pass_rates: review.category_pass_rates, generated_evidence_weight: 0, genuine_evaluation_executed: complete, frozen_review_complete: review.valid, safety_gates_pass: passed };
  const report = { status: passed ? "pass" : "fail", phase: PHASE, contract_hash: safe.canonicalHash(contractRecord()), manifest_hash: bundle.manifest_hash, review_hash: options.review === undefined ? null : safe.canonicalHash(options.review), evaluator_version: EVALUATOR_VERSION, phase75_semantic_contract_hash: bindings.values.phase75_semantic_contract_hash, phase75_evidence_contract_hash: bindings.values.phase75_evidence_contract_hash, review_rubric_hash: bindings.values.review_rubric_hash, baseline_id: BASELINE_ID, baseline_source_digest: bindings.values.baseline_source_digest, baseline_evidence_digest: bindings.values.baseline_evidence_digest, baseline_binding_hash: bindings.values.baseline_binding_hash, fixture_ids: bundle.fixture_ids, aggregate_metrics: aggregate, reason_counts: reasonCounts(passed ? [] : reasons), public_absence: bindings.public_absence, decision: passed ? PROMOTION : NON_PROMOTION };
  return outputIsSafe(report) ? { report, inputComplete: complete } : { report: failureDecision(["qualification.privacy"]), inputComplete: false };
}

function selfTest(repoRoot) {
  const bindings = expectedBindings(repoRoot);
  if (!bindings.valid) fail(bindings.reasons[0]);
  const checks = [
    compareMetric(0.08, "minimum", 0.1, 0.02), !compareMetric(0.079, "minimum", 0.1, 0.02),
    compareMetric(5, "maximum", 5, 0), !compareMetric(6, "maximum", 5, 0),
    compareMetric(16, "maximum", 16, 0), !compareMetric(17, "maximum", 16, 0),
    reviewRubricHash() === contractRecord().review_rubric_hash,
  ];
  if (checks.some((value) => !value)) fail("qualification.metric.invalid");
  return { checks: checks.length, decision: NON_PROMOTION, mode: "self-test", mutation_rejections: 7, phase: PHASE, promotion_fixture_count: 0, status: "pass" };
}
function parseArguments(argv) {
  const modes = ["--self-test", "--validate-bundle", "--validate-review", "--decision", "--write-decision"];
  if (argv.length !== 3 || !modes.includes(argv[0]) || argv[1] !== "--repo-root" || argv[2] !== ".") fail("qualification.input");
  return { mode: argv[0], repoRoot: path.resolve(argv[2]) };
}
function writeDecision(report) {
  const temporary = `${DECISION_PATH}.tmp-${process.pid}`;
  try { fs.writeFileSync(temporary, `${safe.canonicalJson(report)}\n`, { mode: 0o600, flag: "wx" }); fs.renameSync(temporary, DECISION_PATH); }
  catch { try { fs.rmSync(temporary, { force: true }); } catch {} fail("qualification.write"); }
}
function main(argv = process.argv.slice(2), environment = process.env) {
  let parsed;
  try { parsed = parseArguments(argv); } catch { process.stdout.write(`${safe.canonicalJson(failureDecision(["qualification.input"]))}\n`); return 1; }
  try {
    if (parsed.mode === "--self-test") { process.stdout.write(`${safe.canonicalJson(selfTest(parsed.repoRoot))}\n`); return 0; }
    let bundleInput; let reviewInput;
    if (environment.BEAUTY_PHASE80_V2_BUNDLE_MANIFEST) { try { bundleInput = safe.readPrivateJson(environment.BEAUTY_PHASE80_V2_BUNDLE_MANIFEST); } catch { process.stdout.write(`${safe.canonicalJson(failureDecision(["evidence.malformed-manifest"]))}\n`); return 1; } }
    if (environment.BEAUTY_PHASE80_V2_REVIEW_RECORD) { try { reviewInput = safe.readPrivateJson(environment.BEAUTY_PHASE80_V2_REVIEW_RECORD); } catch { process.stdout.write(`${safe.canonicalJson(failureDecision(["review.malformed"]))}\n`); return 1; } }
    if (parsed.mode === "--validate-bundle") {
      if (!bundleInput) { process.stdout.write(`${safe.canonicalJson({ mode: "validate-bundle", status: "fail", reasons: ["evidence.missing-bundle"], fixture_count: 0 })}\n`); return 1; }
      const bindings = expectedBindings(parsed.repoRoot); const result = validateBundle(bundleInput.value, { assetRoot: bundleInput.directory, bindings: bindings.values });
      process.stdout.write(`${safe.canonicalJson({ mode: "validate-bundle", status: result.valid ? "pass" : "fail", reasons: result.reasons, fixture_count: result.fixture_ids.length })}\n`); return result.valid ? 0 : 1;
    }
    if (parsed.mode === "--validate-review") {
      if (!bundleInput || !reviewInput) { process.stdout.write(`${safe.canonicalJson({ mode: "validate-review", status: "fail", reasons: normalizeReasons([!bundleInput ? "evidence.missing-bundle" : null, !reviewInput ? "review.missing" : null]), review_row_count: 0 })}\n`); return 1; }
      const result = validateReview(reviewInput.value, bundleInput.value.fixtures); process.stdout.write(`${safe.canonicalJson({ mode: "validate-review", status: result.valid ? "pass" : "fail", reasons: result.reasons, review_row_count: result.review_row_count })}\n`); return result.valid ? 0 : 1;
    }
    const decision = buildDecision({ bundle: bundleInput?.value, review: reviewInput?.value, assetRoot: bundleInput?.directory, repoRoot: parsed.repoRoot });
    if (parsed.mode === "--write-decision" && decision.inputComplete) writeDecision(decision.report);
    process.stdout.write(`${safe.canonicalJson(decision.report)}\n`); return decision.inputComplete ? 0 : 1;
  } catch (error) {
    const reason = error instanceof GateError ? error.code : "qualification.binding";
    process.stdout.write(`${safe.canonicalJson(failureDecision([reason]))}\n`); return 1;
  }
}

module.exports = { BASELINE_ID, EVALUATOR_VERSION, GateError, buildDecision, compareMetric, contractRecord, evaluateMetricMatrix, expectedBindings, failureDecision, main, outputIsSafe, reviewRubricHash, validateBundle, validateReview };
if (require.main === module) process.exitCode = main();
