<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Delete

## Overview

Delete a local issue by removing its directory. Per Card-016, delete is a tool-level CLI command for cleanup, not a normal agent workflow operation. This task provides the routing path from dispatcher → platform → tool when an explicit delete request arrives.

**Primary tool:** `./.opencode/tools/local-issues`

**Key architectural rule:** Delete is local-only. The remote issue (if any) is untouched. With `--force`, the local mirror is removed despite the remote link. Without `--force`, delete refuses if a remote link exists — this prevents accidental destruction of a local mirror that has stakeholder data on the remote.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue identifier is known — bare `N` (integer) or qualified `{repo}#{N}` (e.g. `<repo>#<N>`)
- \[ \] Issue N exists in `.issues/{N}/` (or `<child-repo>/.issues/{N}/` for qualified)
- \[ \] `./.opencode/tools/local-issues` CLI tool is available
- \[ \] Intent is confirmed — delete is ONLY for cleanup (orphaned drafts, test artifacts, duplicates). Delete is NOT for closing issues in normal workflow. Use `close` instead.
- \[ \] Orchestrator has explicitly requested deletion — delete is never self-initiated by a sub-agent

______________________________________________________________________

## Safety Guard Table

| Condition                                                      | CLI Flag  | Behavior                                                                                          | Exit Code |
| -------------------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------- | --------- |
| No remote link (`github_issue` frontmatter is absent OR empty) | (none)    | Delete the local issue directory. Auto-commit.                                                    | 0         |
| Remote link exists → agent wants to preserve remote            | `--force` | Delete the local mirror only. Remote issue untouched. Auto-commit.                                | 0         |
| Remote link exists → `--force` NOT provided                    | (none)    | Refuse. Print warning: "Remote issue R exists at `url`. Use --force to remove local mirror only." | 2         |
| Issue does not exist                                           | (none)    | Refuse. Print error.                                                                              | 1         |

______________________________________________________________________

## Procedure

| Step | Action              | Command / Details                                                                                                                                       |
| ---- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Verify issue exists | `./.opencode/tools/local-issues read <repo>#<N>` — confirm exit 0. If exit non-zero → exit 1 (issue not found).                                                                    |
| 2    | Check remote link   | Read frontmatter for `github_issue` or `remote_url` field. If present and non-empty → remote link exists.                                               |
| 3    | Apply safety guard  | If remote link exists AND `--force` NOT provided → exit 2 (blocked). Report: "Remote issue R exists at `url`. Use --force to remove local mirror only." |
| 4    | Delete              | `./.opencode/tools/local-issues delete <repo>#<N> [--force]` — removes `.issues/{N}/` directory. Auto-commits on issues-data branch.                 |
| 5    | Verify deletion     | `./.opencode/tools/local-issues read <repo>#<N>` — confirm exit non-zero (issue no longer exists). Verify `.issues/{N}/` no longer exists.    |
| 6    | Report              | Report to orchestrator: issue number, whether remote link existed, whether --force was used, exit code, and whether remote issue is unaffected.         |

______________________________________________________________________

## Exit Criteria

- \[ \] CLI tool returned exit code 0
- \[ \] `.issues/{N}/` absent — issue directory fully removed
- \[ \] Remote issue is confirmed untouched (if remote link existed, `--force` removes only the local mirror)
- \[ \] For exit 2: warning was printed, no files were modified
- \[ \] For exit 1: issue was not found, no files were modified
- \[ \] Auto-commit succeeded (if configured)

______________________________________________________________________

## Error Handling

| Error                                          | Cause                                      | Resolution                                                                                                       |
| ---------------------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------- |
| `./.opencode/tools/local-issues delete N` exits 1                | Issue does not exist                       | HALT. Issue N has no directory. May have been deleted already.                                                   |
| `./.opencode/tools/local-issues delete N` exits 2                | Remote link exists, `--force` not provided | Safety guard triggered. Report to orchestrator. Orchestrator must decide: retry with `--force` or abort.         |
| `./.opencode/tools/local-issues delete N` exits non-zero (other) | CLI error, filesystem error, permissions   | HALT. Check directory permissions, filesystem state, CLI tool integrity.                                         |
| Issue N exists but frontmatter is corrupt      | `spec.md` has invalid YAML                 | HALT. Report corrupt issue. Deletion may still proceed with `--force` but orchestrator must decide.              |
| CLI tool not found                             | `./.opencode/tools/local-issues` missing     | HALT. The tool must exist for local platform operations.                                                         |
| Auto-commit fails                              | Git error on issues-data branch            | HALT. Local deletion has already happened (files removed). Report to orchestrator. Manual git fix may be needed. |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. The safety guard (exit 2) is an intentional block — never proceed past it without orchestrator authorization to retry with `--force`. Filesystem-level deletion (rm -rf) is NEVER performed inline — always route through the CLI tool.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
