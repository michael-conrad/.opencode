# Implementation Plan — [#1873](https://github.com/michael-conrad/.opencode/issues/1873) — Cleanup Post-Verification Missing `git branch --show-current` Check

**Goal:** Add `git branch --show-current` verification to post-cleanup checks in `cleanup.md` Step 4 and `branch-cleanup.md` Step 5, so the agent detects when the working tree is on a feature branch whose HEAD matches `origin/$DEFAULT_BRANCH`.

**Architecture:** Pure additive change — insert a branch-name check alongside the existing hash comparison. No existing behavior modified. The new check runs before the hash comparison and is wrapped in `|| true` for graceful failure handling.

**Files:**
- `.opencode/skills/git-workflow/tasks/cleanup.md` — Step 3 (lines 146-165)
- `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` — Step 5 (lines 434-439)

**Dispatch:** `implementation-pipeline` → `git-workflow` skill (file edits only, no new files)

## Blast Radius

Narrow and self-contained. Two task files in the `git-workflow` skill. No downstream consumers parse the specific format of Step 4/5 verification outputs. No enforcement tests need structural updates (behavioral tests may be added separately).

## Concern Map Reference

Single concern: **Post-cleanup branch verification**. Maps 1:1 to Phase 1.

## Admonishment

> **⚠️ COMPLIANCE REQUIREMENT — READ BEFORE EXECUTING**
> This plan is an AI-generated artifact. The implementing agent MUST:
> 1. Read the spec at [#1873](https://github.com/michael-conrad/.opencode/issues/1873) before starting
> 2. Verify all referenced files and line ranges exist before editing
> 3. Follow the step-by-step sequence — do not skip, reorder, or combine steps
> 4. Run verification after each step before proceeding
> 5. Report BLOCKED with specific reason if any step cannot be completed

## One-Step-at-a-Time Protocol

> **⚠️ ONE STEP AT A TIME — DO NOT PARALLELIZE**
> Each step in this plan depends on the previous step's output. Execute sequentially. Do not dispatch multiple steps in parallel. Do not skip steps. If a step fails, stop and report BLOCKED.

## Step Status

> **📋 STEP STATUS INSTRUCTION**
> The implementing agent MUST maintain a `todowrite` list with status for each step. Mark `in_progress` when starting a step, `completed` when done. Clear the list before HALT.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Add `git branch --show-current` to cleanup verification | Post-cleanup branch verification | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1.1–1.5 | `git-workflow` (file edits) |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | `cleanup.md` Step 4 includes `git branch --show-current` verification | 1 | 1.1 |
| SC-2 | `branch-cleanup.md` Step 5 includes `git branch --show-current` verification | 1 | 1.2 |
| SC-3 | Agent detects wrong-branch state during post-cleanup verification | 1 | 1.3 (behavioral test) |
| SC-4 | Agent correctly reports "all repos at dev tip" when branch AND hash match | 1 | 1.4 (behavioral test) |
| SC-5 | `git branch --show-current` failure handled gracefully with `\|\| true` | 1 | 1.1, 1.2 |

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/skills/git-workflow/tasks/cleanup.md` Step 3 (lines 146-165) | ✅ | `editor_read_file` confirmed content |
| 1.2 | `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` Step 5 (lines 434-439) | ✅ | `editor_read_file` confirmed content |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None (pure additive changes to task files)
- Rollback plan: `git checkout -- <file>` to revert if needed
- Data loss risk: None

## Step-by-Step

- [ ] 1.1 (**sub-agent**) Add `git branch --show-current` to `cleanup.md` Step 3
  - **File:** `.opencode/skills/git-workflow/tasks/cleanup.md`
  - **Location:** After Step 3c (collect evidence artifact), before Step 3d (compare hashes)
  - **Action:** Insert a new sub-step between 3c and 3d:
    ```bash
    e. Verify checked-out branch:
       CURRENT_BRANCH=$(git -C "$REPO_PATH" branch --show-current 2>/dev/null || true)
       if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
           echo "WARNING: $REPO_PATH is on branch '$CURRENT_BRANCH', not '$DEFAULT_BRANCH'"
           echo "Branch mismatch detected — repo is parked on wrong branch"
       fi
    ```
  - **SC:** SC-1, SC-5
  - **Evidence type:** `string`
  - **Verification:** grep for `git branch --show-current` in cleanup.md Step 3

- [ ] 1.2 (**sub-agent**) Add `git branch --show-current` to `branch-cleanup.md` Step 5
  - **File:** `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md`
  - **Location:** After `git status --porcelain` check, before `git branch -vv`
  - **Action:** Insert a new verification command:
    ```bash
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || true)
    if [ -n "$CURRENT_BRANCH" ] && [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
        echo "WARNING: Working tree is on branch '$CURRENT_BRANCH', not '$DEFAULT_BRANCH'"
    fi
    ```
  - **SC:** SC-2, SC-5
  - **Evidence type:** `string`
  - **Verification:** grep for `git branch --show-current` in branch-cleanup.md Step 5

- [ ] 1.3 (**sub-agent**) Write behavioral test for wrong-branch detection (SC-3)
  - **File:** `.opencode/tests/behaviors/cleanup-branch-verification.sh` (new)
  - **Action:** Create a behavioral test that sets up an isolated repo where the working tree is on a feature branch whose HEAD matches `origin/$DEFAULT_BRANCH`, runs the cleanup verification, and asserts the agent detects the mismatch
  - **SC:** SC-3
  - **Evidence type:** `behavioral`
  - **Verification:** `bash .opencode/tests/behaviors/cleanup-branch-verification.sh` passes

- [ ] 1.4 (**sub-agent**) Write behavioral test for correct-branch detection (SC-4)
  - **File:** `.opencode/tests/behaviors/cleanup-branch-verification.sh` (same file, additional assertion)
  - **Action:** Add a second test case to the same file that sets up an isolated repo where the working tree IS on `$DEFAULT_BRANCH` and hash matches, asserts the agent reports "all repos at dev tip"
  - **SC:** SC-4
  - **Evidence type:** `behavioral`
  - **Verification:** `bash .opencode/tests/behaviors/cleanup-branch-verification.sh` passes both assertions

- [ ] 1.5 (**sub-agent**) Verify all changes
  - **Action:** Run content-verification: grep for `git branch --show-current` in both modified files
  - **Action:** Run behavioral tests: `bash .opencode/tests/behaviors/cleanup-branch-verification.sh`
  - **SC:** SC-1, SC-2, SC-3, SC-4, SC-5
  - **Verification:** All grep patterns match, behavioral test passes

## VbC Section

After all steps complete, the implementing agent MUST:
1. **Content-verification:** grep both files for `git branch --show-current` — confirm SC-1, SC-2, SC-5
2. **Behavioral verification:** Run `bash .opencode/tests/behaviors/cleanup-branch-verification.sh` — confirm SC-3, SC-4
3. **Report:** PASS only if all 5 SCs verified. If any SC fails, remediate and re-verify.

## Bottom Admonishment

> **⚠️ COMPLIANCE REQUIREMENT — READ BEFORE EXECUTING**
> This plan is an AI-generated artifact. The implementing agent MUST:
> 1. Read the spec at [#1873](https://github.com/michael-conrad/.opencode/issues/1873) before starting
> 2. Verify all referenced files and line ranges exist before editing
> 3. Follow the step-by-step sequence — do not skip, reorder, or combine steps
> 4. Run verification after each step before proceeding
> 5. Report BLOCKED with specific reason if any step cannot be completed

## Self-Remediation Protocol

> **🔄 SELF-REMEDIATION PROTOCOL**
> If a step fails, the agent MUST:
> 1. Diagnose the root cause
> 2. Attempt remediation (fix the issue, not the symptom)
> 3. Re-verify the step
> 4. Only after 2+ remediation attempts: report BLOCKED with both failure artifacts
> Do NOT skip, reclassify, or soft-pass a failed step.

## Exit Criteria

- [ ] C1: `cleanup.md` Step 3 contains `git branch --show-current` verification (SC-1)
- [ ] C2: `branch-cleanup.md` Step 5 contains `git branch --show-current` verification (SC-2)
- [ ] C3: Behavioral test for wrong-branch detection exists and passes (SC-3)
- [ ] C4: Behavioral test for correct-branch detection exists and passes (SC-4)
- [ ] C5: `git branch --show-current` is wrapped in `|| true` for graceful failure (SC-5)
- [ ] C6: All implementation-pipeline mandatory steps enumerated in plan
- [ ] C7: Plan reported in chat with `.opencode/.issues/1873/plan.md` path

## Approval Cascade

| Scope | Plan Approval | Implementation |
|-------|--------------|----------------|
| `for_pr` | Auto-approved | Auto-approved |

Authorization scope `for_pr` — plan is auto-approved. Proceed to implementation pipeline.

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
