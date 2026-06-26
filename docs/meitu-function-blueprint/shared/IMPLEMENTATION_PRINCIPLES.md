# Shared Implementation Principles

## Business Logic Principles

- Every branch has one status: `implemented`, `partial`, `blocked-by-geometry-output`, or `future`.
- Unsupported tools may be visible for taxonomy fidelity but must not pretend to work.
- Entry routes must preserve local-first behavior: camera/photo processing stays on device.
- Feature names may follow Meitu-style Chinese taxonomy in Demo, but SDK names stay stable and product-neutral.
- Cancel/confirm semantics belong to the editor shell, not individual effect providers.

## Technical Core Principles

- Public parameters remain normalized and serializable.
- Face-dependent effects degrade before failing.
- Geometry effects produce control intent and flow through unified render passes.
- Resource-backed effects must pass manifest validation before use.
- Debug/diagnostic surfaces expose redacted summaries only.
- Network-backed AI, resource/style systems, video/body pipelines, and account/gallery surfaces are outside this milestone.

## Evidence Ladder

| Status | Required evidence |
| --- | --- |
| `implemented` | Tests pass, boundaries are scanned, and public facade saved-image output exists when the branch has visible image output. |
| `partial` | Current public parameters, provider logic, resolver behavior, unit tests, or internal evidence exists, but visible branch completion is incomplete. |
| `blocked-by-geometry-output` | The branch is blocked by missing public facade detection plus geometry render integration for saved-image output. |
| `future` | No current v1.3 implementation claim; planning may describe business behavior and future dependencies only. |

Provider/resolver evidence for geometry is not the same as facade-visible saved-image completion. A geometry branch remains below `implemented` until the public `BeautySDK` facade can process the branch and `BeautyExampleRenderer` can save representative same-dimension output.

## Documentation Checklist

Every branch README should answer:

1. What user-visible behavior is expected?
2. Which SDK/Demo modules own it?
3. Which inputs are required?
4. What state transitions matter?
5. What is out of scope?
6. How would a future implementation be verified?
