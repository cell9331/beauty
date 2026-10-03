#!/usr/bin/env python3
"""Current owner-local renderer inventory + independently declared pixel contracts."""
import argparse
from collections import Counter
import hashlib
import json
import math
import os
from pathlib import Path
import re
import selectors
import signal
import stat
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
REPORT = 'beauty-example-renderer-report.json'
STATUSES = ('passed', 'abstained', 'effect_failed', 'execution_error', 'unverified')
METRICS = ('luma_delta', 'contrast_delta', 'red_blue_delta')

class Invalid(Exception):
    pass

class SafeParser(argparse.ArgumentParser):
    def error(self, message):
        raise Invalid('arguments_invalid')

def require(condition, code):
    if not condition:
        raise Invalid(code)

def sha(data):
    return hashlib.sha256(data).hexdigest()

def parse(data):
    def pairs(items):
        result = {}
        for k, v in items:
            require(k not in result, 'duplicate_json_key')
            result[k] = v
        return result
    try:
        return json.loads(data, object_pairs_hook=pairs,
                          parse_constant=lambda _: (_ for _ in ()).throw(Invalid('nonfinite_json')))
    except (ValueError, TypeError, UnicodeError):
        raise Invalid('invalid_json') from None

def regular(path, directory=False):
    path = Path(os.path.abspath(path))
    require(not any(c in str(path) for c in '\r\n\0'), 'path_invalid')
    for p in [*reversed(path.parents), path]:
        require(not p.is_symlink(), 'symlink_rejected')
    s = path.stat()
    require(stat.S_ISDIR(s.st_mode) if directory else stat.S_ISREG(s.st_mode), 'file_type_invalid')
    return path

def read(path, limit=16*1024*1024):
    path = regular(path)
    with os.fdopen(os.open(path, os.O_RDONLY | os.O_NOFOLLOW), 'rb') as f:
        require(os.fstat(f.fileno()).st_size <= limit, 'file_too_large')
        data = f.read(limit + 1)
    require(len(data) <= limit, 'file_too_large')
    return data

def ignored(path):
    if path.is_relative_to(ROOT):
        result = subprocess.run(['git', '-C', str(ROOT), 'check-ignore', '-q', '--no-index', str(path)],
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        require(result.returncode == 0, 'private_path_not_ignored')

def child(command, timeout=600, limit=8*1024*1024, env=None):
    # Neither raw stdout/stderr nor command arguments are printed or persisted.
    process = subprocess.Popen([str(x) for x in command], cwd=ROOT, env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, start_new_session=True)
    output = bytearray()
    deadline = time.monotonic() + timeout
    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ)
    try:
        while selector.get_map():
            require(time.monotonic() < deadline, 'child_timeout')
            for key, _ in selector.select(0.1):
                data = os.read(key.fileobj.fileno(), 65536)
                if not data:
                    selector.unregister(key.fileobj)
                else:
                    output.extend(data)
                    require(len(output) <= limit, 'child_output_limit')
        status = process.wait(timeout=max(0.01, deadline-time.monotonic()))
        return status, bytes(output)
    finally:
        selector.close()
        process.stdout.close()
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()

def inventory():
    data = parse(read(HERE/'inventory.json'))
    ids = data['default_cases']
    require(data['schema'] == 'beauty.current-batch.inventory.v1' and len(ids) == 98 and
            len(set(ids)) == 98 and all(re.fullmatch(r'[A-Za-z0-9_]+', x) for x in ids), 'inventory_invalid')
    require(data['compatibility_only'] == ['upperEyelidFullnessReduction_1p00'] and
            not set(ids) & set(data['compatibility_only']), 'inventory_hidden_invalid')
    source = read(ROOT/'BeautySDK/Sources/BeautyExampleRenderer/main.swift')
    require(sha(source) == data['registration_source_sha256'], 'registration_source_changed')
    registered = re.findall(rb'\bid: "([A-Za-z0-9_]+)"', source)
    require(len(registered) == 99 and {s.decode() for s in registered} == set(ids + data['compatibility_only']),
            'registration_inventory_mismatch')
    return data

def check_discovery(payload, ids):
    require(isinstance(payload, dict) and payload.get('schemaVersion') == 'beauty.example-renderer.cases.v1',
            'discovery_schema')
    require(payload.get('cases') == ids, 'discovery_inventory_mismatch')

