# Phase 4 — False-signal folding + enforcement scenario

**Concern:** Fold monitor false-positive aborts into the determination record as false_signal annotations; deliver the behavioral enforcement scenario (concern-map: `false-signal-and-enforcement`).

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (abort-folding path)
- `.opencode/tests-v2/behaviors/<new-scenario>.sh` (new enforcement scenario)

**SCs:** SC-10, SC-11

**Dependencies:** Phase 3 (SC-11's scenario exercises the SC-8 gate)

**Entry Conditions:**
- Phase 3 complete and VbC passed (gate predicates implemented)
- Coherence gate + baseline check passed (plan steps 1-2)

**Exit Conditions:**
- Reproduced wrong abort (#2454-style duplicate-running-event over-count) produces a false_signal annotation in the determination record
- New enforcement scenario asserting the gate blocks re-dispatch without determination passes via the `test-enforcement.sh` run

**Code Path Coverage:**
- helpers.sh abort path — kill + export + false_signal folding target (append-only annotation into the determination record)
- new scenario script — artifact-only generator; registered in `test-enforcement.sh --list`; sources helpers.sh with the behavior_run contract preserved

**Cross-Cutting SCs:** Determination record append-only semantics (false_signal annotations); stderr conventions; test-enforcement.sh scenario registry; `BEHAVIOR_SEMANTIC_MONITOR` opt-in unchanged.

**Interface Boundaries:**
- Scenario sources helpers.sh; behavior_run contract (artifact-only, exit 0) preserved
- SC-11 scenario registered as a new `--list` entry; existing scenarios unaffected

**State Transitions:**
- any → aborted on monitor abort/kill; false positives folded as false_signal annotation (append-only) rather than silently retried

**Cost frame:** Reproducing the false-signal costs minutes; running the new scenario costs minutes. Skipping costs weeks — monitor false positives silently retry discarding the evidence that the monitor itself is defective, and the gate has no enforcement test so regressions ship undetected.

---

- [ ] 69. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-10**
- [ ] 70. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-10**
- [ ] 71. **RED — false-signal folding (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — reproduced false-positive abort produces no false_signal annotation in the determination record; assertion fails. **→ SC-10**
- [ ] 72. **GREEN — false-signal folding (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — wrong abort folds a false_signal annotation into the determination record (append-only; annotation presence is the sole assertion). **→ SC-10**
- [ ] 73. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-10**
- [ ] 74. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — #2454-style duplicate-running-event over-count reproduced; annotation asserted present. **→ SC-10**
- [ ] 75. **commit-inline (**direct**).** Commit the abort-folding path. **→ SC-10**
- [ ] 76. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-11**
- [ ] 77. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-11**
- [ ] 78. **RED — enforcement scenario (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — new scenario asserts the gate blocks re-dispatch without determination and fails against the pre-gate harness. **→ SC-11**
- [ ] 79. **GREEN — enforcement scenario (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — scenario passes against the gated harness via the `test-enforcement.sh` run (registration in `--list` is the enabling precondition of the same deliverable). **→ SC-11**
- [ ] 80. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-11**
- [ ] 81. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — scenario passes via `test-enforcement.sh` run. **→ SC-11**
- [ ] 82. **commit-inline (**direct**).** Commit the new `behaviors/<scenario>.sh`. **→ SC-11**

#### Phase 4 VbC

- [ ] 83. **VbC (**task-card**).** Verify SC-10/SC-11 (behavioral) verdicts are PASS with matching evidence types. **→ SC-10, SC-11**

**Concern transition:** Leaving Phase 4 (false-signal-and-enforcement) → entering Phase 5 (docs-alignment).
