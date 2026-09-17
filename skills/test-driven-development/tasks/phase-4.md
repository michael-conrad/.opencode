<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: phase-4

## Purpose

Post-Regression Verification — after the TDD cycle completes (RED→GREEN→REFACTOR), re-compute the blast radius and verify no regressions were introduced. Provides a remediation loop back to GREEN if defects are found.

## Phase 4 Gate: Post-Regression Verification

Invoked after REFACTOR completes. One-time gate per cycle.

## Exit Criteria

Blast radius re-verified GREEN, or entered remediation loop. If BLOCKED after 2 consecutive failures, cycle is HALTED.

## Workflow

### Step 1: Re-Computed Blast Radius

Re-run dependency analysis on the changed area:

```bash
srclight_get_dependents(symbol_name="<function/class under change>", transitive=True)
```

Compare against the Phase 0 blast radius. If new dependents appeared (code was added), verify they are tested.

### Step 2: Remediation Loop

If any Phase 4 verification fails (tests broken, blast radius regressions, uncovered dependents):

- [ ] 1. **First failure:** Return to GREEN phase — fix the defect. Then re-run Phase 4.
- [ ] 2. **Second consecutive failure:** HALT and report BLOCKED status.
- [ ] 3. **Report:** `{ status: "BLOCKED", reason: "2 consecutive Phase 4 failures", cycle: "<cycle-id>" }`
- [ ] 4. The orchestrator must NOT re-task() — this is a genuine blockage requiring human intervention.
- [ ] 5. Return contract: `{ status: "BLOCKED", reason: "<failure details>", cycle: "<cycle-id>" }`

### Step 3: Full Suite Verification

```bash
uv run pytest test/ -v
# Expected: all PASSED
```

### Step 4: Deliberation-Review Directive (R-17) — Behavioral Evidence Review MUST Inspect Deliberation Evidence

When Phase 4 verification includes review of behavioral test evidence (exported session evidence from `opencode run` artifacts — `session.yaml`, timelines, poll logs), the evidence review MUST inspect whatever reasoning/deliberation evidence the session store provides — reasoning events / thinking traces in the exported session evidence, defined GENERICALLY: whatever deliberation evidence the session store represents, with no schema or model-provider assumptions. Deliberation evidence is inspected for test-effectiveness findings:

- **Excessive deliberation** — reasoning budget burned on loops or repeated surveys before any productive tool call
- **False starts** — investigation paths the agent opened and abandoned
- **Off-track reasoning** — deliberation drifting from the scenario goal
- **Prompt/fixture-induced derailment** — evidence that the prompt or fixture steered the agent away from the behavior under test

Each finding is recorded in the verification evidence and routed to test-scenario and prompt adjustments (scenario script, fixture, or prompt text) — a finding without a routing target is an unactioned defect.

**Absent deliberation evidence is recorded as such — NEVER fabricated.** If the session store provides no reasoning/thinking parts for the reviewed run, the review records `deliberation_evidence: absent` and proceeds on tool-call and text-part evidence alone. Fabricating or inferring deliberation content that the session store does not contain is a verification-integrity violation.

### Step 5: PASS Contract

```json
{
  "status": "PASS",
  "blast_radius": "<re-computed blast radius list or 'empty'>",
  "cycle": "<cycle-id>",
  "evidence": "full suite GREEN after Phase 4"
}
```

## Task Context Schema

```json
{
  "spec_context": "<scope of behavior tested>",
  "target_symbol": "<primary function/class under change>",
  "cycle_id": "<unique cycle identifier>",
  "phase_0_contract": "<Phase 0 result contract for comparison>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```

## Timeout-Recovery Resumption Directive (R-15)

At the timeout-recovery decision point — when a Phase 4 verification run is interrupted (bash-tool timeout kill or semantic-monitor abort) and the session store survives — the agent MUST attempt session resumption through the harness BEFORE any re-run. A blind restart after an interrupt is PROHIBITED. Reference whatever resumption mechanism the harness provides; no specific CLI flags or paths are hardcoded in this directive (framework-agnostic, R-15). If resumption is unavailable (session store unreachable), record that fact and fall back per the harness's documented recovery procedure.

## Default-Model Mandate (R-20)

At the model-selection decision point — when a Phase 4 behavioral re-run is launched (including the behavioral re-run that verifies a remediation fix) — the run uses the harness's default test model, resolved from the harness's default-model definition (its single source of truth), unless the user explicitly directs otherwise. Substituting another model on the agent's own initiative is PROHIBITED: model-shopping to work around a failing or slow test is a defect signal, and remediation targets the R-18 defect classes (instructions, task-card/skill-deck wording, prompt construction, fixture state, or harness behavior) — never model selection. A model override is applied only on explicit user direction and MUST be recorded with the direction that authorized it. The mandate binds the harness's default-model mechanism, never a hardcoded model string (framework-agnostic, R-20).

## Cycle-Reset Discipline

After Phase 4 PASSES, the cycle is complete. The agent MUST:

- [ ] 1. Commit the cycle (test + implementation + refactor as one working slice)
- [ ] 2. Reset to Phase 0 for the next item
- [ ] 3. Never carry state across cycles

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `refactor`, `green`
