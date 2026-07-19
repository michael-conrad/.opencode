---
title: "[SPEC-FIX] Plan template must mandate full implementation pipeline; remote spec body format must be enforced"
status: draft
created: 2026-07-19
license: MIT
provenance: AI-generated
issue: 2009
authors:
  - OpenCode (nemotron-3-ultra-free)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-19

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

Two structural defects were discovered during the #1962 plan creation workflow:

### Defect 1: Remote spec body format not enforced

The `spec-creation-validation/tasks/revise-remote-body.md` task defines the correct remote issue body format:
- Blockquote with link to `.issues/{N}/` on `issues-data` branch
- Exec Summary with cards, key decisions, risk callouts
- Success Criteria table
- AI Agent Instructions

However, specs created outside the spec-creation pipeline (e.g., manually, via brainstorming, or by direct `github_issue_write`) produce arbitrary remote bodies. The spec-audit does not check remote body format. This means:
- Remote issue bodies may contain full spec content instead of exec summary
- Blockquote links may be missing or incorrect
- AI Agent Instructions may be absent
- Human reviewers cannot find the authoritative spec

### Defect 2: Plan template missing mandatory implementation pipeline

The writing-plans plan model (defined in `writing-plans-creation/tasks/write.md`) has no requirement that plans include the full implementation pipeline. The plan template only requires:
- Goal, Architecture, Files, Phase table, Exit criteria
- Safety/Rollback, Feasibility, Evidence, SC-to-Step traceability

It does NOT require:
- **Pre-RED common steps:** assemble-work, sc-coherence-gate, pre-red-baseline
- **RED/GREEN chained pipeline per item:** red-phase, z3-check-red, red-doublecheck, green-phase, z3-check-green, green-doublecheck, checkpoint-tag-create, checkpoint-commit
- **Post-GREEN common steps:** green-vbc, sc-count-gate, pre-pr-gate, audit, cross-validate, regression-check, review-prep, create-pr, exec-summary

Without this mandate, every plan produced by writing-plans is structurally defective — it omits the pipeline gates that catch defects before they reach CI.

## Root Cause Analysis

### Root Cause 1: No spec-audit check for remote body format

The `spec-audit` task validates spec content (structure, determinism, documentation sources) but does not check the remote issue body format. The `revise-remote-body.md` task is a procedural step in the spec-creation pipeline, not an enforcement gate. Specs created outside the pipeline bypass it entirely.

**Fix target:** Add remote body format check to `spec-audit` evaluator task.

### Root Cause 2: Plan template has no pipeline mandate

The `writing-plans-creation/tasks/write.md` task defines the plan template sections but does not include a mandatory Pipeline Steps section. The plan model in `writing-plans/SKILL.md` describes the split file convention (index + phase files) but does not mandate the implementation pipeline structure.

The `implementation-pipeline/SKILL.md` Trigger Dispatch Table defines the canonical pipeline (assemble-work → sc-coherence-gate → pre-red-baseline → RED/GREEN per item → VbC → sc-count-gate → pre-pr-gate → audit → cross-validate → regression-check → review-prep → create-pr → exec-summary), but nothing requires plans to include these steps.

**Fix target:** Add mandatory Pipeline Steps section to `writing-plans-creation/tasks/write.md` plan template. Add plan-fidelity audit check for pipeline completeness.

## Goals

- [ ] G1: spec-audit checks remote issue body format (blockquote links, exec summary, AI agent instructions)
- [ ] G2: writing-plans plan template includes mandatory Pipeline Steps section with all implementation pipeline stages
- [ ] G3: Plan-fidelity audit checks for mandatory pipeline steps and FAILs if missing
- [ ] G4: All 8 SCs from #1962 remain satisfied

## Non-Goals

- **Rewriting the implementation pipeline** — Pipeline steps are already defined in `implementation-pipeline/SKILL.md`. This spec only adds enforcement that plans must include them.
- **Retroactively fixing existing plans** — Only newly created plans must comply. Existing plans are grandfathered.
- **Changing the spec-creation pipeline** — Only adding an audit check, not modifying the pipeline itself.

## Constraints and Scope

**In Scope:**
- `spec-creation-validation/tasks/spec-audit-evaluator.md` — Add remote body format check
- `writing-plans-creation/tasks/write.md` — Add mandatory Pipeline Steps section to plan template
- `audit/tasks/plan-fidelity-evaluator.md` — Add pipeline completeness check

**Out of Scope:**
- Existing plans (grandfathered)
- Implementation-pipeline skill (reference pattern only)
- Spec-creation pipeline structure

## Safety Considerations

- **No destructive operations** — Only task file modifications
- **No database/schema changes** — Pure enforcement additions
- **Rollback:** `git revert` on affected task files
- **Data loss risk:** None

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Add pipeline mandate to writing-plans/SKILL.md plan model | Plan model describes file structure, not content. Content mandate belongs in write.md template. |
| Create separate spec for each defect | Defects share root cause (missing enforcement gates). Single spec is more efficient. |
| Fix via guideline change | Guidelines are advisory. Task file changes are enforceable. |

## Evidence/Provenance

