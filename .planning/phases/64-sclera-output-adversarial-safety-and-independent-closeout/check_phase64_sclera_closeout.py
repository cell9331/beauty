#!/usr/bin/env python3
"""Fail-closed Phase 64 scope, safety, privacy, and three-state closeout checker."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Callable, Iterable


THREATS = tuple(f"T-64-{index:02d}" for index in range(1, 9))
PHASE_DIR = Path(".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout")
EXPECTED_TASKS = tuple(
    (
        "64-01-01", "64-01-02", "64-02-01", "64-02-02",
        "64-03-01", "64-03-02", "64-04-01", "64-04-02",
        "64-05-01", "64-05-02", "64-06-01", "64-06-02",
        "64-07-01", "64-07-02", "64-08-01", "64-08-02",
        "64-09-01", "64-09-02", "64-10-01", "64-10-02",
        "64-11-01", "64-11-02", "64-12-01", "64-13-01",
    )
)
EXPECTED_SCENARIOS = (
    "baseline",
    *(f"left_{name}" for name in (
        "contour_contract", "contour_expand", "contour_nasal", "contour_temporal",
        "contour_up", "contour_down", "pupil_nasal", "pupil_temporal", "pupil_up",
        "pupil_down", "asymmetric_contour_opposite_pupil",
    )),
    *(f"right_{name}" for name in (
        "contour_contract", "contour_expand", "contour_nasal", "contour_temporal",
        "contour_up", "contour_down", "pupil_nasal", "pupil_temporal", "pupil_up",
        "pupil_down", "asymmetric_contour_opposite_pupil",
    )),
    "left_pupil_boundary_rejected", "left_collapsed_contour_rejected",
    "right_pupil_boundary_rejected", "right_collapsed_contour_rejected",
)
EXPECTED_CLASSES = (
    "baseline", *("accepted_left" for _ in range(11)),
    *("accepted_right" for _ in range(11)),
    "rejected_left", "rejected_left", "rejected_right", "rejected_right",
)
EXPECTED_FAMILIES = {"apertureExterior", "highlight", "iris", "lashMargin", "pupil", "skin"}
AGGREGATE_KEYS = {
    "schema", "status", "scenario_count", "scenario_ids", "scenario_classes",
    "accepted_scenario_count", "rejected_scenario_count", "left_only_perturbation_count",
    "right_only_perturbation_count", "family_counts", "actual_proposal_count",
    "protected_truth_pixel_count", "recolored_protected_pixel_count",
    "protected_intersection_count", "protected_byte_mismatch_count",
    "outside_proposal_byte_mismatch_count", "actual_proposal_count_mismatch_count",
    "rejected_eye_proposal_count", "active_peer_scenario_count", "active_peer_proposal_count",
}
PRODUCT_FILES = (
    Path("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md"),
    Path("docs/meitu-function-blueprint/FEATURE_MATRIX.md"),
    Path("docs/meitu-function-blueprint/features/beauty-shaping/README.md"),
    Path("docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md"),
)
PROPOSAL_OWNERS = {
    Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift"),
}
MAX_SCAN_FILE_BYTES = 4 * 1024 * 1024
MAX_PRIVATE_ASSET_BYTES = 32 * 1024 * 1024
MAX_GIT_OUTPUT_BYTES = 64 * 1024 * 1024
SCAN_KEYS = (
    "status", "tracked_blob_count", "staged_blob_count",
    "working_file_count", "untracked_file_count",
)
RELEVANT_SOURCE_PATHS = tuple(sorted((
    "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift",
    "BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift",
    "BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift",
    "BeautySDK/Sources/BeautyExampleRenderer/main.swift",
    "BeautySDK/Sources/BeautySDK/BeautyEngine.swift",
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift",
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineScleraRednessIntegrationTests.swift",
    "BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift",
    "BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift",
    "BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift",
    "BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift",
    "BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift",
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js",
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py",
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py",
    "example-images/generate_gallery.py",
)))


class CheckError(Exception):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise CheckError(message)


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError:
        raise CheckError(f"required file unreadable:{path.name}") from None


def safe_relative_key(value: str) -> bool:
    return (
        isinstance(value, str)
        and 0 < len(value.encode("utf-8")) <= 1024
        and not value.startswith("/")
        and "\\" not in value
        and "\0" not in value
        and ":" not in value
        and all(part not in ("", ".", "..") for part in value.split("/"))
    )


def parse_nul_inventory(value: bytes) -> list[bytes]:
    require(isinstance(value, bytes), "inventory type invalid")
    if value == b"":
        return []
    require(value.endswith(b"\0"), "inventory terminator missing")
    entries = value[:-1].split(b"\0")
    require(all(entries) and len(entries) == len(set(entries)), "inventory entry invalid")
    return entries


def decode_path(value: bytes) -> str:
    try:
        path = value.decode("utf-8", errors="strict")
    except UnicodeDecodeError:
        raise CheckError("inventory path invalid") from None
    require(safe_relative_key(path), "inventory path invalid")
    return path


def default_git_runner(repo: Path, args: tuple[str, ...], input_bytes: bytes | None = None) -> bytes:
    try:
        result = subprocess.run(
            ["git", *args], cwd=repo, input=input_bytes, check=False,
            capture_output=True, timeout=20,
        )
    except (OSError, subprocess.SubprocessError):
        raise CheckError("git tool failed") from None
    require(result.returncode == 0 and not result.stderr, "git tool failed")
    require(len(result.stdout) <= MAX_GIT_OUTPUT_BYTES, "git output oversized")
    return result.stdout


def parse_tree_inventory(value: bytes) -> list[tuple[str, str]]:
    parsed: list[tuple[str, str]] = []
    for entry in parse_nul_inventory(value):
        try:
            header, raw_path = entry.split(b"\t", 1)
            mode, kind, raw_oid = header.split(b" ", 2)
            oid = raw_oid.decode("ascii", errors="strict")
        except (ValueError, UnicodeDecodeError):
            raise CheckError("tree inventory malformed") from None
        require(mode in (b"100644", b"100755") and kind == b"blob", "tree entry nonregular")
        require(re.fullmatch(r"[0-9a-f]{40}", oid) is not None, "tree object invalid")
        parsed.append((decode_path(raw_path), oid))
    require(len(parsed) == len({path for path, _ in parsed}), "tree path duplicated")
    return parsed


def parse_index_inventory(value: bytes) -> list[tuple[str, str]]:
    parsed: list[tuple[str, str]] = []
    for entry in parse_nul_inventory(value):
        try:
            header, raw_path = entry.split(b"\t", 1)
            mode, raw_oid, stage = header.split(b" ", 2)
            oid = raw_oid.decode("ascii", errors="strict")
        except (ValueError, UnicodeDecodeError):
            raise CheckError("index inventory malformed") from None
        require(mode in (b"100644", b"100755") and stage == b"0", "index stage/nonregular entry")
        require(re.fullmatch(r"[0-9a-f]{40}", oid) is not None, "index object invalid")
        parsed.append((decode_path(raw_path), oid))
    require(len(parsed) == len({path for path, _ in parsed}), "index path duplicated")
    return parsed


def read_git_blobs(
    repo: Path,
    entries: list[tuple[str, str]],
    git_runner: Callable[[Path, tuple[str, ...], bytes | None], bytes],
) -> dict[str, bytes]:
    if not entries:
        return {}
    request = b"".join(oid.encode("ascii") + b"\n" for _, oid in entries)
    output = git_runner(repo, ("cat-file", "--batch"), request)
    offset = 0
    result: dict[str, bytes] = {}
    for path, expected_oid in entries:
        newline = output.find(b"\n", offset)
        require(newline >= 0, "object header missing")
        try:
            raw_oid, kind, raw_size = output[offset:newline].split(b" ", 2)
            oid = raw_oid.decode("ascii", errors="strict")
            size = int(raw_size.decode("ascii", errors="strict"))
        except (ValueError, UnicodeDecodeError):
            raise CheckError("object header malformed") from None
        require(oid == expected_oid and kind == b"blob", "object identity/type mismatch")
        require(0 < size <= MAX_SCAN_FILE_BYTES, "object size invalid")
        start = newline + 1
        end = start + size
        require(end < len(output) and output[end:end + 1] == b"\n", "object content short")
        result[path] = output[start:end]
        offset = end + 1
    require(offset == len(output), "object output trailing data")
    return result


def read_bounded_regular(path: Path, maximum_bytes: int = MAX_SCAN_FILE_BYTES) -> bytes:
    descriptor: int | None = None
    try:
        flags = os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0) | getattr(os, "O_NONBLOCK", 0)
        require(getattr(os, "O_NOFOLLOW", 0) != 0, "nofollow unavailable")
        descriptor = os.open(path, flags)
        metadata = os.fstat(descriptor)
        require(stat.S_ISREG(metadata.st_mode), "nonregular file")
        require(0 < metadata.st_size <= maximum_bytes, "file size invalid")
        chunks: list[bytes] = []
        remaining = metadata.st_size
        while remaining:
            chunk = os.read(descriptor, min(remaining, 64 * 1024))
            require(bool(chunk), "file read short")
            chunks.append(chunk)
            remaining -= len(chunk)
        require(os.read(descriptor, 1) == b"", "file grew during read")
        return b"".join(chunks)
    except (OSError, TypeError, ValueError):
        raise CheckError("file read failed") from None
    finally:
        if descriptor is not None:
            try:
                os.close(descriptor)
            except OSError:
                pass


def historical_policy_scope(path: str) -> bool:
    return path.startswith((".planning/milestones/", ".planning/spikes/", ".codex/skills/"))


def sensitive_content(content: bytes, path: str, local_digests: frozenset[str]) -> bool:
    if any(content.startswith(signature) for signature in (
        b"\x89PNG\r\n\x1a\n", b"\xff\xd8\xff", b"GIF87a", b"GIF89a",
        b"II*\x00", b"MM\x00*", b"RIFF",
    )):
        return True
    lowered = content.lower()
    if re.search(rb"(?:^|[^a-z0-9+/])(?:ivborw0kggo|/9j/)[a-z0-9+/=]{16,}", lowered):
        return True
    if any(digest.encode("ascii") in lowered for digest in local_digests):
        return True
    serialized_value = rb"(?:[\"'][^\"'\r\n]+[\"']|[a-z0-9_./+-][^\s,}\]]*|\[[^\]\r\n]+\]|\{[^}\r\n]+\})"
    active_patterns = (
        rb"/users/[^\s\"']+/downloads/[^\s\"']+",
        rb"(?:^|[\n,{])\s*[\"']?(?:rights_holder|reviewer_email|subject_name)[\"']?\s*:\s*" + serialized_value,
        rb"(?:^|[\n,{])\s*[\"']?(?:vein_pattern|vessel_map|sclera_veins|vasculature_detail)[\"']?\s*:\s*" + serialized_value,
    )
    if any(re.search(pattern, lowered) for pattern in active_patterns):
        return True
    if historical_policy_scope(path):
        return False
    structured = rb"(?:^|[\n,{])\s*[\"']?(?:source_path|asset_digest|rights_detail|reviewer_identity|reviewer_note|review_note|freeform|visual_feedback|user_said|raw_support|raw_mask|pixel_geometry|raw_geometry|coordinates|landmark_points|pupil_position|mask_pixels)[\"']?\s*:\s*(?!none\b|null\b|\[\s*\]|\{\s*\})" + serialized_value
    return re.search(structured, lowered) is not None


def private_asset_digests(
    repo: Path,
    git_runner: Callable[[Path, tuple[str, ...], bytes | None], bytes],
    reader: Callable[[Path, int], bytes],
) -> frozenset[str]:
    ignored = parse_nul_inventory(git_runner(
        repo, ("ls-files", "--others", "--ignored", "--exclude-standard", "-z"), None,
    ))
    digests: set[str] = set()
    prefix = "example-images/local-retouch-review/"
    for raw_path in ignored:
        key = decode_path(raw_path[:-1] if raw_path.endswith(b"/") else raw_path)
        if not key.startswith(prefix) or raw_path.endswith(b"/"):
            continue
        absolute = repo / key
        require(absolute.parent.resolve(strict=False).is_relative_to(repo.resolve()), "ignored asset escaped root")
        data = reader(absolute, MAX_PRIVATE_ASSET_BYTES)
        if data.startswith((b"\x89PNG\r\n\x1a\n", b"\xff\xd8\xff")):
            digests.add(hashlib.sha256(data).hexdigest())
    require(bool(digests), "private asset digest inventory empty")
    return frozenset(digests)


def scan_repository_content(
    repo: Path = Path("."),
    *,
    local_digests: frozenset[str] | None = None,
    git_runner: Callable[[Path, tuple[str, ...], bytes | None], bytes] = default_git_runner,
    reader: Callable[[Path, int], bytes] = read_bounded_regular,
) -> dict[str, int | str]:
    repo = repo.resolve()
    require((repo / ".git").exists(), "repository missing")
    digests = private_asset_digests(repo, git_runner, reader) if local_digests is None else local_digests

    tracked_entries = parse_tree_inventory(git_runner(
        repo, ("ls-tree", "-r", "-z", "--full-tree", "HEAD"), None,
    ))
    staged_entries = parse_index_inventory(git_runner(repo, ("ls-files", "--stage", "-z"), None))
    tracked = read_git_blobs(repo, tracked_entries, git_runner)
    staged = read_git_blobs(repo, staged_entries, git_runner)
    for path, content in (*tracked.items(), *staged.items()):
        require(not sensitive_content(content, path, digests), "sensitive blob content")

    working_paths = [decode_path(item) for item in parse_nul_inventory(git_runner(
        repo, ("diff", "--name-only", "-z", "--diff-filter=ACMR", "--", "."), None,
    ))]
    deleted_paths = [decode_path(item) for item in parse_nul_inventory(git_runner(
        repo, ("diff", "--name-only", "-z", "--diff-filter=D", "--", "."), None,
    ))]
    require(not set(working_paths) & set(deleted_paths), "working state ambiguous")
    for path in deleted_paths:
        require(not (repo / path).exists(), "deletion state malformed")
    untracked_paths = [decode_path(item) for item in parse_nul_inventory(git_runner(
        repo, ("ls-files", "--others", "--exclude-standard", "-z"), None,
    ))]
    require(len(working_paths) == len(set(working_paths)), "working path duplicated")
    require(len(untracked_paths) == len(set(untracked_paths)), "untracked path duplicated")
    for path in (*working_paths, *untracked_paths):
        absolute = repo / path
        require(absolute.parent.resolve(strict=False).is_relative_to(repo), "filesystem path escaped root")
        content = reader(absolute, MAX_SCAN_FILE_BYTES)
        require(not sensitive_content(content, path, digests), "sensitive filesystem content")
    return {
        "status": "pass",
        "tracked_blob_count": len(tracked),
        "staged_blob_count": len(staged),
        "working_file_count": len(working_paths),
        "untracked_file_count": len(untracked_paths),
    }


def validate_renderer_source(source: str, promoted: bool) -> None:
    require(source.count("engine.processResult(") == 1, "renderer public call not exact")
    require("import BeautySDK" in source, "renderer public import missing")
    for forbidden in ("import BeautyCore", "import BeautyDetection", "import BeautyEffects", "@_spi(Testing)"):
        require(forbidden not in source, "renderer internal/Testing bypass")
    ids = re.findall(r'\bid\s*:\s*"([^"]+)"', source)
    expected_count = 74 if promoted else 73
    require(len(ids) == expected_count and len(set(ids)) == expected_count, "renderer inventory mismatch")
    require(ids.count("geometryBaseline_noop") == 1, "baseline missing")
    require(ids.count("scleraRednessReduction_1p00") == int(promoted), "sclera case state mismatch")
    if promoted:
        require("BeautyParameters(scleraRednessReduction: 1)" in source, "sclera intent not exact")
        require("--no-watermark" in source, "presentation-free mode missing")


def validate_parser_artifacts(helper: str, evidence: str | None) -> None:
    for token in (
        "O_NOFOLLOW", "MAX_FILE_BYTES", "MAX_DECODED_BYTES", "EXPECTED_NAMES",
        "alpha_changed", "changed_outside", "mean_red_excess_after", "improved_eye_count", "--self-test",
    ):
        require(token in helper, "strict helper boundary incomplete")
    if evidence is not None:
        require("6/6" in evidence and "public-facade" in evidence.lower(), "output evidence incomplete")


def validate_adversarial_source(source: str) -> None:
    for token in (
        "fullResolutionProtectedTruth", "testColorIndependentProtectedTruthUsesEveryBilateralFullResolutionFamily",
        "testEveryRecoloredProtectedAndOutsideProposalRGBAByteRemainsExact", "proposalPixelIndices",
        "testBilateralAdversarialAggregateContract", "PHASE64_ADVERSARIAL_AGGREGATE:",
        "apertureExterior", "highlight", "iris", "lashMargin", "pupil", "skin",
        "outsideProposalByteMismatchCount", "protectedByteMismatchCount",
    ):
        require(token in source, "adversarial executable contract incomplete")
    require("protectedCoordinates" not in source, "legacy six-pixel oracle retained")


def validate_aggregate_evidence(value: dict[str, object]) -> None:
    require(set(value) == AGGREGATE_KEYS, "aggregate schema drift or sensitive detail")
    require(value.get("schema") == "phase64-adversarial-aggregate-v1", "aggregate schema mismatch")
    require(value.get("status") == "passed", "aggregate did not pass")
    require(value.get("scenario_count") == 27, "scenario count mismatch")
    require(tuple(value.get("scenario_ids", ())) == EXPECTED_SCENARIOS, "scenario inventory missing/reordered")
    require(tuple(value.get("scenario_classes", ())) == EXPECTED_CLASSES, "scenario independence/class mismatch")
    require(value.get("accepted_scenario_count") == 23, "accepted scenario count mismatch")
    require(value.get("rejected_scenario_count") == 4, "rejected scenario count mismatch")
    require(value.get("left_only_perturbation_count") == 11, "left perturbation coverage mismatch")
    require(value.get("right_only_perturbation_count") == 11, "right perturbation coverage mismatch")
    families = value.get("family_counts")
    require(isinstance(families, dict) and set(families) == {"left", "right"}, "bilateral family evidence missing")
    for eye in ("left", "right"):
        counts = families[eye]
        require(isinstance(counts, dict) and set(counts) == EXPECTED_FAMILIES, "protected family inventory mismatch")
        require(all(isinstance(count, int) and count > 1 for count in counts.values()), "six-point/empty family evidence")
    protected = value.get("protected_truth_pixel_count")
    require(isinstance(protected, int) and protected > 100, "full-resolution protected truth missing")
    require(value.get("recolored_protected_pixel_count") == protected, "not every protected pixel recolored")
    proposals = value.get("actual_proposal_count")
    require(isinstance(proposals, int) and proposals > 0, "actual runtime proposals missing")
    for key in (
        "protected_intersection_count", "protected_byte_mismatch_count",
        "outside_proposal_byte_mismatch_count", "actual_proposal_count_mismatch_count",
        "rejected_eye_proposal_count",
    ):
        require(value.get(key) == 0, f"aggregate safety failure:{key}")
    require(value.get("active_peer_scenario_count") == 4, "peer recovery coverage mismatch")
    peer = value.get("active_peer_proposal_count")
    require(isinstance(peer, int) and peer > 0, "peer eye suppressed")


def runtime_aggregate() -> dict[str, object]:
    result = subprocess.run(
        ["swift", "test", "--package-path", "BeautySDK", "--filter",
         "BeautyScleraRednessAdversarialCloseoutTests.testBilateralAdversarialAggregateContract"],
        check=False, capture_output=True, text=True, timeout=180,
    )
    require(result.returncode == 0, "adversarial runtime evidence failed")
    prefix = "PHASE64_ADVERSARIAL_AGGREGATE:"
    lines = [line for line in (result.stdout + "\n" + result.stderr).splitlines() if line.startswith(prefix)]
    require(len(lines) == 1, "aggregate runtime evidence missing/duplicated")
    value = json.loads(lines[0][len(prefix):])
    require(isinstance(value, dict), "aggregate runtime evidence invalid")
    return value


def validate_proposal_exposure() -> None:
    provider = read(next(path for path in PROPOSAL_OWNERS if "Sources" in path.parts))
    require("internal let proposalPixelIndices: [Int]" in provider, "immutable internal proposal evidence missing")
    require("protectedProposalPixelCount" not in provider, "provider-owned protected oracle retained")
    forbidden = re.compile(r"(?:public|package)\s+let\s+proposalPixelIndices|@_spi|Codable")
    require(not forbidden.search(provider), "proposal evidence escaped internal test boundary")
    found = {
        path for path in Path("BeautySDK").rglob("*.swift")
        if "proposalPixelIndices" in read(path)
    }
    require(found == PROPOSAL_OWNERS, "proposal evidence owner allowlist mismatch")
    for path in found - {next(path for path in PROPOSAL_OWNERS if "Sources" in path.parts)}:
        require("@testable import BeautyEffects" in read(path), "proposal evidence used without @testable")


def validate_final_output_sources(provider: str, transform: str, engine: str) -> None:
    for token in ("beforeRednessScore", "hardEnvelope", "constrainToHardEnvelope", "expandedPupilExclusion", "actual-pupil exclusion"):
        require(token in provider, "provider containment drift")
    for token in ("maximumEffectiveStrength: Float = 0.52", "maximumLuminanceDelta: Float = 0.018", "immutable canonical source triplet"):
        require(token in transform, "transform bound drift")
    require(engine.count("BeautyScleraRednessProvider.makeResult(") == 1, "production route not exact")


def git_blob_oid(content: bytes) -> str:
    return hashlib.sha1(b"blob " + str(len(content)).encode("ascii") + b"\0" + content).hexdigest()


def parse_review_source_manifest(review: str) -> tuple[str, tuple[tuple[str, str], ...]]:
    match = re.search(r"^relevant_source_tree_oid:\s*([0-9a-f]{40})$", review, re.MULTILINE)
    require(match is not None, "review source tree missing")
    require(review.count("relevant_source_manifest_begin") == 1, "review manifest marker invalid")
    require(review.count("relevant_source_manifest_end") == 1, "review manifest marker invalid")
    try:
        body = review.split("relevant_source_manifest_begin\n", 1)[1].split(
            "\nrelevant_source_manifest_end", 1,
        )[0]
    except IndexError:
        raise CheckError("review manifest malformed") from None
    rows: list[tuple[str, str]] = []
    for line in body.splitlines():
        row = re.fullmatch(r"([0-9a-f]{40})  (.+)", line)
        require(row is not None and safe_relative_key(row.group(2)), "review manifest row malformed")
        rows.append((row.group(2), row.group(1)))
    require(tuple(path for path, _ in rows) == RELEVANT_SOURCE_PATHS, "review manifest scope mismatch")
    require(rows == sorted(rows), "review manifest not sorted")
    return match.group(1), tuple(rows)


def validate_review_source_state(review: str, repo: Path = Path(".")) -> None:
    repo = repo.resolve()
    tree_oid, rows = parse_review_source_manifest(review)
    require(default_git_runner(repo, ("cat-file", "-t", tree_oid), None) == b"tree\n", "review tree invalid")
    index = dict(parse_index_inventory(default_git_runner(repo, ("ls-files", "--stage", "-z"), None)))
    for path, expected_oid in rows:
        frozen = default_git_runner(repo, ("ls-tree", "-z", tree_oid, "--", path), None)
        parsed = parse_tree_inventory(frozen)
        require(parsed == [(path, expected_oid)], "review frozen blob mismatch")
        require(index.get(path) == expected_oid, "review index source changed")
        content = read_bounded_regular(repo / path)
        require(git_blob_oid(content) == expected_oid, "review working source changed")


def validate_review(review: str, repo: Path = Path(".")) -> None:
    for token in (
        "original_detail", "positive", "negative", "sclera_locality", "vessel_detail",
        "highlight_identity", "iris_pupil_identity", "lid_skin_identity", "natural_color",
        "negative_stability", "decision: pass",
    ):
        require(token in review, "review category incomplete")
    parse_review_source_manifest(review)
    non_manifest = re.sub(
        r"relevant_source_manifest_begin\n.*?\nrelevant_source_manifest_end",
        "", review, flags=re.DOTALL,
    )
    require("/Users/" not in non_manifest and "example-images/" not in non_manifest, "review contains locator")
    validate_review_source_state(review, repo)


def validate_review_gate(review: str) -> None:
    if "relevant_source_tree_oid:" in review:
        validate_review(review)
        return
    require("status: stale" in review and "decision: invalidated" in review, "review missing immutable source authority")
    try:
        validate_review(review)
    except CheckError:
        return
    raise CheckError("stale review accepted")


def validate_privacy(scan: dict[str, int | str], aggregate: dict[str, object]) -> None:
    require(tuple(scan) == SCAN_KEYS and scan.get("status") == "pass", "privacy scan aggregate invalid")
    require(all(isinstance(scan[key], int) and scan[key] >= 0 for key in SCAN_KEYS[1:]), "privacy scan count invalid")
    require(scan["tracked_blob_count"] > 0 and scan["staged_blob_count"] > 0, "privacy blob scans empty")
    serialized = json.dumps(aggregate, separators=(",", ":")).lower()
    for forbidden in ("/users/", "coordinate", "raw_mask", "raw_metric", "pixel_values", "source_path", "asset_digest"):
        require(forbidden not in serialized, "aggregate contains private detail")


def validate_product_state(ledger: str, matrix: str, shaping: str, eyes: str, promoted: bool) -> None:
    redness = next((line for line in ledger.splitlines() if "| `眼睛` | 祛红血丝 |" in line), "")
    matrix_eye = next((line for line in matrix.splitlines() if "| Beauty shaping | 眼睛 |" in line), "")
    shaping_eye = next((line for line in shaping.splitlines() if "| `眼睛` | partial |" in line), "")
    eyes_redness = "\n".join(line for line in eyes.splitlines() if "祛红血丝" in line)
    require(redness, "sclera ledger row missing")
    require(("| implemented |" in redness) == promoted, "sclera ledger state mismatch")
    require(("| future |" in redness) != promoted, "sclera quarantine state mismatch")
    if promoted:
        require("Phase 64" in redness and "Phase 63" in redness and "Phase 62" in redness, "promotion provenance missing")
        require(all("祛红血丝" in text and "implemented" in text for text in (matrix_eye, shaping_eye, eyes_redness)), "promoted owners disagree")
    else:
        require(all("祛红血丝" in text and "future" in text for text in (matrix_eye, shaping_eye, eyes_redness)), "quarantined owners disagree")
    require("| `眼睛` | 去脂 | future |" in ledger, "eye-fat row changed")
    require("| Beauty shaping | 眼睛 | partial |" in matrix, "eye matrix no longer partial")
    require("| `眼睛` | partial |" in shaping, "eye shaping branch no longer partial")
    require("Status: `partial`" in eyes and "去脂" in eyes, "eye detail sibling boundary changed")


def validate_task_inventory(plan_texts: list[str]) -> None:
    task_ids = tuple(re.findall(r'<task id="([^"]+)"', "\n".join(plan_texts)))
    require(task_ids == EXPECTED_TASKS, "task inventory mismatch")


def task_ids_from_plans() -> tuple[str, ...]:
    plans = sorted(PHASE_DIR.glob("64-??-PLAN.md"))
    require(len(plans) == 13, "plan inventory mismatch")
    texts = [read(path) for path in plans]
    validate_task_inventory(texts)
    return tuple(re.findall(r'<task id="([^"]+)"', "\n".join(texts)))


def validate_lifecycle_inventory(inventory: dict[str, object]) -> None:
    require(task_ids_from_plans() == EXPECTED_TASKS, "task inventory mismatch")
    threats = inventory.get("threats", [])
    require(isinstance(threats, list), "threat inventory shape mismatch")
    require(tuple(item.get("id") for item in threats if isinstance(item, dict)) == THREATS, "threat inventory mismatch")
    require(len(threats) == 8 and all(isinstance(item, dict) and item.get("severity") == "HIGH" for item in threats), "non-HIGH threat disposition")


def validate_stage(mode: str) -> None:
    canonical = read(PHASE_DIR / "64-VERIFICATION.md")
    if mode == "final":
        for token in ("verification_stage: post_promotion", "independent: true", "status: passed"):
            require(token in canonical, "canonical final verification incomplete")
        require("candidate" in canonical.lower(), "canonical verification lacks accepted candidate provenance")
        candidate = read(PHASE_DIR / "64-POST-PROMOTION-CANDIDATE-VERIFICATION.md")
        for token in ("verification_stage: post_promotion_candidate", "independent: true", "status: candidate_passed"):
            require(token in candidate, "candidate verification incomplete")
    else:
        require("status: gaps_found" in canonical, "canonical verification passed prematurely")
    if mode == "promotion-pending-verification":
        eligibility = read(PHASE_DIR / "64-PRE-PROMOTION-VERIFICATION.md")
        for token in ("verification_stage: pre_promotion", "independent: true", "status: eligible_promotion_pending"):
            require(token in eligibility, "pre-promotion authority incomplete")


def validate_validation_ledger(mode: str) -> None:
    if mode == "pre-promotion":
        return
    text = read(PHASE_DIR / "64-VALIDATION.md")
    ids = tuple(re.findall(r"^\| (64-\d\d-\d\d) \|", text, re.MULTILINE))
    require(ids == EXPECTED_TASKS, "validation rows missing/duplicated/reordered")
    lowered = text.lower()
    if mode == "promotion-pending-verification":
        rows = [line.lower() for line in text.splitlines() if re.match(r"^\| 64-(12|13)-01 \|", line)]
        require(len(rows) == 2 and all("pending" in row or "not-run" in row or "not run" in row for row in rows), "future gates not visibly pending")
        require("24/24" not in text, "validation finalized before candidate")
    else:
        require("24/24" in text, "final validation total missing")
        require(not any(token in lowered for token in ("skipped", "conditional pass", "not-run", "not run")), "final validation has non-executed evidence")


def validate_lifecycle_content(texts: str, mode: str) -> None:
    if mode == "promotion-pending-verification":
        require(re.search(r"promotion.?pending|post.?promotion", texts, re.IGNORECASE) is not None, "lifecycle pending state missing")
        require(all(f"64-{plan:02d}" in texts for plan in range(9, 14)), "final serial gates missing")
        require("candidate" in texts.lower() and "bounded final transaction" in texts.lower(), "final gates not explicitly awaited")
    elif mode == "final":
        require(re.search(r"Phase 64.*(?:complete|completed)|64.*100%", texts, re.IGNORECASE | re.DOTALL) is not None, "lifecycle final state missing")


def validate_lifecycle_text(mode: str) -> None:
    validate_lifecycle_content(
        "\n".join(read(path) for path in (Path("PLANS.md"), Path(".planning/STATE.md"), Path(".planning/ROADMAP.md"))),
        mode,
    )


def run_live(mode: str, selected: str | None) -> int:
    promoted = mode != "pre-promotion"
    aggregate_cache: dict[str, object] | None = None
    scan_cache: dict[str, int | str] | None = None

    def aggregate() -> dict[str, object]:
        nonlocal aggregate_cache
        if aggregate_cache is None:
            aggregate_cache = runtime_aggregate()
            validate_aggregate_evidence(aggregate_cache)
        return aggregate_cache

    def scan() -> dict[str, int | str]:
        nonlocal scan_cache
        if scan_cache is None:
            scan_cache = scan_repository_content()
        return scan_cache

    checks: dict[str, Callable[[], int]] = {
        "T-64-01": lambda: (validate_renderer_source(read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")), True), 7)[1],
        "T-64-02": lambda: (validate_parser_artifacts(read(PHASE_DIR / "check_sclera_renderer_outputs.py"), read(PHASE_DIR / "64-SCLERA-OUTPUT-EVIDENCE.md")), 10)[1],
        "T-64-03": lambda: (validate_adversarial_source(read(Path("BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift"))), validate_proposal_exposure(), aggregate(), 20)[3],
        "T-64-04": lambda: (validate_final_output_sources(read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift")), read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift")), read(Path("BeautySDK/Sources/BeautySDK/BeautyEngine.swift"))), 8)[1],
        "T-64-05": lambda: (validate_review_gate(read(PHASE_DIR / "64-REVIEW.md")), 12)[1],
        "T-64-06": lambda: (validate_privacy(scan(), aggregate()), validate_proposal_exposure(), 12)[2],
        "T-64-07": lambda: (validate_product_state(*(read(path) for path in PRODUCT_FILES), promoted), validate_stage(mode), 12)[2],
        "T-64-08": lambda: (validate_lifecycle_inventory(json.loads(read(PHASE_DIR / "64-THREAT-INVENTORY.json"))), validate_validation_ledger(mode), validate_lifecycle_text(mode), 14)[3],
    }
    counts: dict[str, int] = {}
    for threat in ((selected,) if selected else THREATS):
        counts[threat] = checks[threat]()
    output: dict[str, object]
    if selected == "T-64-06":
        output = dict(scan())
    else:
        output = {"status": "pass", "mode": mode, "checks": counts}
    print(json.dumps(output, separators=(",", ":")))
    return sum(counts.values())


def valid_aggregate() -> dict[str, object]:
    return {
        "schema": "phase64-adversarial-aggregate-v1", "status": "passed",
        "scenario_count": 27, "scenario_ids": list(EXPECTED_SCENARIOS), "scenario_classes": list(EXPECTED_CLASSES),
        "accepted_scenario_count": 23, "rejected_scenario_count": 4,
        "left_only_perturbation_count": 11, "right_only_perturbation_count": 11,
        "family_counts": {eye: {family: 4 for family in EXPECTED_FAMILIES} for eye in ("left", "right")},
        "actual_proposal_count": 744, "protected_truth_pixel_count": 1632,
        "recolored_protected_pixel_count": 1632, "protected_intersection_count": 0,
        "protected_byte_mismatch_count": 0, "outside_proposal_byte_mismatch_count": 0,
        "actual_proposal_count_mismatch_count": 0, "rejected_eye_proposal_count": 0,
        "active_peer_scenario_count": 4, "active_peer_proposal_count": 64,
    }


def run_review_source_self_tests() -> int:
    rejected = 0

    def expect_failure(callback: Callable[[], object]) -> None:
        nonlocal rejected
        try:
            callback()
        except (CheckError, OSError, ValueError, TypeError):
            rejected += 1
            return
        raise CheckError("review source mutation accepted")

    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary) / "repo"
        subprocess.run(["git", "init", "-q", str(root)], check=True, capture_output=True)
        subprocess.run(["git", "-C", str(root), "config", "user.email", "review@example.invalid"], check=True)
        subprocess.run(["git", "-C", str(root), "config", "user.name", "Review Self Test"], check=True)
        originals: dict[str, bytes] = {}
        for index, path in enumerate(RELEVANT_SOURCE_PATHS):
            content = f"relevant-source-{index}\n".encode("ascii")
            originals[path] = content
            target = root / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
        subprocess.run(["git", "-C", str(root), "add", *RELEVANT_SOURCE_PATHS], check=True)
        subprocess.run(["git", "-C", str(root), "commit", "-q", "-m", "source freeze"], check=True)
        tree_oid = default_git_runner(root, ("rev-parse", "HEAD^{tree}"), None).decode("ascii").strip()
        inventory = dict(parse_tree_inventory(default_git_runner(
            root, ("ls-tree", "-r", "-z", "--full-tree", tree_oid), None,
        )))
        rows = "\n".join(f"{inventory[path]}  {path}" for path in RELEVANT_SOURCE_PATHS)
        review = (
            "status: current\n"
            f"relevant_source_tree_oid: {tree_oid}\n"
            "original_detail positive negative sclera_locality vessel_detail "
            "highlight_identity iris_pupil_identity lid_skin_identity natural_color "
            "negative_stability decision: pass\n"
            "relevant_source_manifest_begin\n"
            f"{rows}\n"
            "relevant_source_manifest_end\n"
        )
        validate_review(review, root)

        (root / "PLANS.md").write_text("later non-relevant synchronization\n", encoding="utf-8")
        validate_review(review, root)

        relevant = RELEVANT_SOURCE_PATHS[0]
        (root / relevant).write_bytes(b"post-review source change\n")
        expect_failure(lambda: validate_review(review, root))
        (root / relevant).write_bytes(originals[relevant])
        validate_review(review, root)

        (root / relevant).write_bytes(b"staged source change\n")
        subprocess.run(["git", "-C", str(root), "add", relevant], check=True)
        expect_failure(lambda: validate_review(review, root))
        (root / relevant).write_bytes(originals[relevant])
        subprocess.run(["git", "-C", str(root), "add", relevant], check=True)
        validate_review(review, root)

        expect_failure(lambda: validate_review(review.replace(
            f"relevant_source_tree_oid: {tree_oid}",
            f"relevant_source_tree_oid: {'f' * 40}",
        ), root))
        expect_failure(lambda: validate_review(review.replace(
            rows.splitlines()[0] + "\n", "", 1,
        ), root))
        expect_failure(lambda: validate_review(review.replace(
            inventory[relevant], "0" * 40, 1,
        ), root))
        reversed_rows = "\n".join(reversed(rows.splitlines()))
        expect_failure(lambda: validate_review(review.replace(rows, reversed_rows), root))
        expect_failure(lambda: validate_review(review.replace(
            "relevant_source_manifest_end",
            f"{'0' * 40}  unexpected.txt\nrelevant_source_manifest_end",
        ), root))
    require(rejected == 7, "review source self-test coverage incomplete")
    return rejected


def run_content_scanner_self_tests() -> int:
    rejected = 0

    def expect_failure(callback: Callable[[], object]) -> None:
        nonlocal rejected
        try:
            callback()
        except (CheckError, OSError, ValueError, TypeError):
            rejected += 1
            return
        raise CheckError("content scanner mutation accepted")

    def make_repo(root: Path) -> None:
        subprocess.run(["git", "init", "-q", str(root)], check=True, capture_output=True)
        subprocess.run(["git", "-C", str(root), "config", "user.email", "scanner@example.invalid"], check=True)
        subprocess.run(["git", "-C", str(root), "config", "user.name", "Scanner Self Test"], check=True)
        (root / "neutral.txt").write_bytes(b"bounded aggregate policy\n")
        subprocess.run(["git", "-C", str(root), "add", "neutral.txt"], check=True)
        subprocess.run(["git", "-C", str(root), "commit", "-q", "-m", "baseline"], check=True)

    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary) / "repo"
        make_repo(root)
        result = scan_repository_content(root, local_digests=frozenset())
        require(result == {
            "status": "pass", "tracked_blob_count": 1, "staged_blob_count": 1,
            "working_file_count": 0, "untracked_file_count": 0,
        }, "valid scanner fixture rejected")

        (root / "neutral.txt").unlink()
        deleted = scan_repository_content(root, local_digests=frozenset())
        require(deleted["working_file_count"] == 0, "deletion state not handled")

    fixtures: tuple[tuple[str, bytes, str], ...] = (
        ("head", b"rights_holder:private-value\n", "commit"),
        ("head-media", b"\xff\xd8\xffprivate", "commit"),
        ("index", b"raw_mask:private-value\n", "stage"),
        ("index-media", b"\x89PNG\r\n\x1a\nprivate", "stage"),
        ("working", b"coordinates:1,2,3\n", "working"),
        ("untracked-media", b"\x89PNG\r\n\x1a\nprivate", "untracked"),
        ("untracked-decoded-media", b"payload:" + b"iVBO" + b"Rw0KGgoAAAANSUhEUgAAAAEAAAAB", "untracked"),
        ("untracked-geometry", b"pixel_geometry:private-value\n", "untracked"),
        ("untracked-vein", b"vein_pattern:private-value\n", "untracked"),
    )
    for name, content, state in fixtures:
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary) / "repo"
            make_repo(root)
            target = root / "neutral.txt" if state == "working" else root / f"{name}.dat"
            target.write_bytes(content)
            if state in ("commit", "stage"):
                subprocess.run(["git", "-C", str(root), "add", target.name], check=True)
            if state == "commit":
                subprocess.run(["git", "-C", str(root), "commit", "-q", "-m", name], check=True)
            expect_failure(lambda root=root: scan_repository_content(root, local_digests=frozenset()))

    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary) / "repo"
        make_repo(root)
        digest = hashlib.sha256(b"authorized-private-asset").hexdigest()
        (root / "neutral-digest.txt").write_text(digest, encoding="ascii")
        expect_failure(lambda: scan_repository_content(root, local_digests=frozenset((digest,))))

    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary) / "repo"
        make_repo(root)
        (root / "link.dat").symlink_to(root / "neutral.txt")
        expect_failure(lambda: scan_repository_content(root, local_digests=frozenset()))
        (root / "link.dat").unlink()
        fifo = root / "pipe.dat"
        os.mkfifo(fifo)
        expect_failure(lambda: read_bounded_regular(fifo))
        fifo.unlink()
        (root / "empty.dat").write_bytes(b"")
        expect_failure(lambda: scan_repository_content(root, local_digests=frozenset()))
        (root / "empty.dat").unlink()
        (root / "large.dat").write_bytes(b"x" * (MAX_SCAN_FILE_BYTES + 1))
        expect_failure(lambda: scan_repository_content(root, local_digests=frozenset()))

    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary) / "repo"
        make_repo(root)
        (root / "read-failure.dat").write_bytes(b"safe")

        def failed_read(_path: Path, _maximum: int) -> bytes:
            raise CheckError("injected read failure")

        expect_failure(lambda: scan_repository_content(
            root, local_digests=frozenset(), reader=failed_read,
        ))

        def malformed_nul(repo: Path, args: tuple[str, ...], input_bytes: bytes | None = None) -> bytes:
            output = default_git_runner(repo, args, input_bytes)
            return output[:-1] if args[:2] == ("ls-tree", "-r") and output else output

        expect_failure(lambda: scan_repository_content(
            root, local_digests=frozenset(), git_runner=malformed_nul,
        ))

        def git_failure(_repo: Path, _args: tuple[str, ...], _input: bytes | None = None) -> bytes:
            raise CheckError("injected git failure")

        expect_failure(lambda: scan_repository_content(
            root, local_digests=frozenset(), git_runner=git_failure,
        ))

        def object_failure(repo: Path, args: tuple[str, ...], input_bytes: bytes | None = None) -> bytes:
            if args[:2] == ("cat-file", "--batch"):
                return b"missing\n"
            return default_git_runner(repo, args, input_bytes)

        expect_failure(lambda: scan_repository_content(
            root, local_digests=frozenset(), git_runner=object_failure,
        ))

    expect_failure(lambda: parse_nul_inventory(b"one\0two"))
    expect_failure(lambda: parse_nul_inventory(b"one\0one\0"))
    expect_failure(lambda: parse_tree_inventory(b"120000 blob " + b"0" * 40 + b"\tlink\0"))
    expect_failure(lambda: parse_index_inventory(b"100644 " + b"0" * 40 + b" 2\tmerge\0"))
    expect_failure(lambda: parse_index_inventory(b"100644 " + b"0" * 40 + b" 0\t../escape\0"))
    require(rejected >= 18, "content scanner self-test coverage incomplete")
    return rejected


def run_self_test() -> int:
    # RED gate for Plan 64-08: the closeout authority must expose the complete
    # replanned serial graph before any scanner/review implementation can pass.
    require(len(EXPECTED_TASKS) == 24, "RED: thirteen-plan/twenty-four-task inventory missing")
    require(len(tuple(PHASE_DIR.glob("64-??-PLAN.md"))) == 13, "RED: thirteen-plan inventory missing")
    try:
        validate_review(read(PHASE_DIR / "64-REVIEW.md"))
    except CheckError:
        pass
    else:
        raise CheckError("RED: stale review accepted without immutable source manifest")
    require("scan_repository_content" in globals(), "RED: four-state content scanner missing")
    content_scan_rejections = run_content_scanner_self_tests()
    review_source_rejections = run_review_source_self_tests()

    mutations: tuple[tuple[str, Callable[[dict[str, object]], None]], ...] = (
        ("missing-eye", lambda value: value["family_counts"].pop("right")),
        ("missing-family", lambda value: value["family_counts"]["left"].pop("iris")),
        ("six-point", lambda value: value.update(protected_truth_pixel_count=6, recolored_protected_pixel_count=6)),
        ("coupled", lambda value: value.update(left_only_perturbation_count=0)),
        ("coupled-classes", lambda value: value["scenario_classes"].__setitem__(1, "accepted_bilateral")),
        ("missing-scenario", lambda value: value["scenario_ids"].pop()),
        ("reordered", lambda value: value["scenario_ids"].reverse()),
        ("peer-suppressed", lambda value: value.update(active_peer_proposal_count=0)),
        ("overlap", lambda value: value.update(protected_intersection_count=1)),
        ("protected-byte", lambda value: value.update(protected_byte_mismatch_count=1)),
        ("outside-byte", lambda value: value.update(outside_proposal_byte_mismatch_count=1)),
        ("count-mismatch", lambda value: value.update(actual_proposal_count_mismatch_count=1)),
        ("sensitive-payload", lambda value: value.update(raw_mask=[1, 2, 3])),
        ("skipped", lambda value: value.update(status="skipped")),
    )
    validate_aggregate_evidence(valid_aggregate())
    passed = 0
    for name, mutate in mutations:
        value = json.loads(json.dumps(valid_aggregate()))
        mutate(value)
        try:
            validate_aggregate_evidence(value)
        except CheckError:
            passed += 1
        else:
            raise CheckError(f"HIGH mutation accepted:{name}")
    source = " ".join((
        "fullResolutionProtectedTruth",
        "testColorIndependentProtectedTruthUsesEveryBilateralFullResolutionFamily",
        "testEveryRecoloredProtectedAndOutsideProposalRGBAByteRemainsExact",
        "proposalPixelIndices", "testBilateralAdversarialAggregateContract",
        "PHASE64_ADVERSARIAL_AGGREGATE:", "apertureExterior", "highlight", "iris",
        "lashMargin", "pupil", "skin", "outsideProposalByteMismatchCount",
        "protectedByteMismatchCount",
    ))
    validate_adversarial_source(source)
    synthetic_cases: tuple[tuple[str, Callable[[], None]], ...] = (
        ("token-only-source", lambda: validate_adversarial_source("iris pupil highlight skin")),
        (
            "stale-owner-promotion",
            lambda: validate_product_state(
                "| `眼睛` | 去脂 | future |\n| `眼睛` | 祛红血丝 | implemented |",
                "| Beauty shaping | 眼睛 | partial | 祛红血丝 future",
                "| `眼睛` | partial | 祛红血丝 future",
                "Status: `partial` 祛红血丝 future 去脂",
                False,
            ),
        ),
        (
            "wrong-task-inventory",
            lambda: validate_task_inventory([
                f'<task id="{task}"' for task in (*EXPECTED_TASKS[:-2], EXPECTED_TASKS[-1], EXPECTED_TASKS[-2])
            ]),
        ),
        (
            "wrong-lifecycle-state",
            lambda: validate_lifecycle_content("Phase 64 promotion pending; 64-09 64-10 64-11; candidate absent", "promotion-pending-verification"),
        ),
    )
    for name, mutation in synthetic_cases:
        try:
            mutation()
        except CheckError:
            passed += 1
        else:
            raise CheckError(f"HIGH mutation accepted:{name}")
    print(json.dumps({
        "status": "pass", "self_tests": passed,
        "content_scan_rejections": content_scan_rejections,
        "review_source_rejections": review_source_rejections,
        "threats": 8, "states": 3,
    }, separators=(",", ":")))
    return passed + content_scan_rejections + review_source_rejections


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--pre-promotion", action="store_true")
    modes.add_argument("--promotion-pending-verification", action="store_true")
    modes.add_argument("--final", action="store_true")
    parser.add_argument("--threat", choices=THREATS)
    parser.add_argument("--repo-root", type=Path)
    args = parser.parse_args()
    if args.repo_root:
        os.chdir(args.repo_root)
    mode = "final" if args.final else "promotion-pending-verification" if args.promotion_pending_verification else "pre-promotion"
    try:
        run_self_test() if args.self_test else run_live(mode, args.threat)
        return 0
    except (CheckError, json.JSONDecodeError, subprocess.SubprocessError, AssertionError, TypeError, KeyError):
        if args.threat == "T-64-06":
            print(json.dumps({
                "status": "fail", "tracked_blob_count": 0, "staged_blob_count": 0,
                "working_file_count": 0, "untracked_file_count": 0,
            }, separators=(",", ":")))
        else:
            print("phase64_closeout_failed", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
