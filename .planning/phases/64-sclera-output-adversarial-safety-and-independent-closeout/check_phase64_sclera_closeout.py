#!/usr/bin/env python3
"""Fail-closed Phase 64 scope, safety, privacy, and three-state closeout checker."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import secrets
import stat
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Callable, Iterable


THREATS = tuple(f"T-64-{index:02d}" for index in range(1, 9))
PHASE_DIR = Path(".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout")
EXPECTED_PLAN_COUNT = 19
HISTORICAL_EXECUTED_PLAN_IDS = tuple(range(1, 14))
CURRENT_STRUCTURE_PLAN_IDS = tuple(range(14, 20))
EXPECTED_TASKS = tuple(
    (
        "64-01-01", "64-01-02", "64-02-01", "64-02-02",
        "64-03-01", "64-03-02", "64-04-01", "64-04-02",
        "64-05-01", "64-05-02", "64-06-01", "64-06-02",
        "64-07-01", "64-07-02", "64-08-01", "64-08-02",
        "64-09-01", "64-09-02", "64-10-01", "64-10-02",
        "64-11-01", "64-11-02", "64-12-01", "64-13-01",
        "64-14-01", "64-14-02", "64-15-01", "64-15-02",
        "64-16-01", "64-16-02", "64-17-01", "64-17-02",
        "64-18-01", "64-19-01",
    )
)
OPT_IN_TESTS = (
    "VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture",
    "VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload",
    "VisionFaceDetectorTests.testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload",
    "BeautyEngineGeometryFacadeTests.testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade",
    "BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope",
    "BeautyFaceGeometryAdapterTests.testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope",
    "BeautyTeethWhiteningRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds",
    "BeautyScleraRednessRealFixtureTests.testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds",
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
    ".planning/phases/59-teeth-evidence-and-admission-contract/59-private-evidence-runner.js",
    ".planning/phases/61-teeth-output-safety-and-independent-closeout/check_teeth_renderer_outputs.py",
    ".planning/phases/62-sclera-evidence-and-admission-contract/62-private-evidence-runner.js",
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-no-skip-swiftpm-runner.js",
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js",
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py",
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py",
)))
if len(RELEVANT_SOURCE_PATHS) != 19:
    raise RuntimeError("relevant source inventory mismatch")

POST_REPAIR_EVIDENCE = PHASE_DIR / "64-POST-REPAIR-SCLERA-OUTPUT-EVIDENCE.md"
POST_REPAIR_REVIEW = PHASE_DIR / "64-POST-REPAIR-REVIEW.md"
POST_REPAIR_CODE_REVIEW = PHASE_DIR / "64-POST-REPAIR-CODE-REVIEW.md"
POST_REPAIR_REVIEW_FIX = PHASE_DIR / "64-POST-REPAIR-REVIEW-FIX.md"
POST_REPAIR_SECURITY = PHASE_DIR / "64-POST-REPAIR-SECURITY.md"
POST_REPAIR_PRE_PROMOTION = PHASE_DIR / "64-POST-REPAIR-PRE-PROMOTION-VERIFICATION.md"
POST_REPAIR_CANDIDATE = PHASE_DIR / "64-POST-REPAIR-CANDIDATE-VERIFICATION.md"
POST_REPAIR_AUTHORITY_PATHS = tuple(sorted(str(path) for path in (
    POST_REPAIR_EVIDENCE, POST_REPAIR_REVIEW, POST_REPAIR_CODE_REVIEW,
    POST_REPAIR_REVIEW_FIX, POST_REPAIR_SECURITY, POST_REPAIR_PRE_PROMOTION,
)))

ROOT_CONTRACT_FILES = (
    Path("DESIGN.md"), Path("SECURITY.md"), Path("RELIABILITY.md"),
    Path("PRODUCT_SENSE.md"), Path("QUALITY_SCORE.md"),
)
LIFECYCLE_FILES = (
    Path("PLANS.md"), Path(".planning/REQUIREMENTS.md"),
    Path(".planning/ROADMAP.md"), Path(".planning/STATE.md"),
)
CANDIDATE_INPUT_OWNER_PATHS = tuple(sorted(str(path) for path in (
    PHASE_DIR / "64-VERIFICATION.md", PHASE_DIR / "64-VALIDATION.md",
    *PRODUCT_FILES, *ROOT_CONTRACT_FILES, *LIFECYCLE_FILES,
)))
CANDIDATE_IMMUTABLE_OWNER_PATHS = tuple(sorted(str(path) for path in (
    *PRODUCT_FILES, *ROOT_CONTRACT_FILES,
)))
if (
    len(CANDIDATE_INPUT_OWNER_PATHS) != 15
    or len(CANDIDATE_IMMUTABLE_OWNER_PATHS) != 9
    or len(POST_REPAIR_AUTHORITY_PATHS) != 6
):
    raise RuntimeError("candidate owner/authority inventory mismatch")

CANDIDATE_SCHEMA = "phase64-post-repair-candidate-v1"
POST_REPAIR_SCHEMAS = {
    "review": ("phase64-post-repair-review-v1", "post_repair_original_detail_review"),
    "code_review": ("phase64-post-repair-code-review-v1", "post_repair_code_review"),
    "review_fix": ("phase64-post-repair-review-fix-v1", "post_repair_review_fix"),
    "security": ("phase64-post-repair-security-v1", "post_repair_security"),
    "eligibility": ("phase64-post-repair-pre-promotion-v1", "post_repair_pre_promotion"),
}
REVIEW_CATEGORY_ROWS = (
    ("obvious_but_natural_positive_improvement", "pass", "not_applicable", "not_applicable"),
    ("negative_naturalness_no_unnecessary_change", "not_applicable", "pass", "not_applicable"),
    ("iris_pupil_identity", "pass", "pass", "not_applicable"),
    ("highlight_identity", "pass", "pass", "not_applicable"),
    ("lash_identity", "pass", "pass", "not_applicable"),
    ("lid_skin_identity", "pass", "pass", "not_applicable"),
    ("aperture_exterior_identity", "pass", "pass", "not_applicable"),
    ("sclera_locality", "pass", "pass", "not_applicable"),
    ("vessel_detail", "pass", "pass", "not_applicable"),
    ("texture_retention", "pass", "pass", "not_applicable"),
    ("halo_edge_bounded", "pass", "pass", "not_applicable"),
    ("luminance_bounded", "pass", "pass", "not_applicable"),
    ("natural_color", "pass", "pass", "not_applicable"),
    ("negative_stability", "not_applicable", "pass", "not_applicable"),
    ("no_face_identity", "not_applicable", "not_applicable", "pass"),
)
CANDIDATE_GUARD_TIMEOUT_SECONDS = 1800
CANDIDATE_GUARD_POLL_MILLISECONDS = 250


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


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    return sha256_bytes(read_bounded_regular(path))


def parse_scalar(text: str, key: str) -> str:
    matches = re.findall(rf"(?m)^{re.escape(key)}:\s*([^\r\n]+)\s*$", text)
    require(len(matches) == 1, f"scalar field missing/duplicated:{key}")
    return matches[0].strip().strip('"\'')


def parse_block(text: str, name: str) -> tuple[str, ...]:
    begin = f"{name}_begin"
    end = f"{name}_end"
    require(text.count(begin) == 1 and text.count(end) == 1, f"candidate block marker invalid:{name}")
    try:
        body = text.split(begin + "\n", 1)[1].split("\n" + end, 1)[0]
    except IndexError:
        raise CheckError(f"candidate block malformed:{name}") from None
    rows = tuple(line for line in body.splitlines() if line)
    require(len(rows) == len(set(rows)), f"candidate block duplicate:{name}")
    return rows


def parse_hash_manifest(text: str, name: str, expected_paths: tuple[str, ...]) -> dict[str, str]:
    parsed: list[tuple[str, str]] = []
    for line in parse_block(text, name):
        match = re.fullmatch(r"([0-9a-f]{64})  (.+)", line)
        require(match is not None and safe_relative_key(match.group(2)), f"candidate manifest row malformed:{name}")
        parsed.append((match.group(2), match.group(1)))
    require(tuple(path for path, _ in parsed) == expected_paths, f"candidate manifest scope/order mismatch:{name}")
    return dict(parsed)


def parse_dual_hash_manifest(text: str, name: str, expected_paths: tuple[str, ...]) -> dict[str, tuple[str, str]]:
    parsed: list[tuple[str, str, str]] = []
    for line in parse_block(text, name):
        match = re.fullmatch(r"([0-9a-f]{64}) ([0-9a-f]{64})  (.+)", line)
        require(match is not None and safe_relative_key(match.group(3)), f"candidate dual manifest malformed:{name}")
        parsed.append((match.group(3), match.group(1), match.group(2)))
    require(tuple(path for path, _, _ in parsed) == expected_paths, f"candidate dual manifest scope/order mismatch:{name}")
    return {path: (before, after) for path, before, after in parsed}


def hash_paths(paths: tuple[str, ...], repo: Path = Path(".")) -> dict[str, str]:
    repo = repo.resolve()
    result: dict[str, str] = {}
    for key in paths:
        require(safe_relative_key(key), "hash path invalid")
        absolute = repo / key
        require(absolute.parent.resolve(strict=False).is_relative_to(repo), "hash path escaped root")
        result[key] = sha256_file(absolute)
    return result


def repository_delta_snapshot(repo: Path = Path("."), *, exclude: frozenset[str] = frozenset()) -> tuple[tuple[str, str], ...]:
    repo = repo.resolve()
    changed = parse_nul_inventory(default_git_runner(
        repo, ("diff", "--name-only", "-z", "HEAD", "--", "."), None,
    ))
    untracked = parse_nul_inventory(default_git_runner(
        repo, ("ls-files", "--others", "--exclude-standard", "-z"), None,
    ))
    paths = sorted({decode_path(item) for item in (*changed, *untracked)} - set(exclude))
    rows: list[tuple[str, str]] = []
    for key in paths:
        absolute = repo / key
        if not absolute.exists():
            rows.append((key, "deleted"))
        else:
            rows.append((key, sha256_file(absolute)))
    return tuple(rows)


def repository_delta_digest(rows: tuple[tuple[str, str], ...]) -> str:
    return sha256_bytes(json.dumps(rows, ensure_ascii=True, separators=(",", ":")).encode("utf-8"))


def expected_plan_task_ids(plan: int) -> tuple[str, ...]:
    prefix = f"64-{plan:02d}-"
    return tuple(task for task in EXPECTED_TASKS if task.startswith(prefix))


def validate_plan_graph(required_summary_through: int = 13) -> None:
    plans = sorted(PHASE_DIR.glob("64-??-PLAN.md"))
    require(len(plans) == EXPECTED_PLAN_COUNT, "plan inventory mismatch")
    observed_tasks: list[str] = []
    required_requirements = ("SCLERA-14", "SCLERA-15", "SCLERA-16", "SCLERA-17", "SCLERA-18", "OUT-05")
    observed_requirements: set[str] = set()
    for number, path in enumerate(plans, start=1):
        require(path.name == f"64-{number:02d}-PLAN.md", "plan order mismatch")
        text = read(path)
        wave = re.search(r"(?m)^wave:\s*(\d+)\s*$", text)
        depends = re.search(r"(?m)^depends_on:\s*\[([^\]]*)\]\s*$", text)
        require(wave is not None and int(wave.group(1)) == number, "plan wave mismatch")
        expected_dep = "" if number == 1 else f"64-{number - 1:02d}"
        require(depends is not None and depends.group(1).strip() == expected_dep, "plan dependency mismatch")
        observed_requirements.update(requirement for requirement in required_requirements if requirement in text)
        task_tags = re.findall(r"<task(?:\s+[^>]*)?>", text)
        explicit = re.findall(r'<task[^>]*\sid="([^"]+)"', text)
        expected = expected_plan_task_ids(number)
        require(len(task_tags) == len(expected), "plan task cardinality mismatch")
        if number in CURRENT_STRUCTURE_PLAN_IDS:
            require(all(requirement in text for requirement in required_requirements), "current plan requirements incomplete")
            require(tuple(explicit) == expected, "current plan task ids missing/reordered")
            for token in ("must_haves:", "<threat_model>", "<verify>", "<done>"):
                require(token in text, "current plan structure incomplete")
            require(
                "<artifacts_this_phase_produces>" in text or "## Artifacts this phase produces" in text,
                "current plan artifacts section incomplete",
            )
        else:
            derived = tuple(f"64-{number:02d}-{ordinal:02d}" for ordinal in range(1, len(task_tags) + 1))
            require(derived == expected, "historical derived task ids mismatch")
            require(not explicit or tuple(explicit) == expected, "historical explicit task ids mismatch")
        observed_tasks.extend(expected)
        if number <= required_summary_through:
            require((PHASE_DIR / f"64-{number:02d}-SUMMARY.md").is_file(), "required plan summary missing")
    require(tuple(observed_tasks) == EXPECTED_TASKS, "task inventory mismatch")
    require(observed_requirements == set(required_requirements), "phase requirements incomplete")


def parse_no_skip_evidence(text: str) -> dict[str, int]:
    values: dict[str, int] = {}
    for key in ("executed_tests", "failed_tests", "skipped_tests", "opt_in_tests_executed"):
        matches = re.findall(rf"(?m)^{key}:\s*(\d+)\s*$", text)
        require(len(matches) == 1, f"no-skip aggregate field invalid:{key}")
        values[key] = int(matches[0])
    require(values["executed_tests"] > 0, "no-skip executed count empty")
    require(values["failed_tests"] == 0, "no-skip failures present")
    require(values["skipped_tests"] == 0, "no-skip skips present")
    require(values["opt_in_tests_executed"] == len(OPT_IN_TESTS), "no-skip opt-in count mismatch")
    identities = tuple(re.findall(r"(?m)^opt_in_test:\s*([^\s]+)\s+passed\s*$", text))
    require(identities == OPT_IN_TESTS, "no-skip opt-in identities missing/reordered")
    return values


def validate_post_repair_authority(*, require_eligibility: bool) -> dict[str, int]:
    evidence = read(POST_REPAIR_EVIDENCE)
    values = parse_no_skip_evidence(evidence)
    validate_review(read(POST_REPAIR_REVIEW))
    validate_code_review(read(POST_REPAIR_CODE_REVIEW))
    validate_review_fix(read(POST_REPAIR_REVIEW_FIX))
    validate_security(read(POST_REPAIR_SECURITY))
    if require_eligibility:
        validate_eligibility(read(POST_REPAIR_PRE_PROMOTION))
    return values


def parse_post_repair_candidate(text: str) -> dict[str, object]:
    status = parse_scalar(text, "status")
    require(status in ("candidate_passed", "gaps_found"), "candidate status invalid")
    require(parse_scalar(text, "schema") == CANDIDATE_SCHEMA, "candidate schema invalid")
    require(parse_scalar(text, "verification_stage") == "post_repair_candidate", "candidate stage invalid")
    require(parse_scalar(text, "independent") == "true", "candidate independence missing")
    plans = parse_block(text, "plan_inventory")
    tasks = parse_block(text, "task_inventory")
    require(plans == tuple(f"64-{number:02d}" for number in range(1, 20)), "candidate plan inventory mismatch")
    require(tasks == EXPECTED_TASKS, "candidate task inventory mismatch")
    input_owners = parse_dual_hash_manifest(text, "input_owner_manifest", CANDIDATE_INPUT_OWNER_PATHS)
    immutable_owners = parse_dual_hash_manifest(text, "immutable_owner_manifest", CANDIDATE_IMMUTABLE_OWNER_PATHS)
    sources = parse_hash_manifest(text, "relevant_source_manifest", RELEVANT_SOURCE_PATHS)
    authority = parse_hash_manifest(text, "authority_manifest", POST_REPAIR_AUTHORITY_PATHS)
    opt_in_rows = parse_block(text, "opt_in_tests")
    threats = parse_block(text, "threats")
    return {
        "status": status,
        "guard_nonce": parse_scalar(text, "guard_nonce"),
        "repository_delta_digest": parse_scalar(text, "pre_repository_delta_digest"),
        "input_owners": input_owners,
        "immutable_owners": immutable_owners,
        "sources": sources,
        "authority": authority,
        "opt_in_rows": opt_in_rows,
        "threats": threats,
        "executed_tests": int(parse_scalar(text, "executed_tests")),
        "failed_tests": int(parse_scalar(text, "failed_tests")),
        "skipped_tests": int(parse_scalar(text, "skipped_tests")),
        "opt_in_tests_executed": int(parse_scalar(text, "opt_in_tests_executed")),
        "unresolved_high": int(parse_scalar(text, "unresolved_high")),
    }


def capture_candidate_baseline(repo: Path = Path(".")) -> dict[str, object]:
    require(not (repo / POST_REPAIR_CANDIDATE).exists(), "candidate already exists")
    return {
        "delta": repository_delta_snapshot(repo),
        "input_owners": hash_paths(CANDIDATE_INPUT_OWNER_PATHS, repo),
        "immutable_owners": hash_paths(CANDIDATE_IMMUTABLE_OWNER_PATHS, repo),
        "sources": hash_paths(RELEVANT_SOURCE_PATHS, repo),
        "authority": hash_paths(POST_REPAIR_AUTHORITY_PATHS, repo),
    }


def validate_post_repair_candidate(
    text: str,
    *,
    repo: Path = Path("."),
    expected_nonce: str | None = None,
    baseline: dict[str, object] | None = None,
) -> dict[str, object]:
    parsed = parse_post_repair_candidate(text)
    nonce = parsed["guard_nonce"]
    require(isinstance(nonce, str) and re.fullmatch(r"[0-9a-f]{32}", nonce) is not None, "candidate nonce invalid")
    if expected_nonce is not None:
        require(nonce == expected_nonce, "candidate nonce mismatch")
    live_inputs = hash_paths(CANDIDATE_INPUT_OWNER_PATHS, repo)
    live_immutable = hash_paths(CANDIDATE_IMMUTABLE_OWNER_PATHS, repo)
    live_sources = hash_paths(RELEVANT_SOURCE_PATHS, repo)
    live_authority = hash_paths(POST_REPAIR_AUTHORITY_PATHS, repo)
    for key, (before, after) in parsed["input_owners"].items():
        require(before == after == live_inputs[key], "candidate input owner drift")
    for key, (before, after) in parsed["immutable_owners"].items():
        require(before == after == live_immutable[key], "candidate immutable owner drift")
    require(parsed["sources"] == live_sources, "candidate source manifest stale")
    require(parsed["authority"] == live_authority, "candidate authority manifest stale")
    current_delta = repository_delta_snapshot(repo, exclude=frozenset((str(POST_REPAIR_CANDIDATE),)))
    require(parsed["repository_delta_digest"] == repository_delta_digest(current_delta), "candidate repository baseline drift")
    if baseline is not None:
        require(baseline["delta"] == current_delta, "candidate extra repository write")
        require(baseline["input_owners"] == live_inputs, "candidate baseline owner drift")
        require(baseline["immutable_owners"] == live_immutable, "candidate baseline immutable-owner drift")
        require(baseline["sources"] == live_sources, "candidate baseline source drift")
        require(baseline["authority"] == live_authority, "candidate baseline authority drift")
    require(parsed["unresolved_high"] == 0, "candidate HIGH finding open")
    require(parsed["threats"] == tuple(f"{threat}: pass" for threat in THREATS), "candidate threat inventory incomplete")
    if parsed["status"] == "candidate_passed":
        evidence = validate_post_repair_authority(require_eligibility=True)
        require(parsed["executed_tests"] == evidence["executed_tests"] > 0, "candidate no-skip count drift")
        require(parsed["failed_tests"] == 0 and parsed["skipped_tests"] == 0, "candidate suite not clean")
        require(parsed["opt_in_tests_executed"] == 8, "candidate opt-in count mismatch")
        require(parsed["opt_in_rows"] == tuple(f"{identity} passed" for identity in OPT_IN_TESTS), "candidate opt-in identities invalid")
        require(parse_scalar(text, "promotion_authorized") == "true", "candidate promotion authority invalid")
    else:
        require(parse_scalar(text, "promotion_authorized") == "false", "failed candidate authorized promotion")
        require(parse_scalar(text, "required_next_action") == "execute_64_19_full_requarantine", "failed candidate next action invalid")
        require(bool(parse_block(text, "blocker_categories")), "failed candidate blocker categories empty")
    return parsed


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


def validate_source_bound_artifact(
    text: str,
    *,
    schema_key: str,
    independent: str,
    expected_scalars: dict[str, str],
    repo: Path = Path("."),
) -> None:
    schema, stage = POST_REPAIR_SCHEMAS[schema_key]
    required = {
        "schema": schema,
        "verification_stage": stage,
        "independent": independent,
        **expected_scalars,
    }
    for key, expected in required.items():
        require(parse_scalar(text, key) == expected, f"fresh authority scalar invalid:{schema_key}:{key}")
    parse_review_source_manifest(text)
    validate_review_source_state(text, repo)
    non_manifest = re.sub(
        r"relevant_source_manifest_begin\n.*?\nrelevant_source_manifest_end",
        "", text, flags=re.DOTALL,
    )
    require("/Users/" not in non_manifest and "example-images/" not in non_manifest, "authority contains locator")


def validate_review(review: str, repo: Path = Path(".")) -> None:
    validate_source_bound_artifact(
        review,
        schema_key="review",
        independent="true",
        expected_scalars={
            "status": "passed",
            "decision": "pass",
            "original_detail": "true",
            "blinded_items": "4",
        },
        repo=repo,
    )
    rows = tuple(
        match.groups()
        for match in re.finditer(
            r"(?m)^\|\s*([a-z][a-z0-9_]*)\s*\|\s*(pass|not_applicable)\s*\|\s*(pass|not_applicable)\s*\|\s*(pass|not_applicable)\s*\|\s*$",
            review,
        )
    )
    require(rows == REVIEW_CATEGORY_ROWS, "review category inventory/disposition invalid")


def validate_code_review(text: str, repo: Path = Path(".")) -> None:
    validate_source_bound_artifact(
        text,
        schema_key="code_review",
        independent="true",
        expected_scalars={
            "status": "passed",
            "review_status": "passed",
            "unresolved_high": "0",
            "unresolved_warning": "0",
            "promotion_authorized": "false",
        },
        repo=repo,
    )


def validate_review_fix(text: str, repo: Path = Path(".")) -> None:
    validate_source_bound_artifact(
        text,
        schema_key="review_fix",
        independent="false",
        expected_scalars={
            "status": "passed",
            "unresolved_high": "0",
            "unresolved_warning": "0",
            "post_review_image_tuning": "false",
            "promotion_authorized": "false",
        },
        repo=repo,
    )


def validate_security(text: str, repo: Path = Path(".")) -> None:
    validate_source_bound_artifact(
        text,
        schema_key="security",
        independent="true",
        expected_scalars={
            "status": "passed",
            "threats_open": "0",
            "threats_closed": "8",
            "unresolved_high": "0",
            "promotion_authorized": "false",
        },
        repo=repo,
    )


def validate_eligibility(text: str, repo: Path = Path(".")) -> None:
    validate_source_bound_artifact(
        text,
        schema_key="eligibility",
        independent="true",
        expected_scalars={
            "status": "eligible_promotion_pending",
            "unresolved_high": "0",
            "promotion_authorized": "false",
        },
        repo=repo,
    )


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
    require(len(plans) == EXPECTED_PLAN_COUNT, "plan inventory mismatch")
    observed: list[str] = []
    for number, path in enumerate(plans, start=1):
        text = read(path)
        expected = expected_plan_task_ids(number)
        explicit = tuple(re.findall(r'<task[^>]*\sid="([^"]+)"', text))
        if explicit:
            require(explicit == expected, "task inventory mismatch")
        observed.extend(expected)
    require(tuple(observed) == EXPECTED_TASKS, "task inventory mismatch")
    return tuple(observed)


def validate_lifecycle_inventory(inventory: dict[str, object]) -> None:
    require(task_ids_from_plans() == EXPECTED_TASKS, "task inventory mismatch")
    threats = inventory.get("threats", [])
    require(isinstance(threats, list), "threat inventory shape mismatch")
    require(tuple(item.get("id") for item in threats if isinstance(item, dict)) == THREATS, "threat inventory mismatch")
    require(len(threats) == 8 and all(isinstance(item, dict) and item.get("severity") == "HIGH" for item in threats), "non-HIGH threat disposition")


def validate_stage(mode: str) -> None:
    canonical = read(PHASE_DIR / "64-VERIFICATION.md")
    if mode == "final":
        for token in ("verification_stage: post_repair_final", "independent: true", "status: passed"):
            require(token in canonical, "canonical final verification incomplete")
        candidate = read(POST_REPAIR_CANDIDATE)
        validate_post_repair_candidate(candidate)
        require("status: candidate_passed" in candidate, "candidate verification incomplete")
    else:
        require("status: gaps_found" in canonical, "canonical verification passed prematurely")
        require("promotion_status: unproven" in canonical, "canonical quarantine incomplete")
    if mode == "promotion-pending-verification":
        validate_eligibility(read(POST_REPAIR_PRE_PROMOTION))


def validate_validation_ledger(mode: str) -> None:
    if mode == "pre-promotion":
        return
    text = read(PHASE_DIR / "64-VALIDATION.md")
    ids = tuple(re.findall(r"^\| (64-\d\d-\d\d) \|", text, re.MULTILINE))
    require(ids == EXPECTED_TASKS, "validation rows missing/duplicated/reordered")
    lowered = text.lower()
    if mode == "promotion-pending-verification":
        rows = [line.lower() for line in text.splitlines() if re.match(r"^\| 64-(18|19)-01 \|", line)]
        require(len(rows) == 2 and all("pending" in row or "not-run" in row or "not run" in row for row in rows), "future gates not visibly pending")
        require("34/34" not in text, "validation finalized before candidate")
    elif mode == "final":
        require("34/34" in text, "final validation total missing")
        current_rows = [line.lower() for line in text.splitlines() if re.match(r"^\| 64-(14|15|16|17|18|19)-", line)]
        require(not any(token in "\n".join(current_rows) for token in ("skipped", "conditional pass", "not-run", "not run", "failed")), "final validation has current non-executed evidence")
        historical = next((line.lower() for line in text.splitlines() if line.startswith("| 64-13-01 |")), "")
        require("historical" in historical and "superseded" in historical, "historical Plan 13 disposition missing")
    elif mode == "quarantine":
        final_row = next((line.lower() for line in text.splitlines() if line.startswith("| 64-19-01 |")), "")
        require("failed" in final_row and "requarantine" in final_row.replace("-", ""), "quarantine validation row missing")
        require("34/34" not in text, "quarantine validation falsely complete")


def validate_lifecycle_content(texts: str, mode: str) -> None:
    if mode == "promotion-pending-verification":
        require(re.search(r"promotion.?pending|post.?promotion", texts, re.IGNORECASE) is not None, "lifecycle pending state missing")
        require(all(f"64-{plan:02d}" in texts for plan in range(14, 20)), "final serial gates missing")
        require("candidate" in texts.lower() and "bounded final transaction" in texts.lower(), "final gates not explicitly awaited")
    elif mode == "final":
        require(re.search(r"Phase 64.*(?:complete|completed)|64.*100%", texts, re.IGNORECASE | re.DOTALL) is not None, "lifecycle final state missing")
        require(re.search(r"Phase 65.*(?:unblocked|current|ready)", texts, re.IGNORECASE | re.DOTALL) is not None, "Phase 65 not unblocked by final authority")
    elif mode == "quarantine":
        require(re.search(r"Phase 64.*(?:gaps_found|gaps found|incomplete)", texts, re.IGNORECASE | re.DOTALL) is not None, "lifecycle quarantine missing")
        require(re.search(r"Phase 65.*blocked", texts, re.IGNORECASE | re.DOTALL) is not None, "Phase 65 quarantine missing")


def validate_lifecycle_text(mode: str) -> None:
    validate_lifecycle_content(
        "\n".join(read(path) for path in (Path("PLANS.md"), Path(".planning/STATE.md"), Path(".planning/ROADMAP.md"))),
        mode,
    )


def run_live(mode: str, selected: str | None, *, emit: bool = True) -> int:
    promoted = mode in ("promotion-pending-verification", "final")
    aggregate_cache: dict[str, object] | None = None
    scan_cache: dict[str, int | str] | None = None
    authority_cache: dict[str, int] | None = None

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

    def authority() -> dict[str, int]:
        nonlocal authority_cache
        if authority_cache is None:
            authority_cache = validate_post_repair_authority(
                require_eligibility=mode != "pre-promotion",
            )
        return authority_cache

    summary_through = 14 if mode == "pre-promotion" else 16 if mode == "promotion-pending-verification" else 18

    checks: dict[str, Callable[[], int]] = {
        "T-64-01": lambda: (validate_renderer_source(read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")), True), 7)[1],
        "T-64-02": lambda: (validate_parser_artifacts(read(PHASE_DIR / "check_sclera_renderer_outputs.py"), read(POST_REPAIR_EVIDENCE)), authority(), 10)[2],
        "T-64-03": lambda: (validate_adversarial_source(read(Path("BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift"))), validate_proposal_exposure(), aggregate(), 20)[3],
        "T-64-04": lambda: (validate_final_output_sources(read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift")), read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift")), read(Path("BeautySDK/Sources/BeautySDK/BeautyEngine.swift"))), 8)[1],
        "T-64-05": lambda: (validate_review(read(POST_REPAIR_REVIEW)), authority(), 12)[2],
        "T-64-06": lambda: (validate_privacy(scan(), aggregate()), validate_proposal_exposure(), 12)[2],
        "T-64-07": lambda: (validate_product_state(*(read(path) for path in PRODUCT_FILES), promoted), validate_stage(mode), 12)[2],
        "T-64-08": lambda: (validate_plan_graph(summary_through), validate_lifecycle_inventory(json.loads(read(PHASE_DIR / "64-THREAT-INVENTORY.json"))), validate_validation_ledger(mode), validate_lifecycle_text(mode), authority(), 14)[5],
    }
    counts: dict[str, int] = {}
    for threat in ((selected,) if selected else THREATS):
        counts[threat] = checks[threat]()
    output: dict[str, object]
    if selected == "T-64-06":
        output = dict(scan())
    else:
        output = {"status": "pass", "mode": mode, "checks": counts}
    if emit:
        print(json.dumps(output, separators=(",", ":")))
    return sum(counts.values())


def run_candidate_guard(repo: Path = Path(".")) -> int:
    run_live("promotion-pending-verification", None, emit=False)
    validate_plan_graph(17)
    baseline = capture_candidate_baseline(repo)
    nonce = secrets.token_hex(16)
    print(json.dumps({
        "schema": CANDIDATE_SCHEMA,
        "status": "ready",
        "guard_nonce": nonce,
    }, separators=(",", ":")), flush=True)
    deadline = time.monotonic() + CANDIDATE_GUARD_TIMEOUT_SECONDS
    previous: bytes | None = None
    candidate_bytes: bytes | None = None
    while time.monotonic() < deadline:
        try:
            current = read_bounded_regular(repo / POST_REPAIR_CANDIDATE)
        except CheckError:
            previous = None
            time.sleep(CANDIDATE_GUARD_POLL_MILLISECONDS / 1000)
            continue
        if previous == current:
            candidate_bytes = current
            break
        previous = current
        time.sleep(CANDIDATE_GUARD_POLL_MILLISECONDS / 1000)
    require(candidate_bytes is not None, "candidate guard timeout")
    try:
        candidate_text = candidate_bytes.decode("utf-8", errors="strict")
    except UnicodeDecodeError:
        raise CheckError("candidate encoding invalid") from None
    parsed = validate_post_repair_candidate(
        candidate_text, repo=repo, expected_nonce=nonce, baseline=baseline,
    )
    print(json.dumps({
        "schema": CANDIDATE_SCHEMA,
        "status": "pass",
        "branch": parsed["status"],
        "plan_count": EXPECTED_PLAN_COUNT,
        "task_count": len(EXPECTED_TASKS),
        "owner_count": len(CANDIDATE_INPUT_OWNER_PATHS),
    }, separators=(",", ":")))
    return 1


def run_candidate_validation(repo: Path = Path(".")) -> int:
    run_live("promotion-pending-verification", None, emit=False)
    validate_plan_graph(17)
    parsed = validate_post_repair_candidate(read(repo / POST_REPAIR_CANDIDATE), repo=repo)
    print(json.dumps({
        "schema": CANDIDATE_SCHEMA,
        "status": "pass",
        "branch": parsed["status"],
        "plan_count": EXPECTED_PLAN_COUNT,
        "task_count": len(EXPECTED_TASKS),
        "owner_count": len(CANDIDATE_INPUT_OWNER_PATHS),
    }, separators=(",", ":")))
    return 1


def synthetic_candidate_text() -> str:
    digest = "a" * 64
    dual = lambda paths: "\n".join(f"{digest} {digest}  {path}" for path in paths)
    single = lambda paths: "\n".join(f"{digest}  {path}" for path in paths)
    return "\n".join((
        f"schema: {CANDIDATE_SCHEMA}",
        "verification_stage: post_repair_candidate",
        "independent: true",
        "status: candidate_passed",
        "promotion_authorized: true",
        f"guard_nonce: {'b' * 32}",
        f"pre_repository_delta_digest: {digest}",
        "executed_tests: 644", "failed_tests: 0", "skipped_tests: 0",
        "opt_in_tests_executed: 8", "unresolved_high: 0",
        "plan_inventory_begin", *(f"64-{number:02d}" for number in range(1, 20)), "plan_inventory_end",
        "task_inventory_begin", *EXPECTED_TASKS, "task_inventory_end",
        "input_owner_manifest_begin", dual(CANDIDATE_INPUT_OWNER_PATHS), "input_owner_manifest_end",
        "immutable_owner_manifest_begin", dual(CANDIDATE_IMMUTABLE_OWNER_PATHS), "immutable_owner_manifest_end",
        "relevant_source_manifest_begin", single(RELEVANT_SOURCE_PATHS), "relevant_source_manifest_end",
        "authority_manifest_begin", single(POST_REPAIR_AUTHORITY_PATHS), "authority_manifest_end",
        "opt_in_tests_begin", *(f"{identity} passed" for identity in OPT_IN_TESTS), "opt_in_tests_end",
        "threats_begin", *(f"{threat}: pass" for threat in THREATS), "threats_end",
    )) + "\n"


def run_candidate_self_tests() -> int:
    fixture = synthetic_candidate_text()
    parsed = parse_post_repair_candidate(fixture)
    require(parsed["status"] == "candidate_passed", "candidate positive fixture rejected")
    first_task = EXPECTED_TASKS[0]
    first_owner = CANDIDATE_INPUT_OWNER_PATHS[0]
    first_source = RELEVANT_SOURCE_PATHS[0]
    first_authority = POST_REPAIR_AUTHORITY_PATHS[0]
    mutations = (
        fixture.replace(CANDIDATE_SCHEMA, "wrong-schema", 1),
        fixture.replace("independent: true", "independent: false", 1),
        fixture.replace("status: candidate_passed", "status: passed", 1),
        fixture.replace(f"{first_task}\n", "", 1),
        fixture.replace(f"{first_task}\n{EXPECTED_TASKS[1]}\n", f"{EXPECTED_TASKS[1]}\n{first_task}\n", 1),
        fixture.replace(f"{first_task}\n", f"{first_task}\n{first_task}\n", 1),
        fixture.replace(f"{'a' * 64} {'a' * 64}  {first_owner}", f"{'0' * 64} {'a' * 64}  {first_owner}", 1),
        fixture.replace(f"{'a' * 64} {'a' * 64}  {first_owner}\n", "", 1),
        fixture.replace(f"{'a' * 64}  {first_source}\n", "", 1),
        fixture.replace(f"{'a' * 64}  {first_authority}\n", "", 1),
        fixture.replace("opt_in_tests_executed: 8", "opt_in_tests_executed: 7", 1),
        fixture.replace(f"{OPT_IN_TESTS[0]} passed\n", "", 1),
        fixture.replace(f"{OPT_IN_TESTS[0]} passed\n", f"{OPT_IN_TESTS[0]} failed\n", 1),
        fixture.replace(f"{THREATS[0]}: pass\n", "", 1),
        fixture.replace("unresolved_high: 0", "unresolved_high: 1", 1),
        fixture.replace("failed_tests: 0", "failed_tests: 1", 1),
        fixture.replace("skipped_tests: 0", "skipped_tests: 1", 1),
        fixture.replace("executed_tests: 644", "executed_tests: 0", 1),
        fixture.replace("guard_nonce: " + "b" * 32, "guard_nonce: malformed", 1),
        fixture.replace("authority_manifest_end", f"{'a' * 64}  extra/path\nauthority_manifest_end", 1),
    )
    rejected = 0
    for mutation in mutations:
        try:
            value = parse_post_repair_candidate(mutation)
            require(value["guard_nonce"] == "b" * 32, "candidate nonce invalid")
            require(value["unresolved_high"] == 0, "candidate HIGH mutation accepted")
            require(value["executed_tests"] > 0, "candidate zero execution accepted")
            require(value["failed_tests"] == value["skipped_tests"] == 0, "candidate failure/skip accepted")
            require(value["opt_in_tests_executed"] == 8, "candidate opt-in count accepted")
            require(value["opt_in_rows"] == tuple(f"{identity} passed" for identity in OPT_IN_TESTS), "candidate opt-in rows accepted")
            require(value["threats"] == tuple(f"{threat}: pass" for threat in THREATS), "candidate threat mutation accepted")
            for before, after in value["input_owners"].values():
                require(before == after, "candidate owner mutation accepted")
        except (CheckError, ValueError, TypeError):
            rejected += 1
        else:
            raise CheckError("candidate mutation accepted")
    require(rejected == len(mutations), "candidate self-test coverage incomplete")
    return rejected


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
        manifest = (
            f"relevant_source_tree_oid: {tree_oid}\n"
            "relevant_source_manifest_begin\n"
            f"{rows}\n"
            "relevant_source_manifest_end\n"
        )
        category_rows = "\n".join(
            f"| {category} | {positive} | {negative} | {no_face} |"
            for category, positive, negative, no_face in REVIEW_CATEGORY_ROWS
        )
        review = (
            f"schema: {POST_REPAIR_SCHEMAS['review'][0]}\n"
            f"verification_stage: {POST_REPAIR_SCHEMAS['review'][1]}\n"
            "independent: true\nstatus: passed\ndecision: pass\n"
            "original_detail: true\nblinded_items: 4\n"
            "| category | positive | negative | no_face |\n"
            f"{category_rows}\n"
            f"{manifest}"
        )
        validate_review(review, root)

        code_review = (
            f"schema: {POST_REPAIR_SCHEMAS['code_review'][0]}\n"
            f"verification_stage: {POST_REPAIR_SCHEMAS['code_review'][1]}\n"
            "independent: true\nstatus: passed\nreview_status: passed\n"
            "unresolved_high: 0\nunresolved_warning: 0\npromotion_authorized: false\n"
            f"{manifest}"
        )
        review_fix = (
            f"schema: {POST_REPAIR_SCHEMAS['review_fix'][0]}\n"
            f"verification_stage: {POST_REPAIR_SCHEMAS['review_fix'][1]}\n"
            "independent: false\nstatus: passed\nunresolved_high: 0\nunresolved_warning: 0\n"
            "post_review_image_tuning: false\npromotion_authorized: false\n"
            f"{manifest}"
        )
        security = (
            f"schema: {POST_REPAIR_SCHEMAS['security'][0]}\n"
            f"verification_stage: {POST_REPAIR_SCHEMAS['security'][1]}\n"
            "independent: true\nstatus: passed\nthreats_open: 0\nthreats_closed: 8\n"
            "unresolved_high: 0\npromotion_authorized: false\n"
            f"{manifest}"
        )
        eligibility = (
            f"schema: {POST_REPAIR_SCHEMAS['eligibility'][0]}\n"
            f"verification_stage: {POST_REPAIR_SCHEMAS['eligibility'][1]}\n"
            "independent: true\nstatus: eligible_promotion_pending\n"
            "unresolved_high: 0\npromotion_authorized: false\n"
            f"{manifest}"
        )
        validate_code_review(code_review, root)
        validate_review_fix(review_fix, root)
        validate_security(security, root)
        validate_eligibility(eligibility, root)

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

        decoder = ".planning/phases/61-teeth-output-safety-and-independent-closeout/check_teeth_renderer_outputs.py"
        (root / decoder).write_bytes(b"post-review decoder drift\n")
        expect_failure(lambda: validate_review(review, root))
        (root / decoder).write_bytes(originals[decoder])
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
        expect_failure(lambda: validate_review(review.replace(
            "relevant_source_manifest_end",
            rows.splitlines()[0] + "\nrelevant_source_manifest_end",
        ), root))
        expect_failure(lambda: validate_review(review.replace(
            rows.splitlines()[0], "malformed manifest row", 1,
        ), root))
        expect_failure(lambda: validate_review(review.replace(
            "| vessel_detail | pass | pass | not_applicable |\n", "", 1,
        ), root))
        expect_failure(lambda: validate_review(review.replace(
            "status: passed\n", "status: passed\nsource_path: /Users/private/fixture\n", 1,
        ), root))

        authority_mutations: tuple[tuple[Callable[[str, Path], None], str], ...] = (
            (validate_review, review.replace("status: passed\n", "status: failed\nstatus: passed\n", 1)),
            (validate_review, review.replace("decision: pass\n", "decision: fail\ndecision: pass\n", 1)),
            (validate_review, review.replace(POST_REPAIR_SCHEMAS["review"][0], "historical-review-v0", 1)),
            (validate_code_review, code_review.replace("status: passed\n", "status: failed\n", 1) + "Narrative review_status: passed\n"),
            (validate_code_review, code_review.replace("unresolved_high: 0\n", "unresolved_high: 1\nunresolved_high: 0\n", 1)),
            (validate_code_review, code_review.replace("review_status: passed\n", "Narrative review_status: passed\n", 1)),
            (validate_code_review, code_review.replace(POST_REPAIR_SCHEMAS["code_review"][0], "historical-code-review-v0", 1)),
            (validate_review_fix, review_fix.replace("post_review_image_tuning: false\n", "post_review_image_tuning: true\n", 1) + "Narrative post_review_image_tuning: false\n"),
            (validate_review_fix, review_fix.replace("independent: false\n", "independent: true\n", 1)),
            (validate_review_fix, review_fix.replace("unresolved_warning: 0\n", "unresolved_warning: 1\nunresolved_warning: 0\n", 1)),
            (validate_security, security.replace("threats_open: 0\n", "threats_open: 2\n", 1) + "Narrative threats_open: 0\n"),
            (validate_security, security.replace("threats_closed: 8\n", "threats_closed: 6\nthreats_closed: 8\n", 1)),
            (validate_security, security.replace(POST_REPAIR_SCHEMAS["security"][1], "historical_security", 1)),
            (validate_eligibility, eligibility.replace("status: eligible_promotion_pending\n", "status: gaps_found\n", 1) + "Narrative status: eligible_promotion_pending\n"),
            (validate_eligibility, eligibility.replace("promotion_authorized: false\n", "promotion_authorized: true\npromotion_authorized: false\n", 1)),
            (validate_eligibility, eligibility.replace(POST_REPAIR_SCHEMAS["eligibility"][0], "historical-eligibility-v0", 1)),
        )
        for validator, mutation in authority_mutations:
            expect_failure(lambda validator=validator, mutation=mutation: validator(mutation, root))
    require(rejected == 28, "review source self-test coverage incomplete")
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
    require(EXPECTED_PLAN_COUNT == 19 and len(EXPECTED_TASKS) == 34, "post-repair inventory missing")
    require(HISTORICAL_EXECUTED_PLAN_IDS == tuple(range(1, 14)), "historical structure boundary drift")
    require(CURRENT_STRUCTURE_PLAN_IDS == tuple(range(14, 20)), "current structure boundary drift")
    require(len(RELEVANT_SOURCE_PATHS) == 19, "post-repair source closure mismatch")
    validate_plan_graph(13)
    require("scan_repository_content" in globals(), "four-state content scanner missing")
    content_scan_rejections = run_content_scanner_self_tests()
    review_source_rejections = run_review_source_self_tests()
    candidate_rejections = run_candidate_self_tests()

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
        "candidate_rejections": candidate_rejections,
        "plans": EXPECTED_PLAN_COUNT, "tasks": len(EXPECTED_TASKS),
        "threats": 8, "states": 7,
    }, separators=(",", ":")))
    return passed + content_scan_rejections + review_source_rejections + candidate_rejections


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--pre-promotion", action="store_true")
    modes.add_argument("--promotion-pending-verification", action="store_true")
    modes.add_argument("--candidate-guard", action="store_true")
    modes.add_argument("--validate-candidate", action="store_true")
    modes.add_argument("--final", action="store_true")
    modes.add_argument("--quarantine", action="store_true")
    parser.add_argument("--threat", choices=THREATS)
    parser.add_argument("--repo-root", type=Path)
    args = parser.parse_args()
    if args.repo_root:
        os.chdir(args.repo_root)
    try:
        if args.self_test:
            require(not any((args.candidate_guard, args.validate_candidate, args.final, args.quarantine, args.promotion_pending_verification, args.pre_promotion, args.threat)), "self-test mode conflict")
            run_self_test()
        elif args.candidate_guard:
            require(args.threat is None, "candidate guard threat mode invalid")
            run_candidate_guard()
        elif args.validate_candidate:
            require(args.threat is None, "candidate validator threat mode invalid")
            run_candidate_validation()
        else:
            mode = "final" if args.final else "quarantine" if args.quarantine else "promotion-pending-verification" if args.promotion_pending_verification else "pre-promotion"
            run_live(mode, args.threat)
        return 0
    except (CheckError, json.JSONDecodeError, subprocess.SubprocessError, AssertionError, TypeError, KeyError, ValueError, OSError):
        if args.candidate_guard or args.validate_candidate:
            print(json.dumps({
                "schema": CANDIDATE_SCHEMA, "status": "fail", "branch": "gaps_found",
                "plan_count": 0, "task_count": 0, "owner_count": 0,
            }, separators=(",", ":")))
        elif args.threat == "T-64-06":
            print(json.dumps({
                "status": "fail", "tracked_blob_count": 0, "staged_blob_count": 0,
                "working_file_count": 0, "untracked_file_count": 0,
            }, separators=(",", ":")))
        else:
            print("phase64_closeout_failed", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
