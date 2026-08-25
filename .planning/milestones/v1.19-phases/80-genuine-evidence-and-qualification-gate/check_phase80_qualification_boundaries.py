#!/usr/bin/env python3
"""Independent, fail-closed Phase-80 qualification boundary checker."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import os
import re
import stat
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Callable

PHASE = 80
START = "fe4ea9e1c4d153513a769a4310c311b707c39adf"
SDK_TREE = "9e85d22c1e3c7b323d9ae935b5ba959ccd72b8a1"
ARCHIVE_TREE = "43179092cee11938ed207ce073ea628eaee6257c"
CONTEXT_HASH = "c750f860ed2ff568ff212a108df2c1cc39b18ab5cb4a94bb1ea7443605b469bb"
PATTERNS_HASH = "dfc2d58932080e1cbcbcc1598940bd36905587c9b45464c6fca6b4c72bba8b05"
EVALUATOR_HASH = "e1d94b4ac6531678483ad57a61a2a00b3b40d06aac6a0c51d6f565e63e1452a6"
EVALUATOR_TEST_HASH = "b190add22925114f62947b8cbcb7b3766a63fd0ffde9f1f8730d622b4528a80c"
CONTRACT_FILE_HASH = "d3387b500c2e44e1d2b580845e1944f19ad77ccd85acb39162fbc186afb6b72e"
CONTRACT_HASH = "1ef5def516bd7851efa82488543bd9d40c951825a36dd83278c4b2eac10a8107"
SOURCE_DIGEST = "8b928769e5921975880d714d01db39ceb0853f3313dce2e51da6909826a390d2"
EVIDENCE_DIGEST = "f25d9dedffdbcc9d4a313e4e2ecf76d7c76878bc9f90e769572ec4986ec2eb57"
SEMANTIC_HASH = "dd961264f201025c6abf332a97cd8976dcc6e4c42104bf578759b5b47ef99346"
PHASE75_EVIDENCE_HASH = "a5c1f92d4e9b95c5ef2f100755d7af0f61f0a025b65a867dacb08e640bfdd4e2"
RUBRIC_HASH = "c2008a5ca3112659eaf82d0e65689817d5381febf90c3cb794742433313da1ac"
BINDING_HASH = "fdfd0b4370cbca0d26df4727a2ff7fdaf8c474e6c1a85e935c9e0a54ea4b15e0"
RENDERER_HASH = "6d94e0f3a755932a7b1f257830068a42f855b2ec4fcc143dc8bf9ec3d624d251"

PD = Path(".planning/phases/80-genuine-evidence-and-qualification-gate")
CONTRACT = PD / "80-QUALIFICATION-CONTRACT.md"
EVALUATOR = PD / "80-qualification-decision.js"
EVALUATOR_TEST = PD / "80-qualification-decision.test.js"
CONTEXT = PD / "80-CONTEXT.md"
PATTERNS = PD / "80-PATTERNS.md"
ARCHIVE = Path(".planning/milestones/v1.18-phases")
PARAMETERS = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
RENDERER = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
MANIFEST = Path("BeautySDK/Sources/BeautyResources/Resources/manifest.json")
PACKAGE = Path("BeautySDK/Package.swift")
FACADE = Path("BeautySDK/Sources/BeautySDK")
V118_CHECKER = Path("scripts/check-v1-18-decision-binding.py")

PROMOTION = "promotion-ready-deterministic-editor"
NON_PROMOTION = "qualification-not-passed"
VERSION = "phase80-qualification-evaluator-v1"
CATEGORIES = ["genuine-positive", "genuine-negative", "ambiguity", "pose-occlusion", "identity-diversity", "protected-structure"]
PUBLIC = {"beauty_parameter_fields": 61, "preset_ids": 5, "renderer_cases": 74}
HASH_RE = re.compile(r"^[0-9a-f]{64}$")
OPAQUE_RE = re.compile(r"^[A-Za-z0-9_-]{1,64}$")
REASON_RE = re.compile(r"^[a-z][a-z0-9.-]{0,127}$")
SENSITIVE_RE = re.compile(r"(?:path|locator|rights.record|reviewer|timestamp|freeform|prose|raw|pixel|mask|landmark|coordinate|geometry|transcript|media)", re.I)
MAX_FILE = 4 * 1024 * 1024
MAX_CHILD = 1_048_576

EXPECTED_FIELDS = [
    "skinSmoothing", "skinWhitening", "skinRosy", "skinSharpen", "brightness",
    "contrast", "saturation", "temperature", "tint", "exposure", "highlight",
    "shadow", "faceSlim", "faceSmall", "faceVShape", "jawSlim", "chinLength",
    "faceContourSmooth", "templeFullness", "cheekboneSlim", "chinTaper", "eyeSize",
    "eyeDistance", "eyeYPosition", "eyeTailLift", "eyeHeight", "eyeLength",
    "upperEyelidLift", "pupilSize", "gazeCorrection", "lowerEyelidDrop", "eyeTilt",
    "innerCornerOpen", "outerCornerOpen", "eyeSymmetry", "eyebrowYPosition",
    "eyebrowThickness", "eyebrowLength", "eyebrowSpacing", "eyebrowHeadSpacing",
    "eyebrowTilt", "eyebrowPeakDefinition", "noseSlim", "noseWingSlim", "noseTipSize",
    "noseBridge", "noseRootNarrowing", "noseTipLift", "mouthSize", "mouthWidth",
    "smile", "mouthYPosition", "mouthTilt", "mouthXPosition", "lipPeakDefinition",
    "lipPlump", "lipColor", "filterId", "filterIntensity", "teethWhitening",
    "scleraRednessReduction",
]
PRESETS = ["natural", "clear", "refined", "male-natural", "id-photo-natural"]
FORBIDDEN = [
    "uppereyelidfullness", "upperlidfullness", "eyelidfullness", "lidfullness",
    "uppereyelidfatreduction", "upperlidfatreduction", "eyelidfatreduction",
    "lidfatreduction", "uppereyelidfatremoval", "upperlidfatremoval",
    "eyelidfatremoval", "lidfatremoval", "uppereyeliddefatting",
    "upperliddefatting", "eyeliddefatting", "liddefatting",
    "upper_eyelid_fullness", "upper_lid_fullness", "eyelid_fullness",
    "lid_fullness", "remove_upper_eyelid_fat", "remove_eyelid_fat",
    "remove_upper_lid_fat", "remove_lid_fat", "eyes.fat", "去脂",
]
SOURCE_OWNERS = (
    Path("BeautySDK/Sources/BeautyDetection/BeautyUpperEyelidSemanticSupport.swift"),
    Path("BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift"),
    Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyUpperEyelidFullnessEditor.swift"),
    Path("BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift"),
)
EVIDENCE_OWNERS = (
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidEditorSafetyTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidFullnessEditorTests.swift"),
    Path("BeautySDK/Tests/BeautyEffectsTests/BeautyUpperEyelidPackageIntegrationTests.swift"),
)

DECISION_KEYS = {
    "status", "phase", "contract_hash", "manifest_hash", "review_hash",
    "evaluator_version", "phase75_semantic_contract_hash",
    "phase75_evidence_contract_hash", "phase75_review_rubric_hash", "baseline_id",
    "baseline_source_digest", "baseline_evidence_digest", "baseline_binding_hash",
    "fixture_ids", "aggregate_metrics", "reason_counts", "public_absence", "decision",
}
AGGREGATE_KEYS = {
    "fixture_count", "metric_row_count", "passing_metric_row_count", "color_row_count",
    "color_target_max_abs_channel_delta_srgb8",
    "color_protected_max_abs_channel_delta_srgb8", "review_row_count",
    "passing_review_row_count", "category_pass_rates", "generated_evidence_weight",
    "genuine_evaluation_executed", "frozen_review_complete", "safety_gates_pass",
}
REASONS = {
    "evidence.missing-bundle", "evidence.malformed-manifest", "evidence.incomplete-taxonomy",
    "evidence.rights-failure", "evidence.asset-invalid", "evidence.duplicate",
    "evidence.mechanics-only", "review.missing", "review.malformed", "review.incomplete",
    "review.binding", "review.threshold", "qualification.metric.invalid",
    "qualification.metric.minimum-bound", "qualification.metric.maximum-bound",
    "qualification.metric.exact-bound", "qualification.color.invalid",
    "qualification.color.target-bound", "qualification.color.protected-bound",
    "qualification.binding", "qualification.public-absence", "qualification.privacy",
    "qualification.input", "qualification.write",
}
COMPLETE_FAILURES = {
    "review.threshold", "qualification.metric.minimum-bound",
    "qualification.metric.maximum-bound", "qualification.metric.exact-bound",
    "qualification.color.target-bound", "qualification.color.protected-bound",
}


class GateError(Exception):
    pass


def fail(reason: str) -> None:
    raise GateError(reason)


def sha256(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def array_key(value: Any) -> bytes:
    if not isinstance(value, dict):
        return str(value).encode()
    return "\0".join(str(value[k]) for k in ("fixture_id", "category", "role", "sha256", "reason") if k in value).encode()


def canonicalize(value: Any) -> Any:
    if isinstance(value, list):
        return sorted((canonicalize(x) for x in value), key=array_key)
    if isinstance(value, dict):
        return {k: canonicalize(value[k]) for k in sorted(value, key=lambda x: x.encode())}
    if isinstance(value, float) and not math.isfinite(value):
        fail("qualification.input")
    return value


def canonical_json(value: Any) -> str:
    return json.dumps(canonicalize(value), ensure_ascii=False, separators=(",", ":"))


def canonical_hash(value: Any) -> str:
    return sha256(canonical_json(value).encode())


def pairs_hook(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    output: dict[str, Any] = {}
    for key, value in pairs:
        if key in output:
            fail("qualification.input")
        output[key] = value
    return output


def parse_json(raw: str, reason: str = "qualification.input") -> Any:
    try:
        return json.loads(raw, object_pairs_hook=pairs_hook, parse_constant=lambda _: fail(reason))
    except GateError:
        raise
    except (json.JSONDecodeError, TypeError, UnicodeError, ValueError):
        fail(reason)


def resolve_regular(root: Path, relative: Path) -> Path:
    if relative.is_absolute() or not relative.parts or any(x in {"", ".", ".."} for x in relative.parts):
        fail("qualification.input")
    cursor = root
    try:
        if root.is_symlink() or not root.is_dir():
            fail("qualification.input")
        for index, part in enumerate(relative.parts):
            cursor /= part
            mode = cursor.lstat().st_mode
            if stat.S_ISLNK(mode):
                fail("qualification.input")
            if index < len(relative.parts) - 1 and not stat.S_ISDIR(mode):
                fail("qualification.input")
        if not stat.S_ISREG(cursor.lstat().st_mode):
            fail("qualification.input")
        return cursor
    except GateError:
        raise
    except OSError:
        fail("qualification.input")


def read_bytes(root: Path, relative: Path) -> bytes:
    candidate = resolve_regular(root, relative)
    fd: int | None = None
    try:
        fd = os.open(candidate, os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0))
        before = os.fstat(fd)
        if before.st_size <= 0 or before.st_size > MAX_FILE or not stat.S_ISREG(before.st_mode):
            fail("qualification.input")
        data = b""
        while len(data) < before.st_size:
            chunk = os.read(fd, min(65536, before.st_size - len(data)))
            if not chunk:
                fail("qualification.input")
            data += chunk
        after = os.fstat(fd)
        if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns, before.st_ctime_ns) != (
            after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns, after.st_ctime_ns
        ):
            fail("qualification.input")
        return data
    except GateError:
        raise
    except OSError:
        fail("qualification.input")
    finally:
        if fd is not None:
            try:
                os.close(fd)
            except OSError:
                pass


def read_text(root: Path, relative: Path) -> str:
    raw = read_bytes(root, relative)
    if raw.startswith(b"\xef\xbb\xbf"):
        fail("qualification.input")
    try:
        return raw.decode()
    except UnicodeError:
        fail("qualification.input")


def privacy_safe(value: Any) -> bool:
    if isinstance(value, dict):
        return all(isinstance(k, str) and not SENSITIVE_RE.search(k) and privacy_safe(v) for k, v in value.items())
    if isinstance(value, list):
        return all(privacy_safe(v) for v in value)
    if isinstance(value, str):
        return not any(x in value for x in ("/", "\\", "\n", "\r")) and not SENSITIVE_RE.search(value)
    return value is None or type(value) in {bool, int} or isinstance(value, float) and math.isfinite(value)


def run_child(command: list[str], root: Path, environment: dict[str, str] | None = None,
              timeout: int = 180) -> tuple[str, int]:
    try:
        child = subprocess.run(command, cwd=root, env=environment, check=False,
                               capture_output=True, text=True, timeout=timeout)
    except (OSError, UnicodeError, subprocess.SubprocessError):
        fail("qualification.binding")
    if child.stderr or not child.stdout or len(child.stdout.encode()) > MAX_CHILD:
        fail("qualification.binding")
    return child.stdout.strip(), child.returncode


def git_value(root: Path, args: list[str]) -> str:
    try:
        child = subprocess.run(["git", *args], cwd=root, check=False, capture_output=True,
                               text=True, timeout=20)
    except (OSError, UnicodeError, subprocess.SubprocessError):
        fail("qualification.binding")
    if child.returncode or child.stderr or len(child.stdout.encode()) > MAX_CHILD:
        fail("qualification.binding")
    return child.stdout.strip()


def phase_scope_errors(root: Path, mutation: dict[str, str] | None = None) -> list[str]:
    mutation = mutation or {}
    errors: list[str] = []
    if mutation.get("sdk", git_value(root, ["rev-parse", "HEAD:BeautySDK"])) != SDK_TREE:
        errors.append("scope.sdk-tree")
    if mutation.get("archive", git_value(root, ["rev-parse", f"HEAD:{ARCHIVE}"])) != ARCHIVE_TREE:
        errors.append("scope.archive-tree")
    if mutation.get("context", sha256(read_bytes(root, CONTEXT))) != CONTEXT_HASH:
        errors.append("scope.context")
    if mutation.get("patterns", sha256(read_bytes(root, PATTERNS))) != PATTERNS_HASH:
        errors.append("scope.patterns")
    # The phase-start commit predates the planner-owned PATTERNS artifact. Its
    # pinned content hash is the authority; history immutability applies to the
    # pre-existing SDK and v1.18 archive trees.
    protected = ["BeautySDK", str(ARCHIVE), str(CONTEXT), str(PATTERNS)]
    history = git_value(root, ["diff", "--name-only", f"{START}..HEAD", "--", "BeautySDK", str(ARCHIVE)])
    worktree = git_value(root, ["status", "--porcelain=v1", "--untracked-files=all", "--", *protected])
    if mutation.get("history", history):
        errors.append("scope.history")
    if mutation.get("worktree", worktree):
        errors.append("scope.worktree")
    return sorted(set(errors))


def renderer_hash(values: list[str]) -> str:
    return sha256(json.dumps(values, separators=(",", ":")).encode())


def public_absence_errors(root: Path, overrides: dict[Path, str] | None = None) -> list[str]:
    overrides = overrides or {}
    parameters = overrides.get(PARAMETERS, read_text(root, PARAMETERS))
    renderer = overrides.get(RENDERER, read_text(root, RENDERER))
    manifest_text = overrides.get(MANIFEST, read_text(root, MANIFEST))
    package = overrides.get(PACKAGE, read_text(root, PACKAGE))
    errors: list[str] = []
    fields = re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9_]*):",
                        parameters.split("enum CodingKeys", 1)[0], re.M)
    if fields != EXPECTED_FIELDS:
        errors.append("absence.parameters.fields")
    match = re.search(r"enum CodingKeys: String, CodingKey \{(?P<body>[\s\S]*?)\n\s*\}", parameters)
    coding = re.findall(r"^\s*case ([A-Za-z][A-Za-z0-9_]*)\s*$", match.group("body"), re.M) if match else []
    if coding != EXPECTED_FIELDS:
        errors.append("absence.parameters.coding-keys")
    try:
        manifest = parse_json(manifest_text)
    except GateError:
        manifest = None
    ids = [x.get("id") for x in manifest.get("presets", []) if isinstance(x, dict)] if isinstance(manifest, dict) and manifest.get("schemaVersion") == 1 else []
    if ids != PRESETS:
        errors.append("absence.presets")
    renderer_ids = re.findall(r'^\s*id: "([^"]+)"', renderer, re.M)
    if len(renderer_ids) != 74 or len(set(renderer_ids)) != 74 or renderer_hash(renderer_ids) != RENDERER_HASH:
        errors.append("absence.renderer.cases")
    facade_text: list[str] = []
    facade_root = root / FACADE
    if facade_root.is_symlink() or not facade_root.is_dir():
        errors.append("absence.facade")
    else:
        for source in sorted(facade_root.rglob("*.swift")):
            relative = source.relative_to(root)
            facade_text.append(overrides.get(relative, read_text(root, relative)))
    exposed = "\n".join([parameters, renderer, manifest_text, package, *facade_text]).lower()
    if any(identity in exposed for identity in FORBIDDEN):
        errors.append("absence.public-or-spi-route")
    return sorted(set(errors))


def extract_record(text: str, begin: str, end: str) -> dict[str, Any]:
    ticks = chr(96) * 3
    prefix = f"<!-- {begin} -->\n{ticks}json\n"
    suffix = f"\n{ticks}\n<!-- {end} -->"
    start = text.find(prefix)
    finish = text.find(suffix, start + len(prefix))
    if start < 0 or finish < 0:
        fail("qualification.binding")
    record = parse_json(text[start + len(prefix):finish], "qualification.binding")
    if not isinstance(record, dict):
        fail("qualification.binding")
    return record


def at(record: dict[str, Any], *path: str) -> Any:
    value: Any = record
    for part in path:
        if not isinstance(value, dict) or part not in value:
            return None
        value = value[part]
    return value


def contract_errors(record: dict[str, Any], enforce_hash: bool = True) -> list[str]:
    checks = [
        (("version",), 1), (("feature_id",), "upper-eyelid-fullness-reduction"),
        (("evaluator_version",), VERSION),
        (("phase75_bindings", "semantic_contract_hash"), SEMANTIC_HASH),
        (("phase75_bindings", "evidence_contract_hash"), PHASE75_EVIDENCE_HASH),
        (("phase75_bindings", "review_rubric_hash"), RUBRIC_HASH),
        (("baseline_binding", "baseline_id"), "deterministic-editor"),
        (("baseline_binding", "baseline_source_digest"), SOURCE_DIGEST),
        (("baseline_binding", "baseline_evidence_digest"), EVIDENCE_DIGEST),
        (("baseline_binding", "focused_suite_count"), 3),
        (("baseline_binding", "focused_test_count"), 10),
        (("baseline_binding", "focused_test_status"), "pass"),
        (("bundle_schema", "admission_mode"), "genuine-private"),
        (("bundle_schema", "origin"), "genuine-captured"),
        (("bundle_schema", "required_categories"), CATEGORIES),
        (("bundle_schema", "rights_status"), "approved_internal_evaluation"),
        (("bundle_schema", "rights_record_present"), True),
        (("bundle_schema", "minimum_fixture_count"), 2),
        (("bundle_schema", "generated_fixture_weight"), 0),
        (("bundle_schema", "mechanics_only_fixture_weight"), 0),
        (("bundle_schema", "generated_origins_rejected"), ["generated", "ai-generated", "mechanics-only"]),
        (("metric_matrix", "minimum_formula"), "value+tolerance>=threshold"),
        (("metric_matrix", "maximum_formula"), "value<=threshold+tolerance"),
        (("metric_matrix", "exact_formula"), "value===threshold"),
        (("metric_matrix", "finite_numbers_required"), True),
        (("metric_matrix", "every_declared_fixture_category_row_required"), True),
        (("metric_matrix", "every_row_evaluated_independently"), True),
        (("metric_matrix", "aggregate_only_after_all_rows_pass_schema"), True),
        (("metric_matrix", "color_aggregation"), "maximum-after-complete-independent-row-evaluation"),
        (("review_rubric", "mode"), "blinded-original-detail"),
        (("review_rubric", "freeform_text"), False),
        (("review_schema", "complete"), True),
        (("review_schema", "rubric_frozen_before_outcomes"), True),
        (("review_schema", "blindness_attested"), True),
        (("review_schema", "candidate_identity_hidden"), True),
        (("review_schema", "locator_hidden"), True),
        (("review_schema", "detail_scale_percent"), 100),
        (("review_schema", "category_acceptance_threshold"), 1),
        (("review_schema", "category_acceptance_direction"), "minimum"),
        (("review_schema", "category_acceptance_tolerance"), 0),
        (("review_schema", "equality_passes"), True),
        (("canonical_encoding", "input_encoding"), "utf-8-without-bom"),
        (("canonical_encoding", "non_finite_numbers_rejected"), True),
        (("canonical_encoding", "duplicate_json_keys_rejected"), True),
        (("canonical_encoding", "equal_sort_key_result"), "reject-as-duplicate"),
        (("decision_schema", "status_values"), ["pass", "fail"]),
        (("decision_schema", "decision_values"), [PROMOTION, NON_PROMOTION]),
        (("decision_schema", "invalid_input_must_not_replace_decision"), True),
        (("decision_schema", "durable_allowlist_only"), True),
        (("external_fact_boundary", "tool_validates_but_never_creates_external_facts"), True),
        (("external_fact_boundary", "automated_promotion_override_forbidden"), True),
    ]
    errors = ["contract.binding" for path, expected in checks if at(record, *path) != expected]
    if set(at(record, "normalized_reasons") or []) != REASONS:
        errors.append("contract.reasons")
    color = at(record, "metric_matrix", "color_contract")
    required_color = {
        "metric_id": "color-preservation-max-absolute-srgb8-channel-delta",
        "normalization": "opaque-named-srgb-rgba8",
        "channels": "rgb-only-alpha-has-separate-exact-field",
        "source_comparison": "original-vs-candidate-output",
        "target_region": "source-bound-support-envelope-owned-pixels",
        "protected_region": "immutable-source-owned-exterior-rejected-protected-structure-and-collision-pixels",
        "applicable_regions_must_be_nonempty": True, "sample_unit": "integer-srgb8-code-value",
        "direction": "maximum", "target_field": "color_target_max_abs_channel_delta_srgb8",
        "target_threshold": 16, "target_threshold_owner": "BeautyUpperEyelidFullnessEditor.maximumAbsoluteChannelDelta",
        "target_tolerance": 0, "protected_field": "color_protected_max_abs_channel_delta_srgb8",
        "protected_threshold": 0, "protected_threshold_owner": "immutable-original-composition",
        "protected_tolerance": 0, "equality_passes": True,
        "invalid_reason": "qualification.color.invalid",
        "target_bound_reason": "qualification.color.target-bound",
        "protected_bound_reason": "qualification.color.protected-bound",
    }
    if color != required_color:
        errors.append("contract.color")
    row_keys = at(record, "metric_matrix", "row_keys")
    aggregate = at(record, "metric_matrix", "aggregate_fields")
    for name in ("color_target_region_nonempty", "color_protected_region_nonempty",
                 "color_target_max_abs_channel_delta_srgb8", "color_protected_max_abs_channel_delta_srgb8"):
        if not isinstance(row_keys, list) or name not in row_keys:
            errors.append("contract.color-row")
    for name in ("color_row_count", "color_target_max_abs_channel_delta_srgb8",
                 "color_protected_max_abs_channel_delta_srgb8"):
        if not isinstance(aggregate, list) or name not in aggregate:
            errors.append("contract.color-aggregate")
    if enforce_hash and canonical_hash(record) != CONTRACT_HASH:
        errors.append("contract.hash")
    return sorted(set(errors))


EVALUATOR_GUARDS = [
    'bundle.admission_mode !== "genuine-private"',
    'bundle.origin !== "genuine-captured"',
    'fixture.rights_status !== "approved_internal_evaluation"',
    'fixture.rights_record_present !== true',
    "entry.isSymbolicLink()", "descriptorStable(before, after)",
    "observedHash !== record.sha256",
    'if (direction === "minimum") return value + tolerance >= threshold;',
    'if (direction === "maximum") return value <= threshold + tolerance;',
    'if (direction === "exact") return value === threshold;',
    "Number.isInteger(target)", "Number.isInteger(protectedValue)",
    "if (target > 16)", "if (protectedValue > 0)",
    "Math.max(...targetValues)", "Math.max(...protectedValues)",
    "review.detail_scale_percent !== 100",
    'compareMetric(result.category_pass_rates[category], "minimum", 1, 0)',
    "generated_evidence_weight: 0", "if (!outputIsSafe(report))",
    "passed ? PROMOTION_DECISION : NON_PROMOTION_DECISION",
    "return decision.inputComplete ? 0 : 1;",
    "environment.BEAUTY_PHASE80_BUNDLE_MANIFEST",
    "environment.BEAUTY_PHASE80_REVIEW_RECORD", "SENSITIVE_KEY_RE.test(key)",
]


def evaluator_errors(source: str, enforce_hash: bool = True) -> list[str]:
    errors = ["evaluator.guard" for guard in EVALUATOR_GUARDS if guard not in source]
    if enforce_hash and sha256(source.encode()) != EVALUATOR_HASH:
        errors.append("evaluator.hash")
    return sorted(set(errors))


def load_contract(root: Path) -> dict[str, Any]:
    raw = read_bytes(root, CONTRACT)
    if sha256(raw) != CONTRACT_FILE_HASH:
        fail("qualification.binding")
    record = extract_record(raw.decode(), "CANONICAL_QUALIFICATION_RECORDS_BEGIN",
                            "CANONICAL_QUALIFICATION_RECORDS_END")
    if contract_errors(record):
        fail("qualification.binding")
    return record


def verify_evaluator(root: Path) -> str:
    source = read_text(root, EVALUATOR)
    if sha256(read_bytes(root, EVALUATOR_TEST)) != EVALUATOR_TEST_HASH or evaluator_errors(source):
        fail("qualification.binding")
    return source


def owner_digest(root: Path, owners: tuple[Path, ...]) -> str:
    if tuple(sorted(owners, key=lambda item: item.as_posix())) != owners:
        fail("qualification.binding")
    digest = hashlib.sha256()
    for owner in owners:
        contents = read_bytes(root, owner)
        name = owner.as_posix().encode()
        digest.update(len(name).to_bytes(4, "big"))
        digest.update(name)
        digest.update(len(contents).to_bytes(8, "big"))
        digest.update(contents)
    return digest.hexdigest()


def node_normalized(value: Any) -> Any:
    if isinstance(value, float) and math.isfinite(value) and value.is_integer():
        return int(value)
    if isinstance(value, list):
        return [node_normalized(entry) for entry in value]
    if isinstance(value, dict):
        return {key: node_normalized(entry) for key, entry in value.items()}
    return value


def archive_hash(root: Path, relative: Path, begin: str, end: str) -> str:
    record = node_normalized(extract_record(read_text(root, relative), begin, end))
    return sha256(json.dumps(record, ensure_ascii=False, separators=(",", ":")).encode())


def baseline_attestation(root: Path) -> None:
    raw, returncode = run_child(["python3", str(V118_CHECKER), "--live", "--repo-root", "."], root)
    if returncode:
        fail("qualification.binding")
    report = parse_json(raw, "qualification.binding")
    expected = {
        "baseline_source_digest": SOURCE_DIGEST, "baseline_evidence_digest": EVIDENCE_DIGEST,
        "baseline_id": "deterministic-editor", "focused_suite_count": 3,
        "focused_test_count": 10, "focused_test_status": "pass",
        "fields": 61, "presets": 5, "renderer_cases": 74, "status": "pass",
    }
    if not isinstance(report, dict) or not privacy_safe(report):
        fail("qualification.binding")
    if any(report.get(key) != value for key, value in expected.items()):
        fail("qualification.binding")


def verify_authorities(root: Path) -> dict[str, Any]:
    contract = load_contract(root)
    verify_evaluator(root)
    scope = phase_scope_errors(root)
    public = public_absence_errors(root)
    if scope:
        fail(scope[0])
    if public:
        fail(public[0])
    source = owner_digest(root, SOURCE_OWNERS)
    evidence = owner_digest(root, EVIDENCE_OWNERS)
    if source != SOURCE_DIGEST or evidence != EVIDENCE_DIGEST:
        fail("qualification.binding")
    semantic = archive_hash(root, ARCHIVE / "75-semantics-and-genuine-evidence-contract/75-SEMANTICS-CONTRACT.md",
                            "CANONICAL_RECORDS_BEGIN", "CANONICAL_RECORDS_END")
    evidence_contract = archive_hash(root, ARCHIVE / "75-semantics-and-genuine-evidence-contract/75-EVIDENCE-CONTRACT.md",
                                     "CANONICAL_EVIDENCE_RECORDS_BEGIN", "CANONICAL_EVIDENCE_RECORDS_END")
    if semantic != SEMANTIC_HASH or evidence_contract != PHASE75_EVIDENCE_HASH:
        fail("qualification.binding")
    baseline_attestation(root)
    return {"contract": contract, "source": source, "evidence": evidence}


def metric_passes(value: Any, direction: str, threshold: float, tolerance: float) -> bool:
    if type(value) not in {int, float} or not math.isfinite(value):
        return False
    if direction == "minimum":
        return value + tolerance >= threshold
    if direction == "maximum":
        return value <= threshold + tolerance
    return direction == "exact" and value == threshold


def color_reasons(target: Any, protected: Any, target_nonempty: bool = True,
                  protected_nonempty: bool = True) -> list[str]:
    if target_nonempty is not True or protected_nonempty is not True or type(target) is not int or type(protected) is not int or target < 0 or target > 255 or protected < 0 or protected > 255:
        return ["qualification.color.invalid"]
    reasons: list[str] = []
    if target > 16:
        reasons.append("qualification.color.target-bound")
    if protected > 0:
        reasons.append("qualification.color.protected-bound")
    return reasons


def empty_report(report: dict[str, Any]) -> bool:
    aggregate = {
        "fixture_count": 0, "metric_row_count": 0, "passing_metric_row_count": 0,
        "color_row_count": 0, "color_target_max_abs_channel_delta_srgb8": None,
        "color_protected_max_abs_channel_delta_srgb8": None, "review_row_count": 0,
        "passing_review_row_count": 0, "category_pass_rates": {x: 0 for x in CATEGORIES},
        "generated_evidence_weight": 0, "genuine_evaluation_executed": False,
        "frozen_review_complete": False, "safety_gates_pass": False,
    }
    return report["status"] == "fail" and report["decision"] == NON_PROMOTION and report["manifest_hash"] is None and report["review_hash"] is None and report["fixture_ids"] == [] and report["aggregate_metrics"] == aggregate and report["reason_counts"] == {"evidence.missing-bundle": 1, "review.missing": 1}


def parse_qualification_decision(raw: str, contract: dict[str, Any]) -> dict[str, Any]:
    if not raw or len(raw.encode()) > 65536:
        fail("qualification.input")
    report = parse_json(raw)
    if not isinstance(report, dict) or set(report) != DECISION_KEYS or raw != canonical_json(report):
        fail("qualification.input")
    if not privacy_safe(report):
        fail("qualification.privacy")
    bindings = {
        "contract_hash": CONTRACT_HASH, "evaluator_version": VERSION,
        "phase75_semantic_contract_hash": SEMANTIC_HASH,
        "phase75_evidence_contract_hash": PHASE75_EVIDENCE_HASH,
        "phase75_review_rubric_hash": RUBRIC_HASH, "baseline_id": "deterministic-editor",
        "baseline_source_digest": SOURCE_DIGEST, "baseline_evidence_digest": EVIDENCE_DIGEST,
        "baseline_binding_hash": BINDING_HASH,
    }
    if report.get("phase") != PHASE or report.get("status") not in {"pass", "fail"} or any(report.get(k) != v for k, v in bindings.items()) or canonical_hash(contract) != CONTRACT_HASH:
        fail("qualification.binding")
    for key in ("manifest_hash", "review_hash"):
        if report[key] is not None and (not isinstance(report[key], str) or not HASH_RE.fullmatch(report[key])):
            fail("qualification.input")
    ids = report["fixture_ids"]
    if not isinstance(ids, list) or ids != sorted(set(ids), key=lambda x: x.encode()) or any(not isinstance(x, str) or not OPAQUE_RE.fullmatch(x) for x in ids):
        fail("qualification.input")
    metrics = report["aggregate_metrics"]
    if not isinstance(metrics, dict) or set(metrics) != AGGREGATE_KEYS:
        fail("qualification.input")
    integer_keys = ["fixture_count", "metric_row_count", "passing_metric_row_count", "color_row_count", "review_row_count", "passing_review_row_count"]
    if any(type(metrics[k]) is not int or metrics[k] < 0 for k in integer_keys) or metrics["fixture_count"] != len(ids) or metrics["generated_evidence_weight"] != 0:
        fail("qualification.binding")
    if any(type(metrics[k]) is not bool for k in ("genuine_evaluation_executed", "frozen_review_complete", "safety_gates_pass")):
        fail("qualification.input")
    rates = metrics["category_pass_rates"]
    if not isinstance(rates, dict) or set(rates) != set(CATEGORIES) or any(type(v) not in {int, float} or not math.isfinite(v) or v < 0 or v > 1 for v in rates.values()):
        fail("qualification.input")
    reason_counts = report["reason_counts"]
    if not isinstance(reason_counts, dict) or any(k not in REASONS or type(v) is not int or v < 1 for k, v in reason_counts.items()):
        fail("qualification.input")
    if report["public_absence"] != PUBLIC:
        fail("qualification.public-absence")
    if report["decision"] not in {PROMOTION, NON_PROMOTION}:
        fail("qualification.binding")
    complete = metrics["genuine_evaluation_executed"] and metrics["frozen_review_complete"]
    if not complete:
        if not empty_report(report):
            fail("qualification.input")
        return report
    target = metrics["color_target_max_abs_channel_delta_srgb8"]
    protected = metrics["color_protected_max_abs_channel_delta_srgb8"]
    if len(ids) < 2 or report["manifest_hash"] is None or report["review_hash"] is None or color_reasons(target, protected) == ["qualification.color.invalid"] or metrics["color_row_count"] != metrics["metric_row_count"] or metrics["color_row_count"] <= 0:
        fail("qualification.input")
    if report["status"] == "pass":
        if report["decision"] != PROMOTION or reason_counts or not metrics["safety_gates_pass"] or metrics["passing_metric_row_count"] != metrics["metric_row_count"] or metrics["passing_review_row_count"] != metrics["review_row_count"] or any(v != 1 for v in rates.values()) or color_reasons(target, protected):
            fail("qualification.binding")
    elif report["decision"] != NON_PROMOTION or metrics["safety_gates_pass"] or not reason_counts or any(k not in COMPLETE_FAILURES for k in reason_counts) or any(k not in reason_counts for k in color_reasons(target, protected)):
        fail("qualification.binding")
    return report


def evaluator_decision(root: Path, inherit_private: bool) -> tuple[str, int]:
    environment = os.environ.copy()
    if not inherit_private:
        environment.pop("BEAUTY_PHASE80_BUNDLE_MANIFEST", None)
        environment.pop("BEAUTY_PHASE80_REVIEW_RECORD", None)
    return run_child(["node", str(EVALUATOR), "--decision", "--repo-root", "."], root,
                     environment, timeout=60)


def expect_rejected(action: Callable[[], Any]) -> bool:
    try:
        action()
    except GateError:
        return True
    return False


def filesystem_self_test() -> int:
    with tempfile.TemporaryDirectory(prefix="phase80-boundary-") as directory:
        root = Path(directory)
        (root / "record").write_text("bounded", encoding="utf-8")
        if read_text(root, Path("record")) != "bounded":
            fail("qualification.self-test")
        (root / "link").symlink_to(root / "record")
        (root / "target").mkdir()
        (root / "target/nested").write_text("bounded", encoding="utf-8")
        (root / "parent").symlink_to(root / "target", target_is_directory=True)
        rejected = [
            expect_rejected(lambda: resolve_regular(root, Path("link"))),
            expect_rejected(lambda: resolve_regular(root, Path("../record"))),
            expect_rejected(lambda: resolve_regular(root, Path("parent/nested"))),
        ]
        if not all(rejected):
            fail("qualification.self-test")
    return 4


def mutation_self_test(root: Path, contract: dict[str, Any], report: dict[str, Any],
                       source: str) -> int:
    checks: list[bool] = []
    # Contract mutations cover admission, assets, categories, metrics, review,
    # canonical bindings, every color field, and durable schema.
    paths = [
        ("bundle_schema", "admission_mode"), ("bundle_schema", "origin"),
        ("bundle_schema", "required_categories"), ("bundle_schema", "rights_status"),
        ("bundle_schema", "generated_fixture_weight"), ("bundle_schema", "asset_inventory"),
        ("bundle_schema", "independence"), ("bundle_schema", "bindings_keys"),
        ("metric_matrix", "row_keys"), ("metric_matrix", "comparisons"),
        ("metric_matrix", "minimum_formula"), ("metric_matrix", "maximum_formula"),
        ("metric_matrix", "exact_formula"), ("metric_matrix", "color_contract"),
        ("metric_matrix", "aggregate_fields"), ("review_rubric", "fixed_fields"),
        ("review_rubric", "positive_pass_predicate"),
        ("review_rubric", "negative_and_stress_pass_predicate"),
        ("review_schema", "top_level_keys"), ("review_schema", "judgment_keys"),
        ("review_schema", "category_acceptance_threshold"),
        ("canonical_encoding", "array_order"), ("normalized_reasons",),
        ("decision_schema", "top_level_allowlist"), ("decision_schema", "decision_values"),
        ("external_fact_boundary", "automated_promotion_override_forbidden"),
    ]
    for path in paths:
        candidate = copy.deepcopy(contract)
        cursor: Any = candidate
        for part in path[:-1]:
            cursor = cursor[part]
        value = cursor[path[-1]]
        cursor[path[-1]] = (not value if isinstance(value, bool) else value + 1 if isinstance(value, (int, float)) else value[:-1] if isinstance(value, list) else {**value, "unknown": True} if isinstance(value, dict) else str(value) + "-mutated")
        checks.append(bool(contract_errors(candidate)))
    color = at(contract, "metric_matrix", "color_contract")
    for key, value in color.items():
        candidate = copy.deepcopy(contract)
        candidate["metric_matrix"]["color_contract"][key] = not value if isinstance(value, bool) else value + 1 if isinstance(value, int) else str(value) + "-mutated"
        checks.append(bool(contract_errors(candidate)))
    # Source guards are semantic, independently of the whole-file digest.
    for guard in EVALUATOR_GUARDS:
        checks.append(bool(evaluator_errors(source.replace(guard, "removed"), enforce_hash=False)))
    # Exact durable output: every top-level/aggregate field is mandatory.
    for key in DECISION_KEYS:
        candidate = copy.deepcopy(report)
        del candidate[key]
        checks.append(expect_rejected(lambda value=candidate: parse_qualification_decision(canonical_json(value), contract)))
    for key in AGGREGATE_KEYS:
        candidate = copy.deepcopy(report)
        del candidate["aggregate_metrics"][key]
        checks.append(expect_rejected(lambda value=candidate: parse_qualification_decision(canonical_json(value), contract)))
    for key, value in [
        ("status", "pass"), ("decision", PROMOTION), ("phase", 81),
        ("contract_hash", "0" * 64), ("baseline_source_digest", "0" * 64),
        ("baseline_evidence_digest", "0" * 64), ("baseline_binding_hash", "0" * 64),
        ("phase75_semantic_contract_hash", "0" * 64),
        ("phase75_evidence_contract_hash", "0" * 64),
        ("phase75_review_rubric_hash", "0" * 64), ("evaluator_version", "mutated"),
    ]:
        candidate = copy.deepcopy(report)
        candidate[key] = value
        checks.append(expect_rejected(lambda item=candidate: parse_qualification_decision(canonical_json(item), contract)))
    for key in PUBLIC:
        candidate = copy.deepcopy(report)
        candidate["public_absence"][key] += 1
        checks.append(expect_rejected(lambda item=candidate: parse_qualification_decision(canonical_json(item), contract)))
    for key, value in [
        ("generated_evidence_weight", 1), ("color_row_count", 1),
        ("color_target_max_abs_channel_delta_srgb8", 16),
        ("color_protected_max_abs_channel_delta_srgb8", 0),
        ("genuine_evaluation_executed", True), ("frozen_review_complete", True),
        ("safety_gates_pass", True),
    ]:
        candidate = copy.deepcopy(report)
        candidate["aggregate_metrics"][key] = value
        checks.append(expect_rejected(lambda item=candidate: parse_qualification_decision(canonical_json(item), contract)))
    unknown = copy.deepcopy(report)
    unknown["reason_counts"] = {"qualification.unknown": 1}
    checks.append(expect_rejected(lambda: parse_qualification_decision(canonical_json(unknown), contract)))
    private_key = copy.deepcopy(report)
    private_key["private_locator"] = "forbidden"
    checks.append(expect_rejected(lambda: parse_qualification_decision(canonical_json(private_key), contract)))
    private_value = copy.deepcopy(report)
    private_value["decision"] = "private/output"
    checks.append(expect_rejected(lambda: parse_qualification_decision(canonical_json(private_value), contract)))
    checks.append(expect_rejected(lambda: parse_qualification_decision("{\n" + canonical_json(report)[1:], contract)))
    parameters = read_text(root, PARAMETERS)
    renderer = read_text(root, RENDERER)
    manifest = parse_json(read_text(root, MANIFEST))
    package = read_text(root, PACKAGE)
    public_mutations = [
        {PARAMETERS: parameters.replace("enum CodingKeys", "public var injected: Float\n    enum CodingKeys", 1)},
        {PARAMETERS: parameters.replace("        case skinSmoothing\n", "", 1)},
        {RENDERER: renderer.replace('id: "', 'id: "mutated-', 1)},
        {MANIFEST: canonical_json({**manifest, "presets": manifest["presets"][:-1]})},
        {PACKAGE: package + "\n// upperEyelidFullness\n"},
    ]
    checks.extend(bool(public_absence_errors(root, item)) for item in public_mutations)
    for key in ("sdk", "archive", "context", "patterns", "history", "worktree"):
        checks.append(bool(phase_scope_errors(root, {key: "mutated"})))
    if not all(checks):
        fail("qualification.self-test")
    return len(checks)


def self_test(root: Path) -> dict[str, Any]:
    authority = verify_authorities(root)
    source = verify_evaluator(root)
    raw, returncode = evaluator_decision(root, False)
    if returncode == 0:
        fail("qualification.self-test")
    report = parse_qualification_decision(raw, authority["contract"])
    scalars = [
        metric_passes(.08, "minimum", .1, .02),
        not metric_passes(.079, "minimum", .1, .02),
        metric_passes(.02, "maximum", .01, .01),
        not metric_passes(.021, "maximum", .01, .01),
        metric_passes(1, "exact", 1, 0), not metric_passes(.999, "exact", 1, 0),
        color_reasons(16, 0) == [], color_reasons(17, 0) == ["qualification.color.target-bound"],
        color_reasons(16, 1) == ["qualification.color.protected-bound"],
        color_reasons(16.0, 0) == ["qualification.color.invalid"],
        color_reasons(math.nan, 0) == ["qualification.color.invalid"],
        color_reasons(16, 0, False, True) == ["qualification.color.invalid"],
    ]
    if not empty_report(report) or not all(scalars):
        fail("qualification.self-test")
    filesystem_checks = filesystem_self_test()
    mutations = mutation_self_test(root, authority["contract"], report, source)
    result = {
        "baseline_evidence_digest": authority["evidence"],
        "baseline_source_digest": authority["source"],
        "checks": len(scalars) + filesystem_checks + mutations,
        "contract_hash": CONTRACT_HASH, "decision": NON_PROMOTION,
        "fields": 61, "focused_test_count": 10, "mode": "self-test",
        "mutation_rejections": mutations, "phase": PHASE, "presets": 5,
        "promotion_fixture_count": 0, "renderer_cases": 74, "status": "pass",
    }
    if not privacy_safe(result):
        fail("qualification.privacy")
    return result


def preflight_result(root: Path) -> dict[str, Any]:
    if os.environ.get("BEAUTY_PHASE80_BUNDLE_MANIFEST") or os.environ.get("BEAUTY_PHASE80_REVIEW_RECORD"):
        fail("qualification.input")
    authority = verify_authorities(root)
    raw, returncode = evaluator_decision(root, False)
    report = parse_qualification_decision(raw, authority["contract"])
    if returncode == 0 or not empty_report(report):
        fail("qualification.binding")
    result = {
        "baseline_evidence_digest": authority["evidence"],
        "baseline_source_digest": authority["source"], "contract_hash": CONTRACT_HASH,
        "decision": NON_PROMOTION, "fields": 61, "focused_test_count": 10,
        "mode": "preflight", "phase": PHASE, "phase81_eligible": False,
        "presets": 5, "qualification_blocked": True,
        "reasons": ["evidence.missing-bundle", "review.missing"],
        "renderer_cases": 74, "status": "pass",
    }
    if not privacy_safe(result):
        fail("qualification.privacy")
    return result


def live_result(root: Path) -> dict[str, Any]:
    authority = verify_authorities(root)
    raw, returncode = evaluator_decision(root, True)
    if returncode:
        fail("qualification.input")
    report = parse_qualification_decision(raw, authority["contract"])
    metrics = report["aggregate_metrics"]
    if not metrics["genuine_evaluation_executed"] or not metrics["frozen_review_complete"]:
        fail("qualification.input")
    eligible = report["status"] == "pass" and report["decision"] == PROMOTION
    result = {
        "baseline_evidence_digest": authority["evidence"],
        "baseline_source_digest": authority["source"],
        "color_protected_max_abs_channel_delta_srgb8": metrics["color_protected_max_abs_channel_delta_srgb8"],
        "color_row_count": metrics["color_row_count"],
        "color_target_max_abs_channel_delta_srgb8": metrics["color_target_max_abs_channel_delta_srgb8"],
        "contract_hash": CONTRACT_HASH, "decision": report["decision"],
        "fields": 61, "fixture_count": metrics["fixture_count"],
        "focused_test_count": 10, "mode": "live", "phase": PHASE,
        "phase81_eligible": eligible, "presets": 5, "renderer_cases": 74, "status": "pass",
    }
    if not privacy_safe(result):
        fail("qualification.privacy")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--preflight", action="store_true")
    modes.add_argument("--live", action="store_true")
    parser.add_argument("--repo-root", required=True)
    args = parser.parse_args()
    mode = "self-test" if args.self_test else "preflight" if args.preflight else "live"
    try:
        supplied = Path(args.repo_root)
        if supplied.is_symlink() or not supplied.is_dir():
            fail("qualification.input")
        root = supplied.resolve(strict=True)
        result = self_test(root) if args.self_test else preflight_result(root) if args.preflight else live_result(root)
    except GateError as error:
        reason = str(error) if REASON_RE.fullmatch(str(error)) else "qualification.input"
        print(canonical_json({"mode": mode, "phase": PHASE, "reason_count": 1, "reasons": [reason], "status": "fail"}))
        return 1
    except Exception:
        print(canonical_json({"mode": mode, "phase": PHASE, "reason_count": 1, "reasons": ["qualification.input"], "status": "fail"}))
        return 1
    print(canonical_json(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
