<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->
---
name: git-workflow-conflict
description: Load when git reports conflicts during any rebase, merge, or cherry-pick, or when a push/PR shows merge contention. Analyze the intent behind both sides before resolving — never mechanically take ours or theirs — and verify the build and tests after resolution.
license: MIT
provenance: AI-authored, .opencode#2490
---

# git-workflow-conflict

1. **Intent before resolution.** For each conflicted hunk: what was each side
   trying to do? Classify — complementary (merge both), conflicting (one
   intent wins, justify), or stale (drop).
2. **Resolve by intent**, preserving both sides' meaning where complementary.
   Mechanical `--ours`/`--theirs` without analysis is a defect.
3. **Verify.** After resolution: build + run the relevant tests before
   continuing the operation.
4. **Abort is valid.** If intent cannot be determined confidently, abort the
   operation and consult the developer with the specific conflict — a wrong
   silent resolution is worse than a halted one.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
