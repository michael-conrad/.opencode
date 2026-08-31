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
| 3 | **Approach Chosen** | Update the single source of truth `DEFAULT_TEST_MODEL` in `default-model.sh` to the gguf4 value, then propagate the change to the two fallback literals in `with-test-home`, the three behavioral test assertion scripts, and the five documentation files. Each SC is a literal-value swap verified by content-verification (grep) tests. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: leave the fallback literals in `with-test-home` un-env-wrapped and independent.** Discarded because the warmup fallback at line 264 is a separate un-env-wrapped literal that would silently diverge from the source of truth, breaking model consistency across the harness. |
| 5 | **Key Design Decisions** | **Decision: keep `DEFAULT_TEST_MODEL` as the single source of truth and mirror it in all fallbacks.** Tradeoff: requires a coordinated multi-file change, but preserves a single authoritative value and keeps the env-var override honored. **Decision: use content-verification (grep) tests rather than behavioral tests.** Tradeoff: this is a configuration/documentation literal change, not a runtime-behavioral change, so grep-based assertion is the correct evidence type. |
| 6 | **User Intent / Original Prompt** | Change the default test model to `ollama/qwen3.8:27b-256k-gguf4`. |

## 2. Not Included

- **Model-selection logic** — The test framework's model-selection logic is unchanged; only the default literal value changes.
- **GPU/VRAM handling** — No changes to hardware handling.
- **Other model values** — No model value other than the default test model is changed.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The `DEFAULT_TEST_MODEL` fallback literal in `.opencode/tests-v2/default-model.sh` SHALL equal `ollama/qwen3.8:27b-256k-gguf4`, with the variable name and env-var overridability preserved. | structural | `test-2376-sc1-red.sh` content-verification grep of the exact fallback pattern |
| SC-2 | Both fallback model literals in `.opencode/tests-v2/with-test-home` (the `seed_model_config()` path and the warmup smoke-test path) SHALL equal `ollama/qwen3.8:27b-256k-gguf4`. | structural | `test-2376-sc2-red.sh` content-verification grep of the fallback literals |
| SC-3 | The pre-2425 default literal `ollama/qwen3.8:27b-256k` SHALL be absent from all five documentation files: `.opencode/tests-v2/AGENTS.md`, `.opencode/docs/model-dependency.md`, `.opencode/README.md`, `.opencode/AGENTS.md`, and the parent root `AGENTS.md`. | structural | `test-2376-sc3-red.sh` content-verification grep asserting the old literal is absent across the five files |

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

### Item 2 (SC-2): Update the fallback literals in `with-test-home`

- RED: `test-2376-sc2-red.sh` asserts both fallbacks equal `ollama/qwen3.8:27b-256k-gguf4`; currently stale, so it fails.
- GREEN: Replace both fallback literals in `with-test-home` (the `seed_model_config()` path and the warmup path) with the gguf4 value.
- verify: Run `test-2376-sc2-red.sh`; it exits 0.
- commit: Commit the `with-test-home` change and the `test-2376-sc2-red.sh` assertion update together.

### Item 3 (SC-3): Update documentation references across five files

- RED: `test-2376-sc3-red.sh` asserts the pre-2425 default literal `ollama/qwen3.8:27b-256k` is absent across the five documentation files; currently present, so it fails.
- GREEN: Replace the pre-2425 default literal in all five documentation files with the gguf4 value.
- verify: Run `test-2376-sc3-red.sh`; it exits 0.
- commit: Commit the five documentation file changes and the `test-2376-sc3-red.sh` assertion update together.

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
| R-2 | SC-2 | Phase 2 |
| R-3, R-4, R-5, R-6, R-7 | SC-3 | Phase 3 |
| R-8 | SC-1, SC-2, SC-3 | Phase 1, 2, 3 |
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
- SC-2: Verifying both `with-test-home` fallbacks equal the gguf4 value costs one grep search. Skipping means the harness seeds `opencode.jsonc` with the stale model and the warmup smoke-test runs the wrong model, surfacing as a runtime failure in the test harness.
- SC-3: Verifying the pre-2425 default literal is absent from all five documentation files costs one grep search. Skipping means agent-facing documentation cites a stale model, undermining the CRITICAL VIOLATION enforcement text and misleading agents that read it.

## 11. Edge Cases

- **Input boundaries:** The `DEFAULT_TEST_MODEL` env-var override must remain honored; the fallback literal is only used when the env var is unset. The warmup fallback at line 264 is a separate un-env-wrapped literal and must be updated independently.
- **State transitions:** The change is a literal pre/post value swap. SC-1 transitions the source of truth; SC-2 transitions the harness fallbacks; SC-3 transitions the documentation. No runtime state machine exists for model selection.
- **Failure modes:** If any fallback string or test assertion is not updated in lockstep, the corresponding RED test fails, surfacing the divergence at the earliest gate.
- **Concurrency:** No concurrency concerns — this is a coordinated single change across configuration and documentation files.
- **Recovery:** If a RED test fails, the divergence is diagnosed and the missed literal is updated before the change proceeds.

---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (deepseek-v4-flash)
