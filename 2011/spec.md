---
title: "[SPEC-FIX] Behavioral SC evidence enforcement: classification gate at spec-writing + clean-room evaluation at audit"
status: draft
created: 2026-07-19
license: MIT
provenance: AI-generated
issue: 2011
authors:
  - OpenCode (nemotron-3-ultra-free)
supersedes:
  - 1378
---

**STATUS:** DRAFT
**CREATED:** 2026-07-19

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

Two defects in the behavioral SC evidence pipeline, discovered during #2009 clean-room re-audit:

### Defect 1: No mandatory BEH-EV classification at spec-writing time

Spec authors routinely declare `structural` evidence type for SCs that verify changes to agent-facing configuration files — SKILL.md descriptions, trigger dispatch tables, invocation tables, sub-agent routing sections, task files, and enforcement blocks. These changes affect **runtime agent behavior** (dispatch decisions, tool selection, pipeline routing, enforcement gate outcomes), which means the BEH-EV classification gate (`000-critical-rules.md` §critical-rules-BEH-EV) automatically uplifts them to `behavioral`.

The spec-creation workflow has no mandatory step for classifying whether a change affects runtime agent behavior. The author chooses evidence type based on convenience ("structural is easier to verify") rather than substrate classification ("does this change affect runtime behavior?").

**Evidence:** Issue #1376's spec declared all 15 SCs as `structural`. The cross-validate correctly flagged all 15 as EVIDENCE_TYPE_MISMATCH because SKILL.md descriptions, trigger dispatch tables, invocation tables, and sub-agent routing sections all control what the agent does at runtime.

### Defect 2: Evaluators accept file-existence as behavioral evidence

The verification-audit evaluator (`audit/tasks/verification-audit-evaluator.md`) evaluates SCs against evidence. For behavioral SCs, it checks whether behavioral evidence artifacts exist in the `artifact_evidence_dir`. If files exist, it reports PASS — without reading the actual content of stdout.log or stderr.log to determine whether the agent's actions satisfied the SC.

The evaluator has no step that dispatches a clean-room sub-agent to read the raw artifacts and render a binary judgment. The evaluator itself is not a clean-room sub-agent — it receives orchestrator context and cached results. A true clean-room evaluation requires a sub-agent that receives ONLY the artifact directory path, reads the artifacts cold, and renders PASS/FAIL independently.

This defect exists in ALL evaluator tasks (verification-audit, spec-audit, plan-fidelity, concern-separation, coherence-maintenance, drift-detection, test-quality-audit, content-audit), not just verification-audit.

## Root Cause Analysis

### Root Cause 1: No classification step in spec-creation/write.md

The `spec-creation/tasks/write.md` task defines the spec body template but has no mandatory step for classifying evidence types against the substrate-determined question ("does this change affect runtime behavior?"). The author can declare any evidence type without being flagged.

**Fix target:** `spec-creation-validation/tasks/create.md` — Add mandatory BEH-EV classification step with presumptive runtime-behavioral file types.

### Root Cause 2: All evaluators accept file-existence for behavioral SCs

Every evaluator task in `audit/tasks/` has the same pattern: check if evidence artifacts exist, report PASS. None dispatch a clean-room sub-agent to read the raw artifacts and render a binary judgment. This is the same defect as critical-rules-047 (VbC Fabricated PASS) and critical-rules-BEH-EV (EVIDENCE_TYPE_MISMATCH).

**Fix target:** ALL evaluator tasks — Add mandatory clean-room sub-agent dispatch for behavioral SCs. The evaluator MUST NOT accept file-existence as evidence for behavioral SCs.

## Goals

- [ ] G1: spec-creation-validation/tasks/create.md has mandatory BEH-EV classification step with presumptive runtime-behavioral file types
- [ ] G2: ALL evaluator tasks dispatch clean-room sub-agent for behavioral SCs (receives artifact dir only, no orchestrator context)
- [ ] G3: Clean-room sub-agent reads stdout.log/stderr.log and renders binary PASS/FAIL — file-existence alone is FAIL
- [ ] G4: Cross-validate arbiter detects EVIDENCE_TYPE_MISMATCH when behavioral SC verdict cites only file paths
- [ ] G5: All 5 SCs from #2009 remain satisfied

## Non-Goals

- **Retroactively fixing existing behavioral SC verdicts** — Only newly verified SCs must comply
- **Changing the behavioral test harness** — The harness produces artifacts correctly. Only the evaluation is broken.
- **Cost model formalization** — Covered by #916 (approved-for-PR, separate spec)
- **Rewriting evaluator internals** — Only the behavioral SC evaluation path needs fixing

## Constraints and Scope

