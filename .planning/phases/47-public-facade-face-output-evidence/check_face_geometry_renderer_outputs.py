#!/usr/bin/env python3
"""Validate the Phase 47 public renderer matrix and face-local evidence."""

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
EXPECTED_CASE_COUNT = 59
EXPECTED_FIXTURE_COUNT = 7
EXPECTED_OUTPUT_COUNT = 413
EXPECTED_PORTRAIT_COUNT = 6

# Current fixtures are at most 1728x2304 and renderer PNGs are below 5 MiB. These
# ceilings leave deliberate headroom while bounding all untrusted PNG allocation.
MAX_PNG_WIDTH = 4_096
MAX_PNG_HEIGHT = 4_096
MAX_PNG_FILE_BYTES = 16 * 1_024 * 1_024
MAX_PNG_DECODED_BYTES = 64 * 1_024 * 1_024
MAX_JPEG_FILE_BYTES = 16 * 1_024 * 1_024

BASELINE_CASE_ID = "geometryBaseline_noop"
FACE_CONTOUR_CASE_ID = "faceContourSmooth_0p25"
TEMPLE_CASE_ID = "templeFullness_0p25"
CHEEKBONE_CASE_ID = "cheekboneSlim_0p25"
CHIN_TAPER_CASE_ID = "chinTaper_0p25"
NEW_CASE_IDS = (
    FACE_CONTOUR_CASE_ID,
    TEMPLE_CASE_ID,
    CHEEKBONE_CASE_ID,
    CHIN_TAPER_CASE_ID,
)
REQUIRED_CASE_IDS = {
    BASELINE_CASE_ID,
    *NEW_CASE_IDS,
    "faceSmall_0p35",
    "faceSlim_0p35",
    "jawSlim_0p35",
    "chinLength_plus0p30",
    "chinLength_minus0p30",
    "faceVShape_0p35",
}

# Top-origin normalized rectangles, fixed after the one permitted measurement
# render. They are shared across fixtures and wholly exclude the watermark.
#
# The weakest eligible baseline signals were:
# contour 6689/23583, temple 5376/26808, cheekbone 4558/29824,
# chin 1850/5360 (changed pixels / absolute RGB delta).
# The weakest fixed-neighbor signals were respectively:
# 12036/121868, 8587/53186, 8580/53178, 3855/29243.
# Floors below preserve explicit margins and are never derived in strict mode.
MIN_INTENDED_SIGNAL_SHARE = 0.99
MAX_OUTSIDE_CHANGED_PIXELS = 0
MAX_OUTSIDE_RGB_DELTA = 0

FORBIDDEN_DISCLOSURE_TOKENS = (
    "landmark",
    "coordinate",
    "medianline",
    "sourceindex",
    "targetindex",
    "providerpath",
    "rawsupport",
)


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
class RegionMetrics:
    intended: ComparisonMetrics
    outside: ComparisonMetrics


@dataclass(frozen=True)
class FieldGate:
    case_id: str
    region: tuple[float, float, float, float]
    eligible_stems: tuple[str, ...]
    visibility_changed_floor: int
    visibility_delta_floor: int
    family_changed_floor: int
    family_delta_floor: int


@dataclass(frozen=True)
class Family:
    name: str
    candidate: str
    reference: str


FIELD_GATES = (
    FieldGate(
        FACE_CONTOUR_CASE_ID,
        (0.10, 0.92, 0.28, 0.82),
        ("e2", "e3", "e4", "e5", "e6"),
        5_000,
        15_000,
        8_000,
        80_000,
    ),
    FieldGate(
        TEMPLE_CASE_ID,
        (0.10, 0.92, 0.32, 0.80),
        ("e2", "e3", "e4", "e5", "e6"),
        4_000,
        18_000,
        6_000,
        35_000,
    ),
    FieldGate(
        CHEEKBONE_CASE_ID,
        (0.20, 0.82, 0.24, 0.65),
        ("e2", "e3", "e5", "e6"),
        3_500,
        20_000,
        6_000,
        35_000,
    ),
    FieldGate(
        CHIN_TAPER_CASE_ID,
        (0.33, 0.70, 0.24, 0.62),
        ("e2", "e3", "e5", "e6"),
        1_000,
        3_000,
        2_500,
        18_000,
    ),
)

