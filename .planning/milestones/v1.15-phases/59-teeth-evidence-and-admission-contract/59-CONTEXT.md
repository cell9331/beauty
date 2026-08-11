# Phase 59: Teeth Evidence and Admission Contract - Context

**Gathered:** 2026-08-05
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish the independent teeth-whitening evidence/admission contract and, only
after a qualifying teeth decision passes, expose one compatibility-safe,
positive-only `teethWhitening` SDK intent. The phase preserves exact absence of
production sclera-redness and `去脂` surfaces, keeps the existing still-image
canonical/request-local/privacy boundaries, and does not implement teeth masks,
providers, transforms, renderer output, Demo activation, or broader release
claims.

</domain>

<decisions>
## Implementation Decisions

### Genuine teeth evidence gate

- **D-01:** A teeth evidence bundle qualifies only when it contains at least one genuine discolored-teeth positive and one genuine already-light/negative, both explicitly assigned to `teeth_whitening`, with opaque fixture IDs, predeclared polarity/target, approved-internal-evaluation rights, and a complete exact-bound original/mask/after asset triple. Asset binding and completeness are part of admission, not post-review cleanup.
- **D-02:** Teeth acceptance criteria are frozen before any blinded original-detail review. The review uses structured target presence/improvement, mask coverage, protected-tissue leakage, naturalness, structure-change, decision, and fixed reason-code fields; thresholds cannot be tuned after inspecting output.
- **D-03:** `portrait_002/original.png` remains a C2PA-declared AI mechanics candidate with zero product-effectiveness, naturalness, or admission weight. Authorization-only, synthetic, mechanics-only, rejected, historical, and sibling-feature rows cannot satisfy the teeth gate, and sharing the original does not share a mask, after image, review, or decision with sclera.
- **D-04:** A missing, incomplete, unapproved, or failed teeth bundle is a valid closed decision, not an invitation to add a placeholder field or inert route. Only the independently passed teeth decision may open the public intent; no conditional or borrowed evidence may do so.

### Compatibility-safe teeth intent

- **D-05:** `teethWhitening` is one independent positive-only `Float` normalized to finite `0...1`, with default `0`; non-finite input normalizes to `0`, and finite out-of-range input clamps to the range. The normalized nonzero value is the only teeth intent considered for admission.
- **D-06:** Add the field append-only at the end of the existing parameter source, stored-field, `CodingKeys`, and construction order. Keep the initializer addition trailing with a default so existing labeled source calls compile unchanged; a missing key in any legacy payload decodes as neutral zero and no existing key is renamed or repurposed.
- **D-07:** Preserve the five existing bundled preset files and their established neutral compatibility behavior rather than rewriting legacy preset JSON merely to add a zero key. Each preset must decode with `teethWhitening == 0` unless a future teeth-specific preset is separately authorized; existing zero-output behavior remains byte/semantic neutral.
- **D-08:** The public contract exposes only the scalar intent. Raw teeth geometry, masks, candidate colors, fixture identities, rights/review data, gate status, and provider state remain package-private/request-local and absent from public, SPI, Codable, persistence, diagnostics, and network-facing state.

### Teeth-only admission and legacy isolation

- **D-09:** `BeautyEffectResolver.localRetouchAdmission(parameters:)` remains the sole production admission authority. A nonzero effective `teethWhitening` produces one teeth demand; zero, missing, or normalized-away input produces the existing `.none` behavior, and multiple eligible teeth signals never multiply canonicalization, Vision, mapping, or render requests.
- **D-10:** No global whitening/brightness/contrast/saturation/temperature/tint/exposure/shadow/highlight value, `lipColor`, geometry control, Testing-only injection, sclera intent, `去脂` proxy, or spelling/format alias may activate teeth admission. These inputs may retain their unrelated existing behavior but cannot be reinterpreted as teeth demand.
- **D-11:** Legacy payloads, legacy source construction, zero defaults, non-finite values, and unrelated shipped effects remain unchanged when teeth demand is absent. Teeth cannot borrow sibling evidence, support, failure state, cached state, or promotion authority, and sclera/`去脂` work cannot be enabled by a teeth request.
- **D-12:** Phase 59 admission is SDK-core and still-image only. It adds no teeth provider, mask/transform implementation, renderer case, saved-output claim, pixel-buffer/realtime path, external model/dependency, or SwiftUI/Demo control mapping; those downstream behaviors remain owned by later phases.

