# Phase 1: `env-loader.ts` plugin fix

**Spec:** #1832
**SCs:** SC-1, SC-13, SC-14, SC-15, SC-16, SC-17
**Dependency:** None (first phase)

## Goal

Fix `env-loader.ts` to load without "Plugin export is not a function" error. Fix pre-existing TypeScript errors in `session-enforcement.ts`. Create plugin development documentation.

## Steps

### Step 1 — RED: Write behavioral enforcement test for SC-1

**Dispatch:** `sub-agent` via `task()`
**Chain:** `none`

Create `.opencode/tests/behaviors/1832-sc1-env-loader-load.sh`:
- Run `with-test-home opencode-cli run "test"` 
- Assert stderr does NOT contain "Plugin export is not a function"
- Use `assert_stderr_pattern_absent` from helpers.sh

**Exit criteria:** Test FAILS (env-loader still broken)

### Step 2 — GREEN: Fix `env-loader.ts` export style

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_1`

Changes to `.opencode/plugins/env-loader.ts`:
1. Change `export default async function envLoaderPlugin(input: PluginInput)` → `export const EnvLoaderPlugin: Plugin = async ({ project, client, $, directory, worktree }) => { ... }`
2. Update import: `import type { Hooks, PluginInput }` → `import type { Plugin }`
3. Map context: `input?.directory` → `directory`, `input?.worktree` → `worktree`, `input.$.nothrow` → `$.nothrow`
4. Preserve named exports at bottom: `parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic`

**SC-13 verification:** Grep for `export const EnvLoaderPlugin` (must appear), `export default` (must not appear)
**SC-14 verification:** Grep for `export const|function parseEnvFile|isEnvGitignored|writeDiagnostic`, `const DIAGNOSTICS_PATH`, `interface PluginDiagnostic` — all must appear

### Step 3 — GREEN: Fix TypeScript errors in `session-enforcement.ts`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_2`

Fix pre-existing TypeScript errors:
1. `"session.created"` hook key → `event` hook with `event.type` discrimination
2. `part.synthetic` access → narrow to `part.type === 'text'` first

**SC-15 verification:** `tsc --noEmit --project .opencode/tsconfig.json` exits 0

### Step 4 — GREEN: Create `.opencode/plugins/AGENTS.md`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_3`

Create new file documenting plugin development requirements:
- Named export requirement
- Plugin API signature
- Context mapping
- Testing guidance

**SC-16 verification:** File existence check

### Step 5 — GREEN: Verify `shell.env` hook injects env vars

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_4`

Create `.opencode/tests/behaviors/1832-sc17-shell-env-inject.sh`:
- Run `with-test-home opencode-cli run "echo \$BRANCH_NAME"`
- Assert output is non-empty

**SC-17 verification:** `behavior_run` + `behavioral-test-evaluation` clean-room dispatch

### Step 6 — VbC: Verify all Phase 1 SCs

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_5`

Run `verification-before-completion` for SC-1, SC-13, SC-14, SC-15, SC-16, SC-17.
For behavioral SCs (SC-1, SC-15, SC-17): after `behavior_run` artifact generation, dispatch `behavioral-test-evaluation` clean-room sub-agent before allowing PASS verdict.

### Step 7 — Commit

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_6`

Commit Phase 1 changes with message:
```
Phase 1: Fix env-loader.ts plugin export and TypeScript errors

- Change export default to named export const EnvLoaderPlugin
- Fix session-enforcement.ts TypeScript errors
- Create plugins/AGENTS.md documentation
- Add behavioral enforcement tests for SC-1, SC-17

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
```

## Phase Completion

- [ ] All Phase 1 SCs pass (SC-1, SC-13, SC-14, SC-15, SC-16, SC-17)
- [ ] Behavioral SCs verified via clean-room evaluation
- [ ] Changes committed to `feature/1832-test-env-production-parity`
- [ ] Pipeline state updated to Phase 2

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
