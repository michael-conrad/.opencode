# Implementation Plan — Spec #1061: Artifact Infrastructure

**Authorization:** `for_pr` — `halt_at: pr_created`, `pr_strategy: stacked`
**Pipeline:** 14-step implementation pipeline
**Phases:** 3 (Phase 1: spec-creation, Phase 2: writing-plans, Phase 3: pipeline-integration)

---

## Phase 1 — Permanent Artifact Creation (spec-creation changes)

### Item 1.1: SC coverage YAML generation substep in Step 1
- **SC:** SC-4
- **RED:** Write behavioral test that verifies spec-creation Step 1 generates `sc-summary.yaml`
- **GREEN:** Add YAML generation substep to `spec-creation/tasks/write.md` Step 1
- **Verified by:** `solve check` against schema; cross-reference `sc_coverage.total` vs prose SC count

### Item 1.2: Verification consistency contract generation substep in Step 1
- **SC:** SC-8
- **RED:** Write behavioral test that verifies spec-creation Step 1 generates `verification-consistency-contract.yaml`
- **GREEN:** Add solve contract generation substep to `spec-creation/tasks/write.md` Step 1
- **Verified by:** `solve check` — SAT for compliant specs, UNSAT with unsat_core for non-compliant

### Item 1.3: Lifecycle manifest initialization substep in Step 1
- **SC:** SC-6
- **RED:** Write behavioral test that verifies spec-creation creates `lifecycle.yaml` with `spec_created` event
- **GREEN:** Add lifecycle manifest init substep to `spec-creation/tasks/write.md` Step 1
- **Verified by:** `grep -c "event: spec_created" lifecycle.yaml` ≥ 1

### Item 1.4: Revision re-entry protocol contract generation substep in Step 1
- **SC:** SC-5
- **RED:** Write behavioral test that verifies spec-creation generates `revision-re-entry-contract.yaml`
- **GREEN:** Add solve contract generation substep to `spec-creation/tasks/write.md` Step 1
- **Verified by:** `solve model` — query satisfiable

### Item 1.5: `solve` utility invocation after Step 5.5
- **SC:** SC-2
- **RED:** Write behavioral test that verifies `solve` is invoked during spec-creation Step 5.5
- **GREEN:** Add solve invocation substep producing `./tmp/{issue-N}/artifacts/constraints-contract.yaml`
- **Verified by:** `solve check` SAT or documented UNSAT with WARNING

### Item 1.6: Artifact path column to SC table format
- **Applies to:** `spec-creation/tasks/write.md`
- **GREEN:** Add Artifact Path column to the 12-column SC table template in Step 3
- **Verified by:** Structural check — column present in template

### Item 1.7: Self-review (Step 6) with YAML-vs-prose validation
- **Applies to:** `spec-creation/tasks/write.md` Step 6
- **GREEN:** Add YAML-vs-prose cross-reference validation substep
- **Verified by:** Self-review checkpoint tool call artifact

### Item 1.8: Pre-approval gate contract expansion
- **SC:** SC-1 (indirect — column validation)
- **Applies to:** `approval-gate/SKILL.md` Routing Rules
- **GREEN:** Add Pipeline Step Binding, Re-Entry Step, Verification Gate, Artifact Path, Phase Binding column checks
- **Verified by:** Structural — section exists with all 5 column validation rules

---

## Phase 2 — Plan-Level Artifact Consumption (writing-plans changes)

### Item 2.1: Phase dependency-ordering solve contract creation
- **SC:** SC-1
- **Applies to:** `writing-plans/tasks/create/plan-structure.md`
- **GREEN:** Create dependency-ordering solve contract from phase structure
- **Verified by:** `ls` — YAML contract file exists

### Item 2.2: `plan` utility invocation for phase solvability validation
- **SC:** SC-3
- **Applies to:** `writing-plans/tasks/create/plan-structure.md`
- **GREEN:** Add `plan` invocation producing `phase-plan-validated.yaml`
- **Verified by:** Planner returns SOLVED_SATISFICING or SOLVED_OPTIMALLY

### Item 2.3: SC-ID mapping substep consuming `sc-summary.yaml`
- **Applies to:** `writing-plans/tasks/create/plan-structure.md`
- **GREEN:** Add SC-ID mapping from `sc-summary.yaml` to plan items
- **Verified by:** Cross-reference validation

### Item 2.4: Spec-to-plan handoff artifact enumeration and validation
- **Applies to:** `writing-plans/tasks/create/create-and-validate.md`
- **GREEN:** Add artifact enumeration and handoff validation
- **Verified by:** All expected artifacts present

### Item 2.5: Spec-to-plan handoff manifest generation
- **Applies to:** `writing-plans/tasks/create/create-and-validate.md`
- **GREEN:** Add manifest generation for spec-to-plan transfer
- **Verified by:** Manifest file exists

---

## Phase 3 — Pipeline Integration

### Item 3.1: Lifecycle manifest event emission points
- **SC:** SC-6
- **Applies to:** `implementation-pipeline/SKILL.md`
- **GREEN:** Add event emission substeps at pipeline stages
- **Verified by:** Event entries appended to lifecycle manifest

### Item 3.2: Artifact retention policy documentation
- **SC:** SC-7
- **Applies to:** `implementation-pipeline/SKILL.md`
- **GREEN:** Add "Artifact Retention" section with 3 rules
- **Verified by:** `grep "Artifact Retention"` — section exists

### Item 3.3: Step-specific pre-cleanup substeps
- **SC:** SC-7
- **Applies to:** `implementation-pipeline/SKILL.md`
- **GREEN:** Add pre-cleanup substeps (clean previous-run artifacts at step start)
- **Verified by:** Structural — substeps documented

---

## Pipeline Progress

- [ ] **Step 1 — sc-coherence-gate**: Verify spec intent vs current codebase
- [ ] **Step 2 — pre-red-baseline**: Capture pre-implementation state
- [ ] **Step 3 — red-phase**: Write behavioral tests (RED, must fail)
- [ ] **Step 4 — red-doublecheck**: Verify RED-side evidence
- [ ] **Step 5 — green-phase**: Implement Phase 1 items 1.1-1.8
- [ ] **Step 6 — checkpoint-commit**: Commit Phase 1
- [ ] **Step 7 — structural-checks**: Lint, format, typecheck
- [ ] **Step 8 — green-doublecheck**: Verify GREEN-side evidence
- [ ] **Step 9 — green-vbc**: VbC completion artifact
- [ ] **Step 10 — adversarial-audit**: Dual auditor verdicts
- [ ] **Step 11 — cross-validate**: Consensus findings
- [ ] **Step 12 — regression-check**: Full test suite
- [ ] **Step 13 — review-prep**: Squash, push, compare URL
- [ ] **Step 14 — exec-summary**: Push, comment, PR

🤖 OpenCode (deepseek-v4-flash) created