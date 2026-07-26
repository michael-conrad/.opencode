# Task: record-authorization

## Purpose

Write session authorization (given in chat) into persistent issue state in the `.issues/` worktree. Updates three files (`spec.md` frontmatter, `comments.yaml`, `issue.yaml`) and commits the worktree. This task runs BEFORE any verification step reads authorization state — it eliminates the circular dependency where verification checks for recorded authorization that hasn't been written yet.

## Entry Criteria

- Authorization scope resolved (from `scope-auto-resolve`)
- Issue number known
- `.issues/` worktree initialized (orphan branch checked out)

## Exit Criteria

- `spec.md` frontmatter updated with `status: approved` (when scope >= `for_implementation`)
- `comments.yaml` has new authorization record with text, scope, timestamp, human attribution
- `issue.yaml` has `approved-for-{scope}` label
- `.issues/` worktree committed with all three changes
- Result contract returned

## Procedure

### 1. Verify Worktree Existence

Check that the `.issues/` worktree is initialized:

```bash
git -C .issues rev-parse --git-dir
```

If the worktree does not exist (command fails), return BLOCKED with `reason: ISSUES_WORKTREE_NOT_INITIALIZED`.

### 2. Read Current State

Read the three files that will be modified:

1. Read `.issues/{N}/spec.md` — parse YAML frontmatter
2. Read `.issues/{N}/comments.yaml` — if missing, treat as empty (no prior comments)
3. Read `.issues/{N}/issue.yaml` — parse labels and metadata

### 3. Handle Missing spec.md

If `spec.md` does not exist at `.issues/{N}/spec.md`, return BLOCKED with `reason: SPEC_MD_NOT_FOUND`. A spec must exist before authorization can be recorded against it.

### 4. Handle Malformed Frontmatter

If `spec.md` frontmatter is malformed (missing YAML delimiters, invalid YAML, missing `status` field), return BLOCKED with `reason: MALFORMED_FRONTMATTER`. Do NOT attempt to fix or recover the frontmatter.

### 5. Update `spec.md` Frontmatter

If the resolved scope is `for_implementation` or higher (scope hierarchy: `for_analysis` < `for_spec` < `for_plan` < `for_implementation` < `for_pr` < `for_release_pr`):

- If `status` is already `approved`: skip the update — authorization is already recorded. Report success without modifying the file.
- Otherwise: set `status: approved` in the YAML frontmatter
- Preserve all other frontmatter fields unchanged

If the resolved scope is below `for_implementation` (`for_analysis`, `for_spec`, `for_plan`):

- Do NOT set `status: approved`
- Leave frontmatter unchanged

### 6. Append to `comments.yaml`

Append a new authorization record to `comments.yaml`. The file is a YAML list of comment/authorization entries.

#### 6a. Read Existing `comments.yaml`

Read `.issues/{N}/comments.yaml`:

```bash
cat .issues/{N}/comments.yaml
```

If the file does not exist, skip to step 6c (create with initial entry).

#### 6b. Validate Existing YAML

Parse the existing `comments.yaml` content as YAML. It MUST be a valid YAML list (`- type: ...` entries). If the file exists but contains invalid YAML (parse error, not a list, empty file), return BLOCKED with `reason: MALFORMED_COMMENTS_YAML`. Do NOT attempt to fix or recover the malformed content.

#### 6c. Append or Create

Construct the new authorization record:

```yaml
- type: authorization
  author: "human"
  scope: "{resolved_scope}"
  text: "{authorization_text}"
  timestamp: "{utc_timestamp}"
```

- **If `comments.yaml` exists and is valid:** Append the new record to the existing list. Write the complete list back to the file.
- **If `comments.yaml` does not exist:** Create the file with the new record as the sole entry in the list.
- **If `comments.yaml` exists but is empty (zero bytes):** Treat as missing — create the file with the new record as the sole entry.

### 7. Update `issue.yaml` Labels

Update `.issues/{N}/issue.yaml` to add the `approved-for-{scope}` label to the labels array. Preserve all existing labels. Do NOT remove prior scope labels — that is the `apply-label` task's responsibility.

#### 7a. Read Current `issue.yaml`

Read `.issues/{N}/issue.yaml`:

```bash
cat .issues/{N}/issue.yaml
```

If the file does not exist, skip to step 7c (create with initial entry).

#### 7b. Validate and Parse

