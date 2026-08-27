---
remote_issue: 2376
remote_url: https://github.com/michael-conrad/.opencode/issues/2376
promoted_at: 2026-08-27T00:11:00Z
labels:
- spec
- needs-approval
number: 2376
state: OPEN
title: '[SPEC] Update default test model for opencode run framework to qwen3.8:27b-256k'
---

> **Full spec and artifacts: [`.opencode/.issues/2376/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2376)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2376/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem Statement

The default model for the `opencode run` test framework is `ollama/qwen3.6:35b-256k`, declared as the `DEFAULT_TEST_MODEL` fallback in `.opencode/tests-v2/default-model.sh` (the single source of truth), duplicated as two hardcoded fallback literals in `.opencode/tests-v2/with-test-home`, and referenced in five documentation files. A newer local model `ollama/qwen3.8:27b-256k` is now available (verified present via `ollama-probe list`, along with `qwen3.8:27b` and the still-present `qwen3.6:35b-256k`). The test framework default should point at the newer model.

## Root Cause / Motivation

The default model literal is spread across three concerns that are coupled only by the shared string value: the single source of truth variable, two harness fallback literals that do NOT consume `DEFAULT_TEST_MODEL`, and documentation references. Because `with-test-home` hardcodes the fallback in two places rather than reading the variable, updating only `default-model.sh` would leave the harness and docs pointing at the stale model. The change is needed now because the newer model is available locally and the stale default would keep the test harness pinned to an older model.

## Approach Chosen

Update the `DEFAULT_TEST_MODEL` fallback literal in `.opencode/tests-v2/default-model.sh` to `ollama/qwen3.8:27b-256k`. Tests source `default-model.sh` or read the `$DEFAULT_TEST_MODEL` env var, so updating the single source of truth propagates automatically to consumers. Separately update the two hardcoded fallback literals in `.opencode/tests-v2/with-test-home` (which do not consume the variable) and update the model literal across the five documentation files so the documentation matches the source of truth. This is a pure string-value substitution — no logic, routing, or behavioral-semantics change.

## Alternatives Considered & Why Discarded

1. **Leave `default-model.sh` as the only change.** Discarded: `with-test-home` hardcodes the fallback literal in two places that do not consume `$DEFAULT_TEST_MODEL`; leaving them stale means the harness can still select the old model, defeating the update. Consistency requires updating all three concerns together.
2. **Refactor `with-test-home` to consume `$DEFAULT_TEST_MODEL` instead of hardcoding.** Discarded: this changes harness structure and expands blast radius beyond a literal-value substitution, contradicting the no-behavioral-change constraint that makes this spec structural/string verifiable.

## Key Design Decisions

1. **`default-model.sh` remains the single source of truth for the model.** Tradeoff: tests that consume the variable propagate automatically, at the cost of the two `with-test-home` literals needing separate manual updates because they do not read the variable.
2. **Documentation is updated in the same change as the code.** Tradeoff: the doc references stay consistent with the runtime default, at the cost of touching five documentation files for a code-only model change.
3. **This is a pure literal substitution; no behavioral test is required.** Tradeoff: structural/string verification is fast and appropriate, at the cost of not exercising the new model end-to-end (an advisory runtime smoke test is noted but not required).

## User Intent / Original Prompt

The user requested updating the default test model for the `opencode run` framework to `qwen3.8:27b-256k`, replacing the current default `ollama/qwen3.6:35b-256k` across the test harness and its documentation.

## Not Included

- **`opencode.jsonc` model list** — `.opencode/opencode.jsonc` references `qwen3.6:35b` in its model list; this is a different surface (available-model list, no `-256k` suffix) and is explicitly excluded from this spec's scope.
- **Model availability, ollama-probe, or model installation** — no changes to how models are discovered or installed; the target model must simply remain available locally.
- **`.opencode/docs/audit-sc6959-verification.md`** — references `qwen3.6:35b` (no `-256k` suffix); it is a historical audit record, not the default-model literal, and is not in this spec's scope.
- **Harness isolation logic** — no change beyond literal replacement; the isolation logic and interface signatures are untouched.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The `DEFAULT_TEST_MODEL` fallback literal in `.opencode/tests-v2/default-model.sh` is `ollama/qwen3.8:27b-256k`. | structural | Read the `DEFAULT_TEST_MODEL` assignment in `default-model.sh` and assert the fallback equals `ollama/qwen3.8:27b-256k`. | `.opencode/tests-v2/default-model.sh` (source) |
| SC-2 | The two hardcoded fallback literals in `.opencode/tests-v2/with-test-home` (the `seed_model_config` fallback and the `isolation-model` fallback) are both `ollama/qwen3.8:27b-256k`. | structural | Grep `with-test-home` and assert both fallback literals equal `ollama/qwen3.8:27b-256k`. | `.opencode/tests-v2/with-test-home` (source) |
| SC-3 | No default-model reference to `ollama/qwen3.6:35b-256k` remains in `.opencode/AGENTS.md`, `.opencode/docs/model-dependency.md`, `.opencode/README.md`, `.opencode/tests-v2/AGENTS.md`, or root `AGENTS.md`. | string | Grep all five documentation files and assert zero occurrences of the old default-model literal `ollama/qwen3.6:35b-256k`. | `.opencode/AGENTS.md`, `.opencode/docs/model-dependency.md`, `.opencode/README.md`, `.opencode/tests-v2/AGENTS.md`, root `AGENTS.md` (sources) |

## Requirements

- **R-1.** `default-model.sh` SHALL declare the `DEFAULT_TEST_MODEL` fallback as `ollama/qwen3.8:27b-256k`.
- **R-2.** `with-test-home` SHALL set both hardcoded fallback literals (the `seed_model_config` fallback and the `isolation-model` fallback) to `ollama/qwen3.8:27b-256k`.
- **R-3.** The five documentation files SHALL reference `ollama/qwen3.8:27b-256k` as the default test model and SHALL NOT contain any `ollama/qwen3.6:35b-256k` default-model reference.
- **R-4.** The change SHALL NOT modify `opencode.jsonc`, model availability, ollama-probe, or the harness isolation logic.
- **R-5.** The change SHALL NOT modify `.opencode/docs/audit-sc6959-verification.md`.
- **R-6.** Tests that consume the `$DEFAULT_TEST_MODEL` variable SHALL propagate the new value automatically from `default-model.sh` without per-test edits.

## Items

### Item 1 (SC-1): Update the DEFAULT_TEST_MODEL fallback in default-model.sh

- RED: Read `default-model.sh` — the `DEFAULT_TEST_MODEL` fallback still equals `ollama/qwen3.6:35b-256k`.
- GREEN: Replace the fallback literal with `ollama/qwen3.8:27b-256k`.
- verify: Read `default-model.sh` and assert the fallback equals `ollama/qwen3.8:27b-256k`.
- commit: `.opencode/tests-v2/default-model.sh`.

### Item 2 (SC-2): Update the two hardcoded fallback literals in with-test-home

- RED: Grep `with-test-home` — both fallback literals still equal `ollama/qwen3.6:35b-256k`.
- GREEN: Replace both literals with `ollama/qwen3.8:27b-256k`.
- verify: Grep `with-test-home` and assert both fallback literals equal `ollama/qwen3.8:27b-256k`.
- commit: `.opencode/tests-v2/with-test-home`.

### Item 3 (SC-3): Update documentation references across the five documentation files

- RED: Grep the five documentation files — at least one `ollama/qwen3.6:35b-256k` default-model reference remains.
- GREEN: Update the model literal to `ollama/qwen3.8:27b-256k` in `.opencode/AGENTS.md`, `.opencode/docs/model-dependency.md`, `.opencode/README.md`, `.opencode/tests-v2/AGENTS.md`, and root `AGENTS.md`.
- verify: Grep all five documentation files and assert zero occurrences of `ollama/qwen3.6:35b-256k`.
- commit: The five documentation files.

## Dependencies

- **Reference:** `ollama/qwen3.8:27b-256k` local model availability
  - **Relationship:** Must be present locally for the new default to be usable by tests.
  - **Status:** Satisfied (verified via `ollama-probe list`).
- **Reference:** `.opencode/tests-v2/default-model.sh` (single source of truth)
  - **Relationship:** Must be updated first; downstream consumers read the variable.
  - **Status:** Satisfied (source exists).
- **Reference:** `.opencode/tests-v2/with-test-home`
  - **Relationship:** Contains the two hardcoded fallback literals that must be updated manually to match.
  - **Status:** Satisfied (source exists).
- **Reference:** `.opencode/tests-v2/AGENTS.md` §9 Change Control
  - **Relationship:** Requires an approved spec before changing the default model.
  - **Status:** Satisfied (this issue carries the spec).

## Traceability

| Requirement | SC(s) | Item(s) |
|-------------|-------|---------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |
| R-4 | SC-1, SC-2 | Item 1, Item 2 |
| R-5 | SC-3 | Item 3 |
| R-6 | SC-1 | Item 1 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `default-model.sh` | script source | `.opencode/tests-v2/default-model.sh` | read `DEFAULT_TEST_MODEL` assignment |
| `with-test-home` | script source | `.opencode/tests-v2/with-test-home` | grep both fallback literals |
| `AGENTS.md` | documentation | `.opencode/AGENTS.md`, root `AGENTS.md` | grep for old default-model literal |
| `model-dependency.md` | documentation | `.opencode/docs/model-dependency.md` | grep for old default-model literal |
| `README.md` | documentation | `.opencode/README.md` | grep for old default-model literal |
| tests-v2 AGENTS.md | documentation | `.opencode/tests-v2/AGENTS.md` | grep for old default-model literal |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | read model list (out of scope, unchanged) |
| model availability | runtime | `ollama-probe list` | verified `qwen3.8:27b-256k` present |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the `DEFAULT_TEST_MODEL` fallback costs one read of `default-model.sh`. Skipping means the single source of truth stays pinned to the stale model, and every test consuming the variable silently runs the old model.
- **SC-2:** Verifying both `with-test-home` literals costs one grep. Skipping means the two hardcoded fallbacks silently keep selecting the old model even after the variable is updated.
- **SC-3:** Verifying the five documentation files costs a grep across them. Skipping means stale documentation ships and future readers are told the wrong default model, deferring discovery until the next model reference is audited.

## Edge Cases

- **Input boundary — empty/unset fallback:** The `DEFAULT_TEST_MODEL` fallback is only the value used when the env var is not already set; SC-1 asserts the fallback text, not the runtime selection, so an unset var at runtime still resolves to the new literal.
- **Model not available locally:** If `ollama/qwen3.8:27b-256k` is removed locally after approval, tests that select it fail to load; this is a runtime condition handled by the test harness's model-selection path, not by this literal substitution.
- **Stale reference left behind:** If one documentation file is missed, SC-3's grep across all five files flags the remaining `ollama/qwen3.6:35b-256k` reference and the change is not accepted.
- **Out-of-scope literal collisions:** The grep for `ollama/qwen3.6:35b-256k` is scoped to the five named documentation files plus the two scripts, so the `opencode.jsonc` `qwen3.6:35b` (no suffix) and the `audit-sc6959-verification.md` `qwen3.6:35b` references are not caught or modified — matching the exclusion list.
- **Concurrency:** This is a literal string substitution with no shared state or transaction; no race condition or resource contention applies.
- **Recovery:** Because every SC is a single-literal substitution, a failed or partial change is repaired by re-running the corresponding item's GREen edit; no state machine or rollback path is required.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
