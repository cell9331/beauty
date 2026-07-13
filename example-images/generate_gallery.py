#!/usr/bin/env python3
"""Generate the human-review gallery from flat renderer outputs."""

from __future__ import annotations

import argparse
import errno
import os
import re
import stat
import sys
import tempfile
from collections import Counter
from pathlib import Path


SUPPORTED_INPUT_EXTENSIONS = {".png", ".jpg", ".jpeg"}
REPO_ROOT = Path(__file__).resolve().parent.parent
RENDERER_SOURCE = REPO_ROOT / "BeautySDK" / "Sources" / "BeautyExampleRenderer" / "main.swift"
STAGING_NAME = ".gallery-staging"
QUARANTINE_NAME = ".gallery-quarantine"
QUARANTINE_ENTRY = "previous"

CASE_GROUPS = {
    "skin": [
        "skinSmoothing_0p50", "skinWhitening_0p50", "skinRosy_0p40",
        "skinSharpen_0p40", "skinCombo_0p50",
    ],
    "color": ["brightness_plus0p25", "contrast_plus0p25"],
    "filter": ["filter_softClean_0p50", "filter_warmLight_0p50"],
    "face-shape": [
        "geometryBaseline_noop", "faceShapeCombo_0p35", "faceSlim_0p35",
        "faceSmall_0p35", "chinLength_plus0p30", "chinLength_minus0p30",
        "faceVShape_0p35", "jawSlim_0p35",
    ],
    "eyes": [
        "eyeSize_0p35", "eyeDistance_plus0p25", "eyeDistance_minus0p25",
        "eyeYPosition_plus0p20", "eyeYPosition_minus0p20", "eyeTailLift_0p25",
    ],
    "nose": [
        "noseSlim_0p35", "noseWingSlim_0p35", "noseTipSize_plus0p30",
        "noseTipSize_minus0p30", "noseBridge_0p30", "noseRootNarrowing_0p25",
        "noseTipLift_0p25",
    ],
    "mouth": [
        "mouthSize_plus0p35", "mouthSize_minus0p35", "mouthWidth_plus0p35",
        "mouthWidth_minus0p35", "smile_0p50", "lipColor_0p50",
    ],
}


class GalleryError(Exception):
    pass


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="example-images/input", help="Committed source fixture directory.")
    parser.add_argument("--output", default="example-images/output", help="Flat generated renderer output directory.")
    parser.add_argument("--gallery", default="example-images/gallery", help="Generated human-review gallery directory.")
    parser.add_argument("--self-test", action="store_true", help="Run deterministic negative-path checks.")
    args = parser.parse_args()
    try:
        if args.self_test:
            run_self_tests()
        else:
            generate_gallery(Path(args.input), Path(args.output), Path(args.gallery))
    except (GalleryError, AssertionError) as error:
        print(error, file=sys.stderr)
        return 1
    return 0


def generate_gallery(input_dir: Path, output_dir: Path, gallery_dir: Path) -> None:
    validate_gallery_directory(input_dir, output_dir, gallery_dir)
    fixture_stems = discover_fixture_stems(input_dir)
    gallery_case_ids = [case_id for case_ids in CASE_GROUPS.values() for case_id in case_ids]
    validate_case_inventory(gallery_case_ids, discover_renderer_case_ids(RENDERER_SOURCE))
    publish_gallery(CASE_GROUPS, fixture_stems, repo_root=REPO_ROOT)
    print(f"wrote {len(gallery_case_ids) * len(fixture_stems)} gallery PNGs under example-images/gallery")


def lexical_absolute(path: Path) -> Path:
    return Path(os.path.abspath(path))


def require_no_symlink_components(path: Path, repo_root: Path) -> None:
    try:
        relative = path.relative_to(repo_root)
    except ValueError:
        raise GalleryError("Gallery directory must be the repository example-images/gallery") from None
    current = repo_root
    for component in relative.parts:
        current /= component
        if current.is_symlink():
            raise GalleryError(f"Gallery path component must not be a symbolic link: {component}")


