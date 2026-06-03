<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Creation

## Overview

Create issues in the local `.issues/` directory. Three scenarios cover the full lifecycle: local-only drafts, promote-to-remote, and remote-first import.

**Primary tool:** `./.opencode/tools/local-issues`

______________________________________________________________________

## Entry Criteria

- \[ \] Platform is `local` or unset (`github.platform == "local"`)
- \[ \] `.issues/` directory exists at repo root (create if missing)
- \[ \] `./.opencode/tools/local-issues` CLI tool is available
- \[ \] For promote/import-remote scenarios: remote platform type is known (`github` or `gitbucket`)
- \[ \] For promote scenario: local draft issue exists and is in promotable phase
- \[ \] For import-remote scenario: remote issue number is known

______________________________________________________________________

## Scenario Selection Table

| Condition                                                              | Scenario         | CLI Command                                            |
| ---------------------------------------------------------------------- | ---------------- | ------------------------------------------------------ |
| Platform is `local` OR user explicitly requested local-only draft      | **draft**        | `./.opencode/tools/local-issues create --title "TITLE" --labels L1,L2`   |
| Local draft exists, user says "promote" / "create the spec"            | **promote**      | `./.opencode/tools/local-issues promote N` (preceded by remote creation) |
| Remote issue R already exists on `github`/`gitbucket`, import to local | **remote-first** | `./.opencode/tools/local-issues import-remote N --platform TYPE`         |

______________________________________________________________________

## Per-Scenario Procedure

### Scenario A: Draft (Local-Only)

Create a local-only draft issue. No API calls, no remote.

| Step | Action          | Command / Details                                                                |
| ---- | --------------- | -------------------------------------------------------------------------------- |
| 1    | Dedup check     | `./.opencode/tools/local-issues search --query "<keywords>"` — non-empty = DUPLICATE → HALT        |
| 2    | Create issue    | `./.opencode/tools/local-issues create --title "TITLE" --labels "L1,L2"` — captures local number N |
| 3    | Write spec body | Full fidelity spec body content written to `.issues/N/spec.md`                   |
| 4    | Set phase       | Phase set to `draft` in `.issues/N/state.md`                                     |
| 5    | Verify          | `./.opencode/tools/local-issues read N` — exit 0 = PASS                                            |

**Result:** Local issue N in draft phase. No remote exists. `links.yaml` created empty.

______________________________________________________________________

### Scenario B: Promote (Local Draft → Remote)

Promote a local draft to a remote platform. The local issue is renumbered to match the remote issue number.

| Step | Action                | Command / Details                                                                                                               |
| ---- | --------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Verify promotable     | Phase must be `draft` or `ready-to-promote`. Check no TBD/TODO placeholders in spec body.                                       |
| 2    | Create remote issue   | API call per platform (`issue-operations --task creation`). Body = executive summary from local spec. Label = `needs-approval`. |
| 3    | Capture remote number | Extract remote issue number R from API response `html_url` or `number` field                                                    |
| 4    | Renumber local        | `./.opencode/tools/local-issues renumber N --to R` — renames `.issues/N/` → `.issues/R/`, updates frontmatter                                     |
| 5    | Update metadata       | Set `github_issue: R`, `remote_url: <url>`, `phase: promoted` in frontmatter                                                    |
| 6    | Push exec summary     | Write `remote.md` to `.issues/R/remote.md` with remote context. `./.opencode/tools/local-issues push-body R`.                                     |
| 7    | Tag gate              | Create tag: `<parent-repo>/R/spec-promoted` — push tag to remote                                                                |
| 8    | Verify                | `./.opencode/tools/local-issues read R` confirms all metadata fields, remote_url, and phase                                                       |

**Result:** Local `.issues/R/` linked to remote issue R. Phase is `promoted`.

______________________________________________________________________

### Scenario C: Remote-First (Import Remote → Local)

Mirror an existing remote issue into local `.issues/`. The local issue uses the same number as the remote.

| Step | Action                          | Command / Details                                                                                |
| ---- | ------------------------------- | ------------------------------------------------------------------------------------------------ |
| 1    | Pre-creation dedup              | Cross-context dedup: `./.opencode/tools/local-issues search --query "<keywords>"` + remote API search. Dual dedup. |
| 2    | On CLEAN result                 | Proceed. On CONFLICT: HALT with candidate list.                                                  |
| 3    | Fetch remote issue              | API call per platform → extract title, body, html_url, state, labels                             |
| 4    | Fetch remote comments           | API call per platform → collect all comments chronologically                                     |
| 5    | Create local with remote number | `./.opencode/tools/local-issues create --number R --title "TITLE"` — uses remote issue number                      |
| 6    | Write spec.md mirror            | Remote body written as full fidelity mirror to `.issues/R/spec.md`                               |
| 7    | Write comments.md               | All remote comments in chronological order to `.issues/R/comments.md`                            |
| 8    | Write remote.md                 | Executive summary extracted from remote body                                                     |
| 9    | Write state.md                  | `phase: promoted`, `promotion_type: retroactive_import`                                          |
| 10   | Update frontmatter              | Set `github_issue: R`, `remote_url: <url>`                                                       |
| 11   | Verify                          | `./.opencode/tools/local-issues read R` confirms body matches remote, comments match                               |

**Result:** Local `.issues/R/` mirrors full remote issue. No data loss.

______________________________________________________________________

## Exit Criteria

- \[ \] Issue directory exists at `.issues/<N>/` with correct number
- \[ \] `spec.md` contains the full issue body
- \[ \] `state.md` has correct phase value (`draft` or `promoted`)
- \[ \] `links.yaml` exists (empty for new drafts, populated for imports/promotions)
- \[ \] `./.opencode/tools/local-issues read N` returns exit 0
- \[ \] For promoted/imported: `remote_url` and `github_issue` are set in frontmatter
- \[ \] For promoted: tag created and pushed

______________________________________________________________________

## Error Handling

| Error                                 | Cause                                                | Resolution                                                                                    |
| ------------------------------------- | ---------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `./.opencode/tools/local-issues create` exits non-zero  | Missing title, invalid labels, counter file missing  | Check arguments. Initialize `.issues/.counter` if missing.                                    |
| DEDUP: search returns existing issue  | Duplicate title/keywords found                       | HALT. Present candidates to orchestrator. Do not proceed.                                     |
| Promote: phase is not `draft`         | Issue already promoted or not created via draft flow | HALT. Report current phase. Only `draft` or `ready-to-promote` are promotable.                |
| Promote: remote creation fails        | API error (auth, rate limit, 422)                    | HALT. Report API error from platform-specific response.                                       |
| Import-remote: remote fetch fails     | Remote issue does not exist, API error               | HALT. Verify remote issue number is correct.                                                  |
| Import-remote: local number collision | `.issues/R/` already exists                          | HALT. Report collision. Orchestrator must resolve (archive, delete, or use different number). |
| Renumber fails during promote         | Target directory `.issues/R/` already exists         | HALT. Target dir must be empty. Manually resolve collision.                                   |
| CLI tool not found                    | `./.opencode/tools/local-issues` missing               | HALT. The tool must exist for local platform operations.                                      |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip or fall back to inline work.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
