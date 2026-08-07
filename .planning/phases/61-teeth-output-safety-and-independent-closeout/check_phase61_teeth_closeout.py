#!/usr/bin/env python3
"""Fail-closed Phase 61 scope, security, privacy, and promotion checker."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


THREATS = tuple(f"T-61-{index:02d}" for index in range(1, 9))
PHASE_DIR = Path(".planning/phases/61-teeth-output-safety-and-independent-closeout")
EXPECTED_TASKS = tuple(f"61-{plan:02d}-{task:02d}" for plan in range(1, 5) for task in range(1, 3))
PRODUCT_FILES = (
    Path("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md"),
    Path("docs/meitu-function-blueprint/FEATURE_MATRIX.md"),
    Path("docs/meitu-function-blueprint/features/beauty-shaping/README.md"),
    Path("docs/meitu-function-blueprint/features/beauty-shaping/lips/README.md"),
)


class CheckError(Exception):
    pass


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError:
        raise CheckError(f"required file unreadable:{path.name}") from None


def git_lines(*args: str) -> list[str]:
    result = subprocess.run(
        ["git", *args],
        check=False,
        capture_output=True,
        text=True,
        timeout=20,
    )
    if result.returncode != 0:
        raise CheckError("git subprocess failed")
    return [line for line in result.stdout.splitlines() if line]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise CheckError(message)


def validate_renderer_source(source: str, final_ready: bool) -> None:
    require(source.count("engine.processResult(") == 1, "renderer must keep one public facade call")
    require("import BeautySDK" in source, "renderer must import public facade")
    for forbidden in ("import BeautyCore", "import BeautyDetection", "import BeautyEffects", "@_spi(Testing)"):
        require(forbidden not in source, "renderer internal or Testing bypass")
    if final_ready:
        ids = re.findall(r'\bid\s*:\s*"([^"]+)"', source)
        require(len(ids) == 73 and len(set(ids)) == 73, "renderer inventory not exact 73")
        require(ids.count("teethWhitening_1p00") == 1, "exact teeth case missing")
        require(ids.count("geometryBaseline_noop") == 1, "exact baseline case missing")
        require("BeautyParameters(teethWhitening: 1)" in source, "teeth case not direct public intent")
        require("--no-watermark" in source, "presentation-free strict mode missing")


def renderer_checks(final_ready: bool) -> int:
    source = read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift"))
    validate_renderer_source(source, final_ready)
    return 7


def validate_parser_artifacts(helper: str, evidence: str | None) -> None:
    required = (
        "O_NOFOLLOW", "MAX_FILE_BYTES", "MAX_DECODED_BYTES", "EXPECTED_NAMES",
        "alpha_changed", "changed_outside", "mean_yellow_after", "--self-test",
    )
    require(all(token in helper for token in required), "strict helper boundary incomplete")
    if evidence is not None:
        require("6/6" in evidence and "public-facade" in evidence.lower(), "output evidence incomplete")


def parser_checks(final_ready: bool) -> int:
    helper = read(PHASE_DIR / "check_teeth_renderer_outputs.py")
    evidence = read(PHASE_DIR / "61-TEETH-OUTPUT-EVIDENCE.md") if final_ready else None
    validate_parser_artifacts(helper, evidence)
    required_count = 8
    return required_count + int(final_ready)


def validate_adversarial_source(source: str) -> None:
    for token in (
        "colorIndependent", "recoloredProtected", "lip", "tongue", "gum",
        "brace", "facialHair", "skin", "apertureExterior", "XCTAssertEqual",
    ):
        require(token in source, "adversarial protected family incomplete")


def adversarial_checks(final_ready: bool) -> int:
    test_path = Path("BeautySDK/Tests/BeautyEffectsTests/BeautyTeethWhiteningAdversarialCloseoutTests.swift")
    if not test_path.exists():
        require(not final_ready, "adversarial test owner missing")
        return 1
    source = read(test_path)
    validate_adversarial_source(source)
    return 10


def validate_final_output_sources(provider: str, transform: str, engine: str) -> None:
    for token in ("constrainToHardEnvelope", "droppedFixedStrongPixelCount == 0", "hardEnvelope"):
        require(token in provider, "provider containment drift")
    for token in ("maximumEffectiveStrength: Float = 0.62", "yellowNeutralizationFactor: Float = 1.45"):
        require(token in transform, "transform calibration drift")
    require(engine.count("BeautyTeethWhiteningProvider.makeResult(") == 1, "production provider route not exact")


def final_output_checks(final_ready: bool) -> int:
    provider = read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningProvider.swift"))
    transform = read(Path("BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningTransform.swift"))
    engine = read(Path("BeautySDK/Sources/BeautySDK/BeautyEngine.swift"))
    validate_final_output_sources(provider, transform, engine)
    return 6


def validate_review(review: str) -> None:
    for token in (
        "original_detail", "positive", "negative", "tooth_locality", "texture",
        "shading", "edges", "natural_color", "decision: pass",
    ):
        require(token in review, "review categories incomplete")
    require("/Users/" not in review and "example-images/" not in review, "review contains locator")


def review_checks(final_ready: bool) -> int:
    review_path = PHASE_DIR / "61-REVIEW.md"
    if not review_path.exists():
        require(not final_ready, "review missing")
        return 1
    review = read(review_path)
    validate_review(review)
    return 10


def validate_privacy(names: list[str], phase_text: str) -> None:
    for name in names:
        require("local-retouch-review/" not in name, "generated/private media tracked or staged")
    for forbidden in ("/Users/", "/Downloads/", "reviewer_email", "rights_holder", "sha256:"):
        require(forbidden not in phase_text, "tracked phase evidence contains private locator/detail")


def privacy_checks() -> int:
    tracked = git_lines("ls-files")
    staged = git_lines("diff", "--cached", "--name-only")
    phase_text = "\n".join(read(path) for path in PHASE_DIR.glob("61-*.md"))
    validate_privacy(tracked + staged, phase_text)
    return 5


def validate_product_state(
    ledger: str,
    matrix: str,
    shaping: str,
    lips: str,
    allow_promotion: bool,
) -> None:
    white_line = next((line for line in ledger.splitlines() if "| `嘴唇` | 白牙 |" in line), "")
    require(white_line, "white-teeth ledger row missing")
    if allow_promotion:
        require("| implemented |" in white_line, "white-teeth row not promoted")
        for content in (matrix, shaping, lips):
            require("嘴唇" in content or "Branch status" in content, "mouth owner missing")
        require("| Beauty shaping | 嘴唇 | implemented |" in matrix, "mouth matrix not implemented")
        require("| `嘴唇` | implemented |" in shaping, "mouth branch not implemented")
    else:
        require("| future |" in white_line, "white-teeth promoted before gate")
        require("| Beauty shaping | 嘴唇 | partial |" in matrix, "mouth matrix changed before gate")
        require("| `嘴唇` | partial |" in shaping, "mouth branch changed before gate")
        require("Branch status remains `partial`" in lips, "lips detail changed before gate")
    for exact in (
        "| `眼睛` | 去脂 | future |",
        "| `眼睛` | 祛红血丝 | future |",
    ):
        require(exact in ledger, "deferred eye row changed")
    require("| Beauty shaping | 眼睛 | partial |" in matrix, "eye branch no longer partial")


def product_checks(allow_promotion: bool) -> int:
    ledger = read(PRODUCT_FILES[0])
    matrix = read(PRODUCT_FILES[1])
    shaping = read(PRODUCT_FILES[2])
    lips = read(PRODUCT_FILES[3])
    validate_product_state(ledger, matrix, shaping, lips, allow_promotion)
    return 8


def validate_lifecycle_inventory(plan_texts: list[str], inventory: dict[str, object]) -> None:
    tasks = re.findall(r'<task id="([^"]+)"', "\n".join(plan_texts))
    require(tuple(tasks) == EXPECTED_TASKS, "task inventory mismatch")
    threats = inventory.get("threats", [])
    require(isinstance(threats, list), "threat inventory shape mismatch")
    require(tuple(item.get("id") for item in threats if isinstance(item, dict)) == THREATS, "threat inventory mismatch")
    require(
        len(threats) == len(THREATS)
        and all(isinstance(item, dict) and item.get("severity") == "HIGH" for item in threats),
        "non-HIGH threat disposition",
    )


def lifecycle_checks(allow_promotion: bool, final_ready: bool) -> int:
    plans = sorted(PHASE_DIR.glob("61-??-PLAN.md"))
    require(len(plans) == 4, "plan inventory mismatch")
    plan_texts = [read(path) for path in plans]
    inventory = json.loads(read(PHASE_DIR / "61-THREAT-INVENTORY.json"))
    require(isinstance(inventory, dict), "threat inventory shape mismatch")
    validate_lifecycle_inventory(plan_texts, inventory)
    if allow_promotion:
        require(all((PHASE_DIR / f"61-{plan:02d}-SUMMARY.md").exists() for plan in range(1, 4)), "promotion lacks prerequisite summaries")
        security = read(PHASE_DIR / "61-SECURITY.md")
        require("threats_open: 0" in security, "security not final")
    if (PHASE_DIR / "61-VERIFICATION.md").exists():
        verification = read(PHASE_DIR / "61-VERIFICATION.md")
        require("status: passed" in verification and "borrowed" in verification.lower(), "verification not canonical")
    return 6 + int(allow_promotion) * 2 + int(final_ready)


CHECKS = {
    "T-61-01": renderer_checks,
    "T-61-02": parser_checks,
    "T-61-03": adversarial_checks,
    "T-61-04": final_output_checks,
    "T-61-05": review_checks,
    "T-61-06": lambda _final: privacy_checks(),
    "T-61-07": None,
    "T-61-08": None,
}


def final_ready() -> bool:
    return (PHASE_DIR / "61-TEETH-OUTPUT-EVIDENCE.md").exists()


def run_live(allow_promotion: bool, selected: str | None) -> int:
    ready = final_ready()
    counts: dict[str, int] = {}
    targets = (selected,) if selected else THREATS
    for threat in targets:
        if threat == "T-61-07":
            counts[threat] = product_checks(allow_promotion)
        elif threat == "T-61-08":
            counts[threat] = lifecycle_checks(allow_promotion, ready)
        else:
            check = CHECKS[threat]
            assert check is not None
            counts[threat] = check(ready)
    print(json.dumps({"status": "pass", "mode": "post" if allow_promotion else "pre", "checks": counts}, separators=(",", ":")))
    return sum(counts.values())


def run_self_test() -> int:
    renderer = (
        "import BeautySDK\n"
        + "\n".join(f'id: "case_{index}"' for index in range(71))
        + '\nid: "geometryBaseline_noop"\nid: "teethWhitening_1p00"\n'
        + "BeautyParameters(teethWhitening: 1)\n--no-watermark\nengine.processResult("
    )
    helper = " ".join((
        "O_NOFOLLOW", "MAX_FILE_BYTES", "MAX_DECODED_BYTES", "EXPECTED_NAMES",
        "alpha_changed", "changed_outside", "mean_yellow_after", "--self-test",
    ))
    adversarial = "colorIndependent recoloredProtected lip tongue gum brace facialHair skin apertureExterior XCTAssertEqual"
    provider = "constrainToHardEnvelope droppedFixedStrongPixelCount == 0 hardEnvelope"
    transform = "maximumEffectiveStrength: Float = 0.62 yellowNeutralizationFactor: Float = 1.45"
    engine = "BeautyTeethWhiteningProvider.makeResult("
    review = "original_detail positive negative tooth_locality texture shading edges natural_color decision: pass"
    ledger = "\n".join((
        "| `嘴唇` | 白牙 | future |",
        "| `眼睛` | 去脂 | future |",
        "| `眼睛` | 祛红血丝 | future |",
    ))
    matrix = "| Beauty shaping | 嘴唇 | partial |\n| Beauty shaping | 眼睛 | partial |"
    shaping = "| `嘴唇` | partial |"
    lips = "Branch status remains `partial`"
    plan_texts = [
        "\n".join(f'<task id="61-{plan:02d}-{task:02d}"' for task in range(1, 3))
        for plan in range(1, 5)
    ]
    inventory: dict[str, object] = {
        "threats": [{"id": threat, "severity": "HIGH"} for threat in THREATS]
    }
    cases = (
        (
            "T-61-01",
            lambda: validate_renderer_source(renderer, True),
            lambda: validate_renderer_source(renderer + "\n@_spi(Testing)", True),
        ),
        (
            "T-61-02",
            lambda: validate_parser_artifacts(helper, "6/6 public-facade"),
            lambda: validate_parser_artifacts(helper.replace("O_NOFOLLOW", ""), "6/6 public-facade"),
        ),
        (
            "T-61-03",
            lambda: validate_adversarial_source(adversarial),
            lambda: validate_adversarial_source(adversarial.replace("apertureExterior", "")),
        ),
        (
            "T-61-04",
            lambda: validate_final_output_sources(provider, transform, engine),
            lambda: validate_final_output_sources(provider.replace("hardEnvelope", ""), transform, engine),
        ),
        (
            "T-61-05",
            lambda: validate_review(review),
            lambda: validate_review(review.replace("decision: pass", "decision: waive")),
        ),
        (
            "T-61-06",
            lambda: validate_privacy([], "aggregate_only no_locator no_media no_geometry"),
            lambda: validate_privacy([], "aggregate_only /Users/private/input.png"),
        ),
        (
            "T-61-07",
            lambda: validate_product_state(ledger, matrix, shaping, lips, False),
            lambda: validate_product_state(
                ledger.replace("| `嘴唇` | 白牙 | future |", "| `嘴唇` | 白牙 | implemented |"),
                matrix,
                shaping,
                lips,
                False,
            ),
        ),
        (
            "T-61-08",
            lambda: validate_lifecycle_inventory(plan_texts, inventory),
            lambda: validate_lifecycle_inventory(list(reversed(plan_texts)), inventory),
        ),
    )
    passed = 0
    for threat, valid_probe, mutated_probe in cases:
        valid_probe()
        try:
            mutated_probe()
        except CheckError:
            passed += 1
        else:
            raise CheckError(f"{threat} mutation was accepted")
    print(json.dumps({"status": "pass", "self_tests": passed, "threats": len(THREATS)}, separators=(",", ":")))
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--allow-promotion", action="store_true")
    parser.add_argument("--threat", choices=THREATS)
    args = parser.parse_args()
    try:
        if args.self_test:
            run_self_test()
        else:
            run_live(args.allow_promotion, args.threat)
        return 0
    except (CheckError, json.JSONDecodeError, subprocess.SubprocessError, AssertionError) as error:
        print(f"phase61_closeout_failed:{type(error).__name__}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
