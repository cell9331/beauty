#!/usr/bin/env python3
"""Finite Phase 94 prerequisite experiment; native transcripts stay in memory."""
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import selectors
import signal
import subprocess
import sys
import tempfile
import time


def self_tests():
    """Twelve cases, authored before admission implementation; no Swift children."""
    method = REGISTRATION[0]
    identity = method.replace('/', ' ')
    good = (f"Test Case '-[{identity}]' started.\n"
            f"Test Case '-[{identity}]' passed (0.001 seconds).\n"
            "Executed 1 test, with 0 failures (0 unexpected) in 0.001 seconds\n")
    def rejected(fn, category):
        try:
            fn()
        except GateError as error:
            require(str(error) == category, 'self_test_failure')
        else:
            raise GateError('self_test_failure')
    def valid():
        discover(method + '\n', [method])
        require(classify(good, 0, method)['passed'] == 1, 'self_test_failure')
    def timeout():
        rejected(lambda: child([sys.executable, '-c', 'import time; time.sleep(20)'], 0.1), 'child_timeout')
        require(LAST_REAPED, 'self_test_failure')
    def overflow():
        rejected(lambda: child([sys.executable, '-c',
                               'import os; os.write(1, b"x" * (9*1024*1024))'], 5), 'capture_overflow')
        require(LAST_REAPED, 'self_test_failure')
    def drift():
        rejected(lambda: compare_hashes({'a': '0'*64}, {'a': '1'*64}), 'authority_drift')
    def prefix():
        event = make_event([], 'source_locked', {}, empty_counts(0), '0'*64)
        event['previous'] = '1'*64
        rejected(lambda: validate_events([event], '0'*64), 'event_history')
    def counters():
        value = dict(COUNTERS, implementation_attempt_limit=3)
        rejected(lambda: validate_counters(value), 'counter_reset')
    cases = [valid,
             lambda: rejected(lambda: discover('', [method]), 'discovery_failure'),
             lambda: rejected(lambda: discover(method+'\n'+method+'\n', [method]), 'discovery_failure'),
             lambda: rejected(lambda: classify(good.replace('passed', 'skipped'), 0, method), 'skip_failure'),
             lambda: rejected(lambda: classify(good, 2, method), 'child_failure'),
             timeout, overflow,
             lambda: rejected(lambda: aggregate({'case': 'source', 'raw': 1}), 'aggregate_schema'),
             drift, prefix, counters,
             lambda: rejected(lambda: require_open([{'event': 'terminal_hold'}]), 'terminal_hold')]
    require(len(cases) == 12, 'self_test_failure')
    for case in cases:
        case()
    return {'status': 'self_test_pass', 'counts': dict(empty_counts(12), discovered=12,
            executed=12, passed=12, unexecuted=0), **COUNTERS}


ROOT = Path(__file__).resolve().parent.parent
PHASE = '.planning/phases/94-negative-mouth-width-repair/'
GATE = 'scripts/check-phase94-mouth-repair.py'
FIXTURE = 'BeautySDK/Tests/BeautyCoreTests/MouthRepairFixture.swift'
SPI = 'BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift'
REG = 'BeautySDK/Tests/BeautyCoreTests/MouthFixtureRegistrationTests.swift'
ORACLE = 'BeautySDK/Tests/BeautyCoreTests/MouthBaselineOracleTests.swift'
PUBLIC = 'BeautySDK/Tests/BeautyCoreTests/BeautyEngineMouthBaselineTests.swift'
BINDING = PHASE + '94-PREREQUISITE-BINDING.json'
EVENTS = PHASE + '94-PREREQUISITE-EVENTS.jsonl'
BASELINE = PHASE + '94-BASELINE.json'
PLAN_FILES = [PHASE + name for name in ('94-01-PLAN.md', '94-CONTEXT.md', '94-RESEARCH.md', '94-PATTERNS.md')]
MANIFEST = 'scripts/face-feature-batch-manifest.json'
COMPARATOR = 'scripts/compare-face-feature-batches.swift'
COUNTERS = dict(research_passes=1, checked_plan_sets=1, implementation_attempts=0,
                implementation_attempt_limit=2, phase_complete=False)
