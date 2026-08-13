# Codebase Concerns

**Analysis Date:** 2026-08-13

## Tech Debt

**Unsound generic `Sendable` promise (TD-013):**
- Issue: `BeautyResult<Output>` declares unconditional `@unchecked Sendable`, so callers may put an arbitrary non-`Sendable` reference in `Output` and move the result across concurrency domains.
- Files: `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift`, `PLANS.md`, `RELIABILITY.md`.
- Impact: The public API advertises thread safety that the compiler cannot verify; a caller can create a data race while believing the type is safe.
- Fix approach: Make conformance conditional on `Output: Sendable`, introduce a sendable media carrier, or perform a versioned API migration. Add compile-time Swift 6 concurrency fixtures for both accepted and rejected payloads.

**Large, multi-responsibility implementation units:**
- Issue: Several production files concentrate validation, mapping, test seams, and feature orchestration: `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift` is about 1,650 lines, `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` about 1,093, `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` about 1,004, `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyFullScleraRednessProvider.swift` about 918, and `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` about 913.
- Files: `BeautySDK/Sources/BeautySDK/BeautyEngineTestingSupport.swift`, `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`, `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyFullScleraRednessProvider.swift`, `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`.
- Impact: Local changes can cross feature boundaries, reviews require broad context, and merge conflicts become more likely as new geometry or local-retouch families are added.
- Fix approach: Split by owned feature/support family while preserving package visibility and the current one-detection/one-mapping request flow. Keep shared validation in narrowly named helpers and retain existing cross-family regression suites during extraction.

**Historical and current documentation coexist:**
- Issue: Root contracts are current authority, while `docs/`, `.planning/milestones/`, and completed lifecycle rows intentionally retain older inventories and superseded conclusions.
- Files: `AGENTS.md`, `PLANS.md`, `docs/README.md`, `.planning/milestones/`, `.planning/codebase/`.
- Impact: Search results can surface historical field counts, renderer counts, feature states, or failed/pending evidence as if current.
- Fix approach: Follow the authority order in `AGENTS.md`; label historical evidence explicitly and keep current maps synchronized with live source and tests. The active `P-2026-08-13-document-state-drift-repair` plan owns the current refresh.

## Known Bugs

**No confirmed current runtime defect is recorded:**
- Symptoms: Current `PLANS.md` has no active production bug plan; the latest sclera amplification, capacity-preflight, reviewed-area, and contract-drift findings are completed remediations rather than open failures.
- Files: `PLANS.md`, `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyFullScleraRednessProvider.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`.
- Trigger: Not applicable to the mapped source state.
- Workaround: Not applicable. Treat old `H-*`, archived phase failures, and superseded phase conclusions in `PLANS.md` as historical evidence, not live bugs.

## Security Considerations

**Biometric-adjacent data depends on strict request-local ownership:**
- Risk: Images, face/eye/lip/eyebrow geometry, pupil locations, teeth regions, and vein patterns could leak through public types, logs, metrics, test artifacts, or retained request state.
- Files: `SECURITY.md`, `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`, `BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift`, `BeautySDK/Sources/BeautyCore/Models/BeautyDetectionSummary.swift`, `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyValidationWarning.swift`.
- Current mitigation: Raw supports are package-only, non-Codable, request-scoped; public diagnostics expose fixed categories and aggregate counts/timing. The SDK has no default network, cloud, analytics, tracking, or persistence path.
- Recommendations: Preserve fail-closed per-region validation and redacted diagnostics. Run the privacy/public-surface scanners whenever support carriers, warnings, metrics, descriptions, persistence, or networking change.

**Privacy manifest is intentionally absent for current behavior:**
- Risk: Distribution changes, required-reason API use, data collection, third-party SDKs, analytics, networking, or packaged example executables can invalidate the prior no-manifest conclusion.
- Files: `SECURITY.md`, `PLANS.md`, `BeautySDK/Package.swift`, `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`.
- Current mitigation: Current behavior is local-only and the Phase 25 audit found no manifest-triggering behavior in its scoped sources; TD-005 is closed for current evidence only.
- Recommendations: Reopen the manifest review on any behavior or packaging change. Add and validate `PrivacyInfo.xcprivacy` only from a fresh API/data-use inventory.

