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

**⚠️ BROKEN: Returns empty array `[]`, labels are NOT added**

The GitBucket API endpoint `POST /repos/{owner}/{repo}/issues/{number}/labels` returns HTTP 200 with an empty array but does NOT add labels to the issue.

**Workaround:** Add labels during issue creation with `gb issue create --label`.

### CLI (Only Option)

```bash
# ❌ BROKEN: gb issue edit --add-label may not apply via REST

# ✅ WORKAROUND: Add labels during issue creation
gb issue create -t "Bug report" -R org/project --body "Description" --label bug,enhancement
```

## Replace All Labels

**⚠️ BROKEN: Returns empty array `[]`, labels are NOT set**

The GitBucket API endpoint `PUT /repos/{owner}/{repo}/issues/{number}/labels` returns HTTP 200 with an empty array but does NOT set labels on the issue.

**Workaround:** Add labels during issue creation with `gb issue create --label`.

### CLI (Only Option)

```bash
# ❌ BROKEN: No gb command for label replacement

# ✅ WORKAROUND: Add labels during issue creation
gb issue create -t "Bug report" -R org/project --body "Description" --label priority,review
```

## Remove Specific Label

**⚠️ BROKEN: No gb command for post-creation label removal.**

## Remove All Labels

**⚠️ BROKEN: No gb command for post-creation label removal.**

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
| Add labels | N/A | ⚠️ BROKEN (returns `[]`) |
| Replace labels | N/A | ⚠️ BROKEN (returns `[]`) |
| Remove label | N/A | ⚠️ BROKEN |
| Remove all labels | N/A | ⚠️ BROKEN |
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
- Environment: `GB_TOKEN`, `GB_HOST`, `GB_REPO`
