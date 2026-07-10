# Phase 3 — Remove yaml+symbolic from reference files

**Concern:** Remove `yaml+symbolic` code-fenced blocks from 3 reference files.

**Files:** 3 reference files under `skills/*/reference/*.md` (full list discovered by `grep -rl '```yaml+symbolic' skills/*/reference/*.md`)

**SCs:** SC-3 (`string`), SC-10 (`semantic`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** Phase 2 complete

**Entry conditions:** Phase 2 checkpoint committed and tagged, working tree clean

**Exit conditions:** No `yaml+symbolic` blocks in any reference file, all orphan rules migrated to prose, content-loss verification PASS, behavioral regression PASS

---

- [ ] 21. **Pre-RED baseline (**clean-room**).** Run `grep -rl '```yaml+symbolic' skills/*/reference/*.md` to identify all 3 affected files. **→ SC-3**
- [ ] 22. **RED (**sub-agent**).** For each of the 3 reference files, read the file, extract the `yaml+symbolic` block, and identify orphan rules not in prose. **→ SC-10**
- [ ] 23. **GREEN (**sub-agent**).** For each of the 3 reference files, remove the `yaml+symbolic` block. Add missing prose for any orphan rules. **→ SC-3, SC-10**
- [ ] 24. **GREEN doublecheck (**inline**).** Run `grep -rl '```yaml+symbolic' skills/*/reference/*.md` — must return empty. **→ SC-3**
- [ ] 25. **Content-loss verification (**clean-room**).** Confirm every rule from removed blocks is present in prose. **→ SC-10**
- [ ] 26. **Behavioral regression test (**sub-agent**).** Run existing behavioral enforcement tests. All must PASS. **→ SC-11**
- [ ] 27. **SC-12 verification (**clean-room**).** Verify no SC was weakened, deferred, or reclassified. **→ SC-12**
- [ ] 28. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 3: Remove yaml+symbolic blocks from 3 reference files"`
- [ ] 29. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-3-opencode`
- [ ] 30. **VbC (**clean-room**).** Verify: no yaml+symbolic blocks remain in reference files (SC-3), all orphan rules migrated (SC-10), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-3, SC-10, SC-11, SC-12**

**Concern transition:** Leaving reference file removal → entering 000-critical-rules.md fix. Phase 4 depends on Phase 3's complete removal of yaml+symbolic blocks from reference files.
