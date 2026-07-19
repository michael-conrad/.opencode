# Phase 4: Update `session-init` tool to emit `trunk_clean`

## Purpose

Add a `trunk_clean` status section to the session-init tool output so agents have session-level awareness of trunk-tip cleanliness.

## Files

- MODIFY: `tools/session-init`

## Steps

### Step 1: Add trunk_clean output section

In `tools/session-init`, add a new output section that emits trunk-tip status. The section should be emitted after the existing repo information sections:

```python
## Trunk Tip Status
trunk_clean: true|false
parent_branch: <branch_name>
parent_clean: true|false
parent_at_tip: true|false
submodules_clean: <list>
```

The implementation should:
1. Determine `$DEFAULT_BRANCH` (from remote or default to "main")
2. Check `git branch --show-current` == `$DEFAULT_BRANCH`
3. Check `git status --short` is empty
4. Check `git rev-parse $DEFAULT_BRANCH` == `git rev-parse origin/$DEFAULT_BRANCH`
5. For each submodule, check the same conditions
6. Check `git submodule status` for dirty pointer (`+` prefix)
7. Emit the YAML-formatted section

### Step 2: Verify the change

- [ ] grep for `trunk_clean` in session-init — found

## RED/GREEN

- RED: session-init does not emit trunk_clean
- GREEN: session-init emits trunk_clean field

## VbC

- [ ] SC-9: grep for `trunk_clean` in session-init (string)

## Phase Completion

- [ ] All steps complete
- [ ] File committed to feature branch
- [ ] Phase marked complete in work state
