#!/usr/bin/env python3
"""Reviewed, execution-backed Phase 95 verification; no child output is saved."""
from __future__ import annotations
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import selectors
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
PHASE = ROOT / '.planning/phases/95-compatibility-and-sdk-only-closeout'
OPT_INS = (
    'testIntegrationDefaultStillImageProviderReturnsRedactedNoFaceForNoFaceFixture',
    'testIntegrationDefaultStillImageProviderReportsAggregateObservedFaceAvailabilityWithoutRawPayload',
    'testIntegrationDefaultStillImageProviderReportsObservedEyebrowAvailabilityWithoutRawPayload',
    'testIntegrationLocalAuthorizedPortraitRoutesAllEyebrowFieldsThroughPublicFacade',
    'testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope',
    'testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope',
    'testAuthorizedPositiveAndNegativeStayWithinFrozenAggregateBounds',
    'testAuthorizedPairSupportsFullScleraExpansionFromFrozenFocalAnchor',
)
OPT_IN_SUITES = ('VisionFaceDetectorTests',) * 3 + (
    'BeautyEngineGeometryFacadeTests', 'BeautyFaceGeometryAdapterTests',
    'BeautyFaceGeometryAdapterTests', 'BeautyTeethWhiteningRealFixtureTests',
    'BeautyScleraRednessRealFixtureTests')
OPT_IN_CASES = tuple(suite + '.' + method for suite, method in zip(OPT_IN_SUITES, OPT_INS))
MARKERS = (
    'no_skip_archive_verified', 'no_skip_sdk_boundary_self_tested',
    'no_skip_sdk_boundary_verified', 'no_skip_v1_18_decision_self_tested',
    'no_skip_v1_18_decision_verified', 'no_skip_backend_neutral_contract_verified',
    'no_skip_metal_runtime_verified', 'no_skip_metal_feature_passes_verified',
    'no_skip_backend_configuration_verified', 'no_skip_backend_parity_verified',
    'no_skip_swiftpm_consumer_verified', 'no_skip_cpu_reference_oracles_verified',
    'no_skip_swiftpm_passed opt_in_tests=8 skipped_tests=0',
)

spec = importlib.util.spec_from_file_location('phase95_evidence', ROOT / 'scripts/phase95-closeout-evidence.py')
evidence = importlib.util.module_from_spec(spec)
spec.loader.exec_module(evidence)
GateError = evidence.GateError
checked, sha = evidence.checked, evidence.sha
validate_review = evidence.validate_review

def snapshot():
    return evidence.snapshot(ROOT)

def read_review(expected):
    return validate_review(evidence.load(PHASE / evidence.REVIEW), expected)

def bounded(command: list[str], seconds: float, maximum: int = 16 * 1024 * 1024) -> tuple[int, bytes]:
    child = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, start_new_session=True,
                             env=dict(os.environ, BEAUTY_PHASE95_MANAGED_PROCESS_GROUP='1'))
    assert child.stdout is not None
    data = bytearray()
    wall, monotonic = time.time(), time.monotonic()
    try:
        with selectors.DefaultSelector() as selector:
            selector.register(child.stdout, selectors.EVENT_READ)
            while selector.get_map():
                if max(time.time() - wall, time.monotonic() - monotonic) > seconds:
                    raise GateError('child_timeout')
                for key, _ in selector.select(timeout=0.1):
                    chunk = os.read(key.fileobj.fileno(), 8192)
                    if not chunk:
                        selector.unregister(key.fileobj)
                        continue
                    if len(data) + len(chunk) > maximum: raise GateError('child_output_limit')
                    data.extend(chunk)
            remaining = seconds - max(time.time() - wall, time.monotonic() - monotonic)
            return child.wait(timeout=max(0.01, remaining)), bytes(data)
    finally:
        # Always clean the owned group, including descendants whose direct
        # parent has already exited. The driver inherits this group in managed
        # mode rather than creating an unreachable nested session.
        try: os.killpg(child.pid, signal.SIGTERM)
        except ProcessLookupError: pass
        if child.poll() is None:
            try: child.wait(timeout=3)
            except subprocess.TimeoutExpired:
                try: os.killpg(child.pid, signal.SIGKILL)
                except ProcessLookupError: pass
                child.wait(timeout=3)
        try: os.killpg(child.pid, signal.SIGKILL)
        except ProcessLookupError: pass
        child.stdout.close()

