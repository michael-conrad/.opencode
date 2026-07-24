---
remote_issue: 2104
remote_url: "https://github.com/michael-conrad/.opencode/issues/2104"
last_sync: "2026-07-24T22:52:43Z"
source: github
---

> **Migrated from michael-conrad/opencode-config#303** — this issue concerns `.opencode/` submodule content and was refiled to the correct repository.

## Problem

The spec writer and plan writer decompose implementation work to the **file/concern level**, not the **SC level**. A phase covering one file with 3-5 SCs gets a single RED/GREEN cycle, violating the `091-incremental-build.md` mandate that each item must be a single independently verifiable claim whose PASS/FAIL cannot be split across two assertions.

The current pipeline produces this pattern:

```
Spec SC-1..5 → Phase "Fix create.md" (covers SC-1..5) → one RED → one GREEN → one COMMIT
```

Instead of the mandated pattern:

```
Spec SC-1 → RED for SC-1 → GREEN for SC-1 → COMMIT
Spec SC-2 → RED for SC-2 → GREEN for SC-2 → COMMIT (builds on SC-1)
...
```

This produces monolithic RED/GREEN cycles where multiple SCs are implemented in one pass, making per-SC verification impossible and hiding defects until the audit stage. When a single GREEN phase implements 3-5 SCs, a failure in one SC contaminates the entire phase — the pipeline cannot checkpoint per-SC, cannot roll back per-SC, and cannot verify per-SC.

## Root Cause Analysis

The root cause is a **three-layer granularity mismatch** where each layer decomposes to a different level:

| Layer | File | Current Decomposition Level | Problem |
|-------|------|----------------------------|---------|
| Spec writer | `spec-creation-decomposition/tasks/decompose.md` Step 5 | Per-file/per-concern phases (three-tier structure) | Groups multiple SCs into a single phase |
| Plan writer | `writing-plans-creation/tasks/structure.md` Step 5 | Code-path-to-item mapping | Maps code paths to items, not SCs to items |
| Plan writer | `writing-plans-creation/tasks/write.md` Tier 3 | Per-file items | Items at file/concern level, not SC level |
| Pipeline executor | `implementation-pipeline/tasks/pipeline-executor.md` Step 3 | Per-step checkpoint | Checkpoints per step, not per SC |
| TDD chaining gate | `implementation-pipeline/tasks/tdd-chaining-gate.md` | Per-item independence | Items at file/concern level, never checks SC count |
| Spec creator | `spec-creation-validation/tasks/create.md` Step 1.1 | `plan_phase` field in sc-summary.yaml | Binds SCs to phases, not individual items |

## Goals

- Every SC in a spec maps to exactly one RED/GREEN/verify/commit cycle
- The plan writer produces per-SC items, not per-file or per-concern items
- The pipeline executor checkpoints per SC, not per step
- The TDD chaining gate BLOCKs any item covering multiple SCs
- The sc-summary.yaml binds SCs to individual items, not phases
- `.opencode/AGENTS.md` documents the per-SC decomposition as the standard workflow
- `guidelines/091-incremental-build.md` clarifies "item" means "one SC per item"
- `test-driven-development/tasks/red.md` and `tasks/green.md` reference per-SC targeting

## Non-Goals

- Changing the spec-creation SC table format or evidence type taxonomy
- Changing the audit, cross-validate, or review-prep pipeline stages
- Changing the approval-gate or authorization scope model
- Changing the checkpoint-tag naming convention
- Changing the global pre-phase or global post-phase structure (only per-file phases are replaced)

## Affected Files

