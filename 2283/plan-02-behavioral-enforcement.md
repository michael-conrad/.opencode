# Phase 2 — Behavioral Enforcement

**Concern:** Add a behavioral enforcement test proving an agent running the branch-finishing checklist on a fully-implemented multi-phase plan creates zero sub-issues (SC-3).

**Files:**
- `.opencode/tests-v2/behaviors/<scenario>.sh` (new artifact-only generator)
- `.opencode/tests-v2/with-test-home` (invoked for isolation, unchanged)
- `tmp/behavioral-evidence-<scenario>-.../session.yaml` (generated artifacts)

**SCs:** SC-3

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: `checklist.md` has no `link-sub-issue` creation mandate at finishing time
- Phase 1 VbC passed
- Behavioral test harness available (`.opencode/tests-v2/with-test-home`, `helpers.sh`)

**Exit Conditions:**
- Behavioral scenario script exists that dispatches the branch-finishing checklist on a fully-implemented multi-phase plan
- Clean-room `session.yaml` evaluation confirms zero `link-sub-issue` / sub-issue creation calls
- SC-3 behavioral verification passes

---

- [ ] 14. **RED (**sub-agent**).** Dispatch `task(..., prompt: "execute red task from test-driven-development")` to write a failing behavioral enforcement test scenario `2283-sc3-no-subissue-creation.sh` (artifact-only generator). Its real-domain prompt asks the agent to run the branch-finishing checklist on a fully-implemented multi-phase plan. Run it via `bash .opencode/tests-v2/with-test-home opencode run '<prompt>'` with bash-tool timeout >= 600s; confirm the generated `session.yaml` stderr shows sub-issue creation calls (the current checklist mandates creation) — the behavioral criterion is NOT yet met. **→ SC-3**
- [ ] 15. **GREEN (**sub-agent**).** Dispatch `task(..., prompt: "execute green task from test-driven-development")` to finalize the scenario so it exercises the SC-1-modified checklist (no sub-issue creation at finishing time). Run it via `with-test-home`; the generated `session.yaml` records zero `link-sub-issue` / sub-issue creation calls in stderr. **→ SC-3**
- [ ] 16. **GREEN doublecheck (**clean-room**).** Verify the scenario script retains the mandatory cross-reference header, runs as an artifact-only generator (exits 0), and produces a `session.yaml` artifact. **→ SC-3**
- [ ] 17. **Post-regression (**sub-agent**).** Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")` to run regression test patterns after the GREEN phase. **→ SC-3**
- [ ] 18. **Verify (**sub-agent**).** Dispatch `task(..., prompt: "execute verify task from verification-before-completion")` to verify the implementation against SC-3: clean-room `session.yaml` stderr evaluation confirms zero `link-sub-issue` / sub-issue creation calls. **→ SC-3**
- [ ] 19. **Checkpoint commit (**inline**).** Stage the scenario script and commit it as one atomic slice. (No co-author trailer — added at squash time.) **→ SC-3**

#### Phase 2 VbC

- [ ] 20. **VbC (**clean-room**).** Verify SC-3 is satisfied: an agent running the branch-finishing checklist on a fully-implemented multi-phase plan creates zero sub-issues, evidenced by a clean-room `session.yaml` with zero `link-sub-issue` / sub-issue creation calls. **→ SC-3**

**Concern transition:** Leaving behavioral enforcement → entering PR autoclose + plan-content protection. Phase 3 depends on Phase 2 complete.
