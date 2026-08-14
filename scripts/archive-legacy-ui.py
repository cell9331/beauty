#!/usr/bin/env python3
"""Create, verify, reproduce, and safely retire the two legacy UI trees.

The live filesystem is authoritative.  Git inventory is deliberately not used
to decide archive membership because the legacy reference PNG files are
intentionally ignored.
"""

from __future__ import annotations

import argparse
from contextlib import ExitStack
import hashlib
import io
import os
from pathlib import Path, PurePosixPath
import shutil
import stat
import subprocess
import sys
import tempfile
from typing import BinaryIO, Callable, Dict, Iterable, List, Mapping, NamedTuple, Optional, Sequence, Set, Tuple
import zipfile


SOURCE_ROOTS: Tuple[str, ...] = ("BeautyDemo", "meituxiuxiu")
ARCHIVE_DIRECTORY = Path("archives/legacy-ui")
ARCHIVE_VERSION = "v1.16"
ZIP_TIMESTAMP = (1980, 1, 1, 0, 0, 0)
NORMALIZED_FILE_MODE = 0o100644
IO_CHUNK_SIZE = 1024 * 1024
MAX_MANIFEST_BYTES = 1024 * 1024
MAX_DIGEST_RECORD_BYTES = 256
MAX_COMPRESSION_RATIO = 20.0
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


class BundlePolicy(NamedTuple):
    zip_sha256: str
    manifest_sha256: str
    zip_size: int
    entry_count: int
    total_uncompressed_size: int
    maximum_entry_size: int
    maximum_compression_ratio: float
    paths: Tuple[str, ...]


CANONICAL_BUNDLE_POLICIES: Mapping[str, BundlePolicy] = {
    "BeautyDemo": BundlePolicy(
        zip_sha256="04c14bbaa201cc6e9100f4c7b272b697670014041e62804dfa2f561faa29db52",
        manifest_sha256="38314c3aa1e70918921e660308bf64b78ca85b5fac4a222ef66ae5e80250f694",
        zip_size=79_721,
        entry_count=45,
        total_uncompressed_size=342_685,
        maximum_entry_size=38_963,
        maximum_compression_ratio=MAX_COMPRESSION_RATIO,
        paths=(
            "BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj",
            "BeautyDemo/BeautyDemo.xcodeproj/project.xcworkspace/contents.xcworkspacedata",
            "BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift",
            "BeautyDemo/BeautyDemo/Assets.xcassets/AccentColor.colorset/Contents.json",
            "BeautyDemo/BeautyDemo/Assets.xcassets/AppIcon.appiconset/Contents.json",
            "BeautyDemo/BeautyDemo/Assets.xcassets/Contents.json",
            "BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift",
            "BeautyDemo/BeautyDemo/Camera/CameraPermissionClient.swift",
            "BeautyDemo/BeautyDemo/Camera/CameraPreviewLayerView.swift",
            "BeautyDemo/BeautyDemo/Camera/CameraPreviewModels.swift",
            "BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift",
            "BeautyDemo/BeautyDemo/ContentView.swift",
            "BeautyDemo/BeautyDemo/Editor/CompareState.swift",
            "BeautyDemo/BeautyDemo/Editor/DetectionStatusPresentation.swift",
            "BeautyDemo/BeautyDemo/Editor/EditorShellView.swift",
            "BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift",
            "BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift",
            "BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift",
            "BeautyDemo/BeautyDemo/Editor/MeituEditorToolPanelView.swift",
            "BeautyDemo/BeautyDemo/Editor/ParameterJSONSheetView.swift",
            "BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayState.swift",
            "BeautyDemo/BeautyDemo/Editor/PreviewDebugOverlayView.swift",
            "BeautyDemo/BeautyDemo/Home/MeituHomeModels.swift",
            "BeautyDemo/BeautyDemo/Home/MeituHomeView.swift",
            "BeautyDemo/BeautyDemo/Panel/BeautyCategoryModels.swift",
            "BeautyDemo/BeautyDemo/Panel/BeautyCategoryRailView.swift",
            "BeautyDemo/BeautyDemo/Panel/BeautyControlDescriptor.swift",
            "BeautyDemo/BeautyDemo/Panel/BeautyModeEntryView.swift",
            "BeautyDemo/BeautyDemo/Panel/BeautyPanelView.swift",
            "BeautyDemo/BeautyDemo/Panel/BeautyResourcePickerModels.swift",
            "BeautyDemo/BeautyDemo/Panel/BeautySliderView.swift",
            "BeautyDemo/BeautyDemo/State/BeautyParameterStore.swift",
            "BeautyDemo/BeautyDemo/State/ParameterJSONCoding.swift",
            "BeautyDemo/BeautyDemo/Support/DemoFixtures.swift",
            "BeautyDemo/BeautyDemoTests/BeautyCategoryModelTests.swift",
            "BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift",
            "BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift",
            "BeautyDemo/BeautyDemoTests/BeautyParameterStoreTests.swift",
            "BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift",
            "BeautyDemo/BeautyDemoTests/CameraPermissionStateTests.swift",
            "BeautyDemo/BeautyDemoTests/CameraSessionControllerTests.swift",
            "BeautyDemo/BeautyDemoTests/CompareStateTests.swift",
            "BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift",
            "BeautyDemo/BeautyDemoTests/InputPipelinePrivacyTests.swift",
            "BeautyDemo/BeautyDemoTests/ParameterJSONCodingTests.swift",
        ),
    ),
    "meituxiuxiu": BundlePolicy(
        zip_sha256="330e8aa08155eb4ad3a7b2ab84773a8279a8cd3ae87d4737b93e2491232fce9a",
        manifest_sha256="76037b046eb1b2eb3a5df56702d1a17875db5e0634ca2b02904234bef601216d",
        zip_size=88_210_543,
        entry_count=26,
        total_uncompressed_size=88_650_871,
        maximum_entry_size=5_089_061,
        maximum_compression_ratio=MAX_COMPRESSION_RATIO,
        paths=(
            "meituxiuxiu/FUNCTION_MAP.md", "meituxiuxiu/HOME_MAP.md",
            "meituxiuxiu/IMG_0856.PNG", "meituxiuxiu/IMG_0857.PNG",
            "meituxiuxiu/IMG_0858.PNG", "meituxiuxiu/IMG_0859.PNG",
            "meituxiuxiu/IMG_0860.PNG", "meituxiuxiu/IMG_0861.PNG",
            "meituxiuxiu/IMG_0862.PNG", "meituxiuxiu/IMG_0863.PNG",
            "meituxiuxiu/IMG_0864.PNG", "meituxiuxiu/IMG_0865.PNG",
            "meituxiuxiu/IMG_0866.PNG", "meituxiuxiu/IMG_0867.PNG",
            "meituxiuxiu/IMG_0868.PNG", "meituxiuxiu/IMG_0869.PNG",
            "meituxiuxiu/IMG_0870.PNG", "meituxiuxiu/home/IMG_0871.PNG",
            "meituxiuxiu/home/IMG_0872.PNG", "meituxiuxiu/home/IMG_0873.PNG",
            "meituxiuxiu/home/IMG_0874.PNG", "meituxiuxiu/html/README.md",
            "meituxiuxiu/html/editor.html", "meituxiuxiu/html/home.html",
            "meituxiuxiu/html/offline-check.mjs", "meituxiuxiu/html/styles.css",
        ),
    ),
}


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


