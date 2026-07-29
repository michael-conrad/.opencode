---
number: 2173
title: "[SPEC-FIX] session-init and session-to-timeline tool regressions"
status: open
labels: [bug, spec]
created: 2026-07-28T04:51:45Z
updated: 2026-07-28T04:51:45Z
remote_issue: 2173
remote_url: "https://github.com/michael-conrad/.opencode/issues/2173"
promoted_at: 2026-07-28T10:35:00Z
promotion_type: retroactive_import
last_sync: 2026-07-28T10:35:00Z
author: michael-conrad
approved: true
---

## Problem

Two regressions in `.opencode/tools/` affect tool usability:

1. **`session-to-timeline` prints mangled output** when run with no args — shows `execuvrun--script$0$@` instead of the usage message.
2. **`session-init` lost its executable bit** in the committed version — file mode `100644` instead of `100755`.

Both are local filesystem corruptions in the `.opencode` submodule (branch `feature/2141-authorization-record-then-verify`). No committed changes are involved — `git diff HEAD` is clean for both files.

---

## Root Cause Analysis

### Regression 1: `session-to-timeline` — bare string docstring

**File:** `.opencode/tools/session-to-timeline`

**Root cause:** The file uses a bare string docstring (`"""..."""` at line 12). Python's first bare string expression is the bash guard at line 3:

```python
"exec" "uv" "run" "--script" "$0" "$@"
```

Python concatenates adjacent string literals into `"execuvrun--script$0$@"`, which becomes `__doc__`. When `main()` runs with no args, it prints `__doc__` to stderr — producing the mangled output `execuvrun--script$0$@`.

**Comparison with working tools:** `session-init` and other tools that use the `uv run --script` pattern already use the explicit `__doc__ = """..."""` assignment form, which correctly sets `__doc__` regardless of the bash guard expression.

### Regression 2: `session-init` — lost executable bit

**File:** `.opencode/tools/session-init`

**Root cause:** The committed version has file mode `100644` (non-executable) instead of `100755` (executable). The executable bit was lost, likely during a checkout or merge operation. The working tree has been locally restored to `100755` (visible as an unstaged mode change in `git -C .opencode diff`).

---

## Fix Approach

### Fix 1: `session-to-timeline` docstring

Change the bare string docstring to the explicit assignment form:

```python
__doc__ = """DESCRIPTION: Extract structured tool call timeline from behavioral test session.yaml.
...
"""
```

This matches the pattern used by `session-init` and prevents the bash guard expression from becoming `__doc__`.

### Fix 2: `session-init` executable bit

```bash
git -C .opencode chmod +x tools/session-init
```

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `session-to-timeline` with no args prints usage message (not `execuvrun--script$0$@`) | `string` | Run `.opencode/tools/session-to-timeline` with no args; assert stderr contains "DESCRIPTION" or "Usage" |
| SC-2 | `session-init` has executable bit set in committed submodule | `structural` | `git -C .opencode ls-tree HEAD -- tools/session-init` shows mode `100755` |
| SC-3 | `session-init` runs without "Permission denied" | `behavioral` | Run `.opencode/tools/session-init`; assert exit code 0 |

---

## Affected Files

- `.opencode/tools/session-to-timeline` — docstring format fix
- `.opencode/tools/session-init` — file mode fix (chmod +x)
