#!/usr/bin/env python3
"""Generated control tests for append-only follow-up receipts; no portrait run."""
from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'scripts/check-v122-mapping-followup.py'
spec = importlib.util.spec_from_file_location('v122_followup', SCRIPT)
assert spec is not None and spec.loader is not None
followup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(followup)


class AppendOnlyFollowupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='v122-followup-test-', dir='/private/tmp')
        self.addCleanup(self.temporary.cleanup)
        self.qual = Path(self.temporary.name) / 'qualification'
        self.qual.mkdir()
        self.qual_patch = patch.object(followup, 'QUAL', self.qual)
        self.qual_patch.start()
        self.addCleanup(self.qual_patch.stop)
        self.identity = {
            'schema': 'v122-mapping-followup-identity-v1',
            'input_digest': 'a' * 64,
            'phase95_input_digest': 'b' * 64,
            'contract_sha256': 'c' * 64,
            'historical_complete_sha256': followup.HISTORICAL_COMPLETE_SHA,
        }
        self.identity_patch = patch.object(followup, 'identity', return_value=self.identity)
        self.identity_patch.start()
        self.addCleanup(self.identity_patch.stop)
        review = {'schema': 'v122-mapping-followup-implementation-review-v1',
                  'status': 'pass', 'reviewer_agent_id': 'independent-reviewer-one',
                  'input_digest': self.identity['input_digest'], 'findings': []}
        (self.qual / followup.REVIEW).write_text(json.dumps(review) + '\n')
        self.old_hashes = {name: followup.evidence.sha(followup.PHASE / name)
                           for name in ('95-CLEAN-65-REPORT.json',
                                        '95-CLOSEOUT-BINDING.json',
                                        '95-CLOSEOUT-CHECKS.json',
                                        '95-COMPLETE.json')}
        self.old_checks = followup.evidence.load(followup.PHASE / '95-CLOSEOUT-CHECKS.json')
        self.old_portrait = followup.evidence.load(followup.PHASE / '95-CLEAN-65-REPORT.json')

    def checked_old_hashes(self):
        self.assertEqual(self.old_hashes, {
            name: followup.evidence.sha(followup.PHASE / name)
            for name in self.old_hashes
        })

    def fake_execute(self):
        with patch.object(followup, 'run_child', return_value=b''), \
             patch.object(followup, 'qualified_portrait', return_value=self.old_portrait), \
             patch.object(followup.evidence, 'focused_counts',
                          side_effect=lambda _data, lane: self.old_checks[lane]), \
             patch.object(followup.gate, 'counts', return_value=self.old_checks['no_skip']):
            return followup.execute()

    def test_success_is_append_only_and_requires_distinct_goal_review(self):
        first = self.fake_execute()
        second = self.fake_execute()
        self.assertNotEqual(first['attempt_id'], second['attempt_id'])
        self.assertFalse(first['phase_complete'])
        attempt = self.qual / first['attempt_id']
        self.assertEqual({p.name for p in attempt.iterdir()},
                         {followup.PORTRAIT, followup.BINDING, followup.CHECKS})
        self.checked_old_hashes()
        with self.assertRaises(followup.GateError):
            followup.finalize(first['attempt_id'])

        review_sha = followup.evidence.sha(self.qual / followup.REVIEW)
        goal = {
            'schema': 'v122-mapping-followup-goal-review-v1', 'status': 'pass',
            'reviewer_agent_id': 'independent-reviewer-two',
            'input_digest': self.identity['input_digest'],
            'checks_sha256': followup.evidence.sha(attempt / followup.CHECKS),
            'binding_sha256': followup.evidence.sha(attempt / followup.BINDING),
            'review_sha256': review_sha,
            'portrait_sha256': followup.evidence.sha(attempt / followup.PORTRAIT),
            'requirements': followup.evidence.REQUIREMENTS, 'findings': [],
        }
        followup.evidence.publish(attempt / followup.GOAL, goal)
        self.assertTrue(followup.finalize(first['attempt_id'])['phase_complete'])
        self.assertTrue(followup.verify(first['attempt_id'])['phase_complete'])
        with self.assertRaises(followup.GateError):
            followup.finalize(first['attempt_id'])
        self.checked_old_hashes()

        # A changed current identity must revoke the follow-up claim even when
        # the historical completion and all new receipts remain untouched.
        with patch.object(followup, 'identity', return_value={**self.identity,
                           'input_digest': 'd' * 64}):
            with self.assertRaises(followup.GateError):
                followup.verify(first['attempt_id'])

    def test_failed_attempt_records_only_a_stage_and_can_retry(self):
        with patch.object(followup, 'run_child', side_effect=followup.GateError('child_failed')):
            with self.assertRaises(followup.GateError):
                followup.execute()
        attempts = list(self.qual.glob('attempt-*'))
        self.assertEqual(len(attempts), 1)
        self.assertEqual({p.name for p in attempts[0].iterdir()}, {'FAILURE.json'})
        failure = followup.evidence.load(attempts[0] / 'FAILURE.json')
        self.assertEqual((failure['status'], failure['stage'], failure['reason']),
                         ('failed', 'focused', 'child_failed'))
        self.checked_old_hashes()


if __name__ == '__main__':
    unittest.main()