REGISTRATION = ['BeautyCoreTests.MouthFixtureRegistrationTests/' + name for name in (
    'testSourceRecipeAndActualRegistration', 'testMismatchedAndDisconnectedMouthsAreRejected',
    'testMissingOuterLipsAndCanonicalRemainUnregistered')]
BASE_METHODS = REGISTRATION + ['BeautyCoreTests.MouthBaselineOracleTests/' + name for name in (
    'testLiteralRasterSpanAndAdmission', 'testPositivePredicatesRejectEachFailure')] + [
    'BeautyCoreTests.BeautyEngineMouthBaselineTests/testPositiveExpansionAndProtectionBaseline',
    'BeautyCoreTests.BeautyEngineMouthBaselineTests/testRetainedMouthRowsHaveDeterministicDigests',
    'BeautyEffectsTests.MouthWarpProviderTests/testMouthWidthMovesCornersOutwardWithCappedStrength',
    'BeautyEffectsTests.MouthWarpProviderTests/testPhase38LegacyMouthEmissionArraysRemainExact']
ROWS = ('geometryBaseline_noop', 'mouthWidth_plus0p35', 'mouthSize_plus0p35', 'mouthSize_minus0p35',
        'smile_0p50', 'lipColor_0p50', 'mouthYPosition_plus0p25', 'mouthYPosition_minus0p25',
        'mouthTilt_plus0p25', 'mouthTilt_minus0p25', 'mouthXPosition_plus0p25',
        'mouthXPosition_minus0p25', 'lipPeakDefinition_0p25', 'lipPlump_0p25')
METRICS = {'source_changed', 'neutral_changed', 'source_rgb', 'neutral_rgb',
           'source_margin', 'neutral_margin', 'size_plus_margin', 'size_minus_margin',
           'outside_changed', 'outside_rgb', 'height_changed', 'height_rgb',
           'face_changed', 'face_rgb', 'background_changed', 'background_rgb',
           'watermark_changed', 'watermark_rgb'}
SPI_CASES = '    case phase94MouthPortrait\n    case phase94MouthPortraitMissingOuterLips\n'
SPI_BLOCK = '''            // BEGIN PHASE94 FIXED OBSERVATION
            case .phase94MouthPortrait:
                return [VisionDetectionObservation(
                    stableID: "phase-94-mouth-fixture",
                    confidence: 0.96,
                    normalizedArea: (512.0 / 640.0) * (672.0 / 800.0),
                    visionBounds: CoordinateRect(x: 64.0 / 640.0, y: 1 - (48.0 + 672.0) / 800.0,
                                                 width: 512.0 / 640.0, height: 672.0 / 800.0),
                    landmarks: .complete
                )]
            case .phase94MouthPortraitMissingOuterLips:
                return [VisionDetectionObservation(
                    stableID: "phase-94-mouth-fixture",
                    confidence: 0.96,
                    normalizedArea: (512.0 / 640.0) * (672.0 / 800.0),
                    visionBounds: CoordinateRect(x: 64.0 / 640.0, y: 1 - (48.0 + 672.0) / 800.0,
                                                 width: 512.0 / 640.0, height: 672.0 / 800.0),
                    landmarks: BeautyFaceLandmarks(
                        availableGroups: Set(BeautyLandmarkGroup.allCases).subtracting([.outerLips])
                    )
                )]
            // END PHASE94 FIXED OBSERVATION
'''
CATEGORIES = {'authority_drift', 'event_history', 'counter_reset', 'terminal_hold',
              'binding_failure', 'source_scope', 'missing_input', 'receipt_failure',
              'discovery_failure', 'skip_failure', 'child_failure', 'child_timeout',
              'capture_overflow', 'cleanup_failure', 'completion_failure', 'assertion_failure',
              'aggregate_schema', 'child_encoding', 'infrastructure_failure', 'self_test_failure'}