def counts(data: bytes) -> dict:
    spec = importlib.util.spec_from_file_location('phase95_transcript', ROOT / 'scripts/check-no-skip-transcript.py')
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    try: module.validate_transcript(data, OPT_INS)
    except module.TranscriptError as error: raise GateError('transcript_accounting') from error
    text = data.decode('utf-8', errors='strict')
    positions = []
    for marker in MARKERS:
        suffix = r'(?: branch=[A-Za-z0-9_]+ [A-Za-z0-9_= ]+)?' if marker.endswith('parity_verified') else ''
        found = list(re.finditer('^' + re.escape(marker) + suffix + '$', text, re.MULTILINE))
        if len(found) != 1: raise GateError('wrapper_accounting')
        positions.append(found[0].start())
    if positions != sorted(positions): raise GateError('archive_order')
    summaries = list(re.finditer(r"Test Suite 'All tests' passed[^\n]*\n\s*Executed (\d+) tests?, with 0 failures", text))
    if len(summaries) != 1: raise GateError('terminal_summary')
    summary = summaries[0]
    events = list(re.finditer(r"^Test Case '([^']+)' (passed|failed|skipped) ", text, re.MULTILINE))
    n = int(summary[1])
    if (n < len(OPT_INS) or len(events) != n
        or len({event[1] for event in events}) != n or any(event[2] != 'passed' for event in events)):
        raise GateError('test_event_totals')
    identities = [evidence.test_identity(event[1]) for event in events]
    if any(identities.count(case) != 1 for case in OPT_IN_CASES):
        raise GateError('opt_in_identity')
    swift_starts = list(re.finditer(r'Test run started', text))
    swift_ends = list(re.finditer(r'Test run with (\d+) tests? in (\d+) suites? (passed|failed)', text))
    if swift_starts or swift_ends:
        if (len(swift_starts) != 1 or len(swift_ends) != 1
            or swift_ends[0][3] != 'passed'
            or not positions[-2] < swift_starts[0].start() < swift_ends[0].start() < positions[-1]):
            raise GateError('swift_testing_order')
    starts = list(re.finditer(r"^Test (?:Suite|Case) '[^']+' started", text, re.MULTILINE))
    first_test = min(x.start() for x in [*starts, *events])
    if not positions[-2] < first_test <= events[-1].start() < summary.start() < positions[-1]:
        raise GateError('archive_test_order')
    return {'executed': n, 'failed': 0, 'skipped': 0, 'opt_in_tests': len(OPT_INS)}

def record(name, value):
    evidence.publish(PHASE / name, value)

