# Phase 69: Public Concurrency Repair and SDK-Only Closeout — Context

**Gathered:** 2026-08-14  
**Status:** Ready for planning  
**Mode:** Auto-generated from locked milestone direction (`--auto`, research/discuss skipped)

<domain>
## Phase Boundary

Repair the public generic result concurrency contract and close the current
SDK-only milestone through one archive-first, boundary-first, SwiftPM-only gate.
The phase owns `BeautyResult` conditional sendability, public compile/runtime
coverage, static rejection of unconditional generic sendability, closeout gate
ordering, and synchronized current owners/ledgers. It does not add algorithms,
Metal/GPU execution or API, UI/Demo behavior, simulator/device execution,
tracked media, performance/commercial evidence, packaging, shipping, launch, or
release-readiness claims.
</domain>

<decisions>
## Decisions

Implementation Decisions

- **D-01:** `BeautyResult<Output>` uses conditional `Sendable` conformance only when `Output: Sendable`; the arbitrary-payload `@unchecked Sendable` declaration is removed.
- **D-02:** Public tests prove a `Sendable` result can cross an async task boundary while preserving output, warnings, metrics, and detection summary; existing ordinary `BeautyResult(output:)` source remains valid.
- **D-03:** The non-sendable negative is compile-time evidence: a positive generic `Sendable` assertion must compile, while a static boundary self-test must reject any unconditional generic `BeautyResult` sendability declaration. No intentionally compile-failing Swift source is included in a passing SwiftPM target.
- **D-04:** The hardened closeout gate runs the boundary checker self-test and post-archive scan before the public consumer, generated CPU oracle preflight, private opt-ins, and one complete SwiftPM child; it rejects unconditional generic sendability in addition to the existing UI/Xcode/media/Metal drift checks.
- **D-05:** Architecture, design, reliability, security, product, quality, testing-map, plans, project, requirements, roadmap, and state owners describe the same conditional-sendability and SDK-only closeout contract using measured aggregate evidence only.
- **D-06:** Durable evidence contains test identities, counts, fixed codes, and scope/non-claim statements only; raw child transcripts, paths, pixels, masks, landmarks, support, generated outputs, private fixture metadata, and device/release evidence remain non-durable or out of scope.

### D-01 — Conditional public contract

The source declaration must be `public struct BeautyResult<Output>: Sendable
where Output: Sendable` (or an equivalent conditional declaration accepted by the
Swift 6 compiler), with no unconditional or arbitrary-payload
`@unchecked Sendable` promise. Stored warnings, metrics, and detection summary
remain the existing public values and do not change shape.

### D-02/D-03 — Compile and runtime proof

The public `BeautySDK` test target must compile a concrete sendable output
through a `T: Sendable` assertion and move a complete result through
`Task.detached` or an equivalent concurrency boundary. A non-sendable payload
must not satisfy that generic constraint; the static boundary mutation test is
the negative compile-contract guard because a compile-failing source cannot be
part of the passing package target. Existing string-result construction and
stored-value assertions remain in the suite.

### D-04 — Closeout gate

The boundary checker remains the owner of the active-tree static contract. Its
self-test must mutate a temporary `BeautyResult` declaration to the old
unconditional form and prove rejection, while the live post-archive scan proves
the repository is clean. The mandatory wrapper must report short aggregate
markers and must not persist the child transcript.

### D-05/D-06 — Owner synchronization and nonclaims

Current docs and planning ledgers may record measured focused/full test totals
only after the commands run. They must preserve the SDK-only SwiftPM boundary,
the CPU/Core Image reference, retained shader pin, archive contract, optional
private fixture separation, and the queued Metal direction without claiming
Metal/GPU execution, UI/Demo behavior, simulator/device quality, performance,
commercial approval, packaging, shipping, launch, or release readiness.
</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautySDK/Sources/BeautyCore/Models/BeautyResult.swift` is the sole public
  generic result declaration and currently carries the unconditional
  `@unchecked Sendable` debt.
- `BeautySDK/Sources/BeautySDK/BeautySDK.swift` re-exports `BeautyCore`, so a
  test importing only `BeautySDK` can exercise the public contract.
- `BeautySDK/Tests/BeautySDKTests/BeautySDKFacadeTests.swift` already proves
  ordinary `BeautyResult(output:)` source compatibility and is the owning public
  facade test target.
- `scripts/check-sdk-only-boundary.sh` owns active-tree static checks and has a
  mutation self-test pattern suitable for the generic-sendability guard.
- `scripts/run-no-skip-swiftpm.sh` already orders archive, boundary, consumer,
  generated CPU, private opt-in, and one-child SwiftPM validation.

### Established Patterns

- Keep public payloads redacted and aggregate-only; do not expose support,
  coordinates, masks, pixels, or framework internals in diagnostics.
- Use SwiftPM/XCTest commands and SDK-owned shell gates; do not add Xcode,
  simulator, device, or UI automation to the active validation surface.
- Use temporary fixture roots and cleanup traps for static mutation tests; do
  not alter tracked source during a self-test.
- Recalculate source/test line counts from the active tree after implementation;
  executed test totals are authoritative over method-name counts.

### Integration Points

- Phase 69-01 changes the public declaration and creates the compile/runtime
  test evidence consumed by later static and documentation plans.
- Phase 69-02 extends the existing boundary self-test and mandatory wrapper; it
  must preserve Phase 68 generated-oracle ordering and all eight opt-ins.
- Phase 69-03/04 update only current owners and aggregate ledgers after the
  implementation and gate are green.
</code_context>

<specifics>
## Required Observable Outcomes

- A `BeautyResult` containing a `Sendable` output is accepted by a generic
  `T: Sendable` compile-time assertion and survives an async task hop with all
  public result fields intact.
- A non-sendable payload cannot obtain `BeautyResult` sendability through an
  unconditional generic declaration; boundary self-test mutation fails closed.
- Existing source construction and synchronous reads of `BeautyResult` compile
  unchanged.
- The mandatory wrapper rejects a restored unconditional declaration before any
  private fixture or full SwiftPM child runs.
- All active owners report the same conditional-sendability and SDK-only
  closeout status without expanding into Metal, UI, device, or release claims.
</specifics>

<deferred>
## Deferred Ideas

- Metal shaders, GPU runtime, public `.cpu`/`.gpu` selection, backend parity, or
  changes to retained `Warp.metal` (queued for the next milestone).
- New effects, `去脂`, semantic masks, hairline, double-chin, models, or network.
- UI/Demo, Xcode, simulator/device, performance, commercial, packaging,
  shipping, launch, or release-readiness validation.
- Tracked portrait media, generated output baselines, raw diagnostic snapshots,
  or durable fixture locators.
</deferred>
