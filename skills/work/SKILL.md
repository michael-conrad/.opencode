---
name: work
description: "Load before any file modification, branch creation, or implementation start in any repo. Routes every change through spec → plan → implement → PR scaled to the change's need — trivial fixes take the short path, multi-part features take the full path — and checks authorization at each stage boundary. Also load when unsure which stage applies: halt with an open-ended clarification request rather than guess."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# work — the change gate

Consult before touching files.

1. **Path selection (judgment, not thresholds).** What does this change need?
   - *Short path*: single-file fix, typo, config tweak — the developer's request
     itself is the spec; it is verified at PR review.
   - *Full path*: feature, multi-part change, anything with success criteria —
     spec before code.
2. **Authorization check.** The vocabulary in `floor.md` defines authorization.
   No authorization at the required scope → prepare the spec/proposal and stop
   at the boundary. A question, complaint, or confirmation is not authorization.
3. **Route.**
   - Short: `git-workflow-branch` → `implement` → `verify` → `git-workflow-pr`
   - Full: `explore` → `spec` → developer approval → `plan` → `implement` →
     `verify` → `git-workflow-pr`
4. **Boundaries.** Spec approval, plan approval, and merge are human gates.
   PRs are merged by the developer only — never by the agent.

Unsure which path fits? Halt with an open-ended clarification request.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
