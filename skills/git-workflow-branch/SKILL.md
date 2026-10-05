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
2. **Trunk freshness.** Verify the trunk tip before branching — sync and rebase
   if the trunk moved; state the verified tip in the work record.
3. **Submodules.** When work spans the parent and `.opencode`, sync the
   submodule pointer discipline: the pointer update rides with the next real
   parent-repo change — never a pointer-only commit.
4. **Provenance.** Record branch, base tip, and issue in the work state so PR
   preparation can verify the chain later.
5. **Trunk protection.** The trunk commit/push check is enforced mechanically;
   treat any block as the hard boundary it is.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
