---
title: "Universal \`question\` tool prohibition — mandatory for all workflows, all states, all scopes"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2034
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The `question` tool prohibition is currently scattered and inconsistently scoped across multiple files:

1. `020-go-prohibitions.md` §1.6 says "Never use the `question` tool" but it is in a section called "Discussion Mode Mandates" — scoping it to discussion mode only
2. `000-critical-rules.md` `critical-rules-037` says "No `question` tool for structural decisions when `halt_at >= pr_created`" — scoped to `for_pr` scope only
3. `pre-implementation-analysis.md` says "Never use `question` tool after presenting the execution plan" — scoped to post-plan-presentation only
4. `140-planning-spec-creation.md` says "Use the `question` tool with a list of available specs" — **direct contradiction** to the prohibition
5. `010-approval-gate.md` references `critical-rules-037` in its edge cases table — inherits the scoped prohibition

The `question` tool is a pigeon-hole mechanism that forces constrained choices. It is fundamentally incompatible with open-ended discussion. The prohibition MUST be universal — applies to ALL workflows, ALL states, ALL scopes. No exceptions.

## Root Cause Analysis

The prohibition was introduced incrementally in different files at different times, each with a different scope qualifier:

- **`020-go-prohibitions.md`** — Added as a discussion-mode rule, scoped to §1.6 because the original author was thinking about "discussion" as a separate mode from "implementation"
- **`000-critical-rules.md`** — Added as `critical-rules-037` with `for_pr` scope because the author was focused on preventing solicitation during PR creation, not realizing the prohibition should be universal
- **`pre-implementation-analysis.md`** — Added with "after presenting the execution plan" qualifier because the author was focused on preventing solicitation at that specific pipeline stage
- **`140-planning-spec-creation.md`** — Contains the contradictory instruction "Use the `question` tool with a list of available specs" because the author was thinking about user-friendliness (presenting choices) rather than the pigeon-hole problem

The root cause is: **no single file established the universal prohibition first**, so each subsequent file added its own scoped version without cross-referencing or consolidating.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|------------------|
| Keep scoped prohibitions but add a universal one | Creates conflicting rules — agents would not know which takes precedence |
| Only update `020-go-prohibitions.md` and leave other files | Leaves contradictory instructions in `140-planning-spec-creation.md` and scoped versions in other files |
| Add a single critical rule in `000-critical-rules.md` and remove from all other files | Removes useful context from `020-go-prohibitions.md` (the "Never pigeon-hole in natural language" companion rule) and `pre-implementation-analysis.md` (the checkpoint) |

## Objectives

- Make the `question` tool prohibition universal — applies to ALL workflows, ALL states, ALL scopes
- Remove all scope qualifiers from existing prohibitions
- Remove the contradictory instruction in `140-planning-spec-creation.md`
- Add a behavioral enforcement test that verifies the agent does NOT use the `question` tool in ANY context

## Non-Goals

- **Removing the "Never pigeon-hole in natural language" rule** — That rule stays in §1.6 as a companion prohibition for natural language patterns
- **Changing the `question` tool's implementation** — The tool itself is not modified; only the rules governing its use
- **Removing the pre-implementation-analysis checkpoint** — The checkpoint that verifies no `question` tool calls were made stays; only the scope qualifier is removed

## Constraints and Scope

- All changes are in `.opencode/` (submodule) — guidelines, skills, and behavioral tests
- No changes to the parent repo
- All changes affect runtime agent behavior — evidence type MUST be `behavioral`

## Affected Files

