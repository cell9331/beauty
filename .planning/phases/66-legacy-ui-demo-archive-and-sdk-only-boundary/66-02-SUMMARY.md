---
phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
plan: "02"
subsystem: archive
tags: [zip, sha256, deterministic-archive, guarded-retirement, sdk-only]

requires:
  - phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary
    plan: "01"
    provides: deterministic dual-root archive tooling and exact-target retirement guards
provides:
  - Independently recoverable v1.16 ZIP archives for the complete intentional BeautyDemo and meituxiuxiu inventories
  - SHA-256 manifests and deterministic byte-for-byte reproduction evidence
  - Guarded removal of the two exact legacy source roots with an exact tracked-deletion allowlist
affects: [66-03-sdk-only-closeout, phase-67]

tech-stack:
  added: []
  patterns: [digest-bound destructive transaction, independent live-manifest-zip-extraction equality]

key-files:
  created:
    - archives/legacy-ui/BeautyDemo-v1.16.zip
    - archives/legacy-ui/BeautyDemo-v1.16.manifest.tsv
    - archives/legacy-ui/BeautyDemo-v1.16.zip.sha256
    - archives/legacy-ui/meituxiuxiu-v1.16.zip
    - archives/legacy-ui/meituxiuxiu-v1.16.manifest.tsv
    - archives/legacy-ui/meituxiuxiu-v1.16.zip.sha256
  modified:
    - BeautyDemo/
    - meituxiuxiu/

key-decisions:
  - "The retained archives contain the complete intentional live inventories: 45 BeautyDemo files and 26 meituxiuxiu files, including all 19 ignored PNG references."
  - "Original removal was authorized only through the digest-bound guarded retire transaction after fresh combined verification and reproduction."

patterns-established:
  - "Historical binary retention: intentional ZIP artifacts are committed together with sorted path/size/content-hash manifests and ZIP digest records."
  - "Retirement evidence: exact targets, digest approval, tracked deletion allowlist, and unrelated sentinel survival are proven in one guarded transaction."

requirements-completed: [ARCHIVE-01, ARCHIVE-02, ARCHIVE-03]

duration: 2min
completed: 2026-08-14
---

# Phase 66 Plan 02: Legacy UI/Demo Archive and Retirement Summary

**Deterministic, content-hashed archives retain 45 BeautyDemo files and 26 legacy UI-reference files while a digest-bound transaction retires only the two original roots**

## Performance

- **Duration:** 2 min
- **Started:** 2026-08-14T02:17:01Z
- **Completed:** 2026-08-14T02:19:21Z
- **Tasks:** 2
- **Files modified:** 59

## Accomplishments

- Created and committed two deterministic ZIPs plus sorted per-file manifests and ZIP SHA-256 records.
- Independently proved live filesystem, manifest, ZIP listing/content, and fresh temporary extraction equality for every retained file; a separate reproduction rebuilt all six artifacts byte-for-byte.
- Preserved all 45 intentional BeautyDemo files while excluding only the tracked per-user `xcuserdata` scheme-management file and ignored transient state.
- Preserved the exact meituxiuxiu inventory of 19 ignored PNG references and seven text/HTML map files.
- Removed exactly 53 tracked source files through the guarded retirement transaction, with zero unrelated tracked deletions and all SDK/documentation/planning/private-fixture sentinels intact.

## Task Commits

Each task was committed atomically:

1. **Task 1: Materialize and independently verify both archives** - `6d64a6a` (feat)
2. **Task 2: Retire the exact original UI/Demo trees through the guarded transaction** - `8a9274a` (chore)

## Files Created/Modified

- `archives/legacy-ui/BeautyDemo-v1.16.zip` - Deterministic archive of the complete intentional 45-file Demo inventory.
- `archives/legacy-ui/BeautyDemo-v1.16.manifest.tsv` - Sorted path, size, and content SHA-256 evidence for BeautyDemo.
- `archives/legacy-ui/BeautyDemo-v1.16.zip.sha256` - ZIP digest `04c14bbaa201cc6e9100f4c7b272b697670014041e62804dfa2f561faa29db52`.
- `archives/legacy-ui/meituxiuxiu-v1.16.zip` - Deterministic archive of 19 PNG references plus seven text/HTML files.
- `archives/legacy-ui/meituxiuxiu-v1.16.manifest.tsv` - Sorted path, size, and content SHA-256 evidence for meituxiuxiu.
- `archives/legacy-ui/meituxiuxiu-v1.16.zip.sha256` - ZIP digest `330e8aa08155eb4ad3a7b2ab84773a8279a8cd3ae87d4737b93e2491232fce9a`.
- `BeautyDemo/` - Exact historical application/Xcode tree retired after archive approval.
- `meituxiuxiu/` - Exact historical UI-reference tree retired after archive approval.

