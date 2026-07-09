# Phase 3 — Cross-validate behavior

- **Concern:** 2 behavioral tests for evidence type gate (rejects structural evidence for behavioral SCs) and frugal result contract (status/finding_summary/artifact_path only)
- **Files:**
  - `.opencode/tests/behaviors/NEW-sc14-audit-cross-validate-evidence-type-gate.sh`
  - `.opencode/tests/behaviors/NEW-sc15-audit-cross-validate-frugal-contract.sh`
- **SCs:** SC-14, SC-15
- **Dependencies:** Phase 1 (test infrastructure pattern)
- **Entry conditions:** Phase 2 complete, 13 test scripts exist
- **Exit conditions:** 2 cross-validate test scripts exist, each passes individually

## Step-by-step

- [ ] 32. **RED: SC-14 evidence type gate test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc14-audit-cross-validate-evidence-type-gate.sh`. Test verifies cross-validate rejects structural evidence for behavioral SCs with EVIDENCE_TYPE_MISMATCH. Uses `behavior_run`. Annotate with `# SC-14:`. Verify FAILS. **→ SC-14**
- [ ] 33. **GREEN: SC-14 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-14**
- [ ] 34. **RED: SC-15 frugal result contract test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc15-audit-cross-validate-frugal-contract.sh`. Test verifies cross-validate returns contract with only status/finding_summary/artifact_path — no full evidence. Uses `behavior_run`. Annotate with `# SC-15:`. Verify FAILS. **→ SC-15**
- [ ] 35. **GREEN: SC-15 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-15**
- [ ] 36. **Checkpoint commit (**inline**).** `git add .opencode/tests/behaviors/NEW-sc14-audit-cross-validate-evidence-type-gate.sh .opencode/tests/behaviors/NEW-sc15-audit-cross-validate-frugal-contract.sh && git commit -m "Phase 3: 2 cross-validate behavioral tests (SC-14, SC-15)"`. Create checkpoint tag `michael-conrad/checkpoint/1785/phase-3-opencode`. **→ SC-all**

#### Phase 3 VbC

- [ ] **VbC (**clean-room**).** Verify both test scripts exist, are artifact-only, have `# SC-N:` annotations. Run each test individually and confirm PASS. **→ SC-14, SC-15**

**Concern transition:** Leaving cross-validate behavior → entering bidirectional finding. Phase 4 depends on Phase 1 test infrastructure pattern.
