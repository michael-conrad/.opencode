---
plan_schema_version: "1.0"
issue: 2106
title: "Test framework DB isolation fixes"
dispatch:
  - phase: 1
    skill: implementation-pipeline
    task: implement-item
    description: "Fix with-test-home execution block"
  - phase: 1
    skill: implementation-pipeline
    task: implement-item
    description: "Fix helpers.sh lazy-init"
  - phase: 1
    skill: implementation-pipeline
    task: implement-item
    description: "Rewrite SC-2.sh to use behavior_run()"
  - phase: 1
    skill: implementation-pipeline
    task: implement-item
    description: "Rewrite test-verb-variant.sh to use with-test-home"
  - phase: 1
    skill: implementation-pipeline
    task: verify-item
    description: "Verify behavioral SCs (SC-10, SC-11)"
---

## Pre-implementation

- [ ] **Coherence gate** — Verify spec/plan coherence before RED routing
  - Dispatch `audit --task coherence-extraction` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Baseline check** — Verify branch state and working tree cleanliness
  - Dispatch `implementation-pipeline --task pre-red-baseline` via sub-agent
  - Context: `{ issue_number: 2106 }`

## Phase 1: Implement all fixes

All changes are independent — no cross-file dependencies. Each task follows the per-item TDD cycle.

### Task 1.1: Fix with-test-home execution block

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-6, SC-12

- [ ] **RED phase** — Write enforcement test that FAILS (change doesn't exist yet)
  - Dispatch `test-driven-development --task red` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-1, SC-2, SC-3, SC-4, SC-6, SC-12] }`
- [ ] **Z3 check RED** — Validate RED phase state transition
  - Inline: `solve --task check` with RED contract
- [ ] **RED doublecheck** — Verify RED phase output
  - Dispatch `verification-before-completion --task verify` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Post-RED enforcement** — Enforce RED gate
  - Dispatch `implementation-pipeline --task post-red-enforcement` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **GREEN phase** — Implement the fix
  - Dispatch `test-driven-development --task green` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-1, SC-2, SC-3, SC-4, SC-6, SC-12] }`
  - Changes:
    - `.opencode/tests-v2/with-test-home`: Replace subshell execution block with `env -i -C "$TEST_PROJECT"` with explicit allowlist of 16 variables
    - Set `HOME="$TEST_HOME"` in execution block
    - Copy `.tools/opencode/opencode` to `$TEST_HOME/bin/opencode`
    - Prepend `$TEST_HOME/bin` to PATH
    - Change `OPENCODE_CMD` from absolute path to bare `"opencode"`
    - Print `[test-env]` diagnostic lines before running command
- [ ] **Z3 check GREEN** — Validate GREEN phase state transition
  - Inline: `solve --task check` with GREEN contract
- [ ] **Post-GREEN enforcement** — Enforce GREEN gate
  - Dispatch `implementation-pipeline --task post-green-enforcement` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Checkpoint tag create** — Create checkpoint tag for this step
  - Dispatch `implementation-pipeline --task checkpoint-tag-create` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Checkpoint commit** — Commit changes
  - Dispatch `git-workflow --task commit-prep` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Structural checks** — Run lint/typecheck
  - Dispatch `finishing-a-development-branch --task checklist` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **GREEN doublecheck** — Verify GREEN phase output
  - Dispatch `verification-before-completion --task verify` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **GREEN VbC** — Verification before completion
  - Dispatch `verification-before-completion --task completion` via sub-agent
  - Context: `{ issue_number: 2106 }`

### Task 1.2: Fix helpers.sh lazy-init

**SCs:** SC-5, SC-6

- [ ] **RED phase** — Write enforcement test that FAILS
  - Dispatch `test-driven-development --task red` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-5, SC-6] }`
- [ ] **Z3 check RED** — Inline solve check
- [ ] **RED doublecheck** — Verify RED output
  - Dispatch `verification-before-completion --task verify` via sub-agent
- [ ] **Post-RED enforcement** — Enforce RED gate
  - Dispatch `implementation-pipeline --task post-red-enforcement` via sub-agent
- [ ] **GREEN phase** — Implement the fix
  - Dispatch `test-driven-development --task green` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-5, SC-6] }`
  - Changes:
    - `.opencode/tests-v2/behaviors/helpers.sh`: Move `opencode models` from source-time (line 397) into lazy-init function `__init_model_pool()`
    - Change `OPENCODE_CMD` from absolute path to bare `"opencode"`
- [ ] **Z3 check GREEN** — Inline solve check
- [ ] **Post-GREEN enforcement** — Enforce GREEN gate
- [ ] **Checkpoint tag create** — Create checkpoint tag
- [ ] **Checkpoint commit** — Commit changes
- [ ] **Structural checks** — Run lint/typecheck
- [ ] **GREEN doublecheck** — Verify GREEN output
- [ ] **GREEN VbC** — Verification before completion

