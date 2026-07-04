# Phase 5 — Global Verification Sweep

**Concern:** Verify zero `/skill` references remain anywhere in `.opencode/` and all SCs are satisfied.

**Files:** All files under `.opencode/`

**SCs:** SC-5

**Dependencies:** Phase 4 complete

**Entry:** All phases 1-4 complete and verified

**Exit:** SC-5 confirmed, all evidence artifacts collected

- [ ] 16. **Global sweep (**clean-room**).** Run `grep -rn '/skill ' .opencode/ --include='*.md' --include='*.yaml' --include='*.json' --include='*.yml'` across entire `.opencode/` directory. Confirm zero matches. Save result to `./tmp/1650/global-sweep.txt`. **→ SC-5**
- [ ] 17. **Collect evidence (**clean-room**).** Gather all evidence artifacts from `./tmp/1650/` into `./tmp/1650/artifacts/`. Include: baseline files, RED test files, sweep results, behavioral test output. **→ SC-5**
- [ ] 18. **Adversarial audit (**clean-room**).** Dispatch adversarial audit of all changes. Verify no `/skill` references remain, all replacements use correct `skill()` syntax, and behavioral test is valid. **→ SC-5**

#### Phase 5 VbC

- [ ] 19. **VbC (**clean-room**).** Verify: SC-1 (32 SKILL.md lines use `skill()`), SC-2 (7 task examples use `skill()`+`task()`), SC-3 (squash-push.md uses `skill()`), SC-4 (prose mention uses `skill()`), SC-5 (zero `/skill` in `.opencode/`), SC-6 (behavioral test passes). **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6**

**Concern transition:** Leaving implementation → entering completion. All phases depend on clean grep-verified replacements.
