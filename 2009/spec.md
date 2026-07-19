---
title: "[SPEC-FIX] Plan template must mandate full implementation pipeline; spec-creation pipeline must be enforced as sole spec creation path"
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

### Defect 1: Spec-creation pipeline not enforced as sole spec creation path

The spec-creation pipeline (defined in `spec-creation/SKILL.md` Pipeline section) is the mandatory path for ALL spec creation. It produces:
- Local spec at `.issues/{N}/spec.md` with full analytical artifacts
- Remote issue body with blockquote links, exec summary, and AI agent instructions
- All 7 analytical artifacts at `.issues/{N}/artifacts/`

However, agents can bypass the pipeline by calling `github_issue_write` directly or writing spec content inline. When this happens:
- Remote issue bodies contain arbitrary content (full spec body, no blockquote links, no AI agent instructions)
- No analytical artifacts are generated
- No local `.issues/{N}/` entry is created
- Human reviewers cannot find the authoritative spec
- The spec fails spec-audit's provenance check

The fix is NOT an audit check — the fix is behavioral enforcement that agents MUST route ALL spec creation through the spec-creation pipeline. Direct `github_issue_write` for spec content is a critical violation.

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

### Root Cause 1: No behavioral enforcement that spec-creation pipeline is the sole spec creation path

The `000-critical-rules.md` has a rule against direct `github_issue_write` for spec content (critical-rules-XXX), but it's a Tier 2 rule (process-integrity, overridable). The spec-creation pipeline is the mandatory path — bypassing it should be Tier 1 (safety-critical, never overridable). Additionally, there is no behavioral enforcement test that verifies agents route through the pipeline.

**Fix target:** Upgrade critical-rules-XXX to Tier 1. Add behavioral enforcement test.

### Root Cause 2: Plan template has no pipeline mandate

The `writing-plans-creation/tasks/write.md` task defines the plan template sections but does not include a mandatory Pipeline Steps section. The plan model in `writing-plans/SKILL.md` describes the split file convention (index + phase files) but does not mandate the implementation pipeline structure.

The `implementation-pipeline/SKILL.md` Trigger Dispatch Table defines the canonical pipeline (assemble-work → sc-coherence-gate → pre-red-baseline → RED/GREEN per item → VbC → sc-count-gate → pre-pr-gate → audit → cross-validate → regression-check → review-prep → create-pr → exec-summary), but nothing requires plans to include these steps.

**Fix target:** Add mandatory Pipeline Steps section to `writing-plans-creation/tasks/write.md` plan template. Add plan-fidelity audit check for pipeline completeness.

## Goals

- [ ] G1: Direct `github_issue_write` for spec content is Tier 1 CRITICAL VIOLATION — never overridable
- [ ] G2: Behavioral enforcement test verifies agent routes spec creation through spec-creation pipeline
- [ ] G3: writing-plans plan template includes mandatory Pipeline Steps section with all implementation pipeline stages
- [ ] G4: Plan-fidelity audit checks for mandatory pipeline steps and FAILs if missing
- [ ] G5: All 8 SCs from #1962 remain satisfied

## Non-Goals

- **Rewriting the implementation pipeline** — Pipeline steps are already defined in `implementation-pipeline/SKILL.md`. This spec only adds enforcement that plans must include them.
- **Retroactively fixing existing plans** — Only newly created plans must comply. Existing plans are grandfathered.
- **Changing the spec-creation pipeline** — Only adding enforcement, not modifying the pipeline itself.

## Constraints and Scope

**In Scope:**
- `000-critical-rules.md` — Upgrade spec-creation bypass rule to Tier 1
- `.opencode/tests-v2/behaviors/` — Add behavioral enforcement test for spec-creation pipeline routing
- `writing-plans-creation/tasks/write.md` — Add mandatory Pipeline Steps section to plan template
- `audit/tasks/plan-fidelity-evaluator.md` — Add pipeline completeness check

**Out of Scope:**
- Existing plans (grandfathered)
- Implementation-pipeline skill (reference pattern only)
- Spec-creation pipeline structure

## Safety Considerations

- **No destructive operations** — Only task file modifications and rule upgrades
- **No database/schema changes** — Pure enforcement additions
- **Rollback:** `git revert` on affected files
- **Data loss risk:** None

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Add audit check for remote body format (old approach) | Band-aid fix. Root cause is pipeline bypass, not format. Behavioral enforcement prevents bypass entirely. |
| Create separate spec for each defect | Defects share root cause (missing enforcement). Single spec is more efficient. |
| Fix via guideline only | Guidelines are advisory. Tier 1 critical violation + behavioral test is enforceable. |

## Evidence/Provenance

