---
plan_schema_version: "1.0"
issue: 2175
title: "Remove aggregate step counts from plan artifacts — metadata triggers volume-based deliberation"
dispatch:
  - phase: 1
    skill: verification
    task: verify
  - phase: 2
    skill: implementation-pipeline
    task: execute
  - phase: 3
    skill: implementation-pipeline
    task: execute
---

# Plan: Remove aggregate step counts from plan artifacts

## Pre-Implementation

### Coherence gate
- [ ] Dispatch `sc-coherence-gate` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2175, project_root, issues_prefix: .opencode}`
  - SC-ID: SC-7, SC-8, SC-9, SC-10

### Baseline check
- [ ] Dispatch `pre-red-baseline` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2175, project_root, issues_prefix: .opencode}`
  - SC-ID: SC-7, SC-8, SC-9, SC-10

---

## Phase 1: Spec quality verification

**SCs:** SC-7, SC-8, SC-9, SC-10
**Concern:** Verify spec already satisfies quality criteria (pattern definition, scope, cross-refs, self-consistency)

### Item 1: Verify spec defines defective pattern with IS/IS NOT examples (SC-7)

- [ ] **RED phase** — Write a failing test that checks for pattern definition in spec (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-7, evidence_type: string}`
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
- [ ] **Z3 check RED** — Run solve check (**inline**)
  - Context: `{issue_number: 2175, contract_path: .opencode/.issues/2175/dependency-contract.yaml}`
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-7}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
  - Context: `{issue_number: 2175, contract_path: .opencode/.issues/2175/dependency-contract.yaml}`
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-7}`
  - Dispatch: `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
  - Context: `{issue_number: 2175, contract_path: .opencode/.issues/2175/dependency-contract.yaml}`
- [ ] **GREEN phase** — Verify spec already has pattern definition; no change needed (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-7, evidence_type: string}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
  - Context: `{issue_number: 2175, contract_path: .opencode/.issues/2175/dependency-contract.yaml}`
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-7}`
  - Dispatch: `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
  - Context: `{issue_number: 2175, contract_path: .opencode/.issues/2175/dependency-contract.yaml}`
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
  - Context: `{issue_number: 2175, phase: 1, item: 1}`
  - Dispatch: `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
  - Context: `{issue_number: 2175, phase: 1, item: 1}`
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
  - Context: `{issue_number: 2175}`
  - Dispatch: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-7}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-7}`
  - Dispatch: `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
- [ ] **SC count gate** — Verify SC-7 has a verdict (**sub-agent**)
  - Context: `{issue_number: 2175}`
  - Dispatch: `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
  - Context: `{issue_number: 2175}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Rationalization check** — Verify no cost-rationalization in proposed action (**sub-agent**)
  - Context: `{issue_number: 2175, proposed_action: "verify spec pattern definition", rule_text: "spec-creation quality criteria"}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
  - Context: `{issue_number: 2175, spec_local_dir: .opencode/.issues/2175, artifact_evidence_dir: .opencode/.issues/2175/artifacts}`
  - Dispatch: `task(subagent_type="general")` with audit context
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
  - Context: `{issue_number: 2175}`
  - Dispatch: `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
