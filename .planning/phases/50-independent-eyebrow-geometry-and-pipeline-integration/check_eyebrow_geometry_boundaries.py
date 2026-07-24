#!/usr/bin/env python3
"""Fail-closed Phase 50 eyebrow geometry boundary checker."""
from __future__ import annotations

import argparse
import hashlib
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

PACKAGE_HASH = "6f03b078816ad1f7a426e3f70d4f57503f3152e9"
PHASE49_HASH = "7a8716c810d1b81119d14338cb9ce037c8ebb40b"
PROVIDER = "BeautySDK/Sources/BeautyEffects/Warp/EyebrowWarpProvider.swift"
PACKAGE = "BeautySDK/Package.swift"
PHASE49 = ".planning/phases/49-public-contract-and-observed-eyebrow-support/check_eyebrow_support_boundaries.py"
FIELDS = ("eyebrowYPosition", "eyebrowThickness", "eyebrowLength", "eyebrowSpacing",
          "eyebrowHeadSpacing", "eyebrowTilt", "eyebrowPeakDefinition")


class BoundaryCheckFailure(RuntimeError):
    pass


def repo_root(start: Path) -> Path:
    try:
        here = start.resolve(strict=True)
    except OSError as exc:
        raise BoundaryCheckFailure("unresolvable start path") from exc
    for candidate in (here, *here.parents):
        if (candidate / ".git").exists() and (candidate / PACKAGE).is_file():
            return candidate
    raise BoundaryCheckFailure("repository root not found")


def checked_path(root: Path, relative: str, *, required: bool = True) -> Path:
    rel = Path(relative)
    if rel.is_absolute() or ".." in rel.parts:
        raise BoundaryCheckFailure("repository path escape")
    candidate = root / rel
    if required and not candidate.is_file():
        raise BoundaryCheckFailure(f"missing required path: {relative}")
    resolved = candidate.resolve(strict=required)
    base = root.resolve(strict=True)
    if resolved != base and base not in resolved.parents:
        raise BoundaryCheckFailure("repository path escape")
    return candidate


def git_hash(root: Path, relative: str) -> str:
    path = checked_path(root, relative)
    proc = subprocess.run(["git", "hash-object", str(path)], cwd=root, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if proc.returncode != 0 or not proc.stdout.strip():
        raise BoundaryCheckFailure("git hash failure")
    return proc.stdout.strip()


def checked_rg(root: Path, pattern: str, *scopes: str) -> list[str]:
    if not shutil.which("rg"):
        raise BoundaryCheckFailure("rg unavailable")
    proc = subprocess.run(["rg", "-n", "--no-heading", pattern, *scopes], cwd=root,
                          text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if proc.returncode == 1:
        return []
    if proc.returncode != 0:
        raise BoundaryCheckFailure("unexpected rg status")
    return [line for line in proc.stdout.splitlines() if line]


def pinned_contracts(root: Path) -> None:
    if git_hash(root, PACKAGE) != PACKAGE_HASH or git_hash(root, PHASE49) != PHASE49_HASH:
        raise BoundaryCheckFailure("historical package/privacy contract drift")


def scope_fences(root: Path) -> None:
    forbidden = checked_rg(
        root,
        r"(?i)(Eyebrow.*(Codable|cache|persist|network|URLSession)|final eyebrow cap|v1\.(14|15|16)|eyebrow.*(gallery|renderer))",
        "BeautySDK/Sources", "BeautyDemo", ".planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration",
    )
    unclassified = [line for line in forbidden if not line.startswith(str(Path(".planning/phases/50-independent-eyebrow-geometry-and-pipeline-integration")))]
    if unclassified:
        raise BoundaryCheckFailure("unclassified forbidden scope match")


def pre_implementation_checks(root: Path) -> None:
    pinned_contracts(root)
    scope_fences(root)
    if checked_path(root, PROVIDER, required=False).exists():
        raise BoundaryCheckFailure("production eyebrow provider already exists")


def live_checks(root: Path) -> None:
    pinned_contracts(root)
    scope_fences(root)
    source = checked_path(root, PROVIDER).read_text()
    for field in FIELDS:
        if field not in source:
            raise BoundaryCheckFailure(f"missing named emission: {field}")
    resolver = checked_path(root, "BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift").read_text()
    pipeline = checked_path(root, "BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift").read_text()
    if resolver.count("0..<44") != 1:
        raise BoundaryCheckFailure("exact retained loop missing")
    ordered = ["FaceShapeWarpProvider", "ChinWarpProvider", "EyeWarpProvider", "EyebrowWarpProvider", "NoseWarpProvider", "MouthWarpProvider"]
    positions = [pipeline.find(name) for name in ordered]
    if any(pos < 0 for pos in positions) or positions != sorted(positions) or pipeline.count("EyebrowWarpProvider") != 1:
        raise BoundaryCheckFailure("unified provider order/dispatch invalid")
    if "eyebrow_inputs_missing" not in resolver or "skippedEyebrowDomains" not in resolver:
        raise BoundaryCheckFailure("aggregate eyebrow routing markers missing")


def self_test() -> None:
    root = repo_root(Path.cwd())
    pinned_contracts(root)
    scope_fences(root)
    cases = 0
    with tempfile.TemporaryDirectory() as temp:
        corpus = Path(temp) / "repo"
        shutil.copytree(root, corpus, symlinks=True, ignore=shutil.ignore_patterns(".git", ".build"))
        (corpus / ".git").mkdir()
        provider = corpus / PROVIDER
        if provider.exists():
            provider.unlink()
        pre_implementation_checks(corpus)
        # Each live requirement is absent in the isolated pre-production corpus, so live must fail.
        try:
            live_checks(corpus)
        except BoundaryCheckFailure:
            cases += 1
        else:
            raise BoundaryCheckFailure("live mode unexpectedly passed")
        for relative in (PACKAGE, PHASE49):
            target = corpus / relative
            original = target.read_text()
            target.write_text(original + "\n# mutation\n")
            try:
                pre_implementation_checks(corpus)
            except BoundaryCheckFailure:
                cases += 1
            else:
                raise BoundaryCheckFailure("hash mutation escaped")
            target.write_text(original)
        try:
            checked_path(corpus, "../escape")
        except BoundaryCheckFailure:
            cases += 1
        else:
            raise BoundaryCheckFailure("path escape accepted")
    if cases != 4:
        raise BoundaryCheckFailure("self-test accounting mismatch")
    print("Phase 50 eyebrow boundary self-test: 4/4 checks passed")


def main() -> int:
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--pre-implementation", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            self_test()
        elif args.pre_implementation:
            pre_implementation_checks(repo_root(Path.cwd()))
            print("Phase 50 pre-implementation boundaries: passed")
        else:
            live_checks(repo_root(Path.cwd()))
            print("Phase 50 live eyebrow boundaries: passed")
        return 0
    except (BoundaryCheckFailure, OSError) as exc:
        print(f"BLOCKED: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
