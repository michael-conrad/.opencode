---
title: "[SPEC-FIX] Behavioral SC verification must use clean-room sub-agents on raw artifacts — file existence is not behavioral evidence"
status: draft
created: 2026-07-19
license: MIT
provenance: AI-generated
issue: 2011
authors:
  - OpenCode (nemotron-3-ultra-free)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-19

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

During the #2009 clean-room re-audit, the verification-audit evaluator reported PASS for behavioral SC-2 and SC-4 by checking that behavioral test artifact files exist on disk (exit_code=0, manifest.yaml, stdout.log, stderr.log). This is structural evidence — file existence proves the test ran, NOT that the agent's behavior matched the SC criterion.

The evaluator's criterion evaluation logic does not distinguish between "artifact exists" (structural) and "artifact content proves SC compliance" (behavioral). When the evaluator sees behavioral evidence artifacts on disk, it reports PASS without engaging a clean-room sub-agent to read the actual output and judge the agent's behavior.

This is the same defect pattern as:
- **critical-rules-047** (VbC Fabricated PASS) — reporting file existence as verified behavioral evidence
- **critical-rules-BEH-EV** (Runtime-Behavioral Evidence Classification Gate) — structural evidence for behavioral changes is EVIDENCE_TYPE_MISMATCH

## Root Cause Analysis

The `verification-audit` evaluator task (`audit/tasks/verification-audit-evaluator.md`) evaluates SCs against evidence. For behavioral SCs, it checks whether behavioral evidence artifacts exist in the `artifact_evidence_dir`. If files exist, it reports PASS — without reading the actual content of stdout.log or stderr.log to determine whether the agent's actions satisfied the SC.

The evaluator has no step that dispatches a clean-room sub-agent to read the raw artifacts and render a binary judgment. The evaluator itself is not a clean-room sub-agent — it receives orchestrator context and cached results. A true clean-room evaluation requires a sub-agent that receives ONLY the artifact directory path, reads the artifacts cold, and renders PASS/FAIL independently.

**Fix target:** `audit/tasks/verification-audit-evaluator.md` — Add mandatory clean-room sub-agent dispatch for behavioral SCs. The evaluator MUST NOT accept file-existence as evidence for behavioral SCs.

## Goals

- [ ] G1: verification-audit evaluator dispatches clean-room sub-agent for behavioral SCs
- [ ] G2: Clean-room sub-agent reads stdout.log/stderr.log and renders binary PASS/FAIL
- [ ] G3: Cross-validate arbiter detects EVIDENCE_TYPE_MISMATCH when behavioral SC verdict cites only file paths
- [ ] G4: All 5 SCs from #2009 remain satisfied

## Non-Goals

- **Retroactively fixing existing behavioral SC verdicts** — Only newly verified SCs must comply
- **Changing the behavioral test harness** — The harness produces artifacts correctly. Only the evaluation is broken.
- **Rewriting the entire evaluator** — Only the behavioral SC evaluation path needs fixing.

## Constraints and Scope

