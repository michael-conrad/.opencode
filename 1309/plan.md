# Plan: Migrate local-issues from Slug-Based to Flat {N} Directories

**Issue:** #1309
**Spec:** `.opencode/.issues/1309/spec.md`
**Authorized Scope:** `for_implementation` (approved-for-plan label)
**Branch:** `feature/1309-flat-local-issues`

## Overview

Two-phase plan. Phase 1 changes the `local-issues` tool's detection and listing logic to use strict `{N}` directories with legacy-slug warnings. Phase 2 updates all 7 skill task files that reference the old slug-based directory patterns.

---

## Phase 1 — Tool Detection + Strict Lookup (SC-1 to SC-7)

Branch: `feature/1309-flat-local-issues`

All implementation in `.opencode/tools/local-issues`.

### 1. Rewrite `_find_issue_dir()` — strict `{N}` match with legacy warning (**clean-room**) (SC-1, SC-2)

- **SC-1:** Change `_find_issue_dir(dir_path, issue_number)` to search only for `{N}` directories (exact number match, no slug suffix). On the first call that encounters a `{N}-{slug}` directory with the same number, emit a stderr warning: `"WARNING: legacy slug-format directory '...' found — move contents to '{N}/' and delete it"`. Same warning for `0{N}` zero-padded directories (SC-2).
- **SC-2:** Also emit warning for `0{N}*` patterns (zero-padded legacy format).

**Entry criteria:** `_find_issue_dir()` signature known; `test_find_issue_dir.sh` exists
**Exit criteria:** `_find_issue_dir(issues, 42)` matches only `42/`, warns on `42-foo-bar/` and `042-foo-bar/`
**Evidence type:** `behavioral`

### 2. Update `cmd_list()` — strict `{N}` filter (**clean-room**) (SC-3, SC-7)

- **SC-3:** Filter listed directories to only those matching exact `^{N}$` pattern. Any directory with a slug suffix (or zero-padded) is excluded from results. The legacy-format warning is NOT emitted by `cmd_list()` — only by commands that access a specific issue number via `_find_issue_dir()`.
- **SC-7:** Merge `open/` and `closed/` subdirectory scanning into the single flat scan. Remove calls to `cmd_open_list()` and `cmd_closed_list()`.

**Entry criteria:** `cmd_list()` calls `_find_issue_dir()`-adjacent scanning
**Exit criteria:** `cmd_list()` returns only flat `{N}` dirs, no open/closed subdir results
**Evidence type:** `behavioral`

### 3. Update `cmd_get()` — strict `{N}` lookup (**clean-room**) (SC-4)

- **SC-4:** Use `_find_issue_dir()` with strict `{N}` match. `cmd_get(N)` must fail if only a `{N}-{slug}` directory exists (and emit the warning). It must succeed only if an exact `{N}/` directory exists.

**Entry criteria:** `cmd_get()` calls `_find_issue_dir()`
**Exit criteria:** `cmd_get(42)` succeeds on `42/`, warns on `42-foo/`
**Evidence type:** `behavioral`

### 4. Remove `cmd_open_list()` / `cmd_closed_list()` and their call sites (**inline**) (SC-6)

- **SC-6:** `cmd_open_list()` and `cmd_closed_list()` deleted. All call sites (CLI dispatch table, help text) updated to use `cmd_list()` only. `cmd_list()` now serves as the single list entry point.

**Entry criteria:** `cmd_open_list` and `cmd_closed_list` exist
**Exit criteria:** Both functions removed; all dispatch routing points to `cmd_list`
**Evidence type:** `structural`

### 5. Align import-remote slug algorithm with `_slug()` (**clean-room**) (SC-5)

- **SC-5:** The import-remote code at the bottom of the local-issues tool uses its own inline slug algorithm ("first 5 words, kebab-cased") that diverges from the tool's `_slug()` function. Replace the inline algorithm with a call to `_slug()`. Remove the dead `_normalize()` function if no longer used.

**Entry criteria:** import-remote section has inline slug logic
**Exit criteria:** import-remote calls `_slug()` instead of inline slug; `_normalize()` removed if orphaned
**Evidence type:** `structural`

