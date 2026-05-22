# Task: import-remote

## Purpose

Retroactively import a pre-existing remote issue into the local `.issues/` directory. Creates a full local mirror with issue body, comments, and frontmatter. Used when a remote issue was created outside the local-first workflow and needs local tracking.

## Entry Criteria

- Remote issue number identified and verified to exist
- Issue has NOT been previously imported (no `remote_issue` or same-number local issue exists)
- `github.owner`, `github.repo`, `github.platform` available from session context
- Issue comments accessible via platform API

## Exit Criteria

- Full local mirror created at `.issues/open/<remote_number>-<slug>/spec.md`
- Comments imported to `.issues/open/<remote_number>-<slug>/comments.md`
- Frontmatter written with remote metadata and `promotion_type: retroactive_import`
- `.counter` advanced if `counter <= remote_number`

## Procedure

### Step 1: Read Remote Issue

Route based on `github.platform` to read the full issue:

**GitHub platform:**

```python
github_issue_read(
    method="get",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N
)
```

**GitBucket platform:**

```bash
./.opencode/tools/gitbucket-api get-issue <github.owner> <github.repo> <issue-number>
```

**Local platform:**

```bash
./.opencode/tools/local-issues read <issue-number>
```

Extract: title, body, html_url, state, labels, author, created_at, updated_at.

### Step 2: Read Remote Comments

Fetch all comments for the issue:

**GitHub platform:**

```python
github_issue_read(
    method="get_comments",
    owner=<github.owner>,
    repo=<github.repo>,
    issue_number=N
)
```

**GitBucket platform:**

```bash
./.opencode/tools/gitbucket-api list-comments <github.owner> <github.repo> <issue-number>
```

Collect each comment's author, timestamp, and body text.

### Step 3: Ensure .issues/ Exists

If `.issues/` directory does not exist, call `local-issues setup`:

```bash
./.opencode/tools/local-issues setup
```

**Exit code handling:**

| Exit Code | Meaning | Action |
|-----------|---------|--------|
| 0 | Success | Continue |
| 1 | Fatal error | HALT and report stderr |
| 2 | Stale worktree detected | Read stale path from stderr, run `git worktree remove <stale_path>`, re-run `local-issues setup` |

### Step 4: Create Local Issue

Create the local issue directory manually (not via `local-issues create`, because we need to set the number to match the remote):

1. Determine slug from title: first 5 words, kebab-cased
2. Create directory: `.issues/open/<remote_number:03d>-<slug>/`
3. Write `spec.md` with:

```yaml
---
number: <remote_number>
title: "<remote_title>"
status: open
labels: [<remote_labels>]
created: <remote_created_at>
updated: <remote_updated_at>
remote_issue: <remote_number>
remote_url: "<html_url>"
promoted_at: <import_timestamp>
promotion_type: retroactive_import
last_sync: <import_timestamp>
author: <remote_author>
---

<full_remote_issue_body>
```

### Step 5: Import Comments

Write all fetched comments to `.issues/open/<remote_number>-<slug>/comments.md`:

```markdown
---

## YYYY-MM-DDTHH:MM:SSZ

**<author>**:

<comment_body>
```

Each comment gets its own `---` separator and timestamp header. Order by oldest first.

### Step 6: Advance .counter

Read `.issues/.counter`. If `counter <= remote_number`, advance the counter to `remote_number + 1` to prevent number collision:

```bash
echo $((remote_number + 1)) > .issues/.counter
```

If `counter > remote_number`, leave the counter unchanged (local issues already exist beyond this number).

### Step 7: Verify Import

Verify the full local mirror:

1. Read spec.md: body matches remote, frontmatter has all required fields
2. Read comments.md: all comments present, ordered chronologically
3. Verify counter: `cat .issues/.counter` shows `remote_number + 1` or greater

## Edge Cases

| Case | Resolution |
| -- | -- |
| Issue already imported (matching `remote_issue` found) | HALT — report already imported, provide path |
| Issue number conflicts with existing local issue | Use next available number, record remote_number in frontmatter |
| Remote issue is closed | Import as closed: create in `.issues/closed/` with `status: closed` |
| Remote has zero comments | Write empty `comments.md` |
| Remote body is empty | Write "*(No body content)*" placeholder |
| Platform API returns error | HALT — report the error, do not create partial import |
| `.issues/` setup fails | HALT — report setup error |

## Context Required

- Session values: github.owner, github.repo, github.platform
- Issue number to import
- Related tasks: `read-issue`, `read-comments` (both called internally), `local-issues setup` (if .issues/ missing)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`

## Live Verification: Import Evidence (MANDATORY)

| Claim | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "spec.md exists" | Verify file at `.issues/open/NNN-slug/spec.md` | `local-issues read <number>` | MISSING-ELEMENT |
| "comments.md exists with all comments" | Verify file and comment count matches remote | `cat .issues/open/NNN-slug/comments.md \| wc -l` | MISSING-ELEMENT |
| "promotion_type in frontmatter" | Verify `promotion_type: retroactive_import` present | `local-issues read <number>` → parse frontmatter | STRUCTURE-VIOLATION |
| "Counter advanced correctly" | Verify `.counter` value >= remote_number + 1 | `cat .issues/.counter` | VERIFICATION-GAP |
| "Body matches remote" | Compare local body against remote issue body | `local-issues read <number>` | VERIFICATION-GAP |

**Evidence artifact:** spec.md readback showing body + frontmatter, comments.md showing imported comments, .counter value.
