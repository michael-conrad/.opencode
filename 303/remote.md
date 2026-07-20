---
remote_issue: 303
remote_url: "https://github.com/michael-conrad/opencode-config/issues/303"
last_sync: 2026-07-20T14:29:29Z
source: github
---

> **Full spec and plan artifacts: [`.issues/303/`](https://github.com/michael-conrad/opencode-config/tree/issues-data/303/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/303/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The spec writer and plan writer decompose work to the **file/concern level**, not the **SC level**. A phase covering one file with 3-5 SCs gets a single RED/GREEN cycle, violating the `091-incremental-build.md` mandate that each item must be a single independently verifiable claim. This produces monolithic RED/GREEN cycles where multiple SCs are implemented in one pass, making per-SC verification impossible and hiding defects until the audit stage.

## Goals

- Every SC in a spec maps to exactly one RED/GREEN/verify/commit cycle
- The plan writer produces per-SC items, not per-file or per-concern items
- The pipeline executor checkpoints per SC, not per step
- The TDD chaining gate BLOCKs any item covering multiple SCs
- `.opencode/AGENTS.md`, `091-incremental-build.md`, `red.md`, and `green.md` document the per-SC standard

## Non-Goals

- Changing the spec-creation SC table format or evidence type taxonomy
- Changing the audit, cross-validate, or review-prep pipeline stages
- Changing the approval-gate or authorization scope model

## Scope

- `spec-creation-decomposition/tasks/decompose.md` — Replace three-tier per-file phase structure with per-SC item list
- `writing-plans-creation/tasks/structure.md` — Change code-path-to-item mapping to SC-to-item mapping
- `writing-plans-creation/tasks/write.md` — Change Tier 3 from per-file items to per-SC items with SC-ID binding
- `implementation-pipeline/tasks/pipeline-executor.md` — Add per-SC checkpoint verification
- `implementation-pipeline/tasks/tdd-chaining-gate.md` — Add SC-level check (BLOCK on multi-SC items)
- `spec-creation-validation/tasks/create.md` — Change `plan_phase` to `plan_item` in sc-summary.yaml
- `.opencode/AGENTS.md` — Add Per-SC Decomposition section
- `guidelines/091-incremental-build.md` — Clarify "item" = "one SC per item"
- `test-driven-development/tasks/red.md` — Add per-SC targeting note
- `test-driven-development/tasks/green.md` — Add per-SC implementation note

## Approach

Change the decomposition model from per-file/per-concern to per-SC. Each SC gets its own RED/GREEN/verify/commit cycle. Document the standard in AGENTS.md, the incremental-build guideline, and the RED/GREEN task files.

## Impact

- **Risk**: Plan files will be longer (more items). Mitigation: split-file format already handles this.
- **Risk**: Pipeline execution will have more steps. Mitigation: per-SC checkpointing is already supported by the checkpoint-tag system.
- **Dependency**: None — this is a self-contained spec change.
- **Call to action**: Review and approve the spec at `.issues/303/spec.md`.

🤖 OpenCode (deepseek-v4-flash) revised
