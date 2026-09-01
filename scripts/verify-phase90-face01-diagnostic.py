#!/usr/bin/env python3
"""Static, read-only verifier for the FACE-01 revision-19 diagnostic boundary."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
import re
import sys


PRESENT_FILES = (
    "BeautySDK/Sources/BeautyEffects/Warp/FaceShapeWarpProvider.swift",
    "BeautySDK/Tests/BeautyEffectsTests/FaceContourSmoothRepairTests.swift",
    "BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift",
    "BeautySDK/Tests/BeautyEffectsTests/CombinedEffectSafetyTests.swift",
    "BeautySDK/Tests/BeautyEffectsTests/BeautyMetalGeometryPassTests.swift",
    "scripts/verify-phase90-face01-diagnostic.py",
    "scripts/verify-phase90-face01-stop.py",
    ".planning/phases/90-face-contour-and-chin-repairs/90-01-PLAN.md",
    ".planning/phases/90-face-contour-and-chin-repairs/90-02-PLAN.md",
    ".planning/phases/90-face-contour-and-chin-repairs/90-03-PLAN.md",
    ".planning/phases/90-face-contour-and-chin-repairs/90-04-PLAN.md",
    ".planning/phases/90-face-contour-and-chin-repairs/90-02-SUMMARY.md",
    ".planning/phases/90-face-contour-and-chin-repairs/90-VALIDATION.md",
    "PLANS.md",
    ".planning/STATE.md",
    ".planning/ROADMAP.md",
    "DESIGN.md",
    "PRODUCT_SENSE.md",
    "docs/SDK_EFFECT_TAXONOMY.md",
    "SECURITY.md",
    "RELIABILITY.md",
    "QUALITY_SCORE.md",
)

ABSENT_PATHS = (
    "BeautySDK/Tests/BeautyCoreTests/BeautyEngineFaceContourSmoothRepairTests.swift",
    ".planning/phases/90-face-contour-and-chin-repairs/90-01-SUMMARY.md",
    ".planning/phases/90-face-contour-and-chin-repairs/90-03-SUMMARY.md",
    ".planning/phases/90-face-contour-and-chin-repairs/90-04-SUMMARY.md",
)

PROVIDER_PATH = PRESENT_FILES[0]
TEST_PATH = PRESENT_FILES[1]
VERIFIER_PATH = PRESENT_FILES[5]
ATTEMPT_PATH = ".planning/phases/90-face-contour-and-chin-repairs/90-01-ATTEMPT.md"

PROVIDER_TEMPORARY_SYMBOLS = (
    "D1V19Gate",
    "D1V19FixedPointMargin",
    "D1V19Aggregate",
    "D1V19Template",
    "D1V19ConstructionResult",
    "d1V19DiagnosticConstruction",
    "d1V18Template",
    "finalizedD1V18Points",
    "d1FieldPassesSafety",
)

TEST_TEMPORARY_SYMBOLS = (
    "D1V19Outcome",
    "D1V19ReferenceCounts",
    "referenceFinalizeD1V18Template",
    "classifyD1V19",
    "testFACE01D1V19DiagnosticOnlyClassification",
)

GATE_PAIRS = (
    ("requestAdmission", "request_admission"),
    ("canonicalBranches", "canonical_branches"),
    ("slotsExtremaZones", "slots_extrema_zones"),
    ("residualsAndZeroOmission", "residuals_and_zero_omission"),
    ("rawExactLattice", "raw_exact_lattice"),
    ("sourceClearanceClip", "source_clearance_clip"),
    ("exactLinkageAndHalfAdmission", "exact_linkage_and_half_admission"),
    ("targetClearanceAndRadius", "target_clearance_and_radius"),
    ("ownerUnitSlackExpanded", "owner_unit_slack_expanded"),
    ("overlapTopology", "overlap_topology"),
    ("singleSafety", "single_safety"),
    ("adjacentLipschitzInverse", "adjacent_lipschitz_inverse"),
    ("branchChainProxy", "branch_chain_proxy"),
    ("strengthFinalization", "strength_finalization"),
    ("pointBudget", "point_budget"),
    ("none", "none"),
)
GATES = tuple(value for _, value in GATE_PAIRS)

SUFFIX_FIELDS = (
    "diagnostic_contract",
    "classification",
    "first_failure",
    "construction_invocation_count",
    "canonical_branch_counts",
    "analytical_slot_counts",
    "retained_branch_counts",
    "clipped_branch_counts",
    "cap_template_count",
    "provider_cap_admitted_count",
    "provider_half_admitted_count",
    "reference_cap_admitted_count",
    "reference_half_admitted_count",
    "final_point_count",
    "first_failure_margin",
    "render_invocation_count",
    "oracle_invocation_count",
    "rollback_status",
    "static_verifier_status",
)

CLASSIFICATIONS = {
    "implementation_defect",
    "genuine_construction_miss",
    "prior_stop_not_reproduced",
    "diagnostic_invalid",
}

MARGIN_SCALES = {
    "source_clearance_clip": ("q24", 16_777_216),
    "exact_linkage_and_half_admission": ("q24", 16_777_216),
    "target_clearance_and_radius": ("q24", 16_777_216),
    "owner_unit_slack_expanded": ("q24", 16_777_216),
    "overlap_topology": ("q24", 16_777_216),
    "strength_finalization": ("q24", 16_777_216),
    "single_safety": ("q16", 65_536),
    "adjacent_lipschitz_inverse": ("q16", 65_536),
    "branch_chain_proxy": ("q40", 1_099_511_627_776),
}

BANNED_DIAGNOSTIC_TOKENS = (
    "render(",
    "applyMVPProxy",
    "semanticSnapshot",
    "CIContext",
    "CIImage",
    "testFACE01GeneratedCPUFixturePassesFrozenSemanticAndProtectionContract",
    "fieldEmissions(",
    "FileManager",
    "ProcessInfo",
    "URLSession",
    "NSLog",
    "public ",
)

AUTHORIZED_MARKER_EMISSION = 'Swift.print("FACE01_D19_DIAGNOSTIC \\(marker)")'

RAW_EVIDENCE_WORDS = (
    "coordinate",
    "geometry",
    "pixel",
    "landmark",
    "transcript",
    "fixture_locator",
    "absolute_path",
    "environment",
    "source_value",
    "target_value",
    "radius_value",
    "owner_value",
    "slot_index",
    "extremum_index",
)

CONTRACT = "documented-d1-v18-reconstruction-not-byte-identical"
ROLLBACK_STATUS = "provider_and_complete_test_byte_exact;temporary_swift_symbols_absent"


class DiagnosticError(Exception):
    def __init__(self, category: str):
        super().__init__(category)
        self.category = category


def reject(category: str) -> "NoReturn":
    raise DiagnosticError(category)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def valid_relative_path(value: str) -> bool:
    if not value or value.startswith("./") or "\\" in value or "//" in value:
        return False
    path = Path(value)
    return not path.is_absolute() and "." not in path.parts and ".." not in path.parts


def read_regular(root: Path, relative: str) -> bytes:
    if not valid_relative_path(relative):
        reject("diagnostic_harness_violation")
    path = root / relative
    if path.is_symlink() or not path.is_file():
        reject("preserved_state_violation")
    return path.read_bytes()


def extract_swift_method(source: bytes, method_name: str) -> bytes:
    marker = f"func {method_name}".encode()
    try:
        start = source.index(marker)
        opening = source.index(b"{", start)
    except ValueError:
        reject("oracle_method_violation")
    depth = 0
    for index in range(opening, len(source)):
        byte = source[index]
        if byte == ord("{"):
            depth += 1
        elif byte == ord("}"):
            depth -= 1
            if depth == 0:
                return source[start : index + 1]
    reject("oracle_method_violation")


def extract_region(text: str, begin: str, end: str) -> str:
    if text.count(begin) != 1 or text.count(end) != 1:
        reject("diagnostic_harness_violation")
    start = text.index(begin) + len(begin)
    finish = text.index(end, start)
    if finish <= start:
        reject("diagnostic_harness_violation")
    return text[start:finish]


def ordered_positions(text: str, tokens: tuple[str, ...], category: str) -> None:
    cursor = -1
    for token in tokens:
        if text.count(token) != 1:
            reject(category)
        position = text.index(token)
        if position <= cursor:
            reject(category)
        cursor = position


def parse_declarations(
    declarations: list[str], expected: tuple[str, ...], state_kind: str
) -> dict[str, str]:
    result: dict[str, str] = {}
    for declaration in declarations:
        if declaration.count("=") != 1:
            reject("preservation_declaration_violation")
        relative, value = declaration.split("=", 1)
        if not valid_relative_path(relative) or relative in result:
            reject("preservation_declaration_violation")
        if state_kind == "hash":
            if re.fullmatch(r"[0-9a-f]{64}", value) is None:
                reject("preservation_declaration_violation")
        elif value != "absent":
            reject("preservation_declaration_violation")
        result[relative] = value
    if set(result) != set(expected) or len(result) != len(expected):
        reject("preservation_declaration_violation")
    return result


def verify_preservation(root: Path, args: argparse.Namespace, rollback: bool) -> None:
    hashes = parse_declarations(args.required_preserved_file, PRESENT_FILES, "hash")
    states = parse_declarations(args.required_preserved_path, ABSENT_PATHS, "state")
    for relative, expected in hashes.items():
        if not rollback and relative in {PROVIDER_PATH, TEST_PATH}:
            continue
        if sha256(read_regular(root, relative)) != expected:
            reject("preserved_hash_violation")
    for relative, expected in states.items():
        if expected != "absent":
            reject("preserved_state_violation")
        path = root / relative
        if path.exists() or path.is_symlink():
            reject("preserved_state_violation")


def parse_status(raw: str) -> set[str]:
    changed: set[str] = set()
    for line in raw.splitlines():
        if len(line) < 4 or line[2] != " ":
            reject("status_shape_violation")
        relative = line[3:]
        if " -> " in relative:
            relative = relative.split(" -> ", 1)[1]
        if relative.startswith('"') or not valid_relative_path(relative):
            reject("status_shape_violation")
        changed.add(relative)
    return changed


def verify_status(args: argparse.Namespace) -> None:
    if not args.status_stdin:
        reject("status_shape_violation")
    expected = set(args.allowed_diff_path)
    if len(expected) != len(args.allowed_diff_path) or any(
        not valid_relative_path(path) for path in expected
    ):
        reject("status_shape_violation")
    if parse_status(sys.stdin.read()) != expected:
        reject("status_allowlist_violation")


def parse_branch(value: str, maximum: int) -> tuple[int, int, int] | None:
    if value == "not_reached":
        return None
    match = re.fullmatch(r"left=(\d+),right=(\d+),total=(\d+)", value)
    if match is None:
        reject("aggregate_grammar_violation")
    left, right, total = (int(item) for item in match.groups())
    if left > maximum or right > maximum or total > maximum * 2 or total != left + right:
        reject("aggregate_grammar_violation")
    return left, right, total


def parse_scalar(value: str) -> int | None:
    if value == "not_reached":
        return None
    if re.fullmatch(r"(?:0|[1-9]\d*)", value) is None:
        reject("aggregate_grammar_violation")
    parsed = int(value)
    if parsed > 20:
        reject("aggregate_grammar_violation")
    return parsed


def verify_margin(first_failure: str, value: str) -> None:
    required = MARGIN_SCALES.get(first_failure)
    if required is None:
        if value != "not_needed":
            reject("margin_contract_violation")
        return
    match = re.fullmatch(r"value=(-?(?:0|[1-9]\d*)),scale=(q16|q24|q40)", value)
    if match is None:
        reject("margin_contract_violation")
    signed = int(match.group(1))
    scale, limit = required
    if match.group(2) != scale or signed >= 0 or abs(signed) > limit:
        reject("margin_contract_violation")


def stage_index(first_failure: str) -> int:
    if first_failure not in GATES:
        reject("aggregate_grammar_violation")
    return GATES.index(first_failure)


def verify_aggregate(fields: dict[str, str]) -> None:
    if tuple(fields) != SUFFIX_FIELDS:
        reject("aggregate_field_order_violation")
    if fields["diagnostic_contract"] != CONTRACT:
        reject("aggregate_grammar_violation")
    classification = fields["classification"]
    if classification not in CLASSIFICATIONS:
        reject("outcome_invariant_violation")
    first_failure = fields["first_failure"]
    index = stage_index(first_failure)
    if fields["construction_invocation_count"] != "1":
        reject("aggregate_grammar_violation")
    if fields["render_invocation_count"] != "0" or fields["oracle_invocation_count"] != "0":
        reject("aggregate_grammar_violation")
    if fields["rollback_status"] != ROLLBACK_STATUS:
        reject("aggregate_grammar_violation")
    if fields["static_verifier_status"] != "FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED":
        reject("aggregate_grammar_violation")
    if any(raw in name.lower() or raw in value.lower() for name, value in fields.items() for raw in RAW_EVIDENCE_WORDS):
        reject("aggregate_privacy_violation")

    canonical = parse_branch(fields["canonical_branch_counts"], 7)
    analytical = parse_branch(fields["analytical_slot_counts"], 12)
    retained = parse_branch(fields["retained_branch_counts"], 10)
    clipped = parse_branch(fields["clipped_branch_counts"], 10)
    scalar_names = (
        "cap_template_count",
        "provider_cap_admitted_count",
        "provider_half_admitted_count",
        "reference_cap_admitted_count",
        "reference_half_admitted_count",
        "final_point_count",
    )
    scalars = {name: parse_scalar(fields[name]) for name in scalar_names}
    verify_margin(first_failure, fields["first_failure_margin"])

    exact = ((7, 7, 14), (12, 12, 24), (10, 10, 20), (10, 10, 20))
    branches = (canonical, analytical, retained, clipped)
    # Stage reached/failure matrix: a failing stage may report its own count;
    # every passed prior structural stage is exact, and later stages are absent.
    failure_branch_stage = {1: 0, 2: 1, 3: 2, 5: 3}.get(index)
    for branch_stage, value in enumerate(branches):
        if failure_branch_stage == branch_stage:
            if value is None:
                reject("count_prefix_violation")
        elif index > (1, 2, 3, 5)[branch_stage] or first_failure == "none":
            if value != exact[branch_stage]:
                reject("count_prefix_violation")
        elif value is not None:
            reject("count_prefix_violation")

    if index < 5:
        if any(value is not None for value in scalars.values()):
            reject("count_prefix_violation")
    elif index <= 12:
        if any(value is not None for value in scalars.values()):
            reject("count_prefix_violation")
    elif index == 13:
        if scalars["cap_template_count"] != 20:
            reject("count_prefix_violation")
        if any(scalars[name] is None for name in scalar_names[1:5]):
            reject("count_prefix_violation")
        if scalars["final_point_count"] is not None:
            reject("count_prefix_violation")
    elif index in (14, 15):
        if any(scalars[name] is None for name in scalar_names):
            reject("count_prefix_violation")
        if scalars["cap_template_count"] != 20:
            reject("count_prefix_violation")

    template = scalars["cap_template_count"]
    if template is not None:
        for name in scalar_names[1:]:
            if scalars[name] is not None and scalars[name] > template:
                reject("aggregate_grammar_violation")

    provider_reference_mismatch = any(
        scalars[provider] is not None
        and scalars[reference] is not None
        and scalars[provider] != scalars[reference]
        for provider, reference in (
            ("provider_cap_admitted_count", "reference_cap_admitted_count"),
            ("provider_half_admitted_count", "reference_half_admitted_count"),
        )
    )
    conformance_deviation = any(
        value is not None and value != exact[position]
        for position, value in enumerate(branches)
        if failure_branch_stage != position
    )
    if failure_branch_stage is not None:
        observed = branches[failure_branch_stage]
        if observed is not None and observed[0] != observed[1]:
            conformance_deviation = True

    cap = scalars["provider_cap_admitted_count"]
    half = scalars["provider_half_admitted_count"]
    final = scalars["final_point_count"]
    nonzero_reproduction = any(value not in (None, 0) for value in (cap, half, final))
    early_faithful_failure = index < 13 and not conformance_deviation

    if classification == "implementation_defect":
        if not (conformance_deviation or provider_reference_mismatch):
            reject("outcome_invariant_violation")
    elif classification == "genuine_construction_miss":
        faithful_strength_zero = index == 13 and cap == half == 0
        faithful_budget = index == 14
        if first_failure == "none" or conformance_deviation or provider_reference_mismatch:
            reject("outcome_invariant_violation")
        if not (early_faithful_failure or faithful_strength_zero or faithful_budget):
            reject("outcome_invariant_violation")
    elif classification == "prior_stop_not_reproduced":
        if conformance_deviation or provider_reference_mismatch or early_faithful_failure:
            reject("outcome_invariant_violation")
        if first_failure != "none" and not nonzero_reproduction:
            reject("outcome_invariant_violation")
    # diagnostic_invalid intentionally records an externally invalid run while
    # retaining the same strict grammar whenever a marker was safely parsed.

    if first_failure == "none":
        if provider_reference_mismatch or final != cap:
            reject("outcome_invariant_violation")


def parse_attempt(
    data: bytes,
    prefix_bytes: int,
    prefix_hash: str,
    prefix_headings: int,
    suffix_heading: str,
    suffix_sections: int,
    expected_fields: tuple[str, ...],
) -> dict[str, str] | None:
    if prefix_bytes < 0 or prefix_bytes > len(data):
        reject("attempt_prefix_violation")
    prefix, suffix = data[:prefix_bytes], data[prefix_bytes:]
    if sha256(prefix) != prefix_hash:
        reject("attempt_prefix_violation")
    if len(re.findall(rb"^## 2026-", prefix, re.MULTILINE)) != prefix_headings:
        reject("attempt_prefix_violation")
    text = suffix.decode("utf-8")
    if suffix_sections == 0:
        if text:
            reject("attempt_suffix_violation")
        return None
    if suffix_sections != 1 or text.count(suffix_heading) != 1:
        reject("attempt_suffix_violation")
    if not text.startswith("\n\n" + suffix_heading + "\n\n"):
        reject("attempt_suffix_violation")
    if len(re.findall(r"^## ", text, re.MULTILINE)) != 1:
        reject("attempt_suffix_violation")
    matches = re.findall(r"^- ([a-z0-9_]+): ([^\r\n]+)$", text, re.MULTILINE)
    if tuple(name for name, _ in matches) != expected_fields:
        reject("aggregate_field_order_violation")
    fields = dict(matches)
    verify_aggregate(fields)
    return fields


def verify_static_sources(provider_text: str, test_text: str) -> None:
    provider = extract_region(
        provider_text, "// D1V19_DIAGNOSTIC_BEGIN", "// D1V19_DIAGNOSTIC_END"
    )
    test = extract_region(test_text, "// D1V19_DIAGNOSTIC_BEGIN", "// D1V19_DIAGNOSTIC_END")
    for symbol in PROVIDER_TEMPORARY_SYMBOLS:
        if provider.count(symbol) < 1:
            reject("diagnostic_harness_violation")
    for symbol in TEST_TEMPORARY_SYMBOLS:
        if test.count(symbol) < 1:
            reject("diagnostic_harness_violation")
    if test.count("d1V19DiagnosticConstruction(face:") != 1:
        reject("diagnostic_harness_violation")
    if any(token in test for token in BANNED_DIAGNOSTIC_TOKENS):
        reject("diagnostic_harness_violation")
    if any(token in provider for token in BANNED_DIAGNOSTIC_TOKENS):
        reject("diagnostic_harness_violation")
    combined = provider + test
    if combined.count("print(") != 1:
        reject("diagnostic_harness_violation")
    if provider.count(AUTHORIZED_MARKER_EMISSION) != 0:
        reject("diagnostic_harness_violation")
    if test.count(AUTHORIZED_MARKER_EMISSION) != 1:
        reject("diagnostic_harness_violation")
    if any(test.count(f'"{field}=') != 1 for field in SUFFIX_FIELDS):
        reject("diagnostic_harness_violation")
    if re.search(r"\bstatic\s+var\b|\bclass\s+var\b", provider + test):
        reject("diagnostic_harness_violation")
    ordered_positions(
        provider,
        tuple(f'case {case_name} = "{value}"' for case_name, value in GATE_PAIRS),
        "revision18_contract_deviation",
    )
    ordered_positions(
        provider,
        tuple(f"let {name}" for name in SUFFIX_FIELDS[3:15]),
        "revision18_contract_deviation",
    )
    required_contract_tokens = (
        "Float(1.0 / 16_777_216.0)",
        "0x33800000",
        "1...12",
        "Float(index) / 13",
        "Float(index - 1) / 13",
        "Float(index + 1) / 13",
        "64 * Double(g)",
        "4 * Float(q18) * g",
        "2 * Float(q18) * g",
        "0.75 * branchClearance",
        "0.08 * radius",
        "8.0 / 45.0",
        "16.0 / 45.0",
        "29.0 / 45.0",
        "13107",
        "26214",
        "39322",
        "1678",
    )
    if any(token not in provider for token in required_contract_tokens):
        reject("revision18_contract_deviation")
    required_reference_tokens = (
        "round(2 * alpha * Float(item.q18))",
        "referenceFinalizeD1V18Template",
        "classifyD1V19",
        "FACE01_D19_DIAGNOSTIC",
    )
    if any(token not in test for token in required_reference_tokens):
        reject("revision18_contract_deviation")


def verify_oracle(root: Path, args: argparse.Namespace) -> None:
    if args.oracle_status != "not-invoked":
        reject("oracle_status_violation")
    source = read_regular(root, args.oracle_method_path)
    method = extract_swift_method(source, args.oracle_method_name)
    if sha256(method) != args.oracle_method_sha256:
        reject("oracle_method_violation")


def expected_suffix_fields(args: argparse.Namespace) -> tuple[str, ...]:
    fields = tuple(args.expected_suffix_fields.split(","))
    if fields != SUFFIX_FIELDS:
        reject("aggregate_field_order_violation")
    return fields


def common_live(args: argparse.Namespace, rollback: bool) -> tuple[Path, dict[str, str] | None]:
    root = Path(".").resolve()
    verify_preservation(root, args, rollback=rollback)
    verify_oracle(root, args)
    attempt = read_regular(root, args.attempt_path)
    fields = parse_attempt(
        attempt,
        args.attempt_prefix_bytes,
        args.attempt_prefix_sha256,
        args.expected_prefix_headings,
        args.expected_suffix_heading,
        args.expected_suffix_sections,
        expected_suffix_fields(args),
    )
    verify_status(args)
    return root, fields


def run_preflight(args: argparse.Namespace) -> None:
    root, fields = common_live(args, rollback=False)
    if fields is not None or args.expected_suffix_sections != 0:
        reject("attempt_suffix_violation")
    provider = read_regular(root, PROVIDER_PATH).decode("utf-8")
    test = read_regular(root, TEST_PATH).decode("utf-8")
    verify_static_sources(provider, test)
    print("FACE01_DIAGNOSTIC_PREFLIGHT_VERIFIED")


def run_rollback(args: argparse.Namespace) -> None:
    root, _ = common_live(args, rollback=True)
    provider = read_regular(root, PROVIDER_PATH).decode("utf-8")
    test = read_regular(root, TEST_PATH).decode("utf-8")
    for symbol in PROVIDER_TEMPORARY_SYMBOLS + TEST_TEMPORARY_SYMBOLS:
        if symbol in provider or symbol in test:
            reject("temporary_symbol_violation")
    print("FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED")


def parse_frontmatter(text: str) -> dict[str, str]:
    if not text.startswith("---\n") or "\n---\n" not in text[4:]:
        reject("green_summary_violation")
    block = text[4:].split("\n---\n", 1)[0]
    result: dict[str, str] = {}
    for line in block.splitlines():
        if re.fullmatch(r"[a-z][a-z0-9_-]*: .+", line):
            key, value = line.split(": ", 1)
            result[key] = value.strip()
    return result


def verify_green_summary_text(text: str, plan: str, requirements: tuple[str, ...], primary: bool) -> None:
    frontmatter = parse_frontmatter(text)
    if frontmatter.get("phase") != "90-face-contour-and-chin-repairs":
        reject("green_summary_violation")
    if frontmatter.get("plan", "").strip('"') != plan:
        reject("green_summary_violation")
    completed = frontmatter.get("requirements-completed", "")
    if any(requirement not in completed for requirement in requirements):
        reject("green_summary_violation")
    if primary:
        if frontmatter.get("semantic_status") != "green":
            reject("green_summary_violation")
        if "FACE01_SEMANTIC_STATUS=GREEN" not in text or "frozen_oracle_status=passed" not in text:
            reject("green_summary_violation")
        lowered = text.lower()
        if any(word in lowered for word in ("diagnostic summary", "semantic_status: stopped", "semantic_status: blocked", "oracle_status=not-invoked")):
            reject("green_summary_violation")
    elif "## Self-Check: PASSED" not in text:
        reject("green_summary_violation")


def run_green_summary(args: argparse.Namespace) -> None:
    root = Path(".").resolve()
    summary = read_regular(root, args.summary_path).decode("utf-8")
    verify_green_summary_text(summary, "01", ("FACE-01",), primary=True)
    ledger = read_regular(root, args.ledger_path).decode("utf-8")
    if re.search(r"\|\s*Complete FACE-01\s*\|\s*`completed`\s*\|", ledger) is None:
        reject("green_summary_violation")
    declarations: dict[str, tuple[str, ...]] = {}
    for item in args.required_completed_summary:
        if item.count("=") != 1:
            reject("green_summary_violation")
        relative, descriptor = item.split("=", 1)
        if relative in declarations or not valid_relative_path(relative) or ":" not in descriptor:
            reject("green_summary_violation")
        plan, raw_requirements = descriptor.split(":", 1)
        requirements = tuple(value for value in raw_requirements.split(",") if value)
        if not re.fullmatch(r"\d{2}", plan) or not requirements:
            reject("green_summary_violation")
        declarations[relative] = (plan,) + requirements
    for relative, descriptor in declarations.items():
        text = read_regular(root, relative).decode("utf-8")
        verify_green_summary_text(text, descriptor[0], descriptor[1:], primary=False)
    print("FACE01_GREEN_SUMMARY_VERIFIED")


def must_reject(action, category: str | None = None) -> None:
    try:
        action()
    except DiagnosticError as error:
        if category is not None and error.category != category:
            reject("self_test_violation")
        return
    reject("self_test_violation")


def self_test() -> None:
    good_provider = """// D1V19_DIAGNOSTIC_BEGIN
