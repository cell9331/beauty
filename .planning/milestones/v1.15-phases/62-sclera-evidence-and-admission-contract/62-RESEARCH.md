---
phase: 62
slug: sclera-evidence-and-admission-contract
status: complete
researched: 2026-08-07
discovery_level: 0
security_standard: OWASP ASVS Level 1
planner_fallback: main-thread-sequential
---

# Phase 62 Research — Sclera Evidence and Admission Contract

## Executive Summary

Phase 62 is an append-only extension of two already-proven seams: the Phase 54
local evidence authority and the Phase 59 `BeautyParameters` plus
`BeautyEffectResolver.localRetouchAdmission(parameters:)` admission pattern.
It does not need a new framework, dependency, service, model, renderer, Demo
control, or production sclera provider.

The canonical ledger currently has an independently open teeth row, a closed
`sclera_redness` row with both missing-genuine reasons and zero counts, and a
closed upper-eyelid row. The local rights-approved inventory contains no
sclera pair. That is a hard intake precondition: planning may create and test a
fail-closed adapter, privacy runner, contract, and checker, but it must not add
`scleraRednessReduction` or a sclera demand until a genuine authorized positive
and negative are reviewed and the Phase 54 serializer emits the exact open row.

## Existing Authority and Interfaces

### Evidence authority

- The archived Phase 54 `54-evidence-core.js` remains the sole owner of trusted
  authorization binding, exact asset triples, structured review validation,
  feature reduction, independent closed snapshots, and durable serialization.
- The canonical `54-EVIDENCE-DECISIONS.json` is append-only decision authority.
  Phase 62 must reproduce its complete bytes through `serializeDurableExport`;
  a hand-edited sclera row is never an acceptable open decision.
- Phase 59's private teeth runner and adapter prove the correct local-only
  pattern: NUL-safe ignored-file discovery, absolute paths only in child memory,
  unique logical asset basenames, actual in-memory digests, opaque trusted
  rights projections, fixed output, and aggregate-only tracked state.
- A new sclera adapter must select exactly two `sclera_redness` rows by feature,
  polarity and opaque identity. It may not infer by array position, borrow the
  teeth rows, or close the teeth row while serializing siblings.

### Local derivative and review authority

- `spike-findings-beauty` requires a genuine visible-redness positive and a
  genuine normal/already-low-redness negative with approved internal-evaluation
  rights. They may show different people.
- Only the guarded sclera path is suitable for private derivative preparation:
  validate each eye, exclude iris/pupil/highlights before color scoring, feather
  locally, and re-clip to the same hard envelope. The older unguarded
  `sclera-redness` mask can expand after blur and is not admission evidence.
- The existing isolated RetouchSpikeLab `sclera-guarded-color` mode can create
  ignored `guarded-mask.png` and `guarded-after.png` derivatives for review.
  Its experimental guard constants remain mechanics seeds, not production
  constants; Phase 62 reviews the actual local result but does not copy those
  constants into `BeautySDK`.
- Review is local, blinded and original-detail. Durable fields remain exactly:
  target presence, mask coverage 1...5, protected leakage, naturalness 1...5,
  structure change, decision and fixed reason. Mechanics metrics, overlays,
  raw support and reviewer prose have zero admission weight.

### Runtime authority

- `BeautyParameters` currently contains exactly 60 stored properties: 59
  numeric `Float` values plus optional `filterId`; `teethWhitening` is the tail.
  The sclera field, if unlocked, must become the new tail and yield exactly 61
  fields: 60 numeric values plus `filterId`.
- The custom decoder already treats missing numeric keys as zero, and
  `normalized()` uses the public initializer. Appending one trailing defaulted
  `Float` preserves existing labeled source calls and legacy payloads.
- `BeautyEffectResolver.localRetouchAdmission(parameters:)` is the sole
  admission authority. It currently returns one opaque demand for positive
  teeth intent. The open sclera branch must count the independently positive
  normalized teeth and sclera intents, producing 0, 1 or 2 opaque demands;
  repeated aliases or unrelated values cannot multiply them.
- The private carrier exposes only `isEmpty`, so Phase 62 must prove demand
  cardinality through request-local engine observations or a package-only test
  seam without exporting feature names, evidence state, masks or support.

## Recommended Execution Shape

1. Freeze the exact closed/open contract, eight HIGH threats, privacy allowlist,
   edge assumptions, and a mutation checker while preserving the current
   closed sclera row and completed teeth slice.
