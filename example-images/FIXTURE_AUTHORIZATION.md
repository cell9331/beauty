# Local Portrait Fixture Authorization

This record documents the permission boundary for the project's local portrait
fixture without storing the subject's name, source-device metadata, original
download path, or image bytes in Git.

## Active Fixture

| Field | Value |
| --- | --- |
| Fixture ID | `portrait_001` |
| Local path | `example-images/input/portraits/p1.jpg` |
| Rights status | `approved_internal_evaluation` |
| Rights record ID | `user_authorization_20260730_002` |
| Authorization date | 2026-07-30 |
| Source assertion | User supplied the replacement smiling portrait and explicitly confirmed ownership of all required copyright, portrait/likeness, and related permissions, including long-term use. |
| Permitted use | Ongoing local automated/manual SDK tests, algorithm evaluation, and derivative before/mask/after review for this project. |
| Retention | Local project workspace until the user revokes permission; raw and generated image files remain Git-ignored and must not be committed. |

The active copy is re-encoded without GPS, capture time, device, author,
copyright, or orientation metadata. Tests and diagnostics may use only the
opaque fixture name and aggregate results; they must not persist image bytes,
face geometry, or identity-derived descriptors.

## Evidence Boundary

This authorization permits use but does not assign feature polarity. Before the
portrait contributes product-feasibility evidence for teeth whitening, sclera
redness, or upper-eyelid fullness, a feature-specific review manifest must mark
it positive or negative, include complete original/mask/after assets, and apply
predeclared acceptance criteria. One portrait cannot establish population
coverage, calibration, demographic robustness, or commercial naturalness.

The visible smile and exposed teeth make this fixture appropriate for teeth-mask
containment and over-whitening review. Its already-light teeth do not establish
a yellow/dark-teeth positive, and the image is not automatically a redness or
upper-eyelid-fullness positive.

## Local Retouch Candidate

| Field | Value |
| --- | --- |
| Fixture ID | `portrait_002` |
| Local path | `example-images/local-retouch-review/candidates/portrait_002/original.png` |
| Rights status | `mechanics_only` |
| Authorization date | 2026-08-05 |
| Candidate features | `teeth_whitening`, `sclera_redness` |
| Candidate role | Positive-target mechanics candidate for each feature's independent experiment. |
| Asset status | Original only; feature-specific mask and after assets are not yet registered. |
| Permitted use | Local candidate input and derivative before/mask/after review for `teeth_whitening` and `sclera_redness`. |
| Product status | Candidate only; not an active renderer fixture and not a feature-gate or promotion decision. |

This candidate is kept under the ignored local review boundary so it does not
change the exact active renderer inventory or the closed production admission.
Its visible teeth and eye redness make it suitable for feature-specific review,
but polarity, masks, after images, and original-detail acceptance must still be
recorded independently for each feature.

The same original may seed two feature-specific candidate rows, but the rows do
not share masks, after images, judgments, or admission outcomes. Intake review
observed visible tooth yellowing and visible scleral redness. Embedded C2PA
provenance declares `trainedAlgorithmicMedia`, so this image is AI-generated and
may validate mechanics only. It contributes zero genuine-positive,
effectiveness, naturalness, or production-admission weight even after derivative
assets are added.

## Phase 59 Teeth Evidence Intake

| Fixture ID | Polarity | Local bundle path | Rights status | Asset status |
| --- | --- | --- | --- | --- |
| `teeth_fixture_001` | `positive` | `example-images/local-retouch-review/teeth-evidence-20260805/fixture_001/` | `approved_internal_evaluation` | `original/mask/after` present |
| `teeth_fixture_002` | `negative` | `example-images/local-retouch-review/teeth-evidence-20260805/fixture_002/` | `approved_internal_evaluation` | `original/mask/after` present |

The user supplied these two real portrait fixtures and confirmed authorization
for local internal evaluation and derivative review. The adaptive harness
generated the local mask/after assets; both fixtures are the same 1254×1254
format and the mechanics run reports zero changes outside the computed mask.
The first submitted Spike 006 review export failed the frozen Phase 54
predicate, so it is not canonical evidence. The canonical Phase 59 row remains
closed until a replacement Phase 54 review and independent decision are
recorded. Direct visual feedback additionally found the yellow-positive color
change too subtle despite acceptable mask containment; the shared transform
has now been recalibrated and the local after assets refreshed. The harness
passes 24/24 self-tests with zero outside-mask changes on both fixtures, but a
replacement Phase 54 review remains required. The local manifest and media
remain Git-ignored.

## Disabled Fixtures

`e1.png` through `e5.png` and `e6.jpg` are retained only under
`example-images/parked-portraits/`. They are not authorized as current inputs
and must be rejected by active fixture discovery. Historical documents may
refer to their prior mechanics/output evidence but do not reactivate them.
