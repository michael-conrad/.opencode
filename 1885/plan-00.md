# Phase 0: Global Pre-Phase — Coherence Gate & Pre-Flight Checks

**SCs:** SC-9 (coherence gate), SC-10 (pre-flight checks)
**Concern:** Pipeline-readiness

## Entry Criteria

- Spec #1885 is approved (authorization_scope: for_pr)
- Feature branch exists

## Steps

### Step 0.1: Coherence Gate (SC-9)

**Type:** sub-agent
**Dispatch:** `task(subagent_type="general", prompt="Verify spec-to-codebase alignment for .opencode/.issues/1885/spec.md. Read the spec body and all 6 analytical artifacts, then verify: all referenced files exist, no spec claims conflict with current codebase state, no superseding issues exist. Return PASS with evidence or BLOCKED with conflict details.")`
**Chain:** none
**Exit criteria:** PASS — spec is coherent with codebase
**Safety:** None — read-only

### Step 0.2: Pre-Flight Checks (SC-10)

**Type:** sub-agent
**Dispatch:** `task(subagent_type="general", prompt="Run pre-flight checks for issue 1885 implementation: (1) verify feature branch exists via git branch --show-current, (2) verify all 6 analytical artifacts exist in .opencode/.issues/1885/, (3) verify authorization_scope >= for_implementation. Return PASS with evidence or BLOCKED with details.")`
**Chain:** step_0.1
**Exit criteria:** PASS — branch exists, artifacts present, auth valid
**Safety:** None — read-only

## Phase Completion Gate

All SCs in this phase MUST be PASS before proceeding to Phase 1.
