# Technology Stack

**Analysis Date:** 2026-08-14
**Boundary:** SDK-only SwiftPM repository

## Languages and Runtime

- Swift tools 6.0 for the library, command-line renderer, and XCTest suites.
- iOS 17+ library support and macOS 14+ renderer/test support are declared by
  `BeautySDK/Package.swift`.
- JSON for the bundled resource manifest and five preset resources.
- Python and shell for deterministic repository-owned gates.
- Markdown for current contracts and archived evidence.

## Package and Frameworks

Swift Package Manager is the sole active package/build system. The package has
no remote dependencies and therefore needs no lockfile.

Active Apple frameworks include Foundation, Core Image, Core Graphics, ImageIO,
Core Video/Core Media, Vision, AppKit for the macOS renderer, and CryptoKit in a
resource test. No application UI framework or capture/session framework is an
active repository dependency.

The current still-image geometry path is CPU/Core Image-backed. The retained
`BeautySDK/Sources/BeautyRender/Shaders/Warp.metal` bytes are pinned historical
foundation and do not establish a Metal runtime, GPU backend, public backend API,
or parity claim.

## Products and Targets

- Public library product: `BeautySDK`.
- SDK-owned executable product: `BeautyExampleRenderer`.
- Internal/library targets: `BeautyCore`, `BeautyDetection`, `BeautyRender`,
  `BeautyResources`, `BeautyEffects`, and `BeautySDK`.
- Test targets: `BeautyCoreTests`, `BeautyDetectionTests`, `BeautyRenderTests`,
  `BeautyResourcesTests`, `BeautyEffectsTests`, and `BeautySDKTests`.

## Build and Validation

```bash
swift build --package-path BeautySDK
swift test --package-path BeautySDK
swift run --package-path BeautySDK BeautyExampleRenderer --help
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
bash scripts/run-no-skip-swiftpm.sh
```

The no-skip wrapper is the mandatory complete gate. Private native-Vision
fixtures remain ignored and enter only through the documented opt-in environment;
the wrapper must execute all eight opt-ins with zero failure and zero skip.

## Configuration and Distribution Boundary

- `BeautySDK/Package.swift` owns products, targets, platforms, dependencies, and
  resource processing.
- No runtime secrets or service credentials are part of the current stack.
- Bundled resource IDs resolve through `BeautyResourceCatalog`, never arbitrary
  filesystem paths.
- Distribution, binary packaging, App Store submission, commercial approval,
  shipping, launch, and release readiness are not current claims.
- Any future network, external model/resource, privacy-manifest, or render-backend
  change must reopen the owning security and reliability contracts.

---
*Stack analysis: 2026-08-14 after Phase 66 archive retirement*
