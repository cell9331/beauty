# Testing Patterns

**Analysis Date:** 2026-08-18
**Boundary:** SDK-only SwiftPM repository

## Post-Archive Audit Qualification

The v1.17 archive recorded Metal-available focused `12/0/0` and full
`765/0/0` evidence. Current F-03 remediation probes availability first: only the
available branch runs the 13-test suite and reports `parity_executed=1`; the
unavailable branch runs two typed selection tests, reports
`parity_executed=0`, and emits no parity-success marker. The archived counts are
historical. On 2026-08-18 the available branch recorded `metal_available=1`,
`metal_unavailable=0`, `parity_executed=1`, `focused_tests=13`, and
`unavailable_tests=0`; the archive-first wrapper passed XCTest `776/0/0`, all
eight opt-ins exactly once, and `skipped_tests=0`. F-08 result alpha/extent
enforcement is remediated. F-09 geometry-envelope provenance now uses one
immutable observation and two fail-closed mutations. F-02/F-04/F-05/F-10 are
mutation-gated under bounded CPU-owned local-retouch, opaque/named-sRGB GPU
input/output, CPU-oracle still-image math, and caller-serialized engine contracts.

## Standing Automated Acceptance Policy

SwiftPM and SDK-owned scripts are the project-wide milestone authority. Tests
for image-producing behavior inspect actual input/output pixels and metadata,
using the owning contract's exact or bounded assertions for dimensions/extent,
orientation/mirroring, color space, alpha, neutral identity, intended movement,
protected regions, determinism, and typed failure. A command that merely exits
successfully cannot prove image correctness.

Physical-iPhone testing is optional user evaluation after SDK completion. It is
not a default requirement, hard gate, dependency, expected test identity, or
blocker for this or any later SDK milestone. Only an explicit later user
decision can add a device-focused gate. Actionable feedback should be recorded
in `PLANS.md` and converted into a deterministic regression where possible;
without separate device/product evidence, no on-device performance, thermal,
battery, endurance, commercial quality, or release claim is made.

## Runner and Inventory

XCTest through Swift Package Manager is the only active test framework. Six test
targets live under `BeautySDK/Tests/`; the current inventory is 74 Swift files and
33,569 test lines, excluding `.build`.

`BeautyResultConcurrencyTests` is the public concurrency contract suite. It
executes 3 tests with zero failures, compiling a `Sendable` result through a
generic constraint, preserving its public fields over an async task hop, and
retaining ordinary non-sendable result construction as source-compatible. The
SDK-only boundary self-test owns the negative rejection of an unconditional
generic `BeautyResult` sendability declaration.

The generated CPU reference preflight executes 15 fixture, 10 geometry/color, and
16 local-retouch/determinism tests with zero generated skips. The v1.16
historical mandatory full child executed 702 tests with eight documented
environment-gated opt-ins enabled; the Phase-71 full child historically executed
728 tests, and the historical Phase-73 full child executed 753 tests with the same
eight opt-ins. It accepts only one complete SwiftPM child
transcript with:

- all eight opt-ins executed exactly once;
- zero failures;
- zero skips; and
- a nonzero all-tests denominator.

The external consumer preflight runs before the child and builds a separate
local-path package that imports only public `BeautySDK`, generates a neutral
RGBA input, and checks real output bytes/dimensions. The renderer regression
suite covers the exact 74-case inventory, and
`BeautyExampleRendererProcessTests` invokes the compiled binary through
Foundation `Process` for reproducible success, invalid matrix, collision,
artifact replacement, control-character escaping, and independent render/encode
failure behavior. Their temporary build/fixture roots
and captured child output are not evidence artifacts.

`scripts/check-cpu-reference-oracles.sh` runs after the public consumer and
before private bundles or the one-child gate. It statically requires the nine
generated-oracle sources to stay regular files under the test tree, rejects
media/path/raw-output/GPU drift, and runs only generated in-memory filters.
Private/native-Vision suites retain explicit environment guards and remain
optional; they cannot lend success to CPU-01..CPU-05.

