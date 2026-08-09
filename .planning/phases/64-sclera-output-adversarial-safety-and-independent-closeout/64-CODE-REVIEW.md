---
phase: 64-sclera-output-adversarial-safety-and-independent-closeout
reviewed: 2026-08-09T02:12:00Z
depth: standard
independent: true
findings:
  critical: 4
  warning: 1
  info: 0
  total: 5
status: blocked
---

# Phase 64: Fresh Pre-Promotion Code Review

**Status:** BLOCKED

The corrected bilateral oracle is materially stronger than the superseded
six-pixel proof, but the fresh independent review found four HIGH/BLOCKER
issues. No finding is resolved by a green test count, and this report grants no
promotion authority.

## HIGH / Blocker Findings

### CR-01: A demonstrated asymmetric protected-pixel leak was tuned out of the final grid

Plan 64-06 recorded that its first asymmetric right-eye fixture placed a
protected pixel inside an actual proposal. The leaking case used a larger
accepted-neighborhood perturbation; the retained test reduced the contour,
pupil and skew offsets until it passed, while the explicit rejected-boundary
case is much farther away. This leaves a known safety counterexample outside
the final matrix.

**Required remediation:** Reinstate the leaking asymmetric case and sweep its
surrounding boundary. Harden production containment or prove that the exact
case fails closed under a documented calibrated envelope.

### CR-02: Collinear overlap and non-adjacent endpoint touches can evade contour validation

The provider's self-intersection check detects strict proper crossings only.
Collinear overlap, edge retracing and non-adjacent endpoint contact can pass the
current predicate even when a unique, finite, in-range contour is
non-anatomical.

**Required remediation:** Use inclusive segment intersection with collinear
on-segment handling, reject retraced/touching non-adjacent edges, and add
adversarial malformed-contour tests.

### CR-03: T-64-06 does not inspect tracked, staged and working content

The closeout checker combines tracked, staged, working and untracked names, but
its privacy function examines only those names and the in-memory aggregate.
Sensitive content under a neutral filename can therefore pass the HIGH gate.

**Required remediation:** Fail closed while scanning tracked blobs, staged
blobs, working changes and relevant untracked regular files for prohibited
content and media. Scanner/read failures must remain aggregate-only failures.

### CR-04: T-64-05 accepts a stale pre-correction review

The prior original-detail artifact predates the Plan 64-06 production/test
correction and has no source-freeze or run-freshness binding. Token presence
alone lets the checker accept it despite D-16 invalidation.

**Required remediation:** Regenerate the blinded original-detail review after
the final relevant source revision and bind it to an immutable source state.
Any subsequent relevant change must invalidate it.

## Warning

### WR-01: Strict-helper live execution is suppressed from the durable audit trail

The private runner parses the live helper child result but emits only its
generic fixed runner result. Emit a fixed, path-free child-status field so the
live helper invocation is distinguishable from helper self-test evidence.

The existing DeviceRGB warning is not scored here: named-sRGB/SAFE-06 remains
exclusively Phase 65 scope.

## Validation Signals Reviewed

- Focused provider/composition/integration/adversarial/renderer execution:
  68 tests, zero failures.
- Closeout checker mutation execution: 18/18 rejected.
- Isolated T-64-03, T-64-05 and T-64-06 commands mechanically returned green;
  T-64-05 and T-64-06 are false-green under CR-03 and CR-04.
- The bilateral aggregate reported 27 scenarios, 744 actual proposals and
  1,632 protected pixels with zero reported intersections/mismatches; CR-01 and
  CR-02 prevent that aggregate from authorizing promotion.

No production, test, checker or private-runner file was changed by this review.
