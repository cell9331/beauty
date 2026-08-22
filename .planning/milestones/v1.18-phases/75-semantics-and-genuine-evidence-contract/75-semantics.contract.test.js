"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const CONTRACT_PATH = path.join(__dirname, "75-SEMANTICS-CONTRACT.md");
const PROXY_IDS = [
  "smoothing",
  "whitening",
  "eye-enlargement",
  "brow-movement",
  "crease-invention",
  "upper-eyelid-lift",
  "warp",
];

function readCanonicalRecords() {
  const source = fs.readFileSync(CONTRACT_PATH, "utf8");
  const match = source.match(
    /<!-- CANONICAL_RECORDS_BEGIN -->\n```json\n([\s\S]*?)\n```\n<!-- CANONICAL_RECORDS_END -->/,
  );
  assert.ok(match, "contract must contain one canonical JSON record block");
  return JSON.parse(match[1]);
}

function semanticErrors(records) {
  const errors = [];
  if (!records || records.version !== 1) errors.push("contract.version");
  if (records.effect?.id !== "upper-eyelid-fullness-reduction") {
    errors.push("contract.effect");
  }
  if (records.landmark_role !== "envelope-and-pose-guard-only") {
    errors.push("contract.landmark_role");
  }
  for (const proxy of records.prohibited_proxies ?? []) {
    if (proxy.negative?.accepts !== false) errors.push(`proxy.${proxy.id}`);
  }
  if (!records.predicates?.authorization_inputs?.includes("approved-semantic-evidence")) {
    errors.push("predicate.semantic-evidence");
  }
  if (records.predicates?.ambiguous_outcome !== "exact-no-op") {
    errors.push("predicate.ambiguous-no-op");
  }
  return errors;
}

test("semantic contract is a cosmetic still-image definition with explicit nonclaims", () => {
  const records = readCanonicalRecords();
  assert.equal(records.version, 1);
  assert.deepEqual(Object.keys(records).sort(), [
    "effect",
    "landmark_role",
    "nonclaims",
    "predicates",
    "prohibited_proxies",
    "protected_structures",
    "version",
  ]);
  assert.deepEqual(records.effect, {
    id: "upper-eyelid-fullness-reduction",
    medium: "still-image",
    intent: "cosmetic-visual-reduction-of-upper-eyelid-fullness",
    authority: "visual-review-only",
  });
  assert.equal(records.landmark_role, "envelope-and-pose-guard-only");
  assert.ok(records.nonclaims.includes("physical-fat"));
  assert.ok(records.nonclaims.includes("anatomy"));
  assert.ok(records.nonclaims.includes("health"));
  assert.ok(records.nonclaims.includes("diagnosis"));
  assert.ok(records.nonclaims.includes("surgical-outcome"));
});

test("each prohibited proxy has an independently mutation-testable reason", () => {
  const records = readCanonicalRecords();
  assert.deepEqual(records.prohibited_proxies.map((proxy) => proxy.id), PROXY_IDS);
  for (const proxy of records.prohibited_proxies) {
    assert.deepEqual(Object.keys(proxy).sort(), ["id", "negative"]);
    assert.equal(proxy.negative.accepts, false);
    assert.equal(typeof proxy.negative.reason, "string");
    const mutated = structuredClone(records);
    const target = mutated.prohibited_proxies.find((candidate) => candidate.id === proxy.id);
    target.negative.accepts = true;
    assert.notDeepEqual(mutated, records, `${proxy.id} mutation must be observable`);
    assert.deepEqual(semanticErrors(mutated), [`proxy.${proxy.id}`]);
    assert.equal(proxy.negative.reason.startsWith("proxy."), true);
  }
});

test("landmark-only and isolated observations cannot authorize the effect", () => {
  const records = readCanonicalRecords();
  assert.deepEqual(records.predicates.authorization_inputs, [
    "approved-semantic-evidence",
    "visual-fullness-reduction",
    "protected-structure-preserved",
  ]);
  assert.deepEqual(records.predicates.observations_without_authority, [
    "landmark-only",
    "brow-only",
    "eye-aperture-only",
    "crease-only",
    "texture-only",
    "color-only",
  ]);
  assert.equal(records.predicates.ambiguous_outcome, "exact-no-op");
});

test("protected structures are preservation obligations without raw values", () => {
  const records = readCanonicalRecords();
  assert.deepEqual(records.protected_structures, [
    "eye-content",
    "lash-and-crease-structure",
    "brow-geometry",
    "identity-detail",
    "exterior-pixels",
  ]);
  assert.equal(JSON.stringify(records).includes("raw"), false);
  assert.equal(JSON.stringify(records).includes("landmark_points"), false);
});
