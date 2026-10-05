---
name: release-promoter
description: "Load when creating a git tag for a release or promoting a release to GitHub — after a release PR merges. Creates the annotated v-prefixed tag and the GitHub Release from it with the changelog body, verifying each step via the live API."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# release-promoter

1. **Tag.** Annotated tag, `v`-prefixed, pointing at the merged release commit
   on the trunk; tag message names the release.
2. **GitHub Release.** Create from the tag with the changelog as body
   (`gh release create`); the tag and release exist together or neither does.
3. **Verify live.** Confirm tag and release via the API after creation —
   `gh release view` output is the evidence.
4. **No retries on partial state.** If a step half-succeeded, inspect actual
   state first; blind retries create duplicates.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