**In Scope:**
- `audit/tasks/verification-audit-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
- `audit/tasks/cross-validate.md` — Add EVIDENCE_TYPE_MISMATCH detection

**Out of Scope:**
- Other evaluator tasks (spec-audit, plan-fidelity, etc.) — same defect, separate issue
- Behavioral test harness — produces correct artifacts
- Existing SC verdicts — grandfathered

## Safety Considerations

- **No destructive operations** — Only task file modifications
- **No database/schema changes** — Pure enforcement additions
- **Rollback:** `git revert` on affected task files
- **Data loss risk:** None

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Fix in cross-validate only | Cross-validate is downstream. The evaluator should produce correct verdicts. |
| Add guideline instead of task fix | Guidelines are advisory. Task file changes are enforceable. |
| Make evaluator read artifacts directly | Evaluator is not clean-room — it receives orchestrator context. Only a fresh sub-agent is clean. |

## Evidence/Provenance

| Claim | Evidence Source |
|-------|-----------------|
| verification-audit evaluator accepts file-existence for behavioral SCs | `read` verification-audit-evaluator.md → find behavioral SC evaluation logic |
| No clean-room sub-agent dispatch in evaluator | `grep` for `task(` or `sub-agent` in evaluator → zero matches |
| cross-validate has no EVIDENCE_TYPE_MISMATCH check | `read` cross-validate.md → find evidence type validation |
| #2009 re-audit reported PASS for SC-2/SC-4 via file-existence | Session transcript from 2026-07-19 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Artifact Path |
|----|-----------|---------------|---------------------|-------------|--------------|
| SC-1 | verification-audit evaluator dispatches clean-room sub-agent for behavioral SCs (receives artifact dir only, no orchestrator context) | behavioral | `opencode run` → verify clean-room sub-agent dispatch in stderr | Add clean-room dispatch step to evaluator | `.opencode/skills/audit/tasks/verification-audit-evaluator.md` |
| SC-2 | Clean-room sub-agent reads stdout.log/stderr.log and renders binary PASS/FAIL — file-existence alone is FAIL | behavioral | `opencode run` → verify clean-room sub-agent reads artifacts and returns binary verdict | Create clean-room evaluation task | `.opencode/skills/audit/tasks/` |
| SC-3 | Cross-validate arbiter detects EVIDENCE_TYPE_MISMATCH when behavioral SC verdict cites only file paths (no content analysis) | behavioral | `opencode run` → verify cross-validate FAILs on file-path-only behavioral verdict | Add EVIDENCE_TYPE_MISMATCH check to cross-validate | `.opencode/skills/audit/tasks/cross-validate.md` |
| SC-4 | All 5 SCs from #2009 remain satisfied | structural | `grep` for SC-1 through SC-5 in #2009 spec → all present | No changes to #2009 spec | `.opencode/.issues/2009/spec.md` |

## Pipeline / Workflows

### Workflow 1: Fix verification-audit evaluator

```
 1. [sub-task] Read current verification-audit-evaluator.md
 2. [sub-task] Add step: for each behavioral SC, dispatch clean-room sub-agent with artifact dir only
 3. [sub-task] Add step: clean-room sub-agent reads stdout.log/stderr.log, renders PASS/FAIL
 4. [sub-task] Add step: if clean-room returns FAIL, evaluator verdict is FAIL (not PASS)
 5. [inline]  Verify: behavioral test confirms clean-room dispatch in stderr
```

### Workflow 2: Fix cross-validate arbiter

```
 1. [sub-task] Read current cross-validate.md
 2. [sub-task] Add EVIDENCE_TYPE_MISMATCH detection: if behavioral SC verdict cites only file paths, downgrade to FAIL
 3. [inline]  Verify: behavioral test confirms cross-validate FAILs on file-path-only verdict
```

## Implementation Approach

**Phase 1 (single spec, single plan):**
1. Update `audit/tasks/verification-audit-evaluator.md` — Add clean-room sub-agent dispatch for behavioral SCs
2. Create clean-room evaluation task at `audit/tasks/behavioral-sc-evaluator.md`
3. Update `audit/tasks/cross-validate.md` — Add EVIDENCE_TYPE_MISMATCH detection
4. Run `local-issues sync` after each file change
5. Self-review per spec-creation-validation Step 33-35

## Interdependency

| Issue | Direction | Classification | Description |
|-------|-----------|---------------|-------------|
| [#2009](https://github.com/michael-conrad/.opencode/issues/2009) | downstream | DEPENDS_ON | This spec's behavioral SC verification depends on #2009's behavioral test infrastructure |
| [#1962](https://github.com/michael-conrad/.opencode/issues/1962) | downstream | RELATED | Writing-plans workflow fixes provide the plan template that this spec's tests verify against |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read audit/tasks/verification-audit-evaluator.md` | Verify current behavioral SC evaluation logic |
| Direct source search | `read audit/tasks/cross-validate.md` | Verify current evidence type validation |
| Session transcript | #2009 clean-room re-audit output | Confirm file-existence was accepted as behavioral evidence |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Clean-room sub-agent receives artifact dir only | Prevents orchestrator bias from contaminating evaluation | MUST | SC-1, SC-2 |
| DEC-2 | Binary verdict only (PASS/FAIL) | No "PASS with concerns" — caveats are defects | MUST | SC-2 |
| DEC-3 | Fix evaluator, not cross-validate | Evaluator is where verdicts are rendered. Cross-validate is downstream check. | MUST | SC-1, SC-3 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Spec Family Annotation

family: behavioral-sc-cleanroom-evaluation
selectors:
  - spec: #2011
  - spec: glob(pattern: ".opencode/skills/audit/tasks/verification-audit-evaluator.md")
  - spec: glob(pattern: ".opencode/skills/audit/tasks/cross-validate.md")

## Explicit Non-Goals

- **Retroactively fixing existing behavioral SC verdicts** — Only newly verified SCs must comply
- **Changing the behavioral test harness** — The harness produces artifacts correctly
- **Rewriting the entire evaluator** — Only the behavioral SC evaluation path needs fixing

## Regression Invariants

- [ ] 1. Existing structural SC evaluation still works
- [ ] 2. Existing string SC evaluation still works
- [ ] 3. Existing semantic SC evaluation still works
- [ ] 4. #2009 SCs remain satisfied

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (nemotron-3-ultra-free)
