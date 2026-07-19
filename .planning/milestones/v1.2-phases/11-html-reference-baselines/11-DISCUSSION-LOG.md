# Phase 11: HTML Reference Baselines - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-25
**Phase:** 11-HTML Reference Baselines
**Areas discussed:** HTML reconstruction policy, Home baseline scope, Editor baseline scope, offline evidence policy

---

## HTML Reconstruction Policy

| Option | Description | Selected |
|--------|-------------|----------|
| CSS reconstruction | Recreate the reference pages as inspectable local HTML/CSS, using screenshots as source references. | ✓ |
| Screenshot background | Use the source screenshot as the rendered page background for maximum visual similarity. | |
| SwiftUI first | Skip HTML and continue tuning SwiftUI directly. | |

**User's choice:** The user explicitly asked to first convert the two Meitu pages into HTML, then use that HTML to optimize SwiftUI.
**Notes:** The selected approach avoids another direct screenshot-to-SwiftUI pass and creates a measurable intermediate artifact.

---

## Home Baseline Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Full covered Home states | Cover first screen, tool-grid paging, recommendations, bottom tabs, and sticky shortcut state. | ✓ |
| First screen only | Build only the initial Hero/entry screen and defer scroll state. | |
| All app tabs | Include Home, gallery, AI retouch, profile, VIP, search, and detail flows. | |

**User's choice:** The user identified `meituxiuxiu/home` as the Home reference and asked to analyze/restore that page.
**Notes:** `HOME_MAP.md` requires both first-screen and sticky states. Other tabs and downstream flows are not covered by the local screenshots.

---

## Editor Baseline Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Beauty/facial tool panel | Cover the editor preview chrome and `美型 / 五官` bottom panel categories from `FUNCTION_MAP.md`. | ✓ |
| Entire editor product | Include every Meitu editor module, save/export, stickers, makeup, filters, and gallery. | |
| Supported SDK tools only | Only show tools that already map to `BeautyControlID`. | |

**User's choice:** The user called out the editor `美型 / 五官` tool panel as a required reference.
**Notes:** Unsupported functions should still appear visually when present in the reference, but remain static/badged. Functional implementation belongs to later SDK/product phases.

---

## Offline Evidence Policy

| Option | Description | Selected |
|--------|-------------|----------|
| Local deterministic HTML | Use local HTML/CSS/assets only and capture browser screenshots under `.planning/evidence/v1.2/`. | ✓ |
| Remote design assets | Pull web fonts, CDN icon libraries, or remote images for faster fidelity. | |
| No browser evidence | Write HTML files without screenshot verification. | |

**User's choice:** No explicit option selection; inferred from repo privacy/offline constraints and Phase 11 requirements.
**Notes:** HTML-04 requires no network fonts, remote images, analytics, upload, or hidden runtime services. HTML-05 requires browser screenshots.

---

## the agent's Discretion

- Exact CSS file organization, class names, and screenshot capture command can be chosen during Phase 11 planning/execution.
- The sticky Home capture may use documented scroll position or a deterministic static capture target.
- The HTML can use local placeholder shapes and CSS-drawn imagery where commercial screenshots/assets should not be copied into implementation.

## Deferred Ideas

- SwiftUI Home changes move to Phase 13.
- SwiftUI editor changes move to Phase 14.
- Automated visual diffing and broader visual QA move to Phase 15 or later.
