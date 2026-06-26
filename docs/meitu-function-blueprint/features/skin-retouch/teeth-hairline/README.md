# Skin Branch: Teeth And Hairline

## Business Logic

Teeth whitening and hairline adjustment are adjacent localized retouch functions.

## Technical Core

- Teeth whitening needs mouth/teeth region segmentation or reliable landmarks.
- Hairline needs forehead/hair segmentation and should avoid visible artifacts.
- Status: `future`.
- Primary owner: `BeautyEffects` if promoted.
- Dependencies: future landmark/segmentation confidence model and optional resources only after design approval.
- Current public `BeautyParameters` coverage: none.
- Future parameter needs: teeth whitening and hairline controls.
- Evidence expectation: no v1.3 completion evidence until explicitly promoted.

## Boundary

Do not infer identity, persist biometric masks, or expose region masks publicly.
