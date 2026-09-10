#!/usr/bin/env python3
"""Revalidate the same Phase93 candidate after the recorded launcher timeout."""
import importlib.util
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parent.parent
REL = 'scripts/check-phase93-timeout-recovery.py'
PHASE = '.planning/phases/93-distinct-nose-bridge-and-root-repairs/'
spec = importlib.util.spec_from_file_location('phase93_attempt2', ROOT / 'scripts/check-phase93-attempt2.py')
r = importlib.util.module_from_spec(spec); spec.loader.exec_module(r)
g = r.g
original_run_methods = g.run_methods
ALLOW_ROLLBACK = False
# 2 setup children (120s), 37 renderer children (30s), each with 6s
# termination + 5s pipe-drain allowance, plus 60s fixture/teardown allowance.
CLASS_TIMEOUT = 2 * (120 + 6 + 5) + 37 * (30 + 6 + 5) + 60
PROCESS_CLASS = 'BeautyCoreTests.BeautyExampleRendererProcessTests/'
PROCESS_NAMES = (
 'testCompiledRendererDiscoveryAndReproducibility',
 'testCompiledRendererBindsOnlyExactSuccessfulGazeAggregate',
 'testCompiledRendererRejectsArgumentsSelectionAndDuplicateScalars',
 'testCompiledRendererRejectsInputAndOutputMatrix',
 'testCompiledRendererReportsDestinationAndReportCollisions',
 'testCompiledRendererEscapesControlCharactersInProgressOutput',
 'testCompiledRendererReplacesGeneratedArtifactsWhenOutputIsReused',
 'testCompiledRendererReachesInternalRenderAndEncodeFailureSeams')


def identity():
    return dict(r.identity(), **{REL: g.sha(REL)})


def authorization():
    previous, history = r.authorization()
    value = json.loads(g.read_bytes(PHASE + '93-TIMEOUT-AMENDMENT.json'), object_pairs_hook=g.no_duplicates)
    g.require(set(value) == {'schema', 'reason', 'runner', 'candidate_provider', 'adapter', 'commit',
                             'prefix_sha', 'previous_authorization', 'previous_runner', 'timeout_sha'}, 'invalid_record')
    g.require(value['schema'] == 1 and value['reason'] == 'process_class_cold_build_budget', 'invalid_record')
    for key in set(value) - {'schema', 'reason', 'commit'}:
        g.require(type(value[key]) is str and re.fullmatch('[0-9a-f]{64}', value[key]), 'invalid_record')
    g.require(re.fullmatch('[0-9a-f]{40}', value['commit']), 'invalid_record')
    g.require(value['runner'] == g.sha(REL)
              and value['candidate_provider'] == previous['candidate_provider']
              and value['adapter'] == previous['restored_adapter']
              and value['previous_runner'] == g.sha(r.REL)
              and value['previous_authorization'] == g.sha(PHASE + '93-ATTEMPT2.json'), 'hash_drift')
    ledger = g.read_bytes(PHASE + '93-ATTEMPTS.md')
    prefix = b'\n'.join(ledger.splitlines()[:len(g.LEDGER_HEADER.splitlines()) + 40]) + b'\n'
    g.require(len(history) >= 40 and g.digest(prefix) == value['prefix_sha'], 'ledger_failure')
    failure, rollback = history[38:40]
    g.require(g.digest(g.encode(failure).encode()) == value['timeout_sha']
              and failure['event'] == 'failure' and failure['kind'] == 'compatibility'
              and failure['category'] == 'child_timeout'
              and failure['method'] == PROCESS_CLASS + PROCESS_NAMES[1]
              and failure['counts'] == {'discovered': 229, 'passed': 67, 'failed': 0, 'skipped': 0}
              and rollback['kind'] == 'recovery_rollback' and rollback['rollback'] == 'production_restored', 'ledger_failure')
    r.review_verdict(g.read_bytes(PHASE + '93-TIMEOUT-REVIEW.md').decode(), value)
    resumes = [e for e in history if e.get('kind') == 'infrastructure_resume']
    g.require(len(resumes) <= 1, 'attempt_order')
    if resumes:
        event = resumes[0]
        g.require(event['sequence'] == 41 and event['amendment'] == g.sha(PHASE + '93-TIMEOUT-AMENDMENT.json')
                  and event['review'] == g.sha(PHASE + '93-TIMEOUT-REVIEW.md')
                  and event['identity'][REL] == value['runner'], 'hash_drift')
    return value, history


