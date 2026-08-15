# Phase 66: Legacy UI/Demo Archive and SDK-Only Boundary - Context

**Gathered:** 2026-08-14
**Status:** Ready for planning
**Mode:** Auto-generated from locked user direction (`--auto`, discuss skipped)

<domain>
## Phase Boundary

Preserve `BeautyDemo/` and the legacy `meituxiuxiu/` UI-reference tree as verified ZIP archives, retain algorithm-relevant taxonomy in SDK-owned text, then remove the original application/UI files and all active Xcode, simulator, device, UI, and Demo validation dependencies. The active repository must end as an SDK/algorithm SwiftPM project. This phase adds no Metal behavior and changes no beauty algorithm.

</domain>

<decisions>
## Implementation Decisions

### Archive Ownership and Verification
- Archive `BeautyDemo/` and `meituxiuxiu/` separately under a repository-owned historical archive directory so their provenance and contents remain independently inspectable.
- Include intentional source/reference content, including currently ignored legacy reference assets that are part of `meituxiuxiu/`; exclude transient `.DS_Store`, caches, build products, and per-user Xcode state.
- Give each ZIP an explicit source scope, normalized sorted manifest, SHA-256 record, and verification command/script that checks archive integrity, exact entry inventory, extraction, and extracted content hashes before deletion.
- Do not delete the original trees until both archives have passed the verification gate; the retained ZIPs are intentional tracked history even though generated renderer output remains ignored.

### SDK-Only Boundary
- Preserve only algorithm/taxonomy knowledge from the legacy material in the canonical SDK documentation; visual layout, SwiftUI behavior, app navigation, and Demo lifecycle are historical rather than current requirements.
- Remove the Xcode application project, SwiftUI application/test sources, legacy UI-reference originals, and stale build/test commands after archive verification.
- SwiftPM products, SwiftPM tests, SDK-owned scripts, and `BeautyExampleRenderer` become the only active build/test/validation surfaces.
- Rewrite active documentation and repository checks rather than deleting historical archived milestone evidence; history may mention the old Demo but must not remain an executable current dependency.

### the agent's Discretion
- Exact archive directory and manifest file names, deterministic timestamp policy, archive tool implementation, and documentation grouping may follow repository conventions as long as they are reproducible, reviewable, and verified before removal.
- The agent may retain a minimal archive README and restoration instructions, but must not retain active UI source outside the ZIP artifacts.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK/Package.swift` already defines the public `BeautySDK` library and `BeautyExampleRenderer` executable.
- `scripts/run-no-skip-swiftpm.sh` already supplies the mandatory SwiftPM-only regression gate.
- Root architecture, design, product, reliability, security, and quality documents already distinguish SDK-core scope from Demo/product evidence and can become the canonical active authorities.

### Established Patterns
- Generated renderer output stays ignored and reproducible; repository-owned evidence uses deterministic text manifests and explicit checks rather than opaque success claims.
- The repository treats code/tests as authority, current root documents as contracts, and archived milestone material as immutable history.
- Privacy and fixture gates reject raw landmark/mask leakage and do not permit skipped optional tests to satisfy mandatory verification.

### Integration Points
- Root `AGENTS.md`, `ARCHITECTURE.md`, `FRONTEND.md`, `PRODUCT_SENSE.md`, `QUALITY_SCORE.md`, `PLANS.md`, `.gitignore`, and scripts may refer to the active Demo/Xcode surface and require synchronization.
- `BeautyDemo/` contains the active historical Xcode/SwiftUI tree; `meituxiuxiu/` contains legacy UI-reference material, much of it ignored/untracked.
- Phase 67 will strengthen the existing SwiftPM consumer/CLI surface after this phase removes application ownership.

</code_context>

<specifics>
## Specific Ideas

The user explicitly wants UI and Demo packaged as ZIP, original files removed, and all subsequent tests to run Swift code through SwiftPM/`BeautySDK`, checking actual input/output rather than simulator, device, UI, or Demo behavior.

</specifics>

<deferred>
## Deferred Ideas

- Metal implementation and CPU/GPU switching belong entirely to v1.17.
- UI/Demo redevelopment, simulator/device testing, commercial review, packaging, shipping, and release readiness are not planned.

</deferred>
