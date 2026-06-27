# Skin Branch: Basic Skin

## Business Logic

Basic skin provides smoothing, whitening, rosy, and sharpen controls with natural-looking limits.

## Technical Core

- Current SDK supports MVP output.
- Public facade and renderer paths may apply lightweight full-frame skin-tone tuning when detection has not run or no facade-visible face geometry is available.
- Explicit internal no-face resolver contexts may skip face-dependent skin for future detection-integrated flows.
- Verification should include no-face behavior and conservative caps.
- Status: `implemented`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyRender` color/skin path and public `BeautySDK` facade.
- Current public `BeautyParameters` coverage: `skinSmoothing`, `skinWhitening`, `skinRosy`, and `skinSharpen`.
- Future parameter needs: none for the current basic skin branch.
- Evidence expectation: XCTest coverage plus `BeautyExampleRenderer` saved-image cases.

## Boundary

Do not add release-quality retouch claims without dedicated visual QA.
