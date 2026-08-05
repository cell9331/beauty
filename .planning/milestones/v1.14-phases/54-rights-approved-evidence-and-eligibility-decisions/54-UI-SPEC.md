---
phase: 54
slug: rights-approved-evidence-and-eligibility-decisions
status: approved
shadcn_initialized: false
preset: none
created: 2026-07-31
---

# Phase 54 — UI Design Contract

> Visual and interaction contract for the phase-owned, static, browser-local
> evidence reviewer. This is an internal evaluation tool, not BeautyDemo or
> SDK product UI.

---

## Scope and Sources

This contract implements the frozen review decisions in `54-CONTEXT.md`
(D-01 through D-16), especially browser-local operation (D-07), the durable
export allowlist (D-08), and independent feature gates (D-09 through D-16).
It also preserves `SECURITY.md`'s local-only portrait-data boundary,
`PRODUCT_SENSE.md`'s honest evidence language, and `FRONTEND.md`'s accessible,
explicit error-state conventions without adding any SwiftUI or Demo surface.

The existing Spike 006 `review.html` is the interaction reference, not the
Phase 54 contract. Phase 54 must correct the spike's persistence shape:
timestamps, event history, dataset identifiers, raw exception messages, and
path-bearing error copy are forbidden in the durable export.

### In Scope

- One static HTML/CSS/JavaScript page opened directly from the repository.
- Browser File API selection of one JSON manifest and one local asset directory.
- Fail-closed manifest, asset, and decoded-image validation.
- A blinded original/mask/after reviewer at fit and 100% detail.
- Fixed structured judgments, deterministic progress, and independent
  teeth/sclera/upper-eyelid gate status.
- One deterministic, privacy-minimized JSON download.

### Out of Scope

- BeautyDemo, SwiftUI, UIKit, SDK parameters, production render paths, presets,
  realtime/pixel-buffer behavior, or any consumer-facing controls.
- Servers, uploads, network requests, analytics, telemetry, service workers,
  external fonts, external libraries, registries, or package installation.
- Login, reviewer accounts, collaboration, inter-rater workflows, persistent
  drafts, freeform notes, fixture acquisition, or media authoring.
- Product styling, brand work, animation, charts, thumbnails outside the active
  blinded item, or promotional readiness language.

## Design System

Repository scouting found no `components.json`, Tailwind, PostCSS, React, Vite,
or reusable web component system. The relevant local tool is plain static
HTML/CSS/JavaScript, so the shadcn initialization gate is not applicable.

| Property | Value |
|----------|-------|
| Tool | none; repository-local HTML/CSS/JavaScript only |
| Preset | not applicable |
| Component library | none |
| Icon library | none; use visible text labels and native form affordances |
| Font | `-apple-system, BlinkMacSystemFont, "SF Pro Text", "Segoe UI", sans-serif` |
| Motion | none required; state changes are immediate |

No component or token from BeautyDemo is imported. This reviewer remains a
phase-owned local tool and does not establish a reusable product design system.

## Spacing Scale

All layout values use the following multiples-of-four scale:

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4px | Tight inline separation |
| `space-2` | 8px | Label/control and compact status gaps |
| `space-4` | 16px | Default control and card gaps |
| `space-6` | 24px | Card padding and section gaps |
| `space-8` | 32px | Page gutters on wide screens |
| `space-12` | 48px | Header and major section separation |
| `space-16` | 64px | Maximum page-level separation |

Exceptions: interactive controls have a minimum 44px block size, and the
comparison viewport may use a 1px divider. No other spacing value is allowed.

## Typography

Use exactly four sizes and two weights. Do not introduce display lettering,
all-caps paragraphs, or compressed tracking.

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Supporting label / badge | 13px | 600 | 1.4 |
| Body / form control | 16px | 400 | 1.5 |
| Section heading | 20px | 600 | 1.3 |
| Page heading | 32px | 600 | 1.2 |

Fixed-width text is not needed in the main interface. JSON is downloaded, not
previewed or copied into a text area.

## Color

