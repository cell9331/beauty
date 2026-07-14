#!/usr/bin/env python3
"""Validate Phase 29 BeautyExampleRenderer eye PNG invariants."""

from __future__ import annotations

import argparse
import math
import struct
import sys
import zlib
from dataclasses import dataclass
from pathlib import Path


PORTRAIT_FIXTURE_NAMES = [
    "portraits/e1.png",
    "portraits/e2.png",
    "portraits/e3.png",
    "portraits/e4.png",
    "portraits/e5.png",
    "portraits/e6.jpg",
]

NO_FACE_FIXTURE_NAME = "negatives/no-face-gradient.png"

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
    "faceSlim_0p35",
    "faceSmall_0p35",
    "chinLength_plus0p30",
    "chinLength_minus0p30",
    "faceVShape_0p35",
    "jawSlim_0p35",
    "eyeSize_0p35",
    "eyeDistance_plus0p25",
    "eyeDistance_minus0p25",
    "eyeYPosition_plus0p20",
    "eyeYPosition_minus0p20",
    "eyeTailLift_0p25",
]

BASELINE_CASE_ID = "geometryBaseline_noop"

PHASE29_EYE_CASE_IDS = [
    "eyeSize_0p35",
    "eyeDistance_plus0p25",
    "eyeDistance_minus0p25",
    "eyeYPosition_plus0p20",
    "eyeYPosition_minus0p20",
    "eyeTailLift_0p25",
]


class RendererOutputError(Exception):
    pass


@dataclass(frozen=True)
class PNGPayload:
    width: int
    height: int
    color_type: int
    raw: bytes


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


def read_jpeg_dimensions(path: Path, label: str) -> tuple[int, int]:
    try:
        data = path.read_bytes()
    except OSError:
        raise RendererOutputError(f"{label}: unreadable") from None

    if len(data) < 4 or data[:2] != b"\xff\xd8":
        raise RendererOutputError(f"{label}: not a JPEG")

    offset = 2
    while offset + 4 <= len(data):
        if data[offset] != 0xFF:
            raise RendererOutputError(f"{label}: invalid JPEG marker")
        while offset < len(data) and data[offset] == 0xFF:
            offset += 1
        if offset >= len(data):
            break
        marker = data[offset]
        offset += 1
        if marker in (0xD8, 0xD9) or 0xD0 <= marker <= 0xD7:
            continue
        if offset + 2 > len(data):
            break
        segment_length = struct.unpack(">H", data[offset : offset + 2])[0]
        if segment_length < 2 or offset + segment_length > len(data):
            raise RendererOutputError(f"{label}: invalid JPEG segment")
        if marker in (0xC0, 0xC1, 0xC2):
            segment = data[offset + 2 : offset + segment_length]
            if len(segment) < 5:
                raise RendererOutputError(f"{label}: truncated JPEG SOF")
            height, width = struct.unpack(">HH", segment[1:5])
            return width, height
        offset += segment_length

    raise RendererOutputError(f"{label}: missing JPEG dimensions")


def read_fixture_dimensions(path: Path, label: str) -> tuple[int, int]:
    extension = path.suffix.lower()
    if extension == ".png":
        return read_png_dimensions(path, label)
    if extension in (".jpg", ".jpeg"):
        return read_jpeg_dimensions(path, label)
    raise RendererOutputError(f"{label}: unsupported fixture type")


