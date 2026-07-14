# Phase 23: Performance and Reliability Gates - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-01
**Phase:** 23-Performance and Reliability Gates
**Areas discussed:** Timing Gate Path, Long-Run Evidence Bar, Quality/Reset/Degradation Scope, Metrics And Redaction Evidence

---

## Timing Gate Path

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| Primary timing path | SDK 720p synthetic `CVPixelBuffer` loop | Runs through `BeautyEngine` and avoids the current Demo Metal Toolchain blocker. | ✓ |
| Primary timing path | Fixture / `CIImage` loop | Easier still-image path, but less representative of realtime preview. | |
| Primary timing path | Demo camera pipeline harness | Closer to preview, but vulnerable to Demo build/toolchain blockers. | |
| Case matrix | Representative current cases | Covers no-op, skin/color/filter, and high-but-capped cases without becoming Phase 24 renderer regression. | ✓ |
| Case matrix | No-op only | Fastest, but too thin for visible-effect load. | |
| Case matrix | All current renderer cases | Broader than Phase 23 and overlaps Phase 24. | |
| Budget judgment | Record-and-compare, no hard fail on first baseline | Compares against `RELIABILITY.md` budgets and records risk if over. | ✓ |
| Budget judgment | Hard gate | Forces optimization when over budget. | |
| Budget judgment | Evidence only | Records timing without budget interpretation. | |
| Evidence shape | Phase evidence Markdown + optional XCTest/helper output | Preserves command, environment, table, summary, and budget comparison. | ✓ |
| Evidence shape | Only XCTest assertions | More automated, less readable for first baseline. | |
| Evidence shape | Only manual command transcript | Quick but weaker for future comparison. | |

**User's choice:** SDK 720p synthetic `CVPixelBuffer` loop; representative current cases; record-and-compare baseline; Markdown evidence plus optional structured helper/test output.
**Notes:** User chose to move on after four Timing questions.

---

## Long-Run Evidence Bar

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| Primary long-run path | Automated fixture loop first | Produces repeatable evidence even if Demo simulator or device evidence is blocked. | ✓ |
| Primary long-run path | Demo simulator preview first | Closest to preview, but likely blocked by Metal Toolchain. | |
| Primary long-run path | Physical iPhone manual first | Closest to release risk, but hardware evidence is currently blocked. | |
| Primary long-run path | Blocker protocol only | Records how to run but adds no automated evidence. | |
| Memory judgment | Trend-based baseline, no strict MB gate first | Records start/end/peak or available metrics and looks for steady growth. | ✓ |
| Memory judgment | Strict threshold | Hard MB limit without historical baseline. | |
| Memory judgment | Command/protocol only | Too weak as evidence. | |
| Duration rule | Try 10 minutes when cheap; allow shorter baseline with explicit non-claim | Aligns to `RELIABILITY.md` while preserving honest blocker/limit language. | ✓ |
| Duration rule | Always require full 10 minutes | Strict but may block the phase. | |
| Duration rule | Short baseline is enough | Risks overclaiming long-run stability. | |
| Demo/device treatment | Secondary evidence or blocker record | Use if available, otherwise preserve blocker protocol without blocking SDK fixture evidence. | ✓ |
| Demo/device treatment | Required before completion | Would make fixture evidence insufficient. | |
| Demo/device treatment | Out of Phase 23 entirely | Would drop routed TD-008/TD-010 context. | |

**User's choice:** Automated fixture loop first; trend-based baseline; 10-minute target with shorter baseline non-claim allowed; Demo/device evidence secondary or blocker-recorded.
**Notes:** User chose to move on after four Long-run questions.

---

## Quality/Reset/Degradation Scope

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| Quality mode scope | Verify current contract + minimal meaningful behavior only if needed | Keeps `PERF-03` meaningful without expanding public/API/UI scope. | ✓ |
| Quality mode scope | Test configuration only | Conservative but may leave `PERF-03` hollow. | |
| Quality mode scope | Implement full quality-mode processing strategy | Broad rewrite risk. | |
| Reset scope | SDK engine + Demo pipelines | Covers `BeautyEngine`, camera reset, and still-image recovery behavior. | ✓ |
| Reset scope | SDK engine only | Leaves Demo pipeline reset/recovery thin. | |
| Reset scope | Full render/detection/resource caches | Claims caches that may not exist. | |
| Degradation evidence | Regression evidence over existing warning/metric paths | Proves performance work does not bypass caps/recovery rules. | ✓ |
| Degradation evidence | Only cite existing tests | Smaller but weaker against Phase 23 changes. | |
| Degradation evidence | Add visual/naturalness review | Out of Phase 23 reliability scope. | |
| Small-code-change boundary | Only internal behavior/tests, no public surface or UI change | Allows testable internal work while preserving v1.4 boundaries. | ✓ |
| Small-code-change boundary | No production code changes | May leave quality mode untestable. | |
| Small-code-change boundary | Allow broader quality-mode implementation | Scope expansion risk. | |

**User's choice:** Verify current quality-mode contract with minimal internal behavior if needed; cover SDK and Demo reset/recovery; use regression evidence for degradation and safety caps; keep any changes internal/test-focused.
**Notes:** User chose to move on after four Quality/Reset questions.

---

## Metrics And Redaction Evidence

| Question | Option | Description | Selected |
| --- | --- | --- | --- |
| Redaction proof | Structured evidence + redaction scans/tests | Limits output fields and scans for sensitive data leaks. | ✓ |
| Redaction proof | Use existing redaction tests only | Smaller but weak for new performance artifacts. | |
| Redaction proof | Add full logging subsystem | Too broad for Phase 23. | |
| Log config behavior | Keep logs optional/off by default; use structured test output | Preserves release defaults and avoids per-frame logging. | ✓ |
| Log config behavior | Enable performance logging in debug | More noisy and higher privacy risk. | |
| Log config behavior | Implement new public logging behavior | Public behavior expansion. | |
| Backpressure evidence | Existing Demo pipeline test + focused stress case if needed | Reuses current in-flight/drop/latest-frame-wins evidence without requiring live camera. | ✓ |
| Backpressure evidence | Only cite existing tests | Possibly sufficient but thin for `PERF-02`. | |
| Backpressure evidence | Require live camera/simulator proof | Too dependent on tooling/hardware. | |
| Public conclusion boundary | No release-grade performance/naturalness/device parity claims | Keeps conclusions tied to actual current evidence. | ✓ |
| Public conclusion boundary | Allow release-readiness claim if automated loop passes | Overclaims fixture evidence. | |
| Public conclusion boundary | No conclusions at all | Less useful for downstream planning. | |

**User's choice:** Structured redacted evidence; logs off/optional by default; existing backpressure tests plus narrow stress if needed; no release-grade overclaims.
**Notes:** User chose to move to final context after four Metrics/Redaction questions.

---

## the agent's Discretion

- Choose exact helper/test shape, warm-up count, sample count, memory API, artifact names, and evidence table columns.
- Add narrow internal tests/helpers if needed for meaningful evidence, as long as public/API/UI scope does not expand.

## Deferred Ideas

- Full renderer regression matrix belongs to Phase 24.
- Privacy manifest/resource trust/security closeout belongs to Phase 25.
- Full logging subsystem, MetricKit/signpost infrastructure, physical-device parity, and release-grade naturalness/performance claims remain future or blocked work.