### Exact absence and verification boundary

- **D-13:** When Phase 59 closes, production contains no `scleraRednessReduction` or `去脂` field, CodingKey, source-construction argument, preset key, provider, renderer case, admission route, resource/model, or active Demo mapping. The existing disabled `白牙`, `祛红血丝`, and `去脂` taxonomy rows remain honest disabled states; adding the SDK intent does not activate the Demo.
- **D-14:** Compatibility proof covers the current model inventory plus one trailing teeth field, all five presets, default/finite/non-finite normalization, unequal-value Codable round trips, missing-key legacy decode, unchanged legacy construction, and exact neutral behavior. Existing renderer-case inventory and unrelated color/geometry behavior are not expanded by this phase.
- **D-15:** Admission proof uses a focused positive/negative matrix: only a direct normalized nonzero `teethWhitening` request may produce teeth demand, while every forbidden global-color, lip-color, geometry, Testing, sibling, missing/zero, legacy, alias, sclera, and `去脂` mutation remains absent or `.none`. Static identity scans must cover production source and the Demo boundary without treating historical/docs/mechanics-only references as product activation.
- **D-16:** Durable evidence output remains a sanitized aggregate/structured decision record with opaque IDs and fixed judgments/reasons only; local review media and paths remain ignored/disposable. Phase 59 may establish the gate and contract, but effectiveness, naturalness, visible output, protected-tissue safety, full regression, and `白牙` promotion are later closeout claims and must not be inferred here.

### the agent's Discretion

No unresolved discretionary decisions remain for this autonomous context pass. Implementation details may follow the existing v1.14 owners and tests as long as D-01 through D-16 and the phase boundary remain true.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase and milestone authority

- `.planning/ROADMAP.md` §Phase 59 — goal, dependencies, requirements, success criteria, and serial order.
- `.planning/REQUIREMENTS.md` — SEQ-01, EVID-07, TEETH-07, TEETH-08, v1.15 out-of-scope boundaries, and exact phase traceability.
- `.planning/PROJECT.md` — v1.15 independent teeth-first milestone boundary, `portrait_002` mechanics-only status, and nonclaims.
- `.planning/STATE.md` — current blockers, prior decisions, and the explicit absence of a rights-approved genuine teeth bundle.
- `PLANS.md` — active milestone ledger, Phase 54/56/58 evidence history, exact-absence patterns, and next-phase routing.

### Existing product and safety contracts

- `DESIGN.md` — Phase 53 canonical still-image/request-local handoff, exact current parameter/preset/renderer compatibility inventories, and the feature-neutral admission seam.
- `SECURITY.md` — independent evidence authority, local-only review/privacy boundary, sanitized durable output, and exact-absence protections.
- `RELIABILITY.md` — valid-but-closed evidence semantics, fail-closed recovery, request isolation, and unchanged no-admission behavior.
- `PRODUCT_SENSE.md` — conditional product acceptance, disabled Demo taxonomy, and promotion/non-promotion meaning.
- `.planning/milestones/v1.14-phases/54-rights-approved-evidence-and-eligibility-decisions/54-EVIDENCE-EVALUATION.md` — authoritative prior closed ledger, independent feature rows, zero product weight, and privacy/export rules.
- `.planning/milestones/v1.14-phases/56-independent-teeth-whitening-slice/56-03-SUMMARY.md` — prior exact closed-teeth false branch, disabled `白牙` state, and no-promotion/nonclaim boundaries.

### Validated spike and review findings

