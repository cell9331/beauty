# Phase 95 source-anatomy registration amendment

Owner authorization: 2026-09-12, explicitly approve revising ROI registration
from the same authorized portrait's actual anatomical support. Preserve
thresholds and all historical failures; freeze and validate registration before
evaluating outputs.

The original manifest remains immutable for the generated-source oracles and
historical results. Source-only registration disproved anatomical alignment of
its original image-relative boxes: eye contour 0/12, pupils 0/2, lower chin 0/7,
mouth corners 0/2 in their targets; both eye apertures disjoint from gaze targets.
Rectangle admission alone had not established anatomical alignment.

The v1 recipe uses canonical source pixels with one Vision observation. Eye
boxes, inner eyebrow segments, lower contour, lip extrema and nose crest define
the seven active directions' regions. Explicit anatomical neighbors retain
their original protection names and ceilings. Region overlap, invalid extent,
missing anatomy, changed source, changed recipe, changed manifest or different
registration digest rejects admission. Source-only construction corrected chin/
mouth and mouth-height/surrounding-region overlaps before this freeze; no
candidate output was used to choose regions. Two independent source-only runs
produce the same contract digest. Raw geometry is recomputed in memory and
never serialized; the binding contains hashes and counts only.

Thresholds, metric formulas, signs, sibling lists, parameters, original manifest,
and FACE-01 deferral are unchanged. The six-field gaze aggregate proves direction
only, with real target/locality/protection checks retained. Two adversarial gaze
tests reproduce and reject the pre-existing signal/locality bypass. Eleven
closeout classifier tests accept exactly seven passing active directions and
one honestly failed/deferred direction, reject each active failure and tampered
or stale identity, and preserve actual measured protection values. Comparator
self-test: 589 passing probes; driver self-test: 16/16.

`95-ROI-REGISTRATION.json` is frozen before the first registered output run.
Registration establishes an applicable measurement frame, not effect success.
The driver preserves previous output attempts, lets the established runner
create two fresh attempts, and treats exit 3 as a complete measurement to be
classified. It never substitutes zero protection maxima or promotes FACE-01.

## Registered baseline and repair candidate 1

Registered baseline: two identical complete 65-case attempts, semantic failure.
Report SHA256: `4f46c8addc84796bbdbe179c87e25d819cc69df55753b14e44962c1b16e3957d`.
Stable payload: `3126e064aab050df47edb33d546d1bf626126b88e7a6641342a8ced751856ce3`.
Both eyebrow directions passed. Gaze changed 198 target pixels (required 256),
with direction margin 120 and zero outside/protected changes. Chin, nose and
negative mouth failed; FACE-01 remains deferred. This is not erased by a rerun.

Candidate 1 is recorded before portrait evaluation, with the registration and
all acceptance thresholds unchanged. It connects negative mouth and nose to
observed anatomy, constrains chin disks below observed lips, and uses a linear
gaze falloff within the unchanged aperture/motion bound. Generated pixel and
mapping regression selection: 47 tests, zero failures. This does not establish
portrait success. Maximum two repair candidates in this bounded evaluation;
further semantic failure must remain explicit, not trigger an unbounded loop.

Candidate provider SHA256 identities:

- Chin: `62979c1df988bc224f62948ea4ecaf6fd44e89ffad346b6ba7dd43bd5ddf5034`
- Eye: `851bc078a07f82acfe2f902387311763684410ab07dcedfc260ca17af89165ad`
- Mouth: `1b815b3e56a14a13508641434f4e092f5a0432b829595cda30b2c65defb75843`
- Nose: `a0788b78d12060cba797bd13e54fb20c75fb8907047a4baf41ec5e6ba60d5d45`

Expanded generated regression: 106 tests passed twice from an independent fresh
scratch build, zero failures, including frozen Phase 90–94 facade semantics.
The pre-existing incremental build crashed in the malformed-root test during
broader selections but passed that test in isolation; fresh-build passes do not
erase those crashed attempts. No source workaround or test relaxation was used.