- [ ] **Regression check** — Run regression tests (**sub-agent**)
  - Context: `{issue_number: 2175}`
  - Dispatch: `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
- [ ] **Review prep** — Prepare for review (**sub-agent**)
  - Context: `{issue_number: 2175}`
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
- [ ] **Create PR** — Create pull request (**sub-agent**)
  - Context: `{issue_number: 2175, authorization_scope: for_pr, halt_at: pr_created}`
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
- [ ] **Exec summary** — Completion report (**sub-agent**)
  - Context: `{issue_number: 2175}`
  - Dispatch: `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`

### Item 2: Verify spec scopes audit with in-scope/out-of-scope categories (SC-8)

- [ ] **RED phase** — Write failing test for scope section presence (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-8, evidence_type: string}`
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Verify spec already has scope section; no change needed (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-8 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

### Item 3: Verify spec documents relationship to #2138, #2089, #2137 (SC-9)

- [ ] **RED phase** — Write failing test for cross-reference presence (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-9, evidence_type: string}`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Verify spec already has cross-references; no change needed (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-9 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

### Item 4: Verify spec does NOT contain aggregate step counts in its own body (SC-10)

- [ ] **RED phase** — Write failing test for absence of step-count patterns in spec (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-10, evidence_type: string}`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Verify spec already has no step counts; no change needed (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-10 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

---

## Phase 2: Remediation — remove aggregate step counts from plan artifacts

**SCs:** SC-1, SC-2, SC-3, SC-4
**Concern:** Update 4 affected files to remove aggregate step count summaries. Each file is an independent item with its own RED/GREEN cycle.

### Item 5: Remove step-count summary from create.md plan output (SC-1)

- [ ] **RED phase** — Write failing grep test that expects step-count patterns in create.md (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-1, file: .opencode/skills/writing-plans/tasks/create.md, evidence_type: string}`
  - Dispatch: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
- [ ] **Z3 check RED** — Run solve check (**inline**)
  - Context: `{issue_number: 2175, contract_path: .opencode/.issues/2175/dependency-contract.yaml}`
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-1}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Edit create.md to remove step-count summary lines (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-1, file: .opencode/skills/writing-plans/tasks/create.md, evidence_type: string}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
- [ ] **SC count gate** — Verify SC-1 has a verdict (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
  - Dispatch: `task(subagent_type="general")` with audit context
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
- [ ] **Regression check** — Run regression tests (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
- [ ] **Review prep** — Prepare for review (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
- [ ] **Create PR** — Create pull request (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
- [ ] **Exec summary** — Completion report (**sub-agent**)
  - Dispatch: `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`

### Item 6: Remove step-count validation from self-review.md (SC-2)

- [ ] **RED phase** — Write failing grep test for step-count patterns in self-review.md (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-2, file: .opencode/skills/writing-plans/tasks/self-review.md, evidence_type: string}`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Edit self-review.md to remove step-count validation (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-2 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

### Item 7: Remove step-count validation from validate.md (SC-3)

- [ ] **RED phase** — Write failing grep test for step-count patterns in validate.md (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-3, file: .opencode/skills/writing-plans/tasks/validate.md, evidence_type: string}`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Edit validate.md to remove step-count validation (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-3 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

### Item 8: Remove step-count format documentation from plan-artifact-format.md (SC-4)

- [ ] **RED phase** — Write failing grep test for step-count patterns in plan-artifact-format.md (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-4, file: .opencode/skills/writing-plans/reference/plan-artifact-format.md, evidence_type: string}`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Edit plan-artifact-format.md to remove step-count documentation (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-4 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

---

## Phase 3: Verification — pipeline bookkeeping unchanged + behavioral test

**SCs:** SC-5, SC-6
**Concern:** Verify assemble-work.md total_steps is NOT modified. Create behavioral enforcement test for step-volume non-deliberation.

### Item 9: Verify assemble-work.md total_steps field is PRESENT and UNCHANGED (SC-5)

- [ ] **RED phase** — Write failing grep test that expects total_steps in assemble-work.md (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-5, file: .opencode/skills/implementation-pipeline/tasks/assemble-work.md, evidence_type: string}`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Verify assemble-work.md still has total_steps; no change needed (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-5 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

### Item 10: Create behavioral enforcement test for step-volume non-deliberation (SC-6)

- [ ] **RED phase** — Write failing behavioral test that sends plan execution prompt and expects agent to NOT deliberate about step volume (**sub-agent**)
  - Context: `{issue_number: 2175, sc: SC-6, file: .opencode/tests-v2/behaviors/, evidence_type: behavioral}`
- [ ] **Z3 check RED** — Run solve check (**inline**)
- [ ] **RED doublecheck** — Verify RED test correctness (**sub-agent**)
- [ ] **Z3 check RED doublecheck** — Run solve check (**inline**)
- [ ] **Post-RED enforcement** — Verify RED gate passed (**sub-agent**)
- [ ] **Z3 check post-RED** — Run solve check (**inline**)
- [ ] **GREEN phase** — Create behavioral test script in tests-v2/behaviors/ (**sub-agent**)
- [ ] **Z3 check GREEN** — Run solve check (**inline**)
- [ ] **Post-GREEN enforcement** — Verify GREEN gate passed (**sub-agent**)
- [ ] **Z3 check post-GREEN** — Run solve check (**inline**)
- [ ] **Checkpoint tag create** — Create checkpoint tag (**sub-agent**)
- [ ] **Checkpoint commit** — Save checkpoint (**sub-agent**)
- [ ] **Structural checks** — Run lint/typecheck (**sub-agent**)
- [ ] **GREEN doublecheck** — Verify GREEN implementation (**sub-agent**)
- [ ] **GREEN VbC** — Verification before completion (**sub-agent**)
- [ ] **SC count gate** — Verify SC-6 has a verdict (**sub-agent**)
- [ ] **Pre-PR gate** — Verify no FAIL verdicts (**sub-agent**)
- [ ] **Rationalization check** — Verify no cost-rationalization (**sub-agent**)
- [ ] **Audit** — Dispatch audit task (**sub-agent**)
- [ ] **Cross-validate** — Consensus check (**sub-agent**)
- [ ] **Regression check** — Run regression tests (**sub-agent**)
- [ ] **Review prep** — Prepare for review (**sub-agent**)
- [ ] **Create PR** — Create pull request (**sub-agent**)
- [ ] **Exec summary** — Completion report (**sub-agent**)

---

## Post-Implementation

- [ ] **Structural checks** — Run lint/typecheck across all modified files (**sub-agent**)
- [ ] **Verification** — Verify all 10 SCs have PASS verdicts (**sub-agent**)
- [ ] **Audit** — Final adversarial audit of all changes (**sub-agent**)
- [ ] **Cross-validate** — Consensus check between auditor and verifier (**sub-agent**)
- [ ] **Review prep** — Prepare PR for human review (**sub-agent**)
- [ ] **Create PR** — Create pull request with all changes (**sub-agent**)
- [ ] **Completion** — Report summary and HALT (**sub-agent**)

---

## Lifecycle Events

- event: plan_created
  timestamp: 2026-07-29T12:26:00Z
  issuer: OpenCode (deepseek-v4-flash)
  phase_count: 3
  dispatch_mode: sub-agent (primary), inline (Z3 checks)
  pipeline_signal: ready-for-implementation
