# Phase 31 Patterns

| Target | Existing analog | Applied pattern |
| --- | --- | --- |
| Renderer cases | Phase 29 eye cases | Exact case inventory; one public field per case |
| Renderer test | `testPhase29EyeCasesUseOnlyExistingPublicEyeParameters` | Scope tokens and facade-only guards |
| Output helper | `check_eye_renderer_outputs.py` | Full PNG decode, dimension checks, watermark-excluded comparisons |
| Gallery | `CASE_GROUPS["eyes"]` | Generated ignored group with safe root deletion |
| Evidence | Phase 29 evidence/verification | Command-backed counts and conservative non-claims |
