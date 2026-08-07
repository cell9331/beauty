#!/usr/bin/env python3
"""Fail-closed Phase 64 scope, security, privacy, and promotion checker."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path


THREATS = tuple(f"T-64-{index:02d}" for index in range(1, 9))
PHASE_DIR = Path(".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout")
EXPECTED_TASKS = tuple(
    f"64-{plan:02d}-{task:02d}" for plan in range(1, 5) for task in range(1, 3)
)
PRODUCT_FILES = (
    Path("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md"),
    Path("docs/meitu-function-blueprint/FEATURE_MATRIX.md"),
    Path("docs/meitu-function-blueprint/features/beauty-shaping/README.md"),
    Path("docs/meitu-function-blueprint/features/beauty-shaping/eyes/README.md"),
)


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
    result = subprocess.run(
        ["git", *args],
        check=False,
        capture_output=True,
        text=True,
        timeout=20,
    )
    if result.returncode != 0:
        raise CheckError("git inventory failed")
    return [line for line in result.stdout.splitlines() if line]


def validate_renderer_source(source: str, final_ready: bool) -> None:
    require(source.count("engine.processResult(") == 1, "renderer public call not exact")
    require("import BeautySDK" in source, "renderer public import missing")
    for forbidden in ("import BeautyCore", "import BeautyDetection", "import BeautyEffects", "@_spi(Testing)"):
        require(forbidden not in source, "renderer internal/Testing bypass")
    ids = re.findall(r'\bid\s*:\s*"([^"]+)"', source)
    expected_count = 74 if final_ready else 73
    require(len(ids) == expected_count and len(set(ids)) == expected_count, "renderer inventory mismatch")
    require(ids.count("geometryBaseline_noop") == 1, "baseline missing")
    if final_ready:
        require(ids.count("scleraRednessReduction_1p00") == 1, "sclera case missing")
        require("BeautyParameters(scleraRednessReduction: 1)" in source, "sclera intent not exact")
        require("--no-watermark" in source, "presentation-free mode missing")
    else:
        require("scleraRednessReduction_1p00" not in ids, "sclera case added before frozen evidence owner")


def renderer_checks(final_ready: bool) -> int:
    validate_renderer_source(read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")), final_ready)
    return 7


def validate_parser_artifacts(helper: str, evidence: str | None) -> None:
    for token in (
        "O_NOFOLLOW",
        "MAX_FILE_BYTES",
        "MAX_DECODED_BYTES",
        "EXPECTED_NAMES",
        "alpha_changed",
        "changed_outside",
        "mean_red_excess_after",
        "improved_eye_count",
        "--self-test",
    ):
        require(token in helper, "strict helper boundary incomplete")
    if evidence is not None:
        require("6/6" in evidence and "public-facade" in evidence.lower(), "output evidence incomplete")


def parser_checks(final_ready: bool) -> int:
    helper = read(PHASE_DIR / "check_sclera_renderer_outputs.py")
    evidence = read(PHASE_DIR / "64-SCLERA-OUTPUT-EVIDENCE.md") if final_ready else None
    validate_parser_artifacts(helper, evidence)
    return 9 + int(final_ready)


def validate_adversarial_source(source: str) -> None:
    for token in (
        "colorIndependentProtectedTruth",
        "recoloredProtected",
        "iris",
        "pupil",
        "highlight",
        "lashMargin",
        "skin",
        "apertureExterior",
        "XCTAssertEqual",
    ):
        require(token in source, "adversarial protected family incomplete")


def adversarial_checks(final_ready: bool) -> int:
    path = Path("BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift")
    require(path.exists(), "adversarial owner missing")
    validate_adversarial_source(read(path))
    return 10


def validate_final_output_sources(provider: str, transform: str, engine: str) -> None:
    for token in (
        "beforeRednessScore",
        "hardEnvelope",
        "constrainToHardEnvelope",
        "expandedPupilExclusion",
        "actual-pupil exclusion",
    ):
        require(token in provider, "provider containment drift")
    for token in (
        "maximumEffectiveStrength: Float = 0.52",
        "maximumLuminanceDelta: Float = 0.018",
        "immutable canonical source triplet",
    ):
        require(token in transform, "transform bound drift")
    require(engine.count("BeautyScleraRednessProvider.makeResult(") == 1, "production route not exact")


def final_output_checks(_final_ready: bool) -> int:
    validate_final_output_sources(
        read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift")),
        read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift")),
        read(Path("BeautySDK/Sources/BeautySDK/BeautyEngine.swift")),
    )
    return 8


def validate_review(review: str) -> None:
    for token in (
        "original_detail",
        "positive",
        "negative",
        "sclera_locality",
        "vessel_detail",
        "highlight_identity",
        "iris_pupil_identity",
        "lid_skin_identity",
        "natural_color",
        "negative_stability",
        "decision: pass",
    ):
        require(token in review, "review category incomplete")
    require("/Users/" not in review and "example-images/" not in review, "review contains locator")


def review_checks(required: bool) -> int:
    path = PHASE_DIR / "64-REVIEW.md"
    if not path.exists():
        require(not required, "required review missing")
        return 1
    validate_review(read(path))
    return 12


def validate_privacy(names: list[str], phase_text: str) -> None:
    for name in names:
        require("local-retouch-review/" not in name, "private/generated media tracked or staged")
    for forbidden in (
        "/Users/",
        "/Downloads/",
        "reviewer_email",
        "rights_holder",
        "source_path:",
        "asset_digest:",
        "raw_support:",
        "raw_mask:",
        "raw_metric:",
    ):
        require(forbidden not in phase_text, "tracked evidence contains private detail")


def privacy_checks() -> int:
    names = git_names("ls-files") + git_names("diff", "--cached", "--name-only")
    phase_text = "\n".join(read(path) for path in PHASE_DIR.glob("64-*.md"))
    validate_privacy(names, phase_text)
    return 6


def validate_product_state(
    ledger: str,
    matrix: str,
    shaping: str,
    eyes: str,
    allow_promotion: bool,
) -> None:
    redness = next((line for line in ledger.splitlines() if "| `眼睛` | 祛红血丝 |" in line), "")
    require(redness, "sclera ledger row missing")
    if allow_promotion:
        require("| implemented |" in redness, "sclera row not promoted")
        require("Phase 64" in redness, "sclera evidence citation missing")
    else:
        require("| future |" in redness, "sclera promoted before gate")
    require("| `眼睛` | 去脂 | future |" in ledger, "eye-fat row changed")
    require("| Beauty shaping | 眼睛 | partial |" in matrix, "eye matrix no longer partial")
    require("| `眼睛` | partial |" in shaping, "eye shaping branch no longer partial")
    require("Status: `partial`" in eyes, "eye detail no longer partial")
    require("去脂" in eyes, "future eye-fat boundary missing")


def product_checks(allow_promotion: bool) -> int:
    validate_product_state(*(read(path) for path in PRODUCT_FILES), allow_promotion)
    return 8


def validate_lifecycle_inventory(plan_texts: list[str], inventory: dict[str, object]) -> None:
    tasks = re.findall(r'<task id="([^"]+)"', "\n".join(plan_texts))
    require(tuple(tasks) == EXPECTED_TASKS, "task inventory mismatch")
    threats = inventory.get("threats", [])
    require(isinstance(threats, list), "threat inventory shape mismatch")
    require(
        tuple(item.get("id") for item in threats if isinstance(item, dict)) == THREATS,
        "threat inventory mismatch",
    )
    require(
        len(threats) == len(THREATS)
        and all(isinstance(item, dict) and item.get("severity") == "HIGH" for item in threats),
        "non-HIGH threat disposition",
    )


def lifecycle_checks(allow_promotion: bool, final_ready: bool) -> int:
    plans = sorted(PHASE_DIR.glob("64-??-PLAN.md"))
    require(len(plans) == 4, "plan inventory mismatch")
    inventory = json.loads(read(PHASE_DIR / "64-THREAT-INVENTORY.json"))
    require(isinstance(inventory, dict), "threat inventory invalid")
    validate_lifecycle_inventory([read(path) for path in plans], inventory)
    if allow_promotion:
        require(
            all((PHASE_DIR / f"64-{plan:02d}-SUMMARY.md").exists() for plan in range(1, 4)),
            "promotion lacks prerequisite summaries",
        )
        security = read(PHASE_DIR / "64-SECURITY.md")
        require("threats_open: 0" in security, "security not final")
        require((PHASE_DIR / "64-REVIEW.md").exists(), "review not final")
    verification_path = PHASE_DIR / "64-VERIFICATION.md"
    if verification_path.exists():
        verification = read(verification_path)
        require("status: passed" in verification and "borrowed" in verification.lower(), "verification not canonical")
    return 6 + int(allow_promotion) * 3 + int(final_ready)


def final_ready() -> bool:
    return (PHASE_DIR / "64-SCLERA-OUTPUT-EVIDENCE.md").exists()


def run_live(allow_promotion: bool, selected: str | None) -> int:
    ready = final_ready()
    checks = {
        "T-64-01": renderer_checks,
        "T-64-02": parser_checks,
        "T-64-03": adversarial_checks,
        "T-64-04": final_output_checks,
        "T-64-05": lambda _ready: review_checks(
            allow_promotion or (PHASE_DIR / "64-REVIEW.md").exists() or (PHASE_DIR / "64-SECURITY.md").exists()
        ),
        "T-64-06": lambda _ready: privacy_checks(),
        "T-64-07": lambda _ready: product_checks(allow_promotion),
        "T-64-08": lambda _ready: lifecycle_checks(allow_promotion, ready),
    }
    counts: dict[str, int] = {}
    for threat in ((selected,) if selected else THREATS):
        counts[threat] = checks[threat](ready)
    print(json.dumps({"status": "pass", "mode": "post" if allow_promotion else "pre", "checks": counts}, separators=(",", ":")))
    return sum(counts.values())


def run_self_test() -> int:
    renderer = (
        "import BeautySDK\n"
        + "\n".join(f'id: "case_{index}"' for index in range(72))
        + '\nid: "geometryBaseline_noop"\nid: "scleraRednessReduction_1p00"\n'
        + "BeautyParameters(scleraRednessReduction: 1)\n--no-watermark\nengine.processResult("
    )
    helper = " ".join((
        "O_NOFOLLOW", "MAX_FILE_BYTES", "MAX_DECODED_BYTES", "EXPECTED_NAMES",
        "alpha_changed", "changed_outside", "mean_red_excess_after", "improved_eye_count", "--self-test",
    ))
    adversarial = "colorIndependentProtectedTruth recoloredProtected iris pupil highlight lashMargin skin apertureExterior XCTAssertEqual"
    provider = "beforeRednessScore hardEnvelope constrainToHardEnvelope expandedPupilExclusion actual-pupil exclusion"
    transform = "maximumEffectiveStrength: Float = 0.52 maximumLuminanceDelta: Float = 0.018 immutable canonical source triplet"
    engine = "BeautyScleraRednessProvider.makeResult("
    review = "original_detail positive negative sclera_locality vessel_detail highlight_identity iris_pupil_identity lid_skin_identity natural_color negative_stability decision: pass"
    ledger = "\n".join(("| `眼睛` | 去脂 | future |", "| `眼睛` | 祛红血丝 | future |"))
    matrix = "| Beauty shaping | 眼睛 | partial |"
    shaping = "| `眼睛` | partial |"
    eyes = "Status: `partial` 去脂"
    plan_texts = [
        "\n".join(f'<task id="64-{plan:02d}-{task:02d}"' for task in range(1, 3))
        for plan in range(1, 5)
    ]
    inventory: dict[str, object] = {"threats": [{"id": item, "severity": "HIGH"} for item in THREATS]}
    cases = (
        (lambda: validate_renderer_source(renderer, True), lambda: validate_renderer_source(renderer + "\n@_spi(Testing)", True)),
        (lambda: validate_parser_artifacts(helper, "6/6 public-facade"), lambda: validate_parser_artifacts(helper.replace("O_NOFOLLOW", ""), "6/6 public-facade")),
        (lambda: validate_adversarial_source(adversarial), lambda: validate_adversarial_source(adversarial.replace("apertureExterior", ""))),
        (lambda: validate_final_output_sources(provider, transform, engine), lambda: validate_final_output_sources(provider.replace("hardEnvelope", ""), transform, engine)),
        (lambda: validate_review(review), lambda: validate_review(review.replace("decision: pass", "decision: waive"))),
        (lambda: validate_privacy([], "aggregate_only"), lambda: validate_privacy([], "aggregate_only /Users/private/input.png")),
        (lambda: validate_product_state(ledger, matrix, shaping, eyes, False), lambda: validate_product_state(ledger.replace("祛红血丝 | future", "祛红血丝 | implemented"), matrix, shaping, eyes, False)),
        (lambda: validate_lifecycle_inventory(plan_texts, inventory), lambda: validate_lifecycle_inventory(list(reversed(plan_texts)), inventory)),
    )
    passed = 0
    for valid, mutation in cases:
        valid()
        try:
            mutation()
        except CheckError:
            passed += 1
        else:
            raise CheckError("HIGH mutation accepted")
    print(json.dumps({"status": "pass", "self_tests": passed, "threats": len(THREATS)}, separators=(",", ":")))
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--allow-promotion", action="store_true")
    parser.add_argument("--threat", choices=THREATS)
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--repo-root", type=Path)
    args = parser.parse_args()
    if args.repo_root:
        os.chdir(args.repo_root)
    try:
        if args.self_test:
            run_self_test()
        else:
            run_live(args.allow_promotion, args.threat)
        return 0
    except (CheckError, json.JSONDecodeError, subprocess.SubprocessError, AssertionError):
        print("phase64_closeout_failed", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
