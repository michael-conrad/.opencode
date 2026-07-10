# Phase 1 — Remove yaml+symbolic from SKILL.md files

**Concern:** Remove `yaml+symbolic` code-fenced blocks from all 35 SKILL.md files. For any rule in a removed block that is NOT already stated in the file's prose body, add appropriate prose. Verify no content loss.

**Files:** 35 `skills/*/SKILL.md` files (full list discovered by `grep -rl '```yaml+symbolic' skills/*/SKILL.md`)

**SCs:** SC-1 (`string`), SC-10 (`semantic`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** None

**Entry conditions:** Feature branch `feature/1838-remove-yaml-symbolic-blocks` checked out, working tree clean

**Exit conditions:** No `yaml+symbolic` blocks in any SKILL.md file, all orphan rules migrated to prose, content-loss verification PASS, behavioral regression PASS

---

- [ ] 1. **Pre-RED baseline (**clean-room**).** Run `grep -rl '```yaml+symbolic' skills/*/SKILL.md` to identify all 35 affected files. Count and record the list. **→ SC-1**
- [ ] 2. **RED (**sub-agent**).** For each of the 35 SKILL.md files, dispatch a sub-agent to read the file, extract the `yaml+symbolic` block content, and identify which rules in the block are NOT already stated in the file's prose body. Produce a migration map: `{file_path: {orphan_rules: [list], prose_additions: [list]}}`. **→ SC-10**
- [ ] 3. **GREEN (**sub-agent**).** For each of the 35 SKILL.md files, remove the `yaml+symbolic` code-fenced block (from opening ````yaml+symbolic` to closing ````). For any orphan rule identified in Step 2, add the missing prose to the file's body. **→ SC-1, SC-10**
- [ ] 4. **GREEN doublecheck (**inline**).** Run `grep -rl '```yaml+symbolic' skills/*/SKILL.md` — must return empty. **→ SC-1**
- [ ] 5. **Content-loss verification (**clean-room**).** For each of the 35 files, dispatch a clean-room sub-agent with the original yaml+symbolic block content and the modified file. The sub-agent confirms every rule from the block is present in the file's prose body. Produce PASS/FAIL per file. **→ SC-10**
- [ ] 6. **Behavioral regression test (**sub-agent**).** Run existing behavioral enforcement tests via `bash .opencode/tests/with-test-home opencode-cli run` for scenarios that test skill-related behavior. Use `--tag` or `--changed` scope. All must PASS. **→ SC-11**
- [ ] 7. **SC-12 verification (**clean-room**).** Dispatch clean-room sub-agent to inspect the implementation and verify no SC was weakened, deferred, or reclassified to a lower evidence type. **→ SC-12**
- [ ] 8. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 1: Remove yaml+symbolic blocks from 35 SKILL.md files"`
- [ ] 9. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-1-opencode`
- [ ] 10. **VbC (**clean-room**).** Verify: no yaml+symbolic blocks remain in SKILL.md files (SC-1), all orphan rules migrated (SC-10), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-1, SC-10, SC-11, SC-12**

**Concern transition:** Leaving SKILL.md file removal → entering task file removal. Phase 2 depends on Phase 1's complete removal of yaml+symbolic blocks from SKILL.md files.
