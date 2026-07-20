## Problem

When asked to create a spec, the orchestrator bypasses the `spec-creation` skill and writes spec content directly via `github_issue_write`. This produces defective deliverables that lack the full spec-creation pipeline's quality gates: analytical artifacts, SC coverage YAML, verification consistency contracts, lifecycle manifests, holistic self-checks, and spec audits.

## Root Cause

The orchestrator treats `github_issue_write` as a valid spec-creation mechanism. There is no enforcement gate preventing the orchestrator from writing spec content directly instead of routing through `skill({name: "spec-creation"})` → `task(..., prompt: "execute create from spec-creation-validation")`.

The spec-creation pipeline exists and is functional — the orchestrator simply does not dispatch to it. This is a routing failure, not a missing capability.

## Evidence

- Issue #2000 in `.opencode` was created via `github_issue_write` with the full spec body written inline by the orchestrator
- No analytical artifacts were generated (blast radius, concern map, code path inventory, etc.)
- No SC coverage YAML was created
- No verification consistency contract was generated
- No lifecycle manifest was initialized
- No holistic self-check was performed
- No spec audit was run
- The spec was also filed in the wrong repo initially (opencode-config #313) before being moved

## Fix Approach

Add a behavioral enforcement test that verifies the agent dispatches to `spec-creation` when asked to create a spec. The test sends a prompt like "create a spec for X" and verifies the agent calls `skill({name: "spec-creation"})` and dispatches the `create` task — not that it writes the spec body directly.

Additionally, add a critical-rules entry explicitly classifying direct `github_issue_write` for spec content as a Tier 2 violation (Orchestrator Inline Work variant).

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Behavioral test exists that verifies agent dispatches to `spec-creation` when asked to create a spec | `behavioral` | `opencode run` with prompt "create a spec for X" → stderr contains `skill({name: "spec-creation"})` |
| SC-2 | Critical-rules entry added classifying direct `github_issue_write` for spec content as Tier 2 violation | `string` | grep for "github_issue_write.*spec" in `000-critical-rules.md` |
| SC-3 | Existing spec #2000 is replaced by a properly-created spec via the spec-creation pipeline | `structural` | Issue #2000 is closed and a new issue exists with analytical artifacts |

## Affected Files

- `.opencode/tests-v2/behaviors/` — New behavioral enforcement test
- `.opencode/guidelines/000-critical-rules.md` — New critical-rules entry
- `.opencode/skills/spec-creation/SKILL.md` — May need a DISPATCH_GATE section if missing

## Non-Goals

- Not changing the spec-creation pipeline itself
- Not adding new spec-creation steps
- Not modifying existing behavioral tests

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
