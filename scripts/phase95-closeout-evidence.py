#!/usr/bin/env python3
"""Strict Phase95 surface-v4 evidence validation; no image I/O or implicit acceptance."""
from __future__ import annotations
import hashlib
import json
import os
from pathlib import Path
import re
import tempfile

PHASE_REL = '.planning/phases/95-compatibility-and-sdk-only-closeout'
CONTRACT = '95-CLOSEOUT-CONTRACT-v4.md'
ROOT_DEFINITION = '95-ROOT-SURFACE-MARKER-DEFINITION.md'
ROOT_METRIC = 'rootSurfaceSpanQ16_v4'
ROOT_MODEL = '64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff'
ROOT_IMPLEMENTATION = tuple('scripts/' + n for n in (
    'compare-face-feature-batches.swift', 'run-clean-65-portrait.sh',
    'phase95-root-surface-batch.py', 'phase95-root-surface-batch-native.swift',
    'phase95-root-surface-probe.py', 'phase95-root-surface-native.swift',
    'phase95-root-surface-worker.py', 'phase95-root-surface-horizontal.py',
    'phase95-root-mesh-source-diagnostic.py', 'phase95-root-mesh-source-worker.py',
    'phase95-root-sampler-correspondence.py', 'phase95-root-forward-span.py',
    'phase95-root-regional-motion.py'))
ROOT_REFERENCES = ('source', 'neutral', 'noseBridge_0p30', 'noseSlim_0p35', 'noseTipLift_0p25')
REVIEW = '95-INDEPENDENT-REPAIR-REVIEW.json'
GOAL = '95-GOAL-VERIFICATION.json'
ROOT_ADMISSION = '95-ROOT-MEASUREMENT-ADMISSION.json'
ACTIVE = ('chinTaper_0p25', 'gazeCorrection_0p25', 'eyebrowHeadSpacing_plus0p25',
          'eyebrowHeadSpacing_minus0p25', 'noseBridge_0p30', 'noseRootNarrowing_0p25',
          'mouthWidth_minus0p35')
DEFERRED = 'faceContourSmooth_0p25'
METHODS = {
    'safety': ('RepairedControlSafetyTests.testCrossControlSafetyAllDirections',),
    'compatibility': tuple('RepairedControlCompatibilityTests.' + x for x in (
        'testCodableHasExactly62FrozenFields', 'testFivePresetsAndRendererCasesRemainFrozen',
        'testPublicFacadesBackendAndSDKBoundaryRemainPresent',
        'testNonTargetDefaultsAndNeutralBehaviorRemainStable')),
}
REQUIREMENTS = {'SAFE-01': ['safety', 'no_skip'],
                'COMPAT-01': ['compatibility', 'no_skip'],
                'CLOSE-01': ['portrait', 'no_skip']}

class GateError(Exception):
    pass

def need(value, reason):
    if not value:
        raise GateError(reason)

def checked(path):
    path = Path(path)
    need(not any(p.is_symlink() for p in (path, *path.parents)) and path.is_file(), 'input_admission')
    return path

def sha(path):
    return hashlib.sha256(checked(path).read_bytes()).hexdigest()

def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'),
                                     allow_nan=False).encode()).hexdigest()

def pairs(items):
    result = {}
    for k, v in items:
        need(k not in result, 'duplicate_key')
        result[k] = v
    return result

def load(path):
    data = checked(path).read_bytes()
    need(len(data) <= 4 * 1024 * 1024, 'evidence_size')
    def invalid(_):
        raise GateError('nonfinite_json')
    try:
        return json.loads(data, object_pairs_hook=pairs, parse_constant=invalid, parse_float=invalid)
    except (ValueError, UnicodeError, RecursionError):
        raise GateError('invalid_json') from None

def fields(value, expected):
    need(type(value) is dict and set(value) == set(expected.split()), 'evidence_schema')

def is_sha(value):
    return type(value) is str and re.fullmatch('[0-9a-f]{64}', value) is not None

def reviewer(value):
    return type(value) is str and re.fullmatch('[A-Za-z0-9-]{8,80}', value) is not None

