---
plan_schema_version: "1.0"
issue: 2207
title: "Remediate incomplete 000-critical-rules.md compaction — delete remaining moved rules, fix drift from later specs"
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
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: green
  - phase: 2
    skill: verification-before-completion
    task: verify
  - phase: 3
    skill: test-driven-development
    task: red
  - phase: 3
    skill: verification-before-completion
    task: verify
---

# Plan: Remediate incomplete 000-critical-rules.md compaction

## Pre-Implementation

- [ ] **Coherence gate.** Dispatch `audit --task coherence-maintenance` to verify spec/plan coherence before any RED routing.
  - (**clean-room**)
  - `task(..., prompt: "execute coherence-maintenance from audit. Read \`audit/tasks/coherence-maintenance.md\` first")`
  - Context: issue_number=2207, spec_path=.opencode/.issues/2207/spec.md, plan_path=.opencode/.issues/2207/plan.md
  - SC binding: all SCs

- [ ] **Baseline check.** Verify the current state of `.opencode/guidelines/000-critical-rules.md` matches the spec's background claims (41 rule headers, 22 excess rules, 0 orphaned rules, 1 unclassified 073).
  - (**clean-room**)
  - `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md
  - SC binding: SC-1, SC-2

## Phase 1: Delete 22 excess rule blocks (SC-1)

**Concern:** Remove the 22 rule blocks that were moved to target files by #2121 Phase 1 but never deleted from the source file by #2121 Phase 3.

**SC coverage:** SC-1

### Item 1 — Delete 22 excess rule blocks from `.opencode/guidelines/000-critical-rules.md`

- [ ] **RED phase.** Write a behavioral enforcement test that verifies the agent deletes the 22 excess rule blocks. The test MUST fail initially because the deletions haven't been made yet.
  - (**clean-room**)
  - `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, excess_rules=22 rows from spec Excess Rules table
  - SC binding: SC-1

- [ ] **GREEN phase.** Delete each of the 22 excess rule blocks from `.opencode/guidelines/000-critical-rules.md`. For each block, remove the full `### [critical-rules-*]` header and all body content between it and the next rule header or section boundary. The 22 blocks are:
  - Rows 1-21: rules targeting `.opencode/guidelines/020-go-prohibitions.md`
  - Row 22: `[critical-rules-066] Terminology Standardization` targeting `.opencode/guidelines/080-code-standards.md`
  - (**clean-room**)
  - `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, operation=delete_rule_blocks, block_count=22
  - SC binding: SC-1

- [ ] **Verify phase.** Run verification that each of the 22 excess rule headers is absent from the file.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, sc_id=SC-1, evidence_type=string, verification_command=`grep -qF "<full header text>" .opencode/guidelines/000-critical-rules.md` for each of 22 headers
  - SC binding: SC-1

- [ ] **Commit phase.** Stage and commit the changes to `.opencode/guidelines/000-critical-rules.md`.
  - (**inline**)
  - Orchestrator runs: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 1: Delete 22 excess rule blocks from 000-critical-rules.md"`
  - SC binding: SC-1

## Phase 2: Classify critical-rules-073 (SC-2)

**Concern:** Read the body of `critical-rules-073` and determine whether it is universal (applies to ALL agents at ALL times) or skill-specific.

**SC coverage:** SC-2

### Item 2 — Classify critical-rules-073

- [ ] **RED phase.** Write a behavioral enforcement test that verifies the agent classifies `critical-rules-073`. The test MUST fail initially because the classification hasn't been made yet.
  - (**clean-room**)
  - `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, rule=critical-rules-073
  - SC binding: SC-2

- [ ] **GREEN phase.** Read the body of `critical-rules-073` in `.opencode/guidelines/000-critical-rules.md` and classify it:
  - If **universal** (applies to ALL agents at ALL times): keep in source file, ensure it has Tier 1 classification. The header count target becomes 19 (18 universal + 1 classified 073).
  - If **skill-specific**: delete from source file and embed in the appropriate target file.
  - (**clean-room**)
  - `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, rule=critical-rules-073, classification_options=[universal, skill-specific]
  - SC binding: SC-2

- [ ] **Verify phase.** Run verification that `critical-rules-073` is correctly classified per the classification decision.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, sc_id=SC-2, evidence_type=semantic
  - SC binding: SC-2

- [ ] **Commit phase.** Stage and commit the changes.
  - (**inline**)
  - Orchestrator runs: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 2: Classify critical-rules-073"`
  - SC binding: SC-2

## Phase 3: Verify all SCs (SC-3 through SC-7)

**Concern:** Run all verification checks against the modified file to confirm the final state meets all success criteria.

**SC coverage:** SC-3, SC-4, SC-5, SC-6, SC-7

### Item 3 — Verify header count = 19 (SC-3)

- [ ] **RED phase.** Write a test that expects `grep -cE "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md` to return 19. The test MUST fail initially because the count is still 41 (or whatever the current count is after Phase 1 and Phase 2).
  - (**clean-room**)
  - `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, expected_count=19, sc_id=SC-3
  - SC binding: SC-3

- [ ] **GREEN phase.** No code change — verification-only phase.
  - (**inline**)
  - Orchestrator confirms no file modification is needed.
  - SC binding: SC-3

- [ ] **Verify phase.** Run `grep -cE "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md` and confirm the result is 19.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, sc_id=SC-3, evidence_type=string, verification_command=`grep -cE "^### \[critical-rules-" .opencode/guidelines/000-critical-rules.md`, expected=19
  - SC binding: SC-3

- [ ] **Commit phase.** Stage and commit any changes (if the verification test file was created).
  - (**inline**)
  - Orchestrator runs: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 3: Verify SC-3 header count"`
  - SC binding: SC-3

