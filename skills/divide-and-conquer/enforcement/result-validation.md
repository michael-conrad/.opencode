# Result Validation Module

## Empty/Malformed/Overflow Result Handling

When `assemble-work` receives a sub-agent result, it MUST validate the result before recording it in the work state file.

### Validation Protocol

1. **Empty result**: Sub-agent returned no output at all
   - Action: RE-TASK clean-room sub-agent per critical-rules-043 (no inline fallback)
   - NEVER transition from empty result to silent halt

2. **Malformed result**: Result contract has invalid YAML or missing required fields
   - Action: Attempt to extract usable data from result
   - If extraction fails: RE-TASK clean-room sub-agent (do NOT inline fallback per critical-rules-043)
   - If extraction succeeds: Record what was extracted, note malformation

3. **Overflow result**: Sub-agent's context window exceeded during execution
   - Result will have `status: OVERFLOW`
   - Action: Invoke `overflow-signal.md` re-dispatch protocol
   - Split the overflowing task into smaller units and re-dispatch

### Required Result Contract Fields

Every sub-agent result MUST include:

| Field | Required | Type |
|-------|----------|------|
| `status` | Yes | `DONE \| DONE_WITH_CONCERNS \| BLOCKED \| OVERFLOW \| FAIL` |
| `task` | Yes | string (task name) |
| Other fields | Per task | Per result contract schema |

### FAIL Status Verify-Before-Acceptance Protocol

When a sub-agent returns `status: FAIL`, the orchestrator MUST NOT accept the failure at face value. Professional orchestrators independently verify failures — amateurs trust FAIL reports without confirmation.

1. **Independently reproduce the failure** — run the same command/assertion the sub-agent ran
2. **If confirmed FAIL**: re-dispatch with remediation instructions including failure evidence
3. **If reproduction shows PASS**: discard the sub-agent result (it was incorrect), re-task clean-room
4. **Double-verify** after remediation: re-run verification on remediated output
5. **Double-failure**: HALT and report blocker with both failure artifacts
6. **Remediation success**: proceed with work orchestration

### Inline Fallback Is Prohibited

Inline fallback is explicitly prohibited per `000-critical-rules.md` §critical-rules-043 (Universal Re-Task Mandate). The ONLY valid paths are: re-task (clean fallback) → Verify-Before-Acceptance → HALT on double-failure. No inline execution, no silent continuation.
