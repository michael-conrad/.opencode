# Phase 1 — Document No-Outguess Mandate (Concern C1)

**Concern:** C1 — document the no-outguess model/GPU mandate in `tests-v2/AGENTS.md`. The agent MUST NOT outguess model/GPU selection during behavioral testing; the harness/ollama handles it; model selection is `DEFAULT_TEST_MODEL` from `default-model.sh` (the unchanged single source of truth); the agent MUST NOT probe VRAM (`ollama-probe hw`) to justify a model override, MUST NOT hand-select overrides, and MUST follow the §10 remediation path on failure/timeout (SC-3).

**Files:**
- `.opencode/tests-v2/AGENTS.md` (§9 Change Control / Default Model, §10.4 Fabricated Model Excuses, or a new §10.6)

**SCs:** SC-3

**Dependencies:** None

**Entry Conditions:**
- Spec #2248 is approved (issue labeled `approved-for-pr`).
- Feature branch exists on trunk tip (see pre-implementation coherence gate).
- `tests-v2/AGENTS.md` reads at its §9 Default Model and §10.4 regions.

**Exit Conditions:**
- `tests-v2/AGENTS.md` documents the no-outguess mandate stating the agent MUST NOT outguess model/GPU selection; the harness/ollama handles it; model selection is `DEFAULT_TEST_MODEL` only.
- `default-model.sh` unchanged; the mandate is consistent with (does not contradict) Mandate #5.

---

- [ ] 1. **RED (**sub-agent**).** Write a failing content-verification assertion: `grep` `tests-v2/AGENTS.md` for the no-outguess mandate string returns zero matches (the mandate is not yet documented). **→ SC-3**

- [ ] 2. **GREEN (**sub-agent**).** Add the mandate text to `tests-v2/AGENTS.md` §9 (Default Model) and §10.4 (Fabricated Model Excuses), or a new §10.6, stating the agent MUST NOT outguess model/GPU selection; the harness/ollama handles it; model selection is `DEFAULT_TEST_MODEL` only; probing VRAM to justify an override and hand-selecting overrides are violations; the §10 remediation path applies on failure/timeout. Do not modify `default-model.sh`. **→ SC-3**

- [ ] 3. **GREEN doublecheck (**clean-room**).** Inspect the added §9/§10.4 (or §10.6) mandate text; confirm it is coherent, present, and does not contradict Mandate #5's default-model-not-changed rule. **→ SC-3**

- [ ] 4. **Checkpoint commit (**inline**).** Commit the AGENTS.md mandate (foundational — SC-1/SC-2/SC-4 depend on it). (No co-author trailer — added at squash time.)

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** `grep` `tests-v2/AGENTS.md` for the no-outguess mandate string returns a match; text present and coherent; `default-model.sh` byte-for-byte unchanged; mandate consistent with Mandate #5. **→ SC-3**

**Concern transition:** Leaving C1 (document mandate) → entering C2 (behavioral enforcement tests). Phase 2 depends on Phase 1's documented mandate — the behavioral scenarios must reference the mandate so the agent can comply.
