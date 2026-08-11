#!/usr/bin/env python3
"""Fail-closed Phase 61 public teeth output verifier."""

from __future__ import annotations

import argparse
import binascii
import json
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
from pathlib import Path


BASELINE = "geometryBaseline_noop"
ACTIVE = "teethWhitening_1p00"
ROLES = ("positive", "negative", "no_face")
EXPECTED_NAMES = frozenset(f"{role}__{case}.png" for role in ROLES for case in (BASELINE, ACTIVE))
MAX_FILE_BYTES = 16 * 1024 * 1024
MAX_DECODED_BYTES = 64 * 1024 * 1024
MAX_DIMENSION = 4096


class OutputError(Exception):
    pass


@dataclass(frozen=True)
class Image:
    width: int
    height: int
    rgba: bytes


@dataclass(frozen=True)
class Metrics:
    changed_inside: int
    changed_outside: int
    alpha_changed: int
    maximum_channel_delta: int
    mean_absolute_rgb_delta: float
    mean_luminance_delta: float
    mean_yellow_before: float
    mean_yellow_after: float
    texture_ratio: float


def bounded_regular_bytes(path: Path, label: str) -> bytes:
    descriptor = None
    try:
        if not hasattr(os, "O_NOFOLLOW"):
            raise OutputError(f"{label}: no-follow open unsupported")
        descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | getattr(os, "O_CLOEXEC", 0))
        before = os.fstat(descriptor)
        if not stat.S_ISREG(before.st_mode):
            raise OutputError(f"{label}: not a regular file")
        if before.st_size <= 0 or before.st_size > MAX_FILE_BYTES:
            raise OutputError(f"{label}: invalid file size")
        retained = bytearray()
        while len(retained) <= MAX_FILE_BYTES:
            chunk = os.read(descriptor, min(1024 * 1024, MAX_FILE_BYTES + 1 - len(retained)))
            if not chunk:
                break
            retained.extend(chunk)
        after = os.fstat(descriptor)
        if len(retained) != before.st_size or before.st_dev != after.st_dev or before.st_ino != after.st_ino:
            raise OutputError(f"{label}: changed while reading")
        if len(retained) > MAX_FILE_BYTES:
            raise OutputError(f"{label}: exceeds byte budget")
        return bytes(retained)
    except OSError:
        raise OutputError(f"{label}: unreadable") from None
    finally:
        if descriptor is not None:
            os.close(descriptor)


def paeth(left: int, up: int, upper_left: int) -> int:
    estimate = left + up - upper_left
    candidates = (left, up, upper_left)
    return candidates[min(range(3), key=lambda index: abs(estimate - candidates[index]))]


