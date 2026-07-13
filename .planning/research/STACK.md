# Stack Research

**Domain:** Public API expansion for the two remaining nose-geometry tools in a local SwiftPM iOS beauty SDK
**Milestone:** v1.9 Nose Remaining Tools and Branch Closeout
**Researched:** 2026-07-13
**Confidence:** HIGH for package/API compatibility and integration points; MEDIUM for the exact visual algorithm, which must be locked by phase acceptance evidence.

## Recommendation

Keep the current SwiftPM package, target graph, Apple-framework stack, unified geometry pass, and facade-only renderer. Add exactly two product-neutral `Float` fields to `BeautyParameters`:

| Reference tool | Public field | Public range | Default | Directional meaning |
| --- | --- | --- | --- | --- |
| `山根` | `noseRootHeight` | `0...1` | `0` | Positive-only enhancement of the upper nose root between the eyes. It is independent of `noseBridge`, whose current evidence and provider behavior belong to `鼻梁`. |
| `提升` | `noseTipLift` | `-1...1` | `0` | Signed vertical adjustment of the lower nose-tip region: positive lifts upward and negative lowers. It is independent of signed `noseTipSize`, which changes tip size rather than vertical position. |

These names follow the repository's product-neutral camel-case API style and the historical public API vocabulary (`noseBridgeHeight`, `noseTipLift`) while avoiding two ambiguities: `noseBridge` cannot be reused for `山根`, and a broad `noseLift` could be mistaken for whole-nose translation. `noseRootHeight` is preferred over `noseBridgeHeight` because an existing `noseBridge` field already owns `鼻梁` and currently narrows upper bridge points rather than representing an independent root-height control.

Both additions must be no-op by default and decoded as zero when absent. `noseRootHeight` uses the existing positive-only finite clamp; `noseTipLift` uses the existing signed finite clamp. That makes previously saved parameter and preset JSON decode without migration.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
| --- | --- | --- | --- |
| Swift / SwiftPM | Swift tools 6.0 | Add the two public values and route them through existing targets | `BeautySDK/Package.swift` already has the correct public facade, core model, effects, renderer, and tests. No manifest or target change is needed. |
| XCTest | Toolchain supplied | Lock API defaults, normalization, Codable compatibility, resolver behavior, provider direction, degradation, and facade evidence | The existing nose suites already own every relevant seam; extending them preserves the established contract. |
| Core Image plus the existing unified geometry pipeline | Deployment-target supplied; iOS 17+, macOS 14+ | Render the new local warps | Existing nose control points already flow through `NoseWarpProvider` and `BeautyGeometryEffectPipeline` into the common geometry render path. A new render technology or pass is unnecessary. |

### Supporting Tools

| Tool | Version | Purpose | When to Use |
| --- | --- | --- | --- |
| `BeautyExampleRenderer` | Existing SwiftPM executable | Public-facade output cases for `noseRootHeight` and `noseTipLift` | Each case should set exactly one new public field and keep the executable importing only `BeautySDK`. |
| Existing Python nose-output helper pattern | Python 3 standard library | Batch PNG, dimensions, portrait-region difference, no-face, and immutable-count evidence | Extend or successor-copy the completed v1.7 helper; no third-party imaging dependency is justified. |
| `example-images/generate_gallery.py` | Existing repository script | Ignored local review gallery | Add routes for the two cases while keeping output and gallery PNGs untracked. |
| `rg`, Git, and shell checks | Existing developer tools | Inventory, boundary, privacy, dependency, and tracked-artifact checks | Use at closeout to prove the intended 33-field inventory and absence of raw geometry, forbidden imports, new dependencies, or tracked generated output. |

## Public API and Codable Contract

The changes belong in `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` and should mirror every existing numeric field:

```swift
public var noseRootHeight: Float
public var noseTipLift: Float
```

Add both cases to `CodingKeys`; add defaulted initializer arguments; assign `noseRootHeight` with `Self.clampUnit` and `noseTipLift` with `Self.clampSigned`; decode both through `decodeFloatIfPresent`; and forward both through `normalized()`.

Required compatibility behavior:

| Input/API condition | Required result |
| --- | --- |
| `BeautyParameters()` | Both fields are exactly `0`; the full public field inventory becomes 33 fields (32 numeric fields plus `filterId`). |
| Old JSON omits both keys | Decoding succeeds and produces `0` for both because the custom decoder uses `decodeIfPresent(...) ?? 0`. |
| New JSON contains `noseRootHeight` | Finite values clamp to `0...1`; negative values become `0`; values above `1` become `1`; non-finite programmatic values become `0`. JSON itself cannot carry standard non-finite numbers. |
| New JSON contains `noseTipLift` | Finite values clamp to `-1...1`; values outside the range clamp to the nearest endpoint; non-finite programmatic values become `0`. |
| New JSON is read by an older synthesized/custom keyed decoder | Unknown keys are ignored by Swift's keyed decoding, so the additive keys do not invalidate the old payload shape. |
| Encoding with the current synthesized `Encodable` implementation | Both keys are emitted as numeric values, including zero, consistent with all current non-optional fields. Do not introduce omission-only encoding for these two fields. |
| Existing bundled preset JSON omits both keys | Preset decoding remains valid and yields neutral values; editing every preset is not required for compatibility. |

