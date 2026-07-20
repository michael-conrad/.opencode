## Problem

Audit #1591 found that `spec-creation/SKILL.md` exposes Operating Protocol sub-steps as standalone dispatchable entries in the Tasks section and Invocation section. This allows the orchestrator to bypass the sequential Operating Protocol by calling sub-steps directly.

## Affected Entries

| Entry | Location | Operating Protocol Step | Defect Type |
|-------|----------|------------------------|-------------|
| `pipeline-readiness-gate` | Tasks section (line 44), Invocation section (line 56) | Step 4.5 | D4 — Invocation exposes sub-step |
| `completion` | Trigger Dispatch Table (line 33), Tasks section (line 45), Invocation section (line 57) | Step 11 | D3 + D4 — dispatch table and invocation expose sub-step |

## Changes

### 1. Trigger Dispatch Table

Remove the `completion` row. The dispatch table should contain only `create` as the sole pipeline entry point.

### 2. Tasks Section

Remove `pipeline-readiness-gate` and `completion` from the task list. These are Operating Protocol sub-steps, not standalone entry points. The task list should contain only `create`.

### 3. Invocation Section

Remove the `pipeline-readiness-gate` and `completion` rows from the canonical task() string table. Only `create` should have a canonical task() string.

## What Stays

- The `pipeline-readiness-gate` task file at `tasks/pipeline-readiness-gate.md` remains — it is still called from Operating Protocol step 4.5
- The `completion` task file at `tasks/completion.md` remains — it is still called from Operating Protocol step 11
- The Operating Protocol itself is unchanged — steps 4.5 and 11 still reference these tasks
- The `create` entry in the Trigger Dispatch Table, Tasks section, and Invocation section is unchanged

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Trigger Dispatch Table contains only `create` | `string` | grep for `completion` in Trigger Dispatch Table section returns no match |
| SC-2 | Tasks section contains only `create` | `string` | grep for `pipeline-readiness-gate` and `completion` in Tasks section returns no match |
| SC-3 | Invocation section contains only `create` canonical task() string | `string` | grep for `pipeline-readiness-gate` and `completion` in Invocation section returns no match |
| SC-4 | `pipeline-readiness-gate` task file still exists | `structural` | `ls tasks/pipeline-readiness-gate.md` succeeds |
| SC-5 | `completion` task file still exists | `structural` | `ls tasks/completion.md` succeeds |
| SC-6 | Operating Protocol steps 4.5 and 11 still reference these tasks | `string` | grep for task names in Operating Protocol section returns matches |

## Files

- `.opencode/skills/spec-creation/SKILL.md` — remove entries from Tasks section and Invocation section

## Dependencies

- #1591 — Audit that identified the defect

## Risks

- Low. Removing dispatch entries does not delete task files — the Operating Protocol still calls them. The orchestrator can no longer bypass the sequential protocol by calling sub-steps directly.

## Change Control

- 2026-06-30: Initial fix spec

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)