"use strict";

const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const { spawnSync } = require("node:child_process");

const ROOT = path.resolve(__dirname, "..", "..", "..");
const Phase62 = require(path.join(
  ROOT,
  ".planning/phases/62-sclera-evidence-and-admission-contract/62-private-evidence-runner.js"
));
const PRIVATE_PARENT = path.join(ROOT, "example-images", "local-retouch-review");
const WORK_ROOT = path.join(PRIVATE_PARENT, "phase64-sclera-output");
const INPUT_ROOT = path.join(WORK_ROOT, "input");
const OUTPUT_ROOT = path.join(WORK_ROOT, "output");
const REVIEW_ROOT = path.join(WORK_ROOT, "review");
const RENDERER_SOURCE = path.join(ROOT, "BeautySDK", "Sources", "BeautyExampleRenderer", "main.swift");
const HELPER = path.join(__dirname, "check_sclera_renderer_outputs.py");
const NO_FACE = path.join(ROOT, "example-images", "input", "negatives", "no-face-gradient.png");
const CASES = ["geometryBaseline_noop", "scleraRednessReduction_1p00"];
const MAX_ASSET_BYTES = 32 * 1024 * 1024;
const MAX_CHILD_BUFFER = 1024 * 1024;

function fixed(status, extra = {}) {
  process.stdout.write(`${JSON.stringify({ status, outputs: status === "pass" ? 6 : 0, ...extra })}\n`);
}

function run(command, args, options = {}) {
  return spawnSync(command, args, {
    cwd: ROOT,
    encoding: "utf8",
    timeout: 180_000,
    maxBuffer: MAX_CHILD_BUFFER,
    ...options,
  });
}

function assertContained(parent, child) {
  const relative = path.relative(parent, child);
  if (!relative || relative === ".." || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) {
    throw new Error("path_containment_failed");
  }
}

function assertNoSymlinkComponents(target, floor = ROOT) {
  const relative = path.relative(floor, target);
  if (relative.startsWith("..") || path.isAbsolute(relative)) throw new Error("component_escape");
  let current = floor;
  for (const component of relative.split(path.sep).filter(Boolean)) {
    current = path.join(current, component);
    if (!fs.existsSync(current)) break;
    const metadata = fs.lstatSync(current);
    if (metadata.isSymbolicLink()) throw new Error("symlink_component");
  }
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
      const written = fs.writeSync(descriptor, bytes, offset, bytes.length - offset);
      if (written <= 0) throw new Error("short_generated_write");
      offset += written;
    }
  } finally {
    fs.closeSync(descriptor);
  }
}

function loadOriginals(bundle) {
  Phase62.assertIgnoredBundle(bundle);
  const manifest = JSON.parse(
    Phase62.readBoundedRegular(path.join(bundle, "manifest.json"), 256 * 1024).toString("utf8")
  );
  const originals = new Map();
  for (const row of manifest.fixtures) {
    const role = row.polarity;
    const relative = row.assets?.original;
    if (!["positive", "negative"].includes(role) || originals.has(role)
      || !Phase62.safeRelativeKey(relative)) {
      throw new Error("private_fixture_binding");
    }
    const absolute = path.resolve(bundle, relative);
    assertContained(bundle, absolute);
    assertNoSymlinkComponents(absolute);
    originals.set(role, Phase62.readBoundedRegular(absolute, MAX_ASSET_BYTES));
  }
  if (originals.size !== 2) throw new Error("private_pair_incomplete");
  return originals;
}

function assertGeneratedArtifactsPrivate() {
  const relative = path.relative(ROOT, WORK_ROOT).split(path.sep).join("/");
  if (run("git", ["check-ignore", "-q", "--", relative]).status !== 0) {
    throw new Error("generated_root_not_ignored");
  }
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
  const value = JSON.parse(lines[0]);
  if (value?.status !== "pass" || value?.outputs !== 6
    || value?.positive_roles !== 1 || value?.negative_roles !== 1
    || value?.no_face_roles !== 1 || value?.improved_eye_roles !== 1) {
    throw new Error("strict_output_incomplete");
  }
}

function prepareOpaqueReview() {
  fs.mkdirSync(REVIEW_ROOT, { mode: 0o700 });
  const roles = crypto.randomInt(0, 2) === 0 ? ["positive", "negative"] : ["negative", "positive"];
  for (const [index, role] of roles.entries()) {
    const slot = index === 0 ? "A" : "B";
    for (const [label, caseID] of [["baseline", CASES[0]], ["active", CASES[1]]]) {
      const source = path.join(OUTPUT_ROOT, `${role}__${caseID}.png`);
      writeExclusiveRegular(
        path.join(REVIEW_ROOT, `${slot}__${label}.png`),
        Phase62.readBoundedRegular(source, MAX_ASSET_BYTES)
      );
    }
  }
}

function main() {
  try {
    const argv = process.argv.slice(2);
    const prepareReview = argv.length === 1 && argv[0] === "--prepare-review";
    if (process.env.PHASE64_REQUIRE_LOCAL_EVIDENCE !== "1"
      || (argv.length !== 0 && !prepareReview)) {
      throw new Error("required_private_mode_missing");
    }
    const bundle = Phase62.discoverBundle();
    const originals = loadOriginals(bundle);
    assertNoSymlinkComponents(PRIVATE_PARENT);
    removeValidatedTree(WORK_ROOT);
    fs.mkdirSync(WORK_ROOT, { mode: 0o700 });
    fs.mkdirSync(INPUT_ROOT, { mode: 0o700 });
    fs.mkdirSync(OUTPUT_ROOT, { mode: 0o700 });
    writeExclusiveRegular(path.join(INPUT_ROOT, "positive.png"), originals.get("positive"));
    writeExclusiveRegular(path.join(INPUT_ROOT, "negative.png"), originals.get("negative"));
    writeExclusiveRegular(
      path.join(INPUT_ROOT, "no_face.png"),
      Phase62.readBoundedRegular(NO_FACE, MAX_ASSET_BYTES)
    );
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
