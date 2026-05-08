---
name: local
description: Use when local .issues/ tracking is needed. Local .issues/ directory platform for issue tracking. Used when github.platform is local or unset. Routes all issue operations to .issues/ directory with YAML frontmatter and markdown files.
type: discipline-enforcing
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
| Promotion to remote | Yes | `local-issues promote` + remote API |
| Sync with remote | Yes | `local-issues sync` with classification |
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
local-issues promote NNN --remote-url <url>
local-issues sync NNN [--direction pull|push|bidirectional]
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

## Task: promotion

Promote a local issue to remote issue tracker (GitHub or GitBucket). Creates a remote copy with exec-summary style body.

**Invocation:**

```bash
local-issues promote NNN --remote-url <url>
```

**Process:**

1. Read local issue from `.issues/open/NNN-slug/spec.md`
2. Extract exec-summary version (first section or explicit `## Summary`)
3. Create remote issue via platform API (GitHub MCP or gitbucket-api)
4. Record remote metadata in local frontmatter:

```yaml
remote_issue: <remote-number>
remote_url: <html_url>
promoted_at: <timestamp>
promotion_type: manual | auto
```

**Use case:** When a local spec is ready for stakeholder review, promote it to GitHub for visibility and approval workflow.

## Task: sync

Synchronize local and remote issue state. Pull remote updates to local, push local changes to remote (with classification).

**Invocation:**

```bash
local-issues sync NNN [--direction pull|push|bidirectional]
```

**Direction options:**

| Direction | Action |
|-----------|--------|
| `pull` | Fetch remote issue, merge changes into local `.issues/` |
| `push` | Push local changes to remote (with classification) |
| `bidirectional` | Pull first, then push if local has newer changes |

**Classification (for push):**

| Change Type | Auto-Sync? | Action |
|-------------|-----------|--------|
| Correction/clarification | Yes | Push without confirmation |
| Scope/intent change | No | Flag for developer review |
| Uncertain | No | Flag conservative (don't auto-sync) |

**Use case:** Keep local full-fidelity copy in sync with remote concise copy while preserving developer approval workflow.

## Authorization Labels

The local platform supports all eight `approved-for-*` labels in YAML frontmatter. Labels are stored as a frontmatter array field.

| Label | Purpose |
|---|---|
| `approved-for-spec` | Authorization through spec creation |
| `approved-for-plan` | Authorization through plan creation |
| `approved-for-implementation` | Authorization through implementation |
| `approved-for-code-review` | Authorization through code review |
| `approved-for-pr` | Full pipeline through PR creation |
| `approved-for-pr-only` | PR creation only |
| `approved-for-review` | Code review only |
| `approved-for-review-prep` | Default authorization |

`needs-approval` is the default label for unapproved issues. It is applied on creation and replaced by the corresponding `approved-for-*` label at time of authorization. No `approved-for-*` label = awaiting approval. Label replacement on re-authorization updates the frontmatter array.

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
| `pre-analysis` | Before any execution sub-agent dispatch, determine scope independently | Issue number, task description, github.owner, github.repo | File paths, line numbers, expected outcomes, orchestrator reasoning | NO |
| `completion` | When workflow halts at any point | Workflow state | Implementation context, agent memory | NO |