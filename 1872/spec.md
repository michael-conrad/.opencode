# [SPEC] session-init: rename Local Issue Artifacts to Local Issue Folders, emit git -C commands, reorder sections

STATUS: 0.1 — Draft

## Problem Statement

The `session-init` tool's `## Local Issue Artifacts` section emits structured YAML-like fields (`path:`, `issues:`) that are verbose, redundant, and fail to make the worktree nature of `.issues/` directories explicit.

**Current output:**
```
## Local Issue Artifacts
- path: .
  issues: .issues/
- path: .opencode
  issues: .opencode/.issues/
```

**Problems:**
1. **Verbose:** Two lines per entry for what is fundamentally a path-to-directory mapping
2. **Redundant `path` field:** The `path` prefix is already derivable by cross-referencing the `## Repo Information` block — duplicating it wastes context budget
3. **Worktree nature not explicit:** `.issues/` directories are git worktrees (orphan branch worktrees), not regular directories. The current format gives no indication that `git -C` commands are the correct way to interact with them
4. **Section ordering is suboptimal:** `## CLI Auth Status` (auth health, quick to scan) should come first, followed by `## Local Issue Folders` (where issues live), then `## Repo Information` (routing metadata) — this ordering matches the agent's operational priority: "can I authenticate → where are my local issues → how do I route API calls"

## Changes

### Change 1: Rename section header

`## Local Issue Artifacts` → `## Local Issue Folders`

### Change 2: Change output format

From structured YAML-like fields:
```
## Local Issue Artifacts
- path: .
  issues: .issues/
- path: .opencode
  issues: .opencode/.issues/
```

To inline `git -C` commands:
```
## Local Issue Folders
- .issues/: git -C .issues/
- .opencode/.issues/: git -C .opencode/.issues/
```

Each entry is a single line: `- <path>: git -C <path>`. The `git -C` prefix makes the worktree nature explicit — agents see immediately that these are git worktrees, not regular directories.

### Change 3: Reorder sections in `main()`

Current order:
1. `## Repo Information`
2. `## CLI Auth Status`
3. `## Local Issue Artifacts`

Proposed order:
1. `## CLI Auth Status` (first — auth health, quick to scan)
2. `## Local Issue Folders` (second — where issues live)
3. `## Repo Information` (third — routing metadata)

### Change 4: Remove `path` field

The `path` prefix in each entry is derivable by cross-referencing the `## Repo Information` block's `path` field. Removing it eliminates redundancy and reduces context consumption.

## Affected File

- `.opencode/tools/session-init`

## Affected Functions

- `collect_issue_artifact_paths()` — change return format to omit `path` field, emit `git -C` command strings
- `main()` — change emission code to use new format
- `main()` — reorder section emission

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Section header is `## Local Issue Folders` (not `## Local Issue Artifacts`) | `string` |
| SC-2 | Output format uses inline `git -C` commands: `- <path>: git -C <path>` | `string` |
| SC-3 | No `path:` field in `## Local Issue Folders` output | `string` |
| SC-4 | Section emission order in `main()` is: CLI Auth Status first, Local Issue Folders second, Repo Information third | `string` |