def snapshot(root):
    root = Path(root)
    phase = root / PHASE_REL
    files = {root / 'BeautySDK/Package.swift', phase / '95-ROI-REGISTRATION.json', phase / CONTRACT, phase / ROOT_DEFINITION}
    for directory in ('BeautySDK/Sources', 'BeautySDK/Tests', 'scripts'):
        for path in (root / directory).rglob('*'):
            need(not path.is_symlink(), 'input_admission')
            if path.is_file() and path.suffix in ('.swift', '.metal', '.py', '.sh', '.json'):
                files.add(path)
    # Dynamic progress ledgers are not normative acceptance contracts. Their
    # historical digests are recorded in the binding, but never invalidate it.
    for name in ('AGENTS.md', 'DESIGN.md', 'ARCHITECTURE.md', 'SECURITY.md',
                 'RELIABILITY.md', 'PRODUCT_SENSE.md', 'docs/SDK_EFFECT_TAXONOMY.md'):
        files.add(root / name)
    for directory in (root / '.planning/phases').glob('9[0-4]-*'):
        files.update(p for p in directory.rglob('*') if p.is_file())
    if (phase / ROOT_ADMISSION).exists():
        files.add(phase / ROOT_ADMISSION)
    result = {str(p.relative_to(root)): sha(p) for p in sorted(files)}
    return {'input_digest': digest(result), 'files': result}

def validate_review(value, expected):
    fields(value, 'schema status reviewer_agent_id input_digest findings')
    need(value['schema'] == 'phase95-independent-repair-review-v3'
         and value['status'] == 'pass' and value['input_digest'] == expected
         and reviewer(value['reviewer_agent_id']) and value['findings'] == [], 'review_missing_or_stale')
    return value

def root_admission(root):
    phase = Path(root) / PHASE_REL
    need((phase / ROOT_ADMISSION).exists(), 'root_measurement_not_admitted')
    value = load(phase / ROOT_ADMISSION)
    fields(value, 'schema status reviewer_agent_id findings source_sha256 original_registration_sha256 '
           'metric_id definition_sha256 registration_sha256 registered_pairs model_sha256 runtime_sha256 '
           'implementation measurement_identity')
    need(value['schema'] == 'phase95-root-measurement-admission-v4'
         and value['status'] == 'registered' and reviewer(value['reviewer_agent_id'])
         and value['findings'] == [], 'root_admission_invalid')
    original = load(phase / '95-ROI-REGISTRATION.json')
    need(sha(Path(root) / 'scripts/face-feature-batch-manifest.json') == original['manifest_sha256'], 'manifest_identity')
    need(value['source_sha256'] == original['source_sha256']
         and value['original_registration_sha256'] == sha(phase / '95-ROI-REGISTRATION.json'), 'root_source_identity')
    need(type(value['registered_pairs']) is int and 4 <= value['registered_pairs'] <= 32, 'root_coverage')
    need(value['metric_id'] == ROOT_METRIC
         and value['definition_sha256'] == sha(phase / ROOT_DEFINITION)
         and is_sha(value['registration_sha256']), 'root_definition')
    need(value['model_sha256'] == ROOT_MODEL and is_sha(value['runtime_sha256']), 'root_runtime')
    implementation = value['implementation']
    need(type(implementation) is dict and set(implementation) == set(ROOT_IMPLEMENTATION), 'root_implementation')
    need(all(is_sha(v) and sha(Path(root) / k) == v for k, v in implementation.items()), 'root_implementation_stale')
    identity = {k: value[k] for k in ('source_sha256', 'original_registration_sha256', 'metric_id',
                'definition_sha256', 'registration_sha256', 'registered_pairs', 'model_sha256',
                'runtime_sha256', 'implementation')}
    need(value['measurement_identity'] == digest(identity), 'root_measurement_identity')
    return value

def validate_root_evidence(value, admission, row):
    fields(value, 'schema metric_id measurement_identity source_sha256 original_registration_sha256 '
           'definition_sha256 registration_sha256 model_sha256 runtime_sha256 pair_count crop_rgb_sha256 intervals_q16')
    need(value['schema'] == 'phase95-root-batch-evidence-v1', 'root_batch_schema')
    for key in ('metric_id', 'measurement_identity', 'source_sha256', 'original_registration_sha256',
                'definition_sha256', 'registration_sha256', 'model_sha256', 'runtime_sha256'):
        need(value[key] == admission[key], 'root_batch_identity')
    need(type(value['pair_count']) is int and value['pair_count'] == admission['registered_pairs'], 'root_batch_coverage')
    pixels = value['crop_rgb_sha256']
    need(type(pixels) is dict and set(pixels) == set(ROOT_REFERENCES) | {'candidate'}
         and all(is_sha(v) for v in pixels.values()), 'root_batch_pixels')
    need(pixels['source'] == pixels['neutral'], 'root_neutral_identity')
    intervals = value['intervals_q16']
    need(type(intervals) is dict and set(intervals) == set(ROOT_REFERENCES), 'root_batch_intervals')
    for interval in intervals.values():
        need(type(interval) is list and len(interval) == 2
             and all(type(n) is int and -(2**31) <= n < 2**31 for n in interval)
             and interval[0] <= interval[1], 'root_batch_interval')
    distance = lambda interval: max(0, interval[0], -interval[1])
    need(row['sourceSignedMarginQ16'] == intervals['source'][0]
         and row['neutralSignedMarginQ16'] == intervals['neutral'][0]
         and row['signedMarginQ16'] == min(intervals['source'][0], intervals['neutral'][0])
         and row['siblingDistinctMarginQ16'] == min(distance(intervals[k]) for k in ROOT_REFERENCES[2:]),
         'root_batch_margin')
    return value