FAMILIES = (
    Family("contour_vs_face_small", FACE_CONTOUR_CASE_ID, "faceSmall_0p35"),
    Family("contour_vs_face_slim", FACE_CONTOUR_CASE_ID, "faceSlim_0p35"),
    Family("temple_vs_face_small", TEMPLE_CASE_ID, "faceSmall_0p35"),
    Family("temple_vs_face_slim", TEMPLE_CASE_ID, "faceSlim_0p35"),
    Family("temple_vs_cheekbone", TEMPLE_CASE_ID, CHEEKBONE_CASE_ID),
    Family("cheekbone_vs_face_slim", CHEEKBONE_CASE_ID, "faceSlim_0p35"),
    Family("cheekbone_vs_jaw_slim", CHEEKBONE_CASE_ID, "jawSlim_0p35"),
    Family("cheekbone_vs_temple", CHEEKBONE_CASE_ID, TEMPLE_CASE_ID),
    Family("chin_taper_vs_chin_plus", CHIN_TAPER_CASE_ID, "chinLength_plus0p30"),
    Family("chin_taper_vs_chin_minus", CHIN_TAPER_CASE_ID, "chinLength_minus0p30"),
    Family("chin_taper_vs_v_shape", CHIN_TAPER_CASE_ID, "faceVShape_0p35"),
)

EXPECTED_ELIGIBILITY = {
    FACE_CONTOUR_CASE_ID: ("e2", "e3", "e4", "e5", "e6"),
    TEMPLE_CASE_ID: ("e2", "e3", "e4", "e5", "e6"),
    CHEEKBONE_CASE_ID: ("e2", "e3", "e5", "e6"),
    CHIN_TAPER_CASE_ID: ("e2", "e3", "e5", "e6"),
}

