## Root Cause

When constructing artifact URLs pointing to the `issues-data` branch, agents use the main repo's filesystem path (`.issues/N/`) as the URL path segment. This is incorrect because the `issues-data` branch is checked out as a worktree at `.issues/`, so the branch's tree root IS the worktree root — the correct path is `N/`, not `.issues/N/`.

## Example of the Defect

```
WRONG: https://gitbucket.newsrx.com/gitbucket/O/R/tree/issues-data/.issues/25/
RIGHT: https://gitbucket.newsrx.com/gitbucket/O/R/tree/issues-data/25/
```

The `.issues/` prefix is the main repo's path to the worktree — it is NOT part of the `issues-data` branch's tree structure.

## Affected Artifacts

- `issue-operations/tasks/push-artifacts.md` — constructs artifact URLs for spec/plan artifacts pushed to `issues-data`
- `issue-operations/tasks/creation.md` — may embed artifact URLs in issue bodies
- Any agent code that constructs `issues-data` branch URLs from the main repo's `.issues/N/` path

## Fix

Add a `url` subcommand to the `local-issues` tool that outputs the correct issue URL based on remote information in the worktree:

```
local-issues url repo#NNN
```

The tool already has worktree context — it knows the `issues-data` branch is at `.issues/` and can compute the correct path segment (`N/` not `.issues/N/`). The subcommand would:

1. Resolve `repo#NNN` to the correct repo entry from session-init's repo table
2. Determine the platform (GitHub/GitBucket/local)
3. Construct the platform-specific issue URL
4. For `issues-data` artifact URLs, use the worktree-relative path (`N/` not `.issues/N/`)

This centralizes URL construction in the tooling layer, eliminating the defect at its source rather than patching individual task files.

## Verification

After fix, `local-issues url repo#NNN` must output a valid, resolvable URL for the issue on the correct platform.

## SC-1: local-issues url subcommand exists
**Evidence Type:** `behavioral`
`local-issues url NewSRX-Tech-LLC/SEC-Filings-Scraper#25` outputs the correct GitBucket issue URL.

## SC-2: Artifact URL uses worktree-relative path
**Evidence Type:** `behavioral`
`local-issues url NewSRX-Tech-LLC/SEC-Filings-Scraper#25 --artifacts` outputs a URL with `tree/issues-data/25/` (not `.issues/25/`).

## SC-3: All task files use local-issues url instead of inline URL construction
**Evidence Type:** `string`
All occurrences of inline `issues-data` URL construction in task files are replaced with `local-issues url` calls.

---

🤖 Co-authored with AI: opencode (opencode/mimo-v2-free)