struct D1V19Gate {\n""" + "\n".join(
        f'case {case_name} = "{value}"' for case_name, value in GATE_PAIRS
    ) + """
struct D1V19FixedPointMargin {}
struct D1V19Aggregate {
let construction_invocation_count: Int
let canonical_branch_counts: Int
let analytical_slot_counts: Int
let retained_branch_counts: Int
let clipped_branch_counts: Int
let cap_template_count: Int
let provider_cap_admitted_count: Int
let provider_half_admitted_count: Int
let reference_cap_admitted_count: Int
let reference_half_admitted_count: Int
let final_point_count: Int
let first_failure_margin: Int
}
struct D1V19Template {}
struct D1V19ConstructionResult {}
func d1V19DiagnosticConstruction() {}
func d1V18Template() {}
func finalizedD1V18Points() {}
func d1FieldPassesSafety() {}
let g = Float(1.0 / 16_777_216.0)
let bits = 0x33800000
for index in 1...12 { _ = Float(index) / 13; _ = Float(index - 1) / 13; _ = Float(index + 1) / 13 }
_ = 64 * Double(g); _ = 4 * Float(q18) * g; _ = 2 * Float(q18) * g
_ = 0.75 * branchClearance; _ = 0.08 * radius
_ = 8.0 / 45.0; _ = 16.0 / 45.0; _ = 29.0 / 45.0
_ = 13107; _ = 26214; _ = 39322; _ = 1678
// D1V19_DIAGNOSTIC_END"""
    good_test = """// D1V19_DIAGNOSTIC_BEGIN
enum D1V19Outcome {}
struct D1V19ReferenceCounts {}
func referenceFinalizeD1V18Template() { _ = round(2 * alpha * Float(item.q18)) }
func classifyD1V19() {}
func testFACE01D1V19DiagnosticOnlyClassification() {
  _ = d1V19DiagnosticConstruction(face: face)
  let marker = [
""" + "\n".join(f'    "{field}=value",' for field in SUFFIX_FIELDS) + """
  ].joined(separator: "|")
  Swift.print("FACE01_D19_DIAGNOSTIC \\(marker)")
}
// D1V19_DIAGNOSTIC_END"""
    verify_static_sources(good_provider, good_test)
    must_reject(lambda: verify_static_sources(good_provider, good_test.replace("}\n", "  _ = d1V19DiagnosticConstruction(face: face)\n}\n", 1)))
    for token in BANNED_DIAGNOSTIC_TOKENS:
        must_reject(lambda token=token: verify_static_sources(good_provider, good_test.replace("func classifyD1V19() {}", f"func classifyD1V19() {{ _ = {token!r} }}")))
    must_reject(lambda: verify_static_sources(good_provider, good_test.replace(AUTHORIZED_MARKER_EMISSION, "")))
    must_reject(lambda: verify_static_sources(good_provider, good_test.replace(AUTHORIZED_MARKER_EMISSION, AUTHORIZED_MARKER_EMISSION + "\n  " + AUTHORIZED_MARKER_EMISSION)))
    must_reject(lambda: verify_static_sources(good_provider, good_test.replace(AUTHORIZED_MARKER_EMISSION, 'print("FACE01_D19_DIAGNOSTIC \\(marker)")')))
    must_reject(lambda: verify_static_sources(good_provider, good_test.replace('"classification=value",', '"classification_changed=value",')))
    must_reject(lambda: verify_static_sources(good_provider.replace("struct D1V19Template {}", "static var D1V19Template = 0"), good_test))
    first_case = f'case {GATE_PAIRS[0][0]} = "{GATE_PAIRS[0][1]}"'
    second_case = f'case {GATE_PAIRS[1][0]} = "{GATE_PAIRS[1][1]}"'
    must_reject(lambda: verify_static_sources(good_provider.replace(first_case + "\n" + second_case, second_case + "\n" + first_case), good_test))
    must_reject(lambda: verify_static_sources(good_provider.replace(first_case, ""), good_test))
    must_reject(lambda: verify_static_sources(good_provider.replace(first_case, first_case + "\n" + first_case), good_test))
    must_reject(lambda: verify_static_sources(good_provider.replace("let canonical_branch_counts", "let retained_branch_counts2"), good_test))

