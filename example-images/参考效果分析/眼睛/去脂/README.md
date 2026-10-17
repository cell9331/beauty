# Upper-eyelid adjustment (去脂): source-relative evidence

[Test-only geometry research and validation](实施与验证.md) · [Implementation migration plan](改造计划.md) · [Separate evidence gaps](../证据缺口.md)

Analysis date: 2026-10-16. The reference UI labels this item **去脂**. The measured result is a localized upward displacement of upper-eyelid texture. The name alone does not establish a volume-removal, color, or shading mechanism.

**Owner disposition, 2026-10-17: deferred; skip further work for now.** Retain the existing prototype, measurements and failures without further fitting or integration. Continue the programme with 倾斜. This decision does not qualify or enable the feature.

Only one displayed state, `IMG_1938`, is available for this item. The comparison uses a separately supplied, globally aligned photograph, identified here as **S0**. S0 is supported as the same photographic content, but it is **not a certified neutral state**. Consequently, S0 → `IMG_1938` is a source-relative observation, not an isolated control span. Its amplitude cannot be assigned exclusively to this control.

| Result | Observed value |
| --- | --- |
| Independent stable-texture registration check | 131/153 accepted; residual median 0.072 px, P95 0.200 px |
| Broad eye-region NCC checks | 83/89 accepted; 31 accepted points exceed the 0.5 px audit threshold |
| Moving-point direction | Median `(dx,dy) = (−0.134, −1.223)` px; negative y is upward |
| Moving sparse-versus-dense method difference | Median 0.183 px, P95 0.598 px |
| Independent forehead / nose checks | 58/61 and 20/21 accepted; displacement P95 0.217 / 0.132 px |
| Qualification | Measured source-relative geometry; a test-only straight-frame prototype is mechanically tested but underfits the moving replay holdouts; no production SDK implementation or effect-reproduction claim |

All quantities use native aligned screenshot pixels. They are specific to this photograph and comparison.

- [Analysis and uncertainty](分析链路.md)
- [Candidate field and falsifiable checks](实现方案.md)
- [Local evidence and rerun boundary](本地测量说明.md)
- [Shared coordinates and rendering mathematics](../实现公共约定.md)

![Aligned source, observed state, forward dx/dy, and coordinate-labelled profiles](证据/位移证据.png)

The evidence image remains local under the repository's image-ignore rules. The aggregate text does not depend on a temporary session directory.

The owner-authorized 2026-10-17 follow-up is recorded in [Test-only geometry research and validation](实施与验证.md). The retained brightness-relief scalar and suspended host tool are unchanged. The new prototype does not establish a neutral, isolated control amplitude, semantic tissue owner or transferable parameters.
