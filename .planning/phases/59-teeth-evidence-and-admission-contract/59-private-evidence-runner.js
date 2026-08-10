"use strict";

const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const crypto = require("node:crypto");
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
const MAX_MANIFEST_BYTES = 256 * 1024;
const MAX_ASSET_BYTES = 32 * 1024 * 1024;
const ASSET_FIELDS = ["original", "mask", "after"];

function sha256(filePath) {
  assertNoSymlinkComponents(filePath);
  return crypto.createHash("sha256").update(readBoundedRegular(filePath, MAX_ASSET_BYTES)).digest("hex");
}

function fixed(status, extra = {}) {
  process.stdout.write(`${JSON.stringify({ status, ...extra })}\n`);
}

function ignoredFiles() {
  const result = spawnSync("git", ["ls-files", "--others", "--ignored", "--exclude-standard", "-z"], {
    cwd: ROOT,
    encoding: "buffer",
    timeout: 20_000,
  });
  if (result.status !== 0 || result.error) throw new Error("ignored_file_scan_failed");
  return parseNulInventory(result.stdout);
}

function safeRelativeKey(value) {
  return typeof value === "string"
    && value.length > 0
    && value.length <= 256
    && !path.posix.isAbsolute(value)
    && !value.includes("\\")
    && !value.includes("\0")
    && !value.includes(":")
    && value.split("/").every((component) => component && component !== "." && component !== "..");
}

function parseNulInventory(value) {
  const content = Buffer.isBuffer(value) ? value.toString("utf8") : value;
  if (typeof content !== "string") throw new Error("inventory_type_invalid");
  if (content === "") return [];
  if (!content.endsWith("\0")) throw new Error("inventory_nul_terminator_missing");
  const files = content.slice(0, -1).split("\0");
  const normalized = files.map((file) => file.endsWith("/") ? file.slice(0, -1) : file);
  if (normalized.some((file) => !safeRelativeKey(file)) || new Set(files).size !== files.length) {
    throw new Error("inventory_entry_invalid");
  }
  return files;
}

function readBoundedRegular(filePath, maximumBytes) {
  let descriptor;
  try {
    if (!fs.constants.O_NOFOLLOW) throw new Error("nofollow_unavailable");
    descriptor = fs.openSync(filePath, fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW);
    const metadata = fs.fstatSync(descriptor);
    if (!metadata.isFile() || metadata.size < 1 || metadata.size > maximumBytes) {
      throw new Error("bounded_regular_file_required");
    }
    return fs.readFileSync(descriptor);
  } finally {
    if (descriptor !== undefined) fs.closeSync(descriptor);
  }
}

function assertNoSymlinkComponents(target, floor = ROOT) {
  const relative = path.relative(floor, target);
  if (!relative || relative === ".." || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) {
    throw new Error("path_containment_failed");
  }
  let current = floor;
  for (const component of relative.split(path.sep).filter(Boolean)) {
    current = path.join(current, component);
    const metadata = fs.lstatSync(current);
    if (metadata.isSymbolicLink()) throw new Error("symlink_component");
  }
}

function manifestShape(value) {
  if (!value || value.schema_version !== 1 || !Array.isArray(value.fixtures) || value.fixtures.length !== 2) {
    return false;
  }
  const polarities = new Set();
  const fixtureIDs = new Set();
  for (const row of value.fixtures) {
    if (!row || row.feature !== "teeth_whitening"
      || !["positive", "negative"].includes(row.polarity)
      || row.rights_status !== "approved_internal_evaluation"
      || typeof row.fixture_id !== "string" || row.fixture_id.length === 0
      || fixtureIDs.has(row.fixture_id) || polarities.has(row.polarity)
      || !row.assets || typeof row.assets !== "object") {
      return false;
    }
    fixtureIDs.add(row.fixture_id);
    polarities.add(row.polarity);
    const directory = row.polarity === "positive" ? "fixture_001" : "fixture_002";
    if (ASSET_FIELDS.some((field) => row.assets[field] !== `${directory}/${field}.png`)) return false;
  }
  return polarities.has("positive") && polarities.has("negative");
}

function readManifest(relativeRoot) {
  if (!safeRelativeKey(relativeRoot)) return null;
  try {
    const target = path.join(ROOT, relativeRoot, "manifest.json");
    assertNoSymlinkComponents(target);
    const value = JSON.parse(readBoundedRegular(target, MAX_MANIFEST_BYTES).toString("utf8"));
    return manifestShape(value) ? value : null;
  } catch (_) {
    return null;
  }
}

function candidateRoots(files = ignoredFiles()) {
  const roots = new Set();
  for (const file of files) {
    if (!file.endsWith("/manifest.json") || !file.includes(BUNDLE_MARKER) || !safeRelativeKey(file)) continue;
    const root = path.posix.dirname(file);
    if (readManifest(root)) roots.add(root);
  }
  return [...roots].sort();
}

