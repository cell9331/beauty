#!/usr/bin/env python3
"""Validate the Phase 51 single-portrait eyebrow renderer evidence."""

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
EXPECTED_CASE_COUNT = 72
EXPECTED_FIXTURE_COUNT = 2
EXPECTED_OUTPUT_COUNT = 144
EXPECTED_PORTRAIT_COUNT = 1
EXPECTED_PORTRAIT_OUTPUT_COUNT = 72
EXPECTED_PORTRAIT_STEMS = ("e6",)
EXPECTED_NEGATIVE_STEMS = ("no-face-gradient",)

# Current fixtures are at most 1728x2304 and renderer PNGs are below 5 MiB. These
# ceilings leave deliberate headroom while bounding all untrusted PNG allocation.
MAX_PNG_WIDTH = 4_096
MAX_PNG_HEIGHT = 4_096
MAX_PNG_FILE_BYTES = 16 * 1_024 * 1_024
MAX_PNG_DECODED_BYTES = 64 * 1_024 * 1_024
MAX_JPEG_FILE_BYTES = 16 * 1_024 * 1_024

BASELINE_CASE_ID = "geometryBaseline_noop"
Y_PLUS = "eyebrowYPosition_plus0p25"
Y_MINUS = "eyebrowYPosition_minus0p25"
THICKNESS_PLUS = "eyebrowThickness_plus0p25"
THICKNESS_MINUS = "eyebrowThickness_minus0p25"
LENGTH_PLUS = "eyebrowLength_plus0p25"
LENGTH_MINUS = "eyebrowLength_minus0p25"
SPACING_PLUS = "eyebrowSpacing_plus0p25"
SPACING_MINUS = "eyebrowSpacing_minus0p25"
HEAD_SPACING_PLUS = "eyebrowHeadSpacing_plus0p25"
HEAD_SPACING_MINUS = "eyebrowHeadSpacing_minus0p25"
TILT_PLUS = "eyebrowTilt_plus0p25"
TILT_MINUS = "eyebrowTilt_minus0p25"
PEAK = "eyebrowPeakDefinition_0p25"
NEW_CASE_IDS = (
    Y_PLUS, Y_MINUS, THICKNESS_PLUS, THICKNESS_MINUS, LENGTH_PLUS, LENGTH_MINUS,
    SPACING_PLUS, SPACING_MINUS, HEAD_SPACING_PLUS, HEAD_SPACING_MINUS,
    TILT_PLUS, TILT_MINUS, PEAK,
)
REQUIRED_CASE_IDS = {
    BASELINE_CASE_ID,
    *NEW_CASE_IDS,
}

# Frozen e6-only normalized regions.  They use the SDK's canonical top-left
# origin and exclude the renderer label.  The effect ROI contains both brows
# across the measured signed extrema.  The four protected families are
# deliberately disjoint from it and from one another.
BROW_REGIONS = ((0.24, 0.76, 0.24, 0.43),)
PROTECTED_REGION_RECTS = (
    ("eyes", ((0.25, 0.75, 0.42, 0.50),)),
    ("forehead_hair", ((0.18, 0.82, 0.08, 0.23),)),
    ("background", ((0.00, 0.14, 0.08, 0.82), (0.86, 1.00, 0.08, 0.82))),
    ("watermark", ((0.82, 0.98, 0.92, 0.985),)),
)

DARK_LUMINANCE_CEILING = 180.0
LEFT_BROW_REGION = ((0.24, 0.50, 0.24, 0.43),)
RIGHT_BROW_REGION = ((0.50, 0.76, 0.24, 0.43),)
HEAD_GAP_REGION = ((0.44, 0.56, 0.24, 0.43),)
LEFT_INNER_REGION = ((0.40, 0.50, 0.24, 0.43),)
RIGHT_INNER_REGION = ((0.50, 0.60, 0.24, 0.43),)
LEFT_OUTER_REGION = ((0.24, 0.35, 0.24, 0.43),)
RIGHT_OUTER_REGION = ((0.65, 0.76, 0.24, 0.43),)


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
class ProtectedLimit:
    name: str
    maximum_changed_pixels: int
    maximum_absolute_rgb_delta: int


