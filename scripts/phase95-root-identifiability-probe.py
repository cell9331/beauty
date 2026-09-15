#!/usr/bin/env python3
"""Generated-only hypothesis probe, NOT a portrait metric or acceptance gate.

Runs the exact frozen Swift math without its CLI. No private image input,
provider import, threshold amendment, receipt promotion, or third-party package.
"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys

FROZEN = "7100a47cc3176035cb097016b252f00be477307f0d75fde932bffa869027287b"
SWIFT = r'''
func probePlane(_ contraction: Int, competitor: Bool = false,
                gain: Double = 1, offset: Double = 0) throws -> RootEdgePlane {
    let row = (0..<512).map { x -> Double in
        var value = (x >= 200 + contraction && x < 312 - contraction) ? 160.0 : 120.0
        if competitor && (140..<170).contains(x) { value += 30 }
        return value * gain + offset
    }
    return try .init(width: 512, height: 32, values: Array(repeating: row, count: 32).flatMap { $0 })
}
// Area correlation prototype: exhaustively enumerate integer translations.
// Fixed, generated-only anchor locations are NOT anatomical registration.
// The grid result is NOT a confidence interval for arbitrary images/subpixels.
func probeMatch(_ source: RootEdgePlane, _ output: RootEdgePlane, center: Int) throws -> Int {
    let a = (-10...10).map { source.values[center + $0] }
    let ma = a.reduce(0,+) / Double(a.count)
    let aa = a.map { $0 - ma }, va = aa.map { $0 * $0 }.reduce(0,+)
    guard va > 0 else { throw RootEdgeFailure.unavailable }
    var scores: [(Int, Double)] = []
    for d in -8...8 {
        let b = (-10...10).map { output.values[center + d + $0] }
        let mb = b.reduce(0,+) / Double(b.count)
        let bb = b.map { $0 - mb }, vb = bb.map { $0 * $0 }.reduce(0,+)
        if vb == 0 { continue }
        let score = zip(aa, bb).map { $0 * $1 }.reduce(0,+) / sqrt(va * vb)
        scores.append((d, score))
    }
    scores.sort { $0.1 > $1.1 }
    guard scores.count > 1, scores[0].1 > 1 - 1e-12,
          scores[0].1 - scores[1].1 > 1e-8,
          abs(scores[0].0) < 8 else { throw RootEdgeFailure.ambiguous }
    return scores[0].0
}
do {
    let roi = RootEdgeRegion(minX: 100, maxX: 412, minY: 0, maxY: 32)
    let source = try probePlane(0)
    let registration = try RootStructuralMetricPrototype.register(source, roi: roi)
    let narrow = try probePlane(2)
    let before = try RootStructuralMetricPrototype.width(source, registration: registration,
                                                        expectedCommitment: registration.commitment)
    let after = try RootStructuralMetricPrototype.width(narrow, registration: registration,
                                                       expectedCommitment: registration.commitment)
    // Independent pixel-domain truth, not the generator's requested amount.
    // This oracle is specific to the unmodified two-level generated fixture.
    func observedWidth(_ plane: RootEdgePlane) throws -> Int {
        var widths: [Int] = []
        for y in 0..<plane.height {
            let row = Array(plane.values[(y * plane.width)..<((y + 1) * plane.width)])
            guard row.allSatisfy({ $0 == 120 || $0 == 160 }) else { throw RootEdgeFailure.invalidInput }
            let bright = row.indices.filter { row[$0] > 140 }
            guard let first = bright.first, let last = bright.last,
                  last - first + 1 == bright.count else { throw RootEdgeFailure.invalidInput }
            widths.append(bright.count)
        }
        guard let width = widths.first, widths.allSatisfy({ $0 == width }) else { throw RootEdgeFailure.invalidInput }
        return width
    }
    let sourceWidth = try observedWidth(source), candidateWidth = try observedWidth(narrow)
    guard sourceWidth == 112, candidateWidth == 108 else { throw RootEdgeFailure.invalidInput }
    let truthQ16 = (sourceWidth - candidateWidth) * 65536 / source.width
    guard try observedWidth(source) - observedWidth(probePlane(0)) == 0,
          try observedWidth(source) - observedWidth(probePlane(-2)) == -4 else {
        throw RootEdgeFailure.invalidInput
    }
    guard truthQ16 >= 16, before.lo - after.hi < 16 else { throw RootEdgeFailure.invalidInput }
    var zeroShiftCompatible = 0
    for pair in registration.pairs { for anchor in [pair.0, pair.1] {
        if RootStructuralMetricPrototype.compatible(anchor, narrow, Double(anchor.edge)) {
            zeroShiftCompatible += 1
        }
    } }
    guard zeroShiftCompatible == 32 else { throw RootEdgeFailure.invalidInput }
    let clutter = try probePlane(0, competitor: true)
    var clutterRejected = false
    do { _ = try RootStructuralMetricPrototype.register(clutter, roi: roi) }
    catch RootEdgeFailure.ambiguous { clutterRejected = true }
    guard clutterRejected else { throw RootEdgeFailure.invalidInput }
    var matched = 0
    for contraction in [-2, 0, 2] { for gain in [0.5, 1.0, 1.25] { for offset in [0.0, 12.0] {
        let output = try probePlane(contraction, competitor: true, gain: gain, offset: offset)
        guard try probeMatch(clutter, output, center: 199) == contraction,
              try probeMatch(clutter, output, center: 311) == -contraction else {
            throw RootEdgeFailure.invalidInput
        }
        matched += 1
    } } }
    var negatives = 0
    let flat = try RootEdgePlane(width: 512, height: 32, values: Array(repeating: 120, count: 512 * 32))
    do { _ = try probeMatch(flat, flat, center: 199); throw RootEdgeFailure.invalidInput }
    catch RootEdgeFailure.unavailable { negatives += 1 }
    let periodic = try RootEdgePlane(width: 512, height: 32,
        values: (0..<(512 * 32)).map { $0 % 4 < 2 ? 120 : 160 })
    do { _ = try probeMatch(periodic, periodic, center: 199); throw RootEdgeFailure.invalidInput }
    catch RootEdgeFailure.ambiguous { negatives += 1 }
    // A pure ramp's affine brightness normalization cannot identify translation.
    let ramp = try RootEdgePlane(width: 512, height: 32,
        values: (0..<(512 * 32)).map { Double($0 % 512) / 4 })
    do { _ = try probeMatch(ramp, ramp, center: 199); throw RootEdgeFailure.invalidInput }
    catch RootEdgeFailure.ambiguous { negatives += 1 }
    let report: [String: Any] = [
        "kind": "generated_only_identifiability_probe", "phase_complete": false,
        "known_contraction_q16": truthQ16, "observed_source_width": sourceWidth,
        "observed_candidate_width": candidateWidth,
        "frozen_conservative_margin_q16": before.lo - after.hi,
        "zero_motion_explanations_retained": zeroShiftCompatible,
        "remote_edge_rejects_known_generated_structure": clutterRejected,
        "integer_correspondence_cases": matched, "ambiguous_or_unavailable_negatives": negatives,
        "portrait_scoring_attempts": 0, "acceptance_credit": false
    ]
    print(String(data: try JSONSerialization.data(withJSONObject: report, options: [.sortedKeys]), encoding: .utf8)!)
} catch {
    print("{\"kind\":\"generated_probe_failed\"}")
    exit(2)
}
'''


def main():
    if sys.argv[1:] != ["--self-test"]:
        raise SystemExit("usage: phase95-root-identifiability-probe.py --self-test")
    path = Path(__file__).resolve().parent / "phase95-root-edge-metric.swift"
    data = path.read_bytes()
    if hashlib.sha256(data).hexdigest() != FROZEN:
        raise SystemExit("frozen_metric_identity_mismatch")
    marker = '\nvar rootEdgePrototypeStage = "initialization"\n'
    source = data.decode()
    if source.count(marker) != 1:
        raise SystemExit("frozen_metric_entry_mismatch")
    run = subprocess.run(["swift", "-"], input=source.split(marker)[0] + SWIFT,
                         text=True, capture_output=True, timeout=180)
    if run.returncode != 0:
        # Generated-only compiler output, bounded for developer diagnostics.
        print(run.stdout[:4000], end="")
        print(run.stderr[:4000], file=sys.stderr, end="")
        raise SystemExit(run.returncode)
    result = json.loads(run.stdout)
    result["frozen_metric_sha256"] = FROZEN
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()
