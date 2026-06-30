# Implementation Plan — [.opencode#1450](https://github.com/michael-conrad/.opencode/issues/1450) — Centralize default test model

**Goal:** Eliminate duplicated model strings across 6 locations by creating `tests/default-model.sh` as the single source of truth, removing `BEHAVIOR_MODEL`, `ENFORCEMENT_TEST_MODEL`, and `MODEL` aliases, and removing the stale fallback list from `with-test-home`.

**Architecture:** One sourced file (`default-model.sh`) with `DEFAULT_TEST_MODEL=ollama/ornith:35b-256k` and env var override. All consumers source it and use `$DEFAULT_TEST_MODEL` directly. No aliases, no local copies.

**Files:**
- CREATE: `tests/default-model.sh`
- MODIFY: `tests/behaviors/helpers.sh`
- MODIFY: `tests/test-enforcement.sh`
- MODIFY: `tests/test-verification-honesty.sh`
- MODIFY: `tests/behaviors/832-sc1-repo-information-section.sh`
- MODIFY: `tests/behaviors/832-sc2-no-github-flat-keys.sh`
- MODIFY: `tests/behaviors/832-sc10-local-only-degraded.sh`
- MODIFY: `tests/behaviors/832-sc4-platform-raw-hostname.sh`
- MODIFY: `tests/behaviors/1165-yaml-quoting.sh`
- MODIFY: `tests/behaviors/issue-operations-dispatch-instead-of-inline.sh`
- MODIFY: `tests/with-test-home`
- MODIFY: `tests/AGENTS.md`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Create source + wire consumers

**Concern:** Establish single source of truth for default test model. Create `default-model.sh` and update all consumer scripts to source it.

