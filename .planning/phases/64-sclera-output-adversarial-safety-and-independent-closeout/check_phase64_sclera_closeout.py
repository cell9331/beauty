#!/usr/bin/env python3
"""Fail-closed Phase 64 scope, safety, privacy, and three-state closeout checker."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Callable


THREATS = tuple(f"T-64-{index:02d}" for index in range(1, 9))
PHASE_DIR = Path(".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout")
EXPECTED_TASKS = tuple(
    f"64-{plan:02d}-{task:02d}"
    for plan in range(1, 12)
    for task in range(1, 3 if plan <= 9 else 2)
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


def git_names(*args: str) -> list[str]:
    result = subprocess.run(["git", *args], check=False, capture_output=True, text=True, timeout=20)
    require(result.returncode == 0, "git inventory failed")
    return [line for line in result.stdout.splitlines() if line]


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


def validate_review(review: str) -> None:
    for token in (
        "original_detail", "positive", "negative", "sclera_locality", "vessel_detail",
        "highlight_identity", "iris_pupil_identity", "lid_skin_identity", "natural_color",
        "negative_stability", "decision: pass",
    ):
        require(token in review, "review category incomplete")
    require("/Users/" not in review and "example-images/" not in review, "review contains locator")


def validate_privacy(names: list[str], aggregate: dict[str, object]) -> None:
    require(all("local-retouch-review/" not in name for name in names), "private/generated media tracked or changed")
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
    require(len(plans) == 11, "plan inventory mismatch")
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
        rows = [line.lower() for line in text.splitlines() if re.match(r"^\| 64-(10|11)-01 \|", line)]
        require(len(rows) == 2 and all("pending" in row or "not-run" in row or "not run" in row for row in rows), "future gates not visibly pending")
        require("20/20" not in text, "validation finalized before candidate")
    else:
        require("20/20" in text, "final validation total missing")
        require(not any(token in lowered for token in ("skipped", "conditional pass", "not-run", "not run")), "final validation has non-executed evidence")


def validate_lifecycle_content(texts: str, mode: str) -> None:
    if mode == "promotion-pending-verification":
        require(re.search(r"promotion.?pending|post.?promotion", texts, re.IGNORECASE) is not None, "lifecycle pending state missing")
        require("64-10" in texts and "64-11" in texts, "final serial gates missing")
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

    def aggregate() -> dict[str, object]:
        nonlocal aggregate_cache
        if aggregate_cache is None:
            aggregate_cache = runtime_aggregate()
            validate_aggregate_evidence(aggregate_cache)
        return aggregate_cache

    checks: dict[str, Callable[[], int]] = {
        "T-64-01": lambda: (validate_renderer_source(read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")), True), 7)[1],
        "T-64-02": lambda: (validate_parser_artifacts(read(PHASE_DIR / "check_sclera_renderer_outputs.py"), read(PHASE_DIR / "64-SCLERA-OUTPUT-EVIDENCE.md")), 10)[1],
        "T-64-03": lambda: (validate_adversarial_source(read(Path("BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift"))), validate_proposal_exposure(), aggregate(), 20)[3],
        "T-64-04": lambda: (validate_final_output_sources(read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift")), read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift")), read(Path("BeautySDK/Sources/BeautySDK/BeautyEngine.swift"))), 8)[1],
        "T-64-05": lambda: (validate_review(read(PHASE_DIR / "64-REVIEW.md")), 12)[1],
        "T-64-06": lambda: (validate_privacy(git_names("ls-files") + git_names("diff", "--cached", "--name-only") + git_names("diff", "--name-only") + git_names("ls-files", "--others", "--exclude-standard"), aggregate()), validate_proposal_exposure(), 12)[2],
        "T-64-07": lambda: (validate_product_state(*(read(path) for path in PRODUCT_FILES), promoted), validate_stage(mode), 12)[2],
        "T-64-08": lambda: (validate_lifecycle_inventory(json.loads(read(PHASE_DIR / "64-THREAT-INVENTORY.json"))), validate_validation_ledger(mode), validate_lifecycle_text(mode), 14)[3],
    }
    counts: dict[str, int] = {}
    for threat in ((selected,) if selected else THREATS):
        counts[threat] = checks[threat]()
    print(json.dumps({"status": "pass", "mode": mode, "checks": counts}, separators=(",", ":")))
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


def run_self_test() -> int:
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
            lambda: validate_lifecycle_content("Phase 64 gaps_found; 64-10 and 64-11 absent", "promotion-pending-verification"),
        ),
    )
    for name, mutation in synthetic_cases:
        try:
            mutation()
        except CheckError:
            passed += 1
        else:
            raise CheckError(f"HIGH mutation accepted:{name}")
    print(json.dumps({"status": "pass", "self_tests": passed, "threats": 8, "states": 3}, separators=(",", ":")))
    return passed


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
        print("phase64_closeout_failed", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
