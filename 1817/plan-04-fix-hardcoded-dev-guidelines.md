# Phase 4 — Fix Hardcoded `dev` in Guidelines

**Concern:** Replace all remaining hardcoded `dev` branch references in five guideline files.

**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/guidelines/060-tool-usage.md`
- `.opencode/guidelines/116-pair-mode.md`

**SCs:** SC-8

**Dependencies:** None

**Entry conditions:** Phase 3 complete

**Exit conditions:** All five guideline files have zero `dev` branch references

---

- [ ] 34. **RED (**sub-agent**).** Write a grep-based enforcement test that scans the five guideline files for `dev` branch references (excluding `dev.name`, `dev.email`, `dev-pair`, `/dev/null`). The test MUST FAIL because all five files still contain `dev` references. **→ SC-8**
- [ ] 35. **GREEN (**sub-agent**).** Edit `.opencode/guidelines/000-critical-rules.md`: fix compare URL pattern (`compare/dev...<branch>` → `compare/$DEFAULT_BRANCH...<branch>`), "syncs dev" → "syncs trunk", "dev/main" references → trunk terminology. **→ SC-8**
- [ ] 36. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/guidelines/000-critical-rules.md` — confirm zero branch-name `dev` references. **→ SC-8**
- [ ] 37. **Checkpoint commit (**inline**).** Commit with message: `Phase 4a: fix hardcoded dev in 000-critical-rules.md`
- [ ] 38. **GREEN (**sub-agent**).** Edit `.opencode/guidelines/010-approval-gate.md`: fix "Feature PR targets dev" → "Feature PR targets trunk", "committing to dev or main" → "committing to trunk". **→ SC-8**
- [ ] 39. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/guidelines/010-approval-gate.md` — confirm zero branch-name `dev` references. **→ SC-8**
- [ ] 40. **Checkpoint commit (**inline**).** Commit with message: `Phase 4b: fix hardcoded dev in 010-approval-gate.md`
- [ ] 41. **GREEN (**sub-agent**).** Edit `.opencode/guidelines/020-go-prohibitions.md`: fix "merge into dev" example, "commits to dev or main" → "commits to trunk", submodule prose references. **→ SC-8**
- [ ] 42. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/guidelines/020-go-prohibitions.md` — confirm zero branch-name `dev` references. **→ SC-8**
- [ ] 43. **Checkpoint commit (**inline**).** Commit with message: `Phase 4c: fix hardcoded dev in 020-go-prohibitions.md`
- [ ] 44. **GREEN (**sub-agent**).** Edit `.opencode/guidelines/060-tool-usage.md`: fix "committed directly to dev or main" table → "committed directly to trunk". **→ SC-8**
- [ ] 45. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/guidelines/060-tool-usage.md` — confirm zero branch-name `dev` references. **→ SC-8**
- [ ] 46. **Checkpoint commit (**inline**).** Commit with message: `Phase 4d: fix hardcoded dev in 060-tool-usage.md`
- [ ] 47. **GREEN (**sub-agent**).** Edit `.opencode/guidelines/116-pair-mode.md`: fix "protected branch (dev or main)" → "protected branch (trunk)". **→ SC-8**
- [ ] 48. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/guidelines/116-pair-mode.md` — confirm zero branch-name `dev` references. **→ SC-8**
- [ ] 49. **Checkpoint commit (**inline**).** Commit with message: `Phase 4e: fix hardcoded dev in 116-pair-mode.md`

#### Phase 4 VbC

- [ ] 50. **VbC (**clean-room**).** Verify: all five guideline files have zero `dev` branch references, grep sweep passes, enforcement test passes. **→ SC-8**

**Concern transition:** Leaving guideline cleanup → entering skill task prose/command mismatch fixes. Phase 5 depends on Phase 4 being complete (no dependency — independent concerns).
