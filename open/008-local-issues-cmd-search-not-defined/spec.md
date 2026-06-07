---
number: 8
title: "[BUG] local-issues list/search crashes: cmd_search not defined"
status: open
labels: [bug, needs-approval]
created: "2026-05-10T00:00:00Z"
updated: "2026-05-10T00:00:00Z"
github_issue: 493
author: michael-conrad
---

## Objective

Fix `local-issues` tool crash when running `list` or `search` commands — both call `cmd_search` which is never defined.

## Reproduction

```
$ .opencode/tools/local-issues list
Traceback (most recent call last):
  File ".opencode/tools/local-issues", line 769, in <module>
    sys.exit(main())
  File ".opencode/tools/local-issues", line 698, in main
    return cmd_list(status)
  File ".opencode/tools/local-idsues", line 532, in cmd_list
    return cmd_search(status=status)
NameError: name 'cmd_search' is not defined
```

## Root Cause

Two call sites reference a `cmd_search` function that does not exist:

1. **Line 532**: `cmd_list()` delegates to `cmd_search(status=status)`
2. **Line 687**: The `search` command handler calls `cmd_search(status, labels, query)`

No `def cmd_search(...)` appears anywhere in the file. The function was apparently planned but never implemented.

## Expected Behavior

- `local-issues list [--status STATUS]` — list all issues, optionally filtered by status
- `local-issues search [--status STATUS] [--labels LABELS] [--query QUERY]` — search issues with filters

## Fix Approach

Implement `cmd_search(status, labels, query)` that:

1. Scans `.issues/open/` and `.issues/closed/` for issue directories
2. Reads each `spec.md` frontmatter
3. Filters by `status` (if provided), `labels` (if provided), and `query` (substring match on title/body if provided)
4. Prints results in tabular format (number, status, title, labels)
5. `cmd_list` delegates to `cmd_search(status=status)` as currently designed

## Success Criteria

| ID | Criterion | Verification |
|---|---|---|
| SC-1 | `local-issues list` runs without error | Run command, no traceback |
| SC-2 | `local-issues list --status open` filters correctly | Create open + closed issues, verify only open shown |
| SC-3 | `local-issues search --labels bug` filters by label | Verify label filtering |
| SC-4 | `local-issues search --query "search term"` matches body | Verify text search |
| SC-5 | `cmd_search` signature: `(status: str \| None = None, labels: list[str] \| None = None, query: str \| None = None) -> int` | Code review |

## Risk Table

| Risk | Impact | Mitigation |
|---|---|---|
| Breaking existing callers of `cmd_list` | Low | `cmd_list` signature unchanged; new function is additive |
| Search performance on many issues | Low | Issues are local files, count is small |