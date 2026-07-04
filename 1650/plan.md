# Implementation Plan — [#1650](https://github.com/michael-conrad/.opencode/issues/1650) — Replace `/skill` References with `skill()` Syntax

## Goal

Replace all 58 `/skill` references across `.opencode/` with proper `skill({name: "..."})` and `task()` invocation syntax, eliminating the non-existent `/skill` CLI command pattern.

## Architecture

Two phases: (1) find-and-replace all 58 `/skill` references across 8 file categories, (2) post-phase with behavioral test, global verification, and review prep. Phase 1 is a single RED/GREEN chain with intermediate grep checkpoints for SC-1 through SC-4. Phase 2 writes the behavioral test (SC-6), re-verifies zero remaining references (SC-5), and prepares the PR.

## Files

- `.opencode/skills/*/SKILL.md` (31 files + 1 template = 32 CLI lines)
- `.opencode/skills/*/tasks/*.md` (7 `--task` examples + 1 non-`--task` in squash-push.md)
- `.opencode/skills/*/tasks/**/*.md` (7 additional locations in TDD, changelog, sre-runbook)
- `.opencode/skills/brainstorming/tasks/enforcement.md` (1 prose mention)
- `.opencode/.guidelines/README.md` (3 references)
- `.opencode/README.md` (3 references)
- `.opencode/dispatch-table.yaml` (2 references)
- `.opencode/.issues/1372/spec.md` (2 references)
- `.opencode/tests/behaviors/skill-invocation-syntax.sh` (new behavioral test)

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed exactly as specified. No step may be skipped, reordered, or combined. If a step cannot be completed, the plan is BLOCKED and must be reported as such. The plan is not a suggestion — it is the implementation specification.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the output before proceeding. Do not batch steps. Do not skip verification. Each step depends on the previous step's verified output.

> **Step Status:** Before each step, check the step's checkbox status. If `[x]`, the step is complete — skip it. If `[ ]`, execute it. After execution, mark `[x]` and proceed to the next step.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range |
|-------|------|---------|-----|--------------|------------|
| 1 | Find-and-replace `/skill` → `skill()` | Replace all 58 `/skill` references with `skill()` syntax | SC-1, SC-2, SC-3, SC-4, SC-5 | Research complete | 1-8 |
| 2 | Behavioral test + verification + review prep | Write behavioral test, global grep, finishing checklist, PR | SC-6, SC-1–SC-5 (re-verify) | Phase 1 | 9-14 |

> **Compliance requirement:** This plan is a binding contract. Every step MUST be executed exactly as specified. No step may be skipped, reordered, or combined. If a step cannot be completed, the plan is BLOCKED and must be reported as such. The plan is not a suggestion — it is the implementation specification.

> **Self-remediation protocol:** If a step fails (verification mismatch, audit finding, test failure), the agent MUST self-remediate: diagnose the root cause, fix the defect, re-verify, and continue. Do NOT halt on the first failure — remediate first. Only halt if remediation fails twice consecutively.

## Exit Criteria

- [ ] C1. All 32 SKILL.md "CLI equivalent" lines use `skill({name: "..."})` instead of `/skill`
- [ ] C2. All 7 task file examples with `--task` use `skill()` + `task()` patterns instead of `/skill`
- [ ] C3. The 1 task file example without `--task` (squash-push.md) uses `skill()` instead of `/skill`
- [ ] C4. The 1 prose mention in brainstorming/tasks/enforcement.md uses `skill()` instead of `/skill`
- [ ] C5. Zero `/skill` references remain in `.opencode/` (all 58 locations resolved)
- [ ] C6. Behavioral test verifies agent uses `skill()` syntax, not `/skill`, when describing skill invocation
