# Phase 2: Demo Integration Shell - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-11T03:33:59Z
**Phase:** 2-Demo Integration Shell
**Areas discussed:** First Screen Shape, Unavailable Controls, Slider Behavior

---

## First Screen Shape

| Option | Description | Selected |
|--------|-------------|----------|
| Editor Shell | Real editor-like preview, bottom categories, and panel; preview uses placeholder or fixture state. | ✓ |
| Control Catalog | Capability-map style control catalog; wait until Phase 3 to make it feel like an editor. | |
| Split Shell | Preview-like upper area plus catalog-like lower area. | |

**User's choice:** Editor Shell
**Notes:** The Demo should feel like a real editing shell immediately, even before camera or photo input exists.

| Option | Description | Selected |
|--------|-------------|----------|
| Static Portrait Placeholder | Fixed portrait or clear placeholder preview area. | ✓ |
| Neutral Empty Canvas | Empty state saying camera/photo input comes in Phase 3. | |
| SDK Status Panel | Preview area shows SDK integration status and no-op state. | |

**User's choice:** Static Portrait Placeholder
**Notes:** The preview area should preserve the future editor shape without implying live input support.

| Option | Description | Selected |
|--------|-------------|----------|
| Show Disabled Modes | Show Camera and Photo entries but disable or mark them as Phase 3. | ✓ |
| Hide Modes For Now | Single editor shell with no camera/photo entries. | |
| Show Demo Tabs | Developer validation tabs such as Editor / SDK Status / Tests. | |

**User's choice:** Show Disabled Modes
**Notes:** Product paths should be visible while remaining clearly unavailable in Phase 2.

| Option | Description | Selected |
|--------|-------------|----------|
| Beauty | Default bottom category is basic beauty. | ✓ |
| Facial Features | Default category is facial feature hierarchy. | |
| None Selected | Keep panel closed until user chooses a category. | |

**User's choice:** Beauty
**Notes:** The first expanded panel should match common editing expectations.

---

## Unavailable Controls

| Option | Description | Selected |
|--------|-------------|----------|
| Visible Disabled | All top-level categories are visible; unavailable ones open to disabled or coming-later panels. | ✓ |
| Visible Locked | All categories visible, but unavailable categories cannot be opened. | |
| Group Later Categories | Later categories are grouped under a compact Later entry. | |

**User's choice:** Visible Disabled
**Notes:** This supports category visibility tests and keeps the future taxonomy explicit.

| Option | Description | Selected |
|--------|-------------|----------|
| Phase Badge + Short Reason | Show a Coming in Phase X badge plus a concise reason. | ✓ |
| Minimal Disabled Rows | Only gray disabled rows, with no explanation. | |
| Developer-Oriented Detail | Show requirement IDs, target phase, and SDK support state. | |

**User's choice:** Phase Badge + Short Reason
**Notes:** The normal UI should be clear without becoming a developer report.

| Option | Description | Selected |
|--------|-------------|----------|
| All Visible, Mixed Availability | Eyes/Nose/Mouth have usable structure; Eyebrows/Teeth/Hairline are disabled or coming later. | ✓ |
| All Disabled Until Effects | All facial feature subcategories disabled until real effects ship. | |
| Only v1 Visible | Hide future facial feature subcategories. | |

**User's choice:** All Visible, Mixed Availability
**Notes:** Preserve the full Facial Features taxonomy while respecting v1/v2 boundaries.

| Option | Description | Selected |
|--------|-------------|----------|
| Visible Disabled Category | Filters visible; rows and intensity disabled and marked Phase 5. | ✓ |
| Partially Interactive Intensity Only | Filter selection disabled, intensity slider interactive. | |
| Hide Filter Rows | Show only a coming-later empty state. | |

**User's choice:** Visible Disabled Category
**Notes:** Filters should be visible as a planned domain but not partially active in Phase 2.

---

## Slider Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Mapped Parameters Interactive | Existing `BeautyParameters` fields have interactive sliders that update parameter snapshots. | ✓ |
| All Sliders Disabled | Disable all sliders until visual effects exist. | |
| Only Beauty Interactive | Only Beauty sliders are interactive; face and facial features disabled. | |

**User's choice:** Mapped Parameters Interactive
**Notes:** Phase 2 should verify UI-to-SDK parameter mapping even while visual output is no-op.

| Option | Description | Selected |
|--------|-------------|----------|
| Use SDK Domain Table | Enhancement controls use `0...100`, bidirectional controls use `-100...100`, and tests verify normalization. | ✓ |
| All 0...100 For Simplicity | Every slider uses a unit-style UI range. | |
| Manual Per Category | Each category defines ranges independently. | |

**User's choice:** Use SDK Domain Table
**Notes:** UI ranges should stay aligned with `DESIGN.md` and `BeautyParameters`.

| Option | Description | Selected |
|--------|-------------|----------|
| Parameter Applied, Visual Pending | Values change and a short state explains that visual effects come later. | ✓ |
| No Extra Hint | No extra no-op hint. | |
| Developer Debug Readout | Show full parameter snapshots or changed fields. | |

**User's choice:** Parameter Applied, Visual Pending
**Notes:** The UI should be honest that parameters update while no visual effect is expected yet.

| Option | Description | Selected |
|--------|-------------|----------|
| Single + Reset All | Each slider has single reset and there is also reset all. | ✓ |
| Reset All Only | Only global reset. | |
| No Reset Yet | Defer reset until Phase 7. | |

**User's choice:** Single + Reset All
**Notes:** Reset behavior is part of the Phase 2 parameter store and view-state acceptance.

---

## the agent's Discretion

None.

## Deferred Ideas

None. All decisions stayed inside the Phase 2 Demo Integration Shell boundary.
