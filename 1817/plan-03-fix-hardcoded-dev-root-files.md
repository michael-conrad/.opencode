# Phase 3 — Fix Hardcoded `dev` in Root Files

**Concern:** Replace all remaining hardcoded `dev` branch references in `.opencode/AGENTS.md`, `.opencode/README.md`, `.opencode/.guidelines/branch-first-protocol.md`, `.opencode/commands/submodule-tag-prework.md`.

**Files:**
- `.opencode/AGENTS.md`
- `.opencode/README.md`
- `.opencode/.guidelines/branch-first-protocol.md`
- `.opencode/commands/submodule-tag-prework.md`

**SCs:** SC-9, SC-12, SC-13, SC-14

**Dependencies:** None

**Entry conditions:** Phase 2 complete

**Exit conditions:** All four root files use `$DEFAULT_BRANCH` instead of `dev`

---

- [ ] 20. **RED (**sub-agent**).** Write a grep-based enforcement test that scans the four root files for `dev` branch references (excluding `dev.name`, `dev.email`, `dev-pair`, `/dev/null`). The test MUST FAIL because all four files still contain `dev` references. **→ SC-9**
- [ ] 21. **GREEN (**sub-agent**).** Edit `.opencode/AGENTS.md`: replace submodule tracking `dev` references with `$DEFAULT_BRANCH`. Replace dev parking commands (`git checkout dev && git pull && git submodule foreach "git checkout dev && git pull"`) with trunk equivalents. **→ SC-9, SC-12**
- [ ] 22. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/AGENTS.md` — confirm zero branch-name `dev` references (exclude `dev.name`, `dev.email`, `dev-pair`, `/dev/null`). **→ SC-12**
- [ ] 23. **Checkpoint commit (**inline**).** Commit with message: `Phase 3a: fix hardcoded dev in AGENTS.md`
- [ ] 24. **GREEN (**sub-agent**).** Edit `.opencode/README.md`: replace `git checkout dev` with `git checkout $DEFAULT_BRANCH`. **→ SC-9**
- [ ] 25. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/README.md` — confirm zero branch-name `dev` references. **→ SC-9**
- [ ] 26. **Checkpoint commit (**inline**).** Commit with message: `Phase 3b: fix hardcoded dev in README.md`
- [ ] 27. **GREEN (**sub-agent**).** Edit `.opencode/.guidelines/branch-first-protocol.md`: replace all `dev` with `$DEFAULT_BRANCH` in commands and prose. **→ SC-9, SC-13**
- [ ] 28. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/.guidelines/branch-first-protocol.md` — confirm zero branch-name `dev` references. **→ SC-13**
- [ ] 29. **Checkpoint commit (**inline**).** Commit with message: `Phase 3c: fix hardcoded dev in branch-first-protocol.md`
- [ ] 30. **GREEN (**sub-agent**).** Edit `.opencode/commands/submodule-tag-prework.md`: replace all `dev` with `$DEFAULT_BRANCH` in commands and prose. **→ SC-9, SC-14**
- [ ] 31. **GREEN doublecheck (**inline**).** Run `grep -n '\bdev\b' .opencode/commands/submodule-tag-prework.md` — confirm zero branch-name `dev` references. **→ SC-14**
- [ ] 32. **Checkpoint commit (**inline**).** Commit with message: `Phase 3d: fix hardcoded dev in submodule-tag-prework.md`

#### Phase 3 VbC

- [ ] 33. **VbC (**clean-room**).** Verify: all four root files have zero `dev` branch references, grep sweep passes, enforcement test passes. **→ SC-9, SC-12, SC-13, SC-14**

**Concern transition:** Leaving root file cleanup → entering guideline file cleanup. Phase 4 depends on Phase 3 being complete (no dependency — independent concerns).
