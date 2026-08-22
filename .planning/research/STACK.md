# Stack Research: v1.18 Upper-Eyelid Fullness Reduction

**Milestone:** v1.18
**Researched:** 2026-08-22
**Decision mode:** Conditional productization

## Execution Note

Research was completed inline because this task did not authorize child agents. The survey covered papers, technical articles, public datasets, GitHub implementations, Apple platform documentation, and the repository's completed local-retouch spikes.

## Recommended Stack

| Layer | Choice | Role | Decision |
|---|---|---|---|
| Package/runtime | Existing Swift 6 SwiftPM package | Keep SDK-only delivery and current target boundaries | Retain |
| Input normalization | Existing canonical opaque sRGB RGBA8 path | Normalize orientation, mirror state, extent, alpha, and color before semantics | Retain |
| Coarse localization | Apple Vision face landmarks | Supply eye/brow envelopes and pose context only | Retain, but never treat as fullness semantics |
| Semantic support | Owned or rights-approved local evidence/model | Identify a conservative editable upper-eyelid region per eye | Required evidence; no public dependency selected |
| Baseline editor | Deterministic tone/frequency decomposition | Compress low-frequency fullness cues while carrying original high-frequency detail | Primary candidate |
| Learned comparator | Small additive blend-map model, only if owned/licensed | Predict bounded local color deltas rather than reconstructed pixels | Optional; must beat the baseline |
| Composition | Existing original-pixel local-retouch composer | Hard containment, collision-to-source, request-local masks, per-eye fail-closed behavior | Retain |
| CPU/GPU | CPU reference plus existing Metal identity transport | Make the CPU result authoritative and prove selected-output parity | Retain; no new backend/API |
| Tests | XCTest, SDK renderer, SDK-owned scripts | Pixel and metadata assertions, deterministic fixtures, sanitized review evidence | Extend |

## Runtime Recommendation

### Deterministic baseline

The first implementation candidate should be a bounded, per-eye tone/frequency operator:

1. derive a candidate envelope from Vision eye and eyebrow geometry;
2. intersect it with a semantic support mask that is owned by the request;
3. split local luminance into low- and high-frequency components;
4. reduce only the low-frequency bulge/shadow pattern within the support;
5. retain original high-frequency texture and original alpha;
6. compose from original pixels outside the selected local color delta.

This approach matches the completed spike evidence: the tone/frequency candidate retained texture energy at approximately `0.9996` and `0.9866` on the synthetic probes with zero measured leakage. That evidence is architectural, not product proof, because it lacks a genuine positive eyelid-fullness bundle.

### Optional learned comparator

If a model is evaluated, prefer a compact additive blend-map network over inpainting or full-image generation. A three-channel additive map can stay within the repository's original-pixel composition contract and can be clamped to the request-local support. Core ML is technically viable for local semantic segmentation or additive-map inference, but it should be introduced only after model ownership, data rights, failure behavior, and measurable superiority are established.

No external model dependency is recommended for the milestone baseline.

## Rejected Stack Choices

| Candidate | Why it is not selected |
|---|---|
| Generic face-parsing weights trained on CelebAMask-HQ or LaPa | Their labels do not encode upper-eyelid fullness; common data terms are noncommercial or restrict redistribution |
| RetouchFormer-style soft inpainting | Reconstructs local pixels, weakens identity/texture guarantees, and has no verified license path suitable for this SDK |
| AniEyelid or 3D/video eyelid reconstruction | Solves dynamic geometry reconstruction, not conservative still-image fullness reduction; data/code terms are not a product path |
| Vertical warp | The repository spike already invalidated it: texture retention fell to about `0.9305` and `0.9188` without clearer fullness benefit |
| Global smoothing or generic eye enlargement | Changes the wrong visual variables and cannot satisfy protected-region or semantic claims |
| Network/cloud inference | Conflicts with the local, privacy-preserving SDK boundary |

## Evidence and Tooling

- Deterministic generated fixtures remain suitable for geometry, containment, orientation, alpha, color-space, parity, and failure tests.
- A rights-approved local bundle containing genuine positives, negatives, ambiguous cases, and pose/identity stress cases is mandatory for semantic efficacy.
- Review tooling must export only aggregate metrics, fixture IDs, configuration hashes, and decisions. Raw pixels, masks, landmarks, private locators, and generated images stay out of persistent evidence.
- Real iPhone testing remains optional feedback after SDK completion and is not a milestone gate unless the user explicitly changes project policy.

## Dependency and License Position

- Keep the Swift package dependency graph unchanged for the deterministic baseline.
- Treat code license and training-data license as separate gates.
- Do not import public face-parser weights merely because their inference code is MIT licensed.
- Any Core ML artifact must have an owner, provenance record, permitted commercial use, redistribution rights, version/hash, and a fail-closed absence path before it can enter the package.

## Primary Sources

- [Periorbital semantic segmentation dataset and definitions](https://pmc.ncbi.nlm.nih.gov/articles/PMC12417369/)
- [Periorbital dataset code repository](https://github.com/aiolab/periorbital-dataset)
- [CelebAMask-HQ repository and terms](https://github.com/switchablenorms/CelebAMask-HQ)
- [LaPa dataset repository and terms](https://github.com/jd-opensource/lapa-dataset)
- [Generic face-parsing implementation](https://github.com/yakhyo/face-parsing)
- [Local Laplacian filters](https://people.csail.mit.edu/sparis/publi/2011/siggraph/)
- [Reference Local Laplacian implementation](https://github.com/psalvaggio/local_laplacian_filters)
- [Band-sifting filters](https://www.cs.cornell.edu/projects/band_sifting_filters/)
- [Lightweight Additive Blend Maps, AAAI 2026](https://ojs.aaai.org/index.php/AAAI/article/view/41481)
- [Apple Core ML semantic segmentation guidance](https://developer.apple.com/documentation/coreml/using-core-ml-for-semantic-image-segmentation)

---
*Research for v1.18 — upper-eyelid fullness reduction*
