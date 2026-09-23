#!/usr/bin/env python3
"""Reviewed source-only candidate diagnostic; no candidate images or scoring."""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
PHASE = '.planning/phases/95-compatibility-and-sdk-only-closeout/'
SPEC = PHASE + '95-ROOT-SOURCE-CANDIDATES-SPEC.md'
REVIEW = PHASE + '95-ROOT-SOURCE-CANDIDATES-REVIEW.json'


def module(name, filename):
    spec = importlib.util.spec_from_file_location(name, ROOT / filename)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


driver = module('source_driver', 'scripts/phase95-root-registration.py')
candidates = module('source_candidates', 'scripts/phase95-root-source-candidates.py')


def snapshot():
    result = driver.snapshot()
    for name in (SPEC, 'scripts/phase95-root-source-candidates.py',
                 'scripts/phase95-root-source-candidate-diagnostic.py',
                 'scripts/test-phase95-root-source-candidates.py'):
        result[name] = driver.sha(driver.read(name))
    return result


def source_code():
    code = driver.source_code('--register-source').decode()
    start = code.index('        let binding = try RootStructuralMetricPrototype.register(luminance,')
    end = code.index('    static func selfTest() throws -> Int {', start)
    body = '''        let split = (Int(region.minX) + Int(region.maxX)) / 2
        var profiles: [[Int]] = [], limits: [[Int]] = []
        for row in 0..<16 {
            let y = Int(region.minY) + (2 * row + 1) * Int(region.maxY - region.minY) / 32
            var lo = Int(region.minX), hi = Int(region.maxX)
            for box in exclusions where y >= box.minY && y < box.maxY {
                if box.maxX <= split { lo = max(lo, box.maxX) }
                else if box.minX >= split { hi = min(hi, box.minX) }
                else { throw RootEdgeFailure.unavailable }
            }
            guard 0 <= lo, lo < split, split < hi, hi <= image.width else { throw RootEdgeFailure.unavailable }
            profiles.append((0..<image.width).map { Int(lumaQ8(image, x: $0, y: y)) })
            limits.append([lo, split, hi])
        }
        try requireAdmittedRegularFile(source, beneath: input)
        guard sha256Hex(try Data(contentsOf: source)) == sourceHash else { throw RootEdgeFailure.identityMismatch }
        return ["schema": "phase95-source-profiles-ephemeral-v1", "source_sha256": sourceHash,
                "contracts_sha256": contractsHash, "profiles": profiles, "bounds": limits]
    }

'''
    return (code[:start] + body + code[end:]).encode()


def inspect():
    before = snapshot()
    review = driver.decode(driver.read(REVIEW))
    if (set(review) != {'schema','status','reviewer_agent_id','files','findings'}
        or review['schema'] != 'phase95-source-candidates-review-v1'
        or review['status'] != 'pass' or review['files'] != before or review['findings'] != []
        or type(review['reviewer_agent_id']) is not str or len(review['reviewer_agent_id']) < 8):
        raise driver.AdmissionError('independent_diagnostic_review_required')
    results = []
    for _ in range(2):
        code, data = driver.execute(source_code())
        if code != 0:
            raise driver.AdmissionError('source_diagnostic_rejected')
        value = driver.decode(data)
        del data
        if (set(value) != {'schema','source_sha256','contracts_sha256','profiles','bounds'}
            or value['schema'] != 'phase95-source-profiles-ephemeral-v1'
            or type(value['profiles']) is not list or type(value['bounds']) is not list
            or len(value['profiles']) != 16 or len(value['bounds']) != 16
            or any(type(row) is not list for row in value['profiles'] + value['bounds'])):
            raise driver.AdmissionError('source_protocol')
        original = driver.decode(driver.read(PHASE + '95-ROI-REGISTRATION.json'))
        if any(value[k] != original[k] for k in ('source_sha256','contracts_sha256')):
            raise driver.AdmissionError('source_identity')
        result = candidates.diagnostic(tuple(map(tuple,value['profiles'])), tuple(map(tuple,value['bounds'])))
        result['candidate_rows'] = result.pop('registered_rows',0)
        result.update(source_sha256=value['source_sha256'], contracts_sha256=value['contracts_sha256'],
                      source_profile_digest=driver.sha(json.dumps(value,sort_keys=True,separators=(',',':')).encode()),
                      source_registered=False)
        del value
        results.append(result)
    if results[0] != results[1] or snapshot() != before:
        raise driver.AdmissionError('unstable_source_diagnostic')
    return dict(results[0], schema='phase95-source-candidates-observation-v1', attempts=2,
                diagnostic_identity=driver.sha(json.dumps(before,sort_keys=True).encode()),
                acceptance_credit=False)


if __name__ == '__main__':
    try:
        if sys.argv[1:] == ['--review-inputs']:
            print(json.dumps(snapshot(), sort_keys=True))
        elif sys.argv[1:] == ['--inspect-source']:
            print(json.dumps(inspect(), sort_keys=True))
        else:
            raise driver.AdmissionError('arguments')
    except Exception:
        # Native diagnostics, input paths and source material never leave memory.
        print('{"status":"rejected","reason":"source_candidate_diagnostic"}')
        sys.exit(1)