def decode_png(path: Path, label: str, require_explicit_srgb: bool = False) -> Image:
    data = bounded_regular_bytes(path, label)
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise OutputError(f"{label}: not PNG")
    offset = 8
    width = height = bit_depth = color_type = interlace = None
    idat: list[bytes] = []
    seen_ihdr = seen_iend = seen_srgb = seen_iccp = False
    chunk_index = 0
    while offset + 12 <= len(data):
        length = struct.unpack(">I", data[offset : offset + 4])[0]
        kind = data[offset + 4 : offset + 8]
        start = offset + 8
        end = start + length
        crc_end = end + 4
        if crc_end > len(data):
            raise OutputError(f"{label}: truncated chunk")
        payload = data[start:end]
        expected_crc = struct.unpack(">I", data[end:crc_end])[0]
        if binascii.crc32(kind + payload) & 0xFFFFFFFF != expected_crc:
            raise OutputError(f"{label}: invalid CRC")
        offset = crc_end
        if chunk_index == 0 and kind != b"IHDR":
            raise OutputError(f"{label}: IHDR must be first")
        if not seen_ihdr and kind != b"IHDR":
            raise OutputError(f"{label}: chunk before IHDR")
        chunk_index += 1
        if kind == b"IHDR":
            if seen_ihdr or length != 13:
                raise OutputError(f"{label}: invalid IHDR")
            seen_ihdr = True
            width, height = struct.unpack(">II", payload[:8])
            bit_depth, color_type, compression, filtering, interlace = payload[8:13]
            if compression != 0 or filtering != 0:
                raise OutputError(f"{label}: unsupported PNG methods")
        elif kind == b"sRGB":
            if seen_srgb or seen_iccp or length != 1 or payload[0] > 3 or idat:
                raise OutputError(f"{label}: invalid sRGB declaration")
            seen_srgb = True
        elif kind == b"iCCP":
            if seen_iccp or idat or seen_srgb:
                raise OutputError(f"{label}: conflicting ICC declaration")
            seen_iccp = True
        elif kind == b"IDAT":
            idat.append(payload)
        elif kind == b"IEND":
            if length != 0:
                raise OutputError(f"{label}: invalid IEND")
            seen_iend = True
            break
        elif kind not in (b"PLTE",) and kind and kind[0] & 0x20 == 0:
            raise OutputError(f"{label}: unknown critical chunk")
    if not seen_ihdr or not seen_iend or offset != len(data) or not idat:
        raise OutputError(f"{label}: incomplete PNG")
    if require_explicit_srgb and not seen_srgb:
        raise OutputError(f"{label}: explicit sRGB declaration missing")
    if require_explicit_srgb and seen_iccp:
        raise OutputError(f"{label}: ambiguous sRGB authority")
    if not isinstance(width, int) or not isinstance(height, int) or width <= 0 or height <= 0:
        raise OutputError(f"{label}: invalid dimensions")
    if width > MAX_DIMENSION or height > MAX_DIMENSION:
        raise OutputError(f"{label}: dimensions exceed budget")
    if bit_depth != 8 or color_type not in (2, 6) or interlace != 0:
        raise OutputError(f"{label}: unsupported PNG encoding")
    channels = 4 if color_type == 6 else 3
    row_bytes = width * channels
    expected = (row_bytes + 1) * height
    if expected > MAX_DECODED_BYTES:
        raise OutputError(f"{label}: decoded bytes exceed budget")
    try:
        decompressor = zlib.decompressobj()
        raw = decompressor.decompress(b"".join(idat), expected + 1)
        if decompressor.unconsumed_tail:
            raise OutputError(f"{label}: decoded bytes exceed budget")
        remaining = expected + 1 - len(raw)
        if remaining <= 0:
            raise OutputError(f"{label}: decoded bytes exceed budget")
        raw += decompressor.flush(remaining)
    except zlib.error:
        raise OutputError(f"{label}: invalid compressed data") from None
    if not decompressor.eof or decompressor.unused_data or decompressor.unconsumed_tail:
        raise OutputError(f"{label}: invalid compressed stream boundary")
    if len(raw) != expected:
        raise OutputError(f"{label}: decoded length mismatch")
    previous = bytearray(row_bytes)
    cursor = 0
    rgba = bytearray()
    for _ in range(height):
        filter_type = raw[cursor]
        cursor += 1
        row = bytearray(raw[cursor : cursor + row_bytes])
        cursor += row_bytes
        for index in range(row_bytes):
            left = row[index - channels] if index >= channels else 0
            up = previous[index]
            upper_left = previous[index - channels] if index >= channels else 0
            if filter_type == 0:
                value = row[index]
            elif filter_type == 1:
                value = row[index] + left
            elif filter_type == 2:
                value = row[index] + up
            elif filter_type == 3:
                value = row[index] + ((left + up) // 2)
            elif filter_type == 4:
                value = row[index] + paeth(left, up, upper_left)
            else:
                raise OutputError(f"{label}: unsupported PNG filter")
            row[index] = value & 0xFF
        for index in range(0, row_bytes, channels):
            rgba.extend(row[index : index + 3])
            rgba.append(row[index + 3] if channels == 4 else 255)
        previous = row
    return Image(width, height, bytes(rgba))


def luminance(data: bytes, offset: int) -> float:
    return (0.2126 * data[offset] + 0.7152 * data[offset + 1] + 0.0722 * data[offset + 2]) / 255


def yellow(data: bytes, offset: int) -> float:
    return max(0.0, (data[offset] + data[offset + 1]) / (2 * 255) - data[offset + 2] / 255)


def inside_mask(mask: Image, index: int) -> bool:
    offset = index * 4
    return max(mask.rgba[offset : offset + 4]) > 2


def texture_energy(image: Image, mask: Image) -> float:
    total = 0.0
    count = 0
    for y in range(image.height):
        for x in range(image.width):
            index = y * image.width + x
            if not inside_mask(mask, index):
                continue
            if x + 1 < image.width and inside_mask(mask, index + 1):
                total += abs(luminance(image.rgba, index * 4) - luminance(image.rgba, (index + 1) * 4))
                count += 1
            if y + 1 < image.height and inside_mask(mask, index + image.width):
                total += abs(luminance(image.rgba, index * 4) - luminance(image.rgba, (index + image.width) * 4))
                count += 1
    return total / count if count else 0.0


def measure(before: Image, after: Image, mask: Image) -> Metrics:
    if (before.width, before.height) != (after.width, after.height) or (before.width, before.height) != (mask.width, mask.height):
        raise OutputError("comparison dimensions differ")
    changed_inside = changed_outside = alpha_changed = maximum_delta = 0
    rgb_total = luminance_total = yellow_before = yellow_after = 0.0
    mask_count = changed_mask_count = 0
    for index in range(before.width * before.height):
        offset = index * 4
        deltas = [abs(after.rgba[offset + channel] - before.rgba[offset + channel]) for channel in range(3)]
        changed = any(deltas)
        inside = inside_mask(mask, index)
        if after.rgba[offset + 3] != before.rgba[offset + 3]:
            alpha_changed += 1
        if changed:
            if inside:
                changed_inside += 1
            else:
                changed_outside += 1
        if not inside:
            continue
        mask_count += 1
        maximum_delta = max(maximum_delta, *deltas)
        rgb_total += sum(deltas) / (3 * 255)
        luminance_total += luminance(after.rgba, offset) - luminance(before.rgba, offset)
        if changed:
            changed_mask_count += 1
            yellow_before += yellow(before.rgba, offset)
            yellow_after += yellow(after.rgba, offset)
    before_texture = texture_energy(before, mask)
    after_texture = texture_energy(after, mask)
    return Metrics(
        changed_inside,
        changed_outside,
        alpha_changed,
        maximum_delta,
        rgb_total / max(1, mask_count),
        luminance_total / max(1, mask_count),
        yellow_before / max(1, changed_mask_count),
        yellow_after / max(1, changed_mask_count),
        after_texture / before_texture if before_texture > 0 else 1.0,
    )


def discover_case_ids(source_path: Path) -> list[str]:
    try:
        source = source_path.read_text(encoding="utf-8")
    except OSError:
        raise OutputError("renderer source unreadable") from None
    ids = re.findall(r'\bid\s*:\s*"([^"]+)"', source)
    duplicates = [item for item, count in Counter(ids).items() if count > 1]
    if len(ids) != 74 or duplicates or ids.count(BASELINE) != 1 or ids.count(ACTIVE) != 1:
        raise OutputError("renderer case inventory mismatch")
    if "import BeautySDK" not in source:
        raise OutputError("renderer does not import public facade")
    for forbidden_import in ("import BeautyCore", "import BeautyDetection", "import BeautyEffects", "@_spi(Testing)"):
        if forbidden_import in source:
            raise OutputError("renderer contains internal bypass")
    active_start = source.find(f'id: "{ACTIVE}"')
    active_end = source.find("\n    RenderCase(", active_start + 1)
    if active_end < 0:
        active_end = source.find("\n]", active_start + 1)
    snippet = source[active_start:active_end]
    if active_start < 0 or "BeautyParameters(teethWhitening: 1)" not in snippet:
        raise OutputError("renderer active case is not exact public intent")
    if source.count("engine.processResult(") != 1 or "--no-watermark" not in source:
        raise OutputError("renderer facade or presentation-free contract mismatch")
    if "scleraRednessReduction:" in snippet:
        raise OutputError("renderer active case contains sibling intent")
    for forbidden in ("teethWhite:", "toothWhitening:", "upperEyelidFullnessReduction:"):
        if forbidden in source:
            raise OutputError("renderer contains forbidden candidate route")
    return ids


def require_output_inventory(output_dir: Path) -> dict[str, Path]:
    if output_dir.is_symlink() or not output_dir.is_dir():
        raise OutputError("output root invalid")
    discovered: dict[str, Path] = {}
    for path in output_dir.iterdir():
        mode = path.lstat().st_mode
        if not stat.S_ISREG(mode) or path.suffix.lower() != ".png":
            raise OutputError("output contains unexpected entry")
        discovered[path.name] = path
    if frozenset(discovered) != EXPECTED_NAMES:
        raise OutputError("output inventory mismatch")
    return discovered


def load_masks(bundle: Path) -> dict[str, Image]:
    if bundle.is_symlink() or not bundle.is_dir():
        raise OutputError("private bundle invalid")
    try:
        manifest = json.loads(bounded_regular_bytes(bundle / "manifest.json", "manifest"))
    except (json.JSONDecodeError, UnicodeDecodeError):
        raise OutputError("private manifest invalid") from None
    fixtures = manifest.get("fixtures") if isinstance(manifest, dict) else None
    if manifest.get("schema_version") != 1 or not isinstance(fixtures, list) or len(fixtures) != 2:
        raise OutputError("private manifest shape invalid")
    masks: dict[str, Image] = {}
    for fixture in fixtures:
        if not isinstance(fixture, dict) or fixture.get("polarity") not in ("positive", "negative"):
            raise OutputError("private fixture role invalid")
        role = fixture["polarity"]
        assets = fixture.get("assets")
        relative = assets.get("mask") if isinstance(assets, dict) else None
        if not isinstance(relative, str) or relative.startswith("/") or any(part in ("", "..") for part in relative.split("/")):
            raise OutputError("private mask binding invalid")
        path = (bundle / relative).absolute()
        if os.path.commonpath((str(bundle.absolute()), str(path))) != str(bundle.absolute()):
            raise OutputError("private mask escapes bundle")
        if role in masks:
            raise OutputError("duplicate private role")
        masks[role] = decode_png(path, f"{role} mask")
    if set(masks) != {"positive", "negative"}:
        raise OutputError("private role pair incomplete")
    return masks


def verify_live(output_dir: Path, bundle: Path, renderer_source: Path) -> dict[str, int | str]:
    discover_case_ids(renderer_source)
    files = require_output_inventory(output_dir)
    masks = load_masks(bundle)
    metrics: dict[str, Metrics] = {}
    for role in ("positive", "negative"):
        baseline = decode_png(
            files[f"{role}__{BASELINE}.png"], f"{role} baseline", require_explicit_srgb=True
        )
        active = decode_png(
            files[f"{role}__{ACTIVE}.png"], f"{role} active", require_explicit_srgb=True
        )
        metrics[role] = measure(baseline, active, masks[role])
    no_face_before = decode_png(
        files[f"no_face__{BASELINE}.png"], "no-face baseline", require_explicit_srgb=True
    )
    no_face_after = decode_png(
        files[f"no_face__{ACTIVE}.png"], "no-face active", require_explicit_srgb=True
    )
    if (no_face_before.width, no_face_before.height, no_face_before.rgba) != (
        no_face_after.width,
        no_face_after.height,
        no_face_after.rgba,
    ):
        raise OutputError("no-face output changed")
    positive = metrics["positive"]
    negative = metrics["negative"]
    common = (positive, negative)
    if any(item.changed_outside != 0 or item.alpha_changed != 0 or not 0.85 <= item.texture_ratio <= 1.15 for item in common):
        raise OutputError("common containment or texture bound failed")
    if not (
        positive.changed_inside > 0
        and positive.mean_yellow_after < positive.mean_yellow_before
        and 0 < positive.mean_luminance_delta <= 0.03
        and positive.maximum_channel_delta <= 48
    ):
        raise OutputError("positive target bound failed")
    if negative.mean_absolute_rgb_delta > 0.012 or abs(negative.mean_luminance_delta) > 0.006:
        raise OutputError("negative naturalness bound failed")
    return {"status": "pass", "outputs": 6, "positive_roles": 1, "negative_roles": 1, "no_face_roles": 1}


def chunk(kind: bytes, payload: bytes) -> bytes:
    return struct.pack(">I", len(payload)) + kind + payload + struct.pack(">I", binascii.crc32(kind + payload) & 0xFFFFFFFF)


def encode_png(width: int, height: int, rgba: bytes, explicit_srgb: bool = True) -> bytes:
    rows = b"".join(b"\x00" + rgba[y * width * 4 : (y + 1) * width * 4] for y in range(height))
    color = chunk(b"sRGB", b"\x00") if explicit_srgb else b""
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
        + color
        + chunk(b"IDAT", zlib.compress(rows))
        + chunk(b"IEND", b"")
    )