    base = {
        "diagnostic_contract": CONTRACT,
        "classification": "genuine_construction_miss",
        "first_failure": "canonical_branches",
        "construction_invocation_count": "1",
        "canonical_branch_counts": "left=6,right=6,total=12",
        "analytical_slot_counts": "not_reached",
        "retained_branch_counts": "not_reached",
        "clipped_branch_counts": "not_reached",
        "cap_template_count": "not_reached",
        "provider_cap_admitted_count": "not_reached",
        "provider_half_admitted_count": "not_reached",
        "reference_cap_admitted_count": "not_reached",
        "reference_half_admitted_count": "not_reached",
        "final_point_count": "not_reached",
        "first_failure_margin": "not_needed",
        "render_invocation_count": "0",
        "oracle_invocation_count": "0",
        "rollback_status": ROLLBACK_STATUS,
        "static_verifier_status": "FACE01_DIAGNOSTIC_ROLLBACK_VERIFIED",
    }
    verify_aggregate(base)
    mutations = (
        ("classification", "unknown"),
        ("canonical_branch_counts", "left=8,right=0,total=8"),
        ("canonical_branch_counts", "left=6,right=6,total=11"),
        ("analytical_slot_counts", "left=1,right=1,total=2"),
        ("cap_template_count", "21"),
        ("first_failure_margin", "value=-1,scale=q16"),
        ("render_invocation_count", "1"),
        ("oracle_invocation_count", "1"),
    )
    for name, value in mutations:
        must_reject(lambda name=name, value=value: verify_aggregate({**base, name: value}))
    reordered = dict(list(base.items())[::-1])
    must_reject(lambda: verify_aggregate(reordered))
    must_reject(lambda: verify_aggregate({**base, "coordinate": "1"}))
    margin_base = {**base, "first_failure": "single_safety", "canonical_branch_counts": "left=7,right=7,total=14", "analytical_slot_counts": "left=12,right=12,total=24", "retained_branch_counts": "left=10,right=10,total=20", "clipped_branch_counts": "left=10,right=10,total=20", "first_failure_margin": "value=-1,scale=q16"}
    verify_aggregate(margin_base)
    for value in ("not_needed", "value=0,scale=q16", "value=-1,scale=q24", "value=-65537,scale=q16"):
        must_reject(lambda value=value: verify_aggregate({**margin_base, "first_failure_margin": value}))

