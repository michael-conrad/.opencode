# GitBucket CLI Operations

## Overview

GitBucket operations use the `gb` CLI tool. This replaces both MCP tools and the old `gitbucket-api` Python tool for all operations.

**Delegation:** Workflow-level `gb` command sequences (issue triage, PR creation/review, label/milestone/repository management, search, API requests) are delegated to the `gb-cli` skill task cards. This task retains platform-scoped routing: tool detection, auth verification, error classification, and the tool-selection decision tree. Read [the gb-cli skill](../../../../gb-cli/SKILL.md) for workflow-level command coverage.

## TOOL_MISSING Detection

Before any `gb` command, verify the tool is available:

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found. Install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs"
  return 1
fi
```

## Version Check

Verify `gb` version >= 0.6.1 before proceeding:

```bash
GB_VERSION=$(gb --version 2>/dev/null | grep -oP '[\d]+\.[\d]+\.[\d]+' | head -1)
if [ -z "$GB_VERSION" ]; then
  echo "VERSION_CHECK_FAILED: Could not determine gb version"
  return 1
fi
if ! printf '%s\n' "0.6.1" "$GB_VERSION" | sort -V | head -1 | grep -q "^0.6.1$"; then
  echo "VERSION_CHECK_FAILED: gb $GB_VERSION < required 0.6.1"
  return 1
fi
```

## Workflow-Level Delegation

Workflow-level `gb` operations are delegated to the `gb-cli` skill task cards:

| Workflow | gb-cli Task Card |
|----------|------------------|
| Issue triage (list/view/edit/comment/close) | `gb-cli/tasks/triage-issues.md` |
| PR creation | `gb-cli/tasks/create-pr.md` |
| PR review | `gb-cli/tasks/review-pr.md` |
| Repository management | `gb-cli/tasks/manage-repo.md` |
| Label management | `gb-cli/tasks/manage-labels.md` |
| Milestone management | `gb-cli/tasks/manage-milestones.md` |
| Search and investigation | `gb-cli/tasks/search-investigate.md` |
| API passthrough | `gb-cli/tasks/api-requests.md` |
| Authentication | `gb-cli/tasks/authenticate.md` |

Read [the gb-cli skill](../../../../gb-cli/SKILL.md) for the full workflow dispatch contracts.

## Tool Selection Decision Tree

```
Is operation a workflow-level gb operation?
    ├─ YES → Delegate to gb-cli task card
    │         ├─ Success → Return result
    │         └─ Failure → Log error, check auth with gb auth status
    └─ NO → Use gb api passthrough
              ├─ Success → Return result
              └─ Failure → Report missing command, HALT
```

## Error Classification

### CLI Error (Retry or Check Credentials)

```bash
gb auth status
# If auth fails, run gb auth status
```

### API Error (Classified)

```bash
gb issue view 999 -R org/nonexistent
# Error: 404 Not Found - Check owner/repo names

gb issue list -R org/project
# Error: 401 Unauthorized - Check gb auth status

gb issue create -t "Test" -R org/project
# Error: 422 Unprocessable Entity - Check request body format
```

## Label Operations (Post-Creation Label Mutation Works)

GitBucket supports adding and changing labels after issue creation via `gb` subcommands or `gb api` passthrough. Workflow-level label operations are delegated to the `gb-cli` manage-labels task card. Read [the gb-cli manage-labels task card](../../../../gb-cli/tasks/manage-labels.md).

## Admin Operations

Admin operations are not available via the `gb` CLI. Use the GitBucket web UI for admin tasks.

## Source Code

- `gb` CLI tool — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- `gb` manages its own config via `gb auth login` — no environment variables needed
