#!/usr/bin/env python3
"""Fail-closed Phase 41 public-contract and observed-eye boundary gate."""

from __future__ import annotations

import argparse
import dataclasses
import subprocess
import sys
from pathlib import Path
from typing import Callable, Sequence


@dataclasses.dataclass(frozen=True)
class Result:
    name: str
    ok: bool
    detail: str


@dataclasses.dataclass(frozen=True)
class SearchResult:
    state: str
    lines: tuple[str, ...]
    detail: str


Runner = Callable[[Sequence[str], Path], subprocess.CompletedProcess[str]]


def default_runner(command: Sequence[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(list(command), cwd=cwd, text=True, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, check=False)


def run_search(command: Sequence[str], cwd: Path,
               runner: Runner = default_runner) -> SearchResult:
    """Classify rg status 0/1/>1 without ever turning tool errors into clean scans."""
    raise NotImplementedError


def self_test() -> list[Result]:
    return [Result("self-test implementation", False, "not implemented")]


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args(argv)
    results = self_test() if args.self_test else [Result("live gate", False, "not implemented")]
    for result in results:
        print(f"{'PASS' if result.ok else 'FAIL'}: {result.name}: {result.detail}")
    return 0 if results and all(result.ok for result in results) else 1


if __name__ == "__main__":
    sys.exit(main())
