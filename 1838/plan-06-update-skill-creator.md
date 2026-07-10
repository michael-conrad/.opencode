# Phase 6 — Update skill-creator skill

**Concern:** Remove yaml+symbolic block generation from skill-creator templates. Update documentation about what goes into a skill card.

**Files:** `skills/skill-creator/` (templates, task files, SKILL.md)

**SCs:** SC-7 (`string`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** Phase 5 complete

**Entry conditions:** Phase 5 checkpoint committed and tagged, working tree clean

**Exit conditions:** No yaml+symbolic generation in skill-creator templates, behavioral regression PASS

---

- [ ] 47. **RED (**sub-agent**).** Read `skills/skill-creator/` files. Identify all template files and code paths that generate `yaml+symbolic` blocks. Produce a dependency map. **→ SC-7**
- [ ] 48. **GREEN (**sub-agent**).** Remove yaml+symbolic block generation from all skill-creator templates. Update any documentation within the skill that references yaml+symbolic blocks. **→ SC-7**
- [ ] 49. **GREEN doublecheck (**inline**).** Run `grep -r 'yaml+symbolic' skills/skill-creator/` — must return empty. **→ SC-7**
- [ ] 50. **Behavioral regression test (**sub-agent**).** Run existing behavioral enforcement tests. All must PASS. **→ SC-11**
- [ ] 51. **SC-12 verification (**clean-room**).** Verify no SC was weakened, deferred, or reclassified. **→ SC-12**
- [ ] 52. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 6: Remove yaml+symbolic generation from skill-creator"`
- [ ] 53. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-6-opencode`
- [ ] 54. **VbC (**clean-room**).** Verify: no yaml+symbolic in skill-creator (SC-7), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-7, SC-11, SC-12**

**Concern transition:** Leaving skill-creator update → entering test-enforcement.sh update. Phase 7 depends on Phase 6's template changes.
