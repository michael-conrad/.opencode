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

---

## Phase 1 — Submodule trunk branch creation and `--ff-only` enforcement

**Concern:** All three submodule lifecycle points (pre-work, mid-feature, cleanup) need trunk branch creation and `--ff-only` enforcement with HALT on divergence.

**Files:** All 6 affected files listed above.

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

**Dependencies:** None

**Entry conditions:** Spec approved, plan written

**Exit conditions:** All 6 files modified, all 6 SCs verified

### Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write behavioral enforcement test for SC-1 (pre-work creates `main` branch in submodules from default branch if missing). Test MUST FAIL at this point because the change doesn't exist yet. **→ SC-1**
- [ ] 2. **RED (**sub-agent**).** Write behavioral enforcement test for SC-2 (pre-work uses `--ff-only` for submodule trunk pull and HALTs on non-fast-forward). Test MUST FAIL. **→ SC-2**
- [ ] 3. **RED (**sub-agent**).** Write behavioral enforcement test for SC-3 (cleanup submodule trunk restore creates `main` branch if missing). Test MUST FAIL. **→ SC-3**
- [ ] 4. **RED (**sub-agent**).** Write behavioral enforcement test for SC-4 (cleanup submodule trunk restore uses `--ff-only` and HALTs on non-fast-forward). Test MUST FAIL. **→ SC-4**
- [ ] 5. **RED (**sub-agent**).** Write behavioral enforcement test for SC-5 (mid-feature submodule sync uses `--ff-only` and reports divergence). Test MUST FAIL. **→ SC-5**
- [ ] 6. **RED (**sub-agent**).** Write behavioral enforcement test for SC-6 (all divergence/conflict situations report actionable information and HALT). Test MUST FAIL. **→ SC-6**
- [ ] 7. **GREEN (**sub-agent**).** Modify `submodule-tag-prework.jsonc` — update description to include trunk branch creation and `--ff-only` enforcement. **→ SC-1, SC-2**
- [ ] 8. **GREEN (**sub-agent**).** Modify `submodule-dev-restore.jsonc` — update description to include trunk branch creation and `--ff-only` enforcement. **→ SC-3, SC-4**
- [ ] 9. **GREEN (**sub-agent**).** Modify `pre-work.md` Step 3.5 — add trunk branch creation step before submodule checkout: verify `main` exists on submodule remote, create from default branch if missing. Add `--ff-only` flag to `git pull` command. Add HALT on non-fast-forward with actionable divergence report. **→ SC-1, SC-2**
- [ ] 10. **GREEN (**sub-agent**).** Modify `branch-cleanup.md` Step 1.9 — add trunk branch creation step before submodule dev restore: verify `main` exists on submodule remote, create from default branch if missing. Add HALT on `--ff-only` failure with actionable divergence report. **→ SC-3, SC-4**
- [ ] 11. **GREEN (**sub-agent**).** Modify `submodule-sync.md` — change `--ff-only` failure handling from "log and continue" to "report actionable divergence info and HALT". Add trunk branch creation step before checkout. **→ SC-5, SC-6**
- [ ] 12. **GREEN (**sub-agent**).** Modify `SKILL.md` — update sub-agent task descriptions for `submodule-tag-prework`, `submodule-dev-restore`, and `submodule-sync` to reflect new trunk branch creation and `--ff-only` enforcement behavior. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 13. **GREEN doublecheck (**sub-agent**).** Verify all 6 files have correct changes — trunk branch creation present in all three lifecycle points, `--ff-only` present in all three, HALT on divergence present in all three. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 14. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow/tasks/pre-work.md .opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md .opencode/skills/git-workflow/tasks/submodule-sync.md .opencode/skills/git-workflow/SKILL.md .opencode/agents/submodule-tag-prework.jsonc .opencode/agents/submodule-dev-restore.jsonc && git commit -m "submodule: add trunk branch creation and --ff-only enforcement at all three lifecycle points"` **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**
- [ ] 15. **GREEN verify (**sub-agent**).** Run behavioral enforcement tests for SC-1 through SC-6. All MUST PASS now that the changes exist. **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

#### Phase 1 VbC

- [ ] 16. **VbC (**clean-room**).** Verify all 6 SCs have behavioral evidence: pre-work creates `main` branch (SC-1), pre-work uses `--ff-only` and HALTs (SC-2), cleanup creates `main` branch (SC-3), cleanup uses `--ff-only` and HALTs (SC-4), mid-feature uses `--ff-only` and reports divergence (SC-5), all divergence situations report actionable info and HALT (SC-6). **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

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
- [ ] C9: All changes committed in a single checkpoint commit
