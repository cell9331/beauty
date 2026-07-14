# Phase 22: Automated Demo QA and Screenshot Evidence - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-06-30
**Phase:** 22-Automated Demo QA and Screenshot Evidence
**Areas discussed:** Screenshot capture path, Target simulator matrix, Evidence acceptance bar, Blocker and honesty policy

---

## Screenshot Capture Path

| Option | Description | Selected |
|--------|-------------|----------|
| Existing launch args + `simctl` screenshots | Reuse current `--beauty-demo-home-sticky` and `--beauty-demo-route editor-*` hooks; lowest new code and closest to prior v1.1 evidence style. | yes |
| XCUITest screenshot harness | More repeatable long term, but likely needs new UI test plumbing and still depends on the Metal Toolchain build blocker. | |
| Manual screenshot protocol only | Fastest if local tooling stays blocked, but weaker as automated QA evidence. | |
| Other | Freeform preference. | |

**User's choice:** Existing launch args plus `simctl` screenshots.
**Notes:** Existing routes are preferred first. Minimal launch-only QA hooks are allowed only if needed for deterministic required captures.

| Option | Description | Selected |
|--------|-------------|----------|
| Add only minimal QA hooks if needed | Existing routes first; add launch-only fixture/state hooks only if required to capture deterministic Home/Editor evidence. | yes |
| No new hooks | Use only current `--beauty-demo-route` and `--beauty-demo-home-sticky`, even if editor evidence is less realistic. | |
| Build full UI-test navigation | Drive taps/scrolls to reach states instead of adding launch hooks, but this is more brittle. | |
| Other | Freeform preference. | |

**User's choice:** Add only minimal QA hooks if needed.
**Notes:** Hooks must be launch-only QA support and must not create product routes.

| Option | Description | Selected |
|--------|-------------|----------|
| Home first screen, Home sticky state, editor beauty/photo panel | Directly matches Phase 22 roadmap and existing launch hooks. | yes |
| Add editor camera route too | Covers camera shell entry, but may require permission/session handling and is more likely to be blocked. | |
| Capture every supported route | Broader evidence, but risks turning Phase 22 into a UI sweep instead of targeted QA. | |
| Other | Freeform preference. | |

**User's choice:** Home first screen, Home sticky state, editor beauty/photo panel.
**Notes:** Editor camera route is optional only if cheap and reliable.

| Option | Description | Selected |
|--------|-------------|----------|
| Evidence README with exact commands | Record build/test/simctl commands, launch args, simulator destination, output files, and review notes. | yes |
| Add a reusable script | Stronger repeatability, but only if it stays small and does not overbuild a new QA framework. | |
| Screenshots only | Less documentation overhead, but weaker for future agents. | |
| Other | Freeform preference. | |

**User's choice:** Evidence README with exact commands.
**Notes:** The evidence README is required even if screenshots are blocked.

---

## Target Simulator Matrix

| Option | Description | Selected |
|--------|-------------|----------|
| iPhone 17 only | Matches Phase 21 blocker command and available simulator inventory; keeps Phase 22 focused on unblocking current evidence. | yes |
| Compact + baseline iPhones | Add a smaller iPhone-class check if available, improving clipping confidence without broadening too much. | |
| iPhone + iPad | Wider layout confidence, but Phase 22 is about current phone-style Meitu surfaces and may create tablet-specific scope. | |
| Other | Freeform preference. | |

**User's choice:** iPhone 17 only.
**Notes:** Required simulator destination is iPhone 17 / iOS 26.5.

| Option | Description | Selected |
|--------|-------------|----------|
| Optional compact or large phone smoke only | Planner may add one extra phone screenshot/check if cheap after baseline passes. | yes |
| No optional devices | Keep evidence strictly to iPhone 17. | |
| Optional iPad too | Broader coverage, but likely outside the current phone-first Meitu reference scope. | |
| Other | Freeform preference. | |

**User's choice:** Optional compact or large phone smoke only.
**Notes:** Optional coverage must not block the required iPhone 17 evidence.

| Option | Description | Selected |
|--------|-------------|----------|
| Blocked/manual protocol only | Record exact physical-device protocol and mark blocked until hardware exists; do not require it for Phase 22 completion. | yes |
| Required for completion | Stronger evidence, but likely blocks Phase 22 because hardware evidence is not currently available. | |
| Ignore physical device in Phase 22 | Simpler, but loses TD-008 traceability. | |
| Other | Freeform preference. | |

**User's choice:** Blocked/manual protocol only.
**Notes:** Physical iPhone evidence remains blocked until hardware evidence exists.

---

## Evidence Acceptance Bar

| Option | Description | Selected |
|--------|-------------|----------|
| Screenshot + factual review note | Each screenshot needs command, file path, framing, and concrete notes on clipping/overlap/disabled honesty. | yes |
| Screenshot only | Faster, but weaker for future comparison and manual audit. | |
| Screenshot + automated pixel/layout assertions | Stronger, but may require significant harness work and risk brittleness. | |
| Other | Freeform preference. | |