def inventory_directory(
    source: Path,
    source_name: str,
    before_open: Optional[Callable[[Path], None]] = None,
) -> Tuple[InventoryEntry, ...]:
    """Walk one exact directory through pinned descriptors without following links."""

    entries: List[InventoryEntry] = []
    directory_flags = os.O_RDONLY | os.O_CLOEXEC | getattr(os, "O_DIRECTORY", 0)
    directory_flags |= getattr(os, "O_NOFOLLOW", 0)
    file_flags = os.O_RDONLY | os.O_CLOEXEC | getattr(os, "O_NOFOLLOW", 0)
    root_descriptor = os.open(source, directory_flags)
    stack: List[Tuple[int, PurePosixPath]] = [(root_descriptor, PurePosixPath())]
    try:
        while stack:
            directory_descriptor, directory_relative = stack.pop()
            child_directories: List[Tuple[int, PurePosixPath]] = []
            try:
                names = sorted(os.listdir(directory_descriptor), key=os.fsencode)
                for name in names:
                    relative = directory_relative / name
                    before = os.stat(name, dir_fd=directory_descriptor, follow_symlinks=False)
                    if stat.S_ISLNK(before.st_mode):
                        raise ArchiveError(f"symlinks are forbidden in archive sources: {source_name}/{relative}")
                    if exclusion_reason(relative) is not None:
                        continue
                    if before_open is not None:
                        before_open(source / relative)
                    if stat.S_ISDIR(before.st_mode):
                        descriptor = os.open(name, directory_flags, dir_fd=directory_descriptor)
                        opened = os.fstat(descriptor)
                        if (opened.st_dev, opened.st_ino) != (before.st_dev, before.st_ino):
                            os.close(descriptor)
                            raise ArchiveError(f"directory changed while opening: {source_name}/{relative}")
                        child_directories.append((descriptor, relative))
                        continue
                    if not stat.S_ISREG(before.st_mode):
                        raise ArchiveError(f"unsupported filesystem entry: {source_name}/{relative}")
                    descriptor = os.open(name, file_flags, dir_fd=directory_descriptor)
                    try:
                        opened = os.fstat(descriptor)
                        if not stat.S_ISREG(opened.st_mode) or (
                            opened.st_dev,
                            opened.st_ino,
                            opened.st_size,
                        ) != (before.st_dev, before.st_ino, before.st_size):
                            raise ArchiveError(f"file changed while opening: {source_name}/{relative}")
                        chunks: List[bytes] = []
                        while True:
                            chunk = os.read(descriptor, IO_CHUNK_SIZE)
                            if not chunk:
                                break
                            chunks.append(chunk)
                        after = os.fstat(descriptor)
                        if (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns) != (
                            opened.st_dev,
                            opened.st_ino,
                            opened.st_size,
                            opened.st_mtime_ns,
                        ):
                            raise ArchiveError(f"file changed while reading: {source_name}/{relative}")
                        data = b"".join(chunks)
                    finally:
                        os.close(descriptor)
                    archive_path = f"{source_name}/{relative.as_posix()}"
                    entries.append(InventoryEntry(archive_path, len(data), sha256_bytes(data), data))
            except OSError as error:
                for descriptor, _ in child_directories:
                    os.close(descriptor)
                raise ArchiveError(f"cannot safely enumerate {source_name}/{directory_relative}: {error}")
            except BaseException:
                for descriptor, _ in child_directories:
                    os.close(descriptor)
                raise
            finally:
                os.close(directory_descriptor)
            stack.extend(reversed(child_directories))
    except BaseException:
        for descriptor, _ in stack:
            try:
                os.close(descriptor)
            except OSError:
                pass
        raise

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


