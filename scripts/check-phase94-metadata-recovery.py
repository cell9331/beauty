#!/usr/bin/env python3
"""Metadata-only continuation of the exact recorded Phase94 baseline failure.

Uses the pinned compile runner's complete nine-method lane unchanged. Separate
module instances keep its original authority checks and files intact. An empty
successor history inherits ONLY the actual linked registration GREEN; the lane
still freshly executes all three registration methods before its six other tests.
"""
import hashlib
import json
from pathlib import Path
import sys
import types

ROOT = Path(__file__).resolve().parent.parent
REL = 'scripts/check-phase94-metadata-recovery.py'
PHASE = '.planning/phases/94-negative-mouth-width-repair/'
AMENDMENT = PHASE + '94-METADATA-AMENDMENT.json'
EVENTS = PHASE + '94-METADATA-EVENTS.jsonl'
RECEIPT = PHASE + '94-METADATA-BASELINE.json'
COMPILE_RUNNER = 'eb91c3560fdd2b48f92b426934610528e2a1042f17572fce23d81895806b395e'
COMPILE_AMENDMENT = '0b4e5e4926aa0fff96bc8be13e5cf2b7a5e165642154f706c0c7b0973abe527a'
COMPILE_EVENTS = '12034279d402cd4e6fc8b790a8c3a6e14ec588d2877d13da8d52ea189fcd1eba'
BEFORE = '74ba99d798cf3f05808f065a677dda3c816b757b6bdf69f88ebeec04110b1c77'
AFTER = 'b06820a45a24f398042f5c1714b3b8c202a2a076f510f8ceacc666990ff1c282'
ORACLE = '5d5b2a9f98a427ed189c2625951e23961c31e794a5875367fac61e9c91622d0c'
OLD_METADATA = '''    private func extract(_ image: CIImage, active: Bool) throws -> [UInt8] {
        XCTAssertTrue(image.extent == extent, "P94_BASELINE_EXTENT")
        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB), let actual = image.colorSpace else { throw Admission.color }
        let expected = active ? CGColorSpaceCreateDeviceRGB() : sRGB
        XCTAssertTrue(actual.model == expected.model && actual.name == expected.name,
                      "P94_BASELINE_COLOR_METADATA")
        XCTAssertTrue(actual.numberOfComponents == expected.numberOfComponents && CFEqual(actual, expected),
                      "P94_BASELINE_EXACT_COLOR_SPACE")
'''
NEW_METADATA = '''    private func sameColorMetadata(_ first: CIImage, _ second: CIImage) -> Bool {
        switch (first.colorSpace, second.colorSpace) {
        case (nil, nil): return true
        case let (lhs?, rhs?): return CFEqual(lhs, rhs)
        default: return false
        }
    }

    private func extract(_ image: CIImage, active: Bool, colorOnly: Bool = false) throws -> [UInt8] {
        XCTAssertTrue(image.extent == extent, "P94_BASELINE_EXTENT")
        guard let sRGB = CGColorSpace(name: CGColorSpace.sRGB) else { throw Admission.color }
        if colorOnly {
            // Color-filter output has no promised concrete source tag. Its
            // optional metadata must still agree across wrappers and repeats;
            // actual pixels below are always materialized in named sRGB.
            if let actual = image.colorSpace {
                XCTAssertTrue(actual.model == .rgb && actual.numberOfComponents == 3,
                              "P94_BASELINE_COLOR_ONLY_RGB_METADATA")
            }
        } else {
            guard let actual = image.colorSpace else { throw Admission.color }
            let expected = active ? CGColorSpaceCreateDeviceRGB() : sRGB
            XCTAssertTrue(actual.model == expected.model && actual.name == expected.name,
                          "P94_BASELINE_COLOR_METADATA")
            XCTAssertTrue(actual.numberOfComponents == expected.numberOfComponents && CFEqual(actual, expected),
                          "P94_BASELINE_EXACT_COLOR_SPACE")
        }
'''


def load_compile(name):
    p = ROOT / 'scripts/check-phase94-compile-recovery.py'
    raw = p.read_bytes()
    if p.is_symlink() or hashlib.sha256(raw).hexdigest() != COMPILE_RUNNER:
        raise ValueError('authority_drift')
    module = types.ModuleType(name)
    module.__file__ = str(p)
    exec(compile(raw, str(p), 'exec'), module.__dict__)
    return module


try:
    r = load_compile('phase94_compile_authority')
    w = load_compile('phase94_metadata_lane')
except (OSError, ValueError):
    print('{"status":"gate_rejected","category":"authority_drift","phase_complete":false}')
    sys.exit(1)
g = r.g
w.g = g  # One exception/capture type across delegated authority and lane calls.


