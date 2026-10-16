# Planning templates and verification rules

## Plan Template

Prefer updating an existing matching plan. New tasks use
`plans/active/A-YYYY-MM-DD-short-slug.md`; fill the scope and verification policy
before implementation. The ID stays stable when moved to history. PLANS and
its indexes contain a summary/link rather than a second full plan.

```markdown
# A-YYYY-MM-DD-short-slug

| Field | Value |
| --- | --- |
| Status | `planned` |
| Owner | Agent or human owner |
| Started | YYYY-MM-DD |
| Scope | One sentence describing the bounded task. |
| Source Request | User request, issue, or triggering document. |
| Expected Behavior | Observable change and preserved contracts; distinguish implementation from effect qualification. |
| Current Step | First concrete step. |
| Verification Policy | Smallest sufficient commands/oracles and direct dependent paths; explain any required full regression. |

Checklist:

| Step | Status | Evidence |
| --- | --- | --- |
| Define scope | `planned` | Evidence will be added when complete. |
| Implement or edit | `planned` | Evidence will be added when complete. |
| Verify | `planned` | Evidence will be added when complete. |
| Record outcome | `planned` | Evidence will be added when complete. |

Open Questions:

| Question | Current Decision |
| --- | --- |
| Decision needed | Decision owner and current state. |

Preservation and exclusions:

- Existing/concurrent edits, frozen evidence and out-of-scope paths to preserve.
- What this task does not claim or authorize.
```

## Completion Template

Move the same plan to `plans/history/YYYY-MM/<ID>.md`; add its link to the
month index and a `C-...` summary in PLANS. Keep failed attempts and their
meaning. Use `completed` only for the declared achieved scope; a bounded
terminal `closed_with_unmet_objectives` is not a delivered effect.

```markdown
### C-YYYY-MM-DD-short-slug

| Field | Value |
| --- | --- |
| Completed | YYYY-MM-DD |
| Status | `completed` or the actual terminal state from PLANS. |
| Scope | What changed. |
| Rationale | Why this change was needed. |
| Files | Files created or modified. |
| Verification | Commands or checks run, with result. |
| Build | Build/test status, or explicit reason not run. |
| Limits | Unverified scope, remaining risk and separate effect qualification. |

Outcome:

- Observable result.
- Remaining risk, if any.
```

## Verification Log Rules

Verification records must include:

- Command or inspection performed.
- Result observed.
- Scope of confidence.
- Any skipped checks and reason.
- Exact executed-test scope, failures/skips and whether Metal actually ran;
  distinguish a control self-test from SDK execution and a dated receipt from a new run.

Choose checks using [QUALITY_SCORE](../QUALITY_SCORE.md#verification-gates).
Pure prose does not require compiling/rerunning the SDK; a behavior change needs
its relevant tests and applicable independent pixel oracle. Complete milestone
closeout retains the complete no-skip gate. Never shrink scope by disabling a
verifier, bypassing a required gate or reporting zero executed tests as success.

Acceptable examples:

| Claim | Required Evidence |
| --- | --- |
| Markdown file generated | `wc -l`, heading scan, placeholder scan. |
| Swift code compiles | Exact `swift build` or `swift test` command with exit status. |
| Historical UI material is readable | Archive verification plus temporary-directory restoration evidence. |
| Performance target met | Device/simulator, resolution, duration, metric result. |
| Security constraint met | Specific validation/logging/resource test. |

不要把未经验证的主观判断写成验证结论。
