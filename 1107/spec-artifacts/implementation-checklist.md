# Implementation Checklist: [#1107](https://github.com/michael-conrad/.opencode/issues/1107) — solve tool

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

This checklist MUST be followed step-by-step by the orchestrating agent during implementation. Each phase follows the 14-gate implementation pipeline. See the [plan.md](../plan.md) for per-phase exit criteria and SC-ID traceability.

---

## Global Preconditions (Before Any Phase)

- [ ] 1. Authorization scope confirmed as `for_implementation` or higher
- [ ] 2. Feature branch exists (created by `git-workflow --task pre-work`)
- [ ] 3. Issue directory initialised at `.opencode/.issues/1107/spec-artifacts/`
- [ ] 4. Authorization context block available (scope, halt_at, pr_strategy, pipeline_phase, owner, repo)
- [ ] 5. Cluster in working directory is the `.opencode` submodule
- [ ] 6. Z3 phase ordering contract confirmed SAT at `.opencode/.issues/1107/spec-artifacts/dependency-ordering-verification/ordering.yaml`
- [ ] 7. Lifecycle manifest initialised at `.opencode/.issues/1107/spec-artifacts/lifecycle.yaml`

---

## Execution Per Phase

### Phase N Pre-Step (Every Phase)

Before entering gate 1 for any phase:

- [ ] N.0.1. Create `./tmp/1107/artifacts/` directory
- [ ] N.0.2. Create `./tmp/1107/state/` directory
- [ ] N.0.3. Read per-phase pipeline gate table and exit criteria from [plan.md](../plan.md) §Phase N
- [ ] N.0.4. Read per-item TDD specification from [plan.md](../plan.md) §Phase N → TDD Items
- [ ] N.0.5. Verify phase dependency is satisfied (Z3 contract: phase-ordering invariants checked via `solve check`)

---

### Gate 1 — sc-coherence-gate

- [ ] N.1.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-sc-coherence-gate-*`
- [ ] N.1.2. Dispatch: `task(subagent_type="general", prompt: "execute sc-coherence-gate from implementation-pipeline for phase N of #1107")`
- [ ] N.1.3. Collect result contract: `{status, artifact_path, summary}`
- [ ] N.1.4. Read YAML artifact only on FAIL (for remediation routing)
- [ ] N.1.5. Post-step Z3 state update (3 sequential calls):
  ```bash
  solve state update ./tmp/1107/state/ --var-name previous_step --var-value <current> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
  solve state update ./tmp/1107/state/ --var-name current_step --var-value <next> --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
  solve state update ./tmp/1107/state/ --var-name pipeline_state --var-value running --contract-path skills/implementation-pipeline/pipeline-state-machine.yaml
  ```
- [ ] N.1.6. Create checkpoint tag: `<parent>/checkpoint/1107/phase-N-step1-opencode`
- [ ] N.1.7. Append event to lifecycle manifest at `.opencode/.issues/1107/spec-artifacts/lifecycle.yaml`

---

### Gate 2 — pre-red-baseline

- [ ] N.2.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-pre-red-baseline-*`
- [ ] N.2.2. Initialise pipeline state: `solve state init ./tmp/1107/state/`
- [ ] N.2.3. Dispatch: `task(subagent_type="general", prompt: "execute pre-red-baseline from implementation-pipeline for phase N of #1107")`
- [ ] N.2.4. Collect result contract; on FAIL → enter remediation routing
- [ ] N.2.5. Post-step Z3 state update (3 sequential calls)
- [ ] N.2.6. Create checkpoint tag: `<parent>/checkpoint/1107/phase-N-step2-opencode`
- [ ] N.2.7. Append event to lifecycle manifest

---

### Gate 3 — red-phase