def run() -> None:
    admission = evidence.root_admission(ROOT)
    before = snapshot()
    read_review(before['input_digest'])
    review_digest = sha(PHASE / '95-INDEPENDENT-REPAIR-REVIEW.json')
    for name in ('95-CLOSEOUT-BINDING.json', '95-CLOSEOUT-CHECKS.json'):
        if (PHASE / name).exists(): raise GateError('receipt_exists')
    focused = {}
    for lane, suite in (('safety', 'RepairedControlSafetyTests'),
                        ('compatibility', 'RepairedControlCompatibilityTests')):
        print('phase95_stage=' + lane, flush=True)
        code, transcript = bounded(['swift', 'test', '--package-path', 'BeautySDK', '--filter', suite], 600)
        if code: raise GateError('focused_test_failed')
        focused[lane] = evidence.focused_counts(transcript, lane)
        del transcript
    driver = ['bash', 'scripts/run-clean-65-portrait.sh']
    for argument, timeout in (('--self-test', 30), ('--prepare', 120), ('--run', 1000), ('--classify', 150)):
        print('phase95_stage=portrait_' + argument[2:].replace('-', '_'), flush=True)
        status, _ = bounded(driver + [argument], timeout)
        if status != 0 and not (argument == '--run' and status == 3):
            raise GateError('portrait_gate_failed')
    evidence.validate_portrait(evidence.load(PHASE / '95-CLEAN-65-REPORT.json'), admission,
        evidence.load(ROOT / 'scripts/face-feature-batch-manifest.json')['semanticContracts'],
        original_contract_id=evidence.load(PHASE / '95-ROI-REGISTRATION.json')['contracts_sha256'])
    portrait_digest = sha(PHASE / '95-CLEAN-65-REPORT.json')
    print('phase95_portrait_verified', flush=True)
    status, _ = bounded(['bash', 'scripts/run-no-skip-swiftpm.sh', '--self-test'], 120)
    if status: raise GateError('wrapper_self_test_failed')
    print('phase95_stage=no_skip', flush=True)
    status, transcript = bounded(['bash', 'scripts/run-no-skip-swiftpm.sh'], 1800)
    if status:
        markers = re.findall(rb'^no_skip_[a-z_]+$', transcript, re.MULTILINE)
        if markers: print(markers[-1].decode('ascii'), flush=True)
        raise GateError('no_skip_failed')
    measured = counts(transcript)
    del transcript
    if snapshot() != before or sha(PHASE / '95-INDEPENDENT-REPAIR-REVIEW.json') != review_digest:
        raise GateError('inputs_changed_during_execution')
    if sha(PHASE / '95-CLEAN-65-REPORT.json') != portrait_digest:
        raise GateError('portrait_changed_during_execution')
    binding = dict(before, schema='phase95-closeout-binding-v3', review_sha256=review_digest,
                   portrait_sha256=portrait_digest,
                   ledger_snapshot={n: sha(ROOT / n) for n in ('PLANS.md', 'QUALITY_SCORE.md')})
    record('95-CLOSEOUT-BINDING.json', binding)
    record('95-CLOSEOUT-CHECKS.json', {
        'schema': 'phase95-closeout-checks-v3', 'status': 'pass', 'phase_complete': False,
        'binding_sha256': sha(PHASE / '95-CLOSEOUT-BINDING.json'),
        'input_digest': before['input_digest'], 'portrait_sha256': portrait_digest,
        'safety': focused['safety'], 'compatibility': focused['compatibility'],
        'no_skip': measured, 'archive_first': True, 'sdk_boundary': 'pass',
        'wrapper_self_test': 'pass', 'remaining': ['95-04-owner-sync-and-goal-verification'],
    })
    print(json.dumps({'status': 'verification_pass', 'phase_complete': False, **measured}))

