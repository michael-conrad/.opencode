---
phase: 2
concern: Sub-Plan File Format
depends_on: [Phase 1]
scs: [SC-5, SC-6, SC-7, SC-8, SC-16, SC-17, SC-18]
checkpoint_tag: <parent>/checkpoint/<issue>/phase-2-<submodule>
---

# Phase 2 — Sub-Plan File Format

Define the `plan-phase-N.md` structure with dispatch contracts, commit boundaries, and explicit checkpoint tag creation step.

## Pre-RED Common

- [ ] 1. Read spec body for Phase 2 requirements — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis"
    → must_receive: [spec_body, sc_ids]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-5, SC-6, SC-7, SC-8, SC-16, SC-17, SC-18

- [ ] 2. Verify existing plan-structure.md for current sub-plan format — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis"
    → must_receive: [affected_files]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-5

## Per-Item RED/GREEN Chains

### Item 2.1 — Three-section structure

- [ ] 3. RED: Write enforcement test for three-section structure — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-5

- [ ] 4. GREEN: Define Pre-RED Common, Per-Item RED/GREEN Chains, Post-RED/green sections — `write` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, spec_body, plan_structure]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-5

- [ ] 5. REFACTOR: Verify section headers present and in order — `grep` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-5

### Item 2.2 — Dispatch contract fields

- [ ] 6. RED: Write enforcement test for dispatch contract fields — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-6

- [ ] 7. GREEN: Add must_receive/must_not_receive to every TDD item step — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-6

- [ ] 8. REFACTOR: Verify field names not concrete values — `grep` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-6

### Item 2.3 — Checkbox format

- [ ] 9. RED: Write enforcement test for checkbox format — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-7

- [ ] 10. GREEN: Ensure all step lines use `- [ ]` / `- [x]` format — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-7

- [ ] 11. REFACTOR: Verify all step lines use checkbox format — `grep` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-7

### Item 2.4 — Self-contained sub-plans

- [ ] 12. RED: Write enforcement test for self-contained sub-plans — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-8

- [ ] 13. GREEN: Remove cross-file references from sub-plan files — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-8

- [ ] 14. REFACTOR: Verify zero cross-file reference patterns — `grep` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-8

### Item 2.5 — commits: true declaration

- [ ] 15. RED: Write enforcement test for commits:true on every step — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-16

- [ ] 16. GREEN: Add `commits: true` to every TDD item step — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-16

- [ ] 17. REFACTOR: Verify no step lacks commits:true — `grep` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-16

### Item 2.6 — Checkpoint tag header + step

- [ ] 18. RED: Write enforcement test for checkpoint_tag header and step — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-17, SC-18

- [ ] 19. GREEN: Add checkpoint_tag to sub-plan header and explicit checkbox step in Post-RED/green — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-17, SC-18

- [ ] 20. REFACTOR: Verify tag format uses placeholders, step references header tag — `grep` (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-17, SC-18

## Post-RED/green

- [ ] 21. Verify all SCs for Phase 2 — `verification-before-completion` (**sub-agent**)
    → dispatch: "execute verify from verification-before-completion"
    → must_receive: [sc_ids, plan_path, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-5, SC-6, SC-7, SC-8, SC-16, SC-17, SC-18

- [ ] 22. Create checkpoint tag — `git tag` (**inline**)
    → tag: <parent>/checkpoint/<issue>/phase-2-<submodule>
    → commits: false

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
