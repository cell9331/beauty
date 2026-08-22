#!/usr/bin/env node
"use strict";

/*
 * Phase-78 aggregate decision boundary. The Phase-75 process remains the
 * evidence admission authority. This process sees only its JSON summaries and
 * never reads, copies, or prints image-derived material.
 */

const crypto = require("node:crypto");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const childProcess = require("node:child_process");

const PHASE = 78;
const PHASE75_EVALUATOR = path.join(
  __dirname,
  "..",
  "75-semantics-and-genuine-evidence-contract",
  "75-private-evidence-evaluator.js",
);
const PHASE75_CONTRACT = path.join(
  __dirname,
  "..",
  "75-semantics-and-genuine-evidence-contract",
  "75-EVIDENCE-CONTRACT.md",
);
const DURABLE_KEYS = [
  "contract_hash",
  "manifest_hash",
  "fixture_ids",
  "aggregate_metrics",
  "reason_counts",
  "decision",
];
const REPORT_KEYS = ["status", "phase", ...DURABLE_KEYS];
const METRIC_KEYS = [
  "baseline",
  "baseline_disposition",
  "comparator",
  "comparator_disposition",
  "fixture_count",
  "genuine_evaluation_executed",
  "frozen_review_complete",
  "safety_gates_pass",
];
const COMPARATOR_KEYS = [
  "candidate_id",
  "model_rights_status",
  "data_rights_status",
  "redistribution_rights_status",
  "bounded_additive_map",
  "all_safety_gates_pass",
  "materially_outperforms_baseline",
];
const EVALUATION_KEYS = [
  "efficacy_pass",
  "containment_pass",
  "texture_retention_pass",
  "geometry_protected_structures_pass",
  "metadata_integrity_pass",
  "no_op_pass",
  "deterministic_repeatability_pass",
  "blinded_review_pass",
  "prohibited_proxy_absent",
  "protected_structures_preserved",
];
const BASELINE = "deterministic-editor";
const COMPARATOR = "optional-additive-map";
const DECISION = "mechanics-only-not-promotion";
const SENSITIVE_KEY = /(?:path|locator|pixel|mask|landmark|coordinate|geometry|raw|private|biometric|descriptor|prose|output)/i;

function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function contractHash() {
  const source = fs.readFileSync(PHASE75_CONTRACT, "utf8");
  const match = source.match(
    /<!-- CANONICAL_EVIDENCE_RECORDS_BEGIN -->\n```json\n([\s\S]*?)\n```\n<!-- CANONICAL_EVIDENCE_RECORDS_END -->/,
  );
  if (!match) throw new Error("evidence.contract-missing");
  return sha256(JSON.stringify(JSON.parse(match[1])));
}

function sortedUnique(values) {
  return [...new Set(values)].sort();
}

function reasonCounts(reasons) {
  return reasons.reduce((counts, reason) => {
    counts[reason] = (counts[reason] || 0) + 1;
    return counts;
  }, {});
}

function phase75Run(mode, manifestPath) {
  const args = [PHASE75_EVALUATOR, `--${mode}`];
  if (manifestPath) args.push("--manifest", manifestPath);
  const child = childProcess.spawnSync(process.execPath, args, {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
    timeout: 20_000,
  });
  if (!child.stdout) return { status: "fail", reasons: ["evidence.evaluator-failure"] };
  try {
    return JSON.parse(child.stdout.trim());
  } catch {
    return { status: "fail", reasons: ["evidence.evaluator-failure"] };
  }
}

function comparatorAdmission(descriptor) {
  if (descriptor == null) {
    return { admitted: false, reason: "candidate.comparator-not-admitted" };
  }
  if (
    typeof descriptor !== "object" ||
    Array.isArray(descriptor) ||
    JSON.stringify(Object.keys(descriptor).sort()) !== JSON.stringify(COMPARATOR_KEYS.slice().sort())
  ) {
    return { admitted: false, reason: "candidate.comparator-malformed" };
  }
  if (descriptor.model_rights_status !== "approved_internal_evaluation") {
    return { admitted: false, reason: "candidate.model-rights-failure" };
  }
  if (descriptor.data_rights_status !== "approved_internal_evaluation") {
    return { admitted: false, reason: "candidate.data-rights-failure" };
  }
  if (descriptor.redistribution_rights_status !== "approved_internal_evaluation") {
    return { admitted: false, reason: "candidate.redistribution-rights-failure" };
  }
  if (descriptor.bounded_additive_map !== true) {
    return { admitted: false, reason: "candidate.unbounded-additive-map" };
  }
  if (descriptor.all_safety_gates_pass !== true) {
    return { admitted: false, reason: "candidate.safety-gate-failure" };
  }
  if (descriptor.materially_outperforms_baseline !== true) {
    return { admitted: false, reason: "candidate.not-superior-to-baseline" };
  }
  return { admitted: true, reason: "candidate.comparator-admitted" };
}

