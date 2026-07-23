# Phase 47 Pattern Map

**Mapped:** 2026-07-23

## Closest Analogs

| Phase 47 responsibility | Closest repository analog | Reuse guidance |
|---|---|---|
| Four isolated renderer cases | Phase 43 `main.swift` eye additions | Preserve ordered inventory, one scalar per case, `BeautySDK`-only import, and one facade call. |
| Source/no-face contract tests | Phase 43 `BeautyRendererOutputRegressionTests` | Extend exact IDs and table-driven no-face assertions; keep raw terms forbidden. |
| Missing/malformed public route | Phase 46 `BeautyEngineGeometryFacadeTests` plus `BeautyEngineTestingSupport` | Add aggregate enum fixtures only and traverse the production mapper/adapter. |
| Strict bounded helper | Phase 43 `check_eye_geometry_renderer_outputs.py` | Copy descriptor acquisition, decoder, inventory, self-test, measurement/strict modes; replace eye families only. |
| Face-local comparisons | Phase 39/36 strict mouth/nose helpers plus Phase 28 face helper | Use fixed normalized regions and direct semantic comparators; retain newer Phase 43 decoder hardening. |
| Gallery publication | current `example-images/generate_gallery.py` | Add four IDs to `face-shape`; preserve exact set equality and descriptor-safe publication. |
| Evidence/docs | Phase 43 evidence and `EXAMPLE_IMAGE_VALIDATION.md` | Record aggregate counts/minima/nonclaims without early promotion. |

## File-to-Analog Map

### `BeautySDK/Sources/BeautyExampleRenderer/main.swift`

- Insert four cases adjacent to existing face-shape cases.
- IDs: `faceContourSmooth_0p25`, `templeFullness_0p25`,
  `cheekboneSlim_0p25`, `chinTaper_0p25`.
- Do not change any existing ID, case value, import, fixture loop, output naming,
  or processing call.

### `BeautyRendererOutputRegressionTests.swift`

- Extend `expectedRendererCaseIDs` from 55 to 59.
- Add an exact four-case/one-field contract modeled after
  `testPhase43EYE16EyeCasesUseExactlyOneNewPublicEyeParameter`.
- Add four no-face requests modeled after the Phase 43 no-face table.
- Keep expected existing case counts/tests updated atomically.

### `BeautyEngineTestingSupport.swift`

- Extend the testing-only fixture enum with missing and malformed observed
  contour scenarios.
- Return a usable observation with complete shipped landmarks so shipped
  sibling geometry remains eligible.
- Keep support payload constants private and diagnostics aggregate.

### `BeautyEngineGeometryFacadeTests.swift`

- Request one new field plus a shipped `faceSlim` sibling.
- Verify one detection call, extent preservation, `.faceShape` active from the
  sibling, new field zero, aggregate-only metrics/warnings, and no raw terms.
- Use both missing and malformed testing fixture cases.

### `check_face_geometry_renderer_outputs.py`

- Start from the Phase 43 helper as the decoder/security baseline.
- Retain CLI, descriptor checks, exact matrix, PNG/JPEG decode, cache, and
  adversarial self-tests.
- Replace eye IDs/ROIs/families with four face cases, fixed face regions,
  fixed neighbor comparisons, eligibility partitions, and four no-face no-ops.
- Require 59 cases, seven fixtures, 413 outputs.

### `example-images/generate_gallery.py`

- Append exactly four IDs to `CASE_GROUPS["face-shape"]`.
- Do not alter path validation, publication, staging, quarantine, file budgets,
  or renderer set equality.

## Dependency Direction

```text
public scalar RenderCase
  → BeautyEngine.processResult
  → existing detector / mapper / resolver / unified geometry pipeline
  → ignored flat PNG
  → bounded Phase 47 helper
  → aggregate evidence
  → descriptor-safe ignored gallery
```

The helper and gallery never call SDK internals. Testing SPI can select
aggregate detector scenarios but does not expose geometry carriers publicly.

## Fixed Invariants

1. 55 existing cases remain byte-identical at the source-contract level.
2. Four new cases contain exactly one matching public scalar at `0.25`.
3. Live and frozen inventories agree on 59 cases, seven fixtures, and 413
   output/gallery files.
4. Strict regions are normalized, watermark-safe, and fixed before acceptance.
5. All comparators are declared constants; no strongest-match selection.
6. Missing/malformed support removes dependent new work while shipped sibling
   work continues.
7. Generated output stays ignored, untracked, unstaged, and outside commits.
8. SAFE-* and DOC-01 remain Phase 48.

## Review Hotspots

- Descriptor reads and decompression budgets after helper adaptation.
- Row-coordinate convention when defining upper/mid/lower face regions.
- Dynamic threshold/eligibility leakage into strict mode.
- Whole-image differences accidentally satisfying locality.
- Renderer count updates that omit gallery or test inventory.
- Testing fixture payload accidentally becoming public/debuggable.
- Phase 47 docs implying final caps, naturalness, promotion, or readiness.
