# [SPEC-FIX] session-enforcement.ts resolveGitPath() runs invalid git commands

## Problem

Both plugins produce git errors like:
- `branch --show-current is not a git command`
- `config user.name is not a git command`
- `config user.email is not a git command`

Git IS running (the binary is found), but it receives malformed arguments.

## Root Cause

Two distinct bugs:

### Bug 1: `resolveGitPath()` uses `execSync("which git", ...)` — non-POSIX

`which` is not a POSIX-standard command. On minimal systems (Docker, some Linux distros), it doesn't exist. The fallback paths (`/usr/bin/git`, `/usr/local/bin/git`, `/snap/bin/git`) may also be wrong.

### Bug 2: `env-loader.ts` `$.nothrow()` tagged template passes multi-word cmd as single argument

Line 299:
```typescript
$.nothrow()`${gitPath} ${cmd}`
```

When `cmd = "branch --show-current"`, the tagged template passes `"branch --show-current"` (with embedded space) as a **single argument** to the shell. Git interprets the entire string as one command name — `"branch --show-current"` is not a git command.

Same for `cmd = "config user.name"` and `cmd = "config user.email"`.

`execSync(gitPath + " ...")` in `session-enforcement.ts` works because `execSync` passes through a shell which splits on whitespace. But `$.nothrow()` tagged templates pass each interpolated value as a single argument — they do NOT split on spaces within a value.

## Affected Files

- `plugins/env-loader.ts` — `gitCmd()` function (line 292-308), `resolveGitPath()` (line 35-54)
- `plugins/session-enforcement.ts` — `resolveGitPath()` (line 40-59)

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `resolveGitPath()` uses POSIX `command -v git` instead of `which git` in both plugins | `string` |
| SC-2 | `env-loader.ts` `gitCmd()` passes each git subcommand and its arguments as separate template expressions, not as a single `cmd` string | `string` |
| SC-3 | All `$.nothrow()` git calls in `env-loader.ts` use separate arguments (e.g., `${gitPath} branch --show-current` not `${gitPath} ${cmd}`) | `string` |
| SC-4 | Plugin loads without any git-related errors in normal environments | `behavioral` |
| SC-5 | `resolveGitPath()` is called lazily (not at module scope) to prevent module load failures | `string` |

## Fix Approach

### env-loader.ts

Replace the generic `gitCmd(cmd)` function with direct calls:

```typescript
// Before (broken — multi-word cmd passed as single argument)
const branchResult = await gitCmd("branch --show-current");

// After (each argument separate in template)
const branchResult = await $.nothrow()`${gitPath} branch --show-current`;
```

Or fix `gitCmd` to split the cmd string:

```typescript
async function gitCmd(...args: string[]): Promise<...> {
  if (!gitPath) return null;
  try {
    const result = await Promise.race([
      $.nothrow()`${gitPath} ${args.join(' ')}`,
      ...
    ]);
  }
}
```

### session-enforcement.ts

Replace `execSync("which git", ...)` with `execSync("command -v git", ...)`.

### Both

Move `resolveGitPath()` from module scope to lazy initialization (call on first use, cache result).