### Task 1.3: Rewrite SC-2.sh to use behavior_run()

**SCs:** SC-7

- [ ] **RED phase** — Write enforcement test that FAILS
  - Dispatch `test-driven-development --task red` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-7] }`
- [ ] **Z3 check RED** — Inline solve check
- [ ] **RED doublecheck** — Verify RED output
- [ ] **Post-RED enforcement** — Enforce RED gate
- [ ] **GREEN phase** — Implement the fix
  - Dispatch `test-driven-development --task green` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-7] }`
  - Changes:
    - `.opencode/tests-v2/behaviors/secret-redaction/SC-2.sh`: Rewrite to use `behavior_run()` from helpers.sh instead of direct `opencode run`
- [ ] **Z3 check GREEN** — Inline solve check
- [ ] **Post-GREEN enforcement** — Enforce GREEN gate
- [ ] **Checkpoint tag create** — Create checkpoint tag
- [ ] **Checkpoint commit** — Commit changes
- [ ] **Structural checks** — Run lint/typecheck
- [ ] **GREEN doublecheck** — Verify GREEN output
- [ ] **GREEN VbC** — Verification before completion

### Task 1.4: Rewrite test-verb-variant.sh to use with-test-home

**SCs:** SC-8, SC-9

- [ ] **RED phase** — Write enforcement test that FAILS
  - Dispatch `test-driven-development --task red` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-8, SC-9] }`
- [ ] **Z3 check RED** — Inline solve check
- [ ] **RED doublecheck** — Verify RED output
- [ ] **Post-RED enforcement** — Enforce RED gate
- [ ] **GREEN phase** — Implement the fix
  - Dispatch `test-driven-development --task green` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-8, SC-9] }`
  - Changes:
    - `.opencode/tests-v2/behaviors/test-verb-variant.sh`: Replace `snap run opencode` with `with-test-home` wrapper
- [ ] **Z3 check GREEN** — Inline solve check
- [ ] **Post-GREEN enforcement** — Enforce GREEN gate
- [ ] **Checkpoint tag create** — Create checkpoint tag
- [ ] **Checkpoint commit** — Commit changes
- [ ] **Structural checks** — Run lint/typecheck
- [ ] **GREEN doublecheck** — Verify GREEN output
- [ ] **GREEN VbC** — Verification before completion

### Task 1.5: Verify behavioral SCs

**SCs:** SC-10, SC-11

- [ ] **GREEN phase** — Execute behavioral verification
  - Dispatch `test-driven-development --task green` via sub-agent
  - Context: `{ issue_number: 2106, scs: [SC-10, SC-11] }`
  - Verification:
    - SC-10: Run `bash .opencode/tests-v2/with-test-home opencode db path`. Assert output contains `TEST_HOME` and does NOT contain `.local/share/opencode/opencode.db`
    - SC-11: Run `sqlite3 ~/.local/share/opencode/opencode.db 'SELECT COUNT(*) FROM sessions'` before and after a `with-test-home` test run. Assert counts are equal.
- [ ] **Z3 check GREEN** — Inline solve check
- [ ] **Post-GREEN enforcement** — Enforce GREEN gate
- [ ] **Checkpoint tag create** — Create checkpoint tag
- [ ] **Checkpoint commit** — Commit changes
- [ ] **Structural checks** — Run lint/typecheck
- [ ] **GREEN doublecheck** — Verify GREEN output
- [ ] **GREEN VbC** — Verification before completion

## Post-implementation

- [ ] **SC count gate** — Verify all SCs have verdicts
  - Dispatch `implementation-pipeline --task sc-count-gate` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Pre-PR gate** — Verify no FAIL verdicts remain
  - Dispatch `verification-before-completion --task verify` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Audit** — Independent audit of all deliverables
  - Dispatch audit task from audit skill via sub-agent
  - Context: `{ issue_number: 2106 }`
  - If FAIL: remediate root cause, re-run audit
- [ ] **Cross-validate** — Consensus check between audit and VbC
  - Dispatch `audit --task cross-validate` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Regression check** — Run regression tests
  - Dispatch `test-driven-development --task patterns` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Review prep** — Prepare PR for review
  - Dispatch `git-workflow --task review-prep` via sub-agent
  - Context: `{ issue_number: 2106 }`
- [ ] **Create PR** — Create pull request
  - Dispatch `pr-creation-workflow --task create` via sub-agent
  - Context: `{ issue_number: 2106, authorization_scope: for_pr, halt_at: pr_created }`
- [ ] **Completion** — Executive summary
  - Dispatch `completion-core --task completion` via sub-agent
  - Context: `{ issue_number: 2106 }`
