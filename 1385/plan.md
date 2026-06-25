# Implementation Plan — [#1385](https://github.com/michael-conrad/.opencode/issues/1385) — Skill card semantic auditor criteria (SC-SEM-001 through 006)

- **Goal:** Add 6 semantic auditor criteria (SC-SEM-001 through 006) to the spec-audit task for evaluating skill card description quality, with severity-based consensus in cross-validate.
- **Architecture:** spec-audit.md gains a new Step 3a that evaluates SC-SEM criteria when auditing skill cards. cross-validate.md gains severity-based consensus logic (ERROR FAIL blocks, WARNING FAIL flags). A fixture SKILL.md with violations serves as the behavioral test target.
- **Files:** `skills/adversarial-audit/tasks/spec-audit.md`, `skills/adversarial-audit/tasks/cross-validate.md`, `tests/behaviors/1385-sc1-sem-auditor-evaluates-sc-sems.sh`, `tests/behaviors/fixtures/issues/1385/spec.md`, `tests/behaviors/helpers.sh`, `tests/AGENTS.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1 — Add SC-SEM criteria to spec-audit.md

- **Concern:** Evaluation criteria table entries + Step 3a evaluation procedure
- **Files:** `skills/adversarial-audit/tasks/spec-audit.md`
- **SCs:** SC-1 through SC-6, SC-7, SC-8, SC-9
- **Dependencies:** None
- **Entry:** spec-audit.md loaded, spec #1385 approved
- **Exit:** All 6 SC-SEM criteria in evaluation table, Step 3a documented, severity field in YAML format

- [ ] 1. **Add SC-SEM criteria to evaluation criteria table (**inline**).** Insert 6 rows after SC-ADMONISHMENT in the criteria table at `skills/adversarial-audit/tasks/spec-audit.md`. Each row has criteria_id, description, expected result with severity annotation. **→ SC-1 through SC-6, SC-7**
- [ ] 2. **Add Step 3a evaluation procedure (**inline**).** Insert Step 3a after the criteria table and before Step 3 (Cross-Validate). Document per-criterion evaluation methods with PASS/FAIL conditions. Include YAML format with `severity` field. **→ SC-1 through SC-6, SC-7, SC-8, SC-9**
- [ ] 3. **Update checklist and dependency chain (**inline**).** Add Step 3a to the Spec Audit Checklist and Completion Dependency Chain. **→ SC-8**

#### Phase 1 VbC

- [ ] 4. **VbC (**clean-room**).** Verify all 6 SC-SEM criteria present in criteria table with criteria_id, severity, description. Verify Step 3a has per-criterion PASS/FAIL conditions. Verify `severity` field in YAML template. Verify checklist and dependency chain include Step 3a. **→ SC-1 through SC-6, SC-7, SC-8**

**Concern transition:** Leaving criteria definition → entering consensus logic. Phase 2 depends on Phase 1 criteria existing.

## Phase 2 — Update cross-validate.md for severity-based consensus

- **Concern:** Consensus logic for ERROR vs WARNING severity
- **Files:** `skills/adversarial-audit/tasks/cross-validate.md`
- **SCs:** SC-7
- **Dependencies:** Phase 1 (SC-SEM criteria must exist)
- **Entry:** Phase 1 complete, cross-validate.md loaded
- **Exit:** severity field in findings YAML, severity-based consensus logic documented

- [ ] 5. **Add severity field to findings YAML (**inline**).** Add `severity: "ERROR|WARNING"` comment to the findings YAML template in `skills/adversarial-audit/tasks/cross-validate.md`. **→ SC-7**
- [ ] 6. **Add severity-based consensus logic (**inline**).** Add paragraph to Step 6 (Compute Aggregate Consensus) documenting that WARNING-severity FAIL does not cascade to overall FAIL, ERROR-severity FAIL does cascade, and non-SC-SEM criteria default to ERROR. **→ SC-7**

#### Phase 2 VbC

- [ ] 7. **VbC (**clean-room**).** Verify `severity` field in findings YAML. Verify severity-based consensus logic paragraph in Step 6. **→ SC-7**

**Concern transition:** Leaving consensus logic → entering behavioral testing. Phase 3 depends on Phase 1 criteria existing.

## Phase 3 — Behavioral enforcement test

- **Concern:** Verifiable behavioral evidence that spec-audit evaluates SC-SEM criteria
- **Files:** `tests/behaviors/1385-sc1-sem-auditor-evaluates-sc-sems.sh`, `tests/behaviors/fixtures/issues/1385/spec.md`
- **SCs:** SC-1 through SC-6, SC-8, SC-9
- **Dependencies:** Phase 1 (criteria must exist to be tested)
- **Entry:** Phase 1 complete, fixture directory exists
- **Exit:** Fixture SKILL.md with violations, behavioral test script with real dispatch prompt

- [ ] 8. **Create fixture SKILL.md (**inline**).** Write `tests/behaviors/fixtures/issues/1385/spec.md` with vague description ("Use when working with data"), optional language ("You may", "Consider using"), 5 trigger conditions in dispatch table, and sub-checkboxes for parameter metadata. **→ SC-1 through SC-6**
- [ ] 9. **Create behavioral test script (**inline**).** Write `tests/behaviors/1385-sc1-sem-auditor-evaluates-sc-sems.sh` that sends a real spec-audit dispatch prompt (`audit_phase: spec_creation spec_issue_number: 1385 spec_local_dir: fixtures/issues/1385/`). **→ SC-1 through SC-6, SC-8, SC-9**

#### Phase 3 VbC

- [ ] 10. **VbC (**clean-room**).** Verify fixture SKILL.md exists with violations. Verify behavioral test script has valid shebang, helpers.sh source, behavior_run call, exit 0. **→ SC-1 through SC-6, SC-8, SC-9**

**Concern transition:** Leaving behavioral testing → entering harness fix. Phase 4 is independent of Phases 1-3.

## Phase 4 — Stack #1411 (flock timeout)

- **Concern:** Lock contention in behavioral test harness
- **Files:** `tests/behaviors/helpers.sh`, `tests/AGENTS.md`
- **SCs:** SC-1 through SC-4 from #1411
- **Dependencies:** None (independent of Phases 1-3)
- **Entry:** helpers.sh loaded, AGENTS.md loaded
- **Exit:** `flock -x -w 30` with contention handling, no BEHAVIOR_CONCURRENT docs

- [ ] 11. **Add flock timeout (**inline**).** Change `flock -x 200` to `flock -x -w 30 200` in `tests/behaviors/helpers.sh`. Add error handling: on timeout, print `HARNESS_FAILURE: lock contention` to stderr and `return 1`. **→ #1411 SC-1, SC-2**
- [ ] 12. **Remove dead BEHAVIOR_CONCURRENT docs (**inline**).** Replace the Concurrency Lock section in `tests/AGENTS.md` to remove the `BEHAVIOR_CONCURRENT` reference. Document that flock uses `-w 30` timeout. **→ #1411 SC-3**

#### Phase 4 VbC

- [ ] 13. **VbC (**clean-room**).** Verify `flock -x -w 30` in helpers.sh. Verify contention error handling. Verify no `BEHAVIOR_CONCURRENT` reference in tests/AGENTS.md. **→ #1411 SC-1, SC-2, SC-3**

## Global post-steps

- [ ] 14. **Adversarial audit (**clean-room**).** Dispatch spec-audit and cross-validate against the plan. **→ All SCs**
- [ ] 15. **Regression check (**clean-room**).** Run behavioral test to verify no contention. **→ #1411 SC-4**
- [ ] 16. **Review-prep (**clean-room**).** Run finishing-a-development-branch checklist. **→ All SCs**
- [ ] 17. **Push and create PR (**inline**).** Push `feature/1385-semantic-auditor-criteria` to origin, create PR against dev. **→ All SCs**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- C1. All 6 SC-SEM criteria present in spec-audit.md criteria table with criteria_id, severity, description
- C2. Step 3a evaluation procedure documented with per-criterion PASS/FAIL conditions
- C3. `severity` field in verdict YAML format in spec-audit.md
- C4. `severity` field in findings YAML format in cross-validate.md
- C5. Severity-based consensus logic in cross-validate.md Step 6
- C6. Fixture SKILL.md at `fixtures/issues/1385/spec.md` with violations
- C7. Behavioral test script with real dispatch prompt
- C8. `flock -x -w 30` in helpers.sh with contention error handling
- C9. No `BEHAVIOR_CONCURRENT` reference in tests/AGENTS.md
- C10. PR created against dev
