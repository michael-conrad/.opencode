---
trigger_on: incremental, decompose, monolithic, item, TDD, RED, GREEN
tier: 1
load_when: sub-agent
---

# Incremental Build Discipline

**Read [§Monolithic Implementation](000-critical-rules.md). Also covered by [tests-v2/behaviors/tier1-mandate-enforcement.sh](tests-v2/behaviors/tier1-mandate-enforcement.sh) for the overarching incremental build discipline.**

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

An item is a single success criterion (SC) from the spec. Each SC gets its own RED/GREEN/REFACTOR/COMMIT cycle; behavioral items add a PUSH step after COMMIT, before the behavioral test run.

| Phase | Action |
|-------|--------|
| RED | Enforcement test that FAILS (change doesn't exist yet) |
| GREEN | Make the change that makes the test PASS |
| REFACTOR | Clean up cross-references, verify consistency |
| COMMIT | Test + change committed together as one working slice |
| PUSH | Behavioral items only: push the commit to its remote branch, then fresh-fetch and verify the effective commit is contained in a remote ref — required BEFORE the behavioral test run (regular items keep commit-last per the #2433 commit-inline plan pattern) |

**Behavioral variant** (for rule/guideline items): Send a real-domain prompt via `opencode run`, inspect stderr output (not stdout prose) for behavioral evidence of agent actions (skill dispatches, file reads, tool invocations). Assertions use stderr-based helpers (`assert_stderr_pattern_present`/`assert_stderr_pattern_absent_all_models`). Assert agent does NOT follow new rule (RED), then make change and assert agent DOES follow (GREEN). Ordering for behavioral items: COMMIT and PUSH precede the behavioral test run — first commit and push, then a fresh `git fetch` verifies the effective commit is contained in a remote ref, and only after that verification does the behavioral test run execute (the harness pre-flight gate hard-FAILs on uncommitted or unpushed submodule state). Regular (non-behavioral) items keep the commit-last cycle per the #2433 commit-inline plan pattern.

**Behavioral evidence = agent actions visible in stderr (skill dispatches, file reads, sub-agent task() calls, tool invocations). Prose recall (what the agent says in stdout when asked to describe a procedure) is NOT behavioral evidence. Prose-recall prompts are NOT accepted as behavioral tests.** Read [§9 Prompt Construction Mandate](.opencode/tests-v2/AGENTS.md) for the centralized specification of valid vs invalid prompt types.

## Anti-Patterns (Critical Violations)

- Monolithic implementation — no decomposition
- Code-first — writing code before enforcement test
- Batching items — combining separate concerns
- Merging without tests
- Phase-scoped over-verification — testing other phases' deliverables

### [critical-rules-042] Monolithic Implementation — skipping item decomposition
Professional engineers decompose work into testable items and build one per TDD cycle (RED → GREEN → REFACTOR → COMMIT). Amateurs batch everything into single monolithic changes — then wonder why review catches half of it wrong.


