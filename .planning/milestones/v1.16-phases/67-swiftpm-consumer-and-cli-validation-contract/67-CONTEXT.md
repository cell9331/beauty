# Phase 67: SwiftPM Consumer and CLI Validation Contract - Context

**Gathered:** 2026-08-14
**Status:** Ready for planning
**Mode:** Auto-generated from locked user direction (`--auto`, discuss skipped)

<domain>
## Phase Boundary

Prove that a clean external Swift package can depend only on the public `BeautySDK` product, generate a synthetic image, execute a neutral public-facade request, and validate its output. Strengthen the existing SDK-owned `BeautyExampleRenderer` into a deterministic command-line input/output harness with case discovery, explicit output paths, a machine-readable aggregate report, typed failures, and non-zero exit behavior. Phase 67 uses only the CPU implementation and adds no Metal/GPU public API.

</domain>

<decisions>
## Implementation Decisions

### SwiftPM Consumer Contract
- Keep the consumer outside `BeautySDK` target internals and import only `BeautySDK`; no `@testable`, `BeautyCore`, `BeautyEffects`, Demo, Xcode project, simulator, or device dependency is allowed.
- Use a small repository-owned integration fixture/package with a local path dependency on `BeautySDK` and an executable public-API smoke program.
- Generate the input entirely in Swift so a clean clone needs no tracked image asset or optional portrait fixture.
- The consumer must assert public result success, exact dimensions, stable neutral semantics, and a concrete output observation rather than only proving compilation.

### CLI Contract
- Preserve the current 74 renderer cases and existing compatible `--input`, `--output`, `--case`, and `--no-watermark` behavior while adding deterministic `--list-cases` and machine-readable reporting.
- Require an explicit output directory for validation runs; no active behavior may depend on the removed Demo or on simulator/device/UI automation.
- Accept `--backend cpu` in v1.16 as the only valid backend token so Phase 67 establishes the future-neutral CLI shape without exposing a public SDK backend switch. Reject `gpu` and unknown values with a typed non-zero failure until v1.17.
- Emit one versioned JSON aggregate report with requested/succeeded/failed/skipped counts and stable input/case/output identities. Reports must contain no raw landmark, mask, face coordinate, user path beyond bounded public input/output labels, or private fixture metadata.

### Failure and Output Semantics
- Unknown flags/cases/backends, missing values/directories/images, duplicate stems, decode/render/encode/write failures, incomplete requested output, and report-write failures must fail non-zero with a stable typed diagnostic.
- A successful run returns zero only when every requested input×case output exists, is decodable, non-empty, and dimension-preserving, and the aggregate counts reconcile exactly.
- Generated output/report files remain ignored and reproducible; test fixtures use temporary directories and clean up after themselves.
- CLI contract tests should exercise the compiled executable through SwiftPM/`Process`, not reimplement argument parsing expectations in a disconnected test helper.

### the agent's Discretion
- Exact JSON field names/version tag, diagnostic code naming, fixture directory name, and whether CLI logic is factored into an internal source type are at the agent's discretion, provided the executable remains SDK-only and tests exercise the real public contract.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `BeautySDK/Package.swift` already exports the public `BeautySDK` library and `BeautyExampleRenderer` executable on macOS 14/iOS 17.
- `BeautySDK/Sources/BeautyExampleRenderer/main.swift` already defines 74 SDK-only public-facade cases and imports only `BeautySDK` plus Apple image frameworks.
- `BeautySDK/Tests/BeautyCoreTests/BeautyRendererOutputRegressionTests.swift` already freezes case inventory, facade-only imports, ignored output behavior, and selected output semantics.
- `scripts/run-no-skip-swiftpm.sh` is the mandatory one-child SwiftPM gate and can invoke bounded preflight scripts before its child.

### Established Patterns
- Mandatory clean-clone validation uses generated Swift fixtures; rights-approved portraits remain optional/private gates and cannot satisfy a mandatory check through a skip.
- Reports and diagnostics use aggregate, allowlisted identities and do not expose request-local geometry or masks.
- Existing source and renderer case IDs are compatibility surfaces; new behavior should preserve current IDs and neutral output semantics.

### Integration Points
- `BeautySDK/Package.swift` may need a testable internal CLI support target or executable tests while preserving the public product boundary.
- `BeautyExampleRenderer/main.swift` currently defaults input/output directories and prints human text; argument parsing, reporting, and exit status need a deterministic owner.
- A root `Fixtures/` or `IntegrationTests/` package plus a root script can prove external SwiftPM consumption without becoming part of the SDK product.
- Phase 68 will consume the synthetic fixture/oracle helpers but must not be pulled into this phase's CLI/consumer scope prematurely.

</code_context>

<specifics>
## Specific Ideas

The user explicitly wants tests to run Swift code that references the SDK through SPM and checks real input/output results. UI, Demo, simulator, device, and visual automation are not valid substitutes.

</specifics>

<deferred>
## Deferred Ideas

- GPU execution and public `.cpu`/`.gpu` SDK selection remain entirely v1.17.
- CPU feature-family oracle breadth, local-retouch adversarial metrics, and cross-request determinism belong to Phase 68.
- UI/Demo redevelopment, simulator/device testing, commercial approval, packaging, shipping, and release readiness remain out of scope.

</deferred>
