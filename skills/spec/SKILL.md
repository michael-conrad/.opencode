---
name: spec
description: "Load when creating or revising a specification document — success criteria, evidence types, traceability. Also load when a spec needs revision from review findings. Success criteria come from the developer's stated requirements and observed failures only — inventing extra criteria is scope creep. Every criterion is classified behavioral (runtime effect) or structural by its nature, and carries a verification instrument."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# spec — specification creation and revision

1. **Extract, don't invent.** Requirements come from the developer's statements
   and the exploration record. If a criterion cannot be traced to a developer
   statement or an observed failure, delete it — that is the scope-creep guard.
2. **Every SC is testable.** State what to check and how: behavioral SCs get a
   runtime verification instrument; structural SCs get a fact-decidable check.
   Evidence types are classified by the change's nature, not by intent.
3. **Write and persist.** Reserve the number from the store's remote tracker
   first — file the remote issue (`gh`/`gb`) for EVERY issue creation when a
   remote tracker exists; the local `{N}/` folder and `spec.md` follow, linked
   via `update --github`. The remote body is a detailed exec summary (why +
   final what); the full spec and all artifacts live in `.issues/{N}/`. The
   local counter reserves numbers only in remoteless stores. On every remote
   filing into a synced store, advance `.counter` to max(counter, filed
   number); if it has drifted behind the store's highest `{N}/`, advance it to
   that number — the counter is reserve state, and a stale counter corrupts
   numbering.
4. **Revision discipline.** Findings from review produce targeted revisions;
   superseded criteria are removed, never accumulated. **Self-containment
   (normative):** the artifact is the single source of truth and must read
   standalone — revisions edit the artifact in place, superseded text is
   deleted in the same action, and spec content never lives in comments. The
   body footer allowlist is normative: only spec content (behavior, analysis,
   SCs, fixes, evidence) plus the byline footer — no process or tracking
   indicators of any kind (no revision-history blocks, approval-state
   markers, comment-policy statements, or superseded-content pointers). No
   STATUS fields — the spec defines what is required, implemented or not.
5. **Approval is a human gate.** The spec waits for the developer's
   authorization before `plan` — and a terminal-stage approval
   (`approved for pr`, `approved for implementation`, …) from the vocabulary
   in `floor.md` *is* that authorization; the stage is not re-asked.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
