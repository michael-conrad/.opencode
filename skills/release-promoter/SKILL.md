---
name: release-promoter
description: "Load when preparing a release PR, creating a git tag for a release, or promoting a release to GitHub. Runs the clean-room verification gate (shallow checkout of the parent repository resolving every submodule through the parent's recorded pointers, drift assertion, build and test through the parent's build framework) after the parent's release branch is pushed and before the release PR is filed, then — post-merge — a drift and tree-identity re-check before creating the annotated v-prefixed tag and the GitHub Release with the changelog body, verifying each step via the live API. Release PRs are parent-repo artifacts only."
license: MIT
provenance: AI-authored, .opencode#2490; release-PR body composition, .opencode#2615
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; verification gate restored from the #2439 gate, .opencode#2557; gate moved pre-PR with post-merge TREE_MISMATCH re-check, .opencode#2590; parent-checkout boundary — initial clone is of the parent repository, release PRs are parent-repo artifacts only, .opencode#2592; release-PR body composition, .opencode#2615 -->

# release-promoter

0. **Clean-room verification gate — after the parent repository's release branch is pushed, before the release PR is filed.** Verify the release candidate from a clean, shallow temp-copy checkout of the **parent repository** — the repository the project family is consumed from — cloned from the parent repository's remote URL, remote transport only. The parent's submodule resolution (`git submodule update --init --depth 1`) brings the release candidate and its sibling submodules along at the parent's recorded pointers; assert no drift; run the build and test commands through the parent's build framework and require zero failures. Assertion failures (`DRIFT_FAIL`, `MANIFEST_FAIL`, `BUILD_FAIL`) block the release PR — no retries within the release run; environment/transport setup failures are diagnosed and the gate re-run, never treated as release-blockers. The gate never modifies the source working tree. A submodule repository never hosts its own release PR or tag — its content ships via the parent's pointer capture. The full mechanism is the detail card: [the operating protocol](references/operating-protocol.md). **Release PR body:** the changelog plus the Submodule-bump section (`git-workflow-pr` §4), with `Closes` lines only when a release issue exists.
1. **Post-merge pre-tag re-check — after the release PR merges, before tag creation.** From a shallow temp-copy of the parent's merged trunk commit, assert submodule drift against the parent's recorded pointers and that the composed tree is content-identical to the tree the clean-room gate verified. A `TREE_MISMATCH` blocks promotion — no tag — the release stops for developer direction.
2. **Tag.** Annotated tag, `v`-prefixed, pointing at the merged release commit on the parent repository's trunk; tag message names the release.
3. **GitHub Release.** Create from the tag with the changelog as body
   (`gh release create`) — the Release body stays changelog-only; the tag
   and release exist together or neither does.
4. **Verify live.** Confirm tag and release via the API after creation — `gh release view` output is the evidence.
5. **No retries on partial state.** If a step half-succeeded, inspect actual state first; blind retries create duplicates.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
