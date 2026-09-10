#!/usr/bin/env python3
"""Owner-authorized recovery; delegate all effect verdicts to the frozen gate."""
import hashlib
import importlib.util
import json
import os
import re
from pathlib import Path
import sys
import time

ROOT = Path(__file__).resolve().parent.parent
REL = 'scripts/check-phase93-attempt2.py'
PHASE = '.planning/phases/93-distinct-nose-bridge-and-root-repairs/'
spec = importlib.util.spec_from_file_location('phase93_frozen', ROOT / 'scripts/check-phase93-nose-repair.py')
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)
original_identity = g.identity
original_authorities = g.authorities
original_finish = g.finish
ALLOW_FAILED_FINISH = False


def authorization():
    value = json.loads(g.read_bytes(PHASE + '93-ATTEMPT2.json'), object_pairs_hook=g.no_duplicates)
    g.require(set(value) == {'schema', 'phase', 'attempt', 'runner', 'pins', 'ledger_prefix_sha256',
                             'candidate_provider', 'restored_adapter', 'adapter_commit'}, 'invalid_record')
    g.require(value['schema'] == 1 and value['phase'] == 93 and value['attempt'] == 2, 'attempt_limit')
    required = {g.GATE, PHASE + '93-ATTEMPT2-AUTHORIZATION.md'} | set(g.NEW_TESTS) | {g.SPI, g.REGRESSION, g.PROVIDER_TEST}
    required |= {PHASE + '93-' + name + '.json' for name in ('BASELINE', 'REGISTRATION', 'RED', 'PROVIDER-RED', 'GATE-AMENDMENT', 'METADATA-AMENDMENT', 'REDACTION-AMENDMENT')}
    g.require(type(value['pins']) is dict and set(value['pins']) == required, 'invalid_record')
    g.require(all(type(h) is str and re.fullmatch('[0-9a-f]{64}', h) for h in list(value['pins'].values()) + [value[k] for k in ('runner', 'ledger_prefix_sha256', 'candidate_provider', 'restored_adapter')])
              and type(value['adapter_commit']) is str and re.fullmatch('[0-9a-f]{40}', value['adapter_commit']), 'invalid_record')
    g.require(g.sha(REL) == value['runner'], 'hash_drift')
    g.check_hashes(value['pins'])
    report = g.read_bytes(PHASE + '93-ATTEMPT2-REVIEW.md').decode()
    review_verdict(report, value)
    history = g.events()
    validate_history(history, value, g.read_bytes(PHASE + '93-ATTEMPTS.md'))
    second = [e for e in history if e['event'] == 'begin' and e['attempt'] == 2]
    if second:
        g.require(second[0]['sequence'] == 27 and second[0]['authorization'] == g.sha(PHASE + '93-ATTEMPT2.json')
                  and second[0]['identity'][REL] == value['runner']
                  and second[0]['identity'][g.GATE] == g.sha(g.GATE)
                  and second[0]['review'] == g.sha(PHASE + '93-ATTEMPT2-REVIEW.md'), 'hash_drift')
    return value, history


def review_verdict(report, value):
    # Deliberately accept only flat, unquoted scalar YAML frontmatter.
    # Reject unsupported YAML instead of guessing at its meaning.
    lines = report.splitlines()
    g.require(lines and lines[0] == '---' and '---' in lines[1:], 'review_pending')
    end = lines.index('---', 1)
    pairs = []
    for line in lines[1:end]:
        match = re.fullmatch(r'([a-z_]+): ([A-Za-z0-9_.:/ -]+)', line)
        g.require(match is not None, 'review_pending')
        pairs.append(match.groups())
    fields = g.no_duplicates(pairs)
    g.require(set(fields) == {'phase', 'reviewed', 'status', 'blockers', 'candidate_sha', 'runner_sha'}
              and fields['phase'] == '93' and fields['status'] == 'clean'
              and fields['blockers'] == '0'
              and fields['candidate_sha'] == value['candidate_provider']
              and fields['runner_sha'] == value['runner'], 'review_pending')


def failure_latch(history, allow_failed_finish=False):
    second = [e for e in history if e['event'] == 'begin' and e['attempt'] == 2]
    if second:
        failures = [e for e in history[second[0]['sequence']:] if e['event'] == 'failure']
        g.require(not failures or allow_failed_finish, 'attempt_failed')


