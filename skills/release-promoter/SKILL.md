---
name: release-promoter
description: "Load when preparing a release PR, creating a git tag for a release, or promoting a release to GitHub. Runs the clean-room verification gate (shallow branch checkout from the project's own remote URL, pinned-SHA submodule resolution, drift assertion, manifest-sourced canonical build and test) after the release branch is pushed and before its PR is filed, then — post-merge — a drift and tree-identity re-check before creating the annotated v-prefixed tag and the GitHub Release with the changelog body, verifying each step via the live API."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; verification gate restored from the #2439 gate, .opencode#2557; gate moved pre-PR (after branch push, before PR filing; remote-transport-only clone) with post-merge TREE_MISMATCH re-check, .opencode#2590 -->

# release-promoter

0. **Clean-room verification gate — after the release branch is pushed, before the PR is filed.** Verify the release candidate (the release branch's head) from a clean, shallow temp-copy checkout cloned from the same remote URL the project itself is cloned from — remote transport only; resolve submodules to gitlink-pinned SHAs; assert no drift; run the manifest-discovered canonical build and test commands and require zero failures. Assertion failures (`DRIFT_FAIL`, `MANIFEST_FAIL`, `BUILD_FAIL`) block the PR — no retries within the release run; environment/transport setup failures are diagnosed and the gate re-run, never treated as release-blockers. The gate never modifies the source working tree. The full mechanism is the detail card: [the operating protocol](references/operating-protocol.md).
1. **Post-merge pre-tag re-check — after the release PR merges, before tag creation.** From a shallow temp-copy of the merged commit, assert submodule drift and that the merged tree is content-identical to the tree the clean-room gate verified. A `TREE_MISMATCH` blocks promotion — no tag — the release stops for developer direction.
2. **Tag.** Annotated tag, `v`-prefixed, pointing at the merged release commit on the trunk; tag message names the release.
3. **GitHub Release.** Create from the tag with the changelog as body (`gh release create`); the tag and release exist together or neither does.
4. **Verify live.** Confirm tag and release via the API after creation — `gh release view` output is the evidence.
5. **No retries on partial state.** If a step half-succeeded, inspect actual state first; blind retries create duplicates.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