    hash_value = sha256(b"baseline")
    good_declarations = [f"{path}={hash_value}" for path in PRESENT_FILES]
    parse_declarations(good_declarations, PRESENT_FILES, "hash")
    must_reject(lambda: parse_declarations(good_declarations[:-1], PRESENT_FILES, "hash"))
    must_reject(lambda: parse_declarations(good_declarations + [good_declarations[0]], PRESENT_FILES, "hash"))
    must_reject(lambda: parse_declarations(good_declarations + [f"extra={hash_value}"], PRESENT_FILES, "hash"))
    must_reject(lambda: parse_declarations([good_declarations[0].replace(hash_value, "0" * 64)] + good_declarations[1:], PRESENT_FILES, "hash") if sha256(b"baseline") == "0" * 64 else reject("preserved_hash_violation"), "preserved_hash_violation")

    prefix = b"\n".join(f"## 2026-09-01 retry {index}".encode() for index in range(10)) + b"\n"
    parse_attempt(prefix, len(prefix), sha256(prefix), 10, "## suffix", 0, SUFFIX_FIELDS)
    must_reject(lambda: parse_attempt(prefix + b"x", len(prefix), sha256(prefix), 10, "## suffix", 0, SUFFIX_FIELDS))
    must_reject(lambda: parse_attempt(prefix, len(prefix), "0" * 64, 10, "## suffix", 0, SUFFIX_FIELDS))
    suffix = "\n\n## suffix\n\n" + "\n".join(f"- {name}: {base[name]}" for name in SUFFIX_FIELDS) + "\n"
    parse_attempt(prefix + suffix.encode(), len(prefix), sha256(prefix), 10, "## suffix", 1, SUFFIX_FIELDS)
    must_reject(lambda: parse_attempt(prefix + (suffix + suffix).encode(), len(prefix), sha256(prefix), 10, "## suffix", 1, SUFFIX_FIELDS))
    wrong_order = (SUFFIX_FIELDS[1], SUFFIX_FIELDS[0]) + SUFFIX_FIELDS[2:]
    must_reject(lambda: parse_attempt(prefix + suffix.encode(), len(prefix), sha256(prefix), 10, "## suffix", 1, wrong_order))

