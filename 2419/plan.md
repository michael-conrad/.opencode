---
plan_schema_version: 1
issue: .opencode#2419
title: "Remove blanket 'No echo or printf' rule from 020-go-prohibitions.md"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Remove blanket "No echo or printf" rule from 020-go-prohibitions.md

Issue: [.opencode#2419](https://github.com/michael-conrad/.opencode/issues/2419)

## Goal

Remove lines 14-17 of `guidelines/020-go-prohibitions.md` (the "No `echo` or `printf` commands — ever" bullet with its 3 sub-bullets). No other modifications to 020-go-prohibitions.md. No modifications to 117-session-trigger-behavior.md.

## Architecture

Single-phase removal of a 4-line rule with 2 verification-only SCs ensuring scope is contained. No new code or behavioral changes.

## Files

- `guidelines/020-go-prohibitions.md` — lines 14-17 removed

## Blast Radius

Single file edit to `guidelines/020-go-prohibitions.md`. No other files affected. The `117-session-trigger-behavior.md` file is explicitly out of scope.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|--------------|-------|----------|
| 1 | Remove blanket prohibition | rule-removal, scope-preservation, cross-file-preservation | SC-1, SC-2, SC-3 | none | 1-3 | test-driven-development, verification-before-completion |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- [ ] C1. Lines 14-17 removed from `guidelines/020-go-prohibitions.md`
- [ ] C2. No other changes to `guidelines/020-go-prohibitions.md`
- [ ] C3. `guidelines/117-session-trigger-behavior.md` is unmodified
- [ ] C4. All 3 SCs verified by git diff

---

# Phase 1 — Remove blanket prohibition

## Phase Metadata

- Concern: rule-removal, scope-preservation, cross-file-preservation
- Files: `guidelines/020-go-prohibitions.md`
- SCs: SC-1, SC-2, SC-3
- Dependencies: none
- Entry condition: feature branch exists, clean working tree
- Exit condition: all 3 SCs verified, scope contained

## Code Path Coverage

Single path: edit `guidelines/020-go-prohibitions.md` to remove lines 14-17. No branching logic or conditional paths.

## Cross-Cutting SCs

None — all 3 SCs are specific to this phase and do not cross into other phases.

## Interface Boundaries

Single interface: the diff boundary between the old 020-go-prohibitions.md and the new one after removal. No cross-file interface changes.

## State Transitions

No state transitions — this is a documentation-only change with no runtime state.

**Cost frame:** Verifying the line removal costs one git diff command. Skipping verification means the blanket prohibition persists as an unenforceable rule that contradicts the project's own infrastructure.

### Item 1 — SC-1: Remove lines 14-17 from 020-go-prohibitions.md

- [ ] 1. RED — Write a failing enforcement test
  - **Cost frame:** Writing a structural-comparison test costs one tool-call. Skipping it means the removal is not gate-checked against a failing baseline.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute red task from test-driven-development")` with:
    - Issue: `.opencode#2419`
    - SC: SC-1
    - Concern: rule-removal
    - Description: "Write failing enforcement test that checks lines 14-17 of 020-go-prohibitions.md still contain the prohibition"
  - Step precondition: item 1 has not been started
  - Step passes when: RED sub-agent returns status DONE, enforcement test file exists and fails against the current content
  - Step fails if: sub-agent returns BLOCKED or test passes against current content

- [ ] 2. GREEN — Remove lines 14-17
  - **Cost frame:** Editing one file costs one edit operation. Skipping means the spec's primary SC is not implemented.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute green task from test-driven-development")` with:
    - Issue: `.opencode#2419`
    - SC: SC-1
    - Concern: rule-removal
    - Description: "Remove lines 14-17 from guidelines/020-go-prohibitions.md"
  - Step precondition: RED test exists and fails
  - Step passes when: GREEN sub-agent returns status DONE, lines 14-17 are removed
  - Step fails if: sub-agent returns BLOCKED or lines 14-17 still present

- [ ] 3. VERIFY — Verify SC-1 via git diff
  - **Cost frame:** Running git diff costs one shell command. Skipping means the removal is not confirmed against the spec.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` with:
    - Issue: `.opencode#2419`
    - SC: SC-1
    - Evidence type: structural
    - Description: "Verify git diff shows lines 14-17 removed from 020-go-prohibitions.md"
  - Step precondition: GREEN change has been applied
  - Step passes when: verify returns PASS — git diff confirms lines 14-17 removed
  - Step fails if: verify returns FAIL or BLOCKED

- [ ] 4. COMMIT — Commit SC-1 changes
  - `(**inline**)` Orchestrator runs:
    ```
    git add guidelines/020-go-prohibitions.md
    git commit -m "Remove blanket \"No echo or printf\" prohibition (fixes .opencode#2419)"
    ```
  - Step precondition: SC-1 verified PASS
  - Step passes when: commit succeeds, working tree clean
  - Step fails if: commit fails or pre-commit hook blocks

### Item 2 — SC-2: No other changes to 020-go-prohibitions.md

- [ ] 5. RED — Write a failing enforcement test for scope preservation
  - **Cost frame:** Writing a scope-preservation test costs one tool-call. Skipping it means unplanned changes can slip in without detection.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute red task from test-driven-development")` with:
    - Issue: `.opencode#2419`
    - SC: SC-2
    - Concern: scope-preservation
    - Description: "Write failing enforcement test that checks for any unplanned changes in 020-go-prohibitions.md beyond lines 14-17"
  - Step precondition: item 1 committed
  - Step passes when: RED sub-agent returns status DONE, enforcement test file exists and fails against current content
  - Step fails if: sub-agent returns BLOCKED

- [ ] 6. GREEN — Verification-only: confirm diff is limited
  - **Cost frame:** Confirming the diff is limited costs a git diff command. Skipping means scope creep is not detected.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute green task from test-driven-development")` with:
    - Issue: `.opencode#2419`
    - SC: SC-2
    - Concern: scope-preservation
    - Description: "Verification-only — confirm diff is limited to the intended removal; no code change needed"
  - Step precondition: RED test exists and fails
  - Step passes when: GREEN sub-agent returns status DONE, diff confirmed limited
  - Step fails if: sub-agent returns BLOCKED or diff shows unplanned changes

- [ ] 7. VERIFY — Verify SC-2 via git diff
  - **Cost frame:** Running git diff costs one shell command. Skipping means scope creep is not ruled out.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` with:
    - Issue: `.opencode#2419`
    - SC: SC-2
    - Evidence type: structural
    - Description: "Verify git diff of 020-go-prohibitions.md shows ONLY lines 14-17 removed"
  - Step precondition: GREEN verification completed
  - Step passes when: verify returns PASS — git diff shows only lines 14-17 removed
  - Step fails if: verify returns FAIL or BLOCKED

- [ ] 8. COMMIT — No-op (changes already committed with SC-1)
  - `(**inline**)` No action needed — SC-1 commit already contains the change. Verify working tree is clean.
  - Step precondition: SC-2 verified PASS
  - Step passes when: working tree is clean
  - Step fails if: working tree has uncommitted changes

### Item 3 — SC-3: 117-session-trigger-behavior.md is unmodified

- [ ] 9. RED — Write a failing enforcement test for cross-file preservation
  - **Cost frame:** Writing a cross-file preservation test costs one tool-call. Skipping means an unintended edit to 117-session-trigger-behavior.md is not detected.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute red task from test-driven-development")` with:
    - Issue: `.opencode#2419`
    - SC: SC-3
    - Concern: cross-file-preservation
    - Description: "Write failing enforcement test that checks for any changes in 117-session-trigger-behavior.md"
  - Step precondition: item 2 committed or clean
  - Step passes when: RED sub-agent returns status DONE, enforcement test file exists and fails
  - Step fails if: sub-agent returns BLOCKED

- [ ] 10. GREEN — Verification-only: confirm 117-session-trigger-behavior.md unchanged
  - **Cost frame:** Confirming the cross-file is untouched costs a git diff command. Skipping means an unintended side-effect is not caught.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute green task from test-driven-development")` with:
    - Issue: `.opencode#2419`
    - SC: SC-3
    - Concern: cross-file-preservation
    - Description: "Verification-only — confirm 117-session-trigger-behavior.md is unchanged; no code change needed"
  - Step precondition: RED test exists and fails
  - Step passes when: GREEN sub-agent returns status DONE, 117-session-trigger-behavior.md confirmed unchanged
  - Step fails if: sub-agent returns BLOCKED or file shows changes

- [ ] 11. VERIFY — Verify SC-3 via git diff
  - **Cost frame:** Running git diff costs one shell command. Skipping means the cross-file guarantee is unverified.
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` with:
    - Issue: `.opencode#2419`
    - SC: SC-3
    - Evidence type: structural
    - Description: "Verify git diff of 117-session-trigger-behavior.md shows zero changes"
  - Step precondition: GREEN verification completed
  - Step passes when: verify returns PASS — git diff shows zero changes
  - Step fails if: verify returns FAIL or BLOCKED

- [ ] 12. COMMIT — No-op (no changes to commit)
  - `(**inline**)` No action needed — 117-session-trigger-behavior.md has no changes. Verify working tree is clean.
  - Step precondition: SC-3 verified PASS
  - Step passes when: working tree is clean
  - Step fails if: working tree has uncommitted changes

---

## Post-Implementation

- [ ] 13. Audit — Adversarial audit of the deliverable
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-30T19:46:00Z | plan_created | Plan file at `.opencode/.issues/2419/plan.md`, 1 phase, 3 SCs, daisy-chained |
  - Step passes when: audit returns all-clean or concerns documented

- [ ] 14. Z3 check — Run Z3 constraint solver verification
  - `(**inline**)` Orchestrator runs `.opencode/tools/solve check --state-path .opencode/.issues/2419/artifacts/state-analysis.yaml --contract-path .opencode/.issues/2419/dependency-contract.yaml`
  - Step passes when: Z3 check returns clean

- [ ] 15. Structural checks — Lint, typecheck, format check
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Step passes when: all checks pass

- [ ] 16. Pre-PR gate — Verify all SC verdicts before PR creation
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
  - Step passes when: all 3 SCs verified PASS

- [ ] 17. Regression check — Final regression before PR
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Step passes when: regression tests pass

- [ ] 18. Review prep — Prepare PR review context
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - Step passes when: review context prepared

- [ ] 19. Create PR — Create the pull request
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`
  - Step passes when: PR created

- [ ] 20. Completion — Generate completion executive summary
  - `(**sub-agent**)` Dispatch `task(..., prompt: "execute completion task from completion-core")`
  - Step passes when: summary generated