- [ ] N.3.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-red-phase-*`
- [ ] N.3.2. Verify spec/plan coherence per implementation-pipeline-012 (coherence gate check before RED routing)
- [ ] N.3.3. Dispatch: `task(subagent_type="general", prompt: "execute red-phase from implementation-pipeline for phase N of #1107")`
- [ ] N.3.4. RED sub-agent writes test code that FAILS (current behaviour without fix)
- [ ] N.3.5. RED sub-agent executes test, confirms FAIL
- [ ] N.3.6. Collect result contract; on BLOCKED (spec/codebase contradiction detected) → enter remediation routing
- [ ] N.3.7. Post-step Z3 state update
- [ ] N.3.8. Create checkpoint tag
- [ ] N.3.9. Append event to lifecycle manifest

---

### Gate 4 — red-doublecheck

- [ ] N.4.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-red-doublecheck-*`
- [ ] N.4.2. Dispatch: `task(subagent_type="general", prompt: "execute red-doublecheck from implementation-pipeline for phase N of #1107")`
- [ ] N.4.3. Sub-agent collects RED-side SC evidence (verification-before-completion verify)
- [ ] N.4.4. Confirm RED-side evidence matches SC IDs from [plan.md](../plan.md) §SC-ID Traceability
- [ ] N.4.5. Collect result contract; on FAIL → enter remediation routing
- [ ] N.4.6. Post-step Z3 state update
- [ ] N.4.7. Create checkpoint tag
- [ ] N.4.8. Append event to lifecycle manifest

---

### Gate 5 — green-phase

- [ ] N.5.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-green-phase-*`
- [ ] N.5.2. Dispatch: `task(subagent_type="general", prompt: "execute green-phase from implementation-pipeline for phase N of #1107")`
- [ ] N.5.3. GREEN sub-agent implements the fix/feature
- [ ] N.5.4. GREEN sub-agent re-runs RED-phase test, confirms PASS
- [ ] N.5.5. GREEN sub-agent runs all phase-specific tests
- [ ] N.5.6. Collect result contract; on BLOCKED (plan/spec mismatch detected) → enter remediation routing
- [ ] N.5.7. Post-step Z3 state update
- [ ] N.5.8. Create checkpoint tag
- [ ] N.5.9. Append event to lifecycle manifest

---

### Gate 6 — checkpoint-commit

- [ ] N.6.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-checkpoint-commit-*`
- [ ] N.6.2. Dispatch: `task(subagent_type="general", prompt: "execute checkpoint-commit from implementation-pipeline for phase N of #1107")`
- [ ] N.6.3. Sub-agent stages changes and commits with message referencing #1107
- [ ] N.6.4. RED/GREEN sub-agents MUST NOT commit or push (enforced per implementation-pipeline-011)
- [ ] N.6.5. Collect result contract; on FAIL → enter remediation routing
- [ ] N.6.6. Post-step Z3 state update
- [ ] N.6.7. Create checkpoint tag
- [ ] N.6.8. Append event to lifecycle manifest

---

### Gate 7 — structural-checks

- [ ] N.7.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-structural-checks-*`
- [ ] N.7.2. Dispatch: `task(subagent_type="general", prompt: "execute structural-checks from implementation-pipeline for phase N of #1107")`
- [ ] N.7.3. Sub-agent runs project-local linters:
  - Python files: `uvx ruff check --fix`, `uvx ruff format`, `uvx pyright`
  - Markdown files: `uvx pymarkdownlnt scan`, `uvx mdformat`
- [ ] N.7.4. Collect result contract; on FAIL → fix linter issues, re-run
- [ ] N.7.5. Post-step Z3 state update
- [ ] N.7.6. Create checkpoint tag
- [ ] N.7.7. Append event to lifecycle manifest

---

### Gate 8 — green-doublecheck

- [ ] N.8.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-green-doublecheck-*`
- [ ] N.8.2. Dispatch: `task(subagent_type="general", prompt: "execute green-doublecheck from implementation-pipeline for phase N of #1107")`
- [ ] N.8.3. Sub-agent collects GREEN-side SC evidence (verification-before-completion verify)
- [ ] N.8.4. Confirm ALL phase SCs have PASS evidence with correct type (behavioral/string/structural per SC-ID table)
- [ ] N.8.5. EVIDENCE_TYPE_MISMATCH check: structural evidence for behavioral SC → FAIL (hard gate)
- [ ] N.8.6. Collect result contract; on FAIL → enter remediation routing
- [ ] N.8.7. Post-step Z3 state update
- [ ] N.8.8. Create checkpoint tag
- [ ] N.8.9. Append event to lifecycle manifest

