## Problem

The `_check_legacy_formats()` function in `.opencode/tools/local-issues:1959-1963` emits a warning when legacy `.issues/` directory formats are detected, but the warning does not tell the user what the correct format is:

```
Warning: Legacy issue directory format detected in .issues/.
AI agent must inspect and remediate manually.
```

The user (or AI agent) sees this warning and knows something is wrong, but has no information about what the correct format should be. They must go read documentation or source code to discover that the correct format is `.issues/{N}/` (flat numbered directories) or `<submodule>/.issues/{N}/` for submodule repos.

## Root Cause

The warning string at line 1959-1963 only states the problem (legacy format detected) without stating the solution (what the correct format is).

## Affected Files

- `.opencode/tools/local-issues` — `_check_legacy_formats()` function, lines 1959-1963

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Warning message includes the correct format: `.issues/{N}/` (flat numbered directories) | `string` | grep for `.issues/{N}/` in the warning output |
| SC-2 | Warning message mentions submodule variant: `<submodule>/.issues/{N}/` | `string` | grep for `submodule` in the warning output |
| SC-3 | Warning still fires at most once per session (`.legacy-warned` sentinel preserved) | `behavioral` | Run `local-issues` twice, verify warning appears only once |
| SC-4 | Warning still detects both legacy patterns: `open/`/`closed/` subdirectories AND `{N}-{slug}` directories | `behavioral` | Create both legacy patterns, verify warning fires for each |

## Implementation Notes

- Change only the `print()` call at lines 1959-1963
- The sentinel file mechanism (`.legacy-warned`) must remain unchanged
- The detection logic (lines 1941-1956) must remain unchanged
- The correct format is already documented in `AGENTS.md` and `060-tool-usage.md` — the warning should reference this

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