| Claim | Evidence Source |
|-------|-----------------|
| `revise-remote-body.md` defines remote body format | `read` task file |
| `write.md` plan template has no Pipeline Steps section | `read` task file |
| `implementation-pipeline/SKILL.md` TDT defines 15+ pipeline stages | `read` SKILL.md |
| spec-audit does not check remote body format | `read` spec-audit-evaluator.md |
| plan-fidelity audit does not check pipeline completeness | `read` plan-fidelity-evaluator.md |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Artifact Path |
|----|-----------|---------------|---------------------|-------------|--------------|
| SC-1 | `write.md` plan template includes mandatory Pipeline Steps section with all 15 stages (assemble-work, sc-coherence-gate, pre-red-baseline, RED/GREEN per item with Z3 checks, VbC, sc-count-gate, pre-pr-gate, audit, cross-validate, regression-check, review-prep, create-pr, exec-summary) | structural | `read` write.md → find Pipeline Steps section with all stages | Add Pipeline Steps section to plan template | `.opencode/skills/writing-plans-creation/tasks/write.md` |
| SC-2 | spec-audit evaluator checks remote body format (blockquote links, exec summary, AI agent instructions) and FAILs if missing | behavioral | `opencode run` → verify spec-audit FAILs on missing blockquote | Add remote body format check to evaluator | `.opencode/skills/spec-creation-validation/tasks/spec-audit-evaluator.md` |
| SC-3 | Plan-fidelity audit checks for mandatory pipeline steps and FAILs if missing | behavioral | `opencode run` → verify plan-fidelity FAILs on missing pipeline steps | Add pipeline completeness check to evaluator | `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` |
| SC-4 | All 8 SCs from #1962 remain satisfied | structural | `grep` for SC-1 through SC-8 in #1962 spec → all present | No changes to #1962 spec | `.opencode/.issues/1962/spec.md` |

## Pipeline / Workflows

### Workflow 1: Fix plan template (write.md)

```
 1. [sub-task] Read current write.md plan template
 2. [sub-task] Add mandatory Pipeline Steps section with all 15 stages
 3. [inline]  Verify: read write.md → Pipeline Steps section present
```

### Workflow 2: Fix spec-audit evaluator

```
 1. [sub-task] Read current spec-audit-evaluator.md
 2. [sub-task] Add remote body format check (blockquote links, exec summary, AI agent instructions)
 3. [inline]  Verify: behavioral test confirms FAIL on missing blockquote
```

### Workflow 3: Fix plan-fidelity evaluator

```
 1. [sub-task] Read current plan-fidelity-evaluator.md
 2. [sub-task] Add pipeline completeness check (all 15 stages must be present)
 3. [inline]  Verify: behavioral test confirms FAIL on missing pipeline steps
```

## Implementation Approach

**Phase 1 (single spec, single plan):**
1. Update `writing-plans-creation/tasks/write.md` — Add mandatory Pipeline Steps section to plan template
2. Update `spec-creation-validation/tasks/spec-audit-evaluator.md` — Add remote body format check
3. Update `audit/tasks/plan-fidelity-evaluator.md` — Add pipeline completeness check
4. Run `local-issues sync` after each file change
5. Self-review per spec-creation-validation Step 33-35

## Interdependency

| Issue | Direction | Classification | Description |
|-------|-----------|---------------|-------------|
| [#1962](https://github.com/michael-conrad/.opencode/issues/1962) | downstream | DEPENDS_ON | This spec's plan template fix depends on #1962's writing-plans-creation task card conversion |
| [#2008](https://github.com/michael-conrad/.opencode/issues/2008) | upstream | SUPERSEDED_BY | #2008 proposed adding TDT to writing-plans-creation (old approach). Superseded by #1962. |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read spec-creation-validation/tasks/revise-remote-body.md` | Verify remote body format definition |
| Direct source search | `read writing-plans-creation/tasks/write.md` | Verify plan template content |
| Direct source search | `read implementation-pipeline/SKILL.md` | Verify pipeline stage definitions |
| Direct source search | `read spec-creation-validation/tasks/spec-audit-evaluator.md` | Verify current audit scope |
| Direct source search | `read audit/tasks/plan-fidelity-evaluator.md` | Verify current audit scope |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Pipeline mandate in write.md template (not plan model) | Plan model describes file structure. Content mandate belongs in write task. | MUST | SC-1 |
| DEC-2 | Enforcement via audit (not guideline) | Guidelines are advisory. Audit FAILs are enforceable gates. | MUST | SC-2, SC-3 |
| DEC-3 | Existing plans grandfathered | Retroactive enforcement would break existing work. | SHOULD NOT | SC-4 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Spec Family Annotation

family: plan-pipeline-mandate
selectors:
  - spec: #2009
  - spec: glob(pattern: ".opencode/skills/writing-plans-creation/tasks/write.md")
  - spec: glob(pattern: ".opencode/skills/spec-creation-validation/tasks/spec-audit-evaluator.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/plan-fidelity-evaluator.md")

## Explicit Non-Goals

- **Rewriting the implementation pipeline** — Pipeline steps are already defined. This spec only adds enforcement.
- **Retroactively fixing existing plans** — Only newly created plans must comply.
- **Changing the spec-creation pipeline** — Only adding an audit check.

## Regression Invariants

- [ ] 1. Existing spec-audit checks still pass
- [ ] 2. Existing plan-fidelity checks still pass
- [ ] 3. Existing write.md plan template sections preserved
- [ ] 4. #1962 SCs remain satisfied

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)
