"use strict";

const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const { spawnSync } = require("node:child_process");

const ROOT = path.resolve(__dirname, "..", "..", "..");
const PHASE59_DIR = path.join(
  ROOT,
  ".planning/phases/59-teeth-evidence-and-admission-contract",
);
const TeethRunner = require(path.join(PHASE59_DIR, "59-private-evidence-runner.js"));
const MAX_MANIFEST_BYTES = 256 * 1024;
const MAX_ASSET_BYTES = 32 * 1024 * 1024;
const ASSET_FIELDS = ["original", "mask", "after"];

const ACTIVE_SENSITIVE = new RegExp([
  ["/Us", "ers/", "[^\\s\\\"']+", "/Down", "loads/"].join(""),
  ["rights", "_holder"].join("") + "\\s*[:=]",
  ["reviewer", "_email"].join("") + "\\s*[:=]",
  ["subject", "_name"].join("") + "\\s*[:=]",
  ["sclera", "-evidence"].join("") + "-[0-9]{8}",
  ["local-retouch", "-review"].join("") + "/[^\\s]+sclera",
].join("|"), "i");
const REVIEW_FREE_TEXT = new RegExp([
  ["review", "er_note"].join("") + "\\s*[:=]",
  ["review", "_note"].join("") + "\\s*[:=]",
  ["free", "form"].join("") + "\\s*[:=]",
  ["visual", "_feedback"].join("") + "\\s*[:=]",
  ["user", "_said"].join("") + "\\s*[:=]",
].join("|"), "i");

function fixed(status, extra = {}) {
  process.stdout.write(`${JSON.stringify({ status, ...extra })}\n`);
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex");
}

function ignoredFiles() {
  const result = spawnSync(
    "git",
    ["ls-files", "--others", "--ignored", "--exclude-standard", "-z"],
    { cwd: ROOT, encoding: "buffer", timeout: 20_000 },
  );
  if (result.status !== 0 || result.error) throw new Error("ignored_file_scan_failed");
  return result.stdout.toString("utf8").split("\0").filter(Boolean);
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

function readBoundedRegular(filePath, maximumBytes) {
  let descriptor;
  try {
    descriptor = fs.openSync(
      filePath,
      fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW || 0),
    );
    const stat = fs.fstatSync(descriptor);
    if (!stat.isFile() || stat.size < 1 || stat.size > maximumBytes) {
      throw new Error("bounded_regular_file_required");
    }
    return fs.readFileSync(descriptor);
  } finally {
    if (descriptor !== undefined) fs.closeSync(descriptor);
  }
}

function manifestShape(value) {
  if (!value || value.schema_version !== 1 || !Array.isArray(value.fixtures) || value.fixtures.length !== 2) {
    return false;
  }
  if (!value.fixtures.every((row) => row && row.feature === "sclera_redness")) return false;
  if (new Set(value.fixtures.map((row) => row.fixture_id)).size !== 2) return false;
  return new Set(value.fixtures.map((row) => row.polarity)).size === 2
    && value.fixtures.some((row) => row.polarity === "positive")
    && value.fixtures.some((row) => row.polarity === "negative");
}

function readManifest(relativeRoot) {
  if (!safeRelativeKey(relativeRoot)) return null;
  try {
    const bytes = readBoundedRegular(path.join(ROOT, relativeRoot, "manifest.json"), MAX_MANIFEST_BYTES);
    const value = JSON.parse(bytes.toString("utf8"));
    return manifestShape(value) ? value : null;
  } catch (_) {
    return null;
  }
}

function candidateRoots(files = ignoredFiles()) {
  const roots = new Set();
  for (const file of files) {
    if (!file.endsWith("/manifest.json") || !safeRelativeKey(file)) continue;
    const root = path.posix.dirname(file);
    if (readManifest(root)) roots.add(root);
  }
  return [...roots].sort();
}

function discoverBundle() {
  const candidates = candidateRoots();
  if (candidates.length !== 1) {
    throw new Error(candidates.length === 0 ? "ignored_sclera_bundle_missing" : "ignored_sclera_bundle_ambiguous");
  }
  return path.resolve(ROOT, candidates[0]);
}

function assertIgnoredBundle(bundle) {
  const relative = path.relative(ROOT, bundle).split(path.sep).join("/");
  if (!safeRelativeKey(relative)) throw new Error("sclera_bundle_outside_root");
  const manifest = readManifest(relative);
  if (!manifest) throw new Error("sclera_manifest_invalid");
  const ignored = new Set(ignoredFiles());
  const required = [path.posix.join(relative, "manifest.json")];
  for (const row of manifest.fixtures) {
    if (!row.assets || typeof row.assets !== "object") throw new Error("sclera_assets_invalid");
    for (const field of ASSET_FIELDS) {
      const key = row.assets[field];
      if (!safeRelativeKey(key)) throw new Error("sclera_asset_key_invalid");
      required.push(path.posix.join(relative, key));
      readBoundedRegular(path.join(bundle, key), MAX_ASSET_BYTES);
    }
  }
  if (required.length !== 7 || !required.every((file) => ignored.has(file))) {
    throw new Error("sclera_bundle_not_fully_ignored");
  }
  return manifest;
}

