---
name: gh-cli
description: "Load before any command or code that contacts GitHub — using the gh CLI, making GitHub API calls in any language, opening or updating PRs/issues/releases, reading repositories, or anything needing GitHub credentials. Authentication is built into gh; never hand-roll GitHub API calls, never hunt for tokens or passwords. Also load when GitHub operations fail unexpectedly. One load does not carry across operation classes: before your first GitHub contact in a new class (issues ↔ pull requests ↔ API passthrough), load this card again — even though it is already in context."
license: MIT
provenance: AI-authored, .opencode#2490; .opencode#2547; .opencode#2461
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; .opencode#2547; .opencode#2461 -->

# gh-cli — GitHub operations

1. **Auth first.** `gh auth status` before operations that matter; auth is the
   CLI's job — no token hunting, no bespoke request code.
2. **Prefer the CLI over raw API.** `gh api` exists for gaps, but check the
   CLI's native command first — it handles auth, pagination, and errors.
3. **Construct carefully, inspect output.** Verify the command shape; inspect
   the actual output (jq for JSON) rather than assuming success. Before every
   gh contact, run the class check —
   - last gh class contacted: issues / PRs / API / none
   - class of the command about to run
   - different class → load this card again first (one load does not carry
     across classes).
4. **Common operations.** `gh pr create/edit/view/merge`, `gh issue
   create/list/close`, `gh release create/view`, `gh repo view`, `gh api` for
   passthrough. Read `gh <cmd> --help` when unsure — guessing flags is how
   silent failures happen.
5. **Failures are information.** A failed gh call is diagnosed from its
   stderr — not retried blind. `gh pr edit` may fail with the GitHub
   Projects-classic deprecation error (the GraphQL `projectCards` field);
   when it does, amend the PR body via REST instead:
   `gh api -X PATCH repos/{owner}/{repo}/pulls/{N} -F body=@<file>` — same
   built-in auth, no GraphQL read path.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
