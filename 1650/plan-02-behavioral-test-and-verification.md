# Phase 2 — Behavioral Test + Verification + Review Prep

**Concern:** Write behavioral enforcement test for SC-6, re-verify zero remaining `/skill` references, run finishing checklist, and prepare PR.

**Files:**
- `.opencode/tests/behaviors/skill-invocation-syntax.sh` (new behavioral test)
- All `.opencode/` files (global grep re-verification)

**SCs:** SC-6, SC-1, SC-2, SC-3, SC-4, SC-5 (re-verify)

**Dependencies:** Phase 1 complete

**Entry condition:** Phase 1 VbC PASS

**Exit condition:** Behavioral test PASSes, zero `/skill` references confirmed, PR created

### Pre-Flight Handoff

- [ ] 1. **Pre-flight handoff (**sub-agent**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state, verification gate preservation. Writes manifest at `./tmp/1650/artifacts/plan-to-pipeline-handoff-*.yaml`. **→ All SCs**

- [ ] 2. **Handoff-consistency check (**inline**).** Read both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests. Compare shared variables. BLOCK on mismatch. **→ All SCs**

- [ ] 3. **Submodule state check (**inline**).** Resolve default branch, verify `git submodule status` shows submodules at that branch's tip. BLOCK on `SUBMODULE-DRIFT`. **→ All SCs**

- [ ] 4. **Pre-flight PASS required (**inline**).** Pipeline MUST NOT proceed to sc-coherence-gate if pre-flight returns BLOCKED. **→ All SCs**

- [ ] 5. **Z3 state init (**inline**).** Run `solve state init ./tmp/1650/state/` — creates state file with `current_step: pre-red-baseline`, `pipeline_state: init`. **→ All SCs**

- [ ] 6. **Lifecycle manifest init (**inline**).** Create `./tmp/1650/lifecycle.yaml` with initial event. **→ All SCs**

### Pipeline-Executor Dispatch (Steps 0-17)

Each step dispatches to a clean-room sub-agent via `task()` per the implementation-pipeline dispatch routing table. After each step, write YAML artifact at `./tmp/1650/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`, create checkpoint tag, and update Z3 state.

- [ ] 7. **Step 0: submodule-verify (**sub-agent**).** Execute `git-workflow --task pre-work` — verify submodule state against default branch tip. **→ All SCs**

- [ ] 8. **Step 1: sc-coherence-gate (**sub-agent**).** Execute `adversarial-audit --task coherence-extraction` — evidence-type uplift + substrate classification. **→ All SCs**

- [ ] 9. **Step 2: pre-red-baseline (**sub-agent**).** Execute `implementation-pipeline --task pre-red-baseline` — doc-source-currency + SC-ID cross-ref traceability. **→ All SCs**

- [ ] 10. **Step 3: red-phase (**sub-agent**).** Execute `test-driven-development --task red` — write behavioral test at `.opencode/tests/behaviors/skill-invocation-syntax.sh`. Test sends prompt asking agent to describe skill invocation, asserts `skill({name: "..."})` syntax present and `/skill` absent. Test must FAIL because agent may still reference `/skill` from training data. **→ SC-6**

- [ ] 11. **Step 4: red-doublecheck (**sub-agent**).** Execute `verification-before-completion --task verify` — verify RED-side SC evidence (behavioral test fails as expected). **→ SC-6**

- [ ] 12. **Step 5: post-red-enforcement (**sub-agent**).** Execute `implementation-pipeline --task post-red-enforcement` — `git diff --name-only -- src/ | wc -l` (structural gate: no source changes in RED phase). **→ All SCs**

- [ ] 13. **Step 6: green-phase (**sub-agent**).** Execute `test-driven-development --task green` — no code change needed (Phase 1 already removed all `/skill` references). Re-run behavioral test — it should now PASS. **→ SC-6**

- [ ] 14. **Step 7: post-green-enforcement (**sub-agent**).** Execute `implementation-pipeline --task post-green-enforcement` — `git diff --name-only -- test/ | wc -l` (structural gate: test changes in GREEN phase). **→ All SCs**

- [ ] 15. **Step 8: checkpoint-tag-create (**sub-agent**).** Execute `implementation-pipeline --task checkpoint-tag-create` — create git tag per checkpoint rollback exception. **→ All SCs**

- [ ] 16. **Step 9: checkpoint-commit (**sub-agent**).** Execute `git-workflow --task commit-prep` — commit behavioral test. **→ All SCs**

- [ ] 17. **Step 10: structural-checks (**sub-agent**).** Execute `finishing-a-development-branch --task checklist` — lint/typecheck/format (advisory-only mode, no auto-modify). **→ All SCs**

- [ ] 18. **Step 11: green-doublecheck (**sub-agent**).** Execute `verification-before-completion --task verify` — semantic-intent verification of GREEN-side SC evidence. Run behavioral test 3 times to verify non-flaky PASS. Run global grep for `/skill` — verify zero matches. **→ SC-6, SC-5**

- [ ] 19. **Step 12: green-vbc (**sub-agent**).** Execute `verification-before-completion --task completion` — VbC completion artifact. **→ All SCs**

- [ ] 20. **Step 13: adversarial-audit (**orchestrator multi-dispatch**).** Run resolve-models → dispatch verification-audit with auditor_1 (remediate on non-clean-pass) → dispatch same with auditor_2 (remediate on non-clean-pass). **→ All SCs**

- [ ] 21. **Step 14: cross-validate (**sub-agent**).** Execute `adversarial-audit --task cross-validate` — produce cross-validate findings YAML. **→ All SCs**

- [ ] 22. **Step 15: regression-check (**sub-agent**).** Execute `test-driven-development --task patterns` — regression test execution. **→ All SCs**

- [ ] 23. **Step 16: review-prep (**sub-agent**).** Execute `git-workflow --task review-prep` — prepare for review. **→ All SCs**

- [ ] 24. **Step 17: exec-summary (**sub-agent**).** Execute `completion-core --task completion` — append lifecycle event + chat exec summary. **→ All SCs**

#### Phase 2 VbC

- [ ] 25. **VbC (**clean-room**).** Verify all exit criteria C1-C6 are met. Verify all 18 pipeline steps have PASS status in lifecycle manifest. **→ All SCs**

**Concern transition:** Plan complete. All 58 `/skill` references replaced, behavioral test verified, zero remaining references confirmed, all pipeline gates passed.
