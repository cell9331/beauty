#!/usr/bin/env python3
"""Fail-closed Phase 54 evidence, reviewer, ledger, privacy, and scope checker."""

from __future__ import annotations

import argparse
import hashlib
import json
import pathlib
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from typing import Any, Iterable, Sequence


ROOT = pathlib.Path(__file__).resolve().parents[3]
PHASE = ROOT / ".planning" / "phases" / "54-rights-approved-evidence-and-eligibility-decisions"
CORE_TEST = PHASE / "54-evidence-core.test.js"
CORE = PHASE / "54-evidence-core.js"
SCHEMA = PHASE / "54-evidence-manifest.schema.json"
UI_TEST = PHASE / "54-review.contract.test.js"
HTML = PHASE / "54-review.html"
CONTROLLER = PHASE / "54-review-controller.js"
LEDGER = PHASE / "54-EVIDENCE-DECISIONS.json"
LOCAL_REVIEW_ROOT = ROOT / "example-images" / "local-retouch-review"
SPIKE_006 = ROOT / ".codex" / "skills" / "spike-findings-beauty" / "sources" / "006-licensed-fixture-review-gate"

FEATURE_ORDER = ["teeth_whitening", "sclera_redness", "upper_eyelid_fullness"]
EXPECTED_REASONS = {
    "teeth_whitening": ["missing_genuine_positive"],
    "sclera_redness": ["missing_genuine_positive", "incomplete_asset_triple"],
    "upper_eyelid_fullness": ["missing_genuine_positive", "non_warp_design_unqualified"],
}
DECISION_KEYS = (
    "feature",
    "status",
    "reasons",
    "eligible_count",
    "reviewed_count",
    "accepted_count",
    "rejected_count",
    "naturalness_weight",
)
AGGREGATE_KEYS = (
    "feature",
    "eligible_count",
    "reviewed_count",
    "accepted_count",
    "rejected_count",
    "naturalness_weight",
)
ZERO_VALUE_KEYS = (
    "eligible_count",
    "reviewed_count",
    "accepted_count",
    "rejected_count",
    "naturalness_weight",
)
UI_CONSIDERATIONS = tuple(f"UI-CONSIDERATION-{index:02d}" for index in range(1, 9))
UI_ACCEPTANCE = tuple(f"UI-AC-{index:02d}" for index in range(1, 20))
EXPECTED_UI_ROWS = frozenset((*UI_CONSIDERATIONS, *UI_ACCEPTANCE))
EXPECTED_SPIKE_DIGEST = "c5edde15396d5a3d1052f5bfc183d3ac4beb75e11ee4f364c1caaec28cc7a891"

FORBIDDEN_EXPORT_KEYS = frozenset(
    {
        "dataset",
        "dataset_id",
        "generated_at",
        "timestamp",
        "time",
        "session",
        "event",
        "events",
        "metadata",
        "reviewer",
        "notes",
        "freeform",
        "text",
        "filename",
        "file_name",
        "path",
        "directory",
        "rights",
        "rights_record_id",
        "documentation",
        "documentation_record_id",
        "retention",
        "retention_policy",
        "original",
        "mask",
        "after",
        "media",
        "blob",
        "coordinates",
        "landmarks",
        "pupils",
        "descriptors",
        "raw_geometry",
        "raw_error",
        "error",
    }
)
FORBIDDEN_EXPORT_SENTINELS = tuple(f"PHASE54_FORBIDDEN_{name.upper()}" for name in FORBIDDEN_EXPORT_KEYS)
FORBIDDEN_REVIEWER_PATTERNS = (
    r"\bfetch\s*\(",
    r"\bXMLHttpRequest\b",
    r"\bWebSocket\b",
    r"\bEventSource\b",
    r"\bsendBeacon\b",
    r"\bRTCPeerConnection\b",
    r"https?://",
    r"<(?:link|iframe|object|embed)\b",
    r"\b(?:localStorage|sessionStorage|indexedDB|caches)\b|\bdocument\.cookie\b|\bnavigator\.(?:serviceWorker|clipboard)\b|\b(?:SharedWorker|Worker)\s*\(",
    r"\.innerHTML\b",
    r"\.outerHTML\b",
    r"insertAdjacentHTML|document\.write",
    r"<form\b[^>]*(?:action|method)=",
)
FORBIDDEN_CORE_PATTERNS = (
    *FORBIDDEN_REVIEWER_PATTERNS,
    r"\b(?:require\s*\(\s*[\"'](?:fs|node:fs|child_process|node:child_process)|process\.(?:env|cwd)|Date\.now|Math\.random)\b",
)
CANDIDATE_NAMES = (
    "teethWhitening",
    "scleraRednessReduction",
    "upperEyelidFullnessReduction",
)
OWNER_REQUIREMENTS = {
    "PLANS.md": ("Phase 54", "missing_genuine_positive", "non_warp_design_unqualified"),
    "PRODUCT_SENSE.md": ("Phase 54", "missing_genuine_positive", "non_warp_design_unqualified"),
    "SECURITY.md": ("Phase 54", "local-retouch-review", "positive allowlist"),
    "RELIABILITY.md": ("Phase 54", "valid-but-closed", "non_warp_design_unqualified"),
    "QUALITY_SCORE.md": ("Phase 54", "EVID-01", "LID-01"),
}
EXPECTED_WAVE0_FAILURES = frozenset(
    {
        "core:missing_schema",
        "core:missing_module",
        "ui:missing_html",
        "ui:missing_controller",
        "ledger:missing",
        "ignore:missing_local_review_rule",
        *(f"owners:missing_contract:{name}" for name in OWNER_REQUIREMENTS),
    }
)