def inventory_source(
    repo_root: Path,
    source_name: str,
    before_open: Optional[Callable[[Path], None]] = None,
) -> Tuple[InventoryEntry, ...]:
    return inventory_directory(validate_source_root(repo_root, source_name), source_name, before_open)


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
    if len(lines) == 1:
        raise ArchiveError(f"{source_name} manifest must not be empty")
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
    enforce_canonical: bool,
) -> Tuple[str, int]:
    # This second walk is intentionally independent of the caller's preflight.
    live_entries = inventory_source(repo_root, source_name)
    if inventory_signature(live_entries) != inventory_signature(expected_preflight):
        raise ArchiveError(f"{source_name} changed between independent preflight and creation")
    zip_data = deterministic_zip_bytes(live_entries)
    manifest_data = manifest_bytes(live_entries)
    zip_digest = sha256_bytes(zip_data)
    generated_policy = make_bundle_policy(zip_data, manifest_data, source_name)
    if enforce_canonical and generated_policy != CANONICAL_BUNDLE_POLICIES[source_name]:
        raise ArchiveError(f"{source_name} live inventory/artifacts differ from pinned v1.16 authority")
    verify_bundle_bytes(
        source_name,
        zip_data,
        manifest_data,
        digest_record_bytes(source_name, zip_digest),
        generated_policy,
    )
    if not dry_run:
        zip_path, manifest_path, digest_path = bundle_paths(output, source_name)
        write_atomic(zip_path, zip_data)
        write_atomic(manifest_path, manifest_data)
        write_atomic(digest_path, digest_record_bytes(source_name, zip_digest))
        if enforce_canonical:
            verify_bundle(output, source_name)
    return zip_digest, len(live_entries)


def create_all(
    repo_root: Path,
    output: Path,
    dry_run: bool = False,
    enforce_canonical: bool = True,
) -> Mapping[str, str]:
    if output.exists() and output.is_symlink():
        raise ArchiveError(f"archive output directory must not be a symlink: {output}")
    preflight = {source: inventory_source(repo_root, source) for source in SOURCE_ROOTS}
    results: Dict[str, str] = {}
    for source in SOURCE_ROOTS:
        digest, count = create_bundle(
            repo_root,
            output,
            source,
            preflight[source],
            dry_run,
            enforce_canonical,
        )
        results[source] = digest
        action = "DRY-RUN" if dry_run else "CREATED"
        print(f"{action} {source}: files={count} zip_sha256={digest}")
    return results


def make_bundle_policy(
    zip_data: bytes,
    manifest_data: bytes,
    source_name: str,
    maximum_entry_size: Optional[int] = None,
    total_uncompressed_size: Optional[int] = None,
    maximum_compression_ratio: float = MAX_COMPRESSION_RATIO,
) -> BundlePolicy:
    manifest = parse_manifest(manifest_data, source_name)
    total = sum(row[1] for row in manifest)
    return BundlePolicy(
        zip_sha256=sha256_bytes(zip_data),
        manifest_sha256=sha256_bytes(manifest_data),
        zip_size=len(zip_data),
        entry_count=len(manifest),
        total_uncompressed_size=total if total_uncompressed_size is None else total_uncompressed_size,
        maximum_entry_size=max(row[1] for row in manifest) if maximum_entry_size is None else maximum_entry_size,
        maximum_compression_ratio=maximum_compression_ratio,
        paths=tuple(row[0] for row in manifest),
    )


