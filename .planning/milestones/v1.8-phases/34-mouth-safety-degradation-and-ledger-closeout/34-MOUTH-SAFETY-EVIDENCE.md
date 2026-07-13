# Phase 34 Mouth Safety Evidence

full_suite_tests: 190

| Gate | Observed result |
| --- | --- |
| Focused mouth tests | 13/13 passed |
| Full SDK suite | 190/190 passed |
| Exact caps | `mouthSize ±0.35`, `mouthWidth ±0.35`, `smile 0.50`, `lipColor 0.50`; warning/count verified |
| Missing/no-face/stale | Geometry exact zero; missing/no-face lip color exact zero; safe domains continue |
| Reused | Geometry exact `0.5` post-cap scaling (`-0.175`, `0.175`, `0.25`); `lipColor` remains `0.50` |
| Stale lip color | Active at `0.50` when outer lips exist; color-domain, not geometry |
| Combined weakening | Five signed/directional geometry cases weaken; `lipColor` remains `0.50` |
| Renderer/helper | 238/238 outputs, 30/30 geometry ROI, 12/12 signed pairs, 6/6 color containment |
| Boundaries | Zero internal Demo/renderer imports, external dependencies, network/commercial paths, or tracked generated files |

Diagnostics remained stable-code/aggregate-only. No raw geometry or sensitive payload disclosure was introduced.

