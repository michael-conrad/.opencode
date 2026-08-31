---
title: "[SPEC] Change default test model to ollama/qwen3.8:27b-256k-gguf4"
labels:
  - needs-approval
  - spec-draft
remote_issue: 2425
remote_url: https://github.com/michael-conrad/.opencode/issues/2425
promoted_at: 2026-08-31T15:15:00Z
---

> **Full spec and artifacts: [`.opencode/.issues/2425/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2425)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2425/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The default test model for the `opencode run` test framework is `ollama/qwen3.8:27b-256k`. It must be changed to `ollama/qwen3.8:27b-256k-gguf4` across the single source of truth, the harness fallback strings, the behavioral test assertions, and all documentation references. |
| 2 | **Root Cause / Motivation** | The test framework's default model must be updated to the gguf4 build of the same model. The value is defined once in `default-model.sh` as `DEFAULT_TEST_MODEL` and mirrored in harness fallbacks, test assertions, and documentation. A coordinated change is required so every reference names the same model string or tests and documentation drift. |
| 3 | **Approach Chosen** | Update the single source of truth `DEFAULT_TEST_MODEL` in `default-model.sh` to the gguf4 value, then propagate the change to the two fallback literals in `with-test-home` (one SC each) and the five documentation files (one SC each). Each SC is a single-target literal-value swap verified by content-verification (grep) tests. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: leave the fallback literals in `with-test-home` un-env-wrapped and independent.** Discarded because the warmup fallback at line 264 is a separate un-env-wrapped literal that would silently diverge from the source of truth, breaking model consistency across the harness. |
| 5 | **Key Design Decisions** | **Decision: keep `DEFAULT_TEST_MODEL` as the single source of truth and mirror it in all fallbacks.** Tradeoff: requires a coordinated multi-file change, but preserves a single authoritative value and keeps the env-var override honored. **Decision: use content-verification (grep) tests rather than behavioral tests.** Tradeoff: this is a configuration/documentation literal change, not a runtime-behavioral change, so grep-based assertion is the correct evidence type. **Decision: decompose the two `with-test-home` fallbacks and the five documentation files into atomic single-target SCs.** Tradeoff: more SCs, but each SC maps to exactly one deliverable, satisfying Atomicity and Single Deliverable criteria. |
| 6 | **User Intent / Original Prompt** | Change the default test model to `ollama/qwen3.8:27b-256k-gguf4`. |

## 2. Not Included

- **Model-selection logic** — The test framework's model-selection logic is unchanged; only the default literal value changes.
- **GPU/VRAM handling** — No changes to hardware handling.
- **Other model values** — No model value other than the default test model is changed.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `DEFAULT_TEST_MODEL` fallback literal in `.opencode/tests-v2/default-model.sh` SHALL equal `ollama/qwen3.8:27b-256k-gguf4`, with the variable name and env-var overridability preserved. | string | `test-2376-sc1-red.sh` content-verification grep of the exact fallback pattern |
| SC-2 | The fallback model literal in the `seed_model_config()` path of `.opencode/tests-v2/with-test-home` SHALL equal `ollama/qwen3.8:27b-256k-gguf4`. | string | `test-2376-sc2-red.sh` content-verification grep of the `seed_model_config()` fallback literal |
| SC-3 | The fallback model literal in the warmup smoke-test path of `.opencode/tests-v2/with-test-home` SHALL equal `ollama/qwen3.8:27b-256k-gguf4`. | string | `test-2376-sc3-red.sh` content-verification grep of the warmup fallback literal |
| SC-4 | The pre-2425 default literal `ollama/qwen3.8:27b-256k` SHALL be absent from `.opencode/tests-v2/AGENTS.md`. | string | `test-2376-sc4-red.sh` content-verification grep asserting the old literal is absent from `.opencode/tests-v2/AGENTS.md` |
| SC-5 | The pre-2425 default literal `ollama/qwen3.8:27b-256k` SHALL be absent from `.opencode/docs/model-dependency.md`. | string | `test-2376-sc5-red.sh` content-verification grep asserting the old literal is absent from `.opencode/docs/model-dependency.md` |
| SC-6 | The pre-2425 default literal `ollama/qwen3.8:27b-256k` SHALL be absent from `.opencode/README.md`. | string | `test-2376-sc6-red.sh` content-verification grep asserting the old literal is absent from `.opencode/README.md` |
| SC-7 | The pre-2425 default literal `ollama/qwen3.8:27b-256k` SHALL be absent from `.opencode/AGENTS.md`. | string | `test-2376-sc7-red.sh` content-verification grep asserting the old literal is absent from `.opencode/AGENTS.md` |
| SC-8 | The pre-2425 default literal `ollama/qwen3.8:27b-256k` SHALL be absent from the parent root `AGENTS.md`. | string | `test-2376-sc8-red.sh` content-verification grep asserting the old literal is absent from the parent root `AGENTS.md` |

## 4. Requirements

- R-1. The `DEFAULT_TEST_MODEL` fallback literal in `.opencode/tests-v2/default-model.sh` SHALL be changed from `ollama/qwen3.8:27b-256k` to `ollama/qwen3.8:27b-256k-gguf4`.
- R-2. The fallback model strings in `.opencode/tests-v2/with-test-home` (the `seed_model_config()` path and the warmup smoke-test path) SHALL be updated to `ollama/qwen3.8:27b-256k-gguf4`.
- R-3. The documentation references in `.opencode/tests-v2/AGENTS.md` SHALL be updated to the gguf4 value.
- R-4. The documentation references in `.opencode/docs/model-dependency.md` SHALL be updated to the gguf4 value.
- R-5. The documentation references in `.opencode/README.md` SHALL be updated to the gguf4 value.
- R-6. The documentation reference in `.opencode/AGENTS.md` SHALL be updated to the gguf4 value.
- R-7. The documentation reference in the parent root `AGENTS.md` SHALL be updated to the gguf4 value.
- R-8. The behavioral test scripts asserting the default model value (`test-2376-sc1-red.sh`, `test-2376-sc2-red.sh`, `test-2376-sc3-red.sh`) SHALL be updated so their assertion literals match the gguf4 value.
- R-9. The test framework's model-selection logic, GPU/VRAM handling, and other model values beyond the default test model SHALL NOT be changed.
- R-10. The new model `ollama/qwen3.8:27b-256k-gguf4` SHALL be available in the local Ollama instance.

## 5. Items

### Item 1 (SC-1): Update the `DEFAULT_TEST_MODEL` fallback in `default-model.sh`

- RED: `test-2376-sc1-red.sh` asserts the fallback equals `ollama/qwen3.8:27b-256k-gguf4`; currently stale, so it fails.
- GREEN: Replace the fallback literal in `default-model.sh` with the gguf4 value.
- verify: Run `test-2376-sc1-red.sh`; it exits 0.
- commit: Commit the `default-model.sh` change and the `test-2376-sc1-red.sh` assertion update together.

### Item 2 (SC-2): Update the `seed_model_config()` fallback literal in `with-test-home`

- RED: `test-2376-sc2-red.sh` asserts the `seed_model_config()` fallback equals `ollama/qwen3.8:27b-256k-gguf4`; currently stale, so it fails.
- GREEN: Replace the `seed_model_config()` fallback literal in `with-test-home` with the gguf4 value.
- verify: Run `test-2376-sc2-red.sh`; it exits 0.
- commit: Commit the `with-test-home` change and the `test-2376-sc2-red.sh` assertion update together.

### Item 3 (SC-3): Update the warmup smoke-test fallback literal in `with-test-home`

- RED: `test-2376-sc3-red.sh` asserts the warmup fallback equals `ollama/qwen3.8:27b-256k-gguf4`; currently stale, so it fails.
- GREEN: Replace the warmup fallback literal in `with-test-home` with the gguf4 value.
- verify: Run `test-2376-sc3-red.sh`; it exits 0.
- commit: Commit the `with-test-home` change and the `test-2376-sc3-red.sh` assertion update together.

### Item 4 (SC-4): Update documentation reference in `.opencode/tests-v2/AGENTS.md`

- RED: `test-2376-sc4-red.sh` asserts the pre-2425 default literal `ollama/qwen3.8:27b-256k` is absent from `.opencode/tests-v2/AGENTS.md`; currently present, so it fails.
- GREEN: Replace the pre-2425 default literal in `.opencode/tests-v2/AGENTS.md` with the gguf4 value.
- verify: Run `test-2376-sc4-red.sh`; it exits 0.
- commit: Commit the `.opencode/tests-v2/AGENTS.md` change and the `test-2376-sc4-red.sh` assertion update together.

### Item 5 (SC-5): Update documentation reference in `.opencode/docs/model-dependency.md`

- RED: `test-2376-sc5-red.sh` asserts the pre-2425 default literal `ollama/qwen3.8:27b-256k` is absent from `.opencode/docs/model-dependency.md`; currently present, so it fails.
- GREEN: Replace the pre-2425 default literal in `.opencode/docs/model-dependency.md` with the gguf4 value.
- verify: Run `test-2376-sc5-red.sh`; it exits 0.
- commit: Commit the `.opencode/docs/model-dependency.md` change and the `test-2376-sc5-red.sh` assertion update together.

### Item 6 (SC-6): Update documentation reference in `.opencode/README.md`

- RED: `test-2376-sc6-red.sh` asserts the pre-2425 default literal `ollama/qwen3.8:27b-256k` is absent from `.opencode/README.md`; currently present, so it fails.
- GREEN: Replace the pre-2425 default literal in `.opencode/README.md` with the gguf4 value.
- verify: Run `test-2376-sc6-red.sh`; it exits 0.
- commit: Commit the `.opencode/README.md` change and the `test-2376-sc6-red.sh` assertion update together.

### Item 7 (SC-7): Update documentation reference in `.opencode/AGENTS.md`

- RED: `test-2376-sc7-red.sh` asserts the pre-2425 default literal `ollama/qwen3.8:27b-256k` is absent from `.opencode/AGENTS.md`; currently present, so it fails.
- GREEN: Replace the pre-2425 default literal in `.opencode/AGENTS.md` with the gguf4 value.
- verify: Run `test-2376-sc7-red.sh`; it exits 0.
- commit: Commit the `.opencode/AGENTS.md` change and the `test-2376-sc7-red.sh` assertion update together.

### Item 8 (SC-8): Update documentation reference in the parent root `AGENTS.md`

- RED: `test-2376-sc8-red.sh` asserts the pre-2425 default literal `ollama/qwen3.8:27b-256k` is absent from the parent root `AGENTS.md`; currently present, so it fails.
- GREEN: Replace the pre-2425 default literal in the parent root `AGENTS.md` with the gguf4 value.
- verify: Run `test-2376-sc8-red.sh`; it exits 0.
- commit: Commit the parent root `AGENTS.md` change and the `test-2376-sc8-red.sh` assertion update together.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/tests-v2/default-model.sh` | Single source of truth; SC-1 is prerequisite for SC-2 and SC-3 | Satisfied |
| `.opencode/tests-v2/with-test-home` | Sources `default-model.sh`; SC-2 depends on SC-1 | Satisfied |
| Local Ollama instance | Must have `ollama/qwen3.8:27b-256k-gguf4` available (verified present, tag `ba02985ca4b1`, 17 GB) | Satisfied |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2, SC-3 | Phase 2 |
| R-3 | SC-4 | Phase 3 |
| R-4 | SC-5 | Phase 4 |
| R-5 | SC-6 | Phase 5 |
| R-6 | SC-7 | Phase 6 |
| R-7 | SC-8 | Phase 7 |
| R-8 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 | Phase 1, 2, 3, 4, 5, 6, 7 |
| R-9 | — | — |
| R-10 | — | — |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `default-model.sh` | code | `.opencode/tests-v2/default-model.sh` | read + grep |
| `with-test-home` | code | `.opencode/tests-v2/with-test-home` | read + grep |
| `tests-v2/AGENTS.md` | doc | `.opencode/tests-v2/AGENTS.md` | read + grep |
| `model-dependency.md` | doc | `.opencode/docs/model-dependency.md` | read + grep |
| `README.md` | doc | `.opencode/README.md` | read + grep |
| `.opencode/AGENTS.md` | doc | `.opencode/AGENTS.md` | read + grep |
| parent `AGENTS.md` | doc | `AGENTS.md` | read + grep |
| Ollama model availability | API | `ollama list` | live command output |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying the `default-model.sh` fallback equals the gguf4 value costs one grep search. Skipping means the source of truth diverges from the harness and every downstream test run uses the wrong model, surfacing as a behavioral failure in CI.
- SC-2: Verifying the `seed_model_config()` fallback in `with-test-home` equals the gguf4 value costs one grep search. Skipping means the harness seeds `opencode.jsonc` with the stale model, surfacing as a runtime failure in the test harness.
- SC-3: Verifying the warmup smoke-test fallback in `with-test-home` equals the gguf4 value costs one grep search. Skipping means the warmup smoke-test runs the wrong model, surfacing as a runtime failure in the test harness.
- SC-4: Verifying the pre-2425 default literal is absent from `.opencode/tests-v2/AGENTS.md` costs one grep search. Skipping means agent-facing test documentation cites a stale model, misleading agents that read it.
- SC-5: Verifying the pre-2425 default literal is absent from `.opencode/docs/model-dependency.md` costs one grep search. Skipping means the model dependency documentation cites a stale model, misleading agents that read it.
- SC-6: Verifying the pre-2425 default literal is absent from `.opencode/README.md` costs one grep search. Skipping means the README cites a stale model, misleading agents that read it.
- SC-7: Verifying the pre-2425 default literal is absent from `.opencode/AGENTS.md` costs one grep search. Skipping means agent-facing rules cite a stale model, undermining the CRITICAL VIOLATION enforcement text and misleading agents that read it.
- SC-8: Verifying the pre-2425 default literal is absent from the parent root `AGENTS.md` costs one grep search. Skipping means agent-facing rules cite a stale model, misleading agents that read it.

## 11. Edge Cases

- **Input boundaries:** The `DEFAULT_TEST_MODEL` env-var override must remain honored; the fallback literal is only used when the env var is unset. The warmup fallback at line 264 is a separate un-env-wrapped literal and must be updated independently.
- **State transitions:** The change is a literal pre/post value swap. SC-1 transitions the source of truth; SC-2 and SC-3 transition the two harness fallbacks; SC-4 through SC-8 transition the five documentation files. No runtime state machine exists for model selection.
- **Failure modes:** If any fallback string or test assertion is not updated in lockstep, the corresponding RED test fails, surfacing the divergence at the earliest gate.
- **Concurrency:** No concurrency concerns — this is a coordinated single change across configuration and documentation files.
- **Recovery:** If a RED test fails, the divergence is diagnosed and the missed literal is updated before the change proceeds.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-31 | Changed all SC evidence types from `structural` to `string`; decomposed SC-2 into SC-2 (seed_model_config fallback) and SC-3 (warmup fallback); decomposed the former SC-3 into SC-4 through SC-8 (one per documentation file). Updated Approach, Key Design Decisions, Items, Traceability, Cost Frame, and Edge Cases to match. | Validation findings: (1) EVIDENCE_TYPE_MISMATCH — grep-based content-verification is `string` evidence, not `structural`; (2) Decomposition — SC-2 bundled two fallback literals via `and` and SC-3 bundled five documentation files via a comma-separated list, failing Atomicity and Single Deliverable criteria. | Spec-creation pipeline (validation gate) |

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
