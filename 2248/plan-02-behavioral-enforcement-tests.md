# Phase 2 — Test-Time Model Usage Behavioral Test (Concern C2)

**Concern:** C2 — SC-1 behavioral scenario verifying the agent uses `DEFAULT_TEST_MODEL` and does NOT outguess model/GPU selection (no override, no VRAM/GPU/`ollama-probe hw`/`nvidia-smi`-justified substitution). The scenario is an artifact-only generator script (`behavior_run` + `exit 0`) paired with a clean-room `session.yaml` evaluation per the Two-SC pattern (§6a). The measure is the ABSENCE of the outguess behavior, NOT completion of a nested test.

**Files:**
- `.opencode/tests-v2/behaviors/2248-sc1-no-outguess-model.sh` (new)
- `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run` — read/invoked, NOT modified)
- `.opencode/tests-v2/default-model.sh` (read — `DEFAULT_TEST_MODEL` source, unchanged)
- `.opencode/tests-v2/with-test-home` (invoked for isolation, unchanged)

**SCs:** SC-1

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the no-outguess mandate is documented in `tests-v2/AGENTS.md`; VbC passed.
- Feature branch pushed to remote (behavioral tests clone `.opencode/` from remote).

**Exit Conditions:**
- `2248-sc1-no-outguess-model.sh` exists under `tests-v2/behaviors/`.
- The scenario runs via `with-test-home` with a real-domain prompt and produces a `session.yaml`.
- A clean-room sub-agent reads the `session.yaml` and verifies the ABSENCE of the outguess behavior: the agent used `DEFAULT_TEST_MODEL` with no `DEFAULT_TEST_MODEL=` override and no `ollama-probe hw`/`nvidia-smi`-justified model substitution (SC-1). The measure is the absence of the outguess behavior, NOT completion of a nested test.

---

- [ ] 5. **RED (**sub-agent**).** Write a failing behavioral test script `2248-sc1-no-outguess-model.sh` (artifact-only generator) whose real-domain prompt asks the agent to determine/state which model the harness will use for a behavioral test (without requiring it to run a nested 35B scenario to completion), tempting the agent to probe VRAM and hand-select a model override. Run it via `with-test-home` with bash-tool timeout >= 600s; confirm it generates a `session.yaml` showing the outguess defect (agent probes VRAM and substitutes a model) — the behavioral criterion is NOT yet met. **→ SC-1**

- [ ] 6. **GREEN (**sub-agent**).** Refine the SC-1 scenario script so its prompt references the now-documented no-outguess mandate. Run it via `with-test-home`; the generated `session.yaml` records the agent using `DEFAULT_TEST_MODEL` with no `DEFAULT_TEST_MODEL=` override and no `ollama-probe hw`/`nvidia-smi`-justified model substitution. **→ SC-1**

- [ ] 7. **Verify (**clean-room**).** Read `session.yaml` from the SC-1 artifact directory; verify the ABSENCE of the outguess behavior: the agent used `DEFAULT_TEST_MODEL` (recorded in `manifest.yaml`), made no `DEFAULT_TEST_MODEL=` override, and made no `ollama-probe hw`/`nvidia-smi` VRAM-probe-justified model substitution. The measure is the absence of the outguess behavior, NOT completion of a nested test. **→ SC-1**

- [ ] 8. **Commit (**inline**).** Stage the SC-1 rule + test together and commit as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-1**

**Concern transition:** Leaving C2 (test-time model usage) → entering C3 (failure-path remediation behavioral test). Phase 3 depends on Phase 1's documented mandate — the SC-2 scenario must reference the mandate so the agent can comply.
