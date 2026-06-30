# Architecture Research

**Domain:** iOS beauty SDK hardening and technical-debt cleanup.
**Researched:** 2026-06-30
**Confidence:** HIGH for current repo architecture, MEDIUM for future implementation details.

## Standard Architecture

v1.4 should harden the existing architecture instead of rearranging it:

```text
BeautyDemo UI and app pipelines
    -> public BeautySDK facade
        -> BeautyCore models/errors/diagnostics
        -> BeautyDetection coordinate and Vision adapter seams
        -> BeautyEffects resolver, caps, providers, color pipeline
        -> BeautyRender graph, passes, pixel-buffer factory
        -> BeautyResources catalog and validation
    -> local QA artifacts, screenshots, renderer outputs, and metrics
```

## Component Responsibilities

| Component | Responsibility in v1.4 | Notes |
| --- | --- | --- |
| `BeautyDemo` | UI automation, simulator screenshots, camera/editor pipeline checks | Must remain facade-only. |
| `BeautySDK` facade | Public integration, metadata-aware results, error mapping | No public API expansion unless explicitly justified. |
| `BeautyCore` | Configuration, errors, diagnostics, result summaries | Best home for metric/log shapes already owned by root docs. |
| `BeautyDetection` | Face/landmark state and redacted summaries | Real-device Vision parity may be manual or blocked without hardware. |
| `BeautyEffects` | Safety caps, resolver/degradation behavior, visible fixture logic | Performance work should not bypass safety caps. |
| `BeautyRender` | RenderGraph, pass skip behavior, output resources | Metal best practices favor persistent/cached objects and bounded per-frame work. |
| `BeautyResources` | Resource identifier, manifest, preset/filter validation | Privacy/resource review should stay here, not in UI. |
| `BeautyExampleRenderer` | Deterministic output regression evidence | Should remain public-facade based and local-only. |

## Architectural Patterns

### Pattern 1: Evidence-First Hardening

**What:** Establish baseline commands and artifacts before changing behavior.

**When to use:** Any optimization, cleanup, or reliability improvement.

**Trade-offs:** Slower start, but prevents unmeasured optimization and regression masking.

### Pattern 2: Public-Facade Regression Harness

**What:** Test visible output through `BeautySDK`, not internal targets.

**When to use:** Still-image output, no-op tolerance, renderer matrix, host integration behavior.

**Trade-offs:** Some internals need separate unit tests, but user-facing evidence stays realistic.

### Pattern 3: Degrade-and-Measure

**What:** Quality modes, detection states, resource failures, and backpressure should emit redacted metrics/warnings instead of hidden behavior.

**When to use:** Performance, memory, thermal, detection, and render-resource failure paths.

**Trade-offs:** Requires careful redaction and aggregation to avoid privacy leaks.

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do This Instead |
| --- | --- | --- |
| Optimize code without a repeatable baseline | Cannot prove improvement or catch regressions. | Add command-level evidence first. |
| Move SDK logic into Demo to make UI tests pass | Violates facade-only host integration. | Add SDK tests or public facade seams. |
| Treat provider tests as visual output completion | Provider evidence does not prove saved-image geometry output. | Keep geometry-heavy branches partial until facade-visible output exists. |
| Add logs/metrics with raw paths or geometry | Violates security posture. | Use redacted event codes, counts, and timing buckets. |

## Integration Points

| Boundary | Communication | v1.4 Check |
| --- | --- | --- |
| Demo -> SDK | `import BeautySDK` only | Import scans and Demo tests. |
| Camera -> pipeline | `CVPixelBuffer`/metadata | No realtime `UIImage`, bounded late-frame behavior. |
| Renderer -> outputs | local fixture input/output | Dimension, watermark, no-op, visible-output checks. |
| Diagnostics -> logs/metrics | redacted event/metric shapes | No image, path, landmark, bounding box, raw framework error. |
| SDK distribution -> privacy | `PrivacyInfo.xcprivacy` assessment | Manifest behavior matches no-collection/local-first posture. |

## Sources

- `ARCHITECTURE.md`, `DESIGN.md`, `FRONTEND.md`, `SECURITY.md`, `RELIABILITY.md`, and `QUALITY_SCORE.md`.
- Apple official docs listed in `.planning/research/STACK.md`.

---
*Architecture research for: v1.4 Stability, QA, and Debt Cleanup*
*Researched: 2026-06-30*
