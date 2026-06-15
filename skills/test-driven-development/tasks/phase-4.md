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

### Step 4: PASS Contract

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

## Cycle-Reset Discipline

After Phase 4 PASSES, the cycle is complete. The agent MUST:

- [ ] 1. Commit the cycle (test + implementation + refactor as one working slice)
- [ ] 2. Reset to Phase 0 for the next item
- [ ] 3. Never carry state across cycles

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `refactor`, `green`
