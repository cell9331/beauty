# Phase 92 owner-authorized repair candidates

Owner repair authorization: `155d4c7`; reviewed plan: `10aa6cd`.
Independent generic-agent plan check passed after explicit freshness-suite and
closeout-contract corrections. Typed planner initialization was unavailable.

## Registration and pre-candidate evidence

Independent production-mapping registration test first failed four assertions,
then passed one method after source-derived observation correction `01b7883`.
The frozen pixel test, manifest and comparator remained byte-identical.
With restored production, public pixels remained RED: seven assertions, with
signed margins +44/+17 and unilateral peer changes 29/31. Recovery passed.
Provider RED discovered 16 methods with 71 known assertions, zero unexpected.

## R1 — rejected

Cumulative implementation attempt: 3; repair-cycle candidate: 1.
Provider invariant tests passed 16/16 after a zero-rounded taper carrier was
correctly treated as no work at the half boundary.

| Aggregate | Positive | Negative |
| --- | ---: | ---: |
| Source/neutral target changed pixels | 644 | 440 |
| Source/neutral target RGB delta | 37,116 | 23,359 |
| Signed source/neutral gap Q16 | +24 | +16 |

Opposite distinction: 8 Q16; four whole-brow margins: 50/11/58/3.
All outside/outer/eye/background/watermark maxima: 0/0.
Unilateral changes: 322/322; rejected-peer changes: 0/0.
Recovery: 644 changed, recovered-equal 1, rejected-source-equal 1.
Public pixels: 3 methods, 7 failed assertions, zero unexpected; safety and
recovery methods passed. Failure classes: target_signal, signed_direction,
opposite_sign_distinction, whole_brow_minus_distinction.

The negative target-centered disks overlap near the midline and fail the
directional oracle. The candidate is rejected and production restored before
reviewing a revised support placement. No oracle, threshold, public API,
shared renderer, or shader change is authorized by these results.

## R2 — rejected

Cumulative implementation attempt: 4; repair-cycle candidate: 2.
Provider invariants passed 16/16. Public pixel suite: 3 methods, 4 failed
assertions, zero unexpected. Registration/extra peer class: 2 methods,
2 failed assertions, zero unexpected. Registration itself remained GREEN.

| Aggregate | Positive | Negative |
| --- | ---: | ---: |
| Source/neutral target changed pixels | 636 | 627 |
| Source/neutral target RGB delta | 44,260 | 31,793 |
| Signed source/neutral gap Q16 | +35 | -15 |

Opposite distinction: 50 Q16; four whole-brow margins: 39/22/89/28.
Outside/outer/eye/background/watermark maxima: 0/0. The frozen signal's
changed-pixel counter reported zero rejected-peer changes, but exact RGB
assertions detected 12/16 total peer delta. The additional exact-byte peer
test independently detected three changed pixels on two requests. Both
failures reject the candidate regardless of the aggregate counter's tolerance.
Recovery: 636 changed, recovered-equal 1, rejected-source-equal 1.
Failure classes: signed_direction, peer_protection. Production restored before
further revision; frozen image/metric/threshold/registration unchanged.

## R3 — rejected

Cumulative implementation attempt: 5; repair-cycle candidate: 3.
Provider short-trace testing caught Float reconstruction at the exact cutoff;
conservative inward radius slack corrected the implementation without relaxing
its inequality. Provider tests then passed 17/17. The pixel gate was also run
before that correction; it has no pass credit and was not repeated because
the independent whole-brow distinction already disqualified the formula.

Observed public aggregates: target changed 700/730, RGB 71,167/46,938,
signed gap +65/-24, opposite 89, whole-brow margins 9/52/98/37.
Outside/outer/eye/background/watermark maxima: 0/0. Both-sign exact peer test
and registration: 2/2 passed. Public suite: 3 methods, one assertion failure
(`whole_brow_plus_distinction`). Recovery: 700 changed, both equality flags 1.
The linear support achieved both signs and peer protection, but positive
motion was too close to whole-brow output. Formula rejected and restored;
the next reviewed revision must retain the local support and distinguish the
head displacement from the whole-brow nominal displacement.

## R4 — accepted focused gates

Cumulative implementation attempt: 6; repair cycle: 1; candidate: 4.
Independent plan review passed before implementation. Only nominal head
magnitude changed from R3 to W*0.020*abs(u)*w; all support and safety bounds
and frozen oracle thresholds remain unchanged. Provider 17/17 passed first,
then frozen public pixel 3/3 and independent registration/peer 2/2 passed;
22 tests total, zero failures and zero skips.

Target changed: 699/720; source and neutral RGB: 61,174/45,676.
Signed source and neutral gap Q16: +48/-22; opposite: 70;
whole-brow distinctions: 26/35/96/35. Outside, outer, eye, background and
watermark maxima: zero changed pixels and zero RGB delta.
Unilateral signal: left 350, right 349, peer changed 0/0, exact peer bytes pass.
Recovery: 699 changed, recovered-equal 1, rejected-source-equal 1.
Extent, alpha, metadata, determinism and redaction assertions passed.

Rejected production commit/revert pairs: R1 2c9b7d8/82e1819,
R2 c1d177d/ead38e3, R3 a5375e3/4a1bb42. Historical attempts 1–2 remain
unchanged in 92-01/02/05 evidence. Focused acceptance does not yet imply
phase closeout or milestone completion.


## R5 — dense-trace review correction (cumulative attempt 7)

- Prior R4 sparse semantic PASS is retained; independent review found actual
  dense-trace folding, so it was not promoted to phase completion.
- Reviewed fixed candidate: per-side actual sum norm/radius <=0.9, preserving
  sparse controls and all targets/radii; final Float reconstruction revalidated.
- RED commit `4a92373`: one test, 12 expected assertions, zero unexpected failures.
- Accepted fix `470ae0d`: provider18/0/0, public/registration5/0/0;
  compatibility/freshness217/0/2 (two established portrait opt-ins only).
- Frozen metrics unchanged: signs +48/-22, opposite70, siblings26/35/96/35;
  target699/720, RGB61174/45676; all protected maxima0/0; peer0/0;
  recovery equality1 and rejected-source equality1.
- Independent implementation review PASS. This is per-side inverse-field safety,
  not arbitrary combined-field injectivity or live portrait/device evidence.
