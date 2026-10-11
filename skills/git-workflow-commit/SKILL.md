---
name: git-workflow-commit
description: "Always load before staging files or creating ANY commit — however small — in any repo, including when the developer says \"commit this\" or \"save my work\". Atomic commits stage only intended files; messages follow the repo convention; secrets never enter history. Submodule pointer updates ride with real parent-repo changes in the same commit."
license: MIT
provenance: AI-authored, .opencode#2490; submodule discipline rules, .opencode#2563
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; submodule discipline rules, .opencode#2563 -->

# git-workflow-commit

1. **Atomic.** One logical change per commit. Stage named files only — never
   `git add -A` blindly; review the staged diff before committing.
2. **Message.** Follow the repo's convention (`type(#issue): summary` style in
   this deck's repos); body lines state what and why, not narration.
3. **Secrets.** Never commit keys, tokens, or credentials; redact on sight.
4. **Push.** Push the feature branch when the stage completes; the trunk is
   hook-protected — never push to the trunk-identified primary branch.
5. **Submodule pointers.** Pointer commits are scoped by surface:
   - **Branch level (sanctioned):** on a feature branch, an immediate
     pointer-only capture commit — the synced pointers committed before work
     starts — is sanctioned (see `git-workflow-branch` rule 3).
   - **Review surface (forbidden):** pointer-only commits are forbidden at the
     review surface except as release PRs (their changelog, version, and
     tag-prep content is the real content). The ride-along invariant governs
     the squashed review surface: the pointer rides with real changes in the
     same per-issue commit — never a standalone parent PR.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
