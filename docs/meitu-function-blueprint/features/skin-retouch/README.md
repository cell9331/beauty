# Skin Retouch Function Family

## Business Role

Skin retouch covers base beauty adjustments and localized repair-style functions.

## Technical Core

- SDK owner: `BeautyEffects` color/skin pipeline.
- Render owner: Core Image/Metal pass chain.
- Public parameters: current skin smoothing, whitening, rosy, sharpen; future repair parameters need design.

## Branch Contracts

| Branch | Status | Primary owner | Current public `BeautyParameters` coverage | Future parameter needs | Evidence expectation |
| --- | --- | --- | --- | --- | --- |
| Basic skin | implemented | `BeautyEffects` | `skinSmoothing`, `skinWhitening`, `skinRosy`, `skinSharpen` | None for current basic skin branch. | XCTest coverage plus `BeautyExampleRenderer` saved-image cases. |
| Skin repair | future | `BeautyEffects` | None | Blemish, pore, texture, and local repair controls need design updates if promoted. | No v1.3 completion evidence until promoted. |
| Teeth/hairline | future | `BeautyEffects` | None | Teeth whitening and hairline controls need landmark/segmentation/resource design if promoted. | No v1.3 completion evidence until promoted. |

## Boundary

No cloud repair or AI upload by default.
Skin retouch does not own Home/discovery, resource/style systems, AI/background, video/body, gallery/account, search, VIP, payment, or entitlement behavior.