def self_test() -> None:
    fixture = '\n'.join(MARKERS[:-1]) + '\n'
    fixture += ''.join("Test Case '" + name + "' passed (0.01 seconds)\n" for name in OPT_IN_CASES)
    fixture += "Test Suite 'All tests' passed at fixed.\n Executed 8 tests, with 0 failures\n"
    fixture += MARKERS[-1] + '\n'
    if counts(fixture.encode())['executed'] != 8: raise GateError('self_test_counts')
    mutations = [fixture.replace('Executed 8', 'Executed 0'),
        fixture.replace('0 failures', '1 failures'), fixture.replace(OPT_INS[0], 'wrongOptIn'),
        fixture.replace(MARKERS[0] + '\n', ''), fixture + MARKERS[-1] + '\n',
        fixture.replace(MARKERS[0], MARKERS[1]).replace(MARKERS[1], MARKERS[0], 1),
        fixture.replace(OPT_IN_CASES[0] + "' passed", OPT_IN_CASES[0] + "' skipped")]
    mutations.extend([
        fixture.replace('Executed 8 tests', 'Executed 1 test'),
        fixture[fixture.index("Test Case"):fixture.index(MARKERS[-1])] + '\n'.join(MARKERS) + '\n',
        fixture.replace(MARKERS[-1] + '\n', '').replace("Test Suite 'All tests'", MARKERS[-1] + "\nTest Suite 'All tests'"),
    ])
    mixed = fixture.replace(MARKERS[-1], '◇ Test run started.\n✔ Test run with 0 tests in 0 suites passed after 0.001 seconds.\n' + MARKERS[-1])
    if counts(mixed.encode())['executed'] != 8: raise GateError('mixed_positive')
    mutations.extend([
        '◇ Test run started.\n' + mixed.replace('◇ Test run started.\n', ''),
        mixed.replace(MARKERS[-1] + '\n', '').replace('✔ Test run', MARKERS[-1] + '\n✔ Test run'),
        fixture.replace(OPT_INS[0], OPT_INS[0] + 'Different'),
        fixture.replace(OPT_IN_CASES[0], 'WrongSuite.' + OPT_INS[0]),
        fixture.replace(OPT_IN_CASES[0], 'WrongSuite.unrelated') + OPT_INS[0] + ' passed\n',
    ])
    # Explicitly swap the first two ordered prerequisites.
    mutations[5] = fixture.replace(MARKERS[0] + '\n' + MARKERS[1], MARKERS[1] + '\n' + MARKERS[0])
    for altered in mutations:
        try: counts(altered.encode())
        except GateError: pass
        else: raise GateError('mutation_accepted')
    review = {'schema': 'phase95-independent-repair-review-v3', 'status': 'pass',
              'reviewer_agent_id': 'self-test-agent', 'input_digest': 'a' * 64, 'findings': []}
    validate_review(review, 'a' * 64)
    review_mutations = [dict(review, status='pending'), dict(review, input_digest='b' * 64),
                        dict(review, reviewer_agent_id=''), dict(review, findings=['open']),
                        dict(review, extra=True), {}]
    for altered in review_mutations:
        try: validate_review(altered, 'a' * 64)
        except GateError: pass
        else: raise GateError('review_mutation_accepted')
    status, data = bounded([sys.executable, '-c', 'print(7)'], 2)
    if status != 0 or data.strip() != b'7': raise GateError('self_test_child')
    for command, timeout, limit in (([sys.executable, '-c', 'print("x"*2000)'], 2, 128),
                                    ([sys.executable, '-c', 'import time; time.sleep(2)'], 0.05, 1024)):
        try: bounded(command, timeout, limit)
        except GateError: pass
        else: raise GateError('child_bound_not_enforced')
    print(json.dumps({'status': 'pass', 'transcript_mutations_rejected': len(mutations),
                      'review_mutations_rejected': len(review_mutations), 'child_checks': 3}))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=('self-test', 'review-inputs', 'run', 'finalize', 'verify-complete'))
    args = parser.parse_args()
    try:
        if args.command == 'self-test': self_test()
        elif args.command == 'review-inputs': print(json.dumps(snapshot(), sort_keys=True))
        elif args.command == 'verify-complete': print(json.dumps(evidence.verify_complete(ROOT), sort_keys=True))
        elif args.command == 'finalize': print(json.dumps(evidence.finalize(ROOT), sort_keys=True))
        else: run()
    except GateError as error:
        print('phase95_genuine_gate_failed:' + str(error), file=sys.stderr)
        sys.exit(1)
    except (OSError, ValueError, TypeError, KeyError, RecursionError, subprocess.SubprocessError, AssertionError):
        print('phase95_genuine_gate_failed', file=sys.stderr)
        sys.exit(1)
