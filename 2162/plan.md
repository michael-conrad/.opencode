---
plan_schema_version: "1.0"
issue: 2162
title: "Spec Lifecycle State Labels"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 1
    skill: test-driven-development
    task: green
  - phase: 1
    skill: verification-before-completion
    task: verify
  - phase: 1
    skill: verification-before-completion
    task: completion
  - phase: 1
    skill: finishing-a-development-branch
    task: checklist
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: green
  - phase: 2
    skill: verification-before-completion
    task: verify
  - phase: 2
    skill: verification-before-completion
    task: completion
  - phase: 2
    skill: finishing-a-development-branch
    task: checklist
  - phase: 3
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: green
  - phase: 3
    skill: verification-before-completion
    task: verify
  - phase: 3
    skill: verification-before-completion
    task: completion
  - phase: 3
    skill: finishing-a-development-branch
    task: checklist
---

# Plan: Spec Lifecycle State Labels

## Pre-Implementation Steps

- [ ] **Coherence gate** — dispatch `sc-coherence-gate` from implementation-pipeline. Verify spec/plan coherence before RED routing.
  - (**sub-agent**) — `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Baseline check** — dispatch `pre-red-baseline` from implementation-pipeline. Verify baseline state before any RED phase.
  - (**sub-agent**) — `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2162}`

---

## Phase Table

| Phase | SCs | Description | Dispatch |
|-------|-----|-------------|----------|
| 1 — Label Creation | SC-1, SC-2, SC-3, SC-4, SC-5, SC-13, SC-15 | Create all 5 spec lifecycle labels on all platforms with no collisions | `test-driven-development` (red/green), `verification-before-completion` (verify/completion), `finishing-a-development-branch` (checklist) |
| 2 — Label Application | SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-14 | Apply labels at each spec lifecycle transition point in the relevant task files | `test-driven-development` (red/green), `verification-before-completion` (verify/completion), `finishing-a-development-branch` (checklist) |
| 3 — Platform Documentation | SC-12 | Document labels in all three platform SKILL.md files | `test-driven-development` (red/green), `verification-before-completion` (verify/completion), `finishing-a-development-branch` (checklist) |

---

## Phase 1: Label Creation

**Concern:** Create all 5 spec lifecycle labels on all platforms with no collisions.
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-13, SC-15

### Item 1: Create `spec-draft` label (SC-1)

- [ ] **RED phase** — write failing test: `gh label list` / `gb label list` confirms `spec-draft` does NOT exist yet.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-1
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: `gh label create` / `gb label create` `spec-draft` on all 3 platforms.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-1
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 2: Create `spec-needs-research` label (SC-2)

- [ ] **RED phase** — write failing test: `gh label list` / `gb label list` confirms `spec-needs-research` does NOT exist yet.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-2
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: `gh label create` / `gb label create` `spec-needs-research` on all 3 platforms.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-2
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 3: Create `spec-under-review` label (SC-3)

- [ ] **RED phase** — write failing test: `gh label list` / `gb label list` confirms `spec-under-review` does NOT exist yet.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-3
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: `gh label create` / `gb label create` `spec-under-review` on all 3 platforms.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-3
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 4: Create `spec-passed-review` label (SC-4)

- [ ] **RED phase** — write failing test: `gh label list` / `gb label list` confirms `spec-passed-review` does NOT exist yet.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-4
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: `gh label create` / `gb label create` `spec-passed-review` on all 3 platforms.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-4
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 5: Create `spec-cleared` label (SC-5)

- [ ] **RED phase** — write failing test: `gh label list` / `gb label list` confirms `spec-cleared` does NOT exist yet.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-5
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: `gh label create` / `gb label create` `spec-cleared` on all 3 platforms.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-5
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 13: Verify no collision with `approved-for-*` labels (SC-13)

- [ ] **RED phase** — write failing test: grep confirms `spec-*` prefix does not overlap with `approved-for-*`.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-13
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — N/A — verification-only SC, no code change needed. Produce verification evidence artifact.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-13
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 15: Verify terminal states handled by existing mechanisms (SC-15)

- [ ] **RED phase** — write failing test: state machine analysis confirms no spec-lifecycle label for terminal states.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-15
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — N/A — verification-only SC, no code change needed. Produce verification evidence artifact.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-15
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

---

## Phase 2: Label Application

**Concern:** Apply labels at each spec lifecycle transition point in the relevant task files.
**SCs:** SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-14

### Item 6: Apply `spec-draft` after spec creation (SC-6)

- [ ] **RED phase** — write failing test: `opencode run` with spec creation prompt — `spec-draft` NOT applied.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-6
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: add label API call to `spec-creation/tasks/create.md` and `issue-review/tasks/analyze-and-spec.md`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-6
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 7: Apply `spec-needs-research` on triage (SC-7)

- [ ] **RED phase** — write failing test: `opencode run` with triage prompt — `spec-needs-research` NOT applied.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-7
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: add label API call to `issue-review/tasks/triage.md`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-7
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 8: Apply `spec-under-review` on audit start (SC-8)

- [ ] **RED phase** — write failing test: `opencode run` with audit start prompt — `spec-under-review` NOT applied.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-8
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: add label API call to `audit/tasks/spec-audit-evaluator.md`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-8
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 9: Apply `spec-passed-review` on audit PASS (SC-9)

- [ ] **RED phase** — write failing test: `opencode run` with audit PASS prompt — `spec-passed-review` NOT applied, `spec-under-review` NOT removed.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-9
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: add label transition to `audit/tasks/spec-audit-evaluator.md` and `audit/tasks/spec-audit-validator.md`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-9
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 10: Apply `spec-cleared` at plan creation time (SC-10)

- [ ] **RED phase** — write failing test: `opencode run` with plan creation prompt — `spec-cleared` NOT applied.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-10
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: add label API call to `writing-plans/tasks/create.md`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-10
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 11: Reset labels on spec revision (SC-11)

- [ ] **RED phase** — write failing test: `opencode run` with revision prompt — `spec-passed-review` and `spec-cleared` NOT removed, `spec-draft` NOT applied.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-11
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: add label transition to `approval-gate-scope/SKILL.md` Trigger Dispatch Table `revision-revocation` sub-task.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-11
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

### Item 14: Verify no body status fields used for lifecycle tracking (SC-14)

- [ ] **RED phase** — write failing test: grep confirms no STATUS field in spec body across all touched task files.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-14
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — N/A — verification-only SC, no code change needed. Produce verification evidence artifact.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-14
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

---

## Phase 3: Platform Documentation

**Concern:** Document labels in all three platform SKILL.md files.
**SCs:** SC-12

### Item 12: Document spec lifecycle labels in platform SKILL.md files (SC-12)

- [ ] **RED phase** — write failing test: grep confirms label names NOT present in any platform SKILL.md.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-12
- [ ] **Z3 check RED** — solve check RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **RED doublecheck** — verify RED test is valid.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check RED doublecheck** — solve check RED doublecheck contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-RED enforcement** — RED gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-RED** — solve check post-RED contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **GREEN phase** — implement: add label documentation to `issue-operations/platforms/local/SKILL.md`, `issue-operations/platforms/github-mcp/SKILL.md`, `issue-operations/platforms/gitbucket-api/SKILL.md`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2162}`
  - SC-ID: SC-12
