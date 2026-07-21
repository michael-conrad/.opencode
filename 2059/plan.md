# Plan: session-init reports `gb: ✓ Logged in` false positive

## Goal

Fix the `gb` auth check in `.opencode/tools/session-init` to parse output text for `"Not logged in"` before reporting success, so that unauthenticated `gb` CLI does not produce a false positive `gb: ✓ Logged in` status.

## Architecture

Single-file fix to `.opencode/tools/session-init`, lines 247-261. The `gb auth status` check currently uses `result.returncode == 0` as the sole gate. Since `gb auth status` returns exit code 0 even when not logged in, the fix adds a negative-indicator check on the output text before the success branch.

## Files Affected

- `.opencode/tools/session-init` — the `check_gb_auth()` function, lines 247-261

## Phase Table

| Phase | Description | Steps |
|-------|-------------|-------|
| 1 | Add `"Not logged in"` detection to `gb` auth check | 1-3 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | `gb` check parses output text for `"Not logged in"` before reporting success | 1 | 1, 2 |
| SC-2 | `session-init` reports `gb: not_logged_in` when `gb` is not authenticated | 1 | 2, 3 |
| SC-3 | `session-init` reports `gb: ✓ Logged in` when `gb` is authenticated | 1 | 1, 3 |
| SC-4 | Fix does not use exit code as the sole determinant of `gb` auth status | 1 | 1, 2 |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (single-file edit, no data mutation)
- Rollback plan: `git checkout -- .opencode/tools/session-init`
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | `.opencode/tools/session-init` lines 247-261 | ✅ | `editor_read_file` confirmed the buggy code block |
| 2 | `"Not logged in"` string in `gb auth status` output | ✅ | Spec confirms exact output text |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `gb auth status` returns exit code 0 when not logged in | Spec body (lines 25-32) | ✅ |
| The `else` branch at line 260 appends `gb: ✓ Logged in` | `editor_read_file` of lines 247-261 | ✅ |
| The regex `Logged in to (\S+) as (\S+)` doesn't match `"Not logged in..."` | Spec root cause analysis | ✅ |

## Phase 1: Add `"Not logged in"` detection to `gb` auth check

### Step 1 — Add negative-indicator check before success branch

**Action:** In `.opencode/tools/session-init`, modify the `check_gb_auth()` function so that after `result.returncode == 0`, the code checks for `"Not logged in"` in the output text before entering the success branch.

**Details:**
- After line 247 (`if result.returncode == 0:`), add a check: if `"Not logged in"` appears in `line`, append `gb: not_logged_in` and skip the success branch
- The existing `else` branch (line 262) already handles `gb: not_logged_in` for non-zero exit codes — the new check mirrors that behavior for the zero-exit-code + unauthenticated case

**RED:** No test needed (string evidence SCs)
**GREEN:** Edit the file
**VbC:** Verify the edit contains `"Not logged in"` check (SC-1, SC-4)

### Step 2 — Verify the fix handles the unauthenticated case

**Action:** Confirm the logic correctly reports `gb: not_logged_in` when `gb` is not authenticated.

**Details:**
- The `"Not logged in"` check must come before the regex match attempt
- If `"Not logged in"` is found, append `gb: not_logged_in` and `continue`/skip remaining checks
- If `"Not logged in"` is NOT found, proceed to the existing regex match for authenticated output

**VbC:** Run `session-init` with unauthenticated `gb` — must report `gb: not_logged_in` (SC-2, behavioral)

### Step 3 — Verify the fix preserves the authenticated case

**Action:** Confirm the fix does not break the authenticated `gb` path.

**Details:**
- The `"Not logged in"` check is a negative-indicator guard — it only fires when the output contains that exact string
- When `gb` is authenticated, the output contains `"Logged in to <host> as <user>"`, which does NOT match `"Not logged in"`, so the existing regex match and success reporting proceed unchanged

**VbC:** Run `session-init` with authenticated `gb` — must report `gb: ✓ Logged in` (SC-3, behavioral)

### Phase 1 Exit Criteria

- [ ] SC-1: `"Not logged in"` string present in the `gb` auth check block (string evidence: grep)
- [ ] SC-2: `session-init` reports `gb: not_logged_in` when `gb` is unauthenticated (behavioral evidence: run with unauthenticated gb)
- [ ] SC-3: `session-init` reports `gb: ✓ Logged in` when `gb` is authenticated (behavioral evidence: run with authenticated gb)
- [ ] SC-4: `result.returncode == 0` is not the sole determinant (string evidence: grep confirms additional check)
