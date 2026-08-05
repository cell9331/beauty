"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");

const phaseDir = __dirname;
const contract = fs.readFileSync(path.join(phaseDir, "59-EVIDENCE-ADMISSION-CONTRACT.md"), "utf8");
const inventory = JSON.parse(fs.readFileSync(path.join(phaseDir, "59-THREAT-INVENTORY.json"), "utf8"));
const decisions = JSON.parse(fs.readFileSync(
  path.join(__dirname, "../../milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-EVIDENCE-DECISIONS.json"),
  "utf8",
));

const expectedReasons = ["missing_genuine_positive", "missing_genuine_negative"];
const expectedDecision = {
  feature: "teeth_whitening",
  status: "closed",
  reasons: expectedReasons,
  eligible_count: 0,
  reviewed_count: 0,
  accepted_count: 0,
  rejected_count: 0,
  naturalness_weight: 0,
};

assert.match(contract, /phase: 59/);
assert.match(contract, /decision: closed/);
assert.match(contract, /portrait_002/);
assert.match(contract, /Phase 60\/61/);
assert.deepStrictEqual(inventory.threats.map((threat) => threat.id), [
  "T-59-01", "T-59-02", "T-59-03", "T-59-04",
  "T-59-05", "T-59-06", "T-59-07", "T-59-08",
]);
assert.ok(inventory.threats.every((threat) => threat.severity === "HIGH" && threat.disposition === "mitigate"));

const teethRows = decisions.feature_decisions.filter((row) => row.feature === "teeth_whitening");
assert.strictEqual(teethRows.length, 1);
assert.deepStrictEqual(teethRows[0], expectedDecision);
assert.strictEqual(decisions.feature_decisions.filter((row) => /teeth|tooth/i.test(row.feature)).length, 1);
assert.strictEqual(decisions.reviews.length, 0);
assert.strictEqual(decisions.aggregates.find((row) => row.feature === "teeth_whitening").naturalness_weight, 0);

const forbiddenDurableKeys = /(?:path|hash|sha|media|mask|pixel|coordinate|landmark|reviewer|rights_record|raw_error)/i;
for (const threat of inventory.threats) {
  for (const gate of threat.gates) assert.ok(typeof gate === "string" && gate.length > 0);
}
assert.ok(!forbiddenDurableKeys.test(JSON.stringify(expectedDecision)));
assert.deepStrictEqual(expectedReasons, ["missing_genuine_positive", "missing_genuine_negative"]);
console.log(JSON.stringify({ status: "pass", threatCount: inventory.threats.length, decision: "closed" }));
