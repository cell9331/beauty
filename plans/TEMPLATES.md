# Planning templates and verification rules

## 6. Plan Template

Create a new plan by copying this structure and filling every field before implementation starts.

```markdown
### P-YYYY-MM-DD-short-slug

| Field | Value |
| --- | --- |
| Status | `planned` |
| Owner | Agent or human owner |
| Started | YYYY-MM-DD |
| Scope | One sentence describing the bounded task. |
| Source Request | User request, issue, or triggering document. |
| Current Step | First concrete step. |
| Verification Policy | Commands or checks required before completion. |

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
```

## 7. Completion Template

When moving a plan to Completed, include:

```markdown
### C-YYYY-MM-DD-short-slug

| Field | Value |
| --- | --- |
| Completed | YYYY-MM-DD |
| Scope | What changed. |
| Files | Files created or modified. |
| Verification | Commands or checks run, with result. |
| Build | Build/test status, or explicit reason not run. |

Outcome:

- Observable result.
- Remaining risk, if any.
```

## 8. Verification Log Rules

Verification records must include:

- Command or inspection performed.
- Result observed.
- Scope of confidence.
- Any skipped checks and reason.

Acceptable examples:

| Claim | Required Evidence |
| --- | --- |
| Markdown file generated | `wc -l`, heading scan, placeholder scan. |
| Swift code compiles | Exact `swift build` or `swift test` command with exit status. |
| Historical UI material is readable | Archive verification plus temporary-directory restoration evidence. |
| Performance target met | Device/simulator, resolution, duration, metric result. |
| Security constraint met | Specific validation/logging/resource test. |

不要把未经验证的主观判断写成验证结论。