**Files:** CREATE `tests/default-model.sh`; MODIFY `tests/behaviors/helpers.sh`, `tests/test-enforcement.sh`, `tests/test-verification-honesty.sh`, `tests/AGENTS.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-10

**Dependencies:** none

**Entry:** Spec approved, branch created

**Exit:** All consumer scripts source `default-model.sh` and use `$DEFAULT_TEST_MODEL`

- [ ] 1. **Create `tests/default-model.sh`.** Write the single source of truth file with `DEFAULT_TEST_MODEL=ollama/ornith:35b-256k` and env var override pattern. **→ SC-1**
- [ ] 2. **Update `tests/behaviors/helpers.sh`.** Add `source "$(dirname "${BASH_SOURCE[0]}")/../default-model.sh"` at the top. Remove the `BEHAVIOR_MODEL` assignment line. Change `behavior_run()` fallback from `$BEHAVIOR_MODEL` to `$DEFAULT_TEST_MODEL`. **→ SC-2**
- [ ] 3. **Update `tests/test-enforcement.sh`.** Add `source "$(dirname "${BASH_SOURCE[0]}")/default-model.sh"` at the top. Remove the `MODEL` assignment line. Replace all `$MODEL` references with `$DEFAULT_TEST_MODEL`. **→ SC-3**
- [ ] 4. **Update `tests/test-verification-honesty.sh`.** Add `source "$(dirname "${BASH_SOURCE[0]}")/default-model.sh"` at the top. Remove the `MODEL` assignment line. Replace `$MODEL` with `$DEFAULT_TEST_MODEL`. **→ SC-4**
- [ ] 5. **Update `tests/AGENTS.md`.** Replace hardcoded model string references with a pointer to `tests/default-model.sh` as the single source of truth. **→ SC-10**
- [ ] 6. **Verify Phase 1 SCs.** Run grep assertions:
  - `ls tests/default-model.sh` → exists
  - `grep 'source.*default-model.sh' tests/behaviors/helpers.sh` → match
  - `grep 'DEFAULT_TEST_MODEL' tests/behaviors/helpers.sh` → match
  - `grep 'source.*default-model.sh' tests/test-enforcement.sh` → match
  - `grep 'DEFAULT_TEST_MODEL' tests/test-enforcement.sh` → match
  - `grep 'source.*default-model.sh' tests/test-verification-honesty.sh` → match
  - `grep 'DEFAULT_TEST_MODEL' tests/test-verification-honesty.sh` → match
  - `grep 'default-model.sh' tests/AGENTS.md` → match

#### Phase 1 VbC

- [ ] 7. **VbC.** Verify SC-1 (file exists), SC-2 (helpers.sh sources + uses DEFAULT_TEST_MODEL), SC-3 (test-enforcement.sh sources + uses), SC-4 (test-verification-honesty.sh sources + uses), SC-10 (AGENTS.md references default-model.sh). **→ SC-1, SC-2, SC-3, SC-4, SC-10**

**Concern transition:** Leaving source creation → entering stale reference removal. Phase 2 depends on Phase 1 having all consumers wired to `default-model.sh`.

## Phase 2 — Remove hardcoded models + verify

**Concern:** Remove all stale model variables (`BEHAVIOR_MODEL`, `ENFORCEMENT_TEST_MODEL`, `MODEL`) and hardcoded model strings from test scripts. Remove the fallback list from `with-test-home`. Verify no stale refs remain.

**Files:** MODIFY 6 behavior files (`832-sc1`, `832-sc2`, `832-sc4`, `832-sc10`, `1165-yaml-quoting`, `issue-operations-dispatch`), `tests/with-test-home`

**SCs:** SC-5, SC-6, SC-7, SC-8, SC-9, SC-11

**Dependencies:** Phase 1

**Entry:** Phase 1 complete and verified

**Exit:** No stale model variables remain; `with-test-home` has no fallback list; behavioral test passes

- [ ] 8. **Update 4 behavior scripts — replace `$BEHAVIOR_MODEL` with `$DEFAULT_TEST_MODEL`.** For each of the 4 scripts passing `$BEHAVIOR_MODEL` to `behavior_run` (832-sc1, 832-sc2, 832-sc4, 832-sc10), replace the argument. **→ SC-5**
- [ ] 9. **Update `tests/behaviors/1165-yaml-quoting.sh`.** Replace the echo line's `${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}` with `$DEFAULT_TEST_MODEL`. **→ SC-5**
- [ ] 10. **Update `tests/behaviors/issue-operations-dispatch-instead-of-inline.sh`.** Replace `MODEL_FOR_SLUG` assignment's `${BEHAVIOR_MODEL:-ollama/unknown}` with `$DEFAULT_TEST_MODEL`. **→ SC-5**
- [ ] 11. **Remove fallback list from `tests/with-test-home`.** Delete lines 84-86 (the `if [ ${#models[@]} -eq 0 ]; then models=(...); fi` block). The empty-list check at line 88 fires directly. **→ SC-9**
- [ ] 12. **Verify SC-5: No `BEHAVIOR_MODEL` in behavior scripts.** Run `grep -rn 'BEHAVIOR_MODEL' tests/behaviors/*.sh | grep -v 'helpers.sh'` — expect zero matches. **→ SC-5**
- [ ] 13. **Verify SC-6: No `ENFORCEMENT_TEST_MODEL` in tests/.** Run `grep -rn 'ENFORCEMENT_TEST_MODEL' tests/` — expect zero matches. **→ SC-6**
- [ ] 14. **Verify SC-7: No `MODEL` as model variable in `tests/*.sh`.** Run `grep -n '\bMODEL\b' tests/*.sh` — only matches are comments, not variable assignments. Exclude `test-all-auditor-agents.sh` (uses `MODELS` for auditor agent model strings). **→ SC-7**
- [ ] 15. **Verify SC-8: Only `default-model.sh` has `ollama/` in `.sh` files.** Run `grep -rn 'ollama/' tests/ --include='*.sh'` — only match is `tests/default-model.sh`. Exclude intentional test fixtures (`ollama/nonexistent-model-that-will-fail` in dispatch-failure-gate.sh, `ollama/` in helpers.sh grep patterns). **→ SC-8**
- [ ] 16. **Verify SC-9: No fallback models in `with-test-home`.** Run `grep -E 'phi4-mini|llama3.2:3b|qwen3.5:27b' tests/with-test-home` — expect zero matches. **→ SC-9**
- [ ] 17. **Behavioral test: env var override.** Run a test with `DEFAULT_TEST_MODEL=custom-model` and verify the override is used. **→ SC-11**

#### Phase 2 VbC

- [ ] 18. **VbC.** Verify SC-5 (no BEHAVIOR_MODEL), SC-6 (no ENFORCEMENT_TEST_MODEL), SC-7 (no MODEL variable), SC-8 (only default-model.sh has ollama/), SC-9 (no fallback in with-test-home), SC-11 (env var override works). **→ SC-5, SC-6, SC-7, SC-8, SC-9, SC-11**

## Exit Criteria

- **C1.** `tests/default-model.sh` exists with `DEFAULT_TEST_MODEL=ollama/ornith:35b-256k` (SC-1)
- **C2.** `helpers.sh` sources `default-model.sh` and uses `$DEFAULT_TEST_MODEL` in `behavior_run()` (SC-2)
- **C3.** `test-enforcement.sh` sources `default-model.sh` and uses `$DEFAULT_TEST_MODEL` (SC-3)
- **C4.** `test-verification-honesty.sh` sources `default-model.sh` and uses `$DEFAULT_TEST_MODEL` (SC-4)
- **C5.** No `BEHAVIOR_MODEL` in `tests/behaviors/*.sh` (SC-5)
- **C6.** No `ENFORCEMENT_TEST_MODEL` in `tests/` (SC-6)
- **C7.** No `MODEL` as model variable in `tests/*.sh` (SC-7)
- **C8.** Only `default-model.sh` has `ollama/` in `.sh` files (SC-8)
- **C9.** No fallback models in `with-test-home` (SC-9)
- **C10.** `AGENTS.md` references `default-model.sh` (SC-10)
- **C11.** `DEFAULT_TEST_MODEL=custom-model` env var override works (SC-11)
