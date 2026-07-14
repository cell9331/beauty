---
phase: 16
slug: example-image-validation-harness
status: complete
created: 2026-06-26
---

# Phase 16 - Research: Example Image Validation Harness

## RESEARCH COMPLETE

Question: What is needed to plan Phase 16 well?

## Scope Answer

Phase 16 is a formalization and evidence phase for the already-prepared local example-image renderer path. It should prove that the `BeautyExampleRenderer` SwiftPM executable builds, loads the current portrait fixtures from `example-images/input/`, runs them through the public `BeautySDK` facade, and writes same-dimension, watermarked PNG outputs under ignored `example-images/out/`.

This phase should not add SwiftUI screens, new render cases, new fixture coverage, new output formats, or new beauty algorithms. Product code changes are appropriate only when build/run blockers prevent the documented renderer path from working.

## Inputs That Matter

- `.planning/phases/16-example-image-validation-harness/16-CONTEXT.md` locks the two-plan structure and the minimal evidence standard.
- `.planning/ROADMAP.md` assigns Phase 16 to `PREP-01` through `PREP-04` and lists planned slots `16-01` and `16-02`.
- `BeautySDK/Package.swift` declares `BeautyExampleRenderer` as an executable product depending only on `BeautySDK`.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` currently implements `--input`, `--output`, `--case`, built-in render cases, public facade processing, deterministic output names, PNG writing, and bottom watermark drawing.
- `docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md` owns the command contract, current case list, output rules, and geometry limitation.
- `.gitignore` ignores `example-images/out/`, so generated PNGs remain local validation outputs.
- `example-images/input/e1.png` through `e5.png` are the fixed Phase 16 input set.

## Current Implementation Findings

- The executable target imports `AppKit`, `CoreImage`, `Foundation`, `ImageIO`, and public `BeautySDK`; it does not import `BeautyCore`, `BeautyDetection`, `BeautyRender`, `BeautyEffects`, `BeautyResources`, or Demo SwiftUI code.
- The renderer accepts `--input`, `--output`, and `--case`; defaults are `example-images/input` and `example-images/out`.
- Built-in visible-output cases are limited to skin/color/filter domains: `skinSmoothing_0p50`, `skinWhitening_0p50`, `skinRosy_0p40`, `skinSharpen_0p40`, `brightness_plus0p25`, `contrast_plus0p25`, `filter_softClean_0p50`, `filter_warmLight_0p50`, and `skinCombo_0p50`.
- The representative case for Phase 16 evidence is `skinWhitening_0p50`.
- Output names use `{source}__{case}.png`, so the representative output is `example-images/out/e2__skinWhitening_0p50.png`.
- `BeautyEngine.processResult(image:metadata:parameters:)` is the facade call used by the renderer.
- The watermark currently uses the render case display name, for example `skinWhitening 0.50`.
- The current five fixture dimensions are: `e1.png` 1728 x 2304, `e2.png` 576 x 1024, `e3.png` 2160 x 3840, `e4.png` 1440 x 2560, and `e5.png` 1440 x 2560.

## Recommended Plan Shape

Create exactly two execution plans:

1. `16-01` - Verify the executable and local renderer output path.
   - Build `BeautyExampleRenderer`.
   - Run only the representative `skinWhitening_0p50` case unless a blocker requires a minimal fix.
   - Confirm `example-images/out/e2__skinWhitening_0p50.png` exists.
   - Run `file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png` and require both lines to report `576 x 1024`.
   - Record a short factual visual observation: output is non-empty, the watermark is readable, and the bottom watermark does not cover the face.

2. `16-02` - Close documentation and planning evidence.
   - Confirm `EXAMPLE_IMAGE_VALIDATION.md` still records build/run commands, output rules, built-in cases, and geometry limitation.
   - Mark `PREP-01` through `PREP-04` complete only after Phase 16 execution reruns the commands.
   - Keep generated PNG outputs out of `.planning/evidence/` and out of git.
   - Record the geometry limitation as integration-blocked by face detection plus geometry render image-output integration, leaving saved-output status to Phase 19.

## Validation Architecture

Phase 16 can be verified with SwiftPM and shell checks:

- Build command:
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build --package-path BeautySDK --product BeautyExampleRenderer`
- Representative run command:
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift run --package-path BeautySDK BeautyExampleRenderer --input example-images/input --output example-images/out --case skinWhitening_0p50`
- Dimension proof command:
  `file example-images/input/e2.png example-images/out/e2__skinWhitening_0p50.png`
- Facade-only import scan:
  `! rg -n "import Beauty(Core|Detection|Render|Effects|Resources)|import SwiftUI|import UIKit" BeautySDK/Sources/BeautyExampleRenderer`
- Ignored-output check:
  `git check-ignore example-images/out/e2__skinWhitening_0p50.png`
- Documentation scan:
  `rg -n "skinWhitening_0p50|e2__skinWhitening_0p50.png|example-images/out|Geometry Limitation|swift build --package-path BeautySDK --product BeautyExampleRenderer" docs/meitu-function-blueprint/EXAMPLE_IMAGE_VALIDATION.md`

The phase blocks on build failure, renderer run failure, missing representative output, missing ignored-output behavior, or dimension mismatch.

## Pattern Notes

- Treat `BeautyExampleRenderer` like a host app smoke harness: it must enter through the public facade and must not reach into internal targets.
- Keep output evidence textual and command-based. The ignored PNGs are local artifacts, not repository evidence files.
- Do not over-claim visual quality. Phase 16 may record that the watermark is readable and does not cover the face; it should not claim production naturalness or full geometry visual completion.
- If execution discovers a build blocker, fix only the smallest packaging or renderer issue needed to restore the documented path, then record the deviation in the plan summary.
- Later phases that add visible module outputs should extend the same command/document path and update `EXAMPLE_IMAGE_VALIDATION.md`.

## Risks and Mitigations

- Risk: The plan expands into new renderer capabilities. Mitigation: plan tasks explicitly ban new cases, fixtures, formats, and algorithms unless fixing a blocker.
- Risk: Generated PNGs become committed evidence. Mitigation: verify `.gitignore` / `git check-ignore` and keep evidence in summaries as command output and metadata.
- Risk: Geometry-heavy branches are accidentally marked visually complete. Mitigation: repeat the current limitation and defer saved-output proof to Phase 19.
- Risk: Prior `PLANS.md` evidence is treated as enough. Mitigation: require Phase 16 execution to rerun build, run, and `file` commands.
- Risk: Renderer stops being facade-only. Mitigation: include an import scan over `BeautySDK/Sources/BeautyExampleRenderer`.

## Research Gaps

No blocker. Exact wording in summaries and planning ledgers can be chosen during execution as long as the command evidence, requirement traceability, and geometry limitation remain intact.
