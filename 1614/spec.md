<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

```yaml
---
id: .opencode#1614
title: "[SPEC] Split plan files: plan.md (index) + plan-{O}.md (phase files)"
status: draft
created: 2026-06-30
author: michael-conrad
---
```

# [SPEC] Split plan files: plan.md (index) + plan-{O}.md (phase files)

## Problem

The writing-plans skill produces a single monolithic `plan.md` file containing all phases. For multi-phase plans (e.g., #1602 with 7 phases, 149 steps, 510 lines), this is unwieldy. Additionally, the completion and validate tasks incorrectly check the GitHub API (`github_issue_read(method=get_sub_issues)`) for plan sub-issues instead of checking local files — plans are local artifacts, never remote tickets.

## Scope

### In Scope

- New plan file convention: `{N}/plan.md` (index) + `{N}/plan-{O}.md` (one per phase, globally numbered)
- Update writing-plans write task to produce split format
- Update writing-plans completion/validate tasks to check local files instead of GitHub API
- Update all cross-referencing skills (implementation-pipeline, adversarial-audit, plan-creation-pipeline)
- Update guideline 140-planning-spec-creation.md

### Out of Scope

- Changes to the spec-creation pipeline
- Changes to the approval-gate or issue-operations skills
- Changes to the plan tool (unified-planning/PDDL)

## Affected Files

| # | File | Change |
|---|------|--------|
| 1 | `.opencode/skills/writing-plans/SKILL.md` | §Plan Model: phases are separate `plan-{O}.md` files |
| 2 | `.opencode/skills/writing-plans/tasks/create.md` | Exit criteria, plan path references |
| 3 | `.opencode/skills/writing-plans/tasks/write.md` | Produce `plan.md` index + N `plan-{O}.md` phase files |
| 4 | `.opencode/skills/writing-plans/tasks/completion.md` | Check local `plan-{O}.md` files instead of GitHub API sub-issues |
| 5 | `.opencode/skills/writing-plans/tasks/validate.md` | Step 9: replace `github_issue_read(method=get_sub_issues)` with local file glob |
| 6 | `.opencode/skills/writing-plans/tasks/update.md` | Plan path references |
| 7 | `.opencode/skills/writing-plans/tasks/revisit.md` | Plan path references |
| 8 | `.opencode/skills/writing-plans/tasks/audit-fidelity.md` | Plan path references |
| 9 | `.opencode/skills/writing-plans/tasks/audit-concern.md` | Plan path references |
| 10 | `.opencode/skills/writing-plans/tasks/clean-room.md` | Plan path references |
| 11 | `.opencode/skills/implementation-pipeline/tasks/pre-red-baseline.md` | Read `plan.md` for phase table, then `plan-{O}.md` for current phase |
| 12 | `.opencode/skills/implementation-pipeline/tasks/assemble-work.md` | Plan path references |
| 13 | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` | Plan path references |
| 14 | `.opencode/skills/adversarial-audit/tasks/plan-fidelity.md` | Read `plan.md` index + all `plan-{O}.md` for full audit |
| 15 | `.opencode/skills/plan-creation-pipeline/SKILL.md` | Plan artifact path references |
| 16 | `.opencode/guidelines/140-planning-spec-creation.md` | Plan file path references |

## Plan File Convention

### `{N}/plan.md` — Index (required)

- Goal, architecture, file list
- Phase table: each phase with name, concern, SCs, dependencies, step range (e.g., "Phase 2 — Farmage: steps 71-88")
- Exit criteria (C1-C{N})
- All admonishments (compliance, one-step-at-a-time, step status, self-remediation)
- Self-review evidence section

### `{N}/plan-{O}.md` — Phase file (one per phase)

- `{O}` is zero-padded phase number with short slug (e.g., `plan-01-frontmatter.md`, `plan-02-farmage.md`)
- Phase metadata (concern, files, SCs, dependencies, entry/exit conditions)
- Full step-by-step with global sequential numbering
- Dispatch indicators, RED/GREEN chains, Z3 checks, VbC blocks
- Phase completion block
- Concern transition to next phase

### Numbering Rules

- Steps are globally sequential across all phase files
- Phase 2's first step is 71 (not 1), last step is 88
- Phase 4's first step is 89 (not 1)
- No ambiguity about what follows what

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | writing-plans write task produces `plan.md` index + N `plan-{O}.md` phase files | behavioral | Create a multi-phase plan, verify `plan.md` exists with phase table, verify `plan-01-*.md` through `plan-0N-*.md` exist with globally sequential steps |
| SC-2 | writing-plans completion task checks local `plan-{O}.md` files instead of GitHub API | behavioral | Run completion on a multi-phase plan with all phase files present → PASS; with a missing phase file → BLOCKED |
| SC-3 | writing-plans validate task step 9 checks local files instead of GitHub API | string | `grep 'github_issue_read.*get_sub_issues'` on validate.md returns zero matches |
| SC-4 | All 16 affected files updated to reference `plan.md` + `plan-{O}.md` convention | structural | `grep -c 'plan-[0-9]'` on each affected file returns expected count |
| SC-5 | implementation-pipeline pre-red-baseline reads `plan.md` for phase table then `plan-{O}.md` for current phase | behavioral | Dispatch pre-red-baseline on a split-format plan, verify it loads the correct phase file |
| SC-6 | adversarial-audit plan-fidelity reads `plan.md` index + all `plan-{O}.md` for full audit | behavioral | Dispatch plan-fidelity on a split-format plan, verify all phase files are audited |
| SC-7 | guideline 140-planning-spec-creation.md references updated | string | `grep 'plan-[0-9]'` on 140-planning-spec-creation.md returns matches |

## Constraints

| Constraint | Value |
|------------|-------|
| File scope | `.opencode/skills/` task files + `.opencode/guidelines/140-*.md` only |
| Step numbering | Global sequential across all phase files — never per-phase restart |
| Phase file naming | `plan-{NN}-{short-slug}.md` where NN is zero-padded phase number |
| PR strategy | stacked |

## Decision Ledger

| DEC-ID | Decision | Rationale |
|--------|----------|-----------|
| DEC-1 | `plan.md` is index only, no implementation steps | Keeps the overview readable; steps live in phase files |
| DEC-2 | Global sequential numbering across phase files | No ambiguity about current step or next step |
| DEC-3 | Phase file naming: `plan-{NN}-{slug}.md` | Sortable by phase number, readable by slug |
| DEC-4 | Completion/validate check local files, not GitHub API | Plans are local artifacts — remote sub-issue tickets are never created for plan phases |

## AI Agent Instructions

1. Read all comments on this issue before implementing
2. Create feature branch before any file modification
3. Implement per-item TDD cycle: RED → GREEN → REFACTOR → COMMIT
4. Each phase file gets its own commit
5. Update all cross-referencing skills in parallel where possible
6. Run behavioral enforcement tests for SC-1, SC-2, SC-5, SC-6
7. Run string/structural checks for SC-3, SC-4, SC-7
8. Verify all 16 affected files are updated before claiming completion

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
