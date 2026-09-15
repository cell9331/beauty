#!/usr/bin/env python3
"""Review-gated SOURCE-ONLY coverage diagnostic; no registration or scoring.

Reuse pinned source admission/canonicalization and bounded aggregate transport.
Never export coordinates, source paths, images or native child diagnostics.
"""
from pathlib import Path
import hashlib
import importlib.util
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PHASE = '.planning/phases/95-compatibility-and-sdk-only-closeout/'
SELF = 'scripts/phase95-root-anatomy-coverage.py'
SPEC = PHASE + '95-ROOT-ANATOMY-COVERAGE-SPEC.md'
DRIVER = 'scripts/phase95-root-registration.py'
DRIVER_SHA = '99a4edb93b9487ce70d13b411f55c12bc766a4175777fc8fdf551750e5d5fe13'


class Rejected(Exception):
    pass


def dependency():
    path = ROOT / DRIVER
    if path.is_symlink() or any(p.is_symlink() for p in path.parents):
        raise Rejected('dependency_changed')
    data = path.read_bytes()
    if hashlib.sha256(data).hexdigest() != DRIVER_SHA:
        raise Rejected('dependency_changed')
    spec = importlib.util.spec_from_file_location('coverage_admission', path)
    module = importlib.util.module_from_spec(spec)
    exec(compile(data, str(path), 'exec'), module.__dict__)
    return module


CORE = r'''
private func coverageCount(rows: [Double], support: [Double]) throws -> Int {
    guard rows.count == 16, (3...32).contains(support.count),
          (rows + support).allSatisfy({ $0.isFinite && $0 >= 0 && $0 <= 8192 }),
          let lo = support.min(), let hi = support.max(), lo < hi else { throw RootEdgeFailure.invalidInput }
    return rows.filter { $0 >= lo && $0 <= hi }.count
}
private func coverageTests() throws -> Int {
    let rows = (0..<16).map { Double($0) + 0.5 }
    guard try coverageCount(rows: rows, support: [0,8,16]) == 16,
          try coverageCount(rows: rows, support: [20,21,22]) == 0,
          try coverageCount(rows: rows, support: [3.5,5,7.5]) == 5 else { throw RootEdgeFailure.invalidInput }
    var checks = 3
    for bad in [[Double](), [1,1,1], [Double.nan,2,3]] {
        do { _ = try coverageCount(rows: rows, support: bad); throw RootEdgeFailure.unavailable }
        catch RootEdgeFailure.invalidInput { checks += 1 }
    }
    return checks
}
'''


def code(adapter, mode):
    original = adapter.source_code('--register-source').decode()
    marker = '        let binding = try RootStructuralMetricPrototype.register(luminance,'
    if original.count(marker) != 1:
        raise Rejected('definition_boundary')
    prefix = original.split(marker)[0]
    finish = r'''
        func mappedY(_ region: VNFaceLandmarkRegion2D?) throws -> [Double] {
            guard let region, (3...32).contains(region.pointCount) else { throw RootEdgeFailure.unavailable }
            return try region.normalizedPoints.map { p in
                let x = bounds.minX + CGFloat(p.x) * bounds.width
                let y = 1 - bounds.minY - CGFloat(p.y) * bounds.height
                guard x.isFinite, y.isFinite, (0...1).contains(x), (0...1).contains(y) else { throw RootEdgeFailure.invalidInput }
                return Double(y) * Double(image.height)
            }
        }
        let rows = (0..<16).map { Double(region.minY + (2 * Int64($0) + 1) * (region.maxY - region.minY) / 32) }
        let crestCount = try coverageCount(rows: rows, support: mappedY(landmarks.noseCrest))
        let contourCount = try coverageCount(rows: rows, support: mappedY(landmarks.nose))
        try requireAdmittedRegularFile(source, beneath: input)
        guard sha256Hex(try Data(contentsOf: source)) == sourceHash else { throw RootEdgeFailure.identityMismatch }
        return ["status":"source_coverage", "source_sha256":sourceHash, "contracts_sha256":contractsHash,
                "root_rows":16, "crest_covered_rows":crestCount, "contour_covered_rows":contourCount,
                "vision_revision":request.revision, "anatomical_boundary_qualified":false,
                "source_registered":false, "portrait_scoring_attempts":0]
    }
}
'''
    call = ('let r = try RootSourceAdapter.sourceOnly(); print(String(decoding: try JSONSerialization.data(withJSONObject:r, options:[.sortedKeys]), as:UTF8.self))'
            if mode == '--inspect-source' else
            r'let n = try coverageTests(); print("{\"status\":\"generated_pass\",\"checks\":\(n)}")')
    tail = '\ndo { ' + call + r' } catch { print("{\"status\":\"rejected\",\"reason\":\"source_admission\"}"); exit(2) }' + '\n'
    return (prefix + finish + CORE + tail).encode()