function selectSingleCandidate(candidates) {
  if (!Array.isArray(candidates) || candidates.length !== 1) {
    throw new Error(candidates?.length === 0
      ? "ignored_teeth_bundle_missing"
      : "ignored_teeth_bundle_ambiguous");
  }
  return candidates[0];
}

function discoverBundle() {
  return path.resolve(ROOT, selectSingleCandidate(candidateRoots()));
}

function assertIgnoredBundle(bundle) {
  const relative = path.relative(ROOT, bundle).split(path.sep).join("/");
  if (!safeRelativeKey(relative)) throw new Error("teeth_bundle_outside_root");
  assertNoSymlinkComponents(bundle);
  const manifest = readManifest(relative);
  if (!manifest) throw new Error("teeth_manifest_invalid");
  const ignored = new Set(ignoredFiles());
  const required = [path.posix.join(relative, "manifest.json")];
  for (const row of manifest.fixtures) {
    for (const field of ASSET_FIELDS) {
      const key = row.assets[field];
      if (!safeRelativeKey(key)) throw new Error("teeth_asset_key_invalid");
      const absolute = path.join(bundle, key);
      assertNoSymlinkComponents(absolute);
      readBoundedRegular(absolute, MAX_ASSET_BYTES);
      required.push(path.posix.join(relative, key));
    }
  }
  if (required.length !== 7 || !required.every((file) => ignored.has(file))) {
    throw new Error("teeth_bundle_not_fully_ignored");
  }
  return manifest;
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

function runSelfTests() {
  let rejected = 0;
  const expectFailure = (callback) => {
    try { callback(); } catch (_) { rejected += 1; return; }
    throw new Error("self_test_mutation_not_rejected");
  };
  const validManifest = () => ({
    schema_version: 1,
    fixtures: [
      {
        fixture_id: "opaque_positive",
        feature: "teeth_whitening",
        polarity: "positive",
        rights_status: "approved_internal_evaluation",
        assets: Object.fromEntries(ASSET_FIELDS.map((field) => [field, `fixture_001/${field}.png`])),
      },
      {
        fixture_id: "opaque_negative",
        feature: "teeth_whitening",
        polarity: "negative",
        rights_status: "approved_internal_evaluation",
        assets: Object.fromEntries(ASSET_FIELDS.map((field) => [field, `fixture_002/${field}.png`])),
      },
    ],
  });
  if (!manifestShape(validManifest())) throw new Error("valid_manifest_rejected");
  expectFailure(() => parseNulInventory("one\0two"));
  expectFailure(() => parseNulInventory("one\0one\0"));
  expectFailure(() => selectSingleCandidate([]));
  expectFailure(() => selectSingleCandidate(["one", "two"]));
  expectFailure(() => {
    if (safeRelativeKey("../escape")) return;
    throw new Error("unsafe_key_rejected");
  });
  const wrongAsset = validManifest();
  wrongAsset.fixtures[0].assets.original = "fixture_002/original.png";
  expectFailure(() => {
    if (manifestShape(wrongAsset)) return;
    throw new Error("wrong_asset_rejected");
  });
  const duplicatePolarity = validManifest();
  duplicatePolarity.fixtures[1].polarity = "positive";
  expectFailure(() => {
    if (manifestShape(duplicatePolarity)) return;
    throw new Error("duplicate_polarity_rejected");
  });

  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "phase59-runner-self-test-"));
  try {
    const regular = path.join(temporary, "regular.bin");
    const link = path.join(temporary, "link.bin");
    const directory = path.join(temporary, "directory");
    const directoryLink = path.join(temporary, "directory-link");
    fs.writeFileSync(regular, "bounded");
    fs.symlinkSync(regular, link);
    fs.mkdirSync(directory);
    fs.writeFileSync(path.join(directory, "asset.bin"), "bounded");
    fs.symlinkSync(directory, directoryLink);
    expectFailure(() => readBoundedRegular(link, 1024));
    expectFailure(() => assertNoSymlinkComponents(path.join(directoryLink, "asset.bin"), temporary));
  } finally {
    fs.rmSync(temporary, { recursive: true, force: true });
  }
  if (rejected !== 9) throw new Error("self_test_count_invalid");
  return rejected;
}

function main() {
  try {
    const argv = process.argv.slice(2);
    if (argv[0] === "--self-test" && argv.length === 1) fixed("pass", { mutation_rejections: runSelfTests() });
    else if (argv[0] === "--scan-tracked-staged") trackedStagedPrivacyScan();
    else if (argv[0] === "--") runChild(argv.slice(1));
    else throw new Error("runner_usage");
  } catch (error) {
    fixed("fail");
    process.exitCode = 1;
  }
}

if (require.main === module) main();
module.exports = {
  assertIgnoredBundle,
  assertNoSymlinkComponents,
  candidateRoots,
  discoverBundle,
  manifestShape,
  parseNulInventory,
  readBoundedRegular,
  runSelfTests,
  safeRelativeKey,
  selectSingleCandidate,
  trackedStagedPrivacyScan,
};
