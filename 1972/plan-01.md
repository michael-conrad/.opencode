# Phase 1: Fix git path resolution and command execution in both plugins

## Steps

### 1.1 Fix `session-enforcement.ts` — POSIX compliance + lazy init

**SC:** SC-1, SC-5

**Changes:**
1. Replace `execSync("which git", ...)` with `execSync("command -v git", ...)` on line 43
2. Move `resolveGitPath()` call from module scope (line 61) to lazy initialization:
   - Remove `const gitPath = resolveGitPath();` at line 61
   - Add a cached getter: `let _gitPath: string | null | undefined;` at module level
   - Add `function getGitPath(): string | null { if (_gitPath === undefined) _gitPath = resolveGitPath(); return _gitPath; }`
   - Replace all references to `gitPath` with `getGitPath()` throughout the file

**Verification:** `grep -n "which git" plugins/session-enforcement.ts` returns no matches; `grep -n "const gitPath = resolveGitPath" plugins/session-enforcement.ts` returns no matches

### 1.2 Fix `env-loader.ts` — POSIX compliance + lazy init

**SC:** SC-1, SC-5

**Changes:**
1. Replace `execSync("which git", ...)` with `execSync("command -v git", ...)` on line 38
2. Move `resolveGitPath()` call from inside `shell.env` hook (line 290) to lazy initialization:
   - Add `let _gitPath: string | null | undefined;` at module level
   - Add `function getGitPath(): string | null { if (_gitPath === undefined) _gitPath = resolveGitPath(); return _gitPath; }`
   - Replace `const gitPath = resolveGitPath();` on line 290 with `const gitPath = getGitPath();`

**Verification:** `grep -n "which git" plugins/env-loader.ts` returns no matches

### 1.3 Fix `env-loader.ts` — inline git command calls

**SC:** SC-2, SC-3

**Changes:**
1. Remove the `gitCmd()` function (lines 292-308)
2. Replace each call site with direct `$.nothrow()` calls using separate template expressions:
   - Line 311: `const branchResult = await gitCmd("branch --show-current");` → `const branchResult = await $.nothrow()`\`${gitPath} branch --show-current\`;`
   - Line 319: `const remoteResult = await gitCmd("remote get-url origin");` → `const remoteResult = await $.nothrow()`\`${gitPath} remote get-url origin\`;`
   - Line 350: `const nameResult = await gitCmd("config user.name");` → `const nameResult = await $.nothrow()`\`${gitPath} config user.name\`;`
   - Line 358: `const emailResult = await gitCmd("config user.email");` → `const emailResult = await $.nothrow()`\`${gitPath} config user.email\`;`
3. Wrap each call in `Promise.race([... , timeoutPromise])` to preserve the timeout behavior
4. Extract the timeout promise to a shared helper to avoid repetition

**Verification:** `grep -n '\$\{gitPath\} \$\{cmd\}' plugins/env-loader.ts` returns no matches; `grep -n 'gitCmd' plugins/env-loader.ts` returns no matches

### 1.4 Verify TypeScript compilation

**SC:** SC-4

**Changes:**
1. Run `tsc --noEmit` to verify both plugins compile without errors

**Verification:** `tsc --noEmit` exits with code 0

### 1.5 Commit

**SC:** SC-4

**Changes:**
1. `git add plugins/session-enforcement.ts plugins/env-loader.ts`
2. `git commit -m "fix(plugins): replace which with command -v, fix git arg splitting, lazy init"`

## Phase Exit Criteria

| SC ID | Evidence Type | Verification Method |
|-------|---------------|---------------------|
| SC-1 | `string` | `grep -r "which git" plugins/` returns no matches |
| SC-2 | `string` | `grep -r '\$\{gitPath\} \$\{cmd\}' plugins/` returns no matches |
| SC-3 | `string` | All 4 call sites use `${gitPath} <subcommand>` pattern |
| SC-4 | `behavioral` | `tsc --noEmit` passes; plugin loads without errors |
| SC-5 | `string` | `grep -n 'const gitPath = resolveGitPath()' plugins/` returns no matches |
