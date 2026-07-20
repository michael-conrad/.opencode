## Problem

Two issues in the behavioral test harness (`tests/behaviors/helpers.sh`):

1. **`flock -x 200` has no timeout.** When the agent launches N parallel behavioral tests, N-1 pile up on the lock and block indefinitely. The only kill mechanism is the bash tool's 600s timeout or Ctrl-C — both orphan the `opencode-cli run` child, which still holds the lock. Every subsequent test hangs until manual `kill -9`.

2. **`tests/AGENTS.md` still documents `BEHAVIOR_CONCURRENT`** as a bypass option (line 228), but the code removed it in commit `1ec2790c`. This is dead documentation that misleads agents.

## Requirements

### R1: `flock` timeout

Add a short timeout to the `flock` call so the agent can detect contention and retry or serialize explicitly instead of hanging indefinitely.

- Timeout value: 30 seconds
- On timeout: return non-zero exit with `HARNESS_FAILURE: lock contention` message to stderr
- The agent calling the test script sees the non-zero exit and can retry or report contention

### R2: Remove dead `BEHAVIOR_CONCURRENT` documentation

Remove the `BEHAVIOR_CONCURRENT` reference from `tests/AGENTS.md` line 228. The lock is always on — there is no bypass.

## Implementation Notes

- Change `flock -x 200` to `flock -x -w 30 200` in `helpers.sh`
- Add error handling: if flock fails, print `HARNESS_FAILURE: lock contention — another test is running (waited 30s)` to stderr and `return 1`
- Remove the `BEHAVIOR_CONCURRENT` paragraph from `tests/AGENTS.md` §Concurrency Lock
- Single file change, single commit

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `flock -x` changed to `flock -x -w 30` in helpers.sh | `string` |
| SC-2 | On lock timeout, script prints `HARNESS_FAILURE: lock contention` to stderr and exits non-zero | `string` |
| SC-3 | `BEHAVIOR_CONCURRENT` reference removed from tests/AGENTS.md | `string` |
| SC-4 | Behavioral test still runs successfully with no contention (regression check) | `behavioral` |

## References

- `tests/behaviors/helpers.sh` — current `flock -x 200` at line 261
- `tests/AGENTS.md` — dead `BEHAVIOR_CONCURRENT` docs at line 228
- Commit `1ec2790c` — removed BEHAVIOR_CONCURRENT from code but not docs
- Commit `68225888` — original flock addition

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)