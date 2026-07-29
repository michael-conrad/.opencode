---
plan_schema_version: "1.0"
issue: 2172
title: "Add session timestamp to session-init output"
dispatch:
  - phase: 1
    skill: implementation-pipeline
    task: assemble-work
---

## Pre-Implementation

- [ ] **Coherence gate** — dispatch `audit --task coherence-extraction` to verify spec/plan coherence before RED routing
  - (**sub-agent**) — dispatch via `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2172, project_root, issues_prefix: .opencode}`
- [ ] **Baseline check** — dispatch `pre-red-baseline` to verify clean working tree and trunk-tip state
  - (**sub-agent**) — dispatch via `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2172, project_root, issues_prefix: .opencode}`

## Phase 1: Add session timestamp and staleness warning

**Concerns:** timestamp-output, timestamp-position, runtime-generation, staleness-warning
**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
**File:** `.opencode/tools/session-init`

**Note:** SCs 1-5 are already implemented in the current codebase (lines 582-583 of `session-init`). The RED phase for these SCs will verify the existing implementation is correct. SC-6 (staleness warning) requires new implementation.

### Item 1 — SC-1: session-init emits human-readable datetime

- [ ] **RED phase** — write a behavioral enforcement test that verifies session-init emits a human-readable datetime string
  - (**clean-room**) — dispatch via `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-1, evidence_type: behavioral}`
- [ ] **Z3 check RED** — validate RED state against contract
  - (**inline**) — run `/.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] **RED doublecheck** — verify RED test is correct
  - (**clean-room**) — dispatch via `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-1}`
- [ ] **Z3 check RED doublecheck** — validate RED doublecheck state
  - (**inline**) — run `/.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] **Post-RED enforcement** — verify RED gate conditions
  - (**clean-room**) — dispatch via `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-1}`
- [ ] **Z3 check post-RED** — validate post-RED state
  - (**inline**) — run `/.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] **GREEN phase** — verify existing timestamp implementation satisfies SC-1
  - (**clean-room**) — dispatch via `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-1, file: .opencode/tools/session-init}`
- [ ] **Z3 check GREEN** — validate GREEN state
  - (**inline**) — run `/.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] **Post-GREEN enforcement** — verify GREEN gate conditions
  - (**clean-room**) — dispatch via `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-1}`
- [ ] **Z3 check post-GREEN** — validate post-GREEN state
  - (**inline**) — run `/.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] **Checkpoint tag create** — create checkpoint tag for SC-1 completion
  - (**clean-room**) — dispatch via `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-1}`
- [ ] **Checkpoint commit** — commit SC-1 verification with checkpoint tag
  - (**clean-room**) — dispatch via `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-1}`

### Item 2 — SC-2: Timestamp appears after Git branch line, before `## CLI Auth Status`

- [ ] **RED phase** — write a string-matching test that verifies timestamp position in output
  - (**clean-room**) — dispatch via `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-2, evidence_type: string}`
- [ ] **Z3 check RED** — validate RED state
  - (**inline**)
- [ ] **RED doublecheck** — verify RED test
  - (**clean-room**)
- [ ] **Z3 check RED doublecheck** — validate state
  - (**inline**)
- [ ] **Post-RED enforcement** — verify RED gate
  - (**clean-room**)
- [ ] **Z3 check post-RED** — validate state
  - (**inline**)
- [ ] **GREEN phase** — verify existing timestamp position satisfies SC-2
  - (**clean-room**)
- [ ] **Z3 check GREEN** — validate state
  - (**inline**)
- [ ] **Post-GREEN enforcement** — verify GREEN gate
  - (**clean-room**)
- [ ] **Z3 check post-GREEN** — validate state
  - (**inline**)
- [ ] **Checkpoint tag create** — create checkpoint tag
  - (**clean-room**)
- [ ] **Checkpoint commit** — commit SC-2 verification
  - (**clean-room**)

### Item 3 — SC-3: Natural English prose format

- [ ] **RED phase** — write a string-matching test for "Session started:" format with day, date, time, timezone
  - (**clean-room**) — dispatch via `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-3, evidence_type: string}`
- [ ] **Z3 check RED** — validate state
  - (**inline**)
- [ ] **RED doublecheck** — verify RED test
  - (**clean-room**)
- [ ] **Z3 check RED doublecheck** — validate state
  - (**inline**)
- [ ] **Post-RED enforcement** — verify RED gate
  - (**clean-room**)
- [ ] **Z3 check post-RED** — validate state
  - (**inline**)
- [ ] **GREEN phase** — verify existing format satisfies SC-3
  - (**clean-room**)
- [ ] **Z3 check GREEN** — validate state
  - (**inline**)
- [ ] **Post-GREEN enforcement** — verify GREEN gate
  - (**clean-room**)
- [ ] **Z3 check post-GREEN** — validate state
  - (**inline**)
- [ ] **Checkpoint tag create** — create checkpoint tag
  - (**clean-room**)
- [ ] **Checkpoint commit** — commit SC-3 verification
  - (**clean-room**)

### Item 4 — SC-4: Generated at runtime via Python's datetime module

- [ ] **RED phase** — write a structural test verifying `from datetime import datetime` exists in session-init
  - (**clean-room**) — dispatch via `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-4, evidence_type: structural}`