def authorities():
    value, history = authorization()
    g.require(len(history) >= 41 and history[40].get('kind') == 'infrastructure_resume', 'attempt_order')
    g.require(ALLOW_ROLLBACK or not any(e['event'] == 'failure' for e in history[41:]), 'attempt_failed')
    g.require(g.sha(g.PROVIDER) == value['candidate_provider'] and g.sha(g.ADAPTER) == value['adapter'], 'hash_drift')
    return r.original_authorities()


def resume():
    value, history = authorization()
    g.require(len(history) == 40, 'attempt_order')
    base = g.load('BASELINE'); g.check_hashes(base['frozen']); g.check_hashes(base['fixture']); g.source_scope(base)
    g.require(g.sdk_files() - set(g.NEW_TESTS) == set(base['sdk_inventory']), 'source_inventory')
    contents = {}
    for path, key in ((g.PROVIDER, 'candidate_provider'), (g.ADAPTER, 'adapter')):
        g.require(g.sha(path) == base['originals'][path]['sha256'], 'rollback_failure')
        data = g.child(['git', 'show', value['commit'] + ':' + path])[1].encode()
        g.require(g.digest(data) == value[key], 'hash_drift'); contents[path] = data
    g.append({'event': 'receipt', 'kind': 'infrastructure_resume', 'attempt': 2,
              'identity': identity(), 'amendment': g.sha(PHASE + '93-TIMEOUT-AMENDMENT.json'),
              'review': g.sha(PHASE + '93-TIMEOUT-REVIEW.md'), 'timestamp': int(time.time())})
    for path, data in contents.items():
        replace_owned(path, data)
    authorities()


def replace_owned(path, data):
    # Stage on the repository filesystem outside SDK inventory, then atomically
    # replace one file. Abrupt interruption leaves each file original or exact
    # candidate, never truncated. The two-file mixed state remains recoverable.
    target = g.safe_path(path)
    fd, temporary = tempfile.mkstemp(prefix='phase93-swap-', dir=ROOT / '.planning')
    stream = None
    try:
        stream = os.fdopen(fd, 'wb')
        with stream:
            os.fchmod(stream.fileno(), target.stat().st_mode & 0o777)
            stream.write(data); stream.flush(); os.fsync(stream.fileno())
        os.replace(temporary, target)
    finally:
        if stream is None: os.close(fd)
        if os.path.exists(temporary): os.unlink(temporary)


def accept():
    authorities()
    g.require(not any(e.get('kind') == 'revalidation' for e in g.events()), 'attempt_order')
    receipts = [g.latest(kind) for kind in ('provider_green', 'registration_green', 'metrics', 'pixels', 'lifecycle')]
    g.require(all(e['sequence'] > 41 for e in receipts), 'stale_receipt')
    counts = {key: sum(e['counts'][key] for e in receipts) for key in ('discovered', 'passed', 'failed', 'skipped')}
    g.require(counts == {'discovered': 36, 'passed': 36, 'failed': 0, 'skipped': 0}, 'completion_failure')
    g.append({'event': 'receipt', 'kind': 'revalidation', 'attempt': 2, 'identity': identity(),
              'counts': counts, 'status': 'passed', 'new_candidates': 0})


def accepted():
    authorities()
    event = g.latest('revalidation')
    g.require(event['attempt'] == 2 and event['status'] == 'passed'
              and event['counts'] == {'discovered': 36, 'passed': 36, 'failed': 0, 'skipped': 0}, 'gate_not_ready')
    return event


def owned_snapshot():
    result = {}
    for path in (g.ADAPTER, g.PROVIDER):
        try: result[path] = g.sha(path)
        except (g.GateError, OSError): result[path] = None
    return result


def record_failure(command, error):
    category = str(error) if isinstance(error, g.GateError) else 'infrastructure_failure'
    try: current_identity = identity()
    except (g.GateError, OSError): current_identity = {REL: g.sha(REL)}
    g.append({'event': 'failure', 'kind': command, 'category': category,
              'identity': current_identity, 'owned_state': owned_snapshot(),
              'counts': dict(g.PROGRESS), 'assertions': [], 'timestamp': int(time.time())})
    return category


