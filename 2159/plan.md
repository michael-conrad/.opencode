---
plan_schema_version: "1.0"
issue: 2159
title: "SPEC-FIX: verify-authorization should update issue body Status field"
dispatch:
  - phase: 1
    skill: approval-gate-scope
    task: record-authorization
---

## Pre-implementation

- [ ] **Coherence gate** — Dispatch `skill({name: "audit"})` → `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")` with `{issue_number: 2159}`. Verify the spec has no internal conflicts: SC-1 requires a sub-step in record-authorization, SC-2 requires scope guard `for_spec` or higher, SC-3 requires `github_issue_write`. All three are compatible with the proposed single change to `record-authorization.md`.
  - Context: `{issue_number: 2159, issues_prefix: .opencode/.issues/, project_root: /home/muksihs/git/opencode-config}`
  - (**clean-room**)
- [ ] **Baseline check** — Dispatch `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")` with `{issue_number: 2159}`. Verify the current state of the affected files is readable and the `.opencode` submodule is checked out.
  - Context: `{issue_number: 2159, issues_prefix: .opencode/.issues/, project_root: /home/muksihs/git/opencode-config}`
  - (**clean-room**)

## Phase 1: Add Status field update sub-step to record-authorization (SC-1, SC-2, SC-3)

**Concern:** Modify `record-authorization.md` to add a sub-step that updates the remote issue body `### Status` field to "Approved" when `authorization_scope` is `for_spec` or higher. Also update the `SKILL.md` workflow section to include `github.owner` and `github.repo` in the Record authorization step context.

**Affected files:**
- `.opencode/skills/approval-gate-scope/tasks/verify-authorization/record-authorization.md`
- `.opencode/skills/approval-gate-scope/SKILL.md` (workflows section for the Record authorization step)

### Item 1: Add sub-step to Step 2 (Record authorization) — SC-1, SC-2, SC-3

- [ ] **SC coherence gate** — Dispatch `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")` with `{issue_number: 2159}`. Verify item 1's SC bundle is coherent: adding a sub-step that updates remote issue body Status field when `for_spec` or higher, using `github_issue_write`, does not conflict with existing record-authorization logic.
  - (**clean-room**)
- [ ] **Pre-RED baseline** — Dispatch `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")` with `{issue_number: 2159}`. Read the current `record-authorization.md` to capture its content for reference. Read the SKILL.md workflows section to capture current Record authorization step context.
  - (**clean-room**)
- [ ] **RED phase — Write failing enforcement test** — Dispatch `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")` with `{issue_number: 2159}`. Write a behavioral or content-verification test that asserts the Status field update rule exists. For SC-1: grep for `### Status` and `Approved` in the Step 2 section of `record-authorization.md`. For SC-2: sub-agent reads the scope guard. For SC-3: grep for `github_issue_write` in Step 2. The test MUST fail initially.
  - Context: `{issue_number: 2159, sc_ids: [SC-1, SC-2, SC-3]}`
  - (**clean-room**)
- [ ] **Z3 check RED** — Run `.opencode/tools/solve check --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --state-path /home/muksihs/git/opencode-config/tmp/2159/state/` to validate the RED phase state transition.
  - (**inline**)
- [ ] **RED doublecheck** — Dispatch `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` with `{issue_number: 2159}`. Confirm the RED test fails as expected (the Status field update code does not exist yet).
  - (**clean-room**)
- [ ] **Z3 check RED doublecheck** — Run `.opencode/tools/solve check --contract-path .opencode/skills/implementation-pipeline/pipeline-state-machine.yaml --state-path /home/muksihs/git/opencode-config/tmp/2159/state/` to validate the RED doublecheck state transition.
  - (**inline**)
- [ ] **Post-RED enforcement** — Dispatch `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")` with `{issue_number: 2159}`. Verify no prohibited patterns in the test code.
  - (**clean-room**)
- [ ] **Z3 check post-RED** — Run `.opencode/tools/solve check` to validate post-RED state.
  - (**inline**)