def verify_bundle_stream(
    source_name: str,
    zip_stream: BinaryIO,
    zip_size: int,
    actual_zip_digest: str,
    manifest_data: bytes,
    digest_data: bytes,
    policy: BundlePolicy,
    extraction_root: Optional[Path] = None,
) -> str:
    if zip_size != policy.zip_size:
        raise ArchiveError(f"{source_name} ZIP compressed size differs from its pinned value")
    if actual_zip_digest != policy.zip_sha256:
        raise ArchiveError(f"{source_name} ZIP SHA-256 differs from its independent trust anchor")
    if sha256_bytes(manifest_data) != policy.manifest_sha256:
        raise ArchiveError(f"{source_name} manifest SHA-256 differs from its independent trust anchor")
    recorded_digest = parse_digest_record(digest_data, source_name)
    if recorded_digest != policy.zip_sha256:
        raise ArchiveError(f"{source_name} ZIP digest record differs from its independent trust anchor")

    manifest = parse_manifest(manifest_data, source_name)
    paths = tuple(row[0] for row in manifest)
    if len(manifest) != policy.entry_count or paths != policy.paths:
        raise ArchiveError(f"{source_name} manifest count/path inventory differs from its pinned authority")
    if sum(row[1] for row in manifest) != policy.total_uncompressed_size:
        raise ArchiveError(f"{source_name} manifest total size differs from its pinned authority")
    if any(row[1] > policy.maximum_entry_size for row in manifest):
        raise ArchiveError(f"{source_name} manifest entry exceeds its resource bound")
    manifest_by_path = {path: (size, digest) for path, size, digest in manifest}

    try:
        zip_stream.seek(0)
        with zipfile.ZipFile(zip_stream, "r") as archive:
            infos = archive.infolist()
            info_paths = [info.filename for info in infos]
            if len(infos) != policy.entry_count:
                raise ArchiveError(f"{source_name} ZIP entry count differs from its pinned authority")
            if info_paths != sorted(info_paths, key=os.fsencode) or len(info_paths) != len(set(info_paths)):
                raise ArchiveError(f"{source_name} ZIP inventory is unsorted or duplicated")
            total_size = 0
            for info in infos:
                validate_archive_path(info.filename, source_name)
                if info.is_dir():
                    raise ArchiveError(f"{source_name} ZIP must contain files only")
                if info.date_time != ZIP_TIMESTAMP:
                    raise ArchiveError(f"{source_name} ZIP has a non-normalized timestamp")
                if info.create_system != 3 or (info.external_attr >> 16) != NORMALIZED_FILE_MODE:
                    raise ArchiveError(f"{source_name} ZIP has a non-normalized mode")
                if info.file_size > policy.maximum_entry_size:
                    raise ArchiveError(f"{source_name} ZIP entry exceeds its resource bound: {info.filename}")
                total_size += info.file_size
                if total_size > policy.total_uncompressed_size:
                    raise ArchiveError(f"{source_name} ZIP total size exceeds its resource bound")
                ratio = info.file_size / max(info.compress_size, 1)
                if ratio > policy.maximum_compression_ratio:
                    raise ArchiveError(f"{source_name} ZIP compression ratio exceeds its resource bound: {info.filename}")
                expected_size, _ = manifest_by_path.get(info.filename, (-1, ""))
                if info.file_size != expected_size:
                    raise ArchiveError(f"{source_name} ZIP and manifest sizes differ: {info.filename}")
            if tuple(info_paths) != policy.paths or total_size != policy.total_uncompressed_size:
                raise ArchiveError(f"{source_name} ZIP inventory/total differs from its pinned authority")

            for info in infos:
                expected_size, expected_digest = manifest_by_path[info.filename]
                digest = hashlib.sha256()
                observed_size = 0
                target = None
                if extraction_root is not None:
                    destination = extraction_root.joinpath(*PurePosixPath(info.filename).parts)
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    target = destination.open("xb")
                try:
                    with archive.open(info, "r") as source:
                        while True:
                            chunk = source.read(IO_CHUNK_SIZE)
                            if not chunk:
                                break
                            observed_size += len(chunk)
                            if observed_size > expected_size:
                                raise ArchiveError(f"{source_name} ZIP entry exceeded its declared size: {info.filename}")
                            digest.update(chunk)
                            if target is not None:
                                target.write(chunk)
                finally:
                    if target is not None:
                        target.close()
                if observed_size != expected_size or digest.hexdigest() != expected_digest:
                    raise ArchiveError(f"{source_name} content mismatch: {info.filename}")
    except (zipfile.BadZipFile, RuntimeError, OSError) as error:
        raise ArchiveError(f"{source_name} ZIP validation failed: {error}")

    if extraction_root is not None:
        extracted: Dict[str, Tuple[int, str]] = {}
        for path in extraction_root.rglob("*"):
            if path.is_symlink():
                raise ArchiveError(f"extraction produced a symlink: {path}")
            if path.is_file():
                relative = path.relative_to(extraction_root).as_posix()
                if relative.startswith(f"{source_name}/"):
                    extracted[relative] = (path.stat().st_size, sha256_file(path))
        if extracted != manifest_by_path:
            raise ArchiveError(f"{source_name} extracted inventory/content differs from manifest")
    return actual_zip_digest


def verify_bundle_bytes(
    source_name: str,
    zip_data: bytes,
    manifest_data: bytes,
    digest_data: bytes,
    policy: Optional[BundlePolicy] = None,
) -> str:
    selected_policy = policy or CANONICAL_BUNDLE_POLICIES[source_name]
    with tempfile.TemporaryDirectory(prefix=f"archive-{source_name}-extract-") as directory:
        return verify_bundle_stream(
            source_name,
            io.BytesIO(zip_data),
            len(zip_data),
            sha256_bytes(zip_data),
            manifest_data,
            digest_data,
            selected_policy,
            Path(directory),
        )


