# Phase 2 — Pipeline touchpoints

- **Concern:** 7 behavioral tests verifying each consuming skill dispatches the correct audit task at the correct pipeline touchpoint
- **Files:**
  - `.opencode/tests/behaviors/NEW-sc7-audit-touchpoint-spec-creation.sh`
  - `.opencode/tests/behaviors/NEW-sc8-audit-touchpoint-writing-plans.sh`
  - `.opencode/tests/behaviors/NEW-sc9-audit-touchpoint-issue-operations.sh`
  - `.opencode/tests/behaviors/NEW-sc10-audit-touchpoint-implementation-pipeline.sh`
  - `.opencode/tests/behaviors/NEW-sc11-audit-touchpoint-verification-before-completion.sh`
  - `.opencode/tests/behaviors/NEW-sc12-audit-touchpoint-pr-creation.sh`
  - `.opencode/tests/behaviors/NEW-sc13-audit-touchpoint-git-workflow.sh`
- **SCs:** SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13
- **Dependencies:** Phase 1 (test infrastructure pattern established)
- **Entry conditions:** Phase 1 complete, 6 core dispatch tests exist
- **Exit conditions:** 7 touchpoint test scripts exist, each passes individually

## Step-by-step

- [ ] 17. **RED: SC-7 spec-creation touchpoint test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc7-audit-touchpoint-spec-creation.sh`. Test sends prompt triggering spec-creation pipeline and verifies `audit --task spec-audit` with `audit_phase: spec_creation` fires. Scoped to trigger only the spec-creation touchpoint. Uses `behavior_run`. Annotate with `# SC-7:`. Verify FAILS. **→ SC-7**
- [ ] 18. **GREEN: SC-7 implementation (**sub-agent**).** No code change needed — SC-7 tests existing behavior. Verify PASSES. **→ SC-7**
- [ ] 19. **RED: SC-8 writing-plans touchpoint test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc8-audit-touchpoint-writing-plans.sh`. Test verifies writing-plans pipeline dispatches `audit --task plan-fidelity` and `audit --task concern-separation` with `audit_phase: plan_creation`. Uses `behavior_run`. Annotate with `# SC-8:`. Verify FAILS. **→ SC-8**
- [ ] 20. **GREEN: SC-8 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-8**
- [ ] 21. **RED: SC-9 issue-operations touchpoint test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc9-audit-touchpoint-issue-operations.sh`. Test verifies issue-operations dispatches `audit --task concern-separation` with `audit_phase: sub_issue_creation`. Uses `behavior_run`. Annotate with `# SC-9:`. Verify FAILS. **→ SC-9**
- [ ] 22. **GREEN: SC-9 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-9**
- [ ] 23. **RED: SC-10 implementation-pipeline touchpoint test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc10-audit-touchpoint-implementation-pipeline.sh`. Test verifies implementation-pipeline dispatches audit (phase-appropriate task) with `audit_phase: coherence_gate`. Uses `behavior_run`. Annotate with `# SC-10:`. Verify FAILS. **→ SC-10**
- [ ] 24. **GREEN: SC-10 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-10**
- [ ] 25. **RED: SC-11 verification-before-completion touchpoint test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc11-audit-touchpoint-verification-before-completion.sh`. Test verifies verification-before-completion dispatches `audit --task drift-detection` with `audit_phase: implementation_verification`. Uses `behavior_run`. Annotate with `# SC-11:`. Verify FAILS. **→ SC-11**
- [ ] 26. **GREEN: SC-11 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-11**
- [ ] 27. **RED: SC-12 pr-creation-workflow touchpoint test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc12-audit-touchpoint-pr-creation.sh`. Test verifies pr-creation-workflow dispatches `audit --task spec-summary` with `audit_phase: pr_creation`. Uses `behavior_run`. Annotate with `# SC-12:`. Verify FAILS. **→ SC-12**
- [ ] 28. **GREEN: SC-12 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-12**
- [ ] 29. **RED: SC-13 git-workflow touchpoint test (**sub-agent**).** Write `.opencode/tests/behaviors/NEW-sc13-audit-touchpoint-git-workflow.sh`. Test verifies git-workflow dispatches `audit --task closure-verification` with `audit_phase: post_merge`. Uses `behavior_run`. Annotate with `# SC-13:`. Verify FAILS. **→ SC-13**
- [ ] 30. **GREEN: SC-13 implementation (**sub-agent**).** No code change needed. Verify PASSES. **→ SC-13**
- [ ] 31. **Checkpoint commit (**inline**).** `git add .opencode/tests/behaviors/NEW-sc7-audit-touchpoint-spec-creation.sh .opencode/tests/behaviors/NEW-sc8-audit-touchpoint-writing-plans.sh .opencode/tests/behaviors/NEW-sc9-audit-touchpoint-issue-operations.sh .opencode/tests/behaviors/NEW-sc10-audit-touchpoint-implementation-pipeline.sh .opencode/tests/behaviors/NEW-sc11-audit-touchpoint-verification-before-completion.sh .opencode/tests/behaviors/NEW-sc12-audit-touchpoint-pr-creation.sh .opencode/tests/behaviors/NEW-sc13-audit-touchpoint-git-workflow.sh && git commit -m "Phase 2: 7 pipeline touchpoint behavioral tests (SC-7 through SC-13)"`. Create checkpoint tag `michael-conrad/checkpoint/1785/phase-2-opencode`. **→ SC-all**

#### Phase 2 VbC

- [ ] **VbC (**clean-room**).** Verify all 7 test scripts exist, each is artifact-only, each has `# SC-N:` annotations. Run each test individually and confirm PASS. Verify each test is scoped to trigger only its relevant touchpoint. **→ SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13**

**Concern transition:** Leaving pipeline touchpoints → entering cross-validate behavior. Phase 3 depends on Phase 1 test infrastructure pattern.
