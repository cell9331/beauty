#!/usr/bin/env python3
"""Fail-closed Phase 65 combined, privacy, scope, and lifecycle checker."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path


PHASE_DIR = Path(".planning/phases/65-combined-facade-privacy-and-milestone-closeout")
THREATS = tuple(f"T-65-{index:02d}" for index in range(1, 9))
MILESTONE_AUDIT = Path(".planning/milestones/v1.15-MILESTONE-AUDIT.md")
PHASE64_VERIFICATION = Path(
    ".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-VERIFICATION.md"
)
PHASE65_REQUIREMENTS = (
    "SEQ-02", "SEQ-03", "SEQ-04", "SAFE-04", "SAFE-05", "SAFE-06",
    "SAFE-07", "OUT-06", "OUT-07", "OUT-08", "OUT-09",
)
ROOT_CONTRACT_PATHS = (
    Path("DESIGN.md"),
    Path("SECURITY.md"),
    Path("RELIABILITY.md"),
    Path("PRODUCT_SENSE.md"),
    Path("QUALITY_SCORE.md"),
)
ROOT_OWNER_NAMES = {
    "DESIGN.md": "DESIGN",
    "SECURITY.md": "SECURITY",
    "RELIABILITY.md": "RELIABILITY",
    "PRODUCT_SENSE.md": "PRODUCT_SENSE",
    "QUALITY_SCORE.md": "QUALITY_SCORE",
}
FINAL_OWNER_BEGIN = "<!-- PHASE65_FINAL_OWNER_BEGIN -->"
FINAL_OWNER_END = "<!-- PHASE65_FINAL_OWNER_END -->"
FINAL_OWNER_COMMON = {
    "phase": "65",
    "milestone": "v1.15",
    "public_fields": "61",
    "neutral_presets": "5",
    "renderer_cases": "74",
    "disabled_demo_rows": "3",
    "teeth": "implemented",
    "mouth": "implemented",
    "sclera_redness": "implemented",
    "eyes": "partial",
    "eye_fat": "future",
    "safe_06": "closed",
    "lifecycle": "completion-ready",
    "release": "non-release",
}
PUBLIC_SENSITIVE_ALLOWLIST = {
    ("BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift", name)
    for name in (
        "SDKTestingFaceDetectionFixture",
        "SDKTestingStillImageFacadeEntry",
        "SDKTestingScleraEyeSupport",
        "SDKTestingLocalSupportFixture",
        "SDKTestingLocalSupportSequence",
        "aggregateSupportValueID",
        "canonicalConsumerIdentityMatched",
        "lastMappedCoordinateCount",
        "retainedMappedCoordinateCount",
    )
}
REFLECTION_AGGREGATE_ALLOWLIST = {
    ("BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift", name)
    for name in (
        "BeautyObservedFaceSupport",
        "BeautyObservedEyebrowSupport",
        "BeautyObservedLipSupport",
        "BeautyFaceObservation",
    )
}
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


def parse_frontmatter(text: str) -> dict[str, str]:
    lines = text.splitlines()
    require(bool(lines) and lines[0].strip() == "---", "frontmatter missing")
    try:
        end = next(index for index, line in enumerate(lines[1:], 1) if line.strip() == "---")
    except StopIteration as error:
        raise CheckError("frontmatter malformed") from error
    fields: dict[str, str] = {}
    for line in lines[1:end]:
        if not line or line[0].isspace() or ":" not in line:
            continue
        key, value = line.split(":", 1)
        key = key.strip()
        require(bool(key) and key not in fields, "frontmatter field ambiguous")
        fields[key] = value.strip().strip('"\'')
    return fields


def markdown_body(text: str) -> str:
    lines = text.splitlines()
    require(bool(lines) and lines[0].strip() == "---", "frontmatter missing")
    try:
        end = next(index for index, line in enumerate(lines[1:], 1) if line.strip() == "---")
    except StopIteration as error:
        raise CheckError("frontmatter malformed") from error
    return "\n".join(lines[end + 1:]).strip()


def parse_timestamp(value: str) -> datetime:
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise CheckError("authority timestamp malformed") from error
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)


def text_sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def validate_phase64_authority(text: str) -> datetime:
    fields = parse_frontmatter(text)
    expected = {
        "verification_stage": "post_terminal_final",
        "status": "passed",
        "promotion_status": "promoted",
        "requires_requarantine": "false",
        "phase_65_authorized": "true",
    }
    for key, value in expected.items():
        require(fields.get(key) == value, "canonical predecessor authority mismatch")
    return parse_timestamp(fields.get("verified", ""))


def phase65_owner_section(text: str) -> str:
    matches = re.findall(
        r"^### v1\.15 Phase 65[^\n]*\n(.*?)(?=^### |\Z)",
        text,
        re.MULTILINE | re.DOTALL,
    )
    require(len(matches) == 1, "Phase 65 root owner section missing or ambiguous")
    require(text.count(FINAL_OWNER_BEGIN) == 1 and text.count(FINAL_OWNER_END) == 1, "final owner marker duplicated")
    heading = re.search(r"^### v1\.15 Phase 65[^\n]*\n", text, re.MULTILINE)
    require(heading is not None, "Phase 65 root owner section missing")
    return heading.group(0) + matches[0]


def final_owner_disposition(section: str, expected_owner: str) -> dict[str, str]:
    matches = re.findall(
        rf"{re.escape(FINAL_OWNER_BEGIN)}\s*\n(.*?)\n{re.escape(FINAL_OWNER_END)}",
        section,
        re.DOTALL,
    )
    require(len(matches) == 1, "final owner disposition missing or ambiguous")
    fields: dict[str, str] = {}
    for line in matches[0].splitlines():
        require(":" in line, "final owner disposition malformed")
        key, value = (part.strip() for part in line.split(":", 1))
        require(bool(key) and bool(value) and key not in fields, "final owner disposition malformed")
        fields[key] = value
    expected = {"owner": expected_owner, **FINAL_OWNER_COMMON}
    require(fields == expected, "final owner disposition mismatch")
    return {key: value for key, value in fields.items() if key != "owner"}


def validate_root_owner_convergence(root_owners: dict[str, str], plans: str) -> None:
    require(set(root_owners) == {path.as_posix() for path in ROOT_CONTRACT_PATHS}, "root owner inventory mismatch")
    dispositions = []
    sections = []
    for path in ROOT_CONTRACT_PATHS:
        name = path.as_posix()
        section = phase65_owner_section(root_owners[name])
        sections.append(section)
        dispositions.append(final_owner_disposition(section, ROOT_OWNER_NAMES[name]))
    active = re.search(r"^## 3\. Active\n(.*?)(?=^## 3A\.|^## 4\.|\Z)", plans, re.MULTILINE | re.DOTALL)
    require(active is not None, "active lifecycle owner missing")
    sections.append(active.group(0))
    dispositions.append(final_owner_disposition(active.group(0), "PLANS_ACTIVE"))
    require(all(disposition == FINAL_OWNER_COMMON for disposition in dispositions), "root owner dispositions diverge")
    forbidden = (
        "stale/blocked",
        "phase 65 is blocked",
        "safe-06 remains open",
        "devicergb/named-srgb remains open",
        "must be freshly re-verified",
        "not completion-ready",
    )
    for section in sections:
        normalized = section.lower()
        require(all(token not in normalized for token in forbidden), "root owner remains stale or blocked")
        prose = re.sub(
            rf"{re.escape(FINAL_OWNER_BEGIN)}.*?{re.escape(FINAL_OWNER_END)}",
            "",
            section,
            flags=re.DOTALL,
        )
        contradictory = (
            r"(?:teeth|白牙|sclera|祛红血丝)[`*_ :=-]{0,12}(?:(?:is|remains?)\s+)?(?:future|absent|unimplemented)",
            r"(?:mouth|嘴唇)[`*_ :=-]{0,12}(?:(?:is|remains?)\s+)?partial",
            r"(?:eyes|眼睛)[`*_ :=-]{0,12}(?:(?:is|remains?)\s+)?(?:fully\s+)?implemented",
            r"(?:eye[_ -]?fat|去脂)[`*_ :=-]{0,12}(?:(?:is|remains?)\s+)?implemented",
            r"(?:establish(?:es|ed)?|authoriz(?:es|ed)?|adds?)\s+(?!no\b|not\b).{0,60}(?:shipping|archive|tag|release[- ]ready|release authority)",
            r"\bis\s+(?:shipping|archived|tagged|release[- ]ready)\b",
        )
        require(
            all(re.search(pattern, prose, re.IGNORECASE | re.DOTALL) is None for pattern in contradictory),
            "root owner contradicts final disposition",
        )
        inventory_claims = (
            (r"\b(\d+)\s+(?:public\s+)?fields?\b", "61"),
            (r"\b(\d+)\s+(?:neutral\s+)?presets?\b", "5"),
            (r"\b(\d+)\s+renderer\s+cases?\b", "74"),
            (r"\b(\d+)\s+disabled[^.\n]{0,40}(?:demo\s+)?rows?\b", "3"),
        )
        for pattern, expected in inventory_claims:
            require(all(value == expected for value in re.findall(pattern, prose, re.IGNORECASE)), "root owner inventory contradicts final disposition")


def validate_requirement_disposition(requirements: str, include_audit: bool) -> None:
    required = PHASE65_REQUIREMENTS if include_audit else PHASE65_REQUIREMENTS[:-1]
    for requirement in required:
        require(
            re.search(rf"^- \[x\] \*\*{re.escape(requirement)}\*\*:", requirements, re.MULTILINE) is not None,
            "Phase 65 requirement remains incomplete",
        )
    if include_audit:
        completed = re.findall(r"^- \[x\] \*\*([A-Z]+-\d+)\*\*:", requirements, re.MULTILINE)
        require(len(completed) == 40 and len(set(completed)) == 40, "milestone requirement completion mismatch")
        coverage = re.search(r"^\*\*Coverage:\*\*\n(.*?)(?=^## |\Z)", requirements, re.MULTILINE | re.DOTALL)
        require(coverage is not None, "milestone requirement coverage missing")
        for token in (
            "v1.15 requirements: 40 total",
            "Mapped to phases: 40",
            "Unmapped: 0",
            "Duplicate mappings: 0",
            "Currently canonically authorized as satisfied: 40/40",
            "Open Phase 65 requirements: 0",
            "Phase 65 verification is fresh after canonical Phase 64 final",
            "the separately bound milestone audit closes OUT-09",
        ):
            require(token in coverage.group(1), "milestone requirement coverage contradicts final state")


def validate_fresh_phase65_authority(
    phase64: str,
    verification: str,
    requirements: str,
    root_owners: dict[str, str],
    plans: str,
    audit: str | None = None,
) -> None:
    phase64_timestamp = validate_phase64_authority(phase64)
    verification_fields = parse_frontmatter(verification)
    require(verification_fields.get("phase") == "65", "phase verification identity mismatch")
    require(verification_fields.get("status") == "passed", "phase verification not passed")
    verification_timestamp = parse_timestamp(verification_fields.get("verified", ""))
    require(verification_timestamp > phase64_timestamp, "phase verification predates predecessor authority")
    require(
        verification_fields.get("phase_64_verification_sha256") == text_sha256(phase64),
        "phase verification predecessor binding mismatch",
    )
    validate_requirement_disposition(requirements, include_audit=audit is not None)
    validate_root_owner_convergence(root_owners, plans)
    if audit is None:
        return
    audit_fields = parse_frontmatter(audit)
    require(audit_fields.get("milestone") == "v1.15", "milestone audit identity mismatch")
    require(audit_fields.get("status") == "passed", "milestone audit not passed")
    expected_audit_fields = {
        "requirements_verified": "40/40",
        "phases_verified": "7/7",
        "integration_seams_verified": "12/12",
        "flows_verified": "7/7",
        "open_blockers": "0",
        "scope_boundary_verified": "true",
        "archive_or_tag_performed": "false",
        "release_readiness_claimed": "false",
    }
    for key, value in expected_audit_fields.items():
        require(audit_fields.get(key) == value, "milestone audit aggregate mismatch")
    audit_timestamp = parse_timestamp(audit_fields.get("audited", ""))
    require(audit_timestamp > verification_timestamp, "milestone audit predates phase verification")
    require(
        audit_fields.get("phase_65_verification_sha256") == text_sha256(verification),
        "milestone audit source binding mismatch",
    )
    audit_body = markdown_body(audit)
    require(bool(audit_body), "milestone audit body missing")
    require(
        re.search(r"^# v1\.15 Fresh Milestone Audit\s*$", audit_body, re.MULTILINE) is not None,
        "milestone audit body identity mismatch",
    )
    require(re.search(r"^## Result\s*$", audit_body, re.MULTILINE) is not None, "milestone audit result missing")
    normalized_audit_body = re.sub(r"\s+", " ", audit_body)
    for token in (
        "All 40 requirements",
        "all seven phase verifications",
        "twelve cross-phase seams",
        "seven end-to-end flows",
        "no blocker or orphan remains",
        "completion-ready only",
    ):
        require(token in normalized_audit_body, "milestone audit substantive result missing")
    phase_rows = re.findall(
        r"^\| (59|60|61|62|63|64|65) \| [^|]+ \| (\d+)/(\d+) \|$",
        audit_body,
        re.MULTILINE,
    )
    require(
        [row[0] for row in phase_rows] == [str(number) for number in range(59, 66)]
        and sum(int(row[1]) for row in phase_rows) == 40
        and all(row[1] == row[2] for row in phase_rows),
        "milestone audit phase coverage rows mismatch",
    )
    seams = re.search(r"^## Cross-Phase Integration\n(.*?)(?=^## |\Z)", audit_body, re.MULTILINE | re.DOTALL)
    require(seams is not None, "milestone audit seam section missing")
    require(re.findall(r"^(\d+)\. ", seams.group(1), re.MULTILINE) == [str(number) for number in range(1, 13)], "milestone audit seam rows mismatch")
    flows = re.search(r"^## End-to-End Flows\n(.*?)(?=^## |\Z)", audit_body, re.MULTILINE | re.DOTALL)
    require(flows is not None, "milestone audit flow section missing")
    require(len(re.findall(r"^\| [^|]+ \| passed \|$", flows.group(1), re.MULTILINE)) == 7, "milestone audit flow rows mismatch")


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


def non_ignored_production_swift_paths() -> list[Path]:
    paths = [Path("BeautySDK/Package.swift")]
    try:
        for root in (Path("BeautySDK/Sources"), Path("BeautyDemo/BeautyDemo")):
            paths.extend(
                path for path in root.rglob("*.swift")
                if path.is_file() and not any(part.startswith(".") for part in path.parts)
            )
    except OSError as error:
        raise CheckError("production privacy inventory unavailable") from error
    unique = sorted(set(paths))
    require(bool(unique), "production privacy inventory empty")
    require(all("\n" not in path.as_posix() for path in unique), "production source path malformed")
    result = subprocess.run(
        ["git", "check-ignore", "--stdin"],
        input="\n".join(path.as_posix() for path in unique) + "\n",
        check=False,
        capture_output=True,
        text=True,
        timeout=20,
    )
    require(result.returncode in (0, 1), "production ignore classification failed")
    ignored = set(result.stdout.splitlines())
    return [path for path in unique if path.as_posix() not in ignored]


def collect_production_sources(
    paths: list[Path],
    reader=read,
) -> dict[str, str]:
    require(bool(paths), "production privacy inventory empty")
    sources: dict[str, str] = {}
    for path in paths:
        try:
            value = reader(path)
        except CheckError:
            raise
        except (OSError, UnicodeError) as error:
            raise CheckError("production privacy source unreadable") from error
        require(isinstance(value, str), "production privacy source unclassified")
        sources[path.as_posix()] = value
    require(len(sources) == len(set(paths)), "production privacy inventory ambiguous")
    return sources


def sensitive_support_identifier(name: str) -> bool:
    compact = name.replace("_", "").lower()
    patterns = (
        r"raw(?:mask|support|landmark|pupil|coordinate|geometry|pixel)",
        r"(?:pupil|landmark)(?:coordinate|point|position|support|geometry)",
        r"^(?:pupil|landmarks?|facelandmarks?|eyelandmarks?)$",
        r"(?:teeth|sclera|lip|eye)(?:mask|support|geometry|candidate|vein)",
        r"candidatecolou?r",
        r"vein(?:descriptor|pattern|geometry)",
        r"(?:fixturepath|revieweridentity|imagebytes)",
        r"^(?:mask|coordinates?)$",
    )
    return any(re.search(pattern, compact) is not None for pattern in patterns)


def swift_string_end(text: str, start: int) -> int:
    match = re.match(r'(?P<hashes>#+)?(?P<quote>"""|")', text[start:])
    require(match is not None, "production privacy scanner lost string boundary")
    hashes = match.group("hashes") or ""
    quote = match.group("quote")
    cursor = start + len(hashes) + len(quote)
    closing = quote + hashes
    while cursor < len(text):
        if text.startswith(closing, cursor):
            return cursor + len(closing)
        if not hashes and quote == '"' and text[cursor] == "\\":
            cursor += 2
        else:
            cursor += 1
    raise CheckError("production privacy scanner found unterminated string")


