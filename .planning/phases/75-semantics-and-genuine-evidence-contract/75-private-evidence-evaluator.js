#!/usr/bin/env node
"use strict";

/*
 * Phase-75 local evidence boundary. This process accepts only metadata and
 * aggregate output into the repository-facing process. A caller may point it
 * at a private local manifest, but this file never reads or emits image bytes.
 */

const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

const CONTRACT_PATH = path.join(__dirname, "75-EVIDENCE-CONTRACT.md");
const REQUIRED_CATEGORIES = [
  "genuine-positive",
  "genuine-negative",
  "ambiguity",
  "pose-occlusion",
  "identity-diversity",
  "protected-structure",
];
const REQUIRED_FIXTURE_KEYS = [
  "feature_id",
  "fixture_id",
  "polarity",
  "rights_status",
  "rights_record_id",
  "owner_provenance_version",
  "content_hash",
  "asset_roles",
  "categories",
];
const REQUIRED_ASSET_ROLES = ["original", "support-envelope", "candidate-output"];
const DURABLE_KEYS = [
  "contract_hash",
  "manifest_hash",
  "fixture_ids",
  "aggregate_metrics",
  "reason_counts",
  "decision",
];
const SENSITIVE = /(?:path|locator|pixel|mask|landmark|coordinate|geometry|raw|private|biometric|descriptor|prose|output)/i;

function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return null;
  }
}

function canonicalEvidenceRecords() {
  const source = fs.readFileSync(CONTRACT_PATH, "utf8");
  const match = source.match(
    /<!-- CANONICAL_EVIDENCE_RECORDS_BEGIN -->\n```json\n([\s\S]*?)\n```\n<!-- CANONICAL_EVIDENCE_RECORDS_END -->/,
  );
  if (!match) throw new Error("evidence.contract-missing");
  return JSON.parse(match[1]);
}

function contractHash() {
  return sha256(JSON.stringify(canonicalEvidenceRecords()));
}

function parseArguments(argv) {
  const args = { mode: null, manifest: null, emitManifest: null };
  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    if (["--self-test", "--validate", "--aggregate", "--export"].includes(token)) {
      if (args.mode) throw new Error("evaluator.multiple-modes");
      args.mode = token.slice(2);
    } else if (token === "--manifest" || token === "--emit-manifest") {
      const value = argv[index + 1];
      if (!value || value.startsWith("--")) throw new Error("evaluator.missing-argument");
      args[token.slice(2) === "manifest" ? "manifest" : "emitManifest"] = value;
      index += 1;
    } else if (token === "--help") {
      args.mode = "help";
    } else {
      throw new Error("evaluator.unknown-argument");
    }
  }
  if (!args.mode) throw new Error("evaluator.unknown-mode");
  return args;
}

function errorResult(mode, reason) {
  return { status: "fail", mode, reasons: [reason], reason_count: 1 };
}

