# Phase 8 — Update documentation

**Concern:** Update any guidelines or docs that reference yaml+symbolic blocks as required. Update `skill-card-change-types.md` reference document.

**Files:** `guidelines/` (all .md files), `skills/*/reference/skill-card-change-types.md`

**SCs:** SC-9 (`string`), SC-11 (`behavioral`), SC-12 (`behavioral`)

**Dependencies:** Phase 7 complete

**Entry conditions:** Phase 7 checkpoint committed and tagged, working tree clean

**Exit conditions:** No documentation references yaml+symbolic blocks as required, behavioral regression PASS

---

- [ ] 63. **RED (**sub-agent**).** Run `grep -r 'yaml+symbolic' guidelines/` to identify all documentation references. Categorize each as: (a) required reference that must be removed, (b) historical reference that should be preserved, (c) expected reference (e.g., in this spec). **→ SC-9**
- [ ] 64. **GREEN (**sub-agent**).** For each category (a) reference, update the documentation to remove or rewrite the yaml+symbolic reference. For `skill-card-change-types.md`, update to reflect that yaml+symbolic blocks are no longer part of skill cards. **→ SC-9**
- [ ] 65. **GREEN doublecheck (**inline**).** Run `grep -r 'yaml+symbolic' guidelines/` — verify only expected references remain (spec references, historical notes). **→ SC-9**
- [ ] 66. **Behavioral regression test (**sub-agent**).** Run all behavioral enforcement tests. All must PASS. **→ SC-11**
- [ ] 67. **SC-12 verification (**clean-room**).** Verify no SC was weakened, deferred, or reclassified. **→ SC-12**
- [ ] 68. **Checkpoint commit (**inline**).** `git add -A && git commit -m "Phase 8: Update documentation references to yaml+symbolic blocks"`
- [ ] 69. **Checkpoint tag (**inline**).** `git tag feature/1838-remove-yaml-symbolic-blocks/checkpoint/1838/phase-8-opencode`
- [ ] 70. **VbC (**clean-room**).** Verify: no required yaml+symbolic references remain in docs (SC-9), behavioral tests pass (SC-11), no SC weakened (SC-12). **→ SC-9, SC-11, SC-12**

**Concern transition:** Leaving documentation update → entering global post-steps. All 8 phases complete.