def validate_gallery_directory(
    input_dir: Path,
    output_dir: Path,
    gallery_dir: Path,
    *,
    repo_root: Path = REPO_ROOT,
) -> None:
    lexical_repo = lexical_absolute(repo_root)
    lexical_example = lexical_repo / "example-images"
    expected = {
        "input": lexical_example / "input",
        "output": lexical_example / "output",
        "gallery": lexical_example / "gallery",
    }
    supplied = {
        "input": lexical_absolute(input_dir),
        "output": lexical_absolute(output_dir),
        "gallery": lexical_absolute(gallery_dir),
    }
    for label in expected:
        if supplied[label] != expected[label]:
            raise GalleryError(f"{label.capitalize()} directory must be the repository example-images/{label}")
    require_no_symlink_components(supplied["gallery"], lexical_repo)
    if supplied["gallery"].resolve() != expected["gallery"].resolve():
        raise GalleryError("Gallery directory resolves outside the repository example-images/gallery")
    if paths_overlap(supplied["gallery"].resolve(), supplied["input"].resolve()) or paths_overlap(
        supplied["gallery"].resolve(), supplied["output"].resolve()
    ):
        raise GalleryError("Gallery directory must not overlap input or output directories")


def _require_descriptor_operations() -> None:
    required_dir_fd = (os.open, os.stat, os.mkdir, os.rename)
    if (
        not hasattr(os, "O_DIRECTORY")
        or not hasattr(os, "O_NOFOLLOW")
        or any(operation not in os.supports_dir_fd for operation in required_dir_fd)
        or os.stat not in os.supports_follow_symlinks
    ):
        raise GalleryError("Safe descriptor-relative gallery publication is not supported on this platform")


def _directory_open_flags() -> int:
    return os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)


def _open_directory(name: str, *, parent_fd: int) -> int:
    try:
        return os.open(name, _directory_open_flags(), dir_fd=parent_fd)
    except OSError as error:
        raise GalleryError(f"Gallery path component is not a safe directory: {name}") from error


def _same_identity(left: os.stat_result, right: os.stat_result) -> bool:
    return left.st_dev == right.st_dev and left.st_ino == right.st_ino


def _require_entry_identity(parent_fd: int, name: str, opened_fd: int) -> None:
    try:
        entry = os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except OSError as error:
        raise GalleryError(f"Gallery path changed after validation: {name}") from error
    if not stat.S_ISDIR(entry.st_mode) or not _same_identity(entry, os.fstat(opened_fd)):
        raise GalleryError(f"Gallery path changed after validation: {name}")


def _require_absent(parent_fd: int, name: str, label: str) -> None:
    try:
        os.stat(name, dir_fd=parent_fd, follow_symlinks=False)
    except OSError as error:
        if error.errno == errno.ENOENT:
            return
        raise GalleryError(f"Unable to inspect {label}") from error
    raise GalleryError(f"{label} already exists; refusing to traverse or remove it")


def _safe_component(value: str, label: str) -> str:
    if value in ("", ".", "..") or "/" in value or os.sep in value:
        raise GalleryError(f"Unsafe {label}: {value!r}")
    return value


def _mkdir_open(name: str, parent_fd: int) -> int:
    _safe_component(name, "gallery directory component")
    try:
        os.mkdir(name, mode=0o755, dir_fd=parent_fd)
    except OSError as error:
        raise GalleryError(f"Unable to create fresh gallery directory: {name}") from error
    opened = _open_directory(name, parent_fd=parent_fd)
    _require_entry_identity(parent_fd, name, opened)
    return opened


def _write_all(fd: int, data: bytes) -> None:
    offset = 0
    while offset < len(data):
        written = os.write(fd, data[offset:])
        if written <= 0:
            raise GalleryError("Unable to write gallery destination")
        offset += written


