<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Push Spec Artifacts to issues-data Branch

## Overview

Commit `.issues/<N>/` spec artifacts (spec.md, comments.md, state.md, links.yaml, remote.md) to the `issues-data` branch and push to remote. This is a pure-git sync — no curl, no GitHub API, no platform credentials. The `issues-data` branch serves as the persistent artifact store, keeping spec history separate from the main development branch.

**Primary tools:** `git add`, `git commit`, `git push`, `git ls-tree`

**Architectural role:** Push-artifacts is a one-direction sync from the local working tree to the `issues-data` remote branch. It is called after spec artifacts reach a stable state (creation, promotion, update). The `issues-data` branch is append-only — artifacts are never removed, only superseded by newer commits.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/<N>/` directory exists with at least one artifact file (`spec.md`, `comments.md`, `state.md`, `links.yaml`, or `remote.md`)
- \[ \] `issues-data` branch exists on remote (`git ls-remote --heads origin issues-data` returns a ref) OR remote is unreachable (push creates it)
- \[ \] Git is configured with `user.name` and `user.email`
- \[ \] `origin` remote is configured and reachable
- \[ \] Current working directory is clean aside from `.issues/` changes (stash or commit unrelated work first)

______________________________________________________________________

## Procedure

### Step 1: Fetch Latest issues-data Branch

Ensure the local tracking ref is current. If the branch doesn't exist remotely, this step is skipped — push will create it.

```bash
git fetch origin issues-data 2>&1 || true
```

Expected: Fetch succeeds (or fails silently for non-existent branch — the `|| true` handles this).

### Step 2: Git Add the Issue Artifact Directory

Stage all files under the issue's artifact directory:

```bash
git add .issues/<N>/
```

Expected: Files are staged. If no files have changed, `git add` is a no-op.

### Step 3: Commit to issues-data Branch

Check if there are any staged changes from the `.issues/<N>/` subtree. If the index is clean, skip the commit (noop).

Check for changes:

```bash
git diff --cached --name-only -- .issues/<N>/ | head -5
```

If output is empty → nothing to commit (noop — proceed to Exit Criteria with a note).

If output is non-empty → commit to the `issues-data` branch:

```bash
git commit --no-verify -m "docs(#N): spec artifacts [skip ci]"
```

**Important:** `--no-verify` is used because `issues-data` is a non-development branch — hooks are designed for feature branches targeting `dev`. Pre-commit hooks may reject commits to non-standard branches. This is consistent with the local-platform's role as a metadata pipeline, not a development pipeline.

**Edge case — detached HEAD or non-issues-data checkout:** The commit targets the current `HEAD`. If the working tree is not on the `issues-data` branch, the commit lands on the current branch. The push in Step 4 must reference `HEAD:issues-data` to force the target. This pattern is intentionally branch-agnostic — the push target determines where the commit lands remotely, not the local checkout.

### Step 4: Push to origin/issues-data

Push the commit (or noop HEAD if nothing changed) to the `issues-data` branch:

```bash
git push origin HEAD:issues-data --no-verify 2>&1
```

Expected: Push succeeds. If nothing to push (no new commit), git reports "Everything up-to-date" which is a success.

**Note:** `--no-verify` suppresses pre-push hooks for the same reason as Step 3 — `issues-data` is a non-development branch.

### Step 5: Fetch Updated issues-data Branch

Re-fetch to ensure local tracking ref is up to date after the push:

```bash
git fetch origin issues-data 2>&1
```

Expected: Fetch succeeds. `FETCH_HEAD` now points to the latest commit on `issues-data`.

### Step 6: Verify Blobs with git ls-tree

Verify that the pushed artifacts exist as blobs in the remote branch tree. Check for the spec-artifacts directory structure:

```bash
git ls-tree origin/issues-data -- <N>/spec-artifacts/
```

Expected output: one or more lines with blob mode, type, hash, and path under `<N>/spec-artifacts/`. For example:

```
100644 blob abcdef1234567890abcdef1234567890abcdef12	<N>/spec-artifacts/spec.md
100644 blob 1234567890abcdef1234567890abcdef12345678	<N>/spec-artifacts/state.md
```

If the output is empty (no blobs found under `<N>/spec-artifacts/`), attempt a broader check:

```bash
git ls-tree origin/issues-data -- <N>/
```

If both return empty: HALT. Report that the push succeeded but blobs are not visible under the expected path. This indicates the tree structure on `issues-data` does not match the working tree layout.

### Step 7: Build and Return Artifact URL

Extract the repository's HTML URL and construct the artifact URL:

```bash
# Extract html_url from git remote
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
artifact_url = <html_url>/tree/issues-data/<N>/spec-artifacts/
```

Return the `artifact_url` value to the caller.

______________________________________________________________________

## Exit Criteria

- \[ \] `.issues/<N>/` artifacts committed to `issues-data` branch (or confirmed noop with no changes)
- \[ \] Push to `origin issues-data` succeeded (verified by fetch + exit code)
- \[ \] `git ls-tree origin/issues-data -- <N>/spec-artifacts/` returns at least one blob — confirms artifacts landed
- \[ \] `artifact_url` constructed from remote URL
- \[ \] No `curl`, `github_*` API calls, or platform credentials used — pure git only
- \[ \] No files outside `.issues/<N>/` were included in the commit

______________________________________________________________________

## Error Handling

| Error                                                      | Cause                                                   | Resolution                                                                                    |
| ---------------------------------------------------------- | ------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `git push origin HEAD:issues-data` fails with non-zero     | Remote unreachable, auth failure, branch protection     | HALT. Report the git error message. Check remote connectivity and `issues-data` branch config. |
| `git ls-tree origin/issues-data -- <N>/` returns empty     | Commit was a noop, push was a noop, or tree mismatch    | Verify commit actually landed. Run `git log origin/issues-data --oneline -5` to inspect history. |
| `git add .issues/<N>/` produces no changes (noop commit)   | No files were modified since last commit on HEAD        | Report noop. Artifacts are already current. Return success with note.                         |
| `.issues/<N>/` directory does not exist                    | Issue number is wrong or issue was deleted              | HALT. Verify the issue number. Check `.issues/` directory listing.                            |
| `git commit --no-verify` fails                             | Hook rejects the commit despite `--no-verify`           | HALT. Report the hook error. The `issues-data` branch should not be subject to dev-branch hooks — investigate. |
| `origin` remote not configured                             | Repository has no remote                                | HALT. Report no remote configured. Push-artifacts requires a remote to push to.               |
| Remote URL parsing fails                                   | Unrecognized remote URL format                          | HALT. Report the raw remote URL. Construct `artifact_url` manually from known repo info.      |
| Non-zero exit from git fetch                               | Network error, remote down                              | HALT. Report fetch failure. Artifacts may have been pushed but verification cannot complete.  |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate URLs, or fall back to inline platform API calls. Pure git only — no exceptions.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
