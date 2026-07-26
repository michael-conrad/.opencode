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

### 3. Handle Malformed Frontmatter

If `spec.md` frontmatter is malformed (missing YAML delimiters, invalid YAML, missing `status` field), return BLOCKED with `reason: MALFORMED_FRONTMATTER`. Do NOT attempt to fix or recover the frontmatter.

### 4. Update `spec.md` Frontmatter

If the resolved scope is `for_implementation` or higher (scope hierarchy: `for_analysis` < `for_spec` < `for_plan` < `for_implementation` < `for_pr`):

- Set `status: approved` in the YAML frontmatter
- Preserve all other frontmatter fields unchanged

If the resolved scope is below `for_implementation` (`for_analysis`, `for_spec`, `for_plan`):

- Do NOT set `status: approved`
- Leave frontmatter unchanged

### 5. Append to `comments.yaml`

Append a new authorization record to `comments.yaml`:

```yaml
- type: authorization
  author: "human"
  scope: "{resolved_scope}"
  text: "{authorization_text}"
  timestamp: "{utc_timestamp}"
```

If `comments.yaml` does not exist, create it with the initial authorization record as the sole entry.

### 6. Update `issue.yaml` Labels

Update `.issues/{N}/issue.yaml` to add the `approved-for-{scope}` label to the labels array:

```yaml
labels:
  - "approved-for-{scope}"
```

Preserve all existing labels. Do NOT remove prior scope labels — that is the `apply-label` task's responsibility.

### 7. Commit Worktree

Commit all three changes in the `.issues/` worktree:

```bash
git -C .issues add {N}/spec.md {N}/comments.yaml {N}/issue.yaml
git -C .issues commit -m "Record authorization: {scope} for issue #{N}"
```

If the commit fails (merge conflict, hook rejection, dirty index), return BLOCKED with `reason: COMMIT_FAILED` and include the git error output. The authorization data has been written to disk but is not yet committed — do NOT report success without a successful commit.

### 8. Handle Concurrent Authorization

If the commit fails due to a concurrent modification (the worktree state changed between write and commit):

1. Re-read the current state of all three files
2. Verify the existing authorization record is compatible (same scope or higher)
3. If compatible (same scope): skip and report success — authorization already recorded
4. If higher scope: overwrite with the new scope and retry the commit
5. If conflicting scope: return BLOCKED with `reason: CONCURRENT_AUTHORIZATION_CONFLICT`

### 9. Verify Commit Success

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
| Malformed `spec.md` frontmatter | BLOCKED with `MALFORMED_FRONTMATTER` |
| Missing `comments.yaml` | Create file with initial authorization record |
| Commit failure | BLOCKED with `COMMIT_FAILED` + git error output |
| Concurrent authorization (same scope) | Skip, report success |
| Concurrent authorization (higher scope) | Overwrite and retry commit |
| Concurrent authorization (conflicting scope) | BLOCKED with `CONCURRENT_AUTHORIZATION_CONFLICT` |

## Cross-References

- `verify-authorization/scope-auto-resolve.md` — Predecessor: resolves scope before this task runs
- `verify-authorization/verify-recording.md` — Successor: reads back recorded state and confirms
- `apply-label.md` — Runs after verify-recording to apply GitHub label
- `completion.md` — Post-authorization cleanup and reporting
