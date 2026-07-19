# Phase 1: Fix skill metadata and task files

**Issue:** #1962
**Spec:** `.opencode/.issues/1962/spec.md`
**Plan index:** `.opencode/.issues/1962/plan.md`
**Status:** DRAFT
**Created:** 2026-07-19

## Concern

Dispatch routing, contract paths, and skill card structure for `writing-plans` and `writing-plans-creation`.

## Entry Criteria

- [ ] Spec #1962 is approved (`approved-for-plan` label present)
- [ ] Feature branch exists (current: `feature/1962-writing-plans-workflow-fix`)
- [ ] All 7 analytical artifacts exist at `.opencode/.issues/1962/artifacts/`
- [ ] `local-issues sync` run before any file changes

## Steps

### Step 1: Update `writing-plans/SKILL.md`

**SC:** SC-1, SC-2, SC-7, SC-8
**Dispatch:** sub-agent
**Chain:** entry criteria

- [ ] 1.1 (**sub-agent**) Read current `writing-plans/SKILL.md`
- [ ] 1.2 (**sub-agent**) Replace TDT with exactly 4 entries:
  - `create` → `sub-task` → `{spec_issue_number, spec_body}`
  - `update` → `sub-task` → `{spec_issue_number, plan_issue_number}`
  - `retroactive` → `sub-task` → `{spec_issue_number, spec_body}`
  - `holistic-self-check` → `sub-task` → `{plan_context}`
- [ ] 1.3 (**sub-agent**) Add Pipeline section with 4 workflows (create, update, retroactive, holistic-self-check), each with step-level dispatch classification (`[inline]`, `[sub-task]`, `[clean-room]`)
- [ ] 1.4 (**sub-agent**) Update Invocation with 4 canonical dispatch strings per DISPATCH_GATE format
- [ ] 1.5 (**sub-agent**) Document `clean-room` as internal/referenced task (not a TDT entry)
- [ ] 1.6 (**inline**) Verify: `read` SKILL.md → TDT rows = 4, Pipeline section present with 4 workflows, Invocation has 4 canonical strings

### Step 2: Convert `writing-plans-creation/SKILL.md` to task card

**SC:** SC-3
**Dispatch:** sub-agent
**Chain:** step 1

- [ ] 2.1 (**sub-agent**) Read current `writing-plans-creation/SKILL.md`
- [ ] 2.2 (**sub-agent**) Remove YAML frontmatter (lines 1-6)
- [ ] 2.3 (**sub-agent**) Remove "# Skill: writing-plans-creation" header
- [ ] 2.4 (**sub-agent**) Remove Contracts section
- [ ] 2.5 (**sub-agent**) Keep plain task list only
- [ ] 2.6 (**inline**) Verify: `read` SKILL.md → no YAML frontmatter, no "Skill:" header, no TDT, no Invocation

### Step 3: Fix contract paths in `create.md`

**SC:** SC-4, SC-5
**Dispatch:** sub-agent
**Chain:** step 2

- [ ] 3.1 (**sub-agent**) Read current `writing-plans-creation/tasks/create.md`
- [ ] 3.2 (**sub-agent**) Find all 11 references to `writing-plans/contracts/` and replace with `writing-plans-creation/contracts/`
- [ ] 3.3 (**sub-agent**) Add plan-creation-pipeline dispatch step (step 12 in create workflow)
- [ ] 3.4 (**sub-agent**) Update chain refs for all subsequent steps
- [ ] 3.5 (**inline**) Verify: `grep "writing-plans/contracts" create.md` → zero matches; `bash` check each contract path exists

### Step 4: Fix contract paths in `update.md`

**SC:** SC-4
**Dispatch:** sub-agent
**Chain:** step 3

- [ ] 4.1 (**sub-agent**) Read current `writing-plans-creation/tasks/update.md`
- [ ] 4.2 (**sub-agent**) Find all references to `writing-plans/contracts/` and replace with `writing-plans-creation/contracts/`
- [ ] 4.3 (**inline**) Verify: `grep "writing-plans/contracts" update.md` → zero matches

### Step 5: Fix contract paths in `retroactive.md`

**SC:** SC-4
**Dispatch:** sub-agent
**Chain:** step 4

- [ ] 5.1 (**sub-agent**) Read current `writing-plans-creation/tasks/retroactive.md`
- [ ] 5.2 (**sub-agent**) Find all references to `writing-plans/contracts/` and replace with `writing-plans-creation/contracts/`
- [ ] 5.3 (**inline**) Verify: `grep "writing-plans/contracts" retroactive.md` → zero matches

### Step 6: Verify `pre-plan-readiness.md` has solve readiness gate

**SC:** SC-6
**Dispatch:** inline
**Chain:** step 5

- [ ] 6.1 (**inline**) Read `writing-plans-creation/tasks/pre-plan-readiness.md`
- [ ] 6.2 (**inline**) Confirm solve readiness gate is present (already done per commit eda50974)
- [ ] 6.3 (**inline**) If missing, add solve check step

### Step 7: Run `local-issues sync`

**SC:** SC-8
**Dispatch:** inline
**Chain:** step 6

- [ ] 7.1 (**inline**) Run `.opencode/tools/local-issues sync`
- [ ] 7.2 (**inline**) Verify no orphaned tasks: `ls tasks/` vs Pipeline task refs → diff empty

### Step 8: Run `solve check` on all affected contracts

**SC:** SC-4, SC-5, SC-7
**Dispatch:** inline
**Chain:** step 7

- [ ] 8.1 (**inline**) Run `.opencode/tools/solve check` on each affected contract in `writing-plans-creation/contracts/`
- [ ] 8.2 (**inline**) Verify all checks pass

## RED/GREEN Chains

| Step | RED | GREEN |
|------|-----|-------|
| 1 | Current TDT has wrong entries | TDT has exactly 4 entries, Pipeline section present |
| 2 | SKILL.md has YAML frontmatter + "Skill:" header | Plain task list, no YAML, no "Skill:" |
| 3 | `create.md` references `writing-plans/contracts/` | All paths point to `writing-plans-creation/contracts/` |
| 4 | `update.md` references `writing-plans/contracts/` | All paths point to `writing-plans-creation/contracts/` |
| 5 | `retroactive.md` references `writing-plans/contracts/` | All paths point to `writing-plans-creation/contracts/` |

## Z3 Checks

| Step | Check | Contract |
|------|-------|----------|
| 1 | TDT entries = 4 | `writing-plans-creation/contracts/tdt-format.yaml` |
| 3 | Contract paths resolve | `writing-plans-creation/contracts/create-output-template.yaml` |
| 8 | All contracts valid | `writing-plans-creation/contracts/*.yaml` |

## VbC Blocks

| SC | Verification | Evidence |
|----|-------------|----------|
| SC-1 | `read` SKILL.md → count TDT rows = 4 | File content |
| SC-2 | `read` SKILL.md → Pipeline section with 4 workflows | File content |
| SC-3 | `read` SKILL.md → no YAML frontmatter, no "Skill:" header | File content |
| SC-4 | `grep` for `writing-plans/contracts/` → zero matches in 3 files | grep output |
| SC-5 | `opencode run` → verify skill dispatch in stderr | stderr log |
| SC-6 | `read` pre-plan-readiness.md → find solve check | File content |
| SC-7 | `read` Invocation sections → verify DISPATCH_GATE format | File content |
| SC-8 | `ls tasks/` vs Pipeline refs → diff empty | Directory listing |

## Phase Completion

- [ ] All 8 SCs verified PASS
- [ ] `local-issues sync` run
- [ ] Changes committed to feature branch
- [ ] Plan index updated with completion status
