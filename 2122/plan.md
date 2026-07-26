---
plan_schema_version: "1.0"
issue: 2122
title: Compact 010-approval-gate.md by moving 6 skill-specific sections to respective skill cards
dispatch:
  - phase: 1
    skill: test-driven-development
    task: green
  - phase: 1
    skill: git-workflow
    task: commit-prep
  - phase: 1
    skill: verification-before-completion
    task: verify
  - phase: 2
    skill: test-driven-development
    task: green
  - phase: 2
    skill: git-workflow
    task: commit-prep
  - phase: 2
    skill: verification-before-completion
    task: verify
  - phase: 3
    skill: test-driven-development
    task: green
  - phase: 3
    skill: git-workflow
    task: commit-prep
  - phase: 3
    skill: verification-before-completion
    task: verify
  - phase: 4
    skill: test-driven-development
    task: green
  - phase: 4
    skill: git-workflow
    task: commit-prep
  - phase: 4
    skill: verification-before-completion
    task: verify
  - phase: 5
    skill: verification-before-completion
    task: verify
  - phase: 5
    skill: implementation-pipeline
    task: sc-count-gate
  - phase: 5
    skill: verification-before-completion
    task: verify
lifecycle_events:
  - timestamp: 2026-07-26T09:15:00Z
    event: plan_created
    plan_path: .opencode/.issues/2122/plan.md
    phase_count: 5
---

# Implementation Plan: Compact 010-approval-gate.md

Move 6 skill-specific sections from `010-approval-gate.md` to their respective skill cards.
No content rewriting — moved sections retain original wording.

---

## Pre-Implementation Steps

- [ ] **SC-coherence gate** — dispatch audit to verify spec/plan coherence before any implementation
  - (**sub-agent**) `audit --task coherence-extraction`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - SC binding: SC-10 (no line-count metrics)

- [ ] **Pre-RED baseline** — verify trunk tip, create feature branch, verify clean working tree
  - (**sub-agent**) `implementation-pipeline --task pre-red-baseline`
  - Context: `{issue_number: 2122, project_root, authorization_scope: for_pr, halt_at: pr_created}`
  - Dispatch: `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - SC binding: SC-7 (keep sections remain)

---

## Phase 1: Move Spec-to-Plan Cascade, Re-implementation, Label Handling to approval-gate

**Concern:** Move 3 approval-gate-specific sections from 010-approval-gate.md to approval-gate/SKILL.md.
**SC coverage:** SC-1, SC-2, SC-3

### Content to move (from 010-approval-gate.md lines 50-65)

The `### Spec-to-Plan Approval Cascade (Critical)` section including all body text, sub-heading `#### Edge Cases`, and the Edge Cases table.

### Content to move (from 010-approval-gate.md lines 162-169)

The `### Re-implementation Workflow` section including all 4 numbered steps.

### Content to move (from 010-approval-gate.md lines 171-176)

The `### Label Handling` section including all 4 bullet points.

### Target insertion point (approval-gate/SKILL.md)

Append after the existing Cross-References section (after line 93), under new section headings matching the original structure.

### Steps

- [ ] **GREEN phase** — move content from 010-approval-gate.md to approval-gate/SKILL.md
  - (**sub-agent**) `test-driven-development --task green`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - SC binding: SC-1 (Spec-to-Plan Cascade in approval-gate/SKILL.md)

- [ ] **GREEN phase** — move Re-implementation Workflow section
  - (**sub-agent**) `test-driven-development --task green`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - SC binding: SC-2 (Re-implementation Workflow in approval-gate/SKILL.md)

- [ ] **GREEN phase** — move Label Handling section
  - (**sub-agent**) `test-driven-development --task green`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - SC binding: SC-3 (Label Handling in approval-gate/SKILL.md)

- [ ] **Checkpoint commit** — commit the content moves as an atomic change
  - (**sub-agent**) `git-workflow --task commit-prep`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

- [ ] **GREEN doublecheck** — verify SC-1, SC-2, SC-3 content exists in target
  - (**sub-agent**) `verification-before-completion --task verify`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Assert: grep for Spec-to-Plan Cascade content in approval-gate/SKILL.md
  - SC binding: SC-1