def read_png_payload(path: Path, label: str) -> PNGPayload:
    try:
        data = path.read_bytes()
    except OSError:
        raise RendererOutputError(f"{label}: unreadable") from None

    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise RendererOutputError(f"{label}: not a PNG")

    width: int | None = None
    height: int | None = None
    bit_depth: int | None = None
    color_type: int | None = None
    compression_method: int | None = None
    filter_method: int | None = None
    interlace_method: int | None = None
    idat_chunks: list[bytes] = []
    seen_iend = False

    offset = 8
    while offset + 8 <= len(data):
        length = struct.unpack(">I", data[offset : offset + 4])[0]
        chunk_type = data[offset + 4 : offset + 8]
        chunk_start = offset + 8
        chunk_end = chunk_start + length
        if chunk_end + 4 > len(data):
            raise RendererOutputError(f"{label}: truncated chunk")
        chunk_data = data[chunk_start:chunk_end]
        offset = chunk_end + 4

        if chunk_type == b"IHDR":
            if length != 13:
                raise RendererOutputError(f"{label}: invalid IHDR")
            width, height = struct.unpack(">II", chunk_data[:8])
            bit_depth = chunk_data[8]
            color_type = chunk_data[9]
            compression_method = chunk_data[10]
            filter_method = chunk_data[11]
            interlace_method = chunk_data[12]
        elif chunk_type == b"IDAT":
            idat_chunks.append(chunk_data)
        elif chunk_type == b"IEND":
            seen_iend = True
            break

    if width is None or height is None:
        raise RendererOutputError(f"{label}: missing IHDR")
    if not seen_iend:
        raise RendererOutputError(f"{label}: missing IEND")
    if bit_depth != 8 or color_type not in (2, 6):
        raise RendererOutputError(f"{label}: unsupported PNG color type")
    if compression_method != 0 or filter_method != 0 or interlace_method != 0:
        raise RendererOutputError(f"{label}: unsupported PNG encoding")

    try:
        raw = zlib.decompress(b"".join(idat_chunks))
    except zlib.error:
        raise RendererOutputError(f"{label}: invalid PNG data") from None

    channels = 4 if color_type == 6 else 3
    expected_length = (width * channels + 1) * height
    if len(raw) < expected_length:
        raise RendererOutputError(f"{label}: truncated image data")
    if len(raw) > expected_length:
        raise RendererOutputError(f"{label}: invalid image data length")

    return PNGPayload(width=width, height=height, color_type=color_type, raw=raw)


