---
phase: 1
concern: Master ToC Format
depends_on: []
scs: [SC-1, SC-2, SC-3, SC-4]
checkpoint_tag: <parent>/checkpoint/<issue>/phase-1-<submodule>
---

# Phase 1 — Master ToC Format

Define the `plan.md` routing index file: a ~50-line orchestrator-loadable ToC with phase list table, dependency ordering, and exit criteria.

## Pre-RED Common

- [ ] 1. Read spec body for Phase 1 requirements — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis. Read `pre-analysis/tasks/pre-analysis.md` first"
    → must_receive: [spec_body, sc_ids]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-1, SC-2, SC-3, SC-4

- [ ] 2. Verify existing plan-structure.md for current format — `read` (**inline**)
    → dispatch: "execute pre-analysis from pre-analysis. Read `pre-analysis/tasks/pre-analysis.md` first"
    → must_receive: [affected_files]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-1

## Per-Item RED/GREEN Chains

### Item 1.1 — plan.md routing index file

- [ ] 3. RED: Write enforcement test for plan.md routing index file — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development. Read `test-driven-development/tasks/RED.md` first"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-1

- [ ] 4. GREEN: Create plan.md with phase list table, dependency ordering, exit criteria — `write` (**inline**)
    → dispatch: "execute GREEN from test-driven-development. Read `test-driven-development/tasks/GREEN.md` first"
    → must_receive: [sc_ids, spec_body, plan_structure]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-1, SC-2, SC-3

- [ ] 5. REFACTOR: Verify plan.md structure matches spec requirements (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development. Read `test-driven-development/tasks/REFACTOR.md` first"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-1, SC-2, SC-3

### Item 1.2 — Orchestrator-loadable ToC

- [ ] 6. RED: Write behavioral test for orchestrator-loadable ToC — `opencode-cli run` (**behavioral**)
    → dispatch: "execute RED from test-driven-development. Read `test-driven-development/tasks/RED.md` first"
    → must_receive: [sc_ids, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-4

- [ ] 7. GREEN: Ensure ToC is self-contained (no cross-file references) — `edit` (**inline**)
    → dispatch: "execute GREEN from test-driven-development. Read `test-driven-development/tasks/GREEN.md` first"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-4

- [ ] 8. REFACTOR: Verify ToC is self-contained and orchestrator-loadable (**inline**)
    → dispatch: "execute REFACTOR from test-driven-development. Read `test-driven-development/tasks/REFACTOR.md` first"
    → must_receive: [sc_ids, plan_path]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: true
    → SC-4

## Post-RED/green

- [ ] 9. Verify all SCs for Phase 1 — `verification-before-completion` (**sub-agent**)
    → dispatch: "execute verify from verification-before-completion. Read `verification-before-completion/tasks/verify.md` first"
    → must_receive: [sc_ids, plan_path, spec_body]
    → must_not_receive: [orchestrator_reasoning, expected_outcomes]
    → commits: false
    → SC-1, SC-2, SC-3, SC-4

- [ ] 10. Create checkpoint tag — `git tag` (**inline**)
    → tag: <parent>/checkpoint/<issue>/phase-1-<submodule>
    → commits: false

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
