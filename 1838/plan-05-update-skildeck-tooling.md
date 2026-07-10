# Phase 5 — Update skildeck tooling

**Concern:** Update `skildeck` CLI tools (lint, validate, extract) to not require yaml+symbolic blocks. Update `skill-registry-v2-*.json` extraction to work from prose only, or remove the registry if unused.

**Files:** `tools/skildeck/` (lint, validate, extract scripts), `tools/skildeck/skill-registry-v2-*.json`

**SCs:** SC-5 (`behavioral`), SC-6 (`behavioral`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** Phase 4 complete

**Entry conditions:** Phase 4 checkpoint committed and tagged, working tree clean

**Exit conditions:** `skildeck lint` and `validate` pass on files without yaml+symbolic blocks, `skildeck extract` produces valid output from prose-only files, behavioral regression PASS

---

- [ ] 39. **RED (**sub-agent**).** Read `tools/skildeck/` source files. Identify all code paths that require or expect yaml+symbolic blocks. Produce a dependency map of what needs to change. **→ SC-5, SC-6**
- [ ] 40. **GREEN (**sub-agent**).** Update `skildeck lint` and `skildeck validate` to not fail on files without yaml+symbolic blocks. Update `skildeck extract` to handle absence of blocks gracefully (produce empty or prose-based output). Update or remove `skill-registry-v2-*.json` extraction. **→ SC-5, SC-6**
- [ ] 41. **GREEN doublecheck (**sub-agent**).** Run `skildeck lint` and `skildeck validate` on a file with blocks removed — must return PASS. Run `skildeck extract` on a prose-only file — must produce output without error. **→ SC-5, SC-6**
- [ ] 42. **Behavioral regression test (**sub-agent**).** Run existing behavioral enforcement tests. All must PASS. **→ SC-11**
- [ ] 43. **SC-12 verification (**clean-room**).** Verify no SC was weakened, deferred, or reclassified. **→ SC-12**
- [ ] 44. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 5: Update skildeck tooling to not require yaml+symbolic blocks"`
- [ ] 45. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-5-opencode`
- [ ] 46. **VbC (**clean-room**).** Verify: skildeck lint/validate pass without yaml+symbolic (SC-5), extract works on prose-only (SC-6), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-5, SC-6, SC-11, SC-12**

**Concern transition:** Leaving skildeck tooling update → entering skill-creator update. Phase 6 depends on Phase 5's tooling changes.