def check_report(payload, ids, fixture_id, actual_files):
    require(payload.get('schemaVersion') == 'beauty.example-renderer.report.v1' and
            payload.get('backend') == 'cpu', 'renderer_report_schema')
    require(payload.get('caseIDs') == ids and payload.get('inputIDs') == [f'portraits/{fixture_id}.png'],
            'renderer_report_inventory')
    for key, count in [('requested', len(ids)), ('succeeded', len(ids)), ('failed', 0), ('skipped', 0)]:
        require(type(payload.get(key)) is int and payload[key] == count, 'renderer_report_counts')
    outputs = payload.get('outputs', [])
    require(len(outputs) == len(ids), 'renderer_report_missing_or_duplicate')
    expected = {f'{fixture_id}__{id}.png' for id in ids}
    seen = set()
    for row in outputs:
        id = row.get('caseID')
        require(id in ids and id not in seen, 'renderer_report_missing_or_duplicate')
        seen.add(id)
        require(row.get('inputID') == f'portraits/{fixture_id}.png' and
                row.get('outputID') == f'{fixture_id}__{id}.png' and row.get('status') == 'succeeded' and
                row.get('failureCode') is None, 'renderer_report_unit')
    require(set(actual_files) == expected | {REPORT}, 'renderer_output_inventory')

def rect(value):
    require(isinstance(value, list) and len(value) == 4 and
            all(type(v) in (int, float) and math.isfinite(v) and 0 <= v <= 1 for v in value) and
            value[0] < value[2] and value[1] < value[3], 'oracle_rectangle_invalid')

def validate_oracle(oracle):
    require(isinstance(oracle, dict) and oracle.get('kind') in ('exact', 'abstain', 'metrics'), 'oracle_invalid')
    require(not set(oracle) - {'kind', 'target', 'protected', 'checks'}, 'oracle_unknown_field')
    rect(oracle.get('target', [0, 0, 1, 1]))
    protected = oracle.get('protected', [])
    require(isinstance(protected, list) and len(protected) <= 16, 'oracle_protection_invalid')
    for region in protected:
        rect(region)
    checks = oracle.get('checks', [])
    require(isinstance(checks, list) and len(checks) <= 3, 'oracle_checks_invalid')
    require(bool(checks) == (oracle['kind'] == 'metrics'), 'oracle_checks_required')
    seen = set()
    for item in checks:
        require(isinstance(item, dict) and set(item) == {'metric', 'minimum', 'maximum'}, 'oracle_check_invalid')
        name = item['metric']
        require(name in METRICS and name not in seen, 'oracle_metric_invalid')
        seen.add(name)
        lo, hi = item['minimum'], item['maximum']
        require(all(type(x) in (int, float) and math.isfinite(x) and abs(x) <= 510 for x in (lo, hi)) and
                lo <= hi and (lo > 0 or hi < 0), 'oracle_direction_required')

def classify(measurement, oracle):
    if measurement.get('error'):
        return 'execution_error', 'pixel_input_invalid'
    if not measurement.get('srgb') or not measurement.get('source_opaque'):
        return 'execution_error', 'pixel_metadata_invalid'
    if measurement.get('alpha_changed') != 0 or not measurement.get('repeat_exact'):
        return 'effect_failed', 'alpha_or_repeat_failed'
    if measurement.get('protected_changed') != 0:
        return 'effect_failed', 'protected_pixels_changed'
    if oracle is None:
        return 'unverified', 'oracle_missing'
    if oracle['kind'] in ('exact', 'abstain'):
        if not measurement.get('source_exact'):
            return 'effect_failed', 'source_identity_failed'
        return ('abstained' if oracle['kind'] == 'abstain' else 'passed'), 'source_exact'
    if all(type(measurement.get(c['metric'])) in (int, float) and
           math.isfinite(measurement[c['metric']]) and c['minimum'] <= measurement[c['metric']] <= c['maximum']
           for c in oracle['checks']):
        return 'passed', 'direction_passed'
    return 'effect_failed', 'direction_failed'

def default_oracles(ids):
    result = {id: {'kind': 'abstain'} for id in ids}
    result['geometryBaseline_noop'] = {'kind': 'exact'}
    # Combined texture work requests detection; explicit no-face skips the whole
    # skin domain (DESIGN.md and testInternalNoFaceResolverSkipsBasicSkinWithRedactedWarning).
    for id in ('skinWhitening_0p50', 'brightness_plus0p25', 'filter_softClean_0p50'):
        result[id] = {'kind': 'metrics', 'checks': [{'metric': 'luma_delta', 'minimum': 1, 'maximum': 64}]}
    for id in ('skinRosy_0p40', 'filter_warmLight_0p50'):
        result[id] = {'kind': 'metrics', 'checks': [{'metric': 'red_blue_delta', 'minimum': 1, 'maximum': 64}]}
    result['contrast_plus0p25'] = {'kind': 'metrics', 'checks': [{'metric': 'contrast_delta', 'minimum': 0.1, 'maximum': 64}]}
    return result

