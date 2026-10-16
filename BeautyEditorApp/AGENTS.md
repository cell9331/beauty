# BeautyEditorApp

This is the owner's separately authorized, local iPhone editor. The owner explicitly moved this host into `beauty/BeautyEditorApp`.
The sibling `../BeautySDK` package remains SDK-only: keep application sources and
UI dependencies inside this host; do not restore archived UI, publish artifacts,
or distribute SDK/model resources.

`README.md` owns the host product, architecture, input/privacy and recovery
contracts. `VALIDATION.md` owns test results and their platform limits.
The SDK's effect taxonomy remains authoritative for algorithm meanings.

Read the user's iOS safe-area, simulator reuse and build-storage guides before
related edits/tests. Reuse one compatible device, explicitly name its UDID,
disable parallel testing, and retain this checkout's `.build` caches.
Do not replace another task's device claim or install over an existing physical
App without stating the replacement relationship and preserving its data.

Use the actual PhotoRenderer output to verify pixels, EXIF direction, color,
alpha and export. Keep originals, Vision masks and landmarks in memory or
task-owned temporary inputs, never bundled or committed. Persist aggregate
receipts and small metadata-stripped UI previews only.

The chosen iOS 17.5 simulator has observed empty person-segmentation masks.
Do not turn failed mask admission into a successful toggle, lower its admission
threshold to bypass failures, delete failed positive-test records, or claim a
native positive-background pass from macOS results. Keep this limitation explicit.