function validateManifest(manifest) {
  if (!manifest || typeof manifest !== "object" || Array.isArray(manifest)) {
    return ["evidence.malformed-manifest"];
  }
  const errors = [];
  const expectedKeys = ["version", "feature_id", "contract_version", "contract_hash", "admission_mode", "fixtures"];
  if (JSON.stringify(Object.keys(manifest).sort()) !== JSON.stringify(expectedKeys.sort())) {
    errors.push("evidence.manifest-keys");
  }
  if (manifest.version !== 1 || manifest.contract_version !== 1) errors.push("evidence.manifest-version");
  if (manifest.feature_id !== "upper-eyelid-fullness-reduction") errors.push("evidence.feature-id");
  if (manifest.contract_hash !== contractHash()) errors.push("evidence.contract-hash");
  if (!["genuine-private", "metadata-only-self-test"].includes(manifest.admission_mode)) {
    errors.push("evidence.admission-mode");
  }
  if (!Array.isArray(manifest.fixtures) || manifest.fixtures.length < 2) {
    errors.push("evidence.fixture-count");
    return errors;
  }

  const ids = new Set();
  const categories = new Set();
  const polarities = new Set();
  for (const fixture of manifest.fixtures) {
    if (!fixture || typeof fixture !== "object" || Array.isArray(fixture)) {
      errors.push("evidence.fixture-malformed");
      continue;
    }
    if (JSON.stringify(Object.keys(fixture).sort()) !== JSON.stringify(REQUIRED_FIXTURE_KEYS.slice().sort())) {
      errors.push("evidence.fixture-keys");
      continue;
    }
    if (fixture.feature_id !== manifest.feature_id) errors.push("evidence.fixture-feature");
    if (typeof fixture.fixture_id !== "string" || !/^[a-z0-9][a-z0-9-]{2,63}$/.test(fixture.fixture_id)) {
      errors.push("evidence.fixture-id");
    } else if (ids.has(fixture.fixture_id)) {
      errors.push("evidence.duplicate-fixture-id");
    } else {
      ids.add(fixture.fixture_id);
    }
    if (!["positive", "negative"].includes(fixture.polarity)) errors.push("evidence.polarity");
    else polarities.add(fixture.polarity);
    if (fixture.rights_status !== "approved_internal_evaluation") errors.push("evidence.rights");
    if (typeof fixture.rights_record_id !== "string" || !/^rights-[a-z0-9-]+$/.test(fixture.rights_record_id)) {
      errors.push("evidence.rights-record");
    }
    if (typeof fixture.owner_provenance_version !== "string" || !/^v[0-9]+$/.test(fixture.owner_provenance_version)) {
      errors.push("evidence.provenance");
    }
    if (typeof fixture.content_hash !== "string" || !/^[a-f0-9]{64}$/.test(fixture.content_hash)) {
      errors.push("evidence.content-hash");
    }
    if (JSON.stringify(fixture.asset_roles) !== JSON.stringify(REQUIRED_ASSET_ROLES)) {
      errors.push("evidence.asset-roles");
    }
    if (!Array.isArray(fixture.categories) || fixture.categories.length === 0) {
      errors.push("evidence.categories");
    } else {
      for (const category of fixture.categories) {
        if (!REQUIRED_CATEGORIES.includes(category)) errors.push("evidence.unknown-category");
        categories.add(category);
      }
    }
  }
  for (const category of REQUIRED_CATEGORIES) {
    if (!categories.has(category)) errors.push(`evidence.category.${category}`);
  }
  if (!polarities.has("positive")) errors.push("evidence.missing-positive");
  if (!polarities.has("negative")) errors.push("evidence.missing-negative");
  if (manifest.admission_mode === "genuine-private" && manifest.fixtures.some((fixture) => fixture.metadata_only === true)) {
    errors.push("evidence.synthetic-in-genuine-bundle");
  }
  return [...new Set(errors)].sort();
}

function outputIsSafe(value) {
  const encoded = JSON.stringify(value);
  if (encoded.includes("/") || encoded.includes("\\")) return false;
  const walk = (candidate) => {
    if (Array.isArray(candidate)) return candidate.every(walk);
    if (!candidate || typeof candidate !== "object") return typeof candidate !== "string" || !SENSITIVE.test(candidate);
    return Object.entries(candidate).every(([key, entry]) => !SENSITIVE.test(key) && walk(entry));
  };
  return walk(value);
}

function aggregate(manifest, mode) {
  const fixtureIds = manifest.fixtures.map((fixture) => fixture.fixture_id).sort();
  const result = {
    contract_hash: manifest.contract_hash,
    manifest_hash: sha256(JSON.stringify(manifest)),
    fixture_ids: fixtureIds,
    aggregate_metrics: {
      fixture_count: fixtureIds.length,
      genuine_positive_count: manifest.fixtures.filter((fixture) => fixture.polarity === "positive").length,
      genuine_negative_count: manifest.fixtures.filter((fixture) => fixture.polarity === "negative").length,
      mechanics_only: manifest.admission_mode === "metadata-only-self-test",
    },
    reason_counts: {},
    decision: manifest.admission_mode === "metadata-only-self-test"
      ? "mechanics-only-not-promotion"
      : "eligible-for-phase-78-evaluation",
  };
  if (JSON.stringify(Object.keys(result).sort()) !== JSON.stringify(DURABLE_KEYS.slice().sort()) || !outputIsSafe(result)) {
    return errorResult(mode, "evidence.privacy-export-failure");
  }
  return { status: "pass", mode, ...result };
}

