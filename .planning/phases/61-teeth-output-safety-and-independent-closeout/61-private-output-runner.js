"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { spawnSync } = require("node:child_process");

const ROOT = path.resolve(__dirname, "..", "..", "..");
const PRIVATE_PARENT = path.join(
  ROOT,
  "example-images",
  ["local", "retouch", "review"].join("-")
);
const WORK_ROOT = path.join(PRIVATE_PARENT, ["phase61", "teeth", "output"].join("-"));
const INPUT_ROOT = path.join(WORK_ROOT, "input");
const OUTPUT_ROOT = path.join(WORK_ROOT, "output");
const REVIEW_ROOT = path.join(WORK_ROOT, "review");
const RENDERER_SOURCE = path.join(ROOT, "BeautySDK", "Sources", "BeautyExampleRenderer", "main.swift");
const HELPER = path.join(__dirname, "check_teeth_renderer_outputs.py");
const NO_FACE = path.join(ROOT, "example-images", "input", "negatives", "no-face-gradient.png");
const BUNDLE_MARKER = ["teeth", "evidence", "20260805"].join("-");
const MAX_FILE_BYTES = 16 * 1024 * 1024;
const MAX_CHILD_BUFFER = 1024 * 1024;
const CASES = ["geometryBaseline_noop", "teethWhitening_1p00"];

function fixed(status, extra = {}) {
  process.stdout.write(`${JSON.stringify({ status, outputs: status === "pass" ? 6 : 0, ...extra })}\n`);
}

function run(command, args, options = {}) {
  return spawnSync(command, args, {
    cwd: ROOT,
    encoding: "utf8",
    maxBuffer: MAX_CHILD_BUFFER,
    timeout: 180000,
    ...options,
  });
}

function ignoredFiles() {
  const result = run("git", ["ls-files", "--others", "--ignored", "--exclude-standard", "-z"], {
    encoding: "buffer",
  });
  if (result.status !== 0 || result.error) throw new Error("ignored_scan_failed");
  return result.stdout.toString("utf8").split("\0").filter(Boolean);
}

function safeRelative(value) {
  return typeof value === "string"
    && value.length > 0
    && !path.posix.isAbsolute(value)
    && value.split("/").every((part) => part !== "" && part !== "." && part !== "..");
}

function assertContained(parent, child) {
  const relative = path.relative(parent, child);
  if (relative === "" || relative.startsWith(`..${path.sep}`) || relative === ".." || path.isAbsolute(relative)) {
    throw new Error("path_containment_failed");
  }
}

function assertNoSymlinkComponents(target, floor = ROOT) {
  if (!fs.existsSync(floor)) throw new Error("component_floor_missing");
  const floorMetadata = fs.lstatSync(floor);
  if (!floorMetadata.isDirectory() || floorMetadata.isSymbolicLink()) {
    throw new Error("component_floor_unsafe");
  }
  const relative = path.relative(floor, target);
  if (relative.startsWith("..") || path.isAbsolute(relative)) throw new Error("component_escape");
  let current = floor;
  for (const component of relative.split(path.sep).filter(Boolean)) {
    current = path.join(current, component);
    if (!fs.existsSync(current)) break;
    if (fs.lstatSync(current).isSymbolicLink()) throw new Error("symlink_component");
  }
}

function boundedRegularBytes(filePath) {
  assertNoSymlinkComponents(filePath);
  const flags = fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW;
  const descriptor = fs.openSync(filePath, flags);
  try {
    const before = fs.fstatSync(descriptor);
    if (!before.isFile() || before.size <= 0 || before.size > MAX_FILE_BYTES) {
      throw new Error("invalid_private_file");
    }
    const bytes = Buffer.allocUnsafe(before.size);
    let offset = 0;
    while (offset < bytes.length) {
      const count = fs.readSync(descriptor, bytes, offset, bytes.length - offset, null);
      if (count <= 0) throw new Error("short_private_read");
      offset += count;
    }
    const overflow = Buffer.alloc(1);
    if (fs.readSync(descriptor, overflow, 0, 1, null) !== 0) throw new Error("private_file_grew");
    const after = fs.fstatSync(descriptor);
    if (before.dev !== after.dev || before.ino !== after.ino || before.size !== after.size
      || before.mtimeMs !== after.mtimeMs || before.ctimeMs !== after.ctimeMs) {
      throw new Error("private_file_changed");
    }
    return bytes;
  } finally {
    fs.closeSync(descriptor);
  }
}

