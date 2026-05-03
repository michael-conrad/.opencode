---
skill: guideline-auditor
task: completion
type: discipline-enforcing
license: MIT
---

# Task: completion

## Purpose

Ensure mandatory completion steps run regardless of workflow outcome. Idempotent — safe to invoke multiple times.

## Procedure

1. Verify audit report was written or note it was not created
2. Report completion status
3. Return compact completion result

## Result Contract

```yaml
status: COMPLETED
guideline_auditor_workflow_complete: true
audit_report_written: true | false
```

Co-authored with AI: <AgentName> (<ModelId>)
