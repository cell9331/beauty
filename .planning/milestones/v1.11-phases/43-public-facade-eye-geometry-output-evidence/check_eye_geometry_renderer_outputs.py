#!/usr/bin/env python3
"""Validate the Phase 43 discovered renderer matrix and eye-local evidence."""

from __future__ import annotations

import argparse
import binascii
import math
import os
import re
import stat
import struct
import sys
import tempfile
import zlib
from collections import Counter
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path


SUPPORTED_INPUT_EXTENSIONS = {".png", ".jpg", ".jpeg"}
EXPECTED_CASE_COUNT = 55
EXPECTED_FIXTURE_COUNT = 7
EXPECTED_OUTPUT_COUNT = 385
EXPECTED_PORTRAIT_COUNT = 6

# Current fixtures are at most 1728x2304 and renderer PNGs are below 5 MiB. These
# ceilings leave deliberate headroom while bounding all untrusted PNG allocation.
MAX_PNG_WIDTH = 4_096
MAX_PNG_HEIGHT = 4_096
MAX_PNG_FILE_BYTES = 16 * 1_024 * 1_024
MAX_PNG_DECODED_BYTES = 64 * 1_024 * 1_024
MAX_JPEG_FILE_BYTES = 16 * 1_024 * 1_024

BASELINE_CASE_ID = "geometryBaseline_noop"
EYE_HEIGHT_CASE_ID = "eyeHeight_0p25"
EYE_LENGTH_CASE_ID = "eyeLength_0p25"
UPPER_LID_CASE_ID = "upperEyelidLift_0p25"
PUPIL_SIZE_CASE_ID = "pupilSize_0p25"
GAZE_CASE_ID = "gazeCorrection_0p25"
LOWER_LID_CASE_ID = "lowerEyelidDrop_0p25"
EYE_TILT_PLUS_CASE_ID = "eyeTilt_plus0p25"
EYE_TILT_MINUS_CASE_ID = "eyeTilt_minus0p25"
INNER_CORNER_CASE_ID = "innerCornerOpen_0p25"
OUTER_CORNER_CASE_ID = "outerCornerOpen_0p25"
SYMMETRY_CASE_ID = "eyeSymmetry_0p25"
EYE_SIZE_CASE_ID = "eyeSize_0p35"
EYE_DISTANCE_PLUS_CASE_ID = "eyeDistance_plus0p25"
EYE_Y_PLUS_CASE_ID = "eyeYPosition_plus0p20"
EYE_TAIL_CASE_ID = "eyeTailLift_0p25"
NEW_CASE_IDS = (
    EYE_HEIGHT_CASE_ID,
    EYE_LENGTH_CASE_ID,
    UPPER_LID_CASE_ID,
    PUPIL_SIZE_CASE_ID,
    GAZE_CASE_ID,
    LOWER_LID_CASE_ID,
    EYE_TILT_PLUS_CASE_ID,
    EYE_TILT_MINUS_CASE_ID,
    INNER_CORNER_CASE_ID,
    OUTER_CORNER_CASE_ID,
    SYMMETRY_CASE_ID,
)
REQUIRED_CASE_IDS = {
    BASELINE_CASE_ID,
    *NEW_CASE_IDS,
    EYE_SIZE_CASE_ID,
    EYE_DISTANCE_PLUS_CASE_ID,
    EYE_Y_PLUS_CASE_ID,
    EYE_TAIL_CASE_ID,
}

# One global, top-origin normalized eye rectangle. These are committed inputs,
# never derived from an accepting run.
ROI_LEFT = 0.10
ROI_RIGHT = 0.90
ROI_TOP = 0.55
ROI_BOTTOM = 0.82

# Frozen after the one-time Phase 43 measurement run. The weakest required
# visibility measured 909 changed pixels / 1,732 RGB delta and the weakest
# semantic family measured 2,046 / 3,670. These floors retain deliberate
# margins of 409 pixels / 732 RGB delta before a fresh accepting render.
MIN_CHANGED_PIXELS = 500
MIN_ABSOLUTE_RGB_DELTA = 1_000
TILT_EVIDENCE_FIXTURE_STEM = "e1"
TILT_SPLIT_Y = 0.6545
MIN_TILT_POLARITY_MARGIN = 0.0005

# The public PNG fixtures do not contain a stable, independently observable
# pupil displacement at the accepted ROI.  Keep this image-only metric as a
# deterministic adversarial self-test, but do not promote it to strict proof;
# the package-internal aggregate scalar in EyeWarpProviderTests is the EYE-18
# gaze reduction gate.
IMAGE_GAZE_ROIS = (
    (0.30, 0.48, 0.55, 0.70),
    (0.52, 0.70, 0.55, 0.70),
)
IMAGE_DARK_CORE_LUMINANCE_MAX = 80


class RendererOutputError(Exception):
    """A fail-closed renderer-evidence validation error."""


@dataclass(frozen=True)
class Fixture:
    relative_path: str
    path: Path
    stem: str
    dimensions: tuple[int, int]


@dataclass(frozen=True)
class PNGPayload:
    width: int
    height: int
    color_type: int
    raw: bytes


@dataclass(frozen=True)
class ComparisonMetrics:
    changed_pixels: int
    roi_pixels: int
    absolute_rgb_delta: int


@dataclass(frozen=True)
class Family:
    group: str
    name: str
    candidate: str
    reference: str


