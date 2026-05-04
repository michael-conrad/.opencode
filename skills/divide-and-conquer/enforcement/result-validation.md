# Result Validation Module

## Empty/Malformed/Overflow Result Handling

When `assemble-work` receives a sub-agent result, it MUST validate the result before recording it in the work state file.

### Validation Protocol

1. **Empty result**: Sub-agent returned no output at all
   - Action: FALLBACK to inline execution + report warning in chat
   - NEVER transition from empty result to silent halt

2. **FAIL result**: Sub-agent returned `status: FAIL`
   - Action: Do NOT accept — invoke FAIL Result Validation Protocol (below)

3. **Malformed result**: Result contract has invalid YAML or missing required fields
   - Action: Attempt to extract usable data from result
   - If extraction fails: FALLBACK to inline execution + report warning in chat
   - If extraction succeeds: Record what was extracted, note malformation

4. **Overflow result**: Sub-agent's context window exceeded during execution
   - Result will have `status: OVERFLOW`
   - Action: Invoke `overflow-signal.md` re-dispatch protocol
   - Split the overflowing task into smaller units and re-dispatch

### Required Result Contract Fields

Every sub-agent result MUST include:

| Field | Required | Type |
|-------|----------|------|
| `status` | Yes | `DONE \| DONE_WITH_CONCERNS \| FAIL \| BLOCKED \| OVERFLOW` |
| `task` | Yes | string (task name) |
| `error_output` | CONDITIONAL | string (raw tool error output — REQUIRED when `status: FAIL`, empty otherwise) |
| Other fields | Per task | Per result contract schema |

### FAIL Result Validation Protocol

When a sub-agent returns `status: FAIL`, the orchestrator MUST NOT accept the result. Instead:

1. **Validate `error_output` is present:** A FAIL result contract MUST include the `error_output` field with raw tool invocation error output (not a prose summary). If `error_output` is empty, missing, or contains only narrative summary → the result is INCOMPLETE_FAIL → re-dispatch a fresh clean-room sub-agent.

2. **Independently reproduce the claimed failure:** Before accepting the FAIL, the orchestrator MUST execute the tool or command that the sub-agent claimed failed. Compare your output against `error_output`:
   - Orchestrator execution succeeds → sub-agent fabricated the failure → re-dispatch clean-room sub-agent (do NOT include prior error_output in re-dispatch context)
   - Orchestrator execution fails with different error → sub-agent may have misreported → re-dispatch
   - Orchestrator execution fails with matching error → failure verified → escalate to completion

3. **Re-dispatch protocol:** Fresh clean-room sub-agent with identical scoped context. On re-dispatch FAIL → verify again. On re-dispatch DONE → accept result, note fabrication in work state file.

4. **Double-verification escalation:** After two independently verified consecutive FAIL results, invoke `--task completion`, HALT with status message + byline.

**This protocol enforces `000-critical-rules.md` §Verify-Before-Acceptance.** Accepting a sub-agent FAIL claim without independent reproduction is a CRITICAL GUIDELINE VIOLATION. The orchestrator must independently confirm every FAIL before treating it as truth.

### Fallback Procedure

When inline fallback is attempted:
1. Report the original sub-agent failure to chat
2. Execute the sub-agent's task directly within the orchestration context
3. If fallback succeeds: continue work orchestration, note in work state
4. If fallback also fails: report double-failure, invoke `--task completion`, HALT