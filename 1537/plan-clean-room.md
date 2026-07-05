# Clean-Room Plan — #1537 — Submodule pointer bumps: workflow steps and pre-commit Gate 4 fix

## Problem

The git-workflow pipeline has no step ensuring dirty submodule pointers are included in parent repo commits. Pre-commit Gate 4 blocks submodule-pointer-only commits, but there is no complementary mechanism to ensure pointers are included when non-submodule changes are also being committed. This means submodule pointer updates can be silently dropped from parent repo commits, causing the parent to reference stale submodule SHAs.

## Architecture

Single-phase plan with 4 implementation items. Items 1 and 2 are independent (parallel). Item 3 depends on Item 1 (Gate 4 logic change must understand what the workflow step does). Item 4 depends on Items 2 and 3 (the sub-agent task is the formalization of the pointer check).

## Affected Files

| File | Change Type | Purpose |
|------|-------------|---------|
| `.opencode/skills/git-workflow/tasks/implementation.md` | Edit | Add pre-commit pointer check step before commit |
| `.opencode/skills/git-workflow/tasks/pr-creation.md` | Edit | Add pre-push pointer verification step |
| `.opencode/hooks/pre-commit` | Edit | Update Gate 4 to allow pointers alongside non-submodule changes |
| `.opencode/skills/git-workflow/SKILL.md` | Edit | Add `pre-commit-pointer-check` to trigger dispatch table |
| `.opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md` | Create | New sub-agent task for pointer check |

## Phase 1 — Submodule pointer workflow and pre-commit Gate 4 fix

**Concern:** Ensure dirty submodule pointers are included in parent repo commits by adding workflow steps, updating Gate 4, and creating a dedicated sub-agent task.

**Files:** All 5 affected files above.

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** None (single phase)

**Entry conditions:** Spec #1537 approved

**Exit conditions:** All 4 items implemented, committed, and verified

### Step-by-step

- [ ] 1. **Add pre-commit pointer check to implementation.md.**
  - **SC:** SC-1
  - Read `.opencode/skills/git-workflow/tasks/implementation.md`
  - In the "Making Implementation Commits" section, before the `git add <files>` / `git commit` block, insert a step that:
    1. Runs `git submodule status` to detect dirty pointers (lines starting with ` ` or `+`)
    2. If dirty pointers found: runs `git add <submodule-path>` to stage them alongside other changes
    3. Verifies staged files include both source changes AND submodule pointer updates
  - The step should be a `### ⚠️ CRITICAL: Pre-Commit Submodule Pointer Check` subsection
  - Commit: `git-workflow(implementation): add pre-commit submodule pointer check step`
  - **Dependencies:** None (root item)

- [ ] 2. **Add pre-push pointer verification to pr-creation.md.**
  - **SC:** SC-2
  - Read `.opencode/skills/git-workflow/tasks/pr-creation.md`
  - In the "Procedure" section, before the squash/push step (Step 2-4), insert a verification step that:
    1. Checks `git submodule status` for dirty pointers
    2. Verifies the staged/committed changes include the pointer updates
    3. If pointers are missing: warns and suggests re-running implementation step
  - Commit: `git-workflow(pr-creation): add submodule pointer verification step`
  - **Dependencies:** None (parallel with Item 1)

- [ ] 3. **Update pre-commit Gate 4 logic.**
  - **SC:** SC-3
  - Read `.opencode/hooks/pre-commit`
  - Gate 4 currently blocks when ALL staged files are submodule pointers. Update it to:
    - Only block when ALL staged files are submodule pointers AND there are no uncommitted non-submodule changes in the working tree
    - If non-submodule changes exist alongside submodule pointers: allow the commit (the non-submodule changes justify the commit)
    - If only submodule pointers are staged and no other changes exist: still block (standalone pointer-only commit)
  - The key logic change: after detecting `ALL_SUBMODULE_POINTERS=1`, also check `git status --porcelain` for unstaged non-submodule changes. If any exist, allow the commit.
  - Commit: `hooks(pre-commit): update Gate 4 to allow submodule pointers alongside non-submodule changes`
  - **Dependencies:** Item 1

- [ ] 4. **Add pre-commit-pointer-check to SKILL.md dispatch table and create sub-agent task.**
  - **SC:** SC-4, SC-5
  - Read `.opencode/skills/git-workflow/SKILL.md`
  - Add `pre-commit-pointer-check` to the trigger dispatch table with trigger phrases: "pre-commit pointer check", "submodule pointer check", "check submodule pointers"
  - Add to the Tasks list
  - Add to the Invocation table with `task(..., prompt: "execute pre-commit-pointer-check task from git-workflow")`
  - Create `.opencode/skills/git-workflow/tasks/pre-commit-pointer-check.md` with:
    - Purpose: Check for dirty submodule pointers before commit and ensure they are staged
    - Procedure:
      1. Run `git submodule status` to detect dirty pointers
      2. Check whether dirty pointers are staged (`git diff --cached --name-only`)
      3. If dirty pointers exist but are not staged: warn and suggest `git add <path>`
      4. If dirty pointers are staged alongside other changes: report PASS
      5. If no dirty pointers: report PASS with no-action
    - Result contract: `{ status, finding_summary, artifact_path, blocker_reason }`
  - Commit: `git-workflow: add pre-commit-pointer-check sub-agent task and dispatch entry`
  - **Dependencies:** Items 2, 3

### Phase 1 VbC

- [ ] 5. **VbC.** Verify all 4 items are committed and the plan's exit criteria are met. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

### Global post-steps

- [ ] 6. **Adversarial audit.** Audit plan deliverables against spec #1537 success criteria.
- [ ] 7. **Cross-validate.** Cross-validate verification results.
- [ ] 8. **Regression check.** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no regressions.
- [ ] 9. **Review-prep.** Dispatch `git-workflow --task review-prep` for PR readiness.
- [ ] 10. **Executive summary.** Report completion with summary, outcome, blockers, and byline.

## Exit Criteria

- [ ] C1: `implementation.md` has a step checking for dirty submodule pointers before commit
- [ ] C2: `pr-creation.md` has a step verifying submodule pointers are included
- [ ] C3: Pre-commit Gate 4 allows submodule pointers when non-submodule changes are also staged
- [ ] C4: A `pre-commit-pointer-check` sub-task exists in git-workflow
- [ ] C5: Agent following the workflow includes dirty submodule pointers in parent repo commits without `--no-verify`