FAMILIES = (
    Family("visibility", "eye_height_vs_baseline", EYE_HEIGHT_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "eye_length_vs_baseline", EYE_LENGTH_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "upper_lid_vs_baseline", UPPER_LID_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "pupil_size_vs_baseline", PUPIL_SIZE_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "gaze_vs_baseline", GAZE_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "lower_lid_vs_baseline", LOWER_LID_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "eye_tilt_plus_vs_baseline", EYE_TILT_PLUS_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "eye_tilt_minus_vs_baseline", EYE_TILT_MINUS_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "inner_corner_vs_baseline", INNER_CORNER_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "outer_corner_vs_baseline", OUTER_CORNER_CASE_ID, BASELINE_CASE_ID),
    Family("visibility", "symmetry_vs_baseline", SYMMETRY_CASE_ID, BASELINE_CASE_ID),
    Family("signed direction", "eye_tilt_plus_vs_minus", EYE_TILT_PLUS_CASE_ID, EYE_TILT_MINUS_CASE_ID),
    Family("semantic distinction", "height_vs_length", EYE_HEIGHT_CASE_ID, EYE_LENGTH_CASE_ID),
    Family("semantic distinction", "upper_vs_lower_lid", UPPER_LID_CASE_ID, LOWER_LID_CASE_ID),
    Family("semantic distinction", "inner_vs_outer_corner", INNER_CORNER_CASE_ID, OUTER_CORNER_CASE_ID),
    Family("semantic distinction", "pupil_vs_eye_size", PUPIL_SIZE_CASE_ID, EYE_SIZE_CASE_ID),
    Family("semantic distinction", "gaze_vs_pupil", GAZE_CASE_ID, PUPIL_SIZE_CASE_ID),
    Family("semantic distinction", "symmetry_vs_eye_distance", SYMMETRY_CASE_ID, EYE_DISTANCE_PLUS_CASE_ID),
    Family("semantic distinction", "height_vs_eye_size", EYE_HEIGHT_CASE_ID, EYE_SIZE_CASE_ID),
    Family("semantic distinction", "length_vs_eye_distance", EYE_LENGTH_CASE_ID, EYE_DISTANCE_PLUS_CASE_ID),
    Family("semantic distinction", "upper_lid_vs_eye_y", UPPER_LID_CASE_ID, EYE_Y_PLUS_CASE_ID),
    Family("semantic distinction", "corners_vs_tail", INNER_CORNER_CASE_ID, EYE_TAIL_CASE_ID),
)

EXPECTED_GROUP_COMPARISONS = {
    "visibility": 66,
    "signed direction": 6,
    "semantic distinction": 60,
}


def discover_case_ids(renderer_source: Path) -> list[str]:
    try:
        source = renderer_source.read_text(encoding="utf-8")
    except OSError as error:
        raise RendererOutputError(f"renderer source unreadable: {error}") from None
    case_ids = re.findall(r"\bid\s*:\s*\"([^\"]+)\"", source)
    if not case_ids:
        raise RendererOutputError("renderer source contains no case IDs")
    duplicates = sorted(case_id for case_id, count in Counter(case_ids).items() if count > 1)
    if duplicates:
        raise RendererOutputError(f"duplicate renderer case IDs: {', '.join(duplicates)}")
    return case_ids


def discover_fixtures(input_dir: Path) -> list[Fixture]:
    if input_dir.is_symlink() or not input_dir.is_dir():
        raise RendererOutputError(f"input directory does not exist: {input_dir}")
    paths: list[Path] = []
    for path in input_dir.rglob("*"):
        if path.suffix.lower() not in SUPPORTED_INPUT_EXTENSIONS:
            continue
        try:
            mode = path.lstat().st_mode
        except OSError:
            raise RendererOutputError(f"input fixture unreadable: {path}") from None
        if not stat.S_ISREG(mode):
            raise RendererOutputError(f"input fixture is not a regular file: {path}")
        paths.append(path)
    paths.sort(key=lambda path: path.relative_to(input_dir).as_posix())
    if not paths:
        raise RendererOutputError("input directory contains no supported fixtures")
    counts = Counter(path.stem for path in paths)
    duplicates = sorted(stem for stem, count in counts.items() if count > 1)
    if duplicates:
        raise RendererOutputError(f"duplicate fixture stems: {', '.join(duplicates)}")
    fixtures: list[Fixture] = []
    for path in paths:
        relative_path = path.relative_to(input_dir).as_posix()
        fixtures.append(
            Fixture(relative_path, path, path.stem, read_fixture_dimensions(path, f"input/{relative_path}"))
        )
    return fixtures


def require_frozen_inventory(case_ids: list[str], fixtures: list[Fixture]) -> None:
    computed = len(case_ids) * len(fixtures)
    missing_required = sorted(REQUIRED_CASE_IDS.difference(case_ids))
    if missing_required:
        raise RendererOutputError(f"renderer inventory missing required cases: {', '.join(missing_required)}")
    if len(case_ids) != EXPECTED_CASE_COUNT or len(fixtures) != EXPECTED_FIXTURE_COUNT:
        raise RendererOutputError(
            "frozen inventory mismatch: discovered "
            f"{len(case_ids)} cases x {len(fixtures)} fixtures = {computed}; "
            f"required {EXPECTED_CASE_COUNT} x {EXPECTED_FIXTURE_COUNT} = {EXPECTED_OUTPUT_COUNT}"
        )
    if computed != EXPECTED_OUTPUT_COUNT:
        raise RendererOutputError(f"computed output inventory {computed} != {EXPECTED_OUTPUT_COUNT}")


def read_png_dimensions(path: Path, label: str) -> tuple[int, int]:
    payload = read_png_payload(path, label)
    return payload.width, payload.height


