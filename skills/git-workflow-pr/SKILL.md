---
name: git-workflow-pr
description: "Load before opening any pull request, preparing work for review, or updating an existing PR — in any repo, whether the developer says \"create pr\", \"open a PR\", or the work simply reaches the review boundary. Squash the branch's work to one reviewable commit per issue, write a PR body with summary and executed-test evidence, then HALT — humans merge, never the agent."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# git-workflow-pr

1. **Readiness.** The verify pass has produced PASS on the deliverable's SCs;
   structural checks (lint/typecheck/build) ran clean. Not ready → `verify`
   first, not a PR.
2. **Shape.** One PR per issue. Multiple WIP commits squash to one commit at
   PR creation; stacked work keeps its stack honest.
3. **Body.** Executive summary of what changed and why; the executed-test
   evidence (real output, not assertions); linked issue; provenance pointers.
4. **Create via the platform CLI** (`gh pr create` / `gb` equivalent) —
   authenticated tooling, never raw API calls.
5. **HALT after creation.** PR merge is a human gate. Notify and stop; update
   the PR only on review feedback.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