---

### Gate 9 — green-vbc (Verification Before Completion)

- [ ] N.9.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-green-vbc-*`
- [ ] N.9.2. Dispatch: `task(subagent_type="general", prompt: "execute green-vbc from implementation-pipeline for phase N of #1107")`
- [ ] N.9.3. Sub-agent runs completion verification against all Phase N SCs
- [ ] N.9.4. Collect result contract; on FAIL → enter remediation routing
- [ ] N.9.5. Post-step Z3 state update
- [ ] N.9.6. Create checkpoint tag
- [ ] N.9.7. Append event to lifecycle manifest

---

### Gate 10 — adversarial-audit

- [ ] N.10.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-adversarial-audit-*`
- [ ] N.10.2. Run completeness gate: `task(subagent_type="general", prompt: "execute completeness-gate --task check for phase N of #1107")`
- [ ] N.10.3. Only proceed to adversarial audit if completeness gate PASSES (implementation-pipeline-017)
- [ ] N.10.4. Resolve auditor models: `./.opencode/tools/resolve-models` → get 2 auditor types from different families
- [ ] N.10.5. Dispatch auditor 1: `task(subagent_type="<auditor_1>", prompt: "execute adversarial-audit --task verification-audit for phase N of #1107")`
- [ ] N.10.6. Dispatch auditor 2: `task(subagent_type="<auditor_2>", prompt: "execute adversarial-audit --task verification-audit for phase N of #1107")`
- [ ] N.10.7. Collect both auditor result contracts
- [ ] N.10.8. On DISAGREE between auditors: present revision options per adversarial-audit-010
- [ ] N.10.9. On FAIL from either auditor: enter remediation routing (max 3 attempts per implementation-pipeline-014)
- [ ] N.10.10. On consensus PASS: proceed
- [ ] N.10.11. Post-step Z3 state update
- [ ] N.10.12. Create checkpoint tag
- [ ] N.10.13. Append event to lifecycle manifest

---

### Gate 11 — cross-validate

