---
phase: 3
concern: Work State File
depends_on: [Phase 1]
scs: [SC-9, SC-10, SC-11]
checkpoint_tag: <parent>/checkpoint/<issue>/phase-3-<submodule>
---

# Phase 3 — Work State File

Define the `.tmp/work-state-NNN.yaml` format with Z3-verifiable contracts and session-resilient disk persistence.

## Pre-RED Common

- [ ] 1. Read spec body for Phase 3 requirements — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis"
    → must_receive: [spec_body, sc_ids]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-9, SC-10, SC-11

- [ ] 2. Verify existing work state file patterns in implementation-pipeline — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis"
    → must_receive: [affected_files]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-9

## Per-Item RED/GREEN Chains

### Item 3.1 — Work state file format

- [ ] 3. RED: Write enforcement test for work state file format — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-9

- [ ] 4. GREEN: Define work state file format with required fields — `write` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-9

- [ ] 5. REFACTOR: Verify YAML parse, required fields present — `yaml parse` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, work_state_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-9

### Item 3.2 — Z3-verifiable contracts

- [ ] 6. RED: Write enforcement test for Z3-verifiable contracts — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-10

- [ ] 7. GREEN: Add Z3-verifiable contract fields for state transitions — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, work_state_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-10

- [ ] 8. REFACTOR: Verify Z3 can load contract — `solve check` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, work_state_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-10

### Item 3.3 — Session-resilient persistence

- [ ] 9. RED: Write behavioral test for session-resilient persistence — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-11

- [ ] 10. GREEN: Implement disk-persistent work state file (not memory-only) — `write` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, work_state_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-11

- [ ] 11. REFACTOR: Simulate session boundary, verify orchestrator resumes from work state file — `opencode-cli run` (**behavioral**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, work_state_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-11

## Post-RED/green

- [ ] 12. Verify all SCs for Phase 3 — `verification-before-completion` (**sub-agent**)
    → dispatch: "execute verify from verification-before-completion"
    → must_receive: [sc_ids, work_state_path, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-9, SC-10, SC-11

- [ ] 13. Create checkpoint tag — `git tag` (**inline**)
    → tag: <parent>/checkpoint/<issue>/phase-3-<submodule>
    → commits: false

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
