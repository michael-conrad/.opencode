---
remote_issue: 2418
remote_url: "https://github.com/michael-conrad/.opencode/issues/2418"
last_sync: 2026-08-30T23:22:23Z
source: github.com
---

> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2417/ — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.

## Problem

The `git-workflow-cleanup` skill's canonical dispatch string forces the orchestrator to perform inline git/gh investigation (resolving `pr_merge_status` and `branch_name`) before dispatching the cleanup sub-agent. This violates the orchestrator-context-lean principle — the orchestrator should never run inline tool calls to prepare sub-agent context. Additionally, the result contract reporting reverses the submodule-first procedural order defined in the cleanup task card.

## Root Cause

Three independent root causes combine to produce the defect:

1. **Canonical dispatch string requires pre-resolved values** — The `concat()` function in `.opencode/skills/git-workflow-cleanup/SKILL.md` line 36 embeds `pr_merge_status` and `branch_name` as string values, forcing orchestrator inline git/gh resolution before dispatch.
2. **Orchestrator inline investigation before dispatch** — Because the dispatch string requires pre-resolved values, the orchestrator runs git/gh commands inline, contaminating its context with conclusions.
3. **Result contract reporting reverses procedural order** — The task card defines submodule-first iteration (Steps 3, 4) but orchestrator summary reports parent before submodule.

## Scope

**In-scope:**
- Replace `concat()` dispatch prompt with `pr_merged_event: true` flag
- Remove `pr_merge_status` and `branch_name` from Workflows context
- Add guard note in `cleanup.md` Step 0
- Reinforce submodule-first result contract ordering
- Behavioral enforcement test

**Out of scope:** pair-cleanup workflow, other skills' dispatch mechanisms, git-workflow-branch or git-workflow-pr dispatch patterns.

## Approach

Replace `concat()` dispatch with a simple boolean flag. Remove pre-resolved values from context. Add guard note. Reinforce submodule-first ordering in result contract. Add behavioral test.

## Impact

| Risk | Mitigation |
|------|-----------|
| Breaking change to dispatch protocol | Orchestrator and sub-agent updated together (same deployment) — no external consumers affected |
| Behavioral test requires real model inference | Scope-limited to this SC — single scenario, bounded runtime |
| Guard note is documentation-only | Backed by behavioral test that verifies actual agent behavior |

**Call to action:** Review and approve for implementation.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|--------------|-------------------|
| SC-1 | SKILL.md dispatch prompt uses `pr_merged_event: true` instead of `concat()` with pre-resolved `pr_merge_status`/`branch_name` | structural | grep dispatch prompt for `pr_merged_event` in SKILL.md |
| SC-2 | Orchestrator does NOT run any git/gh tool calls inline before dispatching cleanup sub-agent | behavioral | opencode run + stderr inspection |
| SC-3 | Cleanup sub-agent's result contract reports submodules before parent repo | structural | Inspect task card — submodule entries precede parent |
| SC-4 | cleanup.md Step 0 has explicit guard note against orchestrator pre-investigation | string | grep cleanup.md for guard note text |

## Requirements

- R-1. The dispatch prompt SHALL use `pr_merged_event: true` instead of `concat()` with pre-resolved values.
- R-2. The Workflows context SHALL NOT include `pr_merge_status` or `branch_name`.
- R-3. `cleanup.md` Step 0 SHALL include a guard note against orchestrator pre-investigation.
- R-4. `cleanup.md` SHALL reinforce submodule-first ordering in result contract reporting.
- R-5. A behavioral enforcement test SHALL verify no git/gh calls appear before dispatch.