def finish(attempt, status):
    global ALLOW_FAILED_FINISH
    ALLOW_FAILED_FINISH = attempt == 2 and status == 'failed'
    try:
        base = authorities()
        history = g.events()
        ended = [e for e in history if e['event'] == 'finish' and e['attempt'] == 2]
        if ended and ALLOW_FAILED_FINISH:
            # A post-acceptance compatibility failure invalidates acceptance.
            # Preserve the original finish and append a separate rollback receipt.
            g.require(ended[0]['status'] == 'passed'
                      and any(e['event'] == 'failure' for e in history[ended[0]['sequence']:]), 'attempt_order')
            before = identity()
            g.restore_original(base, [g.ADAPTER, g.PROVIDER])
            g.append({'event': 'receipt', 'kind': 'recovery_rollback', 'attempt': 2,
                      'category': 'attempt_failed', 'identity': before,
                      'rollback': 'production_restored',
                      'restored': g.hashes([g.ADAPTER, g.PROVIDER]), 'timestamp': int(time.time())})
            return
        if ALLOW_FAILED_FINISH:
            starts = [e for e in history if e['event'] == 'begin']
            ends = [e for e in history if e['event'] == 'finish']
            g.require(len(starts) == 2 and len(ends) == 1, 'attempt_order')
            failures = [e for e in history[starts[-1]['sequence']:] if e['event'] == 'failure']
            last = failures[-1] if failures else {}
            before = identity()
            # Rollback must not depend on the latest successful receipts.
            g.restore_original(base, [g.ADAPTER, g.PROVIDER])
            g.append({'event': 'finish', 'attempt': 2, 'status': 'failed',
                      'category': last.get('category', 'registration_prerequisite'),
                      'counts': last.get('counts', {'discovered': 0, 'passed': 0, 'failed': 0, 'skipped': 0}),
                      'identity': before, 'rollback': 'production_restored',
                      'restored': g.hashes([g.ADAPTER, g.PROVIDER]),
                      'independent_review': 'pending', 'timestamp': int(time.time())})
            return
        return original_finish(attempt, status)
    finally:
        ALLOW_FAILED_FINISH = False


def validate_history(history, value, ledger):
    g.require(len(history) >= 26, 'ledger_failure')
    prefix = b'\n'.join(ledger.splitlines()[:len(g.LEDGER_HEADER.splitlines()) + 26]) + b'\n'
    g.require(g.digest(prefix) == value['ledger_prefix_sha256'], 'ledger_failure')
    terminal = history[25]
    g.require(terminal['event'] == 'finish' and terminal['attempt'] == 1
              and terminal['status'] == 'failed' and terminal['category'] == 'assertion_failure'
              and terminal['rollback'] == 'production_restored', 'attempt_order')
    starts = [e for e in history if e['event'] == 'begin']
    ends = [e for e in history if e['event'] == 'finish']
    g.require([e['attempt'] for e in starts] in ([1], [1, 2])
              and [e['attempt'] for e in ends] in ([1], [1, 2])
              and len(ends) <= len(starts), 'attempt_order')


def identity():
    return dict(original_identity(), **{REL: g.sha(REL)})


def authorities():
    value, history = authorization()
    failure_latch(history, ALLOW_FAILED_FINISH)
    g.require(any(e['event'] == 'begin' and e['attempt'] == 2 for e in history), 'attempt_order')
    g.require(g.sha(g.PROVIDER) == value['candidate_provider']
              and g.sha(g.ADAPTER) == value['restored_adapter'], 'hash_drift')
    return original_authorities()


def begin(attempt):
    value, history = authorization()
    g.require(attempt == 2 and len(history) == 26, 'attempt_order')
    base = g.load('BASELINE')
    g.check_hashes(base['frozen'])
    g.check_hashes(base['fixture'])
    g.require(g.sdk_files() - set(g.NEW_TESTS) == set(base['sdk_inventory']), 'source_inventory')
    g.source_scope(base)
    for name in (g.ADAPTER, g.PROVIDER):
        g.require(g.sha(name) == base['originals'][name]['sha256'], 'rollback_failure')
    for name in ('REGISTRATION', 'RED', 'PROVIDER-RED'):
        binding = g.load(name)
        g.require(binding['phase'] == 93 and binding['gate'] == g.sha(g.GATE), 'hash_drift')
        g.check_hashes({p: h for p, h in binding['immutable'].items() if p != g.ADAPTER})
        if g.ADAPTER in binding['immutable']:
            g.require(binding['immutable'][g.ADAPTER] == value['restored_adapter'], 'hash_drift')
    adapter = g.child(['git', 'show', value['adapter_commit'] + ':' + g.ADAPTER])[1].encode()
    g.require(g.digest(adapter) == value['restored_adapter'], 'hash_drift')
    g.append({'event': 'begin', 'attempt': 2, 'identity': identity(),
              'authorization': g.sha(PHASE + '93-ATTEMPT2.json'),
              'review': g.sha(PHASE + '93-ATTEMPT2-REVIEW.md'),
              'independent_review': 'pending', 'timestamp': int(time.time())})
    fd = os.open(g.safe_path(g.ADAPTER), os.O_WRONLY | os.O_TRUNC | os.O_NOFOLLOW)
    with os.fdopen(fd, 'wb') as stream:
        stream.write(adapter)
        stream.flush()
        os.fsync(stream.fileno())
    g.require(g.sha(g.ADAPTER) == value['restored_adapter'], 'rollback_failure')


