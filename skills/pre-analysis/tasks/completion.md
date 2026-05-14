# Task: completion

## Purpose

Ensure mandatory completion steps run regardless of workflow outcome. Idempotent — safe to invoke multiple times.

## Procedure

1. Verify dispatch marker still exists: `ls tmp/dispatch-*.marker`
2. Report completion status to work state file
3. Return compact completion result

## Result Contract

```yaml
status: COMPLETED
pre_analysis_complete: true
marker_present: true
```

## Pipeline Signal

```
HALT
```

Co-authored with AI: <AgentName> (<ModelId>)
