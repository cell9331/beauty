#!/usr/bin/env python3
"""One reviewed compile-only continuation; original Phase94 evidence stays immutable.

Commands: self-test/status are read-only; registration/baseline are explicit native
lanes for later parent execution. No resume/reset, amendment creation or installs.
"""
import hashlib
import json
from pathlib import Path
import re
import sys
import time
import types

ROOT = Path(__file__).resolve().parent.parent
REL = 'scripts/check-phase94-compile-recovery.py'
PHASE = '.planning/phases/94-negative-mouth-width-repair/'
AMENDMENT = PHASE + '94-COMPILE-AMENDMENT.json'
EVENTS = PHASE + '94-COMPILE-EVENTS.jsonl'
RECEIPT = PHASE + '94-COMPILE-BASELINE.json'
OLD_RUNNER = '9135d44c7dc9012429f79f30e2ae0e0825ec2011a89814d6ff70b00481385afc'
OLD_BINDING = '37e3ac69512a93b757a3984f1d68b732860528515a0f5b48e91f6f3107dcef0c'
OLD_EVENTS = '544875bf1082b4336bb49f9e6f4843cf7162bc7271ce38bdb15fc0ac025ddafb'
BEFORE = '1252b414807e7a6a67b8dfec23b41d9a7d12b4c4f9cb48b3b1070d541886d335'
AFTER = 'f707e60fa2246d1cd589c9d9e8b932093f251fa0d47b1708f271a5f2cf1a14c3'
OLD_EXPRESSION = '''        XCTAssertTrue(stride(from: 0, to: bytes.count, by: 4).allSatisfy {
            bytes[$0] == bytes[$0 + 1] && bytes[$0] == bytes[$0 + 2] && bytes[$0 + 3] == 255
        }, "P94_SOURCE_CHANNELS")
'''
NEW_EXPRESSION = '''        var sourceChannelsAreValid = true
        for offset in stride(from: 0, to: bytes.count, by: 4) {
            let isGrayscale = bytes[offset] == bytes[offset + 1] && bytes[offset] == bytes[offset + 2]
            if !isGrayscale || bytes[offset + 3] != 255 {
                sourceChannelsAreValid = false
                break
            }
        }
        XCTAssertTrue(sourceChannelsAreValid, "P94_SOURCE_CHANNELS")
'''


def digest(data):
    return hashlib.sha256(data).hexdigest()


def load_helpers():
    # Verify before executing the reused helpers; exec avoids import cache writes.
    file = ROOT / 'scripts/check-phase94-mouth-repair.py'
    if file.is_symlink() or digest(file.read_bytes()) != OLD_RUNNER:
        raise ValueError('original_runner_drift')
    module = types.ModuleType('phase94_frozen_helpers')
    module.__file__ = str(file)
    exec(compile(file.read_bytes(), str(file), 'exec'), module.__dict__)
    return module


try:
    g = load_helpers()
except (OSError, ValueError):
    print('{"status":"gate_rejected","category":"authority_drift","phase_complete":false}')
    sys.exit(1)


def strict_json(raw):
    def pairs(items):
        result = {}
        for key, value in items:
            g.require(key not in result, 'binding_failure')
            result[key] = value
        return result
    return json.loads(raw, object_pairs_hook=pairs,
                      parse_constant=lambda _: (_ for _ in ()).throw(g.GateError('binding_failure')))


def expected_amendment(runner_sha):
    return dict(schema=1, scope='compile_only_prerequisites', original_commit='900bb7ad',
                original_runner=OLD_RUNNER, original_binding=OLD_BINDING,
                original_events=OLD_EVENTS, original_event_count=4,
                registration_before=BEFORE, registration_after=AFTER,
                runner=runner_sha, counters=g.COUNTERS,
                diagnostic=dict(provenance='parent_diagnostic_only', stage='build', exit_code=1,
                                category='type_check_timeout', file=g.REG, line=19, column=9),
                post_patch_diagnostic=dict(provenance='parent_diagnostic_only', stage='build',
                                           exit_code=0, errors=0, tests_executed=0, acceptance=False))


def validate_amendment(value, runner_sha):
    g.require(g.encoded(value) == g.encoded(expected_amendment(runner_sha)), 'binding_failure')


def validate_patch(data):
    g.require(digest(data) == AFTER, 'source_scope')
    new = NEW_EXPRESSION.encode()
    old = OLD_EXPRESSION.encode()
    g.require(data.count(new) == 1 and old not in data
              and digest(data.replace(new, old)) == BEFORE, 'source_scope')