def _copy_regular_file(
    source_name: str,
    destination_name: str,
    source_fd: int,
    destination_fd: int,
) -> os.stat_result:
    source_flags = os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)
    destination_flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)
    source = destination = None
    try:
        source = os.open(source_name, source_flags, dir_fd=source_fd)
        before = os.fstat(source)
        if not stat.S_ISREG(before.st_mode):
            raise GalleryError(f"Gallery source is not a regular file: {source_name}")
        destination = os.open(destination_name, destination_flags, 0o644, dir_fd=destination_fd)
        remaining = before.st_size
        while remaining:
            chunk = os.read(source, min(1024 * 1024, remaining))
            if not chunk:
                raise GalleryError(f"Gallery source changed while copying: {source_name}")
            _write_all(destination, chunk)
            remaining -= len(chunk)
        if os.read(source, 1):
            raise GalleryError(f"Gallery source grew while copying: {source_name}")
        after = os.fstat(source)
        if not _same_identity(before, after) or before.st_size != after.st_size:
            raise GalleryError(f"Gallery source changed while copying: {source_name}")
        return os.fstat(destination)
    except OSError as error:
        raise GalleryError(f"Unable to copy gallery source securely: {source_name}") from error
    finally:
        if destination is not None:
            os.close(destination)
        if source is not None:
            os.close(source)


def publish_gallery(
    case_groups: dict[str, list[str]],
    fixture_stems: list[str],
    *,
    repo_root: Path,
    _before_publish=None,
) -> None:
    """Build a fresh anchored tree and publish it atomically without traversing old trees.

    An existing gallery is moved intact to one ignored quarantine slot. The script
    never enumerates or removes that slot; its presence deliberately blocks reruns
    until a human handles it outside this security-sensitive operation.
    """
    _require_descriptor_operations()
    lexical_repo = lexical_absolute(repo_root)
    descriptors: list[int] = []
    created_directories: list[tuple[int, str, int]] = []
    created_files: list[tuple[int, str, os.stat_result]] = []
    gallery_fd = staging_fd = quarantine_fd = None
    try:
        parent_fd = os.open(str(lexical_repo.parent), _directory_open_flags())
        descriptors.append(parent_fd)
        repo_fd = _open_directory(lexical_repo.name, parent_fd=parent_fd)
        descriptors.append(repo_fd)
        _require_entry_identity(parent_fd, lexical_repo.name, repo_fd)
        example_fd = _open_directory("example-images", parent_fd=repo_fd)
        descriptors.append(example_fd)
        _require_entry_identity(repo_fd, "example-images", example_fd)
        input_fd = _open_directory("input", parent_fd=example_fd)
        output_fd = _open_directory("output", parent_fd=example_fd)
        descriptors.extend((input_fd, output_fd))
        _require_entry_identity(example_fd, "input", input_fd)
        _require_entry_identity(example_fd, "output", output_fd)

        try:
            gallery_fd = os.open("gallery", _directory_open_flags(), dir_fd=example_fd)
        except OSError as error:
            if error.errno != errno.ENOENT:
                raise GalleryError("Gallery path exists but is not a safe directory") from error
        if gallery_fd is not None:
            descriptors.append(gallery_fd)
            _require_entry_identity(example_fd, "gallery", gallery_fd)

        _require_absent(example_fd, STAGING_NAME, "gallery staging slot")
        _require_absent(example_fd, QUARANTINE_NAME, "gallery quarantine slot")
        staging_fd = _mkdir_open(STAGING_NAME, example_fd)
        descriptors.append(staging_fd)
        created_directories.append((example_fd, STAGING_NAME, staging_fd))
        if gallery_fd is not None:
            quarantine_fd = _mkdir_open(QUARANTINE_NAME, example_fd)
            descriptors.append(quarantine_fd)
            created_directories.append((example_fd, QUARANTINE_NAME, quarantine_fd))

        copied = 0
        for group, case_ids in case_groups.items():
            group_fd = _mkdir_open(_safe_component(group, "gallery group"), staging_fd)
            descriptors.append(group_fd)
            created_directories.append((staging_fd, group, group_fd))
            for case_id in case_ids:
                case_fd = _mkdir_open(_safe_component(case_id, "gallery case ID"), group_fd)
                descriptors.append(case_fd)
                created_directories.append((group_fd, case_id, case_fd))
                for fixture_stem in fixture_stems:
                    stem = _safe_component(fixture_stem, "fixture stem")
                    destination_name = f"{stem}.png"
                    destination_stat = _copy_regular_file(
                        f"{stem}__{case_id}.png", destination_name, output_fd, case_fd
                    )
                    created_files.append((case_fd, destination_name, destination_stat))
                    copied += 1

        if _before_publish is not None:
            _before_publish()

        _require_entry_identity(parent_fd, lexical_repo.name, repo_fd)
        _require_entry_identity(repo_fd, "example-images", example_fd)
        _require_entry_identity(example_fd, "input", input_fd)
        _require_entry_identity(example_fd, "output", output_fd)
        for directory_parent_fd, directory_name, directory_fd in created_directories:
            _require_entry_identity(directory_parent_fd, directory_name, directory_fd)
        for file_parent_fd, file_name, original in created_files:
            current = os.stat(file_name, dir_fd=file_parent_fd, follow_symlinks=False)
            if not stat.S_ISREG(current.st_mode) or not _same_identity(original, current):
                raise GalleryError(f"Gallery staging file changed before publication: {file_name}")
        if gallery_fd is not None:
            _require_entry_identity(example_fd, "gallery", gallery_fd)
            _require_entry_identity(example_fd, QUARANTINE_NAME, quarantine_fd)
            _require_absent(quarantine_fd, QUARANTINE_ENTRY, "gallery quarantine entry")
            os.rename("gallery", QUARANTINE_ENTRY, src_dir_fd=example_fd, dst_dir_fd=quarantine_fd)
            _require_entry_identity(quarantine_fd, QUARANTINE_ENTRY, gallery_fd)

        os.rename(STAGING_NAME, "gallery", src_dir_fd=example_fd, dst_dir_fd=example_fd)
        _require_entry_identity(example_fd, "gallery", staging_fd)
        _require_entry_identity(repo_fd, "example-images", example_fd)
        expected = sum(len(case_ids) for case_ids in case_groups.values()) * len(fixture_stems)
        if copied != expected:
            raise GalleryError(f"Gallery copy count {copied} != expected {expected}")
    except OSError as error:
        raise GalleryError("Descriptor-relative gallery publication failed") from error
    finally:
        for descriptor in reversed(descriptors):
            try:
                os.close(descriptor)
            except OSError:
                pass


