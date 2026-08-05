# Phase 3 — Failure-Path Remediation Behavioral Test (Concern C3)

**Concern:** C3 — SC-2 behavioral scenario verifying the agent follows the documented §10 remediation path on failure/timeout rather than diagnosing VRAM and switching models. The scenario is an artifact-only generator script (`behavior_run` + `exit 0`) paired with a clean-room `session.yaml` evaluation per the Two-SC pattern (§6a).

**Files:**
- `.opencode/tests-v2/behaviors/2248-sc2-failure-path-remediation.sh` (new)
- `.opencode/tests-v2/behaviors/helpers.sh` (`behavior_run` — read/invoked, NOT modified)
- `.opencode/tests-v2/default-model.sh` (read — `DEFAULT_TEST_MODEL` source, unchanged)
- `.opencode/tests-v2/with-test-home` (invoked for isolation, unchanged)

**SCs:** SC-2

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the no-outguess mandate is documented in `tests-v2/AGENTS.md`; VbC passed.
- Feature branch pushed to remote (behavioral tests clone `.opencode/` from remote).

**Exit Conditions:**
- `2248-sc2-failure-path-remediation.sh` exists under `tests-v2/behaviors/`.
- The scenario runs via `with-test-home` with a real-domain prompt and produces a `session.yaml`.
- A clean-room sub-agent reads the `session.yaml` and verifies the agent followed the §10 remediation path with no `ollama-probe hw` + model switch (SC-2).

---

- [ ] 9. **RED (**sub-agent**).** Write a failing behavioral test script `2248-sc2-failure-path-remediation.sh` (artifact-only generator) whose real-domain prompt places the agent in a test-failure/timeout scenario. Run it via `with-test-home`; confirm it generates a `session.yaml` showing the outguess-on-failure defect (probes VRAM, diagnoses "model too big", switches model) — the behavioral criterion is NOT yet met. **→ SC-2**

- [ ] 10. **GREEN (**sub-agent**).** Refine the SC-2 scenario script so its prompt references the documented mandate. Run it via `with-test-home`; the generated `session.yaml` records the agent following the §10 remediation path (stale-lock check, bash-tool timeout check, stderr `TEST_HOME`, manual SQLite export) with no `ollama-probe hw` + model switch. **→ SC-2**

- [ ] 11. **Verify (**clean-room**).** Read `session.yaml` from the SC-2 artifact directory; verify the agent's diagnostic tool calls follow the §10 remediation path with no `ollama-probe hw` + "model too big" + model switch. **→ SC-2**

- [ ] 12. **Commit (**inline**).** Stage the SC-2 rule + test together and commit as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-2**

**Concern transition:** Leaving C3 (failure-path remediation) → entering C4 (excuse-fabrication reinforcement behavioral test). Phase 4 depends on Phase 1's documented mandate — the SC-4 scenario must reference the mandate so the agent can comply.
