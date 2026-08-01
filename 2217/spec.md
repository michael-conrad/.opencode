> **Full spec and artifacts: [`.opencode/.issues/2217/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2217)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2217/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Fix the behavioral test harness to respect `DEFAULT_TEST_MODEL`, add the Timeout Export Procedure to prevent blind retries, and close spec #1188 with all 3 SCs verified.

## Background

Three defects were discovered while running behavioral tests for spec #1188:

1. **`seed_model_config()` hardcodes ornith**: The `with-test-home` function `seed_model_config()` wrote `"model": "ollama/ornith:35b-256k"` regardless of the `DEFAULT_TEST_MODEL` environment variable. This caused behavioral tests to always attempt loading ornith (21GB) even when a smaller model was requested via env var.

2. **`helpers.sh` hardcodes ornith fallback**: The `assert_semantic` function in `helpers.sh` used `ollama/ornith:35b-256k` as the default model parameter instead of `$DEFAULT_TEST_MODEL`.

3. **No Timeout Export Procedure**: When a behavioral test timed out, agents retried blindly instead of exporting the surviving SQLite DB and inspecting the agent's reasoning to determine if the behavior was correct.

4. **Spec #1188 SC-3 missing**: The already-implemented closure decision table and Step 2.5 were implemented in `reconcile-status.md` but the behavioral test for SC-3 was not created.

## Changes Made (already implemented on `fix/seed-model-config-DEFAULT_TEST_MODEL`)

| File | Change |
|------|--------|
| `tests-v2/with-test-home` | `seed_model_config()` now uses `$default_model` for the `model` field instead of hardcoded `ollama/ornith:35b-256k`. Removed hardcoded `ornith:35b-256k` from the `models` block. |
| `tests-v2/behaviors/helpers.sh` | Changed `local model="${4:-ollama/ornith:35b-256k}"` to `local model="${4:-$DEFAULT_TEST_MODEL}"` |
| `tests-v2/AGENTS.md` | Added Timeout Export Procedure section under Bash Tool Timeout Mandate. Added FORBIDDEN pattern for blind retries. Documented the `seed_model_config()` bug and fix. |
| `tests-v2/behaviors/1188-sc3-already-implemented-closure-routing.sh` | New behavioral test for spec #1188 SC-3 |
| `tests-v2/behaviors/fixtures/issues/1188/spec.md` | Fixture spec for test harness injection |
| `skills/approval-gate-scope/tasks/pre-impl/reconcile-status.md` | Added already-implemented closure decision table (5 scenarios) and Step 2.5 closure path determination |
| `docs/model-dependency.md` | Updated default model reference from `ollama/ornith:35b-256k` to `ollama/qwen3.6:35b-256k` |
| `README.md` | Updated default model reference from `ollama/ornith:35b-256k` to `ollama/qwen3.6:35b-256k` |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `seed_model_config()` uses `DEFAULT_TEST_MODEL` for the `model` field, not hardcoded ornith | `string` | grep for `"model":` in `with-test-home` `seed_model_config()` — must show `$default_model` not `ornith` |
| SC-2 | `helpers.sh` uses `$DEFAULT_TEST_MODEL` as fallback, not hardcoded ornith | `string` | grep for `model="\${4` in `helpers.sh` — must show `$DEFAULT_TEST_MODEL` not `ornith` |
| SC-3 | `AGENTS.md` documents the Timeout Export Procedure with export command, inspection steps, and FORBIDDEN pattern | `string` | grep for `Timeout Export Procedure` in `AGENTS.md` — must include `export the SQLite DB` and `FORBIDDEN` |
| SC-4 | All docs reference `qwen3.6:35b-256k` as default, not `ornith:35b-256k` | `string` | grep for `ornith:35b-256k` in `docs/model-dependency.md` and `README.md` — must return 0 matches in default value fields |
| SC-5 | PR created from `fix/seed-model-config-DEFAULT_TEST_MODEL` targeting `main` | `behavioral` | PR exists on `michael-conrad/.opencode` with base `main` and head `fix/seed-model-config-DEFAULT_TEST_MODEL` |

## Requirements

1. The `seed_model_config()` function SHALL use `$default_model` (derived from `DEFAULT_TEST_MODEL` env var) for the `model` field in the generated `opencode.jsonc`.
2. The `helpers.sh` `assert_semantic` function SHALL use `$DEFAULT_TEST_MODEL` as the default model parameter.
3. The `AGENTS.md` SHALL document the Timeout Export Procedure: export SQLite DB, inspect agent reasoning, adjust prompt/fixtures, document findings.
4. The `AGENTS.md` SHALL include a FORBIDDEN pattern for blind retries of the same test with the same model and same timeout.
5. All documentation files SHALL reference `ollama/qwen3.6:35b-256k` as the default test model.

## Items

| Item | SC | Description |
|------|----|-------------|
| 1 | SC-1 | Fix `seed_model_config()` in `with-test-home` to use `$default_model` |
| 2 | SC-2 | Fix `helpers.sh` fallback to use `$DEFAULT_TEST_MODEL` |
| 3 | SC-3 | Add Timeout Export Procedure to `AGENTS.md` |
| 4 | SC-4 | Update `docs/model-dependency.md` and `README.md` default model references |
| 5 | SC-5 | Create PR from `fix/seed-model-config-DEFAULT_TEST_MODEL` to `main` |

## Dependencies

- `michael-conrad/.opencode` repo — all changes are in the `.opencode` submodule
- Branch `fix/seed-model-config-DEFAULT_TEST_MODEL` — already pushed with all changes

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-08-01 | Initial spec | Track the test harness fixes and #1188 closure | Agent |
