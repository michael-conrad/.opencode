# Plan: #1972 — session-enforcement.ts resolveGitPath() fixes

## Phase Table

| Phase | Title | SCs | Steps |
|-------|-------|-----|-------|
| 1 | Fix git path resolution and command execution in both plugins | SC-1, SC-2, SC-3, SC-4, SC-5 | 1.1–1.5 |

## Step Details

| Step | Name | Dispatch |
|------|------|----------|
| 1.1 | Fix session-enforcement.ts — which → command -v, lazy init | (**clean-room**) |
| 1.2 | Fix env-loader.ts — which → command -v, lazy init | (**clean-room**) |
| 1.3 | Inline gitCmd() calls with separate template arguments | (**clean-room**) |
| 1.4 | Verify tsc --noEmit passes | (**clean-room**) |
| 1.5 | Commit | (**inline**) |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | `resolveGitPath()` uses POSIX `command -v git` instead of `which git` in both plugins | 1 | 1.1, 1.2 |
| SC-2 | `env-loader.ts` `gitCmd()` passes each git subcommand and its arguments as separate template expressions | 1 | 1.3 |
| SC-3 | All `$.nothrow()` git calls in `env-loader.ts` use separate arguments | 1 | 1.3 |
| SC-4 | Plugin loads without any git-related errors in normal environments | 1 | 1.4 |
| SC-5 | `resolveGitPath()` is called lazily (not at module scope) | 1 | 1.1, 1.2 |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None — only internal implementation changes to git path resolution and command execution
- Rollback plan: `git checkout -- plugins/session-enforcement.ts plugins/env-loader.ts`
- Data loss risk: none

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `plugins/session-enforcement.ts` `resolveGitPath()` line 40-59 | ✅ | Read file |
| 1.1 | `plugins/session-enforcement.ts` `const gitPath` line 61 | ✅ | Read file |
| 1.2 | `plugins/env-loader.ts` `resolveGitPath()` line 35-54 | ✅ | Read file |
| 1.2 | `plugins/env-loader.ts` `const gitPath` line 290 | ✅ | Read file |
| 1.3 | `plugins/env-loader.ts` `gitCmd()` line 292-308 | ✅ | Read file |
| 1.3 | `plugins/env-loader.ts` call sites lines 311, 319, 350, 358 | ✅ | Read file |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `session-enforcement.ts` has `resolveGitPath()` at module scope | Read file lines 40-61 | ✅ |
| `env-loader.ts` has `resolveGitPath()` at module scope | Read file lines 35-54 | ✅ |
| `env-loader.ts` has `gitCmd()` with `$.nothrow()`\`\${gitPath} \${cmd}\`` | Read file line 299 | ✅ |
| `env-loader.ts` calls `gitCmd()` with multi-word args | Read file lines 311, 319, 350, 358 | ✅ |
