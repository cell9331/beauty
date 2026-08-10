"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const ROOT = path.resolve(__dirname, "..", "..", "..");
const BUNDLE_MARKER = ["teeth", "evidence", "20260805"].join("-");
const ACTIVE_SENSITIVE = new RegExp([
  ["teeth", "evidence", "20260805"].join("-"),
  ["teeth", "evidence", "20260805"].join("_"),
  ["user", "authorization", "20260805"].join("_"),
  ["Tooth", "white"].join("-") + "\\.png",
  ["Tooth", "yellow"].join("-") + "\\.png",
].join("|"), "i");
const REVIEW_FREE_TEXT = new RegExp([
  ["review", "er"].join("") + "\\s*[:=]",
  ["review", "_note"].join("") + "\\s*[:=]",
  ["review", "er_note"].join("") + "\\s*[:=]",
  ["free", "form"].join("") + "\\s*[:=]",
  ["user", "_said"].join("") + "\\s*[:=]",
  ["visual", "_feedback"].join("") + "\\s*[:=]",
].join("|"), "i");

function sha256(filePath) {
  return require("node:crypto").createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function fixed(status, extra = {}) {
  process.stdout.write(`${JSON.stringify({ status, ...extra })}\n`);
}

function ignoredFiles() {
  const result = spawnSync("git", ["ls-files", "--others", "--ignored", "--exclude-standard", "-z"], {
    cwd: ROOT,
    encoding: "buffer",
  });
  if (result.status !== 0) throw new Error("ignored_file_scan_failed");
  return result.stdout.toString("utf8").split("\0").filter(Boolean);
}

function manifestLooksLikeTeeth(root) {
  try {
    const value = JSON.parse(fs.readFileSync(path.join(ROOT, root, "manifest.json"), "utf8"));
    return value?.schema_version === 1 && Array.isArray(value.fixtures)
      && value.fixtures.length === 2 && value.fixtures.every((row) => row?.feature === "teeth_whitening")
      && new Set(value.fixtures.map((row) => row.polarity)).size === 2;
  } catch (_) {
    return false;
  }
}

function discoverBundle() {
  const candidates = new Set();
  for (const file of ignoredFiles()) {
    if (!file.endsWith("/manifest.json") || !file.includes(BUNDLE_MARKER)) continue;
    const root = path.posix.dirname(file);
    if (manifestLooksLikeTeeth(root)) candidates.add(root);
  }
  if (candidates.size !== 1) throw new Error(candidates.size === 0 ? "ignored_teeth_bundle_missing" : "ignored_teeth_bundle_ambiguous");
  return path.resolve(ROOT, [...candidates][0]);
}

function assertIgnoredBundle(bundle) {
  const relative = path.relative(ROOT, bundle);
  const files = ignoredFiles();
  const required = ["manifest.json", "fixture_001/original.png", "fixture_001/mask.png", "fixture_001/after.png", "fixture_002/original.png", "fixture_002/mask.png", "fixture_002/after.png"]
    .map((file) => path.posix.join(relative.split(path.sep).join("/"), file));
  if (!required.every((file) => files.includes(file))) throw new Error("teeth_bundle_not_fully_ignored");
}

function isHistorical(file) {
  return file.startsWith(".planning/milestones/")
    || file.startsWith(".planning/spikes/")
    || file.startsWith(".codex/skills/");
}

function containsSensitiveContent(content, file, localDigests) {
  return ACTIVE_SENSITIVE.test(content)
    || (!isHistorical(file) && REVIEW_FREE_TEXT.test(content))
    || [...localDigests].some((digest) => content.includes(digest));
}

function runChild(command) {
  const bundle = discoverBundle();
  assertIgnoredBundle(bundle);
  const child = spawnSync(command[0], command.slice(1), {
    cwd: ROOT,
    env: { ...process.env, PHASE59_TEETH_BUNDLE: bundle },
    encoding: "utf8",
  });
  const combined = `${child.stdout || ""}\n${child.stderr || ""}`;
  if (combined.includes(bundle) || combined.includes(BUNDLE_MARKER)) throw new Error("local_path_leak");
  if (child.status !== 0) throw new Error("local_evidence_child_failed");
  fixed("pass");
}

function trackedStagedPrivacyScan() {
  const bundle = discoverBundle();
  assertIgnoredBundle(bundle);
  const localDigests = new Set();
  for (const fixture of ["fixture_001", "fixture_002"]) {
    for (const asset of ["original", "mask", "after"]) {
      localDigests.add(sha256(path.join(bundle, fixture, `${asset}.png`)));
    }
  }
  const tracked = spawnSync("git", ["ls-files", "-z"], { cwd: ROOT, encoding: "buffer" });
  if (tracked.status !== 0) throw new Error("tracked_file_scan_failed");
  const files = tracked.stdout.toString("utf8").split("\0").filter(Boolean);
  const values = [];
  for (const file of files) {
    const content = fs.readFileSync(path.join(ROOT, file), "utf8");
    if (containsSensitiveContent(content, file, localDigests)) {
      throw new Error("tracked_sensitive_content");
    }
    values.push(content);
  }
  const stagedNames = spawnSync("git", ["diff", "--cached", "--name-only", "-z", "--", "."], {
    cwd: ROOT,
    encoding: "buffer",
  });
  if (stagedNames.status !== 0) throw new Error("staged_file_scan_failed");
  for (const file of stagedNames.stdout.toString("utf8").split("\0").filter(Boolean)) {
    const staged = spawnSync("git", ["show", `:${file}`], { cwd: ROOT, encoding: "utf8" });
    if (staged.status !== 0) continue;
    if (containsSensitiveContent(staged.stdout, file, localDigests)) {
      throw new Error("staged_sensitive_content");
    }
  }
  fixed("pass", { tracked_file_count: values.length });
}

function main() {
  try {
    const argv = process.argv.slice(2);
    if (argv[0] === "--scan-tracked-staged") trackedStagedPrivacyScan();
    else if (argv[0] === "--") runChild(argv.slice(1));
    else throw new Error("runner_usage");
  } catch (error) {
    fixed("fail");
    process.exitCode = 1;
  }
}

if (require.main === module) main();
module.exports = { assertIgnoredBundle, discoverBundle, trackedStagedPrivacyScan };