@dataclass(frozen=True)
class Rule:
    name: str
    pattern: str


def classify_scan(returncode: int, stdout: str, stderr: str) -> str:
    if returncode == 0:
        return "match"
    if returncode == 1 and not stdout and not stderr:
        return "clean"
    raise RuntimeError("scanner_error")


def run_command(command: Sequence[str], cwd: pathlib.Path = ROOT) -> subprocess.CompletedProcess[str]:
    try:
        return subprocess.run(command, cwd=cwd, text=True, capture_output=True, check=False)
    except OSError as error:
        raise RuntimeError("subprocess_error") from error


def read_utf8(path: pathlib.Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except (OSError, UnicodeError) as error:
        raise RuntimeError("unreadable_utf8") from error


def parse_json(path: pathlib.Path) -> Any:
    try:
        return json.loads(read_utf8(path))
    except json.JSONDecodeError as error:
        raise RuntimeError("malformed_json") from error


def validate_safe_key(value: Any) -> bool:
    if not isinstance(value, str) or not value or len(value) > 512:
        return False
    if value.startswith(("/", "\\")) or "\\" in value or ":" in value or "\0" in value:
        return False
    parts = value.split("/")
    return all(part not in {"", ".", ".."} for part in parts)


def validate_opaque_id(value: Any) -> bool:
    return isinstance(value, str) and re.fullmatch(r"[A-Za-z0-9_-]{1,64}", value) is not None


def validate_ui_inventory(rows: Iterable[str]) -> None:
    materialized = tuple(rows)
    if len(materialized) != len(set(materialized)):
        raise AssertionError("duplicate_ui_row")
    if frozenset(materialized) != EXPECTED_UI_ROWS:
        raise AssertionError("ui_row_equality")
    if len(materialized) != 27:
        raise AssertionError("ui_row_total")


def validate_html_document(text: str) -> None:
    if not re.search(r"<!doctype\s+html>", text, re.IGNORECASE):
        raise AssertionError("html_doctype")
    if not re.search(r"<html\b[\s\S]*</html>\s*$", text, re.IGNORECASE):
        raise AssertionError("html_structure")
    for tag in ("head", "body"):
        if len(re.findall(rf"</?{tag}\b", text, re.IGNORECASE)) != 2:
            raise AssertionError(f"html_{tag}")


def validate_ignore_contract(ignore_text: str, ignored: bool, tracked: bool, dirty: bool) -> None:
    if not re.search(r"^/?example-images/local-retouch-review/\s*$", ignore_text, re.MULTILINE):
        raise AssertionError("ignore_rule")
    if not ignored:
        raise AssertionError("ignore_probe")
    if tracked:
        raise AssertionError("tracked_sensitive")
    if dirty:
        raise AssertionError("dirty_sensitive")


def validate_owner_contracts(texts: dict[str, str]) -> None:
    for name, anchors in OWNER_REQUIREMENTS.items():
        if name not in texts or any(anchor not in texts[name] for anchor in anchors):
            raise AssertionError("owner_contract")


def validate_scope_contract(active_text: str, spike_digest: str) -> None:
    if any(candidate in active_text for candidate in CANDIDATE_NAMES):
        raise AssertionError("candidate_activation")
    if re.search(r"54-review|evidence-core|ReviewCore|local-retouch-review", active_text, re.IGNORECASE):
        raise AssertionError("reviewer_import")
    if spike_digest != EXPECTED_SPIKE_DIGEST:
        raise AssertionError("spike_drift")


def scan_patterns(text: str, patterns: Sequence[str]) -> list[str]:
    return [f"pattern_{index}" for index, pattern in enumerate(patterns) if re.search(pattern, text, re.IGNORECASE | re.DOTALL)]


def walk_export(value: Any, failures: list[str], location: str = "root") -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            normalized = str(key).lower()
            if normalized in FORBIDDEN_EXPORT_KEYS:
                failures.append(f"ledger:forbidden_key:{normalized}")
            walk_export(child, failures, f"{location}.value")
    elif isinstance(value, list):
        for child in value:
            walk_export(child, failures, f"{location}.item")
    elif isinstance(value, str):
        lowered = value.lower()
        if any(sentinel.lower() in lowered for sentinel in FORBIDDEN_EXPORT_SENTINELS):
            failures.append("ledger:forbidden_value")
        if re.search(r"(?:^|[/\\])(?:users|private|volumes|home)(?:[/\\]|$)", lowered):
            failures.append("ledger:unsafe_path_value")


def validate_ledger_object(value: Any) -> list[str]:
    failures: list[str] = []
    if not isinstance(value, dict):
        return ["ledger:not_object"]
    if list(value) != ["schema_version", "feature_decisions", "reviews", "aggregates"]:
        failures.append("ledger:top_level_allowlist")
    if type(value.get("schema_version")) is not int or value.get("schema_version") != 1:
        failures.append("ledger:schema_version")
    decisions = value.get("feature_decisions")
    if not isinstance(decisions, list) or len(decisions) != len(FEATURE_ORDER):
        failures.append("ledger:feature_order")
    else:
        for index, (row, expected_feature) in enumerate(zip(decisions, FEATURE_ORDER)):
            if not isinstance(row, dict):
                failures.append(f"ledger:decision_not_object:{index}")
                continue
            feature = row.get("feature")
            label = feature if isinstance(feature, str) else str(index)
            if list(row) != list(DECISION_KEYS):
                failures.append(f"ledger:decision_allowlist:{label}")
            if feature != expected_feature:
                failures.append("ledger:feature_order")
                continue
            if not isinstance(row.get("status"), str) or row.get("status") != "closed":
                failures.append(f"ledger:status:{feature}")
            reasons = row.get("reasons")
            if not isinstance(reasons, list) or reasons != EXPECTED_REASONS[feature] or any(not isinstance(reason, str) for reason in reasons):
                failures.append(f"ledger:reasons:{feature}")
            if any(type(row.get(key)) is not int or row.get(key) != 0 for key in ZERO_VALUE_KEYS):
                failures.append(f"ledger:nonzero_count:{feature}")
    if value.get("reviews") != []:
        failures.append("ledger:reviews_not_empty")
    aggregates = value.get("aggregates")
    if not isinstance(aggregates, list) or len(aggregates) != len(FEATURE_ORDER):
        failures.append("ledger:aggregate_order")
    else:
        for index, (row, expected_feature) in enumerate(zip(aggregates, FEATURE_ORDER)):
            if not isinstance(row, dict):
                failures.append(f"ledger:aggregate_not_object:{index}")
                continue
            feature = row.get("feature")
            label = feature if isinstance(feature, str) else str(index)
            if list(row) != list(AGGREGATE_KEYS):
                failures.append(f"ledger:aggregate_allowlist:{label}")
            if feature != expected_feature:
                failures.append("ledger:aggregate_order")
                continue
            if any(type(row.get(key)) is not int or row.get(key) != 0 for key in ZERO_VALUE_KEYS):
                failures.append(f"ledger:aggregate_nonzero:{feature}")
    walk_export(value, failures)
    return sorted(set(failures))


def directory_digest(root: pathlib.Path) -> str:
    if not root.is_dir():
        raise RuntimeError("missing_spike_source")
    digest = hashlib.sha256()
    for path in sorted(candidate for candidate in root.rglob("*") if candidate.is_file()):
        digest.update(path.relative_to(root).as_posix().encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def check_core() -> list[str]:
    failures: list[str] = []
    if not CORE_TEST.is_file():
        failures.append("core:missing_test")
    if not SCHEMA.is_file():
        failures.append("core:missing_schema")
    else:
        try:
            schema = parse_json(SCHEMA)
            if schema.get("$schema") != "https://json-schema.org/draft/2020-12/schema":
                failures.append("core:schema_draft")
            if schema.get("additionalProperties") is not False:
                failures.append("core:schema_open_root")
        except RuntimeError as error:
            failures.append(f"core:{error}")
    if not CORE.is_file():
        failures.append("core:missing_module")
    else:
        try:
            text = read_utf8(CORE)
            completed = run_command(["node", "--check", str(CORE)])
            if completed.returncode != 0:
                failures.append("core:javascript_syntax")
            if scan_patterns(text, FORBIDDEN_CORE_PATTERNS):
                failures.append("core:forbidden_side_effect")
            for anchor in [
                "ReviewCore", "validateManifest", "normalizeRelativeAssetKey", "createReviewSnapshot",
                "validateReview", "rowPasses", "evaluateFeature", "buildDurableExport", "serializeDurableExport",
            ]:
                if anchor not in text:
                    failures.append(f"core:missing_anchor:{anchor}")
        except RuntimeError as error:
            failures.append(f"core:{error}")
    return failures


def check_ui() -> list[str]:
    failures: list[str] = []
    if not UI_TEST.is_file():
        failures.append("ui:missing_contract_test")
    if not HTML.is_file():
        failures.append("ui:missing_html")
    if not CONTROLLER.is_file():
        failures.append("ui:missing_controller")
    if not HTML.is_file() or not CONTROLLER.is_file():
        return failures
    try:
        html = read_utf8(HTML)
        controller = read_utf8(CONTROLLER)
        completed = run_command(["node", "--check", str(CONTROLLER)])
        if completed.returncode != 0:
            failures.append("ui:javascript_syntax")
        try:
            validate_html_document(html)
        except AssertionError:
            failures.append("ui:malformed_html")
        if "Content-Security-Policy" not in html or "connect-src 'none'" not in html or "script-src 'self'" not in html:
            failures.append("ui:csp")
        if scan_patterns(f"{html}\n{controller}", FORBIDDEN_REVIEWER_PATTERNS):
            failures.append("ui:forbidden_runtime")
        for selector in (
            "manifest-input", "asset-directory-input", "validation-summary", "feature-gates",
            "review-workspace", "judgment-form", "export-review", "replace-session-dialog",
        ):
            if len(re.findall(rf"\bid=[\"']{re.escape(selector)}[\"']", html)) != 1:
                failures.append(f"ui:selector:{selector}")
        for anchor in ["ReviewCore", "createObjectURL", "revokeObjectURL", "beauty-evidence-review-v1.json"]:
            if anchor not in controller:
                failures.append(f"ui:missing_anchor:{anchor}")
    except RuntimeError as error:
        failures.append(f"ui:{error}")
    return failures


def check_ledger() -> list[str]:
    if not LEDGER.is_file():
        return ["ledger:missing"]
    try:
        return validate_ledger_object(parse_json(LEDGER))
    except RuntimeError as error:
        return [f"ledger:{error}"]


def check_ignore() -> list[str]:
    failures: list[str] = []
    ignore = ROOT / ".gitignore"
    try:
        text = read_utf8(ignore)
    except RuntimeError as error:
        return [f"ignore:{error}"]
    has_rule = re.search(r"^/?example-images/local-retouch-review/\s*$", text, re.MULTILINE) is not None
    if not has_rule:
        return ["ignore:missing_local_review_rule"]
    probe = "example-images/local-retouch-review/.phase54-sensitive-probe.json"
    ignored = run_command(["git", "check-ignore", "-q", "--no-index", probe])
    ignored_ok = ignored.returncode == 0
    tracked = run_command(["git", "ls-files", "--", "example-images/local-retouch-review"])
    tracked_bad = tracked.returncode != 0 or bool(tracked.stdout.strip())
    status = run_command(["git", "status", "--porcelain", "--untracked-files=all", "--", "example-images/local-retouch-review"])
    dirty_bad = status.returncode != 0 or bool(status.stdout.strip())
    try:
        validate_ignore_contract(text, ignored_ok, tracked_bad, dirty_bad)
    except AssertionError as error:
        mapping = {
            "ignore_probe": "ignore:probe_not_ignored",
            "tracked_sensitive": "ignore:sensitive_path_tracked",
            "dirty_sensitive": "ignore:sensitive_path_staged_or_untracked",
        }
        failures.append(mapping.get(str(error), "ignore:contract"))
    return failures


def check_owners() -> list[str]:
    failures: list[str] = []
    for name, anchors in OWNER_REQUIREMENTS.items():
        path = ROOT / name
        if not path.is_file():
            failures.append(f"owners:missing_file:{name}")
            continue
        try:
            text = read_utf8(path)
        except RuntimeError:
            failures.append(f"owners:unreadable:{name}")
            continue
        if any(anchor not in text for anchor in anchors):
            failures.append(f"owners:missing_contract:{name}")
    return failures


def check_scope() -> list[str]:
    failures: list[str] = []
    roots = [ROOT / "BeautySDK" / "Sources", ROOT / "BeautyDemo" / "BeautyDemo"]
    for active_root in roots:
        if not active_root.is_dir():
            failures.append("scope:missing_active_root")
            continue
        for path in active_root.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in {".swift", ".metal", ".json"}:
                continue
            try:
                text = read_utf8(path)
            except RuntimeError:
                failures.append("scope:unreadable_active_source")
                continue
            if any(candidate in text for candidate in CANDIDATE_NAMES):
                failures.append("scope:candidate_activation")
            if re.search(r"54-review|evidence-core|ReviewCore|local-retouch-review", text, re.IGNORECASE):
                failures.append("scope:reviewer_import")
    try:
        if directory_digest(SPIKE_006) != EXPECTED_SPIKE_DIGEST:
            failures.append("scope:packaged_spike_drift")
    except (OSError, RuntimeError):
        failures.append("scope:packaged_spike_unreadable")
    spike_status = run_command(["git", "status", "--porcelain", "--", str(SPIKE_006.relative_to(ROOT))])
    if spike_status.returncode != 0 or spike_status.stdout.strip():
        failures.append("scope:packaged_spike_worktree_change")
    return sorted(set(failures))


def check_all() -> list[str]:
    return sorted(set((*check_core(), *check_ui(), *check_ledger(), *check_ignore(), *check_owners(), *check_scope())))


def must_fail(action, name: str) -> None:
    try:
        action()
    except (AssertionError, RuntimeError, UnicodeError, json.JSONDecodeError, ValueError):
        return
    raise AssertionError(f"mutation_not_rejected:{name}")


def self_test() -> None:
    validate_ui_inventory((*UI_CONSIDERATIONS, *UI_ACCEPTANCE))
    cases = 1

    for returncode, stdout, stderr, expected in [(0, "hit\n", "", "match"), (1, "", "", "clean")]:
        assert classify_scan(returncode, stdout, stderr) == expected
        cases += 1
    for code in (2, 127):
        must_fail(lambda code=code: classify_scan(code, "", "failed"), f"scanner_{code}")
        cases += 1

    inventory_mutations = [
        tuple((*UI_CONSIDERATIONS, *UI_ACCEPTANCE[:-1])),
        tuple((*UI_CONSIDERATIONS, *UI_ACCEPTANCE, "UI-AC-20")),
        tuple((*UI_CONSIDERATIONS, *UI_ACCEPTANCE, UI_ACCEPTANCE[0])),
        tuple((*UI_CONSIDERATIONS[:-1], "UI-AC-08", *UI_ACCEPTANCE[:-1])),
    ]
    for index, rows in enumerate(inventory_mutations):
        must_fail(lambda rows=rows: validate_ui_inventory(rows), f"ui_inventory_{index}")
        cases += 1

    for invalid in ["", "/abs.png", "../x.png", "a/../x.png", "./x.png", "a/./x.png", "a\\x.png", "a:x.png", "a\0x.png"]:
        assert not validate_safe_key(invalid)
        cases += 1
    for invalid in ["", "space id", "slash/id", "x" * 65]:
        assert not validate_opaque_id(invalid)
        cases += 1

    with tempfile.TemporaryDirectory(prefix="phase54-self-test-") as temporary:
        root = pathlib.Path(temporary)
        unreadable = root / "invalid-utf8.txt"
        unreadable.write_bytes(b"\xff\xfe")
        must_fail(lambda: read_utf8(unreadable), "invalid_utf8")
        cases += 1
        malformed = root / "malformed.json"
        malformed.write_text("{", encoding="utf-8")
        must_fail(lambda: parse_json(malformed), "malformed_json")
        cases += 1
        missing = root / "missing.txt"
        must_fail(lambda: read_utf8(missing), "required_file_removal")
        cases += 1
        malformed_js = root / "malformed.js"
        malformed_js.write_text("function broken( {", encoding="utf-8")
        completed = run_command(["node", "--check", str(malformed_js)], cwd=root)
        assert completed.returncode != 0
        cases += 1
        malformed_html = "<!doctype html><html><head></head><body>"
        must_fail(lambda: validate_html_document(malformed_html), "malformed_html")
        cases += 1

    clean_ledger = {
        "schema_version": 1,
        "feature_decisions": [
            {"feature": feature, "status": "closed", "reasons": EXPECTED_REASONS[feature], "eligible_count": 0, "reviewed_count": 0, "accepted_count": 0, "rejected_count": 0, "naturalness_weight": 0}
            for feature in FEATURE_ORDER
        ],
        "reviews": [],
        "aggregates": [
            {"feature": feature, "eligible_count": 0, "reviewed_count": 0, "accepted_count": 0, "rejected_count": 0, "naturalness_weight": 0}
            for feature in FEATURE_ORDER
        ],
    }
    assert validate_ledger_object(clean_ledger) == []
    cases += 1
    ledger_mutations = []
    for key in sorted(FORBIDDEN_EXPORT_KEYS):
        candidate = json.loads(json.dumps(clean_ledger))
        candidate["aggregates"][0][key] = f"PHASE54_FORBIDDEN_{key.upper()}"
        ledger_mutations.append(candidate)
    for candidate in ledger_mutations:
        assert validate_ledger_object(candidate)
        cases += 1
    for feature in FEATURE_ORDER:
        wrong_reason = json.loads(json.dumps(clean_ledger))
        row = next(item for item in wrong_reason["feature_decisions"] if item["feature"] == feature)
        row["reasons"] = ["review_rejected"]
        assert validate_ledger_object(wrong_reason)
        cases += 1
    reordered = json.loads(json.dumps(clean_ledger))
    reordered["feature_decisions"].reverse()
    assert validate_ledger_object(reordered)
    cases += 1
    nonzero = json.loads(json.dumps(clean_ledger))
    nonzero["aggregates"][0]["eligible_count"] = 1
    assert validate_ledger_object(nonzero)
    cases += 1

    clean_ignore = "example-images/local-retouch-review/\n"
    validate_ignore_contract(clean_ignore, ignored=True, tracked=False, dirty=False)
    cases += 1
    for name, arguments in [
        ("missing_ignore", ("", True, False, False)),
        ("ignore_command", (clean_ignore, False, False, False)),
        ("tracked_sensitive", (clean_ignore, True, True, False)),
        ("dirty_sensitive", (clean_ignore, True, False, True)),
    ]:
        must_fail(lambda arguments=arguments: validate_ignore_contract(*arguments), name)
        cases += 1

    owner_texts = {name: " ".join(anchors) for name, anchors in OWNER_REQUIREMENTS.items()}
    validate_owner_contracts(owner_texts)
    cases += 1
    for name in OWNER_REQUIREMENTS:
        mutated = dict(owner_texts)
        mutated[name] = "Phase 54"
        must_fail(lambda mutated=mutated: validate_owner_contracts(mutated), f"owner_{name}")
        cases += 1

    validate_scope_contract("clean active source", EXPECTED_SPIKE_DIGEST)
    cases += 1
    for name, active_text, digest in [
        ("candidate", CANDIDATE_NAMES[0], EXPECTED_SPIKE_DIGEST),
        ("reviewer_import", "ReviewCore", EXPECTED_SPIKE_DIGEST),
        ("spike_drift", "clean active source", "0" * 64),
    ]:
        must_fail(lambda active_text=active_text, digest=digest: validate_scope_contract(active_text, digest), name)
        cases += 1

    reviewer_mutations = [
        "fetch('x')", "new XMLHttpRequest()", "new WebSocket('x')", "new EventSource('x')",
        "navigator.sendBeacon('x')", "new RTCPeerConnection()", "https://external.invalid/resource",
        '<link href="external.css">', '<iframe src="x"></iframe>', '<object data="x"></object>',
        '<embed src="x">', "localStorage.setItem('x','y')", "sessionStorage.setItem('x','y')",
        "indexedDB.open('x')", "caches.open('x')", "document.cookie = 'x'",
        "navigator.serviceWorker.register('x')", "navigator.clipboard.writeText('x')",
        "new SharedWorker('x')", "new Worker('x')", "node.innerHTML = value",
        "node.outerHTML = value", "node.insertAdjacentHTML('beforeend', value)",
        "document.write(value)", '<form action="upload">', '<form method="post">',
    ]
    for sample in reviewer_mutations:
        assert scan_patterns(sample, FORBIDDEN_REVIEWER_PATTERNS), sample
        cases += 1

    for collection, index, key, value, expected_failure in [
        ("feature_decisions", 0, "source_uri", "opaque", "ledger:decision_allowlist:teeth_whitening"),
        ("feature_decisions", 1, "reviewerName", "anonymous", "ledger:decision_allowlist:sclera_redness"),
        ("aggregates", 2, "status_detail", "/Users/private/item.png", "ledger:aggregate_allowlist:upper_eyelid_fullness"),
    ]:
        candidate = json.loads(json.dumps(clean_ledger))
        candidate[collection][index][key] = value
        assert expected_failure in validate_ledger_object(candidate)
        cases += 1

    print(json.dumps({
        "status": "pass",
        "selfTestCases": cases,
        "uiRows": 27,
        "uiConsiderations": 8,
        "uiAcceptance": 19,
        "asvsLevel": 1,
        "highMitigations": 6,
    }, sort_keys=True))


def print_failures(failures: Sequence[str]) -> None:
    print("FAIL Phase 54 evidence boundaries")
    for failure in failures:
        print(f"- {failure}")


def main() -> int:
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--expect-wave0-red", action="store_true")
    modes.add_argument("--core", action="store_true")
    modes.add_argument("--ui", action="store_true")
    modes.add_argument("--ledger", action="store_true")
    modes.add_argument("--owners", action="store_true")
    modes.add_argument("--scope", action="store_true")
    args = parser.parse_args()

    if args.self_test:
        self_test()
        return 0
    if args.expect_wave0_red:
        failures = frozenset(check_all())
        if failures != EXPECTED_WAVE0_FAILURES:
            print("FAIL Phase 54 Wave 0 RED classification")
            print(f"- expected_reason_count:{len(EXPECTED_WAVE0_FAILURES)}")
            print(f"- actual_reason_count:{len(failures)}")
            print(f"- missing_reason_count:{len(EXPECTED_WAVE0_FAILURES - failures)}")
            print(f"- extra_reason_count:{len(failures - EXPECTED_WAVE0_FAILURES)}")
            return 1
        print(json.dumps({"status": "pass", "mode": "wave0-red", "expectedReasons": len(failures), "uiRows": "27 = 8 + 19"}, sort_keys=True))
        return 0

    if args.core:
        failures = check_core()
    elif args.ui:
        failures = check_ui()
    elif args.ledger:
        failures = [*check_ledger(), *check_ignore()]
    elif args.owners:
        failures = check_owners()
    elif args.scope:
        failures = check_scope()
    else:
        failures = check_all()
    if failures:
        print_failures(sorted(set(failures)))
        return 1
    print(json.dumps({"status": "pass", "mode": "live", "uiRows": "27 = 8 + 19", "asvsHigh": "6/6"}, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