The visual treatment stays close to the proven Spike 006 dark review surface so
image comparison remains the dominant task.

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#0B0D10` | Page and image-stage background |
| Secondary (30%) | `#14171B` | Loader, gate, form, dialog, and status surfaces |
| Accent (10%) | `#F06E4F` | Primary submit/export button, active view-mode control, and keyboard focus ring only |
| Primary text | `#F4F2EC` | Headings, labels, values |
| Secondary text | `#AAA8A1` | Guidance, descriptions, inactive progress |
| Border | `#3A3F46` | Card, field, table, and pane boundaries |
| Success | background `#173B2A`, text `#9EE7B8` | Explicit `GATE OPEN` or successful export only |
| Warning | background `#4B3520`, text `#FFD19A` | Valid-but-closed or incomplete review only |
| Destructive | background `#4B2523`, text `#FFB4A9` | Invalid input, `GATE CLOSED`, and destructive confirmation only |

Accent is reserved for the currently available primary action, the selected
Fit/100% control, and focus visibility. It is not used for body links, every
select, decorative borders, gate results, or progress. Every semantic state
must include text and/or an icon-independent shape; color alone never conveys
open, closed, success, or failure.

## Page Structure and Visual Hierarchy

The page has one centered column with `max-width: 1200px`, 32px wide-screen
gutters, and 16px compact-screen gutters. Sections appear in this exact order:

1. **Page header** — `本地证据盲审`, one sentence explaining local-only
   processing, and a persistent `不会上传` text badge.
2. **Local loader** — numbered manifest and asset-directory file inputs.
3. **Validation summary** — one top-level state plus fixed, actionable problems.
4. **Independent gate table** — exactly three rows in fixed order:
   `teeth_whitening`, `sclera_redness`, `upper_eyelid_fullness`.
5. **Review workspace** — progress, comparison viewport, structured judgment
   form, and previous/save-next controls. Hidden until at least one structurally
   valid row has a complete decodable asset triple.
6. **Export panel** — explains the allowlist and contains the export action.
   It is visible after validation but disabled until the current review set is
   complete. A closed gate never hides this panel.

Image panes are the strongest visual surface. Gate badges and counts remain
compact; they must not look like product scorecards or imply statistical
sufficiency.

## Component Inventory

| Component | Required contract |
|-----------|-------------------|
| `LocalEvidenceLoader` | Native `<input type="file">` for JSON and native directory input (`webkitdirectory`, `multiple`). No drag/drop, paste, URL field, recent-file list, or rendered filename/path. Reloading either input invokes the destructive-session confirmation when in-memory reviews exist. |
| `ValidationSummary` | Semantic heading plus `role="alert"` list for invalid data and `role="status"` for non-error progress. Maps validator reason codes to fixed copy; never renders an exception string, manifest value, filename, filesystem path, rights record, or JSON excerpt. Uses blinded item number when a row must be identified. |
| `FeatureGateTable` | Three fixed feature rows, each with `OPEN` or `CLOSED`, eligible positive count, eligible negative count, completed-review count, and fixed gate reason code rendered as friendly copy. No combined overall pass badge, borrowed denominator, or cross-feature aggregate. |
| `ReviewProgress` | Displays `项目 N / Total` and `已完成 M / Total`. It never displays fixture ID, polarity, rights status, directory name, or asset name. |
| `ComparisonViewport` | Three labeled panes in fixed order `原图`, `遮罩`, `处理后`; generic alt text only. `适合窗口` and `100%` are the only zoom modes. At 100%, one source pixel maps to one CSS pixel and the three panes share synchronized scroll offsets. Object URLs are created only for the active row and revoked on row change, reload, export completion, and unload. |
| `StructuredJudgmentForm` | Seven required controls: target present (yes/no), mask coverage (1–5), protected leakage (yes/no), naturalness (1–5), structure change (yes/no), decision (accept/reject), and one allowlisted reason code. Every select begins with a non-value `请选择`; there are no inferred defaults and no freeform input. |
| `ReviewNavigation` | `上一个项目` is secondary; `保存并继续` is the primary review action and validates all seven controls. On the final row its label becomes `保存评审`. Moving backward restores the saved structured values. No custom keyboard shortcuts. |
| `ExportPanel` | Primary action `导出脱敏评审 JSON`. Enabled when every reviewable row has a valid saved judgment and per-feature gates have been deterministically resolved, whether those gates are open or closed. Shows a fixed local success/failure message and never previews the JSON in the page. |
| `ReplaceSessionDialog` | Modal confirmation for replacing a manifest/directory after reviews exist. Focus is trapped, initial focus is `保留当前评审`; Escape activates that same keep-current action, and focus returns to the initiating file control. No confirmation is shown before any review has been saved. |