Keep the fields non-optional. Optional values would introduce a second neutral state (`nil` versus `0`), complicate equality and presets, and diverge from the stable normalized-parameter model.

## Integration Points

| Layer | Exact addition | Keep unchanged |
| --- | --- | --- |
| `BeautyCore` | Add the two properties, coding keys, defaulted initializer inputs, clamps, decoder entries, and normalized forwarding. Extend default/normalization/round-trip/old-payload tests. | `Codable`, `Equatable`, `Sendable`; normalized public range; custom missing-key behavior. |
| `BeautyEffects/Planning` | Add fields to `BeautyEffectiveStrengths`; define internal natural caps; include them in geometry gating, cap counts, nose activation, zeroing, reused `0.5` scaling, stale/missing degradation, and combined-effect weakening/conflict calculations. | Single `.nose` domain, current redacted warning/metric vocabulary, safe-domain continuation. |
| `NoseWarpProvider` | Add distinct root-region and tip-lift control-point generation. Root operates only on the upper root subset; tip lift operates only on the lower tip subset and preserves opposite vertical directions. | Existing `noseSlim`, `noseWingSlim`, signed `noseTipSize`, and `noseBridge` semantics and evidence. |
| Geometry render | The existing provider output is automatically combined with other facial control points. | `BeautyGeometryEffectPipeline`, unified warp pass, output dimensions, watermark/evidence conventions. |
| Public facade | `requiresFaceGeometry` must recognize either nonzero field; normal selected-face routing then applies. | No public landmark/control-point API and no new engine method. |
| Renderer/tests | Add one positive single-field root case plus positive/negative single-field lift cases, exact-inventory guards, facade output and signed-pair checks, provider/resolver/degradation/conflict tests, and old-JSON decode tests. | Existing seven-fixture matrix, ignored output/gallery policy, facade-only import boundary. |

The internal cap constants should remain separate from the public normalized ranges. Their exact values are a safety/visual acceptance decision, not a reason to change the public type or add a new configuration object. Tests must lock whichever conservative values the implementation phase adopts.

## Installation

No dependency installation or `Package.swift` edit is recommended.

