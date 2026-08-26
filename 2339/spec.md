---
title: "[SPEC] Skill card pre-flight guard for sub-agent dispatch"
status: draft
created: 2026-08-26
license: MIT
provenance: AI-generated
issue: 2339
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
remote_issue: 2339
remote_url: https://github.com/michael-conrad/.opencode/issues/2339
promoted_at: 2026-08-26T14:30:00Z
---

> **Full spec and artifacts: [`.opencode/.issues/2339/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2339)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2339/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

Skill cards (SKILL.md) are orchestrator-routing metadata — they contain Trigger Dispatch Tables, DISPATCH_GATE protocols, and Invocation sections that only the orchestrator can execute. When a sub-agent receives a skill card, it cannot act on this routing metadata (sub-agents cannot call `task()`), so it must halt immediately rather than attempt to follow orchestrator-level instructions. Currently 0 of 51 skill cards contain any guard, so a sub-agent that receives a skill card silently consumes routing metadata it cannot execute.

### Root Cause / Motivation

The skill card is a category-appropriate consumer artifact: it is routing metadata consumed by the orchestrator. Dispatching SKILL.md content to a sub-agent is a category error (critical-rules-XXX). The pre-flight gate concept was introduced in #2052 but was never implemented — no card carries a guard. Without a guard, there is no defensive backstop that stops a sub-agent from attempting to follow orchestrator-level routing instructions, producing defective work that needs to be redone.

### Approach Chosen

Add a uniform pre-flight guard to every skill card. Each SKILL.md gains a pre-flight entry check that detects sub-agent context and returns `BLOCKED` with the `ORCHESTRATOR_ONLY_SKILL_CARD` reason before any routing metadata is consumed. The canonical guard definition lives once in the requirements documentation; linting enforcement and the template generator keep the guard present and consistent across the deck.

### Alternatives Considered & Why Discarded

- **Runtime guard in the opencode binary** — rejected. The guard must not depend on a binary/semantics change; it is a content-level addition to SKILL.md files that the deck tooling (lint, validation) can enforce mechanically. Changing the binary is out of scope and higher risk.

### Key Design Decisions

- **Canonical guard definition single-source** — the guard wording and behavior live in the requirements docs and are consumed by all cards, linting, and the template. Tradeoff: requires cross-phase consistency, but prevents 37+ cards drifting into inconsistent wording.
- **Context detection distinguishes orchestrator from sub-agent** — the guard must not fire in legitimate orchestrator context (false-positive mitigation). Trade-off: relies on context detection heuristics, which the guard encodes as a pre-flight check.
- **Guard fires before routing metadata is consumed** — positioned as a pre-flight entry check ahead of the Workflows/routing sections. Trade-off: adds a fixed guard section to every card.

### User Intent / Original Prompt

Implement a defensive pre-flight guard on skill cards so that a sub-agent receiving a SKILL.md halts with `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` before consuming routing metadata, backed by lint/validation enforcement and a documentation mandate.

## 2. Not Included

- **Task card structure** — task cards (`tasks/*.md`) are consumed by sub-agents and are outside this spec's scope; their structure is unchanged.
- **Behavioral enforcement test authoring** — authoring a behavioral test for the guard's runtime halt behavior is out of scope; the lint/validation enforcement provides the mechanical backstop.
- **Canonical skill card template redesign** — the canonical template redesign is tracked separately in #2052 and is not addressed here.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | Every SKILL.md under `.opencode/skills/` (including `platforms/*/SKILL.md`) contains a pre-flight guard that detects sub-agent context and returns `BLOCKED` + `ORCHESTRATOR_ONLY_SKILL_CARD` before any routing metadata is consumed. | string | grep across all 51 SKILL.md files for the guard marker; `skildeck lint` passes with no guard findings | `skill-card-schema.md`, `skill-card-spec.md` |
| SC-2 | The linting/validation tools (`skildeck-lint`, `validate_skill_cards.py`) flag a SKILL.md that lacks the pre-flight guard. | behavioral | Run the lint/validation tools against a card with and without the guard; assert a finding when the guard is missing and no finding when present. | `skildeck-lint` tool source, `validate_skill_cards.py` source |
| SC-3 | The skill card requirements documentation (`skill-card-schema.md`, `skill-card-description-standards.md`, `skill-card-spec.md`, `routing-only-template.md`) mandates the guard and defines a single canonical guard definition consistent across all documents. | string | Read the four reference documents; confirm the guard mandate and canonical definition are present and consistent. | `skill-card-schema.md`, `skill-card-description-standards.md` |
| SC-4 | The skill card template generator (`init_skill.py`) includes the pre-flight guard in the generated SKILL_TEMPLATE so new cards are born with the guard. | behavioral | Unit-test `init_skill.py` SKILL_TEMPLATE; generate a card from the template and assert the guard is present. | `init_skill.py` source |
| SC-5 | The critical-rules-XXX rule (dispatching SKILL.md to sub-agents) references the pre-flight guard as the defensive backstop. | string | Read the critical-rules-XXX section in `000-critical-rules.md`; assert the guard reference is present. | `000-critical-rules.md` |

## 4. Requirements

- R-1. The system SHALL add a pre-flight guard to every SKILL.md under `.opencode/skills/` (including `.opencode/skills/*/platforms/*/SKILL.md`) that detects sub-agent context and returns `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` before any routing metadata is consumed.
- R-2. The system SHALL update the skill card linting tool (`skildeck-lint`) to flag a SKILL.md that lacks the pre-flight guard.
- R-3. The system SHALL update `validate_skill_cards.py` to flag a SKILL.md that lacks the pre-flight guard.
- R-4. The system SHALL update the skill card requirements documentation to mandate the guard.
- R-5. The system SHALL define a single canonical guard definition in the requirements documentation that all skill cards use.
- R-6. The system SHALL update the skill card template generator (`init_skill.py`) so newly generated skill cards include the guard.
- R-7. The system SHALL update the critical-rules-XXX rule to reference the pre-flight guard as the defensive backstop.

## 5. Items

### Item 1 (SC-1): Apply the pre-flight guard to all skill cards

- RED: Enforcement check that asserts a skill card without the guard produces a guard finding (grep-based or lint-based).
- GREEN: Add the pre-flight guard section to all 51 SKILL.md files (canonical wording from the requirements docs).
- verify: grep all SKILL.md files for the guard marker; run `skildeck lint` and confirm no guard finding.
- commit: Commit the 51 skill card changes together as one working slice.

### Item 2 (SC-2): Lint and validation enforcement of the guard

- RED: Unit test asserting a card without the guard produces a lint/validation finding.
- GREEN: Add `lint_skill_preflight_guard` to `skildeck-lint` and a REQ rule to `validate_skill_cards.py`.
- verify: Run the lint/validation tools against a card with and without the guard; assert finding present when guard missing, absent when present.
- commit: Commit the lint and validation changes together as one working slice.

### Item 3 (SC-3): Requirements documentation mandate and canonical guard definition

- RED: Assert the requirements docs contain the guard mandate and canonical definition.
- GREEN: Add the guard mandate and canonical guard definition to `skill-card-schema.md`, `skill-card-description-standards.md`, `skill-card-spec.md`, and `routing-only-template.md`.
- verify: Read the four documents; confirm the mandate and canonical definition are present and consistent.
- commit: Commit the four documentation changes together as one working slice.

### Item 4 (SC-4): Template generator includes the guard

- RED: Unit test asserting the generated card from the template contains the guard.
- GREEN: Add the pre-flight guard section to the SKILL_TEMPLATE in `init_skill.py`.
- verify: Unit-test the template string; generate a card and confirm the guard is present.
- commit: Commit the template generator change as one working slice.

### Item 5 (SC-5): Critical rule references the guard

- RED: Assert the critical-rules-XXX section references the guard.
- GREEN: Update the critical-rules-XXX section in `000-critical-rules.md` to reference the pre-flight guard as the defensive backstop.
- verify: Read the critical rule; confirm the guard reference.
- commit: Commit the guideline change as one working slice.

## 6. Dependencies

- **Reference:** `#2052` (canonical skill card structure template — pre-flight gate) — Relationship: complements this spec; introduced the Pre-Flight Gate concept that this spec implements — Status: satisfied (closed/completed).
- **Reference:** `#1992` (task() prohibition in task cards) — Relationship: complementary; no blocking relationship — Status: satisfied (not blocking).
- **Reference:** critical-rules-XXX (dispatching SKILL.md to sub-agents) — Relationship: the normative basis for the guard — Status: satisfied (present in the deck).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 2 |
| R-2 | SC-2 | Phase 3 |
| R-3 | SC-2 | Phase 3 |
| R-4 | SC-3 | Phase 1 |
| R-5 | SC-3 | Phase 1 |
| R-6 | SC-4 | Phase 4 |
| R-7 | SC-5 | Phase 5 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `skill-card-schema.md` | reference doc | `.opencode/reference/skill-card-schema.md` | read |
| `skill-card-description-standards.md` | reference doc | `.opencode/reference/skill-card-description-standards.md` | read |
| `skill-card-spec.md` | reference doc | `.opencode/skills/skill-creator/reference/skill-card-spec.md` | read |
| `routing-only-template.md` | reference doc | `.opencode/skills/skill-creator/reference/routing-only-template.md` | read |
| `skildeck-lint` | code | `.opencode/tools/impl/skildeck/skildeck-lint` | read |
| `validate_skill_cards.py` | code | `.opencode/skills/skill-creator/scripts/validate_skill_cards.py` | read |
| `init_skill.py` | code | `.opencode/skills/skill-creator/scripts/init_skill.py` | read |
| `000-critical-rules.md` | guideline | `.opencode/guidelines/000-critical-rules.md` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying every card carries the guard costs one grep plus a lint run. Skipping means a sub-agent that receives a skill card silently consumes routing metadata it cannot execute, producing defective work that costs a full redo cycle.
- SC-2: Running the lint/validation tools against a guarded and unguarded card costs a bounded tool run. Skipping means an unguarded card passes lint and the guard silently regresses into the deck.
- SC-3: Reading the four reference docs to confirm the canonical definition costs minutes of verification. Skipping means inconsistent guard wording across 37+ cards propagates a multi-definition defect.
- SC-4: Unit-testing the template string costs a single unit-test run. Skipping means newly generated cards ship without the guard, silently reintroducing the gap.
- SC-5: Reading the critical rule to confirm the guard reference costs one read. Skipping means the guard is orphaned from its normative basis and its defensive intent is lost.

## 11. Edge Cases

- **Input boundaries:** A card that already contains a guard must not be double-guarded — the lint rule SHALL be idempotent and flag only cards lacking the guard. The canonical definition MUST be applied verbatim to avoid divergent variants.
- **State transitions:** At the `card_received` boundary, the guard runs context detection; an orchestrator proceeds to `consume_routing_metadata`, a sub-agent transitions to `blocked`. The guard MUST fire before any routing metadata is consumed.
- **Failure modes:** If a card is created without the guard (template bypass or manual edit), lint/validation SHALL flag it (SC-2 backstop). If the canonical definition is inconsistent across docs, the docs mandate (SC-3) SHALL surface the inconsistency.
- **Concurrency:** No shared mutable state; guard detection and linting are per-file and independent.
- **Recovery:** A lint/validation finding SHALL be resolved by adding the canonical guard; the guard is additive and does not alter frontmatter or the Workflows dispatch contract.

🤖 OpenCode (ollama-cloud/deepseek-v4-flash) created
