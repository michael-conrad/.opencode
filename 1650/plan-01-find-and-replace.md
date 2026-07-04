# Phase 1 — Find-and-replace `/skill` → `skill()`

**Concern:** Replace all 58 `/skill` references across `.opencode/` with `skill({name: "..."})` and `task()` syntax.

**Files:**
- `.opencode/skills/*/SKILL.md` (32 CLI lines)
- `.opencode/skills/*/tasks/*.md` (7 `--task` examples)
- `.opencode/skills/*/tasks/**/*.md` (7 additional locations)
- `.opencode/skills/brainstorming/tasks/enforcement.md` (1 prose mention)
- `.opencode/.guidelines/README.md` (3 references)
- `.opencode/README.md` (3 references)
- `.opencode/dispatch-table.yaml` (2 references)
- `.opencode/.issues/1372/spec.md` (2 references)

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5

**Dependencies:** Research complete (58 locations identified)

**Entry condition:** Research evidence artifact exists at `tmp/1650/research/evidence-artifact.md`

**Exit condition:** All 58 `/skill` references replaced; `grep -rn '/skill' .opencode/` returns 0

### Pre-Flight Handoff

- [ ] 1. **Pre-flight handoff (**sub-agent**).** Execute `implementation-pipeline --task pre-flight-handoff` — validates RED checkpoints, SC-ID traceability, approval cascade state, verification gate preservation. Writes manifest at `./tmp/1650/artifacts/plan-to-pipeline-handoff-*.yaml`. **→ All SCs**

- [ ] 2. **Handoff-consistency check (**inline**).** Read both `spec-to-plan-handoff-*.yaml` and `plan-to-pipeline-handoff-*.yaml` manifests. Compare shared variables (SC coverage total, decomposition classification, phase count). BLOCK on mismatch. **→ All SCs**

- [ ] 3. **Submodule state check (**inline**).** Resolve default branch via `git remote show origin | sed -n 's/.*HEAD branch: //p'`, then verify `git submodule status` shows submodules at that branch's tip. If submodules are stale, BLOCK and report `SUBMODULE-DRIFT`. **→ All SCs**

- [ ] 4. **Pre-flight PASS required (**inline**).** Pipeline MUST NOT proceed to sc-coherence-gate if pre-flight returns BLOCKED. **→ All SCs**

- [ ] 5. **Create feature branch (**sub-agent**).** Execute `git-workflow --task pre-work` — create feature branch for issue #1650. **→ All SCs**

- [ ] 6. **Entry proof marker (**inline**).** Write `./tmp/1650/artifacts/entry-proof-{timestamp}.yaml` with plan path, authorization scope, halt_at, pr_strategy. **→ All SCs**

- [ ] 7. **Z3 state init (**inline**).** Run `solve state init ./tmp/1650/state/` — creates state file with `current_step: pre-red-baseline`, `pipeline_state: init`. **→ All SCs**

- [ ] 8. **Lifecycle manifest init (**inline**).** Create `./tmp/1650/lifecycle.yaml` with initial event. **→ All SCs**

### Pipeline-Executor Dispatch (Steps 0-17)

Each step dispatches to a clean-room sub-agent via `task()` per the implementation-pipeline dispatch routing table. After each step, write YAML artifact at `./tmp/1650/artifacts/pipeline-{step_label}-{STATUS}-{timestamp}.yaml`, create checkpoint tag, and update Z3 state.

- [ ] 9. **Step 0: submodule-verify (**sub-agent**).** Execute `git-workflow --task pre-work` — verify submodule state against default branch tip. **→ All SCs**

- [ ] 10. **Step 1: sc-coherence-gate (**sub-agent**).** Execute `adversarial-audit --task coherence-extraction` — evidence-type uplift + substrate classification. **→ All SCs**

- [ ] 11. **Step 2: pre-red-baseline (**sub-agent**).** Execute `implementation-pipeline --task pre-red-baseline` — doc-source-currency + SC-ID cross-ref traceability. **→ All SCs**

- [ ] 12. **Step 3: red-phase (**sub-agent**).** Execute `test-driven-development --task red` — write grep-based verification scripts for SC-1 through SC-5. Scripts must FAIL (exit non-zero) because `/skill` patterns still exist. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 13. **Step 4: red-doublecheck (**sub-agent**).** Execute `verification-before-completion --task verify` — verify RED-side SC evidence (scripts fail as expected). **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 14. **Step 5: post-red-enforcement (**sub-agent**).** Execute `implementation-pipeline --task post-red-enforcement` — `git diff --name-only -- src/ | wc -l` (structural gate: no source changes in RED phase). **→ All SCs**

- [ ] 15. **Step 6: green-phase (**sub-agent**).** Execute `test-driven-development --task green` — replace all 58 `/skill` references with `skill()` syntax across all file categories. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

- [ ] 16. **Step 7: post-green-enforcement (**sub-agent**).** Execute `implementation-pipeline --task post-green-enforcement` — `git diff --name-only -- test/ | wc -l` (structural gate: test changes in GREEN phase). **→ All SCs**

- [ ] 17. **Step 8: checkpoint-tag-create (**sub-agent**).** Execute `implementation-pipeline --task checkpoint-tag-create` — create git tag per checkpoint rollback exception. **→ All SCs**

- [ ] 18. **Step 9: checkpoint-commit (**sub-agent**).** Execute `git-workflow --task commit-prep` — commit all Phase 1 changes. **→ All SCs**

- [ ] 19. **Step 10: structural-checks (**sub-agent**).** Execute `finishing-a-development-branch --task checklist` — lint/typecheck/format (advisory-only mode, no auto-modify). **→ All SCs**

- [ ] 20. **Step 11: green-doublecheck (**sub-agent**).** Execute `verification-before-completion --task verify` — semantic-intent verification of GREEN-side SC evidence. Run grep scripts: SC-1 through SC-4 must PASS (exit zero). **→ SC-1, SC-2, SC-3, SC-4**

- [ ] 21. **Step 12: green-vbc (**sub-agent**).** Execute `verification-before-completion --task completion` — VbC completion artifact. **→ All SCs**

- [ ] 22. **Step 13: adversarial-audit (**orchestrator multi-dispatch**).** Run resolve-models → dispatch verification-audit with auditor_1 (remediate on non-clean-pass) → dispatch same with auditor_2 (remediate on non-clean-pass). **→ All SCs**

- [ ] 23. **Step 14: cross-validate (**sub-agent**).** Execute `adversarial-audit --task cross-validate` — produce cross-validate findings YAML. **→ All SCs**

- [ ] 24. **Step 15: regression-check (**sub-agent**).** Execute `test-driven-development --task patterns` — regression test execution. **→ All SCs**

- [ ] 25. **Step 16: review-prep (**sub-agent**).** Execute `git-workflow --task review-prep` — prepare for review. **→ All SCs**

- [ ] 26. **Step 17: exec-summary (**sub-agent**).** Execute `completion-core --task completion` — append lifecycle event + chat exec summary. **→ All SCs**

#### Phase 1 VbC

- [ ] 27. **VbC (**clean-room**).** Run `grep -rn '/skill' .opencode/` — verify zero matches across ALL file types. Verify all 18 pipeline steps have PASS status in lifecycle manifest. **→ SC-1, SC-2, SC-3, SC-4, SC-5**

**Concern transition:** Leaving find-and-replace → entering behavioral test and verification. Phase 2 depends on Phase 1 completing all `/skill` replacements and passing all pipeline gates.