def rollback():
    # Interrupted writes are not complete candidates. Validate immutable pins,
    # owned preimages and inventory without demanding both candidate hashes.
    value, history = authorization()
    g.require(len(history) >= 41 and history[40].get('kind') == 'infrastructure_resume', 'attempt_order')
    base = g.load('BASELINE'); g.check_hashes(base['frozen']); g.check_hashes(base['fixture'])
    g.require(g.sdk_files() - set(g.NEW_TESTS) == set(base['sdk_inventory']), 'source_inventory')
    snapshots = [e['owned_state'] for e in history[41:]
                 if e['event'] == 'failure' and e.get('kind') == 'resume' and 'owned_state' in e]
    current = owned_snapshot()
    for path, key in ((g.PROVIDER, 'candidate_provider'), (g.ADAPTER, 'adapter')):
        allowed = {base['originals'][path]['sha256'], value[key]}
        allowed |= {snapshot[path] for snapshot in snapshots if snapshot[path] is not None}
        g.require(current[path] in allowed, 'owned_state_drift')
    restore_owned(base)
    g.append({'event': 'receipt', 'kind': 'timeout_recovery_rollback', 'attempt': 2,
              'identity': {REL: g.sha(REL)}, 'before': current, 'rollback': 'production_restored',
              'restored': g.hashes([g.ADAPTER, g.PROVIDER]), 'timestamp': int(time.time())})


def restore_owned(base):
    for path in (g.ADAPTER, g.PROVIDER):
        replace_owned(path, g.blob_bytes(base, path))
        g.require(g.sha(path) == base['originals'][path]['sha256'], 'rollback_failure')


def class_child():
    # Every generated build/fixture root belongs to this one launcher. Child
    # group termination completes before TemporaryDirectory removes the root.
    scratch = None
    try:
        with tempfile.TemporaryDirectory(prefix='beauty-phase93-process-') as scratch:
            return g.child(['env', 'TMPDIR=' + scratch + '/', 'swift', 'test', '--package-path', 'BeautySDK',
                            '--skip-build', '--filter', '^BeautyCoreTests\\.BeautyExampleRendererProcessTests/'],
                           timeout=CLASS_TIMEOUT, allow_failure=True)
    except OSError:
        raise g.GateError('cleanup_or_launch_failure') from None
    finally:
        if scratch is not None:
            g.require(not Path(scratch).exists(), 'cleanup_failure')


def classify_class(output, code, methods):
    g.require(code == 0, 'child_failure')
    identities = [m.replace('/', ' ') for m in methods]
    starts = re.findall(r"^Test Case '-\[([^\]]+)\]' started\.$", output, re.M)
    ends = re.findall(r"^Test Case '-\[([^\]]+)\]' (passed|failed|skipped) \([0-9.]+ seconds\)\.$", output, re.M)
    g.require(sorted(starts) == sorted(identities) and len(set(starts)) == len(methods)
              and sorted(e[0] for e in ends) == sorted(identities)
              and all(e[1] == 'passed' for e in ends)
              and len(re.findall(r'^Test Case ', output, re.M)) == 2 * len(methods), 'completion_failure')
    g.require(not re.search(r'\bskipped\b|\berror:|XCTAssert\w* failed|XCTFail failed', output, re.I), 'assertion_failure')
    summaries = re.findall(r'Executed (\d+) tests?, with (\d+) failures? \((\d+) unexpected\)', output)
    g.require(summaries and all(tuple(map(int, row)) == (len(methods), 0, 0) for row in summaries), 'completion_failure')
    return [{'discovered': 1, 'passed': 1, 'failed': 0, 'skipped': 0, 'assertions': []} for _ in methods]


