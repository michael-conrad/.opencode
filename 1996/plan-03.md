# Phase 3: Add critical violation to `000-critical-rules.md`

## Purpose

Add a critical violation entry for starting work from a non-trunk-tip state, providing the enforcement mandate.

## Files

- MODIFY: `guidelines/000-critical-rules.md`

## Steps

### Step 1: Add critical violation entry

In `guidelines/000-critical-rules.md`, add a new Tier 1 critical violation entry. Place it in the Tier 1 section alongside other critical-rules-XXX entries:

```markdown
### [critical-rules-XXX] CRITICAL VIOLATION — Starting work from non-trunk-tip state
The parent repo MUST be on $DEFAULT_BRANCH at remote tracking tip, all submodules MUST be on $DEFAULT_BRANCH at remote tracking tip, there MUST be zero pending changes, and the submodule pointer MUST match the committed SHA before any work begins. Violation: HALT with blocker report. Discard all work and restart from clean trunk tip. This gate is enforced by `git-workflow-branch/tasks/trunk-tip-verification.md` and MUST be the first step of every pre-work task.
```

### Step 2: Verify the change

- [ ] grep for `non-trunk-tip` in 000-critical-rules.md — found

## RED/GREEN

- RED: 000-critical-rules.md does not contain non-trunk-tip violation
- GREEN: Entry present

## VbC

- [ ] SC-8: grep for `non-trunk-tip` in 000-critical-rules.md (string)

## Phase Completion

- [ ] All steps complete
- [ ] File committed to feature branch
- [ ] Phase marked complete in work state
