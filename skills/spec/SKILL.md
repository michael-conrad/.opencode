---
name: spec
description: "Load when creating or revising a specification document — success criteria, evidence types, traceability. Also load when a spec needs revision from review findings. Success criteria come from the developer's stated requirements and observed failures only — inventing extra criteria is scope creep. Every criterion is classified behavioral (runtime effect) or structural by its nature, and carries a verification instrument."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #2550 validate step, validation-standards reference; #2557 language/tool call out -->

# spec — specification creation and revision

1. **Extract, don't invent.** Requirements come from the developer's statements
   and the exploration record. If a criterion cannot be traced to a developer
   statement or an observed failure, delete it — that is the scope-creep guard.
2. **Load the cards in scope.** Identify the languages and build tools the
   change touches and load their cards (where cards exist), and load
   `programming-principles` for the engineering-principles layer — language
   standards and tool expectations shape what the requirements can demand.
3. **Every SC is testable.** State what to check and how: behavioral SCs get a
   runtime verification instrument; structural SCs get a fact-decidable check.
   Evidence types are classified by the change's nature, not by intent.
4. **Write and persist.** Reserve the number from the store's remote tracker
   first — file the remote issue (`gh`/`gb`) for EVERY issue creation when a
   remote tracker exists; the local `{N}/` folder and `spec.md` follow, linked
   via `update --github`. The remote body is a detailed exec summary (why +
   final what); the full spec and all artifacts live in `.issues/{N}/`. The
   local counter reserves numbers only in remoteless stores. On every remote
   filing into a synced store, advance `.counter` to max(counter, filed
   number); if it has drifted behind the store's highest `{N}/`, advance it to
   that number — the counter is reserve state, and a stale counter corrupts
   numbering.
5. **Revision discipline.** Findings from review produce targeted revisions;
   superseded criteria are removed, never accumulated. **Self-containment
   (normative):** the artifact is the single source of truth and must read
   standalone — revisions edit the artifact in place, superseded text is
   deleted in the same action, and spec content never lives in comments. The
   body footer allowlist is normative: only spec content (behavior, analysis,
   SCs, fixes, evidence) plus the byline footer — no process or tracking
   indicators of any kind (no revision-history blocks, approval-state
   markers, comment-policy statements, or superseded-content pointers). No
   STATUS fields — the spec defines what is required, implemented or not.
6. **Validate before approval.** A completed spec includes one fresh-context
   validation dispatch executed before the developer approval gate: a reviewer
   with no prior context on the spec reads it against
   [the validation standards](references/validation-standards.md) and returns
   PASS or FAIL. On FAIL, revise the named criteria and re-validate; a FAIL
   that persists after revision halts to the developer, naming the failing
   criteria. The approval gate is unchanged and follows validation. Revising
   an existing spec (this card's revision path) validates the revised spec
   against the same standards reference — one criteria source exists in the
   deck; an on-demand audit of a prior spec restates those criteria verbatim
   from the same reference.
7. **Approval is a human gate.** The spec waits for the developer's
   authorization before `plan` — and a terminal-stage approval
   (`approved for pr`, `approved for implementation`, …) from the vocabulary
   in `floor.md` *is* that authorization; the stage is not re-asked.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
