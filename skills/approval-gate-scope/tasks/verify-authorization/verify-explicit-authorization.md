# Task: verify-authorization — Step 1: Verify Explicit Authorization

## Purpose

Check for "approved"/"go" from a human author (MEMBER/OWNER/COLLABORATOR association), verify authorization is current (not superseded by a later revision), record author identity and timestamp.

## Entry Criteria

- Scope resolved (from Step 0.5)
- Issue number known

## Exit Criteria

- Authorization verified as explicit and current
- Author identity and timestamp recorded
- Result contract returned

## Procedure

1. Read issue comments via GitHub API
2. Search for "approved"/"go" from a human author (MEMBER/OWNER/COLLABORATOR association)
3. Verify authorization is current (not superseded by a later revision)
4. Record author identity and timestamp
5. Return result contract

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<summary>"
artifact_path: "<path>"
blocker_reason: "<reason if BLOCKED>"
```