### Item 4 — Verify 0 Read[] cross-refs to guidelines/ (SC-4)

- [ ] **RED phase.** Write a test that expects `grep -cE "Read \[.*guidelines/" .opencode/guidelines/000-critical-rules.md` to return 0. The test MUST fail initially.
  - (**clean-room**)
  - `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, expected_count=0, sc_id=SC-4
  - SC binding: SC-4

- [ ] **GREEN phase.** No code change — verification-only phase.
  - (**inline**)
  - Orchestrator confirms no file modification is needed.
  - SC binding: SC-4

- [ ] **Verify phase.** Run `grep -cE "Read \[.*guidelines/" .opencode/guidelines/000-critical-rules.md` and confirm the result is 0.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, sc_id=SC-4, evidence_type=string, verification_command=`grep -cE "Read \[.*guidelines/" .opencode/guidelines/000-critical-rules.md`, expected=0
  - SC binding: SC-4

- [ ] **Commit phase.** Stage and commit any changes.
  - (**inline**)
  - Orchestrator runs: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 3: Verify SC-4 Read[] cross-refs"`
  - SC binding: SC-4

### Item 5 — Verify 0 Why This Matters tables (SC-5)

- [ ] **RED phase.** Write a test that expects `grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md` to return 0. The test MUST fail initially.
  - (**clean-room**)
  - `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, expected_count=0, sc_id=SC-5
  - SC binding: SC-5

- [ ] **GREEN phase.** No code change — verification-only phase.
  - (**inline**)
  - Orchestrator confirms no file modification is needed.
  - SC binding: SC-5

- [ ] **Verify phase.** Run `grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md` and confirm the result is 0.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, sc_id=SC-5, evidence_type=string, verification_command=`grep -cE "Why This Matters" .opencode/guidelines/000-critical-rules.md`, expected=0
  - SC binding: SC-5

- [ ] **Commit phase.** Stage and commit any changes.
  - (**inline**)
  - Orchestrator runs: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 3: Verify SC-5 Why This Matters"`
  - SC binding: SC-5

### Item 6 — Verify <3 dark prose instances (SC-6)

- [ ] **RED phase.** Write a test that expects `grep -cE "Professional engineers|amateurs" .opencode/guidelines/000-critical-rules.md` to return < 3. The test MUST fail initially.
  - (**clean-room**)
  - `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, expected_max=2, sc_id=SC-6
  - SC binding: SC-6

- [ ] **GREEN phase.** No code change — verification-only phase.
  - (**inline**)
  - Orchestrator confirms no file modification is needed.
  - SC binding: SC-6

- [ ] **Verify phase.** Run `grep -cE "Professional engineers|amateurs" .opencode/guidelines/000-critical-rules.md` and confirm the result is < 3.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, sc_id=SC-6, evidence_type=string, verification_command=`grep -cE "Professional engineers|amateurs" .opencode/guidelines/000-critical-rules.md`, expected_max=2
  - SC binding: SC-6

- [ ] **Commit phase.** Stage and commit any changes.
  - (**inline**)
  - Orchestrator runs: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 3: Verify SC-6 dark prose count"`
  - SC binding: SC-6

### Item 7 — Verify 0 refs to deleted skill dirs (SC-7)

- [ ] **RED phase.** Write a test that expects `grep -cE "executing-plans|implementation-pipeline" .opencode/guidelines/000-critical-rules.md` to return 0. The test MUST fail initially.
  - (**clean-room**)
  - `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, expected_count=0, sc_id=SC-7
  - SC binding: SC-7

- [ ] **GREEN phase.** No code change — verification-only phase.
  - (**inline**)
  - Orchestrator confirms no file modification is needed.
  - SC binding: SC-7

- [ ] **Verify phase.** Run `grep -cE "executing-plans|implementation-pipeline" .opencode/guidelines/000-critical-rules.md` and confirm the result is 0.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: target_file=.opencode/guidelines/000-critical-rules.md, sc_id=SC-7, evidence_type=string, verification_command=`grep -cE "executing-plans|implementation-pipeline" .opencode/guidelines/000-critical-rules.md`, expected=0
  - SC binding: SC-7

- [ ] **Commit phase.** Stage and commit any changes.
  - (**inline**)
  - Orchestrator runs: `git add .opencode/guidelines/000-critical-rules.md && git commit -m "Phase 3: Verify SC-7 deleted skill dir refs"`
  - SC binding: SC-7

## Post-Implementation

- [ ] **Structural checks.** Run the finishing-a-development-branch checklist to verify branch readiness.
  - (**clean-room**)
  - `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: branch=<feature-branch>, target_file=.opencode/guidelines/000-critical-rules.md
  - SC binding: all SCs

- [ ] **Pre-PR gate.** Run verification-before-completion to read all SC verdicts and BLOCK if any FAIL.
  - (**clean-room**)
  - `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: issue_number=2207, scs=[SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7]
  - SC binding: all SCs

- [ ] **Review prep.** Prepare PR body with compare URL and executive summary.
  - (**clean-room**)
  - `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - Context: issue_number=2207, target_file=.opencode/guidelines/000-critical-rules.md
  - SC binding: all SCs

- [ ] **Create PR.** Create the pull request.
  - (**clean-room**)
  - `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
  - Context: issue_number=2207, target_file=.opencode/guidelines/000-critical-rules.md
  - SC binding: all SCs

- [ ] **Executive summary.** Report completion with structured summary.
  - (**clean-room**)
  - `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
  - Context: issue_number=2207, phases_completed=[1, 2, 3]
  - SC binding: all SCs

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-31T15:08:00Z | plan_created | Plan file at `.opencode/.issues/2207/plan.md`, 3 phases, 7 SCs |
