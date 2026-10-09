#!/usr/bin/env python3
"""Shared current dependency boundary for retained SDK/backend gates."""
from pathlib import Path
import re
import sys

APPROVED = {
    ("MediaPipeTasksCommonBinary", "MediaPipeTasksCommon", "d2194b929b91f0c866b2f8d65003e08c474f6c85e8ca7293511e9ff4a780aa68"),
    ("MediaPipeTaskGraphsBinary", "MediaPipeTaskGraphs", "6e59def0a86dcf8b357d6dc4220c8f45a3704449e7c7734677f2db50671c7def"),
    ("MediaPipeTasksVision", "MediaPipeTasksVision", "d66d9929a28febdd52aba49b3336e1550e4526ab0b772c49321db05af5c7614e"),
}
BINARY = re.compile(
    r'\.binaryTarget\(\s*name:\s*"([^"]+)",\s*'
    r'url:\s*"https://dl\.google\.com/cpdc/20261005-190020/([^"/]+)-1\.1\.0\.xcframework\.zip",\s*'
    r'checksum:\s*"([a-f0-9]{64})"\s*\)', re.MULTILINE
)


def validate(package: str) -> None:
    matches = list(BINARY.finditer(package))
    if len(matches) != 3 or {match.groups() for match in matches} != APPROVED:
        raise ValueError("MediaPipe binary identity/checksum inventory changed")
    owner = re.search(r'\.target\(\s*name:\s*"BeautyDetection",\s*dependencies:\s*\[(.*?)\],\s*resources:',
                      package, re.DOTALL)
    if owner is None:
        raise ValueError("MediaPipe dependency owner is missing")
    for name, _, _ in APPROVED:
        dependency = re.compile(r'\.target\(name:\s*"' + name
            + r'",\s*condition:\s*\.when\(platforms:\s*\[\.iOS\]\)\)')
        if len(dependency.findall(package)) != 1 or len(dependency.findall(owner.group(1))) != 1:
            raise ValueError("MediaPipe dependency is not uniquely Detection-owned and iOS-only")
        if len(re.findall(r'"' + name + r'"', package)) != 2:
            raise ValueError("additional MediaPipe dependency use")
    remaining = BINARY.sub("", package)
    if re.search(r'\.package\s*\(|\.binaryTarget\s*\(|https?://', remaining):
        raise ValueError("unapproved SDK dependency")


def self_test(package: str) -> int:
    validate(package)
    checksum = next(iter(APPROVED))[2]
    mutations = [
        package.replace(checksum, "0" * 64, 1),
        package.replace("https://dl.google.com/cpdc/", "https://example.invalid/", 1),
        package.replace("20261005-190020", "20261006-190020", 1),
        package.replace("-1.1.0.xcframework.zip", "-1.2.0.xcframework.zip", 1),
        package.replace('name: "MediaPipeTasksCommonBinary", condition: .when(platforms: [.iOS])',
                        'name: "MediaPipeTasksCommonBinary", condition: .when(platforms: [.macOS])', 1),
        package.replace('name: "MediaPipeTasksCommonBinary", condition: .when(platforms: [.iOS])',
                        'name: "MediaPipeTasksCommonBinary"', 1),
        package.replace('name: "BeautyDetection",', 'name: "OtherOwner",', 1),
        package + '\nlet extra = "https://example.invalid/extra.zip"\n',
        package + '\nlet extra = .package(path: "../unapproved")\n',
        package + '\nlet extra = .binaryTarget(name: "Other", path: "Other.xcframework")\n',
        package.replace('"BeautyCore",\n', '"BeautyCore", "MediaPipeTasksCommonBinary",\n', 1),
    ]
    for mutation in mutations:
        try:
            validate(mutation)
        except ValueError:
            continue
        raise ValueError("dependency mutation unexpectedly admitted")
    return len(mutations)


if __name__ == "__main__":
    package = (Path(__file__).resolve().parents[1] / "BeautySDK/Package.swift").read_text()
    try:
        if sys.argv[1:] == ["--self-test"]:
            print(f"sdk_dependency_self_test_passed mutations={self_test(package)}")
        elif not sys.argv[1:]:
            validate(package)
            print("sdk_dependency_boundary_passed")
        else:
            raise ValueError("invalid arguments")
    except ValueError as error:
        raise SystemExit(str(error))
