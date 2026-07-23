# Implementation Plan: Replace writing-plans skill with flat architecture

> **Goal:** Replace the 3-SKILL.md, 19-task-file writing-plans architecture with a flat 1-SKILL.md, 7-task-file architecture using routing-table plan artifacts.
> **Architecture:** Single SKILL.md with Workflows section per #2076 format. 7 task files (analyze, retroactive, create, solve, validate, revise, completion) with 14 contract templates. Plan artifacts use skill+task references instead of hardcoded implementation steps. External callers updated to new dispatch strings. Old sub-skill directories removed.

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|---|---|---|---|---|---|
| 1 | writing-plans | create | writing-plans/ (new flat structure) | SC-1, SC-2, SC-3, SC-17 | — |
| 2 | writing-plans | create | writing-plans/tasks/{analyze,retroactive,create,solve}.md | SC-5, SC-7, SC-8, SC-9 | Phase 1 |
| 3 | writing-plans | create | writing-plans/tasks/{validate,revise,completion}.md | SC-6, SC-10, SC-11 | Phase 2 |
| 4 | writing-plans | revise | External caller files (9 files) | SC-14 | Phase 3 |
| 5 | writing-plans | revise | writing-plans-creation/, writing-plans-holistic/ | SC-15 | Phase 4 |
| 6 | test-driven-development | red-green-cycle | .opencode/tests-v2/behaviors/ | SC-4, SC-16 | Phase 5 |

## Phase Details

### Phase 1: Flat SKILL.md + task file stubs + contracts

**Skill:** `writing-plans`
**Task:** `create`
**Target:** `writing-plans/` (new flat structure)
**SCs:** SC-1, SC-2, SC-3, SC-17
**Depends On:** (none)

**Context:**
- Write new `writing-plans/SKILL.md` with Workflows section per #2076 format (create, revise, retroactive workflows)
- Write 7 task file stubs: analyze.md, retroactive.md, create.md, solve.md, validate.md, revise.md, completion.md
- Each stub has: Purpose, Entry Criteria, Procedure, Exit Criteria, Result Contract
- Write 14 contract templates (7 input/output pairs) to `writing-plans/contracts/`
- Write `reference/plan-artifact-format.md` as the living canonical specification
- Old files still present — this phase is structural only
- Issues prefix: `.opencode/.issues`

### Phase 2: analyze.md + retroactive.md + create.md + solve.md

**Skill:** `writing-plans`
**Task:** `create`
**Target:** `writing-plans/tasks/{analyze,retroactive,create,solve}.md`
**SCs:** SC-5, SC-7, SC-8, SC-9
**Depends On:** Phase 1

**Context:**
- Implement analyze.md: strict entry gate — verifies spec.md exists (BLOCKED with SPEC_NOT_FOUND), checks YAML frontmatter for approval marker, validates 7 analytical artifacts exist, checks scope boundaries
- Implement retroactive.md: lenient entry gate — backfills missing artifacts from spec body + codebase inspection
- Implement create.md: reads analysis summary, discovers implementation-pipeline SKILL.md TDT for valid skill+task targets, decomposes SCs into phases, builds dependency DAG, writes plan.md and dependency-contract.yaml
- Implement solve.md: reads dependency contract, runs tools/solve (SAT/UNSAT), runs tools/plan (SOLVED/UNSOLVABLE), writes solve-output.yaml
- Issues prefix: `.opencode/.issues`

### Phase 3: validate.md + revise.md + completion.md

**Skill:** `writing-plans`
**Task:** `create`
**Target:** `writing-plans/tasks/{validate,revise,completion}.md`
**SCs:** SC-6, SC-10, SC-11
**Depends On:** Phase 2

**Context:**
- Implement validate.md: structural checks (required fields), skill+task validity against pipeline TDT, SC coverage, concern separation, DAG validation, 11-dimension holistic quality
- Implement revise.md: reads validation findings or revision reason, revises plan structure, updates dependency contract
- Implement completion.md: verifies plan files exist, appends lifecycle event, reports plan_path and execution strategy
- Revise loop: validate → FAIL → revise → solve → validate (max 3 iterations)
- Issues prefix: `.opencode/.issues`

### Phase 4: External caller migration

**Skill:** `writing-plans`
**Task:** `revise`
**Target:** 9 caller files across approval-gate-scope, brainstorming, issue-operations-comments, plan-creation-pipeline, reference, guidelines
**SCs:** SC-14
**Depends On:** Phase 3

**Context:**
- Update 9 caller files with new dispatch strings per spec table
- Old pattern: `writing-plans --task create` → New pattern: `task("execute create from writing-plans")`
- Old pattern: `writing-plans --task update` → New pattern: `task("execute revise from writing-plans")`
- Files: approval-gate-scope/enforcement/auto-dispatch-table.md, approval-gate-scope/tasks/verify-authorization/auto-dispatch.md, approval-gate-scope/tasks/verify-authorization/spec-to-plan-cascade.md, approval-gate-scope/tasks/verify-plan-pipeline.md, brainstorming/tasks/completion.md, issue-operations-comments/tasks/comment.md, plan-creation-pipeline/SKILL.md, reference/holistic-dimensions.yaml, guidelines/010-approval-gate.md
- Verify: grep for old dispatch patterns returns zero matches in caller files

### Phase 5: Remove old sub-skill directories

**Skill:** `writing-plans`
**Task:** `revise`
**Target:** `writing-plans-creation/`, `writing-plans-holistic/`
**SCs:** SC-15
**Depends On:** Phase 4

**Context:**
- Delete `writing-plans-creation/` directory (18 task files, 22 contracts, handoffs/)
- Delete `writing-plans-holistic/` directory (1 task file)
- Verify no broken references remain
- Issues prefix: `.opencode/.issues`

### Phase 6: Behavioral tests

**Skill:** `test-driven-development`
**Task:** `red-green-cycle`
**Target:** `.opencode/tests-v2/behaviors/`
**SCs:** SC-4, SC-16
**Depends On:** Phase 5

**Context:**
- Replace existing `dispatch-boundary-writing-plans.sh` with new flat pipeline tests
- Remove tests for removed functionality (clean-room, handoffs, etc.)
- Add behavioral tests for: create workflow produces routing-table plan, revise loop (max 3 iterations), spec-not-found blocks with SPEC_NOT_FOUND, skill+task validation returns FAIL on invalid reference, retroactive backfill, plan artifact format compliance (SC-4)
- Old tests must FAIL, new tests must PASS
- Use `with-test-home` wrapper for all opencode run calls
