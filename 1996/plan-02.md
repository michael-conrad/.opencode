# Phase 2: Update `pre-work.md` to call trunk-tip-verification as step 0

## Purpose

Add trunk-tip verification as the mandatory first step in `pre-work.md`, before any branch creation or sync operations.

## Files

- MODIFY: `skills/git-workflow-branch/tasks/pre-work.md`

## Steps

### Step 1: Add trunk-tip verification as step 0

In `skills/git-workflow-branch/tasks/pre-work.md`, add a new step 0 before the existing "Step 1: Verify Authorization Context":

```markdown
### Step 0: Trunk-Tip Verification (**sub-agent**)

**Mandatory first step before any work begins.** Verify the repository is at a clean trunk-tip state:

- [ ] 0. **Trunk-tip verification (**sub-agent**).** `task(..., prompt: "execute trunk-tip-verification from git-workflow-branch")`. If BLOCKED, HALT with blocker report. Do NOT proceed to branch creation.
```

Insert this after the "## Procedure" heading and before "### Step 1: Verify Authorization Context".

### Step 2: Verify the change

- [ ] grep for `trunk-tip-verification` in pre-work.md — found

## RED/GREEN

- RED: pre-work.md does not reference trunk-tip-verification
- GREEN: pre-work.md calls trunk-tip-verification as step 0

## VbC

- [ ] SC-7: grep for `trunk-tip-verification` in pre-work.md (string)

## Phase Completion

- [ ] All steps complete
- [ ] File committed to feature branch
- [ ] Phase marked complete in work state
