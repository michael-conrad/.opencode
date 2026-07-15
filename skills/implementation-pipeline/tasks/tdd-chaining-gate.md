# Task: tdd-chaining-gate

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)

## Purpose

Gate that validates batched RED/GREEN phases (multiple items in a single TDD cycle). Ensures each item in the batch has its own RED phase, GREEN phase, and verification before the batch advances. Prevents monolithic implementation where multiple items are implemented in a single GREEN phase without per-item verification.

## Entry Criteria

- Plan has multiple items marked for batched RED/GREEN execution
- `assemble-work` step completed with batch context
- Each item in the batch has its own SC list

## Exit Criteria

- Per-item RED/GREEN/verification sequence confirmed for each item in the batch
- Gate PASS: all items have independent RED/GREEN/verify cycles
- Gate FAIL: items share a single RED or GREEN phase — orchestrator must split them

## Procedure

- [ ] 1. Read the plan's batch configuration — identify all items in the batch
- [ ] 2. For each item, verify it has its own RED phase entry in the pipeline state
- [ ] 3. For each item, verify it has its own GREEN phase entry in the pipeline state
- [ ] 4. For each item, verify it has its own verification step (green-doublecheck or equivalent)
- [ ] 5. If any item shares a RED/GREEN/verify step with another item: return BLOCKED with list of conflated items
- [ ] 6. If all items have independent cycles: write PASS artifact, return DONE

## Artifact Format

```yaml
step_label: tdd-chaining-gate
issue_number: {issue-N}
generated_at: "{timestamp}"
status: PASS | FAIL
summary:
  total_items: <N>
  pass: <N>
  fail: <N>
per_item:
  - item_id: "<item-label>"
    has_independent_red: true | false
    has_independent_green: true | false
    has_independent_verify: true | false
    result: PASS | FAIL
```

## Context Required

- Preceded by: assemble-work (plan reading + batch identification)
- Feeds into: sc-coherence-gate (per-item coherence check)
- Related: `test-driven-development/tasks/red.md`, `test-driven-development/tasks/green.md`

## Related Files

- `skills/implementation-pipeline/SKILL.md` — Trigger Dispatch Table (tdd-chaining-gate entry)
- `skills/implementation-pipeline/SKILL.md` — Mandatory Task Discipline