def mask_swift_comments(text: str) -> str:
    masked = list(text)
    cursor = 0
    while cursor < len(text):
        string_match = re.match(r'#+(?:"""|")|"""|"', text[cursor:])
        if string_match is not None:
            cursor = swift_string_end(text, cursor)
            continue
        if text.startswith("//", cursor):
            end = text.find("\n", cursor)
            end = len(text) if end < 0 else end
            for index in range(cursor, end):
                masked[index] = " "
            cursor = end
            continue
        if text.startswith("/*", cursor):
            depth = 1
            end = cursor + 2
            while end < len(text) and depth:
                if text.startswith("/*", end):
                    depth += 1
                    end += 2
                elif text.startswith("*/", end):
                    depth -= 1
                    end += 2
                else:
                    end += 1
            require(depth == 0, "production privacy scanner found unterminated comment")
            for index in range(cursor, end):
                if masked[index] != "\n":
                    masked[index] = " "
            cursor = end
            continue
        cursor += 1
    return "".join(masked)


def mask_swift_literals(text: str) -> str:
    masked = list(text)
    cursor = 0
    while cursor < len(text):
        string_match = re.match(r'#+(?:"""|")|"""|"', text[cursor:])
        if string_match is None:
            cursor += 1
            continue
        end = swift_string_end(text, cursor)
        for index in range(cursor, end):
            if masked[index] != "\n":
                masked[index] = " "
        cursor = end
    return "".join(masked)


