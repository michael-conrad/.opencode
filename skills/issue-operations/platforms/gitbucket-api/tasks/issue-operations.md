# GitBucket Issue Operations

## Overview

Issue CRUD operations using the `gb` CLI tool.

**Primary Tool: `gb` CLI**

**CRITICAL: The old `gitbucket-api` Python tool has been REMOVED. Use `gb` for all operations.**

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

## Chained Operations

### Workflow 1: Create Issue with Labels and Comments

```bash
# Step 1: Create issue with labels
gb issue create -t "Bug: Login fails on mobile" -R org/project --body "## Description\n\nLogin fails on mobile devices." --label bug,priority:high

# Step 2: Add welcome comment
gb issue comment <issue-number> -b "**Status:** Issue created and under investigation.\n\nWe'll look into this shortly." -R org/project
```

### Workflow 2: Parent/Child Issue Management

```bash
# Step 1: Create parent spec issue
gb issue create -t "[SPEC] Add OAuth2 Authentication" -R org/project --body "## Objective\n\nImplement OAuth2 authentication." --label enhancement,spec

# Step 2: Create child task issues (repeat for each phase)
gb issue create -t "[Task: #<parent>] Phase 1: OAuth2 Client Setup" -R org/project --body "Parent Issue: #<parent>\n\nImplement OAuth2 client setup." --label task

# Step 3: Add comment to parent listing children
gb issue comment <parent-number> -b "**Sub-issues created:**\n\n- #<child1>: OAuth2 Client Setup\n- #<child2>: Token Management" -R org/project
```

### Workflow 3: Close Issue with Summary Comment

```bash
# Step 1: Add completion comment
gb issue comment 14 -b "🤖 <AgentName> (<ModelId>) ✅ completed\n\n**Summary:**\n\nImplemented OAuth2 authentication with automatic token refresh.\n\n**Outcome:**\n\nUsers can now authenticate via OAuth2, and tokens refresh automatically without user intervention." -R org/project

# Step 2: Close issue
gb issue close 14 -R org/project
```

### Workflow 4: Batch Label Operations

**⚠️ CRITICAL: Post-creation label APIs are BROKEN in GitBucket.**

- `gb issue edit --add-label` may not apply labels via REST
- Labels can ONLY be reliably set during `gb issue create --label`

```bash
# ✅ WORKS: Set labels during issue creation
gb issue create -t "Bug report" -R org/project --body "Description" --label bug,priority:high,needs-review

# ❌ BROKEN: Cannot change labels after creation
# gb issue edit --add-label may not work depending on GitBucket version
```

**Workaround:** Delete and recreate the issue if labels need to change.

### Workflow 5: Find and Close Duplicate Issues

```bash
# Step 1: Get the canonical issue
gb issue view 14 -R org/project

# Step 2: List all open issues
gb issue list -R org/project --state open

# Step 3: Identify duplicates from the list

# Step 4: Close each duplicate with comment
gb issue comment <dup-number> -b "**Closing as duplicate of #14**\n\nThis issue is a duplicate and is being closed. Please continue discussion on #14." -R org/project
gb issue close <dup-number> -R org/project
```

### Workflow 6: Title Dedup Search (GitBucket Fallback)

When the platform lacks a search API, use iterative listing with client-side keyword filtering:

```bash
# Step 1: List open issues (most recent first)
gb issue list -R org/project --state open

# Step 2: List closed issues (most recent first)
gb issue list -R org/project --state closed

# Step 3: Client-side keyword filter — extract significant keywords from proposed title
# Remove stop words and prefixes like [SPEC], [SPEC-FIX], [Task:]
# Match issues whose titles share ≥2 significant keywords with proposed title

# Step 4: For each candidate match, read the full body
gb issue view <candidate-number> -R org/project

# Step 5: Classify match (EXACT-DUPLICATE, NEAR-DUPLICATE, CLOSED-IN-ERROR, RELATED-BUT-DISTINCT, FALSE-POSITIVE)
```

**Key difference from GitHub:** GitHub uses `github_search_issues` with a keyword query for server-side filtering. GitBucket requires fetching all issues and filtering client-side by keyword match and recency. Paginate only if no match found on first page.

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

## Complete API Reference

| Operation | gb Command | Status |
|-----------|------------|--------|
| Create issue | `gb issue create -t "<title>" -R O/R [--body ...] [--label ...]` | ✅ |
| Get issue | `gb issue view <N> -R O/R` | ✅ |
| Edit issue | `gb issue edit <N> -R O/R [--title ...] [--add-label ...]` | ✅ (web fallback) |
| Close issue | `gb issue close <N> -R O/R` | ✅ |
| Reopen issue | `gb issue reopen <N> -R O/R` | ✅ |
| List issues | `gb issue list -R O/R [--state ...]` | ✅ |
| Add comment | `gb issue comment <N> -b "<body>" -R O/R` | ✅ |
| Add labels | N/A | ❌ BROKEN (post-creation) |
| Replace labels | N/A | ❌ BROKEN (post-creation) |
| Remove label | N/A | ❌ BROKEN (post-creation) |
| Remove all labels | N/A | ❌ BROKEN (post-creation) |

## Source Code

- `gb` CLI — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- `gb` manages its own config via `gb auth login` — no environment variables needed
