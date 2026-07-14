# Phase 1: SDK Foundation and Public Facade - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-06-10
**Phase:** 1-SDK Foundation and Public Facade
**Areas discussed:** Public API shape, No-op output semantics, Parameter and preset validation strategy

---

## Public API Shape

### Processing Entry Naming

| Option | Description | Selected |
|--------|-------------|----------|
| `process(...)` overloads | Use `process(pixelBuffer:orientation:parameters:)` and `process(image:orientation:parameters:)`; matches existing design docs. | Yes |
| `processFrame(...)` / `processImage(...)` | More explicit at call sites, but diverges from the historical API draft. | |
| Single `BeautyInput` enum | More extensible, but adds a public abstraction in Phase 1. | |
| Other | User-provided freeform shape. | |

**User's choice:** `process(...)` overloads.
**Notes:** Keeps the public API aligned with `DESIGN.md` and `docs/05_public_api_design.md`.

### Process Return Values

| Option | Description | Selected |
|--------|-------------|----------|
| Direct media object returns | Return `CVPixelBuffer` for frame input and `CIImage` for image input. | Yes |
| Unified `BeautyResult` | Return one result envelope with output, warnings, and metrics. | |
| Dual API | Keep simple media-return APIs and add result/debug APIs. | |
| Other | User-provided freeform shape. | |

**User's choice:** Direct media object returns.
**Notes:** `BeautyResult` can still exist as a facade type without being the primary processing return value.

### Parameter Ownership

| Option | Description | Selected |
|--------|-------------|----------|
| Explicit parameters per process call | Every call receives a `BeautyParameters` snapshot. | Yes |
| Engine-owned current parameters | Call `updateParameters(...)`, then process without passing parameters. | |
| Support both | Maximum convenience, larger API and test surface. | |
| Other | User-provided freeform shape. | |

**User's choice:** Explicit parameters per process call.
**Notes:** Matches `DESIGN.md` D1 and avoids shared mutable engine state.

### BeautyResult Role

| Option | Description | Selected |
|--------|-------------|----------|
| Public lightweight `BeautyResult` model | Expose the model through the facade, but do not return it from primary `process(...)`. | Yes |
| Do not implement `BeautyResult` yet | Simpler, but conflicts with `SDK-02` facade type access. | |
| Full `BeautyResult` plus debug API | More complete, but expands foundation scope. | |
| Other | User-provided freeform shape. | |

**User's choice:** Public lightweight `BeautyResult` model.
**Notes:** Satisfies facade-access requirements while keeping primary process calls simple.

---

## No-op Output Semantics

### Output Object Semantics

| Option | Description | Selected |
|--------|-------------|----------|
| Return same input reference | Fastest no-op, but changes semantics when real rendering arrives. | |
| Copy to a new output object | Return an SDK-created or SDK-owned output even for no-op. | Yes |
| Path-specific behavior | Use different semantics for image and frame paths. | |
| Other | User-provided freeform shape. | |

**User's choice:** Copy to a new output object.
**Notes:** Keeps no-op and future real render semantics aligned for host apps.

### Unsupported Format Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Return typed error | Use `.unsupportedPixelFormat`, `.invalidInput`, or similar. | Yes |
| Fallback to original input | Makes no-op succeed but breaks output ownership semantics. | |
| Attempt format conversion | More capable, but expands Phase 1 scope. | |
| Other | User-provided freeform shape. | |

**User's choice:** Return typed error.
**Notes:** Do not silently return original input on output/copy failure.

### No-op Preservation Test

| Option | Description | Selected |
|--------|-------------|----------|
| Pixel equality or fixed tolerance | Compare fixture pixels to prove no-op preservation. | Yes |
| Size/format/non-empty only | Lightweight but does not prove visual preservation. | |
| Layered tests | Basic checks plus selected fixture preservation tests. | |
| Other | User-provided freeform shape. | |

**User's choice:** Pixel equality or fixed tolerance.
**Notes:** No-op correctness is part of the foundation contract.

### Output Lifecycle Documentation

| Option | Description | Selected |
|--------|-------------|----------|
| SDK-created output readable for current result lifecycle | Document without exposing internal buffer pool details. | Yes |
| Immediate consumption only | Safer for buffer pools but less friendly for image path. | |
| No lifecycle contract yet | Simpler but easy for host apps to misuse. | |
| Other | User-provided freeform shape. | |

**User's choice:** SDK-created output readable for current result lifecycle.
**Notes:** Keeps host-app expectations explicit while leaving implementation room.

---

## Parameter and Preset Validation Strategy

### Ordinary Out-of-range Values

| Option | Description | Selected |
|--------|-------------|----------|
| Clamp to valid range | Clamp values into `0...1` or `-1...1` as documented. | Yes |
| Throw or fail | Stricter, but complicates value-model initialization. | |
| Two-layer strategy | Clamp in initializer plus strict validation API. | |
| Other | User-provided freeform shape. | |

**User's choice:** Clamp to valid range.
**Notes:** Ordinary numeric range errors should not reach rendering.

### Non-finite Values

| Option | Description | Selected |
|--------|-------------|----------|
| Reset to default no-op value with validation warning | Prevent `NaN` or infinity from entering rendering. | Yes |
| Throw or fail | Strict, but requires throwing/failable value creation. | |
| Clamp to boundary | `NaN` has no direction and infinity could create strong effects. | |
| Other | User-provided freeform shape. | |

**User's choice:** Reset to default no-op value with validation warning.
**Notes:** Phase 1 can test that non-finite values become zero-effect defaults.

### Unknown JSON Fields

| Option | Description | Selected |
|--------|-------------|----------|
| Ignore unknown fields | Forward compatible; unknown fields do not enter model behavior. | Yes |
| Reject the preset | Catches typos but harms compatibility. | |
| Debug rejects and release ignores | Build-configuration-dependent behavior is complex. | |
| Other | User-provided freeform shape. | |

**User's choice:** Ignore unknown fields.
**Notes:** Unknown fields must not trigger behavior.

### Unknown Resource IDs

| Option | Description | Selected |
|--------|-------------|----------|
| Reject preset with typed error | Fail validation for unknown `filterId` or resource ID. | Yes |
| Clear unknown resource ID and continue | Partial application needs warning/UI synchronization semantics. | |
| Allow ID and fail at render time | Error is surfaced too late. | |
| Other | User-provided freeform shape. | |

**User's choice:** Reject preset with typed error.
**Notes:** Avoid pretending a resource-backed effect applied when its resource is unavailable.

### Built-in Preset Registry

| Option | Description | Selected |
|--------|-------------|----------|
| Model plus decoding/validation only | Keep Phase 1 focused; named built-in presets come later. | Yes |
| Minimal built-in registry | Adds early named IDs but creates product naming commitments. | |
| Complete v1 preset set | Valuable but belongs to Phase 5. | |
| Other | User-provided freeform shape. | |

**User's choice:** Model plus decoding/validation only.
**Notes:** Built-in Natural/Clear/Refined/Male Natural/ID Photo Natural presets are Phase 5 work.

---

## the agent's Discretion

None.

## Deferred Ideas

None.