def complete_call_spans(code: str, pattern: re.Pattern[str]) -> list[tuple[int, int]]:
    spans = []
    for match in pattern.finditer(code):
        opening = code.find("(", match.start(), match.end())
        require(opening >= 0, "production privacy scanner lost call boundary")
        depth = 0
        for cursor in range(opening, len(code)):
            if code[cursor] == "(":
                depth += 1
            elif code[cursor] == ")":
                depth -= 1
                if depth == 0:
                    spans.append((match.start(), cursor + 1))
                    break
        else:
            raise CheckError("production privacy scanner found unterminated call")
    return spans


def sensitive_names_in_code(code: str) -> set[str]:
    identifier = re.compile(r"\b[A-Za-z][A-Za-z0-9_]*\b")
    sensitive = {name for name in identifier.findall(code) if sensitive_support_identifier(name)}
    assignments = re.findall(
        r"\b(?:let|var)\s+([A-Za-z][A-Za-z0-9_]*)\s*(?::[^=\n]+)?=\s*([A-Za-z][A-Za-z0-9_]*)\b",
        code,
    )
    changed = True
    while changed:
        changed = False
        for target, source in assignments:
            if source in sensitive and target not in sensitive:
                sensitive.add(target)
                changed = True
    return sensitive


def call_contains_sensitive_identifier(
    code: str,
    source: str,
    start: int,
    end: int,
    sensitive_names: set[str],
) -> bool:
    identifier = re.compile(r"\b[A-Za-z][A-Za-z0-9_]*\b")
    names = identifier.findall(code[start:end])
    for interpolation in re.findall(r"\\#+?\((.*?)\)|\\\((.*?)\)", source[start:end], re.DOTALL):
        names.extend(identifier.findall(next(value for value in interpolation if value)))
    return any(name in sensitive_names or sensitive_support_identifier(name) for name in names)