def run_self_test() -> int:
    passed = 0
    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        width = height = 8
        source = bytearray([40, 25, 30, 255] * (width * height))
        mask = bytearray([0, 0, 0, 0] * (width * height))
        for y in range(3, 5):
            for x in range(2, 6):
                index = y * width + x
                source[index * 4 : index * 4 + 4] = bytes((181, 161, 120, 255))
                mask[index * 4 : index * 4 + 4] = bytes((255, 255, 255, 255))
        target = bytearray(source)
        for index in (26, 27, 28, 29):
            target[index * 4 : index * 4 + 4] = bytes((183, 163, 153, 255))
        source_path = root / "source.png"
        target_path = root / "target.png"
        mask_path = root / "mask.png"
        source_path.write_bytes(encode_png(width, height, bytes(source)))
        target_path.write_bytes(encode_png(width, height, bytes(target)))
        mask_path.write_bytes(encode_png(width, height, bytes(mask)))
        before = decode_png(source_path, "self source")
        after = decode_png(target_path, "self target")
        decoded_mask = decode_png(mask_path, "self mask")
        result = measure(before, after, decoded_mask)
        if result.changed_inside != 4 or result.changed_outside != 0 or result.alpha_changed != 0:
            raise AssertionError("valid measurement rejected")
        passed += 1

        mutations = []
        mutations.append(("outside", lambda: measure(before, Image(width, height, bytes(bytearray(target[:-4]) + bytearray((1, 1, 1, 255)))), decoded_mask).changed_outside == 0))
        mutations.append(("alpha", lambda: measure(before, Image(width, height, bytes(bytearray(target[:107]) + bytearray((0,)) + bytearray(target[108:]))), decoded_mask).alpha_changed == 0))
        mutations.append(("dimensions", lambda: measure(before, Image(width - 1, height, after.rgba), decoded_mask)))
        for name, probe in mutations:
            failed = False
            try:
                outcome = probe()
                failed = outcome is False
            except OutputError:
                failed = True
            if not failed:
                raise AssertionError(f"mutation did not fail: {name}")
            passed += 1

        corrupt = root / "corrupt.png"
        corrupt.write_bytes(source_path.read_bytes()[:-1] + b"X")
        try:
            decode_png(corrupt, "corrupt")
        except OutputError:
            passed += 1
        else:
            raise AssertionError("corrupt PNG accepted")
        link = root / "link.png"
        link.symlink_to(source_path)
        try:
            decode_png(link, "link")
        except OutputError:
            passed += 1
        else:
            raise AssertionError("symlink PNG accepted")

        oversized = root / "oversized.png"
        oversized.write_bytes(
            b"\x89PNG\r\n\x1a\n"
            + chunk(b"IHDR", struct.pack(">IIBBBBB", MAX_DIMENSION + 1, 1, 8, 6, 0, 0, 0))
            + chunk(b"IDAT", zlib.compress(b""))
            + chunk(b"IEND", b"")
        )
        try:
            decode_png(oversized, "oversized")
        except OutputError:
            passed += 1
        else:
            raise AssertionError("oversized PNG accepted")

        missing_srgb = root / "missing-srgb.png"
        missing_srgb.write_bytes(encode_png(width, height, bytes(source), explicit_srgb=False))
        try:
            decode_png(missing_srgb, "missing sRGB", require_explicit_srgb=True)
        except OutputError:
            passed += 1
        else:
            raise AssertionError("PNG without explicit sRGB accepted")

        wrong_order = root / "wrong-order.png"
        wrong_order.write_bytes(
            b"\x89PNG\r\n\x1a\n"
            + chunk(b"sRGB", b"\x00")
            + source_path.read_bytes()[8:]
        )
        try:
            decode_png(wrong_order, "wrong order", require_explicit_srgb=True)
        except OutputError:
            passed += 1
        else:
            raise AssertionError("PNG with pre-IHDR sRGB accepted")

        conflicting_profile = root / "conflicting-profile.png"
        encoded = encode_png(width, height, bytes(source))
        idat_offset = encoded.index(b"IDAT") - 4
        conflicting_profile.write_bytes(
            encoded[:idat_offset]
            + chunk(b"iCCP", b"profile\x00\x00compressed")
            + encoded[idat_offset:]
        )
        try:
            decode_png(conflicting_profile, "conflicting profile", require_explicit_srgb=True)
        except OutputError:
            passed += 1
        else:
            raise AssertionError("PNG with conflicting iCCP and sRGB accepted")

        output_dir = root / "outputs"
        output_dir.mkdir()
        for name in EXPECTED_NAMES:
            (output_dir / name).write_bytes(b"placeholder")
        if set(require_output_inventory(output_dir)) != set(EXPECTED_NAMES):
            raise AssertionError("valid inventory rejected")
        passed += 1
        (output_dir / "unexpected.png").write_bytes(b"placeholder")
        try:
            require_output_inventory(output_dir)
        except OutputError:
            passed += 1
        else:
            raise AssertionError("unexpected output accepted")
        (output_dir / "unexpected.png").unlink()

        renderer_source = root / "main.swift"
        renderer_source.write_text(
            "import BeautySDK\n"
            + "\n".join(f'RenderCase(id: "case_{index}"),' for index in range(72))
            + f'\nRenderCase(id: "{BASELINE}"),'
            + f'\nRenderCase(id: "{ACTIVE}", parameters: BeautyParameters(teethWhitening: 1))\n'
            + 'let presentationFlag = "--no-watermark"\nengine.processResult(\n',
            encoding="utf-8",
        )
        if len(discover_case_ids(renderer_source)) != 74:
            raise AssertionError("valid renderer source rejected")
        passed += 1
        valid_renderer = renderer_source.read_text(encoding="utf-8")
        renderer_source.write_text(
            valid_renderer.replace(
                "BeautyParameters(teethWhitening: 1)",
                "BeautyParameters(teethWhitening: 1, scleraRednessReduction: 1)",
            ),
            encoding="utf-8",
        )
        try:
            discover_case_ids(renderer_source)
        except OutputError:
            passed += 1
        else:
            raise AssertionError("sibling intent accepted in teeth case")
        renderer_source.write_text(valid_renderer.replace("import BeautySDK", "import BeautyCore"), encoding="utf-8")
        try:
            discover_case_ids(renderer_source)
        except OutputError:
            passed += 1
        else:
            raise AssertionError("internal renderer import accepted")
        renderer_source.write_text(valid_renderer.replace(ACTIVE, "case_0"), encoding="utf-8")
        try:
            discover_case_ids(renderer_source)
        except OutputError:
            passed += 1
        else:
            raise AssertionError("missing active renderer case accepted")

        for predicate in (
            result.mean_yellow_after < result.mean_yellow_before,
            0 < result.mean_luminance_delta <= 0.03,
            result.maximum_channel_delta <= 48,
            result.changed_inside > 0,
            result.texture_ratio > 0,
            result.mean_absolute_rgb_delta > 0,
        ):
            if not predicate:
                raise AssertionError("metric self-test failed")
            passed += 1
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--output")
    parser.add_argument("--bundle")
    parser.add_argument("--renderer-source")
    args = parser.parse_args()
    try:
        if args.self_test:
            count = run_self_test()
            print(json.dumps({"status": "pass", "self_tests": count}, separators=(",", ":")))
            return 0
        if not args.output or not args.bundle or not args.renderer_source:
            raise OutputError("live mode requires output, bundle, and renderer source")
        result = verify_live(Path(args.output), Path(args.bundle), Path(args.renderer_source))
        print(json.dumps(result, separators=(",", ":")))
        return 0
    except (OutputError, AssertionError, OSError, ValueError) as error:
        print(f"phase61_output_failed:{type(error).__name__}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
