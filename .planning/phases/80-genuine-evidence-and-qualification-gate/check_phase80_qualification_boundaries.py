#!/usr/bin/env python3
"""Independent Phase-80 qualification boundary checker.

RED gate: the executable surface and fail-closed modes are fixed here before
the implementation.  The self-test must fail until the independent contract,
privacy, scope, decision, and mutation guards are implemented.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any


PHASE = 80
NON_PROMOTION_DECISION = "qualification-not-passed"


class GateError(Exception):
    """A normalized, privacy-safe gate failure."""


def fail(reason: str) -> None:
    raise GateError(reason)


def self_test(_root: Path) -> dict[str, Any]:
    fail("qualification.not-implemented")


def preflight_result(_root: Path) -> dict[str, Any]:
    fail("qualification.not-implemented")


def live_result(_root: Path) -> dict[str, Any]:
    fail("qualification.not-implemented")


def main() -> int:
    parser = argparse.ArgumentParser(add_help=False)
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--preflight", action="store_true")
    modes.add_argument("--live", action="store_true")
    parser.add_argument("--repo-root", required=True)
    args = parser.parse_args()
    root = Path(args.repo_root)
    try:
        if args.self_test:
            result = self_test(root)
        elif args.preflight:
            result = preflight_result(root)
        else:
            result = live_result(root)
    except GateError as error:
        result = {
            "mode": "self-test" if args.self_test else "preflight" if args.preflight else "live",
            "phase": PHASE,
            "reason_count": 1,
            "reasons": [str(error)],
            "status": "fail",
        }
        print(json.dumps(result, sort_keys=True, separators=(",", ":")))
        return 1
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
