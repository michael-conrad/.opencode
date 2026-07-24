---
remote_issue: 1200
remote_url: "https://github.com/michael-conrad/.opencode/issues/1200"
last_sync: "2026-06-14T16:27:31Z"
source: github
---

## Summary

Remove every reference to the `todowrite` tool from AI-agent-facing text (guidelines, skill task files, task checklists). The todowrite lifecycle is self-policing — the agent checks its own state and self-reports clean, with no runtime detection. The "critical violation" framing is misleading. The agent still has access to the tool for its own task tracking; the instructions about how to use it are removed.

## Root Cause

The todowrite lifecycle mandate was added as a self-verified checklist item replicated across 15+ completion tasks with a "critical violation" label in guidelines. No runtime mechanism detects stale todowrite state. The enforcement is the agent reading the rule and choosing to follow it.

## Affected Locations (27 references total)

### Guidelines — remove entirely

| File | Lines | Content |
|------|-------|---------|
| `guidelines/060-tool-usage.md` | 194-207 | Entire "Todowrite Lifecycle Management" section (CREATE/UPDATE/CLEAR rules) |
| `guidelines/060-tool-usage.md` | (symbolic rules block) | Corresponding `tool-usage-xxx` symbolic rule entry |
| `guidelines/000-critical-rules.md` | 432-433 | "Leaving stale todowrite state after task completion" critical-rules-016 entry |

### Skill task files — remove checklist lines

| File | Lines | Content |
|------|-------|---------|
| `skills/brainstorming/tasks/completion.md` | 67 | `- [ ] No stale todowrite items remain` |
| `skills/changelog-generator/tasks/completion.md` | 77 | same |
| `skills/conflict-resolution/tasks/completion.md` | 77 | same |
| `skills/correspondence/tasks/completion.md` | 83 | same |
| `skills/pr-creation-workflow/tasks/completion.md` | 77 | same |
| `skills/receiving-code-review/tasks/completion.md` | 77 | same |
| `skills/sre-runbook/tasks/completion.md` | 76 | same |
| `skills/sync-guidelines/tasks/completion.md` | 76 | same |
| `skills/systematic-debugging/tasks/completion.md` | 77 | same |
| `skills/using-git-worktrees/tasks/completion.md` | 76 | same |
| `skills/adversarial-audit/tasks/completion.md` | 106 | same |
| `skills/finishing-a-development-branch/tasks/checklist.md` | 51 | same |
| `skills/executing-plans/tasks/completion.md` | 72 | same |
| `skills/writing-plans/tasks/completion.md` | 86 | same |
| `skills/approval-gate/tasks/completion.md` | 87 | same |
| `skills/issue-review/tasks/completion.md` | 78 | same |
| `skills/spec-creation/tasks/completion.md` | 91 | same |
| `skills/verification-before-completion/tasks/verify.md` | 128-131 | 4-line todowrite verification block |

### Not modified (non-agent-facing)

- `CHANGELOG.md` — historical record, not agent-facing
- `agents/auditor-*.md` — tool permission denies (`todowrite: deny`), which is correct; auditors should not use the tool
- `tests/enforcement/agents-content/test-all-auditor-agents.sh` — test infrastructure keeping `todowrite` in deny list

## Spec

### Phase 1: Remove Todowrite Lifecycle from 060-tool-usage.md

Delete the entire **§7 Todowrite Lifecycle Management** section (lines 194-207) and its corresponding symbolic rule entry. Renumber subsequent sections.

### Phase 2: Remove Stale Todowrite Entry from 000-critical-rules.md

Delete the two-line "Leaving stale todowrite state after task completion" entry (lines 432-433).

### Phase 3: Remove Todowrite Checklist Lines from All Skill Completion Tasks

In each of the 18 task files listed above, remove the exact line:

```
- [ ] No stale todowrite items remain (all cleared or N/A)
```

And from `verification-before-completion/tasks/verify.md`, remove the 4-line block (lines 128-131).

### Phase 4: Verify No Agent-Facing References Remain

After all removals, grep for `todowrite` in `guidelines/` and `skills/` — confirm only false positives remain (code-fenced examples, cross-references to non-agent-facing text).

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Todowrite Lifecycle Management section removed from 060-tool-usage.md | `string` |
| SC-2 | Stale todowrite state entry removed from 000-critical-rules.md | `string` |
| SC-3 | Todowrite checklist line removed from all 18 skill task files | `string` |
| SC-4 | grep of `guidelines/` and `skills/` returns no todowrite references | `string` |
| SC-5 | Auditor tool permission files (`agents/auditor-*.md`) and test infrastructure unchanged | `structural` |

## Non-Goals

- Not removing the `todowrite` tool from the MCP tool list — agents still have access for task tracking
- Not removing `todowrite: deny` from auditor agent configs — auditors should not use the tool
- Not modifying CHANGELOG.md or test infrastructure files
- Not removing the tool from the system prompt/available tools — only the instructions about how to use it are removed

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/remove-todowrite-references`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)