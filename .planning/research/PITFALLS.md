# Pitfalls Research

**Domain:** iOS beauty SDK hardening and technical-debt cleanup.
**Researched:** 2026-06-30
**Confidence:** HIGH for project-local pitfalls, MEDIUM for exact implementation costs.

## Critical Pitfalls

### Pitfall 1: Optimizing Without Baseline Evidence

**What goes wrong:** Code changes look like improvements but cannot be compared against a stable command, artifact, or budget.

**Why it happens:** Hardening milestones can drift into ad hoc cleanup.

**How to avoid:** Phase 21 must refresh quality scores, debt status, and baseline commands before implementation work.

**Warning signs:** Claims like "faster", "cleaner", or "release-ready" without command output or artifact links.

**Phase to address:** Phase 21.

---

### Pitfall 2: Flaky Screenshot QA

**What goes wrong:** UI evidence changes because of simulator, clock, animations, permissions, or dynamic data rather than real regressions.

**Why it happens:** Screenshots are introduced without stable launch routes and fixed destinations.

**How to avoid:** Use existing launch hooks, explicit simulator destinations, deterministic screens, and tolerance/documented manual review where automation is not stable.

**Warning signs:** Screenshots fail locally with no source change, or tests depend on remote assets.

**Phase to address:** Phase 22.

---

### Pitfall 3: Simulator-Only Release Claims

**What goes wrong:** Simulator evidence is mistaken for real camera/Vision/hardware performance readiness.

**Why it happens:** Hardware may not be available during automation.

**How to avoid:** Separate simulator evidence from physical-device smoke. Record blocked hardware checks explicitly instead of overclaiming.

**Warning signs:** Front-camera mirroring, low-light Vision quality, thermal, or long-run claims without device notes.

**Phase to address:** Phases 23 and 25.

---

### Pitfall 4: Privacy Manifest Drift

**What goes wrong:** SDK behavior, logs, metrics, or resource handling change without matching privacy manifest review.

**Why it happens:** Privacy docs are treated as distribution paperwork rather than implementation constraints.

**How to avoid:** Review `PrivacyInfo.xcprivacy`, no-network scans, required-reason API usage, and redacted log/metric surfaces before closeout.

**Warning signs:** New metrics/logging/resource code without `SECURITY.md` review.

**Phase to address:** Phase 25.

---

### Pitfall 5: Scope Creep Into New Product Features

**What goes wrong:** Cleanup turns into new Meitu surfaces, public parameters, geometry output, cloud/AI, or distribution packaging.

**Why it happens:** Deferred items are visible in docs and easy to promote accidentally.

**How to avoid:** Requirements must mark these as future/out of scope. Plans should use negative scans for API/UI/product expansion where relevant.

**Warning signs:** New public `BeautyParameters`, new Home/editor routes, network code, or changed feature-matrix completion claims.

**Phase to address:** All phases, final scan in Phase 25.

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
| --- | --- | --- | --- |
| Manual-only QA notes | Fast evidence | Not repeatable and easy to lose | Acceptable only when hardware/tooling is unavailable and blocker is recorded. |
| Updating root docs without command evidence | Looks consistent | Can drift from code and tests | Avoid; cite commands or add explicit unverified notes. |
| Leaving stale research files | Saves time | Future roadmaps may read wrong context | Never for active milestone research. |
| Broad historical doc cleanup | Makes tree look cleaner | Can overwrite unrelated user changes | Only when scoped and recorded as a docs phase. |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
| --- | --- | --- | --- |
| Per-frame object creation | Timing spikes and memory growth | Cache Metal/CI/pipeline resources and measure allocations. | Realtime camera and long-run preview. |
| Unbounded queues | Preview lag and stale outputs | Keep in-flight work bounded and count dropped frames. | Device pressure or slow render frames. |
| Blocking waits in realtime | UI stalls and missed frames | Avoid steady-state `waitUntilCompleted()` in realtime paths. | Camera preview and high resolution input. |
| Per-frame verbose logs | CPU overhead and sensitive data risk | Sample/aggregate metrics and disable per-frame logs by default. | Debug builds and prolonged sessions. |

## Security Mistakes

| Mistake | Risk | Prevention |
| --- | --- | --- |
| Logging paths, raw JSON, face geometry, or framework errors | Sensitive data disclosure | Redaction scans and tests. |
| Declaring privacy behavior too broadly or too narrowly | App Store/distribution mismatch | Manifest review tied to actual SDK behavior. |
| Treating resource IDs as paths | Path traversal/resource trust issues | Conservative ID validation through `BeautyResources`. |

## Looks Done But Is Not Checklist

- [ ] **Performance:** Budget written but no repeatable measurement command.
- [ ] **Visual QA:** Screenshots captured but no route, destination, or review criteria recorded.
- [ ] **Renderer output:** PNG exists but no dimension/watermark/no-op/visible-output checks.
- [ ] **Privacy:** No network scan passes but privacy manifest behavior is not reviewed.
- [ ] **Debt cleanup:** Item marked fixed without updating `PLANS.md` and the owning doc.

## Sources

- `PLANS.md` open technical debt TD-005, TD-008, TD-009, TD-010.
- `QUALITY_SCORE.md` current top repair queue and score gaps.
- `RELIABILITY.md` release readiness gates.
- `SECURITY.md` privacy and resource review gates.
- Apple official docs listed in `.planning/research/STACK.md`.

---
*Pitfalls research for: v1.4 Stability, QA, and Debt Cleanup*
*Researched: 2026-06-30*
