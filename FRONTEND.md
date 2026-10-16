<!-- OWNER_HOST_COLOCATION_20261016 -->
> 2026-10-16 所有者明确要求将 BeautyEditorApp 移入本仓库并提交备份。
> 当前应用宿主只位于 `BeautyEditorApp/`，依赖同仓库 `BeautySDK/`；
> 下文历史“应用必须在仓库外”的位置限制由此取代。SDK target 仍禁止依赖应用、SwiftUI 或 UI 测试；
> 不恢复历史 UI，不改变效果资格或授权分发范围。

# FRONTEND.md

> SDK-only SwiftPM repository boundary, historical UI recovery and the separately
> authorized external owner host. Application work remains outside this repository.

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

## Authorization for external UI work

New application/UI scope requires a separately authorized project or milestone
with its own product, security, reliability, and test owners. Existing explicit
authorization below remains valid for that host and scope; routine continuation
within it does not require repeating authorization. An SDK-only task does not
implicitly include external application edits or native UI regression. Historical
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
coalesces a 960-pixel preview and initially added independent Vision overlays.
The 2026-10-09 follow-up replaces that host detection call with SDK-owned
`OwnerDiagnostics` SPI, using MediaPipe 478 on iOS and reporting the actual model
name. Re-detection remains independent of applied warp-control points. The actual
host's bounded native debug/continuous-nose/UI paths now pass on the authorized
generated input; old Vision-provider failures and the segmentation positive
remain distinct. Overlay visibility does not qualify all effects. Application
sources/UI tests remain external; SDK target/dependency boundaries are preserved.

The 2026-10-09 combination follow-up removes the host's old remaining-budget
slider clamp and routine quota messages. Sliders keep independent capped signed
snapshots and canonical aliases; the dense SDK map handles actual displacement
and gradient admission. Its debug panel counts active canonical edits instead
of presenting the old scalar sum as a capacity percentage. Undesigned categories
and the suspended tool remain visible but grey and disabled; direct model calls
are silent no-ops. Import/undo/confirm, actual missing-support errors and the
single safe-area owner remain unchanged. Application source and UI validation
stay in the already authorized external host.

## Current eye-tool scope (2026-10-14)

The owner's clarified [iris follow-up](plans/history/2026-10/A-2026-10-14-eye-iris-reference-delivery.md)
only optimizes the referenced `pupilSize` control. Eleven distinct reference
sliders remain selectable, with iris size using the established bidirectional
track. Lift, gaze correction, symmetry and sclera redness remain visible but
grey and disabled; their interactions cannot change selection, parameters or
history. Existing values/history are not cleared by this availability choice.
The SDK's fifteen eye fields/APIs remain callable, with caps and defaults
unchanged; host availability does not change SDK taxonomy. Upper-eyelid fullness remains
`suspended`, and closed EYE/SEG work stays closed.

C40's earlier appearance PASS was withdrawn after the owner rejected its iris
shape. The subsequent analytic radial remap reached the bounded C74 checks and
same-ID iPad installation recorded in the dated [iris history](plans/history/2026-10/A-2026-10-14-eye-iris-reference-delivery.md).
That history does not qualify the remaining negative-endpoint gray rim.

The owner explicitly reopened [gray-rim and physical-panel repair](plans/active/A-2026-10-15-iris-gray-panel-repair.md).
C75 now executes the original hosted Panel assertions on the selected iPad:
1 passed, 0 failed, 0 skipped; the active unique scene/key-window wait fixes
admission, and the three generated-input endpoint/neutral screenshots were
inspected. This validation-only installation retains the C74 SDK algorithm.
C77 captures the newly supplied full-resolution original and its preview with
2 passed native capture cases, 0 failed, 0 skipped; independent appearance review
still rejects the lower iris/lid contact line. Gray-rim qualification and final
updated delivery remain open. Existing source/reference oracles and failed
receipts remain unchanged. No full App regression or physical touch-quality
claim is made.
Application source, interaction evidence and native UI validation remain in the
external host's README/VALIDATION.
