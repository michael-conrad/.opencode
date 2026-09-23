# Phase 1 — Monitor evidence + classification + determination record foundation

**Concern:** Record lifecycle foundation in `__semantic_monitor` — poll evidence persistence, classification sub-agent dispatch with scenario-goal context, and durable determination record write.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh`

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry Conditions:**
- Coherence gate passed (plan step 1); baseline check passed, feature branch exists (plan step 2)
- Phase DAG entry: `depends_on: []`

**Exit Conditions:**
- Poll evidence persisted for every monitored run under `BEHAVIOR_SEMANTIC_MONITOR=1`
- Classification sub-agent dispatched with scenario-goal context
- Determination record (YAML) written to the scenario evidence directory with classification + poll-evidence references

**Code Path Coverage:**
- `__semantic_monitor` (`.opencode/tests-v2/behaviors/helpers.sh`) — poll loop (`while kill -0 run_pid`), per-poll stats extraction, new poll-evidence persistence target, new classification dispatch, new determination-record YAML write

**Cross-Cutting SCs:** Determination record spans SC-3/SC-7/SC-8/SC-10 (this phase delivers the schema and write path consumed by later phases); `BEHAVIOR_SEMANTIC_MONITOR` flag gates every monitor-path change (backward compat); YAML per the LLM-to-LLM data standard.

**Interface Boundaries:**
- `behavior_run() -> __semantic_monitor` call signature unchanged; monitor internals extended behind the flag
- New determination-record file interface: YAML in scenario evidence directory alongside session.yaml and poll log; append-only for false_signal annotations and orchestrator decisions (consumed by later phases' gate and counter)

**State Transitions:**
- launched → polling (monitor active under flag); polling persists poll evidence (SC-1); classification dispatch (SC-2) feeds record write (SC-3)

**Cost frame:** Running the behavioral foundation tests costs minutes of live-model execution plus ~15 min harness provisioning. Skipping costs weeks — undetermined runs silently pass verdicts and the defect ships inside every subsequent behavioral test's evidence chain, a 1000× death-spiral multiplier.

---

- [ ] 3. **pre-regression (**task-card**).** Run regression test patterns before RED phase: `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-1**
- [ ] 4. **pre-regression-verify (**task-card**).** Verify pre-regression results: `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1**
- [ ] 5. **RED — poll evidence (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — write a failing behavioral test asserting no poll evidence persisted for a monitored run under `BEHAVIOR_SEMANTIC_MONITOR=1`. **→ SC-1**
- [ ] 6. **GREEN — poll evidence (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement minimal poll-evidence persistence in `__semantic_monitor` to the scenario evidence directory. **→ SC-1**
- [ ] 7. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1**
- [ ] 8. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral run via `with-test-home` asserts poll evidence present. **→ SC-1**
- [ ] 9. **commit-inline (**direct**).** `git add .opencode/tests-v2/behaviors/helpers.sh <test file> && git commit -m "monitor: persist poll evidence per monitored run"`.
- [ ] 10. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-2**
- [ ] 11. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-2**
- [ ] 12. **RED — classification dispatch (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — failing test asserting no classification dispatch for a monitored run. **→ SC-2**
- [ ] 13. **GREEN — classification dispatch (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — dispatch the monitoring sub-agent with scenario goal/expected-behavior context; classification (progressing-directionally / off-track / undetermined) produced in the sub-agent's own context. **→ SC-2**
- [ ] 14. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-2**
- [ ] 15. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral run via `with-test-home` asserts classification dispatch with goal context. **→ SC-2**
- [ ] 16. **commit-inline (**direct**).** Commit the classification dispatch path. **→ SC-2**
- [ ] 17. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-3**
- [ ] 18. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-3**
- [ ] 19. **RED — determination record (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — failing test asserting no determination record written. **→ SC-3**
- [ ] 20. **GREEN — determination record (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — write the YAML determination record (classification + poll-evidence references) to the scenario evidence directory. **→ SC-3**
- [ ] 21. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-3**
- [ ] 22. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral run via `with-test-home` asserts record contents (classification, poll-evidence refs). **→ SC-3**
- [ ] 23. **commit-inline (**direct**).** Commit the determination-record schema + write path. **→ SC-3**

#### Phase 1 VbC

- [ ] 24. **VbC (**task-card**).** Verify all three SC-1/SC-2/SC-3 verdicts are PASS with behavioral evidence artifacts in `{project_root}/tmp/issue-2456/artifacts/`. **→ SC-1, SC-2, SC-3**

#### Item 2R (SC-2 amendment, pipeline-initiated FALSE_PREMISE remediation)

> Spec revision 2026-09-22: the classification dispatch's direction anchor SHALL be a mechanically verifiable goal condition (scenario-declared goal artifact + content pattern), never the run prompt prose (R-2); starved/UNPARSED dispatches recorded as undetermined (R-13). SC-2 re-verified after the anchoring change.

- [ ] 24a. **GREEN — verifiable goal-condition anchoring (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — helpers.sh `__classify_run_state`/classifier prompt: goal context becomes the scenario-declared verifiable goal condition (goal artifact + content pattern, already computed per poll as art_status) folded into the digest; prompt-prose anchor removed; UNPARSED dispatches recorded as undetermined per R-13. **→ SC-2**
- [ ] 24b. **verify — SC-2 re-verification (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — re-run 2456-sc2-classification-dispatch-red.sh BEHAVIOR_PHASE=GREEN → exit 0 (classifier dispatched with verifiable goal condition; classification in own context). **→ SC-2**

#### Item 2R2 (R-13 amendment, orchestrator remediation under the SC-10 gate halt)

> Spec amendment 2026-09-23: a starved/no-parseable dispatch is a DISPATCH FAILURE event — recorded (attempt + failure mode), retried per checkpoint policy; NOT a classification — no halt-class trigger by itself, no undetermined-cycle ceiling increment; 3 consecutive dispatch failures = HARNESS_FAILURE halt naming the infrastructure surface.

- [ ] 24c. **GREEN — dispatch-failure decoupling (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — helpers.sh `__classify_run_state`/record paths: starved/UNPARSED/model-failure dispatches recorded as dispatch-failure events (mode preserved), not undetermined classifications; no halt-class trigger; no ceiling increment; 3 consecutive failures → HARNESS_FAILURE + notify; checkpoint policy retries. Existing SC-7 decision-record path remains the post-halt mechanism for real classifications. **→ SC-2, SC-6, SC-9**
- [ ] 24d. **verify — R-13 re-verification (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — re-run 2456-sc6-haltclass-halt-notify-red.sh (BEHAVIOR_PHASE=GREEN — parsed undetermined classification still halts+notifies) AND 2456-sc9-undetermined-ceiling-red.sh (BEHAVIOR_PHASE=GREEN — ceiling counts parsed-undetermined classifications only) → both exit 0. **→ SC-6, SC-9**

**Concern transition:** Leaving record lifecycle foundation → entering classification routing. Phase 2 depends on Phase 1's classification taxonomy and determination-record schema.