Parse the existing `issue.yaml` content as YAML. It MUST be a valid YAML mapping with an optional `labels` key. If the file exists but contains invalid YAML (parse error, not a mapping), return BLOCKED with `reason: MALFORMED_ISSUE_YAML`. Do NOT attempt to fix or recover the malformed content.

If the file exists and is valid, extract the current `labels` array (if present). If `labels` is missing, treat it as an empty list.

#### 7c. Merge Label

Construct the new label value: `"approved-for-{scope}"` (where `{scope}` is the resolved scope string, e.g., `for_implementation` → `"approved-for-implementation"`).

- **If `issue.yaml` exists and is valid:** Check if the label already exists in the `labels` array (case-sensitive string comparison). If it exists, skip the update — the label is already present. If it does not exist, append the new label to the existing `labels` array.
- **If `issue.yaml` does not exist:** Create the file with the new label as the sole entry in the `labels` array.
- **If `issue.yaml` exists but is empty (zero bytes):** Treat as missing — create the file with the new label as the sole entry.

#### 7d. Write Updated `issue.yaml`

Write the updated YAML back to `.issues/{N}/issue.yaml`. Preserve all existing fields (`title`, `status`, `body`, `created_at`, `updated_at`, etc.) — only modify the `labels` array and update the `updated_at` timestamp to the current UTC timestamp.

```yaml
labels:
  - "approved-for-{scope}"
  # ... existing labels preserved
updated_at: "{utc_timestamp}"
```

### 8. Commit Worktree

Commit all three changes in the `.issues/` worktree:

```bash
git -C .issues add -A
git -C .issues commit -m "authorization: {scope} for issue #{N}"
```

If the commit fails (merge conflict, hook rejection, dirty index), return BLOCKED with `reason: COMMIT_FAILED` and include the git error output. The authorization data has been written to disk but is not yet committed — do NOT report success without a successful commit.

### 9. Handle Concurrent Authorization

If the commit fails due to a concurrent modification (the worktree state changed between write and commit):

1. Re-read the current state of all three files
2. Verify the existing authorization record is compatible (same scope or higher)
3. If compatible (same scope): skip and report success — authorization already recorded
4. If higher scope: overwrite with the new scope and retry the commit
5. If conflicting scope: return BLOCKED with `reason: CONCURRENT_AUTHORIZATION_CONFLICT`

### 10. Verify Commit Success

After a successful commit, verify the worktree is clean:

```bash
git -C .issues status --porcelain
```

If the worktree is not clean, return BLOCKED with `reason: COMMIT_FAILED` — the commit may have been partial.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<summary of what was recorded>"
artifact_path: ".issues/{N}/"
blocker_reason: "<reason if BLOCKED>"
```

## Edge Cases

| Condition | Action |
|-----------|--------|
| `.issues/` worktree not initialized | BLOCKED with `ISSUES_WORKTREE_NOT_INITIALIZED` |
| Missing `spec.md` | BLOCKED with `SPEC_MD_NOT_FOUND` |
| Malformed `spec.md` frontmatter | BLOCKED with `MALFORMED_FRONTMATTER` |
| Missing `comments.yaml` | Create file with initial authorization record |
| Malformed `comments.yaml` (invalid YAML, not a list, empty) | BLOCKED with `MALFORMED_COMMENTS_YAML` |
| Missing `issue.yaml` | Create file with initial label entry |
| Malformed `issue.yaml` (invalid YAML, not a mapping) | BLOCKED with `MALFORMED_ISSUE_YAML` |
| Empty `issue.yaml` (zero bytes) | Treat as missing — create with initial label entry |
| Label already present in `issue.yaml` | Skip update, report success |
| Empty `comments.yaml` (zero bytes) | Treat as missing — create with initial entry |
| Already approved (`status: approved` already set) | Skip update, report success |
| Scope below `for_implementation` | Do NOT set `status: approved`, leave frontmatter unchanged |
| Commit failure | BLOCKED with `COMMIT_FAILED` + git error output |
| Concurrent authorization (same scope) | Skip, report success |
| Concurrent authorization (higher scope) | Overwrite and retry commit |
| Concurrent authorization (conflicting scope) | BLOCKED with `CONCURRENT_AUTHORIZATION_CONFLICT` |

## Cross-References

- `verify-authorization/scope-auto-resolve.md` — Predecessor: resolves scope before this task runs
- `verify-authorization/verify-recording.md` — Successor: reads back recorded state and confirms
- `apply-label.md` — Runs after verify-recording to apply GitHub label
- `completion.md` — Post-authorization cleanup and reporting
