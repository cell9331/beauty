# Coding Conventions

**Analysis Date:** 2026-08-14
**Boundary:** SDK-only SwiftPM repository

## Swift Structure and Naming

- Use PascalCase filenames/types and lowerCamelCase functions/properties.
- Prefix supported domain/public values with `Beauty`; name internal types by
  feature plus role, such as provider, transform, resolver, context, or summary.
- Keep code in its owning SwiftPM target: public/shared values in `BeautyCore`,
  observations in `BeautyDetection`, planning/effects in `BeautyEffects`, render
  primitives in `BeautyRender`, resources in `BeautyResources`, and host-facing
  orchestration in `BeautySDK`.
- Tests live under `BeautySDK/Tests/<Target>Tests/` and use descriptive
  `test<Behavior><Outcome>` names.

There is no active application/UI source convention. Historical naming and
layout from the retired UI/Demo trees are archive material, not templates for
new code.

## Style

- Preserve strict Swift 6 compatibility from `BeautySDK/Package.swift`.
- Use four-space indentation, declaration-line opening braces, trailing commas
  in multiline collections/calls, labeled parameters, and immutable value
  carriers.
- Prefer `guard` for preconditions and smallest-unit fail-closed abstention.
- Use typed `BeautyError` values at public boundaries; do not surface raw
  framework errors, paths, geometry, or fixture identifiers.
- Use `Sendable`, `@Sendable`, or actors deliberately. Any `@unchecked Sendable`
  conformance needs narrow documented ownership and tests.
- Do not widen public API solely for testing; use package/internal seams.

## Safety and Privacy

- Validate dimensions, checked arithmetic, format/color/alpha, and resources
  before allocation-heavy or platform work.
- Keep canonical pixels, observations, masks, proposals, and composition state
  request-local. Emit only fixed categories and bounded aggregates.
- Local-retouch providers may abstain locally; they never synthesize proxy
  geometry from siblings or prior requests.
- Accepted color edits derive from immutable original pixels under one explicit
  composition owner; unexpected overlap preserves source.
- Use `spike-findings-beauty` for local-retouch, private fixture, and privacy
  changes.

## Tests and Tools

- XCTest/Swift Testing source is compiled and run only through SwiftPM.
- Repository policy scripts use fail-closed Python/shell, bounded temporary
  storage, exact inventories, deterministic fixtures, and mutation self-tests.
- Use `rg` for text discovery and `git diff --check` for whitespace hygiene.
- Run the narrow owning suite during implementation and
  `bash scripts/run-no-skip-swiftpm.sh` for complete closeout.

## Scope Rules

- Do not restore active UI/Demo sources, application lifecycle, or UI automation.
- Do not add/modify Metal or GPU backend behavior in v1.16.
- Generated/private image evidence remains ignored and disposable.
- Historical recovery uses only `archive-legacy-ui.py restore` into a fresh
  outside-repository temporary directory after pinned verification.

---
*Convention analysis: 2026-08-14 after Phase 66 review remediation*
