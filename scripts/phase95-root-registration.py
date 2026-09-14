#!/usr/bin/env python3
"""Reviewed-definition source-only adapter; never accepts output directories."""
from __future__ import annotations
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import selectors
import signal
import subprocess
import sys
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
PHASE = '.planning/phases/95-compatibility-and-sdk-only-closeout/'
PINNED = {
    'scripts/phase95-root-edge-metric.swift': '7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b',
    PHASE+'95-ROOT-METRIC-SPEC-v2.md': '168394eb55445d770e72fa1de65546ee0c1ba1cceb15721032f14bdaa9ce426b',
    'BeautySDK/Tests/BeautyEffectsTests/PortraitNoseRegistrationTests.swift': '9634829b8630a6b06aa25fcb0f54e73a7c5229a4497eaacf9fcadcb71c1bfeb4',
    PHASE+'95-ROOT-METRIC-IMPLEMENTATION-REVIEW-v3.md': '947645b74934d89898af44c4644b96ff39f628c4eeaa64bdaa1bfb27323402be',
    PHASE+'95-ROI-REGISTRATION.json': 'ef066fbe62a8385c137666ea0213284244b05199a9df0a81c8998bed07e4c43d',
    'scripts/face-feature-batch-manifest.json': '5665ffa04b9241a73ee864f7230a4abcd677de5dce01a5091a19e70714b7647e',
    'scripts/compare-face-feature-batches.swift': 'd7c7ccd293d4adb53cc2ea521d676cc6f51acd5215ae3a020862d332d1cfca26',
    PHASE+'95-ROOT-REGISTRAR-SPEC-v2.md': '93d37da3b4a17c6b5e5087ee54744bb67c5c8dd1ea009704be0e54f1f28db8db',
}
ADAPTER_FILES = ('scripts/phase95-root-registration.py', 'scripts/phase95-root-registration-adapter.swift',
                 PHASE+'95-ROOT-METRIC-DEFINITION-FREEZE-v2.json', PHASE+'95-ROOT-REGISTRAR-SPEC-v3.md')

class AdmissionError(Exception):
    pass

def read(name: str) -> bytes:
    path = ROOT/name
    if path.is_symlink() or any(p.is_symlink() for p in path.parents) or not path.is_file():
        raise AdmissionError('input_admission')
    if not 0 < path.stat().st_size <= 2 * 1024 * 1024:
        raise AdmissionError('input_size')
    return path.read_bytes()

def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def strict_object(pairs: list) -> dict:
    result = {}
    for key, value in pairs:
        if key in result: raise AdmissionError('duplicate_json_field')
        result[key] = value
    return result

def decode(data: bytes) -> dict:
    value = json.loads(data, object_pairs_hook=strict_object)
    if not isinstance(value, dict): raise AdmissionError('json_shape')
    return value

def snapshot() -> dict:
    result = {name: sha(read(name)) for name in (*PINNED, *ADAPTER_FILES)}
    if any(result[k] != v for k, v in PINNED.items()): raise AdmissionError('frozen_definition_mismatch')
    return result

def validate_review(record: dict, expected: dict) -> None:
    if (set(record) != {'schema', 'status', 'reviewer_agent_id', 'files', 'findings'} or
        record['schema'] != 'phase95-root-registrar-review-v3' or record['status'] != 'pass' or
        not isinstance(record['reviewer_agent_id'], str) or
        not re.fullmatch(r'[A-Za-z0-9-]{8,80}', record['reviewer_agent_id']) or
        record['files'] != expected or record['findings'] != []):
        raise AdmissionError('registrar_review_required')

def source_code(mode: str) -> bytes:
    if mode not in ('--self-test', '--register-source'): raise AdmissionError('arguments')
    comparator = read('scripts/compare-face-feature-batches.swift').decode()
    metric = read('scripts/phase95-root-edge-metric.swift').decode()
    # Fixed, hash-pinned source slices, not regex rewriting or alternate math.
    # Both original CLI dispatchers are excluded. No generated source persists.
    marker = '\nlet commandArguments = Array(CommandLine.arguments.dropFirst())\n'
    other = '\nvar rootEdgePrototypeStage = "initialization"\n'
    if comparator.count(marker) != 1 or metric.count(other) != 1: raise AdmissionError('definition_boundary')
    entry = ('let n = try RootSourceAdapter.selfTest(); print("{\\"status\\":\\"generated_pass\\",\\"checks\\":\\(n)}")'
             if mode == '--self-test' else
             'let r = try RootSourceAdapter.sourceOnly(); print(String(decoding: try JSONSerialization.data(withJSONObject: r, options: [.sortedKeys]), as: UTF8.self))')
    tail = '\ndo { '+entry+' } catch let failure as RootEdgeFailure {\n'
    tail += ' let reason: String; switch failure { case .invalidInput: reason="invalid_input"; case .unavailable: reason="metric_unavailable"; case .ambiguous: reason="ambiguous_structure"; case .identityMismatch: reason="identity_mismatch" }; print("{\\"status\\":\\"rejected\\",\\"reason\\":\\"\\(reason)\\"}"); exit(2)\n'
    tail += '} catch { print("{\\"status\\":\\"rejected\\",\\"reason\\":\\"source_admission\\"}"); exit(2) }\n'
    return (comparator.split(marker)[0]+'\n'+metric.split(other)[0]+'\n'+
            read('scripts/phase95-root-registration-adapter.swift').decode()+tail).encode()