EVENT_KINDS = {'source_locked', 'registration_inputs', 'registration_green', 'baseline_inputs',
               'failure', 'terminal_hold', 'prerequisite_green_phase_incomplete'}
LAST_REAPED = False
DEADLINE = float('inf')


class GateError(Exception):
    pass


def require(value, category):
    if not value:
        raise GateError(category)


def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'), allow_nan=False).encode()


def digest(data):
    return hashlib.sha256(data).hexdigest()


def is_hash(value):
    return isinstance(value, str) and re.fullmatch('[0-9a-f]{64}', value) is not None


def path(name):
    require(isinstance(name, str) and not Path(name).is_absolute()
            and '..' not in Path(name).parts, 'missing_input')
    result = ROOT
    for part in Path(name).parts:
        result = result / part
        require(not result.is_symlink(), 'missing_input')
    return result


def read(name):
    p = path(name)
    require(p.is_file() and p.stat().st_size <= 8 * 1024 * 1024, 'missing_input')
    return p.read_bytes()


def hashes(names):
    return {name: digest(read(name)) for name in sorted(names)}


def compare_hashes(expected, actual):
    require(expected == actual, 'authority_drift')


def validate_counters(value):
    require(encoded(value) == encoded(COUNTERS), 'counter_reset')


def empty_counts(total):
    return dict(discovered=0, executed=0, passed=0, failed=0, skipped=0, unexecuted=total)


def check_counts(value):
    require(set(value) == set(empty_counts(0)) and all(type(v) is int and 0 <= v <= 56 for v in value.values()),
            'event_history')
    require(value['passed'] + value['failed'] + value['skipped'] <= value['executed'], 'event_history')


def child(args, timeout):
    global LAST_REAPED
    LAST_REAPED = False
    limit = min(DEADLINE, time.monotonic() + timeout)
    require(time.monotonic() < limit, 'child_timeout')
    proc = subprocess.Popen(args, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                            start_new_session=True)
    selector = selectors.DefaultSelector()
    captured = bytearray()
    try:
        for pipe in (proc.stdout, proc.stderr):
            os.set_blocking(pipe.fileno(), False)
            selector.register(pipe, selectors.EVENT_READ)
        while selector.get_map():
            require(time.monotonic() < limit, 'child_timeout')
            for key, _ in selector.select(min(0.05, max(0, limit-time.monotonic()))):
                data = os.read(key.fileobj.fileno(), 65536)
                if not data:
                    selector.unregister(key.fileobj)
                else:
                    require(len(captured) + len(data) <= 8*1024*1024, 'capture_overflow')
                    captured.extend(data)
        try:
            proc.wait(timeout=max(0.001, limit-time.monotonic()))
        except subprocess.TimeoutExpired:
            raise GateError('child_timeout') from None
        try:
            output = captured.decode('utf-8', errors='strict')
        except UnicodeError:
            raise GateError('child_encoding') from None
        return proc.returncode, output
    finally:
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        try:
            proc.wait(timeout=5)
            LAST_REAPED = proc.poll() is not None
        finally:
            selector.close()
            proc.stdout.close()
            proc.stderr.close()
        require(LAST_REAPED, 'cleanup_failure')


def discover(output, methods):
    found = re.findall(r'^([A-Za-z0-9_]+\.[A-Za-z0-9_]+/test[A-Za-z0-9_]+)$', output, re.M)
    require(methods and len(set(methods)) == len(methods)
            and all(found.count(m) == 1 for m in methods), 'discovery_failure')
    return found


