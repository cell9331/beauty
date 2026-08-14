#!/usr/bin/env python3
"""Create, verify, reproduce, and safely retire the two legacy UI trees.

The live filesystem is authoritative.  Git inventory is deliberately not used
to decide archive membership because the legacy reference PNG files are
intentionally ignored.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import subprocess
import sys
import tempfile
from typing import Dict, Iterable, List, Mapping, NamedTuple, Optional, Sequence, Set, Tuple
import zipfile


SOURCE_ROOTS: Tuple[str, ...] = ("BeautyDemo", "meituxiuxiu")
ARCHIVE_DIRECTORY = Path("archives/legacy-ui")
ARCHIVE_VERSION = "v1.16"
ZIP_TIMESTAMP = (1980, 1, 1, 0, 0, 0)
NORMALIZED_FILE_MODE = 0o100644
PNG_REFERENCES: Tuple[str, ...] = tuple(
    [f"IMG_{number:04d}.PNG" for number in range(856, 871)]
    + [f"home/IMG_{number:04d}.PNG" for number in range(871, 875)]
)
EXCLUDED_COMPONENTS = frozenset(
    {".build", ".cache", "cache", "caches", "Caches", "__pycache__", "xcuserdata"}
)
EXCLUDED_FILENAMES = frozenset({".DS_Store"})
SENTINEL_PATHS: Tuple[str, ...] = (
    "BeautySDK/Package.swift",
    "ARCHITECTURE.md",
    ".planning/PROJECT.md",
    "example-images/FIXTURE_AUTHORIZATION.md",
)
OPTIONAL_PRIVATE_FIXTURE_SENTINELS: Tuple[str, ...] = (
    "example-images/input/portraits/p1.jpg",
)


class ArchiveError(RuntimeError):
    """A fail-closed archive or retirement validation failure."""


class InventoryEntry(NamedTuple):
    archive_path: str
    size: int
    sha256: str
    data: bytes


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def run_git(repo_root: Path, arguments: Sequence[str]) -> bytes:
    result = subprocess.run(
        ["git", "-C", str(repo_root), *arguments],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        detail = result.stderr.decode("utf-8", errors="replace").strip()
        raise ArchiveError(f"git {' '.join(arguments)} failed: {detail}")
    return result.stdout


def resolve_repo_root(candidate: Optional[Path] = None) -> Path:
    root = (candidate or Path(__file__).resolve().parents[1]).resolve()
    try:
        git_root = Path(
            run_git(root, ["rev-parse", "--show-toplevel"])
            .decode("utf-8")
            .strip()
        ).resolve()
    except ArchiveError as error:
        raise ArchiveError(f"archive tool must run inside its Git repository: {error}")
    if git_root != root:
        raise ArchiveError(f"unexpected repository root: expected {root}, Git reported {git_root}")
    return root


def exclusion_reason(relative_path: PurePosixPath) -> Optional[str]:
    parts = relative_path.parts
    if any(part in EXCLUDED_FILENAMES for part in parts):
        return ".DS_Store"
    if any(part in EXCLUDED_COMPONENTS for part in parts):
        return "build/cache/per-user directory"
    if any(part.endswith(".xcuserstate") for part in parts):
        return "per-user Xcode state"
    return None


def validate_source_root(repo_root: Path, source_name: str) -> Path:
    if source_name not in SOURCE_ROOTS:
        raise ArchiveError(f"unexpected source root {source_name!r}; expected {SOURCE_ROOTS}")
    source = repo_root / source_name
    if source.is_symlink():
        raise ArchiveError(f"source root must not be a symlink: {source_name}")
    if not source.is_dir():
        raise ArchiveError(f"required source directory is missing: {source_name}/")
    if source.resolve() != source:
        raise ArchiveError(f"source root does not resolve to the exact repository target: {source}")
    if source.parent != repo_root:
        raise ArchiveError(f"source root escaped repository root: {source}")
    return source


def inventory_source(repo_root: Path, source_name: str) -> Tuple[InventoryEntry, ...]:
    """Enumerate one live source independently and reject every symlink."""

    source = validate_source_root(repo_root, source_name)
    entries: List[InventoryEntry] = []
    stack = [source]
    while stack:
        directory = stack.pop()
        try:
            children = sorted(os.scandir(str(directory)), key=lambda item: os.fsencode(item.name))
        except OSError as error:
            raise ArchiveError(f"cannot enumerate {directory}: {error}")
        for child in children:
            child_path = Path(child.path)
            relative = PurePosixPath(child_path.relative_to(source).as_posix())
            try:
                mode = child.stat(follow_symlinks=False).st_mode
            except OSError as error:
                raise ArchiveError(f"cannot stat {child_path}: {error}")
            if stat.S_ISLNK(mode):
                raise ArchiveError(f"symlinks are forbidden in archive sources: {source_name}/{relative}")
            if exclusion_reason(relative) is not None:
                continue
            if stat.S_ISDIR(mode):
                stack.append(child_path)
                continue
            if not stat.S_ISREG(mode):
                raise ArchiveError(f"unsupported filesystem entry: {source_name}/{relative}")
            try:
                data = child_path.read_bytes()
            except OSError as error:
                raise ArchiveError(f"cannot read {child_path}: {error}")
            archive_path = f"{source_name}/{relative.as_posix()}"
            entries.append(InventoryEntry(archive_path, len(data), sha256_bytes(data), data))

    entries.sort(key=lambda entry: os.fsencode(entry.archive_path))
    if not entries:
        raise ArchiveError(f"source inventory is unexpectedly empty: {source_name}/")
    if source_name == "meituxiuxiu":
        actual = {
            entry.archive_path[len("meituxiuxiu/") :]
            for entry in entries
            if entry.archive_path.lower().endswith(".png")
        }
        expected = set(PNG_REFERENCES)
        if actual != expected:
            missing = sorted(expected - actual)
            extra = sorted(actual - expected)
            raise ArchiveError(
                "meituxiuxiu PNG inventory must be the exact 19 references; "
                f"missing={missing}, extra={extra}"
            )
    return tuple(entries)


def inventory_signature(entries: Iterable[InventoryEntry]) -> Tuple[Tuple[str, int, str], ...]:
    return tuple((entry.archive_path, entry.size, entry.sha256) for entry in entries)


def manifest_bytes(entries: Sequence[InventoryEntry]) -> bytes:
    lines = ["path\tsize\tsha256"]
    lines.extend(f"{entry.archive_path}\t{entry.size}\t{entry.sha256}" for entry in entries)
    return ("\n".join(lines) + "\n").encode("utf-8")


def parse_manifest(data: bytes, source_name: str) -> Tuple[Tuple[str, int, str], ...]:
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError as error:
        raise ArchiveError(f"{source_name} manifest is not UTF-8: {error}")
    lines = text.splitlines()
    if not lines or lines[0] != "path\tsize\tsha256":
        raise ArchiveError(f"{source_name} manifest has an invalid header")
    parsed: List[Tuple[str, int, str]] = []
    for line_number, line in enumerate(lines[1:], start=2):
        fields = line.split("\t")
        if len(fields) != 3:
            raise ArchiveError(f"{source_name} manifest line {line_number} is malformed")
        path, size_text, digest = fields
        validate_archive_path(path, source_name)
        try:
            size = int(size_text)
        except ValueError:
            raise ArchiveError(f"{source_name} manifest line {line_number} has invalid size")
        if size < 0 or len(digest) != 64 or any(c not in "0123456789abcdef" for c in digest):
            raise ArchiveError(f"{source_name} manifest line {line_number} has invalid metadata")
        parsed.append((path, size, digest))
    if parsed != sorted(parsed, key=lambda row: os.fsencode(row[0])):
        raise ArchiveError(f"{source_name} manifest is not sorted")
    paths = [row[0] for row in parsed]
    if len(paths) != len(set(paths)):
        raise ArchiveError(f"{source_name} manifest contains duplicate paths")
    return tuple(parsed)


def deterministic_zip_bytes(entries: Sequence[InventoryEntry]) -> bytes:
    buffer = io.BytesIO()
    with zipfile.ZipFile(
        buffer,
        mode="w",
        compression=zipfile.ZIP_DEFLATED,
        compresslevel=9,
        allowZip64=True,
    ) as archive:
        for entry in entries:
            info = zipfile.ZipInfo(entry.archive_path, date_time=ZIP_TIMESTAMP)
            info.create_system = 3
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = NORMALIZED_FILE_MODE << 16
            info.flag_bits |= 0x800
            archive.writestr(info, entry.data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    return buffer.getvalue()


def validate_archive_path(path_text: str, source_name: str) -> None:
    if "\\" in path_text or "\x00" in path_text:
        raise ArchiveError(f"unsafe ZIP path: {path_text!r}")
    path = PurePosixPath(path_text)
    if path.is_absolute() or not path.parts or any(part in ("", ".", "..") for part in path.parts):
        raise ArchiveError(f"unsafe ZIP path: {path_text!r}")
    if path.parts[0] != source_name or len(path.parts) < 2:
        raise ArchiveError(f"ZIP path is outside {source_name}/: {path_text!r}")


def bundle_paths(output: Path, source_name: str) -> Tuple[Path, Path, Path]:
    stem = f"{source_name}-{ARCHIVE_VERSION}"
    return (
        output / f"{stem}.zip",
        output / f"{stem}.manifest.tsv",
        output / f"{stem}.zip.sha256",
    )


def digest_record_bytes(source_name: str, zip_digest: str) -> bytes:
    return f"{zip_digest}  {source_name}-{ARCHIVE_VERSION}.zip\n".encode("ascii")


def parse_digest_record(data: bytes, source_name: str) -> str:
    expected_suffix = f"  {source_name}-{ARCHIVE_VERSION}.zip\n"
    try:
        text = data.decode("ascii")
    except UnicodeDecodeError as error:
        raise ArchiveError(f"{source_name} digest record is not ASCII: {error}")
    if not text.endswith(expected_suffix):
        raise ArchiveError(f"{source_name} digest record has an unexpected filename")
    digest = text[: -len(expected_suffix)]
    if len(digest) != 64 or any(c not in "0123456789abcdef" for c in digest):
        raise ArchiveError(f"{source_name} digest record has an invalid SHA-256")
    return digest


def write_atomic(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", dir=str(path.parent))
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary, 0o644)
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()


def create_bundle(
    repo_root: Path,
    output: Path,
    source_name: str,
    expected_preflight: Sequence[InventoryEntry],
    dry_run: bool,
) -> Tuple[str, int]:
    # This second walk is intentionally independent of the caller's preflight.
    live_entries = inventory_source(repo_root, source_name)
    if inventory_signature(live_entries) != inventory_signature(expected_preflight):
        raise ArchiveError(f"{source_name} changed between independent preflight and creation")
    zip_data = deterministic_zip_bytes(live_entries)
    manifest_data = manifest_bytes(live_entries)
    zip_digest = sha256_bytes(zip_data)
    verify_bundle_bytes(source_name, zip_data, manifest_data, digest_record_bytes(source_name, zip_digest))
    if not dry_run:
        zip_path, manifest_path, digest_path = bundle_paths(output, source_name)
        write_atomic(zip_path, zip_data)
        write_atomic(manifest_path, manifest_data)
        write_atomic(digest_path, digest_record_bytes(source_name, zip_digest))
        verify_bundle(output, source_name)
    return zip_digest, len(live_entries)


def create_all(repo_root: Path, output: Path, dry_run: bool = False) -> Mapping[str, str]:
    if output.exists() and output.is_symlink():
        raise ArchiveError(f"archive output directory must not be a symlink: {output}")
    preflight = {source: inventory_source(repo_root, source) for source in SOURCE_ROOTS}
    results: Dict[str, str] = {}
    for source in SOURCE_ROOTS:
        digest, count = create_bundle(repo_root, output, source, preflight[source], dry_run)
        results[source] = digest
        action = "DRY-RUN" if dry_run else "CREATED"
        print(f"{action} {source}: files={count} zip_sha256={digest}")
    return results


def verify_bundle_bytes(source_name: str, zip_data: bytes, manifest_data: bytes, digest_data: bytes) -> str:
    recorded_digest = parse_digest_record(digest_data, source_name)
    actual_digest = sha256_bytes(zip_data)
    if recorded_digest != actual_digest:
        raise ArchiveError(f"{source_name} ZIP SHA-256 does not match its record")
    manifest = parse_manifest(manifest_data, source_name)
    manifest_by_path = {path: (size, digest) for path, size, digest in manifest}
    try:
        with zipfile.ZipFile(io.BytesIO(zip_data), "r") as archive:
            bad = archive.testzip()
            if bad is not None:
                raise ArchiveError(f"{source_name} ZIP CRC failed for {bad}")
            infos = archive.infolist()
            paths = [info.filename for info in infos]
            if paths != sorted(paths, key=os.fsencode) or len(paths) != len(set(paths)):
                raise ArchiveError(f"{source_name} ZIP inventory is unsorted or duplicated")
            if any(info.is_dir() for info in infos):
                raise ArchiveError(f"{source_name} ZIP must contain files only")
            for info in infos:
                validate_archive_path(info.filename, source_name)
                if info.date_time != ZIP_TIMESTAMP:
                    raise ArchiveError(f"{source_name} ZIP has a non-normalized timestamp")
                if info.create_system != 3 or (info.external_attr >> 16) != NORMALIZED_FILE_MODE:
                    raise ArchiveError(f"{source_name} ZIP has a non-normalized mode")
            if set(paths) != set(manifest_by_path):
                raise ArchiveError(f"{source_name} ZIP and manifest path inventories differ")
            for info in infos:
                data = archive.read(info)
                expected_size, expected_digest = manifest_by_path[info.filename]
                if len(data) != expected_size or sha256_bytes(data) != expected_digest:
                    raise ArchiveError(f"{source_name} content mismatch: {info.filename}")
    except zipfile.BadZipFile as error:
        raise ArchiveError(f"{source_name} ZIP is invalid: {error}")

    # Extraction is a separate check, not an assertion over in-memory ZIP reads.
    with tempfile.TemporaryDirectory(prefix=f"archive-{source_name}-extract-") as directory:
        extraction_root = Path(directory)
        with zipfile.ZipFile(io.BytesIO(zip_data), "r") as archive:
            for info in archive.infolist():
                validate_archive_path(info.filename, source_name)
                destination = extraction_root.joinpath(*PurePosixPath(info.filename).parts)
                destination.parent.mkdir(parents=True, exist_ok=True)
                with archive.open(info, "r") as source, destination.open("wb") as target:
                    shutil.copyfileobj(source, target)
        extracted: Dict[str, Tuple[int, str]] = {}
        for path in extraction_root.rglob("*"):
            if path.is_symlink():
                raise ArchiveError(f"extraction produced a symlink: {path}")
            if path.is_file():
                relative = path.relative_to(extraction_root).as_posix()
                extracted[relative] = (path.stat().st_size, sha256_file(path))
        if extracted != manifest_by_path:
            raise ArchiveError(f"{source_name} extracted inventory/content differs from manifest")
    return actual_digest


def verify_bundle(output: Path, source_name: str) -> str:
    zip_path, manifest_path, digest_path = bundle_paths(output, source_name)
    for path in (zip_path, manifest_path, digest_path):
        if path.is_symlink() or not path.is_file():
            raise ArchiveError(f"required archive artifact is missing or symlinked: {path}")
    return verify_bundle_bytes(
        source_name,
        zip_path.read_bytes(),
        manifest_path.read_bytes(),
        digest_path.read_bytes(),
    )


def verify_all(output: Path) -> Mapping[str, str]:
    results: Dict[str, str] = {}
    for source in SOURCE_ROOTS:
        digest = verify_bundle(output, source)
        results[source] = digest
        print(f"VERIFIED {source}: zip_sha256={digest}")
    return results


def reproduce_all(repo_root: Path, output: Path) -> Mapping[str, str]:
    recorded = verify_all(output)
    with tempfile.TemporaryDirectory(prefix="legacy-ui-reproduce-") as directory:
        reproduction = Path(directory)
        create_all(repo_root, reproduction)
        for source in SOURCE_ROOTS:
            for recorded_path, reproduced_path in zip(bundle_paths(output, source), bundle_paths(reproduction, source)):
                if recorded_path.read_bytes() != reproduced_path.read_bytes():
                    raise ArchiveError(
                        f"reproduction differs for {source}: {recorded_path.name}"
                    )
    print("REPRODUCED both archives byte-for-byte from the live filesystem")
    return recorded


def tracked_paths(repo_root: Path, source_names: Sequence[str]) -> Set[str]:
    raw = run_git(repo_root, ["ls-files", "-z", "--", *source_names])
    return {item.decode("utf-8") for item in raw.split(b"\0") if item}


def deleted_tracked_paths(repo_root: Path) -> Set[str]:
    raw = run_git(repo_root, ["diff", "--name-only", "--diff-filter=D", "-z", "--"])
    return {item.decode("utf-8") for item in raw.split(b"\0") if item}


def sentinel_fingerprints(repo_root: Path) -> Mapping[str, str]:
    fingerprints: Dict[str, str] = {}
    for relative in SENTINEL_PATHS:
        path = repo_root / relative
        if path.is_symlink() or not path.is_file():
            raise ArchiveError(f"required retirement sentinel is missing or symlinked: {relative}")
        fingerprints[relative] = sha256_file(path)
    for relative in OPTIONAL_PRIVATE_FIXTURE_SENTINELS:
        path = repo_root / relative
        if path.is_symlink():
            raise ArchiveError(f"private fixture sentinel must not be a symlink: {relative}")
        if path.is_file():
            fingerprints[relative] = sha256_file(path)
    return fingerprints


def parse_approvals(values: Sequence[str]) -> Mapping[str, str]:
    parsed: Dict[str, str] = {}
    for value in values:
        if "=" not in value:
            raise ArchiveError(f"approval must use SOURCE=SHA256: {value!r}")
        source, digest = value.split("=", 1)
        if source not in SOURCE_ROOTS or source in parsed:
            raise ArchiveError(f"unexpected or duplicate digest approval: {source!r}")
        if len(digest) != 64 or any(c not in "0123456789abcdef" for c in digest):
            raise ArchiveError(f"invalid approved SHA-256 for {source}")
        parsed[source] = digest
    if set(parsed) != set(SOURCE_ROOTS):
        raise ArchiveError(f"retirement requires one digest approval for each of {SOURCE_ROOTS}")
    return parsed


def retire_sources(
    repo_root: Path,
    output: Path,
    approvals: Mapping[str, str],
    confirmation: bool,
) -> None:
    if not confirmation:
        raise ArchiveError("retirement requires --yes-retire-exact-sources")
    sources = {source: validate_source_root(repo_root, source) for source in SOURCE_ROOTS}
    expected_deletions = tracked_paths(repo_root, list(SOURCE_ROOTS))
    for path in expected_deletions:
        if not (repo_root / path).is_file():
            raise ArchiveError(f"tracked source is already absent before retirement: {path}")
    deleted_before = deleted_tracked_paths(repo_root)
    sentinels_before = sentinel_fingerprints(repo_root)

    # Fresh reproduction contains the combined source/manifest/ZIP/extraction gate.
    recorded = reproduce_all(repo_root, output)
    if dict(recorded) != dict(approvals):
        raise ArchiveError(
            "digest approval does not match the freshly verified archives: "
            f"expected={dict(recorded)}, approved={dict(approvals)}"
        )

    quarantine = Path(tempfile.mkdtemp(prefix="beauty-legacy-ui-retire-", dir=str(repo_root.parent)))
    moved: List[Tuple[Path, Path]] = []
    try:
        for source in SOURCE_ROOTS:
            original = sources[source]
            staged = quarantine / source
            os.replace(original, staged)
            moved.append((original, staged))

        deleted_after_move = deleted_tracked_paths(repo_root)
        new_deletions = deleted_after_move - deleted_before
        if new_deletions != expected_deletions:
            raise ArchiveError(
                "retirement tracked deletion set differs from its exact precomputed allowlist: "
                f"missing={sorted(expected_deletions - new_deletions)}, "
                f"extra={sorted(new_deletions - expected_deletions)}"
            )
        if sentinel_fingerprints(repo_root) != sentinels_before:
            raise ArchiveError("SDK/docs/planning/private-fixture sentinels changed during retirement")
    except BaseException:
        for original, staged in reversed(moved):
            if staged.exists() and not original.exists():
                os.replace(staged, original)
        shutil.rmtree(quarantine, ignore_errors=True)
        raise

    # Irreversible deletion happens only after both exact roots passed every gate.
    shutil.rmtree(quarantine)
    if any(path.exists() for path in sources.values()):
        raise ArchiveError("retirement finished with a legacy source still present")
    if sentinel_fingerprints(repo_root) != sentinels_before:
        raise ArchiveError("a required sentinel changed after retirement")
    print("RETIRED exact sources: BeautyDemo/ and meituxiuxiu/")


def verify_retirement_postcondition(repo_root: Path, output: Path) -> None:
    verify_all(output)
    present = [source for source in SOURCE_ROOTS if (repo_root / source).exists()]
    if present:
        raise ArchiveError(f"retirement postcondition found legacy sources: {present}")
    expected_deletions = tracked_paths(repo_root, list(SOURCE_ROOTS))
    actual_deletions = deleted_tracked_paths(repo_root)
    if actual_deletions != expected_deletions:
        raise ArchiveError(
            "retirement postcondition deletion set differs from the exact tracked allowlist: "
            f"missing={sorted(expected_deletions - actual_deletions)}, "
            f"extra={sorted(actual_deletions - expected_deletions)}"
        )
    sentinel_fingerprints(repo_root)
    print("RETIREMENT POSTCONDITION VERIFIED")


def initialize_self_test_repo(repo_root: Path) -> None:
    subprocess.run(["git", "init", "-q", str(repo_root)], check=True)
    subprocess.run(["git", "-C", str(repo_root), "config", "user.email", "archive@test.invalid"], check=True)
    subprocess.run(["git", "-C", str(repo_root), "config", "user.name", "Archive Self Test"], check=True)
    for source in SOURCE_ROOTS:
        (repo_root / source).mkdir(parents=True)
    (repo_root / "BeautyDemo" / "Demo.swift").write_text("import Foundation\n", encoding="utf-8")
    (repo_root / "BeautyDemo" / ".DS_Store").write_bytes(b"excluded")
    (repo_root / "BeautyDemo" / "project.xcworkspace" / "xcuserdata").mkdir(parents=True)
    (repo_root / "BeautyDemo" / "project.xcworkspace" / "xcuserdata" / "state").write_bytes(b"excluded")
    (repo_root / "BeautyDemo" / "state.xcuserstate").write_bytes(b"excluded")
    (repo_root / "BeautyDemo" / ".build").mkdir()
    (repo_root / "BeautyDemo" / ".build" / "output").write_bytes(b"excluded")
    (repo_root / "meituxiuxiu" / "FUNCTION_MAP.md").write_text("taxonomy\n", encoding="utf-8")
    for relative in PNG_REFERENCES:
        path = repo_root / "meituxiuxiu" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(b"PNG\r\n" + relative.encode("ascii"))
    for relative in SENTINEL_PATHS + OPTIONAL_PRIVATE_FIXTURE_SENTINELS:
        path = repo_root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(f"sentinel:{relative}\n".encode("utf-8"))
    subprocess.run(["git", "-C", str(repo_root), "add", "."], check=True)
    subprocess.run(["git", "-C", str(repo_root), "commit", "-qm", "self-test fixture"], check=True)


def require_archive_error(action, description: str) -> None:
    try:
        action()
    except ArchiveError:
        return
    raise ArchiveError(f"self-test expected rejection: {description}")


def self_test() -> None:
    with tempfile.TemporaryDirectory(prefix="archive-legacy-ui-self-test-") as directory:
        root = Path(directory).resolve()
        initialize_self_test_repo(root)
        output = root / ARCHIVE_DIRECTORY
        created = create_all(root, output)
        if verify_all(output) != created:
            raise ArchiveError("self-test verification digests differ from creation")
        if reproduce_all(root, output) != created:
            raise ArchiveError("self-test reproduction digests differ from creation")
        sources_before = {source: inventory_signature(inventory_source(root, source)) for source in SOURCE_ROOTS}
        create_all(root, output, dry_run=True)
        if sources_before != {source: inventory_signature(inventory_source(root, source)) for source in SOURCE_ROOTS}:
            raise ArchiveError("create/verify self-test modified a source tree")

        # Tamper and unsafe-path checks must fail closed.
        zip_path, manifest_path, digest_path = bundle_paths(output, "BeautyDemo")
        original_manifest = manifest_path.read_bytes()
        manifest_path.write_bytes(original_manifest + b"BeautyDemo/extra\t0\t" + b"0" * 64 + b"\n")
        require_archive_error(
            lambda: verify_bundle(output, "BeautyDemo"),
            "tampered manifest",
        )
        manifest_path.write_bytes(original_manifest)
        malicious_buffer = io.BytesIO()
        with zipfile.ZipFile(malicious_buffer, "w") as archive:
            archive.writestr("../escape", b"bad")
        malicious = malicious_buffer.getvalue()
        require_archive_error(
            lambda: verify_bundle_bytes(
                "BeautyDemo",
                malicious,
                b"path\tsize\tsha256\n",
                digest_record_bytes("BeautyDemo", sha256_bytes(malicious)),
            ),
            "unsafe ZIP path",
        )
        link = root / "BeautyDemo" / "forbidden-link"
        link.symlink_to("Demo.swift")
        require_archive_error(
            lambda: inventory_source(root, "BeautyDemo"),
            "source symlink",
        )
        link.unlink()

        retire_sources(root, output, created, confirmation=True)
        if any((root / source).exists() for source in SOURCE_ROOTS):
            raise ArchiveError("self-test retirement left a source root")
        verify_retirement_postcondition(root, output)
    print("SELF-TEST PASSED")


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="command", required=True)
    for command in ("create", "verify", "reproduce"):
        subparser = subparsers.add_parser(command)
        subparser.add_argument("--output", type=Path, default=ARCHIVE_DIRECTORY)
        if command == "create":
            subparser.add_argument("--dry-run", action="store_true")
    retire = subparsers.add_parser("retire")
    retire.add_argument("--output", type=Path, default=ARCHIVE_DIRECTORY)
    retire.add_argument("--approve-digest", action="append", default=[], metavar="SOURCE=SHA256")
    retire.add_argument("--yes-retire-exact-sources", action="store_true")
    retire.add_argument("--verify-only-postcondition", action="store_true")
    subparsers.add_parser("self-test")
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> int:
    try:
        arguments = parse_arguments(argv)
        if arguments.command == "self-test":
            self_test()
            return 0
        repo_root = resolve_repo_root()
        output_argument = arguments.output
        output = output_argument if output_argument.is_absolute() else repo_root / output_argument
        output = output.resolve()
        if arguments.command == "create":
            create_all(repo_root, output, dry_run=arguments.dry_run)
        elif arguments.command == "verify":
            verify_all(output)
        elif arguments.command == "reproduce":
            reproduce_all(repo_root, output)
        elif arguments.command == "retire":
            if output != repo_root / ARCHIVE_DIRECTORY:
                raise ArchiveError(
                    f"retire requires the repository-owned archive directory {ARCHIVE_DIRECTORY}"
                )
            if arguments.verify_only_postcondition:
                if arguments.approve_digest or arguments.yes_retire_exact_sources:
                    raise ArchiveError(
                        "--verify-only-postcondition cannot be combined with mutation approvals"
                    )
                verify_retirement_postcondition(repo_root, output)
            else:
                retire_sources(
                    repo_root,
                    output,
                    parse_approvals(arguments.approve_digest),
                    arguments.yes_retire_exact_sources,
                )
        return 0
    except ArchiveError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
