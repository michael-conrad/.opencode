<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Comment

## Overview

Add a comment to a local issue. Two comment types control rendering and remote propagation:

- **internal** (default): Agent-internal notes, status updates between phases. Written to `comments.md` only. No remote action.
- **stakeholder**: Approval requests, feedback responses, progress reports to developers. Written to `comments.md`, added to `remote.md`, then `remote.md` auto-pushed to remote API.

The type flag is set by the caller — the tool does not classify. Classification responsibility belongs to the skill card (per Card-014).

**Primary tool:** `.opencode/tools/local-issues`

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/open/<N>/` or `.issues/closed/<N>/` directory exists (closed issues accept comments for audit trails)
- \[ \] `.opencode/tools/local-issues` CLI tool is available
- \[ \] Comment `--body` text is non-empty
- \[ \] `--type` is specified: `internal` (default) or `stakeholder`
- \[ \] Comment text is substantive — not empty acknowledgements, single-word confirmations, or process noise

______________________________________________________________________

## Type Classification Table

| Type            | CLI Flag                    | Destination                 | Remote Action         | Use Case                                                                                                      |
| --------------- | --------------------------- | --------------------------- | --------------------- | ------------------------------------------------------------------------------------------------------------- |
| **internal**    | `--type internal` (default) | `comments.md` only          | None                  | Agent reasoning, design analysis, corrections, process metadata, decision log entries, phase transition notes |
| **stakeholder** | `--type stakeholder`        | `comments.md` + `remote.md` | Auto-push `remote.md` | Approval requests, completion reports, progress reports, feedback responses, reviewer-visible information     |

**Default is `internal`** — conservative. Stakeholder-visible content is additive (can be promoted later). Internal content posted publicly cannot be retracted.

______________________________________________________________________

## Per-Type Procedure

### Type: internal

| Step | Action                | Command / Details                                                                                                                                                   |
| ---- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Verify issue exists   | `.opencode/tools/local-issues read N` — confirm exit 0. If exit non-zero → HALT. Issue may not exist.                                                                               |
| 2    | Append to comments.md | `.opencode/tools/local-issues comment N --body "TEXT" --type internal` — appends to `.issues/N/comments.md` with frontmatter: `type: internal`, `timestamp`, agent identity header. |
| 3    | Verify append         | `.opencode/tools/local-issues read N` — read comments. Confirm new entry present, `type: internal` in frontmatter.                                                                  |

**Result:** Comment appended to `.issues/N/comments.md` as `type: internal`. No remote.md update. No push. No commit.

______________________________________________________________________

### Type: stakeholder

| Step | Action                    | Command / Details                                                                                                                                                           |
| ---- | ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Verify issue exists       | `.opencode/tools/local-issues read N` — confirm exit 0. If exit non-zero → HALT. Issue may not exist.                                                                                       |
| 2    | Verify remote link exists | Check frontmatter `remote_url` or `github_issue` field. If absent, issue has no remote — stakeholder comment CAN still be added (it documents intent for future promotion). |
| 3    | Append to comments.md     | `.opencode/tools/local-issues comment N --body "TEXT" --type stakeholder` — appends to `.issues/N/comments.md` with frontmatter: `type: stakeholder`, `timestamp`, agent identity header.   |
| 4    | Append to remote.md       | The CLI tool appends the stakeholder-facing comment entry to `remote.md` with context suitable for a remote reader.                                                         |
| 5    | Push remote.md            | `.opencode/tools/local-issues push-body N` — pushes `remote.md` to remote API (GitHub comment or GitBucket comment per platform).                                                           |
| 6    | Verify push               | Verify CLI exit 0. If push fails, local comment is already committed — push failure is a separate concern. Report to orchestrator.                                          |

**Result:** Comment appended to `comments.md` (type: stakeholder), `remote.md` updated, `remote.md` pushed to remote API.

______________________________________________________________________

## Exit Criteria

- \[ \] CLI tool returned exit 0
- \[ \] `.issues/N/comments.md` contains the new entry
- \[ \] Comment frontmatter has correct `type` value (`internal` or `stakeholder`)
- \[ \] Comment has `timestamp` in ISO 8601 format
- \[ \] For `type: stakeholder`: `remote.md` was updated and `push-body` completed (or push failure was reported to orchestrator)
- \[ \] Comment text is preserved verbatim — no truncation, no rephrasing, no redaction

______________________________________________________________________

## Error Handling

| Error                                   | Cause                                                                            | Resolution                                                                                                                               |
| --------------------------------------- | -------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `.opencode/tools/local-issues comment N` exits non-zero | Issue does not exist, body empty, CLI error                                      | Verify `.issues/N/` exists. Ensure `--body` is non-empty. Check CLI tool.                                                                |
| Issue N not found                       | `.issues/N/` directory missing                                                   | HALT. Verify issue number. Check both `.issues/open/` and `.issues/closed/`.                                                             |
| Push-body fails for stakeholder comment | Remote API error (auth, rate limit, 404)                                         | Report to orchestrator. Local comment is already committed — push failure is a separate concern. Orchestrator may retry push-body later. |
| No remote link for stakeholder comment  | Issue was created local-only (`links.yaml` empty, no `github_issue` frontmatter) | Stakeholder comment CAN proceed — future promotion will include the comment context. Report the no-remote state to orchestrator.         |
| Duplicate/redundant comment detected    | Same agent same body posted within 60 seconds                                    | Skip. Report "already posted — duplicate suppressed." HALT is not needed.                                                                |
| CLI tool not found                      | `.opencode/tools/local-issues` missing                                           | HALT. The tool must exist for local platform operations.                                                                                 |

**General rule:** All fatal errors must HALT and report the specific failure to the orchestrator. Non-fatal warnings (no remote link, push-body failure after local write) are reported but do not undo the local comment write. Push-body failure is specifically documented as a separate concern — never inline the push logic.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
