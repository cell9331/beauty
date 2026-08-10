"use strict";

const fs = require("node:fs");
const os = require("node:os");
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
const DESCRIPTOR_RELATIVE_REMOVE = String.raw`
import os
import stat
import sys

root, relative = sys.argv[1], sys.argv[2]
expected_identity = (int(sys.argv[3]), int(sys.argv[4]))
expected_target_identity = (int(sys.argv[5]), int(sys.argv[6]))
trusted_root = sys.argv[7]
expected_trusted_identity = (int(sys.argv[8]), int(sys.argv[9]))
parts = relative.split(os.sep)
if len(parts) != 1 or any(part in ("", ".", "..") for part in parts):
    raise RuntimeError("unsafe_relative_target")
flags = os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW
descriptors = []
current = os.open(root, flags)
descriptors.append(current)
try:
    root_metadata = os.fstat(current)
    if (
        not stat.S_ISDIR(root_metadata.st_mode)
        or (root_metadata.st_dev, root_metadata.st_ino) != expected_identity
    ):
        raise RuntimeError("cleanup_root_identity_changed")

    def mount_identity(descriptor):
        if sys.platform.startswith("linux"):
            with open(f"/proc/self/fdinfo/{descriptor}", "rb", buffering=0) as stream:
                value = stream.read(65537)
            if len(value) > 65536:
                raise RuntimeError("mount_identity_oversized")
            rows = [line.split(b":", 1)[1].strip() for line in value.splitlines()
                    if line.startswith(b"mnt_id:")]
            if len(rows) != 1 or not rows[0].isdigit():
                raise RuntimeError("mount_identity_missing")
            return ("linux", int(rows[0]))
        if sys.platform == "darwin":
            import ctypes

            class Fsid(ctypes.Structure):
                _fields_ = [("value", ctypes.c_int32 * 2)]

            class StatFS(ctypes.Structure):
                _fields_ = [
                    ("f_bsize", ctypes.c_uint32), ("f_iosize", ctypes.c_int32),
                    ("f_blocks", ctypes.c_uint64), ("f_bfree", ctypes.c_uint64),
                    ("f_bavail", ctypes.c_uint64), ("f_files", ctypes.c_uint64),
                    ("f_ffree", ctypes.c_uint64), ("f_fsid", Fsid),
                    ("f_owner", ctypes.c_uint32), ("f_type", ctypes.c_uint32),
                    ("f_flags", ctypes.c_uint32), ("f_fssubtype", ctypes.c_uint32),
                    ("f_fstypename", ctypes.c_char * 16),
                    ("f_mntonname", ctypes.c_char * 1024),
                    ("f_mntfromname", ctypes.c_char * 1024),
                    ("f_flags_ext", ctypes.c_uint32),
                    ("f_reserved", ctypes.c_uint32 * 7),
                ]

            record = StatFS()
            libc = ctypes.CDLL(None, use_errno=True)
            if libc.fstatfs(descriptor, ctypes.byref(record)) != 0:
                raise OSError(ctypes.get_errno(), "fstatfs")
            mountpoint = bytes(record.f_mntonname).split(b"\0", 1)[0]
            if not mountpoint:
                raise RuntimeError("mount_identity_missing")
            return ("darwin", mountpoint)
        raise RuntimeError("unsupported_cleanup_platform")

    root_mount_identity = mount_identity(current)
    trusted_fd = os.open(trusted_root, flags)
    try:
        trusted_metadata = os.fstat(trusted_fd)
        if (
            not stat.S_ISDIR(trusted_metadata.st_mode)
            or (trusted_metadata.st_dev, trusted_metadata.st_ino) != expected_trusted_identity
            or mount_identity(trusted_fd) != root_mount_identity
        ):
            raise RuntimeError("cleanup_root_mount_not_trusted")
    finally:
        os.close(trusted_fd)

    def open_verified_directory(parent_fd, name, expected):
        before = os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
        if (
            not stat.S_ISDIR(before.st_mode)
            or (before.st_dev, before.st_ino) != expected
            or before.st_dev != root_metadata.st_dev
        ):
            raise RuntimeError("unsafe_generated_directory")
        child_fd = os.open(name, flags, dir_fd=parent_fd)
        after = os.fstat(child_fd)
        if (
            not stat.S_ISDIR(after.st_mode)
            or after.st_dev != root_metadata.st_dev
            or (after.st_dev, after.st_ino) != (before.st_dev, before.st_ino)
        ):
            os.close(child_fd)
            raise RuntimeError("generated_directory_identity_changed")
        try:
            if mount_identity(child_fd) != root_mount_identity:
                raise RuntimeError("mounted_generated_directory")
        except Exception:
            os.close(child_fd)
            raise
        return child_fd

    def purge(parent_fd, name, expected):
        child_fd = open_verified_directory(parent_fd, name, expected)
        try:
            for entry in os.listdir(child_fd):
                metadata = os.stat(entry, dir_fd=child_fd, follow_symlinks=False)
                if metadata.st_dev != root_metadata.st_dev:
                    raise RuntimeError("cross_device_generated_entry")
                if stat.S_ISDIR(metadata.st_mode):
                    purge(child_fd, entry, (metadata.st_dev, metadata.st_ino))
                elif stat.S_ISREG(metadata.st_mode):
                    regular_fd = os.open(entry, os.O_RDONLY | os.O_NOFOLLOW, dir_fd=child_fd)
                    try:
                        verified = os.fstat(regular_fd)
                        if (
                            not stat.S_ISREG(verified.st_mode)
                            or verified.st_dev != root_metadata.st_dev
                            or (verified.st_dev, verified.st_ino) != (metadata.st_dev, metadata.st_ino)
                        ):
                            raise RuntimeError("generated_file_identity_changed")
                    finally:
                        os.close(regular_fd)
                    os.unlink(entry, dir_fd=child_fd)
                else:
                    raise RuntimeError("unsafe_generated_entry")
        finally:
            os.close(child_fd)
        os.rmdir(name, dir_fd=parent_fd)

    purge(current, parts[-1], expected_target_identity)
finally:
    for descriptor in reversed(descriptors):
        os.close(descriptor)
`;

