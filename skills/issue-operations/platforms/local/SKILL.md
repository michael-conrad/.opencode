---
name: local
description: Local .issues/ directory platform for issue tracking. Used when github.platform is local or unset. Routes all issue operations to .issues/ directory with YAML frontmatter and markdown files.
type: technique
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: local-issues Platform

## Overview

Local issue tracking platform using `.issues/` directories at the repo root. This platform is selected when `github.platform` is `local` or when no remote is configured.

## Architecture

```
.issues/
  .counter                  # Next issue number (auto-incremented)
  open/
    001-slug/spec.md         # Issue body (markdown + YAML frontmatter)
    001-slug/comments.md     # Comments/updates (append-only)
  closed/
    002-slug/spec.md
    002-slug/comments.md
```

## Capabilities

| Capability | Supported | Method |
|-----------|-----------|--------|
| Create issue | Yes | `local-issues create` |
| Read issue | Yes | `local-issues read` |
| Review issue | Yes | `local-issues review` |
| Update issue | Yes | `local-issues update` |
| Comment on issue | Yes | `local-issues comment` |
| Close issue | Yes | `local-issues close` |
| Link sub-issues | Partial | Comments with `#` references (no formal sub-issue API) |
| Search issues | Yes | `local-issues search` |
| List issues | Yes | `local-issues list` |
| Labels | Yes | YAML frontmatter array |
| Promotion to GitHub | Yes | `local-issues link --github NNN` + manual promotion via issue-operations |
| Assignees | No | N/A |
| Milestones | No | N/A |
| Reactions | No | N/A |

## Invocation

All operations go through `.opencode/tools/local-issues` CLI:

```bash
local-issues create --title "TITLE" --labels L1,L2
local-issues read NNN
local-issues review NNN
local-issues update NNN [--title T] [--status S] [FIELD=VALUE]
local-issues comment NNN --body "TEXT"
local-issues close NNN
local-issues link NNN --github NUM
local-issues search [--status S] [--labels L1,L2] [--query TEXT]
local-issues list [--status S]
```

## Task: review

Pretty-print a local issue spec to stdout for developer review. Renders the spec body as markdown with a metadata table (number, status, labels, author, timestamps, GitHub link) and any existing comments.

**Invocation:**

```bash
local-issues review NNN
```

**Use case:** When a developer needs to review a local spec before approving it, run `review` to get a clean, markdown-renderable output of the full spec including frontmatter metadata and comment history.

## Task: comment

Append a comment to a local issue's `comments.md` with an ISO timestamp separator.

**Invocation:**

```bash
local-issues comment NNN --body "TEXT"
```

**Comment format:**

```markdown
---

## 2026-04-25T12:00:00Z

TEXT
```

**Use case:** When a developer or agent needs to add a comment to a local issue (approval, status update, feedback), use `comment` to append to the comments file.

## Promotion Workflow

When `github.platform` is NOT `local` (i.e., a remote is available), local issues can be promoted to GitHub Issues:

1. Create local issue first (working draft)
2. On authorization event, promote content to GitHub Issue via `issue-operations --task creation`
3. Link local issue to GitHub issue: `local-issues link NNN --github GITHUB_NUM`
4. Add comment on GitHub Issue referencing local path

## Worktree Exemption

`.issues/` files are non-behavioral metadata. They are exempt from the worktree requirement per `060-tool-usage.md` §Worktree Exemption, but NOT exempt from the branching requirement (no direct commits to `dev`/`main`).

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `create` | When creating a local issue | Title, body, labels, .issues/ path | Implementation context, agent memory | NO |
| `read` | When reading a local issue | Issue number, .issues/ path | Implementation context, agent memory | NO |
| `review` | When reviewing a local issue | Issue number, .issues/ path | Implementation context, agent memory | NO |
| `update` | When updating a local issue | Issue number, fields, .issues/ path | Implementation context, agent memory | NO |
| `comment` | When commenting on a local issue | Issue number, comment body, .issues/ path | Implementation context, agent memory | NO |
| `close` | When closing a local issue | Issue number, .issues/ path | Implementation context, agent memory | NO |
| `link` | When linking local issue to GitHub | Local issue number, GitHub issue number, .issues/ path | Implementation context, agent memory | NO |
| `search` | When searching local issues | Search query, .issues/ path | Implementation context, agent memory | NO |
| `list` | When listing local issues | Status filter, labels, .issues/ path | Implementation context, agent memory | NO |