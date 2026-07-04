# Implementation Plan — [#1659](https://github.com/michael-conrad/.opencode/issues/1659) — Remove worktree bootstrap from session-init

**Goal:** Remove `is_worktree_setup()` and `bootstrap_worktree_layout()` from `tools/session-init`, and remove the call to `bootstrap_worktree_layout()` in `main()`.

**Architecture:** Single file edit — `tools/session-init`. Remove two function definitions and one call site. No new files, no structural changes.

**Files:**
- `tools/session-init` — remove `is_worktree_setup()`, `bootstrap_worktree_layout()`, and the call to `bootstrap_worktree_layout()` in `main()`

> **⚠️ Compliance Requirement:** This plan is a binding specification. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step's dispatch indicator is mandatory — `(**sub-agent**)` steps MUST be dispatched via `task()`, `(**inline**)` steps MUST be executed directly by the orchestrator. Violations produce defective deliverables that must be discarded.

> **⚠️ One-Step-at-a-Time Protocol:** Execute exactly one step at a time. After each step, verify the result before proceeding. Do NOT batch multiple steps. Do NOT skip verification between steps. Each step depends on the previous step's verified output.

> **⚠️ Step Status:** Each step MUST be marked with its current status: `- [ ]` (pending), `- [x]` (completed), or `- [-]` (skipped with reason). Status MUST be updated immediately after step execution. No step may be left in `pending` status when the plan is complete.

## Phase 1 — Remove worktree bootstrap

**Concern:** Remove worktree bootstrap code from session-init

**Files:** `tools/session-init`

**SCs:** SC-1, SC-2, SC-3, SC-4

**Dependencies:** None

**Entry:** Approved spec exists, solve output is SAT

**Exit:** All four SCs verified PASS

### Step-by-step

- [ ] 1. **Pre-RED coherence gate (**clean-room**).** Verify the current state of `tools/session-init` — confirm `is_worktree_setup()`, `bootstrap_worktree_layout()`, and the call in `main()` exist. **→ SC-1, SC-2, SC-3**

- [ ] 2. **RED — behavioral test (**sub-agent**).** Write a behavioral enforcement test that sends a prompt triggering session-init and asserts no worktree-related errors. Place in `.opencode/tests/behaviors/`. Test MUST FAIL at this point (change not yet made). **→ SC-4**

- [ ] 3. **GREEN — remove `is_worktree_setup()` (**sub-agent**).** Remove the `is_worktree_setup()` function definition from `tools/session-init`. **→ SC-1**

- [ ] 4. **GREEN — remove `bootstrap_worktree_layout()` (**sub-agent**).** Remove the `bootstrap_worktree_layout()` function definition from `tools/session-init`. **→ SC-2**

- [ ] 5. **GREEN — remove call in `main()` (**sub-agent**).** Remove the call to `bootstrap_worktree_layout()` in `main()`. **→ SC-3**

- [ ] 6. **GREEN doublecheck (**clean-room**).** Verify all three removals are correct — grep for `is_worktree_setup` and `bootstrap_worktree_layout` in `tools/session-init` returns nothing. **→ SC-1, SC-2, SC-3**

- [ ] 7. **Checkpoint commit (**inline**).** Commit the changes with message: `Remove worktree bootstrap from session-init (#1659)`

- [ ] 8. **Collect behavioral evidence (**sub-agent**).** Run the behavioral test from step 2. Verify it now PASSES. Collect evidence to `./tmp/behavioral-evidence-1659/`. **→ SC-4**

- [ ] 9. **Adversarial audit (**sub-agent**).** Dispatch adversarial audit of the deliverable against spec SCs. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 10. **Cross-validate (**sub-agent**).** Cross-validate verification results from steps 6, 8, and 9. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 11. **Regression check (**sub-agent**).** Run `bash .opencode/tests/test-enforcement.sh --changed` to verify no regressions. **→ SC-4**

- [ ] 12. **Review-prep (**sub-agent**).** Run `git-workflow --task review-prep` to prepare branch for PR. **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 13. **Executive summary (**inline**).** Report completion: summary, outcome, blockers (if any), PR URL (if created), byline.

#### Phase 1 VbC

- [ ] 14. **VbC (**clean-room**).** Verify: `is_worktree_setup` and `bootstrap_worktree_layout` absent from `tools/session-init`; behavioral test PASSES; no regressions. **→ SC-1, SC-2, SC-3, SC-4**

> **⚠️ Compliance Requirement:** This plan is a binding specification. Every step MUST be executed in order. No step may be skipped, reordered, or combined. Each step's dispatch indicator is mandatory — `(**sub-agent**)` steps MUST be dispatched via `task()`, `(**inline**)` steps MUST be executed directly by the orchestrator. Violations produce defective deliverables that must be discarded.

> **⚠️ Self-Remediation Protocol:** If any step fails, the orchestrator MUST remediate before proceeding. Remediation means: diagnose root cause, fix the defect, re-verify. If remediation fails after 2 attempts, report BLOCKED with root cause and HALT. Do NOT skip failed steps — a failed step produces a defective deliverable that must be discarded.

## Exit Criteria

- [ ] C1. `is_worktree_setup()` function removed from `tools/session-init` (SC-1)
- [ ] C2. `bootstrap_worktree_layout()` function removed from `tools/session-init` (SC-2)
- [ ] C3. `main()` no longer calls `bootstrap_worktree_layout()` (SC-3)
- [ ] C4. Behavioral test PASSES — session-init completes without worktree errors (SC-4)
- [ ] C5. All verification gates passed (VbC, adversarial audit, cross-validate, regression check)
- [ ] C6. Branch ready for PR (review-prep complete)
