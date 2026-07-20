---
title: "Universal discussion discipline — no question tool, no pigeon-holing, single topics, order of importance, always discuss"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2037
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The agent's discussion discipline is currently scattered, inconsistently scoped, and missing critical rules. Five distinct problems exist:

### Problem 1: `question` tool prohibition is scoped, not universal

The `question` tool prohibition appears in multiple files, each with a different scope qualifier:

1. `020-go-prohibitions.md` §1.6 says "Never use the `question` tool" but it is in a section called "Discussion Mode Mandates" — scoping it to discussion mode only
2. `000-critical-rules.md` `critical-rules-037` says "No `question` tool for structural decisions when `halt_at >= pr_created`" — scoped to `for_pr` scope only
3. `pre-implementation-analysis.md` says "Never use `question` tool after presenting the execution plan" — scoped to post-plan-presentation only
4. `140-planning-spec-creation.md` says "Use the `question` tool with a list of available specs" — **direct contradiction** to the prohibition
5. `010-approval-gate.md` references `critical-rules-037` in its edge cases table — inherits the scoped prohibition

The `question` tool is a pigeon-hole mechanism that forces constrained choices. It is fundamentally incompatible with open-ended discussion. The prohibition MUST be universal — applies to ALL workflows, ALL states, ALL scopes. No exceptions.

### Problem 2: Pigeon-holing in natural language is prohibited but not enforced as a critical rule

`020-go-prohibitions.md` §1.6 says "Never pigeon-hole in natural language either" — presenting constrained options in prose ("Should we do X or Y?") is the same anti-pattern. But this is in §1.6 Discussion Mode Mandates, scoped to discussion mode. The prohibition should be universal — agents must never present constrained choices in any context.

### Problem 3: Single-topic discipline exists but is not enforced as a critical rule

`020-go-prohibitions.md` §1.6 says "Never mix topics. Every discussion addresses exactly one topic at a time." But this is advisory text in §1.6, not a critical rule. Agents routinely violate this by presenting multi-topic responses, mixing concerns, and addressing multiple questions in a single turn.

### Problem 4: "Order of importance" rule does not exist

There is no rule anywhere that says agents should discuss things in order of importance unless directed otherwise. Agents currently discuss topics in whatever order they appear in the user's message or in whatever order the agent's reasoning produces. This leads to the least important topic being discussed first, wasting the developer's attention on trivial matters before reaching the critical point.

### Problem 5: "Always discuss" is not the default

The current rules frame discussion as a mode ("Discussion Mode Mandates") rather than the default. The default should be open-ended discussion. Structured output (specs, plans, checklists, tables) should be the exception, produced only when explicitly requested. The "Never default to structured output" rule in §1.6 is correct but is scoped to discussion mode rather than being the universal default.

## Root Cause Analysis

Each problem has a distinct root cause:

- **Scoped `question` tool prohibition**: The prohibition was introduced incrementally in different files at different times, each with a different scope qualifier. No single file established the universal prohibition first.
- **Pigeon-holing not enforced**: The natural language pigeon-hole rule was added as a companion to the `question` tool rule but inherited its scope qualifier.
- **Single-topic not enforced**: The rule was written as advisory text in §1.6 without a critical-rules entry or enforcement mechanism.
- **Order of importance missing**: The rule was never conceived. It is a gap in the existing discipline.
- **Discussion not default**: The rules were structured as "Discussion Mode" (a special mode) rather than "Discussion is the default" (structured output is the exception).

## Objectives

- Make the `question` tool prohibition universal — applies to ALL workflows, ALL states, ALL scopes
- Make the pigeon-hole prohibition universal — no constrained choices in any context
- Make the single-topic rule a critical rule — one topic per response, decompose multi-topic messages
- Add the "order of importance" rule — discuss things in order of importance unless directed otherwise
- Make "always discuss" the default — open-ended discussion is the default, structured output is the exception
- Remove all scope qualifiers from existing prohibitions
- Remove the contradictory instruction in `140-planning-spec-creation.md`
- Add a behavioral enforcement test that verifies the agent follows all five rules

## Non-Goals

- **Changing the `question` tool's implementation** — The tool itself is not modified; only the rules governing its use
- **Removing the pre-implementation-analysis checkpoint** — The checkpoint that verifies no `question` tool calls were made stays; only the scope qualifier is removed
- **Rewriting §1.6 entirely** — The existing rules in §1.6 are largely correct; they need scope expansion and elevation, not rewriting

## Constraints and Scope

- All changes are in `.opencode/` (submodule) — guidelines, skills, and behavioral tests
- No changes to the parent repo
- All changes affect runtime agent behavior — evidence type MUST be `behavioral`

