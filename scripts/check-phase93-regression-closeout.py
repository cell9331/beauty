#!/usr/bin/env python3
"""Correct only the additional regression selection; retain all prior evidence."""
import importlib.util
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
REL = 'scripts/check-phase93-regression-closeout.py'
PHASE = '.planning/phases/93-distinct-nose-bridge-and-root-repairs/'
spec = importlib.util.spec_from_file_location('phase93_timeout', ROOT / 'scripts/check-phase93-timeout-recovery.py')
t = importlib.util.module_from_spec(spec); spec.loader.exec_module(t)
g = t.g
original_latest = g.latest
CLASSES = ('ChinTaperRepairTests', 'BeautyEngineChinTaperRepairTests',
 'BeautyFaceGeometryAdapterTests', 'EyeWarpProviderTests', 'BeautyEngineGazeCorrectionRepairTests',
 'EyebrowWarpProviderTests', 'BeautyEyebrowFixtureRegistrationTests',
 'BeautyEngineEyebrowHeadSpacingRepairTests', 'BeautyEngineUpperEyelidFullnessIntegrationTests')
EXCLUDED = {'BeautyEffectsTests.BeautyFaceGeometryAdapterTests/' + name for name in (
 'testIntegrationLocalAuthorizedPortraitAggregateFitsLockedFaceValidationEnvelope',
 'testIntegrationLocalAuthorizedPortraitFitsLockedEyebrowValidationEnvelope')}
SAFE_CONTOUR = ['BeautyEffectsTests.FaceContourSmoothRepairTests/' + name for name in (
 'testFACE01ExistingProviderEmitsOneCenteredObservedContourCorrection',
 'testFACE01ProviderFailsOnlyNamedFieldClosedForInvalidSupportAndInputs')]
KINDS = {'revalidation': (47, 36), 'compatibility': (53, 229), 'checks': (54, 8)}


def identity(): return dict(t.identity(), **{REL: g.sha(REL)})


def validate_history(value, history, ledger):
    prefix = b'\n'.join(ledger.splitlines()[:len(g.LEDGER_HEADER.splitlines()) + 55]) + b'\n'
    g.require(len(history) >= 55 and g.digest(prefix) == value['prefix_sha'], 'ledger_failure')
    failure = history[54]
    g.require(g.digest(g.encode(failure).encode()) == value['failure_sha']
              and failure['event'] == 'failure' and failure['kind'] == 'cross_phase_regression'
              and failure['category'] == 'skip_failure'
              and failure['counts'] == {'discovered': 108, 'passed': 34, 'failed': 1, 'skipped': 0}, 'ledger_failure')
    g.require(not any(e['event'] == 'failure' for e in history[55:]), 'attempt_failed')
    g.require(set(value['receipts']) == set(KINDS), 'invalid_record')
    for kind, (sequence, count) in KINDS.items():
        event = history[sequence - 1]
        g.require(event['event'] == 'receipt' and event['kind'] == kind
                  and event['identity'] == value['pins']
                  and event['counts'] == {'discovered': count, 'passed': count, 'failed': 0, 'skipped': 0}
                  and g.digest(g.encode(event).encode()) == value['receipts'][kind], 'stale_receipt')


def authorities():
    t.authorization()
    value = json.loads(g.read_bytes(PHASE + '93-REGRESSION-DISPOSITION.json'), object_pairs_hook=g.no_duplicates)
    g.require(set(value) == {'schema', 'runner', 'prefix_sha', 'failure_sha', 'pins', 'receipts'}
              and value['schema'] == 1 and value['runner'] == g.sha(REL)
              and value['pins'] == t.identity(), 'hash_drift')
    history = g.events()
    validate_history(value, history, g.read_bytes(PHASE + '93-ATTEMPTS.md'))
    t.r.review_verdict(g.read_bytes(PHASE + '93-REGRESSION-REVIEW.md').decode(),
                      {'candidate_provider': value['pins'][g.PROVIDER], 'runner': value['runner']})
    for event in history[55:]:
        if event.get('kind') == 'bounded_cross_phase_regression':
            g.require(event['extra']['disposition'] == g.sha(PHASE + '93-REGRESSION-DISPOSITION.json')
                      and event['extra']['review'] == g.sha(PHASE + '93-REGRESSION-REVIEW.md'), 'hash_drift')
    # Only the exact, preserved out-of-scope selection failure above is excepted.
    # Original source, inventory, test, renderer and prior gate pins still apply.
    before = t.ALLOW_ROLLBACK
    t.ALLOW_ROLLBACK = True
    try: return t.authorities()
    finally: t.ALLOW_ROLLBACK = before


