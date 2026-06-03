<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Push Body to Remote

## Overview

Push local issue body to the remote API. This is a one-direction sync — local spec.md is authoritative. Push-body is a SEPARATE operation from `update --body` (which modifies the local file only). The decision to push happens in the post-update decision gate (see `update.md`).

**Primary tool:** `.opencode/tools/local-issues push-body N`

**Architectural role:** Push-body closes the sync loop after a local body update. It reads spec.md, extracts the body content, and sends it to the remote API via the platform's update-issue endpoint. This task does NOT call `update --body` — that is the caller's responsibility.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/<N>/` directory exists
- \[ \] `.issues/<N>/spec.md` contains body content to push
- \[ \] Issue has a remote link in frontmatter (`remote_url` or `github_issue` field)
- \[ \] `.opencode/tools/local-issues` CLI tool is available
- \[ \] Remote API credentials are available (platform-appropriate env vars or MCP tools)

______________________________________________________________________

## Procedure

### Step 1: Verify Remote Link in Frontmatter

Read the issue's frontmatter to confirm a remote link exists:

```bash
local-issues read N --type full | grep -E '(remote_url|github_issue):'
```

Expected output: a non-empty `remote_url` or `github_issue: <owner>/<repo>#<number>` value.

If no remote link exists: HALT. Report "Issue #N has no remote link. Cannot push body to remote."

### Step 2: Extract Body from spec.md

Read the issue body content from `spec.md`. The body is all content after the frontmatter:

```bash
local-issues read N --type full
```

Extract body portion (everything after the closing `---` of the YAML frontmatter).

### Step 3: Determine Platform and Push

Route to the appropriate remote platform based on the link type:

| Frontmatter Link Field                 | Platform  | Push Method                                                                                      |
| -------------------------------------- | --------- | ------------------------------------------------------------------------------------------------ |
| `github_issue: <owner>/<repo>#<N>`     | GitHub    | `github_issue_write(method="update", owner=<owner>, repo=<repo>, issue_number=<N>, body=<body>)` |
| `remote_url` containing `github.com`   | GitHub    | `github_issue_write(...)`                                                                        |
| `remote_url` containing GitBucket host | GitBucket | `./.opencode/tools/gitbucket-api update-issue <owner> <repo> <N> --body "<body>"`                |

**CRITICAL:** Body-preservation safeguard applies. If the remote body would be erased or shortened to \<80% of original length, HALT per `000-critical-rules.md`.

### Step 4: Record Sync Timestamp

After successful push, record the sync timestamp in the issue's frontmatter:

```bash
local-issues update N --last-sync "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

The `last_sync` field is added to frontmatter. If the field already exists, it is overwritten.

### Step 5: Return Sync Result

Return the sync status to the calling orchestrator or post-update gate.

______________________________________________________________________

## Exit Criteria

- \[ \] Remote link verified in frontmatter (Step 1)
- \[ \] Body extracted from spec.md (Step 2)
- \[ \] Platform API call returned success (Step 3)
- \[ \] Body-preservation safeguard verified (no content erasure)
- \[ \] `last_sync` timestamp recorded in frontmatter (Step 4)
- \[ \] All operations targeted `.issues/<N>/` only — no files outside `.issues/` modified
- \[ \] No direct `github_*` or `gitbucket-api` calls outside platform sub-skills

______________________________________________________________________

## Error Handling

| Error                                | Cause                                                          | Resolution                                                                               |
| ------------------------------------ | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `.opencode/tools/local-issues read N` exits non-zero | Issue directory missing or malformed                           | HALT. Verify `.issues/<N>/spec.md` exists.                                               |
| No remote link in frontmatter        | Issue was created locally only, never promoted                 | HALT. Report "Issue #N has no remote link — use promote task first."                     |
| Remote API call fails                | Network error, auth failure, rate limit                        | HALT. Report the API error message. Do not retry without orchestrator instruction.       |
| Body-preservation violation          | Body content shortened to \<80% of previous remote body length | HALT. Report body erasure risk per `000-critical-rules.md`.                              |
| `last_sync` update fails             | `.opencode/tools/local-issues update` failure                                  | Document that body was pushed but timestamp not recorded. Report to orchestrator.        |
| GitHub owner/repo mismatch           | Frontmatter link targets different repo than session context   | HALT. Report mismatch. The local issue was promoted to a different repo — verify intent. |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate remote links, or inline remote platform logic outside the platform sub-skills.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
