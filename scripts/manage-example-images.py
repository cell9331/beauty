#!/usr/bin/env python3
"""Bound local example media; remove known caches or create compressed previews."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import stat
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
MIB = 1024 * 1024
MAX_TOTAL_BYTES = 128 * MIB
MAX_IMAGES = 160
MAX_IMAGE_BYTES = 16 * MIB
MAX_INPUT_IMAGES = 16
MAX_INPUT_BYTES = 32 * MIB
MAX_PREVIEWS = 32
MAX_PREVIEW_BYTES = 512 * 1024
MEDIA = {'.png', '.jpg', '.jpeg', '.webp', '.gif', '.heic', '.heif', '.tif', '.tiff', '.bmp'}
CACHES = (
    'output', 'gallery', '.gallery-staging', '.gallery-quarantine',
    'parked-generated', '.output-pre-phase51',
    'local-retouch-review/bundle', 'local-retouch-review/candidates',
    'local-retouch-review/face01-diversity',
    'local-retouch-review/full-sclera-remediation-20260811',
    'local-retouch-review/phase61-teeth-output', 'local-retouch-review/phase64-sclera-output',
    'local-retouch-review/sclera-visible-remediation-20260811',
    'local-retouch-review/v1.15-sclera-rerun-20260811',
    'local-retouch-review/evidence-pair-current/qa',
    'local-retouch-review/evidence-pair-current/work-positive',
    'local-retouch-review/evidence-pair-current/work-negative',
)
BUNDLES = ('teeth-evidence-20260805', 'evidence-pair-current')


class StorageError(Exception):
    pass


def require(condition, reason):
    if not condition:
        raise StorageError(reason)


def inventory(root):
    """Refuse links, special files and mount traversal before any mutation."""
    root = Path(root)
    for ancestor in (root, *root.parents):
        require(not ancestor.is_symlink(), 'unsafe_path')
    require(root.is_dir(), 'missing_directory')
    device = root.stat().st_dev
    files = {}

    def visit(directory):
        for path in directory.iterdir():
            info = path.lstat()
            require(not stat.S_ISLNK(info.st_mode), 'unsafe_path')
            require(info.st_dev == device and not path.is_mount(), 'mount_boundary')
            if stat.S_ISDIR(info.st_mode):
                visit(path)
            else:
                require(stat.S_ISREG(info.st_mode), 'unsupported_file')
                files[path.relative_to(root)] = info
    visit(root)
    return files


def check(root):
    files = inventory(root)
    images = {p: s for p, s in files.items() if p.suffix.lower() in MEDIA}
    inputs = {p: s for p, s in images.items() if p.parts[0] == 'input'}
    previews = {p: s for p, s in files.items() if p.parts[0] == 'previews'}
    total = sum(s.st_size for s in files.values())
    require(total <= MAX_TOTAL_BYTES, 'total_byte_limit')
    require(len(images) <= MAX_IMAGES, 'image_count_limit')
    require(all(s.st_size <= MAX_IMAGE_BYTES for s in images.values()), 'image_byte_limit')
    require(len(inputs) <= MAX_INPUT_IMAGES, 'input_count_limit')
    require(sum(s.st_size for s in inputs.values()) <= MAX_INPUT_BYTES, 'input_byte_limit')
    require(len(previews) <= MAX_PREVIEWS, 'preview_count_limit')
    require(all(p.suffix.lower() == '.jpg' and s.st_size <= MAX_PREVIEW_BYTES
                for p, s in previews.items()), 'preview_format_or_byte_limit')
    for path in previews:
        width, height = jpeg_dimensions((Path(root) / path).read_bytes())
        require(max(width, height) <= 1600, 'preview_dimension_limit')
    return {'status': 'passed', 'total_bytes': total, 'images': len(images),
            'input_images': len(inputs), 'previews': len(previews)}


def jpeg_dimensions(raw):
    require(raw[:2] == b'\xff\xd8', 'preview_format_or_byte_limit')
    offset = 2
    while offset < len(raw):
        require(raw[offset] == 255, 'preview_format_or_byte_limit')
        while offset < len(raw) and raw[offset] == 255:
            offset += 1
        require(offset < len(raw), 'preview_format_or_byte_limit')
        marker = raw[offset]
        offset += 1
        if marker in {0xd8, 0x01, *range(0xd0, 0xd8)}:
            continue
        require(marker not in {0xd9, 0xda} and offset + 2 <= len(raw), 'preview_format_or_byte_limit')
        length = int.from_bytes(raw[offset:offset+2], 'big')
        require(length >= 2 and offset + length <= len(raw), 'preview_format_or_byte_limit')
        if marker in {0xc0, 0xc1, 0xc2}:
            require(length >= 8, 'preview_format_or_byte_limit')
            height, width = struct.unpack('>HH', raw[offset+3:offset+7])
            require(width > 0 and height > 0, 'preview_format_or_byte_limit')
            return width, height
        offset += length
    raise StorageError('preview_format_or_byte_limit')


def protected_assets(root):
    protected = set()
    for name in BUNDLES:
        manifest = root / 'local-retouch-review' / name / 'manifest.json'
        if not manifest.exists():
            continue
        require(manifest.stat().st_size <= MIB, 'manifest_byte_limit')
        try:
            payload = json.loads(manifest.read_text())
            require(isinstance(payload, dict) and isinstance(payload.get('fixtures'), list), 'manifest_invalid')
            for row in payload['fixtures']:
                require(isinstance(row, dict) and isinstance(row.get('assets'), dict), 'manifest_invalid')
                for locator in row['assets'].values():
                    require(isinstance(locator, str) and bool(locator), 'manifest_path_invalid')
                    path = Path(locator)
                    require(not path.is_absolute() and '..' not in path.parts, 'manifest_path_invalid')
                    asset = manifest.parent / path
                    require(asset.is_file(), 'manifest_asset_missing')
                    protected.add(asset.relative_to(root))
        except (ValueError, KeyError, TypeError):
            raise StorageError('manifest_invalid') from None
        protected.add(manifest.relative_to(root))
    return protected


def clean(root, repo):
    root, repo = Path(root), Path(repo)
    files = inventory(root)
    protected = protected_assets(root)
    targets = [root / name for name in CACHES if (root / name).exists()]
    candidates = {p: s for p, s in files.items()
                  if any((root / p).is_relative_to(target) for target in targets)}
    require(not protected.intersection(candidates), 'referenced_asset_in_cache')
    tracked = subprocess.run(['git', '-C', str(repo), 'ls-files', '-z', '--', str(root)],
                             capture_output=True, check=True).stdout
    require(all(not (repo / os.fsdecode(p)).is_relative_to(target)
                for p in tracked.split(b'\0') if p for target in targets), 'tracked_cache')
    # Inventory the complete tree before deleting the first target. This is an
    # owner-local operation, not an adversarial concurrent-filesystem sandbox.
    for target in targets:
        require(target.is_dir(), 'cache_not_directory')
    for target in targets:
        shutil.rmtree(target)
    (root / 'output').mkdir(exist_ok=True)
    return {'status': 'cleaned', 'removed_files': len(candidates),
            'removed_bytes': sum(s.st_size for s in candidates.values())}


def preview(root, source, name):
    require(re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_-]{0,63}', name) is not None, 'preview_name_invalid')
    root = Path(root)
    before = check(root)
    source = Path(os.path.abspath(source))
    for ancestor in (source, *source.parents):
        require(not ancestor.is_symlink(), 'unsafe_path')
    require(source.is_file() and source.suffix.lower() in MEDIA, 'preview_source_invalid')
    snapshot = source.stat()
    require(0 < snapshot.st_size <= MAX_IMAGE_BYTES, 'image_byte_limit')
    destination = root / 'previews' / f'{name}.jpg'
    require(not destination.exists(), 'preview_exists')
    require(before['previews'] < MAX_PREVIEWS and before['images'] < MAX_IMAGES, 'preview_count_limit')
    with tempfile.TemporaryDirectory(prefix='beauty-preview-') as temporary:
        work = Path(temporary)
        # Work from a bounded private copy; never rewrite a source fixture.
        with source.open('rb') as stream:
            raw = stream.read(MAX_IMAGE_BYTES + 1)
        after = source.stat()
        require(len(raw) == snapshot.st_size and
                (snapshot.st_dev, snapshot.st_ino, snapshot.st_size, snapshot.st_mtime_ns, snapshot.st_ctime_ns) ==
                (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns, after.st_ctime_ns), 'source_changed')
        staged = work / ('source' + source.suffix.lower())
        staged.write_bytes(raw)
        helper = work / 'preview'
        try:
            subprocess.run(['swiftc', '-O', '-module-cache-path', str(work / 'modules'),
                            str(ROOT / 'scripts/example-image-preview.swift'),
                            '-o', str(helper)], check=True, timeout=120,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            output = work / 'preview.jpg'
            subprocess.run([str(helper), str(staged), str(output)], check=True, timeout=30,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        except (subprocess.SubprocessError, OSError):
            raise StorageError('preview_encoding_failed') from None
        encoded = output.read_bytes()
        require(len(encoded) <= MAX_PREVIEW_BYTES, 'preview_format_or_byte_limit')
        require(before['total_bytes'] + len(encoded) <= MAX_TOTAL_BYTES, 'total_byte_limit')
        destination.parent.mkdir(exist_ok=True)
        with destination.open('xb') as stream:
            stream.write(encoded)
        try:
            result = check(root)
        except (StorageError, OSError):
            destination.unlink()
            raise
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('check', help='Read-only check; fail when a storage limit is exceeded.')
    commands.add_parser('clean', help='Delete known regenerable caches; preserve required fixtures.')
    add = commands.add_parser('preview', help='Create a metadata-stripped JPEG, long edge <=1600 px.')
    add.add_argument('source', type=Path)
    add.add_argument('--name', required=True, help='Opaque preview ID; existing IDs are never overwritten.')
    args = parser.parse_args()
    try:
        root = ROOT / 'example-images'
        if args.command == 'clean':
            result = clean(root, ROOT)
        elif args.command == 'preview':
            result = preview(root, args.source, args.name)
        else:
            result = check(root)
    except (StorageError, OSError, subprocess.SubprocessError) as error:
        reason = str(error) if isinstance(error, StorageError) else 'storage_operation_failed'
        print(json.dumps({'status': 'failed', 'reason': reason}))
        return 1
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