- [ ] **Z3 check GREEN** — solve check GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Post-GREEN enforcement** — GREEN gate check.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Z3 check post-GREEN** — solve check post-GREEN contract.
  - (**inline**)
  - Context: `{issue_number: 2162, contract_path: ...}`
- [ ] **Checkpoint tag create** — create checkpoint tag for this item.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Checkpoint commit** — save checkpoint.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2162}`

---

## Exit Criteria

- [ ] C1. All 5 spec lifecycle labels (`spec-draft`, `spec-needs-research`, `spec-under-review`, `spec-passed-review`, `spec-cleared`) exist on all 3 platforms (GitHub .opencode, GitHub opencode-config, GitBucket) — SC-1, SC-2, SC-3, SC-4, SC-5
- [ ] C2. No collision with existing `approved-for-*` labels — SC-13
- [ ] C3. `spec-draft` is applied after spec creation in `spec-creation/tasks/create.md` and `issue-review/tasks/analyze-and-spec.md` — SC-6
- [ ] C4. `spec-needs-research` is applied on triage research need in `issue-review/tasks/triage.md` — SC-7
- [ ] C5. `spec-under-review` is applied on audit start in `audit/tasks/spec-audit-evaluator.md` — SC-8
- [ ] C6. `spec-passed-review` is applied on audit PASS in `audit/tasks/spec-audit-evaluator.md` and `audit/tasks/spec-audit-validator.md` — SC-9
- [ ] C7. `spec-cleared` is applied at plan creation time in `writing-plans/tasks/create.md` — SC-10
- [ ] C8. On spec revision: `spec-passed-review` and `spec-cleared` removed, `spec-draft` applied — SC-11
- [ ] C9. Spec lifecycle labels documented in all three platform SKILL.md files — SC-12
- [ ] C10. No body status fields used for lifecycle tracking — SC-14
- [ ] C11. Terminal states handled by existing mechanisms, not spec lifecycle labels — SC-15

---

## Post-Implementation Steps

- [ ] **Structural checks** — run lint/typecheck on all modified files.
  - (**sub-agent**) — `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **GREEN doublecheck** — verify all GREEN implementations are correct.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **GREEN VbC** — verification before completion gate.
  - (**sub-agent**) — `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **SC count gate** — verify all 15 SCs have verdicts.
  - (**sub-agent**) — `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Pre-PR gate** — verify no SC has a FAIL verdict.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Rationalization check** — check for rationalization in any step.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2162, proposed_action: ..., rule_text: ...}`
- [ ] **Audit** — dispatch audit task for phase-appropriate audit.
  - (**orchestrator**) — dispatch audit task via `task(subagent_type="general")`
  - Context: `{spec_local_dir: ..., artifact_evidence_dir: ...}`
- [ ] **Cross-validate** — consensus check across verification results.
  - (**sub-agent**) — `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Regression check** — run regression tests.
  - (**sub-agent**) — `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Review prep** — prepare PR for review.
  - (**sub-agent**) — `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
  - Context: `{issue_number: 2162}`
- [ ] **Create PR** — create pull request.
  - (**sub-agent**) — `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
  - Context: `{issue_number: 2162, authorization_scope: ..., halt_at: ...}`
- [ ] **Executive summary** — completion report.
  - (**sub-agent**) — `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
  - Context: `{issue_number: 2162}`

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-27T20:21:00Z | `plan_created` | Plan file: `.opencode/.issues/2162/plan.md`, Phases: 3 |