function selfTestManifest() {
  const contract = contractHash();
  const fixtures = [
    ["self-positive", "positive", ["genuine-positive", "identity-diversity", "protected-structure"]],
    ["self-negative", "negative", ["genuine-negative", "ambiguity"]],
    ["self-pose", "negative", ["pose-occlusion"]],
  ].map(([fixtureId, polarity, categories]) => ({
    feature_id: "upper-eyelid-fullness-reduction",
    fixture_id: fixtureId,
    polarity,
    rights_status: "approved_internal_evaluation",
    rights_record_id: `rights-${fixtureId}`,
    owner_provenance_version: "v1",
    content_hash: sha256(`metadata-only-${fixtureId}`),
    asset_roles: REQUIRED_ASSET_ROLES.slice(),
    categories,
  }));
  return {
    version: 1,
    feature_id: "upper-eyelid-fullness-reduction",
    contract_version: 1,
    contract_hash: contract,
    admission_mode: "metadata-only-self-test",
    fixtures,
  };
}

function runSelfTest(emitPath) {
  const manifest = selfTestManifest();
  const checks = [];
  const expectError = (candidate, prefix) => {
    const result = validateManifest(candidate);
    checks.push(result.some((reason) => reason.startsWith(prefix)));
  };
  expectError(null, "evidence.malformed");
  expectError({ ...manifest, contract_hash: "0".repeat(64) }, "evidence.contract-hash");
  expectError({ ...manifest, fixtures: manifest.fixtures.slice(0, 1) }, "evidence.fixture-count");
  const duplicate = structuredClone(manifest);
  duplicate.fixtures[1].fixture_id = duplicate.fixtures[0].fixture_id;
  expectError(duplicate, "evidence.duplicate-fixture-id");
  const rights = structuredClone(manifest);
  rights.fixtures[0].rights_status = "unapproved";
  expectError(rights, "evidence.rights");
  const category = structuredClone(manifest);
  category.fixtures[2].categories = ["unknown"];
  expectError(category, "evidence.unknown-category");
  const keys = structuredClone(manifest);
  keys.fixtures[0].raw = "blocked";
  expectError(keys, "evidence.fixture-keys");
  const exported = aggregate(manifest, "export");
  checks.push(exported.status === "pass" && outputIsSafe(exported));
  const unsafe = { ...exported, raw: "blocked" };
  checks.push(!outputIsSafe(unsafe));
  checks.push(outputIsSafe(errorResult("validate", "evidence.malformed-manifest")));
  if (!checks.every(Boolean)) return errorResult("self-test", "evidence.self-test-failure");
  if (emitPath) {
    try {
      fs.writeFileSync(emitPath, `${JSON.stringify(manifest, null, 2)}\n`, { encoding: "utf8", mode: 0o600 });
    } catch {
      return errorResult("self-test", "evidence.self-test-emit-failure");
    }
  }
  return {
    status: "pass",
    mode: "self-test",
    check_count: checks.length,
    mutation_rejections: checks.length - 3,
    mechanics_only: true,
  };
}

function main(argv) {
  let args;
  try {
    args = parseArguments(argv);
  } catch (error) {
    return errorResult("argument", error.message);
  }
  if (args.mode === "help") {
    console.log("phase75-evidence-evaluator: --self-test [--emit-manifest FILE] | --validate|--aggregate|--export --manifest FILE");
    return 0;
  }
  if (args.mode === "self-test") {
    const result = runSelfTest(args.emitManifest);
    console.log(JSON.stringify(result, Object.keys(result).sort()));
    return result.status === "pass" ? 0 : 1;
  }
  const manifest = args.manifest ? readJson(args.manifest) : null;
  if (!manifest) {
    console.log(JSON.stringify(errorResult(args.mode, "evidence.missing-bundle")));
    return 1;
  }
  const errors = validateManifest(manifest);
  if (errors.length) {
    console.log(JSON.stringify({ status: "fail", mode: args.mode, reasons: errors, reason_count: errors.length }));
    return 1;
  }
  if (args.mode === "validate") {
    const result = {
      status: "pass",
      mode: "validate",
      admission: manifest.admission_mode === "metadata-only-self-test" ? "mechanics-only" : "genuine-bundle-complete",
      fixture_count: manifest.fixtures.length,
      category_count: REQUIRED_CATEGORIES.length,
    };
    console.log(JSON.stringify(result));
    return 0;
  }
  const result = aggregate(manifest, args.mode);
  console.log(JSON.stringify(result));
  return result.status === "pass" ? 0 : 1;
}

process.exitCode = main(process.argv.slice(2));