def read_small_artifact(path: Path, maximum_size: int) -> bytes:
    flags = os.O_RDONLY | os.O_CLOEXEC | getattr(os, "O_NOFOLLOW", 0)
    try:
        descriptor = os.open(path, flags)
        before = os.fstat(descriptor)
        if not stat.S_ISREG(before.st_mode) or before.st_size > maximum_size:
            raise ArchiveError(f"archive metadata artifact is invalid or oversized: {path}")
        with os.fdopen(descriptor, "rb") as handle:
            data = handle.read(maximum_size + 1)
            after = os.fstat(handle.fileno())
    except OSError as error:
        raise ArchiveError(f"cannot safely read archive artifact {path}: {error}")
    if len(data) > maximum_size or (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) != (
        after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns
    ):
        raise ArchiveError(f"archive metadata artifact changed while reading: {path}")
    return data


def snapshot_zip(path: Path, policy: BundlePolicy) -> Tuple[BinaryIO, int, str]:
    flags = os.O_RDONLY | os.O_CLOEXEC | getattr(os, "O_NOFOLLOW", 0)
    try:
        descriptor = os.open(path, flags)
        before = os.fstat(descriptor)
        if not stat.S_ISREG(before.st_mode) or before.st_size != policy.zip_size:
            os.close(descriptor)
            raise ArchiveError(f"archive ZIP is missing, symlinked, or has unpinned size: {path}")
        snapshot = tempfile.TemporaryFile(mode="w+b")
        digest = hashlib.sha256()
        with os.fdopen(descriptor, "rb") as source:
            while True:
                chunk = source.read(IO_CHUNK_SIZE)
                if not chunk:
                    break
                digest.update(chunk)
                snapshot.write(chunk)
            after = os.fstat(source.fileno())
    except OSError as error:
        raise ArchiveError(f"cannot safely snapshot archive ZIP {path}: {error}")
    if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) != (
        after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns
    ):
        snapshot.close()
        raise ArchiveError(f"archive ZIP changed while snapshotting: {path}")
    snapshot.seek(0)
    return snapshot, before.st_size, digest.hexdigest()


def verify_bundle(output: Path, source_name: str) -> str:
    zip_path, manifest_path, digest_path = bundle_paths(output, source_name)
    policy = CANONICAL_BUNDLE_POLICIES[source_name]
    zip_snapshot, zip_size, zip_digest = snapshot_zip(zip_path, policy)
    try:
        manifest_data = read_small_artifact(manifest_path, MAX_MANIFEST_BYTES)
        digest_data = read_small_artifact(digest_path, MAX_DIGEST_RECORD_BYTES)
        with tempfile.TemporaryDirectory(prefix=f"archive-{source_name}-extract-") as directory:
            return verify_bundle_stream(
                source_name,
                zip_snapshot,
                zip_size,
                zip_digest,
                manifest_data,
                digest_data,
                policy,
                Path(directory),
            )
    finally:
        zip_snapshot.close()


def verify_all(output: Path, enforce_canonical: bool = True) -> Mapping[str, str]:
    results: Dict[str, str] = {}
    for source in SOURCE_ROOTS:
        if enforce_canonical:
            digest = verify_bundle(output, source)
        else:
            zip_path, manifest_path, digest_path = bundle_paths(output, source)
            zip_data = zip_path.read_bytes()
            manifest_data = manifest_path.read_bytes()
            digest = verify_bundle_bytes(
                source,
                zip_data,
                manifest_data,
                digest_path.read_bytes(),
                make_bundle_policy(zip_data, manifest_data, source),
            )
        results[source] = digest
        print(f"VERIFIED {source}: zip_sha256={digest}")
    return results


