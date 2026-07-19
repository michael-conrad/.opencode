# Phase 1: Create `trunk-tip-verification.md` task card

## Purpose

Create the trunk-tip verification task card that verifies the repository is at a clean trunk-tip state before any work begins.

## Files

- CREATE: `skills/git-workflow-branch/tasks/trunk-tip-verification.md`

## Steps

### Step 1: Create trunk-tip-verification.md

Create `.opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md` with the following content:

```markdown
# Task: trunk-tip-verification

## Purpose

Verify the repository is at a clean trunk-tip state before any work begins. This gate MUST pass before any branch creation, file modification, or implementation work.

## Procedure

1. Verify parent repo is on `$DEFAULT_BRANCH`:
   - `git branch --show-current` == `$DEFAULT_BRANCH`
   - If not: return BLOCKED with `reason: PARENT_NOT_ON_TRUNK`

2. Verify parent repo has zero pending changes:
   - `git status --short` returns empty
   - If not: return BLOCKED with `reason: PARENT_HAS_PENDING_CHANGES`

3. Verify parent repo is at remote tracking tip:
   - `git rev-parse $DEFAULT_BRANCH` == `git rev-parse origin/$DEFAULT_BRANCH`
   - If not: return BLOCKED with `reason: PARENT_NOT_AT_REMOTE_TIP`

4. For each submodule in `.gitmodules`:
   a. Verify submodule is on `$DEFAULT_BRANCH`:
      - `git -C <path> branch --show-current` == `$DEFAULT_BRANCH`
      - If not: return BLOCKED with `reason: SUBMODULE_NOT_ON_TRUNK`
   b. Verify submodule has zero pending changes:
      - `git -C <path> status --short` returns empty
      - If not: return BLOCKED with `reason: SUBMODULE_HAS_PENDING_CHANGES`
   c. Verify submodule is at remote tracking tip:
      - `git -C <path> rev-parse $DEFAULT_BRANCH` == `git -C <path> rev-parse origin/$DEFAULT_BRANCH`
      - If not: return BLOCKED with `reason: SUBMODULE_NOT_AT_REMOTE_TIP`

5. Verify submodule pointer matches committed SHA:
   - `git submodule status` shows no `+` prefix (dirty pointer)
   - If not: return BLOCKED with `reason: SUBMODULE_POINTER_DIRTY`

6. Return PASS

## Result Contract

status: PASS | BLOCKED
finding_summary: "Trunk tip verification: <summary>"
blocker_reason: "<reason>"
```

### Step 2: Verify file exists

- [ ] Verify `trunk-tip-verification.md` exists at the expected path
- [ ] Verify all 6 verification steps are present (grep for each check)

## RED/GREEN

- RED: No trunk-tip-verification.md exists
- GREEN: File created with all verification steps

## VbC

- [ ] SC-1: File exists (structural)
- [ ] SC-2: grep for `branch --show-current` (string)
- [ ] SC-3: grep for `status --short` (string)
- [ ] SC-4: grep for `rev-parse origin` (string)
- [ ] SC-5: grep for `submodule` and `branch --show-current` (string)
- [ ] SC-6: grep for `submodule status` (string)

## Phase Completion

- [ ] All steps complete
- [ ] File committed to feature branch
- [ ] Phase marked complete in work state
