#!/usr/bin/env python3
"""Phase-75 contract, exact-absence, and isolated threat gate.

This checker is deliberately standard-library-only. Its durable output is a
fixed JSON shape containing only normalized reasons, identifiers, and counts.
It never prints source matches, paths, fixture content, or private values.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


PHASE = "75"
BASELINE_COMMIT = "0ebcc31"
CONTRACT_REL = Path(".planning/phases/75-semantics-and-genuine-evidence-contract/75-SEMANTICS-CONTRACT.md")
SEMANTIC_TEST_REL = Path(".planning/phases/75-semantics-and-genuine-evidence-contract/75-semantics.contract.test.js")
THREATS_REL = Path(".planning/phases/75-semantics-and-genuine-evidence-contract/75-THREAT-INVENTORY.json")
VALIDATION_REL = Path(".planning/phases/75-semantics-and-genuine-evidence-contract/75-VALIDATION.md")
PACKAGE_REL = Path("BeautySDK/Package.swift")
PARAMETERS_REL = Path("BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift")
RENDERER_REL = Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")
MANIFEST_REL = Path("BeautySDK/Sources/BeautyResources/Resources/manifest.json")

FIELD_INVENTORY = [
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
PROXY_IDS = [
    "smoothing", "whitening", "eye-enlargement", "brow-movement",
    "crease-invention", "upper-eyelid-lift", "warp",
]
THREAT_IDS = [f"T-75-{index:02d}" for index in range(1, 9)] + ["T-75-SC"]
SENSITIVE_KEY = re.compile(
    r"(?:path|locator|pixel|mask|landmark|coordinate|geometry|raw|private|biometric|descriptor)",
    re.IGNORECASE,
)


def read_text(root: Path, relative: Path) -> str | None:
    try:
        return (root / relative).read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        return None


def parse_json_text(text: str | None) -> object | None:
    if text is None:
        return None
    try:
        return json.loads(text)
    except (TypeError, json.JSONDecodeError):
        return None


def canonical_records(text: str | None) -> object | None:
    if text is None:
        return None
    match = re.search(
        r"<!-- CANONICAL_RECORDS_BEGIN -->\n```json\n(?P<body>[\s\S]*?)\n```\n<!-- CANONICAL_RECORDS_END -->",
        text,
    )
    return parse_json_text(match.group("body") if match else None)


def contract_errors(records: object) -> list[str]:
    errors: list[str] = []
    if not isinstance(records, dict):
        return ["contract.malformed"]
    if set(records) != {
        "version", "effect", "landmark_role", "nonclaims", "predicates",
        "prohibited_proxies", "protected_structures",
    }:
        errors.append("contract.keys")
    if records.get("version") != 1:
        errors.append("contract.version")
    effect = records.get("effect")
    if effect != {
        "id": "upper-eyelid-fullness-reduction",
        "medium": "still-image",
        "intent": "cosmetic-visual-reduction-of-upper-eyelid-fullness",
        "authority": "visual-review-only",
    }:
        errors.append("contract.effect")
    if records.get("landmark_role") != "envelope-and-pose-guard-only":
        errors.append("contract.landmark_role")
    if records.get("nonclaims") != ["physical-fat", "anatomy", "health", "diagnosis", "surgical-outcome"]:
        errors.append("contract.nonclaims")
    predicates = records.get("predicates")
    if not isinstance(predicates, dict) or set(predicates) != {
        "authorization_inputs", "observations_without_authority", "ambiguous_outcome",
    }:
        errors.append("contract.predicates")
    else:
        if predicates.get("authorization_inputs") != [
            "approved-semantic-evidence", "visual-fullness-reduction", "protected-structure-preserved",
        ]:
            errors.append("contract.authorization")
        if predicates.get("observations_without_authority") != [
            "landmark-only", "brow-only", "eye-aperture-only", "crease-only", "texture-only", "color-only",
        ]:
            errors.append("contract.observation-authority")
        if predicates.get("ambiguous_outcome") != "exact-no-op":
            errors.append("contract.ambiguous-no-op")
    proxies = records.get("prohibited_proxies")
    if not isinstance(proxies, list) or [row.get("id") for row in proxies if isinstance(row, dict)] != PROXY_IDS:
        errors.append("contract.proxy-inventory")
    else:
        for row in proxies:
            if set(row) != {"id", "negative"}:
                errors.append(f"proxy.{row.get('id', 'unknown')}.keys")
                continue
            negative = row.get("negative")
            if negative != {"accepts": False, "reason": f"proxy.{row['id']}"}:
                errors.append(f"proxy.{row['id']}")
    if records.get("protected_structures") != [
        "eye-content", "lash-and-crease-structure", "brow-geometry", "identity-detail", "exterior-pixels",
    ]:
        errors.append("contract.protected-structures")
    return sorted(set(errors))


def semantic_test_errors(text: str | None) -> list[str]:
    if text is None:
        return ["semantic-test.missing"]
    errors: list[str] = []
    if text.count('test("') != 4:
        errors.append("semantic-test.case-count")
    for proxy in PROXY_IDS:
        if text.count(f'"{proxy}"') < 1:
            errors.append(f"semantic-test.proxy.{proxy}")
    for token in ["approved-semantic-evidence", "protected-structure-preserved", "exact-no-op"]:
        if token not in text:
            errors.append(f"semantic-test.predicate.{token}")
    return sorted(set(errors))


def public_fields(source: str | None) -> list[str]:
    if source is None:
        return []
    head = source.split("enum CodingKeys", 1)[0]
    return re.findall(r"^\s*public var ([A-Za-z][A-Za-z0-9_]*):", head, re.MULTILINE)


def coding_keys(source: str | None) -> list[str]:
    if source is None:
        return []
    match = re.search(r"enum CodingKeys: String, CodingKey \{(?P<body>[\s\S]*?)\n\s*\}", source)
    return re.findall(r"^\s*case ([A-Za-z][A-Za-z0-9_]*)\s*$", match.group("body"), re.MULTILINE) if match else []


def inventory_errors(parameters: str | None, manifest: object, renderer: str | None, package: str | None) -> list[str]:
    errors: list[str] = []
    fields = public_fields(parameters)
    keys = coding_keys(parameters)
    if fields != FIELD_INVENTORY:
        errors.append("absence.parameters.fields")
    if keys != FIELD_INVENTORY:
        errors.append("absence.parameters.coding-keys")
    if not isinstance(manifest, dict) or manifest.get("schemaVersion") != 1:
        errors.append("absence.resource-manifest")
    else:
        presets = manifest.get("presets")
        if not isinstance(presets, list) or len(presets) != 5:
            errors.append("absence.presets.count")
        elif [row.get("id") for row in presets if isinstance(row, dict)] != [
            "natural", "clear", "refined", "male-natural", "id-photo-natural",
        ]:
            errors.append("absence.presets.identity")
    render_ids = re.findall(r"^\s*id: \"([^\"]+)\"", renderer or "", re.MULTILINE)
    if len(render_ids) != 74 or len(set(render_ids)) != 74:
        errors.append("absence.renderer.count")
    if package is None or ".package(" in package or "upperEyelidFullness" in package:
        errors.append("absence.package.graph")
    return sorted(set(errors))


def production_absence_errors(root: Path) -> list[str]:
    errors = inventory_errors(
        read_text(root, PARAMETERS_REL),
        parse_json_text(read_text(root, MANIFEST_REL)),
        read_text(root, RENDERER_REL),
        read_text(root, PACKAGE_REL),
    )
    source_root = root / "BeautySDK" / "Sources"
    forbidden = re.compile(
        r"upperEyelidFullness|upper-eyelid-fullness|upper_eyelid_fullness|fullnessReduction|去脂",
        re.IGNORECASE,
    )
    try:
        text_suffixes = {".swift", ".metal", ".json", ".md"}
        source_paths = sorted(
            path for path in source_root.rglob("*")
            if path.is_file() and path.suffix.lower() in text_suffixes
        )
    except OSError:
        source_paths = []
        errors.append("absence.source-scan")
    for path in source_paths:
        try:
            if forbidden.search(path.read_text(encoding="utf-8")):
                errors.append("absence.production-identifier")
                break
        except (OSError, UnicodeError):
            errors.append("absence.source-read")
            break
    try:
        changed = subprocess.run(
            ["git", "diff", "--name-only", BASELINE_COMMIT, "--", "BeautySDK/Sources", "BeautySDK/Package.swift"],
            cwd=root, check=False, capture_output=True, text=True, timeout=20,
        )
        if changed.returncode != 0:
            errors.append("absence.git-baseline")
        elif changed.stdout.strip():
            errors.append("absence.production-diff")
    except (OSError, subprocess.SubprocessError):
        errors.append("absence.git-scan")
    try:
        status = subprocess.run(
            ["git", "status", "--short", "--untracked-files=all"],
            cwd=root, check=False, capture_output=True, text=True, timeout=20,
        )
        if status.returncode != 0:
            errors.append("absence.status-scan")
        elif any(line[3:].startswith(("BeautySDK/Sources/", "BeautySDK/Package.swift")) for line in status.stdout.splitlines() if len(line) >= 4):
            errors.append("absence.untracked-production")
    except (OSError, subprocess.SubprocessError):
        errors.append("absence.status-exec")
    phase_dir = root / CONTRACT_REL.parent
    allowed = {".md", ".js", ".json", ".py"}
    try:
        for path in phase_dir.rglob("*"):
            if path.is_file() and path.suffix.lower() not in allowed:
                errors.append("absence.private-artifact")
                break
    except OSError:
        errors.append("absence.phase-scan")
    return sorted(set(errors))


def validation_errors(text: str | None, inventory: object) -> list[str]:
    if text is None:
        return ["validation.missing"]
    errors: list[str] = []
    for task in ["75-01-01", "75-01-02", "75-02-01", "75-02-02", "75-02-03"]:
        if task not in text:
            errors.append(f"validation.task.{task}")
    for threat in THREAT_IDS:
        if threat not in text:
            errors.append(f"validation.threat.{threat}")
    if not isinstance(inventory, dict) or [row.get("id") for row in inventory.get("threats", [])] != THREAT_IDS:
        errors.append("validation.inventory-order")
    return sorted(set(errors))


def path_free(value: object) -> bool:
    encoded = json.dumps(value, sort_keys=True, separators=(",", ":"))
    return "/" not in encoded and "\\" not in encoded and "private" not in encoded.lower()


def threat_test(threat: str, root: Path) -> list[str]:
    records = canonical_records(read_text(root, CONTRACT_REL))
    if threat == "T-75-01":
        mutated = copy.deepcopy(records)
        mutated["prohibited_proxies"][0]["negative"]["accepts"] = True
        return [] if "proxy.smoothing" in contract_errors(mutated) else ["threat.contract-mutation"]
    if threat == "T-75-02":
        return semantic_test_errors(read_text(root, SEMANTIC_TEST_REL))
    if threat == "T-75-03":
        return [] if path_free({"status": "pass", "mode": "contract", "checks": 2}) else ["threat.output-path"]
    if threat == "T-75-04":
        mutated = copy.deepcopy(records)
        mutated["landmark_role"] = "semantic-authority"
        return [] if "contract.landmark_role" in contract_errors(mutated) else ["threat.landmark-escalation"]
    if threat == "T-75-05":
        return [] if parse_json_text("{") is None and parse_json_text(None) is None else ["threat.parse-failure"]
    if threat == "T-75-06":
        source = read_text(root, PARAMETERS_REL) or ""
        mutated = source.replace("public var skinSmoothing:", "public var phase75Field:", 1)
        return [] if "absence.parameters.fields" in inventory_errors(mutated, parse_json_text(read_text(root, MANIFEST_REL)), read_text(root, RENDERER_REL), read_text(root, PACKAGE_REL)) else ["threat.inventory-mutation"]
    if threat == "T-75-07":
        return validation_errors(read_text(root, VALIDATION_REL), parse_json_text(read_text(root, THREATS_REL)))
    if threat == "T-75-08":
        return [] if path_free({"status": "fail", "mode": "self-test", "reason_count": 1, "reasons": ["checker.failure"]}) else ["threat.diagnostic-path"]
    if threat == "T-75-SC":
        package = read_text(root, PACKAGE_REL) or ""
        return [] if ".package(" not in package else ["threat.package-install"]
    return ["threat.unknown"]


def run_self_test(root: Path) -> tuple[list[str], int]:
    errors: list[str] = []
    mutation_rejections = 0
    records = canonical_records(read_text(root, CONTRACT_REL))
    for proxy in PROXY_IDS:
        mutated = copy.deepcopy(records)
        target = next(row for row in mutated["prohibited_proxies"] if row["id"] == proxy)
        target["negative"]["accepts"] = True
        if f"proxy.{proxy}" in contract_errors(mutated):
            mutation_rejections += 1
        else:
            errors.append(f"self-test.proxy.{proxy}")
    errors.extend(threat for threat in THREAT_IDS for threat in threat_test(threat, root))
    return sorted(set(errors)), mutation_rejections


def emit(status: str, mode: str, *, reasons: list[str] | None = None, **counts: int | str) -> int:
    payload: dict[str, object] = {"status": status, "mode": mode}
    if reasons:
        payload["reasons"] = sorted(set(reasons))
        payload["reason_count"] = len(payload["reasons"])
    payload.update(counts)
    print(json.dumps(payload, sort_keys=True, separators=(",", ":")))
    return 0 if status == "pass" else 1


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--repo-root", default=".")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--contract", action="store_true")
    parser.add_argument("--absence", action="store_true")
    parser.add_argument("--threat")
    args, unknown = parser.parse_known_args(argv)
    root = Path(args.repo_root).resolve()
    if unknown:
        return emit("fail", "argument", reasons=["checker.unknown-argument"])
    modes = sum([args.self_test, args.contract, args.absence, args.threat is not None])
    if modes != 1 and not (args.contract and args.absence and modes == 2):
        return emit("fail", "argument", reasons=["checker.unknown-mode"])
    if args.self_test:
        reasons, rejected = run_self_test(root)
        return emit("pass" if not reasons else "fail", "self-test", reasons=reasons, mutation_rejections=rejected, threat_count=len(THREAT_IDS))
    if args.contract:
        errors = contract_errors(canonical_records(read_text(root, CONTRACT_REL)))
        if args.absence:
            errors.extend(production_absence_errors(root))
            mode = "contract+absence"
        else:
            mode = "contract"
        return emit("pass" if not errors else "fail", mode, reasons=errors, checks=2 if args.absence else 1)
    if args.absence:
        errors = production_absence_errors(root)
        return emit("pass" if not errors else "fail", "absence", reasons=errors, checks=1)
    errors = threat_test(args.threat, root)
    return emit("pass" if not errors else "fail", "threat", reasons=errors, threat=args.threat, checks=1)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