def validate_original(binding_raw, events_raw):
    g.require(digest(binding_raw) == OLD_BINDING and digest(events_raw) == OLD_EVENTS, 'event_history')
    base = strict_json(binding_raw)
    history = [strict_json(line) for line in events_raw.splitlines()]
    g.validate_events(history, OLD_BINDING)
    g.require([e['event'] for e in history] == ['source_locked', 'registration_inputs', 'failure', 'terminal_hold'],
              'event_history')
    g.require(all(e['counts'] == g.empty_counts(3) for e in history[1:])
              and all(e['category'] == 'child_failure' for e in history[2:])
              and history[1]['inputs'][g.REG] == BEFORE, 'event_history')
    return base, history


def authority():
    g.require(digest(g.read(g.GATE)) == OLD_RUNNER, 'authority_drift')
    amendment_raw = g.read(AMENDMENT)
    amendment = strict_json(amendment_raw)
    validate_amendment(amendment, digest(g.read(REL)))
    g.require(amendment_raw == g.encoded(amendment) + b'\n', 'binding_failure')
    base, history = validate_original(g.read(g.BINDING), g.read(g.EVENTS))
    # This checks all frozen source/package/test/recipe/manifest/plan authorities,
    # including the original runner and exact additive SPI normalization.
    g.identities(base)
    validate_patch(g.read(g.REG))
    for name, sha in history[1]['inputs'].items():
        if name != g.REG:
            g.require(digest(g.read(name)) == sha, 'authority_drift')
    g.require(not g.path(g.BASELINE).exists(), 'receipt_failure')
    return digest(amendment_raw)


def inputs(lane):
    files = [REL, g.GATE, g.FIXTURE, g.SPI, g.REG]
    if lane == 'baseline':
        files += [g.ORACLE, g.PUBLIC]
    return g.hashes(files)


def validate_counts(counts, total, green=False):
    g.check_counts(counts)
    g.require(counts['executed'] + counts['unexecuted'] == total
              and counts['passed'] + counts['failed'] + counts['skipped'] <= counts['executed'], 'event_history')
    if green:
        g.require(counts == dict(discovered=total, executed=total, passed=total,
                                 failed=0, skipped=0, unexecuted=0), 'event_history')


def event(history, kind, amendment, lane, frozen, counts, stage='none', exit_code=None, category=None, receipt=None):
    return dict(sequence=len(history), previous=digest(g.encoded(history[-1])) if history else amendment,
                amendment=amendment, original_events=OLD_EVENTS, event=kind, lane=lane,
                inputs=frozen, counts=counts.copy(), counters=g.COUNTERS, stage=stage,
                exit_code=exit_code, category=category, receipt=receipt)


def validate_history(history, amendment):
    keys = set(event([], 'registration_started', amendment, 'registration', {}, g.empty_counts(3)))
    state = 'ready'
    last_inputs = None
    for i, item in enumerate(history):
        g.require(type(item) is dict and set(item) == keys and item['sequence'] == i
                  and type(item['sequence']) is int and item['amendment'] == amendment
                  and item['original_events'] == OLD_EVENTS
                  and item['previous'] == (digest(g.encoded(history[i-1])) if i else amendment), 'event_history')
        g.validate_counters(item['counters'])
        lane = item['lane']
        g.require(lane in ('registration', 'baseline'), 'event_history')
        total = 3 if lane == 'registration' else 9
        validate_counts(item['counts'], total)
        allowed_inputs = {REL, g.GATE, g.FIXTURE, g.SPI, g.REG}
        if lane == 'baseline':
            allowed_inputs |= {g.ORACLE, g.PUBLIC}
        g.require(type(item['inputs']) is dict and set(item['inputs']) == allowed_inputs
                  and all(g.is_hash(v) for v in item['inputs'].values()), 'event_history')
        kind = item['event']
        if kind in ('registration_started', 'baseline_started'):
            g.require((kind, lane, state) in (('registration_started', 'registration', 'ready'),
                                             ('baseline_started', 'baseline', 'registration_green'))
                      and item['counts'] == g.empty_counts(total), 'event_history')
            last_inputs = item['inputs']
            state = kind
        else:
            g.require(state == lane + '_started' and item['inputs'] == last_inputs, 'event_history')
            if kind == 'terminal_hold':
                g.require(item['category'] in g.CATEGORIES | {'interrupted_lane'}
                          and item['stage'] in ('admission', 'build', 'discovery', 'test', 'finalize')
                          and (item['exit_code'] is None or (type(item['exit_code']) is int
                               and -255 <= item['exit_code'] <= 255)) and item['receipt'] is None, 'event_history')
                state = 'terminal_hold'
            else:
                wanted = 'registration_green' if lane == 'registration' else 'prerequisite_green_phase_incomplete'
                g.require(kind == wanted, 'event_history')
                validate_counts(item['counts'], total, green=True)
                state = kind
        if kind != 'terminal_hold':
            g.require(item['stage'] == 'none' and item['exit_code'] is None and item['category'] is None, 'event_history')
            if kind == 'prerequisite_green_phase_incomplete':
                g.require(g.is_hash(item['receipt']), 'event_history')
            else:
                g.require(item['receipt'] is None, 'event_history')
    return state


