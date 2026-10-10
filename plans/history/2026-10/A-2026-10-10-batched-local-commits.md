# A-2026-10-10-batched-local-commits

Status: `completed`. Branch: `codex/playbook-sdk-refactor`.

Owner request: 分批次提交代码。Only local commits in the current SDK repository;
no push, remote branch mutation or account/global configuration changes.
The external BeautyEditorApp currently has no Git repository, so its source and
verification remain in that authorized local directory without new Git history.

## Commit groups

| Batch | Commit | Purpose | Changed paths |
| --- | --- | --- | --- |
| 1 | `0e4867e796` | `feat(sdk): add owner-only landmark diagnostics` | 3 |
| 2 | `dfa46e0f5a` | `fix(effects): preserve independent dense geometry strengths` | 4 |
| 3 | `471f1ef9db` | `refactor(render): share still-image geometry preparation` | 8 |
| 4 | `d9ba59216e` | `feat(sdk): reuse detection for immutable photo editing` | 8 |
| 5 | `f4aedf7f35` | `docs: import playbook references and implementation guidance` | 29 |
| 6 | This record's commit | `docs: classify guides and synchronize SDK contracts` | Classified guides/history, current contract owners, plan/navigation and scoped commit verification. |

Each batch explicitly stages only reviewed paths and includes its related test
or record. Documentation relocation keeps canonical bodies and required legacy
navigation together; final current owners describe the delivered code. The
formal imported reference is `docs/beauty-sdk-playbook/`. The owner's original
root reference copy and its Python bytecode cache remain local and untracked;
no deletion, duplicate import, cache, model, media or build artifact was staged.

## Pre-commit finding and bounded repair

The prepared-photo suite's final Metal case uses the retained `renderBackend`
setting. Earlier boundary validation preceded that late test addition; the
commit-preparation live gate rejected its unregistered test revision. Register
only the inspected file SHA256
`82e68a8e622fa0e8609c9b63b0601bb029d0917c164e6d8ec6190066f08b2698`
in the existing audited-test hash mechanism. Its self-test now copies that
revision, admits the valid bytes, then appends a GPU declaration and requires
rejection. There is no perpetual path exemption or production GPU/backend/
shader admission change. The MediaPipe resource guide also explicitly limits
retained observations to the immutable prepared source.

## Actual verification and limits

- Each batch: exact staged path equality, reviewed byte fingerprints,
  UTF-8/non-symlink/artifact checks, staged diff whitespace and committed path
  equality. Index must start empty and return empty after every commit.
- After the narrow gate repair: post-archive SDK-only live gate and full boundary
  mutation self-test both pass. Both historical UI archive identities pass.
- Previous source test bytes are unchanged: bounded playbook SDK134/0/0,
  combination SDK25/0/0 and prepared-photo SDK65/0/0 plus native editor13/0/0
  retain their own executed scopes. Commit preparation does not claim fresh
  execution of those suites, a full SDK/App regression or physical-device/fps
  evidence.
- Final classification/navigation, moved document content and working-tree
  byte checks cover this commit operation only. Existing historical invalid
  links and closed effect failures are not rewritten or reopened.
