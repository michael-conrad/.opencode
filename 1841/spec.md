## Bug Description

`local-issues list` (and related commands) produce duplicate entries for the root repo because `_discover_all_repos()` includes the root repo in its return list, but callers also explicitly add the root repo separately.

## Root Cause

`_discover_all_repos()` (`.opencode/tools/local-issues`, lines 203–239) correctly returns all repos including root: `[root, child1, child2, ...]`. The function is correct.

The bug is in callers that redundantly add the root repo on top of what the function already returns:

| Function | Lines | Mechanism | Duplication? |
|----------|-------|-----------|-------------|
| `cmd_list` | 1425–1437 | Explicitly lists `current_cwd` issues, then iterates `_discover_all_repos()` which includes `root` | **YES** |
| `cmd_search` | 1359–1374 | Builds `repo_infos` with `(current_cwd, current_repo_name)` first, then appends all entries from `_discover_all_repos()` (which includes `root`) | **YES** |
| `_print_available_repos` | 1381–1391 | Prints `current_name` explicitly, then iterates `_discover_all_repos()` (which includes `root`) | **YES** |
| `_resolve_qualified` (bare N path) | 1026–1053 | Adds `(current, current_name, ...)` to results, then iterates `_discover_all_repos()` (which includes `root`) with a `seen` set keyed by name — but `current_name` is NOT pre-seeded in `seen` | **YES** |

Functions that iterate `_discover_all_repos()` directly (without separately adding root) are NOT affected: `_ensure_all_worktrees`, `_detect_dual_branch`, `_resolve_repo_path`.

## Affected File

`.opencode/tools/local-issues`

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|-------------------|
| SC-1 | `local-issues list` does not produce duplicate entries for the root repo | `behavioral` | Run `local-issues list` in a repo with child repos; verify each issue appears exactly once |
| SC-2 | `local-issues search` does not search the root repo twice | `behavioral` | Run `local-issues search <term>`; verify no duplicate results for root repo issues |
| SC-3 | `_print_available_repos` does not print the root repo twice | `behavioral` | Run `local-issues repos`; verify root repo appears exactly once |
| SC-4 | `_resolve_qualified` with bare issue number does not return duplicate entries for root repo | `behavioral` | Run `local-issues <N>` for a root repo issue; verify single result |
| SC-5 | All unaffected callers (`_ensure_all_worktrees`, `_detect_dual_branch`, `_resolve_repo_path`) continue to work correctly | `behavioral` | Run affected commands; verify no regression |

## Fix

**Do not touch `_discover_all_repos()`.** The function is correct — it returns all repos including root. The fix is purely in the callers that redundantly add root:

| Caller | Fix |
|--------|-----|
| `cmd_list` | Remove the explicit `_list_issues_in_repo(current_cwd, ...)` call — just iterate `_discover_all_repos()` |
| `cmd_search` | Remove the explicit `(current_cwd, current_repo_name)` prepend — just use `_discover_all_repos()` |
| `_print_available_repos` | Remove the explicit `current_name` print — just iterate `_discover_all_repos()` |
| `_resolve_qualified` | Pre-seed `current_name` in the `seen` set before iterating |

No rename, no split, no new function. The function is correct; the callers are wrong.

## Labels

`bug`, `SPEC-FIX`
