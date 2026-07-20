## Bug

When the agent needs to create an issue about files in `.opencode/` (guidelines, skills), it routes the issue to the parent project repo instead of the `.opencode` sub-repo. The agent has session-init data mapping paths to repos but does not check file ownership before routing.

## Root Cause

`issue-operations` dispatches based on `github.platform` but does not resolve the target repo from the affected file paths. The agent defaults to the parent repo's owner/repo from session-init without verifying that the issue's content matches that repo's scope. There is no pre-flight check that says "the files this issue touches belong to repo X — verify the target repo is X."

## Fix

Add a repo-ownership verification step to the `issue-operations` `creation` task (Step 1, before platform routing) that:

1. Extracts affected file paths from the issue body or context
2. Resolves each path's repo ownership using session-init path→repo mappings
3. Verifies the target owner/repo matches the resolved repo
4. BLOCKs with `WRONG_REPO` on mismatch

### Change: creation.md

Insert a new Step 1.5 (Repo Ownership Gate) between Step 1 (Determine Title Format) and Step 2 (Create Issue):

```
### Step 1.5: Repo Ownership Gate

**MANDATORY before proceeding to platform routing.** Prevents routing issues to the wrong repository.

- [ ] 1. Extract affected file paths from the issue body or context (look for file paths in the Problem, Scope, or Approach sections)
- [ ] 2. For each file path, resolve repo ownership using session-init path→repo mappings:
   - Paths starting with `.opencode/` → `.opencode` sub-repo (`michael-conrad/.opencode`)
   - Paths starting with `.issues/` → root repo
   - All other paths → root repo
- [ ] 3. If any affected file path resolves to a different repo than the current target:
   - BLOCK with `WRONG_REPO`
   - Report: "Affected files belong to {resolved_repo}, not {current_target}. Route to {resolved_repo} instead."
   - HALT — do not proceed with creation
- [ ] 4. If all affected file paths match the current target repo: proceed to Step 2
```

## SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `creation.md` contains Step 1.5 Repo Ownership Gate with file path extraction and repo resolution | string |
| SC-2 | Gate blocks with `WRONG_REPO` when affected files belong to a different repo | string |
| SC-3 | Gate allows creation when all affected files match the target repo | string |
| SC-4 | Agent routes issue to correct repo when affected files are in `.opencode/` | behavioral |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)