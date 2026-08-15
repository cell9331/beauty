# Phase 68: CPU Algorithm Reference Oracles — Context

**Gathered:** 2026-08-14
**Status:** Ready for planning
**Mode:** Auto-generated from locked v1.16 direction (`--auto`, research/discuss skipped)

<domain>
## Phase Boundary

Freeze the current CPU/Core Image implementation as a deterministic, privacy-safe
reference through SwiftPM tests. The phase owns generated in-memory Swift RGBA8
fixtures, deterministic face/landmark/support stubs, feature-specific metrics,
local-retouch containment/composition oracles, failure-isolation/recovery tests,
and the boundary between mandatory generated tests and optional private/native-
Vision evidence. It does not add algorithms, public API, UI/Demo behavior, Metal,
GPU execution, simulator/device execution, tracked portrait media, or release
claims.
</domain>

<decisions>
## Decisions

Implementation Decisions

- **D-01:** Mandatory CPU tests use generated in-memory RGBA8/sRGB, alpha-boundary, geometry, protected/outside, and deterministic support fixtures with no tracked portrait media.
- **D-02:** The current CPU/Core Image implementation remains the sole reference; no public API, backend, shader, algorithm, UI, or device behavior is added.
- **D-03:** Oracles cover the exact current BeautyParameters fields and SDK effect taxonomy; future rows such as 去脂 remain absent.
- **D-04:** Geometry uses direction/displacement/locality/cap metrics and color uses luminance/chroma/channel/red/yellow-excess metrics plus exact neutral/protected bytes.
- **D-05:** Local-retouch tests preserve request-local support, original-pixel ownership, hard containment, alpha, collision-to-source, and smallest-unit failure isolation.
- **D-06:** Repeated, fresh, and recovery requests are finite, bounded, deterministic, and independent of prior request state.
- **D-07:** Rights-approved portrait/native-Vision fixtures remain private and explicit opt-ins that cannot lend success to mandatory generated tests.
- **D-08:** Durable evidence contains aggregate counts and owner contracts only; current quality/security/reliability/testing/project/state owners stay synchronized.

### D-01 — Generated mandatory fixtures

The mandatory suite must build small opaque RGBA8/sRGB and alpha-boundary
fixtures entirely in Swift memory. It must cover color ramps/checker patterns,
transparent/opaque input boundaries, geometric patterns, protected/outside
regions, and deterministic landmark/support stubs. No portrait image, mask,
generated PNG, or fixture locator may be tracked or required for a clean clone.

### D-02 — CPU-only reference boundary

The existing CPU/Core Image path is the reference implementation. Tests must call
current package-internal providers/pipelines and the public `BeautySDK` facade,
without adding a renderer backend selector, Metal/GPU implementation, new shader,
new algorithm, or production effect behavior.

### D-03 — Current taxonomy and public semantics

Oracles must use the exact current `BeautyParameters` fields and
`docs/SDK_EFFECT_TAXONOMY.md` meanings: skin/global color, face/eye/eyebrow/nose/
mouth geometry, lip color, teeth whitening, and sclera redness. `去脂`, semantic
mask features, and other future rows remain absent from the oracle inventory.

### D-04 — Feature-specific metrics

Assertions must prove the existing semantics instead of merely checking that
bytes changed. Geometry uses finite normalized control points, signed
displacement/direction, locality, radius/cap, and protected-region metrics.
Color uses luminance, chroma, channel/red-excess or yellow-excess direction,
alpha, extent, color-space, and bounded-delta metrics. Exact bytes are required
for neutral/no-op and protected/outside regions.

### D-05 — Request-local safety and composition

Generated local-retouch fixtures must exercise canonical opaque sRGB input,
request-local support, original-pixel composition, hard containment, alpha
preservation, collision-to-source behavior, and smallest-unit failure isolation.
Malformed/absent/occluded support must fail closed for only its dependent unit;
eligible siblings and face-agnostic color work continue.

### D-06 — Determinism and state isolation