## Affected Files

| File | Change |
|------|--------|
| `020-go-prohibitions.md` | Add top-level Tier 1 prohibition for `question` tool (universal). Add top-level Tier 1 prohibition for pigeon-holing (universal). Add top-level Tier 1 prohibition for single-topic discipline. Add top-level Tier 1 prohibition for order-of-importance. Add top-level Tier 1 "always discuss" default. Remove scoped versions from §1.6. |
| `000-critical-rules.md` | Update `critical-rules-037` to remove `halt_at >= pr_created` qualifier. Add new critical rules for pigeon-holing, single-topic, order-of-importance, always-discuss. |
| `010-approval-gate.md` | Update the edge case table reference to `critical-rules-037` to reflect the new universal scope. |
| `pre-implementation-analysis.md` | Remove the "after presenting the execution plan" qualifier. Make `question` tool prohibition universal. |
| `140-planning-spec-creation.md` | Remove the "Use the `question` tool with a list of available specs" instruction. Replace with open-ended discussion pattern. |
| `.opencode/tests-v2/behaviors/` | Add behavioral enforcement test for all five discussion discipline rules |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| None | INDEPENDENT | No blocking or blocked-by dependencies |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Implementation Approach

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/2034/plan.md` before implementation begins.

### Phase 1: Update `020-go-prohibitions.md`

1. Add a new top-level Tier 1 prohibition before §1 (before "What GO Is Not & Self-Authorization Prohibitions"):

   > **Never use the `question` tool.** The `question` tool is a pigeon-hole mechanism that forces constrained choices. This prohibition applies to ALL workflows, ALL states, ALL scopes — not just discussion mode, not just `for_pr` scope, not just post-plan-presentation. All discussion must be open-ended.

   > **Never pigeon-hole in natural language.** Presenting constrained options in prose ("Should we do X or Y?", "Which approach: A, B, or C?") is the same anti-pattern as the `question` tool. This prohibition applies to ALL workflows, ALL states, ALL scopes.

   > **Never mix topics.** Every response addresses exactly one topic at a time. Multi-topic messages must be decomposed into single-topic turns. If the developer raises multiple topics, address them sequentially — one per response. This prohibition applies to ALL workflows, ALL states, ALL scopes.

   > **Discuss things in order of importance unless directed otherwise.** When multiple topics are raised, address them in descending order of importance. The most critical topic first, then the next most critical, and so on. This ensures the developer's attention goes to what matters most before anything else. This prohibition applies to ALL workflows, ALL states, ALL scopes.

   > **Always discuss. Open-ended discussion is the default.** Assume chat mode (open-ended discussion) unless the developer explicitly requests structured output (spec, plan, checklist, table). Brainstorming is the default — structured output is the exception. This applies to ALL workflows, ALL states, ALL scopes.

2. Remove the following bullets from §1.6 Discussion Mode Mandates (they are now top-level Tier 1 prohibitions):
   - "Never use the `question` tool"
   - "Never pigeon-hole in natural language either"
   - "Never mix topics"
   - "Never default to structured output"

3. Keep in §1.6: "Never answer without a live tool call", "Never trust training data", "Never trust metadata without a live API call", "Never halt discussion to research", "No skill-routing solicitation after authorization", "Research card catalogue"

### Phase 2: Update `000-critical-rules.md`

1. Update `critical-rules-037`:
   - Old: "No `question` tool for structural decisions when `halt_at >= pr_created`"
   - New: "No `question` tool for structural decisions — applies to ALL scopes, ALL workflows, ALL states."

2. Add new critical rules:

   > ### [critical-rules-XXX] CRITICAL VIOLATION — Pigeon-holing in natural language — presenting constrained choices in prose
   > Presenting constrained options in prose ("Should we do X or Y?", "Which approach: A, B, or C?") is the same anti-pattern as the `question` tool. This applies to ALL workflows, ALL states, ALL scopes. All discussion must be open-ended.

   > ### [critical-rules-XXX] CRITICAL VIOLATION — Mixing topics — addressing multiple topics in a single response
   > Every response addresses exactly one topic at a time. Multi-topic messages must be decomposed into single-topic turns. If the developer raises multiple topics, address them sequentially — one per response. This applies to ALL workflows, ALL states, ALL scopes.

   > ### [critical-rules-XXX] CRITICAL VIOLATION — Discussing topics out of importance order
   > When multiple topics are raised, address them in descending order of importance unless directed otherwise. The most critical topic first, then the next most critical. This applies to ALL workflows, ALL states, ALL scopes.

   > ### [critical-rules-XXX] CRITICAL VIOLATION — Defaulting to structured output without explicit request
   > Open-ended discussion is the default. Structured output (specs, plans, checklists, tables) is the exception — produced only when explicitly requested by the developer. This applies to ALL workflows, ALL states, ALL scopes.

### Phase 3: Update `010-approval-gate.md`

1. Update the edge case table row referencing `critical-rules-037` to reflect the new universal scope. Remove the `for_pr` scope qualifier.

### Phase 4: Update `pre-implementation-analysis.md`

1. Remove the "after presenting the execution plan" qualifier from the "Never use `question` tool" red flag
2. New text: "Never use `question` tool at ANY point."

### Phase 5: Update `140-planning-spec-creation.md`

1. Remove the "Use the `question` tool with a list of available specs" instruction
2. Replace with open-ended discussion pattern: "Present available specs as a prose list with URLs. Use open-ended language: 'Here are the available specs. Which one would you like to work on?'"

### Phase 6: Behavioral enforcement test

1. Create a behavioral test in `.opencode/tests-v2/behaviors/` that sends a prompt where the agent might be tempted to:
   - Use the `question` tool
   - Pigeon-hole in natural language
   - Mix topics in a single response
   - Discuss topics out of importance order
   - Default to structured output without explicit request
2. Verify the agent follows all five rules
3. The test MUST use stderr-based assertions (`assert_stderr_pattern_absent_all_models`) to verify the `question` tool is not called
4. The test MUST use `assert_semantic` for behavioral assertions about topic ordering, single-topic discipline, and open-ended discussion

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `020-go-prohibitions.md` has top-level Tier 1 prohibitions for all five rules: no `question` tool, no pigeon-holing, single topics, order of importance, always discuss. The scoped versions are removed from §1.6. | `behavioral` | `opencode run` with a prompt that triggers spec listing; verify stderr shows NO `question` tool call |
| SC-2 | `000-critical-rules.md` `critical-rules-037` is updated to remove `halt_at >= pr_created` qualifier — applies to ALL scopes. New critical rules added for pigeon-holing, single-topic, order-of-importance, always-discuss. | `behavioral` | `opencode run` with a prompt under `for_analysis` scope where agent might use `question` tool; verify stderr shows NO `question` tool call |
| SC-3 | `pre-implementation-analysis.md` removes "after presenting the execution plan" qualifier — universal prohibition: "Never use `question` tool at ANY point" | `behavioral` | `opencode run` with a prompt that triggers pre-implementation-analysis flow; verify stderr shows NO `question` tool call |
| SC-4 | `140-planning-spec-creation.md` removes "Use the `question` tool" instruction — replaced with open-ended discussion pattern | `behavioral` | `opencode run` with a "specs" or "pending" command; verify agent presents specs as prose list without `question` tool |
| SC-5 | `010-approval-gate.md` edge case table row referencing `critical-rules-037` is updated to reflect universal scope | `string` | grep for `critical-rules-037` in `010-approval-gate.md` and verify the text no longer says `for_pr scope` |
| SC-6 | Behavioral enforcement test exists that verifies agent follows all five discussion discipline rules — test uses stderr-based assertions and real-domain prompts | `behavioral` | `bash .opencode/tests-v2/behaviors/discussion-discipline.sh` returns exit code 0 |
| SC-7 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | verify all SCs maintain their declared evidence type during implementation |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Behavioral test times out due to model inference latency | Medium | Medium | Increase `BEHAVIOR_TIMEOUT`; use `assert_stderr_pattern_absent_all_models` for model-agnostic assertion |
| `140-planning-spec-creation.md` has other references to `question` tool beyond the identified lines | Low | Medium | Full grep of the file for any remaining `question` references |
| Existing behavioral tests that use `question` tool assertions break | Low | Low | No existing behavioral tests use `question` tool assertions (the tool is prohibited) |
| "Order of importance" is subjective — agents may disagree on what is most important | Medium | Low | The rule says "unless directed otherwise" — the developer can override. Default to what the developer emphasized most (strongest language, first mention, repeated references). |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "question tool" .opencode/guidelines/` | Identify all files with `question` tool references |
| Direct source search | `grep -r "question tool" .opencode/skills/` | Identify all skill files with `question` tool references |
| Direct source search | `grep -r "critical-rules-037" .opencode/` | Identify all files referencing `critical-rules-037` |
| Direct source search | `grep -r "pre-implementation-analysis" .opencode/` | Identify the correct file path for pre-implementation-analysis |
| Direct source search | `grep -r "Never mix topics\|single topic\|one topic" .opencode/guidelines/` | Identify existing single-topic rules |
| Direct source search | `grep -r "order of importance\|priority.*discuss" .opencode/guidelines/` | Confirm no existing order-of-importance rule |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*