def execute(code: bytes) -> tuple[int, bytes]:
    if len(code) > 1024 * 1024: raise AdmissionError('source_size')
    child = subprocess.Popen(['/usr/bin/swift', '-O', '-'], cwd=ROOT, stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
    def feed() -> None:
        try:
            child.stdin.write(code); child.stdin.close()
        except (BrokenPipeError, OSError):
            pass
    writer = threading.Thread(target=feed, daemon=True); writer.start()
    output = bytearray(); total_bytes = 0; wall = time.time(); monotonic = time.monotonic()
    try:
        with selectors.DefaultSelector() as selector:
            selector.register(child.stdout, selectors.EVENT_READ, 'protocol')
            selector.register(child.stderr, selectors.EVENT_READ, 'diagnostic')
            while selector.get_map():
                if max(time.time()-wall, time.monotonic()-monotonic) > 180: raise AdmissionError('child_timeout')
                for key, _ in selector.select(timeout=0.1):
                    chunk = os.read(key.fileobj.fileno(), 8192)
                    if not chunk: selector.unregister(key.fileobj); continue
                    total_bytes += len(chunk)
                    if total_bytes > 16*1024*1024: raise AdmissionError('child_output_limit')
                    if key.data == 'protocol': output.extend(chunk)
        return child.wait(timeout=5), bytes(output)
    finally:
        # Own and clean the whole child group, including descendants, on every
        # exit path. Only in-memory aggregate JSON can reach the caller.
        try: os.killpg(child.pid, signal.SIGTERM)
        except ProcessLookupError: pass
        try: child.wait(timeout=2)
        except subprocess.TimeoutExpired:
            try: os.killpg(child.pid, signal.SIGKILL)
            except ProcessLookupError: pass
            child.wait(timeout=2)
        # A direct child may have exited while a descendant ignored TERM.
        # Always finish cleaning the group, not only on parent wait timeout.
        try: os.killpg(child.pid, signal.SIGKILL)
        except ProcessLookupError: pass
        writer.join(timeout=2)
        child.stdout.close()
        child.stderr.close()

def checked_result(code: int, output: bytes, mode: str) -> dict:
    try: record = decode(output)
    except (ValueError, UnicodeError): raise AdmissionError('child_invalid_output')
    if code == 2 and set(record) == {'status', 'reason'} and record['status'] == 'rejected' and record['reason'] in (
        'invalid_input', 'metric_unavailable', 'ambiguous_structure', 'identity_mismatch', 'source_admission'):
        raise AdmissionError(record['reason'])
    if code != 0: raise AdmissionError('child_failed')
    if mode == '--self-test':
        if set(record) != {'status','checks'} or record != {'status':'generated_pass','checks':8}:
            raise AdmissionError('self_test_failed')
        return record
    expected = {'schema','status','source_sha256','contracts_sha256','canonical_source_sha256',
                'source_registration_sha256','registered_rows','eye_exclusions','vision_revision',
                'metric_id','canonicalization','portrait_scoring_enabled'}
    if (set(record) != expected or record['schema'] != 'phase95-root-source-registration-v2' or
        record['status'] != 'registered' or record['portrait_scoring_enabled'] is not False or
        record['metric_id'] != 'rootStructuralEdgeSpanQ16_v2_draft2' or
        record['canonicalization'] != 'legacy_ci_orientation_srgb_cg_opaque_luma_q8_v1' or
        type(record['registered_rows']) is not int or not 12 <= record['registered_rows'] <= 16 or
        type(record['eye_exclusions']) is not int or record['eye_exclusions'] != 2 or
        type(record['vision_revision']) is not int or not 1 <= record['vision_revision'] <= 100):
        raise AdmissionError('source_result_shape')
    for key in ('source_sha256','contracts_sha256','canonical_source_sha256','source_registration_sha256'):
        if not isinstance(record[key], str) or not re.fullmatch('[0-9a-f]{64}',record[key]):
            raise AdmissionError('source_result_identity')
    original = decode(read(PHASE+'95-ROI-REGISTRATION.json'))
    if any(record[k] != original[k] for k in ('source_sha256','contracts_sha256')):
        raise AdmissionError('source_result_identity')
    return record

def admission_tests(expected: dict) -> int:
    import copy
    checks = 0
    good = {'schema':'phase95-root-registrar-review-v3', 'status':'pass',
            'reviewer_agent_id':'generated-reviewer', 'files':expected, 'findings':[]}
    validate_review(good, expected); checks += 1
    for key, value in (('schema','legacy'),('status','pending'),('reviewer_agent_id',''),
                       ('files',{}),('findings',['unresolved'])):
        bad = copy.deepcopy(good); bad[key] = value
        try: validate_review(bad, expected)
        except AdmissionError: checks += 1
        else: raise AdmissionError('self_test_failed')
    for data in (b'{"x":1,"x":2}', b'[]'):
        try: decode(data)
        except AdmissionError: checks += 1
        else: raise AdmissionError('self_test_failed')
    original = decode(read(PHASE+'95-ROI-REGISTRATION.json'))
    record = dict(schema='phase95-root-source-registration-v2',status='registered',
                  source_sha256=original['source_sha256'],contracts_sha256=original['contracts_sha256'],
                  canonical_source_sha256='a'*64,source_registration_sha256='b'*64,
                  registered_rows=12,eye_exclusions=2,vision_revision=1,
                  metric_id='rootStructuralEdgeSpanQ16_v2_draft2',
                  canonicalization='legacy_ci_orientation_srgb_cg_opaque_luma_q8_v1',portrait_scoring_enabled=False)
    checked_result(0,json.dumps(record).encode(),'--register-source'); checks += 1
    for key, value in (('schema','legacy'),('source_sha256','c'*64),('contracts_sha256','d'*64),
                       ('canonical_source_sha256','invalid'),('source_registration_sha256','invalid'),
                       ('registered_rows',11),('registered_rows',True),('eye_exclusions',1),
                       ('vision_revision',True),('metric_id','rootWidthContraction'),
                       ('canonicalization','unknown'),('portrait_scoring_enabled',True),('unknown','field')):
        bad = dict(record); bad[key] = value
        try: checked_result(0,json.dumps(bad).encode(),'--register-source')
        except AdmissionError: checks += 1
        else: raise AdmissionError('self_test_failed')
    return checks

def environment_identity() -> dict:
    result = {'os_version':platform.mac_ver()[0], 'architecture':platform.machine()}
    for key, command in (('compiler_version_sha256',['/usr/bin/swift','--version']),
                         ('os_build_sha256',['/usr/bin/sw_vers','-buildVersion'])):
        completed = subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=15)
        if completed.returncode or not 0 < len(completed.stdout) <= 16_384:
            raise AdmissionError('environment_admission')
        result[key] = sha(completed.stdout)
    return result

