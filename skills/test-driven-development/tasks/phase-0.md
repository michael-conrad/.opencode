<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: phase-0

## Purpose

Pre-Regression Baseline — establish the current state of the codebase before any TDD cycle begins. Ensures the agent knows what depends on what and that all existing tests pass before touching any code.

## Phase 0 Gate: Pre-Regression Baseline

Invoked before the first RED phase of any new TDD cycle. One-time gate per cycle.

## Exit Criteria

Blast radius computed, existing tests verified GREEN. If tests fail, cycle is BLOCKED.

## Workflow

### Step 1: AI-Driven Dependency Analysis

Use `srclight_get_dependents` (or equivalent) to identify the blast radius of the code area being touched:

```bash
# Identify dependents of the area under change
srclight_get_dependents(symbol_name="<function/class under test>", transitive=True)
```

Document the blast radius in the dispatch context:
- Direct dependents (functions that call this symbol)
- Transitive dependents (functions that call the callers)
- Test files that cover this area

### Step 2: Functional Test Execution

Run the full test suite for the affected area:

```bash
uv run pytest test/ -v
# Expected: all PASSED
```

### Step 3: BLOCKED-on-Failure Protocol

If any existing tests fail during Phase 0:

1. **HALT** — do not proceed to RED
2. **Report** the failing tests with their error output
3. **BLOCKED status** — the cycle cannot start until existing failures are resolved
4. **Do NOT fix the failures** — report only. Bug fixes follow their own spec→plan→implementation pipeline.
5. Return contract: `{ status: "BLOCKED", reason: "<test failures>", failures: [...] }`

### Step 4: Empty Blast Radius = Silent Proceed

If dependency analysis shows zero dependents and all tests pass:

- Return contract: `{ status: "PASS", blast_radius: "empty", evidence: "all tests GREEN" }`
- The orchestrator proceeds to RED immediately — no user notification needed
- Empty blast radius means the change cannot cause regressions, so no gate output is required

## Dispatch Context Schema

```json
{
  "spec_context": "<scope of behavior to test>",
  "target_symbol": "<primary function/class under change>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```

## Context Required

- Related skills: `test-driven-development` (parent skill)
- Related tasks: `red`, `checklist`
