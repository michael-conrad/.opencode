<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Pull Body from Remote

## Overview

Pull remote issue body to local mirror. Pull-body brings the remote's current state into a local `remote.md` file — it does NOT overwrite `spec.md`. The local spec.md is the authoritative version; `remote.md` is a reference mirror for diffing, auditing, and conflict detection.

**Primary tool:** `.opencode/tools/local-issues pull-body N`

**Key architectural rule:** Pulls into `remote.md` only. Never overwrites `spec.md` with remote content. The local spec is the canonical source — remote body is a point-in-time reference copy.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/<N>/` directory exists
- \[ \] Issue has a remote link in frontmatter (`remote_url` or `github_issue` field)
- \[ \] Remote API is reachable (platform-appropriate MCP tools or CLI)
- \[ \] `.opencode/tools/local-issues` CLI tool is available

______________________________________________________________________

## Procedure

### Step 1: Verify Remote Link in Frontmatter

Read the issue's frontmatter to confirm a remote link exists:

```bash
local-issues read N --type full | grep -E '(remote_url|github_issue):'
```

Expected output: a non-empty `remote_url` or `github_issue: <owner>/<repo>#<number>` value.

If no remote link exists: HALT. Report "Issue #N has no remote link. Cannot pull body from remote."

### Step 2: Determine Platform and Fetch Remote Body

Route to the appropriate remote platform based on the link type:

| Frontmatter Link Field                 | Platform  | Fetch Method                                                                    |
| -------------------------------------- | --------- | ------------------------------------------------------------------------------- |
| `github_issue: <owner>/<repo>#<N>`     | GitHub    | `github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<N>)` |
| `remote_url` containing `github.com`   | GitHub    | `github_issue_read(method="get", owner=<owner>, repo=<repo>, issue_number=<N>)` |
| `remote_url` containing GitBucket host | GitBucket | `./.opencode/tools/gitbucket-api get-issue <owner> <repo> <N>`                  |

Extract the issue body from the API response. The body field is the raw markdown content of the remote issue.

### Step 3: Write to remote.md

Write the fetched body to `.issues/<N>/remote.md`. This file replaces the previous remote.md content entirely (not append).

If `remote.md` does not exist, create it. If it exists, overwrite.

**DO NOT write to spec.md.** The local spec is the authoritative version. remote.md is a reference copy.

**File format:**

```bash
---
last_pull: <ISO-8601 timestamp>
source: <remote_url>
---

<body content here>
```

### Step 4: Record Sync Timestamp

After successful write, record the sync timestamp in the issue's frontmatter:

```bash
local-issues update N --last-sync "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

The `last_sync` field is added to frontmatter. If the field already exists, it is overwritten.

### Step 5: Return Pull Result

Return the issue number and sync timestamp to the calling orchestrator.

______________________________________________________________________

## Exit Criteria

- \[ \] Remote link verified in frontmatter (Step 1)
- \[ \] Remote body fetched via platform API (Step 2)
- \[ \] Body written to `remote.md` only — spec.md NOT modified (Step 3)
- \[ \] `last_sync` timestamp recorded in frontmatter (Step 4)
- \[ \] `remote.md` file has frontmatter with `last_pull` and `source` fields
- \[ \] No files outside `.issues/<N>/` were modified
- \[ \] No direct `github_*` or `gitbucket-api` calls outside platform sub-skills

______________________________________________________________________

## Error Handling

| Error                                | Cause                                                              | Resolution                                                                                                          |
| ------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| `.opencode/tools/local-issues read N` exits non-zero | Issue directory missing or malformed                               | HALT. Verify `.issues/<N>/spec.md` exists.                                                                          |
| No remote link in frontmatter        | Issue was created locally only, never promoted                     | HALT. Report "Issue #N has no remote link — no remote to pull from."                                                |
| Remote API call fails                | Network error, auth failure, rate limit, issue not found on remote | HALT. Report the API error message. Do not retry without orchestrator instruction.                                  |
| remote.md write fails                | Filesystem permissions, disk full                                  | HALT. Report filesystem error.                                                                                      |
| `last_sync` update fails             | `.opencode/tools/local-issues update` failure                                      | Document that body was pulled but timestamp not recorded. Report to orchestrator.                                   |
| GitHub owner/repo mismatch           | Frontmatter link targets different repo than session context       | HALT. Report mismatch. The local issue was promoted to a different repo — verify intent.                            |
| Pulled body empty                    | Remote issue has no body content                                   | Report "Remote issue #N has empty body — wrote empty remote.md" and continue. This is informational, not a failure. |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate remote links, overwrite spec.md with remote content, or inline remote platform logic outside the platform sub-skills.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