def run_methods(methods, expected=None, listing=None, records=False):
    group = [m for m in methods if m.startswith(PROCESS_CLASS)]
    if not group: return original_run_methods(methods, expected=expected, listing=listing, records=records)
    g.require(expected is None and not records
              and set(group) == {PROCESS_CLASS + name for name in PROCESS_NAMES}
              and len(group) == len(PROCESS_NAMES), 'discovery_failure')
    listing = g.prepare() if listing is None else listing
    g.discover(listing, methods)
    results = []
    total = len(methods)
    # Run all existing process methods in one XCTest process so their retained
    # static build cache and class teardown work as designed. No test changes.
    for selected in ([m for m in methods if not m.startswith(PROCESS_CLASS)], group):
        g.PROGRESS.update(discovered=total, passed=len(results), failed=0, skipped=0)
        if selected is group:
            g.CURRENT_METHOD = 'BeautyCoreTests.BeautyExampleRendererProcessTests'
            g.CURRENT_IDS = []
            code, output = class_child()
            results += classify_class(output, code, group)
        else:
            try:
                rows, _ = original_run_methods(selected, listing=listing)
            except g.GateError:
                g.PROGRESS['discovered'] = total
                raise
            results += rows
    g.PROGRESS.update(discovered=total, passed=len(results), failed=0, skipped=0)
    return results, {}