def classify(output, code, method):
    require(code in (0, 1), 'child_failure')
    require(not re.search(r'\bskipped\b', output, re.I), 'skip_failure')
    identity = method.replace('/', ' ')
    starts = re.findall(r"^Test Case '-\[([^\]]+)\]' started\.$", output, re.M)
    ends = re.findall(r"^Test Case '-\[([^\]]+)\]' (passed|failed) \([0-9.]+ seconds\)\.$", output, re.M)
    require(starts == [identity] and len(ends) == 1 and ends[0][0] == identity
            and len(re.findall(r'^Test Case ', output, re.M)) == 2, 'completion_failure')
    summaries = re.findall(r'Executed (\d+) tests?, with (\d+) failures? \((\d+) unexpected\)', output)
    require(summaries and len(set(summaries)) == 1 and summaries[0][0] == '1', 'completion_failure')
    require(code == 0 and ends[0][1] == 'passed' and summaries[0] == ('1', '0', '0')
            and not re.search(r'\berror:|XCTAssert\w* failed|XCTFail failed', output), 'assertion_failure')
    return {'passed': 1}


def aggregate(value):
    require(type(value) is dict and 'case' in value, 'aggregate_schema')
    case = value['case']
    if case == 'positive':
        require(set(value) == METRICS | {'case', 'ok'} and value['ok'] is True, 'aggregate_schema')
        require(all(type(value[k]) is int and -(2**63) < value[k] < 2**63 for k in METRICS), 'aggregate_schema')
        require(value['source_changed'] >= 500 and value['neutral_changed'] >= 500
                and value['source_rgb'] >= 2000 and value['neutral_rgb'] >= 2000
                and all(value[k] >= 16 for k in ('source_margin', 'neutral_margin', 'size_plus_margin', 'size_minus_margin')),
                'assertion_failure')
        for group, changed, rgb in [('outside', 128, 512), ('height', 64, 256), ('face', 64, 256),
                                    ('background', 0, 0), ('watermark', 0, 0)]:
            require(0 <= value[group+'_changed'] <= changed and 0 <= value[group+'_rgb'] <= rgb,
                    'assertion_failure')
    else:
        require(case in (*ROWS, 'source') and set(value) == {'case', 'sha256'} and is_hash(value['sha256']),
                'aggregate_schema')
    return value


def parse_aggregates(output):
    result = []
    for line in output.splitlines():
        if 'P94_AGGREGATE' in line:
            require(line.startswith('P94_AGGREGATE '), 'aggregate_schema')
            try:
                result.append(aggregate(json.loads(line[len('P94_AGGREGATE '):])))
            except (ValueError, TypeError):
                raise GateError('aggregate_schema') from None
    return result


def tracked():
    code, output = child(['git', 'ls-files', '-z', 'BeautySDK/Sources', 'BeautySDK/Tests', 'BeautySDK/Package.swift'], 5)
    require(code == 0, 'infrastructure_failure')
    return sorted(p for p in output.split('\0') if p and (p.startswith('BeautySDK/Sources/') or p.endswith('.swift')))


def normalize_spi(data):
    text = data.decode('utf-8')
    if 'phase94' not in text and 'PHASE94' not in text:
        return data
    require(text.count(SPI_CASES) == 1 and text.count(SPI_BLOCK) == 1, 'source_scope')
    stripped = text.replace(SPI_CASES, '').replace(SPI_BLOCK, '')
    require('phase94' not in stripped and 'PHASE94' not in stripped, 'source_scope')
    return stripped.encode()


def known_authorities(names):
    research = read(PHASE+'94-RESEARCH.md').decode()
    matches = re.findall(r'\| `([^`]+)` \| `([a-f0-9]{64})` \|', research)
    require(len(matches) == 8, 'authority_drift')
    candidates = set(names) | {MANIFEST, COMPARATOR, PHASE+'94-CONTEXT.md'}
    for label, sha in matches:
        selected = [p for p in candidates if p == label or Path(p).name == label]
        require(len(selected) == 1, 'authority_drift')
        data = read(selected[0])
        if selected[0] == SPI:
            data = normalize_spi(data)
        require(digest(data) == sha, 'authority_drift')