def reproduce_all(
    repo_root: Path,
    output: Path,
    enforce_canonical: bool = True,
) -> Mapping[str, str]:
    recorded = verify_all(output, enforce_canonical=enforce_canonical)
    source_presence = [(repo_root / source).exists() for source in SOURCE_ROOTS]
    if not any(source_presence):
        print("REPRODUCED artifact-only trust anchors with both live roots absent")
        return recorded
    if not all(source_presence):
        raise ArchiveError("reproduction requires both live roots or the canonical artifact-only state")
    with tempfile.TemporaryDirectory(prefix="legacy-ui-reproduce-") as directory:
        reproduction = Path(directory)
        create_all(repo_root, reproduction, enforce_canonical=enforce_canonical)
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
    before_quarantine: Optional[Callable[[], None]] = None,
    after_quarantine: Optional[Callable[[], None]] = None,
    enforce_canonical: bool = True,
) -> None:
    if not confirmation:
        raise ArchiveError("retirement requires --yes-retire-exact-sources")
    sources = {source: validate_source_root(repo_root, source) for source in SOURCE_ROOTS}
    expected_deletions = tracked_paths(repo_root, list(SOURCE_ROOTS))
    for path in expected_deletions:
        if not (repo_root / path).is_file():
            raise ArchiveError(f"tracked source is already absent before retirement: {path}")
    deleted_before = deleted_tracked_paths(repo_root)
    if deleted_before:
        raise ArchiveError(
            "retirement requires no pre-existing tracked deletions: "
            f"unexpected={sorted(deleted_before)}"
        )
    sentinels_before = sentinel_fingerprints(repo_root)

    recorded = verify_all(output, enforce_canonical=enforce_canonical)
    if dict(recorded) != dict(approvals):
        raise ArchiveError(
            "digest approval does not match the freshly verified archives: "
            f"expected={dict(recorded)}, approved={dict(approvals)}"
        )
    if before_quarantine is not None:
        before_quarantine()

    quarantine = Path(tempfile.mkdtemp(prefix="beauty-legacy-ui-retire-", dir=str(repo_root.parent)))
    moved: List[Tuple[Path, Path]] = []
    try:
        for source in SOURCE_ROOTS:
            original = sources[source]
            staged = quarantine / source
            os.replace(original, staged)
            moved.append((original, staged))

        if after_quarantine is not None:
            after_quarantine()

        # The rename freezes the exact bytes. Validate that frozen snapshot before
        # any irreversible removal so a late untracked addition is restored.
        for source in SOURCE_ROOTS:
            frozen = inventory_directory(quarantine / source, source)
            frozen_signature = inventory_signature(frozen)
            zip_path, manifest_path, _ = bundle_paths(output, source)
            if enforce_canonical:
                manifest = parse_manifest(
                    read_small_artifact(manifest_path, MAX_MANIFEST_BYTES),
                    source,
                )
            else:
                manifest = parse_manifest(manifest_path.read_bytes(), source)
            if frozen_signature != manifest:
                raise ArchiveError(f"{source} frozen quarantine inventory differs from verified archive")
            if enforce_canonical:
                rebuilt_zip = deterministic_zip_bytes(frozen)
                if sha256_bytes(rebuilt_zip) != CANONICAL_BUNDLE_POLICIES[source].zip_sha256:
                    raise ArchiveError(f"{source} frozen quarantine bytes differ from pinned archive")

        deleted_after_move = deleted_tracked_paths(repo_root)
        if deleted_after_move != expected_deletions:
            raise ArchiveError(
                "retirement tracked deletion set differs from its exact precomputed allowlist: "
                f"missing={sorted(expected_deletions - deleted_after_move)}, "
                f"extra={sorted(deleted_after_move - expected_deletions)}"
            )
        if sentinel_fingerprints(repo_root) != sentinels_before:
            raise ArchiveError("SDK/docs/planning/private-fixture sentinels changed during retirement")
        replacements = [
            original for original, _ in moved
            if original.exists() or original.is_symlink()
        ]
        if replacements:
            raise ArchiveError(
                "retirement source path was recreated while originals were quarantined: "
                f"{[str(path) for path in replacements]}"
            )
    except BaseException as error:
        # Inspect every destination before restoring any root. If another process
        # recreated even one source path, preserve the complete staged snapshot
        # so the replacement is never mistaken for (or allowed to overwrite) an
        # original and the two-root rollback remains recoverable as one unit.
        collisions = [
            original for original, _ in moved
            if original.exists() or original.is_symlink()
        ]
        missing_staged = [
            staged for _, staged in moved
            if not staged.exists() and not staged.is_symlink()
        ]
        if collisions or missing_staged:
            raise ArchiveError(
                "retirement rollback requires manual recovery; "
                f"staged originals preserved at {quarantine}; "
                f"replacement collisions={list(map(str, collisions))}; "
                f"missing staged roots={list(map(str, missing_staged))}"
            ) from error

        try:
            for original, staged in reversed(moved):
                os.replace(staged, original)
        except BaseException as rollback_error:
            raise ArchiveError(
                "retirement rollback was incomplete; remaining staged originals "
                f"are preserved at {quarantine}"
            ) from rollback_error

        # Every staged root has been restored successfully. Only the now-empty
        # quarantine container may be removed.
        if any(staged.exists() or staged.is_symlink() for _, staged in moved):
            raise ArchiveError(
                f"retirement rollback left staged originals at {quarantine}"
            ) from error
        quarantine.rmdir()
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


