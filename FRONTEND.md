# FRONTEND.md

> Historical application/UI boundary and archive redirect. The active repository is
> SDK-only and uses SwiftPM plus SDK-owned command-line validation.

## Current Contract

The repository has no active frontend, application target, UI source, UI tests,
application navigation, camera permission flow, or visual acceptance surface.
Only applications/tools controlled by the project owner may host the SDK; they
own their UI and protected-resource lifecycle. SDK targets must remain free of
application pages and interaction state. No third-party Demo, customer UI,
App Store delivery, or distribution surface is planned.

Current algorithm/control meanings are owned by
`docs/SDK_EFFECT_TAXONOMY.md`. Visual placement, labels, navigation, sliders,
badges, account state, and historical reference-product behavior do not establish
SDK support.

## Historical Material

The exact former Demo and legacy UI-reference trees are preserved as verified
artifacts under `archives/legacy-ui/`. Read `archives/legacy-ui/README.md` before
accessing them.

- `archives/legacy-ui/BeautyDemo-v1.16.zip` preserves 45 intentional files.
- `archives/legacy-ui/meituxiuxiu-v1.16.zip` preserves 26 intentional files.
- Each ZIP has a sorted path/size/content-hash manifest and a ZIP SHA-256 record.

Historical material is review-only. Restore it into a new temporary directory,
never over the active repository, and rerun:

```bash
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
bash scripts/check-sdk-only-boundary.sh --post-archive
```

Reintroducing either retired source root, any application project artifact, UI
framework source, or UI-test dependency violates the SDK-only boundary.

## Future UI Work

Any future application/UI work requires a separately authorized project or
milestone with its own product, security, reliability, and test owners. Historical
archives are not an active implementation template or acceptance contract.

## Separately authorized owner host (2026-10-08)

The owner explicitly requested a new iOS photo editor from Figma file
`l4srrGA4qSkYGT09nuAxXz`. Its new SwiftUI application and UI tests live outside
this repository in the adjacent `BeautyEditorApp` project. No archived UI was
restored. The host's `README.md` owns its product, architecture, privacy/input
and recovery contracts; `VALIDATION.md` owns native UI and pixel verification.

The host connects six designed categories to the existing SDK, with import,
undo/redo, comparison, confirmation and original-size PNG export. Undesigned
categories and suspended upper-eyelid reduction remain explicitly unavailable.
Simulator person segmentation did not qualify its positive background-protection
case; its failed admission remains visible and cannot be counted as a pass.
This authorization creates no frontend target, UI acceptance gate, algorithm
promotion or distribution commitment in the SDK repository. See the
[owner-host record](plans/history/2026-10/A-2026-10-08-owner-ios-editor.md).

The subsequent [owner-host repair](plans/history/2026-10/A-2026-10-08-owner-editor-debug.md)
maps sliders to admitted per-field caps, reserves previous geometry values,
coalesces a 960-pixel preview and adds in-memory source/output Vision debug
overlays. Re-detection is explicitly independent of SDK warp control points.
Sustained simulator inference and the previous segmentation positive remain
failed; neither overlay visibility nor changed pixels qualify all effects.
SDK source and target boundaries are unchanged by this host repair.
