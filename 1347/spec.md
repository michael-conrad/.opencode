## Problem

The implementation-pipeline's dispatch routing table (14 steps) does not include checkpoint tag creation as an explicit step. The tag creation procedure exists in `pipeline-executor.md` as inline bash that runs after every step, but it is not a dispatch table entry. The plan writer (`writing-plans` skill) generates checkboxes from the dispatch routing table — if checkpoint tag creation is not in the table, the plan writer does not generate the checkbox, and the orchestrator does not create the tag.

This means checkpoint tags are never actually created during plan execution, which breaks the rollback mechanism defined in `000-critical-rules.md` §Checkpoint Rollback Exception.

## Approach

Add checkpoint tag creation as an explicit step in the implementation-pipeline's dispatch routing table. The step sits between the last TDD item step and the Post-RED/green gates. The pipeline state machine (Z3 contract) must be updated to include the new step with valid transitions.

## Files to Modify

| File | Change |
|------|--------|
| `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` | Add `checkpoint-tag-create` to the dispatch routing table (step between last TDD step and Post-RED/green gates) |
| `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml` | Add `checkpoint-tag-create` state with valid transitions (from last TDD step → checkpoint-tag-create, from checkpoint-tag-create → next gate step) |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Update the Trigger Dispatch Table to include the new step |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `pipeline-executor.md` dispatch routing table includes `checkpoint-tag-create` as an explicit step | `string` | Grep for `checkpoint-tag-create` in the dispatch routing table. Verify it appears between the last TDD item step and the Post-RED/green gates |
| SC-2 | `pipeline-state-machine.yaml` includes `checkpoint-tag-create` state with valid transitions | `string` | Verify Z3 state machine YAML includes the new state. Verify transitions: from last TDD step → checkpoint-tag-create, from checkpoint-tag-create → next gate step |
| SC-3 | `SKILL.md` Trigger Dispatch Table includes the new step | `string` | Grep for `checkpoint-tag-create` in the Trigger Dispatch Table section of SKILL.md |
| SC-4 | The step produces a git tag following the convention from `000-critical-rules.md` §Checkpoint Rollback Exception | `behavioral` | Invoke the pipeline for a test issue. Verify a git tag is created matching the pattern `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` |

## Out of Scope

- The plan format spec (#1346) — this spec covers only the pipeline routing table fix
- The plan writer (writing-plans skill) changes — those are covered by #1346 Phase 5
- The sub-plan file format — covered by #1346 Phase 2

## Dependencies

- `000-critical-rules.md` §Checkpoint Rollback Exception for tag format convention
- `#1346` Phase 2 (sub-plan format references the checkpoint tag step)
- `#1346` Phase 5 (writing-plans skill generates the checkbox from the dispatch table)

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)