def checked(adapter, exit_code, raw, mode):
    try:
        result = adapter.decode(raw)
    except (ValueError, UnicodeError, adapter.AdmissionError):
        raise Rejected('child_invalid_output')
    if exit_code != 0:
        raise Rejected('source_admission')
    if mode == '--self-test':
        if result != {'status': 'generated_pass', 'checks': 6} or type(result.get('checks')) is not int:
            raise Rejected('child_invalid_output')
        return result
    keys = {'status','source_sha256','contracts_sha256','root_rows','crest_covered_rows',
            'contour_covered_rows','vision_revision','anatomical_boundary_qualified',
            'source_registered','portrait_scoring_attempts'}
    source = adapter.decode(adapter.read(PHASE + '95-ROI-REGISTRATION.json'))
    if (set(result) != keys or result['status'] != 'source_coverage'
            or result['anatomical_boundary_qualified'] is not False or result['source_registered'] is not False
            or type(result['portrait_scoring_attempts']) is not int or result['portrait_scoring_attempts'] != 0
            or type(result['root_rows']) is not int or result['root_rows'] != 16
            or any(type(result[k]) is not int or not 0 <= result[k] <= 16
                   for k in ('crest_covered_rows','contour_covered_rows'))
            or type(result['vision_revision']) is not int or not 1 <= result['vision_revision'] <= 100
            or any(result[k] != source[k] for k in ('source_sha256','contracts_sha256'))):
        raise Rejected('child_invalid_output')
    return result


def validate_review(review, expected):
    if (not isinstance(review, dict) or set(review) != {'schema','status','reviewer_agent_id','files','findings'}
            or review['schema'] != 'phase95-root-anatomy-coverage-review-v1' or review['status'] != 'pass'
            or not isinstance(review['reviewer_agent_id'], str)
            or not re.fullmatch('[A-Za-z0-9-]{8,80}',review['reviewer_agent_id'])
            or review['files'] != expected or review['findings'] != []):
        raise Rejected('independent_review_required')


def admission_tests(adapter, expected):
    source = adapter.decode(adapter.read(PHASE + '95-ROI-REGISTRATION.json'))
    good = dict(status='source_coverage', source_sha256=source['source_sha256'],
                contracts_sha256=source['contracts_sha256'], root_rows=16, crest_covered_rows=0,
                contour_covered_rows=16, vision_revision=1, anatomical_boundary_qualified=False,
                source_registered=False, portrait_scoring_attempts=0)
    checked(adapter,0,json.dumps(good).encode(),'--inspect-source')
    checks = 1
    for key, value in (('source_sha256','0'*64),('contracts_sha256','0'*64),('root_rows',True),
                       ('crest_covered_rows',17),('contour_covered_rows',True),('vision_revision',False),
                       ('anatomical_boundary_qualified',True),('source_registered',True),
                       ('portrait_scoring_attempts',False),('status','registered')):
        bad = {**good,key:value}
        try: checked(adapter,0,json.dumps(bad).encode(),'--inspect-source')
        except Rejected: checks += 1
        else: raise Rejected('admission_self_test_failed')
    for exit_code, raw in ((2,json.dumps(good).encode()),(0,b'[]'),(0,b'{"x":1,"x":2}')):
        try: checked(adapter,exit_code,raw,'--inspect-source')
        except Rejected: checks += 1
        else: raise Rejected('admission_self_test_failed')
    review = dict(schema='phase95-root-anatomy-coverage-review-v1',status='pass',
                  reviewer_agent_id='generated-reviewer',files=expected,findings=[])
    validate_review(review,expected); checks += 1
    for key, value in (('schema','old'),('status','pending'),('reviewer_agent_id',''),('files',{}),('findings',['open'])):
        try: validate_review({**review,key:value},expected)
        except Rejected: checks += 1
        else: raise Rejected('admission_self_test_failed')
    return checks


def main():
    if sys.argv[1:] not in (['--self-test'], ['--inspect-source']):
        raise Rejected('arguments')
    mode = sys.argv[1]
    adapter = dependency()
    def snapshot():
        result = {**adapter.snapshot(), DRIVER: adapter.sha(adapter.read(DRIVER)),
                  SELF: adapter.sha(adapter.read(SELF)), SPEC: adapter.sha(adapter.read(SPEC))}
        if result[DRIVER] != DRIVER_SHA:
            raise Rejected('dependency_changed')
        return result
    before = snapshot()
    environment = adapter.environment_identity()
    if mode == '--inspect-source':
        review = adapter.decode(adapter.read(PHASE + '95-ROOT-ANATOMY-COVERAGE-REVIEW.json'))
        validate_review(review,before)
    compiled = code(adapter, mode)
    first = checked(adapter, *adapter.execute(compiled), mode)
    if mode == '--inspect-source':
        second = checked(adapter, *adapter.execute(compiled), mode)
        if first != second:
            raise Rejected('nondeterministic_coverage')
        first.update(attempts=2, environment=environment,
                     diagnostic_identity=adapter.sha(json.dumps(before,sort_keys=True,separators=(',',':')).encode()))
    else:
        first['admission_checks'] = admission_tests(adapter,before)
    if snapshot() != before or adapter.environment_identity() != environment:
        raise Rejected('input_changed')
    print(json.dumps(first, sort_keys=True))


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        reason = str(error) if isinstance(error, Rejected) else 'diagnostic_failed'
        print(json.dumps({'status':'rejected','reason':reason},sort_keys=True))
        sys.exit(2)
