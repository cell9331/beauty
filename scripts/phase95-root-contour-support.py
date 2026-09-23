#!/usr/bin/env python3
"""Source-only nose-polyline support diagnostic; never a width qualification."""
from pathlib import Path
import importlib.util
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
PHASE = '.planning/phases/95-compatibility-and-sdk-only-closeout/'
SELF = 'scripts/phase95-root-contour-support.py'
SPEC = PHASE + '95-ROOT-CONTOUR-SUPPORT-SPEC.md'
REVIEW = PHASE + '95-ROOT-CONTOUR-SUPPORT-REVIEW.json'
spec = importlib.util.spec_from_file_location('coverage', ROOT / 'scripts/phase95-root-anatomy-coverage.py')
coverage = importlib.util.module_from_spec(spec)
spec.loader.exec_module(coverage)

CORE = r'''
private func contourSupport(_ points: [CGPoint], rows: [Double],
                            lo: Double, mid: Double, hi: Double) throws -> [String: Int] {
    guard (3...32).contains(points.count), rows.count == 16,
          [lo,mid,hi].allSatisfy({ $0.isFinite && $0 >= 0 && $0 <= 8192 }),
          lo < mid, mid < hi,
          rows.allSatisfy({ $0.isFinite && $0 >= 0 && $0 <= 8192 }),
          points.allSatisfy({ $0.x.isFinite && $0.y.isFinite && $0.x >= 0 && $0.x <= 8192 && $0.y >= 0 && $0.y <= 8192 })
    else { throw RootEdgeFailure.invalidInput }
    var paired = 0, ambiguous = 0, absent = 0
    for y in rows {
        var hits: [Double] = []
        var horizontal = false
        for i in 1..<points.count {
            let a = points[i-1], b = points[i]
            if a.y == b.y {
                if a.y == y && max(a.x,b.x) >= lo && min(a.x,b.x) < hi { horizontal = true }
                continue
            }
            if y < min(a.y,b.y) || y > max(a.y,b.y) { continue }
            let x = Double(a.x) + (y - Double(a.y)) * Double(b.x-a.x) / Double(b.y-a.y)
            if x >= lo && x < hi && !hits.contains(x) { hits.append(x) }
        }
        if horizontal || hits.count > 2 { ambiguous += 1 }
        else if hits.count == 2 && hits.min()! < mid && hits.max()! > mid { paired += 1 }
        else { absent += 1 }
    }
    return ["paired_rows":paired, "ambiguous_rows":ambiguous, "unsupported_rows":absent]
}
private func contourTests() throws -> Int {
    let rows = (0..<16).map { Double($0)+0.5 }
    func p(_ values: [(Double,Double)]) -> [CGPoint] { values.map { CGPoint(x:$0.0,y:$0.1) } }
    func require(_ flag: Bool) throws { if !flag { throw RootEdgeFailure.invalidInput } }
    let u = p([(2,0),(2,16),(8,16),(8,0)])
    let positive = try contourSupport(u,rows:rows,lo:0,mid:5,hi:10)
    try require(positive == ["paired_rows":16,"ambiguous_rows":0,"unsupported_rows":0])
    let single = try contourSupport(p([(2,0),(2,8),(2,16)]),rows:rows,lo:0,mid:5,hi:10)
    try require(single["paired_rows"] == 0 && single["unsupported_rows"] == 16)
    let partial = try contourSupport(p([(2,13),(2,16),(8,16),(8,13)]),rows:rows,lo:0,mid:5,hi:10)
    try require(partial["paired_rows"] == 3 && partial["unsupported_rows"] == 13)
    let many = try contourSupport(p([(1,0),(2,16),(4,0),(6,16),(9,0)]),rows:rows,lo:0,mid:5,hi:10)
    try require(many["ambiguous_rows"] == 16 && many["paired_rows"] == 0)
    let clipped = try contourSupport(u,rows:rows,lo:3,mid:5,hi:10)
    try require(clipped["paired_rows"] == 0)
    let horizontal = try contourSupport(p([(2,0.5),(8,0.5),(8,16)]),rows:rows,lo:0,mid:5,hi:10)
    try require(horizontal["ambiguous_rows"] == 1)
    // No synthetic closing edge may turn this open path into a bilateral contour.
    let open = try contourSupport(p([(2,0),(2,16),(8,16)]),rows:rows,lo:0,mid:5,hi:10)
    try require(open["paired_rows"] == 0)
    let reversed = try contourSupport(Array(u.reversed()),rows:rows,lo:0,mid:5,hi:10)
    try require(reversed == positive)
    for invalid in [[], p([(2,0),(Double.nan,8),(8,16)])] {
        do { _ = try contourSupport(invalid,rows:rows,lo:0,mid:5,hi:10); throw RootEdgeFailure.unavailable }
        catch RootEdgeFailure.invalidInput { }
    }
    return 10
}
'''


