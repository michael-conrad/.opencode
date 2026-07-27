---
plan_schema_version: "1.0"
issue: 2161
title: "Holistic label YAML fix — single approval signal chain"
dispatch:
  - phase: 1
    skill: implementation-pipeline
    task: green-phase
  - phase: 2
    skill: implementation-pipeline
    task: green-phase
  - phase: 3
    skill: implementation-pipeline
    task: green-phase
  - phase: 4
    skill: implementation-pipeline
    task: red-phase
  - phase: 5
    skill: implementation-pipeline
    task: red-phase
  - phase: 6
    skill: implementation-pipeline
    task: red-phase
---

# Implementation Plan — Issue 2161

## Pre-Implementation

- [ ] **Coherence gate.** Dispatch `audit --task coherence-extraction` to verify spec/plan coherence before any RED phase.
  - (**sub-agent**) — `task(..., prompt: "execute coherence-extraction from audit. Read `audit/tasks/coherence-extraction.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Baseline check.** Dispatch `pre-red-baseline` to verify clean working tree, trunk-tip currency, and submodule state before any file modification.
  - (**sub-agent**) — `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read `implementation-pipeline/tasks/pre-red-baseline.md` first")`
  - Context: `{issue_number: 2161}`

## Phase 1: Local label infrastructure (SC-1, SC-6)

### Item 1 (SC-1) — local-issues create auto-applies needs-approval label

- [ ] **red-phase.** Write a structural RED test: verify `needs-approval` is NOT currently auto-applied in `_create_issue_files()`.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-1}`
- [ ] **z3-check-red.** Solve check RED — validate RED step state transition.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED — confirm the RED test correctly detects absence of the feature.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-1}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck — validate doublecheck state transition.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate — confirm RED phase completed cleanly.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-1}`
- [ ] **z3-check-post-red.** Solve check post-RED — validate post-RED state transition.
  - (**inline**)
- [ ] **green-phase.** Modify `.opencode/tools/local-issues` `_create_issue_files()` to ensure `needs-approval` is always in the labels list.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-1}`
- [ ] **z3-check-green.** Solve check GREEN — validate GREEN step state transition.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate — confirm GREEN phase completed cleanly.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-1}`
- [ ] **z3-check-post-green.** Solve check post-GREEN — validate post-GREEN state transition.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 1 Item 1.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-1}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/tools/local-issues && git commit -m "feat: auto-apply needs-approval label on issue creation"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-1}`

### Item 2 (SC-6) — Remove ### Status field from record-authorization.md

- [ ] **red-phase.** Write a structural RED test: grep for `### Status` in `.opencode/skills/approval-gate-scope/tasks/verify-authorization/record-authorization.md`, confirm present.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-6}`
- [ ] **z3-check-red.** Solve check RED.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-6}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-6}`
- [ ] **z3-check-post-red.** Solve check post-RED.
  - (**inline**)
- [ ] **green-phase.** Remove `### Status` references from `record-authorization.md` (lines 13, 23, 37).
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-6}`
- [ ] **z3-check-green.** Solve check GREEN.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-6}`
- [ ] **z3-check-post-green.** Solve check post-GREEN.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 1 Item 2.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-6}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/skills/approval-gate-scope/tasks/verify-authorization/record-authorization.md && git commit -m "fix: remove ### Status field from record-authorization"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-6}`

## Phase 2: Authorization label writing and reading (SC-4, SC-5)

### Item 1 (SC-4) — record-authorization.md writes approved-for-{scope} locally before remote

- [ ] **red-phase.** Write a structural RED test: verify current `record-authorization.md` writes remote before local.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-4}`
- [ ] **z3-check-red.** Solve check RED.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-4}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-4}`
- [ ] **z3-check-post-red.** Solve check post-RED.
  - (**inline**)
- [ ] **green-phase.** Reorder `record-authorization.md` to write `approved-for-{scope}` to `issue.yaml` locally before any remote API call.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-4}`
- [ ] **z3-check-green.** Solve check GREEN.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-4}`
- [ ] **z3-check-post-green.** Solve check post-GREEN.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 2 Item 1.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-4}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/skills/approval-gate-scope/tasks/verify-authorization/record-authorization.md && git commit -m "fix: local-first label write in record-authorization"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-4}`

### Item 2 (SC-5) — Gap-fill cascade reads from issue.yaml labels

- [ ] **red-phase.** Write a structural RED test: grep for GitHub API label reads in gap-fill cascade files, confirm present.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-5}`
- [ ] **z3-check-red.** Solve check RED.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-5}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-5}`
- [ ] **z3-check-post-red.** Solve check post-RED.
  - (**inline**)