def validate_portrait(value, admission, contracts, *, original_contract_id):
    # v2 intentionally rejected: it can credit the known photometric proxy.
    fields(value, 'schema status comparison_count outputs fixture_count repeat_count directions measurements '
           'source_report_digest stable_payload_digest contract_id measurement_identity root_metric_id '
           'root_source_registration_sha256 root_evidence')
    need(value['schema'] == 'phase95-clean-65-v4' and value['status'] == 'pass', 'portrait_schema')
    need(is_sha(original_contract_id) and value['contract_id'] == original_contract_id, 'portrait_contract_identity')
    for key, expected in (('comparison_count', 65), ('outputs', 65), ('fixture_count', 1), ('repeat_count', 2)):
        need(type(value[key]) is int and value[key] == expected, 'portrait_inventory')
    need(value['directions'] == {**{x: 'effective' for x in ACTIVE}, DEFERRED: 'deferred/partial'}, 'portrait_directions')
    need(value['measurement_identity'] == admission['measurement_identity']
         and value['root_metric_id'] == admission['metric_id']
         and value['root_source_registration_sha256'] == admission['registration_sha256'], 'portrait_measurement_identity')
    need(all(is_sha(value[k]) for k in ('source_report_digest', 'stable_payload_digest', 'contract_id')), 'portrait_digest')
    rows = value['measurements']
    need(type(rows) is list and len(rows) == 8 and all(type(v) is dict for v in rows), 'portrait_measurements')
    need({v.get('caseID') for v in rows} == set(ACTIVE) | {DEFERRED}, 'portrait_measurements')
    need(type(contracts) is list and len(contracts) == 8, 'measurement_contracts')
    by_id = {c['caseID']: c for c in contracts}
    need(set(by_id) == set(ACTIVE) | {DEFERRED}, 'measurement_contracts')
    for row in rows:
        fields(row, 'caseID metric fixtureCount sourceTargetChangedPixels sourceTargetAbsoluteRGBDelta '
               'neutralTargetChangedPixels neutralTargetAbsoluteRGBDelta sourceSignedMarginQ16 '
               'neutralSignedMarginQ16 signedMarginQ16 siblingDistinctMarginQ16 outsideChangedPixels '
               'outsideAbsoluteRGBDelta protectedRegions failureReasonCodes verdict')
        contract = by_id[row['caseID']]
        t = contract['thresholds']
        metric = admission['metric_id'] if row['caseID'] == 'noseRootNarrowing_0p25' else contract['metric']
        need(row['metric'] == metric and type(row['fixtureCount']) is int
             and row['fixtureCount'] == 1, 'row_identity')
        signed = {'sourceSignedMarginQ16', 'neutralSignedMarginQ16', 'signedMarginQ16'}
        numeric = signed | {'sourceTargetChangedPixels', 'sourceTargetAbsoluteRGBDelta',
            'neutralTargetChangedPixels', 'neutralTargetAbsoluteRGBDelta', 'siblingDistinctMarginQ16',
            'outsideChangedPixels', 'outsideAbsoluteRGBDelta'}
        for key in numeric:
            need(type(row[key]) is int and -(2**63) <= row[key] < 2**63
                 and (key in signed or row[key] >= 0), 'measurement_integer')
        reasons = set()
        for reference in ('source', 'neutral'):
            if (row[reference+'TargetChangedPixels'] < t['minimumChangedPixels']
                or row[reference+'TargetAbsoluteRGBDelta'] < t['minimumAbsoluteRGBDelta']):
                reasons.add(reference+'_target_signal')
            polarity = 1 if contract['expectedSign'] == 'positive' else -1
            if (polarity * row[reference+'SignedMarginQ16'] < t['minimumSignedMarginQ16']
                or polarity * row['signedMarginQ16'] < t['minimumSignedMarginQ16']):
                reasons.add(reference+'_direction')
        if row['siblingDistinctMarginQ16'] < t['minimumSignedMarginQ16']:
            reasons.add('sibling_alias')
        if (row['outsideChangedPixels'] > t['maximumOutsideChangedPixels']
            or row['outsideAbsoluteRGBDelta'] > t['maximumOutsideAbsoluteRGBDelta']):
            reasons.add('outside_locality')
        protected = row['protectedRegions']
        expected_protected = {p['id']: p for p in contract['protectedRegions']}
        need(type(protected) is list and len(protected) == len(expected_protected), 'protection_inventory')
        ids = set()
        for item in protected:
            fields(item, 'id changedPixels absoluteRGBDelta')
            need(type(item['id']) is str and item['id'] in expected_protected and item['id'] not in ids,
                 'protection_inventory')
            ids.add(item['id'])
            for key in ('changedPixels', 'absoluteRGBDelta'):
                need(type(item[key]) is int and 0 <= item[key] < 2**63, 'protection_integer')
            limit = expected_protected[item['id']]
            if (item['changedPixels'] > limit['maximumChangedPixels']
                or item['absoluteRGBDelta'] > limit['maximumAbsoluteRGBDelta']):
                reasons.add('protected_region')
        need(row['failureReasonCodes'] == sorted(reasons), 'measurement_reasons')
        expected = 'semantic_fail' if reasons else 'semantic_pass'
        need(row['verdict'] == expected, 'measurement_verdict')
        need(expected == ('semantic_fail' if row['caseID'] == DEFERRED else 'semantic_pass'),
             'portrait_measurements')
    validate_root_evidence(value['root_evidence'], admission, next(r for r in rows if r['caseID'] == 'noseRootNarrowing_0p25'))
    return value

