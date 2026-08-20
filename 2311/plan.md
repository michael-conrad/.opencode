---
plan_schema_version: 1
issue: 2311
title: "writing-plans backfill/research dependency_contract contract alignment"
authorization_scope: for_plan
pr_strategy: none
phase_count: 2
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — #2311 — writing-plans backfill/research dependency_contract contract alignment

**Issue:** https://github.com/michael-conrad/.opencode/issues/2311

## Goal

Align the `interface-compatibility.yaml` schema contract between the producer task (`backfill.md` step 4) and the consumer task (`research.md` step 9) so plan creation for retroactive-backfill issues never blocks on `DEPENDENCY_CONTRACT_NOT_FOUND`.

## Architecture

The root cause is a schema definition that exists in only one task file: `research.md` step 9 requires a `dependency_contract` section that `backfill.md` step 4 never instructs the sub-agent to produce. The fix makes the producer and consumer agree on the `interface-compatibility.yaml` schema by either (1) instructing `backfill.md` step 4 to include a `dependency_contract` section, or (2) updating `research.md` step 9 to derive the contract from the existing artifact keys (`interface_boundaries` / `compatibility` / `compatibility_conclusion`). Both task files must reference the same agreed schema. The fix is verified end to end by proving a retroactive-backfill issue completes plan creation without `DEPENDENCY_CONTRACT_NOT_FOUND`.

## Files

- `.opencode/skills/writing-plans/tasks/backfill.md`
- `.opencode/skills/writing-plans/tasks/research.md`

## Blast Radius

Affected files and impact zones (from `blast-radius.yaml`):

- **Phase 1 (contract fix):** edit task-file prose in `backfill.md` and `research.md` to align the `interface-compatibility.yaml` schema. Risk: low. Rollback: revert prose edits.
- **Phase 2 (pipeline verification):** run the backfill → research → solve → plan pipeline for a retroactive-backfill issue. Risk: medium. Rollback: re-run pipeline against original contract state.
- **Cross-repo impact:** none — both files live in the `.opencode` submodule. No root-repo (`opencode-config`) files change.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On | Step Range | Dispatch |
|-------|-------|------|--------|-----|------------|------------|----------|
| 1 — Contract schema alignment | `test-driven-development` | `red`, `green`; `verification-before-completion` `verify` | `.opencode/skills/writing-plans/tasks/backfill.md`, `research.md` | SC-1, SC-2 | — | 3–11 | sub-agent / clean-room |
| 2 — End-to-end plan creation verification | `test-driven-development` | `red`, `green`; `verification-before-completion` `verify` | `.opencode/skills/writing-plans/tasks/backfill.md`, `research.md` | SC-3 | 1 | 12–16 | sub-agent / clean-room |

## Phase Details

### Phase 1 — Contract schema alignment

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green), `verification-before-completion` (verify) |
| Target | `.opencode/skills/writing-plans/tasks/backfill.md` step 4; `.opencode/skills/writing-plans/tasks/research.md` step 9 |
| SCs | SC-1, SC-2 |
| Depends On | — |

**Context:**
```yaml
producer_file: .opencode/skills/writing-plans/tasks/backfill.md
consumer_file: .opencode/skills/writing-plans/tasks/research.md
schema_artifact: .opencode/.issues/2311/artifacts/interface-compatibility.yaml
resolution_paths:
  - path_1: backfill.md step 4 instructs sub-agent to include dependency_contract section
  - path_2: research.md step 9 derives contract from interface_boundaries/compatibility/compatibility_conclusion
z3_contract_crosscheck:
  - .opencode/skills/writing-plans/contracts/solve-input-template.yaml
  - .opencode/skills/writing-plans/contracts/structure-output-template.yaml
```

**Cost frame:** Verifying the schema agreement across both task files costs one cross-file grep and one read of each task file. Skipping the two-sided fix means the producer/consumer mismatch ships unchanged, and plan creation for any retroactive-backfill issue hits `DEPENDENCY_CONTRACT_NOT_FOUND` — a 1000× downstream death spiral each time the pipeline fails. Correctness is the only metric.

### Phase 2 — End-to-end plan creation verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green), `verification-before-completion` (verify) |
| Target | backfill → research → solve model/check → plan plan pipeline for a retroactive-backfill issue |
| SCs | SC-3 |
| Depends On | 1 |

**Context:**
```yaml
pipeline_steps:
  - backfill.md step 4 produces interface-compatibility.yaml with dependency_contract
  - research.md step 9 extracts dependency_contract -> dependency-contract.yaml
  - .opencode/tools/solve model (SAT)
  - .opencode/tools/solve check (SAT)
  - .opencode/tools/plan plan (SOLVED)
retroactive_backfill_issue: "an issue requiring retroactive artifact backfill"
expected_behavior: "plan creation completes without DEPENDENCY_CONTRACT_NOT_FOUND"
```

**Cost frame:** Running the end-to-end pipeline costs minutes of execution time. Skipping it means the mismatch is only documented, not proven resolved — the behavioral defect (plan creation blocked) ships to the next retroactive-backfill issue and costs 1000× more to fix when discovered in the field. Correctness is the only metric.

## Pre-implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec (#2311) and its success criteria (SC-1, SC-2, SC-3) are internally consistent with the structure artifact: two phases, phase DAG phase_1 → phase_2, SC-to-phase mapping SC-1/SC-2 → phase 1 and SC-3 → phase 2, triplet co-location verified, no cross-phase dependency. **→ all SCs**
- [ ] 2. **Baseline check (**inline**).** Confirm the feature branch exists and is up to date, `.opencode` submodule is on `main` at its tracked pointer, and the working tree is clean before any file modification. **→ all SCs**

## Post-implementation Steps

- [ ] 17. **Structural checks (**sub-agent**).** Run the finishing checklist from `finishing-a-development-branch` — lint/format/typecheck on modified files per AGENTS.md build commands. **→ all SCs**
- [ ] 18. **Verification (**clean-room**).** Verify every SC verdict against its evidence type from `verification-before-completion`: SC-1 behavioral (opencode run), SC-2 structural (grep), SC-3 behavioral (opencode run). BLOCK on any FAIL or EVIDENCE_TYPE_MISMATCH. **→ all SCs**
- [ ] 19. **Audit (**clean-room**).** Run adversarial audit of the deliverable (plan-fidelity / verification-audit chain) — spec fidelity, phase coherence, evidence-type compliance. **→ all SCs**
- [ ] 20. **Cross-validate (**clean-room**).** Independently re-verify the deliverable cross-references the structure artifact, dependency contract, and evidence artifacts consistently. **→ all SCs**
- [ ] 21. **Review-prep (**sub-agent**).** Prepare PR review context from `git-workflow-pr` review-prep task. **→ all SCs**
- [ ] 22. **Completion (**sub-agent**).** Generate completion executive summary from `completion-core`. **→ all SCs**

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. `backfill.md` step 4 and `research.md` step 9 agree on the `interface-compatibility.yaml` schema (producer contract matches consumer expectation) — SC-1, SC-2.
- [ ] C2. Plan creation for a retroactive-backfill issue completes without `DEPENDENCY_CONTRACT_NOT_FOUND` — SC-3.
- [ ] C3. The `dependency_contract` schema cross-checks against `solve-input-template.yaml` and `structure-output-template.yaml` (Risk 1 mitigation) — SC-1, SC-3.
- [ ] C4. No skill outside `writing-plans` was modified; scope limited to `backfill.md`/`research.md` (Risk 3 mitigation) — SC-1, SC-2, SC-3.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*