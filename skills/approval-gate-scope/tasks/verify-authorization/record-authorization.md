<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: record-authorization

## Purpose

Write session authorization into persistent issue state (`.issues/{N}/` worktree) before any verification step reads it. Updates three files: `spec.md` frontmatter, `comments.yaml`, and `issue.yaml` labels. Commits the worktree changes after writing.

## Entry Criteria

- Scope resolved (from scope-auto-resolve step)
- Issue number known
- `.issues/` worktree initialized (check with `git -C .issues/ rev-parse --git-dir`)

## Exit Criteria

- `spec.md` frontmatter updated with `status: approved` (when scope is `for_implementation` or higher)
- `comments.yaml` appended with authorization record (text, scope, timestamp, human attribution)
- `issue.yaml` labels updated with `approved-for-{scope}`
- `.issues/` worktree committed with clean working tree

## Procedure

1. **Check worktree existence** — Run `git -C .issues/ rev-parse --git-dir`. If it fails, return BLOCKED with `reason: ISSUES_WORKTREE_NOT_INITIALIZED`.

2. **Read current state** — Read `spec.md` frontmatter, `comments.yaml`, and `issue.yaml` from the `.issues/` worktree.

3. **Update `spec.md` frontmatter** — If the resolved scope is `for_implementation` or higher, add or update `status: approved` in the YAML frontmatter. If frontmatter is malformed (missing YAML delimiters, invalid YAML, missing `status` field), return BLOCKED with `reason: MALFORMED_FRONTMATTER`.

4. **Append to `comments.yaml`** — Append a new authorization record entry with:
   - `author: "human"` (attribution to the developer who authorized)
   - `scope: "{resolved_scope}"` (e.g., `for_implementation`)
   - `text: "{authorization_text}"` (the exact authorization phrase from chat)
   - `timestamp: "{ISO-8601-timestamp}"` (current UTC timestamp)
   - If `comments.yaml` does not exist, create it with the initial authorization record.

5. **Update `issue.yaml` labels** — Add `approved-for-{scope}` to the labels array. Remove prior `approved-for-*` labels. If `issue.yaml` does not exist, create it.

6. **Commit worktree changes** — Run `git -C .issues/ add -A && git -C .issues/ commit -m "record authorization for #{issue_number}: {scope}"`. If commit fails (merge conflict, hook rejection, dirty index), return BLOCKED with `reason: COMMIT_FAILED` and include the git error output.

7. **Handle concurrent authorization** — If commit fails because the worktree state changed between write and commit:
   - Re-read current state
   - Verify existing authorization record is compatible (same scope or higher)
   - If compatible: skip and return DONE
   - If higher scope: overwrite and retry commit
   - If conflicting scope: return BLOCKED with `reason: CONCURRENT_AUTHORIZATION_CONFLICT`

8. **Return result contract** — Return DONE with summary of what was written.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<summary of what was written>"
artifact_path: ".issues/{N}/"
blocker_reason: "<reason if BLOCKED>"
```
