# Task: apply-label

## Purpose

Apply `approved-for-<scope>` label to the issue after authorization is verified. Remove prior scope labels and `needs-approval` label as advisory cleanup.

## Entry Criteria

- Authorization verified (scope resolved)
- Issue number known

## Exit Criteria

- `approved-for-<scope>` label applied
- Prior scope labels removed
- `needs-approval` label removed

## Procedure

1. Read `authorization_scope` from context
2. Apply `approved-for-<scope>` label via GitHub API
3. Remove prior scope labels (`approved-for-*` except current)
4. Remove `needs-approval` label if present
5. Return result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<summary>"
artifact_path: "<path>"
blocker_reason: "<reason if BLOCKED>"
```
