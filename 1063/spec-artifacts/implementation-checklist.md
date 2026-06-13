<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

# Implementation Checklist — Pipeline Enforcement (#1063)

> Actionable per-step checklist mapping each implementation step to its SC-IDs.
> Check off items as completed. Each item maps to a TDD cycle in `plan.md`.

## Pre-Flight

- [ ] Verify branch exists: `feature/1063-pipeline-enforcement`
- [ ] Verify `.opencode/.issues/1063/spec-artifacts/pipeline-state-machine.yaml` exists (Z3 contract — already created)
- [ ] Verify spec-auditor #1060 is merged (dependency)
- [ ] Verify plan-to-pipeline handoff #1062 is merged (dependency)

## Phase 1: Pipeline Routing Table Updates (SKILL.md)

### TDD-1: sc-coherence-gate evidence-type uplift (SC-6)
- [ ] **RED:** Write test asserting absence of `evidence-type uplift` in sc-coherence-gate row — expect FAIL
- [ ] **GREEN:** Edit sc-coherence-gate row: add "evidence-type uplift scan + substrate classification" — test PASS
- [ ] **REFACTOR:** Verify table alignment

### TDD-2: pre-red-baseline doc-source-currency (SC-7, SC-8)
- [ ] **RED:** Write test asserting absence of `doc-source-currency` in pre-red-baseline row — expect FAIL
- [ ] **GREEN:** Edit pre-red-baseline row: add "doc-source-currency + SC-ID cross-ref traceability" — test PASS
- [ ] **REFACTOR:** Verify row formatting

### TDD-3: green-doublecheck semantic-intent (SC-9)
- [ ] **RED:** Write test asserting absence of `semantic-intent` in green-doublecheck row — expect FAIL
- [ ] **GREEN:** Edit green-doublecheck row: add "semantic-intent verification" — test PASS
- [ ] **REFACTOR:** Verify adjacent rows

### TDD-4: post-red-enforcement routing row (SC-1, SC-5)
- [ ] **RED:** Write test: `post-red-enforcement` row absent — expect FAIL (count = 0)
- [ ] **GREEN:** Insert row between `red-doublecheck` and `green-phase` — test PASS (count > 0)
- [ ] **GREEN:** Add pre-cleanup entry for `post-red-enforcement` in Step-Specific Pre-Cleanup table
- [ ] **REFACTOR:** Verify `green-phase` adjacency

### TDD-5: post-green-enforcement routing row (SC-2, SC-5)
- [ ] **RED:** Write test: `post-green-enforcement` row absent — expect FAIL (count = 0)
- [ ] **GREEN:** Insert row between `green-phase` and `checkpoint-commit` — test PASS (count > 0)
- [ ] **GREEN:** Add pre-cleanup entry for `post-green-enforcement` in Step-Specific Pre-Cleanup table
- [ ] **REFACTOR:** Verify `checkpoint-commit` adjacency

### TDD-6: Step labels list (SC-10)
- [ ] **RED:** Count step labels = 14 — expect FAIL
- [ ] **GREEN:** Insert `post-red-enforcement` and `post-green-enforcement` — count = 16 — test PASS
- [ ] **REFACTOR:** Run Z3 solve check at Phase 1→2 boundary

### Phase 1 Checkpoint
- [ ] Tag: `git tag opencode-config/checkpoint/1063/phase-1-opencode`
- [ ] Z3 solve check: `solve check --state-path ./tmp/1063/state/ --contract-path .opencode/.issues/1063/spec-artifacts/pipeline-state-machine.yaml`
- [ ] Verify all Phase 1 SCs: SC-1, SC-2, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10
- [ ] Verify no Phase 2 SCs tested (no cross-phase over-verification)
- [ ] Verify no regression on existing 14-step adjacency

## Phase 2: TDD Task Enforcement Updates

### TDD-7: RED persona enforcement (SC-3)
- [ ] **RED:** Write test: grep red.md for `MUST NOT.*(implementation|source)` — expect FAIL (no match)
- [ ] **GREEN:** Add RED Persona Enforcement block to red.md after Required RED Structure — test PASS
- [ ] **REFACTOR:** `uvx pymarkdownlnt scan -r .opencode/skills/test-driven-development/tasks/red.md`

### TDD-8: GREEN persona enforcement (SC-4)
- [ ] **RED:** Write test: grep green.md for `MUST NOT.*(test|test file)` — expect FAIL (no match)
- [ ] **GREEN:** Add GREEN Persona Enforcement block to green.md after Verification Command — test PASS
- [ ] **REFACTOR:** `uvx pymarkdownlnt scan -r .opencode/skills/test-driven-development/tasks/green.md`

### TDD-9: TDD heading format requirement (SC-11, SC-12)
- [ ] **RED:** Write test: grep TDD SKILL.md for SC-ID heading format — expect FAIL
- [ ] **GREEN:** Add TDD Heading Format Requirement section to TDD SKILL.md after Five Core Principles — test PASS
- [ ] **REFACTOR:** Verify SKILL.md word count ≤ 4,000

### Phase 2 Checkpoint
- [ ] Tag: `git tag opencode-config/checkpoint/1063/phase-2-opencode`
- [ ] Z3 terminal solve check: all invariants satisfied
- [ ] Verify all Phase 2 SCs: SC-3, SC-4, SC-11, SC-12
- [ ] Verify no Phase 1 SCs retested (no cross-phase over-verification)

## Post-Implementation (for_pr scope — PR creation authorized)

- [ ] Run lint: `uvx ruff check --fix src/` (if any Python files modified)
- [ ] Run markdown lint: `uvx pymarkdownlnt scan -r .opencode/skills/`
- [ ] Verify formatting: `uvx ruff format src/` (if Python files modified)
- [ ] Run behavioral enforcement tests: `bash .opencode/tests/test-enforcement.sh --changed`
- [ ] Run Z3 terminal solve check: `solve check --state-path ./tmp/1063/state/ --contract-path .opencode/.issues/1063/spec-artifacts/pipeline-state-machine.yaml`
- [ ] Commit Phase 1 + Phase 2 as atomic commits (2 commits, single PR)
- [ ] Push: `git push -u origin feature/1063-pipeline-enforcement`
- [ ] Create PR: target `dev`, stacked PR strategy (feature/1063-pipeline-enforcement → dev)

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)