### Stable Test Selectors

The implementation must expose these unique IDs without embedding input data:

```text
#manifest-input
#asset-directory-input
#validation-summary
#feature-gates
#gate-teeth-whitening
#gate-sclera-redness
#gate-upper-eyelid-fullness
#review-workspace
#review-progress
#comparison-original
#comparison-mask
#comparison-after
#view-fit
#view-actual
#judgment-form
#previous-item
#save-and-next
#export-review
#session-status
#replace-session-dialog
```

## Interaction Flow

1. The initial page shows the loader, empty guidance, three visibly closed
   feature rows, hidden review workspace, and disabled export.
2. Selecting a manifest reads it with the File API. During parsing, inputs are
   disabled and the status says `正在检查本地清单…`. Parse/schema failure
   leaves all gates closed, clears previously resolved assets only after
   confirmation, focuses the validation heading, and exposes fixed remediation.
3. Selecting an asset directory builds an in-memory lookup. The interface never
   renders the directory name, relative path, or filename. Asset existence,
   regular decode, and equal original/mask/after intrinsic dimensions must pass
   before a row becomes reviewable.
4. Validation distinguishes:
   - invalid input, which blocks review and export;
   - structurally valid but incomplete/rights-ineligible evidence, which keeps
     the affected feature closed;
   - complete reviewable evidence with a closed product gate; and
   - complete evidence whose product gate may open only after every selected
     genuine row passes the frozen rules.
5. Review items use a deterministic internal ordering: feature order is
   teeth, sclera, upper eyelid; rows within a feature sort by opaque fixture ID.
   Only the sequential blinded item number and feature label are rendered.
6. `保存并继续` writes one structured judgment to memory. Invalid or missing
   choices remain next to their field and focus moves to the first invalid
   field. A valid save advances one row and focuses the review heading.
7. Changing a saved judgment recomputes only that feature's status and
   aggregates. It cannot alter a sibling feature's denominator or gate.
8. Completing the final row enables export even when one or all feature gates
   are closed. The feature table and downloaded JSON must agree exactly.
9. Export creates one Blob locally, triggers a fixed filename
   `beauty-evidence-review-v1.json`, immediately revokes the Blob URL, and
   reports success. It performs no upload, clipboard write, cache write, or
   persistent browser storage.
10. Closing/reloading the page discards manifest data, media, judgments, and
    object URLs. The next load starts from the initial state.

## Structured Judgment and Gate Copy

### Field Labels and Options

| Field | Label | Options |
|-------|-------|---------|
| `target_present` | `原图中是否存在目标状态？` | `是`, `否` |
| `mask_coverage` | `遮罩覆盖目标的程度` | `1` through `5` |
| `protected_leakage` | `是否改动了保护区域？` | `无`, `有` |
| `naturalness` | `处理结果自然度` | `1` through `5` |
| `structure_changed` | `是否出现结构变化？` | `无`, `有` |
| `decision` | `本项目结论` | `接受`, `拒绝` |
| `reason_code` | `固定原因` | Friendly labels for the frozen allowlist only |

Coverage scale help is fixed: `1 = 未覆盖，3 = 部分覆盖，5 = 完整且边界准确`.
Naturalness help is fixed: `1 = 明显不自然，3 = 可见瑕疵，5 = 自然且保留细节`.

The row-level reason-code allowlist is:

```text
none
target_mismatch
insufficient_mask_coverage
protected_leakage
unnatural_result
texture_loss
structure_change
unsupported_input
```

