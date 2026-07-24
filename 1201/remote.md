---
remote_issue: 1201
remote_url: "https://github.com/michael-conrad/.opencode/issues/1201"
last_sync: "2026-06-14T16:32:53Z"
source: github
---

## Summary

Every skill completion task contains the same boilerplate checklist items — verify byline, record completion, verify exit criteria. At least 15 task files replicate these identical items. Extract to one flat reference card (`.opencode/.guidelines/completion-checklist.md`). Every completion task replaces its inline checklist with a mandatory read-and-follow reference to the card.

## Core Principle: File IS the section

Cross-referenced material is a flat card with no subsections. The agent reads the whole file or not at all. No parsing out sections.

## Root Cause

When completion checklist items were added, they were embedded in every skill's completion task to ensure visibility. The items are identical across all skills. Each update must touch 15+ files.

## Affected Components

| Component | Change |
|-----------|--------|
| `.opencode/.guidelines/completion-checklist.md` | New flat card — the entire completion checklist |
| `.opencode/skills/*/tasks/completion.md` (~15 files) | Replace inline checklist with reference to card |
| `.opencode.skills/finishing-a-development-branch/tasks/checklist.md` | Replace inline todowrite item with reference (todowrite line removed per #1200) |
| `.opencode/skills/verification-before-completion/tasks/verify.md` | Replace inline todowrite block with reference |
| `.opencode/.guidelines/INDEX.md` | Add entry |

The 15+ task files:

- `skills/brainstorming/tasks/completion.md`
- `skills/changelog-generator/tasks/completion.md`
- `skills/conflict-resolution/tasks/completion.md`
- `skills/correspondence/tasks/completion.md`
- `skills/pr-creation-workflow/tasks/completion.md`
- `skills/receiving-code-review/tasks/completion.md`
- `skills/sre-runbook/tasks/completion.md`
- `skills/sync-guidelines/tasks/completion.md`
- `skills/systematic-debugging/tasks/completion.md`
- `skills/using-git-worktrees/tasks/completion.md`
- `skills/adversarial-audit/tasks/completion.md`
- `skills/executing-plans/tasks/completion.md`
- `skills/writing-plans/tasks/completion.md`
- `skills/approval-gate/tasks/completion.md`
- `skills/issue-review/tasks/completion.md`
- `skills/spec-creation/tasks/completion.md`
- `skills/verification-before-completion/tasks/verify.md`
- `skills/finishing-a-development-branch/tasks/checklist.md`

## Spec

### Phase 1: Create Flat Reference Card

Create `.opencode/.guidelines/completion-checklist.md` containing:

```
Completion Checklist — Mandatory Before Any Halt

- Verify exit criteria for the current task are met. Run verification-before-completion if applicable.
- Verify byline presence on all AI-authored content posted to GitHub (issue bodies, PR bodies, comments). Byline format: 🤖 Co-authored with AI: <AgentName> (<ModelId>).
- Record completion in chat output. Must include: Summary, Outcome, URL (if applicable), Byline.
```

No headings, no subsections. The file IS the checklist.

### Phase 2: Replace Inline Checklists with Reference

In every affected completion task file, replace the full checklist section with:

```
Completion checklist: read and follow `.opencode/.guidelines/completion-checklist.md` before halting.
```

If the task file has other content around the checklist that is task-specific (not boilerplate), preserve the task-specific items and only replace the boilerplate.

### Phase 3: Verify Redundancy Removed

After replacement, grep remaining `skills/` task files for the boilerplate patterns (`"Verify byline"`, `"Verify exit criteria"`, `"Record completion"`). Only task-specific variants should remain.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | completion-checklist.md exists as flat card (no internal headings) | `string` |
| SC-2 | No skill task file contains inline boilerplate checklist items (byline, exit criteria, completion recording) | `string` |
| SC-3 | Every affected completion task references the card instead of embedding | `string` |
| SC-4 | INDEX.md has entry for completion-checklist.md | `string` |
| SC-5 | Behavioral: agent following completion task reads the card before halting | `behavioral` |

## Non-Goals

- Not changing task-specific completion items that differ per skill — only the shared boilerplate
- Not merging completion tasks into a single shared completion skill — each skill still has its own completion task for its specific exit criteria

## Environment

- Repo: `michael-conrad/.opencode`
- Branch: `feature/completion-checklist-card`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)