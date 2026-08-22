"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");
const childProcess = require("node:child_process");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const gate = require("./78-candidate-decision.js");
const phase75 = path.join(
  __dirname,
  "..",
  "75-semantics-and-genuine-evidence-contract",
  "75-private-evidence-evaluator.js",
);

function metadataManifest() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "beauty-phase78-test-"));
  const file = path.join(root, "manifest.json");
  const emitted = childProcess.spawnSync(process.execPath, [phase75, "--self-test", "--emit-manifest", file], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
  });
  assert.equal(emitted.status, 0);
  return { root, file, manifest: JSON.parse(fs.readFileSync(file, "utf8")) };
}

function write(root, manifest) {
  const file = path.join(root, "candidate.json");
  fs.writeFileSync(file, `${JSON.stringify(manifest)}\n`, { encoding: "utf8", mode: 0o600 });
  return file;
}

test("missing bundle is typed and cannot promote", () => {
  const result = gate.decide();
  assert.equal(result.decision, gate.DECISION);
  assert.equal(result.reason_counts["evidence.missing-bundle"], 1);
  assert.equal(result.aggregate_metrics.genuine_evaluation_executed, false);
});

test("metadata-only Phase-75 evidence remains mechanics-only", () => {
  const fixture = metadataManifest();
  try {
    const first = gate.decide({ manifestPath: fixture.file });
    const second = gate.decide({ manifestPath: fixture.file });
    assert.deepEqual(first, second);
    assert.equal(first.decision, gate.DECISION);
    assert.equal(first.reason_counts["evidence.metadata-only-mechanics"], 1);
    assert.equal(first.aggregate_metrics.baseline, "deterministic-editor");
    assert.equal(first.aggregate_metrics.comparator_disposition, "not-admitted");
    assert.equal(gate.outputIsSafe(first), true);
  } finally {
    fs.rmSync(fixture.root, { recursive: true, force: true });
  }
});

test("rights and taxonomy failures remain Phase-75 failures", () => {
  const fixture = metadataManifest();
  try {
    const rights = structuredClone(fixture.manifest);
    rights.fixtures[0].rights_status = "unapproved";
    const rightsResult = gate.decide({ manifestPath: write(fixture.root, rights) });
    assert.equal(rightsResult.reason_counts["evidence.rights"], 1);
    assert.equal(rightsResult.decision, gate.DECISION);

    const taxonomy = structuredClone(fixture.manifest);
    taxonomy.fixtures[1].categories = ["genuine-negative"];
    const taxonomyResult = gate.decide({ manifestPath: write(fixture.root, taxonomy) });
    assert.equal(taxonomyResult.reason_counts["evidence.category.ambiguity"], 1);
    assert.equal(taxonomyResult.decision, gate.DECISION);
  } finally {
    fs.rmSync(fixture.root, { recursive: true, force: true });
  }
});

test("additive comparator requires every rights and safety gate", () => {
  assert.equal(gate.comparatorAdmission(null).reason, "candidate.comparator-not-admitted");
  assert.equal(gate.comparatorAdmission({}).reason, "candidate.comparator-malformed");
  const descriptor = Object.fromEntries(gate.COMPARATOR_KEYS.map((key) => [key, true]));
  descriptor.candidate_id = "candidate";
  descriptor.model_rights_status = "unapproved";
  assert.equal(gate.comparatorAdmission(descriptor).reason, "candidate.model-rights-failure");
  descriptor.model_rights_status = "approved_internal_evaluation";
  descriptor.data_rights_status = "approved_internal_evaluation";
  descriptor.redistribution_rights_status = "approved_internal_evaluation";
  descriptor.bounded_additive_map = false;
  assert.equal(gate.comparatorAdmission(descriptor).reason, "candidate.unbounded-additive-map");
  descriptor.bounded_additive_map = true;
  descriptor.all_safety_gates_pass = false;
  assert.equal(gate.comparatorAdmission(descriptor).reason, "candidate.safety-gate-failure");
});

test("frozen review and privacy gates cannot be omitted", () => {
  assert.deepEqual(gate.evaluationErrors(null), ["evaluation.missing-frozen-results"]);
  const valid = Object.fromEntries([
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
  ].map((key) => [key, true]));
  assert.deepEqual(gate.evaluationErrors(valid), []);
  assert.equal(gate.outputIsSafe({ pixels: "forbidden" }), false);
  assert.equal(gate.outputIsSafe({ private_locator: "forbidden" }), false);
});

test("self-test covers isolated mutation rejection", () => {
  const result = gate.runSelfTest();
  assert.equal(result.status, "pass");
  assert.equal(result.mutation_rejections, 8);
  assert.equal(result.decision, gate.DECISION);
});
