<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Update

## Overview

Update an existing local issue's metadata or body. Update is strictly a local mutation — it modifies files under `.issues/N/`. Body changes require a separate `push-body` step to sync to remote (see Post-Update Decision Gate).

**Primary tool:** `./.opencode/tools/local-issues`

**Key architectural rule:** Update modifies local files only. Push-body is a separate task that syncs remote.md to the remote API. These are intentionally decoupled — see Card-013.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue identifier is known — bare `N` (integer) or qualified `{repo}#{N}` (e.g. `<repo>#<N>`)
- \[ \] `.issues/<N>/` or `<child-repo>/.issues/<N>/` directory exists (open or closed)
- \[ \] `./.opencode/tools/local-issues` CLI tool is available
- \[ \] At least one update field is specified: `--title`, `--status`, `--phase`, `--labels`, or `--body`
- \[ \] For `--body` updates: body content is non-empty
- \[ \] For `--status closed` updates: use the `close` task instead (see `close.md`)

______________________________________________________________________

## Type Dispatch Table

| Type         | CLI Flags                                    | Files Modified      | Remote Sync Required?                                    |
| ------------ | -------------------------------------------- | ------------------- | -------------------------------------------------------- |
| **metadata** | `--title`, `--status`, `--phase`, `--labels` | spec.md frontmatter | Title/status/labels: yes (via push-metadata). Phase: no. |
| **body**     | `--body "..."`                               | spec.md body only   | No (decoupled — see Post-Update Decision Gate)           |

______________________________________________________________________

## Per-Type Procedure

### Type: metadata

Update frontmatter fields. Title, status, phase, and labels are independent — any combination may be specified in a single call.

| Step | Action               | Command / Details                                                                                                                                              |
| ---- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Pre-read             | `./.opencode/tools/local-issues read <repo>#<N>` — capture current frontmatter to verify fields exist                                                                                     |
| 2    | Validate fields      | Confirm each specified field is a valid frontmatter key (title, status, phase, labels). Status values: `open`, `closed`. Phase values: per project convention. |
| 3    | Update               | `./.opencode/tools/local-issues update <repo>#<N> --title "T" --status S --phase P --labels L1,L2` — only include flags that have values                                                  |
| 4    | Verify               | `./.opencode/tools/local-issues read <repo>#<N>` — confirm each field matches the expected value                                                                                          |
| 5    | Post-update decision | See Post-Update Decision Gate below                                                                                                                            |

**Field scope (per Card-013):**

| Field      | spec.md          | remote.md   | Decision                                |
| ---------- | ---------------- | ----------- | --------------------------------------- |
| `--title`  | Frontmatter      | Shared      | Push-metadata required if remote exists |
| `--status` | Frontmatter      | Shared      | Push-metadata required if remote exists |
| `--phase`  | Frontmatter only | Not written | Phase is local-only, no remote sync     |
| `--labels` | Frontmatter      | Shared      | Push-metadata required if remote exists |

______________________________________________________________________

### Type: body

Update the spec.md body content. This is the full-fidelity issue body — spec, plans, models, cards, edge cases. Body is separate from `remote.md` (executive summary for stakeholders).

| Step | Action               | Command / Details                                                     |
| ---- | -------------------- | --------------------------------------------------------------------- |
| 1    | Pre-read             | `./.opencode/tools/local-issues read N` — capture body to verify content structure      |
| 2    | Update body          | `./.opencode/tools/local-issues update N --body "..."` — full body content              |
| 3    | Verify               | `./.opencode/tools/local-issues read N` — confirm body matches expected content, exit 0 |
| 4    | Post-update decision | See Post-Update Decision Gate below                                   |

**Body update does NOT modify:** frontmatter fields (title, status, phase, labels), links, comments, or remote.md. Only spec.md body is changed.

______________________________________________________________________

## Post-Update Decision Gate

After a body update, the agent MUST decide whether to push the updated content to the remote API. This gate fires on every body update. Metadata updates use a separate `push-metadata` path.

### Gate Logic

| Condition                                                               | Action                                                                                              |
| ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Local-only issue (no `remote_url`, no `github_issue` in frontmatter)    | **Skip.** No remote to sync. Done.                                                                  |
| Remote exists AND body content changed substantively                    | **Push body.** `./.opencode/tools/local-issues push-body N` to sync remote.md (via extract-exec-summary → push-body). |
| Remote exists AND body content was trivial/minor (typo fix, formatting) | **Skip.** Notify orchestrator that push was skipped with reason.                                    |

### Push Body Sub-Workflow

When push is needed, the orchestrator dispatches:

1. `extract-exec-summary` task — reads spec.md, writes/updates remote.md
1. `push-body` task — pushes remote.md to remote API

These are separate task dispatches — this task file does NOT inline them.

______________________________________________________________________

## Exit Criteria

- \[ \] CLI tool returned exit code 0
- \[ \] For metadata: `./.opencode/tools/local-issues read N` confirms every updated field in frontmatter
- \[ \] For body: `./.opencode/tools/local-issues read N` confirms body content matches expected value
- \[ \] Post-update decision recorded (pushed or skipped with reason)
- \[ \] No files outside `.issues/N/` were modified

______________________________________________________________________

## Error Handling

| Error                                  | Cause                                                                                            | Resolution                                                                                                     |
| -------------------------------------- | ------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| `./.opencode/tools/local-issues update N` exits non-zero | Invalid arguments, malformed frontmatter, issue not found                                        | Verify issue directory exists and frontmatter is valid YAML. Check that at least one update flag was provided. |
| No update flags provided               | `./.opencode/tools/local-issues update N` called with no `--title`, `--status`, `--phase`, `--labels`, or `--body` | HALT. At least one field must be specified. Report to orchestrator.                                            |
| Invalid field value                    | Status not `open`/`closed`, phase not recognized, labels malformed                               | HALT. Use valid values only.                                                                                   |
| Body content empty                     | `--body ""` or whitespace-only                                                                   | HALT. Body must be non-empty.                                                                                  |
| Issue N not found                      | `.issues/<N>/` or `<child-repo>/.issues/<N>/` directory missing                                     | HALT. Verify issue identifier. Use qualified `{repo}#{N}` form if ambiguous. Cannot update a non-existent issue. |
| CLI tool not found                     | `./.opencode/tools/local-issues` missing                                                           | HALT. The tool must exist for local platform operations.                                                       |
| Push body after update fails           | See push-body task for error codes                                                               | Report failure to orchestrator. The local update is already committed — push failure is a separate concern.    |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate data, or inline push-body logic.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
