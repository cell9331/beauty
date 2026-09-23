---
phase: 95-compatibility-and-sdk-only-closeout
reviewed: 2026-09-22T05:13:54Z
depth: standard
files_reviewed: 2
files_reviewed_list:
  - scripts/phase95-root-structural-metric.py
  - scripts/test-phase95-root-structural-metric.py
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
status: clean
---

# Phase 95: Source-hypothesis reduction review

## Narrative Findings (AI reviewer)

No actionable BLOCKER or WARNING found in the bounded review of `measure_hypotheses`, its existing `measure` dependency and the generated tests. Both source files were read in full. This conclusion applies only to the reduction of a caller-supplied hypothesis collection.

At `scripts/phase95-root-structural-metric.py:61-68`, the reducer admits only a nonempty tuple of at most 64 interpretations. It evaluates every interpretation through the existing strict cohort validator before taking minima; an invalid interpretation raises rather than being dropped. The minimum source, neutral and sibling margins across all interpretations implements the required conjunction: structural credit is possible only when every interpretation meets every unchanged 16 Q16 predicate.

The dependency at lines 22-50 enforces the same fixed 12..16 registered integer rows and the exact six roles in each interpretation. All per-row width intervals must be ordered, positive, bounded Fractions. Equal-row aggregation and outward rounding remain unchanged. Sibling distance is the conservative absolute interval separation and cannot gain credit when one sibling copies or overlaps the candidate.

A fixed outer-width interpretation therefore prevents a moving internal-width interpretation from receiving credit, regardless of order or how many passing interpretations are supplied. This is a mathematical reduction property; the reducer has no image, contrast or anatomical information from which to discover that outer interpretation.

## Independent verification

| Generated check | Result |
| --- | --- |
| Submitted suite, ordinary Python | 14/14 passed |
| Submitted suite, Python optimization enabled | 14/14 passed |
| Independent two-interpretation analytic margin matrix, including reversed order and different source widths | 72/72 matched conjunction and conservative source/neutral margins |
| Delete each row from each of the six roles in one interpretation while another interpretation passes | 72/72 rejected |
| Copy each of the three exact siblings from the candidate in each of three interpretation positions | 9/9 returned no structural credit and zero sibling margin |
| Maximum admitted collection of 64 valid interpretations | Accepted with expected structural result |

The independent matrix used full-image width 512, source widths 56 and 40, exact rational candidate contractions, and margins -32/0/15/16/17/32. Thus the fixed outer-width case and the narrower moving internal-width case have distinct independently assigned latent widths. No production control-point output or registrar result supplied the oracle. Only aggregate counts/results are retained; no pixels, geometry, private locators or child transcripts were persisted.

## Limits and caller obligations

- This review does **not** establish that any registrar supplies all plausible interpretations, that interpretation indices retain their registered identities across outputs, or that supplied intervals correspond to the same source structure. Those are explicit caller obligations at lines 56-59.
- A caller omitting a stationary outer interpretation can still supply a passing collection. The reducer cannot detect missing hypotheses without an independently admitted source registration and commitment. The review must not be used as that admission.
- A collection larger than 64 must reject at the registrar boundary; truncating to the favorable 64 would violate the contract.
- Source-only structure ownership, anatomical relevance, candidate completeness, forward correspondence and image-model validity remain unverified here. Target signal, protected regions, metadata and the complete portrait conjunction remain additional requirements.
- No private image, source registrar, native SwiftPM or full no-skip execution was run by this reviewer. The coordinator's separately reported 925/0/0 full gate is not credited as reviewer execution or as root semantic acceptance.
- No approval/completion JSON or source edit was made. Only this report was created. Existing review artifacts remain unchanged.

## Reviewed identities

| File | SHA-256 |
| --- | --- |
| `scripts/phase95-root-structural-metric.py` | `9abd0bbafe63ded89c730b1bf0858fc321acfa16cc0b52d196d6fecb5739d2a3` |
| `scripts/test-phase95-root-structural-metric.py` | `280598ce7ca2bff0382401eb2b98eadb309b4d0a3ea3971e0d6efadb9c18ca13` |

_Reviewer: closeout_review (gsd-code-reviewer); generated hypothesis reduction only._