function parseManifest(bundleRelative) {
  const bundle = path.resolve(ROOT, bundleRelative);
  assertContained(ROOT, bundle);
  assertNoSymlinkComponents(bundle);
  const manifestPath = path.join(bundle, "manifest.json");
  let manifest;
  try {
    manifest = JSON.parse(boundedRegularBytes(manifestPath).toString("utf8"));
  } catch (_) {
    throw new Error("private_manifest_invalid");
  }
  if (manifest?.schema_version !== 1 || !Array.isArray(manifest.fixtures)
    || manifest.fixtures.length !== 2) {
    throw new Error("private_manifest_shape");
  }
  const originals = new Map();
  for (const row of manifest.fixtures) {
    const role = row?.polarity;
    const original = row?.assets?.original;
    const mask = row?.assets?.mask;
    if (row?.feature !== "teeth_whitening" || !["positive", "negative"].includes(role)
      || originals.has(role) || !safeRelative(original) || !safeRelative(mask)) {
      throw new Error("private_fixture_binding");
    }
    const originalPath = path.resolve(bundle, original);
    const maskPath = path.resolve(bundle, mask);
    assertContained(bundle, originalPath);
    assertContained(bundle, maskPath);
    boundedRegularBytes(maskPath);
    originals.set(role, { path: originalPath, bytes: boundedRegularBytes(originalPath) });
  }
  if (originals.size !== 2 || !originals.has("positive") || !originals.has("negative")) {
    throw new Error("private_role_pair_incomplete");
  }
  return { bundle, originals };
}

function discoverBundle() {
  const ignored = ignoredFiles();
  const candidates = new Set();
  for (const file of ignored) {
    if (!file.endsWith("/manifest.json") || !file.includes(BUNDLE_MARKER)) continue;
    const relative = path.posix.dirname(file);
    try {
      parseManifest(relative);
      candidates.add(relative);
    } catch (_) {
      // Invalid ignored candidates do not become evidence.
    }
  }
  if (candidates.size !== 1) throw new Error("private_bundle_ambiguous_or_missing");
  const parsed = parseManifest([...candidates][0]);
  const bundlePrefix = `${path.relative(ROOT, parsed.bundle).split(path.sep).join("/")}/`;
  const ignoredSet = new Set(ignored);
  for (const entry of fs.readdirSync(parsed.bundle, { recursive: true, withFileTypes: true })) {
    if (!entry.isFile()) continue;
    const absolute = path.join(entry.parentPath || entry.path, entry.name);
    const relative = path.relative(ROOT, absolute).split(path.sep).join("/");
    if (!relative.startsWith(bundlePrefix) || !ignoredSet.has(relative)) {
      throw new Error("private_bundle_not_fully_ignored");
    }
  }
  return parsed;
}

function removeValidatedTree(target) {
  if (!fs.existsSync(target)) return;
  assertContained(PRIVATE_PARENT, target);
  assertNoSymlinkComponents(target, PRIVATE_PARENT);
  const metadata = fs.lstatSync(target);
  if (!metadata.isDirectory() || metadata.isSymbolicLink()) throw new Error("unsafe_generated_root");
  for (const name of fs.readdirSync(target)) {
    const child = path.join(target, name);
    assertContained(target, child);
    const childMetadata = fs.lstatSync(child);
    if (childMetadata.isSymbolicLink()) throw new Error("unsafe_generated_symlink");
    if (childMetadata.isDirectory()) removeValidatedTree(child);
    else if (childMetadata.isFile()) fs.unlinkSync(child);
    else throw new Error("unsafe_generated_entry");
  }
  fs.rmdirSync(target);
}

function writeExclusiveRegular(destination, bytes) {
  assertContained(WORK_ROOT, destination);
  const descriptor = fs.openSync(
    destination,
    fs.constants.O_WRONLY | fs.constants.O_CREAT | fs.constants.O_EXCL | fs.constants.O_NOFOLLOW,
    0o600
  );
  try {
    let offset = 0;
    while (offset < bytes.length) {
      offset += fs.writeSync(descriptor, bytes, offset, bytes.length - offset);
    }
  } finally {
    fs.closeSync(descriptor);
  }
}

