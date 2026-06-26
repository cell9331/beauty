# Skin Branch: Basic Skin

## Business Logic

Basic skin provides smoothing, whitening, rosy, and sharpen controls with natural-looking limits.

## Technical Core

- Current SDK supports MVP output.
- Requires face-aware or full-frame tuning depending on input and detection availability.
- Verification should include no-face behavior and conservative caps.
- Status: `implemented`.
- Primary owner: `BeautyEffects`.
- Dependencies: `BeautyRender` color/skin path and public `BeautySDK` facade.
- Current public `BeautyParameters` coverage: `skinSmoothing`, `skinWhitening`, `skinRosy`, and `skinSharpen`.
- Future parameter needs: none for the current basic skin branch.
- Evidence expectation: XCTest coverage plus `BeautyExampleRenderer` saved-image cases.

## Boundary

Do not add aggressive commercial-grade retouch claims without visual QA.
