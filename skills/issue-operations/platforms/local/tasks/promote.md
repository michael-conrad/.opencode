<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Promote

## Overview

Promote a local issue to a remote issue tracker. Promotion creates a remote issue from the local draft's exec-summary and records the remote metadata in local frontmatter. This is the bridge between local-only and remote-tracked issue lifecycle.

**Primary tool:** `./.opencode/tools/local-issues`

**CLI:** `./.opencode/tools/local-issues promote N --remote-url <url>`

**Parameters:** `{ number: int }` (local issue number, or qualified `{repo}#{N}` for cross-repo)
**Returns:** `{ local_path: string, remote_url: string, remote_number: int }`

Per Card-020, promote is a core local platform capability — without it, local drafts are permanently isolated from the remote tracker.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/open/<N>/` directory exists with valid `spec.md`
- \[ \] Exec-summary is present in spec frontmatter (`exec_summary` field) or can be extracted from body
- \[ \] Remote platform type is resolved (`github` or `gitbucket`) from task context
- \[ \] `./.opencode/tools/local-issues` CLI tool is available
- \[ \] Issue is NOT already promoted (no `github_issue` or `remote_url` in frontmatter)
- \[ \] Remote API credentials are available (verified by session-enforcement before dispatch)

______________________________________________________________________

## Procedure

| Step | Action                      | Command / Details                                                                                                                                                   |
| ---- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Read local issue            | `./.opencode/tools/local-issues read <repo>#<N> --type full` — capture full frontmatter + body                                                                                                 |
| 2    | Extract exec-summary        | Read `exec_summary` from frontmatter. If absent, extract first paragraph of spec body (up to first `---` or 500 chars).                                             |
| 3    | Verify not already promoted | Check `github_issue` and `remote_url` frontmatter fields for empty/falsy values. If already promoted, exit with code 2 (already promoted).                          |
| 4    | Construct remote title      | Use spec title from frontmatter. Append `[local #N]` suffix for traceability.                                                                                       |
| 5    | Construct remote body       | Format: exec-summary + full spec body with local provenance note (`Originally drafted as local issue #N at .issues/open/<N>/`).                                     |
| 6    | Create remote issue         | Call platform dispatcher (`issue-operations --task creation`) with title, body, labels from local frontmatter                                                       |
| 7    | Capture remote response     | Record `html_url`, `number`, `node_id` from platform response                                                                                                       |
| 8    | Run promote CLI             | `./.opencode/tools/local-issues promote <repo>#<N> --remote-url <URL> --remote-number <NUM>` — updates frontmatter with `github_issue`, `remote_url`, `remote_number`, `promoted_at` timestamp |
| 9    | Verify promotion            | `./.opencode/tools/local-issues read <repo>#<N> --type full` — confirm `github_issue`, `remote_url`, `remote_number` are populated, `promoted_at` timestamp present                            |
| 10   | Post remote comment         | Add comment on remote issue referencing local path: `🤖 Promoted from local issue #N (.issues/open/<N>/)`                                                           |

### Remote Body Format

The promoted remote issue body uses this structure:

```bash
## Summary

<exec_summary>

---

<full spec body>

---

*Originally drafted as local issue #<N> at .issues/open/<N>/*
```

The provenance note is appended after a horizontal rule. It is NOT part of the functional spec content — it is a traceability marker for multi-platform workflows.

### Already-Promoted Detection

Frontmatter fields checked for promotion status:

| Field          | If Present                            | If Empty/Absent            |
| -------------- | ------------------------------------- | -------------------------- |
| `github_issue` | Already promoted — exit code 2        | Not yet promoted — proceed |
| `remote_url`   | Already promoted — exit code 2        | Not yet promoted — proceed |
| `promoted_at`  | Already promoted — timestamp confirms | Not yet promoted — proceed |

All three fields must be absent/empty for promotion to proceed. If any one is present, promotion is considered already done.

### Platform Dispatch Routing

The remote platform is selected from task context (`platform_type`). The promote sub-agent does NOT call the remote API directly — it dispatches via `issue-operations` dispatcher:

| `platform_type` | Dispatcher Task                    | Notes                                         |
| --------------- | ---------------------------------- | --------------------------------------------- |
| `github`        | `issue-operations --task creation` | Routes via `github-mcp` platform sub-skill    |
| `gitbucket`     | `issue-operations --task creation` | Routes via `gitbucket-api` platform sub-skill |

The dispatcher handles platform selection. Per Card-020 platform routing mandate, the promote sub-agent MUST NOT call `github_create_pull_request` or raw `gitbucket-api` calls directly.

______________________________________________________________________

## Exit Criteria

- \[ \] CLI tool returned exit code 0
- \[ \] Remote issue was created (confirmed by `html_url` and `number` from platform API)
- \[ \] Local frontmatter updated with `github_issue`, `remote_url`, `remote_number`, `promoted_at`
- \[ \] `./.opencode/tools/local-issues read N --type full` confirms all remote metadata fields are populated
- \[ \] Remote issue body contains the exec-summary and local provenance note
- \[ \] Remote issue has comment referencing local path
- \[ \] Labels from local frontmatter were carried forward to remote issue

______________________________________________________________________

## Error Handling

| Error                                         | Cause                                                                 | Resolution                                                                                                 |
| --------------------------------------------- | --------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `./.opencode/tools/local-issues promote N` exits code 2         | Issue is already promoted                                             | Report to orchestrator. No action needed — remote linkage exists.                                          |
| Remote creation fails (auth, 404, rate limit) | Platform API unavailable or credentials expired                       | HALT. Remote issue was NOT created. Local draft preserved. Report auth/availability error to orchestrator. |
| Local issue N not found                       | `.issues/open/<N>/` does not exist                                    | HALT. Verify issue number. Check if issue is in `.issues/closed/` (closed issues cannot be promoted).      |
| Exec-summary missing                          | `exec_summary` frontmatter absent and body has no extractable summary | HALT. Report that exec-summary is required. Orchestrator must add `exec_summary` field to frontmatter.     |
| Remote URL mismatch                           | `remote_url` in frontmatter differs from actual created remote URL    | HALT. Report mismatch. Orchestrator must resolve which remote is canonical.                                |
| CLI tool not found                            | `./.opencode/tools/local-issues` missing                                | HALT. The tool must exist for local platform operations.                                                   |
| Frontmatter corrupt after promote             | YAML parse failure on re-read                                         | HALT. CLI command may have partially written frontmatter. Report corrupt state — orchestrator must repair. |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate remote data, or inline platform API calls. Already-promoted (exit code 2) is informational only — not an error that halts pipeline.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