- `.codex/skills/spike-findings-beauty/references/licensed-fixture-evaluation.md` — complete rights-approved positive/negative bundle contract, frozen criteria, local blinded review, and sanitized structured export.
- `.codex/skills/spike-findings-beauty/references/teeth-whitening.md` — mechanics-only teeth findings, coarse lip-support limits, and the requirement for licensed protected-tissue review.
- `.codex/skills/spike-findings-beauty/references/still-image-integration.md` — canonical input, one request, request-local support, original-pixel ownership, and privacy/failure boundaries.

### Current implementation owners

- `BeautySDK/Sources/BeautyCore/Models/BeautyParameters.swift` — current append-only Codable parameter model, normalization, and legacy decode behavior.
- `BeautySDK/Sources/BeautyCore/Models/BeautyPreset.swift` and `BeautySDK/Sources/BeautyResources/Resources/Presets/` — bundled preset decoding and neutral compatibility behavior.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyEffectResolver.swift` — current sole production local-retouch admission owner, presently exact-empty.
- `BeautySDK/Sources/BeautyEffects/Planning/BeautyLocalRetouchAdmission.swift` — current feature-neutral opaque demand value and `.none` boundary.
- `BeautyDemo/BeautyDemoTests/BeautyDemoViewStateTests.swift` — exact disabled local-retouch taxonomy rows and forbidden active control IDs.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- `BeautyParameters` already centralizes explicit stored properties, `CodingKeys`, labeled construction, default values, and finite/range normalization; append the single teeth scalar at the existing model tail.
- `BeautyPreset` plus the five bundled JSON resources already provide the compatibility fixture surface; preserve their neutral decode behavior and source identity.
- The Phase 54 evidence/eligibility contract and local-only reviewer provide the established manifest, rights, structured-review, closed-ledger, and positive-allowlist patterns; reuse the pattern rather than inventing a second evidence authority.

### Established Patterns

- Current v1.14 local-retouch admission is deliberately exact-empty through `BeautyEffectResolver.localRetouchAdmission` and `BeautyLocalRetouchAdmission.none`; admission is a single request-scoped handoff, not one route per signal.
- Evidence gates are independent, valid-but-closed decisions with fixed reason codes and zero product weight. Mechanics/AI fixtures are useful for testing mechanics but never qualify product effectiveness or naturalness.
- Sensitive support and review media remain local/ignored and ephemeral; durable records are aggregate-only or fixed structured rows with no raw paths, masks, geometry, pixels, reviewer identity, or freeform text.
- The codebase's current model/tests are authoritative where the generated `.planning/codebase` maps are stale; production code and tests outrank the 2026-06-10 map claims.

### Integration Points

- The planned public scalar connects `BeautyParameters` normalization/Codable/preset compatibility to the resolver's teeth-only admission decision after the independent gate passes.
- Existing still-image `BeautySDK` facade entries and canonical request lifecycle remain unchanged in this phase; no provider, renderer, or pixel-buffer path is opened.
- The Demo keeps its three disabled local-retouch rows and nil control mappings. Static/source scans and focused model/admission tests are the primary Phase 59 verification seam.

</code_context>

<specifics>
## Specific Ideas

- Treat the current `portrait_002` original as mechanics-only despite its C2PA declaration; it cannot stand in for the missing rights-approved genuine positive/negative teeth bundle.
- Preserve the exact teeth-first order: an independently passed teeth decision precedes any teeth production route and precedes all sclera production work.
- Keep adaptive-teeth numerical thresholds as calibration seeds for later provider work, never as Phase 59 admission constants.

</specifics>

<deferred>
## Deferred Ideas

- Teeth mask/provider selection, bounded original-pixel whitening, protected-tissue safety, visible public-facade output, original-detail naturalness review, and exact `白牙` promotion belong to Phases 60–61.
- Sclera redness reduction belongs to Phases 62–64 and must not borrow teeth evidence or admission.
- `去脂`, realtime/pixel-buffer retouch, Demo activation, external models/cloud, tracked portrait media, device/performance budgets, commercial review, packaging, shipping, and launch readiness remain future or separately scoped.

</deferred>

---

*Phase: 59-Teeth Evidence and Admission Contract*
*Context gathered: 2026-08-05*
