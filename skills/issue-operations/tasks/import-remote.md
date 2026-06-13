# Task: import-remote

## Purpose

Retroactively import a pre-existing remote issue into the local `.issues/` directory. Creates a full local mirror with issue body, comments, and frontmatter. Used when a remote issue was created outside the local-first workflow and needs local tracking.

## Entry Criteria

- Remote issue number identified and verified to exist
- Issue has NOT been previously imported (no `remote_issue` or same-number local issue exists)
- `github.owner`, `github.repo`, `github.platform` available from session context
- Issue comments accessible via platform API

## Exit Criteria

- Full local mirror created at `.issues/open/<remote_number>-<slug>/remote.md` (remote body) and `spec.md` (local frontmatter)
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
Route to `platforms/local/tasks/read.md` via task(). Pass: `{issue_number: N}`.

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

If `.issues/` directory does not exist, route to `platforms/local/tasks/creation.md` via task() with setup action. The local-issues tool handles worktree setup transparently.

### Step 4: Create Local Issue

Create the local issue directory manually (not via `local-issues create`, because we need to set the number to match the remote):

1. Determine slug from title: first 5 words, kebab-cased
1. Create directory: `.issues/open/<remote_number>/`
1. Write `remote.md` with minimal frontmatter + full remote body:

```yaml
---
remote_issue: <remote_number>
remote_url: "<html_url>"
last_sync: <import_timestamp>
source: <github.platform>
---

<full_remote_issue_body>
```

4. Write `spec.md` with local frontmatter only — the remote body is NEVER written to spec.md, only to remote.md above:

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

1. Read remote.md: body matches remote; Read spec.md: frontmatter has all required fields (verify no remote body content)
1. Read comments.md: all comments present, ordered chronologically
1. Verify counter: `cat .issues/.counter` shows `remote_number + 1` or greater

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
- Related tasks: `read-issue`, `read-comments` (both called internally), `platforms/local/tasks/creation.md` for setup (if .issues/ missing)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- No direct `github_*` or `gitbucket-api` calls outside `issue-operations/platforms/`

## Live Verification: Import Evidence (MANDATORY)

| Claim | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "remote.md exists (body)" | Verify file at `.issues/open/NNN/remote.md` | `local-issues read <number>` | MISSING-ELEMENT |
| "spec.md exists (frontmatter only)" | Verify file at `.issues/open/NNN/spec.md` | `local-issues read <number>` | MISSING-ELEMENT |
| "comments.md exists with all comments" | Verify file and comment count matches remote | `cat .issues/open/NNN/comments.md \| wc -l` | MISSING-ELEMENT |
| "promotion_type in frontmatter" | Verify `promotion_type: retroactive_import` present | `local-issues read <number>` → parse frontmatter | STRUCTURE-VIOLATION |
| "Counter advanced correctly" | Verify `.counter` value >= remote_number + 1 | `cat .issues/.counter` | VERIFICATION-GAP |
| "Body matches remote (remote.md)" | Compare remote.md body against remote issue body | `local-issues read <number>` | VERIFICATION-GAP |
| "spec.md has no remote body" | Verify spec.md has no body content below frontmatter | `local-issues read <number>` → check body is empty after frontmatter | VERIFICATION-GAP |

**Evidence artifact:** remote.md readback showing body, spec.md readback showing frontmatter only, comments.md showing imported comments, .counter value.
