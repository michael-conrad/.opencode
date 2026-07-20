## Problem

The `spec-creation` SKILL.md has two structural defects that cause dispatch failures:

### Defect A: Dead `diagram` task entry

Commit `75995c64` (feat #163, mermaid workflow diagrams) added `diagram` to the Trigger Dispatch Table, Tasks table, and Invocation table — but never created `tasks/diagram.md`. The task file has never existed in any commit. The diagram-generation rules (check dependencies → generate mermaid → insert at prescribed location → scan for workflow state markers) are already embedded in the `write` task's procedure. The `diagram` entry is a dead dispatch target that routes to nothing.

### Defect B: `change-control` missing from Invocation table and Operating Protocol

`change-control` is one of the 6 original tasks from the initial spec-creation commit (`4ec894fc`, feat #629). It has a valid task file on disk (`tasks/change-control.md`, 94 lines) and is listed in the Trigger Dispatch Table and Tasks table. However, it is missing from:

- The **Invocation table** — no `task(..., prompt: "execute change-control task from spec-creation")` entry exists
- The **Operating Protocol** — no step number assigns it a position in the execution chain

This is a regression from the refactoring that introduced the current Invocation table format. An agent dispatched to execute the full spec-creation pipeline never reaches `change-control`.

## Scope

Changes are limited to `skills/spec-creation/SKILL.md` in the `.opencode` submodule. No task file content changes.

## Design Decisions

### Defect A: Remove, don't create

The `diagram` task was never implemented and its responsibility is already covered by the `write` task's mermaid diagram rules. Creating a task file now would duplicate logic. Removal is the correct fix.

### Defect B: Add to Invocation table and Operating Protocol

`change-control` runs after `write` and before `completion` in the pipeline. It is the revision/versioning step — it only activates when the spec is being revised (not initial creation). The Operating Protocol step should note this conditional nature.

## Affected Files

| File | Change |
|------|--------|
| `skills/spec-creation/SKILL.md` | Remove `diagram` from Trigger Dispatch Table, Tasks table, Invocation table |
| `skills/spec-creation/SKILL.md` | Add `change-control` to Invocation table with canonical dispatch string |
| `skills/spec-creation/SKILL.md` | Add `change-control` step to Operating Protocol (after `write`, before `completion`) |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `diagram` removed from Trigger Dispatch Table | `string` | grep for `diagram` in Trigger Dispatch Table — must return 0 matches |
| SC-2 | `diagram` removed from Tasks table | `string` | grep for `diagram` in Tasks table — must return 0 matches |
| SC-3 | `diagram` removed from Invocation table | `string` | grep for `diagram` in Invocation table — must return 0 matches |
| SC-4 | `change-control` added to Invocation table with canonical dispatch string | `string` | grep for `execute change-control task from spec-creation` in Invocation table — must return 1 match |
| SC-5 | `change-control` step added to Operating Protocol after `write` and before `completion` | `string` | grep for `change-control` in Operating Protocol section — must return 1 match, positioned between `write` and `completion` |
| SC-6 | No existing task files modified or deleted | `structural` | `ls skills/spec-creation/tasks/` — file count unchanged, `diagram.md` absent (never existed) |

## Non-Goals

- The `description` frontmatter fix is tracked in #1388 (Fix C2: Remaining skill descriptions). Not covered here.
- No changes to `tasks/change-control.md` content — the task file is correct as-is.
- No changes to any other SKILL.md file.

## Labels

`[SPEC]`, `skill-creator`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)