---
number: 1210
title: "[SPEC] Workstream B — Trigger Dispatch Tables (all 39 SKILL.md files)"
status: open
labels: [spec]
created: 2026-06-14T20:49:21Z

---
remote_issue: 1210
remote_url: "https://github.com/michael-conrad/.opencode/issues/1210"
last_sync: 2026-06-14T20:49:21Z
source: github.com
---

## Workstream B — Trigger Dispatch Tables

**Parent:** #1208
**Depends on:** #1209 (Workstream A)

### Scope
All 39 SKILL.md files across the skill deck.

### Changes

Add a "## Trigger Dispatch Table" section to EVERY SKILL.md body, positioned after the Overview. The section contains a table with 4 columns:

| Column | Content | Required |
|--------|---------|----------|
| User says / Context | Example user phrases that trigger this dispatch. Include synonyms. | Yes |
| Task | The task to call via `task()` | Yes |
| Dispatch | `sub-task`, `blind sub-task`, or `inline` | Yes |
| Context passed | What context to include in the task() call. `—` if none. | Yes |

### Rules

1. **Every skill gets one.** Zero exceptions. Single-task skills get a single-row table.
2. **Every task gets at least one row.** If a task is listed in the ## Tasks section, it MUST have at least one row in the dispatch table.
3. **Cross-skill routing audit.** Verify no two dispatch tables claim the same primary trigger phrase. Resolve conflicts by routing to the more specific skill. For example, `"merge conflict"` in git-workflow's dispatch table should route to the `conflict-resolution` skill, not attempt to handle it internally.
4. **Pair-mode tasks are excluded.** `pair-pre-work`, `pair-commit`, `pair-pr-creation`, `pair-cleanup`, `pair-mode-resume` are triggered by branch name detection, not user phrases — they belong in a separate operational note, not the user-facing dispatch table.
5. **Task files stay in ## Tasks section.** The dispatch table is a routing section, not a replacement for the task list.

### Cross-Skill Trigger Audit

The following trigger groups have potential cross-skill ambiguity and must be resolved in each dispatch table:

| Trigger | Primary Skill | Secondary Skills | Resolution |
|---------|--------------|-----------------|------------|
| "create spec" / "write spec" | spec-creation | issue-operations (creation), brainstorming | spec-creation gets primary; others route to spec-creation |
| "audit" / "spec audit" | adversarial-audit | issue-review | adversarial-audit gets primary |
| "create issue" / "bug report" | issue-operations | — | no conflict |
| "PR" / "pull request" | git-workflow | pr-creation-workflow | git-workflow routes to pr-creation-workflow internally or dispatches directly |
| "fix" / "debug" | systematic-debugging | engineering-approach | systematic-debugging gets primary |

### SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-B1 | All 39 SKILL.md have a ## Trigger Dispatch Table section | string |
| SC-B2 | Every dispatch table has all 4 required columns | string |
| SC-B3 | No conflicting primary triggers between any two dispatch tables | behavioral |
| SC-B4 | Every task listed in Tasks section has at least one dispatch table row | string |