| Claim | Evidence Source |
|-------|-----------------|
| `write.md` plan template has no Pipeline Steps section | `read` task file |
| `implementation-pipeline/SKILL.md` TDT defines 15+ pipeline stages | `read` SKILL.md |
| critical-rules-XXX is Tier 2 (overridable) | `read` 000-critical-rules.md |
| No behavioral test for spec-creation pipeline routing | `ls tests-v2/behaviors/` → no matching file |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Artifact Path |
|----|-----------|---------------|---------------------|-------------|--------------|
| SC-1 | Direct `github_issue_write` for spec content is Tier 1 CRITICAL VIOLATION in 000-critical-rules.md | structural | `read` 000-critical-rules.md → find rule with Tier 1 classification | Upgrade rule to Tier 1 | `.opencode/guidelines/000-critical-rules.md` |
| SC-2 | Behavioral enforcement test verifies agent routes spec creation through spec-creation pipeline (FAILs on direct write) | behavioral | `opencode run` → verify agent uses spec-creation pipeline, not direct write | Create behavioral test | `.opencode/tests-v2/behaviors/` |
| SC-3 | `write.md` plan template includes mandatory Pipeline Steps section with all 15 stages (assemble-work, sc-coherence-gate, pre-red-baseline, RED/GREEN per item with Z3 checks, VbC, sc-count-gate, pre-pr-gate, audit, cross-validate, regression-check, review-prep, create-pr, exec-summary) | structural | `read` write.md → find Pipeline Steps section with all stages | Add Pipeline Steps section to plan template | `.opencode/skills/writing-plans-creation/tasks/write.md` |
| SC-4 | Plan-fidelity audit checks for mandatory pipeline steps and FAILs if missing | behavioral | `opencode run` → verify plan-fidelity FAILs on missing pipeline steps | Add pipeline completeness check to evaluator | `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` |
| SC-5 | All 8 SCs from #1962 remain satisfied | structural | `grep` for SC-1 through SC-8 in #1962 spec → all present | No changes to #1962 spec | `.opencode/.issues/1962/spec.md` |

## Pipeline / Workflows

### Workflow 1: Upgrade critical rule + add behavioral test

```
 1. [sub-task] Upgrade critical-rules-XXX to Tier 1 in 000-critical-rules.md
 2. [sub-task] Create behavioral enforcement test for spec-creation pipeline routing
 3. [inline]  Verify: behavioral test FAILs on direct write, PASSes on pipeline routing
```

### Workflow 2: Fix plan template (write.md)

```
 1. [sub-task] Read current write.md plan template
 2. [sub-task] Add mandatory Pipeline Steps section with all 15 stages
 3. [inline]  Verify: read write.md → Pipeline Steps section present
```

### Workflow 3: Fix plan-fidelity evaluator

```
 1. [sub-task] Read current plan-fidelity-evaluator.md
 2. [sub-task] Add pipeline completeness check (all 15 stages must be present)
 3. [inline]  Verify: behavioral test confirms FAIL on missing pipeline steps
```

## Implementation Approach

**Phase 1 (single spec, single plan):**
1. Update `000-critical-rules.md` — Upgrade spec-creation bypass rule to Tier 1
2. Create behavioral enforcement test in `tests-v2/behaviors/`
3. Update `writing-plans-creation/tasks/write.md` — Add mandatory Pipeline Steps section to plan template
4. Update `audit/tasks/plan-fidelity-evaluator.md` — Add pipeline completeness check
5. Run `local-issues sync` after each file change
6. Self-review per spec-creation-validation Step 33-35

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
| Direct source search | `read writing-plans-creation/tasks/write.md` | Verify plan template content |
| Direct source search | `read implementation-pipeline/SKILL.md` | Verify pipeline stage definitions |
| Direct source search | `read 000-critical-rules.md` | Verify current Tier classification |
| Direct source search | `ls tests-v2/behaviors/` | Verify no existing test for this concern |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Tier 1 enforcement (not audit check) | Behavioral enforcement prevents bypass. Audit check only catches it after the fact. | MUST | SC-1, SC-2 |
| DEC-2 | Pipeline mandate in write.md template (not plan model) | Plan model describes file structure. Content mandate belongs in write task. | MUST | SC-3 |
| DEC-3 | Enforcement via plan-fidelity audit | Plans missing pipeline steps fail audit. This is an enforceable gate. | MUST | SC-4 |
| DEC-4 | Existing plans grandfathered | Retroactive enforcement would break existing work. | SHOULD NOT | SC-5 |

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
  - spec: glob(pattern: ".opencode/guidelines/000-critical-rules.md")
  - spec: glob(pattern: ".opencode/skills/writing-plans-creation/tasks/write.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/plan-fidelity-evaluator.md")

## Explicit Non-Goals

- **Rewriting the implementation pipeline** — Pipeline steps are already defined. This spec only adds enforcement.
- **Retroactively fixing existing plans** — Only newly created plans must comply.
- **Changing the spec-creation pipeline** — Only adding enforcement, not modifying the pipeline itself.

## Regression Invariants

- [ ] 1. Existing critical-rules Tier 1 rules unchanged
- [ ] 2. Existing plan-fidelity checks still pass
- [ ] 3. Existing write.md plan template sections preserved
- [ ] 4. #1962 SCs remain satisfied

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)