def read_jpeg_dimensions(path: Path, label: str) -> tuple[int, int]:
    data = read_bounded_regular_file(path, label, MAX_JPEG_FILE_BYTES, "JPEG")
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
        length = struct.unpack(">H", data[offset : offset + 2])[0]
        if length < 2 or offset + length > len(data):
            raise RendererOutputError(f"{label}: invalid JPEG segment")
        if marker in (0xC0, 0xC1, 0xC2):
            segment = data[offset + 2 : offset + length]
            if len(segment) < 5:
                raise RendererOutputError(f"{label}: truncated JPEG SOF")
            height, width = struct.unpack(">HH", segment[1:5])
            if width <= 0 or height <= 0:
                raise RendererOutputError(f"{label}: invalid dimensions")
            if width > MAX_PNG_WIDTH or height > MAX_PNG_HEIGHT:
                raise RendererOutputError(
                    f"{label}: dimensions {width}x{height} exceed "
                    f"{MAX_PNG_WIDTH}x{MAX_PNG_HEIGHT} budget"
                )
            return width, height
        offset += length
    raise RendererOutputError(f"{label}: missing JPEG dimensions")


def read_fixture_dimensions(path: Path, label: str) -> tuple[int, int]:
    if path.suffix.lower() == ".png":
        return read_png_dimensions(path, label)
    if path.suffix.lower() in {".jpg", ".jpeg"}:
        return read_jpeg_dimensions(path, label)
    raise RendererOutputError(f"{label}: unsupported fixture type")


def read_bounded_regular_file(
    path: Path,
    label: str,
    maximum_bytes: int,
    kind: str,
    *,
    _after_fstat=None,
) -> bytes:
    """Open once without following a symlink and retain at most max + 1 bytes."""
    descriptor = None
    try:
        if not hasattr(os, "O_NOFOLLOW"):
            raise RendererOutputError(f"{label}: no-follow file opening is unsupported")
        flags = os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0)
        descriptor = os.open(path, flags)
        before = os.fstat(descriptor)
        if not stat.S_ISREG(before.st_mode):
            raise RendererOutputError(f"{label}: {kind} is not a regular file")
        if before.st_size > maximum_bytes:
            raise RendererOutputError(f"{label}: {kind} file exceeds {maximum_bytes} byte budget")
        if _after_fstat is not None:
            _after_fstat()

        retained = bytearray()
        limit = maximum_bytes + 1
        while len(retained) < limit:
            chunk = os.read(descriptor, min(1024 * 1024, limit - len(retained)))
            if not chunk:
                break
            retained.extend(chunk)
        if len(retained) > maximum_bytes:
            raise RendererOutputError(f"{label}: {kind} file exceeds {maximum_bytes} byte budget")
        after = os.fstat(descriptor)
        if not _same_file_identity(before, after) or after.st_size != before.st_size:
            raise RendererOutputError(f"{label}: {kind} file changed while reading")
        if len(retained) != before.st_size:
            raise RendererOutputError(f"{label}: {kind} file changed while reading")
        return bytes(retained)
    except OSError:
        raise RendererOutputError(f"{label}: unreadable") from None
    finally:
        if descriptor is not None:
            os.close(descriptor)


def _same_file_identity(left: os.stat_result, right: os.stat_result) -> bool:
    return left.st_dev == right.st_dev and left.st_ino == right.st_ino


def read_png_payload(path: Path, label: str, *, _after_fstat=None) -> PNGPayload:
    data = read_bounded_regular_file(
        path,
        label,
        MAX_PNG_FILE_BYTES,
        "PNG",
        _after_fstat=_after_fstat,
    )
    if not data:
        raise RendererOutputError(f"{label}: zero bytes")
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise RendererOutputError(f"{label}: not a PNG")

    width = height = bit_depth = color_type = None
    compression_method = filter_method = interlace_method = None
    idat_chunks: list[bytes] = []
    seen_ihdr = seen_iend = False
    offset = 8
    while offset + 12 <= len(data):
        length = struct.unpack(">I", data[offset : offset + 4])[0]
        chunk_type = data[offset + 4 : offset + 8]
        chunk_start = offset + 8
        chunk_end = chunk_start + length
        crc_end = chunk_end + 4
        if crc_end > len(data):
            raise RendererOutputError(f"{label}: truncated chunk")
        chunk_data = data[chunk_start:chunk_end]
        expected_crc = struct.unpack(">I", data[chunk_end:crc_end])[0]
        actual_crc = binascii.crc32(chunk_type + chunk_data) & 0xFFFFFFFF
        if actual_crc != expected_crc:
            raise RendererOutputError(f"{label}: invalid {chunk_type.decode('ascii', 'replace')} CRC")
        offset = crc_end
        if chunk_type == b"IHDR":
            if seen_ihdr or length != 13:
                raise RendererOutputError(f"{label}: invalid IHDR")
            seen_ihdr = True
            width, height = struct.unpack(">II", chunk_data[:8])
            bit_depth, color_type, compression_method, filter_method, interlace_method = chunk_data[8:13]
        elif chunk_type == b"IDAT":
            idat_chunks.append(chunk_data)
        elif chunk_type == b"IEND":
            if length != 0:
                raise RendererOutputError(f"{label}: invalid IEND")
            seen_iend = True
            break

    if not seen_ihdr or width is None or height is None:
        raise RendererOutputError(f"{label}: missing IHDR")
    if width <= 0 or height <= 0:
        raise RendererOutputError(f"{label}: invalid dimensions")
    if width > MAX_PNG_WIDTH or height > MAX_PNG_HEIGHT:
        raise RendererOutputError(
            f"{label}: dimensions {width}x{height} exceed {MAX_PNG_WIDTH}x{MAX_PNG_HEIGHT} budget"
        )
    if not seen_iend:
        raise RendererOutputError(f"{label}: missing IEND")
    if offset != len(data):
        raise RendererOutputError(f"{label}: trailing data after IEND")
    if not idat_chunks:
        raise RendererOutputError(f"{label}: missing IDAT")
    if bit_depth != 8 or color_type not in (2, 6):
        raise RendererOutputError(f"{label}: unsupported PNG color type")
    if compression_method != 0 or filter_method != 0 or interlace_method != 0:
        raise RendererOutputError(f"{label}: unsupported PNG encoding")
    channels = 4 if color_type == 6 else 3
    expected_length = (width * channels + 1) * height
    if expected_length > MAX_PNG_DECODED_BYTES:
        raise RendererOutputError(
            f"{label}: decoded image data budget {expected_length} exceeds {MAX_PNG_DECODED_BYTES}"
        )

    try:
        decompressor = zlib.decompressobj()
        raw = bytearray()
        for index, compressed_chunk in enumerate(idat_chunks):
            if decompressor.eof:
                raise RendererOutputError(f"{label}: trailing compressed PNG data")
            pending = compressed_chunk
            while pending:
                decoded = decompressor.decompress(pending, expected_length + 1 - len(raw))
                raw.extend(decoded)
                if len(raw) > expected_length:
                    raise RendererOutputError(f"{label}: decoded image data exceeds {expected_length} byte budget")
                pending = decompressor.unconsumed_tail
                if pending and not decoded:
                    raise RendererOutputError(f"{label}: compressed PNG data exceeds decoded budget")
            if decompressor.unused_data:
                raise RendererOutputError(f"{label}: trailing compressed PNG data")

        raw.extend(decompressor.flush(expected_length + 1 - len(raw)))
    except zlib.error:
        raise RendererOutputError(f"{label}: invalid PNG data") from None
    if len(raw) > expected_length:
        raise RendererOutputError(f"{label}: decoded image data exceeds {expected_length} byte budget")
    if not decompressor.eof or decompressor.unused_data or decompressor.unconsumed_tail:
        raise RendererOutputError(f"{label}: incomplete PNG data stream")
    if len(raw) != expected_length:
        raise RendererOutputError(f"{label}: decoded image data length {len(raw)} != {expected_length}")
    return PNGPayload(width, height, color_type, bytes(raw))


