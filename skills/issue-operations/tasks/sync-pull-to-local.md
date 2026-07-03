# Task: sync-pull-to-local

## Purpose

After any `read-issue` call, automatically mirror the remote issue body to `.issues/<issue-number>/remote.md` alongside the local `spec.md`. This enforces the Operating Protocol §3 remote mirror mandate — every remote read produces a local mirror.

## Entry Criteria

- Remote issue read completed (`read-issue` task returned issue data)
- Issue number known
- `github.owner`, `github.repo`, `github.platform` available from session context

## Exit Criteria

- Local mirror exists at `.issues/{number}/remote.md` (remote body) alongside `spec.md` (local spec)
- YAML frontmatter written with `remote_issue`, `remote_url`, `last_sync`
- Local mirror is up to date with remote body

## Procedure

### Step 1: Ensure .issues/ Exists

If `.issues/` directory does not exist, route to `platforms/local/tasks/creation.md` via task() with setup action. The local-issues tool handles worktree setup transparently.

### Step 2: Create or Update Local Issue

Determine whether a local issue already exists for this remote number:

- [ ] 1. Search `.issues/` for an entry matching the remote number
- [ ] 2. If found: the issue exists locally — proceed to Step 3 (update)
- [ ] 3. If not found: create a new local issue via task() to `platforms/local/tasks/creation.md`: `{title: "<remote_title>"}`

Capture the returned local issue number.

### Step 3: Write Issue Body to remote.md

Read the remote issue body from the `read-issue` result. Write it to `remote.md` alongside the local `spec.md`:

**New issue (no prior remote mirror):**

```yaml
---
remote_issue: <remote_number>
remote_url: "<remote_html_url>"
last_sync: <timestamp>
source: <github.platform>
---

<remote_issue_body>
```

**Existing issue (update frontmatter only — preserve local spec body):**

Use `platforms/local/tasks/update.md` via task() to update `remote.md` fields (`remote_issue`, `remote_url`, `last_sync`) and body. The local `spec.md` is never touched by this task — only `remote.md` is updated.

### Step 4: Link Local to Remote

If a new issue was created, route to `platforms/local/tasks/link.md` via task() to link it to the remote. Pass: `{local_number: N, remote_number: N, remote_url: "<url>"}`.

### Step 5: Verify Mirror

Read back the local remote.md and verify:

- Body content matches the remote issue body

## Edge Cases

| Case | Resolution |
| -- | -- |
| Remote body is empty | Write empty body with frontmatter noting "Remote body was empty" |
| Local issue already exists with newer content | Do NOT overwrite — flag for developer review (local changes may be newer) |
| `.issues/` setup fails | HALT — report setup error, do not continue |
| Local issue exists but belongs to different remote | HALT — report mismatch, do not overwrite |
| Remote body changes (stale mirror) | On next `read-issue`, update body only if local has no uncommitted changes |
| Platform is `local` | No-op — remote read already returns local data; skip mirroring |

## Context Required

- Session values: github.owner, github.repo, github.platform
- From `read-issue` result: issue_number, issue_body, issue_url
- Related tasks: `read-issue` (runs before), `platforms/local/tasks/creation.md` for setup (if .issues/ missing)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- CLI tool: `.opencode/tools/local-issues`

## Live Verification: Mirror Evidence (MANDATORY)

| Claim | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "Local remote.md exists" | Verify file exists at `.issues/{N}/remote.md` | `ls .issues/{N}/remote.md` | MISSING-ELEMENT |
| "Body matches remote" | Compare local remote.md body vs remote issue body | `local-issues read NNN` (reads remote.md) | VERIFICATION-GAP |
| "Frontmatter has remote_issue" | Verify YAML frontmatter contains `remote_issue` field | `local-issues read NNN` → parse frontmatter | STRUCTURE-VIOLATION |
| "last_sync is recent" | Verify timestamp is within current session window | `local-issues read NNN` → parse frontmatter | VERIFICATION-GAP |

**Evidence artifact:** Local remote.md readback showing body content and frontmatter fields.
