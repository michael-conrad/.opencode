# Task: create-remote-stub

## Purpose

Create a minimal remote issue stub to establish the issue number before full spec assembly.

## Entry Criteria

- Issue number is provided
- No remote issue exists yet for this spec

## Procedure

- [ ] 1. Invoke `issue-operations --task creation` with minimal exec summary body
- [ ] 2. Include spec title, brief problem statement, and `needs-approval` label
- [ ] 3. Record the returned issue number for all subsequent artifact paths

## Exit Criteria

- Remote issue created with `[SPEC]` prefix and `needs-approval` label
- Issue number returned for downstream steps

## Result Contract

| Field | Value |
|-------|-------|
| status | DONE | BLOCKED |
| finding_summary | "Remote stub created for issue #N" |
| artifact_path | `{issue_number}` |
