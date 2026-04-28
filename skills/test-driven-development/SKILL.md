---
name: test-driven-development
description: Use when writing tests before implementation, or when adopting a test-first development approach. Triggers on: TDD, test first, red green refactor, write test, test-driven, unit test, regression.
type: discipline-enforcing
license: MIT
provenance: AI-generated
compatibility: opencode
---

# Skill: test-driven-development

## Overview

Test-driven development (TDD) workflow that enforces writing tests before implementation code. Tests define the contract, implementation satisfies the contract, and refactoring maintains quality.

**MANDATORY: The agent MUST invoke `test-driven-development --task red` before implementation for all code changes (exempt: docs-only, config-only, data-only changes). Skipping this invocation is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Skipping Mandatory Skill Invocation.**

**Source Attribution:** This skill is adapted from <UPSTREAM_ORG>/<UPSTREAM_REPO> workflow (branch: newsrx).

## Tasks

| Task | Purpose | Words |
|------|---------|-------|
| `red` | Write failing test for new behavior | ≈200 |
| `green` | Write minimal implementation to pass test | ≈150 |
| `refactor` | Clean up while keeping tests green | ≈200 |

## Sub-Agent Tasks

### Dispatch Audit Table

| Sub-Agent Task | Trigger Condition | Scope of Context | Exclusions | Inline Work? |
|---|---|---|---|---|
| `red` | When writing failing test for new behavior | Spec SC list, test file paths | Implementation context, implementation intent | NO |
| `green` | When writing minimal implementation to pass test | Spec SC list, test file paths, implementation file paths | Prior RED test output, implementation intent | NO |
| `refactor` | When cleaning up code while keeping tests green | Implementation file paths, test file paths | Implementation context, agent memory | NO |

## Invocation

- `/skill test-driven-development` — Overview only
- `/skill test-driven-development --task red` — Write failing test
- `/skill test-driven-development --task green` — Write minimal implementation
- `/skill test-driven-development --task refactor` — Refactor with tests green

## Operating Protocol

1. **MANDATORY invocation:** This skill MUST be invoked for ALL code changes. The agent MUST NOT treat TDD as optional or contextual. Invoke `/skill test-driven-development --task red` before writing any implementation code. Exempt: documentation-only, configuration-only, or data-only changes.
2. **Red-Green-Refactor cycle:** RED: Write a test that fails (defines expected behavior). GREEN: Write minimal code to make test pass (satisfy contract). REFACTOR: Clean up code while keeping tests green.
3. **Exit conditions:** TDD cycle is COMPLETE when test was written before implementation, implementation passes the test, code is refactored and clean, and all existing tests still pass.

## Enforcement Mechanism

This skill is **MANDATORY** for all code changes. Skipping the TDD enforcement test before implementation is a CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md` §Skipping Mandatory Skill Invocation and §Enforcement Test Updates.

### What Skills SHOULD Check

1. **When TDD is selected:**
   - Was test written before implementation?
   - Does test fail without implementation?
   - Does implementation pass the test?
   - Are all tests still green after refactoring?

2. **TDD violations:**
   - Implementation before test → RECOMMEND starting with test
   - Test always passes → Test doesn't validate anything
   - Refactoring breaks tests → Revert and refactor differently

## Test Standards

- Use `pytest` for all tests
- Run from root: `uv run pytest test/test_filename.py`
- Use `PgServerManager` for database tests (never SQLite)
- Use `./tmp/` for test artifacts

## Integration with Existing Workflow

### Dispatch Order

```
executing-plans (step with TDD approach) → TDD red → TDD green → TDD refactor → verification-before-completion
```

TDD is invoked MANDATORILY — not optionally for all development.

**Exempt from mandatory TDD invocation:** Documentation-only changes, configuration-only changes, data-only changes. All other changes require the RED/GREEN/REFACTOR cycle.

## Cross-References

- Related skills: `systematic-debugging` (testing bug fixes), `verification-before-completion` (evidence)
- Related guidelines: `070-environment.md` (testing standards), `080-code-standards.md` (code quality)

## Platform Compatibility

- **GitHub:** Not applicable (this repository uses GitBucket)
- **GitBucket:** Use Python client from gitbucket-api skill
- **Platform Detection:** Uses `github.platform` environment variable

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: tdd-001
    title: "Tests MUST be written before implementation code"
    conditions:
      all:
        - "implementation_selected == true"
        - "implementation_written_before_test == true"
    actions:
      - HALT
      - INVOKE(test-driven-development --task red)
    conflicts_with: []
    requires: []
    triggers: [test-driven-development]
    source: "test-driven-development/SKILL.md §Operating Protocol"

  - id: tdd-002
    title: "Test MUST fail without implementation (RED phase)"
    conditions:
      all:
        - "implementation_selected == true"
        - "test_passes_without_implementation == true"
    actions:
      - HALT
      - REWRITE_TEST
    conflicts_with: []
    requires: []
    triggers: [test-driven-development]
    source: "test-driven-development/SKILL.md §Enforcement Mechanism"

tasks:
  - id: red
    skill: test-driven-development
    preconditions:
      - "testable_behavior_defined == true"
    postconditions:
      - "failing_test_written == true"
      - "test_defines_expected_behavior == true"
    mandatory: true
    bypass_violation: "implementation started before test written"
    source: "test-driven-development/SKILL.md §Tasks"

  - id: green
    skill: test-driven-development
    preconditions:
      - "red_phase_complete == true"
      - "failing_test_exists == true"
    postconditions:
      - "implementation_passes_test == true"
      - "implementation_is_minimal == true"
    mandatory: true
    bypass_violation: "implementation does not pass the test"
    source: "test-driven-development/SKILL.md §Tasks"

  - id: refactor
    skill: test-driven-development
    preconditions:
      - "green_phase_complete == true"
      - "all_tests_passing == true"
    postconditions:
      - "code_cleaned_up == true"
      - "all_tests_still_passing == true"
    mandatory: false
    bypass_violation: "refactoring broke tests"
    source: "test-driven-development/SKILL.md §Tasks"

decomposition: []
gates:
  - id: red-before-green
    type: precondition
    check: "failing test exists before implementation begins"
    on_fail: RECOMMEND("write test first")
    source: "test-driven-development/SKILL.md §Red-Green-Refactor cycle"
evidence_artifacts:
  - "test file created before implementation file"
  - "uv run pytest output showing test results"
```