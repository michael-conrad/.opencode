> **Migrated from michael-conrad/opencode-config#339** — this issue concerns `.opencode/` submodule content and was refiled to the correct repository.

## Summary

Update the viewport-editor MCP server version pin from `v0.3.4` to `v0.5.0` in `.opencode/opencode.jsonc`.

## Current State

Line 133 of `.opencode/opencode.jsonc`:
```jsonc
"command": ["uvx", "--from", "git+https://github.com/michael-conrad/viewport-editor@v0.3.4", "viewport-editor"],
```

## Target State

```jsonc
"command": ["uvx", "--from", "git+https://github.com/michael-conrad/viewport-editor@v0.5.0", "viewport-editor"],
```

## Changes in v0.5.0

- **File Permission Preservation** — Fixed atomic write operations to preserve original file permissions (executable bit, group/other bits) instead of using default umask-based permissions. Added `_copy_permissions` helper that copies `st_mode & 0o777` from source to destination before `os.replace`.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/opencode.jsonc` | Update version string `v0.3.4` → `v0.5.0` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|----------|---------------|---------------------|
| SC-1 | `.opencode/opencode.jsonc` references `viewport-editor@v0.5.0` | `string` | `grep` for `viewport-editor@v0.5.0` in `opencode.jsonc` |
| SC-2 | No remaining references to `viewport-editor@v0.3.4` in the repo | `string` | `grep` for `v0.3.4` returns no matches outside changelog/history |
| SC-3 | `uvx` can resolve the new version (no syntax error in command) | `structural` | `uvx --from git+https://github.com/michael-conrad/viewport-editor@v0.5.0 --help` exits successfully |

## Risk Assessment

**Low risk.** Single-line version string change. The `uvx` command format is unchanged. The `editor` MCP plugin key and all tool names are identical between versions.

## Root Cause

The version pin was set to `v0.3.4` and has not been updated through three subsequent releases (v0.4.1, v0.4.2, v0.5.0) that include bug fixes and improvements relevant to the editor MCP server used by this repo.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