- [ ] N.11.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-cross-validate-*`
- [ ] N.11.2. Dispatch: `task(subagent_type="general", prompt: "execute cross-validate from implementation-pipeline for phase N of #1107")`
- [ ] N.11.3. Sub-agent runs adversarial-audit cross-validate task: compares both auditor verdicts
- [ ] N.11.4. Collect cross-validate findings YAML
- [ ] N.11.5. On FAIL (verdict mismatch, evidence type mismatch): enter remediation routing
- [ ] N.11.6. Post-step Z3 state update
- [ ] N.11.7. Create checkpoint tag
- [ ] N.11.8. Append event to lifecycle manifest

---

### Gate 12 — regression-check

- [ ] N.12.1. Pre-cleanup: `rm -f ./tmp/1107/artifacts/pipeline-regression-check-*`
- [ ] N.12.2. Dispatch: `task(subagent_type="general", prompt: "execute regression-check from implementation-pipeline for phase N of #1107")`
- [ ] N.12.3. Sub-agent runs test-driven-development regression patterns task
- [ ] N.12.4. ALL existing behavioral tests MUST still pass (no regressions)
- [ ] N.12.5. Collect result contract; on FAIL → enter remediation routing
- [ ] N.12.6. Post-step Z3 state update
- [ ] N.12.7. Create checkpoint tag
- [ ] N.12.8. Append event to lifecycle manifest

---

### Gate 13 — review-prep

- [ ] N.13.1. Dispatch: `task(subagent_type="general", prompt: "execute review-prep from implementation-pipeline for phase N of #1107")`
- [ ] N.13.2. Sub-agent runs git-workflow review-prep task (compare URL, summary)
- [ ] N.13.3. Compare URL base branch verified per URL Sourcing Rule 2
- [ ] N.13.4. Collect result contract; on FAIL → enter remediation routing
- [ ] N.13.5. Post-step Z3 state update
- [ ] N.13.6. Create checkpoint tag
- [ ] N.13.7. Append event to lifecycle manifest

---

### Gate 14 — exec-summary

- [ ] N.14.1. Dispatch: `task(subagent_type="general", prompt: "execute exec-summary from implementation-pipeline for phase N of #1107")`
- [ ] N.14.2. Sub-agent pushes branch
- [ ] N.14.3. Sub-agent generates PR URL (extracted from `github_create_pull_request` API response `html_url` — NEVER constructed from templates)
- [ ] N.14.4. Sub-agent posts issue comment with completion status
- [ ] N.14.5. Collect result contract
- [ ] N.14.6. Post-step Z3 state update
- [ ] N.14.7. Append event to lifecycle manifest

---

## Remediation Routing (Any Gate)

On any gate returning FAIL:

- [ ] R.1. Read FAIL artifact YAML frontmatter from `./tmp/1107/artifacts/pipeline-{step_label}-FAIL-{timestamp}.yaml`
- [ ] R.2. Check for prior checkpoint tag: `<parent>/checkpoint/1107/phase-N-step{N-1}-opencode`
- [ ] R.3. If checkpoint exists → apply Phase Rollback:
  ```bash
  git status
  git diff --stat
  git reset --hard <parent>/checkpoint/1107/phase-N-step{N-1}-opencode
  git submodule update --init
  ```
- [ ] R.4. If no checkpoint (step 1 failure) → `git checkout .` to clean working tree
- [ ] R.5. Dispatch researcher: `task(subagent_type="general", prompt: "investigate FAIL at step <label> for phase N of #1107")`
- [ ] R.6. Researcher determines: remediation_scope, remediation_steps[], escalation_required
- [ ] R.7. If `escalation_required: true` → HALT, report blocker to developer
- [ ] R.8. If `escalation_required: false` → extract `remediation_steps[0].target_step`, re-dispatch from that step
- [ ] R.9. Max 3 remediation attempts before escalation (guidance, not hard gate — genuine progress extends cap)
- [ ] R.10. On BLOCKED sub-agent result → discard ALL files produced by that sub-agent, re-task clean-room with original context

---

## Phase Completion (End of Each Phase)

- [ ] PC.1. All 14 gates for this phase completed with PASS
- [ ] PC.2. All SCs for this phase verified (per SC-ID traceability table in plan.md)
- [ ] PC.3. All checkpoint tags exist for this phase (steps 1-14)
- [ ] PC.4. Lifecycle manifest has 14 entries for this phase
- [ ] PC.5. If more phases remain → advance to next phase (start from Phase N+1 Gate 1)
- [ ] PC.6. If final phase complete → proceed to overall completion

---

## Overall Completion (After All Phases)

- [ ] OC.1. All 4 phases complete (Phases 1-4)
- [ ] OC.2. All 11 SCs verified PASS (SC-1 through SC-11)
- [ ] OC.3. All-or-nothing gate confirmed: every SC has PASS behavioural/string/structural evidence
- [ ] OC.4. Full regression suite passes (all pre-existing behavioural tests)
- [ ] OC.5. Branch pushed, PR URL extracted from API response
- [ ] OC.6. Issue comment posted with final status
- [ ] OC.7. Lifecycle manifest finalised with completion entry

---

## Key Constraints

- Orchestrator NEVER performs inline work (file edits, analysis, decisions) — all work via task() sub-agents (implementation-pipeline-001)
- Orchestrator inline work poisons the pipeline — full restart from `verify-authorization` required (implementation-pipeline-009)
- RED/GREEN sub-agents MUST NOT commit or push (implementation-pipeline-011)
- Completeness gate MUST run before adversarial audit (implementation-pipeline-017)
- Cost-blind verification: never skip steps to save resources (implementation-pipeline-016)
- "Continue" does NOT waive mandatory gates (implementation-pipeline-015)
- EVIDENCE_TYPE_MISMATCH: structural evidence for behavioural SC → FAIL, never PASS (code-standards-016a)
- Behavioural evidence files at `./tmp/1107/behavioral-evidence-*` MUST NOT be deleted before PR merge

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)