function evaluationErrors(evaluation) {
  if (
    !evaluation ||
    typeof evaluation !== "object" ||
    Array.isArray(evaluation) ||
    JSON.stringify(Object.keys(evaluation).sort()) !== JSON.stringify(EVALUATION_KEYS.slice().sort())
  ) {
    return ["evaluation.missing-frozen-results"];
  }
  return EVALUATION_KEYS
    .filter((key) => evaluation[key] !== true)
    .map((key) => `evaluation.${key}`);
}

function outputIsSafe(value) {
  const encoded = JSON.stringify(value);
  if (encoded.includes("/") || encoded.includes("\\")) return false;
  const walk = (candidate) => {
    if (Array.isArray(candidate)) return candidate.every(walk);
    if (!candidate || typeof candidate !== "object") {
      return typeof candidate !== "string" || !SENSITIVE_KEY.test(candidate);
    }
    return Object.entries(candidate).every(([key, entry]) => !SENSITIVE_KEY.test(key) && walk(entry));
  };
  return walk(value);
}

function report({
  status = "fail",
  manifestHash = null,
  fixtureIds = [],
  fixtureCount = 0,
  reasons = [],
  genuineEvaluationExecuted = false,
  frozenReviewComplete = false,
  safetyGatesPass = false,
  comparatorDisposition = "not-admitted",
  decision = DECISION,
}) {
  const normalizedReasons = sortedUnique(reasons.length ? reasons : ["evidence.missing-bundle"]);
  return {
    status,
    phase: PHASE,
    contract_hash: contractHash(),
    manifest_hash: manifestHash,
    fixture_ids: fixtureIds.slice().sort(),
    aggregate_metrics: {
      baseline: BASELINE,
      baseline_disposition: "mechanics-only",
      comparator: COMPARATOR,
      comparator_disposition: comparatorDisposition,
      fixture_count: fixtureCount,
      genuine_evaluation_executed: genuineEvaluationExecuted,
      frozen_review_complete: frozenReviewComplete,
      safety_gates_pass: safetyGatesPass,
    },
    reason_counts: reasonCounts(normalizedReasons),
    decision,
  };
}

function reportFromFailure(reasons, extras = {}) {
  return report({ reasons: sortedUnique(reasons), ...extras });
}

function decide({ manifestPath = null, evaluation = null, comparator = null } = {}) {
  if (!manifestPath) {
    return reportFromFailure(["evidence.missing-bundle"]);
  }
  const validation = phase75Run("validate", manifestPath);
  if (validation.status !== "pass") {
    return reportFromFailure(validation.reasons || ["evidence.malformed-manifest"]);
  }
  const aggregate = phase75Run("aggregate", manifestPath);
  if (aggregate.status !== "pass") {
    return reportFromFailure(aggregate.reasons || ["evidence.privacy-export-failure"]);
  }
  const fixtureCount = Number(aggregate.aggregate_metrics?.fixture_count) || 0;
  const fixtureIds = Array.isArray(aggregate.fixture_ids) ? aggregate.fixture_ids : [];
  if (aggregate.aggregate_metrics?.mechanics_only === true) {
    return reportFromFailure(["evidence.metadata-only-mechanics"], {
      manifestHash: aggregate.manifest_hash || null,
      fixtureIds,
      fixtureCount,
    });
  }

  const evaluationFailures = evaluationErrors(evaluation);
  if (evaluationFailures.length) {
    return reportFromFailure(evaluationFailures, {
      manifestHash: aggregate.manifest_hash || null,
      fixtureIds,
      fixtureCount,
    });
  }
  const comparatorResult = comparatorAdmission(comparator);
  if (!comparatorResult.admitted && comparator != null && comparatorResult.reason !== "candidate.comparator-not-admitted") {
    return reportFromFailure([comparatorResult.reason], {
      manifestHash: aggregate.manifest_hash || null,
      fixtureIds,
      fixtureCount,
      genuineEvaluationExecuted: true,
      frozenReviewComplete: true,
    });
  }
  const selectedComparator = comparatorResult.admitted;
  return report({
    status: "pass",
    manifestHash: aggregate.manifest_hash || null,
    fixtureIds,
    fixtureCount,
    reasons: selectedComparator ? [] : ["candidate.baseline-selected"],
    genuineEvaluationExecuted: true,
    frozenReviewComplete: true,
    safetyGatesPass: true,
    comparatorDisposition: selectedComparator ? "admitted-superior" : "not-admitted",
    decision: selectedComparator ? "promotion-ready-comparator" : "promotion-ready-baseline",
  });
}

function writeManifest(root, manifest) {
  const file = path.join(root, "manifest.json");
  fs.writeFileSync(file, `${JSON.stringify(manifest)}\n`, { encoding: "utf8", mode: 0o600 });
  return file;
}

