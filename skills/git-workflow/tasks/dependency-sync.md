# Task: dependency-sync

## Purpose

Automate the full lifecycle of updating git submodules to their latest dev revision: detect submodules, update to latest, analyze the diff, create a tracking issue, create a feature branch, commit, push, and provide a compare URL for PR review.

This task does NOT invoke the `provenance` task — provenance tracking is handled separately by `review-prep` or `release-promotion` after push.

## Entry Criteria

- `.gitmodules` file exists in the repository root
- Working tree is clean (no uncommitted changes)
- At least one submodule has updates available on its dev branch
- Agent has GitHub API access (for issue creation)

## Exit Criteria

- All updated submodules are committed on the `dep-sync/<issue-number>` branch
- Branch is pushed to origin
- Tracking issue created with per-submodule diff table
- Compare URL generated for PR review
- Result contract populated with `issue_number`, `issue_url`, `compare_url`, `submodules_updated`, `commits_count`

## Pre-Check HALT Conditions

| Condition | Action |
|-----------|--------|
| `.gitmodules` missing | HALT — report "No submodules found" and stop. Do NOT create branches or commits. |
| All submodules already at latest | HALT — report "No submodule changes — all submodules are up to date" and stop. Do NOT create branches or commits. |
| Dirty working tree (`git status --porcelain` not empty) | HALT — report "Working tree has uncommitted changes. Commit or stash changes before running dependency-sync." and stop. |
| Not on a feature branch (on `dev` or `main`) | HALT — report "Must run from a feature branch. Run git-workflow --task pre-work first." and stop. |

## Procedure

### Step 0: Detect Submodules & Pre-Check

```bash
# Pre-check 1: Working tree cleanliness
git status --porcelain
# If NOT empty → HALT with dirty working tree message

# Pre-check 2: Submodule existence
test -f .gitmodules
# If NOT found → HALT with "No submodules found"

# Pre-check 3: Current branch
git branch --show-current
# If dev or main → HALT with branch message

# List submodules from .gitmodules
git config --file .gitmodules --get-regexp path
```

Read `.gitmodules` to enumerate all submodule paths and names.

### Step 1: Update Submodules to Latest Dev

For each submodule:

```bash
# Initialize submodules if needed
git submodule init

# For each submodule path:
git submodule update --remote <submodule-path>
```

This updates each submodule to the latest commit on its configured branch (typically `dev`).

### Step 2: Analyze Diff Per Submodule

For each submodule that was updated, collect:

```bash
# Get old SHA (before update)
git diff --submodule <submodule-path>

# Get commit count and subjects between old and new SHAs
cd <submodule-path>
git log --oneline <old-sha>..<new-sha>
cd ..
```

Build a per-submodule table:

| Submodule | Old SHA | New SHA | Commits | Subject Lines |
|-----------|---------|---------|---------|----------------|
| path/to/sub | abc1234 | def5678 | 3 | fix: bug, feat: feature, docs: update |

### Step 3: Create Tracking Issue

Create a GitHub issue documenting the submodule updates:

```
Title: chore: update submodules to latest dev

Body:
## Submodule Updates

| Submodule | Old SHA | New SHA | Commits | Subject Lines |
|-----------|---------|---------|---------|----------------|
| path/to/sub | abc1234 | def5678 | 3 | fix: bug, feat: feature, docs: update |

## Summary

- <N> submodule(s) updated
- <M> total commit(s) across all submodules

Co-authored with AI: <AgentName> (<ModelId>)
```

Use `github_issue_write(method=create, ...)` to create the issue.

Extract the issue number and URL from the API response `html_url` field.

### Step 4: Create Feature Branch

```bash
# Branch naming follows dep-sync/<issue-number> pattern
git checkout -b dep-sync/<issue-number>
```

### Step 5: Commit Submodule Changes

```bash
# Stage all submodule changes
git add .

# Commit with issue reference
git commit -m "dep-sync(#<issue-number>): update submodules to latest dev

- <submodule-path>: <old-sha-short>..<new-sha-short> (<N> commits)
- <submodule-path>: <old-sha-short>..<new-sha-short> (<M> commits)

Fixes #<issue-number>"
```

### Step 6: Push & Provide Compare URL

```bash
# Push the branch
git push -u origin dep-sync/<issue-number>
```

Construct the compare URL using session-init values:

```
https://github.com/<github.owner>/<github.repo>/compare/dev...dep-sync/<issue-number>
```

Perform character-match verification: confirm the constructed URL contains the exact `<github.owner>` and `<github.repo>` strings from session init.

## Result Contract

```yaml
status: DONE | BLOCKED | SKIP
task: dependency-sync
issue_number: <N>
issue_url: <url>
compare_url: <url>
submodules_updated:
  - path: <submodule-path>
    old_sha: <sha>
    new_sha: <sha>
    commits_count: <N>
commits_count: <N>
```

## Context Required

- `.gitmodules` file for submodule enumeration
- GitHub API access for issue creation
- Session variables: `<github.owner>`, `<github.repo>`, `<dev.name>`, `<dev.email>`
- Current branch must be a feature branch (not `dev` or `main`)

## Cross-References

- Related tasks: `git-workflow --task pre-work` (branch creation prerequisite)
- Related tasks: `git-workflow --task review-prep` (post-push review workflow)
- Related skills: `issue-operations` (issue creation)
- This task does NOT invoke: `provenance` (provenance is handled by review-prep/release-promotion)