---
skill: engineering-approach
task: completion
type: discipline-enforcing
license: MIT
---

# Task: completion

## Purpose

Ensure mandatory completion steps run regardless of workflow outcome. Idempotent — safe to invoke multiple times.

## Procedure

- [ ] 1. Verify no stale design artifacts remain: `ls ./tmp/{issue-N}/design-*.md`
- [ ] 2. Report completion status
- [ ] 3. Return compact completion result

## Result Contract

```yaml
status: COMPLETED
engineering_approach_workflow_complete: true
stale_artifacts_cleared: true
```

## Pipeline Signal

```
HALT
```

Co-authored with AI: <AgentName> (<ModelId>)
