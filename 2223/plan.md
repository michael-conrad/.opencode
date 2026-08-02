---
plan_schema_version: "1.0"
issue: 2223
title: "PR body template: standalone format, DiMo attestation, skill consolidation"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 6
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
| 1 — Extract PR body template, update attestation, update gates | `test-driven-development` | `red`, `green` | `pr-body-template.md`, `create-pr.md` | SC-1 through SC-12, SC-27, SC-28 | — |
| 2 — Delete pr-creation-workflow skill, preserve closing-keywords.md | `test-driven-development` | `red`, `green` | `pr-creation-workflow/`, `closing-keywords.md` | SC-13, SC-14, SC-15 | 1 |
| 3 — Add Workflows section to git-workflow-pr SKILL.md, fix description | `test-driven-development` | `red`, `green` | `git-workflow-pr/SKILL.md` | SC-16, SC-17, SC-18, SC-19 | 2 |
| 4 — Add pr-body-audit task to audit skill | `test-driven-development` | `red`, `green` | `audit/SKILL.md` | SC-20, SC-21 | 1 |
| 5 — Update stale dual-auditor terminology | `test-driven-development` | `red`, `green` | 5 files with "dual-auditor" | SC-22 through SC-26 | 1 |
| 6 — Update cross-references | `test-driven-development` | `red`, `green` | Codebase-wide cross-refs | SC-29, SC-30 | 2 |

---

## Phase Details

### Phase 1 — Extract PR Body Template, Update Attestation, Update Gates

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green` |
| Target | `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`, `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` |
| SCs | SC-1 through SC-12, SC-27, SC-28 |
| Depends On | — |

**Context:**
```yaml
template_path: ".opencode/skills/git-workflow-pr/reference/pr-body-template.md"
create_pr_path: ".opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md"
template_sections:
  - Summary
  - Outcome
  - Verification Attestation
  - "Detail: VbC Table"
  - "Detail: DiMo Chain Attestation"
  - "Detail: Spec-Card-Mapped Commits"
  - closing keywords (Fixes #N / Implements #N)
attestation_columns:
  - Criterion
  - Evidence Type
  - Investigator
  - Validator
  - Evaluator
  - Arbiter
attestation_line: "The Arbiter accepted all Evaluator verdicts as final — no synthesis corrections were needed or applied"
verification_attestation: "DiMo 4-role audit chain"
sc_ids: [SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-27, SC-28]
```

### Phase 2 — Delete pr-creation-workflow Skill, Preserve closing-keywords.md

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green` |
| Target | `.opencode/skills/pr-creation-workflow/`, `.opencode/skills/git-workflow-pr/reference/closing-keywords.md` |
| SCs | SC-13, SC-14, SC-15 |
| Depends On | 1 |

**Context:**
```yaml
delete_path: ".opencode/skills/pr-creation-workflow/"
move_source: ".opencode/skills/pr-creation-workflow/reference/closing-keywords.md"
move_target: ".opencode/skills/git-workflow-pr/reference/closing-keywords.md"
sc_ids: [SC-13, SC-14, SC-15]
```

### Phase 3 — Add Workflows Section to git-workflow-pr SKILL.md, Fix Description

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green` |
| Target | `.opencode/skills/git-workflow-pr/SKILL.md` |
| SCs | SC-16, SC-17, SC-18, SC-19 |
| Depends On | 2 |

**Context:**
```yaml
target_file: ".opencode/skills/git-workflow-pr/SKILL.md"
workflows:
  - "Create PR"
  - "Prepare review"
  - "Create pair mode PR"
  - "Post-implementation"
  - "Complete workflow"
auth_check: "orchestrator inline authorization scope check (no task() call)"
description_format: "agent-intent format — no 'Load via skill() when', 'Also load when', or 'User phrases:' patterns"
sc_ids: [SC-16, SC-17, SC-18, SC-19]
```

### Phase 4 — Add pr-body-audit Task to Audit Skill

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green` |
| Target | `.opencode/skills/audit/SKILL.md` |
| SCs | SC-20, SC-21 |
| Depends On | 1 |

**Context:**
```yaml
target_file: ".opencode/skills/audit/SKILL.md"
task_name: "pr-body-audit"
verification_items:
  - a: Summary section present
  - b: Outcome section present
  - c: Verification Attestation section present
  - d: VbC Table section present
  - e: DiMo Chain Attestation section present
  - f: Spec-Card-Mapped Commits section present
  - g: closing keywords present
  - h: DiMo Chain Attestation table uses correct columns
  - i: attestation line references DiMo 4-role chain
  - j: attestation line states no synthesis corrections
  - k: byline present in correct format
sc_ids: [SC-20, SC-21]
```

### Phase 5 — Update Stale Dual-Auditor Terminology

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green` |
| Target | 5 files with "dual-auditor" references |
| SCs | SC-22 through SC-26 |
| Depends On | 1 |

**Context:**
```yaml
files:
  - ".opencode/guidelines/000-critical-rules.md"
  - ".opencode/guidelines/250-dark-prose-reference.md"
  - ".opencode/guidelines/255-distribution-shifting-reference.md"
  - ".opencode/guidelines/257-procedural-discipline-reference.md"
  - ".opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md"
old_term: "dual-auditor"
new_term: "DiMo chain"
sc_ids: [SC-22, SC-23, SC-24, SC-25, SC-26]
```

### Phase 6 — Update Cross-References

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red`, `green` |
| Target | Codebase-wide cross-references to `pr-creation-workflow` |
| SCs | SC-29, SC-30 |
| Depends On | 2 |

**Context:**
```yaml
search_term: "pr-creation-workflow"
target_file: ".opencode/skills/git-workflow-pr/SKILL.md"
sc_ids: [SC-29, SC-30]
```

---

## Exit Criteria

- [ ] C1. Plan index written to `.opencode/.issues/2223/plan.md` with frontmatter, phase table, and phase details
- [ ] C2. Phase 1 file written to `.opencode/.issues/2223/plan-01-extract-template.md`
- [ ] C3. Phase 2 file written to `.opencode/.issues/2223/plan-02-delete-skill.md`
- [ ] C4. Phase 3 file written to `.opencode/.issues/2223/plan-03-workflows-section.md`
- [ ] C5. Phase 4 file written to `.opencode/.issues/2223/plan-04-pr-body-audit.md`
- [ ] C6. Phase 5 file written to `.opencode/.issues/2223/plan-05-terminology-update.md`
- [ ] C7. Phase 6 file written to `.opencode/.issues/2223/plan-06-cross-references.md`
- [ ] C8. All 30 SCs mapped to at least one phase
- [ ] C9. No circular dependencies in the phase DAG
- [ ] C10. Each item references exactly one SC-ID
- [ ] C11. `spec-cleared` label applied to issue #2223