def self_test():
    checks = g.self_test()
    # Admission tests are memory-only; never append, restore or launch Swift.
    prefix = (g.LEDGER_HEADER + ''.join('row\n' for _ in range(26))).encode()
    history = [{'event': 'receipt'} for _ in range(26)]
    history[0] = {'event': 'begin', 'attempt': 1}
    history[25] = {'event': 'finish', 'attempt': 1, 'status': 'failed',
                   'category': 'assertion_failure', 'rollback': 'production_restored'}
    value = {'ledger_prefix_sha256': g.digest(prefix)}
    validate_history(history, value, prefix)
    checks += 1
    for mutation in ('prefix', 'category', 'rollback', 'third', 'missing'):
        rows = [dict(e) for e in history]
        data = prefix
        if mutation == 'prefix': data = b'x' + prefix
        if mutation == 'category': rows[25]['category'] = 'other'
        if mutation == 'rollback': rows[25]['rollback'] = 'provider_restored'
        if mutation == 'third': rows += [{'event': 'begin', 'attempt': 2}, {'event': 'begin', 'attempt': 3}]
        if mutation == 'missing': rows = rows[:-1]
        try:
            validate_history(rows, value, data)
        except g.GateError:
            checks += 1
        else:
            raise g.GateError('self_test_failure')
    review_value = {'candidate_provider': 'a' * 64, 'runner': 'b' * 64}
    clean = ('---\nphase: 93\nreviewed: 2026-09-10\nstatus: clean\nblockers: 0\n'
             'candidate_sha: ' + 'a' * 64 + '\nrunner_sha: ' + 'b' * 64 + '\n---\nBody\n')
    review_verdict(clean, review_value)
    checks += 1
    bad_reports = [
        clean.replace('status: clean', 'status: issues_found') + '```\nstatus: clean\nblockers: 0\n```',
        clean.replace('blockers: 0', 'blockers: 1'),
        clean.replace('blockers: 0', 'blockers: 0\nblockers: 0'),
        clean.replace('status: clean', 'status: clean\nstatus: issues_found'),
        clean.replace('blockers: 0', 'blockers: false'),
        clean.replace('blockers: 0', 'blockers: "0"'),
        clean.replace('blockers: 0\n', ''),
        clean.replace('a' * 64, 'c' * 64),
        clean.removeprefix('---\n'),
    ]
    for bad in bad_reports:
        try: review_verdict(bad, review_value)
        except g.GateError: checks += 1
        else: raise g.GateError('self_test_failure')
    begun = history + [{'event': 'begin', 'attempt': 2, 'sequence': 27}]
    failure_latch(begun)
    checks += 1
    for category, ended in [('assertion_failure', False), ('semantic_signal', False), ('assertion_failure', True)]:
        rows = begun + ([{'event': 'finish', 'attempt': 2, 'status': 'passed'}] if ended else [])
        rows += [{'event': 'failure', 'category': category}, {'event': 'receipt', 'category': 'passed'}]
        try: failure_latch(rows)
        except g.GateError: checks += 1
        else: raise g.GateError('self_test_failure')
        failure_latch(rows, allow_failed_finish=True)
        checks += 1
    # Exercise the real failed-finish wrapper with complete receipts in memory.
    # No ledger, source, subprocess or production authority operation is called.
    saved = (globals()['authorities'], globals()['identity'], g.events, g.restore_original, g.hashes, g.append)
    try:
        globals()['authorities'] = lambda: {}
        globals()['identity'] = lambda: {}
        for already_finished in (False, True):
            rows = begun + [{'event': 'receipt', 'kind': name, 'category': 'passed'}
                            for name in ('provider_green', 'registration_green', 'metrics', 'pixels', 'lifecycle')]
            if already_finished:
                rows += [{'event': 'finish', 'attempt': 2, 'status': 'passed', 'sequence': len(rows) + 1}]
            rows += [{'event': 'failure', 'category': 'assertion_failure'}]
            restored, recorded = [], []
            g.events = lambda: rows
            g.restore_original = lambda base, paths: restored.extend(paths)
            g.hashes = lambda paths: {}
            g.append = recorded.append
            finish(2, 'failed')
            g.require(restored == [g.ADAPTER, g.PROVIDER] and len(recorded) == 1
                      and recorded[0]['rollback'] == 'production_restored'
                      and recorded[0]['event'] == ('receipt' if already_finished else 'finish')
                      and not ALLOW_FAILED_FINISH, 'self_test_failure')
            checks += 1
    finally:
        globals()['authorities'], globals()['identity'], g.events, g.restore_original, g.hashes, g.append = saved
    print(f'PHASE93_RECOVERY_SELF_TEST passed={checks} failed=0 skipped=0')


if __name__ == '__main__':
    if sys.argv[1:] == ['self-test']:
        self_test()
    else:
        g.identity = identity
        g.authorities = authorities
        g.begin = begin
        g.finish = finish
        # Rebinding or baseline generation is never part of this recovery.
        g.require(len(sys.argv) > 1 and sys.argv[1] in
                  ('begin', 'authorities', 'provider', 'registration', 'metrics', 'pixels',
                   'lifecycle', 'finish', 'compatibility', 'closeout'), 'invalid_command')
        raise SystemExit(g.main())