`none` is valid only with `decision = accept`; a rejection requires a non-none
reason. The pure review core remains the authority for consistency checks.

The gate-level closed reason-code allowlist is separate:

```text
missing_genuine_positive
missing_genuine_negative
incomplete_asset_triple
unapproved_fixture
review_incomplete
review_rejected
non_warp_design_unqualified
```

Upper-eyelid fullness may expose both `missing_genuine_positive` and
`non_warp_design_unqualified`; showing both is required and does not collapse
them into a generic failure. Teeth and sclera retain their own reason sets.

## Copywriting Contract

| Element | Exact copy |
|---------|------------|
| Page title | `本地证据盲审` |
| Privacy line | `文件只在当前浏览器标签页中读取，不会上传或保留。` |
| Primary loader label | `1. 选择评审清单` |
| Asset loader label | `2. 选择本地资产目录` |
| Empty state heading | `等待本地评审材料` |
| Empty state body | `选择清单和资产目录后开始。页面不会显示文件名或路径。` |
| Manifest loading | `正在检查本地清单…` |
| Asset loading | `正在核对本地资产…` |
| Generic invalid state | `无法开始评审。请修正下列清单或资产问题后重新选择。` |
| Ready state | `材料校验完成，可以开始盲审。` |
| Closed state | `证据门已关闭` |
| Open state | `证据门已开启` |
| Primary review CTA | `保存并继续` |
| Final review CTA | `保存评审` |
| Export CTA | `导出脱敏评审 JSON` |
| Export success | `脱敏评审 JSON 已下载。页面不会保留副本。` |
| Export failure | `导出失败。请完成所有必填判断并重试。` |
| Destructive confirmation | `重新载入会清除本标签页内尚未导出的评审。继续？` |
| Destructive confirm action | `继续载入` |
| Destructive keep-current action | `保留当前评审` |

Validation details use fixed, actionable sentences selected by reason code.
They must not concatenate or interpolate raw input. For example:

- `项目 2 缺少完整的原图、遮罩或处理后资产。`
- `清单包含不支持的字段值。`
- `当前功能缺少合格的真实正例。`
- `当前功能缺少合格的真实反例。`
- `去脂的非形变方案尚未通过资格审查。`

Terms such as `ready`, `qualified`, or `通过` refer only to the internal
evidence gate. Copy must never say `可发布`, `商业可用`, `人群有效`,
`已上线`, or otherwise imply product, device, demographic, shipping, or
release readiness.

## State Matrix

| State | Loader | Gate table | Workspace | Export | Focus/status behavior |
|-------|--------|------------|-----------|--------|-----------------------|
| Initial | enabled | all closed, `尚未校验` | hidden | disabled | page heading receives initial logical focus |
| Reading manifest | disabled | unchanged | hidden | disabled | polite `正在检查本地清单…` |
| Invalid manifest | enabled | all closed | hidden | disabled | validation heading focused; fixed errors use `role=alert` |
| Waiting for assets | enabled | affected rows closed, `等待本地资产` | hidden | disabled | directory input described by status |
| Invalid/missing assets | enabled | affected rows closed | only complete mechanics rows may be shown; invalid rows never render | disabled | fixed blinded-item problems announced |
| Ready, product gate closed | enabled | independent closed reason(s) | visible | disabled until reviews complete | review heading focused |
| Ready, product gate eligible | enabled | `等待评审` until all rows pass | visible | disabled until reviews complete | review heading focused |
| Review validation error | enabled | unchanged | visible | unchanged | first invalid control focused; inline text announced |
| Review complete, gates closed | enabled | exact independent decisions | visible | enabled | completion status announced |
| Review complete, gate(s) open | enabled | only qualified row(s) open | visible | enabled | completion status announced |
| Export succeeded | enabled | unchanged | visible | enabled | success status announced; focus stays on export |
| Export failed | enabled | unchanged | visible | enabled | fixed alert, no raw browser error |
| Replacement confirmation | initiating input paused | unchanged | unchanged | unchanged | modal traps focus; `保留当前评审` is initial focus |
| Unsupported browser capability | disabled affected input | all closed | hidden | disabled | fixed compatibility copy; no fallback server suggested |

