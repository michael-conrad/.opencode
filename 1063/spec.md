<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# [SPEC] Pipeline Enforcement — Evidence Uplift, Doc-Source Check, SC Traceability, Anti-Merge, SC-ID Format

> **Spec folder:** `.opencode/.issues/1063/spec.md`
> **Repo:** michael-conrad/.opencode
> **Parent coordination:** #850

## Intent and Executive Summary

Add five pipeline enforcement gates: an evidence-type uplift scan at `sc-coherence-gate`, a doc-source-currency check at `pre-red-baseline`, a semantic-intent verification step at `green-doublecheck`, a RED/GREEN step separation enforcement (persona + git diff structural gates), and a mandatory SC-ID referencing format for plan TDD tasks. Together these close five gaps identified in the analysis of the current pipeline's enforcement coverage.

## Objective

Ensure that SC evidence type declarations match actual substrate classification (Item 2), spec documentation sources remain current between approval and implementation (Item 4), every spec SC-ID is traceable through the plan's TDD tasks (Items 7, 39), and RED/GREEN sub-agents never cross the test/implementation boundary (Item 36), and that PASS verdicts at green-doublecheck are confirmed against semantic intent (Item 9).

## Problem

The pipeline currently has no enforcement at five points:

1. **sc-coherence-gate** accepts SC evidence type declarations at face value — a structural SC gets structural evidence, even when the underlying change affects runtime behavior. The evidence type uplift scan (Item 2 from analysis) catches this at step 1 instead of step 8.
2. **pre-red-baseline** does not re-verify spec Documentation Sources before RED-phase begins. Between spec-approval and implementation-start, source files shift. The doc-source-currency check (Item 4) catches drift.
3. **green-doublecheck** accepts an executable command's PASS as sufficient evidence. It does not confirm that the PASS satisfies the spec's semantic intent field (Item 9). This produces false-positive PASS artifacts.
4. **RED/GREEN sub-agents** receive personas that do not enforce file-type boundaries. A RED-phase sub-agent can modify implementation files; a GREEN-phase sub-agent can modify test files. The structural git diff gate (Item 36) is missing.
5. **Plan TDD tasks** have no mandatory SC-ID referencing format. The plan-to-pipeline handoff cannot deterministically extract which SC-IDs a TDD task covers. Items 7 and 39 from the analysis address this.

## Context

Six items from the spec-output requirements analysis (tmp/spec-output-requirements-analysis.md) converge into one spec because they all modify the same set of files — the implementation-pipeline SKILL.md dispatch routing table and the test-driven-development TDD task files (`tasks/red.md`, `tasks/green.md`). Each item is a self-contained pipeline step addition or task-structural change.

## Affected Files

| File | Change | Item |
|------|--------|------|
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add `post-red-enforcement` and `post-green-enforcement` rows to dispatch routing table | 36 |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Update `sc-coherence-gate` row — evidence-type uplift scan | 2 |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Update `pre-red-baseline` row — doc-source-currency check + SC-ID cross-ref traceability | 4, 7 |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Update `green-doublecheck` row — semantic-intent verification | 9 |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Update step labels list | 2, 4, 7, 9, 36 |
| `.opencode/skills/test-driven-development/tasks/red.md` | Add RED persona enforcement block | 36 |
| `.opencode/skills/test-driven-development/tasks/green.md` | Add GREEN persona enforcement block | 36 |
| `.opencode/skills/test-driven-development/SKILL.md` | Add TDD heading format requirement (SC-ID parenthetical) | 39 |
| Plans consuming TDD tasks (future) | TDD task headings MUST use `(SC-<ID>, SC-<ID>, ...)` format | 39 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Pipeline Step | Re-Entry Step |
|----|-----------|---------------|---------------------|---------------|---------------|
| SC-1 | `post-red-enforcement` gate exits FAIL when RED-phase touched `src/` files | `behavioral` | `git diff --name-only -- src/ \| wc -l` after RED-phase → FAIL if > 0 | `post-red-enforcement` | `red-phase` |
| SC-2 | `post-green-enforcement` gate exits FAIL when GREEN-phase touched `test/` files | `behavioral` | `git diff --name-only -- test/ \| wc -l` after GREEN-phase → FAIL if > 0 | `post-green-enforcement` | `green-phase` |
| SC-3 | RED persona in `tasks/red.md` forbids modifying implementation files | `string` | grep `tasks/red.md` for `MUST NOT` + `implementation` or `source files` | spec-auditor (post-spec) | spec-creation |
| SC-4 | GREEN persona in `tasks/green.md` forbids writing or modifying test files | `string` | grep `tasks/green.md` for `MUST NOT` + `test` or `test file` | spec-auditor (post-spec) | spec-creation |
| SC-5 | Dispatch routing table contains `post-red-enforcement` and `post-green-enforcement` rows | `structural` | `ls` confirms rows exist in pipeline SKILL.md table | structural-checks | structural-checks |
| SC-6 | `sc-coherence-gate` dispatch includes evidence-type uplift scan against substrate classification question | `string` | grep pipeline SKILL.md for `evidence-type uplift` or `substrate classification` | structural-checks | sc-coherence-gate |
| SC-7 | `pre-red-baseline` dispatch includes doc-source-currency check that re-verifies spec Documentation Sources | `string` | grep pipeline SKILL.md for `doc-source-currency` or `documentation source` | structural-checks | pre-red-baseline |
| SC-8 | `pre-red-baseline` dispatch verifies every spec SC-ID has corresponding plan TDD task reference | `behavioral` | Pipeline executor dispatches pre-red-baseline which extracts SC-IDs from plan TDD task headings and cross-references against spec SC table | pre-red-baseline | pre-red-baseline |
| SC-9 | `green-doublecheck` dispatch includes semantic-intent verification that confirms PASS satisfies spec intent | `string` | grep pipeline SKILL.md for `semantic-intent` or `intent verification` | structural-checks | green-doublecheck |
| SC-10 | Step labels list in pipeline SKILL.md includes new step entries for 2, 4, 7, 9, 36 changes | `structural` | Match step label count against expected total (14 base + 2 new = 16) | structural-checks | structural-checks |
| SC-11 | TDD task headings in writing-plans output MUST use format `### TDD-<N>: <description> (SC-<ID>, SC-<ID>, ...)` | `string` | grep plan file for `### TDD-\d+:.*\(SC-\d+` | plan-to-pipeline handoff | writing-plans |
| SC-12 | SC-ID cross-references found in plan TDD headings match existing spec SC-IDs | `behavioral` | pre-red-baseline sub-agent parses plan TDD headings, extracts SC-IDs, compares against spec SC table → BLOCKED on mismatch | pre-red-baseline | pre-red-baseline |