- [ ] **Z3 check RED** — validate state
  - (**inline**)
- [ ] **RED doublecheck** — verify RED test
  - (**clean-room**)
- [ ] **Z3 check RED doublecheck** — validate state
  - (**inline**)
- [ ] **Post-RED enforcement** — verify RED gate
  - (**clean-room**)
- [ ] **Z3 check post-RED** — validate state
  - (**inline**)
- [ ] **GREEN phase** — verify existing datetime import satisfies SC-4
  - (**clean-room**)
- [ ] **Z3 check GREEN** — validate state
  - (**inline**)
- [ ] **Post-GREEN enforcement** — verify GREEN gate
  - (**clean-room**)
- [ ] **Z3 check post-GREEN** — validate state
  - (**inline**)
- [ ] **Checkpoint tag create** — create checkpoint tag
  - (**clean-room**)
- [ ] **Checkpoint commit** — commit SC-4 verification
  - (**clean-room**)

### Item 5 — SC-5: Local time with local timezone abbreviation

- [ ] **RED phase** — write a string-matching test verifying timezone abbreviation (not bare UTC)
  - (**clean-room**) — dispatch via `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-5, evidence_type: string}`
- [ ] **Z3 check RED** — validate state
  - (**inline**)
- [ ] **RED doublecheck** — verify RED test
  - (**clean-room**)
- [ ] **Z3 check RED doublecheck** — validate state
  - (**inline**)
- [ ] **Post-RED enforcement** — verify RED gate
  - (**clean-room**)
- [ ] **Z3 check post-RED** — validate state
  - (**inline**)
- [ ] **GREEN phase** — verify existing timezone handling satisfies SC-5
  - (**clean-room**)
- [ ] **Z3 check GREEN** — validate state
  - (**inline**)
- [ ] **Post-GREEN enforcement** — verify GREEN gate
  - (**clean-room**)
- [ ] **Z3 check post-GREEN** — validate state
  - (**inline**)
- [ ] **Checkpoint tag create** — create checkpoint tag
  - (**clean-room**)
- [ ] **Checkpoint commit** — commit SC-5 verification
  - (**clean-room**)

### Item 6 — SC-6: Staleness warning emitted after timestamp

- [ ] **RED phase** — write a string-matching test verifying staleness warning appears after timestamp line
  - (**clean-room**) — dispatch via `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-6, evidence_type: string}`
- [ ] **Z3 check RED** — validate state
  - (**inline**)
- [ ] **RED doublecheck** — verify RED test
  - (**clean-room**)
- [ ] **Z3 check RED doublecheck** — validate state
  - (**inline**)
- [ ] **Post-RED enforcement** — verify RED gate
  - (**clean-room**)
- [ ] **Z3 check post-RED** — validate state
  - (**inline**)
- [ ] **GREEN phase** — add staleness warning print line after timestamp in `main()`
  - (**clean-room**) — dispatch via `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2172, sc: SC-6, file: .opencode/tools/session-init}`
  - Implementation: add `print("This session start time indicates your training data is extremely stale and always must be re-researched...")` after line 583
- [ ] **Z3 check GREEN** — validate state
  - (**inline**)
- [ ] **Post-GREEN enforcement** — verify GREEN gate
  - (**clean-room**)
- [ ] **Z3 check post-GREEN** — validate state
  - (**inline**)
- [ ] **Checkpoint tag create** — create checkpoint tag
  - (**clean-room**)
- [ ] **Checkpoint commit** — commit SC-6 implementation
  - (**clean-room**)

## Post-Implementation

- [ ] **Structural checks** — run lint/typecheck on modified files
  - (**clean-room**) — dispatch via `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **GREEN doublecheck** — verify all GREEN implementations
  - (**clean-room**) — dispatch via `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **Verification before completion** — run full VbC gate
  - (**clean-room**) — dispatch via `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **SC count gate** — verify all 6 SCs have verdicts
  - (**clean-room**) — dispatch via `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **Pre-PR gate** — verify no FAIL verdicts remain
  - (**clean-room**) — dispatch via `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **Audit** — dispatch adversarial audit of implementation
  - (**sub-agent**) — dispatch via `task(subagent_type="general")` with `{spec_local_dir: .opencode/.issues/2172, artifact_evidence_dir: .opencode/.issues/2172/artifacts}`
- [ ] **Cross-validate** — produce consensus findings
  - (**clean-room**) — dispatch via `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **Regression check** — run regression test patterns
  - (**clean-room**) — dispatch via `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **Review prep** — prepare PR for review
  - (**clean-room**) — dispatch via `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
  - Context: `{issue_number: 2172}`
- [ ] **Create PR** — create pull request
  - (**clean-room**) — dispatch via `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
  - Context: `{issue_number: 2172, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **Completion** — emit lifecycle event and summary
  - (**clean-room**) — dispatch via `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
  - Context: `{issue_number: 2172}`

## Lifecycle Events

- event: plan_created
  timestamp: 2026-07-29T12:25:00Z
  issuer: OpenCode (deepseek-v4-flash)
  plan_path: .opencode/.issues/2172/plan.md
  phase_count: 1
  status: DONE