def unfilter_scanline(
    row: bytearray,
    previous: bytearray,
    bytes_per_pixel: int,
    filter_type: int,
    label: str,
) -> None:
    if filter_type == 0:
        return

    if filter_type == 1:
        for index in range(len(row)):
            left = row[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
            row[index] = (row[index] + left) & 0xFF
        return

    if filter_type == 2:
        for index in range(len(row)):
            row[index] = (row[index] + previous[index]) & 0xFF
        return

    if filter_type == 3:
        for index in range(len(row)):
            left = row[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
            up = previous[index]
            row[index] = (row[index] + ((left + up) // 2)) & 0xFF
        return

    if filter_type == 4:
        for index in range(len(row)):
            left = row[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
            up = previous[index]
            upper_left = previous[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
            row[index] = (row[index] + paeth_predictor(left, up, upper_left)) & 0xFF
        return

    raise RendererOutputError(f"{label}: unsupported PNG filter")


def paeth_predictor(left: int, up: int, upper_left: int) -> int:
    estimate = left + up - upper_left
    distance_left = abs(estimate - left)
    distance_up = abs(estimate - up)
    distance_upper_left = abs(estimate - upper_left)
    if distance_left <= distance_up and distance_left <= distance_upper_left:
        return left
    if distance_up <= distance_upper_left:
        return up
    return upper_left


def expected_output_name(fixture_name: str, case_id: str) -> str:
    return f"{Path(fixture_name).stem}__{case_id}.png"


def comparable_top_region_rows(width: int, height: int) -> int:
    font_size = max(34.0, min(72.0, width / 30.0))
    padding = max(24.0, width / 70.0)
    watermark_band = font_size * 1.75
    excluded_bottom_rows = int(math.ceil(padding * 2 + watermark_band))
    return max(0, height - excluded_bottom_rows)


def top_region_differs(
    baseline_path: Path,
    eye_path: Path,
    label: str,
) -> bool:
    baseline = read_png_payload(baseline_path, f"output/{baseline_path.name}")
    eye = read_png_payload(eye_path, f"output/{eye_path.name}")
    if baseline.width != eye.width or baseline.height != eye.height:
        raise RendererOutputError(f"{label}: comparison dimensions differ")

    comparable_rows = comparable_top_region_rows(baseline.width, baseline.height)
    if comparable_rows <= 0:
        raise RendererOutputError(f"{label}: no comparable rows above watermark")

    baseline_channels = 4 if baseline.color_type == 6 else 3
    eye_channels = 4 if eye.color_type == 6 else 3
    baseline_row_length = baseline.width * baseline_channels
    eye_row_length = eye.width * eye_channels
    baseline_previous = bytearray(baseline_row_length)
    eye_previous = bytearray(eye_row_length)
    baseline_offset = 0
    eye_offset = 0

    for _ in range(comparable_rows):
        baseline_filter = baseline.raw[baseline_offset]
        baseline_offset += 1
        baseline_row = bytearray(baseline.raw[baseline_offset : baseline_offset + baseline_row_length])
        baseline_offset += baseline_row_length
        unfilter_scanline(
            baseline_row,
            baseline_previous,
            baseline_channels,
            baseline_filter,
            f"output/{baseline_path.name}",
        )

        eye_filter = eye.raw[eye_offset]
        eye_offset += 1
        eye_row = bytearray(eye.raw[eye_offset : eye_offset + eye_row_length])
        eye_offset += eye_row_length
        unfilter_scanline(
            eye_row,
            eye_previous,
            eye_channels,
            eye_filter,
            f"output/{eye_path.name}",
        )

        if rows_differ(
            baseline_row,
            baseline.color_type,
            eye_row,
            eye.color_type,
            baseline.width,
        ):
            return True

        baseline_previous = baseline_row
        eye_previous = eye_row

    return False


def rows_differ(
    baseline_row: bytearray,
    baseline_color_type: int,
    eye_row: bytearray,
    eye_color_type: int,
    width: int,
) -> bool:
    if baseline_color_type == eye_color_type:
        return baseline_row != eye_row

    for column in range(width):
        baseline_source = column * (4 if baseline_color_type == 6 else 3)
        eye_source = column * (4 if eye_color_type == 6 else 3)
        baseline_pixel = baseline_row[baseline_source : baseline_source + 3]
        eye_pixel = eye_row[eye_source : eye_source + 3]
        if baseline_pixel != eye_pixel:
            return True
        baseline_alpha = baseline_row[baseline_source + 3] if baseline_color_type == 6 else 255
        eye_alpha = eye_row[eye_source + 3] if eye_color_type == 6 else 255
        if baseline_alpha != eye_alpha:
            return True
    return False


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate generated Phase 29 eye PNG outputs.")
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
            fixture_dimensions = read_fixture_dimensions(fixture_path, fixture_label)
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
                output_payload = read_png_payload(output_path, output_label)
            except RendererOutputError as error:
                failures.append(str(error))
                continue

            output_dimensions = (output_payload.width, output_payload.height)
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
        baseline_bytes = output_bytes.get(baseline_name)
        if baseline_bytes is None:
            continue

        for case_id in PHASE29_EYE_CASE_IDS:
            eye_name = expected_output_name(fixture_name, case_id)
            eye_bytes = output_bytes.get(eye_name)
            if eye_bytes is None:
                continue
            baseline_path = output_dir / baseline_name
            eye_path = output_dir / eye_name
            try:
                differs = top_region_differs(
                    baseline_path,
                    eye_path,
                    f"output/{eye_name}",
                )
            except RendererOutputError as error:
                failures.append(str(error))
                continue
            if not differs:
                failures.append(f"output/{eye_name}: top region byte-identical to {baseline_name}")
                continue
            portrait_comparisons += 1

    expected_comparisons = len(PORTRAIT_FIXTURE_NAMES) * len(PHASE29_EYE_CASE_IDS)
    if portrait_comparisons != expected_comparisons:
        failures.append(
            f"portrait eye-vs-baseline top-region comparisons: "
            f"{portrait_comparisons}/{expected_comparisons}"
        )

    no_face_output = expected_output_name(NO_FACE_FIXTURE_NAME, "eyeSize_0p35")
    no_face_present = no_face_output in output_bytes
    if not no_face_present:
        failures.append(f"output/{no_face_output}: missing")

    expected = len(FIXTURE_NAMES) * len(RENDERER_CASE_IDS)
    if failures:
        print(f"phase 29 eye renderer output check failed: {checked}/{expected} outputs")
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1

    print(f"phase 29 eye renderer output check passed: {checked}/{expected} outputs")
    for dimensions, count in sorted(dimension_counts.items()):
        width, height = dimensions
        print(f"dimensions {width}x{height}: {count} outputs")
    print(f"portrait eye-vs-baseline top-region comparisons: {portrait_comparisons}/{expected_comparisons}")
    print(f"no-face eye output present: {NO_FACE_FIXTURE_NAME} -> {no_face_output}")
    print("fixtures: " + ", ".join(FIXTURE_NAMES))
    print("cases: " + ", ".join(RENDERER_CASE_IDS))
    print("phase 29 cases: " + ", ".join(PHASE29_EYE_CASE_IDS))
    return 0


if __name__ == "__main__":
    sys.exit(main())
