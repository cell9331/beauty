# Owner-authorized Phase 95 repair resumption

## Current checkpoint (2026-09-14)

Candidate 5 finished with a complete semantic failure envelope. Payload SHA256
`2049ea8a89fa2e3d7525e1c7d5b6894fa6132a6d38fb1c8899c20ef267285001`
matches the two-attempt reconciliation digest. Full report SHA256
`dff126fe0bbf17b1980ac90b8f75f8d0e6f224ca1b612a532c94497a5e09ae5b`.
Current chin/nose source hashes still match the pre-run freeze below.

| Direction | Margin Q16 | Target changed pixels | Verdict |
| --- | ---: | ---: | --- |
| chin | 14 | 54740 | fail (requires >=16) |
| gaze | 120 | 306 | pass |
| eyebrow positive | 20 | 13224 | pass |
| eyebrow negative | -23 | 13383 | pass |
| bridge | 107 | 6769 | pass |
| root | 0 | 5845 | fail (requires >=16) |
| mouth negative | -32 | 11204 | pass |
| contour | 0 | 0 | deferred, not promoted |

All outside and protected changed-pixel/RGB values are zero. Candidate 5's
23 focused tests pass; post-archive SDK boundary and diff checks pass. No
candidate-5 full-suite/no-skip or independent review credit is inferred.
The rendering sessions and their temporary sleep assertion have ended.

Water-fill produced the same chin target measurements as candidate 4; it did
not improve this portrait's cap-limited result. Neither canonical sampling nor
the tested canthus-bounded root placements produced a passing root margin.
Further work would propose revising the internal chin displacement/support and
root-field contracts, with new generated safety/semantic coverage before live
scoring. This revision is not yet authorized or implemented. Frozen ROI,
thresholds, public parameter caps, fixture, siblings and failure history remain
unchanged. CLOSE-01 is still unproven; no success receipt is published.

2026-09-13: after receiving the explicit remaining-failure report and proposal
to repair the three controls and update deferred FACE-01 coverage, the owner
replied “修复”. This resumes algorithm repair beyond the prior stopped two
candidates; that history remains unchanged. Same portrait, ROI digest, metric
formulas, signs, siblings, parameters and acceptance thresholds remain frozen.

## Candidate 3, frozen before portrait scoring

Ordered inward horizontal linear fields admit a tighter no-fold proof than a
generic summed radial norm: left-target x values precede all right-target x
values; in between, du/dx <= 0. Outside that interval, its positive part is
bounded by the corresponding side's sum(abs(deltaX)/radius). Requiring each
sum <= 0.8 guarantees inverse-map det(J) >= 0.2 everywhere differentiable and
monotonicity through cone cusps. Y remains unchanged. Original face-relative
physical displacement caps remain; bridge, gaze and legacy nil-support paths
are unchanged. Nose root walls use observed inner eyes when present; mouth
disks stay inside corner quarter-gap envelopes; chin preserves a 0.04-face-width
lip clearance and uses at most 3/4 of each eligible lip-to-chin gap.

Independent finite-difference/adversarial safety tests and expanded generated
regression passed 106/0/0. Additional non-frozen observed-support tests now test
the analytic bound and anatomical quarter-gap envelope instead of the prior
candidate's implementation-specific summed radial norm/box. Original Phase
90–94 active-control effectiveness assertions and all registered thresholds
are unchanged.

Pre-portrait SHA256:

- Chin: `d4ad1ec6accd2d4b62f09602d700b2b9c35455cf4790f95018d993840c9a7631`
- Mouth: `826b1a3ce9c24d592015bc780ec8b1e41734dc705283841420d0f410ca7b1d6a`
- Nose: `1b73a7216f38578a3ea1301140cad4097a424f36da16d7ac75910c1c35e997a4`
- Point/safety contract: `b0a5b8247caeee703247be3cec3a7b7fcab75956c4cc16f6732472873a48f28a`

## Test-contract corrections

Candidate 3 executed all 65 cases twice: stable payload SHA256
`8fe9c5a79753d77024d13dfc0bac347320121c2ecf0b2197f697f666f680d40a`.
Five active directions pass, including negative mouth (-32). Chin (14) and
root (0) remain below 16. All outside/protected pixel and RGB deltas are zero;
FACE-01 remains deferred. This is a failed evaluation, not a completion receipt.

