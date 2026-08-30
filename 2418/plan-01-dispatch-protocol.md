# Phase 1 — DISPATCH_PROTOCOL

**Concern:** Replace `concat()` dispatch prompt with `pr_merged_event: true` flag in SKILL.md.

**Files:**
- `.opencode/skills/git-workflow-cleanup/SKILL.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2418 is approved
- Feature branch exists

**Exit Conditions:**
- SKILL.md dispatch prompt uses `pr_merged_event: true` instead of `concat()` with pre-resolved `pr_merge_status`/`branch_name`
- `pr_merge_status` and `branch_name` are removed from Workflows context

---

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting that SKILL.md dispatch prompt does NOT contain `concat()` with `pr_merge_status` or `branch_name`. Test must fail initially because the old pattern is still present. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Replace `concat()` dispatch prompt in SKILL.md with `pr_merged_event: true` flag. Remove `pr_merge_status` and `branch_name` from Workflows context. **→ SC-1**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify the RED test now passes with the change. **→ SC-1**
- [ ] 4. **Checkpoint commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/SKILL.md && git commit -m "Phase 1: replace concat() dispatch with pr_merged_event flag"`

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Verify SC-1: grep SKILL.md for `pr_merged_event` — confirm present; grep for `concat` with `pr_merge_status`/`branch_name` — confirm absent. **→ SC-1**

**Concern transition:** Dispatch protocol fixed → entering orchestrator guard phase. Phase 2 depends on Phase 1's SKILL.md change being committed so the behavioral test can verify the new behavior.
