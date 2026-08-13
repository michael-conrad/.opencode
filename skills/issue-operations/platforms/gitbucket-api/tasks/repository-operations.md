# GitBucket Repository Operations

## Overview

Repository management operations using the `gb` CLI tool.

**Delegation:** Workflow-level repository operations (create/fork/list/view/clone/delete, branch status checks, PR workflows, health checks, fork sync, releases) are delegated to the `gb-cli` skill task cards. This task retains repo routing logic: default branch resolution and the core `gb repo` command surface. Read [the gb-cli manage-repo task card](../../../../gb-cli/tasks/manage-repo.md) for workflow-level repository sequences.

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

## Workflow-Level Delegation

Chained repository workflows (branch status before PR, stale branch detection, health check, fork sync, release from milestone) are delegated to the `gb-cli` skill task cards:

| Workflow | gb-cli Task Card |
|----------|------------------|
| Repository management (create/fork/list/view/clone/delete) | `gb-cli/tasks/manage-repo.md` |
| PR creation | `gb-cli/tasks/create-pr.md` |
| PR review | `gb-cli/tasks/review-pr.md` |
| Search and investigation | `gb-cli/tasks/search-investigate.md` |
| API passthrough (releases, branches) | `gb-cli/tasks/api-requests.md` |
| End-to-end workflows | `gb-cli/tasks/common-workflows.md` |

Read [the gb-cli skill](../../../../gb-cli/SKILL.md) for the full workflow dispatch contracts.

## Source Code

- `gb` CLI — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- `gb` manages its own config via `gb auth login` — no environment variables needed