Repeated identical CPU requests, fresh-engine requests, and valid→invalid→valid
sequences must produce finite, bounded, byte/metric-equivalent results without
prior-request pixels, support, masks, proposals, or diagnostics. Optional bounded
parallel requests may be used only to prove request isolation, not to claim a
new public concurrency contract.

### D-07 — Optional real/native-Vision evidence

Rights-approved portrait and native-Vision fixtures stay ignored/private and are
entered only through explicit environment opt-ins with manifest/path validation.
They cannot lend success to the mandatory generated suite; absent optional media
is a documented skip in ordinary SwiftPM runs and is executed by the existing
all-opt-ins no-skip gate when available.

### D-08 — Evidence and owner synchronization

The phase records aggregate counts, metric envelopes, test identities, and
privacy-safe gate results only. It does not persist raw pixels, landmarks, masks,
support points, paths, child transcripts, or generated media. Current quality,
reliability, security, testing-map, project, roadmap, state, and plans owners
must state the generated-only mandatory boundary and the CPU-only/non-claim
scope when the phase closes.
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautySDK/Tests/BeautyEffectsTests/FaceShapeWarpProviderTests.swift` owns the
  canonical `FaceGeometry` fixtures, including complete and malformed support.
- `BeautySDK/Tests/BeautySDKTests`/`BeautyCoreTests` already provide generated
  CIImage/CVPixelBuffer helpers, public-facade result rendering, and the
  `SDKTestingLocalRetouchFoundationHarness`/observation seams.
- Existing provider tests cover exact caps, finite/bounded control points,
  malformed support, protected pixels, collision summaries, and redacted
  diagnostics; Phase 68 should consolidate these into explicit reference-oracle
  metrics rather than invent a second production path.
- `BeautyEngine`, `BeautyColorEffectPipeline`, `BeautyGeometryEffectPipeline`,
  `BeautyLocalRetouchCompositionOwner`, and the current private real-fixture
  suites are the implementation/test seams to exercise.

### Established Patterns

- Keep test helpers and support target-local; do not widen public API or add a
  production dependency solely for assertions.
- Use table-driven rows for the current field inventory and explicit arrange /
  act / assert XCTest methods under the owning target.
- Keep all generated input/output in memory or unique temporary directories;
  remove temporary files in `defer`/teardown and never commit output baselines.
- Keep diagnostics and evidence aggregate-only; raw geometry and pixel data stay
  transient inside one test request.

### Integration Points

- The mandatory command remains `bash scripts/run-no-skip-swiftpm.sh`; Phase 68
  may add a bounded generated-oracle preflight before its one SwiftPM child.
- Phase 69 will consume the test counts and no-skip gate; do not change generic
  sendability or other closeout behavior in this phase.
</code_context>

<specifics>
## Required Observable Outcomes

- Neutral public-facade output has exact generated bytes, dimensions, named-sRGB
  metadata, and alpha behavior.
- Geometry controls retain signed direction and locality, and do not satisfy an
  oracle merely by producing global color bias or arbitrary changed pixels.
- Color controls satisfy their documented luminance/chroma/red/yellow direction
  and safety bounds on generated patterns.
- Teeth and sclera generated units preserve hard protected/outside regions,
  alpha, original-pixel ownership, and collision-to-source semantics.
- Per-eye/per-feature failures do not suppress eligible siblings; repeated and
  recovery requests do not reuse prior state.
- Mandatory clean-clone tests execute with zero skips; private/native-Vision
  tests remain explicitly opt-in and privacy-safe.
</specifics>

## Deferred Ideas

- Metal shaders, GPU runtime, public `.cpu`/`.gpu` selection, backend parity, or
  changes to retained `Warp.metal` (v1.17).
- New effects, `去脂`, semantic masks, hairline, double-chin, models, or network
  behavior.
- UI/Demo, Xcode, simulator/device, performance, commercial, packaging,
  shipping, launch, or release-readiness validation.
- Tracked portrait media, generated output baselines, raw diagnostic snapshots,
  or durable fixture locators.
- Generic `BeautyResult` sendability repair (Phase 69).