def test_identity(name):
    """Normalize XCTest's Darwin and dotted spellings to exact suite.method."""
    identifier = r'[A-Za-z_][A-Za-z0-9_]*'
    darwin = re.fullmatch(r'-\[((?:' + identifier + r'\.)?' + identifier + r') (' + identifier + r')\]', name)
    dotted = re.fullmatch(r'((?:' + identifier + r'\.)?' + identifier + r')\.(' + identifier + r')', name)
    match = darwin or dotted
    need(match is not None, 'test_identity')
    return match[1].split('.')[-1] + '.' + match[2]

def focused_counts(data, lane):
    text = data.decode('utf-8', errors='strict')
    rows = re.findall(r"^Test Case '([^']+)' (passed|failed|skipped) ", text, re.M)
    expected = set(METHODS[lane])
    need(len(rows) == len(expected) and {test_identity(n) for n, _ in rows} == expected
         and all(s == 'passed' for _, s in rows), 'focused_accounting')
    totals = re.findall(r"Test Suite 'Selected tests' passed[^\n]*\n\s*Executed (\d+) tests?, with (\d+) failures", text)
    need(totals == [(str(len(expected)), '0')], 'focused_totals')
    return {'executed': len(rows), 'failed': 0, 'skipped': 0, 'methods': sorted(expected)}

def validate_counts(value, lane=None):
    if lane:
        fields(value, 'executed failed skipped methods')
        need(value['methods'] == sorted(METHODS[lane]), 'focused_methods')
        expected = len(METHODS[lane])
    else:
        fields(value, 'executed failed skipped opt_in_tests')
        need(type(value['opt_in_tests']) is int and value['opt_in_tests'] == 8, 'no_skip_opt_ins')
        expected = value['executed']
    need(all(type(value[k]) is int for k in ('executed', 'failed', 'skipped'))
         and value['executed'] == expected and expected >= (len(METHODS[lane]) if lane else 8)
         and value['failed'] == 0 and value['skipped'] == 0, 'test_counts')

