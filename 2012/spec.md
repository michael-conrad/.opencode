# SPEC-FIX: session-init reports `gh: not_logged_in` incorrectly

## Bug

`session-init` reports `gh: not_logged_in` even when `gh` is fully authenticated.

## Root Cause

Line 204 of `.opencode/tools/session-init`:

```python
result = subprocess.run(
    ["gh", "auth", "status", "--no-interactive"],
    ...
)
```

The `--no-interactive` flag does not exist for `gh auth status` in gh v2.45.0. The command fails with exit code 1 and the error `unknown flag: --no-interactive`. The script's fallback at line 228-229 interprets any non-zero exit as `not_logged_in`.

## Fix

Remove `--no-interactive`. The correct invocation is just `gh auth status` — it is non-interactive by default when stdout is not a TTY (which `subprocess.run` with `capture_output=True` ensures).

## Affected Version

gh v2.45.0, session-init as of 2026-07-19

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `gh auth status` is called without `--no-interactive` flag | `string` | grep for `--no-interactive` in `.opencode/tools/session-init` — must be absent |
| SC-2 | `gh auth status` is called with `capture_output=True` (non-TTY) | `string` | grep for `gh auth status` in `.opencode/tools/session-init` — must be present without `--no-interactive` |
| SC-3 | `session-init` correctly reports `gh: not_logged_in` only when gh is actually not authenticated | `behavioral` | Run `session-init` with authenticated gh — must report `gh: ✓ Logged in` or equivalent positive status |