function fixed(status, extra = {}) {
  process.stdout.write(`${JSON.stringify({
    status,
    outputs: status === "pass" ? 6 : 0,
    strict_helper_self_test: status === "pass" ? "pass" : "fail",
    strict_helper_live: status === "pass" ? "pass" : "fail",
    ...extra,
  })}\n`);
}

function fixedSelfTest(status) {
  process.stdout.write(`${JSON.stringify({
    status,
    strict_helper_self_test: status === "pass" ? "pass" : "fail",
  })}\n`);
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

function removeValidatedTree(target, floor = PRIVATE_PARENT) {
  if (!fs.existsSync(target)) return;
  assertContained(floor, target);
  const relative = path.relative(floor, target);
  if (!relative || relative.split(path.sep).length !== 1
    || relative.split(path.sep).some((component) => !component || component === "." || component === "..")) {
    throw new Error("unsafe_generated_root");
  }
  const floorMetadata = fs.lstatSync(floor, { bigint: true });
  if (!floorMetadata.isDirectory()) throw new Error("cleanup_floor_not_directory");
  const targetMetadata = fs.lstatSync(target, { bigint: true });
  if (!targetMetadata.isDirectory()) throw new Error("cleanup_target_not_directory");
  const trustedMetadata = fs.lstatSync(ROOT, { bigint: true });
  if (!trustedMetadata.isDirectory()) throw new Error("cleanup_trusted_root_not_directory");
  const result = spawnSync("python3", [
    "-c", DESCRIPTOR_RELATIVE_REMOVE, floor, relative,
    floorMetadata.dev.toString(), floorMetadata.ino.toString(),
    targetMetadata.dev.toString(), targetMetadata.ino.toString(),
    ROOT, trustedMetadata.dev.toString(), trustedMetadata.ino.toString(),
  ], {
    cwd: ROOT,
    encoding: "buffer",
    timeout: 20_000,
    maxBuffer: 64 * 1024,
  });
  if (result.status !== 0 || result.error || result.signal
    || result.stdout.length !== 0 || result.stderr.length !== 0) {
    throw new Error("descriptor_relative_cleanup_failed");
  }
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

function exactKeys(value, expected) {
  return value && typeof value === "object" && !Array.isArray(value)
    && JSON.stringify(Object.keys(value).sort()) === JSON.stringify([...expected].sort());
}

function classifyStrictHelperChild(child, expectedRole, forbiddenValues = []) {
  if (!child || child.error || child.status !== 0 || child.signal) {
    throw new Error("strict_helper_child_failed");
  }
  if (typeof child.stdout !== "string" || typeof child.stderr !== "string" || child.stderr !== "") {
    throw new Error("strict_helper_child_output_invalid");
  }
  const combined = `${child.stdout}\n${child.stderr}`;
  const fixedForbidden = ["/Users/", "example-images/", "source_path", "asset_digest", "raw_mask"];
  if ([...fixedForbidden, ...forbiddenValues].some(
    (value) => typeof value === "string" && value && combined.includes(value)
  )) {
    throw new Error("strict_helper_child_private_output");
  }
  const lines = child.stdout.split(/\r?\n/).filter((line) => line.length > 0);
  if (lines.length !== 1) throw new Error("strict_helper_child_ambiguous");
  let value;
  try {
    value = JSON.parse(lines[0]);
  } catch (_) {
    throw new Error("strict_helper_child_malformed");
  }
  if (expectedRole === "self-test") {
    if (!exactKeys(value, ["status", "self_tests"])
      || value.status !== "pass" || value.self_tests !== 14) {
      throw new Error("strict_helper_self_test_incomplete");
    }
    return "pass";
  }
  if (expectedRole === "live") {
    const expectedKeys = [
      "status", "outputs", "positive_roles", "negative_roles",
      "no_face_roles", "improved_eye_roles",
    ];
    if (!exactKeys(value, expectedKeys)
      || value.status !== "pass" || value.outputs !== 6
      || value.positive_roles !== 1 || value.negative_roles !== 1
      || value.no_face_roles !== 1 || value.improved_eye_roles !== 1) {
      throw new Error("strict_helper_live_incomplete");
    }
    return "pass";
  }
  throw new Error("strict_helper_role_invalid");
}

function runStrictHelperChildren(bundle, spawn = run) {
  const forbidden = [bundle, OUTPUT_ROOT, RENDERER_SOURCE, HELPER];
  const selfTestChild = spawn("python3", [HELPER, "--self-test"]);
  const strictHelperSelfTest = classifyStrictHelperChild(selfTestChild, "self-test", forbidden);
  const liveChild = spawn("python3", [
    HELPER,
    "--output", OUTPUT_ROOT,
    "--bundle", bundle,
    "--renderer-source", RENDERER_SOURCE,
  ]);
  const strictHelperLive = classifyStrictHelperChild(liveChild, "live", forbidden);
  return {
    strict_helper_self_test: strictHelperSelfTest,
    strict_helper_live: strictHelperLive,
  };
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

function runSelfTests() {
  const selfTestJSON = `${JSON.stringify({ status: "pass", self_tests: 14 })}\n`;
  const liveJSON = `${JSON.stringify({
    status: "pass", outputs: 6, positive_roles: 1, negative_roles: 1,
    no_face_roles: 1, improved_eye_roles: 1,
  })}\n`;
  const valid = (stdout) => ({ status: 0, signal: null, error: undefined, stdout, stderr: "" });
  if (classifyStrictHelperChild(valid(selfTestJSON), "self-test") !== "pass"
    || classifyStrictHelperChild(valid(liveJSON), "live") !== "pass") {
    throw new Error("strict_helper_valid_fixture_rejected");
  }
  let rejected = 0;
  const expectFailure = (callback) => {
    try { callback(); } catch (_) { rejected += 1; return; }
    throw new Error("strict_helper_mutation_accepted");
  };
  expectFailure(() => classifyStrictHelperChild({ ...valid(liveJSON), status: 1 }, "live"));
  expectFailure(() => classifyStrictHelperChild({ ...valid(liveJSON), error: new Error("spawn") }, "live"));
  expectFailure(() => classifyStrictHelperChild({ ...valid(liveJSON), error: Object.assign(new Error("timeout"), { code: "ETIMEDOUT" }) }, "live"));
  expectFailure(() => classifyStrictHelperChild(valid(`${liveJSON}${liveJSON}`), "live"));
  expectFailure(() => classifyStrictHelperChild(valid("not-json\n"), "live"));
  expectFailure(() => classifyStrictHelperChild(valid(JSON.stringify({ status: "pass", outputs: 5 }) + "\n"), "live"));
  expectFailure(() => classifyStrictHelperChild(valid(selfTestJSON), "live"));
  expectFailure(() => classifyStrictHelperChild(valid(liveJSON), "self-test"));
  expectFailure(() => classifyStrictHelperChild(valid(JSON.stringify({
    status: "pass", outputs: 6, positive_roles: 1, negative_roles: 1,
    no_face_roles: 1, improved_eye_roles: 1, strict_helper_live: "pass",
  }) + "\n"), "live"));
  expectFailure(() => classifyStrictHelperChild(valid(JSON.stringify({
    status: "pass", outputs: 6, positive_roles: 1, negative_roles: 1,
    no_face_roles: 1, improved_eye_roles: 1,
    [["source", "path"].join("_")]: "/Users/private",
  }) + "\n"), "live"));
  expectFailure(() => classifyStrictHelperChild({ ...valid(liveJSON), stderr: "raw child failure" }, "live"));
  expectFailure(() => classifyStrictHelperChild(undefined, "live"));
  expectFailure(() => classifyStrictHelperChild(valid(liveJSON), "unknown"));

  let calls = 0;
  const children = [valid(selfTestJSON), valid(liveJSON)];
  const result = runStrictHelperChildren("opaque-bundle", () => children[calls++]);
  if (calls !== 2 || result.strict_helper_self_test !== "pass" || result.strict_helper_live !== "pass") {
    throw new Error("strict_helper_distinct_execution_invalid");
  }
  expectFailure(() => runStrictHelperChildren("opaque-bundle", () => valid(selfTestJSON)));

  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), "phase64-cleanup-self-test-"));
  const safeRoot = path.join(temporary, "safe-root");
  const unsafeRoot = path.join(temporary, "unsafe-root");
  const outside = path.join(temporary, "outside.bin");
  fs.mkdirSync(path.join(safeRoot, "nested"), { recursive: true });
  fs.writeFileSync(path.join(safeRoot, "nested", "generated.bin"), "generated");
  const cleanupIdentity = fs.lstatSync(temporary, { bigint: true });
  const cleanupTargetIdentity = fs.lstatSync(safeRoot, { bigint: true });
  const wrongDevice = cleanupIdentity.dev + 1n;
  const wrongDeviceChild = spawnSync("python3", [
    "-c", DESCRIPTOR_RELATIVE_REMOVE, temporary, "safe-root",
    wrongDevice.toString(), cleanupIdentity.ino.toString(),
    cleanupTargetIdentity.dev.toString(), cleanupTargetIdentity.ino.toString(),
    temporary, cleanupIdentity.dev.toString(), cleanupIdentity.ino.toString(),
  ], {
    cwd: ROOT,
    encoding: "buffer",
    timeout: 20_000,
    maxBuffer: 64 * 1024,
  });
  if (wrongDeviceChild.status === 0 || !fs.existsSync(path.join(safeRoot, "nested", "generated.bin"))) {
    throw new Error("cleanup_device_mutation_accepted");
  }
  const wrongInodeChild = spawnSync("python3", [
    "-c", DESCRIPTOR_RELATIVE_REMOVE, temporary, "safe-root",
    cleanupIdentity.dev.toString(), (cleanupIdentity.ino + 1n).toString(),
    cleanupTargetIdentity.dev.toString(), cleanupTargetIdentity.ino.toString(),
    temporary, cleanupIdentity.dev.toString(), cleanupIdentity.ino.toString(),
  ], {
    cwd: ROOT,
    encoding: "buffer",
    timeout: 20_000,
    maxBuffer: 64 * 1024,
  });
  if (wrongInodeChild.status === 0 || !fs.existsSync(path.join(safeRoot, "nested", "generated.bin"))) {
    throw new Error("cleanup_inode_mutation_accepted");
  }
  const wrongTargetInodeChild = spawnSync("python3", [
    "-c", DESCRIPTOR_RELATIVE_REMOVE, temporary, "safe-root",
    cleanupIdentity.dev.toString(), cleanupIdentity.ino.toString(),
    cleanupTargetIdentity.dev.toString(), (cleanupTargetIdentity.ino + 1n).toString(),
    temporary, cleanupIdentity.dev.toString(), cleanupIdentity.ino.toString(),
  ], {
    cwd: ROOT,
    encoding: "buffer",
    timeout: 20_000,
    maxBuffer: 64 * 1024,
  });
  if (wrongTargetInodeChild.status === 0
    || !fs.existsSync(path.join(safeRoot, "nested", "generated.bin"))) {
    throw new Error("cleanup_target_inode_mutation_accepted");
  }
  removeValidatedTree(safeRoot, temporary);
  if (fs.existsSync(safeRoot)) throw new Error("descriptor_cleanup_incomplete");
  fs.mkdirSync(unsafeRoot);
  fs.writeFileSync(outside, "outside");
  const unsafeLink = path.join(unsafeRoot, "outside-link");
  fs.symlinkSync(outside, unsafeLink);
  expectFailure(() => removeValidatedTree(unsafeRoot, temporary));
  if (fs.readFileSync(outside, "utf8") !== "outside") throw new Error("descriptor_cleanup_escaped");
  fs.unlinkSync(unsafeLink);
  removeValidatedTree(unsafeRoot, temporary);
  fs.unlinkSync(outside);
  fs.rmdirSync(temporary);

  if (rejected !== 15) throw new Error("strict_helper_self_test_count_invalid");
  return rejected;
}

function main() {
  try {
    const argv = process.argv.slice(2);
    if (argv.length === 1 && argv[0] === "--self-test") {
      runSelfTests();
      fixedSelfTest("pass");
      return;
    }
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
    const strictHelperResults = runStrictHelperChildren(bundle);
    if (prepareReview) prepareOpaqueReview();
    assertGeneratedArtifactsPrivate();
    fixed("pass", {
      ...strictHelperResults,
      ...(prepareReview ? { review_ready: true, review_items: 4 } : {}),
    });
  } catch (_) {
    if (process.argv.length === 3 && process.argv[2] === "--self-test") fixedSelfTest("fail");
    else fixed("fail");
    process.exitCode = 1;
  }
}

if (require.main === module) main();

module.exports = {
  classifyStrictHelperChild,
  removeValidatedTree,
  runStrictHelperChildren,
};
