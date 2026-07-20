## Compliance Admonishment

> **⚠️ CRITICAL VIOLATION — Tier 2 Process-Integrity**
>
> The default test model in `.opencode/tests-v2/default-model.sh` is `ollama/gpt-oss:20b-cloud`, which does not exist in the available models. The correct model is `ollama/qwen3.6:35b-256k`. Using a non-existent default model causes all behavioral tests to fail by default.

---

## Root Cause

`default-model.sh` line 4 sets `DEFAULT_TEST_MODEL="${DEFAULT_TEST_MODEL:-ollama/gpt-oss:20b-cloud}"`. The model `ollama/gpt-oss:20b-cloud` is not available in the environment. The correct model that exists and is used in practice is `ollama/qwen3.6:35b-256k`.

---

## Fix

Change line 4 of `.opencode/tests-v2/default-model.sh` from `ollama/gpt-oss:20b-cloud` to `ollama/qwen3.6:35b-256k`.

---

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|-------------------|
| SC-1 | `default-model.sh` contains `ollama/qwen3.6:35b-256k` as the default model | string | `grep` for the model string in the file |
| SC-2 | `ollama/gpt-oss:20b-cloud` is no longer present in `default-model.sh` | string | `grep` confirms absence |

---

## Evidence

- `opencode models` output does not list `ollama/gpt-oss:20b-cloud`
- `ollama/qwen3.6:35b-256k` is a known available model
