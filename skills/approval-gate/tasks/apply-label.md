---
name: apply-label
description: "Apply approved-for-<scope> label to the issue and remove needs-approval label."
provenance: AI-generated
---

# Task: apply-label

## Purpose

Apply the `approved-for-<scope>` label to the GitHub Issue and remove the `needs-approval` label. This provides persistent authorization state visible to all agents.

## Entry Criteria

- Issue number is provided
- Authorization scope is resolved (from resolve-scope task)
- GitHub API credentials are available

## Steps

1. Read the resolved scope from the resolve-scope artifact
2. Call GitHub API to add `approved-for-{scope}` label
3. Call GitHub API to remove `needs-approval` label (if present)
4. Verify labels were applied correctly by reading back issue labels
5. Write result contract to `{project_root}/tmp/{issue-N}/apply-label.yaml`

## Exit Criteria

- `approved-for-{scope}` label is visible on the issue
- `needs-approval` label is removed (if it was present)
- If API call fails: return BLOCKED with `LABEL_APPLICATION_FAILED`

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "Label approved-for-{scope} applied to issue #{issue_number}"
artifact_path: "{project_root}/tmp/{issue-N}/apply-label.yaml"
blocker_reason: null | "LABEL_APPLICATION_FAILED: {error_message}"
```