def read_history(amendment):
    if not g.path(EVENTS).exists():
        g.require(not g.path(RECEIPT).exists(), 'event_history')
        return []
    raw = g.read(EVENTS)
    g.require(raw.endswith(b'\n') and raw, 'event_history')
    history = [strict_json(line) for line in raw.splitlines()]
    g.require(raw == b''.join(g.encoded(e)+b'\n' for e in history), 'event_history')
    validate_history(history, amendment)
    for item in history:
        g.compare_hashes(item['inputs'], g.hashes(item['inputs']))
    return history


def append(history, item, amendment):
    validate_history(history + [item], amendment)
    # Only successor artifacts are writable. Originals have no write path.
    p = g.path(EVENTS)
    if history:
        g.require(g.read(EVENTS) == b''.join(g.encoded(e)+b'\n' for e in history), 'event_history')
    else:
        g.require(not p.exists() and not g.path(RECEIPT).exists(), 'event_history')
    with p.open('ab' if history else 'xb') as stream:
        stream.write(g.encoded(item)+b'\n')
        stream.flush()
        g.os.fsync(stream.fileno())
    history.append(item)


def validate_records(records):
    g.require(type(records) is list, 'aggregate_schema')
    for record in records:
        g.aggregate(record)
    g.require(sorted(r['case'] for r in records) == sorted(['positive', 'source', *g.ROWS]), 'aggregate_schema')


def receipt_check(history, amendment):
    green = history and history[-1]['event'] == 'prerequisite_green_phase_incomplete'
    if not green:
        g.require(not g.path(RECEIPT).exists(), 'receipt_failure')
        return
    raw = g.read(RECEIPT)
    g.require(digest(raw) == history[-1]['receipt'], 'receipt_failure')
    value = strict_json(raw)
    expected_keys = {'amendment', 'original_binding', 'original_events', 'event_prefix', 'inputs',
                     'counts', 'counters', 'records', 'requirement', 'negative_pixels'}
    g.require(set(value) == expected_keys and value['amendment'] == amendment
              and value['original_binding'] == OLD_BINDING and value['original_events'] == OLD_EVENTS
              and value['event_prefix'] == digest(b''.join(g.encoded(e)+b'\n' for e in history[:-1]))
              and value['inputs'] == history[-1]['inputs'] and value['counts'] == history[-1]['counts']
              and value['requirement'] == 'MOUTH-01-incomplete' and value['negative_pixels'] == 'not_measured', 'receipt_failure')
    g.validate_counters(value['counters'])
    validate_records(value['records'])


def snapshot():
    amendment = authority()
    history = read_history(amendment)
    state = validate_history(history, amendment)
    receipt_check(history, amendment)
    return amendment, history, state


def result(state, amendment, history):
    value = dict(status=state, amendment=amendment, original_events=OLD_EVENTS, **g.COUNTERS)
    if history:
        value.update(events=digest(g.read(EVENTS)), counts=history[-1]['counts'])
        if state == 'terminal_hold':
            value.update(category=history[-1]['category'], stage=history[-1]['stage'], exit_code=history[-1]['exit_code'])
    return value