## Responsive Contract

- **1200px and wider:** loader uses two equal columns; feature gates are a
  compact table; three comparison panes share one row; judgments use up to
  three columns.
- **768px–1199px:** page gutters are 24px; loader may remain two columns when
  each field is at least 280px; comparison remains three panes with each pane
  at least 220px or switches to the compact pattern below.
- **Below 768px:** loader and judgment controls stack in one column. The
  comparison becomes one pane with three text tabs (`原图`, `遮罩`, `处理后`);
  switching tabs preserves the same fit/100% zoom and scroll position. The
  feature table becomes three stacked gate cards with the same data order.
- No breakpoint may produce page-level horizontal scrolling. At 100%, overflow
  is confined to the active comparison pane.
- Primary and secondary actions stack below 480px and remain at least 44px
  high. The export action stays after the judgment form in DOM order.

## Accessibility Contract

- Use semantic `header`, `main`, `section`, `form`, `fieldset`, `legend`,
  `table`/headers, `button`, and native file/select controls.
- Every file input and form control has a persistent visible label plus
  programmatic association. Placeholder options never substitute for labels.
- All actions work by keyboard. Visible focus uses a 3px accent ring with 2px
  offset and is never removed. Tab order follows DOM/visual order.
- Status changes use a single polite live region; invalid input and export
  failure use `role="alert"`. Repeated validation must replace existing content
  instead of appending duplicate announcements.
- After successful save-and-next, focus moves to the item heading. After a load
  failure, focus moves to the validation heading. Dialog focus behavior follows
  the component contract above.
- Image alternatives are exactly `原图`, `遮罩`, and `处理后`; they reveal no
  fixture identity. The three pane labels remain visible at every zoom.
- Text and controls meet WCAG AA contrast (4.5:1 normal text, 3:1 large text and
  non-text focus/control boundaries). Open/closed status includes explicit
  words and reason text, never color alone.
- The page remains usable at 200% browser zoom and 320 CSS px width. Text may
  wrap; controls and status content may not overlap or clip.
- Respect `prefers-reduced-motion`; because the contract requires no essential
  motion, state changes occur without animation.

## Privacy and Browser Security Contract

- The page may read only user-selected `File` objects and create temporary
  `blob:` URLs for the active comparison. It must never call `fetch`,
  `XMLHttpRequest`, `WebSocket`, `EventSource`, `sendBeacon`, WebRTC, or any
  network-capable analytics/API.
- No `localStorage`, `sessionStorage`, IndexedDB, Cache API, cookie, service
  worker, clipboard write, form submission, or background worker is used.
- Manifest, rights records, asset paths, filenames, media, raw geometry, masks,
  review drafts, and object URLs remain memory-only. Browser autocomplete is
  disabled for the judgment form.
- Recommended document policy:

```text
default-src 'none';
script-src 'self';
style-src 'self' 'unsafe-inline';
img-src blob:;
connect-src 'none';
font-src 'none';
media-src 'none';
object-src 'none';
frame-src 'none';
worker-src 'none';
base-uri 'none';
form-action 'none'
```

- No image, mask, path, directory, rights/documentation ID, reviewer identity,
  timestamp, event log, freeform text, raw exception, or browser metadata may
  enter the durable JSON.
- Validation and export are fail-closed. A browser decode error, dimension
  mismatch, missing asset, unsupported enum, traversal/absolute path, duplicate
  opaque ID, mixed feature bundle, or inconsistent review disables the affected
  review/export route and produces fixed redacted copy.

## Deterministic Durable Export

The export is UTF-8 JSON with two-space indentation, LF line endings, one final
newline, stable key order, fixed feature order, and reviews sorted by feature
then opaque fixture ID. Repeating export without changing structured judgments
must produce byte-identical content.

The top-level allowlist is:

```text
schema_version
feature_decisions
reviews
aggregates
```

Each review may contain only:

