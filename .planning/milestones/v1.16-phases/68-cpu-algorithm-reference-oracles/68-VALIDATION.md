# Phase 68 Validation Contract

**Status:** Planning contract
**Research:** Explicitly skipped by user; no external dependency or unfamiliar
integration is introduced.
**Boundary:** SwiftPM/XCTest CPU/Core Image oracles only; generated in-memory
Swift fixtures; no UI/Demo, Metal/GPU, simulator/device, tracked portrait media,
or release claim.

## Decision Traceability

| ID | Locked decision | Owning plan |
| --- | --- | --- |
| D-01 | Generated RGBA8/sRGB, alpha, geometry, protected-region, and support fixtures with no tracked media | 68-01 |
| D-02 | Current CPU/Core Image implementation only; no API/backend/algorithm/shader change | 68-01..04 |
| D-03 | Exact current public fields/taxonomy; future rows remain absent | 68-02 |
| D-04 | Feature-specific geometry and color metrics plus exact neutral/protected bytes | 68-01..03 |
| D-05 | Request-local local-retouch, containment, original pixels, collision-to-source, and unit isolation | 68-03 |
| D-06 | Repeated/fresh/recovery requests are finite, bounded, deterministic, and state-independent | 68-03 |
| D-07 | Private/native-Vision fixtures are explicitly opt-in and cannot satisfy generated mandatory evidence | 68-04 |
| D-08 | Aggregate-only evidence and synchronized current owners/maps | 68-04 |

## Nyquist Matrix

| Requirement | Owning plan | Automated evidence | Required assertion |
| --- | --- | --- | --- |
| CPU-01 | 68-01 | `swift test --package-path BeautySDK --filter 'CPUReferenceFixture'` | In-memory named-sRGB RGBA8 fixtures cover opaque colors, alpha boundaries, required transparent rejection inputs, geometry patterns, protected/outside labels, and deterministic support stubs; no tracked media is opened. |
| CPU-02 | 68-03 | `swift test --package-path BeautySDK --filter 'CPUReferenceLocalRetouchOracleTests\|CPUReferenceDeterminismTests'` | Neutral bytes/extent/color metadata/alpha, containment, collision-to-source, original-pixel blending, and per-unit failure isolation are exact or explicitly bounded. |
| CPU-03 | 68-02 | `swift test --package-path BeautySDK --filter 'CPUReferenceGeometryOracleTests\|CPUReferenceColorOracleTests'` | Every current geometry/color family is judged by direction/displacement/locality or luminance/chroma/red/yellow-excess metrics with existing caps and safety envelopes. |
| CPU-04 | 68-03 | `swift test --package-path BeautySDK --filter 'CPUReferenceDeterminismTests'` | Same request is byte/metric deterministic across repeats and fresh engines; valid→invalid→valid recovery is clean; malformed face-dependent units do not suppress teeth/color siblings. |
| CPU-05 | 68-04 | `bash scripts/check-cpu-reference-oracles.sh` and `bash scripts/run-no-skip-swiftpm.sh` | Mandatory generated suite has no skips and succeeds without private media; existing rights/native-Vision tests remain environment-gated and all opt-ins execute only through the documented no-skip path. |

Focused commands diagnose ownership; only the final conjunction closes the phase:

```bash
swift test --package-path BeautySDK --filter 'BeautyEffectsTests.CPUReferenceFixtureTests|BeautyCoreTests.CPUReferenceFacadeFixtureTests'
swift test --package-path BeautySDK --filter 'BeautyEffectsTests.CPUReferenceGeometryOracleTests|BeautyEffectsTests.CPUReferenceColorOracleTests'
swift test --package-path BeautySDK --filter 'BeautyEffectsTests.CPUReferenceLocalRetouchOracleTests|BeautyCoreTests.CPUReferenceDeterminismTests'
bash scripts/check-cpu-reference-oracles.sh
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/check-swiftpm-consumer.sh
bash scripts/run-no-skip-swiftpm.sh
git diff --check
```

## Generated Fixture Matrix

| Fixture class | Required properties | Used by |
| --- | --- | --- |
| Opaque color ramp / checker | finite RGBA8, explicit sRGB, alpha 255, distinct luminance/chroma channels | color pipeline and facade no-op |
| Alpha boundary | alpha values 0/1/127/254/255 in memory; transparent local-retouch input must reject before provider/render | facade validation and local-retouch oracle |
| Geometry pattern | gradient/checker source where sampling displacement is observable without a color-wide bias | unified CPU warp/oracle metrics |
| Protected/outside regions | indexed hard-envelope/protected/union sets with sentinel colors | teeth, sclera, lip color, and geometry locality |
| Support stub | deterministic finite `FaceGeometry`, observed eye/lip/brow support, and malformed/no-face/reordered/occluded variants | provider, facade, recovery, and sibling isolation |
| Composition source | small canonical opaque carrier with unique source colors and colliding proposals | Q16 original-pixel and collision-to-source oracle |

All fixtures are created by Swift builders during a test and released after the
assertion. No fixture writes PNG/JPEG/HEIC, persists raw support, or records a
path/locator in test output.

## Feature Oracle Matrix

