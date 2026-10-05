# Task: verify-worktree

## Purpose

Verifies a git worktree's state after creation — confirming it exists, points to the expected branch, is isolated from the main repo, and that `worktree.path` is set for downstream file operations.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- Worktree path (`{worktree_path}`) provided in context
- Branch name (`{branch_name}`) provided in context
- Session init has been run; `worktree.fatal` is NOT `1` (if it is, HALT immediately)

If any entry criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Procedure

- [ ] 1. List all worktrees and confirm the target worktree exists:
   ```bash
   git worktree list
   ```
   Expected: both the main worktree and `.worktrees/$BRANCH_NAME` are listed. If the target worktree is missing, HALT and report — do not proceed without a valid worktree.
- [ ] 2. Confirm the worktree points to the expected branch:
   ```bash
   git -C <worktree_path> branch --show-current
   ```
   Expected: output matches the expected branch name. If it differs, HALT and report the mismatch.
- [ ] 3. Confirm the path is writable and on the expected branch. If a collision was previously detected with a different branch name, HALT and report.
- [ ] 4. Confirm isolation — the worktree is a separate working directory for the target repo, not the main repo's working tree.
- [ ] 5. Confirm `worktree.path` resolves to the target worktree path. All downstream file operations MUST prefix paths with `worktree.path` when set (per the relative-path rule in `using-git-worktrees` SKILL.md).
- [ ] 6. Write the verification evidence (worktree list output, branch, path) to the evidence artifact.
- [ ] 7. Return the result contract.

## Exit Criteria

- Worktree verified to exist and point to the expected branch
- Worktree path confirmed isolated and writable
- `worktree.path` reported for downstream file operations
- Result contract returned

If any exit criterion is not met, return BLOCKED with the unmet criterion as the reason.

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<1-3 sentences of routing-significant output>"
artifact_path: "<path to the verification evidence on disk>"
blocker_reason: "<reason if BLOCKED>"
```

## Context Required

- Related task: `using-git-worktrees/tasks/create-worktree.md` (Step 3.5 collision check, Step 5 verification logic, Step 9 environment export)
- Related task: `using-git-worktrees/tasks/operating-protocol.md` (safety verification, path resolution)
- Related guideline: `080-code-standards.md` (relative-path rule in worktree context)
