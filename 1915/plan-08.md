# Phase 8: Behavioral Enforcement Test for SC-9

**SCs:** SC-9
**Files:** `.opencode/tests/behaviors/sub-agent-dispatch-rejection.sh` (new)
**Chain dependency:** `phase_7` (test depends on all restructured files existing)

## Steps

### Step 8.1: Create behavioral test script

Create `.opencode/tests/behaviors/sub-agent-dispatch-rejection.sh` that:
1. Uses `with-test-home` wrapper
2. Sends a prompt to a sub-agent that reads a task file containing sub-agent dispatch instructions
3. Asserts the sub-agent returns `BLOCKED` with `PRELOADED_CONTEXT_REJECTED` or equivalent
4. Uses assertion helpers from `.opencode/tests/behaviors/helpers.sh`

**Dispatch:** `sub-agent` — creates test script
**Evidence:** File exists with correct test logic

### Step 8.2: Run behavioral test (RED phase)

Run the test before any implementation changes to confirm it FAILS (the sub-agent currently does not reject impossible dispatch instructions).

**Dispatch:** `sub-agent` — runs `bash .opencode/tests/behaviors/sub-agent-dispatch-rejection.sh`
**Evidence:** Test output showing FAIL

### Step 8.3: Verify SC-9 compliance

- **SC-9:** Behavioral test exists and passes after implementation
- **SC-9:** Test uses `with-test-home` wrapper and assertion helpers

**Dispatch:** `sub-agent` — runs verification
**Evidence:** Test output showing PASS

## SC-to-Step Traceability

| SC ID | Criterion | Step(s) |
|-------|-----------|---------|
| SC-9 | Behavioral test: sub-agent returns BLOCKED on impossible dispatch | 8.1, 8.2, 8.3 |

## Safety/Rollback

- **Destructive operations:** None — new file only
- **Rollback plan:** `rm .opencode/tests/behaviors/sub-agent-dispatch-rejection.sh`
- **Data loss risk:** None
