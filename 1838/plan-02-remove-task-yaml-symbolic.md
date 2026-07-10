# Phase 2 — Remove yaml+symbolic from task files

**Concern:** Remove `yaml+symbolic` code-fenced blocks from all 16 task files. Handle the 8 audit task files with duplicate `next_step`/`all_criteria_pass` boilerplate — these are the same rules repeated 8 times.

**Files:** 16 `skills/*/tasks/*.md` files (full list discovered by `grep -rl '```yaml+symbolic' skills/*/tasks/*.md`)

**SCs:** SC-2 (`string`), SC-10 (`semantic`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** Phase 1 complete

**Entry conditions:** Phase 1 checkpoint committed and tagged, working tree clean

**Exit conditions:** No `yaml+symbolic` blocks in any task file, all orphan rules migrated to prose, content-loss verification PASS, behavioral regression PASS

---

- [ ] 11. **Pre-RED baseline (**clean-room**).** Run `grep -rl '```yaml+symbolic' skills/*/tasks/*.md` to identify all 16 affected files. Count and record the list. **→ SC-2**
- [ ] 12. **RED (**sub-agent**).** For each of the 16 task files, dispatch a sub-agent to read the file, extract the `yaml+symbolic` block content, and identify which rules are NOT already stated in the file's prose body. For the 8 audit task files with duplicate boilerplate, produce a single consolidated migration note. **→ SC-10**
- [ ] 13. **GREEN (**sub-agent**).** For each of the 16 task files, remove the `yaml+symbolic` code-fenced block. For any orphan rule identified in Step 12, add the missing prose. For the 8 audit task files, add the consolidated `next_step`/`all_criteria_pass` prose to each file. **→ SC-2, SC-10**
- [ ] 14. **GREEN doublecheck (**inline**).** Run `grep -rl '```yaml+symbolic' skills/*/tasks/*.md` — must return empty. **→ SC-2**
- [ ] 15. **Content-loss verification (**clean-room**).** For each of the 16 files, dispatch a clean-room sub-agent with the original yaml+symbolic block content and the modified file. Confirm every rule is present in prose. **→ SC-10**
- [ ] 16. **Behavioral regression test (**sub-agent**).** Run existing behavioral enforcement tests. All must PASS. **→ SC-11**
- [ ] 17. **SC-12 verification (**clean-room**).** Verify no SC was weakened, deferred, or reclassified. **→ SC-12**
- [ ] 18. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 2: Remove yaml+symbolic blocks from 16 task files"`
- [ ] 19. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-2-opencode`
- [ ] 20. **VbC (**clean-room**).** Verify: no yaml+symbolic blocks remain in task files (SC-2), all orphan rules migrated (SC-10), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-2, SC-10, SC-11, SC-12**

**Concern transition:** Leaving task file removal → entering reference file removal. Phase 3 depends on Phase 2's complete removal of yaml+symbolic blocks from task files.
