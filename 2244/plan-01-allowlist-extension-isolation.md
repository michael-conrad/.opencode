# Phase 1 — Allowlist Extension + Isolation (Concern C4)

**Concern:** C4 — env -i allowlist extension + isolation. The `env -i` allowlist passes through the three new opt-in flags as a strict superset (SC5), `set-env.sh` records them (SC6), the isolation verification procedure still passes after the extension (SC7), the allowlist contains ONLY the minimal infrastructure set (SC14), and excludes all parent-sourced secrets/credentials/tokens/env-specific vars (SC15).

**Files:**
- `.opencode/tests-v2/with-test-home` (env -i invocation + allowlist block, set-env.sh)

**SCs:** SC5, SC6, SC7, SC14, SC15

**Dependencies:** None

**Entry Conditions:**
- Spec #2244 is approved (issue labeled `approved-for-pr`).
- Feature branch exists on trunk tip (see pre-implementation coherence gate).
- `with-test-home` reads at its `env -i` invocation, allowlist block, and `set-env.sh` regions.

**Exit Conditions:**
- `env -i` allowlist passes `BEHAVIOR_NEEDS_MULTI_SUBMODULES`, `BEHAVIOR_NEEDS_REMOTE`, `BEHAVIOR_SET_BARE_REMOTE` and contains only the minimal infrastructure set.
- No parent-sourced secret/credential/token/env-specific variable is admitted.
- `set-env.sh` records the three flags.
- The isolation verification procedure passes against the extended allowlist.

---

- [ ] 1. **RED (**sub-agent**).** Write failing enforcement tests asserting: (a) the three new flags are absent from the `env -i` allowlist OR an existing allowlisted variable was removed; (b) a parent-sourced secret/credential/token/env-specific variable (GB_*, GITHUB_*, GH_*, NODE_ENV, VIRTUAL_ENV, CONDA_DEFAULT_ENV, OPENCODE_CONFIG_CONTENT, API keys) is admitted by the allowlist; (c) the allowlist admits a variable outside the minimal infrastructure set; (d) the isolation verification procedure fails (a production state leak is admitted) after the allowlist extension. **→ SC5, SC6, SC7, SC14, SC15**

- [ ] 2. **GREEN (**sub-agent**).** In `with-test-home`: extend the `env -i` allowlist with the three new flags (superset only — no removals, no reordering); add the three flags to `set-env.sh`; refactor the allowlist to enumerate exactly the minimal infrastructure set; remove any parent-sourced secret/credential/token/env-specific variable. **→ SC5, SC6, SC7, SC14, SC15**

- [ ] 3. **GREEN doublecheck (**clean-room**).** Inspect the `env -i` invocation + allowlist and `set-env.sh` in `with-test-home`; confirm the three flags are present, no existing variable was removed, the allowlist enumerates exactly the minimal set, and no forbidden parent variable is present. **→ SC5, SC6, SC7, SC14, SC15**

- [ ] 4. **Checkpoint commit (**inline**).** Commit `with-test-home` allowlist + set-env.sh changes. (No co-author trailer — added at squash time.)

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Run the isolation verification procedure against the extended allowlist; confirm no production secret/credential/token/env-specific value is admitted. Verify each of SC5, SC6, SC7, SC14, SC15 individually with its own evidence. **→ SC5, SC6, SC7, SC14, SC15**

**Concern transition:** Leaving C4 (allowlist extension + isolation) → entering C5 (test-provisioned env rule + GB scoping). Phase 2 depends on Phase 1's allowlist/set-env state.
