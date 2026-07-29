---
plan_schema_version: "1.0"
issue: 2173
title: "[SPEC-FIX] session-init and session-to-timeline tool regressions"
dispatch:
  - phase: phase-1
    skill: test-driven-development
    task: red
    sc: SC-1
  - phase: phase-1
    skill: test-driven-development
    task: green
    sc: SC-1
  - phase: phase-2
    skill: test-driven-development
    task: red
    sc: SC-2
  - phase: phase-2
    skill: test-driven-development
    task: green
    sc: SC-2
  - phase: phase-2
    skill: test-driven-development
    task: red
    sc: SC-3
  - phase: phase-2
    skill: test-driven-development
    task: green
    sc: SC-3
---

# Implementation Plan: session-init and session-to-timeline tool regressions

## Pre-Implementation Steps

### SC-Coherence Gate
- [ ] Dispatch `audit --task coherence-extraction` to verify spec/plan coherence before RED routing
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

### Pre-RED Baseline
- [ ] Dispatch `implementation-pipeline --task pre-red-baseline` to capture baseline state before any changes
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

---

## Phase 1: Fix session-to-timeline docstring

**Concern:** session-to-timeline docstring fix
**SCs:** SC-1
**Dependencies:** None

### Item 1 — SC-1: session-to-timeline with no args prints usage message

#### RED Phase
- [ ] Write a failing test that verifies session-to-timeline with no args prints usage message
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode, sc: SC-1}`
  - Test: Run `.opencode/tools/session-to-timeline` with no args; assert stderr does NOT contain "execuvrun"
- [ ] Z3 check RED: validate RED state against contract
  - (**inline**) `solve --task check`
  - Context: `{issue_number: 2173, contract_path, state_path}`
- [ ] RED doublecheck: verify RED test is correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check RED doublecheck
  - (**inline**) `solve --task check`
- [ ] Post-RED enforcement: verify RED gate passed
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check post-RED
  - (**inline**) `solve --task check`

#### GREEN Phase
- [ ] Implement the fix: replace bare string docstring with explicit `__doc__ =` assignment in `.opencode/tools/session-to-timeline`
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode, sc: SC-1}`
  - Change: Replace the bare string `"""DESCRIPTION:..."""` at line ~12 with `__doc__ = """DESCRIPTION:..."""`
- [ ] Z3 check GREEN
  - (**inline**) `solve --task check`
- [ ] Post-GREEN enforcement: verify GREEN gate passed
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check post-GREEN
  - (**inline**) `solve --task check`

#### Checkpoint
- [ ] Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Checkpoint commit
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

#### Verification
- [ ] Structural checks: run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] GREEN doublecheck: verify the fix works
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] GREEN VbC: verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] SC count gate: verify all SCs have verdicts
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

---

## Phase 2: Restore session-init executable bit

**Concern:** session-init executable bit
**SCs:** SC-2, SC-3
**Dependencies:** None

### Item 2 — SC-2: session-init has executable bit set in committed submodule

#### RED Phase
- [ ] Write a failing test that verifies session-init is NOT executable in committed submodule
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode, sc: SC-2}`
  - Test: `git -C .opencode ls-tree HEAD -- tools/session-init` shows mode `100644` (non-executable)
- [ ] Z3 check RED
  - (**inline**) `solve --task check`
- [ ] RED doublecheck
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check RED doublecheck
  - (**inline**) `solve --task check`
- [ ] Post-RED enforcement
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check post-RED
  - (**inline**) `solve --task check`

#### GREEN Phase
- [ ] Implement the fix: restore executable bit on session-init
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode, sc: SC-2}`
  - Change: `git -C .opencode chmod +x tools/session-init`
- [ ] Z3 check GREEN
  - (**inline**) `solve --task check`
- [ ] Post-GREEN enforcement
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check post-GREEN
  - (**inline**) `solve --task check`

#### Checkpoint
- [ ] Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Checkpoint commit
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

#### Verification
- [ ] Structural checks
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] GREEN doublecheck: verify the mode change
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] GREEN VbC
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] SC count gate
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

### Item 3 — SC-3: session-init runs without "Permission denied"

#### RED Phase
- [ ] Write a failing test that verifies session-init exits with code 0
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode, sc: SC-3}`
  - Test: Run `.opencode/tools/session-init`; assert exit code is non-zero (fails because executable bit not yet set)
- [ ] Z3 check RED
  - (**inline**) `solve --task check`
- [ ] RED doublecheck
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check RED doublecheck
  - (**inline**) `solve --task check`
- [ ] Post-RED enforcement
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check post-RED
  - (**inline**) `solve --task check`

#### GREEN Phase
- [ ] Implement the fix: (already done by Item 2 — chmod +x)
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode, sc: SC-3}`
  - Note: GREEN is already satisfied by Item 2's chmod +x. This step verifies the fix works.
- [ ] Z3 check GREEN
  - (**inline**) `solve --task check`
- [ ] Post-GREEN enforcement
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Z3 check post-GREEN
  - (**inline**) `solve --task check`

#### Checkpoint
- [ ] Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] Checkpoint commit
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

#### Verification
- [ ] Structural checks
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] GREEN doublecheck: verify session-init runs
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] GREEN VbC
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`
- [ ] SC count gate
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

---

## Post-Implementation Steps

### Pre-PR Gate
- [ ] Verify all SC verdicts — BLOCK if any FAIL
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

### Audit
- [ ] Dispatch audit task to verify implementation against spec
  - (**sub-agent**) `task(subagent_type="general")`
  - Context: `{spec_local_dir: .opencode/.issues/2173, artifact_evidence_dir: .opencode/.issues/2173/artifacts}`
- [ ] If audit returns non-clean-pass: remediate root cause, restart audit
- [ ] Cross-validate: produce consensus findings
  - (**sub-agent**) `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

### Regression Check
- [ ] Run regression tests
  - (**sub-agent**) `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

### Review Prep
- [ ] Prepare PR for review
  - (**sub-agent**) `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

### Create PR
- [ ] Create pull request
  - (**sub-agent**) `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode, authorization_scope: for_pr, halt_at: pr_created}`

### Completion
- [ ] Append lifecycle event and report summary
  - (**sub-agent**) `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
  - Context: `{issue_number: 2173, project_root, issues_prefix: .opencode}`

---

## Lifecycle Events

- `plan_created` at 2026-07-29T12:25:00Z — 2 phases, 3 items, 3 SCs, clean-room dispatch mode
