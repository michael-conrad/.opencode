# Implementation Plan — [#1445](https://github.com/michael-conrad/opencode-config/issues/1445) — Submodule dev sync verification and conflict detection

**Goal:** Add trunk branch creation and `--ff-only` enforcement to all three submodule lifecycle points (pre-work, mid-feature, cleanup), with HALT on divergence.

**Architecture:** Three sub-agent task files (`submodule-tag-prework`, `submodule-dev-restore`, `submodule-sync`) plus their agent configs and SKILL.md descriptions all need the same two changes: (1) verify/create `main` branch on submodule remote before syncing, (2) use `--ff-only` for trunk pull and HALT on non-fast-forward.

**Files:**
- `.opencode/skills/git-workflow/tasks/pre-work.md` — Step 3.5 submodule sync procedure
- `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` — Step 1.9 submodule dev restore
- `.opencode/skills/git-workflow/tasks/submodule-sync.md` — mid-feature sync
- `.opencode/skills/git-workflow/SKILL.md` — sub-agent task descriptions
- `.opencode/agents/submodule-tag-prework.jsonc` — sub-agent config
- `.opencode/agents/submodule-dev-restore.jsonc` — sub-agent config

> **⚠️ COMPLIANCE REQUIREMENT:** Every step in this plan is mandatory. Skipping, combining, or reordering steps produces defective deliverables that must be discarded. Each step dispatches exactly one sub-agent or executes inline. No step bundles multiple dispatches.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute steps strictly sequentially. Do NOT proceed to step N+1 until step N is fully complete and verified. Do NOT read ahead. Do NOT batch steps. Each step is an atomic unit.

> **⚠️ STEP STATUS:** After completing each step, mark it as `[x]` in the plan file. Do NOT mark steps ahead. Do NOT skip steps.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If a step fails (RED test does not fail, GREEN test does not pass, checkpoint commit fails), the agent MUST: (1) diagnose root cause, (2) fix the defect, (3) re-run the step, (4) proceed only on clean PASS. Do NOT skip past a failed step. Do NOT reclassify a FAIL as "close enough." Do NOT proceed past a failed step without remediation.

---

## Phase 1 — Submodule trunk branch creation and `--ff-only` enforcement

**Concern:** All three submodule lifecycle points (pre-work, mid-feature, cleanup) need trunk branch creation and `--ff-only` enforcement with HALT on divergence.

**Files:** All 6 affected files listed above.

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

**Dependencies:** T6 depends on T1-T5 (actionable divergence reporting requires all three lifecycle points to have divergence detection first)

**Entry conditions:** Spec approved, plan written

**Exit conditions:** All 6 files modified, all 6 SCs verified, behavioral tests pass, adversarial audit clean

### TDD Items

#### T1 — Pre-work main branch creation (SC-1)

- [ ] **T1-RED (**clean-room**).** Write behavioral enforcement test for SC-1 (pre-work creates `main` branch in submodules from default branch if missing). Test MUST FAIL at this point because the change doesn't exist yet.
- [ ] **T1-GREEN (**clean-room**).** Modify `pre-work.md` Step 3.5 — add trunk branch creation step before submodule checkout: verify `main` exists on submodule remote, create from default branch if missing. Modify `submodule-tag-prework.jsonc` — update description to include trunk branch creation.
- [ ] **T1-GREEN-doublecheck (**clean-room**).** Verify the changes are correct: trunk branch creation present in pre-work, agent config description updated. Read the modified files and confirm.
- [ ] **T1-COMMIT (**inline**).** `git add .opencode/skills/git-workflow/tasks/pre-work.md .opencode/agents/submodule-tag-prework.jsonc && git commit -m "T1: pre-work submodule main branch creation"`

#### T2 — Pre-work `--ff-only` (SC-2)

- [ ] **T2-RED (**clean-room**).** Write behavioral enforcement test for SC-2 (pre-work uses `--ff-only` for submodule trunk pull and HALTs on non-fast-forward). Test MUST FAIL.
- [ ] **T2-GREEN (**clean-room**).** Modify `pre-work.md` Step 3.5 — add `--ff-only` flag to `git pull` command. Add HALT on non-fast-forward with actionable divergence report.
- [ ] **T2-GREEN-doublecheck (**clean-room**).** Verify `--ff-only` is present in pre-work submodule pull, HALT on divergence is present, divergence report includes actionable information.
- [ ] **T2-COMMIT (**inline**).** `git add .opencode/skills/git-workflow/tasks/pre-work.md && git commit -m "T2: pre-work submodule --ff-only enforcement"`

#### T3 — Cleanup main branch creation (SC-3)

- [ ] **T3-RED (**clean-room**).** Write behavioral enforcement test for SC-3 (cleanup submodule trunk restore creates `main` branch if missing). Test MUST FAIL.
- [ ] **T3-GREEN (**clean-room**).** Modify `branch-cleanup.md` Step 1.9 — add trunk branch creation step before submodule dev restore: verify `main` exists on submodule remote, create from default branch if missing. Modify `submodule-dev-restore.jsonc` — update description to include trunk branch creation.
- [ ] **T3-GREEN-doublecheck (**clean-room**).** Verify trunk branch creation is present in cleanup step, agent config description updated.
- [ ] **T3-COMMIT (**inline**).** `git add .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md .opencode/agents/submodule-dev-restore.jsonc && git commit -m "T3: cleanup submodule main branch creation"`