- [ ] **GREEN doublecheck** — verify Re-implementation Workflow exists in approval-gate/SKILL.md
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep for Re-implementation Workflow content
  - SC binding: SC-2

- [ ] **GREEN doublecheck** — verify Label Handling exists in approval-gate/SKILL.md
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep for Label Handling content
  - SC binding: SC-3

---

## Phase 2: Move Audit Auto-Fix Exemption to audit

**Concern:** Move audit-specific section from 010-approval-gate.md to audit/SKILL.md.
**SC coverage:** SC-4

### Content to move (from 010-approval-gate.md lines 187-189)

The `### Audit Auto-Fix Exemption` section including both sentences.

### Target insertion point (audit/SKILL.md)

Append after the existing Accountability/Remediation Ownership Model section (after line 163), under a new `### Audit Auto-Fix Exemption` heading.

### Steps

- [ ] **GREEN phase** — move Audit Auto-Fix Exemption section
  - (**sub-agent**) `test-driven-development --task green`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - SC binding: SC-4 (Audit Auto-Fix in audit/SKILL.md)

- [ ] **Checkpoint commit** — commit the content move
  - (**sub-agent**) `git-workflow --task commit-prep`
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

- [ ] **GREEN doublecheck** — verify SC-4 content exists in target
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep for Audit Auto-Fix Exemption content in audit/SKILL.md
  - SC binding: SC-4

---

## Phase 3: Move Bug Report Response to issue-operations

**Concern:** Move bug-to-spec workflow section from 010-approval-gate.md to issue-operations/SKILL.md.
**SC coverage:** SC-5

### Content to move (from 010-approval-gate.md lines 178-185)

The `### Bug Report Response` section including the preamble and all 4 numbered steps.

### Target insertion point (issue-operations/SKILL.md)

Append after the last line of the Cross-References section (after line 193), under a new `### Bug Report Response` heading.

### Steps

- [ ] **GREEN phase** — move Bug Report Response section
  - (**sub-agent**) `test-driven-development --task green`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - SC binding: SC-5 (Bug Report Response in issue-operations/SKILL.md)

- [ ] **Checkpoint commit** — commit the content move
  - (**sub-agent**) `git-workflow --task commit-prep`
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

- [ ] **GREEN doublecheck** — verify SC-5 content exists in target
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep for Bug Report Response content in issue-operations/SKILL.md
  - SC binding: SC-5

---

## Phase 4: Move Bug Discovery Protocol to approval-gate

**Concern:** Move authorization-boundary section from 010-approval-gate.md to approval-gate/SKILL.md.
**SC coverage:** SC-6

### Content to move (from 010-approval-gate.md lines 191-197)

The `### Bug Discovery Protocol (CRITICAL)` section including the preamble and all 3 numbered steps.

### Cross-reference update (XR-2)

In the moved Bug Discovery Protocol text (line 195), change `(see Bug Report Response above)` to `(see Bug Report Response in issue-operations/SKILL.md)` since Bug Report Response now lives in the issue-operations skill card.

### Target insertion point (approval-gate/SKILL.md)

Append after the Phase 1 content (Spec-to-Plan Cascade, Re-implementation Workflow, Label Handling), under a new `### Bug Discovery Protocol (CRITICAL)` heading.

### Steps

- [ ] **GREEN phase** — move Bug Discovery Protocol section (with XR-2 cross-reference update)
  - (**sub-agent**) `test-driven-development --task green`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - SC binding: SC-6 (Bug Discovery Protocol in approval-gate/SKILL.md)
  - Additionally: update the internal reference `(see Bug Report Response above)` to `(see Bug Report Response in issue-operations/SKILL.md)` (covered by SC-8.c)

