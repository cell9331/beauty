#!/usr/bin/env python3
"""Fail-closed Phase 65 combined, privacy, scope, and lifecycle checker."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path


PHASE_DIR = Path(".planning/phases/65-combined-facade-privacy-and-milestone-closeout")
THREATS = tuple(f"T-65-{index:02d}" for index in range(1, 9))
MILESTONE_AUDIT = Path(".planning/milestones/v1.15-MILESTONE-AUDIT.md")
TEXT_SUFFIXES = {".swift", ".metal", ".json", ".plist"}
EXPECTED_SHIPPED_RESOURCES = {
    "BeautySDK/Sources/BeautyRender/Shaders/Warp.metal",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/clear.json",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/id-photo-natural.json",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/male-natural.json",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/natural.json",
    "BeautySDK/Sources/BeautyResources/Resources/Presets/refined.json",
    "BeautySDK/Sources/BeautyResources/Resources/manifest.json",
}
EYELID_IDENTITIES = (
    "upperEyelidFullness", "upperLidFullness", "eyelidFullness", "lidFullness",
    "upperEyelidFullnessReduction", "upperLidFullnessReduction",
    "eyelidFullnessReduction", "lidFullnessReduction",
    "upperEyelidFullnessRemoval", "upperLidFullnessRemoval",
    "eyelidFullnessRemoval", "lidFullnessRemoval",
    "upperEyelidFat", "upperLidFat", "eyelidFat", "lidFat",
    "upperEyelidFatReduction", "upperLidFatReduction", "eyelidFatReduction",
    "lidFatReduction", "upperEyelidFatRemoval", "upperLidFatRemoval",
    "eyelidFatRemoval", "lidFatRemoval", "removeUpperEyelidFat",
    "removeEyelidFat", "removeUpperLidFat", "removeLidFat",
    "upperEyelidDefatting", "upperLidDefatting", "eyelidDefatting", "lidDefatting",
    "defatUpperEyelid", "defatEyelid", "defatUpperLid", "defatLid",
    "upper_eyelid_fullness", "upper_lid_fullness", "eyelid_fullness",
    "lid_fullness", "upper_eyelid_fullness_reduction",
    "upper_lid_fullness_reduction", "eyelid_fullness_reduction",
    "lid_fullness_reduction", "upper_eyelid_fullness_removal",
    "upper_lid_fullness_removal", "eyelid_fullness_removal",
    "lid_fullness_removal", "upper_eyelid_fat", "upper_lid_fat", "eyelid_fat",
    "lid_fat", "upper_eyelid_fat_reduction", "upper_lid_fat_reduction",
    "eyelid_fat_reduction", "lid_fat_reduction", "upper_eyelid_fat_removal",
    "upper_lid_fat_removal", "eyelid_fat_removal", "lid_fat_removal",
    "remove_upper_eyelid_fat", "remove_eyelid_fat", "remove_upper_lid_fat",
    "remove_lid_fat", "upper_eyelid_defatting", "upper_lid_defatting",
    "eyelid_defatting", "lid_defatting", "defat_upper_eyelid", "defat_eyelid",
    "defat_upper_lid", "defat_lid", "eyes.fat", "去脂",
)


class CheckError(Exception):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise CheckError(message)


def read(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise CheckError("required owner unavailable") from error


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


def production_inventory() -> tuple[str, set[str]]:
    files = [Path("BeautySDK/Package.swift")]
    for root in (Path("BeautySDK/Sources"), Path("BeautyDemo/BeautyDemo")):
        try:
            files.extend(
                path for path in root.rglob("*")
                if path.is_file() and not any(part.startswith(".") for part in path.parts)
            )
        except OSError as error:
            raise CheckError("production inventory unavailable") from error
    resource_names = {
        path.as_posix()
        for path in files
        if "/Resources/" in path.as_posix() or "/Shaders/" in path.as_posix()
    }
    text_parts = []
    for path in sorted(set(files)):
        if path.suffix.lower() in TEXT_SUFFIXES or path.name == "Package.swift":
            value = read(path)
            if path == Path("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift"):
                value = value.replace(
                    'unsupported("eyes.fat", title: "去脂", icon: "minus.circle", badge: .free)',
                    "",
                    1,
                )
            text_parts.append(value)
    return "\n".join(text_parts), resource_names


def validate_independent_authority(text: str) -> None:
    for token in (
        "teethWhitening",
        "scleraRednessReduction",
        "BeautyTeethWhiteningProvider.makeResult(",
        "BeautyScleraRednessProvider.makeResult(",
        "hasDirectTeethIntent",
        "hasDirectScleraIntent",
    ):
        require(token in text, "independent authority incomplete")
    require(text.count("BeautyTeethWhiteningProvider.makeResult(") == 1, "teeth provider route not exact")
    require(text.count("BeautyScleraRednessProvider.makeResult(") == 1, "sclera provider route not exact")


def authority_checks() -> int:
    validate_independent_authority(read(Path("BeautySDK/Sources/BeautySDK/BeautyEngine.swift")))
    for path in (
        Path(".planning/phases/61-teeth-output-safety-and-independent-closeout/61-VERIFICATION.md"),
        Path(".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-VERIFICATION.md"),
    ):
        require("status: passed" in read(path), "standalone verification unavailable")
    return 8


def validate_combined_test(text: str, final_ready: bool) -> None:
    for token in (
        "process, .processResult",
        "BeautyParameters(teethWhitening: 1)",
        "BeautyParameters(scleraRednessReduction: 1)",
        "teethWhitening: 1,",
        "scleraRednessReduction: 1",
        "independentMerge",
        "collisionPixelCount",
        "combinedBytes, oracle.bytes",
        "compositionInvocationCount, 1",
        "usedExplicitSRGBRender",
    ):
        require(token in text, "combined byte oracle incomplete")
    if final_ready:
        require("phase65_missing_" not in text and "XCTFail(" not in text, "combined RED sentinel remains")


def combined_checks(final_ready: bool) -> int:
    validate_combined_test(
        read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift")),
        final_ready,
    )
    composition = read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift"))
    require("testCollisionPreservesSourcePixelAndCountsOnce" in composition, "retained collision oracle missing")
    return 11


def validate_failure_matrix(text: str) -> None:
    for token in (
        "InjectedTeethFailure",
        "InjectedWholeScleraFailure",
        "InjectedLeftAndRightEyeFailures",
        "ValidInvalidValid",
        "ThrownCombinedRequest",
        "ParallelCombinedRequests",
        "ResetAndPixelBuffer",
        "CombinedNoFaceAbstains",
        "EarlyInvalidCombinedRequest",
        "retainedRequestOwnerCount",
        "retainedMappedCoordinateCount",
    ):
        require(token in text, "failure/lifecycle matrix incomplete")


def failure_checks() -> int:
    validate_failure_matrix(
        read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift"))
    )
    foundation = read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchFoundationTests.swift"))
    require("canceledOutcome" in foundation and ".discarded" in foundation, "cancellation publication contract missing")
    return 10


def validate_inventory(parameters: str, renderer: str, demo: str, preset_count: int) -> None:
    fields = re.findall(r"^    public var [A-Za-z][A-Za-z0-9]*:", parameters, re.MULTILINE)
    require(len(fields) == 61, "public field inventory mismatch")
    ids = re.findall(r'\bid\s*:\s*"([^"]+)"', renderer)
    require(len(ids) == 74 and len(set(ids)) == 74, "renderer inventory mismatch")
    require(ids.count("teethWhitening_1p00") == 1, "teeth renderer case mismatch")
    require(ids.count("scleraRednessReduction_1p00") == 1, "sclera renderer case mismatch")
    require(preset_count == 5, "preset inventory mismatch")
    for row in (
        'unsupported("lips.teeth", title: "白牙"',
        'unsupported("eyes.fat", title: "去脂"',
        'unsupported("eyes.redness", title: "祛红血丝"',
    ):
        require(demo.count(row) == 1, "disabled Demo inventory mismatch")


def inventory_checks() -> int:
    validate_inventory(
        read(Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")),
        read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")),
        read(Path("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift")),
        len(list(Path("BeautySDK/Sources/BeautyResources/Resources/Presets").glob("*.json"))),
    )
    admission = read(Path("BeautySDK/Tests/BeautyEffectsTests/BeautyEffectResolverTests.swift"))
    for token in (
        "testPhase62DirectLocalRetouchIntentsHaveExactIndependentCardinality",
        '("none", BeautyParameters(), 0)',
        '("teeth", BeautyParameters(teethWhitening: 0.5), 1)',
        '("sclera", BeautyParameters(scleraRednessReduction: 0.5), 1)',
        'BeautyParameters(teethWhitening: 0.5, scleraRednessReduction: 0.5)',
    ):
        require(token in admission, "admission compatibility mismatch")
    return 10


def observation_fields(text: str, struct_name: str) -> tuple[str, ...]:
    match = re.search(
        rf"public struct {re.escape(struct_name)}:[^{{]+\{{(.*?)\n\}}",
        text,
        re.DOTALL,
    )
    require(match is not None, "aggregate observation missing")
    return tuple(re.findall(r"^    public let ([A-Za-z][A-Za-z0-9]*):", match.group(1), re.MULTILINE))


def validate_privacy(
    names: list[str],
    phase_text: str,
    combined_test: str,
    testing_support: str,
) -> None:
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
        require(forbidden not in phase_text, "tracked closeout contains private detail")
    require("CombinedObservationsExposeFixedAggregatesOnly" in combined_test, "aggregate privacy test missing")
    for token in ("coordinate", "pupil", "mask", "candidatecolor", "owneridentity"):
        require(f'"{token}"' in combined_test, "sensitive diagnostic guard incomplete")
    expected_fields = {
        "SDKTestingLocalCompositionObservation": (
            "width", "height", "compositionInvocationCount", "sourceBindingMatched",
            "acceptedUnitCount", "rejectedUnitCount", "ownedPixelCount",
            "changedPixelCount", "changedOutsideUnionPixelCount", "collisionPixelCount",
        ),
        "SDKTestingTeethProviderObservation": (
            "invocationCount", "issuedUnitCount", "abstentionCount",
            "fixedStrongPixelCount", "finalStrongPixelCount", "droppedFixedStrongPixelCount",
        ),
        "SDKTestingScleraProviderObservation": (
            "invocationCount", "issuedUnitCount", "acceptedLeftEyeCount",
            "acceptedRightEyeCount", "abstentionCount",
        ),
    }
    for struct_name, fields in expected_fields.items():
        require(observation_fields(testing_support, struct_name) == fields, "diagnostic field allowlist drift")
        declaration = re.search(rf"public struct {struct_name}: ([^{{]+)", testing_support)
        require(declaration is not None, "diagnostic declaration missing")
        for forbidden_protocol in ("Codable", "Encodable", "Decodable", "CustomStringConvertible"):
            require(forbidden_protocol not in declaration.group(1), "diagnostic serialization surface added")


def privacy_checks() -> int:
    phase_text = "\n".join(read(path) for path in PHASE_DIR.glob("65-*.md"))
    validate_privacy(
        git_names("ls-files") + git_names("diff", "--cached", "--name-only"),
        phase_text,
        read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift")),
        read(Path("BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift")),
    )
    return 8


def validate_deferred_scope(
    parameters: str,
    renderer: str,
    demo: str,
    production_text: str,
    resource_names: set[str],
) -> None:
    require(len(EYELID_IDENTITIES) == 74 and len(set(EYELID_IDENTITIES)) == 74, "去脂 identity inventory drift")
    for forbidden in EYELID_IDENTITIES:
        pattern = re.compile(rf"(?<![A-Za-z0-9_]){re.escape(forbidden)}(?![A-Za-z0-9_])", re.IGNORECASE)
        require(pattern.search(production_text) is None, "去脂 proxy surface added")
    require('unsupported("eyes.fat", title: "去脂"' in demo, "去脂 Demo row activated")
    require('unsupported("eyes.redness", title: "祛红血丝"' in demo, "sclera Demo row activated")
    require('unsupported("lips.teeth", title: "白牙"' in demo, "teeth Demo row activated")
    for retained_proxy in ("eyeHeight", "upperEyelidLift"):
        require(retained_proxy in production_text, "legitimate proxy domain removed")
    for forbidden in (
        "URLSession", "http://", "https://", "import CoreML", "MLModel",
        "VNCoreML", ".mlmodel", ".mlpackage",
    ):
        require(forbidden not in production_text, "network/model surface added")
        require(all(forbidden.lower() not in name.lower() for name in resource_names), "model resource added")
    require(resource_names == EXPECTED_SHIPPED_RESOURCES, "shipped resource inventory mismatch")


def deferred_checks() -> int:
    production_text, resource_names = production_inventory()
    validate_deferred_scope(
        read(Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")),
        read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")),
        read(Path("BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift")),
        production_text,
        resource_names,
    )
    return 9


def validate_owner_state(ledger: str, matrix: str, requirements: str) -> None:
    require("| `眼睛` | 去脂 | future |" in ledger, "去脂 owner drift")
    require("| `眼睛` | 祛红血丝 | implemented |" in ledger, "sclera owner drift")
    require("| `嘴唇` | 白牙 | implemented |" in ledger, "teeth owner drift")
    require("| Beauty shaping | 眼睛 | partial |" in matrix, "eye branch drift")
    require("| Beauty shaping | 嘴唇 | implemented |" in matrix, "mouth branch drift")
    trace_rows = re.findall(r"^\| (?:SEQ|EVID|TEETH|SCLERA|SAFE|OUT)-\d+ \| Phase \d+ \|", requirements, re.MULTILINE)
    require(len(trace_rows) == 40 and len(set(trace_rows)) == 40, "requirement traceability mismatch")


def owner_checks() -> int:
    validate_owner_state(
        read(Path("docs/meitu-function-blueprint/SHAPE_FEATURE_LEDGER.md")),
        read(Path("docs/meitu-function-blueprint/FEATURE_MATRIX.md")),
        read(Path(".planning/REQUIREMENTS.md")),
    )
    return 8


def validate_lifecycle_inventory(inventory: object) -> None:
    require(isinstance(inventory, dict), "threat inventory malformed")
    threats = inventory.get("threats", [])
    require(isinstance(threats, list), "threat inventory malformed")
    require(
        [item.get("id") for item in threats if isinstance(item, dict)] == list(THREATS),
        "threat inventory mismatch",
    )
    require(
        all(isinstance(item, dict) and item.get("severity") == "HIGH" for item in threats),
        "non-HIGH disposition",
    )


def lifecycle_checks(mode: str) -> int:
    plans = sorted(PHASE_DIR.glob("65-??-PLAN.md"))
    require(len(plans) == 4, "plan inventory mismatch")
    tasks = re.findall(r'<task id="([^"]+)"', "\n".join(read(path) for path in plans))
    require(tasks == [f"65-{plan:02d}-{task:02d}" for plan in range(1, 5) for task in range(1, 3)], "task inventory mismatch")
    inventory = json.loads(read(PHASE_DIR / "65-THREAT-INVENTORY.json"))
    validate_lifecycle_inventory(inventory)
    if mode in ("close", "final"):
        verification = read(PHASE_DIR / "65-VERIFICATION.md")
        require("status: passed" in verification and "40/40" in verification, "phase verification not canonical")
        security = read(PHASE_DIR / "65-SECURITY.md")
        require("threats_open: 0" in security, "security not closed")
    if mode == "final":
        audit = read(MILESTONE_AUDIT)
        require("status: passed" in audit and "40/40" in audit, "milestone audit not passed")
    return 8 + int(mode in ("close", "final")) * 2 + int(mode == "final")


def run_self_test() -> int:
    probes = []

    def probe(good_call, bad_call) -> None:
        good_call()
        try:
            bad_call()
        except CheckError:
            probes.append(True)
        else:
            raise CheckError("mutation accepted")

    engine = " ".join((
        "teethWhitening scleraRednessReduction hasDirectTeethIntent hasDirectScleraIntent",
        "BeautyTeethWhiteningProvider.makeResult( BeautyScleraRednessProvider.makeResult(",
    ))
    probe(lambda: validate_independent_authority(engine), lambda: validate_independent_authority(engine.replace("hasDirectScleraIntent", "missing")))

    combined = " ".join((
        "process, .processResult BeautyParameters(teethWhitening: 1)",
        "BeautyParameters(scleraRednessReduction: 1) teethWhitening: 1, scleraRednessReduction: 1",
        "independentMerge collisionPixelCount combinedBytes, oracle.bytes compositionInvocationCount, 1 usedExplicitSRGBRender",
    ))
    probe(lambda: validate_combined_test(combined, False), lambda: validate_combined_test(combined.replace("independentMerge", "missing"), False))

    failures = "InjectedTeethFailure InjectedWholeScleraFailure InjectedLeftAndRightEyeFailures ValidInvalidValid ThrownCombinedRequest ParallelCombinedRequests ResetAndPixelBuffer CombinedNoFaceAbstains EarlyInvalidCombinedRequest retainedRequestOwnerCount retainedMappedCoordinateCount"
    probe(lambda: validate_failure_matrix(failures), lambda: validate_failure_matrix(failures.replace("ThrownCombinedRequest", "missing")))

    parameters = "\n".join(f"    public var field{index}: Float" for index in range(61))
    renderer = "\n".join([f'id: "case{index}"' for index in range(72)] + ['id: "teethWhitening_1p00"', 'id: "scleraRednessReduction_1p00"'])
    demo = '\n'.join(('unsupported("lips.teeth", title: "白牙"', 'unsupported("eyes.fat", title: "去脂"', 'unsupported("eyes.redness", title: "祛红血丝"'))
    probe(lambda: validate_inventory(parameters, renderer, demo, 5), lambda: validate_inventory(parameters, renderer, demo, 4))

    private_test = 'CombinedObservationsExposeFixedAggregatesOnly "coordinate" "pupil" "mask" "candidatecolor" "owneridentity"'
    testing_support = "\n".join((
        "@_spi(Testing) public struct SDKTestingLocalCompositionObservation: Equatable, Sendable {",
        *[f"    public let {field}: Int" for field in (
            "width", "height", "compositionInvocationCount", "sourceBindingMatched",
            "acceptedUnitCount", "rejectedUnitCount", "ownedPixelCount",
            "changedPixelCount", "changedOutsideUnionPixelCount", "collisionPixelCount",
        )],
        "}",
        "@_spi(Testing) public struct SDKTestingTeethProviderObservation: Equatable, Sendable {",
        *[f"    public let {field}: Int" for field in (
            "invocationCount", "issuedUnitCount", "abstentionCount", "fixedStrongPixelCount",
            "finalStrongPixelCount", "droppedFixedStrongPixelCount",
        )],
        "}",
        "@_spi(Testing) public struct SDKTestingScleraProviderObservation: Equatable, Sendable {",
        *[f"    public let {field}: Int" for field in (
            "invocationCount", "issuedUnitCount", "acceptedLeftEyeCount",
            "acceptedRightEyeCount", "abstentionCount",
        )],
        "}",
    ))
    probe(
        lambda: validate_privacy([], "clean", private_test, testing_support),
        lambda: validate_privacy([], "/Users/private", private_test, testing_support),
    )

    proxy_text = "eyeHeight upperEyelidLift"
    probe(
        lambda: validate_deferred_scope(
            parameters, renderer, demo, proxy_text, EXPECTED_SHIPPED_RESOURCES,
        ),
        lambda: validate_deferred_scope(
            parameters,
            renderer,
            demo,
            proxy_text + "\nupperEyelidFatReduction",
            EXPECTED_SHIPPED_RESOURCES,
        ),
    )

    ledger = "| `眼睛` | 去脂 | future |\n| `眼睛` | 祛红血丝 | implemented |\n| `嘴唇` | 白牙 | implemented |"
    matrix = "| Beauty shaping | 眼睛 | partial |\n| Beauty shaping | 嘴唇 | implemented |"
    requirements = "\n".join(f"| SEQ-{index + 1:02d} | Phase 65 | Pending |" for index in range(40))
    probe(lambda: validate_owner_state(ledger, matrix, requirements), lambda: validate_owner_state(ledger.replace("白牙 | implemented", "白牙 | future"), matrix, requirements))

    good_inventory = {"threats": [{"id": item, "severity": "HIGH"} for item in THREATS]}
    bad_inventory = {"threats": good_inventory["threats"][:-1]}
    probe(
        lambda: validate_lifecycle_inventory(good_inventory),
        lambda: validate_lifecycle_inventory(bad_inventory),
    )

    require(len(probes) == 8 and all(probes), "self-test denominator mismatch")
    print(json.dumps({"status": "pass", "self_tests": 8, "threats": 8}, separators=(",", ":")))
    return 8


def run_live(mode: str, selected: str | None) -> int:
    final_ready = (PHASE_DIR / "65-CLOSEOUT-EVIDENCE.md").exists()
    checks = {
        "T-65-01": lambda: authority_checks(),
        "T-65-02": lambda: combined_checks(final_ready),
        "T-65-03": lambda: failure_checks(),
        "T-65-04": lambda: inventory_checks(),
        "T-65-05": lambda: privacy_checks(),
        "T-65-06": lambda: deferred_checks(),
        "T-65-07": lambda: owner_checks(),
        "T-65-08": lambda: lifecycle_checks(mode),
    }
    counts = {}
    for threat in ((selected,) if selected else THREATS):
        counts[threat] = checks[threat]()
    print(json.dumps({"status": "pass", "mode": mode, "checks": counts}, separators=(",", ":")))
    return sum(counts.values())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--live", action="store_true")
    parser.add_argument("--close-phase", action="store_true")
    parser.add_argument("--final", action="store_true")
    parser.add_argument("--threat", choices=THREATS)
    args = parser.parse_args()
    try:
        if args.self_test:
            run_self_test()
        else:
            mode = "final" if args.final else "close" if args.close_phase else "live"
            run_live(mode, args.threat)
        return 0
    except (CheckError, json.JSONDecodeError, subprocess.TimeoutExpired, OSError, UnicodeError):
        print(json.dumps({"status": "fail", "reason": "phase65_gate_failed"}, separators=(",", ":")))
        return 1


if __name__ == "__main__":
    sys.exit(main())