@dataclass(frozen=True)
class DirectionLimit:
    name: str
    minimum_margin: float


@dataclass(frozen=True)
class Calibration:
    visibility_changed_floor: int
    visibility_delta_floor: int
    family_changed_floor: int
    family_delta_floor: int
    protected_limits: tuple[ProtectedLimit, ...]
    direction_limits: tuple[DirectionLimit, ...]

    @property
    def protected_regions(self) -> tuple[str, ...]:
        return tuple(limit.name for limit in self.protected_limits)

    @property
    def direction_floors(self) -> tuple[str, ...]:
        return tuple(limit.name for limit in self.direction_limits)


@dataclass(frozen=True)
class BrowSignature:
    center_y: float
    vertical_spread: float
    horizontal_spread: float
    deformation_vertical_extent: float
    deformation_horizontal_extent: float
    pair_spacing: float
    head_gap_darkness: float
    tail_lift: float


# Frozen from the one-time Phase 51 measurement.  Floors sit below the
# measured minima and ceilings above the measured maxima with explicit
# positive margins; no accepting run derives or mutates these values.
FROZEN_CALIBRATION = Calibration(
    visibility_changed_floor=25_000,
    visibility_delta_floor=175_000,
    family_changed_floor=35_000,
    family_delta_floor=450_000,
    protected_limits=(
        ProtectedLimit("eyes", 750, 1_500),
        ProtectedLimit("forehead_hair", 32, 64),
        ProtectedLimit("background", 32, 64),
        ProtectedLimit("watermark", 32, 64),
    ),
    direction_limits=(
        DirectionLimit("y_position", 0.000_20),
        DirectionLimit("thickness", 0.002_50),
        DirectionLimit("length", 0.050_00),
        DirectionLimit("spacing", 0.002_50),
        DirectionLimit("head_spacing", 0.004_00),
        DirectionLimit("tilt", 0.002_50),
    ),
)


@dataclass(frozen=True)
class Family:
    group: str
    name: str
    candidate: str
    reference: str


POSITIVE_FAMILIES = (Y_PLUS, THICKNESS_PLUS, LENGTH_PLUS, SPACING_PLUS, HEAD_SPACING_PLUS, TILT_PLUS, PEAK)
FAMILIES = tuple(
    Family("visibility", f"{case_id}_vs_baseline", case_id, BASELINE_CASE_ID)
    for case_id in NEW_CASE_IDS
) + tuple(
    Family("signed direction", f"{plus}_vs_{minus}", plus, minus)
    for plus, minus in ((Y_PLUS, Y_MINUS), (THICKNESS_PLUS, THICKNESS_MINUS),
                        (LENGTH_PLUS, LENGTH_MINUS), (SPACING_PLUS, SPACING_MINUS),
                        (HEAD_SPACING_PLUS, HEAD_SPACING_MINUS), (TILT_PLUS, TILT_MINUS))
) + tuple(
    Family("semantic distinction", f"{left}_vs_{right}", left, right)
    for index, left in enumerate(POSITIVE_FAMILIES)
    for right in POSITIVE_FAMILIES[index + 1:]
)

