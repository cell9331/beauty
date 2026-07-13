#!/usr/bin/env python3
"""Generate the human-review gallery from flat renderer outputs."""

from __future__ import annotations

import argparse
import errno
import os
import re
import shutil
import stat
import sys
import tempfile
import uuid
from collections import Counter
from pathlib import Path


SUPPORTED_INPUT_EXTENSIONS = {".png", ".jpg", ".jpeg"}
REPO_ROOT = Path(__file__).resolve().parent.parent
RENDERER_SOURCE = REPO_ROOT / "BeautySDK" / "Sources" / "BeautyExampleRenderer" / "main.swift"

CASE_GROUPS = {
    "skin": [
        "skinSmoothing_0p50",
        "skinWhitening_0p50",
        "skinRosy_0p40",
        "skinSharpen_0p40",
        "skinCombo_0p50",
    ],
    "color": [
        "brightness_plus0p25",
        "contrast_plus0p25",
    ],
    "filter": [
        "filter_softClean_0p50",
        "filter_warmLight_0p50",
    ],
    "face-shape": [
        "geometryBaseline_noop",
        "faceShapeCombo_0p35",
        "faceSlim_0p35",
        "faceSmall_0p35",
        "chinLength_plus0p30",
        "chinLength_minus0p30",
        "faceVShape_0p35",
        "jawSlim_0p35",
    ],
    "eyes": [
        "eyeSize_0p35",
        "eyeDistance_plus0p25",
        "eyeDistance_minus0p25",
        "eyeYPosition_plus0p20",
        "eyeYPosition_minus0p20",
        "eyeTailLift_0p25",
    ],
    "nose": [
        "noseSlim_0p35",
        "noseWingSlim_0p35",
        "noseTipSize_plus0p30",
        "noseTipSize_minus0p30",
        "noseBridge_0p30",
        "noseRootNarrowing_0p25",
        "noseTipLift_0p25",
    ],
    "mouth": [
        "mouthSize_plus0p35",
        "mouthSize_minus0p35",
        "mouthWidth_plus0p35",
        "mouthWidth_minus0p35",
        "smile_0p50",
        "lipColor_0p50",
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
            generate_gallery(
                input_dir=Path(args.input),
                output_dir=Path(args.output),
                gallery_dir=Path(args.gallery),
            )
    except (GalleryError, AssertionError) as error:
        print(error, file=sys.stderr)
        return 1

    return 0


def generate_gallery(input_dir: Path, output_dir: Path, gallery_dir: Path) -> None:
    validate_gallery_directory(input_dir=input_dir, output_dir=output_dir, gallery_dir=gallery_dir)

    fixture_stems = discover_fixture_stems(input_dir)
    gallery_case_ids = [case_id for case_ids in CASE_GROUPS.values() for case_id in case_ids]
    validate_case_inventory(gallery_case_ids, discover_renderer_case_ids(RENDERER_SOURCE))
    expected_sources = [
        output_dir / f"{fixture_stem}__{case_id}.png"
        for case_id in gallery_case_ids
        for fixture_stem in fixture_stems
    ]
    missing = [path for path in expected_sources if not path.is_file()]
    if missing:
        sample = ", ".join(display_path(path) for path in missing[:5])
        suffix = "" if len(missing) <= 5 else f", ... ({len(missing)} missing)"
        raise GalleryError(f"Missing generated output PNGs: {sample}{suffix}")

    recreate_gallery_directory(gallery_dir)

    copied = 0
    for group, case_ids in CASE_GROUPS.items():
        for case_id in case_ids:
            case_dir = gallery_dir / group / case_id
            case_dir.mkdir(parents=True, exist_ok=True)
            for fixture_stem in fixture_stems:
                source = output_dir / f"{fixture_stem}__{case_id}.png"
                destination = case_dir / f"{fixture_stem}.png"
                shutil.copy2(source, destination)
                copied += 1

    print(f"wrote {copied} gallery PNGs under {display_path(gallery_dir)}")


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
    lexical_repo_root = lexical_absolute(repo_root)
    lexical_gallery = lexical_absolute(gallery_dir)
    allowed_gallery_root = lexical_repo_root / "example-images" / "gallery"
    if lexical_gallery != allowed_gallery_root:
        raise GalleryError("Gallery directory must be the repository example-images/gallery")
    require_no_symlink_components(lexical_gallery, lexical_repo_root)

    resolved_gallery = lexical_gallery.resolve()
    resolved_allowed_gallery = lexical_repo_root.resolve() / "example-images" / "gallery"
    resolved_input = input_dir.resolve()
    resolved_output = output_dir.resolve()

    if resolved_gallery != resolved_allowed_gallery:
        raise GalleryError("Gallery directory resolves outside the repository example-images/gallery")
    if paths_overlap(resolved_gallery, resolved_input) or paths_overlap(resolved_gallery, resolved_output):
        raise GalleryError("Gallery directory must not overlap input or output directories")


def _require_descriptor_operations() -> None:
    required_dir_fd = (os.open, os.stat, os.mkdir, os.rename, os.unlink, os.rmdir)
    if (
        not hasattr(os, "O_DIRECTORY")
        or not hasattr(os, "O_NOFOLLOW")
        or any(operation not in os.supports_dir_fd for operation in required_dir_fd)
        or os.stat not in os.supports_follow_symlinks
        or os.listdir not in os.supports_fd
    ):
        raise GalleryError("Safe descriptor-relative gallery cleanup is not supported on this platform")


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
    opened = os.fstat(opened_fd)
    if not stat.S_ISDIR(entry.st_mode) or not _same_identity(entry, opened):
        raise GalleryError(f"Gallery path changed after validation: {name}")


def _remove_directory_contents(directory_fd: int) -> None:
    """Remove an opened directory tree without resolving a child pathname outside it."""
    try:
        names = os.listdir(directory_fd)
    except OSError as error:
        raise GalleryError("Unable to enumerate quarantined gallery directory") from error

    for name in names:
        if name in (".", ".."):
            raise GalleryError("Unsafe gallery directory entry")
        try:
            entry = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        except OSError as error:
            raise GalleryError(f"Gallery entry changed during cleanup: {name}") from error

        if stat.S_ISDIR(entry.st_mode):
            child_fd = _open_directory(name, parent_fd=directory_fd)
            try:
                if not _same_identity(entry, os.fstat(child_fd)):
                    raise GalleryError(f"Gallery entry changed during cleanup: {name}")
                _remove_directory_contents(child_fd)
                _require_entry_identity(directory_fd, name, child_fd)
            finally:
                os.close(child_fd)
            try:
                os.rmdir(name, dir_fd=directory_fd)
            except OSError as error:
                raise GalleryError(f"Unable to remove gallery directory entry: {name}") from error
        else:
            try:
                os.unlink(name, dir_fd=directory_fd)
            except OSError as error:
                raise GalleryError(f"Unable to remove gallery file entry: {name}") from error


def recreate_gallery_directory(
    gallery_dir: Path,
    *,
    repo_root: Path = REPO_ROOT,
    _before_destructive_use=None,
) -> None:
    """Recreate gallery through anchored descriptors; never follow entries while deleting."""
    validate_gallery_directory(
        input_dir=repo_root / "example-images" / "input",
        output_dir=repo_root / "example-images" / "output",
        gallery_dir=gallery_dir,
        repo_root=repo_root,
    )
    _require_descriptor_operations()

    lexical_repo_root = lexical_absolute(repo_root)
    parent_fd = repo_fd = example_fd = gallery_fd = None
    try:
        parent_fd = os.open(str(lexical_repo_root.parent), _directory_open_flags())
        repo_fd = _open_directory(lexical_repo_root.name, parent_fd=parent_fd)
        _require_entry_identity(parent_fd, lexical_repo_root.name, repo_fd)
        example_fd = _open_directory("example-images", parent_fd=repo_fd)
        _require_entry_identity(repo_fd, "example-images", example_fd)

        try:
            gallery_fd = os.open("gallery", _directory_open_flags(), dir_fd=example_fd)
        except OSError as error:
            if error.errno != errno.ENOENT:
                raise GalleryError("Gallery path exists but is not a safe directory") from error

        if gallery_fd is not None:
            _require_entry_identity(example_fd, "gallery", gallery_fd)
        if _before_destructive_use is not None:
            _before_destructive_use()

        # These identity checks are deliberately after the final validation hook.
        _require_entry_identity(parent_fd, lexical_repo_root.name, repo_fd)
        _require_entry_identity(repo_fd, "example-images", example_fd)
        if gallery_fd is not None:
            _require_entry_identity(example_fd, "gallery", gallery_fd)
            quarantine_name = f".gallery-delete-{os.getpid()}-{uuid.uuid4().hex}"
            try:
                os.rename(
                    "gallery",
                    quarantine_name,
                    src_dir_fd=example_fd,
                    dst_dir_fd=example_fd,
                )
            except OSError as error:
                raise GalleryError("Gallery path changed before quarantine") from error
            _require_entry_identity(example_fd, quarantine_name, gallery_fd)
            _remove_directory_contents(gallery_fd)
            _require_entry_identity(example_fd, quarantine_name, gallery_fd)
            try:
                os.rmdir(quarantine_name, dir_fd=example_fd)
            except OSError as error:
                raise GalleryError("Unable to remove quarantined gallery directory") from error

        _require_entry_identity(repo_fd, "example-images", example_fd)
        try:
            os.mkdir("gallery", dir_fd=example_fd)
        except OSError as error:
            raise GalleryError("Unable to create gallery directory safely") from error
        created_fd = _open_directory("gallery", parent_fd=example_fd)
        try:
            _require_entry_identity(example_fd, "gallery", created_fd)
            _require_entry_identity(repo_fd, "example-images", example_fd)
        finally:
            os.close(created_fd)
    except OSError as error:
        raise GalleryError("Unable to anchor gallery cleanup to repository descriptors") from error
    finally:
        for descriptor in (gallery_fd, example_fd, repo_fd, parent_fd):
            if descriptor is not None:
                os.close(descriptor)


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
        path
        for path in input_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in SUPPORTED_INPUT_EXTENSIONS
    )
    if not input_paths:
        raise GalleryError(f"Input directory contains no supported images: {display_path(input_dir)}")

    stems = [path.stem for path in input_paths]
    counts = Counter(stems)
    duplicates = sorted(stem for stem, count in counts.items() if count > 1)
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
    counts = Counter(gallery_case_ids)
    duplicates = sorted(case_id for case_id, count in counts.items() if count > 1)
    if duplicates:
        raise GalleryError(f"Duplicate gallery case IDs are not supported: {', '.join(duplicates)}")

    renderer_counts = Counter(renderer_case_ids)
    renderer_duplicates = sorted(case_id for case_id, count in renderer_counts.items() if count > 1)
    if renderer_duplicates:
        raise GalleryError(f"Duplicate renderer case IDs are not supported: {', '.join(renderer_duplicates)}")

    gallery_cases = set(gallery_case_ids)
    renderer_cases = set(renderer_case_ids)
    missing = sorted(renderer_cases - gallery_cases)
    unexpected = sorted(gallery_cases - renderer_cases)
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


def run_self_tests() -> None:
    expect_gallery_error(
        "duplicate renderer IDs",
        lambda: validate_case_inventory(["only"], ["only", "only"]),
        "Duplicate renderer case IDs",
    )

    with tempfile.TemporaryDirectory() as temporary:
        repo_root = Path(temporary) / "repo"
        example_images = repo_root / "example-images"
        example_images.mkdir(parents=True)
        gallery = example_images / "gallery"
        external = Path(temporary) / "external"
        victim = external / "victim"
        victim.mkdir(parents=True)
        sentinel = victim / "must-survive.txt"
        sentinel.write_text("outside repository", encoding="utf-8")

        gallery.symlink_to(external, target_is_directory=True)
        expect_gallery_error(
            "symlinked gallery root",
            lambda: recreate_gallery_directory(gallery, repo_root=repo_root),
            "must not be a symbolic link",
        )
        if not sentinel.is_file():
            raise AssertionError("symlinked gallery root deleted an external file")

        gallery.unlink()
        example_images.rmdir()
        example_images.symlink_to(external, target_is_directory=True)
        expect_gallery_error(
            "symlinked gallery ancestor",
            lambda: recreate_gallery_directory(gallery, repo_root=repo_root),
            "must not be a symbolic link",
        )
        if not sentinel.is_file():
            raise AssertionError("symlinked gallery ancestor deleted an external file")

        expect_gallery_error(
            "gallery child rejected",
            lambda: recreate_gallery_directory(gallery / "victim", repo_root=repo_root),
            "must be the repository example-images/gallery",
        )
        if not sentinel.is_file():
            raise AssertionError("gallery child validation deleted an external file")

    with tempfile.TemporaryDirectory() as temporary:
        repo_root = Path(temporary) / "repo"
        example_images = repo_root / "example-images"
        gallery = example_images / "gallery"
        gallery.mkdir(parents=True)
        (gallery / "local.txt").write_text("local gallery", encoding="utf-8")

        external = Path(temporary) / "external"
        external_gallery = external / "gallery"
        external_gallery.mkdir(parents=True)
        sentinel = external_gallery / "must-survive.txt"
        sentinel.write_text("outside repository", encoding="utf-8")
        displaced = repo_root / "example-images-before-swap"

        def swap_example_images_after_validation() -> None:
            example_images.rename(displaced)
            example_images.symlink_to(external, target_is_directory=True)

        try:
            expect_gallery_error(
                "ancestor swap after final validation",
                lambda: recreate_gallery_directory(
                    gallery,
                    repo_root=repo_root,
                    _before_destructive_use=swap_example_images_after_validation,
                ),
                "changed after validation: example-images",
            )
            if not sentinel.is_file():
                raise AssertionError("ancestor swap deleted the external sentinel")
            if not (displaced / "gallery" / "local.txt").is_file():
                raise AssertionError("ancestor swap performed destructive cleanup before failing closed")
        finally:
            if example_images.is_symlink():
                example_images.unlink()
            if displaced.exists():
                displaced.rename(example_images)

    with tempfile.TemporaryDirectory() as temporary:
        repo_root = Path(temporary) / "repo"
        gallery = repo_root / "example-images" / "gallery"
        nested = gallery / "nested"
        nested.mkdir(parents=True)
        external = Path(temporary) / "external"
        external.mkdir()
        sentinel = external / "must-survive.txt"
        sentinel.write_text("outside repository", encoding="utf-8")
        (nested / "external-link").symlink_to(external, target_is_directory=True)

        recreate_gallery_directory(gallery, repo_root=repo_root)
        if not sentinel.is_file():
            raise AssertionError("descriptor-relative cleanup followed a nested symlink")
        if list(gallery.iterdir()):
            raise AssertionError("descriptor-relative cleanup did not recreate an empty gallery")

    print(
        "self-test passed: exact gallery root, static symlink containment, "
        "ancestor-swap fail-closed, recursive no-follow cleanup, external survival, "
        "duplicate renderer IDs"
    )


if __name__ == "__main__":
    raise SystemExit(main())
