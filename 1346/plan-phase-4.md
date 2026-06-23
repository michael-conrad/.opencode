---
phase: 4
concern: implementation-pipeline Skill Update
depends_on: [Phase 2]
scs: [SC-19, SC-20, SC-21]
checkpoint_tag: <parent>/checkpoint/<issue>/phase-4-<submodule>
---

# Phase 4 — implementation-pipeline Skill Update

Audit the dispatch routing table for implicit steps. Every mandatory step must be an explicit entry. Add checkpoint tag creation, Z3 state updates, and any other missing steps. Update the pipeline state machine (Z3 contract) to include new step transitions.

## Pre-RED Common

- [ ] 1. Read spec body for Phase 4 requirements — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis"
    → must_receive: [spec_body, sc_ids]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-19, SC-20, SC-21

- [ ] 2. Read implementation-pipeline dispatch routing table — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis"
    → must_receive: [affected_files]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-19, SC-21

- [ ] 3. Read pipeline state machine YAML — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis"
    → must_receive: [affected_files]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-20

## Per-Item RED/GREEN Chains

### Item 4.1 — Explicit checkpoint-tag-create step

- [ ] 4. RED: Write enforcement test for checkpoint-tag-create in dispatch table — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-19

- [ ] 5. GREEN: Add checkpoint-tag-create as explicit step in dispatch routing table — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, dispatch_table_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-19

- [ ] 6. REFACTOR: Verify step appears between last TDD item and Post-RED/green gates — `grep` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, dispatch_table_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-19

### Item 4.2 — Z3 state machine update

- [ ] 7. RED: Write enforcement test for Z3 state machine with new step — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-20

- [ ] 8. GREEN: Add checkpoint-tag-create step to Z3 state machine with valid transitions — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, state_machine_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-20

- [ ] 9. REFACTOR: Verify transitions: last TDD step → checkpoint-tag-create → next gate — `solve check` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, state_machine_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-20

### Item 4.3 — No implicit steps

- [ ] 10. RED: Write behavioral test for no implicit steps — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-21

- [ ] 11. GREEN: Audit dispatch routing table, add any missing mandatory steps — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, dispatch_table_path, pipeline_executor_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-21

- [ ] 12. REFACTOR: Verify every pipeline operation has dispatch table entry — `grep`, `diff` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, dispatch_table_path, pipeline_executor_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-21

## Post-RED/green

- [ ] 13. Verify all SCs for Phase 4 — `verification-before-completion` (**sub-agent**)
    → dispatch: "execute verify from verification-before-completion"
    → must_receive: [sc_ids, dispatch_table_path, state_machine_path, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-19, SC-20, SC-21

- [ ] 14. Create checkpoint tag — `git tag` (**inline**)
    → tag: <parent>/checkpoint/<issue>/phase-4-<submodule>
    → commits: false

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