**Future external resources need an integrity boundary:**
- Risk: Downloaded LUTs, makeup assets, models, stickers, or preset packages could introduce traversal, substitution, oversized-resource, licensing, or code/data provenance failures.
- Files: `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift`, `BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift`, `BeautySDK/Sources/BeautyResources/Resources/manifest.json`, `SECURITY.md`.
- Current mitigation: Only bundled resources are supported; identifiers and manifest data are validated, and no runtime download path exists.
- Recommendations: Before adding external packages, define size ceilings, trusted origins, schema/version checks, cryptographic integrity, atomic installation, rollback, cache ownership, and licensing evidence.

**Generated and licensed image evidence must remain untracked:**
- Risk: Portrait fixtures or generated review images can contain sensitive pixels or metadata and may be accidentally committed.
- Files: `example-images/FIXTURE_AUTHORIZATION.md`, `example-images/README.md`, `example-images/generate_gallery.py`, `.gitignore`.
- Current mitigation: Active rights-approved portraits and generated output/gallery/review artifacts are local and ignored; committed evidence records redacted counts rather than image bytes or paths.
- Recommendations: Keep fixture preflight, metadata sanitation, authorization checks, `git check-ignore`, and tracked/staged scans mandatory for real-fixture work.

## Performance Bottlenecks

**Release-like realtime budgets are not established:**
- Problem: Contracts target stable 720p/1080p preview and bounded per-frame rendering, but there is no physical-device 600-second run, optimized GPU profile, or device matrix supporting those claims.
- Files: `RELIABILITY.md`, `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`, `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`.
- Cause: Existing evidence is simulator, deterministic, or short-duration; the public pixel-buffer route intentionally omits realtime landmark detection and geometry providers.
- Improvement path: Profile release builds on supported physical devices at explicit resolutions, record frame latency/drop rate/memory/thermal behavior, and verify degradation modes under pressure before release-like claims.

**Still-image local retouch amplifies decoded images into multiple buffers:**
- Problem: Canonical RGBA storage, request-local masks, proposal rasters, and rendered output can coexist for large images.
- Files: `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`, `BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`, `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyFullScleraRednessProvider.swift`.
- Cause: Safety requires immutable original-pixel composition and independent mask ownership. Public limits bound input to 32 MiB encoded / 50,000,000 decoded pixels, while full-sclera capacity preflight protects proposal allocation.
- Improvement path: Retain checked arithmetic and pre-allocation capacity checks; add peak-RSS and latency tests at boundary dimensions before increasing ceilings or enabling more local-retouch owners.

## Fragile Areas

**Local-retouch anatomy and composition contracts:**
- Files: `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyTeethWhiteningProvider.swift`, `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyFullScleraRednessProvider.swift`, `BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyFullScleraRednessTransform.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`.
- Why fragile: Small changes to admission thresholds, morphology, blur/reclip order, mask identity, or overlap rules can expand edits into lips, iris, pupil, highlights, lashes, skin, caruncle, or aperture exterior.
- Safe modification: Keep geometry and color qualification independent, blur then hard-reclip, derive color from immutable original pixels, preflight allocation before raster creation, and fail closed on owner/collision ambiguity.
- Test coverage: Strong synthetic/provider/integration/adversarial coverage exists, but private real-fixture suites are opt-in and do not establish population or commercial naturalness.

**Vision observation mapping and per-region degradation:**
- Files: `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift`, `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`.
- Why fragile: Orientation, mirroring, semantic left/right, malformed sibling support, and request reuse interact across detection, mapping, provider eligibility, and redacted summaries.
- Safe modification: Normalize once, map each accepted support once, preserve anatomical side semantics, reject malformed regions locally, and never substitute synthetic proxy geometry for observed support.
- Test coverage: Extensive mapping and degradation tests exist; native Apple Vision integration cases may skip unless explicitly opted in on a pinned host.

