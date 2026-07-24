---
number: 1253
title: "[SPEC-FIX] Fix requires-python tilde specifier in all PEP 723 scripts"
state: OPEN
---

---
id: FIX
type: spec-fix
title: "[SPEC-FIX] Fix requires-python tilde specifier in all PEP 723 scripts"
status: draft
created: 2026-06-16
author: Michael Conrad
affected-files:
  - .opencode/tools/local-issues
  - .opencode/tools/* (all PEP 723 scripts)
  - .opencode/tools/impl/* (all PEP 723 scripts)
  - .opencode/tools/impl/skildeck/* (all PEP 723 scripts)
  - .opencode/skills/skill-creator/scripts/*.py
  - .opencode/skills/issue-operations/platforms/gitbucket-api/tests/*.py
  - .opencode/scripts/session_context_triggers.py
  - .opencode/tests/regressions/regression-91-verify-structure.py
  - .opencode/guidelines/070-environment.md
related:
  - michael-conrad/.opencode#1252
---

## Summary

All PEP 723 inline script metadata blocks use `requires-python = "~=3.12"` which uv interprets as `>=3.12, <4` — too broad. This causes `uv run --script` to fail with `ModuleNotFoundError` because uv selects a Python 3.13+ interpreter but the script's dependencies aren't installed for that interpreter.

## Problem

When running `uv run --script .opencode/tools/local-issues import-remote 1252`, uv warns:

```
The `requires-python` specifier (`~=3.12`) uses the tilde specifier (`~=`) without a patch version. This will be interpreted as `>=3.12, <4`. Did you mean `~=3.12.0` to constrain the version as `>=3.12.0, <3.13`?
```

Then the script fails with `ModuleNotFoundError: No module named 'yaml'` because uv created an isolated environment using Python 3.13+ (allowed by `~=3.12` → `>=3.12, <4`) but didn't install pyyaml into it.

## Root Cause

The tilde operator `~=` without a patch version is ambiguous. `~=3.12` means `>=3.12, <4` — allowing any Python 3.x version. The intended constraint is `~=3.12.0` which means `>=3.12.0, <3.13` — only Python 3.12.x.

## Scope

### In Scope

- All PEP 723 scripts in `.opencode/` that use `requires-python = "~=3.12"` — change to `requires-python = "~=3.12.0"`
- The example in `.opencode/guidelines/070-environment.md` that shows `~=3.12` — update to `~=3.12.0`
- The parent repo's `pyproject.toml` `requires-python` field (not PEP 723, but same issue) — change to `~=3.12.0`

### Out of Scope

- Non-PEP-723 Python files
- Third-party scripts

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | All PEP 723 scripts in `.opencode/tools/` use `requires-python = "~=3.12.0"` | string |
| SC-2 | All PEP 723 scripts in `.opencode/tools/impl/` use `requires-python = "~=3.12.0"` | string |
| SC-3 | All PEP 723 scripts in `.opencode/tools/impl/skildeck/` use `requires-python = "~=3.12.0"` | string |
| SC-4 | Skill creator scripts use `requires-python = "~=3.12.0"` | string |
| SC-5 | GitBucket API test scripts use `requires-python = "~=3.12.0"` | string |
| SC-6 | `session_context_triggers.py` uses `requires-python = "~=3.12.0"` | string |
| SC-7 | `regression-91-verify-structure.py` uses `requires-python = "~=3.12.0"` | string |
| SC-8 | `070-environment.md` examples use `~=3.12.0` | string |
| SC-9 | `pyproject.toml` uses `requires-python = "~=3.12.0"` | string |
| SC-10 | `uv run --script .opencode/tools/local-issues import-remote 1252` works without ModuleNotFoundError | behavioral |

## Affected Files

~51 files total across:
- `.opencode/tools/` — 15+ scripts
- `.opencode/tools/impl/` — 15+ scripts
- `.opencode/tools/impl/skildeck/` — 10+ scripts
- `.opencode/skills/skill-creator/scripts/` — 4 scripts
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tests/` — 3 scripts
- `.opencode/scripts/session_context_triggers.py`
- `.opencode/tests/regressions/regression-91-verify-structure.py`
- `.opencode/guidelines/070-environment.md`
- `pyproject.toml` (parent repo)

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*