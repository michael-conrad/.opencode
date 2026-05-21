# Completion Checkpoint Module

## Sub-Agent Completion Detection

Each sub-agent task()ed by `assemble-work` MUST produce a result contract upon completion. The completion checkpoint determines whether the sub-agent's work is verifiably complete.

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
| `BLOCKED` | Cannot proceed due to external dependency | HALT, report blocker in chat |
| `OVERFLOW` | Context window exceeded during execution | Initiate overflow recovery |
| `FAIL` | Sub-agent returned FAIL status | Initiate Verify-Before-Acceptance protocol |

### Verify-Before-Acceptance Protocol (for FAIL status)

When a sub-agent returns `status: FAIL`, the orchestrator MUST NOT accept it at face value. Professional orchestrators verify failures independently — amateurs trust FAIL reports without confirmation.

1. **Independently reproduce** the failure — run the same verification command or assertion the sub-agent ran
2. **If reproduction confirms FAIL**: re-dispatch with remediation instructions (include the failure evidence)
3. **If reproduction shows PASS**: the sub-agent result was incorrect — discard and re-task clean-room
4. **Double-verify** after remediation — re-run the verification on the remediated result
5. **Double-failure**: if remediation also fails, HALT and report blocker with both failure artifacts. If remediation passes, accept and proceed.

### Recovery Mode

When a sub-agent fails:
1. Log the failure in work state file
2. Initiate the Verify-Before-Acceptance protocol (do NOT inline fallback — see `000-critical-rules.md` §critical-rules-043)
3. If remediation succeeds: continue work orchestration
4. If remediation double-fails: report double-failure, call `--task completion`, HALT with status message
5. NEVER silently continue after sub-agent failure
