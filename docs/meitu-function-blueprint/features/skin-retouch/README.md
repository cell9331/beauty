# Skin Retouch Function Family

## Business Role

Skin retouch covers base beauty adjustments and localized repair-style functions.

## Technical Core

- SDK owner: `BeautyEffects` color/skin pipeline.
- Render owner: Core Image/Metal pass chain.
- Public parameters: current skin smoothing, whitening, rosy, sharpen, plus bounded still-image `teethWhitening`; future repair and hairline parameters need design.

## Branch Contracts

| Branch | Status | Primary owner | Current public `BeautyParameters` coverage | Future parameter needs | Evidence expectation |
| --- | --- | --- | --- | --- | --- |
| Basic skin | implemented | `BeautyEffects` | `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen` | None for current basic skin branch. | XCTest coverage plus `BeautyExampleRenderer` saved-image cases. |
| Skin repair | future | `BeautyEffects` | None | Blemish, pore, texture, and local repair controls need design updates if promoted. | No v1.3 completion evidence until promoted. |
| Teeth | implemented | `BeautyEffects` with product ownership under `Beauty shaping / 嘴唇` | Bounded opaque still-image `teethWhitening` through the public facade | Broader semantic coverage, Demo/realtime/device/commercial scope require separate evidence. | Phases 59-61 plus Phase 65 combined closeout and post-archive adversarial remediation. |
| Hairline | future | `BeautyEffects` if promoted | None | Hairline needs approved local segmentation/resource design and reproducible fixtures. | No completion evidence until explicitly promoted. |

## Boundary

No cloud repair or AI upload by default.
Skin retouch does not own Home/discovery, resource/style systems, AI/background, video/body, gallery/account, search, VIP, payment, or entitlement behavior.
