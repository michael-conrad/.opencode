# GitBucket Issue Operations

## Overview

Issue CRUD operations using the `gb` CLI tool.

**Primary Tool: `gb` CLI**

**CRITICAL: The old `gitbucket-api` Python tool has been REMOVED. Use `gb` for all operations.**

**Delegation:** Workflow-level issue operations (triage, chained workflows, search/dedup) are delegated to the `gb-cli` skill task cards. This task retains issue CRUD routing: the core `gb issue` command surface and response-type handling. Read [the gb-cli triage-issues task card](../../../../gb-cli/tasks/triage-issues.md) for workflow-level issue sequences.

## TOOL_MISSING Detection

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found"
  return 1
fi
```

## Response Types

**ALL `list` commands return JSON arrays:**
- `gb issue list --json --no-pager` → JSON array
- `gb issue view <number> --json --no-pager` → JSON object

**Always check type before iterating:**
```bash
# List returns JSON array
gb issue list -R org/project --state open --json --no-pager

# Get single issue returns JSON object
gb issue view 14 -R org/project --json --no-pager
```

## Basic Operations

### Create Issue

```bash
gb issue create -t "Issue title" -R org/project --body "Issue body" --label enhancement,bug
```

**Fields supported:**
- `-t <title>` (required) - Issue title
- `--body` (optional) - Issue description
- `--label` (optional, comma-separated) - Label names (auto-created)

### Get Issue

```bash
gb issue view 14 -R org/project
```

### Edit Issue

```bash
gb issue edit 14 -R org/project --title "Updated title" --add-label urgent
```

Uses web fallback for title/body/assignee/milestone/state updates. Label edits require REST support from the target GitBucket.

### List Issues

```bash
gb issue list -R org/project --state open
```

### Add Comment

```bash
gb issue comment 14 -b "Comment text" -R org/project
```

## Workflow-Level Delegation

Chained issue workflows (create-with-labels-and-comments, parent/child management, close-with-summary, batch label operations, duplicate detection, title dedup search) are delegated to the `gb-cli` skill task cards:

| Workflow | gb-cli Task Card |
|----------|------------------|
| Issue triage (list/view/edit/comment/close) | `gb-cli/tasks/triage-issues.md` |
| Search and dedup (iterative listing + client-side filter) | `gb-cli/tasks/search-investigate.md` |
| Label operations | `gb-cli/tasks/manage-labels.md` |
| End-to-end workflows | `gb-cli/tasks/common-workflows.md` |

Read [the gb-cli skill](../../../../gb-cli/SKILL.md) for the full workflow dispatch contracts.

## Error Handling

The `gb` CLI outputs structured error information:

```bash
# 401 - Authentication error
gb auth status

# 404 - Repo doesn't exist
gb issue view 999 -R org/nonexistent
# Error: 404 Not Found

# 422 - Invalid input
gb issue create -t "Test" -R org/project --label "invalid label!"
# Error: 422 Unprocessable Entity
```

## Source Code

- `gb` CLI — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- `gb` manages its own config via `gb auth login` — no environment variables needed