def self_test():
    r.self_test()
    methods = [PROCESS_CLASS + name for name in PROCESS_NAMES]
    body = ''.join("Test Case '-[" + m.replace('/', ' ') + "]' started.\nTest Case '-[" + m.replace('/', ' ') + "]' passed (0.001 seconds).\n" for m in methods)
    output = body + 'Executed 8 tests, with 0 failures (0 unexpected)\n'
    g.require(len(classify_class(output, 0, methods)) == 8, 'self_test_failure')
    count = 1
    mutations = [output.replace('started.', 'started.', 1) + body.splitlines()[0] + '\n',
                 output.replace('passed (', 'failed (', 1), output.replace('passed (', 'skipped (', 1),
                 output.replace('Executed 8', 'Executed 7'), output.replace('0 failures', '1 failures'),
                 output + 'error: hidden\n', output.replace(methods[0].replace('/', ' '), 'unexpected', 2),
                 output.replace(body.splitlines()[0] + '\n', '', 1), body]
    for bad in mutations:
        try: classify_class(bad, 0, methods)
        except g.GateError: count += 1
        else: raise g.GateError('self_test_failure')
    try: classify_class(output, 1, methods)
    except g.GateError: count += 1
    else: raise g.GateError('self_test_failure')
    from unittest.mock import patch
    # Virtual serial schedule: retained child waits + termination/drain bounds.
    clock = 0
    for budget in [131] * 2 + [41] * 37 + [60]:
        clock += budget
        g.require(clock <= CLASS_TIMEOUT, 'self_test_failure')
    g.require(CLASS_TIMEOUT == 1839 and 2 * 110 + 37 * 20 < CLASS_TIMEOUT, 'self_test_failure')
    count += 1
    for timed_out in (False, True):
        cleaned = []
        class FakeTemporary:
            def __init__(self, **kwargs): pass
            def __enter__(self): return '/owned-synthetic-root'
            def __exit__(self, *args): cleaned.append(True)
        def fake_child(args, timeout, allow_failure):
            g.require(args[:2] == ['env', 'TMPDIR=/owned-synthetic-root/']
                      and timeout == CLASS_TIMEOUT and not cleaned, 'self_test_failure')
            if timed_out: raise g.GateError('child_timeout')
            return 0, ''
        with patch.object(tempfile, 'TemporaryDirectory', FakeTemporary), patch.object(g, 'child', fake_child), patch.object(Path, 'exists', lambda self: False):
            try: class_child()
            except g.GateError as error: g.require(timed_out and str(error) == 'child_timeout', 'self_test_failure')
            else: g.require(not timed_out, 'self_test_failure')
        g.require(cleaned == [True], 'self_test_failure'); count += 1
    # Real rollback admission with synthetic complete, mixed and truncated states.
    base = {'frozen': {}, 'fixture': {}, 'sdk_inventory': [], 'originals': {
        g.PROVIDER: {'sha256': 'a' * 64}, g.ADAPTER: {'sha256': 'b' * 64}}}
    value = {'candidate_provider': 'c' * 64, 'adapter': 'd' * 64}
    for variant in ('complete', 'mixed', 'truncated', 'unowned'):
        current = {g.PROVIDER: 'c' * 64, g.ADAPTER: 'd' * 64}
        if variant == 'mixed': current[g.ADAPTER] = 'b' * 64
        if variant in ('truncated', 'unowned'): current[g.ADAPTER] = g.digest(b'')
        history = [{}] * 40 + [{'kind': 'infrastructure_resume'}]
        if variant == 'truncated': history += [{'event': 'failure', 'kind': 'resume', 'owned_state': dict(current)}]
        recorded, restored = [], []
        def restore(base, paths):
            restored.extend(paths)
            for path in paths: current[path] = base['originals'][path]['sha256']
        with patch.dict(globals(), authorization=lambda: (value, history)), patch.object(g, 'load', lambda _: base), patch.object(g, 'check_hashes', lambda _: None), patch.object(g, 'sdk_files', lambda: set(g.NEW_TESTS)), patch.object(g, 'sha', lambda path: current.get(path, 'e' * 64)), patch.dict(globals(), restore_owned=lambda base: restore(base, [g.ADAPTER, g.PROVIDER])), patch.object(g, 'hashes', lambda paths: dict(current)), patch.object(g, 'append', recorded.append):
            try: rollback()
            except g.GateError: g.require(variant == 'unowned' and not restored, 'self_test_failure')
            else: g.require(variant != 'unowned' and len(restored) == 2 and recorded[0]['rollback'] == 'production_restored', 'self_test_failure')
        count += 1
    recorded = []
    with patch.object(g, 'sha', lambda path: 'e' * 64), patch.object(g, 'append', recorded.append):
        g.require(record_failure('resume', OSError('synthetic sensitive details')) == 'infrastructure_failure', 'self_test_failure')
    g.require(len(recorded) == 1 and recorded[0]['event'] == 'failure'
              and 'synthetic sensitive details' not in g.encode(recorded), 'self_test_failure'); count += 1
    # Inject failures through the real atomic replacement operation; all file
    # descriptors/content are synthetic, including a partially written stage.
    from types import SimpleNamespace
    for point in ('open', 'chmod', 'write', 'flush', 'fsync', 'replace', 'after_replace', 'none'):
        staged, live = {}, [b'original']
        def fail(name):
            if point == name: raise OSError('injected')
        class FakeTarget:
            def stat(self): return SimpleNamespace(st_mode=0o100644)
        class FakeStream:
            def __enter__(self): return self
            def __exit__(self, *args): pass
            def fileno(self): return 12345
            def write(self, data):
                staged['synthetic-stage'] = data[:2] if point == 'write' else data
                fail('write')
            def flush(self): fail('flush')
        def stage(**kwargs):
            staged['synthetic-stage'] = b''
            return 12345, 'synthetic-stage'
        def open_stage(fd, mode): fail('open'); return FakeStream()
        def replace_stage(src, dst):
            fail('replace'); live[0] = staged.pop(src); fail('after_replace')
        with patch.object(g, 'safe_path', lambda _: FakeTarget()), patch.object(tempfile, 'mkstemp', stage), patch.object(os, 'fdopen', open_stage), patch.object(os, 'close', lambda fd: None), patch.object(os, 'fchmod', lambda *args: fail('chmod')), patch.object(os, 'fsync', lambda *args: fail('fsync')), patch.object(os, 'replace', replace_stage), patch.object(os.path, 'exists', lambda path: path in staged), patch.object(os, 'unlink', lambda path: staged.pop(path)):
            try: replace_owned(g.PROVIDER, b'candidate')
            except OSError: g.require(point != 'none', 'self_test_failure')
            else: g.require(point == 'none', 'self_test_failure')
        g.require(not staged and live[0] == (b'candidate' if point in ('after_replace', 'none') else b'original'), 'self_test_failure')
        count += 1
    print('PHASE93_TIMEOUT_SELF_TEST passed=' + str(count) + ' failed=0 skipped=0')


if __name__ == '__main__':
    if sys.argv[1:] == ['self-test']: self_test()
    else:
        g.identity = identity; g.authorities = authorities; g.accepted = accepted; g.run_methods = run_methods
        command = sys.argv[1] if len(sys.argv) > 1 else ''
        if command in ('resume', 'accept', 'rollback') and len(sys.argv) == 2:
            try:
                {'resume': resume, 'accept': accept, 'rollback': rollback}[command]()
                print('PHASE93_TIMEOUT status=pass command=' + command)
            except (g.GateError, OSError, ValueError) as error:
                category = record_failure(command, error)
                print('PHASE93_TIMEOUT status=failed category=' + category); raise SystemExit(2)
        else:
            g.require(command in ('authorities', 'provider', 'registration', 'metrics', 'pixels', 'lifecycle', 'compatibility', 'closeout'), 'invalid_command')
            raise SystemExit(g.main())
