# GitBucket CLI Operations

## Overview

GitBucket operations use the `gb` CLI tool. This replaces both MCP tools and the old `gitbucket-api` Python tool for all operations.

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

## CLI Command Reference

| Operation | gb Command | Status |
|-----------|------------|--------|
| Get issue | `gb issue view <number> -R owner/repo` | ✅ |
| Create issue | `gb issue create -t "<title>" -R owner/repo [--body "..."] [--label l1,l2]` | ✅ |
| Edit issue | `gb issue edit <number> -R owner/repo [--title ...] [--add-label ...] [--remove-label ...]` | ✅ (web fallback) |
| Close issue | `gb issue close <number> -R owner/repo` | ✅ |
| Reopen issue | `gb issue reopen <number> -R owner/repo` | ✅ |
| Add comment | `gb issue comment <number> -b "<body>" -R owner/repo` | ✅ |
| List issues | `gb issue list -R owner/repo [--state open\|closed\|all]` | ✅ |
| Get repository | `gb repo view owner/repo` | ✅ |
| List repos | `gb repo list [owner]` | ✅ |
| Create repo | `gb repo create <name> [-g group]` | ✅ |
| List branches | `gb api repos/owner/repo/branches -R owner/repo` | ✅ (passthrough) |
| List PRs | `gb pr list -R owner/repo [--state open\|closed\|all]` | ✅ |
| Get PR | `gb pr view <number> -R owner/repo` | ✅ |
| Create PR | `gb pr create -t "<title>" --head <branch> -B <base> -R owner/repo` | ✅ |
| Edit PR | `gb pr edit <number> -R owner/repo [--add-assignee ...]` | ✅ |
| Merge PR | `gb pr merge <number> -R owner/repo` | ✅ |
| Close PR | `gb pr close <number> -R owner/repo` | ✅ |
| PR diff | `gb pr diff <number> -R owner/repo` | ✅ |
| PR comment | `gb pr comment <number> -b "<body>" -R owner/repo` | ✅ |
| List labels | `gb label list -R owner/repo` | ✅ |
| Create label | `gb label create <name> --color <hex> [--description "..."] -R owner/repo` | ✅ |
| View label | `gb label view <name> -R owner/repo` | ✅ |
| Edit label | `gb label edit <name> -R owner/repo [--name ...] [--color ...] [--description ...]` | ✅ |
| Delete label | `gb label delete <name> --yes -R owner/repo` | ✅ |
| Get current user | `gb auth status` | ✅ |
| Validate auth | `gb auth status` | ✅ |
| API passthrough | `gb api <endpoint> [-X method] [--input ...]` | ✅ |

## CLI-First Workflow

**For all operations:**

```bash
# Create issue
gb issue create -t "Bug fix" -R org/project --body "Description" --label bug,enhancement

# Get issue
gb issue view 14 -R org/project

# List issues
gb issue list -R org/project --state open
```

## Tool Selection Decision Tree

```
Is operation in gb command table?
    ├─ YES → Use gb subcommand
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

## Label Operations (Labels Can ONLY Be Set During Creation)

GitBucket does **not** support adding labels after issue creation. Use `--label` during creation:

```bash
# ✅ WORKS: Set labels during issue creation
gb issue create -t "Bug report" -R org/project --body "Description" --label bug,enhancement

# ❌ BROKEN: Cannot change labels after creation
# gb issue edit supports --add-label/--remove-label but GitBucket REST may not apply them
```

## Admin Operations

Admin operations are not available via the `gb` CLI. Use the GitBucket web UI for admin tasks.

## Source Code

- `gb` CLI tool — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- `gb` manages its own config via `gb auth login` — no environment variables needed
