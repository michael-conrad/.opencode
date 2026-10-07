---
name: git-workflow-cleanup
description: "Load after any pull request merges — when the developer says \"pr merged\", \"merged\", or a merge event is otherwise confirmed. Verify the merge via the platform API, delete the feature branch (destructive-action gate applies on dispatched tasks), close the completed issues (the sole authorized closure path), sync the trunk, and remove work-state artifacts."
license: MIT
provenance: AI-authored, .opencode#2490; #1011 destructive-action gate
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #1011 destructive-action gate -->

# git-workflow-cleanup

1. **Verify the merge** via the platform API (`gh`/`gb`) — never assume from
   memory or cache; the API call is the evidence.
2. **Delete the feature branch** locally and on the remote — subject to the
   floor's destructive-action gate: on a dispatched task, only when the
   dispatch prompt explicitly names the deletion and its target; direct
   developer instruction (`pr merged` → cleanup) remains the sanctioned flow.
   `issues-data` is a reserved orphan-branch issue-store ref, checked out in a
   linked worktree (the `+` marker in `git branch -a`) — it is never a
   feature-branch cleanup candidate and never receives worktree removal
   (#2548 C8).
3. **Close issues** whose work the merged PR delivered — closure happens only
   here or on explicit developer instruction, never speculatively; on a
   dispatched task, the dispatch prompt must explicitly name the closure and
   its target (floor: destructive-action gate).
4. **Sync the trunk** locally so the next branch starts from the tip.
5. **Remove work-state artifacts** (work files, scratch state) so stale state
   never misleads a later session.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
