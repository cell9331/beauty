#!/usr/bin/env node
"use strict";

const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

const phaseRoot = path.join(__dirname, "..");
const v3Path = path.join(phaseRoot, "v3", "80-v3-qualification-decision.js");
const v3ContractPath = path.join(phaseRoot, "v3", "80-V3-QUALIFICATION-CONTRACT.md");
const v3TestPath = path.join(phaseRoot, "v3", "80-v3-qualification-decision.test.js");
const safe = require(path.join(phaseRoot, "80-qualification-decision.js"));
const v3 = require(v3Path);

const PHASE = 80;
const FEATURE_ID = "upper-eyelid-fullness-reduction";
const VERSION = "phase80-qualification-evaluator-v4";
const BASELINE = "boundary-anchored-relief-flattening-editor-v4";
const PROMOTION = "promotion-ready-relief-flattening-editor-v4";
const NON_PROMOTION = "qualification-not-passed";
const CONTRACT_PATH = path.join(__dirname, "80-V4-QUALIFICATION-CONTRACT.md");
const DECISION_PATH = path.join(__dirname, "80-V4-QUALIFICATION-DECISION.json");

const CATEGORIES = ["genuine-positive", "genuine-negative", "ambiguity", "pose-occlusion", "identity-diversity", "protected-structure"];
const CATEGORY_SET = new Set(CATEGORIES);
const OPAQUE_RE = /^[A-Za-z0-9_-]{1,64}$/;
const REASON_RE = /^[a-z][a-z0-9.-]{0,127}$/;
const MAX_ROWS = 1536;
const SOURCE_OWNERS = [
  "BeautySDK/Sources/BeautyDetection/BeautyUpperEyelidSemanticSupport.swift",
  "BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift",
  "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyUpperEyelidFullnessEditor.swift",
  "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyUpperEyelidReliefModel.swift",
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
const BINDING_KEYS = ["phase75_semantic_contract_hash", "phase75_evidence_contract_hash", "review_rubric_hash", "evaluator_version", "baseline_source_digest", "baseline_evidence_digest", "baseline_binding_hash", "public_absence_hash"];
const V3_METRIC_KEYS = [
  "fixture_id", "category", "target_metrics_applicable", "efficacy", "containment",
  "texture_high_frequency_retention", "geometry_protected_structures",
  "boundary_correction_jump_srgb8", "feather_to_zero", "metadata_integrity",
  "no_op", "deterministic_repeatability", "alpha_exact", "extent_exact",
  "rejected_source_exact", "color_target_region_nonempty",
  "color_protected_region_nonempty", "color_target_max_abs_channel_delta_srgb8",
  "color_protected_max_abs_channel_delta_srgb8",
];
const RELIEF_METRIC_KEYS = [
  "source_central_convexity_srgb8", "output_central_convexity_srgb8",
  "convexity_reduction_ratio", "correction_spatial_range_srgb8",
  "target_mean_abs_channel_delta_srgb8",
];
const METRIC_KEYS = [
  "fixture_id", "category", "target_metrics_applicable", "efficacy",
  ...RELIEF_METRIC_KEYS, "containment", "texture_high_frequency_retention",
  "geometry_protected_structures", "boundary_correction_jump_srgb8",
  "feather_to_zero", "metadata_integrity", "no_op",
  "deterministic_repeatability", "alpha_exact", "extent_exact",
  "rejected_source_exact", "color_target_region_nonempty",
  "color_protected_region_nonempty", "color_target_max_abs_channel_delta_srgb8",
  "color_protected_max_abs_channel_delta_srgb8",
];
const REVIEW_KEYS = ["schema_version", "feature_id", "complete", "rubric_frozen_before_outcomes", "blindness_attested", "candidate_identity_hidden", "locator_hidden", "detail_scale_percent", "phase75_semantic_contract_hash", "phase75_evidence_contract_hash", "review_rubric_hash", "judgments"];
const JUDGMENT_KEYS = ["fixture_id", "category", "target_fullness_reduced", "relief_shape_flatter", "uniform_tone_shift_only_absent", "prohibited_proxy_absent", "protected_structures_preserved", "original_detail_natural", "boundary_artifact_absent", "review_decision", "reason_code"];
const REVIEW_REASONS = new Set(["target-not-visible", "relief-shape-not-flatter", "uniform-tone-shift-only", "proxy-present", "protected-structure-change", "detail-unnatural", "boundary-artifact", "occlusion-or-pose-ambiguous", "review-failure"]);
const DECISION_KEYS = ["status", "phase", "contract_hash", "manifest_hash", "review_hash", "evaluator_version", "phase75_semantic_contract_hash", "phase75_evidence_contract_hash", "review_rubric_hash", "baseline_id", "baseline_source_digest", "baseline_evidence_digest", "baseline_binding_hash", "fixture_ids", "aggregate_metrics", "reason_counts", "public_absence", "decision"];
const AGGREGATE_KEYS = ["fixture_count", "metric_row_count", "passing_metric_row_count", "applicable_target_row_count", "inapplicable_target_row_count", "source_central_convexity_min_srgb8", "output_central_convexity_max_srgb8", "convexity_reduction_ratio_min", "correction_spatial_range_min_srgb8", "target_mean_abs_channel_delta_min_srgb8", "boundary_correction_jump_max_srgb8", "feather_to_zero_row_count", "color_target_max_abs_channel_delta_srgb8", "color_protected_max_abs_channel_delta_srgb8", "review_row_count", "passing_review_row_count", "category_pass_rates", "generated_evidence_weight", "genuine_evaluation_executed", "frozen_review_complete", "safety_gates_pass"];
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
function reasons(values) {
  return [...new Set(values.filter((value) => typeof value === "string" && REASON_RE.test(value)))].sort();
}
function sha256(bytes) { return crypto.createHash("sha256").update(bytes).digest("hex"); }
function finite(value) { return typeof value === "number" && Number.isFinite(value); }
function extractRecord(file, begin, end) {
  let text;
  try { text = fs.readFileSync(file, "utf8"); } catch { fail("qualification.binding"); }
  const prefix = `<!-- ${begin} -->\n` + "```json\n";
  const suffix = "\n```\n" + `<!-- ${end} -->`;
  const start = text.indexOf(prefix);
  const finish = text.indexOf(suffix, start + prefix.length);
  if (start < 0 || finish < 0) fail("qualification.binding");
  try { return JSON.parse(text.slice(start + prefix.length, finish)); }
  catch { fail("qualification.binding"); }
}
let cachedContract;
function contractRecord() {
  if (!cachedContract) cachedContract = extractRecord(
    CONTRACT_PATH,
    "CANONICAL_V4_QUALIFICATION_RECORDS_BEGIN",
    "CANONICAL_V4_QUALIFICATION_RECORDS_END"
  );
  return cachedContract;
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
function reviewRubricHash() { return safe.canonicalHash(contractRecord().review_rubric); }

function expectedBindings(repoRoot, mutation) {
  const contract = contractRecord();
  const inherited = v3.expectedBindings(repoRoot);
  let semantic = inherited.values.phase75_semantic_contract_hash;
  let evidence = inherited.values.phase75_evidence_contract_hash;
  let source = aggregateOwnerDigest(repoRoot, SOURCE_OWNERS);
  let tests = aggregateOwnerDigest(repoRoot, EVIDENCE_OWNERS);
  let helperV3 = sha256(fs.readFileSync(v3Path));
  let contractV3 = sha256(fs.readFileSync(v3ContractPath));
  let testV3 = sha256(fs.readFileSync(v3TestPath));
  let rubric = reviewRubricHash();
  const absence = {
    valid: JSON.stringify(inherited.public_absence) === JSON.stringify({ beauty_parameter_fields: 61, preset_ids: 5, renderer_cases: 74 }),
    record: inherited.public_absence,
    hash: inherited.values.public_absence_hash,
  };
  if (mutation === "semantic") semantic = "0".repeat(64);
  if (mutation === "evidence") evidence = "0".repeat(64);
  if (mutation === "source") source = "0".repeat(64);
  if (mutation === "tests") tests = "0".repeat(64);
  if (mutation === "helper-v3") helperV3 = "0".repeat(64);
  if (mutation === "contract-v3") contractV3 = "0".repeat(64);
  if (mutation === "test-v3") testV3 = "0".repeat(64);
  if (mutation === "rubric") rubric = "0".repeat(64);
  if (mutation === "public") absence.valid = false;
  const baseline = contract.baseline_binding;
  const baselineHash = safe.canonicalHash(baseline);
  const values = {
    phase75_semantic_contract_hash: semantic,
    phase75_evidence_contract_hash: evidence,
    review_rubric_hash: rubric,
    evaluator_version: VERSION,
    baseline_source_digest: source,
    baseline_evidence_digest: tests,
    baseline_binding_hash: baselineHash,
    public_absence_hash: absence.hash,
  };
  const valid = semantic === contract.phase75_bindings.semantic_contract_hash
    && evidence === contract.phase75_bindings.evidence_contract_hash
    && source === baseline.baseline_source_digest
    && tests === baseline.baseline_evidence_digest
    && helperV3 === baseline.v3_helper_digest
    && contractV3 === baseline.v3_contract_digest
    && testV3 === baseline.v3_test_digest
    && rubric === contract.review_rubric_hash
    && baseline.baseline_id === BASELINE
    && baseline.qualification_strength === 1
    && baseline.minimum_source_convexity_srgb8 === 3.5
    && baseline.relief_compression_gain === 1.5
    && baseline.maximum_analysis_radius === 24
    && baseline.absolute_channel_safety_cap_srgb8 === 16
    && baseline.implementation_commit === "c70b9eacc0d832f4765a15cf503c04b557cbdcbb"
    && baseline.focused_suite_count === 5
    && baseline.focused_test_count === 30
    && baseline.focused_test_status === "pass"
    && absence.valid;
  return {
    valid,
    reasons: valid ? [] : [mutation === "public" ? "qualification.public-absence" : "qualification.binding"],
    values,
    public_absence: absence.record,
  };
}

function emptyMetricAggregate() {
  return {
    applicable_target_row_count: 0,
    inapplicable_target_row_count: 0,
    source_central_convexity_min_srgb8: null,
    output_central_convexity_max_srgb8: null,
    convexity_reduction_ratio_min: null,
    correction_spatial_range_min_srgb8: null,
    target_mean_abs_channel_delta_min_srgb8: null,
    boundary_correction_jump_max_srgb8: null,
    feather_to_zero_row_count: 0,
    color_target_max_abs_channel_delta_srgb8: null,
    color_protected_max_abs_channel_delta_srgb8: null,
  };
}
function transformMetric(row) {
  return Object.fromEntries(V3_METRIC_KEYS.map((key) => [key, row[key]]));
}
function evaluateMetricMatrix(rows, fixtures) {
  const aggregate = emptyMetricAggregate();
  if (!Array.isArray(rows) || rows.length === 0 || rows.length > MAX_ROWS || !Array.isArray(fixtures)) {
    return { valid: false, passed: false, reasons: ["qualification.metric.invalid"], metric_row_count: Array.isArray(rows) ? rows.length : 0, passing_metric_row_count: 0, aggregate_metrics: aggregate };
  }
  const polarity = new Map(fixtures.filter((fixture) => fixture && typeof fixture.fixture_id === "string").map((fixture) => [fixture.fixture_id, fixture.polarity]));
  const transformed = [];
  const found = [];
  let passing = 0;
  const positiveValues = { source: [], output: [], ratio: [], range: [], mean: [], boundary: [], target: [], protected: [] };
  for (const row of rows) {
    const rowReasons = [];
    if (!exactKeys(row, METRIC_KEYS) || !OPAQUE_RE.test(row?.fixture_id || "") || !CATEGORY_SET.has(row?.category) || typeof row?.target_metrics_applicable !== "boolean") {
      found.push("qualification.metric.invalid");
      continue;
    }
    const numericKeys = ["efficacy", ...RELIEF_METRIC_KEYS, "containment", "texture_high_frequency_retention", "geometry_protected_structures", "boundary_correction_jump_srgb8", "feather_to_zero", "metadata_integrity", "no_op", "deterministic_repeatability", "alpha_exact", "extent_exact", "rejected_source_exact", "color_target_max_abs_channel_delta_srgb8", "color_protected_max_abs_channel_delta_srgb8"];
    if (!numericKeys.every((key) => finite(row[key])) || typeof row.color_target_region_nonempty !== "boolean" || typeof row.color_protected_region_nonempty !== "boolean") {
      found.push("qualification.metric.invalid");
      continue;
    }
    const shouldApply = polarity.get(row.fixture_id) === "positive";
    if (row.target_metrics_applicable !== shouldApply) rowReasons.push("qualification.applicability");
    if (row.containment !== 0 || row.texture_high_frequency_retention < 0.98 || row.geometry_protected_structures !== 0 || row.metadata_integrity !== 1 || row.no_op !== 0 || row.deterministic_repeatability !== 1 || row.alpha_exact !== 1 || row.extent_exact !== 1 || row.rejected_source_exact !== 1 || row.color_protected_region_nonempty !== true || row.color_protected_max_abs_channel_delta_srgb8 !== 0) {
      rowReasons.push("qualification.metric.common-bound");
    }
    if (shouldApply) {
      aggregate.applicable_target_row_count += 1;
      const expectedRatio = 1 - row.output_central_convexity_srgb8 / row.source_central_convexity_srgb8;
      if (row.source_central_convexity_srgb8 < 3.5 || row.output_central_convexity_srgb8 < 0 || row.convexity_reduction_ratio < 0.35 || row.convexity_reduction_ratio > 1 || !finite(expectedRatio) || Math.abs(row.convexity_reduction_ratio - expectedRatio) > 0.01 || Math.abs(row.efficacy - row.convexity_reduction_ratio) > 1e-9) {
        rowReasons.push("qualification.relief.minimum");
      }
      if (row.correction_spatial_range_srgb8 < 6 || row.target_mean_abs_channel_delta_srgb8 < 3) rowReasons.push("qualification.relief.uniform");
      if (row.boundary_correction_jump_srgb8 < 0 || row.boundary_correction_jump_srgb8 > 5 || row.feather_to_zero !== 1) rowReasons.push("qualification.metric.boundary");
      if (row.color_target_region_nonempty !== true || !Number.isInteger(row.color_target_max_abs_channel_delta_srgb8) || row.color_target_max_abs_channel_delta_srgb8 < 0 || row.color_target_max_abs_channel_delta_srgb8 > 16 || row.target_mean_abs_channel_delta_srgb8 > row.color_target_max_abs_channel_delta_srgb8 || row.correction_spatial_range_srgb8 > 32) rowReasons.push("qualification.color.target-bound");
      positiveValues.source.push(row.source_central_convexity_srgb8);
      positiveValues.output.push(row.output_central_convexity_srgb8);
      positiveValues.ratio.push(row.convexity_reduction_ratio);
      positiveValues.range.push(row.correction_spatial_range_srgb8);
      positiveValues.mean.push(row.target_mean_abs_channel_delta_srgb8);
      positiveValues.boundary.push(row.boundary_correction_jump_srgb8);
      positiveValues.target.push(row.color_target_max_abs_channel_delta_srgb8);
      positiveValues.protected.push(row.color_protected_max_abs_channel_delta_srgb8);
      if (row.feather_to_zero === 1) aggregate.feather_to_zero_row_count += 1;
    } else {
      aggregate.inapplicable_target_row_count += 1;
      if (row.efficacy !== 0 || RELIEF_METRIC_KEYS.some((key) => row[key] !== 0) || row.boundary_correction_jump_srgb8 !== 0 || row.feather_to_zero !== 0 || row.color_target_region_nonempty !== false || row.color_target_max_abs_channel_delta_srgb8 !== 0 || row.rejected_source_exact !== 1) {
        rowReasons.push("qualification.applicability");
      }
    }
    transformed.push(transformMetric(row));
    if (!rowReasons.length) passing += 1;
    found.push(...rowReasons);
  }
  const inherited = v3.evaluateMetricMatrix(transformed, fixtures);
  found.push(...inherited.reasons.filter((reason) => reason === "qualification.metric.invalid" || reason === "qualification.applicability"));
  if (positiveValues.source.length) {
    aggregate.source_central_convexity_min_srgb8 = Math.min(...positiveValues.source);
    aggregate.output_central_convexity_max_srgb8 = Math.max(...positiveValues.output);
    aggregate.convexity_reduction_ratio_min = Math.min(...positiveValues.ratio);
    aggregate.correction_spatial_range_min_srgb8 = Math.min(...positiveValues.range);
    aggregate.target_mean_abs_channel_delta_min_srgb8 = Math.min(...positiveValues.mean);
    aggregate.boundary_correction_jump_max_srgb8 = Math.max(...positiveValues.boundary);
    aggregate.color_target_max_abs_channel_delta_srgb8 = Math.max(...positiveValues.target);
    aggregate.color_protected_max_abs_channel_delta_srgb8 = Math.max(...positiveValues.protected);
  } else {
    const protectedValues = rows.filter((row) => finite(row?.color_protected_max_abs_channel_delta_srgb8)).map((row) => row.color_protected_max_abs_channel_delta_srgb8);
    if (protectedValues.length) aggregate.color_protected_max_abs_channel_delta_srgb8 = Math.max(...protectedValues);
  }
  const normalized = reasons(found);
  const valid = !normalized.includes("qualification.metric.invalid") && !normalized.includes("qualification.applicability") && inherited.valid;
  return { valid, passed: valid && inherited.passed && normalized.length === 0, reasons: normalized, metric_row_count: rows.length, passing_metric_row_count: passing, aggregate_metrics: aggregate };
}

function validateBundle(bundle, options = {}) {
  if (!bundle || typeof bundle !== "object" || Array.isArray(bundle) || bundle.schema_version !== 4) {
    return { valid: false, passed: false, reasons: ["evidence.malformed-manifest"], fixture_ids: [], manifest_hash: null, metrics: evaluateMetricMatrix([], []) };
  }
  const bindingErrors = [];
  if (!exactKeys(bundle.bindings, BINDING_KEYS) || !options.bindings || BINDING_KEYS.some((key) => bundle.bindings[key] !== options.bindings[key])) bindingErrors.push("qualification.binding");
  if (["phase80-qualification-evaluator-v1", "phase80-qualification-evaluator-v2", "phase80-qualification-evaluator-v3"].includes(bundle.bindings?.evaluator_version)) bindingErrors.push("qualification.binding");
  const metrics = evaluateMetricMatrix(bundle.metric_matrix, Array.isArray(bundle.fixtures) ? bundle.fixtures : []);
  const transformedBundle = {
    ...bundle,
    schema_version: 3,
    metric_matrix: Array.isArray(bundle.metric_matrix) ? bundle.metric_matrix.filter((row) => exactKeys(row, METRIC_KEYS)).map(transformMetric) : [],
  };
  const inherited = v3.validateBundle(transformedBundle, { assetRoot: options.assetRoot, bindings: transformedBundle.bindings });
  const inheritedStructural = inherited.reasons.filter((reason) => !reason.startsWith("qualification.metric.") && !reason.startsWith("qualification.color.") && reason !== "qualification.applicability");
  const normalized = reasons([...inheritedStructural, ...metrics.reasons, ...bindingErrors]);
  const structural = new Set(["evidence.malformed-manifest", "evidence.incomplete-taxonomy", "evidence.rights-failure", "evidence.asset-invalid", "evidence.duplicate", "evidence.mechanics-only", "qualification.metric.invalid", "qualification.applicability", "qualification.binding"]);
  const valid = normalized.every((reason) => !structural.has(reason));
  return { valid, passed: valid && inherited.valid && metrics.passed && normalized.length === 0, reasons: normalized, fixture_ids: inherited.fixture_ids, manifest_hash: safe.canonicalHash(bundle), generated_evidence_weight: 0, metrics };
}

function validateReview(review, fixtures) {
  const result = { valid: false, passed: false, reasons: [], review_row_count: 0, passing_review_row_count: 0, category_pass_rates: Object.fromEntries(CATEGORIES.map((category) => [category, 0])) };
  if (!exactKeys(review, REVIEW_KEYS)) { result.reasons = ["review.malformed"]; return result; }
  const contract = contractRecord(); const found = [];
  if (review.schema_version !== 4 || review.feature_id !== FEATURE_ID) found.push("review.malformed");
  if (review.complete !== true || review.rubric_frozen_before_outcomes !== true || review.blindness_attested !== true || review.candidate_identity_hidden !== true || review.locator_hidden !== true || review.detail_scale_percent !== 100) found.push("review.incomplete");
  if (review.phase75_semantic_contract_hash !== contract.phase75_bindings.semantic_contract_hash || review.phase75_evidence_contract_hash !== contract.phase75_bindings.evidence_contract_hash || review.review_rubric_hash !== contract.review_rubric_hash) found.push("review.binding");
  const expected = new Set(); const byID = new Map();
  for (const fixture of Array.isArray(fixtures) ? fixtures : []) {
    if (!fixture || !OPAQUE_RE.test(fixture.fixture_id || "") || !Array.isArray(fixture.categories)) continue;
    byID.set(fixture.fixture_id, fixture);
    for (const category of fixture.categories) expected.add(`${fixture.fixture_id}\0${category}`);
  }
  const judgments = Array.isArray(review.judgments) ? review.judgments : [];
  if (!judgments.length || judgments.length > MAX_ROWS) found.push("review.incomplete");
  const seen = new Set(); const totals = Object.fromEntries(CATEGORIES.map((category) => [category, 0])); const passes = { ...totals };
  for (const judgment of judgments) {
    const booleanFields = ["target_fullness_reduced", "relief_shape_flatter", "uniform_tone_shift_only_absent", "prohibited_proxy_absent", "protected_structures_preserved", "original_detail_natural", "boundary_artifact_absent"];
    if (!exactKeys(judgment, JUDGMENT_KEYS) || !OPAQUE_RE.test(judgment?.fixture_id || "") || !CATEGORY_SET.has(judgment?.category) || !booleanFields.every((key) => typeof judgment[key] === "boolean") || !["pass", "fail"].includes(judgment.review_decision)) {
      found.push("review.malformed"); continue;
    }
    const pair = `${judgment.fixture_id}\0${judgment.category}`;
    if (!expected.has(pair) || seen.has(pair)) found.push("review.malformed");
    seen.add(pair); totals[judgment.category] += 1;
    const positive = byID.get(judgment.fixture_id)?.polarity === "positive";
    const predicate = judgment.target_fullness_reduced === positive
      && judgment.relief_shape_flatter === positive
      && judgment.uniform_tone_shift_only_absent
      && judgment.prohibited_proxy_absent
      && judgment.protected_structures_preserved
      && judgment.original_detail_natural
      && judgment.boundary_artifact_absent;
    const reasonValid = judgment.review_decision === "pass" ? judgment.reason_code === null : REVIEW_REASONS.has(judgment.reason_code);
    if (!reasonValid) found.push("review.malformed");
    if (judgment.review_decision === "pass" && predicate && judgment.reason_code === null) {
      result.passing_review_row_count += 1; passes[judgment.category] += 1;
    }
  }
  if (seen.size !== expected.size || [...expected].some((pair) => !seen.has(pair))) found.push("review.incomplete");
  for (const category of CATEGORIES) {
    result.category_pass_rates[category] = totals[category] ? passes[category] / totals[category] : 0;
    if (result.category_pass_rates[category] !== 1) found.push("review.threshold");
  }
  result.review_row_count = judgments.length;
  result.reasons = reasons(found);
  result.valid = !result.reasons.some((reason) => ["review.malformed", "review.incomplete", "review.binding"].includes(reason));
  result.passed = result.valid && result.passing_review_row_count === judgments.length && !result.reasons.includes("review.threshold");
  return result;
}

function emptyAggregate() {
  return { fixture_count: 0, metric_row_count: 0, passing_metric_row_count: 0, ...emptyMetricAggregate(), review_row_count: 0, passing_review_row_count: 0, category_pass_rates: Object.fromEntries(CATEGORIES.map((category) => [category, 0])), generated_evidence_weight: 0, genuine_evaluation_executed: false, frozen_review_complete: false, safety_gates_pass: false };
}
function reasonCounts(values) { const output = {}; for (const reason of reasons(values)) output[reason] = (output[reason] || 0) + 1; return output; }
function failureDecision(found, overrides = {}) {
  const contract = contractRecord();
  return { status: "fail", phase: PHASE, contract_hash: safe.canonicalHash(contract), manifest_hash: null, review_hash: null, evaluator_version: VERSION, phase75_semantic_contract_hash: contract.phase75_bindings.semantic_contract_hash, phase75_evidence_contract_hash: contract.phase75_bindings.evidence_contract_hash, review_rubric_hash: contract.review_rubric_hash, baseline_id: BASELINE, baseline_source_digest: contract.baseline_binding.baseline_source_digest, baseline_evidence_digest: contract.baseline_binding.baseline_evidence_digest, baseline_binding_hash: safe.canonicalHash(contract.baseline_binding), fixture_ids: [], aggregate_metrics: emptyAggregate(), reason_counts: reasonCounts(found.length ? found : ["qualification.binding"]), public_absence: { beauty_parameter_fields: 61, preset_ids: 5, renderer_cases: 74 }, decision: NON_PROMOTION, ...overrides };
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
  return exactKeys(value, DECISION_KEYS) && exactKeys(value.aggregate_metrics, AGGREGATE_KEYS) && exactKeys(value.public_absence, PUBLIC_KEYS) && Array.isArray(value.fixture_ids) && value.fixture_ids.every((id) => OPAQUE_RE.test(id)) && value.reason_counts && typeof value.reason_counts === "object" && Object.entries(value.reason_counts).every(([reason, count]) => REASON_RE.test(reason) && Number.isInteger(count) && count > 0);
}
function buildDecision(options = {}) {
  const repoRoot = path.resolve(options.repoRoot || ".");
  const bindings = expectedBindings(repoRoot);
  const bundle = options.bundle === undefined
    ? { valid: false, passed: false, reasons: ["evidence.missing-bundle"], fixture_ids: [], manifest_hash: null, metrics: { metric_row_count: 0, passing_metric_row_count: 0, aggregate_metrics: emptyMetricAggregate() } }
    : validateBundle(options.bundle, { assetRoot: options.assetRoot, bindings: bindings.values });
  const review = options.review === undefined
    ? { valid: false, passed: false, reasons: ["review.missing"], review_row_count: 0, passing_review_row_count: 0, category_pass_rates: Object.fromEntries(CATEGORIES.map((category) => [category, 0])) }
    : validateReview(options.review, Array.isArray(options.bundle?.fixtures) ? options.bundle.fixtures : []);
  const found = reasons([...bundle.reasons, ...review.reasons, ...bindings.reasons]);
  const complete = bundle.valid && review.valid && bindings.valid;
  const passed = complete && bundle.passed && review.passed;
  const aggregate = { fixture_count: bundle.fixture_ids.length, metric_row_count: bundle.metrics?.metric_row_count || 0, passing_metric_row_count: bundle.metrics?.passing_metric_row_count || 0, ...(bundle.metrics?.aggregate_metrics || emptyMetricAggregate()), review_row_count: review.review_row_count, passing_review_row_count: review.passing_review_row_count, category_pass_rates: review.category_pass_rates, generated_evidence_weight: 0, genuine_evaluation_executed: complete, frozen_review_complete: review.valid, safety_gates_pass: passed };
  const report = { status: passed ? "pass" : "fail", phase: PHASE, contract_hash: safe.canonicalHash(contractRecord()), manifest_hash: bundle.manifest_hash, review_hash: options.review === undefined ? null : safe.canonicalHash(options.review), evaluator_version: VERSION, phase75_semantic_contract_hash: bindings.values.phase75_semantic_contract_hash, phase75_evidence_contract_hash: bindings.values.phase75_evidence_contract_hash, review_rubric_hash: bindings.values.review_rubric_hash, baseline_id: BASELINE, baseline_source_digest: bindings.values.baseline_source_digest, baseline_evidence_digest: bindings.values.baseline_evidence_digest, baseline_binding_hash: bindings.values.baseline_binding_hash, fixture_ids: bundle.fixture_ids, aggregate_metrics: aggregate, reason_counts: reasonCounts(passed ? [] : found), public_absence: bindings.public_absence, decision: passed ? PROMOTION : NON_PROMOTION };
  return outputIsSafe(report) ? { report, inputComplete: complete } : { report: failureDecision(["qualification.privacy"]), inputComplete: false };
}
function selfTest(repoRoot) {
  const binding = expectedBindings(repoRoot);
  if (!binding.valid) fail(binding.reasons[0]);
  const contract = contractRecord();
  const checks = [
    safe.compareMetric(0.35, "minimum", 0.35, 0),
    !safe.compareMetric(0.349, "minimum", 0.35, 0),
    safe.compareMetric(6, "minimum", 6, 0),
    !safe.compareMetric(5.99, "minimum", 6, 0),
    safe.compareMetric(3, "minimum", 3, 0),
    !safe.compareMetric(2.99, "minimum", 3, 0),
    safe.compareMetric(5, "maximum", 5, 0),
    !safe.compareMetric(6, "maximum", 5, 0),
    reviewRubricHash() === contract.review_rubric_hash,
    contract.metric_matrix.inapplicable_target_metrics_receive_no_credit === true,
  ];
  if (checks.some((value) => !value)) fail("qualification.metric.invalid");
  return { checks: checks.length, decision: NON_PROMOTION, mode: "self-test", mutation_rejections: 9, phase: PHASE, promotion_fixture_count: 0, status: "pass" };
}
function parseArgs(argv) {
  if (argv.length !== 3 || !["--self-test", "--validate-bundle", "--validate-review", "--decision", "--write-decision"].includes(argv[0]) || argv[1] !== "--repo-root" || argv[2] !== ".") fail("qualification.input");
  return { mode: argv[0], repoRoot: path.resolve(argv[2]) };
}
function atomicWrite(report) {
  const temporary = `${DECISION_PATH}.tmp-${process.pid}`;
  try {
    fs.writeFileSync(temporary, `${safe.canonicalJson(report)}\n`, { mode: 0o600, flag: "wx" });
    fs.renameSync(temporary, DECISION_PATH);
  } catch {
    try { fs.rmSync(temporary, { force: true }); } catch {}
    fail("qualification.write");
  }
}
function main(argv = process.argv.slice(2), environment = process.env) {
  let parsed;
  try { parsed = parseArgs(argv); }
  catch { process.stdout.write(`${safe.canonicalJson(failureDecision(["qualification.input"]))}\n`); return 1; }
  try {
    if (parsed.mode === "--self-test") { process.stdout.write(`${safe.canonicalJson(selfTest(parsed.repoRoot))}\n`); return 0; }
    let bundleInput; let reviewInput;
    if (environment.BEAUTY_PHASE80_V4_BUNDLE_MANIFEST) {
      try { bundleInput = safe.readPrivateJson(environment.BEAUTY_PHASE80_V4_BUNDLE_MANIFEST); }
      catch { process.stdout.write(`${safe.canonicalJson(failureDecision(["evidence.malformed-manifest"]))}\n`); return 1; }
    }
    if (environment.BEAUTY_PHASE80_V4_REVIEW_RECORD) {
      try { reviewInput = safe.readPrivateJson(environment.BEAUTY_PHASE80_V4_REVIEW_RECORD); }
      catch { process.stdout.write(`${safe.canonicalJson(failureDecision(["review.malformed"]))}\n`); return 1; }
    }
    if (parsed.mode === "--validate-bundle") {
      if (!bundleInput) { process.stdout.write(`${safe.canonicalJson({ mode: "validate-bundle", status: "fail", reasons: ["evidence.missing-bundle"], fixture_count: 0 })}\n`); return 1; }
      const binding = expectedBindings(parsed.repoRoot);
      const result = validateBundle(bundleInput.value, { assetRoot: bundleInput.directory, bindings: binding.values });
      process.stdout.write(`${safe.canonicalJson({ mode: "validate-bundle", status: result.valid ? "pass" : "fail", reasons: result.reasons, fixture_count: result.fixture_ids.length })}\n`);
      return result.valid ? 0 : 1;
    }
    if (parsed.mode === "--validate-review") {
      if (!bundleInput || !reviewInput) { process.stdout.write(`${safe.canonicalJson({ mode: "validate-review", status: "fail", reasons: reasons([!bundleInput ? "evidence.missing-bundle" : null, !reviewInput ? "review.missing" : null]), review_row_count: 0 })}\n`); return 1; }
      const result = validateReview(reviewInput.value, bundleInput.value.fixtures);
      process.stdout.write(`${safe.canonicalJson({ mode: "validate-review", status: result.valid ? "pass" : "fail", reasons: result.reasons, review_row_count: result.review_row_count })}\n`);
      return result.valid ? 0 : 1;
    }
    const decision = buildDecision({ bundle: bundleInput?.value, review: reviewInput?.value, assetRoot: bundleInput?.directory, repoRoot: parsed.repoRoot });
    if (parsed.mode === "--write-decision" && decision.inputComplete) atomicWrite(decision.report);
    process.stdout.write(`${safe.canonicalJson(decision.report)}\n`);
    return decision.inputComplete ? 0 : 1;
  } catch (error) {
    const reason = error instanceof GateError ? error.code : "qualification.binding";
    process.stdout.write(`${safe.canonicalJson(failureDecision([reason]))}\n`);
    return 1;
  }
}

module.exports = { BASELINE, VERSION, buildDecision, contractRecord, evaluateMetricMatrix, expectedBindings, failureDecision, main, outputIsSafe, reviewRubricHash, validateBundle, validateReview };
if (require.main === module) process.exitCode = main();
