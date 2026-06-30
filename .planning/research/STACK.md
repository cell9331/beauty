# Stack Research

**Domain:** iOS beauty SDK hardening, QA automation, performance, and distribution readiness.
**Researched:** 2026-06-30
**Confidence:** HIGH for Apple platform guidance, MEDIUM for project-specific phase sizing.

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
| --- | --- | --- | --- |
| Swift / SwiftPM | Apple Swift 6.x observed locally during v1.3 planning | SDK unit tests, executable renderer, package-level validation | Existing SDK is a Swift Package and already verifies with `swift test --package-path BeautySDK`. |
| XCTest / XCUITest / XCTMetric | Xcode-provided | Unit, UI, and repeatable performance tests | Official Apple test stack; avoids adding third-party runners before the local gates are stable. |
| Xcode / xcodebuild / simctl | Xcode 26.x observed locally during v1.3 planning | Demo build, simulator test, screenshot capture | Existing evidence and repo docs already require explicit simulator destinations. |
| Instruments / xctrace | Xcode-provided | Timing, allocations, long-run profiling | Apple recommends Xcode performance tools for app performance investigation. |
| Metal / Core Image / AVFoundation / Vision | Apple platform frameworks | Rendering, image IO, camera input, face detection | Existing architecture already uses Apple-local processing and avoids third-party beauty SDKs. |
| OSLog / OSSignposter / MetricKit | Apple platform frameworks | Redacted logs, signposts, app-level diagnostics | Existing `RELIABILITY.md` names these as the diagnostics model. |

### Supporting Tools

| Tool | Purpose | When to Use |
| --- | --- | --- |
| `BeautyExampleRenderer` | Deterministic still-image output regression | Use for no-op tolerance, visible output, dimensions, watermark, and geometry-output boundaries. |
| `rg`, shell scans | Boundary and privacy checks | Use for facade-only imports, no realtime `UIImage`, no raw path/framework error leaks, and no overclaiming. |
| Local screenshot artifacts | UI/layout regression evidence | Use for simulator visual checks without introducing remote services or network assets. |

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
| --- | --- | --- |
| XCTest/XCUITest | Third-party iOS UI testing frameworks | Only after native tests cannot express a required check. |
| Instruments/xctrace evidence | Ad hoc timing logs only | Logs are acceptable as a first signal, but release-like claims need profiler or repeatable metric evidence. |
| Local renderer fixtures | Manual-only visual review | Manual review remains useful, but deterministic fixture output should be the regression backbone. |
| Apple-local processing | Third-party beauty SDK or cloud processing | Requires explicit user approval plus `SECURITY.md` network/dependency updates. |

## What NOT to Use

| Avoid | Why | Use Instead |
| --- | --- | --- |
| Hidden network analytics or cloud processing | Violates current local-first privacy posture. | Local tests, local metrics, and explicit opt-in design if network is ever promoted. |
| New product feature work during v1.4 | Dilutes hardening goals and makes quality regressions harder to isolate. | Defer feature breadth to later milestones. |
| Unbounded screenshot expectations | Causes flaky UI tests across simulator/device differences. | Stable routes, fixed destinations, scoped screenshots, and tolerance-based comparisons. |
| Per-frame free-form logging | High overhead and privacy risk. | Sampled metrics, redacted event logs, and signposts. |

## Sources

- Apple Xcode performance documentation: https://developer.apple.com/documentation/xcode/improving-your-app-s-performance
- Apple Metal Best Practices Guide, persistent objects: https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/PersistentObjects.html
- Apple Metal Best Practices Guide, buffering: https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/MTLBestPracticesGuide/TripleBuffering.html
- Apple XCTest metrics documentation: https://developer.apple.com/documentation/xctest/xctmetric
- Apple AVFoundation late-frame discard property: https://developer.apple.com/documentation/avfoundation/avcapturevideodataoutput/alwaysdiscardslatevideoframes
- Apple privacy manifest documentation: https://developer.apple.com/documentation/bundleresources/privacy-manifest-files
- Apple Vision face landmarks request documentation: https://developer.apple.com/documentation/vision/vndetectfacelandmarksrequest

---
*Stack research for: v1.4 Stability, QA, and Debt Cleanup*
*Researched: 2026-06-30*