def latest(kind, current=True):
    event = original_latest(kind, current=False)
    if current:
        valid = event['identity'] == identity()
        if kind in KINDS:
            valid |= event['sequence'] == KINDS[kind][0] and event['identity'] == t.identity()
        g.require(valid, 'stale_receipt')
    return event


def accepted():
    authorities()
    regression = latest('bounded_cross_phase_regression')
    g.require(regression['counts'] == {'discovered': 106, 'passed': 106, 'failed': 0, 'skipped': 0}, 'gate_not_ready')
    return latest('revalidation')


def checks_publish():
    authorities()
    prior = g.events()
    receipts = [e for e in prior if e['event'] == 'receipt'
                and e.get('kind') in ('compatibility', 'checks', 'design', 'owners', 'bounded_cross_phase_regression')
                and (e['identity'] == identity() or (e.get('kind') in KINDS and e['sequence'] == KINDS[e['kind']][0]))]
    value = {'phase': 93, 'gate': g.sha(g.GATE), 'identity': identity(),
             'prior_validation_identity': t.identity(),
             'regression_disposition': g.sha(PHASE + '93-REGRESSION-DISPOSITION.json'), 'receipts': receipts}
    fd = os.open(g.safe_path(PHASE + '93-CHECKS.json', writing=True), os.O_WRONLY | os.O_CREAT | os.O_TRUNC | os.O_NOFOLLOW, 0o600)
    with os.fdopen(fd, 'w') as stream:
        stream.write(g.encode(value) + '\n'); stream.flush(); os.fsync(stream.fileno())


def select_methods(listing):
    methods = []
    for cls in CLASSES:
        found = re.findall(r'^([A-Za-z0-9_]+\.' + cls + r'/test[A-Za-z0-9_]+)$', listing, re.M)
        g.require(found and len(found) == len(set(found)), 'discovery_failure')
        methods.extend(found)
    g.require(EXCLUDED <= set(methods), 'discovery_failure')
    methods = [m for m in methods if m not in EXCLUDED] + SAFE_CONTOUR
    g.require(len(methods) == 106, 'discovery_failure')
    g.discover(listing, methods)
    return methods


def regression():
    authorities()
    g.require(not any(e.get('kind') == 'bounded_cross_phase_regression' for e in g.events()), 'attempt_order')
    disposition = g.sha(PHASE + '93-REGRESSION-DISPOSITION.json')
    def expired(signum, frame): raise g.GateError('child_timeout')
    signal.signal(signal.SIGALRM, expired); signal.alarm(600)
    try:
        listing = g.prepare()
        results, _ = g.run_methods(select_methods(listing), listing=listing)
        authorities()
        g.require(disposition == g.sha(PHASE + '93-REGRESSION-DISPOSITION.json'), 'hash_drift')
        result = g.receipt('bounded_cross_phase_regression', results,
                           {'disposition': disposition, 'review': g.sha(PHASE + '93-REGRESSION-REVIEW.md'),
                            'classes': 10, 'excluded_portrait_methods': 2, 'deferred_face01_excluded': 1})
        checks_publish()
        print('PHASE93_REGRESSION ' + g.encode(result['counts']))
    finally: signal.alarm(0)


def run_regression_command():
    try:
        regression()
        return 0
    except Exception as error:
        category = (str(error) if isinstance(error, g.GateError) else
                    'child_timeout' if isinstance(error, subprocess.TimeoutExpired) else 'infrastructure_failure')
        try: current = identity()
        except Exception: current = {REL: g.sha(REL)}
        g.append({'event': 'failure', 'kind': 'bounded_cross_phase_regression', 'category': category,
                  'identity': current, 'counts': dict(g.PROGRESS), 'method': g.CURRENT_METHOD, 'assertions': []})
        print('PHASE93_REGRESSION status=failed category=' + category)
        return 2