def snapshot(adapter):
    result = adapter.snapshot()
    for name in ('scripts/phase95-root-anatomy-coverage.py', SELF, SPEC):
        result[name] = adapter.sha(adapter.read(name))
    return result


def code(adapter, mode):
    original = adapter.source_code('--register-source').decode()
    marker = '        let binding = try RootStructuralMetricPrototype.register(luminance,'
    if original.count(marker) != 1:
        raise ValueError('definition_boundary')
    prefix = original.split(marker)[0]
    finish = r'''
        guard let nose = landmarks.nose, (3...32).contains(nose.pointCount) else { throw RootEdgeFailure.unavailable }
        let points = nose.normalizedPoints.map { p in
            CGPoint(x:(bounds.minX + CGFloat(p.x)*bounds.width)*Double(image.width),
                    y:(1-bounds.minY-CGFloat(p.y)*bounds.height)*Double(image.height))
        }
        let rows = (0..<16).map { Double(region.minY + (2*Int64($0)+1)*(region.maxY-region.minY)/32) }
        let counts = try contourSupport(points, rows:rows, lo:Double(region.minX),
                                        mid:Double((region.minX+region.maxX)/2), hi:Double(region.maxX))
        try requireAdmittedRegularFile(source,beneath:input)
        guard sha256Hex(try Data(contentsOf:source)) == sourceHash else { throw RootEdgeFailure.identityMismatch }
        return ["status":"source_contour_support", "source_sha256":sourceHash,
                "contracts_sha256":contractsHash, "counts":counts,
                "vision_revision":request.revision, "source_registered":false,
                "anatomical_boundary_qualified":false, "acceptance_credit":false]
    }
}
'''
    call = ('let r = try RootSourceAdapter.sourceOnly(); print(String(decoding:try JSONSerialization.data(withJSONObject:r,options:[.sortedKeys]),as:UTF8.self))'
            if mode == '--inspect-source' else
            r'let n = try contourTests(); print("{\"status\":\"generated_pass\",\"checks\":\(n)}")')
    return (prefix + finish + CORE + '\ndo { ' + call + r' } catch { print("{\"status\":\"rejected\"}"); exit(2) }' + '\n').encode()


def checked(adapter, status, raw, mode):
    value = adapter.decode(raw)
    if status != 0: raise ValueError('child_failed')
    if mode == '--self-test':
        if value != {'status':'generated_pass','checks':10} or type(value.get('checks')) is not int:
            raise ValueError('self_test')
        return value
    if set(value) != {'status','source_sha256','contracts_sha256','counts','vision_revision',
                      'source_registered','anatomical_boundary_qualified','acceptance_credit'}:
        raise ValueError('protocol')
    original = adapter.decode(adapter.read(PHASE + '95-ROI-REGISTRATION.json'))
    if (value['status'] != 'source_contour_support'
        or any(value[k] != original[k] for k in ('source_sha256','contracts_sha256'))
        or any(value[k] is not False for k in ('source_registered','anatomical_boundary_qualified','acceptance_credit'))
        or type(value['vision_revision']) is not int or not 1 <= value['vision_revision'] <= 100):
        raise ValueError('identity')
    counts = value['counts']
    if (type(counts) is not dict or set(counts) != {'paired_rows','ambiguous_rows','unsupported_rows'}
        or any(type(n) is not int or not 0 <= n <= 16 for n in counts.values()) or sum(counts.values()) != 16):
        raise ValueError('counts')
    return value


def inspect(adapter):
    before = snapshot(adapter)
    review = adapter.decode(adapter.read(REVIEW))
    if (set(review) != {'schema','status','reviewer_agent_id','files','findings'}
        or review['schema'] != 'phase95-contour-support-review-v1' or review['status'] != 'pass'
        or type(review['reviewer_agent_id']) is not str
        or not re.fullmatch(r'[A-Za-z0-9-]{8,80}',review['reviewer_agent_id'])
        or review['files'] != before or review['findings'] != []):
        raise ValueError('independent_review_required')
    results = [checked(adapter,*adapter.execute(code(adapter,'--inspect-source')),'--inspect-source') for _ in range(2)]
    if results[0] != results[1] or snapshot(adapter) != before: raise ValueError('unstable')
    return dict(results[0],schema='phase95-contour-support-observation-v1',attempts=2,
                diagnostic_identity=adapter.sha(json.dumps(before,sort_keys=True).encode()))


if __name__ == '__main__':
    try:
        adapter = coverage.dependency()
        if sys.argv[1:] == ['--review-inputs']: result = snapshot(adapter)
        elif sys.argv[1:] == ['--self-test']: result = checked(adapter,*adapter.execute(code(adapter,'--self-test')),'--self-test')
        elif sys.argv[1:] == ['--inspect-source']: result = inspect(adapter)
        else: raise ValueError('arguments')
        print(json.dumps(result,sort_keys=True))
    except Exception:
        print('{"status":"rejected","reason":"contour_support_diagnostic"}')
        sys.exit(1)