| Family | Metrics and safety claims |
| --- | --- |
| Skin/global color | exact neutral bytes; luminance direction for brightness/exposure/whitening/highlight/shadow; chroma/channel direction for saturation/temperature/tint/rosy; smoothing/spread and contrast bounds; alpha/extent preservation |
| Face/eye/eyebrow/nose/mouth geometry | finite normalized source/target; signed field direction; field-specific displacement and radius/cap; changed-pixel locality around control-point support; no outside/sentinel change; no global additive color bias |
| Lip color | bounded local red/chroma direction inside lip envelope; exact outside and alpha preservation; missing support abstains |
| Teeth whitening | fixed inner-aperture ownership; yellow-excess reduction and bounded luminance/texture; no outer-lip/lookalike/protected/alpha change; source pixels on collisions |
| Sclera redness | per-eye red-excess reduction; guarded eye/protected region preservation for iris/pupil/highlight/lash/caruncle/exterior; bounded luminance/channel/texture; malformed peer isolation |
| Resolver/cap/degradation | exact zero/no-op, finite cap metrics, direction retention, missing/reused/stale support semantics, and safe sibling continuation |

## Failure and Privacy Matrix

| Scenario | Expected result |
| --- | --- |
| Neutral or missing optional effect | output bytes, dimensions, named-sRGB metadata, and alpha exactly preserved where current contract requires it |
| Transparent local-retouch input | typed `.invalidInput` before canonical carrier/provider/composition/render work |
| Missing/malformed/occluded eye/lip support | only dependent unit abstains; unrelated face-agnostic color and eligible sibling units continue |
| Unexpected proposal overlap | source pixel is preserved and one collision aggregate is recorded; unique neighboring work remains |
| Repeated and valid→invalid→valid requests | same finite bytes/metrics and no retained support/pixel/diagnostic state |
| Optional private/native-Vision bundle absent | ordinary focused run records its documented opt-in skip; generated mandatory checks do not skip and no-skip executes all configured opt-ins when bundles are present |
| Privacy scan | no raw pixels, masks, landmarks, coordinates, local paths, fixture locators, or child transcripts in durable evidence or reports |

## Multi-Source Coverage Audit

| SOURCE | ID | Feature/Requirement | Plan | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| GOAL | — | Detect semantic/safety regressions in current CPU implementation without tracked portrait media or GPU | 68-01..04 | COVERED | Generated fixtures, family metrics, recovery/isolation, and optional gate form one CPU-only reference boundary. |
| REQ | CPU-01 | Generated RGBA fixtures and deterministic support stubs | 68-01 | COVERED | Target-local in-memory Swift builders and contract tests. |
| REQ | CPU-02 | Exact neutral/safety/composition/failure reference behavior | 68-03 | COVERED | Local-retouch and facade deterministic oracle tests consume 68-01 helpers. |
| REQ | CPU-03 | Explicit geometry/color feature-family metrics | 68-02 | COVERED | Table-driven current taxonomy rows and bounded semantic metrics. |
| REQ | CPU-04 | Repeatability, finite/bounded results, state independence, sibling isolation | 68-03 | COVERED | Fresh/repeated/recovery and malformed-peer tests. |
| REQ | CPU-05 | Optional private/native-Vision separation and zero-skip generated clean clone | 68-04 | COVERED | Boundary preflight plus existing environment-gated opt-ins and final no-skip gate. |
| RESEARCH | — | No research artifact | 68-01..04 | EXCLUDED | User explicitly selected research skip; plans use existing repository contracts only. |
| CONTEXT | D-01 | Generated mandatory fixtures | 68-01 | COVERED | Fixture factories and contract tests. |
| CONTEXT | D-02 | CPU-only reference boundary | 68-01..04 | COVERED | All plans touch tests/scripts/docs only; no Metal/API/algorithm production change. |
| CONTEXT | D-03 | Exact taxonomy/public semantics | 68-02 | COVERED | Geometry/color table rows match current `BeautyParameters` and taxonomy. |
| CONTEXT | D-04 | Feature-specific metrics | 68-01..03 | COVERED | Metric helpers plus family/local-retouch oracles. |
| CONTEXT | D-05 | Local-retouch safety/composition | 68-03 | COVERED | Generated protected regions, collisions, and local failure tests. |
| CONTEXT | D-06 | Determinism/state isolation | 68-03 | COVERED | Repeated/fresh/recovery/failure-sibling tests. |
| CONTEXT | D-07 | Optional private/native-Vision evidence | 68-04 | COVERED | Static boundary gate and existing all-opt-in no-skip contract. |
| CONTEXT | D-08 | Aggregate-only owner synchronization | 68-04 | COVERED | Gate/report/docs/maps/ledger closeout task. |

## Reachability

- Each fixture builder is directly referenced by its owning target's XCTest
  suite; no helper exists without a test consumer.
- Geometry/color tests call package-internal resolver/provider/pipeline APIs using
  `@testable` imports and compare against the public taxonomy fields.
- Local-retouch tests call provider/composition seams and the public facade
  harness, so each safety oracle has a real production execution path.
- `scripts/check-cpu-reference-oracles.sh` is invoked before the one-child
  SwiftPM gate; private opt-ins remain owned by `scripts/run-no-skip-swiftpm.sh`.
- Phase 69 consumes only the aggregate counts and owner updates; no Phase 68
  test depends on the future sendability change.

