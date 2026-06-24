# [SPEC-FIX] env-loader.ts: change default export to named export per plugin API

## Problem

`env-loader.ts` fails to load at startup with:

```
ERROR service=plugin path=file:///.../env-loader.ts error=Plugin export is not a function failed to load plugin
```

The plugin uses `export default async function envLoaderPlugin(input: PluginInput)` but the opencode plugin system (per https://opencode.ai/docs/plugins/) expects a **named export** — a `const` or `function` with a specific name, not a `default` export. The loader iterates over module exports looking for named function exports; `export default` is a `default` key on the module, not a named export, so the loader doesn't find it.

## Root Cause

Official docs show the correct pattern:

```typescript
export const MyPlugin = async ({ project, client, $, directory, worktree }) => {
```

Current code uses:

```typescript
export default async function envLoaderPlugin(input: PluginInput): Promise {
```

## Fix

1. Change export from `export default async function envLoaderPlugin(input: PluginInput): Promise` to a named export `export const EnvLoaderPlugin: Plugin = async ({ project, client, $, directory, worktree }) => { ... }`
2. Update the import to include `Plugin` type and remove `PluginInput`:
   - `import type { Hooks, PluginInput } from "@opencode-ai/plugin"` → `import type { Plugin } from "@opencode-ai/plugin"`
3. Map context object properties:
   - `input?.directory` → `directory`
   - `input?.worktree` → `worktree`
   - `input.$.nothrow` → `$.nothrow`
4. Preserve all named exports at bottom of file (`parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic`)
5. Fix pre-existing TypeScript errors in `session-enforcement.ts`:
   - `"session.created"` hook key → `event` hook with `event.type` discrimination
   - `part.synthetic` access on non-`TextPart` variants → narrow to `part.type === 'text'` first
6. Create `.opencode/plugins/AGENTS.md` documenting plugin development requirements

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Plugin loads without "Plugin export is not a function" error | behavioral | `opencode-cli run` with plugin loaded → assert stderr does NOT contain "Plugin export is not a function" |
| SC-2 | `shell.env` hook injects all env vars (BRANCH_NAME, GIT_OWNER, GIT_REPO, etc.) | behavioral | `opencode-cli run` with plugin loaded → assert `echo $BRANCH_NAME` produces non-empty output |
| SC-3 | Named exports (`parseEnvFile`, `isEnvGitignored`, `writeDiagnostic`, `DIAGNOSTICS_PATH`, `PluginDiagnostic`) preserved | structural | `grep` for each export name in `plugins/env-loader.ts` |
| SC-4 | No TypeScript compilation errors | structural | `tsc --noEmit --project .opencode/tsconfig.json` exits 0 |
| SC-5 | `.opencode/plugins/AGENTS.md` created documenting plugin development requirements per official opencode plugin docs | structural | `ls .opencode/plugins/AGENTS.md` |

## Labels

`[SPEC-FIX]`, `plugin`
