# SPEC-FIX: session-init reports `gb: ✓ Logged in` false positive

## Bug

`session-init` reports `gb: ✓ Logged in` even when `gb` is not authenticated.

## Root Cause

Lines 247-267 of `.opencode/tools/session-init`:

```python
result = subprocess.run(
    ["gb", "auth", "status"],
    capture_output=True,
    text=True,
    check=False,
    stdin=subprocess.DEVNULL,
    timeout=NETWORK_TIMEOUT,
)
if result.returncode == 0:
    ...
    status_lines.append("gb: ✓ Logged in")
```

`gb auth status` returns exit code **0** even when not logged in. The output is:

```
Not logged in to any GitBucket instance.
Run `gb auth login` to authenticate.
```

The script enters the `returncode == 0` branch, the regex `Logged in to (\S+) as (\S+)` doesn't match `"Not logged in..."`, so it falls to the `else` and appends `gb: ✓ Logged in` — a false positive.

## Fix

Parse the output text for negative indicators before reporting success. The `gb` check must detect `"Not logged in"` in the output text and report `gb: not_logged_in` regardless of exit code.

## Affected Version

`gb` CLI v0.6.1, `session-init` as of 2026-07-21

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `gb` check parses output text for `"Not logged in"` before reporting success | `string` | grep for `Not logged in` in `.opencode/tools/session-init` — must be present in the `gb` auth check block |
| SC-2 | `session-init` reports `gb: not_logged_in` when `gb` is not authenticated | `behavioral` | Run `session-init` with unauthenticated `gb` — must report `gb: not_logged_in` |
| SC-3 | `session-init` reports `gb: ✓ Logged in` when `gb` is authenticated | `behavioral` | Run `session-init` with authenticated `gb` — must report `gb: ✓ Logged in` or equivalent positive status |
| SC-4 | Fix does not use exit code as the sole determinant of `gb` auth status | `string` | grep for `result.returncode == 0` in the `gb` block — must not be the only check before reporting success |