```bash
swift test --package-path BeautySDK
swift build --package-path BeautySDK --product BeautyExampleRenderer
swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/output
python3 <v1.9-nose-output-helper>.py --input example-images/input --output example-images/output
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
| --- | --- | --- |
| `noseRootHeight` | `noseBridgeHeight` | Only if the product intentionally renames/deprecates the existing `noseBridge` contract in a separately planned API migration. Keeping both `noseBridge` and `noseBridgeHeight` would be easy to confuse. |
| `noseTipLift` | `noseLift` | Use only for a deliberately defined whole-nose vertical transform; that is not the narrow remaining `提升` behavior supported by the current lower-tip landmark seam. |
| Signed `noseTipLift` | Positive-only lift | Use positive-only only if product acceptance explicitly forbids lowering. The repository's historical advanced-nose contract already defines `noseTipLift` as signed, and a stable adjustment parameter can represent both vertical directions without conflating size. |
| Two independent stored fields | Alias/computed properties backed by `noseBridge` or `noseTipSize` | Only if the product accepts identical behavior and shared evidence. v1.9 explicitly requires independent semantics, so aliases are unsuitable. |
| Extend `NoseWarpProvider` | Add `NoseRootWarpProvider`, `NoseLiftWarpProvider`, or new targets | Split only if future nose algorithms require genuinely different dependencies or lifecycle. Two related control-point builders do not justify architectural expansion. |

## What NOT to Use

| Avoid | Why | Use Instead |
| --- | --- | --- |
| Reusing `noseBridge` for `山根` | Existing code moves upper bridge points toward the center, and v1.7 evidence is explicitly owned by `鼻梁`. Reuse would make two product tools indistinguishable and overclaim old evidence. | Independent `noseRootHeight` storage, behavior, and output evidence. |
| Reusing signed `noseTipSize` for `提升` | Size moves tip points toward/away from a center; lift is vertical direction. Shared storage cannot preserve both meanings. | Independent signed `noseTipLift`. |
| Public names such as `shanGen`, `tiSheng`, or vendor-prefixed labels | They expose reference-product vocabulary rather than a stable SDK concept. | `noseRootHeight` and `noseTipLift`. |
| Optional fields, schema wrappers, or a `BeautyParametersV2` type | The existing custom decoder already provides additive missing-key compatibility. Extra schema machinery creates unnecessary host migration work. | Add two defaulted non-optional fields to the existing value type. |
| New package target, renderer executable, geometry domain, render pass, or dependency | The current target graph and unified nose geometry seams cover the work. | Extend the existing core/effects/renderer/test files. |
| New public raw landmarks, bounding boxes, control points, or Vision types | Violates the facade/privacy boundary and is not needed for the algorithms. | Keep region selection and control points package-internal. |
| Demo UI, presets with nonzero new defaults, network/cloud processing, ML models, or tracked PNG baselines | All are outside the SDK-core v1.9 scope and add behavior, privacy, or release claims not required for branch closeout. | Neutral preset fallback, local fixture evidence, ignored output/gallery artifacts. |
| A global Y translation for `noseTipLift` | It would move the whole nose and collapse `提升` into a position control such as historical `nosePositionY`. | Restrict signed lift/lower behavior to lower tip points with conservative radius/falloff. |

## Stack Patterns by Variant

**If old parameter or preset JSON omits the new keys:**
- Use the current custom keyed decoder and resolve both values to `0`.
- Do not add a migration step or schema wrapper.

**If only `noseRootHeight` is active:**
- Generate control points only from the upper root subset and preserve `noseBridge == 0`.
- Require output evidence distinct from the existing `noseBridge` case.

**If `noseTipLift` is positive or negative:**
- Use the same lower-tip subset and reverse only the vertical displacement direction.
- Preserve equal cap magnitude and signed direction through normalization, weakening, provider planning, and output evidence.

**If nose geometry is missing, stale, or reused:**
- Apply the existing whole-nose-domain degradation policy to all six nose fields: missing/stale fails closed and reused geometry scales by `0.5`.
- Continue independent safe color/filter domains and expose only redacted warnings and aggregate metrics.

## Version Compatibility

| Component | Compatible With | Notes |
| --- | --- | --- |
| Swift tools 6.0 package | iOS 17+, macOS 14+ | Preserve the current manifest and deployment targets. Renderer evidence can continue to run on macOS through the public facade. |
| Expanded 33-field `BeautyParameters` | Existing parameter and preset JSON | Missing keys decode to zero. Encoding remains additive and explicit. No schema-version bump exists or is needed in this value type. |
| Existing presets | New SDK | Omitted new fields are neutral. Do not assign nonzero defaults during this milestone. |
| Existing public facade and geometry pipeline | Both new fields | Geometry detection gating and nose-domain routing need only inventory extensions; method signatures and result metadata remain stable. |
| SwiftPM source consumers | Expanded public struct and initializer | Defaulted labeled arguments preserve normal source call sites when consumers rebuild. Adding stored properties changes binary layout/API symbols, so a prebuilt binary client must consume a rebuilt SDK; the repository currently ships source through SwiftPM rather than a library-evolution binary artifact. |

## Repository Sources

- `.planning/PROJECT.md` — v1.9 goal, active requirements, SDK-only scope, and explicit public-inventory expansion.
- `.planning/milestones/v1.7-REQUIREMENTS.md` — old four-parameter nose evidence boundary and the explicit unresolved `山根`/`提升` decisions.
- `DESIGN.md` — normalized parameter model, nose safety/degradation contract, and internal geometry/privacy rules.
- `ARCHITECTURE.md` — current SwiftPM target ownership, unified geometry pass, facade-only integration, and no raw-geometry boundary.
- `BeautySDK/Package.swift` — Swift tools 6.0, iOS 17/macOS 14 platforms, products, targets, and dependencies.
- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — authoritative public fields, unit/signed clamps, defaulted initializer, missing-key decoding, and normalized forwarding.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` and `BeautyEffectPlan.swift` — geometry gating, effective strengths, cap/degradation/combined-effect integration seams.
- `BeautySDK/Sources/BeautyEffects/Warp/NoseWarpProvider.swift` — current bridge/root-region and lower-tip control-point seams, and proof that existing bridge and tip-size semantics differ from the new tools.
- `BeautySDK/Tests/BeautyCoreTests/BeautyParametersTests.swift`, `BeautyRendererOutputRegressionTests.swift`, and current `BeautyEffectsTests` nose suites — exact compatibility, facade, cap, provider, degradation, and conflict test owners.
- `docs/01_product_feature_plan.md` and `docs/06_beauty_parameters_spec.md` — historical neutral nose vocabulary and the planned signed `noseTipLift` contract, used to disambiguate naming/direction; current source and v1.9 planning remain authoritative.

---
*Stack research for: v1.9 Nose Remaining Tools and Branch Closeout*
*Researched: 2026-07-13*