    good_summary = """---
phase: 90-face-contour-and-chin-repairs
plan: "01"
semantic_status: green
requirements-completed: [FACE-01]
---
FACE01_SEMANTIC_STATUS=GREEN
frozen_oracle_status=passed
"""
    verify_green_summary_text(good_summary, "01", ("FACE-01",), primary=True)
    for mutation in (
        "",
        good_summary.replace("phase: 90-face-contour-and-chin-repairs", "phase: wrong"),
        good_summary.replace('plan: "01"', 'plan: "09"'),
        good_summary.replace("FACE-01", "FACE-02"),
        good_summary.replace("semantic_status: green", "semantic_status: blocked"),
        good_summary.replace("FACE01_SEMANTIC_STATUS=GREEN", "FACE01_SEMANTIC_STATUS=RED"),
        good_summary.replace("frozen_oracle_status=passed", "oracle_status=not-invoked"),
    ):
        must_reject(lambda mutation=mutation: verify_green_summary_text(mutation, "01", ("FACE-01",), primary=True))
    # Symlink/present-summary and live file drift are covered by read_regular,
    # verify_preservation, and run_green_summary; their pure validators above
    # are mutation-tested without creating any filesystem fixture.
    print("FACE01_DIAGNOSTIC_SELF_TESTED")


def add_common_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--status-stdin", action="store_true")
    parser.add_argument("--oracle-status", required=True)
    parser.add_argument("--oracle-method-path", required=True)
    parser.add_argument("--oracle-method-name", required=True)
    parser.add_argument("--oracle-method-sha256", required=True)
    parser.add_argument("--required-preserved-file", action="append", default=[], required=True)
    parser.add_argument("--required-preserved-path", action="append", default=[], required=True)
    parser.add_argument("--attempt-path", required=True)
    parser.add_argument("--attempt-prefix-bytes", type=int, required=True)
    parser.add_argument("--attempt-prefix-sha256", required=True)
    parser.add_argument("--expected-prefix-headings", type=int, required=True)
    parser.add_argument("--expected-suffix-heading", required=True)
    parser.add_argument("--expected-suffix-sections", type=int, required=True)
    parser.add_argument("--expected-suffix-fields", required=True)
    parser.add_argument("--allowed-diff-path", action="append", default=[])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="mode", required=True)
    subparsers.add_parser("self-test", help="Run in-memory mutation tests.")
    add_common_arguments(subparsers.add_parser("preflight", help="Verify the temporary diagnostic statically."))
    add_common_arguments(subparsers.add_parser("rollback", help="Verify rollback and optional evidence statically."))
    green = subparsers.add_parser("green-summary", help="Verify a later GREEN FACE-01 activation summary.")
    green.add_argument("--summary-path", required=True)
    green.add_argument("--ledger-path", required=True)
    green.add_argument("--required-completed-summary", action="append", default=[])
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.mode == "self-test":
        self_test()
    elif args.mode == "preflight":
        run_preflight(args)
    elif args.mode == "rollback":
        run_rollback(args)
    else:
        run_green_summary(args)


if __name__ == "__main__":
    try:
        main()
    except DiagnosticError as error:
        print(f"FACE01_DIAGNOSTIC_ERROR:{error.category}", file=sys.stderr)
        raise SystemExit(1)