def publish(path, value):
    """Atomic, exclusive publication; an interrupted writer cannot leave a receipt."""
    path = Path(path)
    need(not any(p.is_symlink() for p in (path, *path.parents)), 'output_admission')
    need(not path.exists(), 'receipt_exists')
    data = (json.dumps(value, sort_keys=True, indent=2, allow_nan=False) + '\n').encode()
    fd, temporary = tempfile.mkstemp(prefix='.phase95-', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        # Same filesystem hard link is atomic and fails if any destination exists.
        try:
            os.link(temporary, path)
        except FileExistsError:
            raise GateError('receipt_exists') from None
    finally:
        os.unlink(temporary)

def completion(root):
    root = Path(root)
    phase = root / PHASE_REL
    current = snapshot(root)
    admission = root_admission(root)
    names = ('95-CLOSEOUT-BINDING.json', '95-CLOSEOUT-CHECKS.json', '95-CLEAN-65-REPORT.json', REVIEW, GOAL)
    hashes = {n: sha(phase / n) for n in names}
    binding, checks, portrait, review, goal = (load(phase / n) for n in names)
    validate_review(review, current['input_digest'])
    fields(binding, 'schema input_digest files review_sha256 portrait_sha256 ledger_snapshot')
    need(binding['schema'] == 'phase95-closeout-binding-v3'
         and binding['input_digest'] == current['input_digest'] and binding['files'] == current['files']
         and binding['review_sha256'] == hashes[REVIEW]
         and binding['portrait_sha256'] == hashes['95-CLEAN-65-REPORT.json'], 'binding_stale')
    fields(binding['ledger_snapshot'], 'PLANS.md QUALITY_SCORE.md')
    need(all(is_sha(x) for x in binding['ledger_snapshot'].values()), 'ledger_snapshot')
    fields(checks, 'schema status phase_complete binding_sha256 input_digest portrait_sha256 safety compatibility '
           'no_skip archive_first sdk_boundary wrapper_self_test remaining')
    need(checks['schema'] == 'phase95-closeout-checks-v3' and checks['status'] == 'pass'
         and checks['phase_complete'] is False and checks['archive_first'] is True
         and checks['sdk_boundary'] == checks['wrapper_self_test'] == 'pass'
         and checks['remaining'] == ['95-04-owner-sync-and-goal-verification']
         and checks['binding_sha256'] == hashes['95-CLOSEOUT-BINDING.json']
         and checks['input_digest'] == current['input_digest']
         and checks['portrait_sha256'] == hashes['95-CLEAN-65-REPORT.json'], 'checks_invalid')
    validate_counts(checks['safety'], 'safety')
    validate_counts(checks['compatibility'], 'compatibility')
    validate_counts(checks['no_skip'])
    validate_portrait(portrait, admission, load(root / 'scripts/face-feature-batch-manifest.json')['semanticContracts'],
                     original_contract_id=load(phase / '95-ROI-REGISTRATION.json')['contracts_sha256'])
    fields(goal, 'schema status reviewer_agent_id input_digest checks_sha256 binding_sha256 review_sha256 '
           'portrait_sha256 requirements findings')
    need(goal['schema'] == 'phase95-goal-verification-v3' and goal['status'] == 'pass'
         and reviewer(goal['reviewer_agent_id'])
         and goal['reviewer_agent_id'] != review['reviewer_agent_id'] and goal['findings'] == []
         and goal['requirements'] == REQUIREMENTS, 'goal_invalid')
    need(goal['input_digest'] == current['input_digest']
         and goal['checks_sha256'] == hashes['95-CLOSEOUT-CHECKS.json']
         and goal['binding_sha256'] == hashes['95-CLOSEOUT-BINDING.json']
         and goal['review_sha256'] == hashes[REVIEW]
         and goal['portrait_sha256'] == hashes['95-CLEAN-65-REPORT.json'], 'goal_stale')
    need(snapshot(root) == current and all(sha(phase / n) == h for n, h in hashes.items()), 'inputs_changed')
    return {'schema': 'phase95-complete-v3', 'status': 'complete', 'phase_complete': True,
            'input_digest': current['input_digest'], 'evidence': hashes,
            'measurement_identity': admission['measurement_identity'], 'requirements': sorted(REQUIREMENTS)}

def finalize(root):
    result = completion(root)
    destination = Path(root) / PHASE_REL / '95-COMPLETE.json'
    publish(destination, result)
    identity = destination.stat()
    try:
        need(completion(root) == result, 'inputs_changed_after_publication')
    except BaseException:
        # Remove only the inode this invocation published, never another writer's.
        if destination.exists() and destination.stat().st_ino == identity.st_ino:
            destination.unlink()
        raise
    return result

def verify_complete(root):
    result = completion(root)
    need(load(Path(root) / PHASE_REL / '95-COMPLETE.json') == result, 'completion_stale')
    return result
