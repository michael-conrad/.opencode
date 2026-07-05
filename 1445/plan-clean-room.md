# Implementation Plan — [#1445](https://github.com/michael-conrad/.opencode/issues/1445) — git-workflow: submodule dev sync verification and conflict detection

**Goal:** Add `--ff-only` enforcement and trunk branch creation to all three submodule sync lifecycle points (pre-work, mid-feature sync, cleanup), plus add symbolic rules for submodule verification.

**Architecture:** Three task files and one SKILL.md are modified. Each task file's submodule sync section gets two additions: (1) verify `main` exists on submodule remote and create it from default branch if missing, (2) use `--ff-only` for trunk pull and HALT/report on non-fast-forward. The SKILL.md gets new symbolic rules for submodule verification.

**Files:**
- `.opencode/skills/git-workflow/tasks/pre-work.md` — Step 3.5 sub-agent dispatch: add `--ff-only` and trunk branch creation
- `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` — Step 1.9 submodule dev restore: add trunk branch creation
- `.opencode/skills/git-workflow/tasks/submodule-sync.md` — Step 2: add trunk branch creation (already has `--ff-only`)
- `.opencode/skills/git-workflow/SKILL.md` — add symbolic rules for submodule verification

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a formal implementation specification. Every step, gate, and verification assertion is mandatory. The orchestrator MUST execute every step in order. Skipping, reordering, or combining steps produces defective deliverables that MUST be discarded. "This step seems unnecessary" is NOT a valid reason to skip — the plan author designed each step for a reason. If a step appears redundant, execute it anyway; the cost of one extra verification is zero compared to the cost of a missed defect.

> **⚠️ ONE-STEP-AT-A-TIME PROTOCOL:** Execute exactly one step at a time. After each step, report status and wait for the orchestrator to confirm before proceeding. Do NOT batch steps, do NOT skip ahead, do NOT combine multiple steps into a single action. Each step is an atomic unit of work with its own verification.

> **⚠️ STEP STATUS:** After each step, report: `[PASS|FAIL|BLOCKED] Step N: <description> — <evidence summary>`. On FAIL or BLOCKED, HALT and report findings. Do NOT proceed past a failed step.

## Phase 1 — Submodule dev sync verification and conflict detection

| Step | Item | Concern | Files | SCs | Dependencies |
|------|------|---------|-------|-----|--------------|
| 1-6 | T1-T6 | Submodule dev sync verification and conflict detection | pre-work.md, branch-cleanup.md, submodule-sync.md, SKILL.md | SC-1 through SC-6 | T1-T5 independent; T6 depends on T1-T5 |

### Entry Criteria

- Spec #1445 approved (label `approved-for-pr` verified)
- Solve step completed with SAT and SOLVED status
- Feature branch exists for implementation

### Exit Conditions

- All 6 TDD items implemented and verified
- All 4 affected files modified
- All 6 success criteria verified PASS

---

