# Task: verify-authorization — Step 2: Verify Recording

## Purpose

Read back the recorded authorization state from persistent issue state (`spec.md` frontmatter, `comments.yaml`, `issue.yaml`) and confirm it matches what was written by the `record-authorization` task. Returns PASS if all three files match expectations. Returns BLOCKED with a specific reason if any file is missing, malformed, or contains unexpected values.

## Entry Criteria

- Scope resolved (from Step 0.5: `scope-auto-resolve`)
- `record-authorization` task completed (Step 1)
- Issue number known
- `.issues/` worktree exists

## Exit Criteria

- All three state files verified: `spec.md` frontmatter has `status: approved`, `comments.yaml` has the authorization record, `issue.yaml` has the label
- BLOCKED returned if any check fails with a specific reason
- Result contract returned

## Procedure

### 1. Verify `.issues/` Worktree Exists

Check that the `.issues/` worktree is initialized:

```bash
git -C .issues rev-parse --git-dir
```

If the command fails (worktree not initialized), return BLOCKED with `reason: ISSUES_WORKTREE_NOT_INITIALIZED`.

### 2. Verify `spec.md` Frontmatter

1. Read `spec.md` from `.issues/{issue-N}/spec.md`:

```bash
cat .issues/{issue-N}/spec.md
```

2. Parse YAML frontmatter (content between `---` delimiters at the start of the file).

3. If the file does not exist, return BLOCKED with `reason: SPEC_MD_NOT_FOUND`.

4. If frontmatter is malformed (missing YAML delimiters, invalid YAML, missing `status` field), return BLOCKED with `reason: MALFORMED_FRONTMATTER`.

5. Verify the `status` field is `approved`:

```bash
# Extract status from frontmatter
sed -n '/^---$/,/^---$/p' .issues/{issue-N}/spec.md | grep '^status:' | awk '{print $2}'
```

6. If `status` is not `approved`, return BLOCKED with `reason: STATUS_NOT_APPROVED`.

### 3. Verify `comments.yaml` Authorization Record

1. Read `comments.yaml` from `.issues/{issue-N}/comments.yaml`:

```bash
cat .issues/{issue-N}/comments.yaml
```

2. If the file does not exist, return BLOCKED with `reason: MISSING_COMMENTS_YAML`.

3. If the file exists but is empty (zero bytes), return BLOCKED with `reason: MISSING_COMMENTS_YAML`.

4. Parse the YAML content. It MUST be a valid YAML list with at least one entry of `type: authorization`.

5. Verify the file contains an authorization record with:
   - `author: "human"`
   - `scope` matching the resolved scope
   - A non-empty `timestamp` field

6. If the YAML is invalid (parse error, not a list), return BLOCKED with `reason: MALFORMED_COMMENTS_YAML`.

7. If no authorization record is found (no entry with `type: authorization`), return BLOCKED with `reason: MISSING_AUTHORIZATION_RECORD`.

8. If the authorization record exists but is missing required fields (`author`, `scope`, `timestamp`), return BLOCKED with `reason: INCOMPLETE_AUTHORIZATION_RECORD`.

### 4. Verify `issue.yaml` Label

1. Read `issue.yaml` from `.issues/{issue-N}/issue.yaml`:

```bash
cat .issues/{issue-N}/issue.yaml
```

2. If the file does not exist, return BLOCKED with `reason: MISSING_ISSUE_YAML`.

3. If the file exists but is empty (zero bytes), return BLOCKED with `reason: MISSING_ISSUE_YAML`.

4. Parse the YAML content. It MUST be a valid YAML mapping with a `labels` key.

5. If the YAML is invalid (parse error, not a mapping), return BLOCKED with `reason: MALFORMED_ISSUE_YAML`.

6. Verify the `labels` array contains `approved-for-{scope}` matching the resolved scope (e.g., `approved-for-implementation` for `for_implementation` scope).

7. If the `labels` key is missing, return BLOCKED with `reason: MISSING_LABELS_KEY`.

8. If the label is missing from the `labels` array, return BLOCKED with `reason: MISSING_APPROVED_LABEL`.

### 5. Return Result Contract

If all three checks pass, return DONE. If any check fails, return BLOCKED with the specific reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<summary of verification results>"
artifact_path: ".issues/{N}/"
blocker_reason: "<reason if BLOCKED>"
```

## Edge Cases

| Condition | Action |
|-----------|--------|
| `.issues/` worktree not initialized | BLOCKED with `ISSUES_WORKTREE_NOT_INITIALIZED` |
| Missing `spec.md` | BLOCKED with `SPEC_MD_NOT_FOUND` |
| Malformed `spec.md` frontmatter (missing YAML delimiters, invalid YAML, missing `status` field) | BLOCKED with `MALFORMED_FRONTMATTER` |
| `status` field is not `approved` | BLOCKED with `STATUS_NOT_APPROVED` |
| Missing `comments.yaml` | BLOCKED with `MISSING_COMMENTS_YAML` |
| Empty `comments.yaml` (zero bytes) | BLOCKED with `MISSING_COMMENTS_YAML` |
| Malformed `comments.yaml` (invalid YAML, not a list) | BLOCKED with `MALFORMED_COMMENTS_YAML` |
| No authorization record in `comments.yaml` | BLOCKED with `MISSING_AUTHORIZATION_RECORD` |
| Authorization record missing required fields | BLOCKED with `INCOMPLETE_AUTHORIZATION_RECORD` |
| Missing `issue.yaml` | BLOCKED with `MISSING_ISSUE_YAML` |
| Empty `issue.yaml` (zero bytes) | BLOCKED with `MISSING_ISSUE_YAML` |
| Malformed `issue.yaml` (invalid YAML, not a mapping) | BLOCKED with `MALFORMED_ISSUE_YAML` |
| `labels` key missing from `issue.yaml` | BLOCKED with `MISSING_LABELS_KEY` |
| `approved-for-{scope}` label not in `labels` array | BLOCKED with `MISSING_APPROVED_LABEL` |

## Cross-References

- `verify-authorization/scope-auto-resolve.md` — Predecessor: resolves scope before this task runs
- `record-authorization.md` — Predecessor: writes authorization state before this task reads it
- `apply-label.md` — Successor: applies GitHub label after verification passes
- `completion.md` — Post-authorization cleanup and reporting
