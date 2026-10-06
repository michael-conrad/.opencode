---
name: work
description: "Load before any file modification, branch creation, or implementation start in any repo. Routes every change through spec → plan → implement → PR scaled to the change's need — trivial fixes take the short path, multi-part features take the full path — and checks authorization at each stage boundary. Also load when unsure which stage applies: halt with an open-ended clarification request rather than guess."
license: MIT
provenance: AI-authored, .opencode#2490; #2525 pipeline continuation
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #2525 pipeline continuation on terminal authorization -->

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
4. **Boundaries.** Spec approval, plan approval, and merge are human gates —
   and a developer-issued terminal-stage approval (`approved for pr`,
   `approved for implementation`, …) *is* that human gate for the upstream
   stages it carries, per the vocabulary in `floor.md`. It authorizes the
   item through every phase up to and including the named one; only merge
   remains human-only unconditionally. Halt for authorization only on genuine
   ambiguity — never because an intermediate stage lacks its own approval.
   Missing upstream *artifacts* (no spec, plan, or branch yet) trigger the
   pipeline itself: run it from the earliest missing stage under the granted
   authorization. Downstream card gates (e.g. PR readiness) are reached by
   running the pipeline — they are never reasons to halt; the artifacts the
   gate checks are what the pipeline exists to produce.

Unsure which path fits? Halt with an open-ended clarification request.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
