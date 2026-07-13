# Phase 34: Mouth Safety, Degradation, and Ledger Closeout - Context

**Gathered:** 2026-07-13
**Status:** Ready for planning
**Mode:** Autonomous smart discuss (`--auto`)

## Phase Boundary

Close MOUTH-05 through MOUTH-10 and DOC-01 for the four existing public mouth/lip fields. No new public field, Demo feature, dependency, network/commercial path, or tracked generated image is allowed.

## Locked Decisions

- `mouthSize` and `mouthWidth` stay signed; `smile` and `lipColor` stay positive-only. Exact effective caps are `±0.35`, `±0.35`, `0.50`, and `0.50`.
- No-face, missing outer lips, and stale geometry zero `mouthSize`, `mouthWidth`, and `smile`. Missing/no-face also zero and skip `lipColor`; unrelated color/filter domains continue.
- Reused geometry applies exact `0.5` sign-preserving scaling after caps to the three geometry fields.
- `lipColor` is independently color-domain: with outer lips present it remains active and unscaled for reused or stale geometry. It is neither combined-geometry weakened nor evidence for true `丰唇`.
- Combined face/eye/nose/mouth geometry weakens every mouth geometry direction, never `lipColor`.
- Promote exactly `大小`, `宽度`, and `微笑`; keep branch-level `嘴唇` partial and `上下`, `倾斜`, `左右`, `M唇`, `丰唇`, `白牙` future/partial.
- Diagnostics expose stable codes and aggregate counts only. Raw landmarks, boxes, control points, image bytes, file paths, and detector objects remain private.

## Evidence Strategy

Use focused normalization/resolver/provider tests, full SDK tests, renderer run plus Phase 33 helper, active-source boundary scans, zero tracked generated artifacts, and synchronized owning documents. Device parity, commercial visual approval, packaging, launch readiness, and whole-branch completion remain non-claims.