def paths_overlap(left: Path, right: Path) -> bool:
    return left == right or is_relative_to(left, right) or is_relative_to(right, left)


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def display_path(path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return path.name or "<outside-repository>"


def discover_fixture_stems(input_dir: Path) -> list[str]:
    if not input_dir.is_dir():
        raise GalleryError(f"Input directory does not exist: {display_path(input_dir)}")
    input_paths = sorted(
        path for path in input_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in SUPPORTED_INPUT_EXTENSIONS
    )
    if not input_paths:
        raise GalleryError(f"Input directory contains no supported images: {display_path(input_dir)}")
    stems = [path.stem for path in input_paths]
    duplicates = sorted(stem for stem, count in Counter(stems).items() if count > 1)
    if duplicates:
        raise GalleryError(f"Duplicate fixture stems are not supported: {', '.join(duplicates)}")
    return stems


def discover_renderer_case_ids(renderer_source: Path) -> list[str]:
    if not renderer_source.is_file():
        raise GalleryError(f"Renderer source does not exist: {display_path(renderer_source)}")
    case_ids = re.findall(r'RenderCase\(\s*id:\s*"([^"]+)"', renderer_source.read_text(encoding="utf-8"))
    if not case_ids:
        raise GalleryError("Renderer source contains no RenderCase IDs")
    return case_ids


def validate_case_inventory(gallery_case_ids: list[str], renderer_case_ids: list[str]) -> None:
    duplicates = sorted(case_id for case_id, count in Counter(gallery_case_ids).items() if count > 1)
    if duplicates:
        raise GalleryError(f"Duplicate gallery case IDs are not supported: {', '.join(duplicates)}")
    renderer_duplicates = sorted(case_id for case_id, count in Counter(renderer_case_ids).items() if count > 1)
    if renderer_duplicates:
        raise GalleryError(f"Duplicate renderer case IDs are not supported: {', '.join(renderer_duplicates)}")
    gallery_cases, renderer_cases = set(gallery_case_ids), set(renderer_case_ids)
    missing, unexpected = sorted(renderer_cases - gallery_cases), sorted(gallery_cases - renderer_cases)
    if missing or unexpected:
        details = []
        if missing:
            details.append(f"missing from gallery: {', '.join(missing)}")
        if unexpected:
            details.append(f"not in renderer: {', '.join(unexpected)}")
        raise GalleryError("Gallery case inventory does not match renderer: " + "; ".join(details))


def expect_gallery_error(label: str, function, expected_fragment: str) -> None:
    try:
        function()
    except GalleryError as error:
        if expected_fragment not in str(error):
            raise AssertionError(f"{label}: unexpected error: {error}") from error
        return
    raise AssertionError(f"{label}: expected GalleryError")


def _make_test_repository(root: Path, *, old_gallery: bool = True) -> tuple[Path, Path]:
    repo = root / "repo"
    output = repo / "example-images" / "output"
    (repo / "example-images" / "input").mkdir(parents=True)
    output.mkdir()
    (output / "f__case.png").write_bytes(b"new gallery bytes")
    if old_gallery:
        gallery = repo / "example-images" / "gallery"
        gallery.mkdir()
        (gallery / "old.txt").write_text("old gallery", encoding="utf-8")
    return repo, output


def run_self_tests() -> None:
    expect_gallery_error(
        "duplicate renderer IDs", lambda: validate_case_inventory(["only"], ["only", "only"]),
        "Duplicate renderer case IDs",
    )

    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        repo, _ = _make_test_repository(root)
        example = repo / "example-images"
        gallery = example / "gallery"
        external = root / "external"
        external.mkdir()
        sentinel = external / "must-survive.txt"
        sentinel.write_text("outside repository", encoding="utf-8")
        nested = gallery / "nested"
        nested.mkdir()
        (nested / "external-link").symlink_to(external, target_is_directory=True)

        original_listdir = os.listdir
        os.listdir = lambda *_args, **_kwargs: (_ for _ in ()).throw(AssertionError("old gallery traversed"))
        try:
            publish_gallery({"x": ["case"]}, ["f"], repo_root=repo)
        finally:
            os.listdir = original_listdir
        if sentinel.read_text(encoding="utf-8") != "outside repository":
            raise AssertionError("gallery publication touched an external sentinel")
        if not (example / QUARANTINE_NAME / QUARANTINE_ENTRY / "nested" / "external-link").is_symlink():
            raise AssertionError("preexisting gallery was traversed instead of quarantined intact")
        published = gallery / "x" / "case" / "f.png"
        if published.read_bytes() != b"new gallery bytes":
            raise AssertionError("fresh staging tree was not published")

        before = published.read_bytes()
        expect_gallery_error(
            "bounded repeated run",
            lambda: publish_gallery({"x": ["case"]}, ["f"], repo_root=repo),
            "quarantine slot already exists",
        )
        if published.read_bytes() != before or sentinel.read_text(encoding="utf-8") != "outside repository":
            raise AssertionError("blocked repeated run had external or published-gallery effects")

    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        repo, _ = _make_test_repository(root)
        example = repo / "example-images"
        displaced = repo / "example-images-before-swap"
        external = root / "external"
        (external / "gallery" / "x" / "case").mkdir(parents=True)
        sentinel = external / "gallery" / "x" / "case" / "f.png"
        sentinel.write_bytes(b"external sentinel")

        def swap_after_recreation() -> None:
            example.rename(displaced)
            example.symlink_to(external, target_is_directory=True)

        try:
            expect_gallery_error(
                "post-recreation ancestor swap",
                lambda: publish_gallery(
                    {"x": ["case"]}, ["f"], repo_root=repo, _before_publish=swap_after_recreation
                ),
                "changed after validation: example-images",
            )
            if sentinel.read_bytes() != b"external sentinel":
                raise AssertionError("ancestor swap overwrote an external gallery file")
            if not (displaced / STAGING_NAME / "x" / "case" / "f.png").is_file():
                raise AssertionError("ancestor swap did not leave the staged tree contained")
        finally:
            if example.is_symlink():
                example.unlink()
            if displaced.exists():
                displaced.rename(example)

    print(
        "self-test passed: descriptor-relative staging/copy/publication, post-recreation "
        "ancestor-swap containment, non-traversed old gallery, bounded quarantine, repeated-run "
        "fail-closed behavior, external survival, duplicate renderer IDs"
    )


if __name__ == "__main__":
    raise SystemExit(main())
