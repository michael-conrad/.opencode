---
trigger_on: incremental, decompose, monolithic, item, TDD, RED, GREEN
tier: 1
load_when: sub-agent
---

# Incremental Build Discipline

**Load [§Monolithic Implementation](000-critical-rules.md). Also covered by [tests-v2/behaviors/tier1-mandate-enforcement.sh](tests-v2/behaviors/tier1-mandate-enforcement.sh) for the overarching incremental build discipline.** Load [§Monolithic Implementation](000-critical-rules.md) for the critical violation.

## Mandate

All implementation MUST follow: top-down decomposition → bottom-up design → per-item TDD cycle. Applies to ALL scopes.

## Scope Classification

| Scope | Top-Down Starts From |
|-------|---------------------|
| GREENFIELD | Project spec (no existing code) |
| NEW_FEATURE | Existing code + feature request |
| FIX | Existing code + bug report |
| ENHANCEMENT | Existing code + change request |

## Per-Item TDD Cycle

| Phase | Action |
|-------|--------|
| RED | Enforcement test that FAILS (change doesn't exist yet) |
| GREEN | Make the change that makes the test PASS |
| REFACTOR | Clean up cross-references, verify consistency |
| COMMIT | Test + change committed together as one working slice |

**Behavioral variant** (for rule/guideline items): Send a real-domain prompt via `opencode run`, inspect stderr output (not stdout prose) for behavioral evidence of agent actions (skill dispatches, file reads, tool invocations). Assertions use stderr-based helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`). Assert agent does NOT follow new rule (RED), then make change and assert agent DOES follow (GREEN).

**Behavioral evidence = agent actions visible in stderr (skill dispatches, file reads, sub-agent task() calls, tool invocations). Prose recall (what the agent says in stdout when asked to describe a procedure) is NOT behavioral evidence. Prose-recall prompts are NOT accepted as behavioral tests.** Load [§9 Prompt Construction Mandate](.opencode/tests-v2/AGENTS.md) for the centralized specification of valid vs invalid prompt types.

## Anti-Patterns (Critical Violations)

- Monolithic implementation — no decomposition
- Code-first — writing code before enforcement test
- Batching items — combining separate concerns
- Merging without tests
- Phase-scoped over-verification — testing other phases' deliverables

> **Implementation work is measured ONLY by whether tested verified correct code operations pass with 100% clean PASS. Document size metrics (word count, line count, token count, byte-dispatch formulas) are NOT valid proxies for implementation complexity.**

**Symbolic rules below** — the prose above this line replaces the previous ~200 lines of advisory text.