- [ ] 1. **T1: Pre-work `--ff-only` enforcement (**sub-agent**).** Modify `pre-work.md` Step 3.5 sub-agent dispatch instructions to add `--ff-only` flag to the submodule trunk pull command. The sub-agent must use `git pull origin dev --ff-only` (replacing plain `git pull`). On non-fast-forward failure, the sub-agent must report divergence and return BLOCKED status for developer consultation. **→ SC-2**
  - [ ] 1.1. **RED (**sub-agent**).** Write behavioral enforcement test that sends a prompt triggering pre-work submodule sync and verifies the agent uses `--ff-only` for submodule trunk pull. Test MUST FAIL before change.
  - [ ] 1.2. **GREEN (**sub-agent**).** Edit `pre-work.md` Step 3.5: change `git pull` to `git pull origin dev --ff-only` in the sub-agent dispatch instructions. Add divergence handling: on `--ff-only` failure, sub-agent returns BLOCKED with divergence details.
  - [ ] 1.3. **GREEN doublecheck (**sub-agent**).** Verify the edit is correct: re-read `pre-work.md` Step 3.5, confirm `--ff-only` is present and divergence handling is documented.
  - [ ] 1.4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/pre-work.md && git commit -m "T1: pre-work submodule sync --ff-only enforcement"`

- [ ] 2. **T2: Pre-work trunk branch creation (**sub-agent**).** Modify `pre-work.md` Step 3.5 sub-agent dispatch instructions to add trunk branch creation. Before syncing submodules to dev tip, the sub-agent must verify `main` exists on the submodule remote (`git ls-remote --heads origin main`). If missing, create it from the default branch (`git checkout -b main <default-branch> && git push origin main`). **→ SC-1**
  - [ ] 2.1. **RED (**sub-agent**).** Write behavioral enforcement test that sends a prompt triggering pre-work submodule sync and verifies the agent creates `main` branch in submodules if missing. Test MUST FAIL before change.
  - [ ] 2.2. **GREEN (**sub-agent**).** Edit `pre-work.md` Step 3.5: add trunk branch creation step before the sync step. Sub-agent checks `git ls-remote --heads origin main`, creates `main` from default branch if absent, then proceeds with sync.
  - [ ] 2.3. **GREEN doublecheck (**sub-agent**).** Re-read `pre-work.md` Step 3.5, confirm trunk branch creation is present and correctly ordered before sync.
  - [ ] 2.4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/pre-work.md && git commit -m "T2: pre-work submodule trunk branch creation"`

- [ ] 3. **T3: Cleanup trunk branch creation (**sub-agent**).** Modify `branch-cleanup.md` Step 1.9 submodule dev restore instructions to add trunk branch creation. Before syncing submodule to dev tip, the sub-agent must verify `main` exists on the submodule remote. If missing, create it from the default branch. **→ SC-3**
  - [ ] 3.1. **RED (**sub-agent**).** Write behavioral enforcement test that verifies the agent creates `main` branch in submodules during cleanup submodule restore. Test MUST FAIL before change.
  - [ ] 3.2. **GREEN (**sub-agent**).** Edit `branch-cleanup.md` Step 1.9: add trunk branch creation step before the `git checkout dev && git pull origin dev --ff-only` step in the sub-agent dispatch instructions.
  - [ ] 3.3. **GREEN doublecheck (**sub-agent**).** Re-read `branch-cleanup.md` Step 1.9, confirm trunk branch creation is present and correctly ordered.
  - [ ] 3.4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md && git commit -m "T3: cleanup submodule trunk branch creation"`

- [ ] 4. **T4: Mid-feature submodule sync trunk branch creation (**sub-agent**).** Modify `submodule-sync.md` Step 2 to add trunk branch creation. Before syncing submodule to dev tip, the sub-agent must verify `main` exists on the submodule remote. If missing, create it from the default branch. (The `--ff-only` flag is already present in `submodule-sync.md`.) **→ SC-5**
  - [ ] 4.1. **RED (**sub-agent**).** Write behavioral enforcement test that verifies the agent creates `main` branch in submodules during mid-feature submodule sync. Test MUST FAIL before change.
  - [ ] 4.2. **GREEN (**sub-agent**).** Edit `submodule-sync.md` Step 2: add trunk branch creation before the `git checkout dev && git pull origin dev --ff-only` step.
  - [ ] 4.3. **GREEN doublecheck (**sub-agent**).** Re-read `submodule-sync.md`, confirm trunk branch creation is present and `--ff-only` is already present.
  - [ ] 4.4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/submodule-sync.md && git commit -m "T4: mid-feature submodule trunk branch creation"`

