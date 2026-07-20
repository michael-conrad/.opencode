# [SPEC] Mirror missing GitHub specs to local .issues/ tracking

## Problem

There are 211 GitHub issues on `michael-conrad/opencode-config` that have no corresponding local `.opencode/.issues/{N}/` directory. This means the local issues-data worktree is out of sync with the remote — agents working offline or in local-only mode cannot access these specs.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | All 211 GitHub-only issues are imported into `.opencode/.issues/{N}/` with spec.md bodies | `structural` | `ls .opencode/.issues/{N}/spec.md` for each imported issue |
| SC-2 | Each imported issue has correct title, body, and labels preserved from GitHub | `string` | grep title/labels in `issue.yaml` matches GitHub data |
| SC-3 | No local-only issues are duplicated or overwritten | `structural` | Pre-existing local issue dirs remain unchanged |

## Implementation

Use `issue-operations-sync --task import-remote` for each GitHub-only issue. The import-remote task reads the GitHub issue body and creates the local `.issues/{N}/` directory with `spec.md`, `issue.yaml`, and metadata files.

## Affected Files

- `.opencode/.issues/{N}/` (new directories for each of the 211 issues)
