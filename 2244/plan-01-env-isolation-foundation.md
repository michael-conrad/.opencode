# Phase 1 — Env Isolation Foundation

**Concern:** Establish the env isolation foundation: the `env -i` allowlist passes through the three new opt-in flags as a strict superset (SC5), `set-env.sh` records them (SC6), and the general env-set rule holds — every required test value is provisioned by the test setup itself (SC13), the allowlist contains ONLY the minimal infrastructure set (SC14), excludes all parent-sourced secrets/credentials/tokens/env-specific vars (SC15), and required values are generated/set by the setup (SC16).

**Files:**
- `.opencode/tests-v2/with-test-home` (env -i invocation + allowlist block, set-env.sh, do_setup, seed_model_config)

**SCs:** SC5, SC6, SC13, SC14, SC15, SC16

**Dependencies:** None

**Entry Conditions:**
- Spec #2244 is approved (issue labeled `approved-for-pr`).
- Feature branch exists on trunk tip (see pre-implementation coherence gate).
- `with-test-home` reads at its `env -i` invocation, allowlist block, `set-env.sh`, `do_setup`, and `seed_model_config` regions.

**Exit Conditions:**
- `env -i` allowlist passes `BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, `BEHAVIOR_SET_BARE_REMOTE` and contains only the minimal infrastructure set.
- No parent-sourced secret/credential/token/env-specific variable is admitted.
- `set-env.sh` records the three flags.
- `do_setup`/`seed_model_config`/test-home provisioning set every required test value.

---

- [ ] 1. **RED (**sub-agent**).** Write failing enforcement tests asserting: (a) the three new flags are absent from the `env -i` allowlist OR an existing allowlisted variable was removed; (b) a required test value (model/config) is inherited rather than set by the setup; (c) the allowlist admits a variable outside the minimal infrastructure set; (d) the allowlist admits a parent-sourced secret/credential/token/env-specific variable (GB_*, GITHUB_*, GH_*, NODE_ENV, VIRTUAL_ENV, CONDA_DEFAULT_ENV, OPENCODE_CONFIG_CONTENT, API keys). **→ SC5, SC6, SC13, SC14, SC15, SC16**

- [ ] 2. **GREEN (**sub-agent**).** In `with-test-home`: extend the `env -i` allowlist with the three new flags (superset only — no removals, no reordering); add the three flags to `set-env.sh`; refactor the allowlist to enumerate exactly the minimal infrastructure set; remove any parent-sourced secret/credential/token/env-specific variable; ensure `do_setup`/`seed_model_config`/test-home provisioning set model/config values. **→ SC5, SC6, SC13, SC14, SC15, SC16**

- [ ] 3. **GREEN doublecheck (**clean-room**).** Inspect the `env -i` invocation + allowlist and `set-env.sh` in `with-test-home`; confirm the three flags are present, no existing variable was removed, the allowlist enumerates exactly the minimal set, no forbidden parent variable is present, and `do_setup`/`seed_model_config` set required values. **→ SC5, SC6, SC13, SC14, SC15, SC16**

- [ ] 4. **Checkpoint commit (**inline**).** Commit `with-test-home` allowlist + set-env.sh + setup changes. (No co-author trailer — added at squash time.)

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Run the isolation verification procedure against the extended allowlist; confirm no production secret/credential/token/env-specific value is admitted. Verify each of SC5, SC6, SC13, SC14, SC15, SC16 individually with its own evidence. **→ SC5, SC6, SC13, SC14, SC15, SC16**

**Concern transition:** Leaving env isolation foundation → entering GB_* scoping. Phase 2 depends on Phase 1's allowlist/set-env/setup state.

---