- [ ] **green-phase.** Modify gap-fill cascade files to read from `issue.yaml` labels via `local-issues read` or direct YAML read instead of GitHub API.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-5}`
- [ ] **z3-check-green.** Solve check GREEN.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-5}`
- [ ] **z3-check-post-green.** Solve check post-GREEN.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 2 Item 2.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-5}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/skills/approval-gate-scope/tasks/gap-fill-cascade/ && git commit -m "fix: gap-fill cascade reads from issue.yaml labels"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-5}`

## Phase 3: Critical violation for read-with-intent-to-modify (SC-7)

### Item 1 (SC-7) — New critical violation in 000-critical-rules.md

- [ ] **red-phase.** Write a structural RED test: grep `000-critical-rules.md` for existing critical violations, confirm the new one is absent.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-7}`
- [ ] **z3-check-red.** Solve check RED.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-7}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-7}`
- [ ] **z3-check-post-red.** Solve check post-RED.
  - (**inline**)
- [ ] **green-phase.** Add a new Tier 1 critical violation section to `000-critical-rules.md`: reading source files with intent to modify without `for_implementation`+ scope.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-7}`
- [ ] **z3-check-green.** Solve check GREEN.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-7}`
- [ ] **z3-check-post-green.** Solve check post-GREEN.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 3 Item 1.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-7}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "feat: add critical violation for read-with-intent-to-modify"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-7}`

## Phase 4: Behavioral test — needs-approval local verification (SC-2)

### Item 1 (SC-2) — Agent verifies needs-approval in local issue.yaml after creation

- [ ] **red-phase.** Write a behavioral RED test: send prompt to create issue, assert agent checks local `issue.yaml` for `needs-approval` label.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-2}`
- [ ] **z3-check-red.** Solve check RED.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-2}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-2}`
- [ ] **z3-check-post-red.** Solve check post-RED.
  - (**inline**)
- [ ] **green-phase.** Implement agent behavior to verify `needs-approval` in local `issue.yaml` after creation — if missing, remediate via `local-issues update --labels +needs-approval`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-2}`
- [ ] **z3-check-green.** Solve check GREEN.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-2}`
- [ ] **z3-check-post-green.** Solve check post-GREEN.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 4 Item 1.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-2}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/tests-v2/behaviors/ && git commit -m "test: behavioral test for needs-approval local verification"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-2}`

## Phase 5: Behavioral test — needs-approval remote verification (SC-3)

### Item 1 (SC-3) — Agent verifies needs-approval on remote issue after creation

- [ ] **red-phase.** Write a behavioral RED test: send prompt to create issue, assert agent checks remote issue for `needs-approval` label.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-3}`
- [ ] **z3-check-red.** Solve check RED.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-3}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-3}`
- [ ] **z3-check-post-red.** Solve check post-RED.
  - (**inline**)
- [ ] **green-phase.** Implement agent behavior to verify `needs-approval` on remote issue after creation — if missing, remediate via `github_issue_add_labels`.
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-3}`
- [ ] **z3-check-green.** Solve check GREEN.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-3}`
- [ ] **z3-check-post-green.** Solve check post-GREEN.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 5 Item 1.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-3}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/tests-v2/behaviors/ && git commit -m "test: behavioral test for needs-approval remote verification"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-3}`

## Phase 6: Behavioral test — issue.yaml labels for approval state (SC-8)

### Item 1 (SC-8) — Agent reads issue.yaml labels to determine approval state

- [ ] **red-phase.** Write a behavioral RED test: send prompt to check approval state, assert agent reads `issue.yaml` labels not body prose.
  - (**sub-agent**) — `task(..., prompt: "execute red from test-driven-development. Read `test-driven-development/tasks/red.md` first")`
  - Context: `{issue_number: 2161, sc: SC-8}`
- [ ] **z3-check-red.** Solve check RED.
  - (**inline**)
- [ ] **red-doublecheck.** Verify RED.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161, sc: SC-8}`
- [ ] **z3-check-red-doublecheck.** Solve check RED doublecheck.
  - (**inline**)
- [ ] **post-red-enforcement.** RED gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-red-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-8}`
- [ ] **z3-check-post-red.** Solve check post-RED.
  - (**inline**)
- [ ] **green-phase.** Implement agent behavior to read `issue.yaml` labels for approval state determination (not body prose).
  - (**sub-agent**) — `task(..., prompt: "execute green from test-driven-development. Read `test-driven-development/tasks/green.md` first")`
  - Context: `{issue_number: 2161, sc: SC-8}`
- [ ] **z3-check-green.** Solve check GREEN.
  - (**inline**)
