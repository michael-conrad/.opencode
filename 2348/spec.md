> **Full spec and artifacts: [`2348/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2348)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `2348/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC — Condense 010-approval-gate.md: Move Scope Model to the approval-gate Skill Card

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The preloaded Tier 1 guideline `.opencode/guidelines/010-approval-gate.md` costs ~5.7k tokens of orchestrator context before the first prompt. Approximately 45% of that burden is procedural content — the authorization scope model, verb-prefix parsing table, decision tables, edge-case tables, and action classification — that the `approval-gate` skill card already carries verbatim. |
| 2 | **Root Cause / Motivation** | The procedural scope content is duplicated across the preloaded guideline and the skill card. Because the guideline is preloaded into orchestrator context at session start, the duplication taxes every session's context budget even though the skill card is the authoritative scope parser. The duplication must be collapsed to a single source of truth. |
| 3 | **Approach Chosen** | Relocate the duplicated procedural tables (scope model, verb-prefix, decision, edge-case, action-classification) out of the preloaded `010-approval-gate.md` and into the `approval-gate` skill card, making the skill card the single source of truth. Retain the safety-critical authorization cores (spec-before-code, plan-before-implementation, explicit-authorization, human-only-merge, bug-discovery-does-not-authorize) verbatim in the preloaded guideline, and add a mandatory Read-link from the guideline to the skill card so relocated rules remain reachable. |
| 4 | **Alternatives Considered & Why Discarded** | **Create a new shared-reference file** (as `#2347`/`#2359` do) — discarded because the `approval-gate` skill card already exists and already contains the scope model, verb-prefix table, and edge cases; a new shared-reference file would add a third copy of the same content. **Remove the guideline from preload entirely** — discarded because the safety-critical authorization cores are Tier 1 and must stay preloaded per the opencode.jsonc instructions array mandate. |
| 5 | **Key Design Decisions** | The `approval-gate` skill card becomes the single source of truth for scope parsing (tradeoff: the skill card grows slightly, but the preload token burden drops ~45%). The preloaded guideline retains only the safety-critical cores plus a Read-link (tradeoff: the guideline no longer self-contains the procedural tables, but reachability is preserved via the canonical Read-link form, validated at 100% Tier 1 access rate). The opencode.jsonc instructions array is unchanged — `010-approval-gate.md` stays preloaded (tradeoff: preload content changes but preload membership does not). |
| 6 | **User Intent / Original Prompt** | Condense `.opencode/guidelines/010-approval-gate.md` to reduce preload token burden by moving the already-duplicated procedural scope content to the `approval-gate` skill card, retaining the Tier-1 authorization cores. |

## 2. Not Included

- **Removing `010-approval-gate.md` from the opencode.jsonc instructions array** — the guideline stays preloaded (C-1); only its content is condensed.
- **Removing any safety-critical authorization core** — spec-before-code, plan-before-implementation, explicit-authorization, human-only-merge, and bug-discovery-does-not-authorize are retained verbatim (R-6..R-11).
- **Creating a new shared-reference file** — the relocation target is the existing `approval-gate` skill card (N-3).
- **Editing consuming task files** — consumers (read-labels, close, read-sub-issues, triage-issues, 020, 140) are verified for reachability only; no file edits unless a broken reference is found.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The authorization scope-model table (Key Scope Values + Scope-Dependent PR Strategy) is removed from the preloaded `010-approval-gate.md`; the `approval-gate` skill card is the single source of truth. | structural | read/grep confirms 010 no longer contains the scope-model table and `approval-gate/SKILL.md` retains it verbatim. | `.opencode/guidelines/010-approval-gate.md`; `.opencode/skills/approval-gate/SKILL.md` |
| SC-2 | The verb-prefix parsing table is not duplicated in the preloaded `010-approval-gate.md`; it lives only in the `approval-gate` skill card. | structural | read/grep confirms no verb-prefix scope-mapping table in 010; `approval-gate/SKILL.md` retains it. | `.opencode/guidelines/010-approval-gate.md`; `.opencode/skills/approval-gate/SKILL.md` |
| SC-3 | The decision table (Authorization + File Modifications) is relocated out of the preloaded `010-approval-gate.md` to the `approval-gate` skill card. | structural | read/grep confirms the decision table is removed from 010 and present in `approval-gate/SKILL.md`. | `.opencode/guidelines/010-approval-gate.md`; `.opencode/skills/approval-gate/SKILL.md` |
| SC-4 | The edge-case table (Key Edge Cases) is relocated out of the preloaded `010-approval-gate.md` to the `approval-gate` skill card, reconciled with the existing Edge Cases table. | structural | read/grep confirms edge-case content is removed from 010 and present in `approval-gate/SKILL.md`. | `.opencode/guidelines/010-approval-gate.md`; `.opencode/skills/approval-gate/SKILL.md` |
| SC-5 | The action-classification table (Action Authorization Classification) is relocated out of the preloaded `010-approval-gate.md` to the `approval-gate` skill card. | structural | read/grep confirms the action-classification table is removed from 010 and present in `approval-gate/SKILL.md`. | `.opencode/guidelines/010-approval-gate.md`; `.opencode/skills/approval-gate/SKILL.md` |
| SC-6 | The safety-critical authorization cores (spec-before-code, plan-before-implementation, explicit-authorization, human-only-merge, bug-discovery-does-not-authorize) are retained verbatim in the preloaded `010-approval-gate.md`. | behavioral | `opencode run` with a self-authorization / bug-discovery prompt; clean-room sub-agent inspects session.yaml for evidence the agent does NOT self-authorize and does NOT fix a discovered bug. | `.opencode/guidelines/010-approval-gate.md` |
| SC-7 | The preloaded `010-approval-gate.md` retains a mandatory Read-link to the `approval-gate` skill card so relocated procedural content remains reachable. | structural | read confirms 010's cross-reference note has a `Read [approval-gate skill](skills/approval-gate/SKILL.md)` link. | `.opencode/guidelines/010-approval-gate.md`; `.opencode/reference/cross-reference-form-comparison.md` |
| SC-8 | The preloaded token/byte burden of `010-approval-gate.md` is reduced to < 8,466 bytes (< 55% of the original 15,393 bytes). | structural | byte/line count of `010-approval-gate.md` after condensation is < 8,466 bytes. | `.opencode/guidelines/010-approval-gate.md` |
| SC-9 | Scope-parsing behavior is not regressed — the `approval-gate` skill card remains the authoritative scope parser and the verb-prefix table is present. | behavioral | `opencode run` with an authorization-scope prompt; clean-room sub-agent inspects session.yaml for evidence the agent dispatches `approval-gate resolve-scope` and correctly parates scope. | `.opencode/skills/approval-gate/SKILL.md`; `.opencode/skills/approval-gate/tasks/resolve-scope.md` |

## 4. Requirements

- R-1. The authorization scope-model table(s) SHALL be relocated out of the preloaded `010-approval-gate.md` to the `approval-gate` skill card as the single source of truth.
- R-2. The verb-prefix parsing table SHALL NOT be duplicated in the preloaded `010-approval-gate.md`; it SHALL live only in the `approval-gate` skill card.
- R-3. The decision table (Authorization + File Modifications) SHALL be relocated out of the preloaded `010-approval-gate.md` to the `approval-gate` skill card.
- R-4. The edge-case table (Key Edge Cases) SHALL be relocated out of the preloaded `010-approval-gate.md` to the `approval-gate` skill card, reconciled with the existing Edge Cases table.
- R-5. The action-classification table (Action Authorization Classification) SHALL be relocated out of the preloaded `010-approval-gate.md` to the `approval-gate` skill card.
- R-6. The spec-before-code core SHALL be retained verbatim in the preloaded `010-approval-gate.md`.
- R-7. The plan-before-implementation core SHALL be retained verbatim in the preloaded `010-approval-gate.md`.
- R-8. The explicit-authorization core SHALL be retained verbatim in the preloaded `010-approval-gate.md`.
- R-9. The human-only-merge core SHALL be retained verbatim in the preloaded `010-approval-gate.md`.
- R-10. The bug-discovery-does-not-authorize core SHALL be retained verbatim in the preloaded `010-approval-gate.md`.
- R-11. No safety-critical authorization core SHALL be removed from the preloaded `010-approval-gate.md`.
- R-12. The `approval-gate` skill card SHALL become the single source of truth for the relocated procedural content.
- R-13. The preloaded `010-approval-gate.md` SHALL retain a mandatory Read-link to the `approval-gate` skill card so relocated procedural content remains reachable.
- R-14. Consuming skill cards / guidelines that Read-link 010 for the relocated tables (read-labels.md, close.md, read-sub-issues.md, triage-issues.md, 020-go-prohibitions.md, 140-planning-spec-creation.md) SHALL still resolve the scope rules via the skill card.
- R-15. Scope-parsing behavior SHALL NOT regress; the `approval-gate` skill card SHALL remain the authoritative scope parser.
- C-1. `010-approval-gate.md` SHALL remain in the opencode.jsonc instructions array (Tier 1 preload); only its content is condensed.
- C-2. The `approval-gate` skill card SHALL be authoritative for the scope model; the verb-prefix table SHALL already exist there.

## 5. Items

### Item 1 (SC-1): Remove the Authorization Scope Model from 010; confirm skill card retains it

- RED: Enforcement check that the scope-model table is still present in 010 (fails because it should be removed).
- GREEN: Remove the Authorization Scope Model (Key Scope Values + Scope-Dependent PR Strategy) from `010-approval-gate.md`; confirm `approval-gate/SKILL.md` retains it as single source of truth.
- verify: read/grep confirms 010 no longer contains the scope-model table and the skill card retains it verbatim.
- commit: Remove the scope-model table from the guideline.

### Item 2 (SC-2): Confirm verb-prefix table absent from 010, present only in skill card

- RED: Enforcement check that the verb-prefix table is duplicated in 010 (fails because it should not be).
- GREEN: Confirm the verb-prefix parsing table is absent from `010-approval-gate.md` and present only in `approval-gate/SKILL.md`.
- verify: read/grep confirms no verb-prefix scope-mapping table in 010; skill card retains it.
- commit: No-op verification slice; no content change if already absent.

### Item 3 (SC-3): Relocate the Decision Table to the skill card

- RED: Enforcement check that the Decision Table is absent from the skill card (fails because it should be added).
- GREEN: Remove the Decision Table (Authorization + File Modifications) from `010-approval-gate.md` and add it to `approval-gate/SKILL.md`.
- verify: read/grep confirms the decision table removed from 010 and present in the skill card.
- commit: Move the Decision Table.

### Item 4 (SC-4): Relocate the Key Edge Cases table to the skill card

- RED: Enforcement check that the Key Edge Cases table is absent from the skill card (fails because it should be added).
- GREEN: Remove the Key Edge Cases table from `010-approval-gate.md` and reconcile it into the `approval-gate/SKILL.md` Edge Cases table.
- verify: read/grep confirms edge-case content removed from 010 and present in the skill card.
- commit: Move and reconcile the Edge Cases table.

### Item 5 (SC-5): Relocate the Action Authorization Classification table to the skill card

- RED: Enforcement check that the Action Authorization Classification table is absent from the skill card (fails because it should be added).
- GREEN: Remove the Action Authorization Classification table from `010-approval-gate.md` and add it to `approval-gate/SKILL.md`.
- verify: read/grep confirms the action-classification table removed from 010 and present in the skill card.
- commit: Move the Action Authorization Classification table.

### Item 6 (SC-6): Verify safety-critical cores retained verbatim

- RED: Behavioral test with a self-authorization / bug-discovery prompt asserts the agent DOES self-authorize or DOES fix a discovered bug (fails because cores are retained and enforced).
- GREEN: Confirm the safety-critical cores remain verbatim in `010-approval-gate.md` after condensation.
- verify: `opencode run` with self-authorization / bug-discovery prompt; clean-room sub-agent inspects session.yaml for evidence the agent does NOT self-authorize and does NOT fix a discovered bug.
- commit: No content change; verification slice confirming core retention.

### Item 7 (SC-7): Add mandatory Read-link to the skill card

- RED: Enforcement check that 010 lacks a Read-link to the skill card (fails because it should be added).
- GREEN: Add a mandatory `Read [approval-gate skill](skills/approval-gate/SKILL.md)` link in `010-approval-gate.md` so relocated procedural content remains reachable.
- verify: read confirms 010's cross-reference note has the Read-link; consumer reachability (R-14) verified for read-labels, close, read-sub-issues, triage-issues, 020, 140.
- commit: Add the Read-link to the guideline.

### Item 8 (SC-8): Measure post-condensation byte burden

- RED: Enforcement check that the byte count is >= 8,466 (fails because it should be below).
- GREEN: Measure the post-condensation byte/line burden of `010-approval-gate.md`.
- verify: byte/line count of `010-approval-gate.md` is < 8,466 bytes (< 55% of original 15,393 bytes).
- commit: No content change; measurement slice confirming token reduction.

### Item 9 (SC-9): Behavioral enforcement test for scope-parsing regression

- RED: Behavioral test with an authorization-scope prompt asserts the agent does NOT dispatch `approval-gate resolve-scope` or mis-parses scope (fails because scope parsing is unregressed).
- GREEN: Run a behavioral enforcement test asserting scope parsing is not regressed: the `approval-gate` skill remains the authoritative scope parser with the verb-prefix table present.
- verify: `opencode run` with an authorization-scope prompt; clean-room sub-agent inspects session.yaml for evidence the agent dispatches `approval-gate resolve-scope` and correctly parses scope.
- commit: No content change; behavioral verification slice.

## 6. Dependencies

- **Reference:** `.opencode/skills/approval-gate/SKILL.md`
  - **Relationship:** Relocation target and single source of truth for the scope model; must be read before implementation and edited to add the missing tables.
  - **Status:** Satisfied (exists; contains scope model, verb-prefix table, edge cases).
- **Reference:** `.opencode/opencode.jsonc` instructions array (line 80)
  - **Relationship:** Constraint that `010-approval-gate.md` stays preloaded; no config change.
  - **Status:** Satisfied.
- **Reference:** `.opencode/reference/cross-reference-form-comparison.md` (research card, conf 0.95)
  - **Relationship:** Validates the mandatory Read-link relocation mechanism (100% Tier 1 access).
  - **Status:** Satisfied.
- **Reference:** `.opencode#2347` (sibling condensation of 020-go-prohibitions.md)
  - **Relationship:** Confirms the family approach (relocate-procedural/retain-core pattern); not a hard dependency.
  - **Status:** Satisfied (informational).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-12 | SC-1 | Structural relocation |
| R-2 | SC-2 | Structural relocation |
| R-3 | SC-3 | Structural relocation |
| R-4 | SC-4 | Structural relocation |
| R-5 | SC-5 | Structural relocation |
| R-6, R-7, R-8, R-9, R-10, R-11 | SC-6 | Behavioral verification |
| R-13, R-14 | SC-7 | Structural relocation |
| R-1, C-1 | SC-8 | Structural relocation |
| R-15, C-2 | SC-9 | Behavioral verification |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| 010-approval-gate.md | code/guideline | `.opencode/guidelines/010-approval-gate.md` | read/grep of current content |
| approval-gate skill card | code/skill | `.opencode/skills/approval-gate/SKILL.md` | read of scope model, verb-prefix table, edge cases |
| resolve-scope task card | code/task | `.opencode/skills/approval-gate/tasks/resolve-scope.md` | read of scope-parsing procedure |
| opencode.jsonc | config | `.opencode/opencode.jsonc` | read of instructions array line 80 |
| cross-reference-form-comparison.md | research card | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read of Read-link access-rate finding |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the scope-model table is removed from 010 and retained in the skill card costs one read/grep pass. Skipping means the duplicated table ships, the preload burden stays at ~5.7k tokens, and the condensation goal fails silently.
- **SC-2:** Verifying the verb-prefix table is not duplicated costs one read/grep pass. Skipping means a duplicate scope-mapping table survives and the single-source-of-truth goal is defeated.
- **SC-3:** Verifying the decision table is relocated costs one read/grep pass. Skipping means the decision table is orphaned from the skill card and the scope parser loses the authorization decision matrix.
- **SC-4:** Verifying the edge-case table is relocated and reconciled costs one read/grep pass. Skipping means edge cases diverge between the guideline and the skill card, and the authoritative edge-case set is ambiguous.
- **SC-5:** Verifying the action-classification table is relocated costs one read/grep pass. Skipping means the action-classification matrix is orphaned and authorization scope classification loses its source.
- **SC-6:** Running the behavioral core-retention test costs minutes of execution time. Skipping means a safety-critical authorization core is silently dropped and the agent self-authorizes or fixes discovered bugs — a 1000× production defect.
- **SC-7:** Verifying the Read-link is present and consumers resolve costs one read/grep pass. Skipping means relocated rules are orphaned and consumers silently lose the scope model — a reachability defect caught only when a consumer fails.
- **SC-8:** Measuring the post-condensation byte count costs one byte/line count. Skipping means the token-reduction claim is unverified and the preload burden may not actually drop.
- **SC-9:** Running the behavioral scope-parsing test costs minutes of execution time. Skipping means the named scope-parsing regression risk ships unverified — the exact risk the issue Impact section calls out, at 1000× downstream cost.

## 11. Edge Cases

- **Condition:** The `approval-gate` skill card is edited but a relocated table is not added (e.g., Decision Table omitted).
  - **Expected behavior:** The scope parser loses the authorization decision matrix; the skill card is no longer the complete single source of truth.
  - **Resolution:** SC-3 and SC-5 require ADDING the missing tables to the skill card; verification confirms presence before completion.
- **Condition:** A consumer (read-labels, close, read-sub-issues, triage-issues, 020, 140) still Read-links 010 for a relocated table.
  - **Expected behavior:** The relocated rule remains reachable via the skill card; no orphaned reference.
  - **Resolution:** SC-7 + R-14 verify consumer reachability; a broken reference is fixed in the consumer before completion.
- **Condition:** The preload token burden does not drop below 8,466 bytes after condensation.
  - **Expected behavior:** The token-reduction claim is unverified; the condensation goal fails.
  - **Resolution:** SC-8 measures the byte count; if above threshold, additional procedural content is relocated.
- **Condition:** The scope-parsing behavioral test fails (agent mis-parses an authorization scope).
  - **Expected behavior:** Scope parsing regressed; the named risk materialized.
  - **Resolution:** SC-9 fails; remediation restores the verb-prefix table / skill-card authority before completion.
- **Condition:** A safety-critical core is accidentally removed during condensation.
  - **Expected behavior:** The agent self-authorizes or fixes a discovered bug — a Tier 1 violation.
  - **Resolution:** SC-6 behavioral test fails; the core is restored verbatim before completion.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