**Concurrency wrappers and shared engines:**
- Files: `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift`, `BeautySDK/Sources/BeautySDK/BeautyStillImageRequestContext.swift`, `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`, `BeautyDemo/BeautyDemo/Editor/ImageEditorPipeline.swift`, `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`.
- Why fragile: Several types use narrowly asserted `@unchecked Sendable`; the still-image foundation documents independent request values but does not claim same-engine parallelism or cooperative cancellation.
- Safe modification: Treat engine/request ownership as explicit, keep mutable pixel/mask state request-local, audit every unchecked conformance, and add race/cancellation tests before promising concurrent use.
- Test coverage: Demo pipelines test stale-result suppression and concurrent callbacks; compile-time generic sendability and production same-engine concurrent processing remain gaps.

**Xcode project and simulator selection:**
- Files: `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`, `AGENTS.md`.
- Why fragile: The project uses file-system-synchronized groups and generated Info.plist settings; an implicit destination may select incompatible “My Mac”.
- Safe modification: Make focused project edits, inspect schemes with `xcodebuild -list`, and build/test against an explicit available iOS Simulator destination.
- Test coverage: Simulator unit tests exist; project-format portability and physical-device execution are not continuously verified.

## Scaling Limits

**Single-face processing contract:**
- Current capacity: One selected face is processed according to `FaceSelectionPolicy`; raw supports are carried for that selected request only.
- Limit: Multi-face simultaneous retouch, identity-stable tracking, and cross-frame face association are not current contracts.
- Scaling path: Add an explicit multi-face ownership/composition design, bounded per-face resources, deterministic overlap policy, and privacy-safe aggregate diagnostics before widening scope.
- Files: `BeautySDK/Sources/BeautyDetection/FaceSelectionPolicy.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`, `DESIGN.md`.