- [ ] **post-green-enforcement.** GREEN gate.
  - (**sub-agent**) — `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read `implementation-pipeline/tasks/post-green-enforcement.md` first")`
  - Context: `{issue_number: 2161, sc: SC-8}`
- [ ] **z3-check-post-green.** Solve check post-GREEN.
  - (**inline**)
- [ ] **checkpoint-tag-create.** Create checkpoint tag for Phase 6 Item 1.
  - (**sub-agent**) — `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read `implementation-pipeline/tasks/checkpoint-tag-create.md` first")`
  - Context: `{issue_number: 2161, sc: SC-8}`
- [ ] **checkpoint-commit.** Commit the change: `git add .opencode/tests-v2/behaviors/ && git commit -m "test: behavioral test for issue.yaml label approval state"`.
  - (**sub-agent**) — `task(..., prompt: "execute commit-prep from git-workflow. Read `git-workflow/tasks/commit-prep.md` first")`
  - Context: `{issue_number: 2161, sc: SC-8}`

## Post-Implementation

- [ ] **Structural checks.** Run lint/typecheck/format on all modified files.
  - (**sub-agent**) — `task(..., prompt: "execute checklist from finishing-a-development-branch. Read `finishing-a-development-branch/tasks/checklist.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Green doublecheck.** Verify all GREEN phases — dispatch `verification-before-completion --task verify` to confirm all SCs are implemented.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Green VbC.** Run completion gate — `verification-before-completion --task completion` to produce SC verdicts.
  - (**sub-agent**) — `task(..., prompt: "execute completion from verification-before-completion. Read `verification-before-completion/tasks/completion.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **SC count gate.** Read `sc-summary.yaml` total SC count, count verified SCs from VbC evidence. BLOCK if `verified_count < total_count`.
  - (**sub-agent**) — `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read `implementation-pipeline/tasks/sc-count-gate.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Pre-PR gate.** Verify all SC verdicts — BLOCK if any FAIL.
  - (**sub-agent**) — `task(..., prompt: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Audit.** Dispatch adversarial audit to verify spec fidelity, plan coherence, and implementation correctness.
  - (**sub-agent**) — dispatch audit task via `task(subagent_type="general")` with `{spec_local_dir, artifact_evidence_dir}`
  - Context: `{issue_number: 2161}`
  - If non-clean-pass: remediate root cause, restart audit.
- [ ] **Cross-validate.** Dispatch clean-room cross-validation to produce consensus findings.
  - (**sub-agent**) — `task(..., prompt: "execute cross-validate from audit. Read `audit/tasks/cross-validate.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Regression check.** Run regression test patterns to verify no existing behavior is broken.
  - (**sub-agent**) — `task(..., prompt: "execute patterns from test-driven-development. Read `test-driven-development/tasks/patterns.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Review prep.** Prepare PR for review — generate reviewer context, verify branch readiness.
  - (**sub-agent**) — `task(..., prompt: "execute review-prep from git-workflow. Read `git-workflow/tasks/review-prep.md` first")`
  - Context: `{issue_number: 2161}`
- [ ] **Create PR.** Create pull request with the implementation.
  - (**sub-agent**) — `task(..., prompt: "execute create from pr-creation-workflow. Read `pr-creation-workflow/tasks/create.md` first")`
  - Context: `{issue_number: 2161, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **Completion.** Report executive summary with byline.
  - (**sub-agent**) — `task(..., prompt: "execute completion from completion-core. Read `completion-core/tasks/completion.md` first")`
  - Context: `{issue_number: 2161}`

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-26T22:52:00Z | `plan_created` | Plan file created at `.opencode/.issues/2161/plan.md` with 6 phases, 8 SCs |

## Exit Criteria

| SC | Phase | Verification Method | Evidence Type |
|----|-------|---------------------|---------------|
| SC-1 | 1 — Local label infrastructure | grep for needs-approval in _create_issue_files() | string |
| SC-6 | 1 — Local label infrastructure | grep for ### Status removal in record-authorization.md | string |
| SC-4 | 2 — Authorization label writing and reading | grep for local-first order in record-authorization.md | string |
| SC-5 | 2 — Authorization label writing and reading | grep for issue.yaml label reads in gap-fill cascade | string |
| SC-7 | 3 — Critical violation | grep for new violation in 000-critical-rules.md | string |
| SC-2 | 4 — Behavioral test: needs-approval local | behavioral test execution | behavioral |
| SC-3 | 5 — Behavioral test: needs-approval remote | behavioral test execution | behavioral |
| SC-8 | 6 — Behavioral test: issue.yaml labels | behavioral test execution | behavioral |