function metadataOnlyFixture() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "beauty-phase78-"));
  const emitted = phase75Run("self-test", null);
  if (emitted.status !== "pass") throw new Error("evidence.self-test-failure");
  const manifest = {
    version: 1,
    feature_id: "upper-eyelid-fullness-reduction",
    contract_version: 1,
    contract_hash: contractHash(),
    admission_mode: "metadata-only-self-test",
    fixtures: [
      {
        feature_id: "upper-eyelid-fullness-reduction",
        fixture_id: "phase78-positive",
        polarity: "positive",
        rights_status: "approved_internal_evaluation",
        rights_record_id: "rights-phase78-positive",
        owner_provenance_version: "v1",
        content_hash: sha256("phase78-metadata-positive"),
        asset_roles: ["original", "support-envelope", "candidate-output"],
        categories: ["genuine-positive", "identity-diversity", "protected-structure"],
      },
      {
        feature_id: "upper-eyelid-fullness-reduction",
        fixture_id: "phase78-negative",
        polarity: "negative",
        rights_status: "approved_internal_evaluation",
        rights_record_id: "rights-phase78-negative",
        owner_provenance_version: "v1",
        content_hash: sha256("phase78-metadata-negative"),
        asset_roles: ["original", "support-envelope", "candidate-output"],
        categories: ["genuine-negative", "ambiguity", "pose-occlusion"],
      },
    ],
  };
  return { root, manifest, file: writeManifest(root, manifest) };
}

function runSelfTest() {
  const checks = [];
  const fixture = metadataOnlyFixture();
  try {
    const missing = decide();
    checks.push(missing.reason_counts["evidence.missing-bundle"] === 1 && missing.decision === DECISION);

    const mechanics = decide({ manifestPath: fixture.file });
    checks.push(mechanics.decision === DECISION && mechanics.aggregate_metrics.baseline_disposition === "mechanics-only");
    checks.push(outputIsSafe(mechanics));
    checks.push(JSON.stringify(mechanics) === JSON.stringify(decide({ manifestPath: fixture.file })));

    const rightsManifest = structuredClone(fixture.manifest);
    rightsManifest.fixtures[0].rights_status = "unapproved";
    const rightsFile = writeManifest(fixture.root, rightsManifest);
    const rights = decide({ manifestPath: rightsFile });
    checks.push(rights.reason_counts["evidence.rights"] === 1 && rights.decision === DECISION);

    checks.push(comparatorAdmission(null).reason === "candidate.comparator-not-admitted");
    checks.push(comparatorAdmission({}).reason === "candidate.comparator-malformed");
    const unapprovedComparator = Object.fromEntries(COMPARATOR_KEYS.map((key) => [key, true]));
    unapprovedComparator.candidate_id = "candidate";
    checks.push(comparatorAdmission(unapprovedComparator).reason === "candidate.model-rights-failure");

    const approvedShape = {
      candidate_id: "candidate",
      model_rights_status: "approved_internal_evaluation",
      data_rights_status: "approved_internal_evaluation",
      redistribution_rights_status: "approved_internal_evaluation",
      bounded_additive_map: true,
      all_safety_gates_pass: true,
      materially_outperforms_baseline: true,
    };
    checks.push(comparatorAdmission(approvedShape).admitted === true);
    checks.push(evaluationErrors(null)[0] === "evaluation.missing-frozen-results");

    const unsafe = { ...mechanics, pixels: "forbidden" };
    checks.push(!outputIsSafe(unsafe));
    checks.push(!outputIsSafe({ ...mechanics, private_locator: "forbidden" }));
  } finally {
    fs.rmSync(fixture.root, { recursive: true, force: true });
  }
  if (!checks.every(Boolean)) {
    return { status: "fail", mode: "self-test", reason_count: 1, reasons: ["candidate.self-test-failure"] };
  }
  return {
    status: "pass",
    mode: "self-test",
    check_count: checks.length,
    mutation_rejections: 8,
    decision: DECISION,
    comparator: "not-admitted",
  };
}

function parseArguments(argv) {
  const args = { mode: null, manifest: null };
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (["--self-test", "--decision"].includes(token)) {
      if (args.mode) throw new Error("candidate.multiple-modes");
      args.mode = token.slice(2);
    } else if (token === "--manifest") {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error("candidate.missing-argument");
      args.manifest = value;
      index += 1;
    } else if (token === "--help") {
      args.mode = "help";
    } else {
      throw new Error("candidate.unknown-argument");
    }
  }
  if (!args.mode) throw new Error("candidate.unknown-mode");
  return args;
}

function main(argv) {
  try {
    const args = parseArguments(argv);
    if (args.mode === "help") {
      console.log("phase78-candidate-decision: --self-test | --decision [--manifest FILE]");
      return 0;
    }
    if (args.mode === "self-test") {
      const result = runSelfTest();
      console.log(JSON.stringify(result, Object.keys(result).sort()));
      return result.status === "pass" ? 0 : 1;
    }
    const result = decide({ manifestPath: args.manifest });
    console.log(JSON.stringify(result, Object.keys(result).sort()));
    return result.status === "pass" ? 0 : 1;
  } catch (error) {
    console.log(JSON.stringify({ status: "fail", mode: "argument", reasons: [error.message] }));
    return 1;
  }
}

module.exports = {
  COMPARATOR_KEYS,
  DECISION,
  decide,
  comparatorAdmission,
  evaluationErrors,
  outputIsSafe,
  runSelfTest,
};

if (require.main === module) process.exitCode = main(process.argv.slice(2));
