# Codebase Structure

**Analysis Date:** 2026-08-13

## Directory Layout

```text
beauty/
├── AGENTS.md                         # Agent workflow and contract routing
├── PLANS.md                          # Active/completed work and technical-debt ledger
├── ARCHITECTURE.md                    # Authoritative package/domain boundaries
├── DESIGN.md                          # Models, states, and processing contracts
├── FRONTEND.md                        # Demo UI and concurrency contracts
├── SECURITY.md                        # Privacy and trust boundaries
├── RELIABILITY.md                     # Errors, recovery, performance, diagnostics
├── PRODUCT_SENSE.md                   # User journeys and acceptance criteria
├── QUALITY_SCORE.md                    # Quality inventory and verification gates
├── BeautySDK/
│   ├── Package.swift                    # SwiftPM products, targets, dependencies
│   ├── Sources/
│   │   ├── BeautyCore/                 # Shared models and diagnostics
│   │   ├── BeautyDetection/            # Vision and coordinate mapping
│   │   ├── BeautyEffects/              # Planning, warp, render, local retouch
│   │   ├── BeautyRender/               # Pass/pixel-buffer/Metal foundations
│   │   ├── BeautyResources/            # Manifest and bundled presets
│   │   ├── BeautySDK/                  # Public facade and request orchestration
│   │   └── BeautyExampleRenderer/       # Public-facade evidence executable
│   └── Tests/                           # One suite directory per package target
├── BeautyDemo/
│   ├── BeautyDemo.xcodeproj/            # App and test target configuration
│   ├── BeautyDemo/                      # SwiftUI app implementation
│   │   ├── App/                         # @main entry
│   │   ├── Home/                        # Landing models/views
│   │   ├── Editor/                      # Photo/editor shell and debug UI
│   │   ├── Camera/                      # Capture, preview, backpressure
│   │   ├── Panel/                       # Categories, controls, resource pickers
│   │   ├── State/                       # Parameter store and JSON coding
│   │   ├── Support/                     # Deterministic Demo fixtures
│   │   └── Assets.xcassets/             # App assets
│   └── BeautyDemoTests/                 # App-side unit/integration tests
├── scripts/                           # Verification helpers
├── docs/                              # Historical/background and feature blueprints
├── meituxiuxiu/                       # Offline HTML reference maps
└── .planning/                         # GSD plans, milestones, evidence, maps, spikes
```

## Directory Purposes

**`BeautySDK/Sources/BeautyCore/`:**
- Purpose: Own shared stable values at the bottom of the dependency graph.
- Contains: Public configuration/parameters/result/error/frame/preset models, package canonical raster, and privacy-safe diagnostic values.
- Key files: `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift`, `BeautySDK/Sources/BeautyCore/Models/BeautyCanonicalStillImage.swift`, `BeautySDK/Sources/BeautyCore/Diagnostics/BeautyValidationWarning.swift`.

**`BeautySDK/Sources/BeautyDetection/`:**
- Purpose: Isolate Vision, coordinate conversion, face selection, and package-only semantic observation types.
- Contains: Flat Swift source files rather than feature subdirectories.
- Key files: `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`, `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`, `BeautySDK/Sources/BeautyDetection/CoordinateMapper.swift`.

**`BeautySDK/Sources/BeautyEffects/`:**
- Purpose: Own all effect resolution and implementation behind the facade.
- Contains: `Planning/` for plan/admission/caps, `Warp/` for geometry providers, `Render/` for shared pipelines/composition, and `LocalRetouch/` for teeth/sclera providers/transforms.
- Key files: `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`, `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`.

**`BeautySDK/Sources/BeautyRender/`:**
- Purpose: Own low-level rendering foundations separately from effect policy.
- Contains: Pass protocol/graph, copy pass, pixel-buffer factory, and `Shaders/Warp.metal`.
- Key files: `BeautySDK/Sources/BeautyRender/RenderPass.swift`, `BeautySDK/Sources/BeautyRender/RenderGraph.swift`, `BeautySDK/Sources/BeautyRender/PixelBufferFactory.swift`.