- [ ] **GREEN phase — Implement the fix** — Dispatch `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")` with `{issue_number: 2159}`. Make the code change that adds the Status field update sub-step. Two files need modification:

    1. **`record-authorization.md`** — Add a new numbered step (e.g., Step 3a or 3.5) after the existing "Update `spec.md` frontmatter" step:
       - Description: "Update remote issue body Status field"
       - Scope guard: `authorization_scope` is `for_spec` or higher
       - Action: Use `github_issue_write` to edit the issue body, replacing `### Status: Draft` with `### Status: Approved`
       - Include error handling for malformed issue body

    2. **`approval-gate-scope/SKILL.md`** — Update the Record authorization step in all three workflow paths (fast-path, gap-fill-path, full-path) to include `github.owner` and `github.repo` in the context, since `github_issue_write` requires them.
  - Context: `{issue_number: 2159, github.owner: michael-conrad, github.repo: .opencode}`
  - (**clean-room**)
- [ ] **Z3 check GREEN** — Run `.opencode/tools/solve check` to validate GREEN state transition.
  - (**inline**)
- [ ] **Post-GREEN enforcement** — Dispatch `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")` with `{issue_number: 2159}`. Verify no prohibited patterns in the implementation code (no inline secrets, no preloaded context).
  - (**clean-room**)
- [ ] **Z3 check post-GREEN** — Run `.opencode/tools/solve check` to validate post-GREEN state.
  - (**inline**)
- [ ] **Create checkpoint tag** — Dispatch `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")` with `{issue_number: 2159}`. Create a checkpoint tag marking the GREEN completion.
  - (**clean-room**)
- [ ] **Checkpoint commit** — Dispatch `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")` with `{issue_number: 2159}`. Commit the GREEN implementation and the RED test together.
  - (**clean-room**)
- [ ] **Structural checks** — Dispatch `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")` with `{issue_number: 2159}`. Run lint/typecheck on affected files if applicable.
  - (**clean-room**)
- [ ] **GREEN doublecheck** — Dispatch `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")` with `{issue_number: 2159}`. Confirm the RED test now passes (the Status field update code exists). For SC-1: grep `record-authorization.md` Step 2 section for `### Status` and `Approved`. For SC-2: read the scope guard condition. For SC-3: grep for `github_issue_write` in Step 2.
  - (**clean-room**)
- [ ] **GREEN VbC** — Dispatch `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")` with `{issue_number: 2159}`. Produce per-SC evidence artifacts.
  - (**clean-room**)
- [ ] **SC count gate** — Dispatch `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")` with `{issue_number: 2159}`. Verify all 3 SCs have PASS verdicts.
  - (**clean-room**)

## Post-implementation

- [ ] **Audit** — Dispatch `task(..., prompt: "execute audit from audit")` with `{issue_number: 2159, spec_local_dir: .opencode/.issues/2159/, artifact_evidence_dir: /home/muksihs/git/opencode-config/tmp/2159/}`. The auditor verifies the fix matches the spec requirements.
  - (**clean-room**)
- [ ] **Cross-validate** — Dispatch `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")` with `{issue_number: 2159}`. Reach consensus between auditor findings and implementation evidence.
  - (**clean-room**)
- [ ] **Regression check** — Dispatch `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")` with `{issue_number: 2159}`. Check for any regression in existing enforcement tests related to verify-authorization.
  - (**clean-room**)
- [ ] **Review prep** — Dispatch `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")` with `{issue_number: 2159}`. Prepare the PR for review.
  - (**clean-room**)
- [ ] **Create PR** — Dispatch `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")` with `{issue_number: 2159, authorization_scope: for_pr, halt_at: pr_created}`. Create the pull request targeting the `.opencode` submodule repo.
  - (**clean-room**)
- [ ] **Completion** — Dispatch `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")` with `{issue_number: 2159}`. Applies lifecycle event and reports execution summary.
  - (**clean-room**)

---

## Exit Criteria

| SC ID | Criterion | Phase | Evidence Type |
|-------|-----------|-------|---------------|
| SC-1 | Sub-step added to Step 2 that updates `### Status` to "Approved" | 1 — Item 1 | `string` |
| SC-2 | Status update only occurs for `for_spec` or higher | 1 — Item 1 | `semantic` |
| SC-3 | Status field update uses `github_issue_write` | 1 — Item 1 | `string` |

---

## Lifecycle Events

- **2026-07-26T23:30:00Z** — `plan_created` — Plan created with 1 phase, 1 item, 3 SCs. Execution strategy: clean-room dispatch per item, single phase with no dependencies. Dispatch skill: `approval-gate-scope`, task: `record-authorization`. Next step: implementation-pipeline entry via `assemble-work` after plan approval.