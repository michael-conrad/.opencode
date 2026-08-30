---
plan_schema_version: "1.0"
issue: 2413
title: "Fix interface-compatibility.yaml: emit dependency_contract section from spec-creation pipeline"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
---

# Implementation Plan — #2413 — Fix interface-compatibility.yaml dependency_contract emission

**Goal:** Ensure spec-creation-generated `interface-compatibility.yaml` always contains a `dependency_contract` section so writing-plans research step 9 does not hard-block with `DEPENDENCY_CONTRACT_NOT_FOUND`.

**Architecture:** Two complementary fixes: (1) the forward spec-creation artifact-generation step emits a `dependency_contract` section populated with concrete dependency data extracted from the existing `interfaces`/`removed_interfaces`/`breaking_changes` keys, and (2) `research.md` step 9 detects a missing `dependency_contract` and auto-backfills it from the existing artifact keys instead of hard-blocking. Phase 3 cross-verifies that both sides agree on the `interface-compatibility.yaml` schema.

**Files:**
- `.opencode/skills/spec-creation/tasks/analyze.md`
- `.opencode/skills/brainstorming/` (top-down-analysis artifact production)
- `.opencode/skills/writing-plans/tasks/research.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Forward spec-creation artifact | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | `.opencode/skills/spec-creation/tasks/analyze.md` | SC-1 | — |
| 2 — Research.md auto-backfill | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | `.opencode/skills/writing-plans/tasks/research.md` | SC-3 | — |
| 3 — Schema agreement verification | `test-driven-development` | `red` → `green` → `verify` → `commit-inline` | Contract templates | SC-2 | 1 |

---

## Phase Details

### Phase 1 — Forward spec-creation artifact generation — emit dependency_contract

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | `.opencode/skills/spec-creation/tasks/analyze.md` |
| SCs | SC-1 |
| Depends On | — |

- [ ] Step 1: Read the current `analyze.md` task file and identify the interface-compatibility.yaml artifact-generation step (Step 5.1.5 or equivalent) to understand where and how the YAML keys (`interfaces`, `removed_interfaces`, `breaking_changes`) are written.
- [ ] Step 2: Write a RED enforcement test (behavioral, using `opencode run`) that asserts a spec-creation pipeline run produces an `interface-compatibility.yaml` containing a `dependency_contract` section. The test must fail initially because the section does not yet exist.
- [ ] Step 3: Implement the GREEN change in `analyze.md` — add a `dependency_contract` section to the emitted `interface-compatibility.yaml`, populated with concrete dependency data extracted from the existing `interfaces`/`removed_interfaces`/`breaking_changes` keys. Each dependency entry maps: `source` (from `interfaces` key), `target` (from `removed_interfaces` or related), `type` ("artifact schema"), and `constraint` (from `breaking_changes` or implied coupling).
- [ ] Step 4: Run `verify` on the GREEN change — confirm the RED test now passes.
- [ ] Step 5: Squash-commit the change via `commit-inline` with message `fix(spec-creation): emit dependency_contract section in interface-compatibility.yaml`.

### Phase 2 — Research.md step 9 adaptation — validate or auto-backfill dependency_contract

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | `.opencode/skills/writing-plans/tasks/research.md` |
| SCs | SC-3 |
| Depends On | — (independent of Phase 1) |

- [ ] Step 1: Read `research.md` step 9 to understand the current `DEPENDENCY_CONTRACT_NOT_FOUND` hard-block behavior and the expected `dependency_contract` section structure.
- [ ] Step 2: Write a RED enforcement test (behavioral, using `opencode run`) that asserts research step 9 can proceed when `interface-compatibility.yaml` lacks a `dependency_contract` section — i.e., it auto-backfills instead of hard-blocking. The test must fail initially.
- [ ] Step 3: Implement the GREEN change in `research.md` step 9 — detect whether `dependency_contract` is present in the loaded `interface-compatibility.yaml`. If present, extract it as-is. If absent, auto-backfill a `dependency_contract` section from the existing `interfaces`, `removed_interfaces`, and `breaking_changes` keys using the same mapping logic Phase 1 uses.
- [ ] Step 4: Run `verify` on the GREEN change — confirm the RED test now passes.
- [ ] Step 5: Squash-commit via `commit-inline` with message `fix(writing-plans): auto-backfill dependency_contract in research step 9`.

### Phase 3 — Producer-consumer schema agreement verification

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` → `green` → `verify` → `commit-inline` |
| Target | Contract templates |
| SCs | SC-2 |
| Depends On | 1 |

- [ ] Step 1: Read the writing-plans contracts/ directory (`contracts/`) to identify the expected schema for `dependency_contract` sections as consumed by `solve`/`plan` tools.
- [ ] Step 2: Write a RED test comparing the `dependency_contract` section structure emitted by Phase 1's `analyze.md` change against the contract schema templates. The test asserts key membership, nesting structure, and required fields match.
- [ ] Step 3: If a mismatch is found, align Phase 1's emission logic to match the contract template schema. Re-run the RED test to confirm GREEN.
- [ ] Step 4: Run the full RED-GREEN-VERIFY cycle end-to-end: verify both Phase 1 and Phase 2 produce compatible `dependency_contract` sections that match the contract templates.
- [ ] Step 5: Squash-commit via `commit-inline` with message `fix(spec-creation): align dependency_contract schema with contract templates`.

---

## Exit Criteria

| Criterion | Description | Phase |
|-----------|-------------|-------|
| C1 | Phase 1 writes `dependency_contract` section to spec-creation-generated `interface-compatibility.yaml` (or Phase 2 research.md auto-backfills instead of hard-blocking) | 1 |
| C2 | Phase 2 research.md step 9 auto-backfills `dependency_contract` from existing keys when section is missing | 2 |
| C3 | Phase 3 confirms spec-creation producer and writing-plans research consumer agree on `interface-compatibility.yaml` schema | 3 |
| C4 | Plan creation for a spec with forward-spec-creation-generated `interface-compatibility.yaml` proceeds without `DEPENDENCY_CONTRACT_NOT_FOUND` | 1, 2 |
| C5 | No regression of closed #2311 / PR #2316 backfill fix | 2 |

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-29T22:31:00Z | `plan_created` | Plan file at `.opencode/.issues/2413/plan.md` — 3 phases |

Co-authored with AI: OpenCode (DeepSeek-V4-Flash)