def restore_all(
    repo_root: Path,
    output: Path,
    destination: Path,
    policies: Mapping[str, BundlePolicy] = CANONICAL_BUNDLE_POLICIES,
) -> None:
    if destination.exists() or destination.is_symlink():
        raise ArchiveError("restore destination must not already exist")
    parent = destination.parent
    if parent.is_symlink() or not parent.is_dir():
        raise ArchiveError("restore destination parent must be an existing non-symlink directory")
    parent_stat = parent.stat()
    if parent_stat.st_uid != os.getuid() or stat.S_IMODE(parent_stat.st_mode) & 0o077:
        raise ArchiveError("restore destination parent must be private to the current user")
    if any(parent.iterdir()):
        raise ArchiveError("restore destination parent must be a fresh empty temporary directory")
    resolved_destination = parent.resolve() / destination.name
    if resolved_destination.is_relative_to(repo_root):
        raise ArchiveError("restore destination must be outside the active repository")

    snapshots = {}
    with ExitStack() as stack:
        for source_name in SOURCE_ROOTS:
            zip_path, manifest_path, digest_path = bundle_paths(output, source_name)
            policy = policies[source_name]
            zip_snapshot, zip_size, zip_digest = snapshot_zip(zip_path, policy)
            stack.callback(zip_snapshot.close)
            manifest_data = read_small_artifact(manifest_path, MAX_MANIFEST_BYTES)
            digest_data = read_small_artifact(digest_path, MAX_DIGEST_RECORD_BYTES)
            verify_bundle_stream(
                source_name,
                zip_snapshot,
                zip_size,
                zip_digest,
                manifest_data,
                digest_data,
                policy,
            )
            snapshots[source_name] = (
                zip_snapshot,
                zip_size,
                zip_digest,
                manifest_data,
                digest_data,
                policy,
            )

        resolved_destination.mkdir(mode=0o700)
        try:
            for source_name in SOURCE_ROOTS:
                verify_bundle_stream(
                    source_name,
                    *snapshots[source_name],
                    extraction_root=resolved_destination,
                )
        except BaseException:
            shutil.rmtree(resolved_destination, ignore_errors=True)
            raise
    print(f"RESTORED verified historical material to {resolved_destination}")


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
    (repo_root / "unrelated.txt").write_text("unrelated sentinel\n", encoding="utf-8")
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
        created = create_all(root, output, enforce_canonical=False)
        if verify_all(output, enforce_canonical=False) != created:
            raise ArchiveError("self-test verification digests differ from creation")
        if reproduce_all(root, output, enforce_canonical=False) != created:
            raise ArchiveError("self-test reproduction digests differ from creation")
        sources_before = {source: inventory_signature(inventory_source(root, source)) for source in SOURCE_ROOTS}
        create_all(root, output, dry_run=True, enforce_canonical=False)
        if sources_before != {source: inventory_signature(inventory_source(root, source)) for source in SOURCE_ROOTS}:
            raise ArchiveError("create/verify self-test modified a source tree")

        # Tamper and unsafe-path checks must fail closed.
        zip_path, manifest_path, digest_path = bundle_paths(output, "BeautyDemo")
        original_manifest = manifest_path.read_bytes()
        manifest_path.write_bytes(original_manifest + b"BeautyDemo/extra\t0\t" + b"0" * 64 + b"\n")
        require_archive_error(
            lambda: verify_all(output, enforce_canonical=False),
            "tampered manifest",
        )
        manifest_path.write_bytes(original_manifest)

        empty_buffer = io.BytesIO()
        with zipfile.ZipFile(empty_buffer, "w"):
            pass
        empty_zip = empty_buffer.getvalue()
        require_archive_error(
            lambda: verify_bundle_bytes(
                "BeautyDemo",
                empty_zip,
                b"path\tsize\tsha256\n",
                digest_record_bytes("BeautyDemo", sha256_bytes(empty_zip)),
            ),
            "self-consistent empty replacement bundle",
        )
        malicious_buffer = io.BytesIO()
        with zipfile.ZipFile(malicious_buffer, "w") as archive:
            archive.writestr("../escape", b"bad")
        malicious = malicious_buffer.getvalue()
        require_archive_error(
            lambda: verify_bundle_bytes(
                "BeautyDemo",
                malicious,
                b"path\tsize\tsha256\nBeautyDemo/placeholder\t0\t" + b"0" * 64 + b"\n",
                digest_record_bytes("BeautyDemo", sha256_bytes(malicious)),
            ),
            "unsafe ZIP path",
        )

        bounded_entry = InventoryEntry("BeautyDemo/high-expansion.bin", 200_000, sha256_bytes(b"0" * 200_000), b"0" * 200_000)
        bounded_zip = deterministic_zip_bytes((bounded_entry,))
        bounded_manifest = manifest_bytes((bounded_entry,))
        bounded_digest = digest_record_bytes("BeautyDemo", sha256_bytes(bounded_zip))
        bounded_policy = make_bundle_policy(bounded_zip, bounded_manifest, "BeautyDemo")
        require_archive_error(
            lambda: verify_bundle_bytes("BeautyDemo", bounded_zip, bounded_manifest, bounded_digest, bounded_policy._replace(zip_size=len(bounded_zip) - 1)),
            "oversized compressed archive",
        )
        require_archive_error(
            lambda: verify_bundle_bytes("BeautyDemo", bounded_zip, bounded_manifest, bounded_digest, bounded_policy._replace(maximum_entry_size=199_999)),
            "oversized per-entry content",
        )
        require_archive_error(
            lambda: verify_bundle_bytes("BeautyDemo", bounded_zip, bounded_manifest, bounded_digest, bounded_policy._replace(total_uncompressed_size=199_999)),
            "uncompressed total overflow",
        )
        require_archive_error(
            lambda: verify_bundle_bytes("BeautyDemo", bounded_zip, bounded_manifest, bounded_digest, bounded_policy._replace(maximum_compression_ratio=2.0)),
            "high expansion ratio",
        )

        outside = root / "outside-private.txt"
        outside.write_text("must not be archived\n", encoding="utf-8")
        victim = root / "BeautyDemo" / "Demo.swift"
        backup = root / "BeautyDemo" / "Demo.swift.saved"
        swapped = False
        def adversarial_swap(path: Path) -> None:
            nonlocal swapped
            if path == victim and not swapped:
                victim.rename(backup)
                victim.symlink_to(outside)
                swapped = True
        require_archive_error(
            lambda: inventory_source(root, "BeautyDemo", adversarial_swap),
            "adversarial regular-file to symlink swap",
        )
        victim.unlink()
        backup.rename(victim)
        link = root / "BeautyDemo" / "forbidden-link"
        link.symlink_to("Demo.swift")
        require_archive_error(
            lambda: inventory_source(root, "BeautyDemo"),
            "source symlink",
        )
        link.unlink()

        unrelated = root / "unrelated.txt"
        unrelated.unlink()
        require_archive_error(
            lambda: retire_sources(root, output, created, confirmation=True, enforce_canonical=False),
            "pre-existing unrelated tracked deletion",
        )
        unrelated.write_text("unrelated sentinel\n", encoding="utf-8")

        def late_mutation() -> None:
            (root / "BeautyDemo" / "late-untracked.txt").write_text("late\n", encoding="utf-8")
        require_archive_error(
            lambda: retire_sources(
                root,
                output,
                created,
                confirmation=True,
                before_quarantine=late_mutation,
                enforce_canonical=False,
            ),
            "late untracked mutation before quarantine validation",
        )
        late_path = root / "BeautyDemo" / "late-untracked.txt"
        if not late_path.is_file():
            raise ArchiveError("late mutation was not restored after retirement rollback")
        late_path.unlink()

        replacement_marker = root / "BeautyDemo" / "replacement-only.txt"
        collision_status = 0
        collision_error: Optional[ArchiveError] = None

        def recreate_source_after_quarantine() -> None:
            replacement_marker.parent.mkdir()
            replacement_marker.write_text("concurrent replacement\n", encoding="utf-8")

        try:
            retire_sources(
                root,
                output,
                created,
                confirmation=True,
                after_quarantine=recreate_source_after_quarantine,
                enforce_canonical=False,
            )
        except ArchiveError as error:
            collision_status = 1
            collision_error = error
        if collision_status == 0 or collision_error is None:
            raise ArchiveError("concurrent source recreation did not return a failure")
        if not replacement_marker.is_file():
            raise ArchiveError("concurrent replacement was lost during collision rollback")
        marker = "staged originals preserved at "
        message = str(collision_error)
        if marker not in message:
            raise ArchiveError("collision failure omitted the manual recovery path")
        recovery = Path(message.split(marker, 1)[1].split(";", 1)[0])
        for source in SOURCE_ROOTS:
            staged = recovery / source
            if not staged.is_dir():
                raise ArchiveError(f"collision rollback lost staged original: {source}")
            if inventory_signature(inventory_directory(staged, source)) != sources_before[source]:
                raise ArchiveError(f"collision rollback changed staged original: {source}")

        # Restore the fixture explicitly after proving the replacement and the
        # complete two-root original snapshot coexist without data loss.
        shutil.rmtree(replacement_marker.parent)
        for source in SOURCE_ROOTS:
            os.replace(recovery / source, root / source)
        recovery.rmdir()

        test_policies = {}
        for source in SOURCE_ROOTS:
            test_zip, test_manifest, _ = bundle_paths(output, source)
            test_policies[source] = make_bundle_policy(
                test_zip.read_bytes(), test_manifest.read_bytes(), source
            )
        retire_sources(root, output, created, confirmation=True, enforce_canonical=False)
        if any((root / source).exists() for source in SOURCE_ROOTS):
            raise ArchiveError("self-test retirement left a source root")
        verify_all(output, enforce_canonical=False)
        restore_parent = Path(tempfile.mkdtemp(prefix="archive-restore-self-test-"))
        try:
            destination = restore_parent / "legacy-ui"
            restore_all(root, output, destination, test_policies)
            if not all((destination / source).is_dir() for source in SOURCE_ROOTS):
                raise ArchiveError("verified restore omitted a historical root")
            require_archive_error(
                lambda: restore_all(root, output, destination, test_policies),
                "existing restore destination",
            )
        finally:
            shutil.rmtree(restore_parent, ignore_errors=True)
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
    restore = subparsers.add_parser("restore")
    restore.add_argument("--output", type=Path, default=ARCHIVE_DIRECTORY)
    restore.add_argument("--destination", type=Path, required=True)
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
        elif arguments.command == "restore":
            destination = arguments.destination
            if not destination.is_absolute():
                destination = Path.cwd() / destination
            restore_all(repo_root, output, destination)
        return 0
    except ArchiveError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
