# Phase 3: validate.md + revise.md + completion.md

**Skill:** `writing-plans`
**Task:** `create`
**Target:** `writing-plans/tasks/{validate,revise,completion}.md`
**SCs:** SC-6, SC-10, SC-11
**Depends On:** Phase 2

## Context

- validate.md: structural checks (Goal, Architecture, Phase Table, Phase Details), skill+task validity against pipeline TDT, SC coverage, concern separation, DAG validation, 11-dimension holistic quality
- revise.md: reads validation findings or revision reason, revises plan structure, updates dependency contract
- completion.md: verifies plan files exist, appends lifecycle event, reports plan_path and execution strategy
- Revise loop: validate → FAIL → revise → solve → validate (max 3 iterations)

## Entry Criteria

- [ ] Phase 2 complete (analyze, retroactive, create, solve implemented)
- [ ] Plan artifact exists for testing validation

## Procedure

1. Implement validate.md with all 6 check categories
2. Implement revise.md with plan revision and dependency contract update
3. Implement completion.md with lifecycle event and execution strategy
4. Verify revise loop cycles correctly (max 3 iterations)

## Exit Criteria

- [ ] validate.md returns FAIL for invalid skill+task references
- [ ] validate.md returns FAIL for missing SC coverage
- [ ] validate.md returns FAIL for circular dependencies
- [ ] revise.md updates plan and dependency contract
- [ ] completion.md reports artifact_path and execution strategy
- [ ] Revise loop: max 3 iterations before escalation
