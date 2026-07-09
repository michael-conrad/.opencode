# Phase 4 — Bidirectional finding

- **Concern:** 1 behavioral test for plan-spec mismatch detection triggering revision options (not silent correction)
- **Files:**
  - `.opencode/tests/behaviors/NEW-sc16-audit-bidirectional-finding.sh`
- **SCs:** SC-16
- **Dependencies:** Phase 1 (test infrastructure pattern)
- **Entry conditions:** Phase 3 complete, 15 test scripts exist
- **Exit conditions:** 1 bidirectional finding test script exists, passes individually

## Step-by-step

- [ ] 37. **RED: SC-16 bidirectional finding test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc16-audit-bidirectional-finding.sh`. Test verifies plan-spec mismatch detected during audit triggers revision prompt with options, not silent correction. Uses `behavior_run`. Annotate with `# SC-16:`. Verify FAILS. **→ SC-16**
- [ ] 38. **GREEN: SC-16 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-16**
- [ ] 39. **Checkpoint commit (**inline**).** `git add .opencode/tests/behaviors/NEW-sc16-audit-bidirectional-finding.sh && git commit -m "Phase 4: 1 bidirectional finding behavioral test (SC-16)"`. Create checkpoint tag `michael-conrad/checkpoint/1785/phase-4-opencode`. **→ SC-all**

#### Phase 4 VbC

- [ ] **VbC (**clean-room**).** Verify test script exists, is artifact-only, has `# SC-16:` annotation. Run test and confirm PASS. **→ SC-16**

**Concern transition:** Leaving bidirectional finding → entering structural changes. Phase 5 has no dependency on prior phases.
