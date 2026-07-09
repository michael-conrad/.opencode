# Phase 6 — Auto-invocation

- **Concern:** 1 behavioral test verifying audit invocations fire automatically as part of consuming skill's Operating Protocol — no developer needs to explicitly request `audit #NNN`
- **Files:**
  - `.opencode/tests/behaviors/NEW-sc19-audit-auto-invocation.sh`
- **SCs:** SC-19
- **Dependencies:** Phase 1 (test infrastructure pattern)
- **Entry conditions:** Phase 5 complete, all structural changes applied
- **Exit conditions:** 1 auto-invocation test script exists, passes individually

## Step-by-step

- [ ] 50. **RED: SC-19 auto-invocation test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc19-audit-auto-invocation.sh`. Test verifies audit fires without explicit user request for audit — the consuming skill's Operating Protocol triggers it automatically. Uses `behavior_run`. Annotate with `# SC-19:`. Verify FAILS. **→ SC-19**
- [ ] 51. **GREEN: SC-19 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-19**
- [ ] 52. **Checkpoint commit (**inline**).** `git add .opencode/tests/behaviors/NEW-sc19-audit-auto-invocation.sh && git commit -m "Phase 6: 1 auto-invocation behavioral test (SC-19)"`. Create checkpoint tag `michael-conrad/checkpoint/1785/phase-6-opencode`. **→ SC-all**

#### Phase 6 VbC

- [ ] **VbC (**clean-room**).** Verify test script exists, is artifact-only, has `# SC-19:` annotation. Run test and confirm PASS. **→ SC-19**

**Concern transition:** All 6 phases complete. Proceed to global post-steps.
