<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->
---
name: git-workflow-commit
description: Load before staging files, creating any commit, or writing a commit message in any repo — including when the developer says "commit this" or "save my work". Atomic commits stage only intended files; messages follow the repo convention; secrets never enter history. Submodule pointer updates ride with real parent-repo changes in the same commit.
license: MIT
provenance: AI-authored, .opencode#2490
---

# git-workflow-commit

1. **Atomic.** One logical change per commit. Stage named files only — never
   `git add -A` blindly; review the staged diff before committing.
2. **Message.** Follow the repo's convention (`type(#issue): summary` style in
   this deck's repos); body lines state what and why, not narration.
3. **Secrets.** Never commit keys, tokens, or credentials; redact on sight.
4. **Push.** Push the feature branch when the stage completes; the trunk is
   hook-protected — never push to the trunk-identified primary branch.
5. **Submodule pointers.** A `.opencode` pointer change in the parent rides
   with real parent changes in the same commit; pointer-only commits are a
   review-overhead defect.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