def run(lane):
    amendment, history, state = snapshot()
    g.require(state == ('ready' if lane == 'registration' else 'registration_green'), 'terminal_hold')
    frozen = inputs(lane)
    methods = g.REGISTRATION if lane == 'registration' else g.BASE_METHODS
    counts = g.empty_counts(len(methods))
    append(history, event(history, lane+'_started', amendment, lane, frozen, counts), amendment)
    g.DEADLINE = time.monotonic() + (1410 if lane == 'registration' else 2130) - 30
    stage = 'admission'
    code = None
    def recheck():
        authority()
        g.compare_hashes(frozen, inputs(lane))
        g.require(g.read(EVENTS) == b''.join(g.encoded(e)+b'\n' for e in history), 'event_history')
    try:
        for stage, args in [('build', ['swift', 'build', '--package-path', 'BeautySDK', '--build-tests']),
                            ('discovery', ['swift', 'test', '--package-path', 'BeautySDK', 'list'])]:
            code = None
            recheck()
            code, output = g.child(args, 600)
            g.require(code == 0, 'child_failure')
        found = re.findall(r'^([A-Za-z0-9_]+\.[A-Za-z0-9_]+/test[A-Za-z0-9_]+)$', output, re.M)
        counts['discovered'] = min(56, sum(found.count(m) for m in methods))
        g.discover(output, methods)
        records = []
        stage = 'test'
        for method in methods:
            code = None
            recheck()
            timeout = 120 if method == g.BASE_METHODS[5] else 360 if method == g.BASE_METHODS[6] else 60
            code, output = g.child(['swift', 'test', '--package-path', 'BeautySDK', '--skip-build',
                                    '--filter', '^'+re.escape(method)+'$'], timeout)
            identity = method.replace('/', ' ')
            if f"Test Case '-[{identity}]' started." in output:
                counts['executed'] += 1
                counts['unexecuted'] -= 1
                if re.search(r'\bskipped\b', output, re.I):
                    counts['skipped'] += 1
                elif f"Test Case '-[{identity}]' failed" in output:
                    counts['failed'] += 1
            g.classify(output, code, method)
            counts['passed'] += 1
            parsed = g.parse_aggregates(output)
            expected = ['positive'] if method == g.BASE_METHODS[5] else [*g.ROWS, 'source'] if method == g.BASE_METHODS[6] else []
            g.require(sorted(r['case'] for r in parsed) == sorted(expected), 'aggregate_schema')
            records.extend(parsed)
        stage, code = 'finalize', None
        recheck()
        receipt = None
        if lane == 'baseline':
            validate_records(records)
            value = dict(amendment=amendment, original_binding=OLD_BINDING, original_events=OLD_EVENTS,
                         event_prefix=digest(g.read(EVENTS)), inputs=frozen, counts=counts,
                         counters=g.COUNTERS, records=records, requirement='MOUTH-01-incomplete', negative_pixels='not_measured')
            raw = g.encoded(value)+b'\n'
            with g.path(RECEIPT).open('xb') as stream:
                stream.write(raw)
                stream.flush()
                g.os.fsync(stream.fileno())
            receipt = digest(raw)
        state = 'registration_green' if lane == 'registration' else 'prerequisite_green_phase_incomplete'
        append(history, event(history, state, amendment, lane, frozen, counts, receipt=receipt), amendment)
        return result(state, amendment, history), 0
    except (g.GateError, OSError, ValueError, TypeError):
        error = sys.exc_info()[1]
        category = str(error) if isinstance(error, g.GateError) and str(error) in g.CATEGORIES else 'infrastructure_failure'
        append(history, event(history, 'terminal_hold', amendment, lane, frozen, counts,
                              stage=stage, exit_code=code, category=category), amendment)
        return result('terminal_hold', amendment, history), 1


