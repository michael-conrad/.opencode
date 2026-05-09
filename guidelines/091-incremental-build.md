---
trigger_on: incremental, decompose, monolithic, item, TDD, RED, GREEN
tier: 1
load_when: sub-agent
---

# Incremental Build Discipline

**Enforced by behavioral test `tests/behaviors/incremental-build-enforcement.sh`.** See `000-critical-rules.md` §Monolithic Implementation for the critical violation.

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

**Behavioral variant** (for rule/guideline items): Send prompt via `opencode-cli run`, assert agent does NOT follow new rule (RED), then make change and assert agent DOES follow (GREEN).

## Anti-Patterns (Critical Violations)

- Monolithic implementation — no decomposition
- Code-first — writing code before enforcement test
- Batching items — combining separate concerns
- Merging without tests
- Phase-scoped over-verification — testing other phases' deliverables

## Complexity Metric

Word count (`wc -w`) is canonical. Task files ≤3,000 words, routing SKILL.md ≤4,000 words, condensed SKILL.md ≤2,000 words.

**Symbolic rules below** — the prose above this line replaces the previous ~200 lines of advisory text.

```yaml+symbolic
schema_version: "2.0"
last_updated: "2026-04-25T00:00:00Z"
rules:
  - id: incremental-build-001
    title: "All implementation must follow incremental build discipline"
    conditions:
      all:
        - "implementation_in_progress == true"
        - "top_down_decomposition_completed == false"
    actions:
      - HALT
    conflicts_with: [critical-rules-017]
    requires: []
    triggers: [approval-gate, divide-and-conquer]
    source: "091-incremental-build.md §Mandate"

  - id: incremental-build-002
    title: "Item enumeration and dependency ordering required before implementation"
    conditions:
      all:
        - "implementation_in_progress == true"
        - "item_enumeration_exists == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [writing-plans, approval-gate]
    source: "091-incremental-build.md §Top-Down Decomposition Rules"

  - id: incremental-build-003
    title: "Enforcement test must be RED before GREEN for each item"
    conditions:
      all:
        - "item_implementation_started == true"
        - "red_test_artifact_exists == false"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [executing-plans, divide-and-conquer]
    source: "091-incremental-build.md §Per-Item TDD Cycle"

  - id: incremental-build-004
    title: "Behavioral RED required for rule/guideline items"
    conditions:
      all:
        - "item_type == 'rule_guideline'"
        - "behavioral_test_RED_verified == false"
    actions:
      - HALT
    conflicts_with: [code-standards-005]
    requires: []
    triggers: []
    source: "091-incremental-build.md §Behavioral Variant"

  - id: incremental-build-005
    title: "Phase-scoped test assertions — no cross-phase over-verification"
    conditions:
      all:
        - "phase_n_test_asserts_phase_m_sc == true"
        - "phase_m != phase_n"
    actions:
      - HALT
    conflicts_with: []
    requires: []
    triggers: [verification-before-completion]
    source: "091-incremental-build.md §Phase-Scoped Test Assertions"

  - id: incremental-build-006
    title: "Task files must not exceed 3000 words"
    conditions:
      all:
        - "task_file_word_count > 3000"
    actions:
      - SPLIT_FILE
    conflicts_with: []
    requires: []
    triggers: [skill-creator]
    source: "091-incremental-build.md §Complexity Metric: Word Count"

  - id: incremental-build-007
    title: "SC-specific TDD — test assertions must reference SC IDs"
    conditions:
      all:
        - "spec_has_success_criteria == true"
        - "enforcement_test_references_SC == false"
    actions:
      - HALT
    conflicts_with: [code-standards-008]
    requires: []
    triggers: [spec-creation, verification-before-completion]
    source: "091-incremental-build.md §SC-Specific TDD Mandate"
```