| File | Change |
|------|--------|
| `020-go-prohibitions.md` | Move "Never use the `question` tool" from §1.6 to a top-level Tier 1 prohibition (before §1). Make it universal, not scoped to discussion mode. |
| `000-critical-rules.md` | Update `critical-rules-037` to remove the `halt_at >= pr_created` scope qualifier. Make it universal. |
| `010-approval-gate.md` | Update the edge case table reference to `critical-rules-037` to reflect the new universal scope. |
| `pre-implementation-analysis.md` | Remove the "after presenting the execution plan" qualifier. Make it universal. |
| `140-planning-spec-creation.md` | Remove the "Use the `question` tool with a list of available specs" instruction. Replace with open-ended discussion pattern. |
| `.opencode/tests-v2/behaviors/` | Add behavioral enforcement test for universal `question` tool prohibition |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| None | INDEPENDENT | No blocking or blocked-by dependencies |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Implementation Approach

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/2034/plan.md` before implementation begins.

### Phase 1: Update `020-go-prohibitions.md`

1. Add a new top-level Tier 1 prohibition before §1: "**Never use the `question` tool.** The `question` tool is a pigeon-hole mechanism that forces constrained choices. This prohibition applies to ALL workflows, ALL states, ALL scopes — not just discussion mode, not just `for_pr` scope, not just post-plan-presentation. All discussion must be open-ended."
2. Remove the "Never use the `question` tool" bullet from §1.6 Discussion Mode Mandates (the "Never pigeon-hole in natural language" rule stays in §1.6)

### Phase 2: Update `000-critical-rules.md`

1. Update `critical-rules-037` to remove the `halt_at >= pr_created` qualifier
2. New text: "No `question` tool for structural decisions — applies to ALL scopes, ALL workflows, ALL states."

### Phase 3: Update `010-approval-gate.md`

1. Update the edge case table row referencing `critical-rules-037` to reflect the new universal scope

### Phase 4: Update `pre-implementation-analysis.md`

1. Remove the "after presenting the execution plan" qualifier from the "Never use `question` tool" red flag
2. New text: "Never use `question` tool at ANY point."

### Phase 5: Update `140-planning-spec-creation.md`

1. Remove the "Use the `question` tool with a list of available specs" instruction (lines 56-59)
2. Replace with open-ended discussion pattern: "Present available specs as a prose list with URLs. Use open-ended language: 'Here are the available specs. Which one would you like to work on?'"

### Phase 6: Behavioral enforcement test

1. Create a behavioral test in `.opencode/tests-v2/behaviors/` that sends a prompt where the agent might be tempted to use the `question` tool
2. Verify the agent does NOT use the `question` tool in ANY context
3. The test MUST use stderr-based assertions (`assert_stderr_pattern_absent_all_models`) to verify the `question` tool is not called

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `020-go-prohibitions.md` has a top-level Tier 1 prohibition: "Never use the `question` tool" — universal, not scoped to discussion mode. The "Never pigeon-hole in natural language" rule stays in §1.6. | `behavioral` — `opencode run` with a prompt that triggers spec listing; verify stderr shows NO `question` tool call | On FAIL: verify the top-level prohibition text exists in `020-go-prohibitions.md` and the §1.6 bullet was removed | RED/GREEN | `.opencode/.issues/2034/` | Root cause: scattered scoped prohibitions | Phase 1 | pre-commit | sequential | — | — | `behaviors/question-tool-prohibition.sh` | Phase 1 |
| SC-2 | `000-critical-rules.md` `critical-rules-037` is updated to remove `halt_at >= pr_created` qualifier — applies to ALL scopes, ALL workflows, ALL states | `behavioral` — `opencode run` with a prompt under `for_analysis` scope where agent might use `question` tool; verify stderr shows NO `question` tool call | On FAIL: verify `critical-rules-037` text no longer contains `halt_at >= pr_created` | RED/GREEN | `.opencode/.issues/2034/` | Root cause: scoped prohibition | Phase 2 | pre-commit | sequential | — | — | `behaviors/question-tool-prohibition.sh` | Phase 2 |
| SC-3 | `pre-implementation-analysis.md` removes "after presenting the execution plan" qualifier — universal prohibition: "Never use `question` tool at ANY point" | `behavioral` — `opencode run` with a prompt that triggers pre-implementation-analysis flow; verify stderr shows NO `question` tool call | On FAIL: verify the red flag text no longer contains "after presenting the execution plan" | RED/GREEN | `.opencode/.issues/2034/` | Root cause: scoped prohibition | Phase 4 | pre-commit | sequential | — | — | `behaviors/question-tool-prohibition.sh` | Phase 4 |
| SC-4 | `140-planning-spec-creation.md` removes "Use the `question` tool" instruction — replaced with open-ended discussion pattern | `behavioral` — `opencode run` with a "specs" or "pending" command; verify agent presents specs as prose list without `question` tool | On FAIL: verify the "Use the `question` tool" text is removed and replaced with open-ended pattern | RED/GREEN | `.opencode/.issues/2034/` | Root cause: contradictory instruction | Phase 5 | pre-commit | sequential | — | — | `behaviors/question-tool-prohibition.sh` | Phase 5 |
| SC-5 | Behavioral enforcement test exists that verifies agent does NOT use `question` tool in any context — test uses stderr-based assertions and real-domain prompts | `behavioral` — `bash .opencode/tests-v2/behaviors/question-tool-prohibition.sh` returns exit code 0 | On FAIL: diagnose test failure (timeout, assertion mismatch, model issue) and remediate | RED/GREEN | `.opencode/tests-v2/behaviors/question-tool-prohibition.sh` | Root cause: no enforcement test | Phase 6 | pre-commit | sequential | — | — | `behaviors/question-tool-prohibition.sh` | Phase 6 |
| SC-6 | `010-approval-gate.md` edge case table row referencing `critical-rules-037` is updated to reflect universal scope | `string` — grep for `critical-rules-037` in `010-approval-gate.md` and verify the text no longer says `for_pr scope` | On FAIL: update the edge case table row | RED/GREEN | `.opencode/.issues/2034/` | Root cause: inherited scoped reference | Phase 3 | pre-commit | sequential | — | — | — | Phase 3 |
| SC-7 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` — verify all SCs maintain their declared evidence type during implementation | On FAIL: restore original SC evidence type | RED/GREEN | `.opencode/.issues/2034/` | Anti-lobotomization | Common | pre-commit | cross-cutting | — | — | — | Common |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Behavioral test times out due to model inference latency | Medium | Medium | Increase `BEHAVIOR_TIMEOUT`; use `assert_stderr_pattern_absent_all_models` for model-agnostic assertion |
| `140-planning-spec-creation.md` has other references to `question` tool beyond the identified lines | Low | Medium | Full grep of the file for any remaining `question` references |
| Existing behavioral tests that use `question` tool assertions break | Low | Low | No existing behavioral tests use `question` tool assertions (the tool is prohibited) |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "question tool" .opencode/guidelines/` | Identify all files with `question` tool references |
| Direct source search | `grep -r "question tool" .opencode/skills/` | Identify all skill files with `question` tool references |
| Direct source search | `grep -r "critical-rules-037" .opencode/` | Identify all files referencing `critical-rules-037` |
| Direct source search | `grep -r "pre-implementation-analysis" .opencode/` | Identify the correct file path for pre-implementation-analysis |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
