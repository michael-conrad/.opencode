---
plan_schema_version: "1.0"
issue: 2142
title: "Fix skill card descriptions to reference project-local tool paths"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: green-phase
  - phase: 2
    skill: verification-before-completion
    task: verify
  - phase: 3
    skill: test-driven-development
    task: red-phase
---

# Implementation Plan: Skill Description Tool Path Fix

## Pre-Implementation Steps

- [ ] **Coherence gate.** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence before any implementation begins.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Baseline check.** Dispatch `pre-red-baseline` from implementation-pipeline to verify the codebase state before any changes.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

## Phase 1: Update Skill Descriptions

Covers SC-1, SC-2, SC-3, SC-4. Four items, each updating one SKILL.md description field.

### Item 1 — SC-1: Update solve/SKILL.md description

- [ ] **Green phase.** Dispatch `green-phase` from implementation-pipeline. Sub-agent reads `implementation-pipeline/tasks/green-phase.md`, then edits `.opencode/skills/solve/SKILL.md` description to lead with `.opencode/tools/solve`.
  - Context: `{issue_number: 2142, sc: SC-1}`
  - (**sub-agent**)

- [ ] **Z3 check GREEN.** Run `solve --task check` inline to verify state transition.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Post-green enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Z3 check post-GREEN.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Checkpoint commit.** Dispatch `commit-prep` from git-workflow.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Structural checks.** Dispatch `checklist` from finishing-a-development-branch.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Green doublecheck.** Dispatch `verify` from verification-before-completion to verify SC-1 is satisfied.
  - Context: `{issue_number: 2142, sc: SC-1}`
  - (**sub-agent**)

- [ ] **Green VbC.** Dispatch `completion` from verification-before-completion.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

### Item 2 — SC-2: Update plan/SKILL.md description

- [ ] **Green phase.** Dispatch `green-phase` from implementation-pipeline. Sub-agent edits `.opencode/skills/plan/SKILL.md` description to lead with `.opencode/tools/plan`.
  - Context: `{issue_number: 2142, sc: SC-2}`
  - (**sub-agent**)

- [ ] **Z3 check GREEN.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Post-green enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Z3 check post-GREEN.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Checkpoint commit.** Dispatch `commit-prep` from git-workflow.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Structural checks.** Dispatch `checklist` from finishing-a-development-branch.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Green doublecheck.** Dispatch `verify` from verification-before-completion to verify SC-2 is satisfied.
  - Context: `{issue_number: 2142, sc: SC-2}`
  - (**sub-agent**)

- [ ] **Green VbC.** Dispatch `completion` from verification-before-completion.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

### Item 3 — SC-3: Update plan-creation-pipeline/SKILL.md description

- [ ] **Green phase.** Dispatch `green-phase` from implementation-pipeline. Sub-agent edits `.opencode/skills/plan-creation-pipeline/SKILL.md` description to reference `.opencode/tools/solve` instead of bare "Z3".
  - Context: `{issue_number: 2142, sc: SC-3}`
  - (**sub-agent**)

- [ ] **Z3 check GREEN.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Post-green enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Z3 check post-GREEN.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Checkpoint commit.** Dispatch `commit-prep` from git-workflow.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Structural checks.** Dispatch `checklist` from finishing-a-development-branch.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Green doublecheck.** Dispatch `verify` from verification-before-completion to verify SC-3 is satisfied.
  - Context: `{issue_number: 2142, sc: SC-3}`
  - (**sub-agent**)

- [ ] **Green VbC.** Dispatch `completion` from verification-before-completion.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

### Item 4 — SC-4: Update issue-operations-core/SKILL.md description

- [ ] **Green phase.** Dispatch `green-phase` from implementation-pipeline. Sub-agent edits `.opencode/skills/issue-operations-core/SKILL.md` description to reference `.opencode/tools/gitbucket-api` instead of bare "GitBucket API".
  - Context: `{issue_number: 2142, sc: SC-4}`
  - (**sub-agent**)

- [ ] **Z3 check GREEN.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Post-green enforcement.** Dispatch `post-green-enforcement` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Z3 check post-GREEN.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Create checkpoint tag.** Dispatch `checkpoint-tag-create` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Checkpoint commit.** Dispatch `commit-prep` from git-workflow.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Structural checks.** Dispatch `checklist` from finishing-a-development-branch.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Green doublecheck.** Dispatch `verify` from verification-before-completion to verify SC-4 is satisfied.
  - Context: `{issue_number: 2142, sc: SC-4}`
  - (**sub-agent**)

- [ ] **Green VbC.** Dispatch `completion` from verification-before-completion.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

## Phase 2: Verify No Unintended Changes

Covers SC-5. Runs in parallel with Phase 3.

### Item 5 — SC-5: Verify diff shows only 4 files modified

- [ ] **Verify.** Dispatch `verify` from verification-before-completion. Sub-agent runs `git diff --stat` and confirms exactly 4 files are modified.
  - Context: `{issue_number: 2142, sc: SC-5}`
  - (**sub-agent**)

## Phase 3: Write Behavioral Enforcement Test

Covers SC-6. Runs in parallel with Phase 2.

### Item 6 — SC-6: Write behavioral enforcement test for tool-lookup pattern

- [ ] **Red phase.** Dispatch `red-phase` from implementation-pipeline. Sub-agent writes a behavioral enforcement test that sends a prompt and verifies the agent does NOT run `which`/`command -v` for `.opencode/tools/` tools.
  - Context: `{issue_number: 2142, sc: SC-6}`
  - (**sub-agent**)

- [ ] **Z3 check RED.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Red doublecheck.** Dispatch `verify` from verification-before-completion to verify the test is correctly written.
  - Context: `{issue_number: 2142, sc: SC-6}`
  - (**sub-agent**)

- [ ] **Z3 check RED doublecheck.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

- [ ] **Post-red enforcement.** Dispatch `post-red-enforcement` from implementation-pipeline.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Z3 check post-RED.** Run `solve --task check` inline.
  - Context: `{issue_number: 2142, contract_path: .opencode/.issues/2142/dependency-contract.yaml}`
  - (**inline**)

## Post-Implementation Steps

- [ ] **SC count gate.** Dispatch `sc-count-gate` from implementation-pipeline. Reads SC summary, counts verified SCs, blocks if any SC has no verdict.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Pre-PR gate.** Dispatch `verify` from verification-before-completion. Reads all SC verdicts, blocks if any FAIL.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Audit.** Dispatch appropriate audit task from audit skill with `{spec_local_dir, artifact_evidence_dir}`. If non-clean-pass, remediate and restart.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Cross-validate.** Dispatch `cross-validate` from audit.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Regression check.** Dispatch `patterns` from test-driven-development.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Review prep.** Dispatch `review-prep` from git-workflow.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

- [ ] **Create PR.** Dispatch `create` from pr-creation-workflow.
  - Context: `{issue_number: 2142, authorization_scope: for_pr, halt_at: pr_created}`
  - (**sub-agent**)

- [ ] **Completion.** Dispatch `completion` from completion-core.
  - Context: `{issue_number: 2142}`
  - (**sub-agent**)

## Lifecycle Events

- `plan_created` at 2026-07-25T18:00:00Z by OpenCode (deepseek-v4-flash)
  - Plan file: `.opencode/.issues/2142/plan.md`
  - Phase count: 3
  - Execution strategy: Phase 1 (4 items, sequential sub-agent dispatch), Phase 2 and Phase 3 (parallel sub-agent dispatch)
