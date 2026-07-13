#!/usr/bin/env python3
"""Generate the human-review gallery from flat renderer outputs."""

from __future__ import annotations

import argparse
import shutil
import sys
from collections import Counter
from pathlib import Path


SUPPORTED_INPUT_EXTENSIONS = {".png", ".jpg", ".jpeg"}
REPO_ROOT = Path(__file__).resolve().parent.parent
ALLOWED_GALLERY_ROOT = (REPO_ROOT / "example-images" / "gallery").resolve()

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
    ],
}


class GalleryError(Exception):
    pass


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default="example-images/input", help="Committed source fixture directory.")
    parser.add_argument("--output", default="example-images/output", help="Flat generated renderer output directory.")
    parser.add_argument("--gallery", default="example-images/gallery", help="Generated human-review gallery directory.")
    args = parser.parse_args()

    try:
        generate_gallery(
            input_dir=Path(args.input),
            output_dir=Path(args.output),
            gallery_dir=Path(args.gallery),
        )
    except GalleryError as error:
        print(error, file=sys.stderr)
        return 1

    return 0


def generate_gallery(input_dir: Path, output_dir: Path, gallery_dir: Path) -> None:
    validate_gallery_directory(input_dir=input_dir, output_dir=output_dir, gallery_dir=gallery_dir)

    fixture_stems = discover_fixture_stems(input_dir)
    expected_sources = [
        output_dir / f"{fixture_stem}__{case_id}.png"
        for case_ids in CASE_GROUPS.values()
        for case_id in case_ids
        for fixture_stem in fixture_stems
    ]
    missing = [path for path in expected_sources if not path.is_file()]
    if missing:
        sample = ", ".join(display_path(path) for path in missing[:5])
        suffix = "" if len(missing) <= 5 else f", ... ({len(missing)} missing)"
        raise GalleryError(f"Missing generated output PNGs: {sample}{suffix}")

    if gallery_dir.exists() and not gallery_dir.is_dir():
        raise GalleryError("Gallery path exists but is not a directory")
    if gallery_dir.is_symlink():
        raise GalleryError("Gallery directory must not be a symbolic link")
    if gallery_dir.exists():
        shutil.rmtree(gallery_dir)
    gallery_dir.mkdir(parents=True, exist_ok=True)

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


def validate_gallery_directory(input_dir: Path, output_dir: Path, gallery_dir: Path) -> None:
    resolved_gallery = gallery_dir.resolve()
    resolved_input = input_dir.resolve()
    resolved_output = output_dir.resolve()

    if not is_relative_to(resolved_gallery, ALLOWED_GALLERY_ROOT):
        raise GalleryError("Gallery directory must be under example-images/gallery")
    if paths_overlap(resolved_gallery, resolved_input) or paths_overlap(resolved_gallery, resolved_output):
        raise GalleryError("Gallery directory must not overlap input or output directories")


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


if __name__ == "__main__":
    raise SystemExit(main())