def validate_patch(data):
    g.require(r.digest(data) == AFTER, 'source_scope')
    replacements = [
        ('extract(result.output, active: active, colorOnly: row.0 == "lipColor_0p50")',
         'extract(result.output, active: active)'),
        ('extract(legacy, active: active, colorOnly: row.0 == "lipColor_0p50")',
         'extract(legacy, active: active)'),
        ('                XCTAssertTrue(sameColorMetadata(old.output, result.output), "P94_BASELINE_REPEATED_COLOR_METADATA")\n', ''),
        ('            XCTAssertTrue(sameColorMetadata(result.output, legacy), "P94_BASELINE_WRAPPER_COLOR_METADATA")\n', ''),
        (NEW_METADATA, OLD_METADATA)
    ]
    original = data
    for new, old in replacements:
        g.require(original.count(new.encode()) == 1, 'source_scope')
        original = original.replace(new.encode(), old.encode())
    g.require(r.digest(original) == BEFORE, 'source_scope')


def expected_amendment(runner_sha):
    return dict(schema=1, scope='color_only_metadata_test_correction', original_commit='5e680ebb',
                compile_runner=COMPILE_RUNNER, compile_amendment=COMPILE_AMENDMENT,
                compile_events=COMPILE_EVENTS, compile_event_count=4,
                public_before=BEFORE, public_after=AFTER, oracle=ORACLE,
                runner=runner_sha, counters=g.COUNTERS,
                diagnostic=dict(provenance='parent_diagnostic_only', invocations=2,
                                first_parser='incomplete', exit_codes=[1, 1],
                                second=dict(executed=1, failures=1, unexpected=1,
                                            file=g.PUBLIC, line=143, color_token=True, xctassert_failures=0)),
                post_patch_diagnostic=dict(provenance='parent_diagnostic_only', stage='build',
                                           exit_code=0, errors=0, tests_executed=0, acceptance=False))


def validate_amendment(value, runner_sha):
    g.require(g.encoded(value) == g.encoded(expected_amendment(runner_sha)), 'binding_failure')


def validate_prefix(raw):
    g.require(r.digest(raw) == COMPILE_EVENTS, 'event_history')
    history = [r.strict_json(line) for line in raw.splitlines()]
    g.require(r.validate_history(history, COMPILE_AMENDMENT) == 'terminal_hold'
              and [e['event'] for e in history] == ['registration_started', 'registration_green',
                                                  'baseline_started', 'terminal_hold'], 'event_history')
    g.require(history[1]['counts'] == dict(discovered=3, executed=3, passed=3, failed=0, skipped=0, unexecuted=0)
              and history[-1]['counts'] == dict(discovered=9, executed=7, passed=6, failed=1, skipped=0, unexecuted=2)
              and history[-1]['category'] == 'assertion_failure' and history[-1]['stage'] == 'test'
              and history[-1]['exit_code'] == 1 and history[-1]['inputs'][g.PUBLIC] == BEFORE
              and history[-1]['inputs'][g.ORACLE] == ORACLE, 'event_history')
    return history


def authority():
    # Original source binding, original failure, compile amendment, exact SPI and
    # REG correction, all existing source/tests/manifest/recipe identities.
    g.require(r.authority() == COMPILE_AMENDMENT, 'authority_drift')
    history = validate_prefix(g.read(r.EVENTS))
    for item in history:
        for name, sha in item['inputs'].items():
            if name != g.PUBLIC:
                g.require(r.digest(g.read(name)) == sha, 'authority_drift')
    validate_patch(g.read(g.PUBLIC))
    raw = g.read(AMENDMENT)
    amendment = r.strict_json(raw)
    validate_amendment(amendment, r.digest(g.read(REL)))
    g.require(raw == g.encoded(amendment)+b'\n' and not g.path(r.RECEIPT).exists(), 'binding_failure')
    return r.digest(raw)


def validate_history(history, amendment):
    # No manufactured registration events: authority() verifies the actual
    # preserved receipt, and this successor admits one fresh baseline only.
    state = 'registration_green'
    keys = set(w.event([], 'baseline_started', amendment, 'baseline', {}, g.empty_counts(9)))
    names = {REL, g.GATE, g.FIXTURE, g.SPI, g.REG, g.ORACLE, g.PUBLIC}
    for i, item in enumerate(history):
        g.require(type(item) is dict and set(item) == keys and type(item['sequence']) is int
                  and item['sequence'] == i and item['previous'] == (r.digest(g.encoded(history[i-1])) if i else amendment)
                  and item['amendment'] == amendment and item['original_events'] == r.OLD_EVENTS
                  and item['lane'] == 'baseline' and set(item['inputs']) == names
                  and all(g.is_hash(v) for v in item['inputs'].values()), 'event_history')
        g.validate_counters(item['counters'])
        r.validate_counts(item['counts'], 9)
        if i == 0:
            g.require(item['event'] == 'baseline_started' and item['counts'] == g.empty_counts(9), 'event_history')
        else:
            g.require(i == 1 and state == 'baseline_started' and item['inputs'] == history[0]['inputs'], 'event_history')
        kind = item['event']
        if kind == 'terminal_hold':
            g.require(item['category'] in g.CATEGORIES | {'interrupted_lane'}
                      and item['stage'] in ('admission', 'build', 'discovery', 'test', 'finalize')
                      and (item['exit_code'] is None or (type(item['exit_code']) is int
                           and -255 <= item['exit_code'] <= 255)) and item['receipt'] is None, 'event_history')
        else:
            g.require(kind in ('baseline_started', 'prerequisite_green_phase_incomplete')
                      and item['stage'] == 'none' and item['category'] is None and item['exit_code'] is None, 'event_history')
            if kind == 'prerequisite_green_phase_incomplete':
                r.validate_counts(item['counts'], 9, green=True)
                g.require(g.is_hash(item['receipt']), 'event_history')
            else:
                g.require(item['receipt'] is None, 'event_history')
        state = kind
    return state