- [ ] **Checkpoint commit** — commit the content move
  - (**sub-agent**) `git-workflow --task commit-prep`
  - Dispatch: `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

- [ ] **GREEN doublecheck** — verify SC-6 content exists in target
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep for Bug Discovery Protocol content in approval-gate/SKILL.md
  - SC binding: SC-6

---

## Phase 5: Verification

**Concern:** Run all verification checks — keep sections, content loss, orphaned refs, size metrics.
**SC coverage:** SC-7, SC-8, SC-9, SC-10

### Steps

- [ ] **GREEN doublecheck** — verify all 13 keep sections remain in 010-approval-gate.md
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep each of the 13 keep section headers: "Tier 0: Zero Tolerance Rules", "Mandatory Requirements", "Issue Creation Is Reporting", "Decision Table", "Explicit Authorization Priority", "Authorization Scope", "Authorization Scope Model", "Scope Is Permission", "Multi-Task Plan Authorization", "Authorization Carry-Forward", "Revision Revokes Approval", "Action Authorization Classification", "for_analysis Allowlist and Blocklist", "Key Edge Cases"
  - SC binding: SC-7

- [ ] **GREEN doublecheck** — no content loss behavioral comparison
  - (**sub-agent**) `verification-before-completion --task verify`
  - Dispatch: clean-room sub-agent reads each moved section from original 010-approval-gate.md location (pre-move snapshot or git diff) and compares against target card content. Checks: (a) every bullet point present verbatim, (b) no text truncated, (c) all internal cross-references updated to target card paths
  - SC binding: SC-8

- [ ] **GREEN doublecheck** — no orphaned cross-references to moved sections
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep for "Spec-to-Plan Approval Cascade", "Re-implementation Workflow", "Label Handling", "Audit Auto-Fix Exemption", "Bug Report Response", "Bug Discovery Protocol" across `.opencode/` — only target cards and 010-approval-gate.md remain
  - SC binding: SC-9

- [ ] **GREEN doublecheck** — verify no size metrics used as success measurement
  - (**sub-agent**) `verification-before-completion --task verify`
  - Assert: grep spec.md for absence of 'wc -l', 'file size', 'Final file size', 'line count', 'word count' as success measurement
  - SC binding: SC-10

- [ ] **Cross-reference update (XR-1)** — update 140-planning-spec-creation.md line 29
  - (**sub-agent**) `test-driven-development --task green`
  - Update `[§"Re-implementation Workflow"](010-approval-gate.md)` to `[§"Re-implementation Workflow"](approval-gate/SKILL.md)`
  - SC binding: SC-9 (no orphaned cross-references)

- [ ] **SC count gate** — verify all 10 SCs have a PASS verdict
  - (**sub-agent**) `implementation-pipeline --task sc-count-gate`
  - Reads SC summary, counts verified SCs from VbC evidence
  - Block if `verified_count < 10`
  - Dispatch: `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`

- [ ] **Pre-PR gate** — block if any SC is FAIL
  - (**sub-agent**) `verification-before-completion --task verify`
  - Reads all SC verdicts, blocks if any FAIL
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

---

## Post-Implementation Steps

- [ ] **Structural checks** — run lint and typecheck on modified files
  - (**sub-agent**) `finishing-a-development-branch --task checklist`
  - Context: `{issue_number: 2122, project_root}`
  - Dispatch: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`

- [ ] **Audit** — dispatch verification-audit to verify all SCs are properly implemented
  - (**sub-agent**) `audit --task verification-audit`
  - Context: `{issue_number: 2122, project_root, issues_prefix: .opencode/.issues}`
  - Dispatch: DiMo chain — 4 sequential task() calls (investigator, validator, evaluator, arbiter)

- [ ] **Cross-validate** — arbiter reads upstream artifacts, produces final judgment
  - (**sub-agent**) `audit --task cross-validate`
  - Dispatch: `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`

- [ ] **Review prep** — prepare branch for review
  - (**sub-agent**) `git-workflow --task review-prep`
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`

- [ ] **Create PR** — create pull request with the compiled changes
  - (**sub-agent**) `pr-creation-workflow --task create`
  - Context: `{issue_number: 2122, authorization_scope: for_pr, halt_at: pr_created}`
  - Dispatch: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`

- [ ] **Completion** — emit lifecycle event, produce executive summary
  - (**sub-agent**) `completion-core --task completion`
  - Dispatch: `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
