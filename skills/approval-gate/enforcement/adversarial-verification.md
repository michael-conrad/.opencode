# Adversarial Verification Module

## Evidence Artifact Format

Every verification checkpoint in approval-gate tasks MUST produce a tool-call artifact demonstrating the verification was performed. Assertions without tool-call artifacts are verification honesty violations per `065-verification-honesty.md`.

### Required Format

```
Check: [what was verified]
Tool: [tool call and parameters]
Result: [actual state found]
Classification: [STRUCTURE-VIOLATION|MISSING-ELEMENT|CONFLICTING|VERIFICATION-GAP|MISSING-TRACEABILITY]
Action: [auto-fix|escalate]
```

### Evidence Rules

1. Every fact assertion about GitHub state, file existence, or code behavior MUST have a tool-call artifact
2. Cache invalidation: re-verify before significant actions, never trust cached values
3. Staleness rule: evidence from previous exchanges is stale; re-verify before acting
4. Single exchange window: tool-call evidence from the immediately preceding exchange MAY be trusted without re-verification

## Finding Classification

Findings from verification follow a binary model: PASS or FAIL. No classification tier may imply "defects are acceptable."

| Classification | When | Action |
|----------------|------|--------|
| PASS | Finding matches expected state | No action needed |
| FAIL | Finding deviates from expected state | Remediate or escalate |

### Remediation Actions

- **auto-fix**: Apply automated correction for non-substantive mechanical FAILs (formatting, typos, stale references). This is a remediation action, not a classification tier — the finding is still FAIL until corrected.
- **escalate**: Report FAIL findings that require domain judgment in findings, do NOT apply, HALT for developer review.