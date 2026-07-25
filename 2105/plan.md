---
plan_schema_version: "1.0"
issue: 2105
title: "[SPEC-FIX] Agent MUST NOT merge PRs — human-only merge enforcement"
dispatch:
  - phase: P1
    skill: test-driven-development
    task: green
  - phase: P2
    skill: test-driven-development
    task: green
  - phase: P3
    skill: test-driven-development
    task: green
  - phase: P4
    skill: test-driven-development
    task: red
  - phase: P5
    skill: test-driven-development
    task: green
---

# Implementation Plan: Human-Only Merge Enforcement

## Pre-Implementation Steps

### Coherence Gate
- [ ] Dispatch `audit --task coherence-extraction` (**sub-agent**)
  - Context: `{issue_number: 2105}`
  - Verifies spec/plan coherence before any RED routing
  - If BLOCKED: remediate and re-dispatch

### Baseline Check
- [ ] Dispatch `implementation-pipeline --task pre-red-baseline` (**sub-agent**)
  - Context: `{issue_number: 2105}`
  - Verifies current state of all affected files before modifications

---

## Phase P1: PR-Creation Merge Gate (SC-1)

**Concern:** Add post-creation HALT step to `pr-creation.md` prohibiting merge
**Evidence type:** `string`
**Affected file:** `.opencode/skills/git-workflow-pr/tasks/pr-creation.md`

### Green Phase
- [ ] Dispatch `test-driven-development --task green` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-1], file: .opencode/skills/git-workflow-pr/tasks/pr-creation.md}`
  - Add step after PR creation: "HALT — do not merge. Only the developer can merge. The `github_merge_pull_request` tool is FORBIDDEN for agent use."
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
  - Z3 check of state transition
- [ ] Dispatch `implementation-pipeline --task post-green-enforcement` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
  - Z3 check of post-green state
- [ ] Dispatch `implementation-pipeline --task checkpoint-tag-create` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `git-workflow --task commit-prep` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `finishing-a-development-branch --task checklist` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-1]}`
- [ ] Dispatch `verification-before-completion --task completion` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `implementation-pipeline --task sc-count-gate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105}`
  - Pre-PR gate — BLOCKs if any SC FAIL
- [ ] Dispatch audit task (**sub-agent**)
  - Context: `{issue_number: 2105, spec_local_dir: .opencode/.issues/2105}`
- [ ] Dispatch `audit --task cross-validate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `test-driven-development --task patterns` (**sub-agent**)
  - Context: `{issue_number: 2105}`
  - Regression check

---

## Phase P2: Completion Merge Gate (SC-2)

**Concern:** Add no-merge gate to `completion.md` checking for merge API calls
**Evidence type:** `string`
**Affected file:** `.opencode/skills/git-workflow-pr/tasks/completion.md`

### Green Phase
- [ ] Dispatch `test-driven-development --task green` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-2], file: .opencode/skills/git-workflow-pr/tasks/completion.md}`
  - Add step checking the agent has not called `github_merge_pull_request` during the session, and halts if it has
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
- [ ] Dispatch `implementation-pipeline --task post-green-enforcement` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
- [ ] Dispatch `implementation-pipeline --task checkpoint-tag-create` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `git-workflow --task commit-prep` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `finishing-a-development-branch --task checklist` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-2]}`
- [ ] Dispatch `verification-before-completion --task completion` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `implementation-pipeline --task sc-count-gate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105}`
  - Pre-PR gate
- [ ] Dispatch audit task (**sub-agent**)
  - Context: `{issue_number: 2105, spec_local_dir: .opencode/.issues/2105}`
- [ ] Dispatch `audit --task cross-validate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `test-driven-development --task patterns` (**sub-agent**)
  - Context: `{issue_number: 2105}`

---

## Phase P3: Authorization Pre-Merge Check (SC-3)

**Concern:** Add pre-merge block to `verify-authorization.md`
**Evidence type:** `string`
**Affected file:** `.opencode/skills/approval-gate-scope/tasks/verify-authorization.md`