## Commands

```bash
swift test --package-path BeautySDK
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFullScleraRednessProviderTests
swift test --package-path BeautySDK --enable-code-coverage
bash scripts/check-cpu-reference-oracles.sh
bash scripts/run-no-skip-swiftpm.sh
```

The mandatory wrapper orders archive verification → post-archive SDK-only
boundary self-test/live scan → backend contract/configuration → Metal
runtime/feature/parity preflights → external consumer → generated CPU reference
preflight → private opt-ins → one SwiftPM child. Archive
corruption, restored source roots, stale application dependencies, retained
shader drift, an unexpected skip/failure, or a zero-test run must fail non-zero.

The v1.16 historical mandatory wrapper executed 702 tests with zero failures and
zero skips. The Phase-71 archive-first wrapper historically executed 728 tests
with zero failures and zero skips. The historical Phase-73 archive-first wrapper
executed 753 tests with zero failures and zero skips, all eight opt-ins exactly
once, and separate Metal availability classifications. Its aggregate markers
are evidence for the SDK-only SwiftPM gate only; they do not establish UI/Demo behavior,
simulator/device quality, performance, commercial approval, packaging,
shipping, launch, or release readiness.

## Organization and Style

- Co-locate tests by owning target under `BeautySDK/Tests/<Target>Tests/`.
- Use XCTest only; no external assertion or mocking library is present.
- Prefer direct arrange/act/assert and exact values for public inventories,
  defaults, caps, error cases, state transitions, and no-op behavior.
- Use table-driven typed rows for repeated feature-family invariants.
- Use injected closures, Vision observation providers, and package testing hooks
  for deterministic integration seams.
- Do not mock pure normalization, geometry math, color transforms, composition
  ownership, resource parsing, or pixel-level containment.

## Fixture Boundary

- Deterministic synthetic in-memory fixtures prove mechanics and adversarial
  safety only.
- Rights-approved real positive/negative media remains ignored under
  `example-images/local-retouch-review/` and is consumed only by validated
  opt-in paths.
- Both generated and rights-approved fixture paths are automated input/output
  oracles; neither requires a physical iPhone or a manual checkpoint.
- Raw media, mask/landmark/pixel data, local locations, and child output do
  not enter tracked evidence.
- Generated renderer output remains ignored, disposable, bounded, and unstaged.

## Coverage and Failure Semantics

No numeric line/branch threshold is configured. Behavioral coverage is enforced
through exact inventories, focused suites, adversarial containment, request-local
privacy/recovery tests, renderer checks, source scanners, and the no-skip gate.

Assert typed and redacted error surfaces. Concurrency tests must use bounded
expectations/actors rather than arbitrary sleeps and must prove request isolation,
stale-result rejection, recovery, and zero retained sensitive state.

Historical application/UI tests are recoverable only from the archive. They are
not active coverage, may not satisfy current requirements, and must not be restored
to the repository.

## Phase 70 Backend Contract Coverage

The package-only `BeautyBackendContractTests` suite owns the shared backend
boundary. It exercises valid still-image and pixel-buffer requests, canonical
metadata/extent consistency, malformed dimensions and normalized strength
rejection, output-kind pairing, false alpha/extent declarations, shifted and
unchanged translated still-image extents, deterministic bounded diagnostics,
and a terminal executor failure with exactly one dispatch and no fallback. The request
keeps selected support and canonical/composition state transient; only aggregate
dimensions, alpha/extent flags, and bounded unit/failure/collision/change counts
are observable.

## Phase 71 Metal Runtime Coverage

`BeautyMetalRuntimeTests` owns unavailable-host, malformed-input, resource
creation, command/encoder status, identity output, repeated-request, and
failed-then-valid cleanup behavior. `BeautyMetalBackendTests` owns the shared
package boundary for pixel buffers and still images, output-kind/extent and
aggregate diagnostics, exactly-one runtime invocation, terminal errors, and
CPU/Metal isolation. The focused Metal preflight runs these suites with the
existing backend contract/CPU routing tests for 26 tests, requiring nonzero
execution and zero failures/skips. It reports `metal_available` separately
from `metal_unavailable`; unavailable hosts are explicit evidence, never GPU
success.