def self_test():
    # Synthetic discovery and history mutations; no Swift or writes.
    lines = []
    for index, cls in enumerate(CLASSES):
        lines.extend('BeautyEffectsTests.' + cls + '/testSynthetic' + str(n) for n in range(12 if index < 5 else 8))
    # 92 synthetic methods + 12 additional + 2 safe contour = 106 selected.
    lines += sorted(EXCLUDED) + SAFE_CONTOUR + ['BeautyEffectsTests.' + CLASSES[0] + '/testExtra' + str(n) for n in range(12)]
    listing = '\n'.join(lines)
    g.require(len(select_methods(listing)) == 106, 'self_test_failure')
    checks = 1
    for bad in (listing + '\n' + lines[0], listing.replace(sorted(EXCLUDED)[0], 'removed'), listing.replace(SAFE_CONTOUR[0], 'removed'), listing.replace(lines[0], 'removed')):
        try: select_methods(bad)
        except g.GateError: checks += 1
        else: raise g.GateError('self_test_failure')
    history = [{'event': 'receipt'} for _ in range(55)]
    value = {'pins': {}, 'receipts': {}}
    for kind, (sequence, count) in KINDS.items():
        history[sequence - 1] = {'event': 'receipt', 'kind': kind, 'identity': {}, 'counts': {'discovered': count, 'passed': count, 'failed': 0, 'skipped': 0}}
        value['receipts'][kind] = g.digest(g.encode(history[sequence - 1]).encode())
    history[54] = {'event': 'failure', 'kind': 'cross_phase_regression', 'category': 'skip_failure', 'counts': {'discovered': 108, 'passed': 34, 'failed': 1, 'skipped': 0}}
    ledger = (g.LEDGER_HEADER + 'row\n' * 55).encode()
    value.update(prefix_sha=g.digest(ledger), failure_sha=g.digest(g.encode(history[54]).encode()))
    validate_history(value, history, ledger); checks += 1
    for mutation in ('prefix', 'failure', 'later_failure', 'receipt'):
        rows = [dict(e) for e in history]; data = ledger
        if mutation == 'prefix': data = b'x' + data
        if mutation == 'failure': rows[54] = dict(rows[54], category='assertion_failure')
        if mutation == 'later_failure': rows += [{'event': 'failure', 'category': 'skip_failure'}]
        if mutation == 'receipt': rows[52] = dict(rows[52], identity={'different': 'hash'})
        try: validate_history(value, rows, data)
        except g.GateError: checks += 1
        else: raise g.GateError('self_test_failure')
    from unittest.mock import patch
    from contextlib import redirect_stdout
    from io import StringIO
    rows = [dict(e) for e in history]
    calls = []
    def prepare_timeout():
        calls.append(True)
        raise subprocess.TimeoutExpired(['synthetic-sensitive-command'], 1, output=b'synthetic-sensitive-output')
    def admit(): validate_history(value, rows, ledger)
    captured = StringIO()
    with patch.dict(globals(), authorities=admit, identity=lambda: {}), patch.object(g, 'events', lambda: rows), patch.object(g, 'sha', lambda _: 'a' * 64), patch.object(g, 'prepare', prepare_timeout), patch.object(g, 'append', rows.append), patch.object(signal, 'signal', lambda *args: None), patch.object(signal, 'alarm', lambda *args: None), redirect_stdout(captured):
        g.require(run_regression_command() == 2 and len(rows) == 56
                  and rows[-1]['category'] == 'child_timeout', 'self_test_failure')
        g.require(run_regression_command() == 2 and len(calls) == 1
                  and rows[-1]['category'] == 'attempt_failed', 'self_test_failure')
    g.require('synthetic-sensitive' not in captured.getvalue()
              and 'synthetic-sensitive' not in g.encode(rows), 'self_test_failure')
    checks += 2
    print('PHASE93_REGRESSION_SELF_TEST passed=' + str(checks) + ' failed=0 skipped=0')


if __name__ == '__main__':
    if sys.argv[1:] == ['self-test']: self_test()
    else:
        g.identity = identity; g.authorities = authorities; g.accepted = accepted; g.latest = latest; g.checks_publish = checks_publish
        if sys.argv[1:] == ['regression']:
            raise SystemExit(run_regression_command())
        else:
            g.require(len(sys.argv) > 1 and sys.argv[1] in ('authorities', 'closeout'), 'invalid_command')
            raise SystemExit(g.main())