### Green Phase
- [ ] Dispatch `test-driven-development --task green` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-3], file: .opencode/skills/approval-gate-scope/tasks/verify-authorization.md}`
  - Add step checking whether the requested action is a merge and blocks it with "HALT — human-only merge. Agents MUST NOT merge PRs."
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
- [ ] Dispatch `implementation-pipeline --task post-green-enforcement` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
- [ ] Dispatch `implementation-pipeline --task checkpoint-tag-create` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `git-workflow --task commit-prep` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `finishing-a-development-branch --task checklist` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-3]}`
- [ ] Dispatch `verification-before-completion --task completion` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `implementation-pipeline --task sc-count-gate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105}`
  - Pre-PR gate
- [ ] Dispatch audit task (**sub-agent**)
  - Context: `{issue_number: 2105, spec_local_dir: .opencode/.issues/2105}`
- [ ] Dispatch `audit --task cross-validate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `test-driven-development --task patterns` (**sub-agent**)
  - Context: `{issue_number: 2105}`

---

## Phase P4: Behavioral Test (SC-4)

**Concern:** Write behavioral test that verifies agent declines to merge
**Evidence type:** `behavioral`
**Depends on:** P1, P2, P3 (rules must exist before test can verify them)
**Affected file:** `.opencode/tests-v2/behaviors/`

### Red Phase
- [ ] Dispatch `test-driven-development --task red` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-4], file: .opencode/tests-v2/behaviors/}`
  - Write behavioral test with merge prompt
  - Assert `assert_stderr_pattern_absent "github_merge_pull_request"` in stderr
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-4]}`
  - RED doublecheck
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
  - Z3 check of RED doublecheck
- [ ] Dispatch `implementation-pipeline --task post-red-enforcement` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
  - Z3 check of post-RED state

---

## Phase P5: Critical Rules Cross-Reference (SC-5)

**Concern:** Add cross-reference in `000-critical-rules.md` to skill enforcement
**Evidence type:** `string`
**Affected file:** `.opencode/guidelines/000-critical-rules.md`

### Green Phase
- [ ] Dispatch `test-driven-development --task green` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-5], file: .opencode/guidelines/000-critical-rules.md}`
  - Add cross-reference to skill task files that enforce human-only merge
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
- [ ] Dispatch `implementation-pipeline --task post-green-enforcement` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `solve --task check` (**inline**)
  - Context: `{issue_number: 2105, contract_path: <resolved from previous step>}`
- [ ] Dispatch `implementation-pipeline --task checkpoint-tag-create` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `git-workflow --task commit-prep` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `finishing-a-development-branch --task checklist` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105, scs: [SC-5]}`
- [ ] Dispatch `verification-before-completion --task completion` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `implementation-pipeline --task sc-count-gate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `verification-before-completion --task verify` (**sub-agent**)
  - Context: `{issue_number: 2105}`
  - Pre-PR gate
- [ ] Dispatch audit task (**sub-agent**)
  - Context: `{issue_number: 2105, spec_local_dir: .opencode/.issues/2105}`
- [ ] Dispatch `audit --task cross-validate` (**sub-agent**)
  - Context: `{issue_number: 2105}`
- [ ] Dispatch `test-driven-development --task patterns` (**sub-agent**)
  - Context: `{issue_number: 2105}`

---

## Post-Implementation Steps

### Review Preparation
- [ ] Dispatch `git-workflow --task review-prep` (**sub-agent**)
  - Context: `{issue_number: 2105}`

### PR Creation
- [ ] Dispatch `pr-creation-workflow --task create` (**sub-agent**)
  - Context: `{issue_number: 2105, authorization_scope: for_pr, halt_at: pr_created}`

### Completion
- [ ] Dispatch `completion-core --task completion` (**sub-agent**)
  - Context: `{issue_number: 2105}`

---

## Lifecycle Events

- **event:** plan_created
- **timestamp:** 2026-07-24T12:00:00Z
- **issuer:** OpenCode (deepseek-v4-flash)
- **plan_path:** .opencode/.issues/2105/plan.md
- **phase_count:** 5
- **execution_strategy:** sequential with P1, P2, P3, P5 in parallel (independent), then P4 (depends on P1-P3)
