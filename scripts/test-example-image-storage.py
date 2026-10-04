#!/usr/bin/env python3
"""Regression checks for destructive cache cleanup and storage admission."""
import importlib.util
import json
from pathlib import Path
import struct
import subprocess
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('storage', Path(__file__).with_name('manage-example-images.py'))
storage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(storage)


class StorageTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='beauty-storage-test-')
        self.addCleanup(self.temporary.cleanup)
        self.repo = Path(self.temporary.name).resolve()
        self.root = self.repo / 'example-images'
        self.root.mkdir()
        subprocess.run(['git', 'init', '-q', str(self.repo)], check=True, capture_output=True)

    def write(self, path, data=b'fixture'):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        return target

    def reject(self, reason, function, *args):
        with self.assertRaisesRegex(storage.StorageError, '^' + reason + '$'):
            function(*args)

    def test_small_inventory_passes(self):
        self.write('input/f.png')
        self.assertEqual(storage.check(self.root)['input_images'], 1)

    def test_total_byte_limit_includes_non_media(self):
        self.write('record.json', b'12345')
        with patch.object(storage, 'MAX_TOTAL_BYTES', 4):
            self.reject('total_byte_limit', storage.check, self.root)

    def test_image_count_limit(self):
        for i in range(3): self.write(f'output/{i}.png')
        with patch.object(storage, 'MAX_IMAGES', 2):
            self.reject('image_count_limit', storage.check, self.root)

    def test_image_byte_limit(self):
        self.write('input/f.png', b'12345')
        with patch.object(storage, 'MAX_IMAGE_BYTES', 4):
            self.reject('image_byte_limit', storage.check, self.root)

    def test_input_count_limit(self):
        for i in range(3): self.write(f'input/{i}.png')
        with patch.object(storage, 'MAX_INPUT_IMAGES', 2):
            self.reject('input_count_limit', storage.check, self.root)

    def test_input_byte_limit(self):
        self.write('input/f.png', b'12345')
        with patch.object(storage, 'MAX_INPUT_BYTES', 4):
            self.reject('input_byte_limit', storage.check, self.root)

    def test_preview_count_and_size_limits(self):
        self.write('previews/one.jpg', b'12345')
        with patch.object(storage, 'MAX_PREVIEWS', 0):
            self.reject('preview_count_limit', storage.check, self.root)
        with patch.object(storage, 'MAX_PREVIEW_BYTES', 4):
            self.reject('preview_format_or_byte_limit', storage.check, self.root)

    def test_preview_format_and_dimensions(self):
        self.write('previews/one.jpg', b'not jpeg')
        self.reject('preview_format_or_byte_limit', storage.check, self.root)
        self.write('previews/one.jpg', b'\xff\xd8\xff\xc0' + struct.pack('>HBHHB', 8, 8, 100, 1601, 1))
        self.reject('preview_dimension_limit', storage.check, self.root)

    def test_clean_only_removes_known_cache(self):
        source = self.write('input/f.png')
        unknown = self.write('unclassified/keep.png')
        parked = self.write('parked-portraits/e1.png')
        cache = self.write('output/old.png')
        result = storage.clean(self.root, self.repo)
        self.assertEqual(result['removed_files'], 1)
        self.assertTrue(source.exists() and unknown.exists() and parked.exists())
        self.assertFalse(cache.exists())
        self.assertEqual(storage.clean(self.root, self.repo)['removed_files'], 0)

    def test_clean_rejects_links_before_any_deletion(self):
        cache = self.write('output/keep.png')
        outside = self.repo / 'sentinel'
        outside.write_bytes(b'keep')
        (self.root / 'parked-generated').symlink_to(outside)
        self.reject('unsafe_path', storage.clean, self.root, self.repo)
        self.assertTrue(cache.exists())
        self.assertEqual(outside.read_bytes(), b'keep')

    def test_clean_rejects_tracked_cache(self):
        cache = self.write('output/tracked.txt')
        subprocess.run(['git', '-C', str(self.repo), 'add', str(cache)], check=True, capture_output=True)
        self.reject('tracked_cache', storage.clean, self.root, self.repo)
        self.assertTrue(cache.exists())

    def test_clean_preserves_manifest_assets_and_rejects_conflict(self):
        bundle = 'local-retouch-review/evidence-pair-current/'
        asset = self.write(bundle + 'fixture/original.png')
        manifest = self.write(bundle + 'manifest.json', json.dumps({
            'fixtures': [{'assets': {'original': 'fixture/original.png'}}]
        }).encode())
        self.write(bundle + 'work-positive/old.png')
        storage.clean(self.root, self.repo)
        self.assertTrue(asset.exists() and manifest.exists())
        self.write(bundle + 'work-positive/original.png')
        manifest.write_text(json.dumps({'fixtures': [{'assets': {'original': 'work-positive/original.png'}}]}))
        cache = self.write('output/keep.png')
        self.reject('referenced_asset_in_cache', storage.clean, self.root, self.repo)
        self.assertTrue(cache.exists())

    def test_clean_rejects_missing_manifest_asset(self):
        self.write('local-retouch-review/evidence-pair-current/manifest.json', json.dumps({
            'fixtures': [{'assets': {'original': 'missing.png'}}]
        }).encode())
        cache = self.write('output/keep.png')
        self.reject('manifest_asset_missing', storage.clean, self.root, self.repo)
        self.assertTrue(cache.exists())

    def test_preview_rejects_invalid_name_before_work(self):
        self.reject('preview_name_invalid', storage.preview, self.root, self.root / 'f.png', '../escape')

    def test_check_rejects_directory_symlink(self):
        (self.root / 'input').symlink_to(self.repo)
        self.reject('unsafe_path', storage.check, self.root)


if __name__ == '__main__':
    unittest.main()
