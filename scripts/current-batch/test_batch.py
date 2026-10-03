#!/usr/bin/env python3
"""Contract and adversarial checks for the current batch tool."""
import copy
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch
import run as batch

class BatchTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.ids = batch.inventory()['default_cases']
        cls.oracles = batch.default_oracles(cls.ids)

    def test_independent_inventory(self):
        self.assertEqual(len(self.ids), 98)
        self.assertEqual(len(set(self.ids)), 98)
        self.assertNotIn('upperEyelidFullnessReduction_1p00', self.ids)
        self.assertEqual(self.oracles['skinCombo_0p50'], {'kind': 'abstain'})
        self.assertEqual(sum(o['kind']=='abstain' for o in self.oracles.values()), 91)
        for oracle in self.oracles.values():
            batch.validate_oracle(oracle)

    def test_discovery_rejects_missing_duplicate_reorder_same_count_swap(self):
        good = {'schemaVersion': 'beauty.example-renderer.cases.v1', 'cases': self.ids}
        batch.check_discovery(good, self.ids)
        for ids in [self.ids[:-1], self.ids[:-1]+[self.ids[0]], list(reversed(self.ids)),
                    self.ids[:-1]+['upperEyelidFullnessReduction_1p00']]:
            with self.subTest(mutation=len(ids)), self.assertRaises(batch.Invalid):
                batch.check_discovery(dict(good, cases=ids), self.ids)

    def report(self):
        return {'schemaVersion': 'beauty.example-renderer.report.v1', 'backend': 'cpu',
                'requested': 98, 'succeeded': 98, 'failed': 0, 'skipped': 0,
                'caseIDs': self.ids, 'inputIDs': ['portraits/F01.png'],
                'outputs': [{'inputID': 'portraits/F01.png', 'caseID': id,
                             'outputID': f'F01__{id}.png', 'status': 'succeeded'} for id in self.ids]}

    def files(self):
        return [f'F01__{id}.png' for id in self.ids]+[batch.REPORT]

    def test_renderer_report_actual_files_and_counts(self):
        good = self.report()
        batch.check_report(good, self.ids, 'F01', self.files())
        mutations = []
        for key, value in [('backend', 'metal'), ('failed', 1), ('skipped', 1), ('succeeded', 97),
                           ('requested', True), ('inputIDs', ['portraits/F02.png']), ('caseIDs', self.ids[:-1])]:
            bad = copy.deepcopy(good);bad[key] = value;mutations.append(bad)
        bad = copy.deepcopy(good);bad['outputs'][1] = bad['outputs'][0];mutations.append(bad)
        bad = copy.deepcopy(good);bad['outputs'].pop();mutations.append(bad)
        for key, value in [('outputID', '../outside.png'), ('failureCode', 'render_failed'), ('status', 'skipped')]:
            bad = copy.deepcopy(good);bad['outputs'][0][key] = value;mutations.append(bad)
        for i, bad in enumerate(mutations):
            with self.subTest(mutation=i), self.assertRaises(batch.Invalid):
                batch.check_report(bad, self.ids, 'F01', self.files())
        for files in [self.files()[:-2]+[batch.REPORT], self.files()+['stale.png']]:
            with self.assertRaises(batch.Invalid):
                batch.check_report(good, self.ids, 'F01', files)

    def test_json_duplicate_and_nonfinite_rejected(self):
        for text in ['{"k":1,"k":2}', '{"k":NaN}', '{"nested":{"x":1,"x":2}}', 'broken']:
            with self.assertRaises(batch.Invalid):
                batch.parse(text)

    def test_oracle_requires_direction_and_valid_regions(self):
        good = self.oracles['brightness_plus0p25']
        batch.validate_oracle(good)
        bads = [{'kind': 'metrics'}, {'kind': 'unknown'}, {'kind': 'exact', 'private': 'x'},
                {'kind': 'exact', 'protected': [[0, 0, 2, 1]]},
                {'kind': 'exact', 'target': [0.5, 0, 0.5, 1]},
                {'kind': 'metrics', 'checks': [{'metric': 'changed_pixels', 'minimum': 1, 'maximum': 99}]},
                {'kind': 'metrics', 'checks': [{'metric': 'luma_delta', 'minimum': 0, 'maximum': 99}]}]
        for bad in bads:
            with self.assertRaises(batch.Invalid):
                batch.validate_oracle(bad)

    def stats(self):
        return dict(srgb=True, source_opaque=True, alpha_changed=0, protected_changed=0,
                    repeat_exact=True, source_exact=True, luma_delta=0, contrast_delta=0, red_blue_delta=0)

    def test_noop_is_not_effect_pass(self):
        self.assertEqual(batch.classify(self.stats(), self.oracles['brightness_plus0p25'])[0], 'effect_failed')
        self.assertEqual(batch.classify(self.stats(), {'kind': 'exact'})[0], 'passed')
        self.assertEqual(batch.classify(self.stats(), {'kind': 'abstain'})[0], 'abstained')
        self.assertEqual(batch.classify(self.stats(), None)[0], 'unverified')

    def test_protection_metadata_repeat_override_direction(self):
        a = self.stats();a.update(luma_delta=5, source_exact=False)
        oracle = self.oracles['brightness_plus0p25']
        self.assertEqual(batch.classify(a, oracle)[0], 'passed')
        for key, value, expected in [('protected_changed', 1, 'effect_failed'), ('alpha_changed', 1, 'effect_failed'),
                                      ('repeat_exact', False, 'effect_failed'), ('srgb', False, 'execution_error'),
                                      ('source_opaque', False, 'execution_error'), ('luma_delta', -5, 'effect_failed')]:
            self.assertEqual(batch.classify(dict(a, **{key: value}), oracle)[0], expected)
        self.assertEqual(batch.classify({'error': 'pixel_input_invalid'}, oracle)[0], 'execution_error')

    def test_exit_precedence(self):
        for statuses, code in [(['passed', 'abstained'], 0), (['unverified'], 3),
                               (['unverified', 'effect_failed'], 1), (['effect_failed', 'execution_error'], 2)]:
            counts, result = batch.summarize([{'status': s} for s in statuses])
            self.assertEqual(result, code);self.assertEqual(sum(counts.values()), len(statuses))

    def test_suite_hash_missing_oracles_and_path_boundary(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            p = Path(temp);source = p/'source.png';source.write_bytes(b'local input')
            item = {'id': 'F01', 'path': 'source.png', 'sha256': batch.sha(source.read_bytes()), 'oracles': {}}
            suite = p/'suite.json'
            data = {'schema': 'beauty.current-batch.suite.v1', 'fixtures': [item]}
            suite.write_text(json.dumps(data))
            items, _ = batch.suite(suite, self.ids);self.assertEqual(len(items), 1)
            source.write_bytes(b'tampered')
            with self.assertRaisesRegex(batch.Invalid, 'fixture_digest_mismatch'):
                batch.suite(suite, self.ids)
            source.unlink();source.symlink_to(suite)
            with self.assertRaisesRegex(batch.Invalid, 'symlink_rejected'):
                batch.suite(suite, self.ids)

    def test_child_failures_bounded_and_not_promoted(self):
        status, _ = batch.child([sys.executable, '-c', 'raise SystemExit(7)'])
        self.assertEqual(status, 7)
        with self.assertRaisesRegex(batch.Invalid, 'child_timeout'):
            batch.child([sys.executable, '-c', 'import time;time.sleep(5)'], timeout=0.05)
        with self.assertRaisesRegex(batch.Invalid, 'child_output_limit'):
            batch.child([sys.executable, '-c', 'print("x"*10000)'], limit=128)

    def test_timeout_cleans_descendants_after_leader_exit(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            marker=Path(temp)/'descendant-survived'
            code='import os,sys,time; from pathlib import Path\nif os.fork(): os._exit(0)\ntime.sleep(0.5)\nPath(sys.argv[1]).write_text("leaked")\n'
            with self.assertRaisesRegex(batch.Invalid, 'child_timeout'):
                batch.child([sys.executable, '-c', code, marker], timeout=0.15)
            time.sleep(0.55)
            self.assertFalse(marker.exists(), 'descendant survived the bounded child cleanup')

    def test_bad_arguments_do_not_echo_private_paths(self):
        result = subprocess.run([sys.executable, '-B', str(batch.HERE/'run.py'), '--unknown', '/private/sentinel.png'], capture_output=True)
        self.assertEqual(result.returncode, 2)
        self.assertNotIn(b'sentinel', result.stdout+result.stderr)
        self.assertEqual(batch.parse(result.stdout)['reason'], 'arguments_invalid')

    def test_report_write_failure_is_redacted_nonzero(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            output=io.StringIO()
            with patch('sys.argv', ['run.py']), patch.object(batch.tempfile, 'mkdtemp', return_value=temp), \
                 patch.object(batch, 'execute', return_value={'exit_code': 0, 'rows': []}), \
                 patch.object(Path, 'write_text', side_effect=OSError('/private/sentinel.png')), redirect_stdout(output):
                self.assertEqual(batch.main(), 2)
            self.assertNotIn('sentinel', output.getvalue())
            self.assertEqual(batch.parse(output.getvalue())['reason'], 'report_write_failed')

    def test_zero_tests_not_relevant_preflight_is_explicit(self):
        # Check the actual executable/list path with a temporary stand-in only for inventory plumbing.
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            work=Path(temp);binary=work/'BeautyExampleRenderer';binary.write_bytes(b'local stand-in')
            responses=[(0,b''),(0,str(work).encode()),
                       (0,json.dumps({'schemaVersion':'beauty.example-renderer.cases.v1','cases':self.ids}).encode())]*1
            responses.append(responses[-1])
            with patch.object(batch,'child',side_effect=responses):
                result=batch.execute(work,preflight_only=True)
            self.assertEqual(result['status'],'preflight_only')
            self.assertFalse(result['effect_qualification']);self.assertEqual(result['rows'],[])

    def test_nonzero_renderer_cannot_use_success_artifacts(self):
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            work=Path(temp);binary=work/'BeautyExampleRenderer';binary.write_bytes(b'local stand-in')
            def fake(command, **kwargs):
                if '--show-bin-path' in command:return 0,str(work).encode()
                if '--list-cases' in command:return 0,json.dumps({'schemaVersion':'beauty.example-renderer.cases.v1','cases':self.ids}).encode()
                if 'fixture' in command:
                    Path(command[-1]).write_bytes(b'fixture');return 0,b'{}'
                if 'measure' in command:return 0,b'[{"srgb":true,"source_opaque":true}]'
                if '--output' in command:
                    dest=Path(command[command.index('--output')+1]);(dest/batch.REPORT).write_text(json.dumps(self.report()))
                    return 7,b''
                return 0,b''
            with patch.object(batch,'child',side_effect=fake):result=batch.execute(work)
            self.assertEqual(result['exit_code'],2);self.assertEqual(result['counts']['execution_error'],98)
            self.assertTrue(all(row['reason']=='renderer_execution_failed' for row in result['rows']))
            self.assertFalse(list(work.rglob(batch.REPORT)));self.assertFalse(list(work.rglob('request.json')))

class NativeTests(unittest.TestCase):
    def test_actual_file_decode_and_empty_protection_rejected(self):
        native=os.environ.get('BEAUTY_CURRENT_BATCH_PIXEL_HELPER')
        self.assertTrue(native, 'native helper is required')
        with tempfile.TemporaryDirectory(dir='/private/tmp') as temp:
            p=Path(temp);source=p/'source.png';request=p/'request.json'
            self.assertEqual(batch.child([native, 'fixture', source])[0], 0)
            base={'case_id':'F01', 'source':str(source), 'output':str(source), 'repeated':str(source),
                  'target':[0,0,1,1], 'protected':[]}
            invalid=p/'invalid.png';invalid.write_bytes(b'not a PNG')
            request.write_text(json.dumps([base, dict(base, protected=[[0,0,0.00001,0.00001]]),
                                           dict(base, output=str(invalid))]))
            status,output=batch.child([native,'measure',request]);self.assertEqual(status,0)
            rows=batch.parse(output)
            self.assertTrue(rows[0]['source_exact'] and rows[0]['repeat_exact'] and rows[0]['srgb'])
            self.assertEqual(rows[1]['error'],'pixel_input_invalid')
            self.assertEqual(rows[2]['error'],'pixel_input_invalid')

    def test_actual_pixel_controls(self):
        native = os.environ.get('BEAUTY_CURRENT_BATCH_PIXEL_HELPER')
        self.assertTrue(native, 'compile the native helper and set BEAUTY_CURRENT_BATCH_PIXEL_HELPER; no skipped gate')
        status, output = batch.child([native, 'controls'])
        self.assertEqual(status, 0)
        rows = {r['case_id']: r for r in batch.parse(output)}
        self.assertEqual(len(rows), 8)
        ids=batch.inventory()['default_cases'];oracle=batch.default_oracles(ids)
        self.assertEqual(batch.classify(rows['unchanged'], oracle['brightness_plus0p25'])[0], 'effect_failed')
        self.assertEqual(batch.classify(rows['brighter'], oracle['brightness_plus0p25'])[0], 'passed')
        self.assertEqual(batch.classify(rows['darker'], oracle['brightness_plus0p25'])[0], 'effect_failed')
        self.assertEqual(batch.classify(rows['redder'], oracle['skinRosy_0p40'])[0], 'passed')
        self.assertEqual(batch.classify(rows['contrast'], oracle['contrast_plus0p25'])[0], 'passed')
        for key in ('protected_leak','repeat_mismatch','alpha_changed'):
            self.assertEqual(batch.classify(rows[key], oracle['brightness_plus0p25'])[0], 'effect_failed')

if __name__ == '__main__':
    unittest.main()