def reject_sensitive_calls(
    code: str,
    source: str,
    patterns: tuple[re.Pattern[str], ...],
    message: str,
    sensitive_names: set[str],
    predicate=lambda _span: True,
) -> None:
    for pattern in patterns:
        for start, end in complete_call_spans(code, pattern):
            if predicate(code[start:end]):
                require(
                    not call_contains_sensitive_identifier(code, source, start, end, sensitive_names),
                    message,
                )


def validate_production_privacy(sources: dict[str, str]) -> None:
    require(bool(sources), "production privacy inventory empty")
    public_declaration = re.compile(
        r"(?:@_spi\([^)]*\)\s*)?(?:public|open)\s+"
        r"(?:let|var|func|struct|class|enum|protocol|typealias)\s+([A-Za-z][A-Za-z0-9_]*)"
    )
    serialized_type = re.compile(
        r"(?:struct|class|enum|extension)\s+([A-Za-z][A-Za-z0-9_]*)\s*:\s*([^\{;=]{1,500})\{"
    )
    diagnostic_calls = (
        re.compile(r"\b(?:print|debugPrint|os_log)\s*\("),
        re.compile(r"\.\s*(?:trace|debug|info|notice|warning|error|critical|log)\s*\("),
    )
    reflection_calls = (
        re.compile(r"\bString\s*\("),
        re.compile(r"\bMirror\s*\("),
    )
    persistence_calls = (
        re.compile(
            r"\b[A-Za-z][A-Za-z0-9_]*(?:\s*\.\s*[A-Za-z][A-Za-z0-9_]*)*"
            r"\s*\.\s*(?:write|encode|set|setValue|persist|save|store|archivedData|archiveRootObject)\s*\("
        ),
        re.compile(r"\.\s*(?:write|encode|set|setValue|persist|save|store|archivedData|archiveRootObject)\s*\("),
    )
    metric_calls = (
        re.compile(r"\b(?:metric|metrics|telemetry|analytics|tracer|tracing)\s*\.\s*[A-Za-z][A-Za-z0-9_]*\s*\("),
        re.compile(r"\.\s*(?:addEvent|recordEvent|startSpan|setAttribute)\s*\("),
    )
    for path, text in sources.items():
        require(path.endswith(".swift"), "production privacy source unclassified")
        commentless = mask_swift_comments(text)
        code = mask_swift_literals(commentless)
        sensitive_names = sensitive_names_in_code(code)
        for public_match in public_declaration.finditer(code):
            if sensitive_support_identifier(public_match.group(1)):
                require(
                    (path, public_match.group(1)) in PUBLIC_SENSITIVE_ALLOWLIST,
                    "sensitive public or SPI declaration added",
                )
        for serialized_match in serialized_type.finditer(code):
            protocols = serialized_match.group(2)
            if any(protocol in protocols for protocol in ("Codable", "Encodable", "Decodable")):
                require(
                    not sensitive_support_identifier(serialized_match.group(1)),
                    "sensitive serialization carrier added",
                )
            if any(protocol in protocols for protocol in ("CustomStringConvertible", "CustomReflectable")):
                require(
                    not sensitive_support_identifier(serialized_match.group(1))
                    or (path, serialized_match.group(1)) in REFLECTION_AGGREGATE_ALLOWLIST,
                    "sensitive reflection carrier added",
                )
        reject_sensitive_calls(code, commentless, diagnostic_calls, "sensitive diagnostic interpolation added", sensitive_names)
        reject_sensitive_calls(
            code,
            commentless,
            reflection_calls,
            "sensitive serialization or reflection sink added",
            sensitive_names,
            predicate=lambda span: re.search(r"\b(?:describing|reflecting)\s*:", span) is not None,
        )
        reject_sensitive_calls(code, commentless, persistence_calls, "sensitive persistence sink added", sensitive_names)
        reject_sensitive_calls(code, commentless, metric_calls, "sensitive metric or tracing sink added", sensitive_names)


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
    require(
        parse_frontmatter(
            read(Path(".planning/phases/61-teeth-output-safety-and-independent-closeout/61-VERIFICATION.md"))
        ).get("status") == "passed",
        "teeth standalone verification unavailable",
    )
    validate_phase64_authority(read(PHASE64_VERIFICATION))
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
    ):
        require(token in text, "combined byte oracle incomplete")
    combined_test = re.search(
        r"\bfunc testCombinedFacadeMatchesIndependentStandaloneMergeThroughBothEntries\([^)]*\)\s+throws\s*\{"
        r"(.*?)(?=\n    func |\n\})",
        text,
        re.DOTALL,
    )
    require(combined_test is not None, "combined facade test owner missing")
    for assertion in (
        "hasNamedSRGBColorSpace(teeth.output)",
        "hasNamedSRGBColorSpace(sclera.output)",
        "hasNamedSRGBColorSpace(combined.output)",
    ):
        require(assertion in combined_test.group(1), "both-entry named-sRGB proof incomplete")
    if final_ready:
        require("phase65_missing_" not in text and "XCTFail(" not in text, "combined RED sentinel remains")


