# Task: sync-pull-to-local

## Purpose

After any `read-issue` call, automatically mirror the remote issue body to `.issues/<issue-number>/spec.md`. This enforces the Operating Protocol §3 spec.md mirror mandate — every remote read produces a local mirror.

## Entry Criteria

- Remote issue read completed (`read-issue` task returned issue data)
- Issue number known
- `github.owner`, `github.repo`, `github.platform` available from session context

## Exit Criteria

- Local mirror exists at `.issues/open/<number>-<slug>/spec.md`
- YAML frontmatter written with `remote_issue`, `remote_url`, `last_sync`
- Local mirror is up to date with remote body

## Procedure

### Step 1: Ensure .issues/ Exists

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

### Step 2: Create or Update Local Issue

Determine whether a local issue already exists for this remote number:

1. Search `.issues/open/` and `.issues/closed/` for an entry matching the remote number
2. If found: the issue exists locally — proceed to Step 3 (update)
3. If not found: create a new local issue:

```bash
./.opencode/tools/local-issues create --title "<remote_title>"
```

Capture the returned local issue number.

### Step 3: Write Issue Body to spec.md

Read the remote issue body from the `read-issue` result. Write it to the local spec.md, preserving the existing YAML frontmatter and adding remote metadata:

**New issue (no prior frontmatter):**

```yaml
---
number: <local_number>
title: "<remote_title>"
status: open
labels: [imported]
created: <timestamp>
updated: <timestamp>
remote_issue: <remote_number>
remote_url: "<remote_html_url>"
last_sync: <timestamp>
author: <dev.name>
---

<remote_issue_body>
```

**Existing issue (update frontmatter only — preserve local body):**

Use `local-issues update NNN` to set `remote_issue`, `remote_url`, and `last_sync` fields. Only overwrite the body if explicitly instructed (see Edge Cases below).

### Step 4: Link Local to Remote

If a new issue was created, link it to the remote:

```bash
./.opencode/tools/local-issues link <local_number> --github <remote_number>
```

### Step 5: Verify Mirror

Read back the local spec.md and verify:

- Body content matches the remote issue body
- `remote_issue` field matches the remote number
- `remote_url` field matches the remote issue URL
- `last_sync` timestamp is recent

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
- Related tasks: `read-issue` (runs before), `local-issues setup` (if .issues/ missing)
- Platform routing: `../platforms/github-mcp/` or `../platforms/gitbucket-api/` or `../platforms/local/`
- CLI tool: `.opencode/tools/local-issues`

## Live Verification: Mirror Evidence (MANDATORY)

| Claim | Verification Action | Tool Call | Problem Class |
| -- | -- | -- | -- |
| "Local spec.md exists" | Verify file exists at `.issues/open/NNN-slug/spec.md` | `ls .issues/open/*/spec.md` | MISSING-ELEMENT |
| "Body matches remote" | Compare local spec.md body vs remote issue body | `local-issues read NNN` | VERIFICATION-GAP |
| "Frontmatter has remote_issue" | Verify YAML frontmatter contains `remote_issue` field | `local-issues read NNN` → parse frontmatter | STRUCTURE-VIOLATION |
| "last_sync is recent" | Verify timestamp is within current session window | `local-issues read NNN` → parse frontmatter | VERIFICATION-GAP |

**Evidence artifact:** Local spec.md readback showing body content and frontmatter fields.
