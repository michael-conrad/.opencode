# GitBucket Label Operations

## Overview

GitBucket label operations using the `gb` CLI tool.

## TOOL_MISSING Detection

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found"
  return 1
fi
```

## Add Labels to Issue

**✅ WORKING: issue-level label mutation via `gb api` passthrough**

The GitBucket API endpoint `POST /repos/{owner}/{repo}/issues/{number}/labels` applies labels to the issue. Use `gb api` passthrough with a JSON body containing the `labels` array.

### CLI

```bash
# ✅ WORKING: Add labels to an existing issue via gb api passthrough
echo '{"labels":["bug"]}' | gb api "repos/org/project/issues/14/labels" -R org/project -X POST -i -
```

## Replace All Labels

**✅ WORKING: issue-level label mutation via `gb api` passthrough**

The GitBucket API endpoint `PUT /repos/{owner}/{repo}/issues/{number}/labels` replaces all labels on the issue. Use `gb api` passthrough with a JSON body containing the `labels` array.

### CLI

```bash
# ✅ WORKING: Replace all labels on an existing issue via gb api passthrough
echo '{"labels":["priority","review"]}' | gb api "repos/org/project/issues/14/labels" -R org/project -X PUT -i -
```

## Remove Specific Label

**✅ WORKING: issue-level label mutation via `gb api` passthrough**

The GitBucket API endpoint `DELETE /repos/{owner}/{repo}/issues/{number}/labels/{name}` removes a specific label from the issue. Use `gb api` passthrough.

### CLI

```bash
# ✅ WORKING: Remove a specific label from an existing issue via gb api passthrough
gb api "repos/org/project/issues/14/labels/bug" -R org/project -X DELETE -i -
```

## Remove All Labels

**✅ WORKING: issue-level label mutation via `gb api` passthrough**

The GitBucket API endpoint `DELETE /repos/{owner}/{repo}/issues/{number}/labels` removes all labels from the issue. Use `gb api` passthrough.

### CLI

```bash
# ✅ WORKING: Remove all labels from an existing issue via gb api passthrough
gb api "repos/org/project/issues/14/labels" -R org/project -X DELETE -i -
```

## Repository Labels

### List Labels

```bash
gb label list -R org/project
```

### Create Label

```bash
gb label create bug --color fc2929 --description "Broken behavior" -R org/project
```

### View Label

```bash
gb label view bug -R org/project
```

### Edit Label

```bash
gb label edit bug --name defect --color cc0000 --description "Confirmed defect" -R org/project
```

### Delete Label

```bash
gb label delete bug --yes -R org/project
```

## Tool Selection

| Operation | gb Command | Status |
|-----------|------------|--------|
| Add labels | `gb api "repos/O/R/issues/{number}/labels" -X POST` | ✅ WORKING |
| Replace labels | `gb api "repos/O/R/issues/{number}/labels" -X PUT` | ✅ WORKING |
| Remove label | `gb api "repos/O/R/issues/{number}/labels/{name}" -X DELETE` | ✅ WORKING |
| Remove all labels | `gb api "repos/O/R/issues/{number}/labels" -X DELETE` | ✅ WORKING |
| List labels | `gb label list -R O/R` | ✅ |
| Create label | `gb label create <name> --color <hex> -R O/R` | ✅ |
| View label | `gb label view <name> -R O/R` | ✅ |
| Edit label | `gb label edit <name> -R O/R` | ✅ |
| Delete label | `gb label delete <name> --yes -R O/R` | ✅ |

## Error Handling

```bash
# 422 - Invalid label name or format
gb issue create -t "Test" -R org/project --label "invalid label!"
# Error output will indicate validation failure
```

## Source Code

- `gb` CLI — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- `gb` manages its own config via `gb auth login` — no environment variables needed
