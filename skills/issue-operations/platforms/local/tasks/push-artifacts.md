<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Push Spec Artifacts to issues-data Branch

## Overview

Commit `.issues/<N>/` spec artifacts (spec.md, comments.md, state.md, links.yaml, remote.md) to the `issues-data` branch and push to remote. Uses `local-issues sync` for the commit+push operation, with explicit local filesystem verification before and after.

**Primary tool:** `.opencode/tools/local-issues sync` (commit+push), `ls`/`cat`/`find` (local verification)

**Architectural role:** Push-artifacts is a one-direction sync from the local working tree to the `issues-data` remote branch. It is called after spec artifacts reach a stable state (creation, promotion, update). The `issues-data` branch is append-only — artifacts are never removed, only superseded by newer commits.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/<N>/` directory exists with at least one artifact file (`spec.md`, `comments.md`, `state.md`, `links.yaml`, or `remote.md`)
- \[ \] `local-issues` tool is available at `.opencode/tools/local-issues`

______________________________________________________________________

## Procedure

### Step 1: Verify Local Artifacts Exist

Confirm the issue directory and its artifacts are present on the local filesystem:

```bash
ls .issues/<N>/
```

Expected: Directory exists with at least one artifact file. If the directory does not exist, HALT — artifacts must be created before push.

### Step 2: Sync via local-issues

The `local-issues sync` command handles commit, pull-rebase, and push for the `.issues/` worktree:

```bash
.opencode/tools/local-issues sync
```

Expected: Sync completes with exit 0. Output confirms commit and push.

### Step 3: Verify Local State After Sync

Confirm the local `.issues/` worktree is still intact after sync:

```bash
ls .issues/<N>/
```

Expected: Directory still exists with artifacts. The sync operation should not delete local files.

### Step 4: Build and Return Artifact URL

Extract the repository's HTML URL from git remote:

```bash
REMOTE_URL=$(git remote get-url origin)
```

Parse the remote URL to extract the base HTML URL. For common Git hosting:

| Remote URL Pattern               | HTML URL                            |
| -------------------------------- | ----------------------------------- |
| `git@github.com:owner/repo.git`  | `https://github.com/owner/repo`     |
| `https://github.com/owner/repo`  | `https://github.com/owner/repo`     |
| `git@githost:owner/repo.git`     | `https://githost/owner/repo`        |

Construct the artifact URL:

```
artifact_url = <html_url>/tree/issues-data/<N>/
```

Return the `artifact_url` value to the caller.

______________________________________________________________________

## Exit Criteria

- \[ \] Local `.issues/<N>/` artifacts verified on filesystem (Step 1)
- \[ \] `local-issues sync` completed with exit 0 (Step 2)
- \[ \] Local artifacts confirmed intact after sync (Step 3)
- \[ \] `artifact_url` constructed from remote URL
- \[ \] No raw `git add`, `git commit`, `git push`, or `git ls-tree` commands used — commit+push delegated to `local-issues` tool

______________________________________________________________________

## Error Handling

| Error                                                      | Cause                                                   | Resolution                                                                                    |
| ---------------------------------------------------------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `local-issues sync` fails with non-zero                    | Worktree not initialized, remote unreachable, auth failure | HALT. Report the tool error output. Run `local-issues init` first if worktree not set up.     |
| `.issues/<N>/` directory does not exist                    | Issue number is wrong or issue was deleted              | HALT. Verify the issue number. Check `.issues/` directory listing.                            |
| `local-issues` tool not found                              | Tool not installed or path wrong                        | HALT. Verify `.opencode/tools/local-issues` exists.                                           |
| Remote URL parsing fails                                   | Unrecognized remote URL format                          | HALT. Report the raw remote URL. Construct `artifact_url` manually from known repo info.      |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate URLs, or fall back to inline platform API calls. Commit+push goes through `local-issues`; local verification uses standard filesystem tools (`ls`, `cat`, `find`).

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
