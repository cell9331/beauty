# 鼻部双向控制与滑杆预览修复

Status: `completed` (bounded implementation and targeted verification). Owner request: Meitu reference has six bidirectional nose
sliders; current effects are weak, and preview does not keep up with dragging.
The clarified issue is response latency, not a redesign of the editing journey.

## Scope and acceptance fixed before implementation

- Six SDK nose fields normalize signed values, retain keys/defaults/caps and
  positive directions; host controls expose -100/0/+100 with neutral at center.
- At most one render plus a replaceable latest request. Limit starts during
  continuous dragging, bypass the pending timer on release, preserve final
  snapshot/export/undo and reject obsolete workers. Debug re-detection waits
  for settled preview instead of competing with drag renders.
- Reduce per-pixel dense-map overhead with byte-identical sampling validation.
  Inspect small nasal support that can disappear between lattice quantiles;
  improve source-anchored support without relaxing displacement/gradient bounds.
- Actual pixel oracles: signed direction, nonzero monotone amplitude at four
  settings, source-exact exterior, alpha/dimensions/determinism/neutral identity,
  missing/invalid support abstention. No-op and opposite-direction controls must
  fail those oracles. Generated inputs are eligible; real portraits optional.
- Minimum related SwiftPM parameter/resolver/nose/dense sampling tests; one
  existing iPhone 15 Pro iOS 17.5 simulator with native session/control/pipeline
  tests and a bidirectional slider screenshot/interaction. No full regression,
  new backend/model, device install, archive mutation or distribution.

## Claim boundary

Targeted responsiveness and nasal geometry improvements do not establish Meitu
visual parity, 3-D nose height, relighting or device performance. Preserve those
unmet comparison items separately from implemented contracts.

## Implementation and diagnosis

- Five unit-only fields now use signed normalization/capping/backend admission;
  tip keeps its signed public behavior. No keys/defaults/absolute caps changed.
  All host nose ranges are signed; negative active-tool state is retained.
- Timer and in-flight worker are separate. First request starts immediately;
  subsequent starts are limited at 40 ms, with one replaceable pending snapshot.
  Release bypasses the timer; existing synchronous render finishes before latest
  pending work starts. Debug output re-detection waits for settled editing.
- Quantiles could miss small root support entirely. Nasal anatomy and local
  centers are required only when a nose field is active, leaving sibling-only
  lattices unchanged. Source-anchored kernels and cap-shape admission repair
  intensity-dependent attenuation/nonmonotone motion seen in the first candidate.
  Dense size now affects width/length, tip has its own center, wing/lift broader
  support, and bridge greater admitted amplitude. Legacy positives retain hashes.
- Sampler precomputes cell membership, skips source-exact cells and visits only
  active cells. Reference pixel-center interpolation/rounding is byte-identical
  on portrait/landscape, odd and small dimensions; safety limits are unchanged.

## Actual verification

**85 different SDK tests passed, 0 failures / 0 skips in final related runs.**
67 parameter/reconstruction/resolver/provider/repair/registration/dense
support+combination/shared-stage/Metal-geometry tests; 8 dense-map tests;
4 signed-nose pixel/isolation tests; 6 CPU/Metal parity tests with
`BEAUTYSDK_REQUIRE_METAL_PARITY_EXECUTION=1`. This is a scoped regression, not
an all-opt-ins/all-SDK closeout.

Generated source-fixed actual pixels cover six fields × two directions × four
settings × two dimensions (480×640, 640×480), monotone directed change,
>1 pixel endpoint, exterior/alpha/repetition and neutral/missing-support cases.
Paired-eye root cases keep complete eye boxes and lip-band bytes exact. No-op
and wrong-direction controls fail the same fixed direction predicate. Inactive
nose anatomy leaves sibling lattice and output bytes identical.

**20 different external native tests passed:** 5 controls, 11 sessions,
3 real-renderer pipelines and 1 UI. Same existing iPhone 15 Pro / iOS 17.5,
UDID `2CE927C9-9303-4A9B-9C03-F28C42045186`, portrait/current font,
parallel testing disabled, stable host `.build`. The native renderer exercises
six tools at ±25/50/75/100 (48 outputs), actual 478-point support, original
immutability, warnings, repeated combination, prepared/fresh agreement and
original-resolution metadata-stripped export. Final nose pipeline adds actual
preview dimensions, sRGB and alpha checks. UI verifies both halves of all six
sliders and reachable undo/bottom controls; both sign screenshots were inspected.

Simulator Debug 48-output measurements: first implementation median **308.0 ms**;
cell-limited sampler recheck **124.9 ms**; final metadata recheck **103.9 ms**.
These are SDK+pixel-materialization durations on this simulator, exclude queue
and debug detection, and do not prove physical-device latency or fixed fps.

Initial candidate failed monotonicity/protection and tiny-support admission;
fixed by source kernels, cap admission and crest knots, without lowering pixel
thresholds. Swift type/function-name/loop and test-fixture construction errors were corrected before their respective tests ran. An old synthetic dense
wing lost eligibility; observed-support fallback restored compatibility. Two
legacy negative-no-op assertions were updated to the new signed contract;
positive scaling/cutoff/safety assertions remain. First UI run tapped an
occluded offscreen category; explicit category scrolling repaired test access.
The failed receipts remain separate from final passes.

Boundary live/self-test, two archive identities, example storage, host field/cap
bindings, links and whitespace checks passed. No retained shader, model or
frozen qualification source/receipt was changed. Temporary private evaluation
input is removed after verification; only aggregate SDK evidence persists.

## Remaining comparison limits

The local effects are stronger and genuinely bidirectional, but Meitu appearance
parity is not accepted. Root/bridge remain surface-width geometry; dedicated
lighting, 3-D height, complete nostril morphology and whole-nose/philtrum
coordination are outside this implementation. `NOSE-REF-01` keeps those limits.
No full app/SDK regression, new simulator, font/orientation matrix, physical
installation, performance/thermal qualification or distribution was performed.
