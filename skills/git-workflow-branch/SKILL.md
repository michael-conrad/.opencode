---
name: git-workflow-branch
description: "Always load before creating any git branch or starting any work on a task in any repo — however small the task seems. Branch naming, trunk-freshness checks, submodule sync, provenance recording. Never commit directly to the trunk-identified primary branch; the feature branch exists before the first file modification."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# git-workflow-branch

1. **Branch before files.** Create the feature branch before any modification:
   `feature/<issue>-<slug>` (or `<issue>-<slug>` for parent-repo submodule work).
   Issues sharing an authorization scope share **one** feature branch — name it
   after the scope's primary issue; one branch per issue is the violation.
2. **Trunk freshness.** Verify the trunk tip before branching — sync and rebase
   if the trunk moved; state the verified tip in the work record. When scanning
   branches, `issues-data` is a reserved orphan-branch issue-store ref, checked
   out in a linked worktree (the `+` marker in `git branch -a`) — never a
   feature-branch naming or cleanup candidate (#2548 C8).
3. **Submodules.** When work spans the parent and `.opencode`, sync the
   submodule pointer discipline: the pointer update rides with the next real
   parent-repo change — never a pointer-only commit.
 4. **Provenance.** Record branch, base tip, and the issue in the work state so
    PR preparation can verify the chain later. **When the work has no issue,
    record branch and base tip only** — never create an issue, or initialize an
    issue store, to satisfy provenance; the record is input to PR prep, not a
    checklist that summons new machinery.
5. **Trunk protection.** The trunk commit/push check is enforced mechanically;
   treat any block as the hard boundary it is.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