**In Scope:**
- `spec-creation-validation/tasks/create.md` — Add mandatory BEH-EV classification step
- `audit/tasks/verification-audit-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/spec-audit-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/plan-fidelity-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/concern-separation-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/coherence-maintenance-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/drift-detection-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/test-quality-audit-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/content-audit-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/guideline-audit-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/cross-validate.md` — Add EVIDENCE_TYPE_MISMATCH detection
- `audit/tasks/behavioral-sc-evaluator.md` — New clean-room evaluation task

**Out of Scope:**
- Behavioral test harness — produces correct artifacts
- Existing SC verdicts — grandfathered
- Cost model formalization — #916
- Evaluator investigator/validator/arbiter roles — only evaluator role needs fixing

## Safety Considerations

- **No destructive operations** — Only task file modifications
- **No database/schema changes** — Pure enforcement additions
- **Rollback:** `git revert` on affected task files
- **Data loss risk:** None

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Fix only verification-audit (narrow #2011) | Same defect exists in ALL evaluators. Fixing one leaves 7 others broken. |
| Fix in cross-validate only | Cross-validate is downstream. Evaluators should produce correct verdicts. |
| Add guideline instead of task fix | Guidelines are advisory. Task file changes are enforceable. |
| Make evaluator read artifacts directly | Evaluator is not clean-room — it receives orchestrator context. Only a fresh sub-agent is clean. |
| Keep #1378 as separate spec | #1378 and #2011 share the same root cause and fix targets. Folding avoids duplicate work. |

## Evidence/Provenance

| Claim | Evidence Source |
|-------|-----------------|
| spec-creation/write.md has no BEH-EV classification step | `read` write.md → no "Evidence Type Classification Gate" section |
| verification-audit evaluator accepts file-existence for behavioral SCs | `read` verification-audit-evaluator.md → find behavioral SC evaluation logic |
| No clean-room sub-agent dispatch in any evaluator | `grep` for `task(` or `sub-agent` in all evaluator files → zero matches |
| cross-validate has no EVIDENCE_TYPE_MISMATCH check | `read` cross-validate.md → find evidence type validation |
| #2009 re-audit reported PASS for SC-2/SC-4 via file-existence | Session transcript from 2026-07-19 |
| #1376 spec declared 15 SCs as structural for runtime-behavioral changes | `read` #1376 spec → SC table |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Artifact Path |
|----|-----------|---------------|---------------------|-------------|--------------|
| SC-1 | spec-creation-validation/tasks/create.md contains mandatory BEH-EV classification step with presumptive runtime-behavioral file types (SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md) | behavioral | `opencode run` → verify spec-creation agent includes BEH-EV classification step when writing specs | Add classification step | `.opencode/skills/spec-creation-validation/tasks/create.md` |
| SC-2 | ALL 9 evaluator tasks dispatch clean-room sub-agent for behavioral SCs (receives artifact dir only, no orchestrator context) | behavioral | `opencode run` → verify clean-room sub-agent dispatch in stderr for each evaluator | Add clean-room dispatch step to each evaluator | `.opencode/skills/audit/tasks/*-evaluator.md` |
| SC-3 | Clean-room sub-agent (behavioral-sc-evaluator.md) reads stdout.log/stderr.log and renders binary PASS/FAIL — file-existence alone is FAIL | behavioral | `opencode run` → verify clean-room sub-agent reads artifacts and returns binary verdict | Create clean-room evaluation task | `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` |
| SC-4 | Cross-validate arbiter detects EVIDENCE_TYPE_MISMATCH when behavioral SC verdict cites only file paths (no content analysis) | behavioral | `opencode run` → verify cross-validate FAILs on file-path-only behavioral verdict | Add EVIDENCE_TYPE_MISMATCH check to cross-validate | `.opencode/skills/audit/tasks/cross-validate.md` |
| SC-5 | All 5 SCs from #2009 remain satisfied | structural | `grep` for SC-1 through SC-5 in #2009 spec → all present | No changes to #2009 spec | `.opencode/.issues/2009/spec.md` |

## Pipeline / Workflows

### Workflow 1: Add BEH-EV classification step to spec-creation/write.md

```
 1. [sub-task] Read current spec-creation/tasks/write.md
 2. [sub-task] Add "Evidence Type Classification Gate" step between SC definition and spec finalization
 3. [sub-task] Include presumptive runtime-behavioral file types (SKILL.md, tasks/*.md, guidelines/*.md, enforcement/*.md)
 4. [inline]  Verify: grep for "Evidence Type Classification Gate" in write.md
```

### Workflow 2: Create clean-room evaluation task

```
 1. [sub-task] Create audit/tasks/behavioral-sc-evaluator.md
 2. [sub-task] Task receives ONLY artifact directory path (no orchestrator context)
 3. [sub-task] Task reads stdout.log/stderr.log, renders binary PASS/FAIL per SC
 4. [sub-task] File-existence alone returns FAIL
 5. [inline]  Verify: behavioral test confirms clean-room dispatch in stderr
```

### Workflow 3: Fix all 8 evaluator tasks

```
 1. [sub-task] For each evaluator: add step dispatching behavioral-sc-evaluator for behavioral SCs
 2. [sub-task] If clean-room returns FAIL, evaluator verdict is FAIL (not PASS)
 3. [inline]  Verify: each evaluator behavioral test confirms clean-room dispatch
```

### Workflow 4: Fix cross-validate arbiter

```
 1. [sub-task] Read current cross-validate.md
 2. [sub-task] Add EVIDENCE_TYPE_MISMATCH detection: if behavioral SC verdict cites only file paths, downgrade to FAIL
 3. [inline]  Verify: behavioral test confirms cross-validate FAILs on file-path-only verdict
```

## Implementation Approach

**Phase 1 (single spec, single plan):**
1. Update `spec-creation/tasks/write.md` — Add BEH-EV classification step
2. Create `audit/tasks/behavioral-sc-evaluator.md` — Clean-room evaluation task
3. Update all 8 evaluator tasks — Add clean-room dispatch for behavioral SCs
4. Update `audit/tasks/cross-validate.md` — Add EVIDENCE_TYPE_MISMATCH detection
5. Run `local-issues sync` after each file change
6. Self-review per spec-creation-validation Step 33-35

## Interdependency

| Issue | Direction | Classification | Description |
|-------|-----------|---------------|-------------|
| [#1378](https://github.com/michael-conrad/.opencode/issues/1378) | upstream | SUPERSEDED_BY | This spec supersedes #1378 by incorporating its BEH-EV classification step plus comprehensive evaluator fixes |
| [#2009](https://github.com/michael-conrad/.opencode/issues/2009) | downstream | DEPENDS_ON | This spec's behavioral SC verification depends on #2009's behavioral test infrastructure |
| [#1962](https://github.com/michael-conrad/.opencode/issues/1962) | downstream | RELATED | Writing-plans workflow fixes provide the plan template that this spec's tests verify against |
| [#916](https://github.com/michael-conrad/.opencode/issues/916) | upstream | RELATED | Cost model formalization provides the rationale for EVIDENCE_TYPE_MISMATCH enforcement. Not superseded — separate concern. |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read spec-creation/tasks/write.md` | Verify no BEH-EV classification step |
| Direct source search | `read audit/tasks/verification-audit-evaluator.md` | Verify current behavioral SC evaluation logic |
| Direct source search | `ls audit/tasks/*-evaluator.md` | Count evaluator tasks |
| Direct source search | `read audit/tasks/cross-validate.md` | Verify current evidence type validation |
| Session transcript | #2009 clean-room re-audit output | Confirm file-existence was accepted as behavioral evidence |
| Existing spec | #1378 spec body | Extract BEH-EV classification step design |
| Existing spec | #916 spec body | Confirm cost model is separate concern |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Fold #1378 into this spec | Same root cause (wrong evidence type for behavioral SCs). Prevention (classification gate) + detection (clean-room evaluation) are complementary. | MUST | SC-1, SC-2 |
| DEC-2 | Fix ALL 8 evaluators, not just verification-audit | Same defect pattern in every evaluator. Fixing one leaves 7 broken. | MUST | SC-2 |
| DEC-3 | Clean-room sub-agent receives artifact dir only | Prevents orchestrator bias from contaminating evaluation | MUST | SC-2, SC-3 |
| DEC-4 | Binary verdict only (PASS/FAIL) | No "PASS with concerns" — caveats are defects | MUST | SC-3 |
| DEC-5 | #916 stays separate | Cost model is a different concern (formalization, not enforcement). No overlap. | SHOULD NOT | N/A |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Spec Family Annotation

family: behavioral-sc-evidence-enforcement
selectors:
  - spec: #2011
  - spec: glob(pattern: ".opencode/skills/spec-creation/tasks/write.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/*-evaluator.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/cross-validate.md")

## Explicit Non-Goals

- **Retroactively fixing existing behavioral SC verdicts** — Only newly verified SCs must comply
- **Changing the behavioral test harness** — The harness produces artifacts correctly
- **Cost model formalization** — Covered by #916 (separate spec, approved-for-PR)
- **Rewriting evaluator internals** — Only the behavioral SC evaluation path needs fixing

## Regression Invariants

- [ ] 1. Existing structural SC evaluation still works
- [ ] 2. Existing string SC evaluation still works
- [ ] 3. Existing semantic SC evaluation still works
- [ ] 4. #2009 SCs remain satisfied
- [ ] 5. #1378's BEH-EV classification step is incorporated (not lost)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)
