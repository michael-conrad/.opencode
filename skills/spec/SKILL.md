---
name: spec
description: "Load when creating or revising a specification document — success criteria, evidence types, traceability. Also load when a spec needs revision from review findings. Success criteria come from the developer's stated requirements and observed failures only — inventing extra criteria is scope creep. Every criterion is classified behavioral (runtime effect) or structural by its nature, and carries a verification instrument."
license: MIT
provenance: AI-authored, .opencode#2490; single-sourcing discipline, .opencode#2660
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490; #2550 validate step, validation-standards reference; #2557 language/tool call out; pointer-resolution guarantee, .opencode#2597; producer-side self-check, .opencode#2601; single-sourcing discipline in self-containment, .opencode#2660 -->

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
   via `update --github`. The local-artifacts pointer written into the remote
   body must resolve to the actual local folder at write time; a mid-flow
   local write failure BLOCKs the flow — the remote body is never left
   carrying an unresolvable pointer. The remote body follows
   [the remote-body-format reference](references/remote-body-format.md)
   — sizing doctrine (fuller-but-still-exec-summary, self-sufficient for
   developer judgment), required sections, and the closing blockquoted
   artifacts link; the full spec and all artifacts live in
   `.issues/{N}/` and stay local-authoritative. The
   local counter reserves numbers only in remoteless stores. On every remote
   filing into a synced store, advance `.counter` to max(counter, filed
   number); if it has drifted behind the store's highest `{N}/`, advance it to
   that number — the counter is reserve state, and a stale counter corrupts
   numbering.
5. **Revision discipline.** Findings from review produce targeted revisions;
   superseded criteria are removed, never accumulated. **Self-containment
   (normative):** the artifact is the single source of truth and must read
   standalone — revisions edit the artifact in place, superseded text is
   deleted in the same action, and spec content never lives in comments.
   Self-containment carries the single-sourcing discipline: the artifact
   states each operative fact once, in the section that owns it — surfaces in
   the scope table, rules in the requirements, checks as mappings whose
   element lists the mapped requirement owns, measured history in the
   evidence, the artifact's own loop history in the issue's validation record
   where the record rule applies — and every other mention points at its
   owner. The
   body footer allowlist is normative: only spec content (behavior, analysis,
   SCs, fixes, evidence) plus the byline footer — no process or tracking
   indicators of any kind (no revision-history blocks, approval-state
   markers, comment-policy statements, or superseded-content pointers). No
   STATUS fields — the spec defines what is required, implemented or not.
6. **Validate before approval.** A completed spec includes one fresh-context
   validation dispatch executed before the developer approval gate. Before
   dispatching, the writer applies
   [the validation standards](references/validation-standards.md) to the
   completed draft in their own context and remediates what they find — a
   duty-of-care pass whose purpose is to spend the fresh-context dispatch on
   judgment-level defects rather than mechanical-consistency ones. It is
   hygiene, not a gate: it never replaces the dispatch, and a self-passed
   verdict is no verdict. The dispatch itself is unchanged: a reviewer
   with no prior context on the spec reads it against the same standards
   and returns PASS or FAIL. On FAIL, revise the named findings in place
   and re-validate; the loop repeats until a verdict with zero findings, per
   the standards reference's loop section. The approval gate is unchanged
   and follows validation. Revising
   an existing spec (this card's revision path) validates the revised spec
   against the same standards reference — one criteria source exists in the
   deck; an on-demand audit of a prior spec restates those criteria verbatim
   from the same reference.
7. **Approval is a human gate.** The spec waits for the developer's
   authorization before `plan` — and a terminal-stage approval
   (`approved for pr`, `approved for implementation`, …) from the vocabulary
   in `floor.md` *is* that authorization; the stage is not re-asked.
8. **Email actions.** Mid-flow email work — drafting, sending, or mailbox
   checks — dispatches to the `email-ops` subagent, which holds the gmail
   tool permissions; the flow itself never calls gmail tools directly.
9. **Deprecation encounters at authoring time.** A spec that touches a
   witnessed deprecation follows [the deprecation encounter protocol](../guidelines/deprecation-encounter-protocol.md):
   new requirements never specify deprecated surface; a load-bearing
   deprecation with no route around becomes a temporary-use exception
   carve-out cross-referencing the owning `[BITROT]` ticket and is escalated
   with the proposed text — the carve-out adjusts this spec, it never widens
   its scope.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
