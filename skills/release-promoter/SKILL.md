---
name: release-promoter
description: "Load when creating a git tag for a release or promoting a release to GitHub — after a release PR merges. Runs the pre-tag verification gate (shallow temp-copy checkout, pinned-SHA submodule resolution, drift assertion, manifest-sourced canonical build and test) before any tag is created, then creates the annotated v-prefixed tag and the GitHub Release from it with the changelog body, verifying each step via the live API."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; verification gate restored from the #2439 gate, .opencode#2557 -->

# release-promoter

0. **Verification gate — before tag creation, exactly once per release.**
   Verify the release tree against a clean, shallow temp-copy checkout of the
   release commit; resolve submodules to gitlink-pinned SHAs; assert no drift;
   run the manifest-discovered canonical build and test commands and require
   zero failures. Any gate failure (`DRIFT_FAIL`, `MANIFEST_FAIL`, `BUILD_FAIL`)
   blocks promotion — no tag, no retries within the release run. The gate never
   modifies the source working tree. The full mechanism is the detail card:
   [the operating protocol](references/operating-protocol.md).
1. **Tag.** Annotated tag, `v`-prefixed, pointing at the merged release commit
   on the trunk; tag message names the release.
2. **GitHub Release.** Create from the tag with the changelog as body
   (`gh release create`); the tag and release exist together or neither does.
3. **Verify live.** Confirm tag and release via the API after creation —
   `gh release view` output is the evidence.
4. **No retries on partial state.** If a step half-succeeded, inspect actual
   state first; blind retries create duplicates.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
