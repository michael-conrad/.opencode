# GitBucket Label Operations

## Overview

GitBucket label operations using the `gb` CLI tool.

**Delegation:** Workflow-level label operations (list/create/view/edit/delete repository labels, issue-level label mutation) are delegated to the `gb-cli` skill task cards. This task retains label routing logic: the post-creation label mutation capability via `gb api` passthrough and the repository label command surface. Read [the gb-cli manage-labels task card](../../../../gb-cli/tasks/manage-labels.md) for workflow-level label sequences.

## TOOL_MISSING Detection

```bash
if ! command -v gb &>/dev/null; then
  echo "TOOL_MISSING: gb CLI not found"
  return 1
fi
```

## Issue-Level Label Mutation (Post-Creation)

**✅ WORKING: issue-level label mutation via `gb api` passthrough**

The GitBucket API endpoint `POST /repos/{owner}/{repo}/issues/{number}/labels` applies labels to the issue. Use `gb api` passthrough with a JSON body containing the `labels` array.

### Add Labels to Issue

```bash
# ✅ WORKING: Add labels to an existing issue via gb api passthrough
echo '{"labels":["bug"]}' | gb api "repos/org/project/issues/14/labels" -R org/project -X POST -i -
```

### Replace All Labels

```bash
# ✅ WORKING: Replace all labels on an existing issue via gb api passthrough
echo '{"labels":["priority","review"]}' | gb api "repos/org/project/issues/14/labels" -R org/project -X PUT -i -
```

### Remove Specific Label

```bash
# ✅ WORKING: Remove a specific label from an existing issue via gb api passthrough
gb api "repos/org/project/issues/14/labels/bug" -R org/project -X DELETE -i -
```

### Remove All Labels

```bash
# ✅ WORKING: Remove all labels from an existing issue via gb api passthrough
gb api "repos/org/project/issues/14/labels" -R org/project -X DELETE -i -
```

## Repository Label Routing

Repository label operations (list/create/view/edit/delete) are delegated to the `gb-cli` manage-labels task card. Read [the gb-cli manage-labels task card](../../../../gb-cli/tasks/manage-labels.md).

## Error Handling

```bash
# 422 - Invalid label name or format
gb issue create -t "Test" -R org/project --label "invalid label!"
# Error output will indicate validation failure
```

## Source Code

- `gb` CLI — install from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs
- `gb` manages its own config via `gb auth login` — no environment variables needed
