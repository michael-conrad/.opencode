# Completion Checkpoint Module

## Sub-Agent Completion Detection

Each sub-agent dispatched by `assemble-work` MUST produce a result contract upon completion. The completion checkpoint determines whether the sub-agent's work is verifiably complete.

### Completion Detection Protocol

1. **Result contract received**: Sub-agent returns YAML result contract with `status` field
2. **Status check**: `status` must be `DONE` or `DONE_WITH_CONCERNS`
3. **Concerns check**: If `DONE_WITH_CONCERNS`, log concerns but do not block
4. **Failure check**: If `OVERFLOW` or `BLOCKED`, initiate recovery mode

### Status Classification

| Status | Meaning | Action |
|--------|---------|--------|
| `DONE` | All sub-tasks completed successfully | Record result, proceed to next sub-agent |
| `DONE_WITH_CONCERNS` | Completed but with warnings | Record concerns in work state, proceed |
| `FAIL` | Sub-agent claims operation failed | Do NOT accept — invoke verify-before-acceptance protocol |
| `BLOCKED` | Cannot proceed due to external dependency | HALT, report blocker in chat |
| `OVERFLOW` | Context window exceeded during execution | Initiate overflow recovery |

### Verify-Before-Acceptance Protocol (FAIL results only)

When a sub-agent returns `status: FAIL`, the orchestrator MUST NOT accept the claim without independent verification:

1. **Check `error_output`** — the result contract MUST include raw tool invocation error output. Empty or prose-summary `error_output` is INCOMPLETE_FAIL → re-dispatch.

2. **Independently reproduce the failure** — execute the claimed failing tool/command from the orchestrator context:
   - Tool succeeds → sub-agent fabricated → re-dispatch clean-room sub-agent
   - Tool fails with different error → sub-agent misreported → re-dispatch
   - Tool fails with matching error → verified FAIL → escalate to completion

3. **Re-dispatch:** Dispatch fresh clean-room sub-agent with identical scoped context (no prior error_output). On re-dispatch FAIL, verify again. On re-dispatch DONE, accept and note fabrication in work state.

4. **Double verification:** After two independently verified FAIL results, invoke `--task completion`, HALT with status message + byline.

Accepting a FAIL result contract without independent verification violates `000-critical-rules.md` §Verify-Before-Acceptance. This protocol is MANDATORY — the orchestrator independently validates every sub-agent failure claim before accepting it as truth.

### Recovery Mode

When a sub-agent fails:
1. Log the failure in work state file
2. Attempt inline fallback (perform the sub-agent's task directly)
3. If inline fallback succeeds: continue work orchestration
4. If inline fallback fails: report double-failure, invoke `--task completion`, HALT with status message
5. NEVER silently continue after sub-agent failure