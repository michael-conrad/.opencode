---
plan_schema_version: "1.0"
issue: 2223
title: "PR body template: standalone format, DiMo attestation, skill consolidation"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 8
---

# Implementation Plan — #2223 — PR Body Template: Standalone Format, DiMo Attestation, Skill Consolidation

**Issue:** https://github.com/michael-conrad/.opencode/issues/2223

**Goal:** Extract the PR body template to a standalone reference file, replace stale dual-auditor attestation with DiMo 4-role chain, eliminate the ceremony `pr-creation-workflow` skill, and add a PR body audit task to the audit skill.

**Architecture:** The PR body template is extracted from the `github_create_pull_request()` call in `create-pr.md` to a standalone reference file at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`. Both platform sections (GitHub MCP, GitBucket CLI) reference the same standalone template. The `pr-creation-workflow` skill directory is deleted; its authorization check is folded into `git-workflow-pr`'s Workflows section as an orchestrator inline step. The `git-workflow-pr` SKILL.md replaces its Trigger Dispatch Table with a Workflows section containing 5 separate workflows. A `pr-body-audit` task is added to the audit skill. Stale "dual-auditor" terminology is replaced with "DiMo chain" across 5 files. All cross-references to `pr-creation-workflow` are updated or removed.

**Files:**
- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`
- `.opencode/skills/git-workflow-pr/reference/pr-body-template.md` (new)
- `.opencode/skills/git-workflow-pr/reference/closing-keywords.md` (moved)
- `.opencode/skills/git-workflow-pr/SKILL.md`
- `.opencode/skills/pr-creation-workflow/` (deleted)
- `.opencode/skills/audit/SKILL.md`
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/guidelines/250-dark-prose-reference.md`
- `.opencode/guidelines/255-distribution-shifting-reference.md`
- `.opencode/guidelines/257-procedural-discipline-reference.md`
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Extract PR body template to standalone file | `test-driven-development` | `red`, `green` | `pr-body-template.md`, `create-pr.md` | SC-1, SC-12 | — |
| 2 — Update attestation to DiMo 4-role chain | `test-driven-development` | `red`, `green` | `pr-body-template.md` | SC-2 through SC-11 | 1 |
| 3 — Update verification-evidence-check gate and Data Flow table | `test-driven-development` | `red`, `green` | `create-pr.md` | SC-27, SC-28 | 1 |
| 4 — Delete pr-creation-workflow skill, preserve closing-keywords.md | `test-driven-development` | `red`, `green` | `pr-creation-workflow/`, `closing-keywords.md` | SC-13, SC-14, SC-15 | 2 |
| 5 — Add Workflows section to git-workflow-pr SKILL.md, fix description | `test-driven-development` | `red`, `green` | `git-workflow-pr/SKILL.md` | SC-16, SC-17, SC-18, SC-19 | 4 |
| 6 — Add pr-body-audit task to audit skill | `test-driven-development` | `red`, `green` | `audit/SKILL.md` | SC-20, SC-21 | 1 |
| 7 — Update stale dual-auditor terminology | `test-driven-development` | `red`, `green` | 5 files with "dual-auditor" | SC-22 through SC-26 | 2 |
| 8 — Update cross-references | `test-driven-development` | `red`, `green` | Codebase-wide cross-refs | SC-29, SC-30 | 4 |

---

## Phase Details

### Phase 1 — Extract PR Body Template to Standalone File

- [ ] 1. Create `.opencode/skills/git-workflow-pr/reference/` directory if it does not exist.
- [ ] 2. Extract the PR body template from `github_create_pull_request()` call in `create-pr.md` to standalone file at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`.
- [ ] 3. Replace the inline template in `create-pr.md` with a reference to the standalone file (e.g., `Read [pr-body-template.md](reference/pr-body-template.md)`).
- [ ] 4. Verify both platform sections (GitHub MCP, GitBucket CLI) in `create-pr.md` reference the same standalone template file.
- [ ] 5. Verify SC-1 (file exists) and SC-12 (both sections reference same template).

### Phase 2 — Update Attestation to DiMo 4-Role Chain

- [ ] 1. Open `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`.
- [ ] 2. Replace "Dual-Auditor Cross-Validation" section header with "DiMo Chain Attestation".
- [ ] 3. Replace attestation table columns from "Auditor 1 / Auditor 2" to "Criterion, Evidence Type, Investigator, Validator, Evaluator, Arbiter".
- [ ] 4. Replace Verification Attestation line to reference "DiMo 4-role audit chain" instead of "Dual independent auditors".
- [ ] 5. Add attestation line: "The Arbiter accepted all Evaluator verdicts as final — no synthesis corrections were needed or applied".
- [ ] 6. Verify SC-2 through SC-11 pass.

### Phase 3 — Update Verification-Evidence-Check Gate and Data Flow Table

- [ ] 1. Open `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md`.
- [ ] 2. Update verification-evidence-check gate to reference `judgment.yaml` with `overall_verdict: PASS` instead of `audit-cross-validate-*.json`.
- [ ] 3. Update Data Flow table to reference "DiMo Chain Attestation → `judgment.yaml`" instead of "Dual-Auditor Cross-Validation → `audit-cross-validate-*.json`".
- [ ] 4. Verify SC-27 and SC-28 pass.

