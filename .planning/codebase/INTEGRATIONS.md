# External Integrations

**Analysis Date:** 2026-08-14
**Boundary:** SDK-only SwiftPM repository

## Apple Frameworks

- Vision runs on-device behind `BeautyDetection` to produce package-only,
  request-local face support. It requires no account, API key, or network call.
- Core Image, Core Graphics, ImageIO, Core Video/Core Media, and Foundation back
  validation, canonicalization, rendering, and public value types.
- AppKit is used only by the macOS `BeautyExampleRenderer` executable.
- CryptoKit is used by a resource integrity test.

No application UI framework, camera/photo permission path, capture session, or
application lifecycle integration is active. Any such implementation exists only
inside the verified historical archives and is not current integration guidance.

## Network, Identity, and Services

- No URL endpoint, upload, analytics, remote configuration, account, login,
  payment, entitlement, webhook, hosted backend, or third-party SDK is active.
- No credential, token, certificate, service-account file, `.env` contract, or
  runtime secret is required.
- Adding network/cloud/model delivery requires a new security, privacy,
  integrity, licensing, failure, cache, and observability design.

## Storage and Resources

- Production resources are bundled through SwiftPM under
  `BeautySDK/Sources/BeautyResources/Resources/` plus the single retained,
  byte-pinned inactive shader resource.
- `BeautyResourceCatalog` resolves logical IDs through `Bundle.module`; there is
  no arbitrary-path or runtime-download API.
- `BeautyExampleRenderer` reads local image inputs, accepts only the executable
  `cpu` token, writes ignored disposable PNGs, reopens/checks dimensions, and
  persists only a versioned aggregate report of relative public identities and
  reconciled counts. This is not SDK persistence or a public backend contract.
- `IntegrationTests/BeautySDKConsumer` is an external one-target SwiftPM
  fixture with one local `BeautySDK` path dependency; it generates its own
  neutral input and observes real public-facade output. It has no internal
  target, UI/Demo, Xcode, simulator, device, or tracked-media dependency.
- Real-image fixtures remain ignored under `example-images/`; tracked
  authorization metadata contains no private locator or image bytes.
- Historical archives under `archives/legacy-ui/` are tracked recovery artifacts,
  never runtime resources. Their tool pins ZIP/manifest digests, inventory, and
  resource bounds before any temporary extraction.

## Diagnostics

There is no hosted error tracker or telemetry client. Public observability is
limited to typed errors, fixed warnings, redacted detection summaries, and
bounded aggregate metrics. Raw images, framework objects, geometry, masks,
paths, child transcripts, and biometric-adjacent support are forbidden durable
diagnostics.

## Build and Validation

SwiftPM is the only active package/build/test system:

```bash
swift build --package-path BeautySDK
swift test --package-path BeautySDK
swift run --package-path BeautySDK BeautyExampleRenderer --help
bash scripts/check-swiftpm-consumer.sh
bash scripts/run-no-skip-swiftpm.sh
```

The mandatory wrapper first verifies both archives, the SDK-only scanner, and
the external consumer, then runs one bounded child with all required local
opt-ins. No CI/CD,
distribution, registry publication, or release pipeline is claimed.

---
*Integration audit: 2026-08-14 after Phase 66 review remediation*
