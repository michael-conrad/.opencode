# Phase 2: `with-test-home` — model discovery unification

**Spec:** #1832
**SCs:** SC-2, SC-3, SC-4, SC-5, SC-6
**Dependency:** Phase 1 complete

## Goal

Replace `ollama_models()` with `opencode-cli models` in `seed_model_config()`. Add `ollama-cloud` provider block. Add `TEST_HOME` passthrough. Preserve `OPENCODE_CONFIG_CONTENT`. Remove `ollama_models()` function.

## Steps

### Step 8 — RED: Write behavioral enforcement tests for SC-2 through SC-6

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_7`

Create behavioral test scripts:

1. `.opencode/tests/behaviors/1832-sc2-model-discovery.sh` — Run `with-test-home opencode-cli run "test"`, assert stderr contains `opencode-cli models` invocation. Secondary: grep `seed_model_config()` for "ollama list" — must not appear.

2. `.opencode/tests/behaviors/1832-sc3-cloud-provider.sh` — Run `with-test-home opencode-cli run "test"`, assert stderr contains `ollama-cloud` provider block. Secondary: grep `seed_model_config()` for `ollama-cloud` — must appear.

3. `.opencode/tests/behaviors/1832-sc4-test-home-passthrough.sh` — Run `with-test-home opencode-cli run "echo \$TEST_HOME"`, assert output non-empty. Secondary: grep `with-test-home` for `TEST_HOME` in `pass_through_env` array.

4. `.opencode/tests/behaviors/1832-sc5-config-content.sh` — Run `with-test-home opencode-cli run "test"`, assert stderr contains `OPENCODE_CONFIG_CONTENT`. Secondary: grep `with-test-home` for `OPENCODE_CONFIG_CONTENT`.

5. `.opencode/tests/behaviors/1832-sc6-ollama-models-removed.sh` — Run `with-test-home opencode-cli run "test"`, assert stderr does NOT contain `ollama_models`. Secondary: grep `with-test-home` for `ollama_models` — must not appear.

**Exit criteria:** All 5 tests FAIL (changes not yet made)

### Step 9 — GREEN: Fix `with-test-home`

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_8`

Changes to `.opencode/tests/with-test-home`:

1. **Replace `ollama_models()` call** in `seed_model_config()` with `opencode-cli models` filtered to `ollama/*` entries
2. **Add `ollama-cloud` provider block** to the seeded config with extended timeouts (30min)
3. **Remove the `ollama_models()` function** entirely — no callers remain
4. **Add `TEST_HOME`** to `pass_through_env` array so `env -i` preserves it across sequential dispatches
5. **Keep** `OPENCODE_CONFIG_CONTENT` — it is a documented override mechanism; it merges on top of the seeded config

### Step 10 — VbC: Verify all Phase 2 SCs

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_9`

Run `verification-before-completion` for SC-2, SC-3, SC-4, SC-5, SC-6.
For behavioral SCs: after `behavior_run` artifact generation, dispatch `behavioral-test-evaluation` clean-room sub-agent before allowing PASS verdict.

### Step 11 — Commit

**Dispatch:** `sub-agent` via `task()`
**Chain:** `step_10`

Commit Phase 2 changes with message:
```
Phase 2: Unify model discovery in with-test-home

- Replace ollama_models() with opencode-cli models
- Add ollama-cloud provider block with extended timeouts
- Add TEST_HOME passthrough in env -i block
- Preserve OPENCODE_CONFIG_CONTENT
- Remove ollama_models() function
- Add behavioral enforcement tests for SC-2 through SC-6

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
```

## Phase Completion

- [ ] All Phase 2 SCs pass (SC-2, SC-3, SC-4, SC-5, SC-6)
- [ ] Behavioral SCs verified via clean-room evaluation
- [ ] Changes committed to `feature/1832-test-env-production-parity`
- [ ] Pipeline state updated to Phase 3

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
