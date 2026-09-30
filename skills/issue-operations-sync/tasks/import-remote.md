# Task: import-remote

## Purpose

Retroactively import a pre-existing remote issue into the local `.issues/` directory. Creates a full local mirror with issue body, comments, and frontmatter. Used when a remote issue was created outside the local-first workflow and needs local tracking.

## Entry Criteria

- Remote issue number identified and verified to exist
- Issue has NOT been previously imported (no `remote_issue` or same-number local issue exists)
- `github.owner`, `github.repo`, `github.platform` available from session context
- Issue comments accessible via platform API

## Exit Criteria

- Full local mirror created at `.issues/{remote_number}/issue.yaml` (remote body) and `spec.md` (local frontmatter)
- Comments imported to `.issues/{remote_number}/comments.yaml`
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
gb issue view <issue-number> -R <github.owner>/<github.repo>
```

**Local platform:**
Route to `platforms/local/tasks/read.md`. Pass: `{issue_number: N}`.

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
# Note: gb CLI does not have a dedicated list-comments command.
# Use gb issue view to get issue details including comments.
gb issue view <issue-number> -R <github.owner>/<github.repo>
```

Collect each comment's author, timestamp, and body text.

### Step 3: Ensure .issues/ Exists

If `.issues/` directory does not exist, route to `platforms/local/tasks/creation.md` with setup action. The local-issues tool handles worktree setup transparently.

### Step 4: Completeness Gate

When the local issue directory `.issues/{remote_number}/` already exists, do NOT halt on directory existence alone. Enumerate the required mirror files and materialize any that are missing rather than halting:

- [ ] 1. Required mirror files: `spec.md`, `issue.yaml`, `comments.yaml`, `links.yaml`
- [ ] 1. Required frontmatter fields: `github_issue`, `remote_url`
- [ ] 1. For each required mirror file that is ABSENT, materialize it (fetch the remote body/comments/frontmatter as needed and write the file)
- [ ] 1. For each required frontmatter field that is ABSENT, materialize it by writing the field into the file's frontmatter
- [ ] 1. Only HALT when the directory is genuinely complete (all required mirror files and frontmatter fields present)

**Never overwrite an existing file** — only create files that are missing. Materializing a missing file is the completeness-gate behavior; halting on directory existence alone is a defect.

### Step 5: Create Local Issue

Create the local issue directory manually (not via `local-issues create`, because we need to set the number to match the remote):

- [ ] 1. Create directory: `.issues/{remote_number}/`
- [ ] 1. Write `issue.yaml` with minimal frontmatter + full remote body:

```yaml
---
remote_issue: <remote_number>
remote_url: "<html_url>"
last_sync: <import_timestamp>
source: <github.platform>
---

<full_remote_issue_body>
```

- [ ] 4. Write `spec.md` with local frontmatter only — the remote body is NEVER written to spec.md, only to issue.yaml above:

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

### Step 6: Import Comments

Write all fetched comments to `.issues/{remote_number}/comments.yaml` as YAML validated by the `local-issues` tool (`cmd_comment` writes `{type, body, timestamp}` entries under a top-level `comments:` list):

```yaml
comments:
  - type: internal
    body: "<comment_body>"
    timestamp: "YYYY-MM-DDTHH:MM:SSZ"
```

Each comment is one dict entry in the `comments:` list with:

- `type:` — `internal` or `stakeholder` (comment classification)
- `body:` — the comment body text; remote author attribution is included here as documented (`<author>: <comment_body>`) since the YAML format has no separate author field
- `timestamp:` — the remote comment date, ISO 8601 format

List order is oldest-first (chronological). Entries are appended in that order so the list matches `local-issues` read-back ordering.

### Step 7: Advance .counter

Use the named counter-write validation procedure — the sole documented mechanism for advancing `.counter` during import. Rationale: `_next_number` in `.opencode/tools/local-issues` (~line 1089) enforces fail-fast digit-parse semantics — it errors `FATAL: .counter file is corrupt — expected a number` and exits on any malformed counter rather than silently consuming corrupt state. The import procedure mirrors that semantics.

1. Read `.issues/.counter`.
2. Digit-parse check: `read_text().strip()` must satisfy `isdigit()`; if the value is non-digit or corrupt, fail fast with `FATAL: .counter file is corrupt — expected a number` (do not write, do not guess a replacement value).
3. If `counter <= remote_number`: write the successor value `remote_number + 1`, satisfying the monotonic invariant — counter after write >= `remote_number + 1` (never below, never overwrite a higher existing counter).
4. If `counter > remote_number`: leave the counter unchanged (local issues already exist beyond this number).

No unvalidated write is permitted — never run a bare `echo`/arithmetic write to `.counter` without the digit-parse check above. No alternative mechanism is documented or offered.

### Step 8: Verify Import

Verify the full local mirror:

- [ ] 1. Read issue.yaml: body matches remote; Read spec.md: frontmatter has all required fields (verify no remote body content)
- [ ] 1. Read comments.yaml: all comments present, ordered chronologically
- [ ] 1. Verify counter: read `.issues/.counter` and confirm the value satisfies the digit-parse check and the monotonic invariant (counter >= `remote_number + 1`, per Step 7)

## Edge Cases

| Case | Resolution |
| -- | -- |
| Issue already imported (matching `remote_issue` found) | Run the completeness gate — enumerate required mirror files (`spec.md`, `issue.yaml`, `comments.yaml`, `links.yaml`, frontmatter `github_issue`/`remote_url`) and materialize any that are missing; only HALT when the directory is genuinely complete |
| Issue number conflicts with existing local issue | Use next available number, record remote_number in frontmatter |
| Remote issue is closed | Import as closed: create at `.issues/{N}/` with `status: closed` |
| Remote has zero comments | Write empty `comments.yaml` |
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
| "issue.yaml exists (body)" | Verify file at `.issues/{N}/issue.yaml` | `local-issues read <repo>#<number>` | MISSING-ELEMENT |
| "spec.md exists (frontmatter only)" | Verify file at `.issues/{N}/spec.md` | `local-issues read <repo>#<number>` | MISSING-ELEMENT |
| "comments.yaml exists with all comments" | Verify file and comment count matches remote | `ls .issues/{N}/comments.yaml` | MISSING-ELEMENT |
| "promotion_type in frontmatter" | Verify `promotion_type: retroactive_import` present | `local-issues read <repo>#<number>` → parse frontmatter | STRUCTURE-VIOLATION |
| "Counter advanced correctly" | Verify `.counter` value passes digit-parse check and satisfies monotonic invariant (>= remote_number + 1) per Step 7 | read `.issues/.counter` | VERIFICATION-GAP |
| "Body matches remote (issue.yaml)" | Compare issue.yaml body against remote issue body | `local-issues read <repo>#<number>` | VERIFICATION-GAP |
| "spec.md has no remote body" | Verify spec.md has no body content below frontmatter | `local-issues read <repo>#<number>` → check body is empty after frontmatter | VERIFICATION-GAP |

**Evidence artifact:** issue.yaml readback showing body, spec.md readback showing frontmatter only, comments.yaml showing imported comments, .counter value.