EXPECTED_COMPARATORS = {
    FACE_CONTOUR_CASE_ID: ("faceSmall_0p35", "faceSlim_0p35"),
    TEMPLE_CASE_ID: ("faceSmall_0p35", "faceSlim_0p35", CHEEKBONE_CASE_ID),
    CHEEKBONE_CASE_ID: ("faceSlim_0p35", "jawSlim_0p35", TEMPLE_CASE_ID),
    CHIN_TAPER_CASE_ID: ("chinLength_plus0p30", "chinLength_minus0p30", "faceVShape_0p35"),
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


def normalized_roi(
    width: int,
    height: int,
    region: tuple[float, float, float, float],
) -> tuple[int, int, int, int]:
    left_normalized, right_normalized, top_normalized, bottom_normalized = region
    left = int(width * left_normalized)
    right = int(width * right_normalized)
    top = int(height * top_normalized)
    bottom = int(height * bottom_normalized)
    comparable_rows = comparable_top_region_rows(width, height)
    if right <= left or bottom <= top:
        raise RendererOutputError(f"invalid face ROI for {width}x{height}")
    if bottom > comparable_rows:
        raise RendererOutputError(
            f"face ROI bottom {bottom} is not wholly above watermark boundary {comparable_rows} "
            f"for {width}x{height}"
        )
    return left, right, top, bottom


def region_and_outside_difference(
    reference_path: Path,
    candidate_path: Path,
    region: tuple[float, float, float, float],
) -> RegionMetrics:
    width, height, reference_rows = decoded_rgb(reference_path)
    other_width, other_height, candidate_rows = decoded_rgb(candidate_path)
    if (width, height) != (other_width, other_height):
        raise RendererOutputError("comparison dimensions differ")
    left, right, top, bottom = normalized_roi(width, height, region)
    comparable_rows = comparable_top_region_rows(width, height)
    intended_changed = intended_delta = outside_changed = outside_delta = 0
    for row_index in range(comparable_rows):
        reference = reference_rows[row_index]
        candidate = candidate_rows[row_index]
        for column in range(width):
            start = column * 3
            first = reference[start : start + 3]
            second = candidate[start : start + 3]
            pixel_delta = sum(abs(first[channel] - second[channel]) for channel in range(3))
            if not pixel_delta:
                continue
            if top <= row_index < bottom and left <= column < right:
                intended_changed += 1
                intended_delta += pixel_delta
            else:
                outside_changed += 1
                outside_delta += pixel_delta
    intended_pixels = (right - left) * (bottom - top)
    outside_pixels = width * comparable_rows - intended_pixels
    return RegionMetrics(
        ComparisonMetrics(intended_changed, intended_pixels, intended_delta),
        ComparisonMetrics(outside_changed, outside_pixels, outside_delta),
    )


def validate_fixed_contract(
    gates: tuple[FieldGate, ...] = FIELD_GATES,
    families: tuple[Family, ...] = FAMILIES,
) -> None:
    if tuple(gate.case_id for gate in gates) != NEW_CASE_IDS:
        raise RendererOutputError("field gate order does not match the four frozen cases")
    if not 0 < MIN_INTENDED_SIGNAL_SHARE <= 1:
        raise RendererOutputError("fixed locality share must be positive and bounded")
    for gate in gates:
        if min(
            gate.visibility_changed_floor,
            gate.visibility_delta_floor,
            gate.family_changed_floor,
            gate.family_delta_floor,
        ) <= 0:
            raise RendererOutputError(f"{gate.case_id}: dynamic or zero floor is forbidden")
        left, right, top, bottom = gate.region
        if not 0 <= left < right <= 1 or not 0 <= top < bottom <= 1:
            raise RendererOutputError(f"{gate.case_id}: invalid normalized region")
        if gate.eligible_stems != EXPECTED_ELIGIBILITY[gate.case_id]:
            raise RendererOutputError(f"{gate.case_id}: eligibility partition is not frozen")

    actual_comparators: dict[str, list[str]] = {case_id: [] for case_id in NEW_CASE_IDS}
    for family in families:
        if family.candidate not in actual_comparators:
            raise RendererOutputError(f"{family.name}: unexpected candidate family")
        if family.candidate == family.reference:
            raise RendererOutputError(f"{family.name}: self comparison is forbidden")
        actual_comparators[family.candidate].append(family.reference)
    for case_id, expected in EXPECTED_COMPARATORS.items():
        if tuple(actual_comparators[case_id]) != expected:
            raise RendererOutputError(f"{case_id}: wrong fixed comparator family")


def reject_disclosure_tokens(values: list[str]) -> None:
    for value in values:
        folded = re.sub(r"[^a-z0-9]", "", value.lower())
        for token in FORBIDDEN_DISCLOSURE_TOKENS:
            if token in folded:
                raise RendererOutputError("raw geometry disclosure token is forbidden")


def validate_renderer_boundary(renderer_source: Path) -> None:
    try:
        source = renderer_source.read_text(encoding="utf-8")
    except OSError as error:
        raise RendererOutputError(f"renderer source unreadable: {error}") from None
    imports = re.findall(r"^\s*import\s+([A-Za-z0-9_]+)\s*$", source, re.MULTILINE)
    if imports != ["AppKit", "CoreImage", "Foundation", "ImageIO", "BeautySDK"]:
        raise RendererOutputError("renderer import boundary changed")
    if len(re.findall(r"\bengine\.processResult\s*\(", source)) != 1:
        raise RendererOutputError("renderer must contain exactly one public facade call")
    reject_disclosure_tokens([source])


def intended_signal_share(metrics: RegionMetrics) -> float:
    total = metrics.intended.absolute_rgb_delta + metrics.outside.absolute_rgb_delta
    if total == 0:
        return 0.0
    return metrics.intended.absolute_rgb_delta / total


def require_visibility_and_locality(
    gate: FieldGate,
    fixture_stem: str,
    metrics: RegionMetrics,
    measure: bool,
) -> None:
    if measure:
        return
    if (
        metrics.intended.changed_pixels < gate.visibility_changed_floor
        or metrics.intended.absolute_rgb_delta < gate.visibility_delta_floor
    ):
        raise RendererOutputError(
            f"{gate.case_id}/{fixture_stem}: intended signal "
            f"{metrics.intended.changed_pixels}/{metrics.intended.absolute_rgb_delta} "
            f"below fixed visibility floors "
            f"{gate.visibility_changed_floor}/{gate.visibility_delta_floor}"
        )
    share = intended_signal_share(metrics)
    if (
        share < MIN_INTENDED_SIGNAL_SHARE
        or metrics.outside.changed_pixels > MAX_OUTSIDE_CHANGED_PIXELS
        or metrics.outside.absolute_rgb_delta > MAX_OUTSIDE_RGB_DELTA
    ):
        raise RendererOutputError(
            f"{gate.case_id}/{fixture_stem}: locality failed fixed share/outside limits"
        )


def require_family_signal(
    gate: FieldGate,
    family: Family,
    fixture_stem: str,
    metrics: RegionMetrics,
    measure: bool,
) -> None:
    if measure:
        return
    if (
        metrics.intended.changed_pixels < gate.family_changed_floor
        or metrics.intended.absolute_rgb_delta < gate.family_delta_floor
    ):
        raise RendererOutputError(
            f"{family.name}/{fixture_stem}: intended signal "
            f"{metrics.intended.changed_pixels}/{metrics.intended.absolute_rgb_delta} "
            f"below fixed family floors {gate.family_changed_floor}/{gate.family_delta_floor}"
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


def validate_outputs(input_dir: Path, output_dir: Path, renderer_source: Path, measure: bool) -> None:
    validate_fixed_contract()
    validate_renderer_boundary(renderer_source)
    case_ids = discover_case_ids(renderer_source)
    fixtures = discover_fixtures(input_dir)
    reject_disclosure_tokens(case_ids + [fixture.relative_path for fixture in fixtures])
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

    portrait_by_stem = {fixture.stem: fixture for fixture in portraits}
    if set(portrait_by_stem) != {f"e{index}" for index in range(1, 7)}:
        raise RendererOutputError("portrait eligibility pool does not match the frozen six fixtures")
    for fixture in portraits:
        for gate in FIELD_GATES:
            normalized_roi(*fixture.dimensions, gate.region)

    visibility_metrics: dict[str, list[RegionMetrics]] = {}
    ineligible_noops = 0
    for gate in FIELD_GATES:
        metrics: list[RegionMetrics] = []
        eligible_stems = set(gate.eligible_stems)
        for fixture in portraits:
            comparison = region_and_outside_difference(
                outputs[(fixture.stem, BASELINE_CASE_ID)],
                outputs[(fixture.stem, gate.case_id)],
                gate.region,
            )
            if fixture.stem in eligible_stems:
                require_visibility_and_locality(gate, fixture.stem, comparison, measure)
                metrics.append(comparison)
            else:
                if (
                    comparison.intended.changed_pixels
                    or comparison.intended.absolute_rgb_delta
                    or comparison.outside.changed_pixels
                    or comparison.outside.absolute_rgb_delta
                ):
                    raise RendererOutputError(
                        f"{gate.case_id}/{fixture.stem}: frozen ineligible portrait is not a no-op"
                    )
                ineligible_noops += 1
        if len(metrics) != len(gate.eligible_stems):
            raise RendererOutputError(
                f"{gate.case_id}: eligible comparison count {len(metrics)}/{len(gate.eligible_stems)}"
            )
        visibility_metrics[gate.case_id] = metrics

    family_metrics: dict[str, list[RegionMetrics]] = {}
    gates_by_case = {gate.case_id: gate for gate in FIELD_GATES}
    for family in FAMILIES:
        gate = gates_by_case[family.candidate]
        metrics: list[RegionMetrics] = []
        for fixture_stem in gate.eligible_stems:
            comparison = region_and_outside_difference(
                outputs[(fixture_stem, family.reference)],
                outputs[(fixture_stem, family.candidate)],
                gate.region,
            )
            require_family_signal(gate, family, fixture_stem, comparison, measure)
            metrics.append(comparison)
        family_metrics[family.name] = metrics

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
    print(f"face evidence mode: {'measurement' if measure else 'strict'}")
    for gate in FIELD_GATES:
        metrics = visibility_metrics[gate.case_id]
        print(
            f"field {gate.case_id}: eligible={len(metrics)}/{len(gate.eligible_stems)}; "
            f"region={gate.region}; "
            f"min_changed={min(item.intended.changed_pixels for item in metrics)}; "
            f"min_absolute_rgb_delta={min(item.intended.absolute_rgb_delta for item in metrics)}; "
            f"min_intended_share={min(intended_signal_share(item) for item in metrics):.6f}; "
            f"max_outside_changed={max(item.outside.changed_pixels for item in metrics)}; "
            f"max_outside_delta={max(item.outside.absolute_rgb_delta for item in metrics)}"
        )
    for family in FAMILIES:
        metrics = family_metrics[family.name]
        print(
            f"family {family.name}: {len(metrics)}/{len(metrics)}; "
            f"min_changed={min(item.intended.changed_pixels for item in metrics)}; "
            f"min_absolute_rgb_delta={min(item.intended.absolute_rgb_delta for item in metrics)}"
        )
    visibility_count = sum(len(metrics) for metrics in visibility_metrics.values())
    family_count = sum(len(metrics) for metrics in family_metrics.values())
    if visibility_count != 18 or family_count != 49 or ineligible_noops != 6:
        raise RendererOutputError("aggregate comparison counts do not match frozen contract")
    print(f"aggregate eligible visibility/locality comparisons: {visibility_count}/18")
    print(f"aggregate fixed-neighbor comparisons: {family_count}/49")
    print(f"aggregate ineligible portrait no-op comparisons: {ineligible_noops}/6")
    print("no-face 64x64 watermark-safe no-op comparisons: 4/4")
    print("renderer boundary: BeautySDK public facade only; raw geometry disclosure: 0")


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
        validate_fixed_contract()

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

        make_test_png(output / "same__one.png", width=3, height=2)
        expect_error(
            "dimension mismatch",
            lambda: validate_matrix(output, ["one"], [fixture]),
            "dimensions 3x2 !=",
        )

        crc_failure = root / "crc-failure.png"
        make_test_png(crc_failure)
        crc_bytes = bytearray(crc_failure.read_bytes())
        crc_bytes[-1] ^= 0x01
        crc_failure.write_bytes(crc_bytes)
        expect_error(
            "CRC failure",
            lambda: read_png_payload(crc_failure, "CRC"),
            "invalid IEND CRC",
        )

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

        invalid_filter = root / "invalid-filter.png"
        make_test_png(invalid_filter, width=1, height=1, raw_override=b"\x05\x00\x00\x00")
        expect_error(
            "invalid PNG filter",
            lambda: decoded_rgb(invalid_filter),
            "unsupported PNG filter 5",
        )
        expect_error(
            "ROI watermark",
            lambda: normalized_roi(100, 100, FIELD_GATES[0].region),
            "not wholly above watermark",
        )

        no_face_baseline = root / "no-face-baseline.png"
        no_face_candidate = root / "no-face-candidate.png"
        make_test_png(no_face_baseline, width=64, height=64)
        make_test_png(no_face_candidate, width=64, height=64)
        no_face_metrics = watermark_safe_no_face_difference(no_face_baseline, no_face_candidate)
        if no_face_metrics != ComparisonMetrics(0, 2_048, 0):
            raise AssertionError(f"no-face fallback mismatch: {no_face_metrics}")

        zero_floor_gate = FieldGate(
            FACE_CONTOUR_CASE_ID,
            FIELD_GATES[0].region,
            FIELD_GATES[0].eligible_stems,
            0,
            FIELD_GATES[0].visibility_delta_floor,
            FIELD_GATES[0].family_changed_floor,
            FIELD_GATES[0].family_delta_floor,
        )
        expect_error(
            "zero/dynamic floor",
            lambda: validate_fixed_contract((zero_floor_gate, *FIELD_GATES[1:]), FAMILIES),
            "dynamic or zero floor",
        )
        wrong_eligibility_gate = FieldGate(
            FACE_CONTOUR_CASE_ID,
            FIELD_GATES[0].region,
            ("e1", *FIELD_GATES[0].eligible_stems),
            FIELD_GATES[0].visibility_changed_floor,
            FIELD_GATES[0].visibility_delta_floor,
            FIELD_GATES[0].family_changed_floor,
            FIELD_GATES[0].family_delta_floor,
        )
        expect_error(
            "ineligible visibility partition",
            lambda: validate_fixed_contract((wrong_eligibility_gate, *FIELD_GATES[1:]), FAMILIES),
            "eligibility partition",
        )
        wrong_families = (
            Family("contour_vs_wrong", FACE_CONTOUR_CASE_ID, "jawSlim_0p35"),
            *FAMILIES[1:],
        )
        expect_error(
            "wrong comparator family",
            lambda: validate_fixed_contract(FIELD_GATES, wrong_families),
            "wrong fixed comparator family",
        )
        expect_error(
            "raw geometry disclosure",
            lambda: reject_disclosure_tokens(["raw-landmarks.json"]),
            "raw geometry disclosure token",
        )

        synthetic_width = synthetic_height = 800
        baseline_raw = b"".join(
            b"\x00" + b"\x00\x00\x00" * synthetic_width
            for _ in range(synthetic_height)
        )
        outside_rows = [
            bytearray(b"\x00\x00\x00" * synthetic_width)
            for _ in range(synthetic_height)
        ]
        outside_rows[100][760 * 3 : 760 * 3 + 3] = b"\xff\xff\xff"
        outside_raw = b"".join(b"\x00" + bytes(row) for row in outside_rows)
        locality_baseline = root / "locality-baseline.png"
        locality_candidate = root / "locality-outside-only.png"
        make_test_png(
            locality_baseline,
            width=synthetic_width,
            height=synthetic_height,
            raw_override=baseline_raw,
        )
        make_test_png(
            locality_candidate,
            width=synthetic_width,
            height=synthetic_height,
            raw_override=outside_raw,
        )
        outside_only = region_and_outside_difference(
            locality_baseline,
            locality_candidate,
            FIELD_GATES[0].region,
        )
        expect_error(
            "outside-only locality",
            lambda: require_visibility_and_locality(FIELD_GATES[0], "synthetic", outside_only, False),
            "below fixed visibility floors",
        )

    print(
        "self-test passed: duplicate IDs/stems, missing/extra/corrupt/CRC/filter/dimension/symlink outputs, "
        "bounded PNG/JPEG decode, single-descriptor replacement/growth races, ROI/watermark rejection, "
        "fixed positive floors/comparators/eligibility, outside-only rejection, raw-disclosure rejection, "
        "and 2048-pixel no-face fallback"
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
        print(f"phase 47 face renderer output check failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