EXPECTED_GROUP_COMPARISONS = {
    "visibility": 13,
    "signed direction": 6,
    "semantic distinction": 21,
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
    portrait_stems = tuple(fixture.stem for fixture in fixtures if fixture.dimensions != (64, 64))
    negative_stems = tuple(fixture.stem for fixture in fixtures if fixture.dimensions == (64, 64))
    if portrait_stems != EXPECTED_PORTRAIT_STEMS or negative_stems != EXPECTED_NEGATIVE_STEMS:
        raise RendererOutputError(
            f"fixture scope mismatch: portraits={portrait_stems}, negatives={negative_stems}"
        )


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


@lru_cache(maxsize=32)
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


def pixel_rectangles(
    width: int,
    height: int,
    rectangles: tuple[tuple[float, float, float, float], ...],
    label: str,
) -> tuple[tuple[int, int, int, int], ...]:
    comparable_rows = comparable_top_region_rows(width, height)
    pixels: list[tuple[int, int, int, int]] = []
    for left, right, top, bottom in rectangles:
        if not (
            all(math.isfinite(value) for value in (left, right, top, bottom))
            and 0 <= left < right <= 1
            and 0 <= top < bottom <= 1
        ):
            raise RendererOutputError(f"{label}: invalid normalized region")
        pixel_rect = (
            int(width * left),
            int(width * right),
            int(height * top),
            int(height * bottom),
        )
        if pixel_rect[1] <= pixel_rect[0] or pixel_rect[3] <= pixel_rect[2]:
            raise RendererOutputError(f"{label}: empty pixel region for {width}x{height}")
        if label != "watermark" and pixel_rect[3] > comparable_rows:
            raise RendererOutputError(
                f"{label}: bottom {pixel_rect[3]} is not wholly above watermark boundary "
                f"{comparable_rows} for {width}x{height}"
            )
        pixels.append(pixel_rect)
    return tuple(pixels)


def region_difference(
    reference_path: Path,
    candidate_path: Path,
    rectangles: tuple[tuple[float, float, float, float], ...] = BROW_REGIONS,
    label: str = "brow",
) -> ComparisonMetrics:
    width, height, reference_rows = decoded_rgb(reference_path)
    other_width, other_height, candidate_rows = decoded_rgb(candidate_path)
    if (width, height) != (other_width, other_height):
        raise RendererOutputError("comparison dimensions differ")
    changed = delta = pixels = 0
    for left, right, top, bottom in pixel_rectangles(width, height, rectangles, label):
        pixels += (right - left) * (bottom - top)
        for row_index in range(top, bottom):
            first_segment = reference_rows[row_index][left * 3 : right * 3]
            second_segment = candidate_rows[row_index][left * 3 : right * 3]
            if first_segment == second_segment:
                continue
            for offset in range(0, len(first_segment), 3):
                pixel_delta = (
                    abs(first_segment[offset] - second_segment[offset])
                    + abs(first_segment[offset + 1] - second_segment[offset + 1])
                    + abs(first_segment[offset + 2] - second_segment[offset + 2])
                )
                if pixel_delta:
                    changed += 1
                    delta += pixel_delta
    return ComparisonMetrics(changed, pixels, delta)


def darkness_moments(
    rows: tuple[bytes, ...],
    width: int,
    height: int,
    rectangles: tuple[tuple[float, float, float, float], ...],
    label: str,
) -> tuple[float, float, float, float, float, int]:
    total = weighted_x = weighted_y = weighted_x2 = weighted_y2 = 0.0
    pixel_count = 0
    for left, right, top, bottom in pixel_rectangles(width, height, rectangles, label):
        pixel_count += (right - left) * (bottom - top)
        for y in range(top, bottom):
            row = rows[y]
            normalized_y = (y + 0.5) / height
            for x in range(left, right):
                index = x * 3
                red, green, blue = row[index : index + 3]
                luminance = (54 * red + 183 * green + 19 * blue) / 256
                weight = max(0.0, DARK_LUMINANCE_CEILING - luminance)
                if weight == 0:
                    continue
                normalized_x = (x + 0.5) / width
                total += weight
                weighted_x += normalized_x * weight
                weighted_y += normalized_y * weight
                weighted_x2 += normalized_x * normalized_x * weight
                weighted_y2 += normalized_y * normalized_y * weight
    if total <= 0 or pixel_count <= 0:
        raise RendererOutputError(f"{label}: no dark eyebrow evidence")
    return total, weighted_x, weighted_y, weighted_x2, weighted_y2, pixel_count


def dark_centroid(
    rows: tuple[bytes, ...],
    width: int,
    height: int,
    rectangles: tuple[tuple[float, float, float, float], ...],
    label: str,
) -> tuple[float, float]:
    total, weighted_x, weighted_y, _, _, _ = darkness_moments(
        rows, width, height, rectangles, label
    )
    return weighted_x / total, weighted_y / total


def difference_extent(reference_path: Path, candidate_path: Path) -> tuple[float, float]:
    """Return robust 5%-95% RGB-delta extents inside the frozen brow ROI."""
    width, height, reference_rows = decoded_rgb(reference_path)
    other_width, other_height, candidate_rows = decoded_rgb(candidate_path)
    if (width, height) != (other_width, other_height):
        raise RendererOutputError("direction comparison dimensions differ")
    x_weights = [0] * width
    y_weights = [0] * height
    total = 0
    for left, right, top, bottom in pixel_rectangles(
        width, height, BROW_REGIONS, "brow"
    ):
        for y in range(top, bottom):
            for x in range(left, right):
                index = x * 3
                delta = sum(
                    abs(reference_rows[y][index + channel] - candidate_rows[y][index + channel])
                    for channel in range(3)
                )
                x_weights[x] += delta
                y_weights[y] += delta
                total += delta
    if total <= 0:
        raise RendererOutputError("direction comparison has no brow deformation")

    def quantile(weights: list[int], fraction: float) -> int:
        target = total * fraction
        cumulative = 0
        for index, weight in enumerate(weights):
            cumulative += weight
            if cumulative >= target:
                return index
        raise RendererOutputError("direction comparison quantile is unavailable")

    return (
        (quantile(x_weights, 0.95) - quantile(x_weights, 0.05)) / width,
        (quantile(y_weights, 0.95) - quantile(y_weights, 0.05)) / height,
    )


def brow_signature(path: Path, baseline_path: Path) -> BrowSignature:
    width, height, rows = decoded_rgb(path)
    total, weighted_x, weighted_y, weighted_x2, weighted_y2, _ = darkness_moments(
        rows, width, height, BROW_REGIONS, "brow signature"
    )
    center_x = weighted_x / total
    center_y = weighted_y / total
    horizontal_spread = math.sqrt(max(0.0, weighted_x2 / total - center_x * center_x))
    vertical_spread = math.sqrt(max(0.0, weighted_y2 / total - center_y * center_y))

    left_x, _ = dark_centroid(rows, width, height, LEFT_BROW_REGION, "left brow")
    right_x, _ = dark_centroid(rows, width, height, RIGHT_BROW_REGION, "right brow")
    head_total, _, _, _, _, head_pixels = darkness_moments(
        rows, width, height, HEAD_GAP_REGION, "head gap"
    )
    _, left_inner_y = dark_centroid(rows, width, height, LEFT_INNER_REGION, "left inner brow")
    _, right_inner_y = dark_centroid(rows, width, height, RIGHT_INNER_REGION, "right inner brow")
    _, left_outer_y = dark_centroid(rows, width, height, LEFT_OUTER_REGION, "left outer brow")
    _, right_outer_y = dark_centroid(rows, width, height, RIGHT_OUTER_REGION, "right outer brow")
    deformation_horizontal_extent, deformation_vertical_extent = difference_extent(
        baseline_path, path
    )

    return BrowSignature(
        center_y=center_y,
        vertical_spread=vertical_spread,
        horizontal_spread=horizontal_spread,
        deformation_vertical_extent=deformation_vertical_extent,
        deformation_horizontal_extent=deformation_horizontal_extent,
        pair_spacing=right_x - left_x,
        head_gap_darkness=head_total / head_pixels / DARK_LUMINANCE_CEILING,
        tail_lift=((left_inner_y - left_outer_y) + (right_inner_y - right_outer_y)) / 2,
    )


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


def validate_calibration_contract(calibration: Calibration) -> None:
    protected_names = tuple(name for name, _ in PROTECTED_REGION_RECTS)
    if calibration.protected_regions != protected_names:
        raise AssertionError(
            f"protected calibration names {calibration.protected_regions} != {protected_names}"
        )
    if len(set(calibration.protected_regions)) != 4:
        raise AssertionError("protected calibration requires four unique regions")
    if (
        calibration.visibility_changed_floor <= 0
        or calibration.visibility_delta_floor <= 0
        or calibration.family_changed_floor <= 0
        or calibration.family_delta_floor <= 0
    ):
        raise AssertionError("visibility/family calibration floors must be positive")
    for limit in calibration.protected_limits:
        if limit.maximum_changed_pixels < 0 or limit.maximum_absolute_rgb_delta < 0:
            raise AssertionError(f"{limit.name}: protected ceilings must be nonnegative")
    expected_directions = (
        "y_position",
        "thickness",
        "length",
        "spacing",
        "head_spacing",
        "tilt",
    )
    if calibration.direction_floors != expected_directions:
        raise AssertionError(
            f"direction calibration names {calibration.direction_floors} != {expected_directions}"
        )
    if any(limit.minimum_margin <= 0 for limit in calibration.direction_limits):
        raise AssertionError("direction calibration floors must be positive")

    all_regions = (("brow", BROW_REGIONS), *PROTECTED_REGION_RECTS)
    for name, rectangles in all_regions:
        if not rectangles:
            raise AssertionError(f"{name}: region inventory is empty")
        for rectangle in rectangles:
            left, right, top, bottom = rectangle
            if not (
                all(math.isfinite(value) for value in rectangle)
                and 0 <= left < right <= 1
                and 0 <= top < bottom <= 1
            ):
                raise AssertionError(f"{name}: invalid normalized rectangle {rectangle}")


def direction_metrics(signatures: dict[str, BrowSignature]) -> dict[str, float]:
    return {
        "y_position": signatures[Y_PLUS].center_y - signatures[Y_MINUS].center_y,
        "thickness": (
            signatures[THICKNESS_PLUS].deformation_vertical_extent
            - signatures[THICKNESS_MINUS].deformation_vertical_extent
        ),
        "length": (
            signatures[LENGTH_PLUS].deformation_horizontal_extent
            - signatures[LENGTH_MINUS].deformation_horizontal_extent
        ),
        "spacing": signatures[SPACING_PLUS].pair_spacing - signatures[SPACING_MINUS].pair_spacing,
        "head_spacing": (
            signatures[HEAD_SPACING_MINUS].head_gap_darkness
            - signatures[HEAD_SPACING_PLUS].head_gap_darkness
        ),
        "tilt": signatures[TILT_PLUS].tail_lift - signatures[TILT_MINUS].tail_lift,
    }


def require_direction_metrics(
    observed: dict[str, float],
    calibration: Calibration = FROZEN_CALIBRATION,
) -> None:
    for limit in calibration.direction_limits:
        value = observed.get(limit.name)
        if value is None or not math.isfinite(value) or value < limit.minimum_margin:
            raise RendererOutputError(
                f"signed direction {limit.name}: margin={value} below fixed floor "
                f"{limit.minimum_margin:.8f}"
            )


def require_protected_metrics(
    observed: dict[str, ComparisonMetrics],
    calibration: Calibration = FROZEN_CALIBRATION,
) -> None:
    for limit in calibration.protected_limits:
        metrics = observed.get(limit.name)
        if metrics is None:
            raise RendererOutputError(f"protected region {limit.name}: missing metrics")
        if (
            metrics.changed_pixels > limit.maximum_changed_pixels
            or metrics.absolute_rgb_delta > limit.maximum_absolute_rgb_delta
        ):
            raise RendererOutputError(
                f"protected region {limit.name}: changed={metrics.changed_pixels}, "
                f"delta={metrics.absolute_rgb_delta} exceeds fixed ceilings "
                f"{limit.maximum_changed_pixels}/{limit.maximum_absolute_rgb_delta}"
            )


def validate_outputs(input_dir: Path, output_dir: Path, renderer_source: Path, measure: bool) -> None:
    validate_calibration_contract(FROZEN_CALIBRATION)
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
        pixel_rectangles(*fixture.dimensions, BROW_REGIONS, "brow")
        for region_name, rectangles in PROTECTED_REGION_RECTS:
            pixel_rectangles(*fixture.dimensions, rectangles, region_name)

    all_metrics: dict[str, list[ComparisonMetrics]] = {}
    for family in FAMILIES:
        metrics: list[ComparisonMetrics] = []
        for fixture in portraits:
            comparison = region_difference(
                outputs[(fixture.stem, family.reference)], outputs[(fixture.stem, family.candidate)]
            )
            if family.group == "visibility":
                changed_floor = FROZEN_CALIBRATION.visibility_changed_floor
                delta_floor = FROZEN_CALIBRATION.visibility_delta_floor
            else:
                changed_floor = FROZEN_CALIBRATION.family_changed_floor
                delta_floor = FROZEN_CALIBRATION.family_delta_floor
            if not measure and (
                comparison.changed_pixels < changed_floor
                or comparison.absolute_rgb_delta < delta_floor
            ):
                raise RendererOutputError(
                    f"{family.name}/{fixture.stem}: changed={comparison.changed_pixels}, "
                    f"delta={comparison.absolute_rgb_delta} below fixed floors "
                    f"{changed_floor}/{delta_floor}"
                )
            metrics.append(comparison)
        if len(metrics) != EXPECTED_PORTRAIT_COUNT:
            raise RendererOutputError(f"{family.name}: {len(metrics)}/{EXPECTED_PORTRAIT_COUNT} comparisons")
        all_metrics[family.name] = metrics

    portrait = portraits[0]
    baseline_path = outputs[(portrait.stem, BASELINE_CASE_ID)]
    protected_maxima: dict[str, ComparisonMetrics] = {}
    for region_name, rectangles in PROTECTED_REGION_RECTS:
        comparisons = [
            region_difference(
                baseline_path,
                outputs[(portrait.stem, case_id)],
                rectangles,
                region_name,
            )
            for case_id in NEW_CASE_IDS
        ]
        protected_maxima[region_name] = ComparisonMetrics(
            changed_pixels=max(item.changed_pixels for item in comparisons),
            roi_pixels=comparisons[0].roi_pixels,
            absolute_rgb_delta=max(item.absolute_rgb_delta for item in comparisons),
        )
    if not measure:
        require_protected_metrics(protected_maxima)

    signatures = {
        case_id: brow_signature(outputs[(portrait.stem, case_id)], baseline_path)
        for case_id in (
            Y_PLUS,
            Y_MINUS,
            THICKNESS_PLUS,
            THICKNESS_MINUS,
            LENGTH_PLUS,
            LENGTH_MINUS,
            SPACING_PLUS,
            SPACING_MINUS,
            HEAD_SPACING_PLUS,
            HEAD_SPACING_MINUS,
            TILT_PLUS,
            TILT_MINUS,
        )
    }
    observed_directions = direction_metrics(signatures)
    if not measure:
        require_direction_metrics(observed_directions)

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
    print(f"brow ROI normalized rectangles: {BROW_REGIONS}")
    print(
        "fixed floors: "
        f"visibility={FROZEN_CALIBRATION.visibility_changed_floor}/"
        f"{FROZEN_CALIBRATION.visibility_delta_floor}; "
        f"family={FROZEN_CALIBRATION.family_changed_floor}/"
        f"{FROZEN_CALIBRATION.family_delta_floor}; "
        f"mode={'measurement' if measure else 'strict'}"
    )
    for limit in FROZEN_CALIBRATION.protected_limits:
        metrics = protected_maxima[limit.name]
        print(
            f"protected {limit.name}: max_changed={metrics.changed_pixels}; "
            f"max_absolute_rgb_delta={metrics.absolute_rgb_delta}; "
            f"fixed_ceilings={limit.maximum_changed_pixels}/"
            f"{limit.maximum_absolute_rgb_delta}"
        )
    direction_limit_by_name = {
        limit.name: limit.minimum_margin for limit in FROZEN_CALIBRATION.direction_limits
    }
    for name, margin in observed_directions.items():
        print(
            f"signed direction {name}: observed_margin={margin:.8f}; "
            f"fixed_floor={direction_limit_by_name[name]:.8f}"
        )
    print(f"portrait outputs: {EXPECTED_PORTRAIT_OUTPUT_COUNT}/{EXPECTED_PORTRAIT_OUTPUT_COUNT}; no-face fixture separate")
    print("eligibility inventory: eyebrow=1/1; no_face=1/1")
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
    if total_comparisons != 40:
        raise RendererOutputError(f"portrait direct comparison aggregate mismatch: {total_comparisons}/40")
    print(f"aggregate portrait direct comparisons: {total_comparisons}/40")
    print("no-face 64x64 watermark-safe no-op comparisons: 13/13")
    print("cases: " + ", ".join(case_ids))
    print("fixtures: " + ", ".join(fixture.relative_path for fixture in fixtures))
    if measure:
        print("MEASUREMENT ONLY: thresholds were observed but no OUT-02 strict pass is claimed")
    else:
        print("STRICT ACCEPTANCE: frozen calibration satisfied")


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
    # Phase 51 strict acceptance requires one immutable calibration object,
    # four independently budgeted protected regions, and six semantic
    # direction predicates.  This assertion is deliberately written before
    # the implementation so the RED gate proves those contracts are absent.
    validate_calibration_contract(FROZEN_CALIBRATION)
    if tuple(FROZEN_CALIBRATION.protected_regions) != (
        "eyes",
        "forehead_hair",
        "background",
        "watermark",
    ):
        raise AssertionError("protected-region calibration inventory drifted")
    if tuple(FROZEN_CALIBRATION.direction_floors) != (
        "y_position",
        "thickness",
        "length",
        "spacing",
        "head_spacing",
        "tilt",
    ):
        raise AssertionError("signed-direction calibration inventory drifted")
    passing_directions = {
        limit.name: limit.minimum_margin
        for limit in FROZEN_CALIBRATION.direction_limits
    }
    require_direction_metrics(passing_directions)
    for limit in FROZEN_CALIBRATION.direction_limits:
        reversed_directions = dict(passing_directions)
        reversed_directions[limit.name] = -limit.minimum_margin
        expect_error(
            f"reversed {limit.name}",
            lambda values=reversed_directions: require_direction_metrics(values),
            f"signed direction {limit.name}",
        )
    passing_protected = {
        limit.name: ComparisonMetrics(
            limit.maximum_changed_pixels,
            max(1, limit.maximum_changed_pixels),
            limit.maximum_absolute_rgb_delta,
        )
        for limit in FROZEN_CALIBRATION.protected_limits
    }
    require_protected_metrics(passing_protected)
    for limit in FROZEN_CALIBRATION.protected_limits:
        spilled = dict(passing_protected)
        spilled[limit.name] = ComparisonMetrics(
            limit.maximum_changed_pixels + 1,
            max(1, limit.maximum_changed_pixels + 1),
            limit.maximum_absolute_rgb_delta,
        )
        expect_error(
            f"protected spill {limit.name}",
            lambda values=spilled: require_protected_metrics(values),
            f"protected region {limit.name}",
        )

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
        expect_error(
            "ROI watermark",
            lambda: pixel_rectangles(100, 100, BROW_REGIONS, "brow"),
            "not wholly above watermark",
        )

        no_face_baseline = root / "no-face-baseline.png"
        no_face_candidate = root / "no-face-candidate.png"
        make_test_png(no_face_baseline, width=64, height=64)
        make_test_png(no_face_candidate, width=64, height=64)
        no_face_metrics = watermark_safe_no_face_difference(no_face_baseline, no_face_candidate)
        if no_face_metrics != ComparisonMetrics(0, 2_048, 0):
            raise AssertionError(f"no-face fallback mismatch: {no_face_metrics}")

    print(
        "self-test passed: frozen four-region/six-direction calibration, reversed/spill rejection, "
        "duplicate IDs/stems, missing/extra/corrupt/symlink outputs, bounded PNG/JPEG decode, "
        "single-descriptor replacement/growth races, ROI/watermark rejection, and 2048-pixel no-face fallback"
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
        print(f"phase 51 eyebrow renderer output check failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
