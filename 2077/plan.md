# Implementation Plan — [#2077](.opencode#2077) — Replace spec-creation skill with flat architecture

**Goal:** Replace the current spec-creation skill (dispatcher with 5 sub-skills, 32 task files across 6 directories) with a single flat skill card that dispatches directly to 4 task cards. No sub-skill indirection.

**Architecture:** Single SKILL.md + tasks/ directory with 4 task files (analyze.md, create.md, validate.md, revise.md). Three clean-room categories: ANALYSIS (analyze), PRODUCTION (create, revise), VERIFICATION (validate). Orchestrator sequences via Workflows section.

**Files:**
- `.opencode/skills/spec-creation/SKILL.md` — New flat skill card
- `.opencode/skills/spec-creation/tasks/analyze.md` — ANALYSIS task
- `.opencode/skills/spec-creation/tasks/create.md` — PRODUCTION task
- `.opencode/skills/spec-creation/tasks/validate.md` — VERIFICATION task
- `.opencode/skills/spec-creation/tasks/revise.md` — PRODUCTION (revision) task
- `.opencode/skills/brainstorming/tasks/completion.md` — Update handoff signal
- 5 sub-skill directories to remove (Phase 3)

**Dispatch:** orchestrator

## Blast Radius

- `.opencode/skills/spec-creation/` — Entire directory restructured
- `.opencode/skills/spec-creation-validation/` — Removed
- `.opencode/skills/spec-creation-decomposition/` — Removed
- `.opencode/skills/spec-creation-requirements/` — Removed
- `.opencode/skills/spec-creation-change-control/` — Removed
- `.opencode/skills/spec-creation-operating-protocol/` — Removed
- `.opencode/skills/brainstorming/tasks/completion.md` — Updated handoff
- `<available_skills>` in system prompt — 5 fewer entries

## Concern Map Reference

| Concern | Phase |
|---------|-------|
| New flat skill architecture | Phase 1 |
| Brainstorming handoff | Phase 2 |
| Cleanup old sub-skills | Phase 3 |
| End-to-end verification | Phase 4 |

## Admonishment

> **COMPLIANCE REQUIREMENT:** This plan MUST be followed step-by-step. No step may be skipped, reordered, or combined. Each step is a mandatory gate. The orchestrator dispatches each step to a clean-room sub-agent via `task()` — no inline work. Verification is MANDATORY after every implementation step. FAIL at any gate halts the pipeline.

## One-step-at-a-time protocol admonishment

> **ONE STEP AT A TIME:** Execute exactly one step. Then stop. Report the result. Wait for the next instruction. Do NOT proceed to the next step automatically. Do NOT batch steps. Do NOT combine steps. One step, one result, one report — then stop.

## Step Status instruction

> **STEP STATUS:** After each step, report the step number and status (PASS/FAIL/BLOCKED). If PASS, the orchestrator proceeds to the next step. If FAIL, remediate and re-run. If BLOCKED, report the blocker and halt.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Create new spec-creation skill | New flat skill architecture | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-13, SC-14, SC-15, SC-16 | None | 1-5 | orchestrator |
| 2 | Update brainstorming handoff | Brainstorming handoff | SC-12 | Phase 1 | 6 | orchestrator |
| 3 | Remove old sub-skill directories | Cleanup old sub-skills | SC-10, SC-11 | Phase 1, Phase 2 | 7 | orchestrator |
| 4 | Verify end-to-end | End-to-end verification | SC-9, SC-13, SC-14, SC-15 | Phase 3 | 8 | orchestrator |

## Bottom admonishment

> **COMPLIANCE REQUIREMENT:** This plan MUST be followed step-by-step. No step may be skipped, reordered, or combined. Each step is a mandatory gate. The orchestrator dispatches each step to a clean-room sub-agent via `task()` — no inline work. Verification is MANDATORY after every implementation step. FAIL at any gate halts the pipeline.

## Self-remediation protocol admonishment

> **SELF-REMEDIATION PROTOCOL:** When a step FAILs, the orchestrator MUST attempt remediation before halting. Read [000-critical-rules.md §Hard Failure Discipline](guidelines/000-critical-rules.md). Remediation means: diagnose root cause, fix the defect, re-run verification. Only after 2+ remediation attempts may the orchestrator HALT with escalation.

## Exit Criteria

- [ ] C1: `skills/spec-creation/` contains exactly one SKILL.md and a `tasks/` directory with exactly 4 task files
- [ ] C2: SKILL.md Workflows section dispatches directly to task cards (no "from spec-creation-validation" or other sub-skill names)
- [ ] C3: SKILL.md description uses agent-intent format (no "Load via skill() when" or "User phrases:")
- [ ] C4: analyze.md contains analysis pipeline only (no spec writing, remote issue ops, or holistic check)
- [ ] C5: create.md contains production pipeline only (no analysis or verification steps)
- [ ] C6: validate.md contains verification pipeline only (no production or analysis steps)
- [ ] C7: revise.md exists and handles spec revision with change control tracking
- [ ] C8: No task file contains task() or skill() calls
- [ ] C9: create task writes spec to correct `.issues/{N}/` or `<sub-repo>/.issues/{N}/` path
- [ ] C10: 5 sub-skill directories removed
- [ ] C11: 32 task files consolidated into exactly 4 task files
- [ ] C12: brainstorming completion task returns handoff signal to spec-creation
- [ ] C13: analyze sub-agent receives only {issue_number, project_root}
- [ ] C14: create sub-agent receives only {issue_number, analysis_artifact_path}
- [ ] C15: validate sub-agent receives only {issue_number, spec_path}
- [ ] C16: Workflows section sequences analyze → create → validate → (revise → validate)* → done