def validate_saved_srgb_contract(
    renderer: str,
    renderer_test: str,
    teeth_decoder: str,
    sclera_decoder: str,
) -> None:
    for token in (
        "CGColorSpace(name: CGColorSpace.sRGB)",
        ".workingColorSpace: outputColorSpace",
        ".outputColorSpace: outputColorSpace",
        "NSBitmapImageRep(cgImage: cgImage)",
    ):
        require(token in renderer, "renderer named-sRGB export incomplete")
    for forbidden in ("CGColorSpaceCreateDeviceRGB()", "colorSpaceName: .deviceRGB"):
        require(forbidden not in renderer, "renderer DeviceRGB fallback remains")
    require(
        "testRendererSavedPNGPathUsesNamedSRGBWithoutDeviceRGBFallback" in renderer_test,
        "renderer named-sRGB regression missing",
    )
    for token in (
        'kind == b"sRGB"',
        "require_explicit_srgb: bool = False",
        "require_explicit_srgb=True",
        "PNG without explicit sRGB accepted",
        "IHDR must be first",
        "conflicting ICC declaration",
        "PNG with pre-IHDR sRGB accepted",
        "PNG with conflicting iCCP and sRGB accepted",
    ):
        require(token in teeth_decoder, "teeth saved-output sRGB decoder incomplete")
    for token in ("require_explicit_srgb=True", '"missing sRGB"'):
        require(token in sclera_decoder, "sclera saved-output sRGB decoder incomplete")


def load_strict_png_decoder():
    path = Path(
        ".planning/phases/61-teeth-output-safety-and-independent-closeout/"
        "check_teeth_renderer_outputs.py"
    )
    spec = importlib.util.spec_from_file_location("phase65_strict_png_decoder", path)
    require(spec is not None and spec.loader is not None, "strict PNG decoder unavailable")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    try:
        spec.loader.exec_module(module)
    except Exception as error:
        raise CheckError("strict PNG decoder unavailable") from error
    return module


