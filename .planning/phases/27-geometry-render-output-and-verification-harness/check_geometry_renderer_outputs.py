#!/usr/bin/env python3
"""Validate Phase 27 BeautyExampleRenderer geometry PNG invariants."""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path


PORTRAIT_FIXTURE_NAMES = [
    "e1.png",
    "e2.png",
    "e3.png",
    "e4.png",
    "e5.png",
]

NO_FACE_FIXTURE_NAME = "no-face-gradient.png"

FIXTURE_NAMES = PORTRAIT_FIXTURE_NAMES + [
    NO_FACE_FIXTURE_NAME,
]

RENDERER_CASE_IDS = [
    "skinSmoothing_0p50",
    "skinWhitening_0p50",
    "skinRosy_0p40",
    "skinSharpen_0p40",
    "brightness_plus0p25",
    "contrast_plus0p25",
    "filter_softClean_0p50",
    "filter_warmLight_0p50",
    "skinCombo_0p50",
    "geometryBaseline_noop",
    "faceShapeCombo_0p35",
]

BASELINE_CASE_ID = "geometryBaseline_noop"
GEOMETRY_CASE_ID = "faceShapeCombo_0p35"


class RendererOutputError(Exception):
    pass


def read_png_dimensions(path: Path, label: str) -> tuple[int, int]:
    try:
        with path.open("rb") as handle:
            signature = handle.read(8)
            if signature != b"\x89PNG\r\n\x1a\n":
                raise RendererOutputError(f"{label}: not a PNG")
            length_data = handle.read(4)
            chunk_type = handle.read(4)
            if len(length_data) != 4 or chunk_type != b"IHDR":
                raise RendererOutputError(f"{label}: missing IHDR")
            length = struct.unpack(">I", length_data)[0]
            if length < 8:
                raise RendererOutputError(f"{label}: invalid IHDR")
            ihdr = handle.read(length)
            if len(ihdr) != length:
                raise RendererOutputError(f"{label}: truncated IHDR")
            return struct.unpack(">II", ihdr[:8])
    except OSError:
        raise RendererOutputError(f"{label}: unreadable") from None


def expected_output_name(fixture_name: str, case_id: str) -> str:
    return f"{Path(fixture_name).stem}__{case_id}.png"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate generated Phase 27 geometry PNG outputs.")
    parser.add_argument("--input", required=True, help="Fixture input directory")
    parser.add_argument("--output", required=True, help="Generated renderer output directory")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    input_dir = Path(args.input)
    output_dir = Path(args.output)
    failures: list[str] = []
    checked = 0
    dimension_counts: dict[tuple[int, int], int] = {}
    output_bytes: dict[str, bytes] = {}

    for fixture_name in FIXTURE_NAMES:
        fixture_path = input_dir / fixture_name
        fixture_label = f"input/{fixture_name}"
        if not fixture_path.is_file():
            failures.append(f"{fixture_label}: missing")
            continue

        try:
            fixture_dimensions = read_png_dimensions(fixture_path, fixture_label)
        except RendererOutputError as error:
            failures.append(str(error))
            continue

        for case_id in RENDERER_CASE_IDS:
            output_name = expected_output_name(fixture_name, case_id)
            output_path = output_dir / output_name
            output_label = f"output/{output_name}"

            if not output_path.is_file():
                failures.append(f"{output_label}: missing")
                continue

            try:
                rendered = output_path.read_bytes()
            except OSError:
                failures.append(f"{output_label}: unreadable")
                continue

            if not rendered:
                failures.append(f"{output_label}: zero bytes")
                continue

            try:
                output_dimensions = read_png_dimensions(output_path, output_label)
            except RendererOutputError as error:
                failures.append(str(error))
                continue

            if output_dimensions != fixture_dimensions:
                failures.append(
                    f"{output_label}: dimensions {output_dimensions[0]}x{output_dimensions[1]} "
                    f"!= {fixture_name} {fixture_dimensions[0]}x{fixture_dimensions[1]}"
                )
                continue

            checked += 1
            output_bytes[output_name] = rendered
            dimension_counts[fixture_dimensions] = dimension_counts.get(fixture_dimensions, 0) + 1

    portrait_comparisons = 0
    for fixture_name in PORTRAIT_FIXTURE_NAMES:
        baseline_name = expected_output_name(fixture_name, BASELINE_CASE_ID)
        geometry_name = expected_output_name(fixture_name, GEOMETRY_CASE_ID)
        baseline_bytes = output_bytes.get(baseline_name)
        geometry_bytes = output_bytes.get(geometry_name)
        if baseline_bytes is None or geometry_bytes is None:
            continue
        if baseline_bytes == geometry_bytes:
            failures.append(f"output/{geometry_name}: byte-identical to {baseline_name}")
            continue
        portrait_comparisons += 1

    no_face_output = expected_output_name(NO_FACE_FIXTURE_NAME, GEOMETRY_CASE_ID)
    no_face_present = no_face_output in output_bytes
    if not no_face_present:
        failures.append(f"output/{no_face_output}: missing")

    expected = len(FIXTURE_NAMES) * len(RENDERER_CASE_IDS)
    if failures:
        print(f"phase 27 geometry renderer output check failed: {checked}/{expected} outputs")
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1

    print(f"phase 27 geometry renderer output check passed: {checked}/{expected} outputs")
    for dimensions, count in sorted(dimension_counts.items()):
        width, height = dimensions
        print(f"dimensions {width}x{height}: {count} outputs")
    print(f"portrait geometry-vs-baseline comparisons: {portrait_comparisons}/{len(PORTRAIT_FIXTURE_NAMES)}")
    print(f"no-face geometry output present: {NO_FACE_FIXTURE_NAME} -> {no_face_output}")
    print("fixtures: " + ", ".join(FIXTURE_NAMES))
    print("cases: " + ", ".join(RENDERER_CASE_IDS))
    return 0


if __name__ == "__main__":
    sys.exit(main())
