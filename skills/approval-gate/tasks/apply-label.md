---
name: apply-label
description: "Apply approved-for-<scope> label to the issue and remove needs-approval label."
provenance: AI-generated
---

# Task: apply-label

## Purpose

Apply the `approved-for-<scope>` label to the issue and remove the `needs-approval` label. The local `issue.yaml` file is the **primary canonical source** for authorization state — the write to `{issues_prefix}/{N}/issue.yaml` labels array MUST succeed and is authoritative. Remote writes (GitHub, GitBucket) are best-effort/secondary and MUST NEVER block the pipeline.

## Entry Criteria

- Issue number is provided
- Authorization scope is resolved (from resolve-scope task)
- `{issues_prefix}/{N}/issue.yaml` exists (local canonical record)

## Steps

1. Read the resolved scope from the resolve-scope artifact
2. **PRIMARY — write to local canonical source:** Write `approved-for-{scope}` to the local `issue.yaml` labels array via `local-issues update`:
   - `./.opencode/tools/local-issues update <repo>#<N> --labels approved-for-{scope}`
   - This replaces the labels array with `approved-for-{scope}` (removing `needs-approval`). This is the authoritative authorization record.
   - If this write fails: return BLOCKED with `LOCAL_LABEL_WRITE_FAILED` — the pipeline MUST NOT proceed without the canonical local record.
3. **SECONDARY — best-effort remote write (never blocking):** Dispatch to `issue-operations` skill for platform-aware label management:
   - `skill({name: "issue-operations"})` → `task("execute update-issue from issue-operations-core")`
   - Context: `{issue_number, labels: ["approved-for-{scope}"]}`
   - This is best-effort only. If the remote write fails, log the failure and continue — it MUST NOT block the pipeline.
4. Verify the local canonical write by reading back the labels array via `./.opencode/tools/local-issues read-labels --number <repo>#<N>`
5. Write result contract to `{project_root}/tmp/{issue-N}/apply-label.yaml`

## Exit Criteria

- `approved-for-{scope}` is present in the local `{issues_prefix}/{N}/issue.yaml` labels array (canonical — REQUIRED)
- `needs-approval` is removed from the local `issue.yaml` labels array (if it was present)
- Remote label write attempted best-effort; remote failure does not block completion
- If the local canonical write fails: return BLOCKED with `LOCAL_LABEL_WRITE_FAILED`

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "Label approved-for-{scope} written to local issue.yaml for issue #{issue_number}"
artifact_path: "{project_root}/tmp/{issue-N}/apply-label.yaml"
blocker_reason: null | "LOCAL_LABEL_WRITE_FAILED: {error_message}"
```