function isHistorical(file) {
  return file.startsWith(".planning/milestones/")
    || file.startsWith(".planning/spikes/")
    || file.startsWith(".codex/skills/");
}

function containsSensitiveContent(content, file, localDigests = new Set()) {
  return ACTIVE_SENSITIVE.test(content)
    || (!isHistorical(file) && REVIEW_FREE_TEXT.test(content))
    || [...localDigests].some((digest) => content.includes(digest));
}

function localDigestsIfAvailable() {
  const digests = new Set();
  let scleraBundle;
  try {
    scleraBundle = discoverBundle();
    const manifest = assertIgnoredBundle(scleraBundle);
    for (const row of manifest.fixtures) {
      for (const field of ASSET_FIELDS) digests.add(sha256(path.join(scleraBundle, row.assets[field])));
    }
  } catch (_) {
    scleraBundle = null;
  }
  if (scleraBundle) {
    const teethBundle = TeethRunner.discoverBundle();
    for (const fixture of ["fixture_001", "fixture_002"]) {
      for (const field of ASSET_FIELDS) digests.add(sha256(path.join(teethBundle, fixture, `${field}.png`)));
    }
  }
  return digests;
}

function trackedStagedPrivacyScan({ closed = false } = {}) {
  const localDigests = closed ? new Set() : localDigestsIfAvailable();
  if (!closed && localDigests.size === 0) throw new Error("local_sclera_bundle_required");
  const tracked = spawnSync("git", ["ls-files", "-z"], {
    cwd: ROOT,
    encoding: "buffer",
    timeout: 20_000,
  });
  if (tracked.status !== 0 || tracked.error) throw new Error("tracked_file_scan_failed");
  const files = tracked.stdout.toString("utf8").split("\0").filter(Boolean);
  for (const file of files) {
    const content = fs.readFileSync(path.join(ROOT, file), "utf8");
    if (containsSensitiveContent(content, file, localDigests)) throw new Error("tracked_sensitive_content");
  }
  const stagedNames = spawnSync("git", ["diff", "--cached", "--name-only", "-z", "--", "."], {
    cwd: ROOT,
    encoding: "buffer",
    timeout: 20_000,
  });
  if (stagedNames.status !== 0 || stagedNames.error) throw new Error("staged_file_scan_failed");
  for (const file of stagedNames.stdout.toString("utf8").split("\0").filter(Boolean)) {
    const staged = spawnSync("git", ["show", `:${file}`], {
      cwd: ROOT,
      encoding: "utf8",
      timeout: 20_000,
    });
    if (staged.status !== 0 || staged.error) continue;
    if (containsSensitiveContent(staged.stdout, file, localDigests)) throw new Error("staged_sensitive_content");
  }
  return { tracked_file_count: files.length };
}

function runChild(command) {
  if (!Array.isArray(command) || command.length === 0) throw new Error("runner_command_missing");
  const scleraBundle = discoverBundle();
  assertIgnoredBundle(scleraBundle);
  const teethBundle = TeethRunner.discoverBundle();
  const child = spawnSync(command[0], command.slice(1), {
    cwd: ROOT,
    env: {
      ...process.env,
      PHASE62_SCLERA_BUNDLE: scleraBundle,
      PHASE59_TEETH_BUNDLE: teethBundle,
    },
    encoding: "utf8",
    timeout: 120_000,
  });
  const combined = `${child.stdout || ""}\n${child.stderr || ""}`;
  if (combined.includes(scleraBundle) || combined.includes(teethBundle)) throw new Error("local_path_leak");
  if (child.status !== 0 || child.error) throw new Error("local_evidence_child_failed");
}

function main() {
  try {
    const argv = process.argv.slice(2);
    if (argv[0] === "--scan-tracked-staged") {
      const closed = argv[1] === "--closed";
      if (argv.length !== (closed ? 2 : 1)) throw new Error("runner_usage");
      fixed("pass", trackedStagedPrivacyScan({ closed }));
    } else if (argv[0] === "--verify-bundle" && argv.length === 1) {
      assertIgnoredBundle(discoverBundle());
      fixed("pass");
    } else if (argv[0] === "--") {
      runChild(argv.slice(1));
      fixed("pass");
    } else {
      throw new Error("runner_usage");
    }
  } catch (_) {
    fixed("fail");
    process.exitCode = 1;
  }
}

if (require.main === module) main();

module.exports = {
  assertIgnoredBundle,
  candidateRoots,
  containsSensitiveContent,
  discoverBundle,
  manifestShape,
  readBoundedRegular,
  safeRelativeKey,
  trackedStagedPrivacyScan,
};