def self_test():
    amendment, history, state = snapshot()
    g.require(state in ('ready', 'registration_green', 'prerequisite_green_phase_incomplete'), 'terminal_hold')
    passed = 0
    def check(fn):
        nonlocal passed
        fn()
        passed += 1
    def rejects(fn):
        try:
            fn()
        except (g.GateError, ValueError, TypeError):
            return
        raise AssertionError('mutation_admitted')
    def mutate_amend(key, value):
        altered = expected_amendment(digest(g.read(REL)))
        altered[key] = value
        validate_amendment(altered, digest(g.read(REL)))
    check(lambda: validate_amendment(strict_json(g.read(AMENDMENT)), digest(g.read(REL))))
    check(lambda: validate_original(g.read(g.BINDING), g.read(g.EVENTS)))
    check(lambda: validate_patch(g.read(g.REG)))
    for key in ('original_runner', 'original_binding', 'original_events', 'registration_before', 'registration_after', 'runner'):
        check(lambda key=key: rejects(lambda: mutate_amend(key, '0'*64)))
    check(lambda: rejects(lambda: mutate_amend('original_event_count', 3)))
    check(lambda: rejects(lambda: mutate_amend('counters', dict(g.COUNTERS, implementation_attempts=1))))
    check(lambda: rejects(lambda: mutate_amend('diagnostic', dict(expected_amendment('0'*64)['diagnostic'], line=20))))
    check(lambda: rejects(lambda: mutate_amend('unknown', True)))
    check(lambda: rejects(lambda: strict_json(b'{"schema":1,"schema":1}')))
    check(lambda: rejects(lambda: validate_original(g.read(g.BINDING), g.read(g.EVENTS)[:-1])))
    changed = g.read(g.EVENTS).replace(b'child_failure', b'assertion_failure')
    check(lambda: rejects(lambda: validate_original(g.read(g.BINDING), changed)))
    check(lambda: rejects(lambda: validate_patch(g.read(g.REG).replace(NEW_EXPRESSION.encode(), OLD_EXPRESSION.encode()))))
    check(lambda: rejects(lambda: validate_patch(g.read(g.REG)+b'\n')))
    # Source predicate equivalence is independently evaluated over channel/alpha
    # boundaries, every channel mismatch and a late failing pixel after valid data.
    def equivalent():
        samples = [bytes((r, a, b, alpha)) for r in (0, 1, 80, 144, 240, 255)
                   for a in (r, (r+1) % 256) for b in (r, (r+1) % 256) for alpha in (0, 254, 255)]
        for pixels in [b'', bytes((80,80,80,255))] + samples + [bytes((80,80,80,255))+p for p in samples]:
            old = all(pixels[i] == pixels[i+1] and pixels[i] == pixels[i+2] and pixels[i+3] == 255
                      for i in range(0, len(pixels), 4))
            new = True
            for offset in range(0, len(pixels), 4):
                grayscale = pixels[offset] == pixels[offset+1] and pixels[offset] == pixels[offset+2]
                if not grayscale or pixels[offset+3] != 255:
                    new = False
                    break
            g.require(old == new, 'self_test_failure')
    check(equivalent)
    frozen = inputs('registration')
    started = event([], 'registration_started', amendment, 'registration', frozen, g.empty_counts(3))
    check(lambda: validate_history([started], amendment))
    for key, value in [('previous', '0'*64), ('sequence', 1), ('amendment', '0'*64), ('unknown', 1)]:
        altered = dict(started, **{key: value})
        check(lambda altered=altered: rejects(lambda: validate_history([altered], amendment)))
    hold = event([started], 'terminal_hold', amendment, 'registration', frozen, g.empty_counts(3),
                 stage='build', exit_code=1, category='child_failure')
    check(lambda: validate_history([started, hold], amendment))
    restart = event([started, hold], 'registration_started', amendment, 'registration', frozen, g.empty_counts(3))
    check(lambda: rejects(lambda: validate_history([started, hold, restart], amendment)))
    fake_green = event([started], 'registration_green', amendment, 'registration', frozen, g.empty_counts(3))
    check(lambda: rejects(lambda: validate_history([started, fake_green], amendment)))
    check(lambda: rejects(lambda: validate_records([])))
    method = g.REGISTRATION[0]
    check(lambda: g.discover(method+'\n', [method]))
    check(lambda: rejects(lambda: g.discover('', [method])))
    check(lambda: rejects(lambda: g.discover(method+'\n'+method+'\n', [method])))
    text = (f"Test Case '-[{method.replace('/', ' ')}]' started.\n"
            f"Test Case '-[{method.replace('/', ' ')}]' passed (0.001 seconds).\n"
            'Executed 1 test, with 0 failures (0 unexpected) in 0.001 seconds\n')
    check(lambda: g.classify(text, 0, method))
    check(lambda: rejects(lambda: g.classify(text, 1, method)))
    check(lambda: rejects(lambda: g.classify(text.replace('passed', 'skipped'), 0, method)))
    check(lambda: rejects(lambda: g.aggregate({'case': 'source', 'sha256': '0'*64, 'raw': 1})))
    # No child, temporary ledger, native build, or source write is used here.
    g.require(passed == 35, 'self_test_failure')
    return dict(status='self_test_pass', passed=passed, failed=0, skipped=0, amendment=amendment, **g.COUNTERS)


def main():
    g.require(len(sys.argv) == 2 and sys.argv[1] in ('self-test', 'status', 'registration', 'baseline'), 'binding_failure')
    command = sys.argv[1]
    if command == 'self-test':
        value, code = self_test(), 0
    elif command == 'status':
        amendment, history, state = snapshot()
        value = result(state, amendment, history)
        code = 0 if state in ('ready', 'registration_green', 'prerequisite_green_phase_incomplete') else 1
    else:
        value, code = run(command)
    print(json.dumps(value, sort_keys=True))
    return code


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (g.GateError, OSError, ValueError, TypeError, AssertionError) as error:
        category = str(error) if isinstance(error, g.GateError) and str(error) in g.CATEGORIES else 'infrastructure_failure'
        print(json.dumps(dict(status='gate_rejected', category=category, **g.COUNTERS), sort_keys=True))
        sys.exit(1)