## Decisions Made

- Accepted only the tool-defined transient/per-user exclusions; no intentional source, test, project data, UI map, HTML reference, or PNG reference was omitted.
- Bound the destructive transaction to both freshly verified ZIP digests and invoked only `archive-legacy-ui.py retire`; no manual deletion path was used.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Metadata state] Corrected malformed state-handler output**
- **Found during:** Plan metadata update
- **Issue:** The state handlers wrote progress as 0%, inserted the Plan 02 metric into Deferred Items, and left ROADMAP at 1/3 plans despite detecting two summaries.
- **Fix:** Corrected the progress counters/bar, milestone totals, current activity/next action, and Phase 66 roadmap count while preserving the phase as in progress at Plan 3 of 3.
- **Files modified:** `.planning/STATE.md`, `.planning/ROADMAP.md`
- **Verification:** STATE and ROADMAP both report two completed summaries, 67% progress, and Plan 66-03 as next without marking Phase 66 complete.
- **Committed in:** Plan metadata commit

---

**Total deviations:** 1 auto-fixed (1 metadata state bug)
**Impact on plan:** Metadata only; archive materialization and guarded retirement scope remained unchanged.

## Issues Encountered

- The extra post-archive SDK-only scanner correctly reports that `AGENTS.md` has not yet been rewritten to carry the new SDK-only/SwiftPM current boundary. That documentation migration belongs to Plan 66-03; archive verification, retirement postconditions, and this plan's success criteria all pass independently.
- Serena tools were not exposed in this executor session, so inventory and structural verification used the committed archive tool, Git, shell checks, and an independent Python verifier.

## Verification

- `bash scripts/check-sdk-only-boundary.sh --pre-archive` - passed before artifact creation.
- Independent inventory audit - BeautyDemo `45` included / `46` tracked with exactly one excluded `xcuserdata` file; meituxiuxiu `26` included with exactly `19` ignored PNGs and `7` text/HTML files.
- `python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui` - both digests, safe paths, normalized metadata, exact listings, temporary extraction, and content hashes passed before and after retirement.
- `python3 scripts/archive-legacy-ui.py reproduce --output archives/legacy-ui` - all six artifacts rebuilt byte-identically from the live sources before retirement.
- Independent live/manifest/ZIP/extraction comparison - exact equality passed for all `45 + 26` files.
- `python3 scripts/archive-legacy-ui.py retire ... --yes-retire-exact-sources` - fresh combined verification/reproduction and digest approvals passed before retiring the two exact roots.
- `python3 scripts/archive-legacy-ui.py retire --output archives/legacy-ui --verify-only-postcondition` - passed after retirement and again after the deletion commit.
- Exact tracked deletion comparison - `53/53` expected deletions, `0` unrelated deletions.
- Required SDK, docs, planning, authorization, and optional private portrait sentinels survived unchanged.
- `git diff --check` - passed.

## User Setup Required

None - no external service configuration is required.

## Next Phase Readiness

- Plan 66-03 can now rewrite active owners and validation commands against an SDK-only/SwiftPM repository while retaining the verified historical archives.
- The legacy source roots are absent; their 71 intentional files remain independently recoverable from verified artifacts.
- No SDK, Metal, UI, or beauty-algorithm behavior changed.

## Self-Check: PASSED

- All six retained artifacts exist and both archive digests verify.
- Task commits `6d64a6a` and `8a9274a` exist in repository history.
- `BeautyDemo/` and `meituxiuxiu/` are absent.
- The deletion commit contains exactly 53 source-root deletions and no unrelated deletion.

---
*Phase: 66-legacy-ui-demo-archive-and-sdk-only-boundary*
*Completed: 2026-08-14*