## Candidate 4 sampling correction

A generated vertical-gradient regression exposed 2274 changed bytes from a
horizontal-only warp: normalized pixel centers were converted back with
`u*(extent-1)` instead of `u*extent-0.5`. Global correction broke frozen legacy
mouth receipts and was rejected in an isolated source copy. The scoped fix
marks only analytically admitted observed chin/root/negative-mouth fields;
CPU rendering uses canonical sampling only when every field is marked. Legacy
and mixed field sets retain prior sampling. No Metal/public backend changes.
The isolated scoped fix passed 25 targeted tests, including exact gradient
identity and frozen legacy mouth receipts. Candidate 3's no-fold derivation
describes its normalized field only; canonical sampling makes that derivation
applicable to the admitted homogeneous CPU field (not legacy/mixed rendering).

## Test-contract corrections (continued)

## Candidate 5 pre-portrait freeze

Chin water-fills the same per-side 0.8 slope budget instead of discarding unused
shares of physical-cap-limited points. No physical displacement or safety
ceiling increases. Nose root fields center at the crest-to-inner-canthus
midpoint, with unshifted and shifted disks contained inside the canthus
interval and the same crest/eye vertical band. No metric/ROI amendment.
Focused selection passes 23/0/0, including new budget redistribution and
canthus-containment tests and legacy chin/nose/mouth pixel oracles. Recorded
test durations are unusually long and are not performance evidence.

- Chin SHA256: `6a300c06b844cd1e0ad7e2bf5f68ba66b48fafe749206bd6debdcfb419a6cda6`
- Nose SHA256: `7d6f822028be616c2fc947db2600d0023c655bbba51bc77c6bbfd3dd93724c2c`
- Other production identities retain candidate 4 values below.

Candidate 4 completed both 65-case attempts identically. Stable payload SHA256
`c32daa37544fa0161d7fac269a8956c594d81ead3367ae9fc625a54afe187fa3`.
Five active directions pass. Chin/root/negative-mouth margins are 14/0/-32;
target changed pixels are 54740/9851/11204. Every outside/protected pixel/RGB
delta is zero. Full ordinary SwiftPM exited zero, but no exact suite count is
credited from its truncated tail. No archive-first no-skip or completion claim.
The runner's intermediate render_failure envelope is its deliberate pre-run
fail-closed placeholder, not evidence of a competing writer or final failure.

Candidate 4 pre-portrait freeze: workspace fresh build passed 22 focused
methods, zero failures/skips, including the previously red sampling regression.
Source SHA256:

- Chin: `38906ba2f5375459042e91c8fe0cf93e5071605f010ca3ec11414614acc1fe8f`
- Mouth: `ad7c291fb37e0fd31a37470b9aa57a4d2354d1fe24a19ee564617c07bd5ba1d1`
- Nose: `6836075bc6cc182d9f2c8c7c21a18ec71ce47ac0a858723f86895e6c746690d5`
- Point: `8683da97791e83283d72fb9b86fd70d1fc7b901effedab06280fb4e7d78aba2e`
- CPU pipeline: `bbffaffbeecb6432ee1c917e9b7d2143fae8ca46028aedeecb01f5f690b0981a`

FACE-01 old test SHA `7988a202c22aa4c63fa9057d6cb08c6f28594867aa161c8c6730a5181e529d2f`
becomes `4b26f8462f526f2958bb4c583dd11d200b6760944f305b063cfeaeea9677bdff`.
It retains all original numerical predicates, checks the exact eight failed
categories, neutral identity, repeatability, alpha and background/watermark
protection, and asserts non-promotion. No skip/expected-failure masking is used.

The compatibility test now checks the unchanged backend file's complete SHA256
instead of two string fragments. Old test SHA
`365c886a9646f98dc96ab3f0fe6991b2899557ac09aa539d5b07745cf16d1761`, new
`14abb90776386ad1568eeb5fdda124a04cc4449a64c567bfea77f9e3169e4926`.
Original COMPAT binding SHA
`4eaf1a6d13c2a3da2d7422bb2edf1600e174e1b7ba5956016d969f1d6a48ab4b`
is preserved and is not claimed to approve the changed test. New execution
evidence is separate; independent review remains pending, not self-authored.
