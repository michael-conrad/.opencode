# Phase 1: Flat SKILL.md + task file stubs + contracts

**Skill:** `writing-plans`
**Task:** `create`
**Target:** `writing-plans/` (new flat structure)
**SCs:** SC-1, SC-2, SC-3, SC-17
**Depends On:** (none)

## Context

- Write new `writing-plans/SKILL.md` with Workflows section per #2076 format
- Workflows: create (analyze→create→solve→validate→(revise→solve→validate)*→completion), retroactive (retroactive→create→solve→validate→(revise→solve→validate)*→completion), revise (revise→solve→validate→completion)
- 7 task file stubs: analyze.md, retroactive.md, create.md, solve.md, validate.md, revise.md, completion.md
- Each stub: Purpose, Entry Criteria, Procedure, Exit Criteria, Result Contract
- 14 contract templates (7 input/output pairs) at `writing-plans/contracts/`
- `reference/plan-artifact-format.md` as living canonical specification
- Old files remain — structural only

## Entry Criteria

- [ ] writing-plans/ directory exists
- [ ] Old writing-plans/SKILL.md exists (will be replaced)

## Procedure

1. Write new `writing-plans/SKILL.md` with Workflows section
2. Write 7 task file stubs
3. Write 14 contract templates
4. Write `reference/plan-artifact-format.md`
5. Verify file structure matches spec

## Exit Criteria

- [ ] `writing-plans/SKILL.md` exists with Workflows section
- [ ] 7 task files exist at `writing-plans/tasks/`
- [ ] 14 contract templates exist at `writing-plans/contracts/`
- [ ] `writing-plans/reference/plan-artifact-format.md` exists
- [ ] Old files still present (not yet removed)
