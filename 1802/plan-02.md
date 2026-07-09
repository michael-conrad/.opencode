# Phase 2: Update PR Body Generation to Include the VbC Table

## Purpose

Modify the PR body generation in `git-workflow/pr-creation/create-pr.md` to include the VbC 4-column table from the VbC artifact, replacing the current per-SC evidence table format.

## SC Coverage

| SC ID | Criterion | Evidence Type |
|-------|-----------|---------------|
| SC-1 | PR body generation produces a 4-column VbC table (ID, Criterion, Test, Result) with test-type annotations | behavioral |

## Red Checkpoint

- **RED checkpoint:** PR body template does NOT include the 4-column VbC table → failure condition: SC-1 not satisfied
- **Failure condition:** `create-pr.md` output lacks VbC table or uses old per-SC evidence format

## Steps

### Step 5: Update `create-pr.md` — Add VbC Table to PR Body Template

**File:** `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md`

Modify the PR body template to include the VbC 4-column table.

**Changes:**
- Replace the current "Per-SC Evidence" table format (5 columns: SC ID, Success Criterion, Evidence Type, Command, Result) with the new 4-column format (ID, Criterion, Test, Result)
- Add a new data flow entry in the Data Flow table: `**VbC Table**` sourced from `read {project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md`
- Update the PR Body Requirements section to reference the new table format
- Keep the Dual-Auditor Cross-Validation table and Spec-Card-Mapped Commits table unchanged

**Dispatch:** `sub-agent` via `task()`

### Step 6: Update Verification-Evidence-Check Gate

**File:** `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md`

Update the verification-evidence-check gate to also check for the VbC table artifact.

**Changes:**
- Add a check for `{project_root}/tmp/{issue-N}/artifacts/vbc-table-*.md` alongside the existing verification artifact checks
- If the VbC table artifact is MISSING, add it to the blocked state blockers list

**Dispatch:** `sub-agent` via `task()`

## Phase Completion Block

- [ ] Both steps complete
- [ ] PR body template includes VbC 4-column table from VbC artifact
- [ ] Verification-evidence-check gate checks for VbC table artifact
- [ ] Phase checkpoint tag created
