# Feature Research

**Domain:** iOS beauty SDK hardening and technical-debt cleanup.
**Researched:** 2026-06-30
**Confidence:** HIGH for project-local gaps, MEDIUM for exact phase sizing.

## Feature Landscape

### Table Stakes

| Feature | Why Expected | Complexity | Notes |
| --- | --- | --- | --- |
| Quality/debt baseline audit | A hardening milestone must start from known gaps, not assumptions. | LOW | Refresh `QUALITY_SCORE.md`, `PLANS.md`, `.planning/PROJECT.md`, and open debt status. |
| Full existing test/build sweep | Existing behavior must stay stable before optimization. | MEDIUM | Include SwiftPM SDK tests and Demo xcodebuild when local simulator state allows it. |
| Automated Demo visual evidence | v1.1/v1.2 retained visual references but UI automation is still future. | MEDIUM | Prefer stable launch routes and simulator screenshots over manual-only proof. |
| Performance budget evidence | `RELIABILITY.md` defines budgets but current score shows performance tests at 0. | HIGH | Start with measurable 720p renderer/pipeline budgets and documented environment limits. |
| Long-run reliability evidence | Release readiness requires no continuous memory growth. | HIGH | Automate where possible; document manual/hardware protocol where not possible locally. |
| Renderer output regression | Example output exists but should become a stable regression gate. | MEDIUM | Cover no-op tolerance, visible output, dimensions, watermarks, and known geometry limitations. |
| Privacy/resource review | Distribution-like claims need privacy manifest and trust-boundary review. | MEDIUM | Assess `PrivacyInfo.xcprivacy`, resource IDs, redaction, and no-network invariants. |

### Differentiators

| Feature | Value Proposition | Complexity | Notes |
| --- | --- | --- | --- |
| First-principles quality gates | Future feature work starts from measured constraints. | MEDIUM | Convert vague release risks into commands, artifacts, and acceptance criteria. |
| Honest release readiness | Prevents overclaiming visual naturalness, performance, or device parity. | LOW | Record what passed, what is blocked by hardware, and what remains future. |
| Traceable debt closure | Makes cleanup visible to future agents. | LOW | Every closed debt item should cite evidence and commit scope. |

### Anti-Features

| Feature | Why Requested | Why Problematic | Alternative |
| --- | --- | --- | --- |
| New Meitu product areas | Tempting after core module closeout. | Adds breadth before release risks are measured. | Keep Home/discovery, AI/background, video/body, account, payment, and entitlement future. |
| Public API expansion | May seem needed for tests or geometry output. | Changes contracts and expands compatibility risk. | Use existing public facade unless a later phase explicitly promotes API changes. |
| Screenshot-only quality claims | Easy to capture. | Screenshots alone do not prove performance, naturalness, or device parity. | Pair screenshots with test/build/performance evidence and manual protocols. |
| Blanket historical-doc rewrites | Can make docs look cleaner. | Risks overwriting useful history or unrelated user changes. | Only update current owner docs and record separate debt for broader cleanup. |

## Feature Dependencies

```text
Baseline audit
    -> Requirements and roadmap confidence
    -> Automated QA
    -> Performance/reliability gates
    -> Renderer regression
    -> Security/distribution cleanup
    -> Milestone closeout
```

### Dependency Notes

- Baseline audit must precede optimization so the milestone fixes real gaps instead of speculative issues.
- Automated visual QA should precede UI/layout cleanup because it creates regression evidence for existing Demo surfaces.
- Performance and long-run gates should precede performance tuning claims because budgets without measurements are not useful.
- Security/distribution cleanup depends on knowing whether any metric/log/resource behavior changed.

## MVP Definition for v1.4

### Launch With

- [ ] Current quality/debt baseline refreshed and traceable.
- [ ] Existing SDK and Demo verification commands either pass or record reproducible local blockers.
- [ ] Automated or documented visual QA evidence for current Demo surfaces.
- [ ] Performance/reliability budgets have executable checks or documented manual protocols.
- [ ] Renderer output regression covers current visible output cases and no-op behavior.
- [ ] Privacy manifest/resource/logging review is complete.

### Future Consideration

- [ ] New public geometry saved-image output.
- [ ] New public beauty parameters.
- [ ] Full commercial SDK packaging or XCFramework distribution.
- [ ] New Meitu product areas.

## Sources

- `.planning/PROJECT.md` current next-milestone candidates.
- `QUALITY_SCORE.md` performance, UI automation, privacy manifest, render, reliability, and docs score gaps.
- `RELIABILITY.md` service-level targets and release readiness gates.
- `SECURITY.md` privacy manifest and resource trust boundary.
- Apple official docs listed in `.planning/research/STACK.md`.

---
*Feature research for: v1.4 Stability, QA, and Debt Cleanup*
*Researched: 2026-06-30*
