---
name: apply-label
description: "Apply approved-for-<scope> label to the issue and remove needs-approval label."
provenance: AI-generated
---

# Task: apply-label

## Purpose

Apply the `approved-for-<scope>` label to the issue and remove the `needs-approval` label. This provides persistent authorization state visible to all agents regardless of platform (GitHub, GitBucket, or local .issues/).

## Entry Criteria

- Issue number is provided
- Authorization scope is resolved (from resolve-scope task)
- Platform credentials are available (verified by session-init)

## Steps

1. Read the resolved scope from the resolve-scope artifact
2. Dispatch to `issue-operations` skill for platform-aware label management:
   - `skill({name: "issue-operations"})` → `task("execute update-labels from issue-operations-core")`
   - Context: `{issue_number, labels_to_add: ["approved-for-{scope}"], labels_to_remove: ["needs-approval"]}`
3. Verify labels were applied correctly by reading back issue labels via `issue-operations`
4. Write result contract to `{project_root}/tmp/{issue-N}/apply-label.yaml`

## Exit Criteria

- `approved-for-{scope}` label is visible on the issue
- `needs-approval` label is removed (if it was present)
- If label operation fails: return BLOCKED with `LABEL_APPLICATION_FAILED`

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "Label approved-for-{scope} applied to issue #{issue_number}"
artifact_path: "{project_root}/tmp/{issue-N}/apply-label.yaml"
blocker_reason: null | "LABEL_APPLICATION_FAILED: {error_message}"
```
