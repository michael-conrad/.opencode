# Phase 3: Update Finishing Checklist to Verify Table Presence

## Purpose

Add a checklist item to the `finishing-a-development-branch` checklist that verifies the VbC 4-column table is present in the PR body before PR creation.

## SC Coverage

| SC ID | Criterion | Evidence Type |
|-------|-----------|---------------|
| SC-2 | Finishing checklist verifies VbC table presence in PR body | string |

## Red Checkpoint

- **RED checkpoint:** Finishing checklist does NOT verify VbC table presence → failure condition: SC-2 not satisfied
- **Failure condition:** `checklist.md` lacks VbC table verification item

## Steps

### Step 7: Add VbC Table Checklist Item

**File:** `.opencode/skills/finishing-a-development-branch/tasks/checklist.md`

Add a new checklist section or item under "SC Verification" that verifies the VbC table is present in the PR body.

**Changes:**
- Add a new checklist item: `- [ ] VbC 4-column table (ID, Criterion, Test, Result) present in PR body`
- Add a verification step: read the PR body and confirm the table format matches the spec
- Add a note that the table must be populated from VbC output, not hand-written

**Dispatch:** `sub-agent` via `task()`

## Phase Completion Block

- [ ] Step 7 complete
- [ ] Finishing checklist includes VbC table presence verification
- [ ] Phase checkpoint tag created
