# Using Git Worktrees Operating Protocol

## Entry Criteria

- Worktree creation requested
- `WORKTREE_REQUIRED` flag set or developer requests isolation

## Procedure

- [ ] 1. **Opt-in only** — created when `WORKTREE_REQUIRED` or developer requests.
- [ ] 2. **Safety verification:** confirm git worktree add succeeded, verify path is writable.
- [ ] 3. **Path resolution:** `worktree.path` set; all file ops prefix paths.
- [ ] 4. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- Worktree created and verified
- `worktree.path` set for file operations