```text
fixture_id
feature
polarity
target_present
mask_coverage
protected_leakage
naturalness
structure_changed
decision
reason_code
```

Each feature decision/aggregate may contain only the feature ID, open/closed
decision, allowlisted fixed reason codes, genuine positive/negative counts,
eligible/reviewed/accepted/rejected counts, and aggregate structured judgment
counts. Mechanics-only/synthetic/AI/disabled/parked/historical rows contribute
zero product-effectiveness and zero naturalness weight; any displayed excluded
count is separate from the product denominator.

Explicitly forbidden keys and values include `dataset_id`, `generated_at`,
`timestamp`, `events`, `metadata`, `reviewer`, `notes`, `text`, any asset/media
key, filename/path/directory, rights or documentation IDs, retention text,
original/mask/after content, coordinates, landmarks, pupils, descriptors, and
raw error strings.

## Executable Acceptance Criteria

The planner must turn these into deterministic DOM/core tests or static scans.

1. **Initial boundary:** Given a fresh file-open page, all three gate selectors
   say closed/not-validated, `#review-workspace` is hidden, and
   `#export-review` is disabled.
2. **Local-only operation:** A source scan of the shipped reviewer contains no
   network, storage, service-worker, clipboard, external URL, or third-party
   dependency APIs named in the privacy contract. The document policy contains
   `connect-src 'none'`.
3. **Redacted invalid input:** Invalid JSON, traversal/absolute paths,
   unsupported enums, duplicate IDs, and missing assets produce fixed copy,
   never the raw parser exception, manifest value, fixture ID, filename, or
   path; review and export stay disabled for invalid rows.
4. **Blinded display:** A valid complete row renders only item number, feature,
   and the three generic pane labels. Fixture/polarity/rights/path values are
   absent from visible text, `title`, `alt`, ARIA labels, and DOM data
   attributes.
5. **Original detail:** Fit mode contains all three images. Actual-size mode
   maps source pixels 1:1 to CSS pixels, synchronizes pane scroll offsets, and
   keeps overflow inside the viewport. A decode or intrinsic-dimension mismatch
   fails closed before review.
6. **Required judgments:** Save with any of the seven fields unset fails,
   announces a fixed error, and focuses the first invalid field. Save with all
   valid fields stores exactly the allowlisted values and advances once.
7. **No implicit approval:** Every judgment control begins unselected.
   `decision = reject` plus `reason_code = none`, or `decision = accept` plus a
   rejection reason, fails the core consistency check.
8. **Progress and navigation:** Saving N distinct rows reports exactly
   `已完成 N / Total`; revisiting a row restores its values without incrementing
   completion. Replacing selected local inputs after N > 0 requires explicit
   confirmation.
9. **Mechanics exclusion:** Adding or accepting mechanics-only, synthetic,
   disabled, parked, or historically authorized rows changes neither the
   genuine product denominator nor naturalness aggregate and cannot open any
   gate.
10. **Independent gates:** Adding a passing teeth row cannot alter sclera or
    upper-eyelid counts/status; sibling evidence cannot satisfy a missing
    positive/negative. A closed feature does not disable review or export for a
    complete sibling.
11. **Frozen acceptance:** A positive opens only with target present, coverage
    at least 4, no leakage, naturalness at least 4, no structure change, and
    accept. A negative opens only when its predeclared absence/challenge
    judgment passes the corresponding frozen rule. Every selected genuine row
    must pass.
12. **Upper-eyelid decision:** The current upper-eyelid row exposes both
    `missing_genuine_positive` and `non_warp_design_unqualified`; no eye/brow
    geometry or smoothing substitute can change it.
13. **Closed-result export:** When all reviewable rows are complete but a gate
    remains closed, export is enabled and the JSON records that closed decision
    and fixed reasons. Closed is a completed outcome, not a UI error.
14. **Determinism:** Two exports from identical manifest inventory and
    judgments are byte-identical, use the fixed filename, stable ordering,
    two-space JSON, LF, and a final newline.
