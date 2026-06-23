---
phase: 5
concern: writing-plans Skill Changes
depends_on: [Phase 2, Phase 3]
scs: [SC-12, SC-13, SC-14, SC-15]
checkpoint_tag: <parent>/checkpoint/<issue>/phase-5-<submodule>
---

# Phase 5 — writing-plans Skill Changes

Update the writing-plans skill to produce the new multi-file format (master ToC + per-phase sub-plans) instead of the single-file format. Include dispatch contract fields, work state file creation, and updated task files.

## Pre-RED Common

- [ ] 1. Read spec body for Phase 5 requirements — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis. Read `pre-analysis/tasks/pre-analysis.md` first"
    → must_receive: [spec_body, sc_ids]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-12, SC-13, SC-14, SC-15

- [ ] 2. Read current writing-plans skill files — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis. Read `pre-analysis/tasks/pre-analysis.md` first"
    → must_receive: [affected_files]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-12, SC-15

- [ ] 3. Read plan-structure.md and create-and-validate.md — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis. Read `pre-analysis/tasks/pre-analysis.md` first"
    → must_receive: [affected_files]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-15

## Per-Item RED/GREEN Chains

### Item 5.1 — Multi-file output

- [ ] 4. RED: Write behavioral test for multi-file plan output — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development. Read `test-driven-development/tasks/RED.md` first"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-12

- [ ] 5. GREEN: Update writing-plans to produce plan.md + plan-phase-N.md files — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development. Read `test-driven-development/tasks/GREEN.md` first"
    → must_receive: [sc_ids, writing_plans_skill_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-12

- [ ] 6. REFACTOR: Invoke skill for 3-phase spec, verify plan.md + 3 sub-plan files (**behavioral**)
    → dispatch: "execute REFACTOR from test-driven-development. Read `test-driven-development/tasks/REFACTOR.md` first"
    → must_receive: [sc_ids, writing_plans_skill_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-12

### Item 5.2 — Dispatch contract fields

- [ ] 7. RED: Write behavioral test for dispatch contract fields in generated sub-plans — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development. Read `test-driven-development/tasks/RED.md` first"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-13

- [ ] 8. GREEN: Add must_receive/must_not_receive generation to sub-plan writer — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development. Read `test-driven-development/tasks/GREEN.md` first"
    → must_receive: [sc_ids, writing_plans_skill_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-13

- [ ] 9. REFACTOR: Invoke skill, verify dispatch contracts in generated files (**behavioral**)
    → dispatch: "execute REFACTOR from test-driven-development. Read `test-driven-development/tasks/REFACTOR.md` first"
    → must_receive: [sc_ids, writing_plans_skill_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-13

### Item 5.3 — Work state file creation

- [ ] 10. RED: Write behavioral test for work state file creation — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development. Read `test-driven-development/tasks/RED.md` first"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-14

- [ ] 11. GREEN: Add work state file creation to writing-plans pipeline — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development. Read `test-driven-development/tasks/GREEN.md` first"
    → must_receive: [sc_ids, writing_plans_skill_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-14

- [ ] 12. REFACTOR: Invoke skill, verify .tmp/work-state-NNN.yaml created with required fields (**behavioral**)
    → dispatch: "execute REFACTOR from test-driven-development. Read `test-driven-development/tasks/REFACTOR.md` first"
    → must_receive: [sc_ids, writing_plans_skill_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-14

### Item 5.4 — Task file updates

- [ ] 13. RED: Write enforcement test for task file updates — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development. Read `test-driven-development/tasks/RED.md` first"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-15

- [ ] 14. GREEN: Update plan-structure.md and create-and-validate.md for new format — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development. Read `test-driven-development/tasks/GREEN.md` first"
    → must_receive: [sc_ids, plan_structure_path, create_validate_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-15

- [ ] 15. REFACTOR: Verify both files reference multi-file format, dispatch contracts, commit boundaries, checkpoint tag (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development. Read `test-driven-development/tasks/REFACTOR.md` first"
    → must_receive: [sc_ids, plan_structure_path, create_validate_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-15

## Post-RED/green

- [ ] 16. Verify all SCs for Phase 5 — `verification-before-completion` (**sub-agent**)
    → dispatch: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first"
    → must_receive: [sc_ids, writing_plans_skill_path, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-12, SC-13, SC-14, SC-15

- [ ] 17. Create checkpoint tag — `git tag` (**inline**)
    → tag: <parent>/checkpoint/<issue>/phase-5-<submodule>
    → commits: false

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
