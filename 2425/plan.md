---
plan_schema_version: 1
issue: 2425
title: "Change the default test model to ollama/qwen3.8:27b-256k-gguf4"
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Plan — Change default test model to ollama/qwen3.8:27b-256k-gguf4

Issue: [#2425](https://github.com/michael-conrad/.opencode/issues/2425)

## Goal

Change the default test model string from `ollama/qwen3.8:27b-256k` to `ollama/qwen3.8:27b-256k-gguf4` across the single source of truth, the two test-harness fallback literals, and five documentation files. Each target is an atomic literal-value swap verified by a content-verification (grep) test.

## Architecture

- `.opencode/tests-v2/default-model.sh` defines `DEFAULT_TEST_MODEL` as the single source of truth, env-var overridable.
- `.opencode/tests-v2/with-test-home` sources that variable and carries two independent fallback literals (seed_model_config and warmup).
- Five documentation files reference the model literal: `.opencode/AGENTS.md`, `.opencode/docs/model-dependency.md`, `.opencode/README.md`, `.opencode/tests-v2/AGENTS.md`, and the parent root `AGENTS.md`.
- No runtime model-selection logic, GPU/VRAM handling, or other model values change.

## Files

| File | SC | Change |
|------|-----|--------|
| `.opencode/tests-v2/default-model.sh` | SC-1 | Update `DEFAULT_TEST_MODEL` fallback literal to gguf4 value |
| `.opencode/tests-v2/with-test-home` (seed_model_config, ~line 135) | SC-2 | Update seed fallback literal to gguf4 value |
| `.opencode/tests-v2/with-test-home` (warmup, ~line 264) | SC-3 | Update warmup fallback literal to gguf4 value |
| `.opencode/tests-v2/AGENTS.md` | SC-4 | Remove stale pre-2425 literal |
| `.opencode/docs/model-dependency.md` | SC-5 | Remove stale pre-2425 literal |
| `.opencode/README.md` | SC-6 | Remove stale pre-2425 literal |
| `.opencode/AGENTS.md` | SC-7 | Remove stale pre-2425 literal |
| `AGENTS.md` (parent root) | SC-8 | Remove stale pre-2425 literal |

## Dispatch

- test-driven-development — RED/GREEN per-item cycles and regression checks
- verification-before-completion — pre/post-regression verify and pre-pr-gate
- audit — verification-audit adversarial gate
- finishing-a-development-branch — structural checks
- git-workflow-pr — review-prep and PR creation
- completion-core — completion summary

## Blast Radius

Affected files and impact zones from `blast-radius.yaml`. The change is limited to the single source-of-truth literal in `default-model.sh`, two fallback literals in `with-test-home`, and five documentation files. Out of scope: model-selection logic, GPU/VRAM handling, and all other model values beyond the default test model. Each affected file maps to exactly one SC, except `with-test-home`, which carries SC-2 and SC-3.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps | Dispatch |
|-------|------|---------|-----|--------------|-------|----------|
| 1 | Update the DEFAULT_TEST_MODEL source of truth | source of truth literal | SC-1 | — | P1-1 .. P1-7 | test-driven-development |
| 2 | Update the with-test-home fallback literals | harness fallback literals | SC-2, SC-3 | Phase 1 | P2-1 .. P2-13 | test-driven-development |
| 3 | Update tests-v2 AGENTS.md reference | docs tests-v2 | SC-4 | Phase 1 | P3-1 .. P3-7 | test-driven-development |
| 4 | Update model-dependency.md reference | docs model dependency | SC-5 | Phase 1 | P4-1 .. P4-7 | test-driven-development |
| 5 | Update README.md reference | docs README | SC-6 | Phase 1 | P5-1 .. P5-7 | test-driven-development |
| 6 | Update .opencode AGENTS.md reference | docs opencode AGENTS | SC-7 | Phase 1 | P6-1 .. P6-7 | test-driven-development |
| 7 | Update parent root AGENTS.md reference | docs parent AGENTS | SC-8 | Phase 1 | P7-1 .. P7-7 | test-driven-development |

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

## Exit Criteria

- C1. SC-1 passes: the `DEFAULT_TEST_MODEL` fallback in `default-model.sh` equals `ollama/qwen3.8:27b-256k-gguf4`, with the variable name and env-var overridability preserved.
- C2. SC-2 passes: the `seed_model_config()` fallback in `with-test-home` equals `ollama/qwen3.8:27b-256k-gguf4`.
- C3. SC-3 passes: the warmup smoke-test fallback in `with-test-home` equals `ollama/qwen3.8:27b-256k-gguf4`.
- C4. SC-4 passes: the pre-2425 literal is absent from `.opencode/tests-v2/AGENTS.md`.
- C5. SC-5 passes: the pre-2425 literal is absent from `.opencode/docs/model-dependency.md`.
- C6. SC-6 passes: the pre-2425 literal is absent from `.opencode/README.md`.
- C7. SC-7 passes: the pre-2425 literal is absent from `.opencode/AGENTS.md`.
- C8. SC-8 passes: the pre-2425 literal is absent from the parent root `AGENTS.md`.
- C9. The new model is available in the local Ollama instance.
- C10. No runtime model-selection logic, hardware handling, or other model values changed.

---

## Pre-Implementation Steps

- [ ] P0-1. **Coherence gate** (**inline**). Confirm all SCs map to exactly one phase in the phase table and no item covers more than one SC. Verify the phase DAG has no circular dependencies.
- [ ] P0-2. **Baseline check** (**inline**). Verify `.opencode/tests-v2/default-model.sh` currently defines `DEFAULT_TEST_MODEL="${DEFAULT_TEST_MODEL:-ollama/qwen3.8:27b-256k}"`, both `with-test-home` fallbacks carry the pre-2425 literal, and all five documentation files still reference the stale literal.

---

# Phase 1 — Update the DEFAULT_TEST_MODEL source of truth

## Phase Metadata

- **Concern:** Single source of truth literal
- **Files:** `.opencode/tests-v2/default-model.sh`
- **SCs:** SC-1
- **Dependencies:** none
- **Entry condition:** Coherence gate and baseline check passed.
- **Exit condition:** SC-1 GREEN and committed; the source-of-truth value is `ollama/qwen3.8:27b-256k-gguf4`.

**Cost frame:** Verifying the `default-model.sh` fallback equals the gguf4 value costs one grep search. Skipping means the source of truth diverges from the harness and every downstream test run uses the wrong model, surfacing as a behavioral failure in CI.

## Code Path Coverage

- `.opencode/tests-v2/default-model.sh` — `DEFAULT_TEST_MODEL` fallback literal expression (SC-1). Update the literal value only; preserve the variable name and env-var override.

## Cross-Cutting SCs

- All SCs converge on the same model string value `ollama/qwen3.8:27b-256k-gguf4`. SC-1 is the shared surface root; every phase depends on it.

## Interface Boundaries

- `with-test-home` consumes the `DEFAULT_TEST_MODEL` env var defined/exported by `default-model.sh`. The sourcing contract (variable name and env-var overridability) must be preserved; only the fallback literal value changes.

## State Transitions

- `default-model.sh`: `DEFAULT_TEST_MODEL` fallback transitions from `ollama/qwen3.8:27b-256k` to `ollama/qwen3.8:27b-256k-gguf4`.

## Step-by-Step

- [ ] P1-1. **Pre-cleanup** (**inline**). Remove stale artifacts for this phase: `{}`/`artifacts/pipeline-pre-regression-*`, `pipeline-red-*`, `pipeline-green-*`, `pipeline-post-regression-*`, `pipeline-verify-*` for item 1. Verify the local Ollama instance has `ollama/qwen3.8:27b-256k-gguf4` available by running the model-list check.
- [ ] P1-2. **Pre-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")` for issue 2425. Run existing regression patterns to establish the baseline. Exit 0 expected.
- [ ] P1-3. **Pre-regression verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Confirm the pre-regression result is clean before the RED phase.
- [ ] P1-4. **RED for SC-1** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. `test-2376-sc1-red.sh` asserts the `DEFAULT_TEST_MODEL` fallback in `.opencode/tests-v2/default-model.sh` equals `ollama/qwen3.8:27b-256k-gguf4`. Because the fallback is still the pre-2425 literal, the assertion FAILS. The test is content-verification (string evidence), not behavioral.
- [ ] P1-5. **GREEN for SC-1** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the fallback literal in `default-model.sh` with the gguf4 value, preserving the variable name and env-var override. No scope creep — only the minimum literal change.
- [ ] P1-6. **Post-regression and verify for SC-1** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, then `task(..., prompt: "execute verify task from verification-before-completion")`. Run `test-2376-sc1-red.sh`; it must exit 0. Confirm SC-1 verdict is a clean PASS with string evidence.
- [ ] P1-7. **Commit for SC-1** (**inline**). Orchestrator runs `git add <default-model.sh> <test-2376-sc1-red.sh> && git commit -m "<message>"`. Commit the source-of-truth change and the assertion update as one atomic slice. No co-author trailer on implementation commits.

## Phase Completion Block

- Verify SC-1 against the success criterion: the `DEFAULT_TEST_MODEL` fallback in `default-model.sh` equals `ollama/qwen3.8:27b-256k-gguf4`, with the variable name and env-var overridability preserved. Report `[item 1] [PASS|FAIL]`.

## Concern Transition

- Source-of-truth value is updated. Proceed to Phase 2, which updates the harness fallback literals that mirror this value.

---

# Phase 2 — Update the with-test-home fallback literals

## Phase Metadata

- **Concern:** Test harness fallback literals
- **Files:** `.opencode/tests-v2/with-test-home`
- **SCs:** SC-2, SC-3
- **Dependencies:** Phase 1 (SC-1)
- **Entry condition:** SC-1 committed and verified.
- **Exit condition:** SC-2 and SC-3 GREEN and committed; both harness fallbacks use `ollama/qwen3.8:27b-256k-gguf4`.

**Cost frame:** Verifying the `seed_model_config()` fallback costs one grep search; skipping means the harness seeds `opencode.jsonc` with the stale model, surfacing as a runtime failure in the harness. Verifying the warmup fallback costs one grep search; skipping means the warmup smoke test runs the wrong model.

## Code Path Coverage

- `.opencode/tests-v2/with-test-home` `seed_model_config()` — fallback literal `local default_model="${DEFAULT_TEST_MODEL:-...}"` used to seed opencode.jsonc (SC-2).
- `.opencode/tests-v2/with-test-home` warmup smoke-test path — un-env-wrapped fallback `default_model="..."` (SC-3).

## Cross-Cutting SCs

- SC-2 and SC-3 share the `concern_harness_fallbacks` concern but are independent literals in the same file. Each maps to one atomic deliverable and one item.

## Interface Boundaries

- `seed_model_config()` writes the `default_model` value into the generated `opencode.jsonc`; the seeded value must be the gguf4 literal. The `DEFAULT_TEST_MODEL` env-var sourcing contract is preserved. No schema or key change.

## State Transitions

- `with-test-home` seed fallback: `ollama/qwen3.8:27b-256k` → `ollama/qwen3.8:27b-256k-gguf4` (SC-2).
- `with-test-home` warmup fallback: `ollama/qwen3.8:27b-256k` → `ollama/qwen3.8:27b-256k-gguf4` (SC-3).

## Item 2 — SC-2 (seed_model_config fallback)

- [ ] P2-1. **Pre-cleanup** (**inline**). Remove stale `pipeline-*` artifacts for this phase's steps.
- [ ] P2-2. **Pre-regression** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-0 task from test-driven-development")`. Establish regression baseline. Exit 0 expected.
- [ ] P2-3. **Pre-regression verify** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Confirm clean baseline.
- [ ] P2-4. **RED for SC-2** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. `test-2376-sc2-red.sh` asserts the `seed_model_config()` fallback in `with-test-home` equals `ollama/qwen3.8:27b-256k-gguf4`. It FAILS because the seed fallback is still the pre-2425 literal. Content-verification (string evidence).
- [ ] P2-5. **GREEN for SC-2** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the `seed_model_config()` fallback literal in `with-test-home` with the gguf4 value. No scope creep.
- [ ] P2-6. **Post-regression and verify for SC-2** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, then `task(..., prompt: "execute verify task from verification-before-completion")`. Run `test-2376-sc2-red.sh`; it must exit 0. Confirm SC-2 clean PASS.
- [ ] P2-7. **Commit for SC-2** (**inline**). Orchestrator runs `git add <with-test-home> <test-2376-sc2-red.sh> && git commit -m "<message>"`. Atomic slice; no co-author trailer.

## Item 3 — SC-3 (warmup fallback)

- [ ] P2-8. **Pre-cleanup** (**inline**). Remove stale `pipeline-*` artifacts.
- [ ] P2-9. **RED for SC-3** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. `test-2376-sc3-red.sh` asserts the warmup fallback in `with-test-home` equals `ollama/qwen3.8:27b-256k-gguf4`. It FAILS because the warmup fallback is still the pre-2425 literal. Content-verification (string evidence).
- [ ] P2-10. **GREEN for SC-3** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the warmup fallback literal (independent, un-env-wrapped) in `with-test-home` with the gguf4 value. No scope creep.
- [ ] P2-11. **Post-regression and verify for SC-3** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`, then `task(..., prompt: "execute verify task from verification-before-completion")`. Run `test-2376-sc3-red.sh`; it must exit 0. Confirm SC-3 clean PASS.
- [ ] P2-12. **Commit for SC-3** (**inline**). Orchestrator runs `git add <with-test-home> <test-2376-sc3-red.sh> && git commit -m "<message>"`. Atomic slice; no co-author trailer.

## Phase Completion Block

- Verify SC-2 and SC-3 against their success criteria: the `seed_model_config()` fallback and the warmup fallback each equal `ollama/qwen3.8:27b-256k-gguf4`. Report `[item 2] [PASS|FAIL]`, `[item 3] [PASS|FAIL]`.

## Concern Transition

- Both harness fallbacks now use the gguf4 value. Proceed to the documentation-file phases (3 through 7), each of which removes the stale pre-2425 literal from one documentation file.

---

# Phase 3 — Update tests-v2 AGENTS.md reference

## Phase Metadata

- **Concern:** tests-v2 documentation reference
- **Files:** `.opencode/tests-v2/AGENTS.md`
- **SCs:** SC-4
- **Dependencies:** Phase 1 (SC-1)
- **Entry condition:** SC-1 committed and verified.
- **Exit condition:** SC-4 GREEN and committed; the stale literal is absent from `.opencode/tests-v2/AGENTS.md`.

**Cost frame:** Verifying the stale literal is absent from `.opencode/tests-v2/AGENTS.md` costs one grep search. Skipping means agent-facing test documentation cites a stale model, misleading agents that read it.

## Code Path Coverage

- `.opencode/tests-v2/AGENTS.md` — documentation reference to the pre-2425 model literal. Replace with the gguf4 value (SC-4).

## Cross-Cutting SCs

- SC-8 is the only cross-repo SC (parent root). SC-4 through SC-7 stay within the `.opencode` submodule.

## Interface Boundaries

- None — documentation file, no runtime interface.

## State Transitions

- `.opencode/tests-v2/AGENTS.md`: stale literal present → stale literal absent.

## Step-by-Step

- [ ] P3-1. **Pre-cleanup** (**inline**). Remove stale `pipeline-*` artifacts.
- [ ] P3-2. **RED for SC-4** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. The SC-4 assertion checks the stale literal is absent from `.opencode/tests-v2/AGENTS.md`. It FAILS while the stale literal is present. Content-verification (string evidence).
- [ ] P3-3. **GREEN for SC-4** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the pre-2425 default literal in `.opencode/tests-v2/AGENTS.md` with the gguf4 value. No scope creep.
- [ ] P3-4. **Verify for SC-4** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run the SC-4 verification; it must exit 0. Confirm SC-4 clean PASS.
- [ ] P3-5. **Commit for SC-4** (**inline**). Orchestrator runs `git add <.opencode/tests-v2/AGENTS.md> <SC-4 assertion> && git commit -m "<message>"`. Atomic slice; no co-author trailer.

## Phase Completion Block

- Verify SC-4 against its criterion: the stale literal is absent from `.opencode/tests-v2/AGENTS.md`. Report `[item 4] [PASS|FAIL]`.

## Concern Transition

- `.opencode/tests-v2/AGENTS.md` is clean. Proceed to Phase 4.

---

# Phase 4 — Update model-dependency.md reference

## Phase Metadata

- **Concern:** model-dependency documentation reference
- **Files:** `.opencode/docs/model-dependency.md`
- **SCs:** SC-5
- **Dependencies:** Phase 1 (SC-1)
- **Entry condition:** SC-1 committed and verified.
- **Exit condition:** SC-5 GREEN and committed; the stale literal is absent from `.opencode/docs/model-dependency.md`.

**Cost frame:** Verifying the stale literal is absent from `.opencode/docs/model-dependency.md` costs one grep search. Skipping means the model dependency documentation cites a stale model, misleading agents that read it.

## Code Path Coverage

- `.opencode/docs/model-dependency.md` — documentation reference to the pre-2425 model literal. Replace with the gguf4 value (SC-5).

## Cross-Cutting SCs

- None beyond the shared model string value.

## Interface Boundaries

- None — documentation file, no runtime interface.

## State Transitions

- `.opencode/docs/model-dependency.md`: stale literal present → stale literal absent.

## Step-by-Step

- [ ] P4-1. **Pre-cleanup** (**inline**). Remove stale `pipeline-*` artifacts.
- [ ] P4-2. **RED for SC-5** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. The SC-5 assertion checks the stale literal is absent from `.opencode/docs/model-dependency.md`. It FAILS while the stale literal is present. Content-verification (string evidence).
- [ ] P4-3. **GREEN for SC-5** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the pre-2425 default literal in `.opencode/docs/model-dependency.md` with the gguf4 value. No scope creep.
- [ ] P4-4. **Verify for SC-5** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run the SC-5 verification; it must exit 0. Confirm SC-5 clean PASS.
- [ ] P4-5. **Commit for SC-5** (**inline**). Orchestrator runs `git add <.opencode/docs/model-dependency.md> <SC-5 assertion> && git commit -m "<message>"`. Atomic slice; no co-author trailer.

## Phase Completion Block

- Verify SC-5 against its criterion: the stale literal is absent from `.opencode/docs/model-dependency.md`. Report `[item 5] [PASS|FAIL]`.

## Concern Transition

- `.opencode/docs/model-dependency.md` is clean. Proceed to Phase 5.

---

# Phase 5 — Update README.md reference

## Phase Metadata

- **Concern:** README documentation reference
- **Files:** `.opencode/README.md`
- **SCs:** SC-6
- **Dependencies:** Phase 1 (SC-1)
- **Entry condition:** SC-1 committed and verified.
- **Exit condition:** SC-6 GREEN and committed; the stale literal is absent from `.opencode/README.md`.

**Cost frame:** Verifying the stale literal is absent from `.opencode/README.md` costs one grep search. Skipping means the README cites a stale model, misleading agents that read it.

## Code Path Coverage

- `.opencode/README.md` — documentation reference to the pre-2425 model literal. Replace with the gguf4 value (SC-6).

## Cross-Cutting SCs

- None beyond the shared model string value.

## Interface Boundaries

- None — documentation file, no runtime interface.

## State Transitions

- `.opencode/README.md`: stale literal present → stale literal absent.

## Step-by-Step

- [ ] P5-1. **Pre-cleanup** (**inline**). Remove stale `pipeline-*` artifacts.
- [ ] P5-2. **RED for SC-6** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. The SC-6 assertion checks the stale literal is absent from `.opencode/README.md`. It FAILS while the stale literal is present. Content-verification (string evidence).
- [ ] P5-3. **GREEN for SC-6** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the pre-2425 default literal in `.opencode/README.md` with the gguf4 value. No scope creep.
- [ ] P5-4. **Verify for SC-6** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run the SC-6 verification; it must exit 0. Confirm SC-6 clean PASS.
- [ ] P5-5. **Commit for SC-6** (**inline**). Orchestrator runs `git add <.opencode/README.md> <SC-6 assertion> && git commit -m "<message>"`. Atomic slice; no co-author trailer.

## Phase Completion Block

- Verify SC-6 against its criterion: the stale literal is absent from `.opencode/README.md`. Report `[item 6] [PASS|FAIL]`.

## Concern Transition

- `.opencode/README.md` is clean. Proceed to Phase 6.

---

# Phase 6 — Update .opencode AGENTS.md reference

## Phase Metadata

- **Concern:** .opencode AGENTS.md documentation reference
- **Files:** `.opencode/AGENTS.md`
- **SCs:** SC-7
- **Dependencies:** Phase 1 (SC-1)
- **Entry condition:** SC-1 committed and verified.
- **Exit condition:** SC-7 GREEN and committed; the stale literal is absent from `.opencode/AGENTS.md`.

**Cost frame:** Verifying the stale literal is absent from `.opencode/AGENTS.md` costs one grep search. Skipping means agent-facing rules cite a stale model, undermining the CRITICAL VIOLATION enforcement text and misleading agents that read it.

## Code Path Coverage

- `.opencode/AGENTS.md` — documentation reference to the pre-2425 model literal. Replace with the gguf4 value (SC-7).

## Cross-Cutting SCs

- None beyond the shared model string value.

## Interface Boundaries

- None — documentation file, no runtime interface.

## State Transitions

- `.opencode/AGENTS.md`: stale literal present → stale literal absent.

## Step-by-Step

- [ ] P6-1. **Pre-cleanup** (**inline**). Remove stale `pipeline-*` artifacts.
- [ ] P6-2. **RED for SC-7** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. The SC-7 assertion checks the stale literal is absent from `.opencode/AGENTS.md`. It FAILS while the stale literal is present. Content-verification (string evidence).
- [ ] P6-3. **GREEN for SC-7** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the pre-2425 default literal in `.opencode/AGENTS.md` with the gguf4 value. No scope creep.
- [ ] P6-4. **Verify for SC-7** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run the SC-7 verification; it must exit 0. Confirm SC-7 clean PASS.
- [ ] P6-5. **Commit for SC-7** (**inline**). Orchestrator runs `git add <.opencode/AGENTS.md> <SC-7 assertion> && git commit -m "<message>"`. Atomic slice; no co-author trailer.

## Phase Completion Block

- Verify SC-7 against its criterion: the stale literal is absent from `.opencode/AGENTS.md`. Report `[item 7] [PASS|FAIL]`.

## Concern Transition

- `.opencode/AGENTS.md` is clean. Proceed to Phase 7.

---

# Phase 7 — Update parent root AGENTS.md reference

## Phase Metadata

- **Concern:** Parent root AGENTS.md documentation reference
- **Files:** `AGENTS.md` (parent repo root)
- **SCs:** SC-8
- **Dependencies:** Phase 1 (SC-1); cross-repo — targets the parent repo, not the `.opencode` submodule
- **Entry condition:** SC-1 committed and verified.
- **Exit condition:** SC-8 GREEN and committed; the stale literal is absent from the parent root `AGENTS.md`.

**Cost frame:** Verifying the stale literal is absent from the parent root `AGENTS.md` costs one grep search. Skipping means agent-facing rules cite a stale model, misleading agents that read it.

## Code Path Coverage

- `AGENTS.md` (parent root) — documentation reference to the pre-2425 model literal. Replace with the gguf4 value (SC-8).

## Cross-Cutting SCs

- SC-8 is the only cross-repo SC: it targets the parent root `AGENTS.md`, which lives in the parent repo rather than the `.opencode` submodule. This is the only cross-repo boundary in the change.

## Interface Boundaries

- None — documentation file, no runtime interface. The submodule pointer is unaffected; this file lives in the parent repo.

## State Transitions

- Parent root `AGENTS.md`: stale literal present → stale literal absent.

## Step-by-Step

- [ ] P7-1. **Pre-cleanup** (**inline**). Remove stale `pipeline-*` artifacts.
- [ ] P7-2. **RED for SC-8** (**sub-agent**). Dispatch `task(..., prompt: "execute red task from test-driven-development")`. The SC-8 assertion checks the stale literal is absent from the parent root `AGENTS.md`. It FAILS while the stale literal is present. Content-verification (string evidence).
- [ ] P7-3. **GREEN for SC-8** (**sub-agent**). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. Replace the pre-2425 default literal in the parent root `AGENTS.md` with the gguf4 value. No scope creep.
- [ ] P7-4. **Verify for SC-8** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Run the SC-8 verification; it must exit 0. Confirm SC-8 clean PASS.
- [ ] P7-5. **Commit for SC-8** (**inline**). Orchestrator runs `git add <parent root AGENTS.md> <SC-8 assertion> && git commit -m "<message>"`. This commit includes the parent-repo change alongside the submodule pointer update. Atomic slice; no co-author trailer.

## Phase Completion Block

- Verify SC-8 against its criterion: the stale literal is absent from the parent root `AGENTS.md`. Report `[item 8] [PASS|FAIL]`.

## Concern Transition

- All eight SCs are GREEN. Proceed to post-implementation steps.

---

## Post-Implementation Steps

- [ ] PX-1. **Structural checks** (**sub-agent**). Dispatch `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. Run the finishing checklist, including markdown lint and format checks on the modified documentation files.
- [ ] PX-2. **Verification audit** (**sub-agent**). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by the validator, evaluator, and arbiter in sequence. Confirm all SC verdicts are clean PASS; any non-clean pass (DONE_WITH_CONCERNS) or evidence-type mismatch is coerced to FAIL.
- [ ] PX-3. **Z3 check** (**inline**). Orchestrator runs `.opencode/tools/solve check --state-path ... --contract-path ...` directly to verify phase solvability and dependency ordering.
- [ ] PX-4. **Regression check** (**sub-agent**). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. Final regression check before PR.
- [ ] PX-5. **Pre-PR gate** (**sub-agent**). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. Reads all SC verdicts; BLOCKs if any FAIL. Also verify the new model is available in the local Ollama instance and confirm no out-of-scope behavior changed.
- [ ] PX-6. **Review prep** (**sub-agent**). Dispatch `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. Prepare the PR review context.
- [ ] PX-7. **Create PR** (**sub-agent**). Dispatch `task(..., prompt: "execute create task from git-workflow-pr")`. Create the pull request only when `for_pr` scope is active or an explicit create-PR instruction is given.
- [ ] PX-8. **Completion summary** (**sub-agent**). Dispatch `task(..., prompt: "execute completion task from completion-core")`. Generate the completion executive summary.

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-31T23:24:17Z | `plan_created` | Plan file: `.opencode/.issues/2425/plan.md`; 7 phases, 8 SCs |