**User's choice:** Screenshot plus factual review note.
**Notes:** Review notes must include command, path, framing, clipping/overlap, and disabled-honesty observations.

| Option | Description | Selected |
|--------|-------------|----------|
| Explicit build and Demo tests if Metal Toolchain is fixed | Screenshot evidence should sit next to `xcodebuild ... build/test`; if blocked, record exact blocker. | yes |
| Build only | Lower bar, enough to install/capture screenshots, but misses existing Demo test regressions. | |
| Screenshots only | Visual evidence focused, but weaker for a QA phase. | |
| Other | Freeform preference. | |

**User's choice:** Explicit build and Demo tests if Metal Toolchain is fixed.
**Notes:** If the Metal Toolchain remains missing, record the exact blocker.

| Option | Description | Selected |
|--------|-------------|----------|
| Current tests plus human-readable screenshot notes | Add narrow view-state/route tests only when needed; avoid brittle pixel-perfect assertions. | yes |
| Accessibility/element existence checks | Good middle ground if XCUITest is cheap, but requires more UI automation. | |
| Pixel/image diff baseline | Strongest regression gate, but better suited to a later screenshot-diff phase unless already easy. | |
| Other | Freeform preference. | |

**User's choice:** Current tests plus human-readable screenshot review notes.
**Notes:** Narrow tests are allowed if needed; pixel-perfect assertions are discouraged.

| Option | Description | Selected |
|--------|-------------|----------|
| Clipping/overlap + disabled honesty + route scope | Controls, labels, badges, panels, and disabled/future areas stay visible and inactive; no new route is enabled. | yes |
| Visual fidelity to Meitu references | More subjective and risks redesign scope. | |
| Naturalness/effect quality | Important, but belongs more to renderer/physical QA than Phase 22 layout evidence. | |
| Other | Freeform preference. | |

**User's choice:** Clipping/overlap plus disabled honesty plus route scope.
**Notes:** Phase 22 should not claim product naturalness or visual redesign fidelity.

---

## Blocker and Honesty Policy

| Option | Description | Selected |
|--------|-------------|----------|
| Reproduce blocker + write manual protocol | Exact failing command/environment/impact, plus commands to rerun after installing Metal Toolchain; no screenshot pass claimed. | yes |
| Stop Phase 22 as blocked | Strict, but prevents any non-simulator documentation progress. | |
| Use archived v1.1 screenshots as pass evidence | Faster, but overclaims current v1.4 evidence. | |
| Other | Freeform preference. | |

**User's choice:** Reproduce blocker and write manual protocol.
**Notes:** If the Metal Toolchain remains missing, Phase 22 can complete with documented blocker/protocol only, not screenshot pass evidence.

| Option | Description | Selected |
|--------|-------------|----------|
| Background comparison only | Useful reference context, but not current v1.4 pass evidence. | yes |
| Treat as sufficient if current build is blocked | Faster, but conflicts with Phase 21's current-evidence policy. | |
| Ignore archived screenshots | Conservative, but loses helpful comparison context. | |
| Other | Freeform preference. | |

**User's choice:** Background comparison only.
**Notes:** Archived v1.1/v1.2 screenshots are not current v1.4 evidence.

| Option | Description | Selected |
|--------|-------------|----------|
| Route/model tests + screenshot notes + scans if needed | Verify disabled routes remain disabled, badges/hints remain visible, and no new UI route is enabled. | yes |
| Screenshot notes only | Simpler, but weaker for QA-04. | |
| Static tests only | Good for route honesty, but misses visible disabled badge/panel problems. | |
| Other | Freeform preference. | |

**User's choice:** Route/model tests plus screenshot notes, with scans if needed.
**Notes:** This is the QA-04 evidence path.

| Option | Description | Selected |
|--------|-------------|----------|
| Manual protocol + blocked status | Record the physical-device steps and state that hardware evidence remains blocked until a device run exists. | yes |
| Remove it from Phase 22 entirely | Simpler, but weakens TD-008 traceability. | |
| Require a real device run now | Stronger, but likely blocks the phase. | |
| Other | Freeform preference. | |

**User's choice:** Manual protocol plus blocked status.
**Notes:** Physical-device camera/Vision parity remains blocked until a device run exists.

---

## the agent's Discretion

- Choose exact screenshot filenames and evidence README layout.
- Decide whether a tiny helper script is worth adding.
- Choose exact command ordering for boot, install, launch, screenshot, and shutdown.
- Add one optional extra phone smoke check only if cheap after the required iPhone 17 path passes.

## Deferred Ideas

- Full XCUITest screenshot harness unless it is cheaper than the selected `simctl` path.
- Pixel-perfect screenshot diffing and image-regression baselines.
- Required editor camera route evidence.
- Physical iPhone camera/Vision parity until hardware exists.
- Production naturalness and effect-quality review.
- iPad/tablet layout evidence.