def transport_tests() -> int:
    header = 'import Foundation\n'
    success = 'print("{\\"status\\":\\"generated_pass\\",\\"checks\\":8}")\n'
    diagnostic = 'FileHandle.standardError.write(Data("generated diagnostic\\n".utf8))\n'
    result = checked_result(*execute((header+diagnostic+success).encode()),'--self-test')
    if result != {'status':'generated_pass','checks':8}: raise AdmissionError('transport_self_test_failed')
    cases = [
        (diagnostic+'print("{\\"status\\":\\"rejected\\",\\"reason\\":\\"ambiguous_structure\\"}"); exit(2)', 'ambiguous_structure'),
        ('print("extra stdout"); '+success, 'child_invalid_output'),
        (success+'exit(1)', 'child_failed'),
        ('FileHandle.standardError.write(Data(repeating:65,count:17*1024*1024))', 'child_output_limit'),
        ('FileHandle.standardOutput.write(Data(repeating:65,count:17*1024*1024))', 'child_output_limit'),
        ('FileHandle.standardError.write(Data(repeating:65,count:9*1024*1024)); FileHandle.standardOutput.write(Data(repeating:65,count:9*1024*1024))', 'child_output_limit'),
    ]
    for source, expected in cases:
        try: checked_result(*execute((header+source).encode()),'--self-test')
        except AdmissionError as failure:
            if str(failure) != expected: raise AdmissionError('transport_self_test_failed')
        else: raise AdmissionError('transport_self_test_failed')
    return len(cases)+1

def main() -> None:
    if sys.argv[1:] not in (['--self-test'], ['--register-source']): raise AdmissionError('arguments')
    mode = sys.argv[1]; before = snapshot()
    environment = environment_identity()
    if mode == '--register-source':
        validate_review(decode(read(PHASE+'95-ROOT-REGISTRAR-REVIEW-v3.json')), before)
    code = source_code(mode)
    first = checked_result(*execute(code), mode)
    if mode == '--register-source':
        second = checked_result(*execute(code), mode)
        if first != second: raise AdmissionError('nondeterministic_registration')
        first.update(attempts=2, environment=environment,
                     adapter_identity=sha(json.dumps(before,sort_keys=True,separators=(',',':')).encode()))
    else:
        first['admission_checks'] = admission_tests(before)
        first['transport_checks'] = transport_tests()
    if snapshot() != before or environment_identity() != environment: raise AdmissionError('input_changed')
    print(json.dumps(first, sort_keys=True, separators=(',',':')))

if __name__ == '__main__':
    try: main()
    except (AdmissionError, OSError, ValueError, subprocess.SubprocessError) as error:
        reason = str(error) if isinstance(error, AdmissionError) else 'registration_failed'
        print(json.dumps({'status':'rejected','reason':reason},sort_keys=True)); sys.exit(2)