Static mutations cover missing cleanup, public selector/schema drift, alternate
execution paths, private diagnostic fields, and movement outside the owning
targets. The runtime lifecycle is validate dimensions/bytes → create bounded
resources → encode retained identity → synchronize/check status → materialize
matching output → release all request resources on success/error. Phase 72
owns feature passes, Phase 73 owns public `.cpu`/`.gpu` configuration and typed
unavailable behavior, and Phase 74 owns generated parity/no-skip closeout. CPU remains the reference;
these tests do not establish simulator/physical-device behavior, performance,
commercial approval, packaging, shipping, launch, or release readiness.

## Phase 72 Feature-Pass Coverage

`BeautyMetalLocalRetouchPassTests` executes generated carrier/original-pixel,
protected-byte, alpha, extent, collision, malformed/foreign/duplicate,
smallest-unit isolation, mixed-order, and terminal-cleanup checks alongside
the color, geometry, backend, and runtime suites. The archive-first order is
archive → boundary → backend → runtime → feature passes → consumer → CPU
oracle → opt-ins → full child. `check-metal-feature-passes.sh` is invoked once,
uses bounded logs, mutation-tests source binding/privacy/cleanup/scope, and
records available/unavailable Metal separately. No raw private payloads enter
tracked evidence; CPU remains the reference until Phase 74 parity closeout.

## Phase 73 Configuration Coverage

Historical Phase-73 focused coverage recorded public configuration `16/0/0`
and Metal runtime `34/0/0`, each with separate
`metal_available=1` / `metal_unavailable=0` classifications. Tests cover the
exact `.cpu`/`.gpu` selector, `.cpu` defaults and missing legacy Codable keys,
request-local factory policy, and terminal `.metalUnavailable` without a CPU
fallback. The archived full wrapper executed `753/0/0` with all eight
opt-ins exactly once. Phase 74 owns generated parity and closeout; no
UI/Demo, simulator/device, performance, commercial, packaging, shipping,
launch, or release-readiness claim is carried by these tests.

## Phase 74 Historical Generated Parity Coverage

`BeautyBackendParityTests`, `BeautyBackendSafetyParityTests`,
`BeautyBackendDeterminismParityTests`, and
`BeautyBackendSelectionConcurrencyTests` execute generated CPU/Metal
structural, numeric, safety, degradation, failure-isolation, determinism, and
request-local policy cases. Neutral/no-face bytes are exact; general active
tolerances remain maximum channel `8` and mean RGB `< 5.0`, while the generated
still-image color/lip oracle is pinned to maximum channel `2` and mean RGB
`< 0.75`. The suites retain only
aggregate counts/deltas and use no skips, sleeps, files, media, or durable
payloads.

`check-backend-parity.sh` mutation-tests omitted or weakened assertions and
availability merging. The archived wrapper invoked it once and the historical
full gate executed `765/0/0` with eight opt-ins exactly once and separate
`metal_available=1` / `metal_unavailable=0`. The repaired unavailable branch
reports `parity_executed=0` and no parity-success marker. Current focused
preflights pass backend-neutral `24/0/0`, Metal runtime `42/0/0`, Metal feature
`34/0/0`, configuration `19/0/0`, CPU reference `41/0/0`, and available parity
`13/0/0`; the full wrapper passes `776/0/0`. This remains SDK-only and does not
establish transparent-input support, end-to-end GPU local-retouch composition,
shared-instance parallel safety, UI/Demo,
simulator/device, performance, commercial, packaging, shipping, launch, or
release-readiness behavior.

---
*Testing analysis: 2026-08-18 after bounded v1.17 post-archive remediation closeout*
