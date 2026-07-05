# GitBucket Repository Operations

## Overview

Repository management operations using the `gb` CLI tool.

## Default Branch Resolution

```bash
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p')
if [ -z "$DEFAULT_BRANCH" ]; then DEFAULT_BRANCH="main"; fi
```

**Primary Tool: `gb` CLI**

**CRITICAL: The old `gitbucket-api` Python tool has been REMOVED. Use `gb` for all operations.**

## TOOL_MISSING Detection

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found"
  return 1
fi
```

## Basic Operations

### Get Repository

```bash
gb repo view org/project
```

### List User's Repositories

```bash
# List own repositories
gb repo list

# List repositories for a specific user
gb repo list username
```

### List Branches

```bash
gb api repos/org/project/branches -R org/project
```

### List Pull Requests

```bash
gb pr list -R org/project --state open
```

### Get Pull Request

```bash
gb pr view 42 -R org/project
```

## Chained Operations

### Workflow 1: Check Branch Status Before Creating PR

```bash
# Step 1: Check if branch exists
gb api repos/org/project/branches -R org/project

# Step 2: Check for existing PRs for this branch
gb pr list -R org/project --state open

# Step 3: Create new PR (if no existing PR found)
gb pr create -t "Feature: feature/oauth2" --head feature/oauth2 -B "$DEFAULT_BRANCH" -R org/project --body "## Description\n\nImplements OAuth2 authentication."
```

### Workflow 2: Find Stale Branches

```bash
# List all branches
gb api repos/org/project/branches -R org/project
# Then filter out protected branches (main, master, $DEFAULT_BRANCH) and identify stale ones
```

### Workflow 3: Repository Health Check

```bash
# Check for required labels
gb label list -R org/project

# Check for open PRs
gb pr list -R org/project --state open

# Get repository info
gb repo view org/project

# Check branches
gb api repos/org/project/branches -R org/project
```

### Workflow 4: Sync Fork with Upstream

```bash
# Get repository info
gb repo view org/fork-repo
# Check if it's a fork and get upstream info from response
```

### Workflow 5: Create Release from Milestone

```bash
# Note: Release/milestone operations require gb api passthrough
# gb api repos/org/project/releases -X POST --input body.json
```

## Complete API Reference

| Operation | gb Command | Returns |
|-----------|------------|---------|
| Get repository | `gb repo view O/R` | JSON |
| List own repos | `gb repo list` | JSON array |
| List user repos | `gb repo list <user>` | JSON array |
| List branches | `gb api repos/O/R/branches -R O/R` | JSON array |
| List PRs | `gb pr list -R O/R [--state ...]` | JSON array |
| Get PR | `gb pr view <N> -R O/R` | JSON |
| Create PR | `gb pr create -t "<title>" --head <b> -B <b> -R O/R [--body ...]` | JSON |

## Source Code

- `gb` CLI — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- Environment: `GB_TOKEN`, `GB_HOST`, `GB_REPO`
