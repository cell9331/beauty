schema: phase64-post-repair-security-v1
verification_stage: post_repair_security
independent: true
status: passed
threats_open: 0
threats_closed: 8
unresolved_high: 0
promotion_authorized: false
relevant_source_tree_oid: dfb7944365fdd7943ad3c115b519caa9da444be9

# Phase 64 Post-Repair Security Audit

OWASP ASVS Level 1. The audit treated every declared mitigation as absent until its implementation and fail-closed checks were verified against the frozen source and current authority inputs. All eight registered threats are closed. The dependency-surface guard is also satisfied; the frozen change does not add a package, model, network route, or dependency.

## Threat verification

| Threat | Category | Disposition | Result | Implementation evidence |
| --- | --- | --- | --- | --- |
| T-64-01 | Spoofing | mitigate | CLOSED | The renderer preflights the exact public-facade case before output creation; the strict helper requires the six fixed role/case names; the no-skip runner requires all eight suite-qualified opt-in identities exactly once. |
| T-64-02 | Tampering | mitigate | CLOSED | Output files are bounded regular no-follow inputs with an exact inventory and decoded limits. Private helper children have exact one-line schemas, bounded output, distinct self/live execution, locator rejection, and an exact complete-fraction evidence predicate. The full-suite parser rejects zero, failure, skip, ambiguity, duplicate identity, malformed UTF-8, timeout, and oversized output. |
| T-64-03 | Tampering | mitigate | CLOSED | The adversarial suite enforces the ordered 27-scenario inventory, bilateral six-family full-resolution truth, 744 runtime proposals, 1,632 protected pixels, exact protected/outside RGBA bytes, and active-peer behavior. Focused execution passed all six adversarial cases and fifteen provider cases. |
| T-64-04 | Information disclosure | mitigate | CLOSED | Durable output is reduced to fixed allowlisted aggregates. Generated artifacts remain ignored and untracked, helper output rejects private locators and sensitive field classes, and the repository scanner covers committed, staged, modified, and untracked content. |
| T-64-05 | Repudiation | mitigate | CLOSED | The authority parser requires one exact sorted 19-row manifest and a Git tree object, then independently compares every frozen blob with both index and bounded working-file bytes. The imported Phase 61 decoder is explicitly present in the closure. |
| T-64-06 | Information disclosure | mitigate | CLOSED | The four-state content scan passed. Private bundle reads require exact ignored membership and bounded no-follow regular files; the previously exposed teeth bundle additionally rejects every symlink component. Child environments and composition ownership are request-local, and proposal indices remain internal test-only evidence. |
| T-64-07 | Spoofing | mitigate | CLOSED | The strict security schema requires independent authorship and cannot grant promotion. The pre-promotion stage validator confirms the product owners remain quarantined, and duplicate or contradictory authority scalars are rejected. |
| T-64-08 | Elevation of privilege | mitigate | CLOSED | The checker binds the serial plan graph, lifecycle inventory, validation state, and fresh authority. This audit leaves canonical Phase 64 unchanged and authorizes only the later ordered verification plans. |

## Prior blocker closure

- Source closure: the runtime-imported Phase 61 PNG decoder is frozen as one of the exact nineteen blobs; tree, index, and worktree equality are mandatory.
- Bundle traversal: ignored bundle membership is exact, file descriptors use no-follow regular-file checks, and the hardened teeth bundle rejects both leaf and directory symlinks.
- Renderer destinations: output stems are case-folded and canonically decomposed before the output directory is created, closing case and Unicode-equivalent overwrite aliases.
- Cleanup containment: deletion is restricted to the single fixed work-root component. The trusted repository root, cleanup floor, initial target, and every recursive directory are bound to device/inode identity; descriptor-derived mount identity must remain equal; traversal and removal are descriptor-relative; non-regular entries, links, substitutions, cross-device entries, and mounted directories fail closed. Wrong-device, root-inode, target-inode, and external-link mutations leave the protected target intact.

## Bounded verification

- Private cleanup and strict-child self-test passed.
- No-skip parser rejected all fourteen mutations.
- Output helper passed all fourteen self-tests, including malformed, oversized, unexpected-inventory, and symlink cases.
- Closeout checker passed eighteen core mutations, twenty-three content-scan rejections, twenty-eight source-authority rejections, and twenty candidate rejections.
- Focused Swift execution passed twenty-two selected cases with no failure, including the normalized stem regression and all provider/adversarial cases.
- The four-state privacy check passed with every inventory class present and no sensitive match.

## Unregistered flags

None. The executor-recorded source-closure, bundle-link, filesystem-equivalent stem, descriptor cleanup, and mount/substitution surfaces map to the mitigations above.

relevant_source_manifest_begin
502c96aacf2a80394b176bf9c93ccb96bce73453  .planning/phases/59-teeth-evidence-and-admission-contract/59-private-evidence-runner.js
63b2d6104739c14f9aaa0ba83a76a05ba2a80aea  .planning/phases/61-teeth-output-safety-and-independent-closeout/check_teeth_renderer_outputs.py
fc494486201ccab82ffb3e55e3a6aa8086073420  .planning/phases/62-sclera-evidence-and-admission-contract/62-private-evidence-runner.js
20e7ec45e79ad33bff58af01d20c2075bd0bed61  .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-no-skip-swiftpm-runner.js
87953ac099aad9cd824ff00d113294af3566b558  .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/64-private-output-runner.js
969afd82ec87c21f1740eebc610bdb0e9a4f83e9  .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_phase64_sclera_closeout.py
e4e30224abfd0e48b46ee8edac80ff1ea425b56c  .planning/phases/64-sclera-output-adversarial-safety-and-independent-closeout/check_sclera_renderer_outputs.py
0e0f8aee76861e5fc60ac8f48daca6b37b24953b  BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessProvider.swift
e38f191d3a707ddb6d2821646fd842b2b9bf21e9  BeautySDK/Sources/BeautyEffects/LocalRetouch/BeautyScleraRednessTransform.swift
ed65274b8fd13ab0521e098eeacff3254eed220f  BeautySDK/Sources/BeautyEffects/Render/BeautyLocalRetouchComposition.swift
ded6a15331babcd7df2637032c0efdf11a31aaaa  BeautySDK/Sources/BeautyExampleRenderer/main.swift
07a87c2198de0c7e68c989d89766bed28bc0eeed  BeautySDK/Sources/BeautySDK/BeautyEngine.swift
7f8568788b981f6280aa84e1cef08346b26e22a3  BeautySDK/Tests/BeautyCoreTests/BeautyEngineLocalRetouchCompositionTests.swift
a77af968db21ea80b8fb1bc2d843c7d5df352f2d  BeautySDK/Tests/BeautyCoreTests/BeautyEngineScleraRednessIntegrationTests.swift
7aa383cc0ed1ddb95dd78c1770fde1ee7a76c6c2  BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift
8ba8e805d7abe6b6242493ab571e0f0d4d7b492b  BeautySDK/Tests/BeautyCoreTests/BeautyScleraRednessRealFixtureTests.swift
c7dcb39d1282d1efe40eb84ff4adf8bf12a11697  BeautySDK/Tests/BeautyEffectsTests/BeautyLocalRetouchCompositionTests.swift
00d0a759a6c3783186a43881c4f573a609171f59  BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessAdversarialCloseoutTests.swift
92b17b40dce4f93f804ca2ddfdcdb47211835982  BeautySDK/Tests/BeautyEffectsTests/BeautyScleraRednessProviderTests.swift
relevant_source_manifest_end
