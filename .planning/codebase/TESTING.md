# Testing Patterns

**Analysis Date:** 2026-08-14
**Boundary:** SDK-only SwiftPM repository

## Runner and Inventory

XCTest through Swift Package Manager is the only active test framework. Six test
targets live under `BeautySDK/Tests/`; the current inventory is 50 Swift files and
27,494 test lines, excluding `.build`.

The default full suite currently executes 650 tests with eight documented
environment-gated opt-ins skipped. The mandatory no-skip run enables the same
eight identities and accepts only one complete SwiftPM child transcript with:

- all eight opt-ins executed exactly once;
- zero failures;
- zero skips; and
- a nonzero all-tests denominator.

## Commands

```bash
swift test --package-path BeautySDK
swift test --package-path BeautySDK --filter BeautyEffectsTests.BeautyFullScleraRednessProviderTests
swift test --package-path BeautySDK --enable-code-coverage
bash scripts/run-no-skip-swiftpm.sh
```

The mandatory wrapper first verifies both retained legacy archives and the
post-archive SDK-only boundary. Archive corruption, restored source roots, stale
application dependencies, retained shader drift, an unexpected skip/failure, or
a zero-test run must fail non-zero.

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
- Raw media, masks, landmarks, pixels, local locators, and child transcripts do
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

---
*Testing analysis: 2026-08-14 after Phase 66 archive retirement*
