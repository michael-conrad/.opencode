# Phase 3 — Multi-Submodule Provisioning (Concern C1)

**Concern:** C1 — multi-submodule fixture provisioning. `behavior_run()` provisions `test-submodule-1`/`test-submodule-2` as local git repos in the attempt workdir when `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`, and not when unset.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (behavior_run multi-submodule provisioning)

**SCs:** SC1

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: env isolation foundation in place; VbC passed.
- `behavior_run()` in `helpers.sh` read to understand current provisioning.

**Exit Conditions:**
- `behavior_run()` provisions `test-submodule-1`/`test-submodule-2` when `BEHAVIOR_NEEDS_MULTI_SUBMODULES=1`, and not when unset.
- The fixtures are local git repos created from fixture templates.

---

- [ ] 11. **RED (**sub-agent**).** Write a failing enforcement test asserting: (a) no `test-submodule-1`/`test-submodule-2` dirs appear when `BEHAVIOR_NEEDS_MULTI_SUBMODULES` is unset, but do appear when set; (b) the fixture dirs are not local git repos. **→ SC1**

- [ ] 12. **GREEN (**sub-agent**).** In `helpers.sh` `behavior_run()`: add the `BEHAVIOR_NEEDS_MULTI_SUBMODULES` branch that `git init`s the two fixture repos from fixture templates. **→ SC1**

- [ ] 13. **GREEN doublecheck (**clean-room**).** Verify flag-on/flag-off submodule provisioning: with the flag set, `test-submodule-1`/`test-submodule-2` are present and are local git repos; with the flag unset, they are absent. **→ SC1**

- [ ] 14. **Checkpoint commit (**inline**).** Commit `helpers.sh` + new fixture templates. (No co-author trailer — added at squash time.)

#### Phase 3 VbC

- [ ] 15. **VbC (**clean-room**).** Verify SC1: `ls` workdir + `git submodule status` confirm `test-submodule-1`/`test-submodule-2` are provisioned as local git repos when the flag is set and absent when unset. **→ SC1**

**Concern transition:** Leaving C1 (multi-submodule provisioning) → entering C3 (remote-strategy mutual exclusion) and C7 (cleanup). Phase 4 depends on Phase 1's allowlist; Phase 5 depends on this phase's fixtures; Phase 6 depends on this phase's fixture repos.