def write_once(name, data):
    require(name in (BINDING, EVENTS, BASELINE), 'binding_failure')
    with path(name).open('xb') as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())


def require_open(events):
    require(not any(e['event'] in ('terminal_hold', 'failure') for e in events), 'terminal_hold')


def make_event(events, kind, inputs, counts, binding, category=None, receipt=None):
    value = dict(sequence=len(events), previous=digest(encoded(events[-1])) if events else '0'*64,
                 binding=binding, event=kind, inputs=inputs, counts=counts, counters=COUNTERS)
    if category is not None:
        value['category'] = category
    if receipt is not None:
        value['receipt'] = receipt
    return value


def validate_events(events, binding):
    require(events, 'event_history')
    allowed = {'sequence', 'previous', 'binding', 'event', 'inputs', 'counts', 'counters'}
    prior = []
    expected_order = ['source_locked', 'registration_inputs', 'registration_green', 'baseline_inputs',
                      'prerequisite_green_phase_incomplete']
    normal = 0
    failed = False
    for e in events:
        require(type(e) is dict and set(e) <= allowed | {'category', 'receipt'} and allowed <= set(e), 'event_history')
        require(type(e['sequence']) is int and e['sequence'] == len(prior)
                and e['previous'] == (digest(encoded(prior[-1])) if prior else '0'*64)
                and e['binding'] == binding and e['event'] in EVENT_KINDS, 'event_history')
        validate_counters(e['counters'])
        check_counts(e['counts'])
        require(type(e['inputs']) is dict and all(is_hash(v) for v in e['inputs'].values()), 'event_history')
        permitted = {GATE, FIXTURE, SPI, REG, ORACLE, PUBLIC} | set(PLAN_FILES) | {MANIFEST, COMPARATOR, 'BeautySDK/Package.swift'}
        require(set(e['inputs']) <= permitted, 'event_history')
        kind = e['event']
        if kind == 'failure':
            require(not failed and e.get('category') in CATEGORIES, 'event_history')
            failed = True
        elif kind == 'terminal_hold':
            require(prior and prior[-1]['event'] == 'failure' and e.get('category') == prior[-1]['category'], 'event_history')
        else:
            require(not failed and normal < len(expected_order) and kind == expected_order[normal], 'event_history')
            normal += 1
        if prior:
            require(prior[-1]['event'] != 'terminal_hold', 'event_history')
        if kind == 'prerequisite_green_phase_incomplete':
            require(is_hash(e.get('receipt')), 'event_history')
        else:
            require('receipt' not in e, 'event_history')
        if kind not in ('failure', 'terminal_hold'):
            require('category' not in e, 'event_history')
        prior.append(e)
    return events


def load_events(binding):
    raw = read(EVENTS)
    require(raw.endswith(b'\n'), 'event_history')
    try:
        events = [json.loads(line) for line in raw.splitlines()]
    except ValueError:
        raise GateError('event_history') from None
    require(raw == b''.join(encoded(e)+b'\n' for e in events), 'event_history')
    return validate_events(events, binding)


def append(events, kind, inputs, counts, binding, **kwargs):
    value = make_event(events, kind, inputs, counts.copy(), binding, **kwargs)
    proposed = events + [value]
    validate_events(proposed, binding)
    if events:
        require(read(EVENTS) == b''.join(encoded(e)+b'\n' for e in events), 'event_history')
        with path(EVENTS).open('ab') as stream:
            stream.write(encoded(value)+b'\n')
            stream.flush()
            os.fsync(stream.fileno())
    else:
        write_once(EVENTS, encoded(value)+b'\n')
    events.append(value)