function assertGeneratedArtifactsPrivate() {
  const relative = path.relative(ROOT, WORK_ROOT).split(path.sep).join("/");
  const ignored = run("git", ["check-ignore", "-q", "--", relative]);
  if (ignored.status !== 0) throw new Error("generated_root_not_ignored");
  const tracked = run("git", ["ls-files", "-z", "--", relative], { encoding: "buffer" });
  const staged = run("git", ["diff", "--cached", "--name-only", "-z", "--", relative], { encoding: "buffer" });
  if (tracked.status !== 0 || staged.status !== 0 || tracked.stdout.length || staged.stdout.length) {
    throw new Error("generated_artifact_tracked_or_staged");
  }
}

function render(caseID) {
  const result = run("swift", [
    "run", "--package-path", "BeautySDK", "BeautyExampleRenderer",
    "--input", INPUT_ROOT,
    "--output", OUTPUT_ROOT,
    "--case", caseID,
    "--no-watermark",
  ]);
  if (result.status !== 0 || result.error) throw new Error("renderer_failed");
}

function verify(bundle) {
  const result = run("python3", [
    HELPER,
    "--output", OUTPUT_ROOT,
    "--bundle", bundle,
    "--renderer-source", RENDERER_SOURCE,
  ]);
  if (result.status !== 0 || result.error) throw new Error("strict_output_failed");
  const lines = result.stdout.trim().split("\n");
  if (lines.length !== 1) throw new Error("strict_output_ambiguous");
  let value;
  try {
    value = JSON.parse(lines[0]);
  } catch (_) {
    throw new Error("strict_output_invalid");
  }
  if (value?.status !== "pass" || value?.outputs !== 6
    || value?.positive_roles !== 1 || value?.negative_roles !== 1 || value?.no_face_roles !== 1) {
    throw new Error("strict_output_incomplete");
  }
}

function prepareOpaqueReview() {
  fs.mkdirSync(REVIEW_ROOT, { mode: 0o700 });
  const roles = require("node:crypto").randomInt(0, 2) === 0
    ? ["positive", "negative"]
    : ["negative", "positive"];
  for (const [index, role] of roles.entries()) {
    const slot = index === 0 ? "A" : "B";
    const baseline = boundedRegularBytes(path.join(OUTPUT_ROOT, `${role}__${CASES[0]}.png`));
    const active = boundedRegularBytes(path.join(OUTPUT_ROOT, `${role}__${CASES[1]}.png`));
    writeExclusiveRegular(path.join(REVIEW_ROOT, `${slot}__baseline.png`), baseline);
    writeExclusiveRegular(path.join(REVIEW_ROOT, `${slot}__active.png`), active);
  }
}

function main() {
  try {
    const argv = process.argv.slice(2);
    const prepareReview = argv.length === 1 && argv[0] === "--prepare-review";
    if (process.env.PHASE61_REQUIRE_LOCAL_EVIDENCE !== "1"
      || (argv.length !== 0 && !prepareReview)) {
      throw new Error("required_private_mode_missing");
    }
    const { bundle, originals } = discoverBundle();
    assertNoSymlinkComponents(PRIVATE_PARENT);
    removeValidatedTree(WORK_ROOT);
    fs.mkdirSync(WORK_ROOT, { mode: 0o700 });
    fs.mkdirSync(INPUT_ROOT, { mode: 0o700 });
    fs.mkdirSync(OUTPUT_ROOT, { mode: 0o700 });
    writeExclusiveRegular(path.join(INPUT_ROOT, "positive.png"), originals.get("positive").bytes);
    writeExclusiveRegular(path.join(INPUT_ROOT, "negative.png"), originals.get("negative").bytes);
    writeExclusiveRegular(path.join(INPUT_ROOT, "no_face.png"), boundedRegularBytes(NO_FACE));
    assertGeneratedArtifactsPrivate();
    for (const caseID of CASES) render(caseID);
    verify(bundle);
    if (prepareReview) prepareOpaqueReview();
    assertGeneratedArtifactsPrivate();
    fixed("pass", prepareReview ? { review_ready: true, review_items: 4 } : {});
  } catch (_) {
    fixed("fail");
    process.exitCode = 1;
  }
}

if (require.main === module) main();