- [ ] 5. **T5: Symbolic rules for submodule verification (**sub-agent**).** Add new symbolic rules to `git-workflow/SKILL.md` for submodule verification: (a) pre-work submodule sync MUST use `--ff-only`, (b) cleanup submodule restore MUST use `--ff-only`, (c) all three lifecycle points MUST create `main` branch if missing, (d) divergence/conflict MUST HALT with actionable report. **→ SC-6**
  - [ ] 5.1. **RED (**sub-agent**).** Write behavioral enforcement test that verifies the agent enforces submodule verification rules. Test MUST FAIL before change.
  - [ ] 5.2. **GREEN (**sub-agent**).** Edit `git-workflow/SKILL.md`: add symbolic rules for submodule `--ff-only` enforcement, trunk branch creation, and divergence HALT requirements.
  - [ ] 5.3. **GREEN doublecheck (**sub-agent**).** Re-read `git-workflow/SKILL.md`, confirm new symbolic rules are present and syntactically valid.
  - [ ] 5.4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/SKILL.md && git commit -m "T5: submodule verification symbolic rules"`

- [ ] 6. **T6: Cleanup `--ff-only` enforcement (**sub-agent**).** Modify `branch-cleanup.md` Step 1.9 to add explicit `--ff-only` enforcement documentation. The sub-agent dispatch instructions already use `git pull origin dev --ff-only` (verified in spec). Add divergence handling: on `--ff-only` failure, sub-agent returns BLOCKED with divergence details. **→ SC-4**
  - [ ] 6.1. **RED (**sub-agent**).** Write behavioral enforcement test that verifies the agent uses `--ff-only` for cleanup submodule restore and HALTs on non-fast-forward. Test MUST FAIL before change.
  - [ ] 6.2. **GREEN (**sub-agent**).** Edit `branch-cleanup.md` Step 1.9: add explicit divergence handling documentation for `--ff-only` failure. Sub-agent returns BLOCKED with divergence details on non-fast-forward.
  - [ ] 6.3. **GREEN doublecheck (**sub-agent**).** Re-read `branch-cleanup.md` Step 1.9, confirm `--ff-only` is present and divergence handling is documented.
  - [ ] 6.4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md && git commit -m "T6: cleanup submodule --ff-only enforcement"`

### Phase 1 VbC

- [ ] 7. **VbC (**clean-room**).** Verify all 6 success criteria against the modified files. Read each affected file and confirm: SC-1 (pre-work creates `main` in submodules), SC-2 (pre-work uses `--ff-only`), SC-3 (cleanup creates `main`), SC-4 (cleanup uses `--ff-only`), SC-5 (mid-feature sync creates `main`), SC-6 (all divergence situations report actionable info and HALT). **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

### Concern Transition

**Concern transition:** Leaving submodule dev sync verification and conflict detection → entering post-implementation verification. No further phases — single-phase plan complete.

---

> **⚠️ COMPLIANCE REQUIREMENT:** This plan is a formal implementation specification. Every step, gate, and verification assertion is mandatory. The orchestrator MUST execute every step in order. Skipping, reordering, or combining steps produces defective deliverables that MUST be discarded. "This step seems unnecessary" is NOT a valid reason to skip — the plan author designed each step for a reason. If a step appears redundant, execute it anyway; the cost of one extra verification is zero compared to the cost of a missed defect.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If any step fails verification, the orchestrator MUST NOT proceed. Diagnose the root cause, remediate, re-verify, and only proceed on confirmed PASS. If remediation fails twice, report double-failure and HALT. Do NOT reclassify FAIL as PASS, do NOT soft-pass with caveats, do NOT mark INCONCLUSIVE and proceed.

## Exit Criteria

- [ ] C1: All 4 affected files modified with correct changes
- [ ] C2: All 6 TDD items implemented (T1-T6)
- [ ] C3: All 6 success criteria verified PASS (SC-1 through SC-6)
- [ ] C4: Behavioral enforcement tests exist and pass for all 6 items
- [ ] C5: All checkpoint commits created with correct messages
- [ ] C6: Phase 1 VbC completed with PASS verdict
