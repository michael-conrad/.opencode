---
plan_schema_version: "1.0"
issue: 2180
title: Replace `ls -d .git/` glob with `git submodule status` for submodule detection
dispatch:
  - phase: phase-1
    skill: test-driven-development
    task: green
---

## Pre-Implementation

- [ ] **Coherence gate.** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence before any implementation work.
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **Baseline check.** Dispatch `implementation-pipeline --task pre-red-baseline` to verify baseline state before implementation.
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: {issue_number: 2180}

## Phase 1: Replace `ls -d .git/` glob with `git submodule status`

Concern: All 8 SCs are independent string replacements — same change type, no dependencies, same evidence type (string). Any order is valid.

### Item 1 — SC-1: `branch-cleanup.md` submodule detection

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status | awk '{print $2}'` in `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`.
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-1, file: .opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md, change_type: Replace glob with git submodule status | awk pipeline}
- [ ] **z3-check-green.** Dispatch `solve --task check` to validate GREEN state transition.
  - (**inline**) `solve --task check`
  - Context: {issue_number: 2180, contract_path: ...}
- [ ] **post-green-enforcement.** Dispatch `implementation-pipeline --task post-green-enforcement`.
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **z3-check-post-green.** Dispatch `solve --task check` to validate post-GREEN state transition.
  - (**inline**) `solve --task check`
  - Context: {issue_number: 2180, contract_path: ...}
- [ ] **checkpoint-tag-create.** Dispatch `implementation-pipeline --task checkpoint-tag-create`.
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **checkpoint-commit.** Dispatch `git-workflow --task commit-prep`.
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: {issue_number: 2180}

### Item 2 — SC-2: `issue-closure.md` submodule detection

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status | awk '{print $2}'` in `.opencode/skills/git-workflow-cleanup/tasks/cleanup/issue-closure.md`.
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-2, file: .opencode/skills/git-workflow-cleanup/tasks/cleanup/issue-closure.md, change_type: Replace glob with git submodule status | awk pipeline}
- [ ] **z3-check-green.** (**inline**) `solve --task check`
- [ ] **post-green-enforcement.** (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **z3-check-post-green.** (**inline**) `solve --task check`
- [ ] **checkpoint-tag-create.** (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **checkpoint-commit.** (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

### Item 3 — SC-3: `check-pr.md` submodule detection (first occurrence, prose)

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status` (prose context) in `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` (first occurrence).
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-3, file: .opencode/skills/git-workflow-cleanup/tasks/check-pr.md, change_type: Replace glob with git submodule status (prose, first occurrence)}
- [ ] **z3-check-green.** (**inline**) `solve --task check`
- [ ] **post-green-enforcement.** (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **z3-check-post-green.** (**inline**) `solve --task check`
- [ ] **checkpoint-tag-create.** (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **checkpoint-commit.** (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

### Item 4 — SC-4: `check-pr.md` submodule detection (second occurrence, prose)

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status` (prose context) in `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` (second occurrence).
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-4, file: .opencode/skills/git-workflow-cleanup/tasks/check-pr.md, change_type: Replace glob with git submodule status (prose, second occurrence)}
- [ ] **z3-check-green.** (**inline**) `solve --task check`
- [ ] **post-green-enforcement.** (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **z3-check-post-green.** (**inline**) `solve --task check`
- [ ] **checkpoint-tag-create.** (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **checkpoint-commit.** (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

### Item 5 — SC-5: `cleanup.md` submodule detection

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status | awk '{print $2}'` in `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md`.
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-5, file: .opencode/skills/git-workflow-cleanup/tasks/cleanup.md, change_type: Replace glob with git submodule status | awk pipeline}
- [ ] **z3-check-green.** (**inline**) `solve --task check`
- [ ] **post-green-enforcement.** (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **z3-check-post-green.** (**inline**) `solve --task check`
- [ ] **checkpoint-tag-create.** (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **checkpoint-commit.** (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

### Item 6 — SC-6: `operating-protocol.md` submodule detection

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status | awk '{print $2}'` in `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md`.
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-6, file: .opencode/skills/git-workflow-branch/tasks/operating-protocol.md, change_type: Replace glob with git submodule status | awk pipeline}
- [ ] **z3-check-green.** (**inline**) `solve --task check`
- [ ] **post-green-enforcement.** (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **z3-check-post-green.** (**inline**) `solve --task check`
- [ ] **checkpoint-tag-create.** (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **checkpoint-commit.** (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

### Item 7 — SC-7: `pre-work.md` submodule detection

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status | awk '{print $2}'` in `.opencode/skills/git-workflow-branch/tasks/pre-work.md`.
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-7, file: .opencode/skills/git-workflow-branch/tasks/pre-work.md, change_type: Replace glob with git submodule status | awk pipeline}
- [ ] **z3-check-green.** (**inline**) `solve --task check`
- [ ] **post-green-enforcement.** (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **z3-check-post-green.** (**inline**) `solve --task check`
- [ ] **checkpoint-tag-create.** (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **checkpoint-commit.** (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

### Item 8 — SC-8: `provenance.md` submodule detection (prose)

- [ ] **green-phase.** Dispatch `test-driven-development --task green` to replace `ls -d .git/` with `git submodule status` (prose context) in `.opencode/skills/git-workflow-branch/tasks/provenance.md`.
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: {issue_number: 2180, sc: SC-8, file: .opencode/skills/git-workflow-branch/tasks/provenance.md, change_type: Replace glob with git submodule status (prose)}
- [ ] **z3-check-green.** (**inline**) `solve --task check`
- [ ] **post-green-enforcement.** (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
- [ ] **z3-check-post-green.** (**inline**) `solve --task check`
- [ ] **checkpoint-tag-create.** (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **checkpoint-commit.** (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

## Post-Implementation

- [ ] **structural-checks.** Dispatch `finishing-a-development-branch --task checklist` to run lint/typecheck/structural verification.
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **green-doublecheck.** Dispatch `verification-before-completion --task verify` to verify all GREEN implementations.
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **green-vbc.** Dispatch `verification-before-completion --task completion` for verification before completion.
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **sc-count-gate.** Dispatch `implementation-pipeline --task sc-count-gate` to verify all 8 SCs have verdicts.
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **pre-pr-gate.** Dispatch `verification-before-completion --task verify` to read all SC verdicts and BLOCK if any FAIL.
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **audit.** Dispatch audit task to verify all implementations against spec.
  - (**orchestrator**) Dispatch the appropriate audit task via `task(subagent_type="general")`
  - Context: {issue_number: 2180, spec_local_dir: .opencode/.issues/2180, artifact_evidence_dir: ...}
  - If non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, then restart audit step
  - On clean PASS: collect artifact_path and pass as auditor_artifact_paths to cross-validate
- [ ] **cross-validate.** Dispatch `audit --task cross-validate` for consensus check.
  - (**sub-agent**) `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **regression-check.** Dispatch `test-driven-development --task patterns` for regression test patterns.
  - (**sub-agent**) `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **review-prep.** Dispatch `git-workflow --task review-prep` to prepare PR review.
  - (**sub-agent**) `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
  - Context: {issue_number: 2180}
- [ ] **create-pr.** Dispatch `pr-creation-workflow --task create` to create the pull request.
  - (**sub-agent**) `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
  - Context: {issue_number: 2180, authorization_scope: ..., halt_at: ...}
- [ ] **exec-summary.** Dispatch `completion-core --task completion` for final completion report.
  - (**sub-agent**) `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
  - Context: {issue_number: 2180}

## Exit Criteria

All 8 SCs are independent string replacements in Phase 1. The implementation is complete when:

| SC | Phase | Criterion | Evidence |
|----|-------|-----------|----------|
| SC-1 | Phase 1 | `branch-cleanup.md`: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | grep: old pattern absent, new pattern present |
| SC-2 | Phase 1 | `issue-closure.md`: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | grep: old pattern absent, new pattern present |
| SC-3 | Phase 1 | `check-pr.md` (first): `ls -d .git/` replaced with `git submodule status` (prose) | grep: old pattern absent, new pattern present |
| SC-4 | Phase 1 | `check-pr.md` (second): `ls -d .git/` replaced with `git submodule status` (prose) | grep: old pattern absent, new pattern present |
| SC-5 | Phase 1 | `cleanup.md`: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | grep: old pattern absent, new pattern present |
| SC-6 | Phase 1 | `operating-protocol.md`: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | grep: old pattern absent, new pattern present |
| SC-7 | Phase 1 | `pre-work.md`: `ls -d .git/` replaced with `git submodule status \| awk '{print $2}'` | grep: old pattern absent, new pattern present |
| SC-8 | Phase 1 | `provenance.md`: `ls -d .git/` replaced with `git submodule status` (prose) | grep: old pattern absent, new pattern present |

**Gate:** All 8 SCs must PASS for implementation to be complete. Any single FAIL blocks completion.

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-29T21:34:00Z | plan_created | Plan file: `.opencode/.issues/2180/plan.md`, Phases: 1 (Phase 1: Replace `ls -d .git/` glob with `git submodule status`), Items: 8, Dispatch: clean-room sub-agents with inline solve checks