2. Implement a sclera-only ignored-bundle runner and Phase 54 adapter. Test its
   missing, malformed, ambiguous, wrong-feature, duplicate-polarity, rights,
   binding, extra-field and sensitive-output failure modes with disposable
   non-product fixtures; keep the canonical row closed.
3. Stop at a hard intake checkpoint unless two licensed originals are present.
   When supplied, create guarded ignored derivatives, inspect original/mask/
   after at original detail, record only fixed judgments, and let ReviewCore
   serialize the exact open row while preserving teeth and upper eyelid.
4. Only after exact open, append `scleraRednessReduction`, extend model/Codable/
   preset compatibility to 61/5, and admit one independent sclera demand without
   adding a renderer case. Renderer inventory remains 73 and Demo stays disabled.
5. Run exact-open mutations, isolated HIGH modes, tracked/staged privacy, focused
   and full SwiftPM, explicit Demo regression, and owner/requirements lifecycle
   checks. Any missing private gate or HIGH failure blocks Phase 63.

## Validation Architecture

| Layer | Existing owner | Phase 62 proof |
| --- | --- | --- |
| Evidence core | Node built-in tests around Phase 54 ReviewCore | Exact pair, reviews, independent decisions, serializer bytes |
| Private intake | Node child-process runner | NUL-safe ignored discovery, nofollow/bounds, fixed path-free output |
| Contract/security | Standard-library Python checker | One-field mutations, exact inventories, isolated T-62-01...08 |
| SDK model/admission | SwiftPM XCTest | 61-field append-only model and 0/1/2 independent demand matrix |
| Compatibility/output | SwiftPM plus resource tests | Five unchanged presets, 73 unchanged renderer cases, teeth unchanged |
| Demo/lifecycle | Explicit iOS Simulator tests | Three disabled nil-mapped local-retouch rows |
| Human evidence | Local original-detail review | Genuine polarity, target improvement, containment, naturalness, no-op |
| Privacy | Tracked/staged scanner | No media, path, digest, rights detail, identity, raw support or prose |

Focused Node/Python and SwiftPM filters are the per-task feedback loop; full
SwiftPM and explicit Demo tests are wave/final gates. A human review is required
only for the two real local fixtures and cannot be replaced by aggregate
mechanics metrics.

## Spec-less Edge Resolution

The deterministic fallback surfaced nine probes because this phase has no
separate SPEC. Five are concretely covered by the locked context:

- Empty or one-sided evidence remains closed with exact missing-genuine reasons.
- Duplicate/equal IDs, ambiguous asset basenames and touching identities do not
  merge; validation rejects them.
- Fixture and ledger order is non-authoritative; joins use exact feature,
  polarity and opaque identity, while serializer output retains canonical order.
- Empty review input emits closed feature-local aggregates and no sensitive row.
- Durable equality is exact UTF-8 serializer bytes with two-space LF JSON and
  one final newline.

The four `unclassified` probes for frozen review, independent decisions,
append-only scalar compatibility and sole-input admission remain visible
planner assumptions. Plans resolve them only through D-05...D-16 and executable
acceptance tests; they are never silently dismissed or treated as human-passed.

## Security and Privacy Findings

- Highest-risk evidence failures are cross-feature borrowing, path/digest/rights
  leakage, reviewer-prose persistence, hand-edited admission, duplicate or
  substituted assets, and scanner/tool errors interpreted as clean.
- Highest-risk runtime failures are adding an inert field while closed, moving
  the existing teeth tail, alias/proxy activation, one feature suppressing or
  multiplying the other, and accidentally starting Phase 63 provider/output work.
- Every threat is HIGH under ASVS Level 1. A skipped local-evidence gate, missing
  fixture, unclassified subprocess status, or absent isolated threat mode is a
  failure, not a pass.

## Package Legitimacy Audit

Not applicable. Phase 62 adds no package, model, network integration, external
API, database schema, or service. The existing SwiftPM, Node, Python standard
library and local spike harness are sufficient.

## Confidence and Open Precondition

| Area | Confidence | Basis |
| --- | --- | --- |
| Evidence serialization | High | Phase 54 core plus Phase 59 open teeth adapter |
| Private runner/privacy | High | Existing fixed-output ignored-bundle pattern |
| Scalar/Codable compatibility | High | Current tail field and 60-field tests |
| Independent demand | High | Existing opaque admission seam and teeth tests |
| Real sclera admission | Blocked by input | Zero licensed sclera fixtures are currently available |

The only material external precondition is the licensed genuine positive and
negative. All closed-state infrastructure can be completed before requesting
them; the canonical row, scalar and demand must remain closed until then.