# Rebind only the successor's output identities and authority/state admission.
# run/child/selection/deadlines/capture/counts/aggregate/receipt code is unchanged.
w.REL, w.AMENDMENT, w.EVENTS, w.RECEIPT = REL, AMENDMENT, EVENTS, RECEIPT
w.authority, w.validate_history = authority, validate_history


def self_test():
    amendment, history, state = w.snapshot()
    g.require(state == 'registration_green' and not history, 'terminal_hold')
    count = 0
    def check(fn):
        nonlocal count
        fn()
        count += 1
    def rejects(fn):
        try:
            fn()
        except (g.GateError, w.g.GateError, ValueError, TypeError):
            return
        raise AssertionError('mutation_admitted')
    check(authority)
    check(lambda: validate_patch(g.read(g.PUBLIC)))
    check(lambda: rejects(lambda: validate_patch(g.read(g.PUBLIC)+b'\n')))
    check(lambda: rejects(lambda: validate_prefix(g.read(r.EVENTS)[:-1])))
    check(lambda: rejects(lambda: validate_prefix(g.read(r.EVENTS).replace(b'assertion_failure', b'child_failure'))))
    value = expected_amendment(r.digest(g.read(REL)))
    for key in ('public_before', 'public_after', 'oracle', 'compile_events', 'runner'):
        bad = dict(value, **{key: '0'*64})
        check(lambda bad=bad: rejects(lambda: validate_amendment(bad, value['runner'])))
    bad = dict(value, counters=dict(g.COUNTERS, implementation_attempts=1))
    check(lambda: rejects(lambda: validate_amendment(bad, value['runner'])))
    frozen = w.inputs('baseline')
    start = w.event([], 'baseline_started', amendment, 'baseline', frozen, g.empty_counts(9))
    check(lambda: validate_history([start], amendment))
    hold = w.event([start], 'terminal_hold', amendment, 'baseline', frozen, g.empty_counts(9),
                   stage='build', exit_code=1, category='child_failure')
    check(lambda: validate_history([start, hold], amendment))
    restart = w.event([start, hold], 'baseline_started', amendment, 'baseline', frozen, g.empty_counts(9))
    check(lambda: rejects(lambda: validate_history([start, hold, restart], amendment)))
    green = w.event([start], 'prerequisite_green_phase_incomplete', amendment, 'baseline', frozen,
                    g.empty_counts(9), receipt='0'*64)
    check(lambda: rejects(lambda: validate_history([start, green], amendment)))
    check(lambda: rejects(lambda: validate_history([dict(start, previous='0'*64)], amendment)))
    check(lambda: rejects(lambda: r.validate_records([])))
    g.require(count == 17, 'self_test_failure')
    return dict(status='self_test_pass', passed=count, failed=0, skipped=0, amendment=amendment, **g.COUNTERS)


def main():
    g.require(len(sys.argv) == 2 and sys.argv[1] in ('self-test', 'status', 'baseline'), 'binding_failure')
    if sys.argv[1] == 'self-test':
        value, code = self_test(), 0
    elif sys.argv[1] == 'baseline':
        value, code = w.run('baseline')
    else:
        amendment, history, state = w.snapshot()
        value = w.result(state, amendment, history)
        if not history:
            value['status'] = 'ready_for_fresh_baseline'
            value['inherited_registration_events'] = COMPILE_EVENTS
        code = 0 if state in ('registration_green', 'prerequisite_green_phase_incomplete') else 1
    print(json.dumps(value, sort_keys=True))
    return code


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (g.GateError, w.g.GateError, OSError, ValueError, TypeError, AssertionError) as error:
        category = str(error) if str(error) in g.CATEGORIES else 'infrastructure_failure'
        print(json.dumps(dict(status='gate_rejected', category=category, **g.COUNTERS), sort_keys=True))
        sys.exit(1)
