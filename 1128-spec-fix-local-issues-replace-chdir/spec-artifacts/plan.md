# Plan: local-issues chdir Design Fix

**Issue:** #1128 — `[SPEC-FIX] local-issues: replace global-state chdir design with PROJECT_DIR-anchored operations`
**Parent bug:** #1127
**Z3 contract:** `contract.yaml` — validates linear p1→p2→p3→p4→p5→p6→p7 dependency chain
**Z3 solve check:** SAT — all preconditions, postconditions, and invariants satisfied (7 phases, 21 variables, 31 constraints)
**PDDL plan tool:** SOLVED_SATISFICING — 20-step plan generated (see generated plan output in session log)

## Phase Dependency Chain

```
p1 (PROJECT_DIR) → p2 (resolve_repo_name) → p3 (remove chdir) → p4 (ISSUES_DIR) → p5 (bare except) → p6 (worktree errors) → p7 (integration)
```

Each phase is RED → GREEN → MERGED. A phase cannot start RED until the previous phase is MERGED.

## Phase 1: Add PROJECT_DIR computation

- Compute `PROJECT_DIR` at module top using canonical walk-up-to-`.opencode` per `210-scripting.md:28-38`
- No `os.chdir()` anywhere in the file
- All future path operations are absolute from PROJECT_DIR
- SC-5 (`string`): verify walk-up-to-`.opencode` method used

**RED:** No PROJECT_DIR constant exists
**GREEN:** PROJECT_DIR computed at module top via walk-up loop with filesystem-root guard
**MERGED:** SC-5 passes

## Phase 2: Replace `_resolve_repo_name()`

- Replace `.gitmodules` heuristic with `resolved_path.name` after `_resolve_repo_path()` returns the correct path
- No guesswork, no chdir dependency, no `.gitmodules` walking
- Handles all three repo types: root, submodule, independent repo
- SC-3 (`behavioral`): verify correct name for root, submodule, independent repo

**RED:** `_resolve_repo_name()` walks `.gitmodules` (always returns root)
**GREEN:** `_resolve_repo_name()` returns `resolved_path.name`
**MERGED:** SC-3 passes

## Phase 3: Remove `os.chdir()` from `_ensure_repo()`

- Rename to `_resolve_repo_path()` — returns `Path`, never mutates CWD
- All callers updated to use the returned path explicitly instead of relative `ISSUES_DIR`
- SC-2 (`string`): grep confirms zero `os.chdir()` calls remain

**RED:** `_ensure_repo()` calls `os.chdir()`
**GREEN:** `_ensure_repo()` renamed to `_resolve_repo_path()`, returns Path, no chdir
**MERGED:** SC-2 passes

## Phase 4: Replace bare relative `ISSUES_DIR` usage

- Every `Path(ISSUES_DIR)` or bare `".issues"` reference becomes `repo_path / ".issues"`
- All command handlers use the explicit resolved path, not CWD-relative
- `_resolve_qualified()`, `_collect_repos()`, `cmd_search()`, `cmd_list()` all updated
- SC-1 (`behavioral`): `create --number .opencode#1125` labels correctly
- SC-6 (`behavioral`): `list`/`search`/`read` show correct qualifiers
- SC-7 (`behavioral`): `create --number 1125` (bare) still works

**RED:** Relative `ISSUES_DIR` paths depend on CWD
**GREEN:** All paths use `repo_path / ".issues"` — no CWD dependency
**MERGED:** SC-1, SC-6, SC-7 all pass

## Phase 5: Eliminate bare `except Exception: pass`

- Every one of the 8+ silent error paths replaced with explicit diagnostics:
  - `_discover_repos()`: report parse failures to stderr
  - `_ensure_worktree()`: propagate errors with context, return False + stderr diagnostic
  - `_push_orphan_if_needed()`, `_push_issues_branch()`, `_auto_commit()`: report failure to stderr
  - Orphan branch creation subprocess calls: check return codes
- SC-4 (`string`): grep confirms zero bare `except Exception: pass`
- SC-9 (`string`): each error path produces a diagnostic

**RED:** 8+ bare `except Exception: pass` exist
**GREEN:** All replaced with explicit error handling
**MERGED:** SC-4, SC-9 pass

## Phase 6: Update `_ensure_worktree()` and `_auto_commit()` error handling

- All subprocess calls checked for return code
- Worktree creation, migration, prune all verified with diagnostics
- Failures produce stderr diagnostics
- SC-9 (`string`): re-checked for error diagnostics

**RED:** Subprocess calls unchecked, silent failures
**GREEN:** All subprocess calls checked, errors produce diagnostics
**MERGED:** SC-9 passes

## Phase 7: Full integration verification

- All 9 SCs verified at once via behavioral test
- Full create/read/update/close/delete cycle through root and submodule
- `sync` and `init` verified across all repos
- Bug #1127 reproduction case verified: `create --number .opencode#N` produces `.opencode#N`
- SC-8 (`behavioral`): `sync`/`init` across repos

**RED:** Reproduction case still shows wrong qualifier
**GREEN:** All 9 SCs pass
**MERGED:** All SCs verified, issue #1128 resolved