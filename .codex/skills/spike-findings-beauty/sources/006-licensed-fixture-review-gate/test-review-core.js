"use strict";

const fs = require("fs");
const path = require("path");
const core = require("./review-core.js");

const checks = [];
function check(name, condition) {
  checks.push({ name, pass: Boolean(condition) });
  if (!condition) throw new Error(`FAIL: ${name}`);
}
function manifest(rightsStatus = "mechanics_only") {
  return {
    schema_version: 1,
    dataset: {
      dataset_id: "dataset_001",
      documentation_record_id: "docs_001",
      intended_use: "internal_product_evaluation",
      retention_policy: "Local evaluation only",
    },
    fixtures: [
      {
        fixture_id: "positive_001",
        feature: "teeth_whitening",
        polarity: "positive",
        rights_status: rightsStatus,
        rights_record_id: "rights_001",
        assets: { original: "assets/p-original.png", mask: "assets/p-mask.png", after: "assets/p-after.png" },
      },
      {
        fixture_id: "negative_001",
        feature: "teeth_whitening",
        polarity: "negative",
        rights_status: rightsStatus,
        rights_record_id: "rights_002",
        assets: { original: "assets/n-original.png", mask: "assets/n-mask.png", after: "assets/n-after.png" },
      },
    ],
  };
}

const assets = [
  "bundle/assets/p-original.png", "bundle/assets/p-mask.png", "bundle/assets/p-after.png",
  "bundle/assets/n-original.png", "bundle/assets/n-mask.png", "bundle/assets/n-after.png",
];

const mechanics = core.validateManifest(manifest(), assets);
check("mechanics manifest is structurally valid", mechanics.valid);
check("mechanics manifest cannot open product gate", !mechanics.productEvidenceReady);

const approvedManifest = manifest("approved_internal_evaluation");
const approved = core.validateManifest(approvedManifest, assets);
check("approved positive and negative assets open gate", approved.productEvidenceReady);

const unsafe = manifest("approved_internal_evaluation");
unsafe.fixtures[0].assets.original = "/Users/person/private.png";
check("absolute path is rejected", !core.validateManifest(unsafe, assets).valid);

const duplicate = manifest("approved_internal_evaluation");
duplicate.fixtures[1].fixture_id = duplicate.fixtures[0].fixture_id;
check("duplicate fixture ID is rejected", !core.validateManifest(duplicate, assets).valid);

const reviews = approvedManifest.fixtures.map((fixture) => ({
  fixture_id: fixture.fixture_id,
  target_present: fixture.polarity === "positive",
  mask_coverage: fixture.polarity === "positive" ? 4 : 1,
  protected_leakage: false,
  naturalness: 4,
  structure_changed: false,
  decision: "accept",
  reason_code: "none",
}));
const exported = core.buildSanitizedExport(approvedManifest, reviews, new Date("2026-07-29T00:00:00Z"));
const serialized = JSON.stringify(exported);
check("export contains every review", exported.summary.review_count === 2);
check("export omits asset paths", !serialized.includes("assets/"));
check("export omits rights record IDs", !serialized.includes("rights_"));
check("export omits retention and documentation records", !serialized.includes("retention") && !serialized.includes("docs_001"));

const result = { pass: true, checks, checkCount: checks.length };
const outputPath = path.join(__dirname, "artifacts", "core-test.json");
fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, JSON.stringify(result, null, 2) + "\n");
console.log(`PASS: ${checks.length}/${checks.length}`);