**Realtime route is color-only for geometry purposes:**
- Current capacity: Pixel-buffer processing supports validated BGRA input and face-agnostic/color work.
- Limit: Realtime detection cadence, landmark smoothing, geometry warp, and local teeth/sclera retouch are intentionally absent.
- Scaling path: Define frame ownership, backpressure, cancellation, stale-detection policy, temporal smoothing, device budgets, and protected-region safety before routing geometry into realtime.
- Files: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`, `ARCHITECTURE.md`.

**Input ceilings are fixed compatibility boundaries:**
- Current capacity: Public processing enforces 32 MiB encoded input and 50,000,000 decoded pixels.
- Limit: `PhotosPicker` may materialize `Data` before the Demo can reject it, and larger decoded images are intentionally refused.
- Scaling path: Revisit only with a transfer/streaming API that can reject before materialization and with new checked-allocation/performance evidence.
- Files: `BeautySDK/Sources/BeautyCore/Models/BeautyConfiguration.swift`, `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`, `BeautyDemo/BeautyDemo/Editor/ImageInputModels.swift`, `PLANS.md`.

## Dependencies at Risk

**Apple Vision behavior and host availability:**
- Risk: Landmark availability and observation behavior vary by OS, image, and host; native integration tests can be unavailable or explicitly opt-in.
- Impact: Deterministic fixtures prove mapping mechanics but cannot establish real-world detection quality, low-light/pose coverage, or device parity.
- Migration plan: Keep Vision behind `BeautyDetection`, fail closed per region, retain synthetic deterministic tests, and run the opt-in native suites plus rights-approved positive/negative fixtures on pinned Apple hosts before stronger claims.
- Files: `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift`, `scripts/run-no-skip-swiftpm.sh`.

**Research-only Core ML candidate has unresolved provenance:**
- Risk: The EasyPortrait-derived upper-eyelid path lacks independently approved and pinned data, checkpoint, conversion, and redistribution licenses.
- Impact: It cannot be shipped, bundled, downloaded, or used as product evidence.
- Migration plan: Keep it outside production targets. Require independent license/provenance approval, reproducible conversion, model integrity, local inference/privacy review, and real positive/negative fixture evidence before reconsideration.
- Files: `.codex/skills/spike-findings-beauty/SKILL.md`, `.codex/skills/spike-findings-beauty/references/upper-eyelid-fullness.md`, `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md`.

## Missing Critical Features

**Upper-eyelid fullness reduction (`去脂`):**
- Problem: The tested warp is rejected and there is no approved production method with licensed real positive/negative evidence.
- Blocks: The `眼睛` branch remains `partial`; the feature must not alias eye height, eyelid lift, brow movement, eye-bag removal, dark-circle removal, or global smoothing.
- Files: `PRODUCT_SENSE.md`, `DESIGN.md`, `.codex/skills/spike-findings-beauty/references/upper-eyelid-fullness.md`.

**Demo exposure for local teeth/sclera retouch:**
- Problem: SDK-core `白牙` and `祛红血丝` are implemented, but all three local-retouch Demo taxonomy rows remain disabled and nil-mapped.
- Blocks: End-user Demo activation and interaction evidence for those effects; this is an intentional product boundary, not an SDK defect.
- Files: `BeautyDemo/BeautyDemo/Editor/MeituEditorToolModels.swift`, `BeautyDemo/BeautyDemo/Panel/BeautyControlDescriptor.swift`, `FRONTEND.md`, `PLANS.md`.

**Release and distribution readiness:**
- Problem: The repository explicitly does not claim physical-device parity, population coverage, commercial naturalness, optimized performance, packaging, shipping, launch, or release readiness.
- Blocks: Any production-distribution claim despite the archived internal v1.15 milestone.
- Files: `PLANS.md`, `PRODUCT_SENSE.md`, `RELIABILITY.md`, `SECURITY.md`.

## Test Coverage Gaps

**Physical-device and long-run camera behavior:**
- What's not tested: Real front-camera mirror/crop parity, low-light/side-face Vision behavior, thermal degradation, 600-second preview stability, and hardware memory/frame-drop behavior.
- Files: `BeautyDemo/BeautyDemo/Camera/CameraSessionController.swift`, `BeautyDemo/BeautyDemo/Camera/CameraBeautyPipeline.swift`, `RELIABILITY.md`, `PLANS.md`.
- Risk: Simulator-green behavior can still fail on camera hardware or under sustained thermal/memory pressure.
- Priority: High before release-like or performance claims.

**Current UI screenshot and accessibility coverage:**
- What's not tested: A current screenshot-diff/UI-automation pass, multi-device layout, Dynamic Type overlap, clipping, and full manual visual review.
- Files: `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`, `BeautyDemo/BeautyDemo/Home/MeituHomeView.swift`, `BeautyDemo/BeautyDemo/Panel/BeautyPanelView.swift`, `FRONTEND.md`, `PLANS.md`.
- Risk: Model/view-state tests can pass while labels, chips, panels, or controls render incorrectly.
- Priority: Medium; high before a release-like UI claim.

**Opt-in real-fixture and native Vision suites:**
- What's not tested by default: Rights-approved teeth/sclera positive/negative image gates and several native Vision integration paths may call `XCTSkip` unless the documented environment and opt-ins are present.
- Files: `BeautySDK/Tests/BeautyCoreTests/BeautyTeethWhiteningRealFixtureTests.swift`, `BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift`, `BeautySDK/Tests/BeautyDetectionTests/VisionFaceDetectorTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyFaceGeometryAdapterTests.swift`, `scripts/run-no-skip-swiftpm.sh`.
- Risk: The ordinary suite can be green without exercising host-dependent or private-media evidence.
- Priority: High for local-retouch changes; run `scripts/run-no-skip-swiftpm.sh` on the pinned Apple Vision host when claiming complete current evidence.

**Same-engine concurrency and cancellation:**
- What's not tested: A documented public guarantee for concurrent calls on one engine, cooperative cancellation during Vision/canonicalization/render work, and generic `BeautyResult` compile-time sendability.
- Files: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift`, `RELIABILITY.md`, `PLANS.md`.
- Risk: Callers may infer stronger concurrency semantics than the implementation and unchecked conformances support.
- Priority: High for any public concurrency guarantee; otherwise preserve the current nonclaim.

---

*Concerns audit: 2026-08-13*