def png_has_exif_orientation(data: bytes) -> bool:
    offset = 8
    exif_payloads: list[bytes] = []
    while offset + 12 <= len(data):
        length = int.from_bytes(data[offset : offset + 4], "big")
        kind = data[offset + 4 : offset + 8]
        start = offset + 8
        end = start + length
        require(end + 4 <= len(data), "saved PNG metadata malformed")
        if kind == b"eXIf":
            exif_payloads.append(data[start:end])
        offset = end + 4
    require(offset == len(data), "saved PNG metadata malformed")
    require(len(exif_payloads) <= 1, "saved PNG EXIF metadata ambiguous")
    if not exif_payloads:
        return False
    payload = exif_payloads[0]
    if payload.startswith(b"Exif\x00\x00"):
        payload = payload[6:]
    require(len(payload) >= 8, "saved PNG EXIF metadata malformed")
    byte_order = payload[:2]
    require(byte_order in (b"II", b"MM"), "saved PNG EXIF metadata malformed")
    order = "little" if byte_order == b"II" else "big"
    require(int.from_bytes(payload[2:4], order) == 42, "saved PNG EXIF metadata malformed")
    ifd_offset = int.from_bytes(payload[4:8], order)
    require(ifd_offset + 2 <= len(payload), "saved PNG EXIF metadata malformed")
    count = int.from_bytes(payload[ifd_offset : ifd_offset + 2], order)
    require(count <= 256, "saved PNG EXIF metadata malformed")
    entries_end = ifd_offset + 2 + count * 12
    require(entries_end <= len(payload), "saved PNG EXIF metadata malformed")
    for index in range(count):
        entry = ifd_offset + 2 + index * 12
        if int.from_bytes(payload[entry : entry + 2], order) == 0x0112:
            return True
    return False


