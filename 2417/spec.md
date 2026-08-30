> **Full spec and artifacts: [`.opencode/.issues/2417/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2417/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2417/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The `git-workflow-cleanup` skill's canonical dispatch string forces the orchestrator to perform inline git/gh investigation (resolving `pr_merge_status` and `branch_name`) before dispatching the cleanup sub-agent. This violates the orchestrator-context-lean principle — the orchestrator should never run inline tool calls to prepare sub-agent context. Additionally, the result contract reporting reverses the submodule-first procedural order defined in the cleanup task card.

## Root Cause

Three independent root causes combine to produce the defect:

### Root Cause 1: Canonical dispatch string requires pre-resolved values
- File: `.opencode/skills/git-workflow-cleanup/SKILL.md` line 36
- The `concat()` function embeds `pr_merge_status` and `branch_name` as string values, forcing orchestrator inline git/gh resolution before dispatch.

### Root Cause 2: Orchestrator inline investigation before dispatch
- Because the dispatch string requires pre-resolved values, the orchestrator runs git/gh commands inline, contaminating its context with conclusions.

### Root Cause 3: Result contract reporting reverses procedural order
- The task card defines submodule-first iteration (Steps 3, 4) but orchestrator summary reports parent before submodule.

## Approach Chosen

Replace `concat()` dispatch with a simple boolean flag. Remove pre-resolved values from context. Add guard note. Reinforce submodule-first ordering in result contract. Add behavioral test.

## Alternatives Considered & Why Discarded

- **Keep `concat()` and document that orchestrator should pre-resolve** — This codifies the orchestrator-context-lean violation rather than fixing it. Discarded.
- **Remove submodule-first reporting entirely** — Reports parent-only skips submodule state entirely, which is worse. Discarded.

## Key Design Decisions

- **Boolean flag over string interpolation:** `pr_merged_event: true` is the simplest possible signal — no pre-resolved values needed. Breaking change is safe because orchestrator and sub-agent ship together.
- **Guard note + behavioral test:** The guard note is documentation; the behavioral test verifies binding behavior. Both are needed.

## User Intent / Original Prompt

This spec fixes a structural defect discovered during spec audit of the git-workflow-cleanup skill. The orchestrator was performing inline git/gh investigation before dispatch, which violates the orchestrator-context-lean principle.

## Scope

**In-scope:**
- Replace `concat()` dispatch prompt with `pr_merged_event: true` flag
- Remove `pr_merge_status` and `branch_name` from Workflows context
- Add guard note in `cleanup.md` Step 0
- Reinforce submodule-first result contract ordering
- Behavioral enforcement test

**Out of scope:** pair-cleanup workflow, other skills' dispatch mechanisms, git-workflow-branch or git-workflow-pr dispatch pattern changes.

## Not Included

- **pair-cleanup workflow** — Different entry point and routing path; separate fix if needed.
- **Other git-workflow sub-skills** — Each skill's dispatch mechanism is independently scoped.
- **`git-workflow-branch` / `git-workflow-pr` dispatch patterns** — Their `concat()` patterns are distinct concerns.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|--------------|-------------------|----------------------|
| SC-1 | SKILL.md dispatch prompt for cleanup workflow uses `pr_merged_event: true` instead of `concat()` with pre-resolved `pr_merge_status`/`branch_name` | structural | grep dispatch prompt for `pr_merged_event` in SKILL.md | `.opencode/skills/git-workflow-cleanup/SKILL.md` |
| SC-2 | Orchestrator does NOT run any git/gh tool calls inline before dispatching cleanup sub-agent on "pr merged" trigger | behavioral | opencode run + stderr inspection — no git/gh calls before task() dispatch | Behavioral test scenario |
| SC-3 | Cleanup sub-agent's result contract reports submodules before parent repo | structural | Inspect task card — submodule entries precede parent | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |
| SC-4 | cleanup.md Step 0 has explicit guard note: "The orchestrator MUST NOT investigate PR/issue state before dispatching this task — the sub-agent discovers everything independently" | string | grep cleanup.md for guard note text | `.opencode/skills/git-workflow-cleanup/tasks/cleanup.md` |

## Requirements

- R-1. The dispatch prompt SHALL use `pr_merged_event: true` instead of `concat()` with pre-resolved values.
- R-2. The Workflows context SHALL NOT include `pr_merge_status` or `branch_name`.
- R-3. `cleanup.md` Step 0 SHALL include a guard note against orchestrator pre-investigation.
- R-4. `cleanup.md` SHALL reinforce submodule-first ordering in result contract reporting.
- R-5. A behavioral enforcement test SHALL verify no git/gh calls appear before dispatch.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the dispatch string change costs one grep call. Skipping means the old `concat()` pattern persists and the orchestrator continues to pre-investigate.
- SC-2: Running the behavioral test costs minutes of execution time. Skipping means the orchestrator-pre-investigation defect ships into every cleanup dispatch cycle, compounding rework cost with each PR.
- SC-3: Verifying the result contract order costs one read. Skipping means the sub-agent reports parent-first, reversing the procedural order and masking submodule state.
- SC-4: Verifying the guard note costs one grep call. Skipping means the sub-agent receives no explicit boundary against orchestrator pre-investigation.

## Items

### Item 1 (SC-1): Replace dispatch string with `pr_merged_event: true`

- RED: grep for `concat()` or `pr_merge_status` in SKILL.md — must exist before change
- GREEN: Replace `concat()` dispatch with `pr_merged_event: true`
- verify: grep confirms no `concat()` or `pr_merge_status` remains
- commit: SKILL.md changes only

### Item 2 (SC-4): Add guard note in cleanup.md Step 0

- RED: grep cleanup.md for guard note — must not exist before change
- GREEN: Add guard note text in cleanup.md Step 0
- verify: grep confirms guard note text
- commit: cleanup.md changes only

### Item 3 (SC-3): Reinforce submodule-first in result contract

- RED: check cleanup.md does not have submodule-first language in result contract section
- GREEN: Add note reinforcing submodule-first ordering
- verify: grep confirms submodule-first language
- commit: cleanup.md changes only

### Item 4 (SC-2): Behavioral enforcement test

- RED: Behavioral test fails — orchestrator runs git/gh commands before dispatch
- GREEN: Apply Items 1-3 changes; behavioral test now passes
- verify: Behavioral test passes
- commit: Test scenario file only

## Dependencies

- **git-workflow-cleanup skill** — This spec modifies the same skill. No external dependency on other skills or specs.
- **opencode run environment** — Behavioral test requires `opencode` runtime with model inference. Verified available in CI.

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-1 | Item 1 |
| R-3 | SC-4 | Item 2 |
| R-4 | SC-3 | Item 3 |
| R-5 | SC-2 | Item 4 |

## Change Control

| Date | Change | Reason |
|------|--------|--------|
| 2026-08-30 | Re-created from root repo #369 (closed) to .opencode#2417 | Wrong repo: affected files under .opencode/ belong to michael-conrad/.opencode |
