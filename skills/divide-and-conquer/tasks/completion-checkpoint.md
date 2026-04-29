# Task: completion-checkpoint

Post-dispatch completion detection: determine whether a sub-agent's work is verifiably complete and take corrective action if not.

## Purpose

Each sub-agent dispatched by `assemble-work` MUST produce a result contract upon completion. This task checks the result contract status, detects abnormal termination, and initiates recovery when a sub-agent's work cannot be confirmed as complete.

**This task enforces `000-critical-rules.md` §Post-Flight Checks for Sub-Agents and §Post-Dispatch Output Guarantee.**

## Pre-Conditions

- A sub-agent has been dispatched via `divide-and-conquer --task dispatch` or `assemble-work`
- The sub-agent's execution has completed (or timed out)

## Status Classification

| Status | Meaning | Action |
|--------|---------|--------|
| `DONE` | All sub-tasks completed successfully | Record result, proceed to next sub-agent |
| `DONE_WITH_CONCERNS` | Completed but with warnings | Record concerns in work state, proceed |
| `BLOCKED` | Cannot proceed due to external dependency | HALT, report blocker in chat |
| `OVERFLOW` | Context window exceeded | Invoke `overflow-signal` task |
| Empty/null | Sub-agent produced no output | FALLBACK to inline execution + warn |

## Completion Detection Protocol

### Step 1: Receive Result Contract

Read the sub-agent's result contract. Verify it contains:
- `status` field (mandatory)
- `files_changed` list (mandatory, may be empty)
- `summary` text (mandatory)

If any mandatory field is missing, the result is malformed — invoke `result-validation` task.

### Step 2: Classify Status

Map the `status` field to the action table above.

### Step 3: Verify Deliverables

For `DONE` or `DONE_WITH_CONCERNS` status:
1. Run `git diff --stat` against base branch to confirm files changed match spec scope
2. Verify no uncommitted changes remain (`git status --short`)
3. Check success criteria traceability — each SC must map to at least one file change

### Step 4: Handle Abnormal States

For `BLOCKED` status:
1. Record blocker in work state file
2. Report blocker in chat with specific description
3. Determine whether to proceed with remaining sub-agents or halt

For `OVERFLOW` status:
1. Invoke `overflow-signal` task for re-dispatch protocol
2. The overflow task determines whether to re-dispatch with smaller scope or report failure

For empty/null result:
1. FALLBACK to inline execution
2. Report warning in chat: "Sub-agent [name] returned no result — falling back to inline"
3. NEVER transition from empty result to silent halt

### Step 5: Record in Work State

Record the completion checkpoint in the work state file:
- Sub-agent name and task
- Status received
- Validation results
- Any concerns or blockers
- Timestamp

## Recovery Protocol

When a sub-agent's completion cannot be verified:

1. Attempt inline fallback execution
2. If inline also fails: report double-failure to orchestrator
3. The orchestrator decides whether to retry, skip, or halt the entire work order
4. NEVER silently skip a failed sub-agent

## Result Contract

```json
{
  "status": "complete | blocked | overflow | failed",
  "sub_agent": "name",
  "original_status": "string",
  "validation_result": "valid | malformed | phantom_files",
  "concerns": ["list"],
  "recovery_action": "proceed | inline_fallback | halt"
}
```

## Completion Guarantee

If this task halts at any point, invoke `divide-and-conquer --task completion` before halting.