def renderer_saved_output_smoke() -> int:
    decoder = load_strict_png_decoder()
    width = height = 64
    rgba = bytes(
        channel
        for y in range(height)
        for x in range(width)
        for channel in (40 + x, 50 + y, 90 + ((x + y) // 2), 255)
    )
    try:
        input_png = decoder.encode_png(width, height, rgba, explicit_srgb=True)
    except Exception as error:
        raise CheckError("strict PNG smoke input unavailable") from error
    with tempfile.TemporaryDirectory(prefix="beauty-phase65-srgb-") as temporary:
        root = Path(temporary)
        input_dir = root / "input"
        input_dir.mkdir()
        (input_dir / "source.png").write_bytes(input_png)
        for presentation_free in (True, False):
            output_dir = root / ("plain" if presentation_free else "watermarked")
            arguments = [
                "swift", "run", "--package-path", "BeautySDK", "BeautyExampleRenderer",
                "--input", str(input_dir), "--output", str(output_dir),
                "--case", "geometryBaseline_noop",
            ]
            if presentation_free:
                arguments.append("--no-watermark")
            child = subprocess.run(
                arguments,
                check=False,
                capture_output=True,
                timeout=180,
            )
            require(child.returncode == 0, "renderer saved-output smoke failed")
            expected = output_dir / "source__geometryBaseline_noop.png"
            try:
                files = {path.name for path in output_dir.iterdir() if path.is_file()}
                image = decoder.decode_png(expected, "saved output", require_explicit_srgb=True)
                data = decoder.bounded_regular_bytes(expected, "saved output")
            except Exception as error:
                raise CheckError("renderer saved-output validation failed") from error
            require(files == {expected.name}, "renderer saved-output inventory mismatch")
            require((image.width, image.height) == (width, height), "renderer saved-output dimensions changed")
            require(all(image.rgba[index] == 255 for index in range(3, len(image.rgba), 4)), "renderer saved-output alpha changed")
            require(not png_has_exif_orientation(data), "renderer saved-output orientation metadata remains")
    return 2


def combined_checks(final_ready: bool) -> int:
    validate_combined_test(
        read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift")),
        final_ready,
    )
    validate_saved_srgb_contract(
        read(Path("BeautySDK/Sources/BeautyExampleRenderer/main.swift")),
        read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift")),
        read(Path(".planning/phases/61-teeth-output-safety-and-independent-closeout/check_teeth_renderer_outputs.py")),
        read(Path(".planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py")),
    )
    smoke_count = renderer_saved_output_smoke()
    composition = read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift"))
    require("testCollisionPreservesSourcePixelAndCountsOnce" in composition, "retained collision oracle missing")
    return 14 + smoke_count


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
    production_sources: dict[str, str],
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
    validate_production_privacy(production_sources)


def privacy_checks() -> int:
    phase_text = "\n".join(read(path) for path in PHASE_DIR.glob("65-*.md"))
    validate_privacy(
        git_names("ls-files") + git_names("diff", "--cached", "--name-only"),
        phase_text,
        read(Path("BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift")),
        read(Path("BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift")),
        collect_production_sources(non_ignored_production_swift_paths()),
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
        phase64 = read(PHASE64_VERIFICATION)
        verification = read(PHASE_DIR / "65-VERIFICATION.md")
        security = read(PHASE_DIR / "65-SECURITY.md")
        require("threats_open: 0" in security, "security not closed")
        validate_fresh_phase65_authority(
            phase64,
            verification,
            read(Path(".planning/REQUIREMENTS.md")),
            {path.as_posix(): read(path) for path in ROOT_CONTRACT_PATHS},
            read(Path("PLANS.md")),
            read(MILESTONE_AUDIT) if mode == "final" else None,
        )
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

    combined_body = " ".join((
        "process, .processResult BeautyParameters(teethWhitening: 1)",
        "BeautyParameters(scleraRednessReduction: 1) teethWhitening: 1, scleraRednessReduction: 1",
        "independentMerge collisionPixelCount combinedBytes, oracle.bytes compositionInvocationCount, 1",
        "hasNamedSRGBColorSpace(teeth.output) hasNamedSRGBColorSpace(sclera.output)",
        "hasNamedSRGBColorSpace(combined.output)",
    ))
    combined = (
        "func testCombinedFacadeMatchesIndependentStandaloneMergeThroughBothEntries() throws {\n"
        f"{combined_body}\n"
        "}\n\n    func nextTest() {}"
    )
    probe(lambda: validate_combined_test(combined, False), lambda: validate_combined_test(combined.replace("independentMerge", "missing"), False))
    probe(
        lambda: validate_combined_test(combined, False),
        lambda: validate_combined_test(
            combined.replace("hasNamedSRGBColorSpace(combined.output)", "missingSRGBProof"),
            False,
        ),
    )
    renderer_srgb = " ".join((
        "CGColorSpace(name: CGColorSpace.sRGB)",
        ".workingColorSpace: outputColorSpace",
        ".outputColorSpace: outputColorSpace",
        "NSBitmapImageRep(cgImage: cgImage)",
    ))
    renderer_srgb_test = "testRendererSavedPNGPathUsesNamedSRGBWithoutDeviceRGBFallback"
    teeth_srgb = 'kind == b"sRGB" require_explicit_srgb: bool = False require_explicit_srgb=True PNG without explicit sRGB accepted IHDR must be first conflicting ICC declaration PNG with pre-IHDR sRGB accepted PNG with conflicting iCCP and sRGB accepted'
    sclera_srgb = 'require_explicit_srgb=True "missing sRGB"'
    probe(
        lambda: validate_saved_srgb_contract(renderer_srgb, renderer_srgb_test, teeth_srgb, sclera_srgb),
        lambda: validate_saved_srgb_contract(
            renderer_srgb + " CGColorSpaceCreateDeviceRGB()",
            renderer_srgb_test,
            teeth_srgb,
            sclera_srgb,
        ),
    )

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
        lambda: validate_privacy(
            [], "clean", private_test, testing_support,
            {"Neutral.swift": "package struct RequestLocalCarrier {}"},
        ),
        lambda: validate_privacy(
            [], "/Users/private", private_test, testing_support,
            {"Neutral.swift": "package struct RequestLocalCarrier {}"},
        ),
    )
    clean_production = {
        "Neutral.swift": """package struct RenderSummary:
    Codable { let count: Int }

func benignMultiline(count: Int, png: Data, destination: URL) throws {
    logger.info(
        "count \\(count)"
    )
    _ = String(
        describing: count
    )
    _ = Mirror(
        reflecting: count
    )
    try png.write(
        to: destination
    )
}
"""
    }
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "public struct Carrier {\n    public let rawMask: [Float]\n}"}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "struct PupilSupport:\n    Codable { let value: Int }"}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": 'logger.info(\n    "pupil \\(pupilCoordinates)"\n)'}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "try rawMask.write(\n    to: destination\n)"}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "_ = String(\n    describing: pupilCoordinates\n)"}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "_ = Mirror(\n    reflecting: rawMask\n)"}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "metrics.record(\n    rawMask\n)"}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "extension PupilSupport:\n    Codable {}"}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": 'privacyLogger.info(\n    "\\(landmarks)"\n)'}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": 'UserDefaults.standard.setValue(\n    rawMask,\n    forKey: "mask"\n)'}
        ),
    )
    probe(
        lambda: validate_production_privacy(clean_production),
        lambda: validate_production_privacy(
            {"Neutral.swift": "let payload = faceLandmarks\ntracer.addEvent(\n    payload\n)"}
        ),
    )
    probe(
        lambda: collect_production_sources([Path("Neutral.swift")], reader=lambda _: "clean"),
        lambda: collect_production_sources(
            [Path("Neutral.swift")],
            reader=lambda _: (_ for _ in ()).throw(CheckError("read failed")),
        ),
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

    phase64 = """---
verification_stage: post_terminal_final
status: passed
verified: 2026-08-10T18:15:00+08:00
promotion_status: promoted
requires_requarantine: false
phase_65_authorized: true
---
canonical predecessor
"""
    phase65 = f"""---
phase: 65
status: passed
verified: 2026-08-11T09:00:00+08:00
phase_64_verification_sha256: {text_sha256(phase64)}
---
fresh named-sRGB proof
"""
    final_requirements = "\n".join(
        [f"- [x] **REQ-{index:02d}**: complete" for index in range(1, 30)]
        + [f"- [x] **{requirement}**: complete" for requirement in PHASE65_REQUIREMENTS]
        + [
            "",
            "**Coverage:**",
            "",
            "- v1.15 requirements: 40 total",
            "- Mapped to phases: 40",
            "- Unmapped: 0",
            "- Duplicate mappings: 0",
            "- Currently canonically authorized as satisfied: 40/40",
            "- Open Phase 65 requirements: 0",
            "- Phase 65 verification is fresh after canonical Phase 64 final; the separately bound milestone audit closes OUT-09",
            "",
            "## Next",
        ]
    )
    def owner_block(owner: str) -> str:
        fields = {"owner": owner, **FINAL_OWNER_COMMON}
        values = "\n".join(f"{key}: {value}" for key, value in fields.items())
        return f"{FINAL_OWNER_BEGIN}\n{values}\n{FINAL_OWNER_END}"

    root_owners = {
        path.as_posix(): (
            "### v1.15 Phase 65 Current Closeout\n"
            f"{owner_block(ROOT_OWNER_NAMES[path.as_posix()])}\n"
            "Freshly verified named-sRGB contract.\n"
        )
        for path in ROOT_CONTRACT_PATHS
    }
    plans_owner = (
        "## 3. Active\n"
        f"{owner_block('PLANS_ACTIVE')}\n"
        "Phase 65 freshly verified.\n\n"
        "## 3A. Archived Active Ledger\n"
    )
    audit = f"""---
milestone: v1.15
status: passed
audited: 2026-08-11T10:00:00+08:00
phase_65_verification_sha256: {text_sha256(phase65)}
requirements_verified: 40/40
phases_verified: 7/7
integration_seams_verified: 12/12
flows_verified: 7/7
open_blockers: 0
scope_boundary_verified: true
archive_or_tag_performed: false
release_readiness_claimed: false
---
# v1.15 Fresh Milestone Audit

## Result

All 40 requirements have one disposition; all seven phase verifications are
canonical. The audit confirms twelve cross-phase seams, seven end-to-end flows,
no blocker or orphan remains, and the milestone is completion-ready only.

## Requirement Coverage

| Phase | Requirements | Result |
| --- | --- | --- |
| 59 | four | 4/4 |
| 60 | six | 6/6 |
| 61 | two | 2/2 |
| 62 | six | 6/6 |
| 63 | five | 5/5 |
| 64 | six | 6/6 |
| 65 | eleven | 11/11 |

## Cross-Phase Integration

{chr(10).join(f"{number}. Seam {number}." for number in range(1, 13))}

## End-to-End Flows

| Flow | Result |
| --- | --- |
{chr(10).join(f"| Flow {number} | passed |" for number in range(1, 8))}

## Boundary
"""

    def final_authority(
        predecessor: str = phase64,
        verification: str = phase65,
        requirement_owner: str = final_requirements,
        owners: dict[str, str] = root_owners,
        plans: str = plans_owner,
        audit_owner: str = audit,
    ) -> None:
        validate_fresh_phase65_authority(
            predecessor,
            verification,
            requirement_owner,
            owners,
            plans,
            audit_owner,
        )

    probe(final_authority, lambda: final_authority(predecessor=phase64.replace("post_terminal_final", "post_promotion")))
    probe(final_authority, lambda: final_authority(verification=phase65.replace("2026-08-11T09:00:00+08:00", "2026-08-08T09:00:00+08:00")))
    probe(final_authority, lambda: final_authority(verification=phase65.replace("phase: 65", "phase: 64", 1)))
    probe(final_authority, lambda: final_authority(requirement_owner=final_requirements.replace("[x] **SAFE-06**", "[ ] **SAFE-06**")))
    probe(final_authority, lambda: final_authority(requirement_owner=final_requirements.replace("satisfied: 40/40", "satisfied: 23/40")))
    for owner_path in ROOT_OWNER_NAMES:
        probe(
            final_authority,
            lambda owner_path=owner_path: final_authority(
                owners={
                    **root_owners,
                    owner_path: "### v1.15 Phase 65 Current Closeout\nNo lifecycle or product facts.\n",
                }
            ),
        )
    probe(final_authority, lambda: final_authority(plans="## 3. Active\n\n## 3A. Archived Active Ledger\n"))
    probe(
        final_authority,
        lambda: final_authority(
            owners={
                **root_owners,
                "DESIGN.md": root_owners["DESIGN.md"]
                + "\n### v1.15 Phase 65 Contradiction\nPhase 65 establishes shipping/release authority.\n",
            }
        ),
    )
    probe(
        final_authority,
        lambda: final_authority(
            owners={
                **root_owners,
                "DESIGN.md": root_owners["DESIGN.md"].replace(
                    "Freshly verified named-sRGB contract.",
                    "Freshly verified named-sRGB contract. Phase 65 establishes shipping/release authority.",
                ),
            }
        ),
    )
    probe(final_authority, lambda: final_authority(audit_owner=audit.replace("2026-08-11T10:00:00+08:00", "2026-08-11T08:00:00+08:00")))
    probe(final_authority, lambda: final_authority(audit_owner=audit.replace(text_sha256(phase65), "0" * 64)))
    probe(final_authority, lambda: final_authority(audit_owner=audit.replace("open_blockers: 0", "open_blockers: 1")))
    probe(final_authority, lambda: final_authority(audit_owner=audit.split("---", 2)[0] + "---\n" + audit.split("---", 2)[1] + "---\n"))
    probe(final_authority, lambda: final_authority(audit_owner=audit.replace("requirements_verified: 40/40", "requirements_verified: 39/40")))
    probe(final_authority, lambda: final_authority(audit_owner=audit.replace("milestone: v1.15", "milestone: v1.14")))
    one_paragraph_audit = audit.split("---", 2)[0] + "---\n" + audit.split("---", 2)[1] + "---\n" + """# v1.15 Fresh Milestone Audit

## Result

All 40 requirements and all seven phase verifications pass. The prose names
twelve cross-phase seams, seven end-to-end flows, no blocker or orphan remains,
and completion-ready only.
"""
    probe(final_authority, lambda: final_authority(audit_owner=one_paragraph_audit))

    good_inventory = {"threats": [{"id": item, "severity": "HIGH"} for item in THREATS]}
    bad_inventory = {"threats": good_inventory["threats"][:-1]}
    probe(
        lambda: validate_lifecycle_inventory(good_inventory),
        lambda: validate_lifecycle_inventory(bad_inventory),
    )

    require(len(probes) == 42 and all(probes), "self-test denominator mismatch")
    print(json.dumps({"status": "pass", "self_tests": 42, "threats": 8}, separators=(",", ":")))
    return 42


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
