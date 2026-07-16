# Plan: Submodule Hook Installation in session-enforcement.ts

## Phase 1: Extend `ensureHooksInstalled` to iterate over submodules

**Goal:** After installing hooks in the parent repo, iterate over `git submodule status` entries and install the same hooks into each submodule's `.git/hooks/`.

### SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Every registered submodule has non-sample hooks in `.git/hooks/` after session-enforcement runs | 1 | 1.1, 1.2, 1.3 |
| SC-2 | Submodule pre-push hook blocks direct pushes to default branch | 1 | 1.1, 1.2, 1.3 |
| SC-3 | Submodule pre-push hook blocks submodule-pointer-only pushes | 1 | 1.1, 1.2, 1.3 |
| SC-4 | Uninitialized submodules are skipped without error | 1 | 1.2 |
| SC-5 | Hook installation is idempotent (re-running does not duplicate hooks) | 1 | 1.3 |

### Steps

#### Step 1.1: Add `getSubmodulePaths()` helper function

- **File:** `plugins/session-enforcement.ts`
- **Action:** Create a new function `getSubmodulePaths(projectDir: string): string[]` that:
  - Runs `git submodule status` in `projectDir`
  - Parses each line to extract the submodule path (second whitespace-delimited field)
  - Skips lines starting with `-` (uninitialized submodules) — returns empty array for those
  - Returns array of submodule paths (relative to `projectDir`)
- **Edge cases:** No submodules → returns `[]`; `git submodule status` fails → returns `[]`; uninitialized submodules (prefixed with `-`) → skipped
- **Verification:** `getSubmodulePaths()` returns correct paths for initialized submodules, empty array for no submodules, skips uninitialized

#### Step 1.2: Extend `ensureHooksInstalled()` to iterate submodules

- **File:** `plugins/session-enforcement.ts`
- **Action:** After the parent repo hook installation loop (line 363), add:
  1. Call `getSubmodulePaths(projectDir)` to get submodule paths
  2. For each submodule path, resolve its `.git` directory:
     - If `<submodule>/.git` is a file (worktree-style), read its content to find the actual git dir
     - If `<submodule>/.git` is a directory, use it directly
  3. Call the same hook-copying logic (source dir → target dir) for each submodule's git hooks dir
  4. Skip submodules whose `.git` directory cannot be resolved (log a diagnostic warning)
- **Edge cases:** Submodule not checked out → skip; submodule uses `.git` file (superproject worktree) → resolve correctly; submodule has no `.opencode/hooks/` in its source → use parent's `.opencode/hooks/` as source
- **Verification:** Hooks appear in `<submodule>/.git/hooks/` after `ensureHooksInstalled()` runs

#### Step 1.3: Ensure idempotency

- **File:** `plugins/session-enforcement.ts`
- **Action:** The existing content-comparison logic (lines 352-356) already handles idempotency — it only copies when source and target differ. No additional changes needed for idempotency.
- **Verification:** Running `ensureHooksInstalled()` twice produces identical hook files

### Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (hook installation is additive — copies files, never deletes)
- Rollback plan: N/A — no destructive operations
- Data loss risk: none

### Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `plugins/session-enforcement.ts` `ensureHooksInstalled()` | ✅ | `read` — function exists at line 314 |
| 1.1 | `git submodule status` output format | ✅ | `man git-submodule` — format: `[ -+ ]<sha1> <path> <ref>` |
| 1.2 | `plugins/session-enforcement.ts` `resolveGitDir()` | ✅ | `read` — function exists at line 298 |
| 1.2 | `plugins/session-enforcement.ts` hook-copying loop (lines 340-363) | ✅ | `read` — loop copies files with content comparison |
| 1.2 | `.opencode/hooks/` source directory | ✅ | `ls` — contains 5 hook files (post-commit, pre-commit, pre-merge-commit, prepare-commit-msg, pre-push) |

### Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `ensureHooksInstalled()` exists at line 314 | `read` of `session-enforcement.ts` | ✅ |
| `resolveGitDir()` exists at line 298 | `read` of `session-enforcement.ts` | ✅ |
| Hook-copying loop at lines 340-363 | `read` of `session-enforcement.ts` | ✅ |
| `.opencode/hooks/` has 5 hook files | `ls .opencode/hooks/` | ✅ |
| `git submodule status` format: `[ -+ ]<sha1> <path> <ref>` | `man git-submodule` | ✅ |
| Parent repo has `.opencode` submodule | `.gitmodules` | ✅ |