### Phase 4 — Delete pr-creation-workflow Skill, Preserve closing-keywords.md

- [ ] 1. Copy `.opencode/skills/pr-creation-workflow/reference/closing-keywords.md` to `.opencode/skills/git-workflow-pr/reference/closing-keywords.md`.
- [ ] 2. Verify the copied file matches the source content.
- [ ] 3. Delete `.opencode/skills/pr-creation-workflow/` directory (SKILL.md + all task files).
- [ ] 4. Verify SC-13 (directory deleted) and SC-14 (closing-keywords.md preserved at target).
- [ ] 5. Add authorization scope check as orchestrator inline Step 1 in `git-workflow-pr` Workflows section (SC-15).

### Phase 5 — Add Workflows Section to git-workflow-pr SKILL.md, Fix Description

- [ ] 1. Open `.opencode/skills/git-workflow-pr/SKILL.md`.
- [ ] 2. Replace `## Trigger Dispatch Table` and `## DISPATCH_GATE` sections with `## Workflows` section.
- [ ] 3. Add 5 workflow entries: "Create PR", "Prepare review", "Create pair mode PR", "Post-implementation", "Complete workflow".
- [ ] 4. Each workflow starts with orchestrator inline authorization scope check (no `task()` call).
- [ ] 5. Update description field to use agent-intent format — no "Load via skill() when", "Also load when", or "User phrases:" patterns.
- [ ] 6. Remove cross-reference to `pr-creation-workflow` from SKILL.md.
- [ ] 7. Verify SC-16, SC-17, SC-18, SC-19 pass.

### Phase 6 — Add pr-body-audit Task to Audit Skill

- [ ] 1. Open `.opencode/skills/audit/SKILL.md`.
- [ ] 2. Add `pr-body-audit` task entry to the Trigger Dispatch Table.
- [ ] 3. Create task file at `.opencode/skills/audit/tasks/pr-body-audit.md` that verifies all 11 enumerated PR body requirements:
  - [ ] a. Summary section present
  - [ ] b. Outcome section present
  - [ ] c. Verification Attestation section present
  - [ ] d. VbC Table section present
  - [ ] e. DiMo Chain Attestation section present
  - [ ] f. Spec-Card-Mapped Commits section present
  - [ ] g. Closing keywords present
  - [ ] h. DiMo Chain Attestation table uses correct columns
  - [ ] i. Attestation line references DiMo 4-role chain
  - [ ] j. Attestation line states no synthesis corrections
  - [ ] k. Byline present in correct format
- [ ] 4. Verify SC-20 and SC-21 pass.

### Phase 7 — Update Stale Dual-Auditor Terminology

- [ ] 1. Open `.opencode/guidelines/000-critical-rules.md` and replace "dual-auditor" with "DiMo chain".
- [ ] 2. Open `.opencode/guidelines/250-dark-prose-reference.md` and replace both "dual-auditor" occurrences with "DiMo chain".
- [ ] 3. Open `.opencode/guidelines/255-distribution-shifting-reference.md` and replace "dual-auditor" with "DiMo chain".
- [ ] 4. Open `.opencode/guidelines/257-procedural-discipline-reference.md` and replace "dual-auditor" with "DiMo chain".
- [ ] 5. Open `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` and replace "dual-auditor" with "DiMo chain".
- [ ] 6. Verify SC-22 through SC-26 pass (grep for "dual-auditor" returns zero in each file).

### Phase 8 — Update Cross-References

- [ ] 1. Grep codebase for `pr-creation-workflow` to find all cross-references.
- [ ] 2. For each match, update the reference or remove it.
- [ ] 3. Verify SC-29 (grep for `pr-creation-workflow` returns zero results codebase-wide).
- [ ] 4. Verify SC-30 (grep for `pr-creation-workflow` in `git-workflow-pr/SKILL.md` returns zero).

---

## Lifecycle Events

- `2026-08-02T04:30:00Z` — `plan_created` — Plan created with 8 phases, all using `test-driven-development` clean-room dispatch. Authorization scope: `for_pr`, PR strategy: `stacked`.

## Exit Criteria

- [ ] C1. Plan index written to `.opencode/.issues/2223/plan.md` with frontmatter, phase table, and phase details
- [ ] C2. Phase 1 file written to `.opencode/.issues/2223/plan-01-extract-template.md`
- [ ] C3. Phase 2 file written to `.opencode/.issues/2223/plan-02-attestation-update.md`
- [ ] C4. Phase 3 file written to `.opencode/.issues/2223/plan-03-gate-updates.md`
- [ ] C5. Phase 4 file written to `.opencode/.issues/2223/plan-04-delete-skill.md`
- [ ] C6. Phase 5 file written to `.opencode/.issues/2223/plan-05-workflows-section.md`
- [ ] C7. Phase 6 file written to `.opencode/.issues/2223/plan-06-pr-body-audit.md`
- [ ] C8. Phase 7 file written to `.opencode/.issues/2223/plan-07-terminology-update.md`
- [ ] C9. Phase 8 file written to `.opencode/.issues/2223/plan-08-cross-references.md`
- [ ] C10. All 30 SCs mapped to at least one phase
- [ ] C11. No circular dependencies in the phase DAG
- [ ] C12. Each item references exactly one SC-ID
- [ ] C13. `spec-cleared` label applied to issue #2223
