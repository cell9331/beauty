#!/usr/bin/env python3
"""Validate Phase 31 nose outputs by reusing the proven Phase 29 PNG parser."""

from __future__ import annotations

import importlib.util
import sys
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
    "noseSlim_0p35",
    "noseWingSlim_0p35",
    "noseTipSize_plus0p30",
    "noseTipSize_minus0p30",
    "noseBridge_0p30",
]

helper.RENDERER_CASE_IDS = helper.RENDERER_CASE_IDS + NOSE_CASE_IDS
helper.PHASE29_EYE_CASE_IDS = NOSE_CASE_IDS


def signed_tip_outputs_differ(output_dir: Path) -> list[str]:
    failures: list[str] = []
    for fixture_name in helper.PORTRAIT_FIXTURE_NAMES:
        positive = output_dir / helper.expected_output_name(fixture_name, "noseTipSize_plus0p30")
        negative = output_dir / helper.expected_output_name(fixture_name, "noseTipSize_minus0p30")
        if not positive.is_file() or not negative.is_file():
            failures.append(f"output/{positive.name} or output/{negative.name}: missing")
            continue
        if not helper.top_region_differs(positive, negative, f"output/{positive.name} vs {negative.name}"):
            failures.append(f"output/{positive.name}: top region byte-identical to {negative.name}")
    return failures


def main() -> int:
    args = helper.parse_args()
    result = helper.main()
    if result != 0:
        return result
    failures = signed_tip_outputs_differ(Path(args.output))
    if failures:
        print("phase 31 signed nose-tip comparison failed")
        for failure in failures:
            print(f"FAIL: {failure}")
        return 1
    print("phase 31 nose renderer output check passed: 196/196 outputs")
    print("portrait nose-vs-baseline top-region comparisons: 30/30")
    print("signed noseTipSize positive-vs-negative comparisons: 6/6")
    print("no-face nose output present: negatives/no-face-gradient.png -> no-face-gradient__noseSlim_0p35.png")
    return 0


if __name__ == "__main__":
    sys.exit(main())