**`BeautySDK/Sources/BeautyResources/`:**
- Purpose: Own bundled resource discovery and manifest parsing.
- Contains: Catalog/manifest types plus `Resources/manifest.json` and five preset JSON files under `Resources/Presets/`.
- Key files: `BeautySDK/Sources/BeautyResources/BeautyResourceCatalog.swift`, `BeautySDK/Sources/BeautyResources/Resources/manifest.json`.

**`BeautySDK/Sources/BeautySDK/`:**
- Purpose: Define the only host-facing package product and coordinate internal targets.
- Contains: `BeautyEngine`, geometry-routing extension, canonicalizer, request context, resource facade, module marker, and testing support.
- Key files: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`, `BeautySDK/Sources/BeautySDK/BeautyEngineGeometryDetection.swift`, `BeautySDK/Sources/BeautySDK/BeautyStillImageCanonicalizer.swift`.

**`BeautySDK/Tests/`:**
- Purpose: Verify each target boundary plus public-facade integration, real-fixture opt-ins, adversarial safety, and output regression.
- Contains: `BeautyCoreTests/`, `BeautyDetectionTests/`, `BeautyEffectsTests/`, `BeautyRenderTests/`, `BeautyResourcesTests/`, and `BeautySDKTests/`.
- Key files: `BeautySDK/Tests/BeautyCoreTests/BeautyEngineCombinedLocalRetouchCloseoutTests.swift`, `BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift`, `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift`.

**`BeautyDemo/BeautyDemo/`:**
- Purpose: Demonstrate host integration without reaching into SDK internals.
- Contains: Feature folders for navigation, editor/photo flow, camera flow, panels, app state, fixtures, and assets.
- Key files: `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`, `BeautyDemo/BeautyDemo/ContentView.swift`, `BeautyDemo/BeautyDemo/Editor/EditorShellView.swift`.

**`BeautyDemo/BeautyDemoTests/`:**
- Purpose: Test UI-independent Demo models, stores, permissions, pipelines, privacy, and SDK import boundaries.
- Contains: Flat `*Tests.swift` files aligned to production concepts.
- Key files: `BeautyDemo/BeautyDemoTests/BeautyDemoImportBoundaryTests.swift`, `BeautyDemo/BeautyDemoTests/CameraBeautyPipelineTests.swift`, `BeautyDemo/BeautyDemoTests/ImageEditorPipelineTests.swift`.

**`docs/`:**
- Purpose: Preserve historical long-form designs and current Meitu feature blueprints; root contract documents remain authoritative.
- Contains: Numbered historical docs, `docs/superpowers/`, and `docs/meitu-function-blueprint/`.
- Key files: `docs/README.md`, `docs/meitu-function-blueprint/FEATURE_MATRIX.md`, `docs/meitu-function-blueprint/shared/IMPLEMENTATION_PRINCIPLES.md`.

**`.planning/`:**
- Purpose: Store GSD lifecycle artifacts, evidence, archived milestones, spikes, research, and generated codebase maps.
- Contains: `.planning/codebase/`, `.planning/milestones/`, `.planning/evidence/`, `.planning/spikes/`, `.planning/research/`, and current phase/quick artifacts.
- Key files: `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`.

## Key File Locations

**Entry Points:**
- `BeautyDemo/BeautyDemo/App/BeautyDemoApp.swift`: iOS `@main` application entry.
- `BeautyDemo/BeautyDemo/ContentView.swift`: Home-to-editor route switch.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`: Public image and pixel-buffer processing facade.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`: SwiftPM executable entry for output evidence.

**Configuration:**
- `BeautySDK/Package.swift`: Swift tools version, supported platforms, products, targets, resources, and target dependencies.
- `BeautyDemo/BeautyDemo.xcodeproj/project.pbxproj`: Demo app/test targets, Swift Package reference, build settings, and capabilities.
- `BeautySDK/Sources/BeautyResources/Resources/manifest.json`: Bundled resource inventory.
- `BeautySDK/Sources/BeautyResources/Resources/Presets/*.json`: Built-in parameter snapshots.

**Core Logic:**
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift`: Parameter normalization, safety caps, geometry resolution, and plan creation.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyColorEffectPipeline.swift`: Pixel-buffer and still-image execution.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`: Single combined still-image geometry warp.
- `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`: Original-pixel proposal ownership/composition.
- `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift`: Still-image Vision detection and semantic mapping.

**Testing:**
- `BeautySDK/Tests/<TargetName>Tests/`: SwiftPM test suites coarsely grouped by owning target.
- `BeautyDemo/BeautyDemoTests/`: Xcode Demo tests.
- `scripts/run-no-skip-swiftpm.sh`: Strict SwiftPM run that rejects skipped tests.

**Contract and Planning Documentation:**
- `AGENTS.md`: Repository workflow entry and task routing.
- `PLANS.md`: Current execution ledger; read before edits.
- `ARCHITECTURE.md`: Package/domain dependency authority.
- `DESIGN.md`: Public models and processing invariants.
- `FRONTEND.md`: Demo state/concurrency/layout authority.
- `SECURITY.md`: Input/privacy/resource trust authority.
- `RELIABILITY.md`: Error/performance/recovery authority.
- `PRODUCT_SENSE.md`: Product acceptance authority.

## Naming Conventions

**Files:**
- Use PascalCase matching the primary Swift type: `BeautyEngine.swift`, `CameraBeautyPipeline.swift`, `BeautyEffectResolver.swift`.
- Name production test files `<Subject>Tests.swift`: `BeautySDK/Tests/BeautyDetectionTests/CoordinateMapperTests.swift`.
- Use a shared feature prefix for package-public/package-only SDK concepts: `BeautyCanonicalStillImage`, `BeautyLocalRetouchCompositionOwner` in `BeautySDK/Sources/`.
- Pair local-retouch implementation files by feature and role: `BeautyTeethWhiteningProvider.swift` plus `BeautyTeethWhiteningTransform.swift` in `BeautySDK/Sources/BeautyEffects/LocalRetouch/`.
- Use uppercase root and generated contract names: `ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`.
- Use numbered snake_case for historical docs: `docs/08_metal_render_pipeline_design.md`.

**Directories:**
- Use PascalCase for Swift targets and test targets: `BeautyEffects`, `BeautyEffectsTests` under `BeautySDK/`.
- Use responsibility nouns inside a target: `Planning`, `Warp`, `Render`, `LocalRetouch` under `BeautySDK/Sources/BeautyEffects/`.
- Use app feature nouns: `Camera`, `Editor`, `Home`, `Panel`, `State`, `Support` under `BeautyDemo/BeautyDemo/`.
- Use lowercase kebab-case for GSD phase/spike artifact directories under `.planning/`.

## Where to Add New Code

**New Public SDK Behavior:**
- Primary code: add stable shared types to `BeautySDK/Sources/BeautyCore/Models/`, orchestration to `BeautySDK/Sources/BeautySDK/`, and implementation behind an internal target boundary.
- Tests: use `BeautySDK/Tests/BeautySDKTests/` for facade contracts and the owning target test directory for implementation details.
- Contract updates: update `ARCHITECTURE.md` for boundaries, `DESIGN.md` for models/state, and `PRODUCT_SENSE.md` for new public acceptance behavior.

**New Face Geometry Feature:**
- Planning/caps: `BeautySDK/Sources/BeautyEffects/Planning/`.
- Provider/control points: `BeautySDK/Sources/BeautyEffects/Warp/` using `WarpControlPointProvider`.
- Rendering: feed the existing `BeautySDK/Sources/BeautyEffects/Render/BeautyGeometryEffectPipeline.swift`; do not add a second warp pipeline.
- Tests: `BeautySDK/Tests/BeautyEffectsTests/`, plus public integration in `BeautySDK/Tests/BeautyCoreTests/` when the facade changes.

**New Still-Image Local Color Retouch:**
- Admission: `BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift` and `BeautyEffectResolver.swift`.
- Provider/transform: `BeautySDK/Sources/BeautyEffects/LocalRetouch/<Feature>Provider.swift` and `<Feature>Transform.swift`.
- Composition: emit units for `BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift`; retain one request-local owner.
- Orchestration: `BeautySDK/Sources/BeautySDK/BeautyEngine.swift` and request-local support in `BeautyStillImageRequestContext.swift`.
- Tests: provider/adversarial suites in `BeautySDK/Tests/BeautyEffectsTests/`, facade integration and rights-gated real fixtures in `BeautySDK/Tests/BeautyCoreTests/`.

**New Detection Support:**
- Platform mapping: `BeautySDK/Sources/BeautyDetection/VisionFaceDetector.swift` and `CoordinateMapper.swift`.
- Package-only semantic carrier: `BeautySDK/Sources/BeautyDetection/BeautyFaceObservation.swift`.
- Effects adapter: `BeautySDK/Sources/BeautyEffects/Planning/BeautyFaceGeometryAdapter.swift` or the owning provider.
- Tests: `BeautySDK/Tests/BeautyDetectionTests/` and the affected `BeautyEffectsTests/` suite.

**New SDK Resource:**
- Asset/config: `BeautySDK/Sources/BeautyResources/Resources/`.
- Manifest/catalog parsing: `BeautySDK/Sources/BeautyResources/BeautyResourceManifest.swift` and `BeautyResourceCatalog.swift`.
- Facade exposure: `BeautySDK/Sources/BeautySDK/BeautySDKResources.swift`.
- Tests: `BeautySDK/Tests/BeautyResourcesTests/`.

**New Demo Screen or Interaction:**
- App launch/routing: `BeautyDemo/BeautyDemo/App/` or `BeautyDemo/BeautyDemo/ContentView.swift`.
- Feature UI: choose `BeautyDemo/BeautyDemo/Home/`, `Editor/`, `Camera/`, or `Panel/` by ownership.
- Shared app state: `BeautyDemo/BeautyDemo/State/`; deterministic fixtures: `BeautyDemo/BeautyDemo/Support/`.
- Tests: `BeautyDemo/BeautyDemoTests/`; keep SDK algorithm code out of the Demo.

**Utilities:**
- Shared cross-target SDK value helpers: `BeautySDK/Sources/BeautyCore/` only when genuinely dependency-neutral.
- Target-specific helpers: colocate with the owning target/feature directory under `BeautySDK/Sources/`.
- Repository verification helpers: `scripts/`.

## Special Directories

**`.planning/`:**
- Purpose: GSD-generated plans, archived milestones, codebase maps, evidence, and spikes.
- Generated: Mixed; workflow artifacts are generated, spike sources/evidence are curated.
- Committed: Yes for authoritative artifacts; ignored local media/evidence remains governed by repository rules.

**`.codex/skills/spike-findings-beauty/`:**
- Purpose: Project-local implementation blueprint for normalized still-image input, request-local masks, original-pixel composition, fail-closed ownership, and licensed evidence gates.
- Generated: No.
- Committed: Yes.

**`example-images/`:**
- Purpose: Committed input fixtures plus ignored renderer/local-review outputs and rights-gated evidence.
- Generated: Mixed.
- Committed: Only approved fixture/metadata subsets; do not assume every local file is tracked.

**`.worktrees/` and `.codex-backups/`:**
- Purpose: Local auxiliary worktrees and historical backups outside current source authority.
- Generated: Yes/local.
- Committed: No; do not map their contents as the live implementation.

**`BeautySDK/.build/`, `BeautySDK/.swiftpm/`, and Xcode user-data directories:**
- Purpose: Local build caches and IDE metadata.
- Generated: Yes.
- Committed: No for build/user state; never add new code here.

---

*Structure analysis: 2026-08-13*