Candidate 1 portrait result: two identical complete 65-case attempts, four
active directions passed (gaze, both brow signs, bridge). Report SHA256
`4bda21a8091e0c6c42deb91d856f175d03c2d8467b5154c6163869d0681873f0`,
stable payload `5fe4163fa82b234e2a64993f5dac1ecf72032fe7f09430c5fce0a170e5edf9d9`.
Chin rejected the complete field (zero signal); root margin +1 versus +16;
mouth margin -19 passes direction but protection has 28 changed pixels / 986
RGB delta (outside RGB 1001). FACE-01 remains deferred. No closeout pass.

Candidate 2 addresses independent support defects, without changing registration:
chin rejects only paired flanks above the lip boundary rather than the entire
valid lower band, and preserves its derived radius instead of re-expanding it
with a legacy minimum; observed mouth uses anatomical gap without the legacy
minimum radius. Root uses the observed upper-eye/crest anatomical root interval
rather than only the lower crest quarter. Explicit malformed lip support must
not disappear into a nil/template fallback. This is the second bounded repair
candidate; no further output-driven attempt is authorized by this record.

Source-only follow-up confirms lower-chin eligible samples by paired flank:
2/2, 2/2, 1/2. No raw coordinates were stored. Candidate 2 retains only complete
eligible pairs and scales displacement with reduced radius to preserve the
original displacement/radius ceiling. Observed chin and mouth use linear cones
(no larger support or displacement; lower slope than quadratic), while legacy
nil-support paths retain exact historical output. New small-mouth and clipped-
chin tests plus mapping/support selection passed 44/0/0 before the final
explicit-argument-only mouth refactor. Final pre-portrait identities:

- Chin: `bf24c22a60c3236a2cc8ba863b4c0a9774e52028fa3c161995d23519d1f8871e`
- Mouth: `94c1f272bdc3a95bdb31342ac5264384cb12d3999fb6aa643e8c77edefac00d7`
- Nose: `cdf79dde31806f7efa5024bd3b66af54e70391d986f9afa2aac82a840cca15eb`
- Detector: `26299bb74d757c1bcf7962170fb1c43edd74ec47155dd36307a5b53818ff2b4f`

Comparator, manifest, source and ROI binding are unchanged from candidate 1.

Candidate 2 final focused selection passed 117/0/0. Ordinary full SwiftPM
executed 904 methods with eight opt-in skips and eight assertion failures in
one FACE-01 positive-acceptance method. The untouched HEAD
`24ac1f0db7ddf70982525eb926df68790fe43571` was independently exported to a fresh
temporary SDK-only tree and reproduced all eight exact failures (3 methods,
8 assertion failures): margin 12, sibling minima 3/0, outside 2724/284565,
central protection 909/138177. Thus this is a pre-existing deferred-control
test-contract conflict, not a passing gate or a repair-induced regression.
Owner disposition for explicit negative/deferred coverage was requested;
the original test remains unchanged pending that decision.

## Candidate 2 terminal result

Two identical complete 65-case attempts still report semantic failure. Report
SHA256 `061b425794e9fbde01cdc644433b3627bf0714e1bc9d86bed54ffe7a41313050`;
stable payload `ca8cabeb37d62fc43b38e4fbb50b4fbbd0cfa8f80d12fe0fa9ae05d8ed39c328`.

| Direction | Target changed pixels | Source/neutral margin | Verdict |
| --- | ---: | ---: | --- |
| chinTaper | 36361 | 5 | fail: direction and sibling distinctness |
| gazeCorrection | 306 | 120 | pass |
| eyebrowHeadSpacing positive | 13224 | 20 | pass |
| eyebrowHeadSpacing negative | 13383 | -23 | pass |
| noseBridge | 6769 | 107 | pass |
| noseRootNarrowing | 5938 | 0 | fail: direction and sibling distinctness |
| mouthWidth negative | 9161 | -7 | fail: direction and sibling distinctness |
| faceContourSmooth | 0 | 0 | deferred, not promoted |

Every outside/protected changed-pixel and absolute-RGB value is zero. Target
signal predicates pass for all seven active directions. Remaining failures are
the unchanged semantic margin/distinctness predicates, not registration or
locality. Three controls are still unqualified; four passes do not prove CLOSE-01.
The bounded two-candidate repair is stopped without a third attempt or weaker
threshold. Further algorithm work needs a new explicit repair disposition;
the pending deferred FACE-01 test-contract decision and reviewed compatibility
boundary/evidence-chain correction also remain prerequisites for final closeout.
The full archive-first no-skip wrapper was not run or credited.