## Dependencies

- **#1060** — Spec-auditor must validate the pipeline routing table structure before these changes are accepted (pre-approval gate)
- **#1062** — Plan-to-pipeline handoff manifest must support SC-ID extraction from TDD task headings before pre-red-baseline can use them

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| RED-phase modifies implementation files intentionally (correct behavior change) | Gate catches it — block. RED should only write tests. If test requires helper infra that lives in `src/`, the helper must be pre-existing or the task must be reclassified as a GREEN-phase item. |
| GREEN-phase modifies a test fixture file that lives inside `test/` | Gate catches it — block. Fixture changes are test infrastructure and belong in RED-phase or a separate pre-RED setup step. |
| Green-doublecheck PASS satisfies the literal command output but not the spec's semantic intent | Gate reports FAIL with finding: "PASS artifact produced but intent not satisfied." The sub-agent returns the FAIL artifact; orchestrator routes to remediation. |
| Spec's Documentation Sources reference files or functions that have been renamed or moved since spec approval | Doc-source-currency check reports FAIL with drift summary. Pre-red-baseline halts until spec is updated or drift is resolved. |
| Plan TDD task heading references an SC-ID that does not exist in the spec SC table | Pre-red-baseline BLOCKED — MISSING-TRACEABILITY. Plan must be revised to correct or remove the invalid reference. |
| Evidence-type uplift scan flags a behavioral SC declared as structural | sc-coherence-gate reports EVIDENCE_TYPE_MISMATCH. Orchestrator routes to spec-revision before pipeline continues. |
| Pipeline routing table has exactly 16 step labels but the remaining 14 steps still function | The 2 new steps (`post-red-enforcement`, `post-green-enforcement`) are inserted between existing steps. Existing adjacent steps (`red-phase→red-doublecheck`, `green-phase→green-doublecheck`) shift position but their dispatch logic is unchanged. |

## Risk

| ID | Risk | Likelihood | Impact | Mitigation | Verifying SC | Pipeline Step |
|----|------|------------|--------|------------|--------------|---------------|
| RISK-1 | Git diff gate false-positive (RED touches a generated file in `src/`) | Low | Medium | The `git diff` is scoped to `-- src/` and `-- test/` — generated files outside these prefixes are not caught. Add `.gitattributes` entries for generated paths if needed. | SC-1 | post-red-enforcement |
| RISK-2 | Semantic-intent verification increases green-doublecheck latency | Medium | Low | Inspection is a single sub-agent read of the spec semantic intent field + the PASS artifact. Sub-second overhead. | SC-9 | green-doublecheck |
| RISK-3 | Plan TDD heading format changes break existing plans | Medium | High | Transition period: existing plans without parenthetical SC-IDs are grandfathered. Only new plans (created after this spec's PR merge) must comply. | SC-11 | plan-to-pipeline handoff |

## Documentation Sources

- `tmp/spec-output-requirements-analysis.md` — Items 2, 4, 7, 9, 36, 39
- `.opencode/skills/implementation-pipeline/SKILL.md` — Dispatch routing table at lines 26-42
- `.opencode/skills/test-driven-development/tasks/red.md` — Current RED task file (32 lines)
- `.opencode/skills/test-driven-development/tasks/green.md` — Current GREEN task file (36 lines)
- `.opencode/skills/test-driven-development/SKILL.md` — Current TDD skill file (185 lines)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)