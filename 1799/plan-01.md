---
phase: 1
scs: [SC-1]
depends_on: []
concern: "Guideline text — add Authorization Scope ≠ Implementation Trigger block to 010-approval-gate.md"
---

# Phase 1: Add Authorization Scope Block to 010-approval-gate.md

## Concern

Add the "Authorization scope defines what the agent MAY do, not what it MUST do now" block to `010-approval-gate.md`. This is a string-evidence SC — verified by grep.

## Steps

### Step 1: Pre-flight — verify spec and current state

- **Dispatch**: inline
- **Chain**: none
- **Action**: Verify spec #1799 is approved (label check). Read current `010-approval-gate.md` to find insertion point.
- **Expected**: Spec approved. File exists at `.opencode/guidelines/010-approval-gate.md`.

### Step 2: RED — write content-verification test

- **Dispatch**: sub-agent via `task(..., prompt: "execute research task from writing-plans")`
- **Chain**: step_1
- **Action**: Create a grep-based assertion that checks for the string "Authorization scope defines what the agent MAY do" in `010-approval-gate.md`. This test MUST fail initially (string not present).
- **Expected**: Test file created, test fails on first run.

### Step 3: GREEN — insert the authorization scope block

- **Dispatch**: sub-agent via `task(..., prompt: "execute write task from writing-plans")`
- **Chain**: step_2
- **Action**: Insert the following block into `010-approval-gate.md` at the appropriate location (after the existing "Authorization scope" section or in the Mandatory Requirements section):

  ```
  > **Authorization scope defines what the agent MAY do, not what it MUST do now.**
  >
  > `for_pr` scope means: "you are authorized to proceed through the full pipeline (plan → implement → PR)." It does NOT mean "skip to implementation." The agent MUST still:
  > 1. Create a plan from the spec (via `writing-plans`)
  > 2. Present the plan
  > 3. Execute the plan step-by-step
  > 4. Create the PR
  >
  > A question is NEVER authorization. A scope approval is NEVER a skip-the-pipeline directive. The pipeline sequence (spec → plan → implement → PR) is invariant — no authorization scope compresses it.
  ```

- **Expected**: Block inserted, file saved.

### Step 4: REFACTOR — verify block presence

- **Dispatch**: inline
- **Chain**: step_3
- **Action**: Run `grep` for the block string. Verify the content-verification test now passes.
- **Expected**: grep finds the string. Test passes.

### Step 5: COMMIT

- **Dispatch**: sub-agent via `task(..., prompt: "execute completion task from writing-plans")`
- **Chain**: step_4
- **Action**: Commit the change to `010-approval-gate.md` with message: `Phase 1: Add Authorization Scope ≠ Implementation Trigger block to 010-approval-gate.md`
- **Expected**: Commit succeeds.

## Phase Exit Criteria

| SC | Evidence Type | Verification Method | Status |
|----|---------------|---------------------|--------|
| SC-1 | `string` | grep for "Authorization scope defines what the agent MAY do" | PENDING |

## VbC Block

- [ ] grep for "Authorization scope defines what the agent MAY do" in `010-approval-gate.md` — must return match
- [ ] Content-verification test passes
- [ ] Commit exists with Phase 1 changes

## Concern Transition

Phase 1 complete → transition to Phase 2 (test infrastructure). No dependency chain between Phase 1 and Phase 2.
