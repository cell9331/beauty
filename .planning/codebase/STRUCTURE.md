# Codebase Structure

**Analysis Date:** 2026-08-14
**Boundary:** SDK-only SwiftPM repository

## Directory Layout

```text
beauty/
├── BeautySDK/
│   ├── Package.swift
│   ├── Sources/
│   │   ├── BeautyCore/
│   │   ├── BeautyDetection/
│   │   ├── BeautyEffects/
│   │   ├── BeautyRender/
│   │   ├── BeautyResources/
│   │   ├── BeautySDK/
│   │   └── BeautyExampleRenderer/
│   └── Tests/
│       ├── BeautyCoreTests/
│       ├── BeautyDetectionTests/
│       ├── BeautyEffectsTests/
│       ├── BeautyRenderTests/
│       ├── BeautyResourcesTests/
│       └── BeautySDKTests/
├── scripts/
├── archives/legacy-ui/
├── docs/
├── example-images/
├── IntegrationTests/BeautySDKConsumer/
└── .planning/
```

The active tree contains 66 Swift source files and 61 SwiftPM test files.
Production/test Swift lines are 14,952/29,995, excluding `.build`. The package
declares one public library, one SDK-owned executable, six internal/library
targets, and six test targets.

## Ownership

- `BeautyCore`: stable public/shared models, errors, configuration, request
  carriers, and privacy-safe diagnostics.
- `BeautyDetection`: Vision detection, coordinate mapping, face selection, and
  request-local package-only support.
- `BeautyEffects`: effect resolution, geometry/color pipelines, local-retouch
  providers/transforms, and original-pixel composition.
- `BeautyRender`: pass/pixel-buffer foundations and the single retained,
  byte-pinned placeholder shader resource. Its presence is not a GPU claim.
- `BeautyResources`: bundled manifest and preset validation.
- `BeautySDK`: sole host-facing facade and request orchestration.
- `BeautyExampleRenderer`: executable consumer that imports the public product,
  preserves the exact 74-case catalog, validates persisted PNGs, and writes a
  versioned aggregate report plus disposable ignored output.
- `IntegrationTests/BeautySDKConsumer`: separate local-path SwiftPM executable
  fixture importing only the public `BeautySDK` product; it is not an SDK target.
- `BeautySDK/Tests`: all active automated tests.
- `BeautySDK/Tests/BeautyCoreTests/BeautyExampleRendererProcessTests.swift`:
  compiled Foundation `Process` matrix with temporary fixtures and bounded
  stream capture.
- `BeautySDK/Tests/BeautySDKTests/BeautyResultConcurrencyTests.swift`:
  public conditional-sendability compile/runtime coverage with complete result
  field preservation across an async task hop.
- `BeautySDK/Tests/BeautyCoreTests/CPUReferenceDeterminismTests.swift` and the
  generated `CPUReference*OracleTests.swift` suites: current CPU/Core Image
  reference semantics, safety, determinism, and failure-isolation coverage.
- `scripts`: archive integrity, SDK boundary, consumer, and no-skip SwiftPM gates.
- `scripts/check-cpu-reference-oracles.sh`: generated-only CPU reference
  preflight that stays separate from optional private/native-Vision fixtures.
- `scripts/check-sdk-only-boundary.sh`: active-tree scanner and mutation-tested
  rejection of unconditional generic `BeautyResult` sendability.
- `archives/legacy-ui`: verified historical ZIPs, manifests, digest records,
  and restoration contract; never an active build input.

## Entry Points and Configuration

- `BeautySDK/Package.swift`: only active build graph.
- `BeautySDK/Sources/BeautySDK/BeautyEngine.swift`: public processing facade.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`: command-line consumer.
- `BeautySDK/Sources/BeautyExampleRenderer/RendererCLIContract.swift` and
  `RendererExecution.swift`: strict CPU-only parser, typed diagnostics,
  versioned report, matrix execution, and output validation.
- `scripts/check-swiftpm-consumer.sh`: clean external public-product consumer
  preflight.
- `scripts/run-no-skip-swiftpm.sh`: mandatory complete regression gate.
- `archives/legacy-ui/README.md`: safe historical access and recovery.
- `docs/SDK_EFFECT_TAXONOMY.md`: current effect/control taxonomy.

## Where New Code Goes

- Stable public values: `BeautySDK/Sources/BeautyCore/Models/`.
- Public orchestration: `BeautySDK/Sources/BeautySDK/`.
- Detection/support: `BeautySDK/Sources/BeautyDetection/`.
- Effect planning/providers/pipelines: `BeautySDK/Sources/BeautyEffects/`.
- Bundled resources: `BeautySDK/Sources/BeautyResources/Resources/`.
- Low-level render foundations: `BeautySDK/Sources/BeautyRender/` only under an
  explicitly authorized render phase.
- Tests: owning `BeautySDK/Tests/<Target>Tests/` plus facade coverage when public
  behavior changes.
- Repository gates: `scripts/`.

Do not add application/UI roots to this repository. Historical recovery belongs
in a new temporary directory and must never be used as an active source owner.

## Special Directories

- `.planning/`: active GSD state plus immutable archived milestone evidence.
- `.codex/skills/spike-findings-beauty/`: local-retouch/privacy/fixture guidance.
- `example-images/`: approved committed fixtures plus ignored private/generated
  evidence under their existing authorization contracts.
- `BeautySDK/.build/` and `BeautySDK/.swiftpm/`: generated local state; never edit
  or commit as source.

---
*Structure analysis: 2026-08-14 after Phase 69 aggregate SDK-only closeout*
