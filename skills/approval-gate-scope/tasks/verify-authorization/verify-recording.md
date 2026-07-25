<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Task: verify-recording

## Purpose

Read back the recorded authorization state from persistent issue state and confirm it matches what was written. Checks three files: `spec.md` frontmatter for `status: approved`, `comments.yaml` for the authorization record, and `issue.yaml` for the label. Returns BLOCKED if any of the three checks fail.

## Entry Criteria

- Authorization recorded (from record-authorization step)
- Issue number known
- `.issues/` worktree initialized

## Exit Criteria

- `spec.md` frontmatter confirmed to have `status: approved`
- `comments.yaml` confirmed to have the authorization record
- `issue.yaml` confirmed to have the `approved-for-{scope}` label
- Result contract returned

## Procedure

1. **Check worktree existence** — Run `git -C .issues/ rev-parse --git-dir`. If it fails, return BLOCKED with `reason: ISSUES_WORKTREE_NOT_INITIALIZED`.

2. **Read `spec.md` frontmatter** — Read the YAML frontmatter from `spec.md` in the `.issues/` worktree. Check for `status: approved`. If frontmatter is malformed (missing YAML delimiters, invalid YAML), return BLOCKED with `reason: MALFORMED_FRONTMATTER`. If `status: approved` is missing, return BLOCKED with `reason: AUTHORIZATION_NOT_RECORDED` and detail that `spec.md` frontmatter is missing `status: approved`.

3. **Read `comments.yaml`** — Read `comments.yaml` from the `.issues/` worktree. Check for an authorization record entry with matching scope and a recent timestamp. If `comments.yaml` does not exist, return BLOCKED with `reason: AUTHORIZATION_NOT_RECORDED` and detail that `comments.yaml` is missing. If no matching authorization record is found, return BLOCKED with `reason: AUTHORIZATION_NOT_RECORDED` and detail that no authorization record exists in `comments.yaml`.

4. **Read `issue.yaml` labels** — Read `issue.yaml` from the `.issues/` worktree. Check for `approved-for-{scope}` in the labels array. If the label is missing, return BLOCKED with `reason: AUTHORIZATION_NOT_RECORDED` and detail that `issue.yaml` is missing the `approved-for-{scope}` label.

5. **Return result contract** — If all three checks pass, return DONE. If any check fails, return BLOCKED with the specific reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<summary of verification results>"
artifact_path: ".issues/{N}/"
blocker_reason: "<reason if BLOCKED>"
```
