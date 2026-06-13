<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Close

## Overview

Close a local issue by moving it from `.issues/open/` to `.issues/closed/`. Close is a local file mutation only — remote closure is handled by the sync-pull-to-local workflow. The agent that calls close must also dispatch `push-body` separately if remote sync is needed (see Remote Sync Note below).

**Primary tool:** `./.opencode/tools/local-issues`

**Key architectural rule:** Close is local-only. Remote closure is handled by `push-body` which reads `state.md` and pushes the updated status to the remote API. These are intentionally decoupled — same pattern as update vs push-body (Card-013, Card-015).

______________________________________________________________________

## Entry Criteria

- \[ \] Issue identifier is known — bare `N` (integer) or qualified `{repo}#{N}` (e.g. `<repo>#<N>`)
- \[ \] `.issues/open/<N>/` or `<child-repo>/.issues/open/<N>/` directory exists
- \[ \] `./.opencode/tools/local-issues` CLI tool is available
- \[ \] Issue is currently open (`status: open` in frontmatter)
- \[ \] Close reason is specified if known: `--reason completed|not_planned|duplicate`

______________________________________________________________________

## Procedure

| Step | Action               | Command / Details                                                                                                                                                                         |
| ---- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Verify open state    | `./.opencode/tools/local-issues read <repo>#<N>` — confirm `status: open`. If already `closed`, exit with code 2 (already closed).                                                                                   |
| 2    | Pre-read frontmatter | Capture current frontmatter to preserve fields during transition.                                                                                                                         |
| 3    | Close issue          | `./.opencode/tools/local-issues close <repo>#<N> [--reason completed]` — updates frontmatter (status → `closed`, `closed_at` timestamp, `state_reason`), moves `.issues/open/NNN/` → `.issues/closed/NNN/` |
| 4    | Verify               | `./.opencode/tools/local-issues read <repo>#<N>` — confirm exit 0, `status: closed`, `closed_at` timestamp present, `state_reason` matches expected value                                                            |
| 5    | Auto-commit          | The CLI tool auto-commits the move on the issues-data branch (if configured). Verify the commit succeeded.                                                                                |

### Reason Values

| `--reason`    | Use Case                                           |
| ------------- | -------------------------------------------------- |
| `completed`   | Issue finished, spec implemented, PR merged        |
| `not_planned` | Issue accepted but will not be worked on (wontfix) |
| `duplicate`   | Issue describes the same thing as another issue    |

When no reason is specified, default is `completed`.

### Directory Move

The CLI tool handles the physical move:

- Source: `.issues/open/<N>-<slug>/`
- Destination: `.issues/closed/<N>-<slug>/`

The slug stays the same — only the parent directory changes. This preserves all files: `spec.md`, `comments.md`, `links.yaml`, `remote.md`, `state.md`.

______________________________________________________________________

## Exit Criteria

- \[ \] CLI tool returned exit code 0
- \[ \] `.issues/open/<N>/` directory no longer exists
- \[ \] `.issues/closed/<N>/` directory exists with all files intact
- \[ \] `./.opencode/tools/local-issues read N` returns exit 0
- \[ \] Frontmatter `status` is `closed`
- \[ \] `closed_at` timestamp is present (ISO 8601 format)
- \[ \] `state_reason` matches expected value (or default `completed`)
- \[ \] Comments, links, and remote.md are preserved in the new location

______________________________________________________________________

## Remote Sync Note

Close is local-only. If a remote issue exists (`github_issue` or `remote_url` in frontmatter), the remote API is NOT called during close. The remote closure is handled by a separate sync-pull-to-local workflow:

1. On next `pull-body` from the remote, the remote issue's closed status propagates to the local issue
1. Or: the orchestrator dispatches `push-body` after close to update the remote issue status

This decoupling prevents the local close operation from depending on remote API availability. Local operations are always available — remote sync is conditional.

**The agent MUST document whether push-body dispatch is needed** by reporting the remote sync requirement in the result contract:

| Case                                          | Report                                                   |
| --------------------------------------------- | -------------------------------------------------------- |
| No remote issue                               | `sync_required: false` — close complete                  |
| Remote issue exists, push-body dispatched     | `sync_required: true, sync_action: push-body-dispatched` |
| Remote issue exists, push-body NOT dispatched | `sync_required: true, sync_action: pending-orchestrator` |

______________________________________________________________________

## Error Handling

| Error                                         | Cause                                             | Resolution                                                                                        |
| --------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `./.opencode/tools/local-issues close N` exits code 2           | Issue is already closed                           | Report to orchestrator. No action needed — issue is in desired state.                             |
| `./.opencode/tools/local-issues close N` exits non-zero (non-2) | Issue not found, move failed, frontmatter corrupt | Verify `.issues/open/<N>/` exists. Check frontmatter is valid YAML. Check filesystem permissions. |
| Issue N not found                             | `.issues/open/<N>/` does not exist                | HALT. Verify issue number. Check if issue is already in `.issues/closed/`.                        |
| Frontmatter missing `status` field            | Corrupted spec.md                                 | HALT. Report corrupt issue data. Orchestrator must repair or delete.                              |
| Move to closed fails                          | Filesystem error, permissions, destination exists | HALT. `.issues/closed/<N>/` may already exist. Orchestrator must resolve collision.               |
| CLI tool not found                            | `./.opencode/tools/local-issues` missing            | HALT. The tool must exist for local platform operations.                                          |
| Push-body after close fails                   | Remote API error (auth, rate limit, 404)          | Report to orchestrator. Local close is already committed — push failure is a separate concern.    |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate data, or inline push-body logic. Already-closed (exit code 2) is informational only — not an error that halts pipeline.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
