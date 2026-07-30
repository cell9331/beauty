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
| Rights record ID | `user_authorization_20260730_001` |
| Authorization date | 2026-07-30 |
| Source assertion | User supplied the real portrait and explicitly confirmed ownership of all required copyright, portrait/likeness, and related permissions. |
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

## Disabled Fixtures

`e1.png` through `e5.png` and `e6.jpg` are retained only under
`example-images/parked-portraits/`. They are not authorized as current inputs
and must be rejected by active fixture discovery. Historical documents may
refer to their prior mechanics/output evidence but do not reactivate them.
