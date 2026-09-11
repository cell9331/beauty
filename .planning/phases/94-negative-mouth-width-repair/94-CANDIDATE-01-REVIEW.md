```json
{
  "schema": "phase94.candidate-review.1",
  "reviewer_role": "independent-parent",
  "verdict": "PASS",
  "unresolved_blockers": 0,
  "attempt": 1,
  "policy": "A",
  "begin_event_sha256": "82fa6084f070d41411b30768229b983e481ce771eee65341d55969daef029ca7",
  "provider_before_sha256": "d8f306e3643aca367451a3dbd3bc97c2208e0abfa9b4ab80fdfb3c4390fcc6b3",
  "provider_after_sha256": "26ce08d347bcd0db762120938f4c9c3ee59bf7b57b5eecb7a79e22f50467ce56",
  "frozen_inputs_sha256": "ed2c8f17c6b716e3a38b981210121ca33bcb339cfc15159cbc6058b8b120b7e4",
  "runner_sha256": "d7ddb91e59548f752422c62f91f632d8312a6cc57712d626300ef74ae370c45d",
  "compilation_receipt_sha256": "10ea815ada0bc3621737518816ac58625ba97dec513587196d933693bffa43b9"
}
```

Independent review: fixed policy A is implemented after retained signed/whole-support admission: radius clamp(g/8,0.035,0.20), displacement min(B*0.040,r/5,g/4)*u, unchanged legacy floor and makePoints. Removing exactly the dispatch and private helper reproduces the original provider bytes, including positive/shared behavior. No threshold, fixture, renderer or public API change was admitted.

The helper computes the sum of quadratic-field bounds from reconstructed Float vectors in Double, performs at most one prescribed scaling with the 16-ULP safety factor, reconstructs and rechecks bound<=0.8, strict inward/noncrossing targets and unchanged Y. Existing makePoints supplies finite/support/radius/emission admission. Invalid pairs return empty. This sufficient bound covers the two negative fields; it does not establish mixed-sibling, clamped/raster injectivity or portrait efficacy.

The counted A begin, compile receipt, original baseline classification, frozen F/P/L/oracle inputs and their independent reviews match current hashes. Compilation records exit0 and zero tests. This is independent code/compile review only: no seal, acceptance measurement, native execution or Phase94 completion claim.