def identities(base):
    require(set(base) == {'hashes', 'tracked', 'counters'}, 'binding_failure')
    validate_counters(base['counters'])
    production = {str(p.relative_to(ROOT)) for p in (ROOT/'BeautySDK/Sources').rglob('*.swift')}
    require(production == {p for p in base['tracked'] if p.startswith('BeautySDK/Sources/') and p.endswith('.swift')},
            'source_scope')
    expected_names = set(base['tracked']) | set(PLAN_FILES) | {GATE, FIXTURE, MANIFEST, COMPARATOR}
    require(set(base['hashes']) == expected_names, 'binding_failure')
    actual = hashes(expected_names)
    actual[SPI] = digest(normalize_spi(read(SPI)))
    compare_hashes(base['hashes'], actual)
    known_authorities(base['tracked'])


def load():
    raw = read(BINDING)
    try:
        base = json.loads(raw)
    except ValueError:
        raise GateError('binding_failure') from None
    require(raw == encoded(base)+b'\n', 'binding_failure')
    binding = digest(raw)
    events = load_events(binding)
    identities(base)
    for event in events:
        if event['event'] in ('registration_inputs', 'baseline_inputs'):
            compare_hashes(event['inputs'], hashes(event['inputs']))
    return base, binding, events


def lock_source():
    if path(BINDING).exists():
        _, binding, events = load()
        require_open(events)
        return dict(status='source_locked', binding=binding, events=digest(read(EVENTS)), **COUNTERS)
    require(not path(EVENTS).exists() and not path(BASELINE).exists(), 'event_history')
    names = tracked()
    require(not any(path(p).exists() for p in (REG, ORACLE, PUBLIC)) and normalize_spi(read(SPI)) == read(SPI), 'source_scope')
    known_authorities(names)
    names = [n for n in names if n not in (FIXTURE, REG, ORACLE, PUBLIC)]
    base = dict(hashes=hashes(set(names) | set(PLAN_FILES) | {GATE, FIXTURE, MANIFEST, COMPARATOR}),
                tracked=names, counters=COUNTERS)
    raw = encoded(base)+b'\n'
    write_once(BINDING, raw)
    binding = digest(raw)
    events = []
    append(events, 'source_locked', hashes([GATE, FIXTURE]), empty_counts(0), binding)
    return dict(status='source_locked', binding=binding, events=digest(read(EVENTS)), **COUNTERS)