| File | Change |
|------|--------|
| `spec-creation-decomposition/tasks/decompose.md` | Replace three-tier per-file phase structure with per-SC item list |
| `writing-plans-creation/tasks/structure.md` | Change Step 5 from code-path-to-item to SC-to-item mapping |
| `writing-plans-creation/tasks/write.md` | Change Tier 3 from per-file to per-SC with SC-ID binding |
| `implementation-pipeline/tasks/pipeline-executor.md` | Add per-SC checkpoint verification with SC-ID in tag |
| `implementation-pipeline/tasks/tdd-chaining-gate.md` | Add SC-level check, BLOCK with `MULTI_SC_ITEM` |
| `spec-creation-validation/tasks/create.md` | Change `plan_phase` to `plan_item` in sc-summary.yaml |
| `.opencode/AGENTS.md` | Add Per-SC Decomposition section |
| `guidelines/091-incremental-build.md` | Clarify "item" = "one SC per item" |
| `test-driven-development/tasks/red.md` | Add per-SC targeting note |
| `test-driven-development/tasks/green.md` | Add per-SC implementation note |

## Implementation Approach

### Phase 1 — Spec Writer Changes

**Files:** `spec-creation-decomposition/tasks/decompose.md`, `spec-creation-validation/tasks/create.md`

1. In `decompose.md`, replace Step 5 (three-tier per-file phase structure) with a per-SC item enumeration step. Remove "one phase per file or concern" language. Add: "For each SC in the spec's success criteria table, create one implementation item with its own RED/GREEN/verify/commit cycle. Items are numbered sequentially. Each item references exactly one SC-ID."

2. In `create.md` Step 1.1, change `plan_phase` field to `plan_item` in the sc-summary.yaml template. Each SC gets an item number instead of a phase group.

### Phase 2 — Documentation Standards

**Files:** `.opencode/AGENTS.md`, `guidelines/091-incremental-build.md`, `test-driven-development/tasks/red.md`, `test-driven-development/tasks/green.md`

1. In `.opencode/AGENTS.md`, add a "Per-SC Decomposition" section documenting the standard: each SC maps to exactly one RED/GREEN/verify/commit cycle. Reference `091-incremental-build.md` and the research card at `.issues/research-cards/per-sc-decomposition-industry-standards.md`.

2. In `guidelines/091-incremental-build.md`, clarify that "item" in the Per-Item TDD Cycle table means "one SC per item." Add a note: "An item is a single success criterion (SC) from the spec. Each SC gets its own RED/GREEN/REFACTOR/COMMIT cycle."

3. In `test-driven-development/tasks/red.md`, add a note in the Required RED Structure section: "The RED phase targets exactly one SC from the spec. Reference the SC-ID in the test file path or test name."

4. In `test-driven-development/tasks/green.md`, add a note in the Exit Criteria section: "The GREEN phase implements exactly one SC. Verify the SC's evidence type before declaring PASS."

### Phase 3 — Plan Writer Changes

**Files:** `writing-plans-creation/tasks/structure.md`, `writing-plans-creation/tasks/write.md`

1. In `structure.md` Step 5, change the mapping directive from code-path-to-item to SC-to-item. The step reads `sc-summary.yaml` and creates one item per SC.

2. In `write.md`, change Tier 3 from "per-item" (file level) to "per-SC" with explicit SC-ID binding. Add validation rule: each item MUST reference exactly one SC ID. Add validation rule 16: "Each item references exactly one SC-ID."

### Phase 4 — Pipeline Changes

**Files:** `implementation-pipeline/tasks/pipeline-executor.md`, `implementation-pipeline/tasks/tdd-chaining-gate.md`

1. In `pipeline-executor.md`, add per-SC checkpoint verification after each RED/GREEN cycle. Include SC-ID in checkpoint tag naming: `{parent}/checkpoint/{issue}/sc-{SC-ID}`.

2. In `tdd-chaining-gate.md`, add SC-level check: verify each item covers exactly one SC. BLOCK with `MULTI_SC_ITEM` if any item covers multiple SCs.

### Phase 5 — Behavioral Tests

**Files:** `.opencode/tests-v2/behaviors/per-sc-decomposition.sh`, `.opencode/tests-v2/behaviors/tdd-chaining-multi-sc-block.sh`

1. Create behavioral test that verifies the plan writer produces per-SC items.
2. Create behavioral test that verifies the TDD chaining gate BLOCKs on multi-SC items.
