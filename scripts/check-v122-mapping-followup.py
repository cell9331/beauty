#!/usr/bin/env python3
"""Append-only, current-tree Phase95 qualification after the face-mapping repair."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import importlib.util
import json
import os
from pathlib import Path
import re
import secrets
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
PHASE = ROOT / '.planning/phases/95-compatibility-and-sdk-only-closeout'
QUAL = ROOT / '.planning/qualifications/v1.22-mapping-followup'
CONTRACT = QUAL / 'CONTRACT.md'
HISTORICAL_COMPLETE_SHA = '33b49fee25b4156b8a947ac437822ac33f7e5473a61ed74b1015c393035862d4'
HISTORICAL_INPUT_DIGEST = '56d33c8d9ddfbd6899287feeac501139d6ea1bac05250ca8982fa861482ed6f0'
REVIEW = 'IMPLEMENTATION-REVIEW.json'
PORTRAIT = 'PORTRAIT.json'
BINDING = 'BINDING.json'
CHECKS = 'CHECKS.json'
GOAL = 'GOAL-REVIEW.json'
COMPLETE = 'COMPLETE.json'
ATTEMPT_PATTERN = re.compile(r'attempt-[0-9]{8}T[0-9]{6}Z-[0-9a-f]{8}\Z')


def module(name: str, relative: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative)
    assert spec is not None and spec.loader is not None
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


evidence = module('phase95_followup_evidence', 'scripts/phase95-closeout-evidence.py')
gate = module('phase95_followup_gate', 'scripts/phase95-genuine-gate.py')
GateError = evidence.GateError


def identity() -> dict:
    historical_sha = evidence.sha(PHASE / '95-COMPLETE.json')
    historical = evidence.load(PHASE / '95-COMPLETE.json')
    evidence.need(historical_sha == HISTORICAL_COMPLETE_SHA
                  and historical.get('phase_complete') is True
                  and historical.get('input_digest') == HISTORICAL_INPUT_DIGEST,
                  'historical_receipt_changed')
    historical_evidence = historical.get('evidence')
    evidence.need(type(historical_evidence) is dict and historical_evidence
                  and all(type(name) is str and '/' not in name and name.endswith('.json')
                          and evidence.is_sha(value)
                          for name, value in historical_evidence.items()),
                  'historical_receipt_invalid')
    evidence.need(all(evidence.sha(PHASE / name) == value
                      for name, value in historical_evidence.items()),
                  'historical_evidence_changed')
    base = evidence.snapshot(ROOT)
    contract_sha = evidence.sha(CONTRACT)
    values = {'phase95_input_digest': base['input_digest'],
              'contract_sha256': contract_sha,
              'historical_complete_sha256': historical_sha}
    return {'schema': 'v122-mapping-followup-identity-v1',
            'input_digest': evidence.digest(values), **values}


def admitted_review(current: dict) -> tuple[dict, str]:
    review = evidence.load(QUAL / REVIEW)
    evidence.fields(review, 'schema status reviewer_agent_id input_digest findings')
    evidence.need(review['schema'] == 'v122-mapping-followup-implementation-review-v1'
                  and review['status'] == 'pass'
                  and evidence.reviewer(review['reviewer_agent_id'])
                  and review['input_digest'] == current['input_digest']
                  and review['findings'] == [], 'review_missing_or_stale')
    return review, evidence.sha(QUAL / REVIEW)


def attempt_path(attempt_id: str) -> Path:
    evidence.need(type(attempt_id) is str and ATTEMPT_PATTERN.fullmatch(attempt_id),
                  'attempt_id_invalid')
    path = QUAL / attempt_id
    evidence.need(path.is_dir() and not any(p.is_symlink() for p in (path, *path.parents)),
                  'attempt_missing')
    return path


def run_child(command: list[str], timeout: float, *, allowed=(0,)) -> bytes:
    try:
        status, output = gate.bounded(command, timeout)
    except (OSError, ValueError):
        raise GateError('child_spawn_failed') from None
    evidence.need(status in allowed, 'child_failed')
    return output


def strict_stdout_json(data: bytes) -> dict:
    evidence.need(len(data) <= 4 * 1024 * 1024, 'evidence_size')
    def invalid(_):
        raise GateError('nonfinite_json')
    try:
        value = json.loads(data.decode('utf-8', errors='strict'),
                           object_pairs_hook=evidence.pairs,
                           parse_constant=invalid, parse_float=invalid)
    except (ValueError, UnicodeError, RecursionError):
        raise GateError('invalid_json') from None
    evidence.need(type(value) is dict, 'invalid_json')
    return value


def portrait_environment(admission: dict) -> dict[str, str]:
    registration = evidence.load(PHASE / '95-ROI-REGISTRATION.json')
    evidence.need(registration.get('status') == 'registered', 'registration_invalid')
    return {
        'BEAUTY_PHASE95_ROI_DIGEST': registration['contracts_sha256'],
        'BEAUTY_PHASE95_SOURCE_DIGEST': registration['source_sha256'],
        'BEAUTY_PHASE95_ROOT_MEASUREMENT_IDENTITY': admission['measurement_identity'],
    }


def qualified_portrait(admission: dict) -> dict:
    run_child(['bash', 'scripts/run-clean-65-portrait.sh', '--self-test'], 30)
    original = {key: os.environ.get(key) for key in portrait_environment(admission)}
    os.environ.update(portrait_environment(admission))
    try:
        # Separate report and output parents satisfy the runner's path boundary.
        # Both are destroyed after strict aggregate classification.
        with tempfile.TemporaryDirectory(prefix='beauty-v122-followup-', dir='/private/tmp') as temporary:
            work = Path(temporary)
            reports = work / 'reports'
            reports.mkdir()
            report = reports / 'runner.json'
            runner = ['bash', 'scripts/run-face-feature-batches.sh',
                      '--output', str(work / 'outputs'), '--report', str(report)]
            run_child(runner + ['--preflight-only'], 120)
            run_child(runner, 1000, allowed=(0, 3))
            output = run_child(['swift', 'scripts/compare-face-feature-batches.swift',
                                '--classify-phase95', '--manifest',
                                'scripts/face-feature-batch-manifest.json',
                                '--report', str(report)], 150)
            portrait = strict_stdout_json(output)
            evidence.validate_portrait(
                portrait, admission,
                evidence.load(ROOT / 'scripts/face-feature-batch-manifest.json')['semanticContracts'],
                original_contract_id=evidence.load(PHASE / '95-ROI-REGISTRATION.json')['contracts_sha256'])
            return portrait
    finally:
        for key, value in original.items():
            if value is None:
                os.environ.pop(key, None)
            else:
                os.environ[key] = value


def execute() -> dict:
    admission = evidence.root_admission(ROOT)
    before = identity()
    _, review_sha = admitted_review(before)
    attempt_id = 'attempt-' + datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ') + '-' + secrets.token_hex(4)
    attempt = QUAL / attempt_id
    attempt.mkdir(mode=0o700, exist_ok=False)
    print('followup_attempt=' + attempt_id, flush=True)
    stage = 'focused'
    try:
        focused = {}
        for lane, suite in (('safety', 'RepairedControlSafetyTests'),
                            ('compatibility', 'RepairedControlCompatibilityTests')):
            print('followup_stage=' + lane, flush=True)
            transcript = run_child(['swift', 'test', '--package-path', 'BeautySDK', '--filter', suite], 600)
            focused[lane] = evidence.focused_counts(transcript, lane)
        stage = 'portrait'
        print('followup_stage=portrait', flush=True)
        portrait = qualified_portrait(admission)
        stage = 'no_skip'
        print('followup_stage=no_skip', flush=True)
        run_child(['bash', 'scripts/run-no-skip-swiftpm.sh', '--self-test'], 120)
        transcript = run_child(['bash', 'scripts/run-no-skip-swiftpm.sh'], 1800)
        no_skip = gate.counts(transcript)
        del transcript
        stage = 'identity'
        evidence.need(identity() == before and evidence.sha(QUAL / REVIEW) == review_sha,
                      'inputs_changed_during_execution')
        stage = 'publication'
        evidence.publish(attempt / PORTRAIT, portrait)
        portrait_sha = evidence.sha(attempt / PORTRAIT)
        binding = {**before, 'schema': 'v122-mapping-followup-binding-v1',
                   'review_sha256': review_sha, 'portrait_sha256': portrait_sha,
                   'ledger_snapshot': {name: evidence.sha(ROOT / name)
                                       for name in ('PLANS.md', 'QUALITY_SCORE.md')}}
        evidence.publish(attempt / BINDING, binding)
        evidence.publish(attempt / CHECKS, {
            'schema': 'v122-mapping-followup-checks-v1', 'status': 'pass',
            'phase_complete': False, 'input_digest': before['input_digest'],
            'binding_sha256': evidence.sha(attempt / BINDING),
            'portrait_sha256': portrait_sha, 'safety': focused['safety'],
            'compatibility': focused['compatibility'], 'no_skip': no_skip,
            'archive_first': True, 'sdk_boundary': 'pass',
            'wrapper_self_test': 'pass', 'remaining': ['independent-goal-review'],
        })
        evidence.need(identity() == before and evidence.sha(QUAL / REVIEW) == review_sha,
                      'inputs_changed_after_publication')
        return {'status': 'verification_pass', 'attempt_id': attempt_id,
                'phase_complete': False, **no_skip}
    except BaseException as error:
        # A retry always gets a fresh attempt. Never mutate a prior success or
        # publish child output, private paths, or transcripts as a failure log.
        if not (attempt / CHECKS).exists():
            try:
                evidence.publish(attempt / 'FAILURE.json', {
                    'schema': 'v122-mapping-followup-failure-v1', 'status': 'failed',
                    'stage': stage,
                    'reason': str(error) if isinstance(error, GateError) else 'execution_error',
                })
            except (GateError, OSError):
                pass
        raise


def completion(attempt_id: str) -> dict:
    attempt = attempt_path(attempt_id)
    current = identity()
    review, review_sha = admitted_review(current)
    admission = evidence.root_admission(ROOT)
    names = (PORTRAIT, BINDING, CHECKS, GOAL)
    hashes = {name: evidence.sha(attempt / name) for name in names}
    portrait, binding, checks, goal = (evidence.load(attempt / name) for name in names)
    evidence.validate_portrait(
        portrait, admission,
        evidence.load(ROOT / 'scripts/face-feature-batch-manifest.json')['semanticContracts'],
        original_contract_id=evidence.load(PHASE / '95-ROI-REGISTRATION.json')['contracts_sha256'])
    evidence.fields(binding, 'schema input_digest phase95_input_digest contract_sha256 '
                    'historical_complete_sha256 review_sha256 portrait_sha256 ledger_snapshot')
    evidence.need(binding['schema'] == 'v122-mapping-followup-binding-v1'
                  and all(binding[key] == current[key] for key in
                          ('input_digest', 'phase95_input_digest', 'contract_sha256',
                           'historical_complete_sha256'))
                  and binding['review_sha256'] == review_sha
                  and binding['portrait_sha256'] == hashes[PORTRAIT], 'binding_stale')
    evidence.fields(binding['ledger_snapshot'], 'PLANS.md QUALITY_SCORE.md')
    evidence.need(all(evidence.is_sha(value) for value in binding['ledger_snapshot'].values()),
                  'ledger_snapshot')
    evidence.fields(checks, 'schema status phase_complete input_digest binding_sha256 '
                    'portrait_sha256 safety compatibility no_skip archive_first sdk_boundary '
                    'wrapper_self_test remaining')
    evidence.need(checks['schema'] == 'v122-mapping-followup-checks-v1'
                  and checks['status'] == 'pass' and checks['phase_complete'] is False
                  and checks['input_digest'] == current['input_digest']
                  and checks['binding_sha256'] == hashes[BINDING]
                  and checks['portrait_sha256'] == hashes[PORTRAIT]
                  and checks['archive_first'] is True
                  and checks['sdk_boundary'] == checks['wrapper_self_test'] == 'pass'
                  and checks['remaining'] == ['independent-goal-review'], 'checks_invalid')
    evidence.validate_counts(checks['safety'], 'safety')
    evidence.validate_counts(checks['compatibility'], 'compatibility')
    evidence.validate_counts(checks['no_skip'])
    evidence.fields(goal, 'schema status reviewer_agent_id input_digest checks_sha256 '
                    'binding_sha256 review_sha256 portrait_sha256 requirements findings')
    evidence.need(goal['schema'] == 'v122-mapping-followup-goal-review-v1'
                  and goal['status'] == 'pass'
                  and evidence.reviewer(goal['reviewer_agent_id'])
                  and goal['reviewer_agent_id'] != review['reviewer_agent_id']
                  and goal['input_digest'] == current['input_digest']
                  and goal['checks_sha256'] == hashes[CHECKS]
                  and goal['binding_sha256'] == hashes[BINDING]
                  and goal['review_sha256'] == review_sha
                  and goal['portrait_sha256'] == hashes[PORTRAIT]
                  and goal['requirements'] == evidence.REQUIREMENTS
                  and goal['findings'] == [], 'goal_invalid')
    evidence.need(identity() == current
                  and all(evidence.sha(attempt / name) == value for name, value in hashes.items())
                  and evidence.sha(QUAL / REVIEW) == review_sha, 'inputs_changed')
    return {'schema': 'v122-mapping-followup-complete-v1', 'status': 'complete',
            'phase_complete': True, 'attempt_id': attempt_id,
            'input_digest': current['input_digest'],
            'historical_complete_sha256': HISTORICAL_COMPLETE_SHA,
            'measurement_identity': admission['measurement_identity'],
            'requirements': sorted(evidence.REQUIREMENTS),
            'evidence': {**hashes, REVIEW: review_sha}}


def finalize(attempt_id: str) -> dict:
    result = completion(attempt_id)
    destination = attempt_path(attempt_id) / COMPLETE
    evidence.publish(destination, result)
    inode = destination.stat().st_ino
    try:
        evidence.need(completion(attempt_id) == result, 'inputs_changed_after_publication')
    except BaseException:
        if destination.exists() and destination.stat().st_ino == inode:
            destination.unlink()
        raise
    return result


def verify(attempt_id: str) -> dict:
    result = completion(attempt_id)
    evidence.need(evidence.load(attempt_path(attempt_id) / COMPLETE) == result,
                  'completion_stale')
    return result


def self_test() -> dict:
    for invalid in ('../attempt-20260923T000000Z-12345678',
                    'attempt-20260923T000000Z-12345678/other', '',
                    'attempt-20260923T000000Z-1234567g'):
        try:
            attempt_path(invalid)
        except GateError:
            pass
        else:
            raise GateError('attempt_mutation_accepted')
    for payload in (b'{"a":1,"a":2}', b'{"a":NaN}', b'{"a":1.0}', b'[]'):
        try:
            strict_stdout_json(payload)
        except GateError:
            pass
        else:
            raise GateError('json_mutation_accepted')
    evidence.need(strict_stdout_json(b'{"a":1}') == {'a': 1}, 'json_positive')
    return {'status': 'pass', 'attempt_mutations_rejected': 4,
            'json_mutations_rejected': 4}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=('identity', 'self-test', 'execute', 'finalize', 'verify'))
    parser.add_argument('--attempt', help='Attempt ID printed by a successful execute run')
    args = parser.parse_args()
    if (args.command in ('finalize', 'verify')) != (args.attempt is not None):
        parser.error('--attempt is required only for finalize or verify')
    if args.command == 'identity':
        result = identity()
    elif args.command == 'self-test':
        result = self_test()
    elif args.command == 'execute':
        result = execute()
    elif args.command == 'finalize':
        result = finalize(args.attempt)
    else:
        result = verify(args.attempt)
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except GateError as error:
        print('v122_mapping_followup_failed:' + str(error), file=sys.stderr)
        raise SystemExit(1)
    except (OSError, ValueError, TypeError, KeyError, RecursionError, AssertionError):
        print('v122_mapping_followup_failed', file=sys.stderr)
        raise SystemExit(1)
