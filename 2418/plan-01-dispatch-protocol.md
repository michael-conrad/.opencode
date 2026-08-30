# Phase 1 — DISPATCH_PROTOCOL

**Concern:** Replace `concat()` dispatch prompt with `pr_merged_event: true` flag, remove `pr_merge_status` and `branch_name` from Workflows context.

**Files:**
- `.opencode/skills/git-workflow-cleanup/SKILL.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2418 is approved
- Feature branch exists
- `.opencode/skills/git-workflow-cleanup/SKILL.md` exists and is readable

**Exit Conditions:**
- SKILL.md dispatch prompt uses `pr_merged_event: true` instead of `concat()` with pre-resolved values
- Workflows context does NOT include `pr_merge_status` or `branch_name`

---

**Cost frame:** This phase modifies a single file (SKILL.md) with a targeted structural change — replacing a `concat()` call with a boolean flag and removing two context fields. The change is contained within one file and has no external dependencies. One sub-agent dispatch per daisy-chain step is sufficient; the RED/GREEN/verify/commit cycle costs ~4 tool calls and is the minimum viable sequence for a structural change verified by grep.

- [ ] 1. **Pre-regression (**sub-agent**).** Run regression test patterns before RED phase. **→ SC-1**
- [ ] 2. **Pre-regression verify (**clean-room**).** Verify pre-regression results. **→ SC-1**

- [ ] 3. **RED (**sub-agent**).** Write a failing enforcement test asserting SKILL.md dispatch prompt uses `pr_merged_event: true` instead of `concat()`. **→ SC-1**
- [ ] 4. **GREEN (**sub-agent**).** Replace `concat()` dispatch prompt with `pr_merged_event: true` flag in SKILL.md. Remove `pr_merge_status` and `branch_name` from Workflows context. **→ SC-1**
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ SC-1**
- [ ] 6. **Verify (**clean-room**).** Verify implementation against SC-1: grep dispatch prompt for `pr_merged_event` in SKILL.md. **→ SC-1**
- [ ] 7. **Commit (**inline**).** `git add .opencode/skills/git-workflow-cleanup/SKILL.md && git commit -m "Phase 1: replace concat() dispatch with pr_merged_event flag"`. **→ SC-1**

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify SC-1: grep SKILL.md for `pr_merged_event` — must find the flag. Verify `pr_merge_status` and `branch_name` are absent from Workflows context. **→ SC-1**

**Concern transition:** Leaving dispatch protocol change → entering orchestrator guard addition. Phase 2 depends on Phase 1's dispatch prompt change (the behavioral test relies on the new prompt format).
