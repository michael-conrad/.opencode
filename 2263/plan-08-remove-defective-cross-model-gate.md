# Phase 8 — Remove defective cross-model gate (verify.md §4.5)

**Concern:** Remove the defective CROSS_MODEL_GAP cross-model validation requirement from `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5, replacing it with a single-model verification model consistent with the framework's DEFAULT_TEST_MODEL contract. Remove the false Spec #262 authority line.

**Files:**
- `.opencode/skills/verification-before-completion/tasks/verify.md`

**SCs:** SC-8

**Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4, Phase 5, Phase 6, Phase 7

**Entry Conditions:**
- Phases 1-7 complete: all context-economy phases done
- Phases 1-7 VbC passed

**Exit Conditions:**
- CROSS_MODEL_GAP cross-model validation requirement absent from `verify.md` §4.5
- Single-model verification consistent with the DEFAULT_TEST_MODEL contract present
- False Spec #262 authority line absent
- No residual multi-model/cloud cross-verification mandate

---

**Cost frame:** Verifying the §4.5 removal costs one grep of `verify.md` §4.5. Skipping means the defective CROSS_MODEL_GAP requirement survives, mandating an impossible two-model cloud run that contradicts the framework's single-model DEFAULT_TEST_MODEL contract and blocks legitimate verification.

- [ ] 39. **RED (**sub-agent**).** Write an enforcement test asserting the CROSS_MODEL_GAP cross-model validation requirement is present in `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5 (fails because the removal doesn't exist yet). **→ SC-8**
- [ ] 40. **GREEN (**sub-agent**).** Remove the CROSS_MODEL_GAP cross-model validation requirement from `.opencode/skills/verification-before-completion/tasks/verify.md` §4.5 and replace it with a single-model verification model consistent with the framework's DEFAULT_TEST_MODEL contract; remove the false Spec #262 authority line. **→ SC-8**
- [ ] 41. **GREEN doublecheck (**clean-room**).** Verify the CROSS_MODEL_GAP cross-model requirement is absent, single-model verification consistent with DEFAULT_TEST_MODEL is present, and the false Spec #262 authority line is gone. **→ SC-8**
- [ ] 42. **Checkpoint commit (**inline**).** Commit the §4.5 replacement and authority-line removal in `.opencode/skills/verification-before-completion/tasks/verify.md`. **→ SC-8**

#### Phase 8 VbC

- [ ] 43. **VbC (**clean-room**).** Verify `verify.md` §4.5 contains no CROSS_MODEL_GAP cross-model requirement, contains single-model verification consistent with the DEFAULT_TEST_MODEL contract, has no false Spec #262 authority line, and no residual multi-model/cloud cross-verification mandate remains. **→ SC-8**

**Concern transition:** Cross-model gate removal complete. All phases done — proceeding to global post-implementation steps (steps 44-51).
