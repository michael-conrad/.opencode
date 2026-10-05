# Task: completion

## Purpose

Ensure mandatory completion steps run regardless of workflow outcome. Idempotent — safe to invoke multiple times.

## Procedure

- [ ] 1. Verify task marker still exists: `ls {project_root}/tmp/{issue-N}/task-*.marker`
- [ ] 2. Record completeness gate result in work state file if not already recorded
- [ ] 3. Return compact completion result

## Result Contract

```yaml
status: COMPLETED
completeness_gate_complete: true
marker_present: true
```

## Pipeline Signal

```
HALT
```

Co-authored with AI: <AgentName> (<ModelId>)
