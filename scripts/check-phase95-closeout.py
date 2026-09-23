#!/usr/bin/env python3
"""Phase 95 CLI: execution-backed verification, never predeclared test credit."""
from __future__ import annotations
import argparse
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PHASE = ROOT / ".planning/phases/95-compatibility-and-sdk-only-closeout"

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("self-test", "review-inputs", "full-closeout", "finalize", "verify-complete", "closeout"))
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--review")
    parser.add_argument("--emit")
    parser.add_argument("--binding")
    parser.add_argument("--batch")
    args = parser.parse_args()
    if args.batch is not None or (args.self_test and args.command not in {"self-test", "closeout"}):
        print("unsupported_option_combination", file=sys.stderr)
        return 2
    if args.command != "full-closeout" and any((args.review, args.emit, args.binding)):
        print("unsupported_evidence_options", file=sys.stderr)
        return 2
    if args.command == "closeout" and args.self_test:
        return subprocess.run(["bash", str(ROOT / "scripts/run-clean-65-portrait.sh"),
                               "--self-test"], cwd=ROOT, timeout=30).returncode
    if args.command not in {"self-test", "review-inputs", "full-closeout", "finalize", "verify-complete"}:
        print("legacy_nonexecuting_or_unreviewed_lane_disabled_use_full_closeout", file=sys.stderr)
        return 1
    for supplied, expected in (
        (args.review, "95-INDEPENDENT-REPAIR-REVIEW.json"),
        (args.emit, "95-CLOSEOUT-CHECKS.json"),
        (args.binding, "95-CLOSEOUT-BINDING.json"),
    ):
        if supplied and Path(supplied).absolute() != PHASE / expected:
            print("unsupported_evidence_destination", file=sys.stderr)
            return 1
    command = ("self-test" if args.command == "self-test" or args.self_test
               else "review-inputs" if args.command == "review-inputs"
               else args.command if args.command in {"finalize", "verify-complete"} else "run")
    # The helper owns per-child deadlines, bounded capture and process groups.
    return subprocess.run([sys.executable, str(ROOT / "scripts/phase95-genuine-gate.py"),
                           command], cwd=ROOT).returncode

if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, subprocess.SubprocessError):
        print("phase95_cli_failed", file=sys.stderr)
        raise SystemExit(1)
