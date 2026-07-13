#!/usr/bin/env python3
"""Validate Phase 33 mouth/lip outputs with decoded, mouth-local evidence."""

from __future__ import annotations

import importlib.util
import sys
from functools import lru_cache
from pathlib import Path


PHASE_DIR = Path(__file__).resolve().parent
EYE_HELPER = PHASE_DIR.parent / "29-eye-renderer-output-evidence" / "check_eye_renderer_outputs.py"
SPEC = importlib.util.spec_from_file_location("phase29_output_helper", EYE_HELPER)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError("Phase 29 output helper is unavailable")
helper = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = helper
SPEC.loader.exec_module(helper)

NOSE_CASE_IDS = [
    "noseSlim_0p35", "noseWingSlim_0p35", "noseTipSize_plus0p30",
    "noseTipSize_minus0p30", "noseBridge_0p30",
]
GEOMETRY_CASE_IDS = [
    "mouthSize_plus0p35", "mouthSize_minus0p35",
    "mouthWidth_plus0p35", "mouthWidth_minus0p35", "smile_0p50",
]
LIP_COLOR_CASE_ID = "lipColor_0p50"
MOUTH_CASE_IDS = GEOMETRY_CASE_IDS + [LIP_COLOR_CASE_ID]

helper.RENDERER_CASE_IDS = helper.RENDERER_CASE_IDS + NOSE_CASE_IDS + MOUTH_CASE_IDS
helper.PHASE29_EYE_CASE_IDS = []


@lru_cache(maxsize=None)
def decoded_rgb(path: Path) -> tuple[int, int, list[bytes]]:
    payload = helper.read_png_payload(path, f"output/{path.name}")
    channels = 4 if payload.color_type == 6 else 3
    row_length = payload.width * channels
    previous = bytearray(row_length)
    offset = 0
    rows: list[bytes] = []
    for _ in range(payload.height):
        filter_type = payload.raw[offset]
        offset += 1
        row = bytearray(payload.raw[offset:offset + row_length])
        offset += row_length
        helper.unfilter_scanline(row, previous, channels, filter_type, f"output/{path.name}")
        rows.append(b"".join(row[index:index + 3] for index in range(0, len(row), channels)))
        previous = row
    return payload.width, payload.height, rows


def region_difference_count(baseline_path: Path, candidate_path: Path) -> tuple[int, int, int]:
    width, height, baseline_rows = decoded_rgb(baseline_path)
    other_width, other_height, candidate_rows = decoded_rgb(candidate_path)
    if (width, height) != (other_width, other_height):
        raise helper.RendererOutputError("comparison dimensions differ")

    # Portrait fixtures are centered; this lower-central crop contains the mouth
    # while remaining above the renderer's bottom watermark band.
    left, right = int(width * 0.10), int(width * 0.90)
    top, bottom = int(height * 0.25), helper.comparable_top_region_rows(width, height)
    changed = outside = total = 0
    for row_index in range(bottom):
        baseline = baseline_rows[row_index]
        candidate = candidate_rows[row_index]
        for column in range(width):
            start = column * 3
            if baseline[start:start + 3] != candidate[start:start + 3]:
                if top <= row_index < bottom and left <= column < right:
                    changed += 1
                else:
                    outside += 1
            if top <= row_index < bottom and left <= column < right:
                total += 1
    return changed, outside, total


def main() -> int:
    args = helper.parse_args()
    result = helper.main()
    if result != 0:
        return result

    output_dir = Path(args.output)
    failures: list[str] = []
    geometry_comparisons = signed_comparisons = color_comparisons = 0
    for fixture_name in helper.PORTRAIT_FIXTURE_NAMES:
        baseline = output_dir / helper.expected_output_name(fixture_name, helper.BASELINE_CASE_ID)
        for case_id in GEOMETRY_CASE_IDS:
            candidate = output_dir / helper.expected_output_name(fixture_name, case_id)
            changed, _, total = region_difference_count(baseline, candidate)
            if changed == 0:
                failures.append(f"output/{candidate.name}: mouth ROI unchanged from baseline")
            else:
                geometry_comparisons += 1

        for positive_id, negative_id in [
            ("mouthSize_plus0p35", "mouthSize_minus0p35"),
            ("mouthWidth_plus0p35", "mouthWidth_minus0p35"),
        ]:
            positive = output_dir / helper.expected_output_name(fixture_name, positive_id)
            negative = output_dir / helper.expected_output_name(fixture_name, negative_id)
            changed, _, _ = region_difference_count(positive, negative)
            if changed == 0:
                failures.append(f"output/{positive.name}: mouth ROI unchanged from {negative.name}")
            else:
                signed_comparisons += 1

        lip = output_dir / helper.expected_output_name(fixture_name, LIP_COLOR_CASE_ID)
        changed, outside, total = region_difference_count(baseline, lip)
        if changed == 0 or total == 0 or outside != 0:
            failures.append(f"output/{lip.name}: documented mouth color ROI unchanged")
        else:
            color_comparisons += 1

    no_face_name = helper.expected_output_name(helper.NO_FACE_FIXTURE_NAME, "mouthSize_plus0p35")
    no_face = output_dir / no_face_name
    if not no_face.is_file():
        failures.append(f"output/{no_face_name}: missing")

    if failures:
        print("phase 33 mouth renderer output check failed")
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1

    print("phase 33 mouth renderer output check passed: 238/238 outputs")
    print(f"portrait mouth-geometry ROI comparisons: {geometry_comparisons}/30")
    print(f"signed mouth positive-vs-negative ROI comparisons: {signed_comparisons}/12")
    print(f"lip-color mouth-region containment comparisons: {color_comparisons}/6")
    print(f"no-face mouth output present: {helper.NO_FACE_FIXTURE_NAME} -> {no_face_name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
