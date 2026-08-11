#!/usr/bin/env python3
"""Fail-closed Phase 64 public sclera output verifier."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import re
import struct
import sys
import tempfile
import zlib
from collections import Counter
from dataclasses import dataclass
from pathlib import Path


BASELINE = "geometryBaseline_noop"
ACTIVE = "scleraRednessReduction_1p00"
ROLES = ("positive", "negative", "no_face")
EXPECTED_NAMES = frozenset(
    f"{role}__{case}.png" for role in ROLES for case in (BASELINE, ACTIVE)
)
MAX_FILE_BYTES = 16 * 1024 * 1024
MAX_DECODED_BYTES = 64 * 1024 * 1024
MAX_DIMENSION = 4096


def load_phase61_decoder():
    if not hasattr(os, "O_NOFOLLOW"):
        raise RuntimeError("O_NOFOLLOW unavailable")
    source = Path(__file__).resolve().parents[1] / (
        "61-teeth-output-safety-and-independent-closeout/check_teeth_renderer_outputs.py"
    )
    spec = importlib.util.spec_from_file_location("phase61_png_decoder", source)
    if spec is None or spec.loader is None:
        raise RuntimeError("shared decoder unavailable")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    module.BASELINE = BASELINE
    module.ACTIVE = ACTIVE
    module.ROLES = ROLES
    module.EXPECTED_NAMES = EXPECTED_NAMES
    module.MAX_FILE_BYTES = MAX_FILE_BYTES
    module.MAX_DECODED_BYTES = MAX_DECODED_BYTES
    module.MAX_DIMENSION = MAX_DIMENSION
    return module


Shared = load_phase61_decoder()
OutputError = Shared.OutputError
Image = Shared.Image
decode_png = Shared.decode_png
encode_png = Shared.encode_png
bounded_regular_bytes = Shared.bounded_regular_bytes
inside_mask = Shared.inside_mask
texture_energy = Shared.texture_energy


@dataclass(frozen=True)
class Metrics:
    changed_inside: int
    changed_outside: int
    alpha_changed: int
    maximum_channel_delta: int
    mean_absolute_rgb_delta: float
    mean_luminance_delta: float
    mean_red_excess_before: float
    mean_red_excess_after: float
    texture_ratio: float
    improved_eye_count: int


def luminance(data: bytes, offset: int) -> float:
    return (
        0.2126 * data[offset]
        + 0.7152 * data[offset + 1]
        + 0.0722 * data[offset + 2]
    ) / 255


def red_excess(data: bytes, offset: int) -> float:
    return max(0.0, (data[offset] - max(data[offset + 1], data[offset + 2])) / 255)


def measure(before: Image, after: Image, mask: Image) -> Metrics:
    if (before.width, before.height) != (after.width, after.height) or (
        before.width,
        before.height,
    ) != (mask.width, mask.height):
        raise OutputError("comparison dimensions differ")
    changed_inside = changed_outside = alpha_changed = maximum_delta = 0
    rgb_total = luminance_total = red_before = red_after = 0.0
    mask_count = changed_mask_count = 0
    eye_changed = [0, 0]
    eye_before = [0.0, 0.0]
    eye_after = [0.0, 0.0]
    for index in range(before.width * before.height):
        offset = index * 4
        deltas = [
            abs(after.rgba[offset + channel] - before.rgba[offset + channel])
            for channel in range(3)
        ]
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
            side = 0 if index % before.width < before.width / 2 else 1
            eye_changed[side] += 1
            before_value = red_excess(before.rgba, offset)
            after_value = red_excess(after.rgba, offset)
            eye_before[side] += before_value
            eye_after[side] += after_value
            red_before += before_value
            red_after += after_value
    before_texture = texture_energy(before, mask)
    after_texture = texture_energy(after, mask)
    improved_eye_count = sum(
        count > 0 and eye_after[index] < eye_before[index]
        for index, count in enumerate(eye_changed)
    )
    return Metrics(
        changed_inside=changed_inside,
        changed_outside=changed_outside,
        alpha_changed=alpha_changed,
        maximum_channel_delta=maximum_delta,
        mean_absolute_rgb_delta=rgb_total / max(1, mask_count),
        mean_luminance_delta=luminance_total / max(1, mask_count),
        mean_red_excess_before=red_before / max(1, changed_mask_count),
        mean_red_excess_after=red_after / max(1, changed_mask_count),
        texture_ratio=after_texture / before_texture if before_texture > 0 else 1.0,
        improved_eye_count=improved_eye_count,
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
    for forbidden_import in (
        "import BeautyCore",
        "import BeautyDetection",
        "import BeautyEffects",
        "@_spi(Testing)",
    ):
        if forbidden_import in source:
            raise OutputError("renderer contains internal bypass")
    active_start = source.find(f'id: "{ACTIVE}"')
    active_end = source.find("\n    RenderCase(", active_start + 1)
    if active_end < 0:
        active_end = source.find("\n]", active_start + 1)
    if active_end < 0:
        active_end = len(source)
    snippet = source[active_start:active_end]
    if active_start < 0 or "BeautyParameters(scleraRednessReduction: 1)" not in snippet:
        raise OutputError("renderer active case is not exact public intent")
    if source.count("engine.processResult(") != 1 or "--no-watermark" not in source:
        raise OutputError("renderer facade contract mismatch")
    for forbidden in (
        "scleraRedness:",
        "scleraWhitening:",
        "eyeRednessReduction:",
        "upperEyelidFullnessReduction:",
    ):
        if forbidden in source:
            raise OutputError("renderer contains forbidden candidate route")
    return ids


def require_output_inventory(output_dir: Path) -> dict[str, Path]:
    return Shared.require_output_inventory(output_dir)


def load_masks(bundle: Path) -> dict[str, Image]:
    return Shared.load_masks(bundle)


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
    if any(
        item.changed_outside != 0
        or item.alpha_changed != 0
        or not 0.82 <= item.texture_ratio <= 1.18
        for item in (positive, negative)
    ):
        raise OutputError("common containment or texture bound failed")
    if not (
        positive.changed_inside > 0
        and positive.improved_eye_count >= 1
        and positive.mean_red_excess_after < positive.mean_red_excess_before
        and abs(positive.mean_luminance_delta) <= 0.018
        and positive.maximum_channel_delta <= 44
    ):
        raise OutputError("positive target bound failed")
    if negative.mean_absolute_rgb_delta > 0.010 or abs(negative.mean_luminance_delta) > 0.006:
        raise OutputError("negative naturalness bound failed")
    return {
        "status": "pass",
        "outputs": 6,
        "positive_roles": 1,
        "negative_roles": 1,
        "no_face_roles": 1,
        "improved_eye_roles": 1,
    }


def must_fail(probe, label: str) -> int:
    try:
        outcome = probe()
    except (OutputError, OSError, ValueError):
        return 1
    if outcome is False:
        return 1
    raise AssertionError(f"mutation did not fail: {label}")


def run_self_test() -> int:
    passed = 0
    with tempfile.TemporaryDirectory() as temporary:
        root = Path(temporary)
        width, height = 12, 8
        source = bytearray([40, 30, 30, 255] * (width * height))
        mask = bytearray([0, 0, 0, 0] * (width * height))
        for y in range(3, 5):
            for x in list(range(2, 5)) + list(range(7, 10)):
                index = y * width + x
                source[index * 4:index * 4 + 4] = bytes((210, 150, 150, 255))
                mask[index * 4:index * 4 + 4] = bytes((255, 255, 255, 255))
        target = bytearray(source)
        for index in (38, 39, 43, 44):
            target[index * 4:index * 4 + 4] = bytes((190, 156, 156, 255))
        source_path, target_path, mask_path = root / "source.png", root / "target.png", root / "mask.png"
        source_path.write_bytes(encode_png(width, height, bytes(source)))
        target_path.write_bytes(encode_png(width, height, bytes(target)))
        mask_path.write_bytes(encode_png(width, height, bytes(mask)))
        before = decode_png(source_path, "source")
        after = decode_png(target_path, "target")
        decoded_mask = decode_png(mask_path, "mask")
        result = measure(before, after, decoded_mask)
        if result.changed_inside != 4 or result.changed_outside or result.alpha_changed:
            raise AssertionError("valid measurement rejected")
        passed += 1
        if result.improved_eye_count != 2 or result.mean_red_excess_after >= result.mean_red_excess_before:
            raise AssertionError("valid improvement rejected")
        passed += 1
        outside = bytearray(target)
        outside[0:4] = bytes((1, 1, 1, 255))
        passed += must_fail(
            lambda: measure(before, Image(width, height, bytes(outside)), decoded_mask).changed_outside == 0,
            "outside",
        )
        alpha = bytearray(target)
        alpha[38 * 4 + 3] = 0
        passed += must_fail(
            lambda: measure(before, Image(width, height, bytes(alpha)), decoded_mask).alpha_changed == 0,
            "alpha",
        )
        passed += must_fail(
            lambda: measure(before, Image(width - 1, height, after.rgba), decoded_mask),
            "dimensions",
        )
        corrupt = root / "corrupt.png"
        corrupt.write_bytes(source_path.read_bytes()[:-1] + b"X")
        passed += must_fail(lambda: decode_png(corrupt, "corrupt"), "corrupt")
        link = root / "link.png"
        link.symlink_to(source_path)
        passed += must_fail(lambda: decode_png(link, "link"), "symlink")
        oversized = root / "oversized.png"
        oversized.write_bytes(
            b"\x89PNG\r\n\x1a\n"
            + Shared.chunk(b"IHDR", struct.pack(">IIBBBBB", MAX_DIMENSION + 1, 1, 8, 6, 0, 0, 0))
            + Shared.chunk(b"IDAT", zlib.compress(b""))
            + Shared.chunk(b"IEND", b"")
        )
        passed += must_fail(lambda: decode_png(oversized, "oversized"), "oversized")
        missing_srgb = root / "missing-srgb.png"
        missing_srgb.write_bytes(encode_png(width, height, bytes(source), explicit_srgb=False))
        passed += must_fail(
            lambda: decode_png(missing_srgb, "missing sRGB", require_explicit_srgb=True),
            "missing sRGB",
        )
        output_dir = root / "outputs"
        output_dir.mkdir()
        for name in EXPECTED_NAMES:
            (output_dir / name).write_bytes(b"placeholder")
        if set(require_output_inventory(output_dir)) != set(EXPECTED_NAMES):
            raise AssertionError("valid inventory rejected")
        passed += 1
        (output_dir / "stale.png").write_bytes(b"stale")
        passed += must_fail(lambda: require_output_inventory(output_dir), "stale inventory")
        renderer = root / "renderer.swift"
        renderer.write_text(
            "import BeautySDK\n"
            + "\n".join(f'id: "case_{index}"' for index in range(72))
            + f'\nid: "{BASELINE}"\nid: "{ACTIVE}"\n'
            + "BeautyParameters(scleraRednessReduction: 1)\n"
            + "--no-watermark\nengine.processResult(\n",
            encoding="utf-8",
        )
        discover_case_ids(renderer)
        passed += 1
        original = renderer.read_text(encoding="utf-8")
        renderer.write_text(original + "\n@_spi(Testing)", encoding="utf-8")
        passed += must_fail(lambda: discover_case_ids(renderer), "Testing bypass")
        renderer.write_text(original.replace("scleraRednessReduction: 1", "scleraRednessReduction: 0.5"), encoding="utf-8")
        passed += must_fail(lambda: discover_case_ids(renderer), "wrong scalar")
        renderer.write_text(original.replace('id: "case_0"\n', ""), encoding="utf-8")
        passed += must_fail(lambda: discover_case_ids(renderer), "wrong count")
    print(json.dumps({"status": "pass", "self_tests": passed}, separators=(",", ":")))
    return passed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--output", type=Path)
    parser.add_argument("--bundle", type=Path)
    parser.add_argument("--renderer-source", type=Path)
    args = parser.parse_args()
    try:
        if args.self_test:
            run_self_test()
        elif args.output and args.bundle and args.renderer_source:
            print(json.dumps(verify_live(args.output, args.bundle, args.renderer_source), separators=(",", ":")))
        else:
            raise OutputError("exact live arguments required")
        return 0
    except (OutputError, AssertionError, RuntimeError):
        print("phase64_sclera_output_failed", file=os.sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
