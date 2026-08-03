> GitHub Issue: https://github.com/michael-conrad/.opencode/issues/2239

# [SPEC] Remove redundant check-pr task, fix cleanup processing order

## Problem Statement

The `git-workflow-cleanup` skill has a redundant `check-pr.md` task file that duplicates logic already present in `cleanup.md`. The `check-pr` task was created as a separate entry point for "check pr" trigger phrases, but `cleanup.md` already contains all the same logic (PR scan, verify-merge, issue-closure, branch-cleanup). This creates confusion about which task to dispatch and increases maintenance surface area.

Additionally, `cleanup.md` processes the parent repo before submodules in Step 3 (branch-cleanup) and Step 4 (post-cleanup dev-tip verification). The correct order is submodules first, then parent — because submodule cleanup is a prerequisite for parent repo state verification.

## Success Criteria

| ID | Description | Evidence Type | Documentation Sources |
|----|-------------|---------------|----------------------|
| SC-1 | `check-pr.md` SHALL be deleted from `.opencode/skills/git-workflow-cleanup/tasks/` | structural | `pre-spec-inspection.yaml` |
| SC-2 | `git-workflow-cleanup/SKILL.md` SHALL have no `check-pr` references in its TDT or Tasks table | structural | `pre-spec-inspection.yaml` |
| SC-3a | `git-workflow/SKILL.md` SHALL have no `check-pr` references in its TDT, Invocation section, or Sub-Skills table | structural | `pre-spec-inspection.yaml` |
| SC-3b | `git-workflow/SKILL.md` SHALL list the `git-workflow-cleanup` task count as 3 | structural | `pre-spec-inspection.yaml` |
| SC-5 | `cleanup.md` SHALL have no `check-pr` references in its "Related tasks" or "Automatic Cleanup Detection" sections | structural | `pre-spec-inspection.yaml` |
| SC-6 | `cleanup.md` Step 3 SHALL specify submodule-first iteration order for branch-cleanup | structural | `cleanup.md` current state |
| SC-7 | `cleanup.md` Step 4 SHALL list submodules before parent in the repo verification list | structural | `cleanup.md` current state |
| SC-8 | Dispatching "check pr" via `opencode run` SHALL route to `git-workflow-cleanup --task cleanup` (not `check-pr`) | behavioral | `git-workflow/SKILL.md` TDT |

### Cost-Frame Statements

- **SC-1 through SC-3b (remove check-pr):** A redundant task file with its own TDT entry and dispatch string is a maintenance trap. Every future agent that encounters "check pr" in the TDT must decide between two tasks that do the same thing — and every wrong decision is a defect. Removing the duplicate eliminates the decision branch entirely.
- **SC-6 through SC-7 (fix processing order):** Processing parent before submodules means the parent repo's state verification runs against stale submodule state. The parent's `git status` and branch state depend on submodule state — verifying parent first produces false positives. Submodules-first is the only correct dependency order.
- **SC-8 (behavioral backward compatibility):** A structural change that breaks agent dispatch is not a complete change. The behavioral test proves that "check pr" trigger phrases still work — they just route to the correct task now.

## Approach

### Phase 1: Remove check-pr.md and update references

1. Delete `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
2. Update `git-workflow-cleanup/SKILL.md`:
   - Remove `check-pr` row from TDT
   - Remove `check-pr` row from Tasks table
3. Update `git-workflow/SKILL.md`:
   - Remove `check-pr` row from TDT (row 7)
   - Remove `check-pr` row from Invocation section (row 7)
   - Update Sub-Skills table: `git-workflow-cleanup` task count from 4 to 3
4. Update `cleanup.md`:
   - Remove "Related tasks" reference to check-pr
   - Remove "Check PR" Workflow subsection from "Automatic Cleanup Detection"
   - Remove "check pr" / "check prs" from "Entry triggers" (these phrases are handled by git-workflow/SKILL.md TDT routing to cleanup)

### Phase 2: Fix cleanup processing order

1. Update `cleanup.md` Step 3 (branch-cleanup): Change iteration order to process submodules before parent
2. Update `cleanup.md` Step 4 (post-cleanup dev-tip verification): Change repo list to list submodules before parent

## Affected Files

| File | Change Type | Phase |
|------|-------------|-------|
| `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md` | DELETE | 1 |
| `.opencode/skills/git-workflow-cleanup/SKILL.md` | MODIFY (TDT, Tasks table) | 1 |
| `.opencode/skills/git-workflow/SKILL.md` | MODIFY (TDT, Invocation, Sub-Skills) | 1 |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | MODIFY (remove check-pr refs) | 1 |
| `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` | MODIFY (Step 3, Step 4 order) | 2 |

## Dependencies

- Phase 1 and Phase 2 are independent — either can be implemented first
- Within Phase 1: SC-1 (delete file) must precede SC-2/SC-3a/SC-3b/SC-5 (update references)
- SC-8 (behavioral verification) must be last

## Open Questions

None.

## Out of Scope

- Changes to `pair-cleanup` task — not affected by this spec
- Changes to `git-workflow-cleanup` task file count in any other location
- Any changes outside the `.opencode` submodule

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-03 | Split SC-3 into SC-3a (no check-pr references) and SC-3b (task count = 3). Re-numbered SC-4→SC-5, SC-5→SC-6, SC-6→SC-7, SC-7→SC-8. Updated Cost-Frame Statements and Dependencies to match. | SC-3 was compound — bundled two independently verifiable claims. | Pipeline (spec-creation revise task) |
