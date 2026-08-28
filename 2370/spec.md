---
number: 2370
title: '[SPEC] Update writing-plans skill — Read-link orchestrator-context-discipline'
status: open
labels: [needs-approval, spec-draft]
---

> **Full spec and artifacts: [`.opencode/.issues/2370/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2370)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2370/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Add mandatory Read-link to orchestrator-context-discipline.md in writing-plans SKILL.md

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The writing-plans skill card (`.opencode/skills/writing-plans/SKILL.md`) does not currently link its consumers to the shared orchestrator-context-discipline reference, so an orchestrator loading the card during plan creation is not instructed to load the context-discipline rules into its context. |
| 2 | **Root Cause / Motivation** | The orchestrator-context-lean, sub-agent-context-generosity, and result-contract-frugality mandates are moving to the shared reference `.opencode/reference/orchestrator-context-discipline.md` (issue #2359). Consuming skill cards must anchor that reference via a mandatory `Read [Text](path)` link so the discipline is actually loaded during plan creation. Without the link, the condensation of 020-go-prohibitions.md §1.1 would leave the rules unreachable from the writing-plans workflow. |
| 3 | **Approach Chosen** | Add a mandatory `Read [Text](path)` link to orchestrator-context-discipline.md in the writing-plans SKILL.md Cross-References section, using the canonical imperative inline-link form. The link path resolves to `reference/orchestrator-context-discipline.md` relative to `.opencode/`. |
| 4 | **Alternatives Considered & Why Discarded** | Re-inlining the context-discipline content into the writing-plans card was considered and discarded — it duplicates content and creates drift risk, violating the single-source-of-truth principle. A resolution table or bare `§Name` citation was discarded per the cross-reference-form-comparison research card (only 42-58% access rate vs. 100% for the imperative inline-link form). |
| 5 | **Key Design Decisions** | (1) The link uses the mandatory `Read [Text](path)` form per the Read-Link Cross-Reference Rule (Tier 1) — not "See", not a resolution table. (2) The link lives in the Cross-References section, the canonical home for shared-reference Read-links. (3) The change is confined to the SKILL.md card — no task file, contract, or frontmatter is modified. |
| 6 | **User Intent / Original Prompt** | Update the writing-plans skill card to add a mandatory Read-link to the shared orchestrator-context-discipline reference, enabling the 020-go-prohibitions condensation while keeping the discipline rules reachable during plan creation. |

## 2. Not Included

- **Creating the reference file** — `.opencode/reference/orchestrator-context-discipline.md` is created by issue #2359, not this spec.
- **020-go-prohibitions.md §1.1 condensation** — The condensation of the guideline content is a separate downstream issue, not this spec's scope.
- **Re-inlining the context-discipline rules** — The rules live only in the shared reference; this spec adds the link, never the content.
- **Modifying writing-plans task files** — The change is confined to the SKILL.md card; no `tasks/*.md`, contract, or reference file under the skill is touched.
- **Other skill cards** — Each consuming card's Read-link is owned by its own issue; this spec covers only writing-plans.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The writing-plans SKILL.md Cross-References section SHALL contain a mandatory `Read [Text](path)` link to orchestrator-context-discipline.md whose path resolves to `.opencode/reference/orchestrator-context-discipline.md`, and an orchestrator dispatching the writing-plans skill SHALL load that reference into its context during plan creation. | behavioral | `opencode run` behavioral test `writing-plans-reads-context-discipline-reference` — dispatch writing-plans against a real AI model and inspect stderr for a read tool call targeting orchestrator-context-discipline.md (assert_stderr_pattern_present). Supplementary structural check confirms the Read-link presence in the Cross-References section. | `.opencode/skills/writing-plans/SKILL.md` (Cross-References section); `.opencode/reference/orchestrator-context-discipline.md` (link target, created by #2359); `.opencode/guidelines/000-critical-rules.md` (Read-Link rule) |

## 4. Requirements

- R-1. The writing-plans SKILL.md SHALL include a mandatory `Read [Text](path)` link to orchestrator-context-discipline.md in its Cross-References section.
- R-2. The link target path SHALL resolve to `.opencode/reference/orchestrator-context-discipline.md`.
- R-3. The link SHALL use the canonical `Read [Text](path)` form — not "See", not a resolution table.
- R-4. The link SHALL be placed in the Cross-References section of the writing-plans SKILL.md.
- R-5. The link SHALL be mandatory — the orchestrator loads the context-discipline reference into its context during plan creation.
- R-6. The context-discipline rules SHALL NOT be lost or duplicated inline; they SHALL be preserved in the shared reference.
- R-C1. Implementation SHALL depend on `.opencode/reference/orchestrator-context-discipline.md` existing (issue #2359) and the 020-go-prohibitions.md §1.1 condensation being complete.
- R-N1. This issue SHALL NOT create the reference file, condense 020-go-prohibitions.md, or modify any writing-plans task file.

## 5. Items

### Item 1 (SC-1): Add mandatory Read-link to orchestrator-context-discipline.md in writing-plans SKILL.md

- RED: Behavioral enforcement test asserts the orchestrator does NOT currently load orchestrator-context-discipline.md when dispatching writing-plans (no Read-link present) — assert_stderr_pattern_absent on the reference path.
- GREEN: Add the mandatory `Read [Text](path)` link to orchestrator-context-discipline.md in the writing-plans SKILL.md Cross-References section.
- verify: Re-run the behavioral test — assert the orchestrator DOES load orchestrator-context-discipline.md (assert_stderr_pattern_present on the reference path / a read tool call targeting it).
- commit: Single atomic commit for the SKILL.md change + behavioral test.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode#2359` | Creates `.opencode/reference/orchestrator-context-discipline.md` — the link target. MUST be merged before this change lands and before the behavioral GREEN test can pass. | pending (open, [needs-approval, spec-draft]) |
| `020-go-prohibitions.md §1.1` | The §1.1 content must be condensed into the shared reference before the link is the canonical home of the rules. | pending (separate condensation issue) |
| `000-critical-rules.md` Read-Link Cross-Reference Rule | Tier 1 mandate requiring the `Read [Text](path)` form. | satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1 | Phase 1 |
| R-5 | SC-1 | Phase 1 |
| R-6 | SC-1 | Phase 1 |
| R-C1 | SC-1 | Phase 1 |
| R-N1 | SC-1 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| writing-plans SKILL.md | code | `.opencode/skills/writing-plans/SKILL.md` | read — Cross-References section (lines 185-187) |
| orchestrator-context-discipline.md | doc (target) | `.opencode/reference/orchestrator-context-discipline.md` (created by #2359) | read after #2359 lands |
| Read-Link Cross-Reference Rule | guideline | `.opencode/guidelines/000-critical-rules.md` | read |
| cross-reference-form-comparison.md | research card | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | read — confidence 0.95, Form A 100% access rate |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Running the behavioral test costs minutes of execution time — a bounded delay that surfaces the context-loading defect at the earliest gate. Skipping it means an orchestrator that fails to load the context-discipline reference ships unchanged; the defect is discovered only when a plan is created without the discipline rules, costing the full rework cycle (diagnose + fix + re-CI + re-deploy) at 1000× the bounded test cost.

## 11. Edge Cases

- **Input boundaries:** Not applicable — this is a static content change to a skill card; no runtime input surface exists.
- **State transitions:** The only affected "state" is orchestrator context — after the change, an orchestrator loading the writing-plans card additionally loads the orchestrator-context-discipline reference. No state-machine transition is introduced.
- **Failure modes:** If `.opencode/reference/orchestrator-context-discipline.md` does not exist (issue #2359 not landed), the link resolves to a nonexistent file and the behavioral GREEN test cannot pass. Resolution: implementation MUST NOT begin until the dependency resolves; the SC is FAIL until then.
- **Concurrency:** Not applicable — single-file additive content change; no shared mutable state.
- **Recovery:** If the dependency is unresolved, block implementation and re-dispatch after #2359 lands. No rollback path is needed beyond reverting the single additive link.
