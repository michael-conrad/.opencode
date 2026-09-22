---
title: "[SPEC] Deprecation Encounter Protocol — pending-breakage directive across skill cards"
labels:
  - spec
  - needs-approval
remote_issue: 2458
remote_url: https://github.com/michael-conrad/.opencode/issues/2458
promoted_at: '2026-09-22T14:55:30+00:00'
---

## Problem Statement
The deck has no rule governing how agents respond when they encounter deprecated items (APIs, config keys, library functions, skill cards, formats). All existing deprecation text in the deck is output-side (creating deprecations, removal notices — audit coherence-maintenance, changelog `deprecate:` category, 087-no-backward-compat). Encountered deprecated items are currently treated as ignorable noise, and no directive surfaces possible future breakage to the developer.

## Proposed Directive (design approved in brainstorming session 2026-09-22)
**Deprecation Encounter Protocol:** A deprecated item encountered during workflow — called, depended on, recommended, validated against, routed through, or merely observed — is pending breakage and a clear sign of bitrot, never ignorable noise. Do not build on it or rely on it. File (or update) a spec in the module that owns the deprecated item for the deprecation to be resolved, via the normal spec-creation pipeline. Filing triggers on every encounter, dependent or observed, so the developer always has knowledge of possible future breakage requiring research.

## Scope
1. Inline directive (identical fragment text, managed via skill-creator fragment-management) in six SKILL.md cards: research, systematic-debugging, programming-principles, audit, skill-creator, engineering-approach
2. Runtime-constraint documentation (full skill/task cards load into context before any decision-making; no mid-card content insertion; decision-point directives must be inline, never Read-link-only/load-on-encounter forms) in skill-card-description-standards.md and task-card-structure-standards.md (full detail) plus a compact 2-3 sentence statement in .opencode/AGENTS.md
3. Behavioral enforcement test per critical-rules-009; evidence types per critical-rules-BEH-EV (placement SCs = string, encounter behavior SCs = behavioral)

## Filing Mechanics
Orchestrator dispatches filing sub-agent immediately at encounter receipt (sub-agents cannot dispatch task() — encounters propagate via result contracts). Search-then-create-or-comment ([BITROT] title prefix + bitrot label; check-before-POST per critical-rules-029). Channel routing: remote API when available; transient API failure = chat executive summary + defer-and-retry; structurally no remote (platform: local) = repo standard tracking via local .issues/ with same [BITROT] prefix + label. No special tracking file.

## SC-Eligibility Gate
When the encountered deprecated item is a code path the current change touches, the finding is surfaced to the developer with a scope assessment and folding a resolution SC into the current spec requires a brainstorm session with the developer — substantive spec revision revokes plan approval (approval-gate-006), and that cost must be presented. Observed-only encounters never raise the SC question.

## Cross-Spec Coordination
Zero FULL-SUPERSESSION (212 open [SPEC]-titled issues searched in this repo); 17 PARTIAL-OVERLAP (additive coordination); 4 CONFLICT-RISK deck-wide structural specs (#2056, #1199, #1204, #1358) touch the same six cards — merge-sequence coordination required.

---
Stub issue pending full spec authoring by the spec-creation pipeline. Brainstorming handoff: tmp/issue-pending-deprecation-bitrot/artifacts/preliminary/handoff.yaml

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