#### T4 — Cleanup `--ff-only` (SC-4)

- [ ] **T4-RED (**clean-room**).** Write behavioral enforcement test for SC-4 (cleanup submodule trunk restore uses `--ff-only` and HALTs on non-fast-forward). Test MUST FAIL.
- [ ] **T4-GREEN (**clean-room**).** Modify `branch-cleanup.md` Step 1.9 — add HALT on `--ff-only` failure with actionable divergence report.
- [ ] **T4-GREEN-doublecheck (**clean-room**).** Verify `--ff-only` HALT is present in cleanup step, divergence report includes actionable information.
- [ ] **T4-COMMIT (**inline**).** `git add .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md && git commit -m "T4: cleanup submodule --ff-only enforcement"`

#### T5 — Mid-feature sync `--ff-only` (SC-5)

- [ ] **T5-RED (**clean-room**).** Write behavioral enforcement test for SC-5 (mid-feature submodule sync uses `--ff-only` and reports divergence). Test MUST FAIL.
- [ ] **T5-GREEN (**clean-room**).** Modify `submodule-sync.md` — change `--ff-only` failure handling from "log and continue" to "report actionable divergence info and HALT". Add trunk branch creation step before checkout.
- [ ] **T5-GREEN-doublecheck (**clean-room**).** Verify mid-feature sync has trunk branch creation, `--ff-only`, HALT on divergence, and actionable divergence report.
- [ ] **T5-COMMIT (**inline**).** `git add .opencode/skills/git-workflow/tasks/submodule-sync.md && git commit -m "T5: mid-feature submodule --ff-only enforcement"`

#### T6 — Actionable divergence reporting (SC-6, depends on T1-T5)

- [ ] **T6-RED (**clean-room**).** Write behavioral enforcement test for SC-6 (all divergence/conflict situations report actionable information and HALT). Test MUST FAIL.
- [ ] **T6-GREEN (**clean-room**).** Modify `SKILL.md` — update sub-agent task descriptions for `submodule-tag-prework`, `submodule-dev-restore`, and `submodule-sync` to reflect new trunk branch creation and `--ff-only` enforcement behavior. Ensure all three lifecycle points have consistent divergence reporting format.
- [ ] **T6-GREEN-doublecheck (**clean-room**).** Verify SKILL.md descriptions are updated for all three sub-agents, divergence reporting format is consistent across all three lifecycle points.
- [ ] **T6-COMMIT (**inline**).** `git add .opencode/skills/git-workflow/SKILL.md && git commit -m "T6: actionable divergence reporting for all submodule sync points"`

---

### Verification Gates

- [ ] **VbC (**clean-room**).** Verify all 6 SCs have behavioral evidence: pre-work creates `main` branch (SC-1), pre-work uses `--ff-only` and HALTs (SC-2), cleanup creates `main` branch (SC-3), cleanup uses `--ff-only` and HALTs (SC-4), mid-feature uses `--ff-only` and reports divergence (SC-5), all divergence situations report actionable info and HALT (SC-6). Produce evidence artifacts for each SC.
- [ ] **Adversarial audit (**clean-room**).** Dispatch adversarial audit of all 6 SCs. Dual auditors from different model families. Consensus required for PASS.
- [ ] **Cross-validate (**clean-room**).** Cross-validate VbC evidence against adversarial audit findings. Resolve any discrepancies.
- [ ] **Regression check (**clean-room**).** Run full behavioral enforcement test suite to verify no regressions in existing tests.
- [ ] **Review-prep (**clean-room**).** Prepare PR body with Summary, Outcome, Fixes section. Generate compare URL. Verify base branch is `dev`.

---

## Exit Criteria

- [ ] C1: Pre-work submodule sync creates `main` branch from default branch if missing (SC-1)
- [ ] C2: Pre-work submodule sync uses `--ff-only` and HALTs on non-fast-forward (SC-2)
- [ ] C3: Cleanup submodule trunk restore creates `main` branch if missing (SC-3)
- [ ] C4: Cleanup submodule trunk restore uses `--ff-only` and HALTs on non-fast-forward (SC-4)
- [ ] C5: Mid-feature submodule sync uses `--ff-only` and reports divergence (SC-5)
- [ ] C6: All divergence/conflict situations report actionable information and HALT for developer consultation (SC-6)
- [ ] C7: All 6 affected files modified with correct changes
- [ ] C8: Behavioral enforcement tests exist for all 6 SCs and pass
- [ ] C9: All changes committed in 6 checkpoint commits (one per TDD item)
- [ ] C10: Adversarial audit clean — dual auditor consensus PASS
- [ ] C11: Cross-validate clean — VbC and audit findings agree
- [ ] C12: Regression check clean — no existing tests broken
- [ ] C13: Review-prep complete — PR body written, compare URL generated

> **⚠️ COMPLIANCE REMINDER:** All steps are mandatory. No step may be skipped, combined, or reordered. Each step is an atomic unit. Self-remediation on failure — never reclassify a FAIL. One step at a time — never read ahead.
