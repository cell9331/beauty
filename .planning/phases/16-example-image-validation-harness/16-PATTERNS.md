# Phase 16 - Pattern Map

**Mapped:** 2026-06-26
**Scope:** Formalize the local example-image validation harness and planning evidence for v1.3 preparation.

## Source Inputs

- `.planning/phases/16-example-image-validation-harness/16-CONTEXT.md`
- `.planning/phases/16-example-image-validation-harness/16-RESEARCH.md`
- `.planning/REQUIREMENTS.md`
- `.planning/ROADMAP.md`
- `.planning/STATE.md`
- `PLANS.md`
- `BeautySDK/Package.swift`
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift`
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`
- `docs/meitu-function-blueprint/MODULES.md`
- `docs/meitu-function-blueprint/DELIVERY_BOUNDARY.md`
- `.gitignore`
- `example-images/input/e1.png` through `e5.png`

## Implementation Pattern Map

| New / Changed Area | Closest Existing Analog | Pattern to Preserve |
| --- | --- | --- |
| SwiftPM executable validation | `BeautySDK/Package.swift` executable product declaration | Use `swift build --package-path BeautySDK --product BeautyExampleRenderer`; keep the executable dependent only on public `BeautySDK`. |
| Facade-only renderer path | `BeautySDK/Sources/BeautyExampleRenderer/main.swift` and `BeautyEngine.processResult(image:metadata:parameters:)` | Treat the renderer like a host integration harness: no imports of internal SDK targets and no Demo SwiftUI state. |
| Local image output | `.gitignore` and `example-images/out/` | Generated PNGs are local, ignored, and overwriteable; do not move them into `.planning/evidence/`. |
| Dimension proof | Existing shell verification style in prior phase validation docs | Use `file input output` and require exact same dimensions for the representative `e2` case. |
| Documentation closeout | `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` | Keep commands, cases, output rules, and geometry limitation in one authoritative document. |
| Requirement closeout | Prior GSD phase summaries and root `PLANS.md` completed entries | Mark `PREP-*` complete only from freshly rerun Phase 16 command evidence. |

## Planned File Ownership

| Plan | Primary Files / Artifacts | Notes |
| --- | --- | --- |
| `16-01` | `BeautySDK/Package.swift`, `BeautySDK/Sources/BeautyExampleRenderer/main.swift`, `example-images/input/`, `example-images/out/`, `.gitignore` | Verification-first plan. Product code changes only for direct build/run blockers. |
| `16-02` | `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `PLANS.md` | Documentation and ledger closeout after 16-01 command evidence exists. |

## Landmines

- Do not add SwiftUI screens or Demo UI behavior in Phase 16.
- Do not add new built-in renderer cases, new fixtures, timestamped output directories, or alternate output formats.
- Do not commit generated files from `example-images/out/`.
- Do not claim saved-image geometry output is complete for face shape, eyes, nose, mouth, eyebrows, proportion, or 3D sculpt.
- Do not count prior `PLANS.md` evidence as Phase 16 completion; execution must rerun commands.
- Do not expose internal SDK target imports or raw face geometry through the renderer.
- Do not make subjective beauty-quality or production-naturalness claims from the representative output.

## Verification Hooks

- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer`
- `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50`
- `file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png`
- `git check-ignore example-images/out/e2__skinWhitening_0p50.png`
- `! rg -n "import Beauty(Core|Detection|Render|Effects|Resources)|import SwiftUI|import UIKit" BeautySDK/Sources/BeautyExampleRenderer`
