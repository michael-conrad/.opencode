# Task: sync-pull

## Purpose

Pull core guideline/skill changes from source repository into local repository via GitHub/GitBucket issue. This task creates a structured sync issue in the source repository requesting that core changes be reviewed and applied locally.

## Operating Protocol

1. Invoked by: `/skill sync-guidelines --task sync-pull`
2. When to use: When syncing changes FROM source repo INTO local repo
3. Exit criteria: Sync issue created in source repo with classified files

## Procedure

### Step 1: Pre-Work Verification

Before starting the sync-pull:

1. **Verify on feature branch** (never pull into `main`)
   ```bash
   BRANCH=$(git branch --show-current)
   if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "dev" ]; then
       # BLOCKED — create feature branch first
   fi
   ```

2. **Check for uncommitted changes**
   ```bash
   git status --porcelain
   ```
   Stash if needed before proceeding.

3. **Verify source repo access**
   ```python
   github_get_file_contents(
       owner=<source_owner>,
       repo=<source_repo>,
       path=""
   )
   ```

### Step 2: Discover Changed Files

1. **Detect changed files** since last sync:
   ```bash
   git diff --name-only <last-sync-commit>..HEAD -- .opencode/
   ```

2. **Read each file's content from source repository** using `github_get_file_contents` or local file reads:
   - Fetch the full content of each changed file
   - Do NOT classify by filename patterns alone
   - Read and analyze every file's content

3. **Analyze and classify** using `classify` task criteria:
   - Core content (generic, portable) → sync
   - Project-specific content (paths, configs, names) → skip
   - Uncertain → flag for human review

### Step 3: Conflict Detection (Pull)

Before creating the pull issue, check for local conflicts:

1. **Read local file content** for each file proposed for sync:
   - If the file does not exist locally → new file, no conflict
   - If the file exists and is identical → already synced, skip
   - If the file exists and differs → potential conflict, mark for manual review

2. **Analyze for project-specific modifications:**
   - Check for project-specific imports, paths, or configurations
   - If project-specific content found in the local version:
     - SKIP this file from automatic sync
     - Note as "protected" in the issue
     - Recommend manual review if the core content is important

3. **Flag protected files:**
   - Files with project-specific content should NEVER be overwritten automatically
   - The sync issue should list these files with "protected" status
   - Manual merge is required for protected files

### Step 4: Create Sync Issue

Use `github_issue_write` to create an issue in source repository:

```python
github_issue_write(
    method="create",
    owner=<source_owner>,
    repo=<source_repo>,
    title="[SYNC] Pull: {count} files from {source_repo}",
    body=<structured issue per issue-format template>,
    labels=["sync", "needs-review"]
)
```

Issue format follows the `issue-format` task template, including:
- Full file contents for human review
- Classification reasoning per file
- Protected file analysis
- Recommended manual merge approach

### Step 5: Report Completion

Report to chat documenting:
- Files analyzed (count)
- Classification decisions with reasoning per file
- Protected files identified (count and list)
- Sync issue URL created (extracted from API response `html_url`)

## Pull vs Push

| Aspect | sync-pull | sync-push |
|--------|-----------|----------|
| Direction | Source → Local | Local → Source |
| Issue location | Source repo | Target repo |
| Protected files | Skip automatically | Note as conflict |
| Conflict handling | Local wins | Source wins (with note) |

## Error Handling

| Error | Resolution |
|-------|-----------|
| Source repo access denied | HALT and report access issue |
| No files changed since last sync | Report "No changes to sync" and HALT |
| Local file has project-specific content | Mark as protected, skip from automatic sync |
| Issue creation fails | Retry once; if failure persists, HALT |

## Context Required

- Related skills: `sync-guidelines` (parent skill)
- Related tasks: `classify`, `issue-format`