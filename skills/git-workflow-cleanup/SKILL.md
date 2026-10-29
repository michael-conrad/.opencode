---
name: git-workflow-cleanup
description: "Load after any pull request merges — when the developer says \"pr merged\", \"merged\", or a merge event is otherwise confirmed. Verify the merge via the platform API, delete the feature branch (destructive-action gate applies on dispatched tasks), verify-and-sync issue closure from the PR body's closing keywords, sync the trunk, and remove work-state artifacts."
license: MIT
provenance: AI-authored, .opencode#2490; #1011 destructive-action gate; verify-and-sync closure, .opencode#2615; idempotent tag backstop at deletion, .opencode#2683
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #1011 destructive-action gate; verify-and-sync closure, .opencode#2615; idempotent tag backstop at deletion, .opencode#2683 -->

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
   **Before deletion — idempotent tag backstop (.opencode#2683):** for every
   submodule commit the branch's work recorded, run the tag-if-untagged check
   against the submodule's remote — if a recorded SHA is reachable by no
   pushed tag, create the annotated hash-permanence tag
   (`<parent-repo>/<issue-number>-<submodule-dir>`, the `git-workflow-branch`
   rule 3 format), push it, and verify on the remote, and push-reconcile any
   discipline tag found local-only — the branch deletion never removes the
   last capture path to a recorded pointer.
3. **Verify-and-sync closure.** Closing keywords in the PR body auto-close
   the remote issue at default-branch merge on platforms that support it
   (`git-workflow-pr` §4 names which platforms fall in which class); on
   platforms without closing-keyword support, closure happens here or on
   explicit developer instruction. Verify the remote closure state via the
   platform API first, then close/sync the local `.issues/` records to
   match — an issue the keywords already auto-closed is not closed again.
   Never speculatively; on a dispatched task, the dispatch prompt must
   explicitly name the closure and its target (floor: destructive-action
   gate).
4. **Sync the trunk** locally so the next branch starts from the tip.
5. **Remove work-state artifacts** (work files, scratch state) so stale state
   never misleads a later session.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
