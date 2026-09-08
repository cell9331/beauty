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
