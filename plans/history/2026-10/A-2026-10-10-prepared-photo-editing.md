# A-2026-10-10-prepared-photo-editing

Status: `completed`. Branch: `codex/playbook-sdk-refactor`.

## Request and interpretation

Owner asked to apply the playbook's continuous-frame processing ideas to the
SDK and update the existing editor Demo. Owner explicitly confirmed on
2026-10-10: borrow video-processing ideas to optimize the existing photo SDK and
editor. This plan adds no video importer/camera UI or temporal tracking.
Application edits stay in the separate authorized BeautyEditorApp.

## Research

The host already serializes one running render plus one replaceable newest
snapshot. Every preview starts from the same immutable 960-pixel source, but the
SDK detects that unchanged source again for each geometry/texture/local request.
Fixed contexts and native detector tasks are already reused. The useful next
optimization is explicit source preparation and bounded detection reuse, not
reusing edited pixels or guessing support across changing video frames.

## Plan review and corrections before implementation

1. CIImage graphs and CVPixelBuffer backing can change: accept only an explicitly
   prepared CGImage with a deep byte snapshot; RGB8 admission and checked row/
   total-byte bounds preserve color/alpha/bitmap semantics. Ordinary APIs remain
   unchanged and detect afresh.
2. Caller-provided photo IDs alone are insufficient SDK identity: opaque tokens
   bind to one engine-owned active source. Replacement/reset invalidates tokens
   and releases retained pixels/observations. Failed prepare preserves the prior
   valid source. Never use a global/key-growing image cache.
3. Detection purpose changes selection and validity: cache separately by
   geometry/local/combined purpose and original/canonical raster. Keep the same
   purpose and routing as a fresh call; do not upgrade partial observations.
4. Transient inference failures must recover: cache only usable/no-face outcomes;
   skipped/low-confidence/partial outcomes retry and cannot borrow earlier support.
5. Local composition, masks and source-dependent geometry remain per-render,
   starting from the prepared original. No retained masks/retouch units, reordered
   stages, accumulated warp or relaxed admission.
6. Preview identity/engine/backend changes invalidate host tokens. Original-size
   exports use the ordinary fresh route, preventing preview support from being
   applied at another raster size. Keep existing CPU fallback and revision guards.
7. Opaque token/state reflection stays aggregate; session state is memory-only.
   This explicit source-bound exception must replace incompatible no-cache claims
   in current owners. No landmark/byte/path evidence or new effect qualification.
8. Verification is scoped: new SDK lifecycle/purpose/independent pixel parity,
   failure/reset/metadata/alpha/mask regressions, existing direct facade/local
   integration paths, and native host preview/export/session tests on the existing
   iPhone 15 Pro iOS17.5. No all-feature/all-device/full SDK regression or fps claim.

## Execution

- [x] Research current source and host; review and correct plan before code.
- [x] Implement explicit prepared source API and bounded purpose-aware reuse.
- [x] Verify SDK output against fresh calls, failure/reset and immutable source.
- [x] Integrate the existing editor preview; retain fresh full-size export.
- [x] Verify real native model reuse, changing snapshots, replacement/export and
      asynchronous preview guards on one existing device.
- [x] Update current contract owners and record actual results/limits.

## Verification completed while waiting for the native device

- SDK: 63 direct tests passed, then the final 9-case new suite passed including
  actual Metal. Deduplicated coverage is **65 / 0 failures / 0 skips**.
  Covers lazy detection, changed parameter snapshots, exact fresh-path pixels,
  positive geometry, no accumulation, mask isolation, all eight EXIF directions,
  input/preview mirror, P3/alpha, deep-copy mutable backing, neutral/disabled,
  wrong/expired tokens, failed prepare, reset/release, retry and purpose/raster
  isolation. Ordinary encoded/local/cadence regressions also passed.
- External editor build-for-testing succeeds on stable `.build`; it does not
  install/run on the currently claimed simulator.
- macOS exact production PhotoRenderer `--verify-controls` passes: six nose tools
  ×four nonzero steps, CPU/Metal max channel delta<=1, exact repeats, previous
  field preservation, debug pixel-inert, alpha CPU fallback, neutral and original
  size sRGB PNG round trip/no GPS. It is a macOS result, not native iOS evidence.
- Both archives, SDK-only boundary live/self-test, image storage, existing 51
  bindings/60 assets and scoped 207 current local links passed; git diff whitespace valid.
- Only two existing SDK Swift files changed from the turn's source hash baseline;
  251 existing source/test files unchanged, including model/shader and prior
  uncommitted work. One new source and one new test file added.
- Early failures retained separately: sandbox Swift/Clang cache denial; inaccessible
  package-internal result initializer corrected to retaining the returned value;
  compilation rejected a test file changed during the build; initial partial
  fixture constructed usable support (3 assertions failed), corrected by explicit
  rejected-face evidence; host new test used `[UInt8]` instead of its `Data` pixel
  helper, corrected. Mask fixture corrected to existing binary255 before execution.
  No production admission, failure policy or pixel oracle was weakened.
- Native device waiting: queued for the existing iPhone15Pro/iOS17.5 while AIVideo
  held its claim. It released the device before the queue deadline; Beauty claimed
  it at 02:26:40 UTC, ran only the selected cases and released it at 02:27:13 UTC.
  No claim overwrite, alternate device, clone or shutdown performed.

## Final native verification

`build-for-testing` used the stable external host `.build`, selected UDID
`2CE927C9-9303-4A9B-9C03-F28C42045186`, disabled parallel testing and enabled
`BEAUTY_OWNER_PORTRAIT_CHECK`. With the same unchanged source/test binary,
`test-without-building` ran **13 / 0 failures / 0 skips**: nine photo-pipeline,
three asynchronous editor-session and one actual UI case. The result bundle is
`BeautyEditorApp/.verification/prepared-editing-20261010.xcresult`; its independently
parsed summary confirms all 13, one device, iOS17.5 and no expected failures.
The host's aggregate receipt is `.verification/prepared-editing-native.json`.

- Actual MediaPipe used one 478-point face for four changed/repeated nose-wing
  snapshots. First detection reported reuse0; the following three reported1.
  Every output exactly matched an independent fresh production engine, the
  positive edit changed pixels, and returning to the first value exactly restored
  its output. Replacing the photo restarted reuse0 and matched the original result.
- No-face preview reuse, original-size fresh export and preview-after-export passed.
  EXIF/P3/alpha, actual tone, neutral/no-face/recovery, full-range independent
  combination and independent pixel-inert debug detection passed.
- One-running/newest-request and stale-publication guards passed. Actual native
  clicks/sliders verified 478-point debug revision matching, nose adjustment,
  previous value retention and debug toggling.
- Initial xcresult parsing needed sandbox escalation for its internal SQLite
  database; it was not a native test failure. No failing native case or skip.

Current contract owners, source-only integration guide and external README/
VALIDATION now describe the explicit source-bound cache and ordinary fresh routes.
Final scoped navigation check passes **226 local links / 0 missing**, host added
lines and Git diff have no whitespace errors, and the source hash baseline still
confirms 251 existing SDK source/test/resource files unchanged.
After the last native use, the one task-owned temporary input copy was removed
(1,864,563 bytes); the authorized shared original, stable build, result bundle,
aggregate receipts and useful diagnostic logs remain available.
Only scoped SDK/host cases ran. No video UI, temporal tracking, new beauty effect,
grey-button unlock, full SDK/App regression, physical-device installation or
throughput/thermal/energy claim. Existing algorithm qualification and prior
uncommitted work are preserved.
