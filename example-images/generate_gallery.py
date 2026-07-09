#!/usr/bin/env python3
"""Generate the human-review gallery from flat renderer outputs."""

from __future__ import annotations

import argparse
import shutil
import sys
from collections import Counter
from pathlib import Path


SUPPORTED_INPUT_EXTENSIONS = {".png", ".jpg", ".jpeg"}

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
    fixture_stems = discover_fixture_stems(input_dir)
    expected_sources = [
        output_dir / f"{fixture_stem}__{case_id}.png"
        for case_ids in CASE_GROUPS.values()
        for case_id in case_ids
        for fixture_stem in fixture_stems
    ]
    missing = [path for path in expected_sources if not path.is_file()]
    if missing:
        sample = ", ".join(str(path) for path in missing[:5])
        suffix = "" if len(missing) <= 5 else f", ... ({len(missing)} missing)"
        raise GalleryError(f"Missing generated output PNGs: {sample}{suffix}")

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

    print(f"wrote {copied} gallery PNGs under {gallery_dir}")


def discover_fixture_stems(input_dir: Path) -> list[str]:
    if not input_dir.is_dir():
        raise GalleryError(f"Input directory does not exist: {input_dir}")

    input_paths = sorted(
        path
        for path in input_dir.rglob("*")
        if path.is_file() and path.suffix.lower() in SUPPORTED_INPUT_EXTENSIONS
    )
    if not input_paths:
        raise GalleryError(f"Input directory contains no supported images: {input_dir}")

    stems = [path.stem for path in input_paths]
    counts = Counter(stems)
    duplicates = sorted(stem for stem, count in counts.items() if count > 1)
    if duplicates:
        raise GalleryError(f"Duplicate fixture stems are not supported: {', '.join(duplicates)}")

    return stems


if __name__ == "__main__":
    raise SystemExit(main())