---

## Phase 2 — Skill Task File Remediation (SC-8 to SC-14)

All changes happen after Phase 1 code changes are verified. Each task file is updated to reference `{N}` flat directory paths instead of slug-based paths. No behavioral-logic changes — only path-string and documentation updates.

### 6. Update `platforms/local/SKILL.md` (**clean-room**) (SC-8)

- Replace architecture diagram that shows `001-slug/` format with `{N}/` flat format. Update any `open/`/`closed/` subdirectory references.

**File:** `.opencode/skills/issue-operations/platforms/local/SKILL.md`
**Evidence type:** `string`

### 7. Update `platforms/local/tasks/close.md` (**clean-room**) (SC-9)

- Replace `.issues/open/<N>/`, `.issues/open/NNN-slug/`, `.issues/closed/NNN-slug/` → `.issues/{N}/`. Update entry criteria and all path references.

**File:** `.opencode/skills/issue-operations/platforms/local/tasks/close.md`
**Evidence type:** `string`

### 8. Update `platforms/local/tasks/delete.md` (**clean-room**) (SC-10)

- Replace `.issues/open/NNN-slug/`, `.issues/closed/NNN-slug/` → `.issues/{N}/`. Update entry criteria and all path references.

**File:** `.opencode/skills/issue-operations/platforms/local/tasks/delete.md`
**Evidence type:** `string`

### 9. Update `tasks/import-remote.md` (**clean-room**) (SC-11)

- Replace `.issues/open/<remote_number:03d>-<slug>/`, `.issues/open/<remote_number>-<slug>/`, `NNN-slug` → `.issues/{N}/`. Update exit criteria and verification section.

**File:** `.opencode/skills/issue-operations/tasks/import-remote.md`
**Evidence type:** `string`

### 10. Update `tasks/creation.md` (**clean-room**) (SC-12)

- Replace `.issues/open/<remote-number>-<slug>/`, `.issues/open/NNN-slug/spec.md`, all slug references → `.issues/{N}/`. Update creation path and verification section.

**File:** `.opencode/skills/issue-operations/tasks/creation.md`
**Evidence type:** `string`

### 11. Update `tasks/body-edit.md` (**clean-room**) (SC-13)

- Replace `.issues/open/N-slug/remote.md` → `.issues/N/remote.md`. Other references already use `{N}` format.

**File:** `.opencode/skills/issue-operations/tasks/body-edit.md`
**Evidence type:** `string`

### 12. Update `tasks/sync-pull-to-local.md` (**clean-room**) (SC-14)

- Replace `.issues/open/<number>-<slug>/remote.md` and `NNN-slug` patterns → `.issues/{N}/`. Update verification section.

**File:** `.opencode/skills/issue-operations/tasks/sync-pull-to-local.md`
**Evidence type:** `string`

---

## Evidence Summary

| SC | Description | Type | Phase |
|----|-------------|------|-------|
| SC-1 | `_find_issue_dir()` warns on legacy `{N}-{slug}` | behavioral | 1 |
| SC-2 | `_find_issue_dir()` warns on zero-padded `0{N}` | behavioral | 1 |
| SC-3 | `local-issues list` strict `{N}` filter, no open/closed subdirs | behavioral | 1 |
| SC-4 | `local-issues get` strict `{N}` lookup | behavioral | 1 |
| SC-5 | import-remote uses `_slug()` not inline slug algo | structural | 1 |
| SC-6 | `cmd_open_list()` / `cmd_closed_list()` removed | structural | 1 |
| SC-7 | `cmd_list()` returns combined open + closed results | behavioral | 1 |
| SC-8 | `platforms/local/SKILL.md` diagram updated | string | 2 |
| SC-9 | `close.md` path references updated | string | 2 |
| SC-10 | `delete.md` path references updated | string | 2 |
| SC-11 | `import-remote.md` path references updated | string | 2 |
| SC-12 | `creation.md` path references updated | string | 2 |
| SC-13 | `body-edit.md` path references updated | string | 2 |
| SC-14 | `sync-pull-to-local.md` path references updated | string | 2 |
