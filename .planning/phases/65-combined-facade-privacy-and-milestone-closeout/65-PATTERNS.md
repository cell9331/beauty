# Phase 65 Existing Patterns

| Need | Reuse | Phase 65 adaptation |
| --- | --- | --- |
| Public combined request | `BeautyEngineScleraRednessIntegrationTests` | Fresh teeth-only/sclera-only/both harnesses and an independent byte merge oracle. |
| Collision/failure semantics | `BeautyLocalRetouchCompositionTests` and `BeautyEngineLocalRetouchCompositionTests` | Retain literal source/collision/four-unit-failure oracles; map concepts only in tests. |
| Request-local recovery | Phase 53/60/63 valid-invalid-valid, parallel, reset and publication tests | Add combined mixed-request sequences; no production state. |
| Private evidence | Phase 59/62 fixed-output runners and Phase 61/64 output runners | Rerun independently with fixed status; do not merge fixture authorities. |
| Compatibility/privacy | Phase 58 closeout checker and Phase 64 tracked/staged scanner | New current-state checker; never edit or trust old denominators blindly. |
| Lifecycle | Phase 64 verification plus `gsd-audit-milestone` | Phase verification first, separate v1.15 audit second, no archive/tag preclaim. |

## Implementation Constraints

- Prefer a new focused XCTest owner over changes to provider or composition
  code. The only anticipated source edit is one Testing-only support fixture.
- Construct expected bytes independently from standalone outputs and immutable
  source; production helpers may render inputs but may not build the oracle.
- Use fresh harnesses for standalone and combined runs. Sharing one sequential
  harness would make retained-state bugs indistinguishable from merge behavior.
- Keep failure quadrants explicit: teeth, whole sclera, left eye and right eye.
  A broad malformed/no-face assertion cannot replace them.
- Keep exact inventories and all forbidden-surface scans centralized in one
  mutation-tested checker with fixed path-free output.
- Root and lifecycle owners update only after full focused/private/opt-in/full
  conjunction and independent verification.