def suite(path, ids):
    path = regular(path)
    ignored(path)
    data = parse(read(path, 1024*1024))
    require(data.get('schema') == 'beauty.current-batch.suite.v1', 'suite_schema')
    items = data.get('fixtures', [])
    require(isinstance(items, list) and 1 <= len(items) <= 4, 'suite_count')
    seen = set()
    result = []
    for item in items:
        id = item.get('id', '')
        require(re.fullmatch(r'F[0-9]{2}', id) is not None and id not in seen, 'fixture_identity_invalid')
        seen.add(id)
        locator = item.get('path', '')
        require(isinstance(locator, str) and locator and '..' not in Path(locator).parts, 'fixture_path_invalid')
        source = Path(locator) if Path(locator).is_absolute() else path.parent/locator
        source = regular(source)
        ignored(source)
        require(source.suffix.lower() == '.png', 'fixture_format_invalid')
        pixels = read(source)
        require(sha(pixels) == item.get('sha256'), 'fixture_digest_mismatch')
        oracles = item.get('oracles', {})
        require(isinstance(oracles, dict) and not set(oracles)-set(ids), 'suite_case_unknown')
        for oracle in oracles.values():
            validate_oracle(oracle)
        result.append((id, pixels, oracles))
    return result, sha(read(path, 1024*1024))

def summarize(rows):
    counts = {s: 0 for s in STATUSES}
    counts.update(Counter(row['status'] for row in rows))
    code = 2 if counts['execution_error'] else 1 if counts['effect_failed'] else 3 if counts['unverified'] else 0
    return counts, code

