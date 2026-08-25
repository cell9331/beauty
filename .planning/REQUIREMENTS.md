# Requirements: Beauty v1.21 Provisional Upper-Eyelid Public Activation

**Defined:** 2026-08-25

**Core Value:** The project owner's local host can keep and publicly call the
existing `去脂` API while the SDK preserves bounded, deterministic, fail-closed
still-image behavior.

**Owner Acceptance:** The owner directs the milestone to treat manual checks as
accepted and explicitly states that the current visual result is not very good
and should be optimized later. This is recorded as an owner-provided decision;
no new blinded review transcript or result is fabricated.

## v1 Requirements

- [x] **API-01**: `BeautyParameters` exposes trailing positive-only
  `upperEyelidFullnessReduction`, defaults/missing/non-finite values to zero,
  clamps finite values to `0...1`, round-trips with Codable, and admits positive
  local-retouch intent without changing presets or other parameters.
- [x] **OUT-01**: Both public still-image facade entries route positive intent
  through the existing one-request per-eye semantic relief editor and
  immutable-source composer, with actual deterministic pixel change when
  supported and source-exact neutral/no-face/rejected behavior otherwise.
- [x] **ACCEPT-01**: Current taxonomy and owner contracts mark `去脂` implemented
  for owner-local opaque still-image use with a provisional weak-quality caveat,
  retain internal experimental provenance, and preserve the historical
  v1.18/v1.19 non-promotion evidence.
- [x] **CLOSE-01**: Public/static inventories reconcile at 62 fields, five
  presets, and 75 renderer cases; focused tests, archive verification, SDK-only
  boundary, historical v1.18 binding, full SwiftPM, and no-skip closeout pass
  without adding UI, model, network, device, or distribution scope.

## Future Requirements

- **FUTURE-01**: Improve visual strength/naturalness behind the existing public
  contract using a separately authorized milestone and new automated/product
  evidence; do not silently remove or rename the field.
- **FUTURE-02**: Any learned replacement requires actual-use-compatible data,
  model/resource/license/security/privacy review and must remain owner-local.
- **FUTURE-03**: Realtime/pixel-buffer, transparent/HDR/video, device,
  population, commercial quality, packaging, shipping, launch, release, and
  external distribution remain separately scoped or prohibited.

## Out of Scope

| Feature | Reason |
| --- | --- |
| New `去脂` algorithm or threshold retuning | The owner requested the existing implementation remain unchanged apart from public routing. |
| New manual/blinded review evidence | Acceptance is the owner's explicit decision; no review run is fabricated. |
| Training/model/weights/downloads | The current public route is the retained source-derived no-model v4 path. |
| UI/Demo or realtime activation | The active product surface is SDK-only opaque still images. |
| External/device/commercial/release claims | SwiftPM and owner acceptance do not establish these claims. |

## Traceability

| Requirement | Phase | Status |
| --- | --- | --- |
| API-01 | Phase 88 | Complete |
| OUT-01 | Phase 88 | Complete |
| ACCEPT-01 | Phase 88 | Complete |
| CLOSE-01 | Phase 88 | Complete |

**Coverage:** 4 total, 4 mapped, 4 complete, 0 unmapped.

---
*Last updated: 2026-08-25 for v1.21 closeout*
