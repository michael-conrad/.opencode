# Phase 4 — Update 000-critical-rules.md misleading claim

**Concern:** Fix the misleading claim on line 12 of `000-critical-rules.md` that says "The symbolic rules block below contains machine-parseable rule definitions for all violations." No such machine-parseable block exists.

**Files:** `guidelines/000-critical-rules.md`

**SCs:** SC-4 (`string`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** Phase 3 complete

**Entry conditions:** Phase 3 checkpoint committed and tagged, working tree clean

**Exit conditions:** Line 12 no longer contains the misleading claim, behavioral regression PASS

---

- [ ] 31. **RED (**inline**).** Read `guidelines/000-critical-rules.md` line 12. Confirm the misleading claim exists: `grep 'machine-parseable rule definitions' guidelines/000-critical-rules.md` must return a match. **→ SC-4**
- [ ] 32. **GREEN (**inline**).** Edit line 12 of `guidelines/000-critical-rules.md` to remove the misleading claim. Replace with accurate description of the file's content (e.g., "This file provides critical rules organized into three tiers."). **→ SC-4**
- [ ] 33. **GREEN doublecheck (**inline**).** Run `grep 'machine-parseable rule definitions' guidelines/000-critical-rules.md` — must return empty. **→ SC-4**
- [ ] 34. **Behavioral regression test (**sub-agent**).** Run existing behavioral enforcement tests. All must PASS. **→ SC-11**
- [ ] 35. **SC-12 verification (**clean-room**).** Verify no SC was weakened, deferred, or reclassified. **→ SC-12**
- [ ] 36. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 4: Fix misleading claim in 000-critical-rules.md"`
- [ ] 37. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-4-opencode`
- [ ] 38. **VbC (**clean-room**).** Verify: misleading claim removed (SC-4), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-4, SC-11, SC-12**

**Concern transition:** Leaving 000-critical-rules.md fix → entering skildeck tooling update. Phase 5 depends on Phase 4's fix to the misleading claim.