def execute(work, preflight_only=False, suite_path=None):
    inv = inventory()
    ids = inv['default_cases']
    items, suite_sha = suite(suite_path, ids) if suite_path else (None, None)
    scratch = work/'build'
    env = os.environ.copy()
    for key in list(env):
        if key.startswith('BEAUTY_') or key.startswith('BEAUTYSDK_'):
            env.pop(key)
    build = ['swift', 'build', '--package-path', ROOT/'BeautySDK', '--scratch-path', scratch,
             '--configuration', 'release']
    status, _ = child(build+['--product', 'BeautyExampleRenderer'], env=env)
    require(status == 0, 'renderer_build_failed')
    status, output = child(build+['--show-bin-path'], env=env)
    require(status == 0, 'renderer_build_failed')
    binary = regular(Path(output.decode().strip())/'BeautyExampleRenderer')
    for _ in range(2):
        status, output = child([binary, '--list-cases'], env=env)
        require(status == 0, 'discovery_failed')
        check_discovery(parse(output), ids)
    bindings = {name: sha(read(HERE/name)) for name in ('run.py', 'pixels.swift', 'inventory.json')}
    bindings['renderer_binary'] = sha(read(binary, 128*1024*1024))
    sources = {str(f.relative_to(ROOT)): sha(read(f)) for f in sorted((ROOT/'BeautySDK/Sources').rglob('*')) if f.is_file()}
    bindings['sdk_source_tree'] = sha(json.dumps(sources, sort_keys=True).encode())
    report = {'schema': 'beauty.current-batch.result.v1', 'claim': 'declared_batch_contract_only',
              'default_inventory': 98, 'registered_inventory': 99, 'backend': 'cpu',
              'bindings': bindings, 'effect_qualification': False, 'rows': []}
    if preflight_only:
        report.update(status='preflight_only', exit_code=0)
        return report
    native = work/'pixels'
    status, _ = child(['swiftc', '-O', HERE/'pixels.swift', '-o', native], env=env)
    require(status == 0, 'pixel_helper_build_failed')
    if items is None:
        generated = work/'generated.png'
        status, _ = child([native, 'fixture', generated], env=env)
        require(status == 0, 'fixture_generation_failed')
        items = [('F01', read(generated), default_oracles(ids))]
        suite_sha = sha(json.dumps(default_oracles(ids), sort_keys=True).encode())
    report.update(suite_kind='owner_declared' if suite_path else 'generated_no_face', suite_sha256=suite_sha,
                  fixture_count=len(items), expected_units=len(items)*len(ids))
    for id, source, oracles in items:
        item = work/id
        portraits = item/'input/portraits'
        portraits.mkdir(parents=True, mode=0o700)
        source_path = portraits/(id+'.png')
        source_path.write_bytes(source)
        source_digest = sha(source)
        request = item/'request.json'
        try:
            request.write_text(json.dumps([{'case_id': 'source', 'source': str(source_path), 'output': str(source_path),
                                            'repeated': str(source_path), 'target': [0, 0, 1, 1], 'protected': []}]))
            status, output = child([native, 'measure', request], env=env)
            require(status == 0, 'source_validation_failed')
            source_check = parse(output)[0]
            require(source_check.get('srgb') is True and source_check.get('source_opaque') is True,
                    'source_metadata_invalid')
            for repeat in ('first', 'repeat'):
                dest = item/repeat
                dest.mkdir(mode=0o700)
                status, _ = child([binary, '--input', item/'input', '--output', dest, '--backend', 'cpu', '--no-watermark'], env=env)
                require(status == 0, 'renderer_execution_failed')
                for f in dest.iterdir():
                    regular(f)
                check_report(parse(read(dest/REPORT)), ids, id, [f.name for f in dest.iterdir()])
                (dest/REPORT).unlink()
            require(sha(read(source_path)) == source_digest, 'source_changed')
            requests = [{'case_id': case, 'source': str(source_path), 'output': str(item/'first'/f'{id}__{case}.png'),
                         'repeated': str(item/'repeat'/f'{id}__{case}.png'),
                         'target': oracles.get(case, {}).get('target', [0, 0, 1, 1]),
                         'protected': oracles.get(case, {}).get('protected', [])} for case in ids]
            request.write_text(json.dumps(requests))
            status, output = child([native, 'measure', request], env=env)
            require(status == 0, 'pixel_measurement_failed')
            measurements = parse(output)
            require(len(measurements) == len(ids) and [r.get('case_id') for r in measurements] == ids, 'pixel_inventory_mismatch')
            for measurement in measurements:
                case = measurement['case_id']
                outcome, reason = classify(measurement, oracles.get(case))
                report['rows'].append({'fixture_id': id, 'case_id': case, 'status': outcome, 'reason': reason,
                                       'source_file_sha256': source_digest, 'measurements': measurement})
        except Invalid as error:
            report['rows'].extend({'fixture_id': id, 'case_id': case, 'status': 'execution_error', 'reason': str(error)} for case in ids)
        finally:
            request.unlink(missing_ok=True)
            for dest in ('first', 'repeat'):
                (item/dest/REPORT).unlink(missing_ok=True)
    report['counts'], report['exit_code'] = summarize(report['rows'])
    report['status'] = 'completed' if report['exit_code'] in (0, 1, 3) else 'execution_error'
    return report

def main():
    parser = SafeParser(description=__doc__)
    parser.add_argument('--preflight-only', action='store_true')
    parser.add_argument('--suite', type=Path)
    work = None
    try:
        args = parser.parse_args()
        parent = ROOT/'BeautySDK/.build/current-batch'
        regular(parent.parent, directory=True)
        ignored(parent)
        if parent.exists():
            regular(parent, directory=True)
        else:
            parent.mkdir(mode=0o700)
        work = Path(tempfile.mkdtemp(prefix='run-', dir=parent))
        report = execute(work, args.preflight_only, args.suite)
    except Invalid as error:
        report = {'schema': 'beauty.current-batch.result.v1', 'status': 'execution_error', 'reason': str(error),
                  'effect_qualification': False, 'exit_code': 2, 'rows': []}
    except (Exception, KeyboardInterrupt):
        report = {'schema': 'beauty.current-batch.result.v1', 'status': 'execution_error', 'reason': 'tool_unavailable',
                  'effect_qualification': False, 'exit_code': 2, 'rows': []}
    if work:
        report['run_id'] = work.name
        target = work/'report.json'
        temporary = work/'report.tmp'
        try:
            temporary.write_text(json.dumps(report, sort_keys=True, allow_nan=False)+'\n')
            temporary.replace(target)
        except OSError:
            report = {'schema': 'beauty.current-batch.result.v1', 'status': 'execution_error',
                      'reason': 'report_write_failed', 'effect_qualification': False, 'exit_code': 2, 'rows': []}
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, sort_keys=True, allow_nan=False))
    return report['exit_code']

if __name__ == '__main__':
    raise SystemExit(main())