15. **Export privacy:** Parsing the exported JSON finds exactly the top-level
    and row allowlists above. A recursive forbidden-key/value scan finds zero
    media, filename/path, rights/documentation ID, raw geometry, reviewer,
    timestamp/event, freeform, or raw-error fields.
16. **Ephemeral media:** Object URL instrumentation shows at most the active
    original/mask/after URLs and confirms revocation on navigation, replacement,
    export completion, and unload. No browser persistence remains after reload.
17. **Accessibility:** Automated DOM checks find one visible label per control,
    semantic fieldsets/legends, explicit live/alert regions, and unique stable
    selectors. Keyboard-only traversal reaches every action in visual order;
    the replacement dialog traps and restores focus.
18. **Responsive behavior:** At 1200, 768, and 320 CSS px widths and at 200%
    zoom, the page has no page-level horizontal scroll, labels/status do not
    overlap, mobile comparison tabs retain state, and every action remains at
    least 44px high.
19. **Scope boundary:** Static scans show no changes or imports under
    `BeautyDemo/` or production SDK targets, no candidate feature field,
    provider, renderer case, preset key, realtime route, or production
    admission caused by the reviewer.

## UI Considerations

> Populated by the ui-phase UI-consideration probe and lifted by plan-phase.
> The probe inspected eight authored surfaces with explicit element-kind
> overrides and proposed 50 applicable shape-rooted considerations.

Applicable state considerations resolved: **50 covered, 0 backstop, 0 unresolved**.

| Category | Element(s) | Status | Resolution / Reason |
|----------|------------|--------|---------------------|
| empty | loader, validation summary, gate table, comparison, judgment form, navigation, replacement dialog | ✅ covered | A fresh page renders the documented waiting guidance and three closed/not-validated gates, hides the workspace, disables export, leaves every judgment unselected, and does not render the replacement dialog before a saved review. |
| loading | loader, validation summary, gate table, comparison, judgment form, navigation, replacement dialog | ✅ covered | Manifest and asset reads disable initiating inputs, preserve closed gates, hide unavailable media, announce the fixed local loading copy through the polite status region, and expose no indefinite animation or server retry state. |
| error | loader, validation summary, gate table, comparison, judgment form, navigation, replacement dialog | ✅ covered | Parse, validation, decode, dimension, save, export, and replacement failures use the documented fixed redacted copy, keep affected routes disabled or unchanged, and focus the validation heading or first invalid control without rendering raw values or exceptions. |
| populated | validation summary, gate table, comparison, navigation | ✅ covered | The happy path shows exactly three independent gate rows, one active blinded original/mask/after triple, accurate item/completion counts, and only the documented controls and generic pane labels. |
| partial | loader, validation summary, gate table, judgment form, navigation, replacement dialog | ✅ covered | One selected input, incomplete asset triples, partially eligible features, and partially completed judgments remain visibly incomplete and fail closed; complete reviewable siblings stay independent, while no missing field receives an inferred value. |
| overflow | every authored surface | ✅ covered | At 320 CSS px, 200% zoom, and all declared breakpoints, copy and controls wrap without overlap or page-level horizontal scrolling; only the active 100% image pane scrolls, and dialog/action content remains reachable. |
| zero-one-many | validation summary, gate table, navigation/progress | ✅ covered | Zero reviewable rows retain the waiting/closed state, one row uses accurate singular item progress, many rows preserve deterministic order and exact completion counts, and the gate surface always retains exactly three independent feature rows. |
| long-text | every authored surface | ✅ covered | Fixed labels, reasons, status copy, and controls wrap and reflow at the required widths without clipping; input-derived identifiers, filenames, paths, exceptions, and freeform text are never substituted into the UI, so adversarial long values cannot expand visible content. |

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | none | Not applicable — repository scout on 2026-07-31 found no React/Vite/shadcn stack and this phase requires static dependency-free files |
| Third-party registries | none | PASS — no registry or external component is permitted |

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [x] Dimension 2 Visuals: PASS
- [x] Dimension 3 Color: PASS
- [x] Dimension 4 Typography: PASS
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: PASS

**Approval:** approved 2026-07-31
