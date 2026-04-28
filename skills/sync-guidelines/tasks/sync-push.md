# Task: sync-push

## Purpose

Push core guideline/skill changes from source repository to target repository via GitHub/GitBucket issue. This task creates a structured sync issue that enables the target repository's maintainer to review and apply core changes originating from the source.

## Operating Protocol

1. Invoked by: `/skill sync-guidelines --task sync-push`
2. When to use: When syncing changes FROM source repo TO target repo
3. Exit criteria: Sync issue created in target repo with classified files

## Procedure

### Step 1: Pre-Work Verification

Before starting the sync-push:

1. **Verify on feature branch** (never push from `main`)
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

3. **Verify target repo access**
   ```python
   github_get_file_contents(
       owner=<target_owner>,
       repo=<target_repo>,
       path=""
   )
   ```
   If access denied, HALT and report.

### Step 2: Discover Changed Files

1. **Detect changed files** since last sync:
   ```bash
   git diff --name-only <last-sync-commit>..HEAD -- .opencode/
   ```

2. **Read the entire file content** of each changed file using the `read` tool. Do NOT analyze filenames or directory patterns — read every file in full.

3. **Analyze semantically** what the file does based on its actual content:
   - Does it define workflows applicable to any project?
   - Does it reference project-specific paths, databases, or APIs?
   - Is it self-contained or does it require project context?

4. **Determine classification** using `classify` task criteria (core vs project-specific).

### Step 3: Conflict Detection

Before creating the push issue, check for potential conflicts:

1. **Check if file exists in target repo:**
   ```python
   github_get_file_contents(
       owner=<target_owner>,
       repo=<target_repo>,
       path="filepath"
   )
   ```

2. **If file exists in both repos and both modified:**
   - Note conflict in the sync issue
   - Include both versions for comparison
   - Recommend manual merge in issue body

3. **If file only exists in source:**
   - Mark as "new file" in the sync issue
   - No conflict possible

### Step 4: Create Sync Issue

Use `github_issue_write` to create an issue in target repository:

```python
github_issue_write(
    method="create",
    owner=<target_owner>,
    repo=<target_repo>,
    title="[SYNC] Push: {count} files from {source_repo}",
    body=<structured issue per issue-format template>,
    labels=["sync", "needs-review"]
)
```

Issue format follows the `issue-format` task template. Every file MUST have its content, classification reasoning, and project-specific findings documented.

### Step 5: Report Completion

Report to chat documenting:
- Files analyzed (count)
- Classification decisions with reasoning per file
- Sync issue URL created (extracted from API response `html_url`)
- Any conflicts detected

## Error Handling

| Error | Resolution |
|-------|-----------|
| Target repo access denied | HALT and report access issue |
| No files changed since last sync | Report "No changes to sync" and HALT |
| File read failure | Skip file, report in issue as "read failure" |
| Issue creation fails | Retry once; if failure persists, HALT |

## Key Principles

### Content-Based Classification

Classification decisions are based on reading and analyzing the actual content of each changed file. Filename patterns, directory locations, and heuristics are NOT classification criteria. The `classify` task provides the semantic analysis framework. Every classification decision must have documented reasoning in the sync issue.

### Issue-Based Sync, Not Direct Modification

Sync-push creates GitHub Issues in the target repository — it does NOT directly create, modify, or delete files in the target. The target maintainer reviews the sync issue and decides which changes to apply. Direct modification of another repository without review violates the approval-gate principle.

### Idempotent Issue Creation

Before creating a sync issue, check whether an open sync issue already exists for this source repository and commit range. Duplicate sync issues create confusion and may lead to conflicting changes. Use `github_list_issues` with the `sync` label to check for existing issues first.

### No Authorization Required for Issue Creation

Creating a sync issue is a reporting action, not an implementation action. It does not require explicit authorization per `010-approval-gate.md` §Issue Creation Is Reporting, Not Implementation. The issue is a proposal for the target maintainer — applying the changes in the target repo requires separate authorization.

## Result Contract

```yaml
status: DONE | BLOCKED
task: sync-push
files_analyzed: <int>
core_count: <int>
project_specific_count: <int>
conflicts_detected: <int>
issue_url: <url|null>
blocking_reason: <str|null>
```

## Context Required

- Related skills: `sync-guidelines` (parent skill)
- Related tasks: `classify`, `issue-format`