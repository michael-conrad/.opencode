# Phase 2 — Classification routing (off-track / progressing / halt-class / decision)

**Concern:** Route classification outcomes to their governed paths — off-track notify, progressing continue, halt-class halt+notify, and the recorded orchestrator decision field.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh`

**SCs:** SC-4, SC-5, SC-6, SC-7

**Dependencies:** Phase 1 (classification taxonomy from SC-2; record schema from SC-3)

**Entry Conditions:**
- Phase 1 complete and VbC passed (determination record schema exists)
- Coherence gate + baseline check passed (plan steps 1-2)

**Exit Conditions:**
- Off-goal motion classified off-track and routed to orchestrator notification — never silent continuation
- Progressing runs continue polling regardless of duration
- Halt-class states (undetermined / excessive-without-classification / direction-deviation) halt monitoring and notify before any further dispatch
- Decision field recorded with allowed value-set {continue-new-dispatch, terminate-with-root-cause}

**Code Path Coverage:**
- `__semantic_monitor` — classification routing after the SC-2 dispatch; halt+notify path emitting the `ORCHESTRATOR_DECISION_REQUIRED`-class stderr convention; polling continuation branch; decision-field write path into the determination record

**Cross-Cutting SCs:** `BEHAVIOR_SEMANTIC_MONITOR` flag gates all routing; stderr conventions (FATAL:/HARNESS_FAILURE:/ORCHESTRATOR_DECISION_REQUIRED-class); the decision field is the append-only orchestrator-decision slot of the Phase 1 record schema.

**Interface Boundaries:**
- Classification enum {progressing-directionally, off-track, undetermined} consumed by the halt+notify routing (shared by SC-4 and SC-6 paths)
- with-test-home CLI unchanged; no flag changes in this phase

**State Transitions:**
- polling → polling on progressing-directionally (SC-5); polling → halted-notify-orchestrator on halt-class outcomes (SC-6); halted-notify-orchestrator → continue-new-dispatch | terminate-with-root-cause via recorded decision (SC-7)

**Cost frame:** Running the routing fixtures costs minutes of live-model execution. Skipping costs days-to-weeks — off-target runs silently consume the entire run budget, verdicts are issued for runs that never approached the scenario goal, and every monitor halt re-enters the silent kill+export cycle with no orchestrator visibility.

---

- [ ] 25. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-4**
- [ ] 26. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-4**
- [ ] 27. **RED — off-track notification (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — off-track fixture run silently continues with no orchestrator notification; assertion fails. **→ SC-4**
- [ ] 28. **GREEN — off-track notification (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — off-track classification emits the orchestrator notification on stderr; no silent continuation. **→ SC-4**
- [ ] 29. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-4**
- [ ] 30. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — off-track fixture run shows the notification, not continuation. **→ SC-4**
- [ ] 31. **commit-inline (**direct**).** Commit the classification routing (off-track path). **→ SC-4**
- [ ] 32. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-5**
- [ ] 33. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-5**
- [ ] 34. **RED — progressing continues (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — progressing run halted by a duration cap; assertion fails. **→ SC-5**
- [ ] 35. **GREEN — progressing continues (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — progressing runs keep polling without duration cap. **→ SC-5**
- [ ] 36. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-5**
- [ ] 37. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — progressing fixture continues polling past the halt threshold. **→ SC-5**
- [ ] 38. **commit-inline (**direct**).** Commit the polling continuation branch. **→ SC-5**
- [ ] 39. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-6**
- [ ] 40. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6**
- [ ] 41. **RED — halt-class halt+notify (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — undetermined condition continues without halt/notification; assertion fails. **→ SC-6**
- [ ] 42. **GREEN — halt-class halt+notify (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — halt-class states halt monitoring and notify the orchestrator before any further dispatch. **→ SC-6**
- [ ] 43. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-6**
- [ ] 44. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral run asserts halt and orchestrator notification for a halt-class condition. **→ SC-6**
- [ ] 45. **commit-inline (**direct**).** Commit the halt-class routing. **→ SC-6**
- [ ] 46. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-7**
- [ ] 47. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-7**
- [ ] 48. **RED — decision field (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — no decision field recorded in the determination record after an orchestrator decision; assertion fails. **→ SC-7**
- [ ] 49. **GREEN — decision field (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — record the decision field with allowed value-set {continue-new-dispatch, terminate-with-root-cause}; root-cause present when terminate-with-root-cause. **→ SC-7**
- [ ] 50. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-7**
- [ ] 51. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral run asserts the recorded decision field carries an allowed value. **→ SC-7**
- [ ] 52. **commit-inline (**direct**).** Commit the decision-record write path. **→ SC-7**

#### Phase 2 VbC

- [ ] 53. **VbC (**task-card**).** Verify all four SC-4..SC-7 verdicts are PASS with behavioral evidence artifacts. **→ SC-4, SC-5, SC-6, SC-7**

**Concern transition:** Leaving classification routing → entering the resume gate + ceiling. Phase 3 depends on Phase 1's record schema (Phase 2's routing feeds records the gate reads).
