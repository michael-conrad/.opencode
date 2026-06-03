<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Body Edit Pipeline

## Overview

Four-phase pipeline for editing the executive summary (`remote.md`) and syncing it to the remote API. Edits to the full spec (`spec.md`) use the `update` task instead. The pipeline runs locally — the orchestrator dispatches once and receives one result contract.

**Scope:** `remote.md` only. Never touches `spec.md`.

**Primary tool:** `.opencode/tools/local-issues`

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/<N>/` directory exists
- \[ \] Issue has a remote link (`remote_url` or `github_issue` in frontmatter)
- \[ \] `.opencode/tools/local-issues` CLI tool is available
- \[ \] `local-issues extract-exec-summary N` is functional (target utility)
- \[ \] `local-issues push-body N` is functional (target utility)
- \[ \] `local-issues pull-body N` is functional (target utility)

______________________________________________________________________

## Procedure

### Phase 1: Extract — Generate exec summary from spec

Extract the executive summary from the local spec body into `remote.md`. This reads `spec.md`, identifies the exec-summary section, and writes/updates `remote.md`.

| Step | Action                | Command / Details                                                                   |
| ---- | --------------------- | ----------------------------------------------------------------------------------- |
| 1.1  | Extract exec-summary  | `local-issues extract-exec-summary N`                                               |
| 1.2  | Verify extraction     | Read `.issues/<N>/remote.md` — confirm file exists and is non-empty                 |
| 1.3  | Capture path and body | Record `{ current_body, remote_md_path: ".issues/<N>/remote.md", issue_number: N }` |

**Exit from Phase 1:** `remote.md` exists with extracted exec-summary content.

______________________________________________________________________

### Phase 2: Edit — Apply edit script to remote.md

Apply a text edit script to the extracted `remote.md`. The edit script is a set of text replacements or section rewrites provided by the orchestrator.

| Step | Action                 | Command / Details                                                                                                                  |
| ---- | ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| 2.1  | Read current remote.md | Read `.issues/<N>/remote.md` to capture current content                                                                            |
| 2.2  | Apply edit script      | Use the Edit tool to apply the supplied edit script (text replacement, section rewrite, append/prepend) to `.issues/<N>/remote.md` |
| 2.3  | Verify edit            | Read `.issues/<N>/remote.md` — confirm changes applied as expected                                                                 |
| 2.4  | Record summary         | `{ success: true, summary_of_changes: "<brief description>" }`                                                                     |

**Exit from Phase 2:** `remote.md` contains the edited exec-summary reflecting the edit script.

______________________________________________________________________

### Phase 3: Verify — Structural integrity check

Verify that the edited `remote.md` is structurally sound before pushing.

| Step | Action                      | Details                                                                                      |
| ---- | --------------------------- | -------------------------------------------------------------------------------------------- |
| 3.1  | Check for binary corruption | Read `.issues/<N>/remote.md` — confirm no null bytes or binary content (UTF-8 decodable)     |
| 3.2  | Check no YAML frontmatter   | Confirm file does NOT start with `---` (remote.md is pure markdown, not frontmatter-wrapped) |
| 3.3  | Check body non-empty        | Confirm file length > 0 after trimming whitespace                                            |
| 3.4  | Compare against expected    | If orchestrator provided expected content patterns, verify the file contains them            |
| 3.5  | Record pass/fail            | `{ pass: true/false, issues: ["issue1", ...] }`                                              |

**Integrity rules:**

- ❌ No null bytes or binary corruption
- ❌ No YAML frontmatter (`---` at start)
- ❌ Empty body
- ✅ Pure UTF-8 markdown, non-empty

**On integrity FAIL:** HALT. Report issues to orchestrator. Do NOT proceed to Phase 4.

______________________________________________________________________

### Phase 4: Push and Verify — Sync to remote API

Push the edited `remote.md` to the remote API, then verify sync succeeded by pulling the remote body and comparing.

| Step | Action               | Command / Details                                                                                |
| ---- | -------------------- | ------------------------------------------------------------------------------------------------ |
| 4.1  | Push to remote       | `local-issues push-body N`                                                                       |
| 4.2  | Check push exit code | Confirm exit code 0                                                                              |
| 4.3  | Pull remote body     | `local-issues pull-body N` — fetch the remote issue body                                         |
| 4.4  | Compare bodies       | Compare pulled body against local `.issues/<N>/remote.md` — must match character-for-character   |
| 4.5  | Record result        | `{ sync_status: "pushed", url: "<remote_issue_url>" }` or `{ sync_status: "failed", url: null }` |

**On compare mismatch:** The push may have been silently truncated or transformed. HALT and report mismatch to orchestrator. Do NOT report sync success.

______________________________________________________________________

## Result Contract

Return to orchestrator:

```json
{
  "sync_status": "pushed|failed",
  "url": "https://github.com/owner/repo/issues/N",
  "summary_of_changes": "Brief description of edits applied",
  "integrity_pass": true
}
```

______________________________________________________________________

## Exit Criteria

- \[ \] `remote.md` edited per orchestrator-supplied edit script
- \[ \] Structural integrity check passed (no binary corruption, no YAML frontmatter, non-empty)
- \[ \] `local-issues push-body N` exited 0
- \[ \] `local-issues pull-body N` confirmed remote body matches local `remote.md`
- \[ \] Result contract returned to orchestrator
- \[ \] No files outside `.issues/<N>/` were modified

______________________________________________________________________

## Error Handling

| Error                                                | Cause                                                         | Resolution                                                                                                                                              |
| ---------------------------------------------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `local-issues extract-exec-summary N` exits non-zero | `remote.md` may not exist, spec body may lack exec-summary    | Verify `.issues/<N>/spec.md` exists and has an exec-summary section. Report to orchestrator.                                                            |
| `local-issues push-body N` exits non-zero            | No remote link configured, API unreachable, permissions error | Check frontmatter for `remote_url` or `github_issue`. If missing, issue is local-only — push is not applicable. Report to orchestrator.                 |
| `local-issues pull-body N` exits non-zero            | Remote doesn't exist yet, network error, API changed          | The push may have succeeded but pull failed. Report partial success to orchestrator — push was committed but sync verification is inconclusive.         |
| Body mismatch after pull                             | Remote body differs from local `remote.md`                    | API may have transformed content (added/removed whitespace, truncated). Read remote body directly via API and compare. Report mismatch to orchestrator. |
| Integrity check fails                                | Binary corruption, YAML frontmatter, empty body               | HALT. Report specific integrity issue. Do NOT push.                                                                                                     |
| Edit script malformed                                | Orchestrator-supplied script contains invalid replacements    | HALT. Report that edit script could not be applied. Request corrected script.                                                                           |
| CLI tool not found                                   | `.opencode/tools/local-issues` missing                        | HALT. The tool must exist for local platform operations.                                                                                                |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