def lane(command):
    global DEADLINE
    DEADLINE = time.monotonic() + (1410 if command == 'registration' else 2130) - 30
    _, binding, events = load()
    require_open(events)
    expected = 'source_locked' if command == 'registration' else 'registration_green'
    require(events[-1]['event'] == expected and not path(BASELINE).exists(), 'event_history')
    methods = REGISTRATION if command == 'registration' else BASE_METHODS
    counts = empty_counts(len(methods))
    inputs = hashes([SPI, REG] if command == 'registration' else [ORACLE, PUBLIC])
    append(events, command+'_inputs', inputs, counts, binding)
    try:
        # SwiftPM owns its ordinary existing build directory. No raw log/result
        # bundle is requested; this runner creates no external cache files.
        code, _ = child(['swift', 'build', '--package-path', 'BeautySDK', '--build-tests'], 600)
        require(code == 0, 'child_failure')
        code, listing = child(['swift', 'test', '--package-path', 'BeautySDK', 'list'], 600)
        require(code == 0, 'child_failure')
        found = re.findall(r'^([A-Za-z0-9_]+\.[A-Za-z0-9_]+/test[A-Za-z0-9_]+)$', listing, re.M)
        counts['discovered'] = sum(found.count(m) for m in methods)
        discover(listing, methods)
        records = []
        for index, method in enumerate(methods):
            load()  # Recheck all frozen bytes and the complete prior prefix.
            timeout = 120 if method == BASE_METHODS[5] else 360 if method == BASE_METHODS[6] else 60
            code, output = child(['swift', 'test', '--package-path', 'BeautySDK', '--skip-build',
                                  '--filter', '^'+re.escape(method)+'$'], timeout)
            identity = method.replace('/', ' ')
            if f"Test Case '-[{identity}]' started." in output:
                counts['executed'] += 1
                counts['unexecuted'] -= 1
            if re.search(r'\bskipped\b', output, re.I):
                counts['skipped'] += 1
            elif f"Test Case '-[{identity}]' failed" in output:
                counts['failed'] += 1
            classify(output, code, method)
            counts['passed'] += 1
            parsed = parse_aggregates(output)
            expected_cases = ['positive'] if method == BASE_METHODS[5] else list(ROWS)+['source'] if method == BASE_METHODS[6] else []
            require(sorted(r['case'] for r in parsed) == sorted(expected_cases), 'aggregate_schema')
            records.extend(parsed)
        load()
        if command == 'registration':
            append(events, 'registration_green', inputs, counts, binding)
        else:
            receipt = dict(binding=binding, event_prefix=digest(read(EVENTS)),
                           hashes=hashes([GATE, FIXTURE, SPI, REG, ORACLE, PUBLIC] + PLAN_FILES),
                           records=records, counts=counts, counters=COUNTERS,
                           requirement='MOUTH-01-incomplete', negative_pixels='not_measured')
            write_once(BASELINE, encoded(receipt)+b'\n')
            append(events, 'prerequisite_green_phase_incomplete', inputs, counts, binding,
                   receipt=digest(read(BASELINE)))
        return dict(status=events[-1]['event'], counts=counts, binding=binding,
                    events=digest(read(EVENTS)), **COUNTERS)
    except (GateError, OSError, ValueError, TypeError) as error:
        category = str(error) if isinstance(error, GateError) and str(error) in CATEGORIES else 'infrastructure_failure'
        append(events, 'failure', inputs, counts, binding, category=category)
        append(events, 'terminal_hold', inputs, counts, binding, category=category)
        print(json.dumps(dict(status='terminal_hold', category=category, inputs=inputs,
                              counts=counts, binding=binding, events=digest(read(EVENTS)), **COUNTERS), sort_keys=True))
        return None


def status():
    _, binding, events = load()
    require_open(events)
    if events[-1]['event'] == 'prerequisite_green_phase_incomplete':
        require(digest(read(BASELINE)) == events[-1]['receipt'], 'receipt_failure')
        receipt = json.loads(read(BASELINE))
        require(receipt['binding'] == binding and receipt['event_prefix'] ==
                digest(b''.join(encoded(e)+b'\n' for e in events[:-1])), 'receipt_failure')
        validate_counters(receipt['counters'])
        compare_hashes(receipt['hashes'], hashes(receipt['hashes']))
    else:
        require(not path(BASELINE).exists(), 'receipt_failure')
    return dict(status=events[-1]['event'], counts=events[-1]['counts'], binding=binding,
                events=digest(read(EVENTS)), **COUNTERS)


def main():
    global DEADLINE
    require(len(sys.argv) == 2 and sys.argv[1] in ('self-test', 'lock-source', 'registration', 'baseline', 'status'), 'binding_failure')
    command = sys.argv[1]
    DEADLINE = time.monotonic() + (30 if command == 'self-test' else 10)
    if command == 'self-test':
        if path(BINDING).exists() or path(EVENTS).exists():
            _, _, events = load()
            require_open(events)
        result = self_tests()
    elif command == 'lock-source':
        result = lock_source()
    elif command == 'status':
        result = status()
    else:
        result = lane(command)
    if result is None:
        return 1
    print(json.dumps(result, sort_keys=True))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (GateError, OSError, ValueError, TypeError):
        # Never forward exception text, child diagnostics, or private locators.
        print(json.dumps(dict(status='gate_rejected', **COUNTERS), sort_keys=True))
        sys.exit(1)