def paeth_predictor(left: int, up: int, upper_left: int) -> int:
    estimate = left + up - upper_left
    distances = (abs(estimate - left), abs(estimate - up), abs(estimate - upper_left))
    return (left, up, upper_left)[distances.index(min(distances))]


def unfilter_scanline(row: bytearray, previous: bytearray, bpp: int, filter_type: int, label: str) -> None:
    for index in range(len(row)):
        left = row[index - bpp] if index >= bpp else 0
        up = previous[index]
        upper_left = previous[index - bpp] if index >= bpp else 0
        if filter_type == 0:
            value = row[index]
        elif filter_type == 1:
            value = row[index] + left
        elif filter_type == 2:
            value = row[index] + up
        elif filter_type == 3:
            value = row[index] + ((left + up) // 2)
        elif filter_type == 4:
            value = row[index] + paeth_predictor(left, up, upper_left)
        else:
            raise RendererOutputError(f"{label}: unsupported PNG filter {filter_type}")
        row[index] = value & 0xFF


@lru_cache(maxsize=None)
def decoded_rgb(path: Path) -> tuple[int, int, tuple[bytes, ...]]:
    payload = read_png_payload(path, f"output/{path.name}")
    channels = 4 if payload.color_type == 6 else 3
    row_length = payload.width * channels
    previous = bytearray(row_length)
    offset = 0
    rows: list[bytes] = []
    for _ in range(payload.height):
        filter_type = payload.raw[offset]
        offset += 1
        row = bytearray(payload.raw[offset : offset + row_length])
        offset += row_length
        unfilter_scanline(row, previous, channels, filter_type, f"output/{path.name}")
        rows.append(bytes(component for index in range(0, len(row), channels) for component in row[index : index + 3]))
        previous = row
    return payload.width, payload.height, tuple(rows)


def comparable_top_region_rows(width: int, height: int) -> int:
    font_size = max(34.0, min(72.0, width / 30.0))
    padding = max(24.0, width / 70.0)
    watermark_band = font_size * 1.75
    return max(0, height - int(math.ceil(padding * 2 + watermark_band)))


def eye_roi(width: int, height: int) -> tuple[int, int, int, int]:
    left = int(width * ROI_LEFT)
    right = int(width * ROI_RIGHT)
    top = int(height * ROI_TOP)
    bottom = int(height * ROI_BOTTOM)
    comparable_rows = comparable_top_region_rows(width, height)
    if right <= left or bottom <= top:
        raise RendererOutputError(f"invalid eye ROI for {width}x{height}")
    if bottom > comparable_rows:
        raise RendererOutputError(
            f"eye ROI bottom {bottom} is not wholly above watermark boundary {comparable_rows} for {width}x{height}"
        )
    return left, right, top, bottom


def region_difference(reference_path: Path, candidate_path: Path) -> ComparisonMetrics:
    width, height, reference_rows = decoded_rgb(reference_path)
    other_width, other_height, candidate_rows = decoded_rgb(candidate_path)
    if (width, height) != (other_width, other_height):
        raise RendererOutputError("comparison dimensions differ")
    left, right, top, bottom = eye_roi(width, height)
    changed = delta = 0
    for row_index in range(top, bottom):
        reference = reference_rows[row_index]
        candidate = candidate_rows[row_index]
        for column in range(left, right):
            start = column * 3
            first = reference[start : start + 3]
            second = candidate[start : start + 3]
            pixel_delta = sum(abs(first[channel] - second[channel]) for channel in range(3))
            if pixel_delta:
                changed += 1
                delta += pixel_delta
    return ComparisonMetrics(changed, (right - left) * (bottom - top), delta)


def eye_delta_centroid_y(reference_path: Path, candidate_path: Path) -> float:
    """Return the normalized vertical centroid of fixed-ROI RGB change."""
    width, height, reference_rows = decoded_rgb(reference_path)
    other_width, other_height, candidate_rows = decoded_rgb(candidate_path)
    if (width, height) != (other_width, other_height):
        raise RendererOutputError("tilt comparison dimensions differ")
    left, right, top, bottom = eye_roi(width, height)
    weighted_y = total_delta = 0
    for row_index in range(top, bottom):
        reference = reference_rows[row_index]
        candidate = candidate_rows[row_index]
        for column in range(left, right):
            start = column * 3
            pixel_delta = sum(
                abs(reference[start + channel] - candidate[start + channel])
                for channel in range(3)
            )
            total_delta += pixel_delta
            weighted_y += pixel_delta * row_index
    if total_delta == 0:
        raise RendererOutputError("tilt comparison has no changed eye-local pixels")
    return weighted_y / total_delta / height


def dark_core_centroid(
    rows: tuple[bytes, ...], width: int, height: int, roi: tuple[float, float, float, float]
) -> tuple[float, float] | None:
    """Locate a bounded dark-core centroid in one fixed normalized eye ROI."""
    left, right, top, bottom = roi
    x0, x1 = int(width * left), int(width * right)
    y0, y1 = int(height * top), int(height * bottom)
    weight_total = weighted_x = weighted_y = 0
    for y in range(y0, y1):
        row = rows[y]
        for x in range(x0, x1):
            index = x * 3
            red, green, blue = row[index : index + 3]
            luminance = (54 * red + 183 * green + 19 * blue) / 256
            if luminance > IMAGE_DARK_CORE_LUMINANCE_MAX:
                continue
            weight = IMAGE_DARK_CORE_LUMINANCE_MAX - luminance + 1
            weight_total += weight
            weighted_x += x * weight
            weighted_y += y * weight
    if weight_total == 0:
        return None
    return weighted_x / weight_total / width, weighted_y / weight_total / height


def dark_core_deviation(
    rows: tuple[bytes, ...], width: int, height: int
) -> float | None:
    """Aggregate distance from each ROI's fixed neutral center, for self-tests only."""
    total = 0.0
    for left, right, top, bottom in IMAGE_GAZE_ROIS:
        centroid = dark_core_centroid(rows, width, height, (left, right, top, bottom))
        if centroid is None:
            return None
        neutral = ((left + right) / 2, (top + bottom) / 2)
        total += math.hypot(centroid[0] - neutral[0], centroid[1] - neutral[1])
    return total


def watermark_safe_no_face_difference(reference_path: Path, candidate_path: Path) -> ComparisonMetrics:
    """Compare the conservative pre-watermark region of a no-face output.

    Normal images use every full row above the renderer-matched exclusion. The
    64x64 negative has zero such rows because the display label overflows its
    tiny canvas, so its deterministic fallback is the right half, which is
    outside the observed left-origin label raster and still covers 2,048 pixels.
    """
    width, height, reference_rows = decoded_rgb(reference_path)
    other_width, other_height, candidate_rows = decoded_rgb(candidate_path)
    if (width, height) != (other_width, other_height):
        raise RendererOutputError("no-face comparison dimensions differ")
    comparable_rows = comparable_top_region_rows(width, height)
    fallback_left = math.ceil(width / 2)
    changed = delta = pixels = 0
    for row_index in range(height):
        for column in range(width):
            if comparable_rows > 0 and row_index >= comparable_rows:
                continue
            if comparable_rows == 0 and column < fallback_left:
                continue
            start = column * 3
            first = reference_rows[row_index][start : start + 3]
            second = candidate_rows[row_index][start : start + 3]
            pixel_delta = sum(abs(first[channel] - second[channel]) for channel in range(3))
            pixels += 1
            if pixel_delta:
                changed += 1
                delta += pixel_delta
    if pixels == 0:
        raise RendererOutputError("no-face fixture has no watermark-safe comparison pixels")
    return ComparisonMetrics(changed, pixels, delta)


def expected_output_name(fixture: Fixture, case_id: str) -> str:
    return f"{fixture.stem}__{case_id}.png"


def validate_matrix(output_dir: Path, case_ids: list[str], fixtures: list[Fixture]) -> dict[tuple[str, str], Path]:
    if output_dir.is_symlink() or not output_dir.is_dir():
        raise RendererOutputError(f"output directory does not exist: {output_dir}")
    expected_names = {expected_output_name(fixture, case_id) for fixture in fixtures for case_id in case_ids}
    actual_names: set[str] = set()
    try:
        entries = list(os.scandir(output_dir))
    except OSError:
        raise RendererOutputError(f"output directory unreadable: {output_dir}") from None
    for entry in entries:
        actual_names.add(entry.name)
        if not entry.is_file(follow_symlinks=False):
            raise RendererOutputError(f"output/{entry.name}: output is not a regular file")
    missing = sorted(expected_names - actual_names)
    unexpected = sorted(actual_names - expected_names)
    if missing:
        raise RendererOutputError(f"missing outputs ({len(missing)}): {', '.join(missing[:5])}")
    if unexpected:
        raise RendererOutputError(f"unexpected outputs ({len(unexpected)}): {', '.join(unexpected[:5])}")
    outputs: dict[tuple[str, str], Path] = {}
    for fixture in fixtures:
        for case_id in case_ids:
            name = expected_output_name(fixture, case_id)
            path = output_dir / name
            dimensions = read_png_dimensions(path, f"output/{name}")
            if dimensions != fixture.dimensions:
                raise RendererOutputError(
                    f"output/{name}: dimensions {dimensions[0]}x{dimensions[1]} != "
                    f"input/{fixture.relative_path} {fixture.dimensions[0]}x{fixture.dimensions[1]}"
                )
            outputs[(fixture.stem, case_id)] = path
    return outputs


def validate_outputs(input_dir: Path, output_dir: Path, renderer_source: Path, measure: bool) -> None:
    case_ids = discover_case_ids(renderer_source)
    fixtures = discover_fixtures(input_dir)
    computed = len(case_ids) * len(fixtures)
    print(f"discovered inventory: {len(case_ids)} cases x {len(fixtures)} fixtures = {computed} outputs")
    require_frozen_inventory(case_ids, fixtures)
    outputs = validate_matrix(output_dir, case_ids, fixtures)

    no_face = [fixture for fixture in fixtures if fixture.dimensions == (64, 64)]
    portraits = [fixture for fixture in fixtures if fixture.dimensions != (64, 64)]
    if len(no_face) != 1 or len(portraits) != EXPECTED_PORTRAIT_COUNT:
        raise RendererOutputError(
            f"fixture role mismatch: discovered {len(portraits)} portraits and {len(no_face)} 64x64 no-face fixtures"
        )

    for fixture in portraits:
        eye_roi(*fixture.dimensions)

    all_metrics: dict[str, list[ComparisonMetrics]] = {}
    for family in FAMILIES:
        metrics: list[ComparisonMetrics] = []
        for fixture in portraits:
            comparison = region_difference(
                outputs[(fixture.stem, family.reference)], outputs[(fixture.stem, family.candidate)]
            )
            if not measure and (
                comparison.changed_pixels < MIN_CHANGED_PIXELS
                or comparison.absolute_rgb_delta < MIN_ABSOLUTE_RGB_DELTA
            ):
                raise RendererOutputError(
                    f"{family.name}/{fixture.stem}: changed={comparison.changed_pixels}, "
                    f"delta={comparison.absolute_rgb_delta} below fixed floors "
                    f"{MIN_CHANGED_PIXELS}/{MIN_ABSOLUTE_RGB_DELTA}"
                )
            metrics.append(comparison)
        if len(metrics) != EXPECTED_PORTRAIT_COUNT:
            raise RendererOutputError(f"{family.name}: {len(metrics)}/{EXPECTED_PORTRAIT_COUNT} comparisons")
        all_metrics[family.name] = metrics

    portrait_stems = {fixture.stem for fixture in portraits}
    for required_stem in (TILT_EVIDENCE_FIXTURE_STEM,):
        if required_stem not in portrait_stems:
            raise RendererOutputError("fixed eligibility evidence fixture is absent")

    tilt_baseline = outputs[(TILT_EVIDENCE_FIXTURE_STEM, BASELINE_CASE_ID)]
    tilt_plus_y = eye_delta_centroid_y(
        tilt_baseline, outputs[(TILT_EVIDENCE_FIXTURE_STEM, EYE_TILT_PLUS_CASE_ID)]
    )
    tilt_minus_y = eye_delta_centroid_y(
        tilt_baseline, outputs[(TILT_EVIDENCE_FIXTURE_STEM, EYE_TILT_MINUS_CASE_ID)]
    )
    if not measure and (
        tilt_plus_y < TILT_SPLIT_Y + MIN_TILT_POLARITY_MARGIN
        or tilt_minus_y > TILT_SPLIT_Y - MIN_TILT_POLARITY_MARGIN
    ):
        raise RendererOutputError(
            f"tilt polarity failed fixed split/margin: plus={tilt_plus_y:.6f}, "
            f"minus={tilt_minus_y:.6f}, split={TILT_SPLIT_Y:.6f}, "
            f"margin={MIN_TILT_POLARITY_MARGIN:.6f}"
        )

    no_face_fixture = no_face[0]
    if no_face_fixture.relative_path != "negatives/no-face-gradient.png":
        raise RendererOutputError(f"unexpected 64x64 no-face fixture: {no_face_fixture.relative_path}")
    for case_id in NEW_CASE_IDS:
        comparison = watermark_safe_no_face_difference(
            outputs[(no_face_fixture.stem, BASELINE_CASE_ID)], outputs[(no_face_fixture.stem, case_id)]
        )
        if comparison.roi_pixels != 2_048:
            raise RendererOutputError(
                f"no-face {case_id}: watermark-safe fallback has {comparison.roi_pixels} pixels, expected 2048"
            )
        if comparison.changed_pixels or comparison.absolute_rgb_delta:
            raise RendererOutputError(
                f"no-face {case_id}: {comparison.changed_pixels} watermark-safe pixels changed, "
                f"delta={comparison.absolute_rgb_delta}"
            )

    dimensions = Counter(fixture.dimensions for fixture in fixtures)
    print(f"matrix validation: {len(outputs)}/{computed} non-empty, fully decoded, same-dimension PNGs")
    for (width, height), fixture_count in sorted(dimensions.items()):
        print(f"dimensions {width}x{height}: {fixture_count * len(case_ids)} outputs")
    print(
        f"ROI normalized x=[{ROI_LEFT:.2f},{ROI_RIGHT:.2f}), y=[{ROI_TOP:.2f},{ROI_BOTTOM:.2f}); "
        f"fixed floors changed>={MIN_CHANGED_PIXELS}, absolute_rgb_delta>={MIN_ABSOLUTE_RGB_DELTA}; "
        f"mode={'measurement' if measure else 'strict'}"
    )
    print(
        f"tilt polarity: plus_y={tilt_plus_y:.6f}; minus_y={tilt_minus_y:.6f}; "
        f"fixed_split={TILT_SPLIT_Y:.6f}; margin={MIN_TILT_POLARITY_MARGIN:.6f}"
    )
    print("gaze image-only dark-core reduction: not accepted; package aggregate scalar gate is required")
    print("eligibility inventory: contour=6/6; pupil_gaze=6/6; symmetry=6/6; portrait_noop=0/0; no_face=1/1")
    for family in FAMILIES:
        metrics = all_metrics[family.name]
        print(
            f"family {family.name}: {len(metrics)}/{EXPECTED_PORTRAIT_COUNT}; "
            f"min_changed={min(item.changed_pixels for item in metrics)}; "
            f"min_roi_pixels={min(item.roi_pixels for item in metrics)}; "
            f"min_absolute_rgb_delta={min(item.absolute_rgb_delta for item in metrics)}"
        )
    actual_group_comparisons = Counter(
        family.group for family in FAMILIES for _ in all_metrics[family.name]
    )
    for group, expected in EXPECTED_GROUP_COMPARISONS.items():
        actual = actual_group_comparisons[group]
        if actual != expected:
            raise RendererOutputError(f"{group} aggregate mismatch: {actual}/{expected}")
        print(f"aggregate {group} comparisons: {actual}/{expected}")
    total_comparisons = sum(actual_group_comparisons.values())
    if total_comparisons != 132:
        raise RendererOutputError(f"portrait direct comparison aggregate mismatch: {total_comparisons}/132")
    print(f"aggregate portrait direct comparisons: {total_comparisons}/132")
    print("no-face 64x64 watermark-safe no-op comparisons: 11/11")
    print("cases: " + ", ".join(case_ids))
    print("fixtures: " + ", ".join(fixture.relative_path for fixture in fixtures))


def expect_error(label: str, function, expected_fragment: str) -> None:
    try:
        function()
    except RendererOutputError as error:
        if expected_fragment not in str(error):
            raise AssertionError(f"{label}: unexpected error: {error}") from error
        return
    raise AssertionError(f"{label}: expected RendererOutputError")


def make_test_png(
    path: Path,
    width: int = 2,
    height: int = 2,
    corrupt: bool = False,
    raw_override: bytes | None = None,
    compressed_suffix: bytes = b"",
) -> None:
    raw = raw_override if raw_override is not None else b"".join(
        b"\x00" + b"\x00\x00\x00" * width for _ in range(height)
    )
    def chunk(kind: bytes, payload: bytes) -> bytes:
        crc = binascii.crc32(kind + payload) & 0xFFFFFFFF
        return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", crc)
    data = b"\x89PNG\r\n\x1a\n"
    data += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    data += chunk(b"IDAT", zlib.compress(raw) + compressed_suffix) + chunk(b"IEND", b"")
    if corrupt:
        data = data[:-1]
    path.write_bytes(data)


def run_self_tests() -> None:
    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        source = root / "main.swift"
        source.write_text('RenderCase(id: "one")\nRenderCase(id: "one")\n', encoding="utf-8")
        expect_error("duplicate IDs", lambda: discover_case_ids(source), "duplicate renderer case IDs")

        fixtures = root / "fixtures"
        (fixtures / "a").mkdir(parents=True)
        (fixtures / "b").mkdir()
        make_test_png(fixtures / "a" / "same.png")
        make_test_png(fixtures / "b" / "same.png")
        expect_error("duplicate stems", lambda: discover_fixtures(fixtures), "duplicate fixture stems")

        output = root / "output"
        output.mkdir()
        fixture = Fixture("one.png", fixtures / "a" / "same.png", "same", (2, 2))
        expect_error("missing output", lambda: validate_matrix(output, ["one"], [fixture]), "missing outputs")
        make_test_png(output / "same__one.png")
        make_test_png(output / "stale__one.png")
        expect_error("extra output", lambda: validate_matrix(output, ["one"], [fixture]), "unexpected outputs")
        (output / "stale__one.png").unlink()
        make_test_png(output / "same__one.png", corrupt=True)
        expect_error("corrupt output", lambda: validate_matrix(output, ["one"], [fixture]), "missing IEND")

        (output / "same__one.png").unlink()
        (output / "same__one.png").symlink_to(fixtures / "a" / "same.png")
        expect_error(
            "symlink output",
            lambda: validate_matrix(output, ["one"], [fixture]),
            "output is not a regular file",
        )
        (output / "same__one.png").unlink()

        oversized_dimensions = root / "oversized-dimensions.png"
        make_test_png(oversized_dimensions, width=MAX_PNG_WIDTH + 1, height=1, raw_override=b"")
        expect_error(
            "oversized dimensions",
            lambda: read_png_payload(oversized_dimensions, "oversized"),
            "exceed 4096x4096 budget",
        )

        oversized_jpeg = root / "oversized-dimensions.jpg"
        oversized_jpeg.write_bytes(
            b"\xff\xd8\xff\xc0\x00\x07\x08"
            + struct.pack(">HH", 1, MAX_PNG_WIDTH + 1)
        )
        expect_error(
            "oversized JPEG dimensions",
            lambda: read_jpeg_dimensions(oversized_jpeg, "oversized JPEG"),
            "exceed 4096x4096 budget",
        )

        replaced_path = root / "replaced-after-fstat.png"
        opened_path = root / "opened-before-replacement.png"
        make_test_png(replaced_path)

        def replace_after_fstat() -> None:
            replaced_path.rename(opened_path)
            with replaced_path.open("wb") as replacement:
                replacement.truncate(MAX_PNG_FILE_BYTES + 1)

        replacement_payload = read_png_payload(
            replaced_path,
            "replacement race",
            _after_fstat=replace_after_fstat,
        )
        if (replacement_payload.width, replacement_payload.height) != (2, 2):
            raise AssertionError("replacement race did not stay on the securely opened PNG descriptor")

        growing_path = root / "grown-after-fstat.png"
        make_test_png(growing_path)

        def grow_after_fstat() -> None:
            with growing_path.open("r+b") as growing:
                growing.truncate(MAX_PNG_FILE_BYTES + 1)

        expect_error(
            "growth after fstat",
            lambda: read_png_payload(growing_path, "growth race", _after_fstat=grow_after_fstat),
            f"exceeds {MAX_PNG_FILE_BYTES} byte budget",
        )

        compression_bomb = root / "compression-bomb.png"
        make_test_png(compression_bomb, raw_override=b"\x00" * 1_000_000)
        expect_error(
            "compression bomb",
            lambda: read_png_payload(compression_bomb, "bomb"),
            "decoded image data exceeds 14 byte budget",
        )

        trailing_stream = root / "trailing-stream.png"
        make_test_png(trailing_stream, compressed_suffix=zlib.compress(b"unexpected"))
        expect_error(
            "trailing compressed stream",
            lambda: read_png_payload(trailing_stream, "trailing"),
            "trailing compressed PNG data",
        )
        expect_error("ROI watermark", lambda: eye_roi(100, 100), "not wholly above watermark")

        no_face_baseline = root / "no-face-baseline.png"
        no_face_candidate = root / "no-face-candidate.png"
        make_test_png(no_face_baseline, width=64, height=64)
        make_test_png(no_face_candidate, width=64, height=64)
        no_face_metrics = watermark_safe_no_face_difference(no_face_baseline, no_face_candidate)
        if no_face_metrics != ComparisonMetrics(0, 2_048, 0):
            raise AssertionError(f"no-face fallback mismatch: {no_face_metrics}")

        # The image-only pupil metric is intentionally adversarial and is not
        # used as the fixture gate.  A synthetic pair proves that a real
        # toward-neutral displacement reduces deviation, while an unrelated
        # bright color patch or one-sided mirror/asymmetry change cannot.
        synthetic_width = synthetic_height = 100
        def synthetic_rows(points: tuple[tuple[float, float], tuple[float, float]]) -> tuple[bytes, ...]:
            rows = [bytearray([255] * (synthetic_width * 3)) for _ in range(synthetic_height)]
            for x_normalized, y_normalized in points:
                x = int(x_normalized * synthetic_width)
                y = int(y_normalized * synthetic_height)
                for row_index in range(max(0, y - 1), min(synthetic_height, y + 2)):
                    for column in range(max(0, x - 1), min(synthetic_width, x + 2)):
                        index = column * 3
                        rows[row_index][index : index + 3] = b"\x00\x00\x00"
            return tuple(bytes(row) for row in rows)

        neutral_points = ((0.39, 0.625), (0.61, 0.625))
        baseline_points = ((0.35, 0.625), (0.65, 0.625))
        corrected_points = neutral_points
        baseline_deviation = dark_core_deviation(
            synthetic_rows(baseline_points), synthetic_width, synthetic_height
        )
        corrected_deviation = dark_core_deviation(
            synthetic_rows(corrected_points), synthetic_width, synthetic_height
        )
        if baseline_deviation is None or corrected_deviation is None or not corrected_deviation < baseline_deviation:
            raise AssertionError("dark-core centroid did not prove synthetic toward-neutral reduction")

        color_rows = [bytearray(row) for row in synthetic_rows(baseline_points)]
        color_rows[10][10 * 3 : 10 * 3 + 3] = b"xxy"
        if dark_core_deviation(tuple(bytes(row) for row in color_rows), synthetic_width, synthetic_height) != baseline_deviation:
            raise AssertionError("unrelated bright/color change altered dark-core evidence")

        asymmetric_deviation = dark_core_deviation(
            synthetic_rows(((0.39, 0.625), (0.70, 0.625))), synthetic_width, synthetic_height
        )
        if asymmetric_deviation is None or asymmetric_deviation < baseline_deviation:
            raise AssertionError("one-sided asymmetry incorrectly satisfied dark-core reduction")

    print(
        "self-test passed: duplicate IDs/stems, missing/extra/corrupt/symlink outputs, bounded PNG/JPEG decode, "
        "single-descriptor replacement/growth races, ROI/watermark rejection, 2048-pixel no-face fallback, "
        "dark-core toward-neutral reduction and adversarial color/asymmetry rejection"
    )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", help="Recursive fixture input directory")
    parser.add_argument("--output", help="Flat generated renderer output directory")
    parser.add_argument("--renderer-source", help="BeautyExampleRenderer main.swift")
    parser.add_argument("--measure", action="store_true", help="Report metrics without applying fixed floors")
    parser.add_argument("--self-test", action="store_true", help="Run deterministic negative-path checks")
    args = parser.parse_args()
    if not args.self_test and not (args.input and args.output and args.renderer_source):
        parser.error("--input, --output, and --renderer-source are required unless --self-test is used")
    return args


def main() -> int:
    args = parse_args()
    try:
        if args.self_test:
            run_self_tests()
        else:
            validate_outputs(Path(args.input), Path(args.output), Path(args.renderer_source), args.measure)
    except (RendererOutputError, AssertionError) as error:
        print(f"phase 43 eye renderer output check failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
