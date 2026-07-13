# Phase 31 Shared Contract Scan

**Scanned:** 2026-07-13 before planning
**Status:** Complete

## Recorded Counts

| Scan | Matches |
| --- | ---: |
| Four nose field references under `BeautySDK` Swift source/tests | 159 |
| Safety cap/resolver/provider/conflict-resolver signature references | 263 |
| Sign/`abs` focused matches | 4 |
| `NoseWarpProvider` production/test call sites | 10 |
| Renderer/helper/gallery/legacy-count consumers | 94 |
| Current-owner blueprint/root/planning nose consumers | 400 |

Counts were recorded from full `rg` outputs before `PLAN.md` creation; generated `.build`, output, and gallery trees were excluded.

## Public Parameter Contract

- `BeautyParameters` declares exactly `noseSlim`, `noseWingSlim`, `noseTipSize`, and `noseBridge` for the nose domain.
- Initialization normalizes `noseSlim`, `noseWingSlim`, and `noseBridge` with `clampUnit`; `noseTipSize` uses `clampSigned`.
- `BeautySafetyCaps` already declares exact caps `0.35`, `0.35`, `0.30`, and `0.30`.
- `BeautyEffectResolver` uses `capUnit` for the three positive-only fields and `capSigned` for `noseTipSize`.

## Provider and Conflict Signatures

- Production provider calls exist in `BeautyGeometryEffectPipeline` and `BeautyEffectResolver`.
- Test calls are concentrated in `NoseWarpProviderTests`; geometry conflict and combined safety tests cover all four strength fields.
- `GeometryConflictResolver` weakens all four fields and uses `abs(noseTipSize)` only for magnitude calculations, which is compatible with preserving the signed value.
- Real defect found: `NoseWarpProvider.makeControlPoints` passes `abs(strengths.noseTipSize)` into `tipPoints`, folding positive and negative output directions. Planning must fix this source behavior and add direction-sensitive tests.

## Renderer and Helper Consumers

- `BeautyExampleRenderer/main.swift` currently owns 23 cases.
- `BeautyRendererOutputRegressionTests.expectedRendererCaseIDs` owns the exact inventory and must become 28 cases.
- `check_eye_renderer_outputs.py` remains an eye-specific 161/161 and 36/36 owner; it must not be rewritten to pretend nose evidence.
- `example-images/generate_gallery.py` owns gallery mappings and currently has no `nose` group.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `QUALITY_SCORE.md`, planning evidence, and historical `PLANS.md` contain current or historical 23/161/36 counts. Historical records remain unchanged; current-owner wording must become 28/196 while retaining the eye helper's factual 36/36 scope.

## Blueprint and Status Consumers

Current-owner scan includes `SHAPE_FEATURE_LEDGER.md`, `FEATURE_MATRIX.md`, the parent beauty-shaping README, the nose README, `EXAMPLE_IMAGE_VALIDATION.md`, root contracts, `QUALITY_SCORE.md`, and live planning owners. Phase 31 may document output evidence but must not promote nose rows; Phase 32 owns the exact four-row atomic promotion.

## Planning Consequences

1. Fix provider sign preservation early enough for renderer evidence to distinguish both directions.
2. Add exact renderer cases and inventory/single-field tests.
3. Add a dedicated helper with immutable 196/196, 30/30, signed-difference, and no-face gates.
4. Add ignored nose gallery routing and containment evidence.
5. Update only current output-evidence owners in Phase 31; defer ledger/root closeout to Phase 32.
