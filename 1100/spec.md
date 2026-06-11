# Bug: local-issues delete cannot find issues with zero-padded 3-digit directory names

## Summary
`local-issues delete --number hermes#1` fails with "Issue #1 not found" because the `_find_issue_dir_in_repo` function cannot match a zero-padded 3-digit directory name like `001-init` against the unpadded search number `1`.

## Root Cause
`get_issue_path()` at line 127 uses `f"{number:03d}"` to create directories like `001-init`, but `_find_issue_dir()` and `_find_issue_dir_in_repo()` search with `str(number)` = `"1"`, and `"001-init".startswith("1-")` returns `False`.

## Success Criteria
| ID | Criterion |
|----|-----------|
| SC-1 | `delete --number N` succeeds when the issue directory uses zero-padded naming (e.g. `001-init`), resolving the unpadded query `1` to the directory `001-init` |
| SC-2 | New issues created via `create --number N` produce unpadded directory names (e.g. `1-init`, not `001-init`) |
| SC-3 | Backward compatibility — existing zero-padded directories (`001-init`) are still found by bare number `1` |
| SC-4 | `read --number N` works for both padded and unpadded directories |
| SC-5 | All mutation commands — delete, close, update, promote — find zero-padded dirs by bare number |

## Implementation
- `get_issue_path()`: remove `:03d` zero-padding
- `_find_issue_dir()`: add zero-padded prefix fallback for backward compat
- `_find_issue_dir_in_repo()`: same fallback