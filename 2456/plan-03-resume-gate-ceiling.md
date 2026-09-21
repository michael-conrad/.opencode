# Phase 3 — Resume gate + undetermined-cycle ceiling

**Concern:** Mechanical gate + counter in `with-test-home` — block resume/re-run of aborted/killed dispatches without a recorded non-undetermined determination; ceiling (3) on undetermined cycles with CEILING_REACHED block.

**Files:**
- `.opencode/tests-v2/with-test-home`
- `.opencode/tests-v2/behaviors/helpers.sh` (ceiling counter under the existing flock discipline)

**SCs:** SC-8, SC-9

**Dependencies:** Phase 1 (gate reads the SC-3 determination record; counter counts undetermined records)

**Entry Conditions:**
- Phase 1 complete and VbC passed (record schema exists; Phase 2 routing is not a hard prerequisite for the gate predicate but the DAG recommends Phase 1 only)
- Coherence gate + baseline check passed (plan steps 1-2)

**Exit Conditions:**
- Resume (`--resume-home` or `--continue`) and re-run of an aborted/killed dispatch blocked with a FATAL-class message when no recorded non-undetermined determination exists; valid determination permits resume
- Undetermined-cycle counter persisted across invocations under `tmp/.behavior-run.lock` flock; counter ≥ 3 produces the CEILING_REACHED mechanical block persisting until developer-level remediation

**Code Path Coverage:**
- `with-test-home` resume/clone guard chain — new determination-record read gate as an internal precondition check before resume/re-run; no CLI flag changes
- helpers.sh flock discipline (`tmp/.behavior-run.lock`) — new ceiling counter persistence; CEILING_REACHED message joins the existing stderr convention

**Cross-Cutting SCs:** Determination record spans SC-3/SC-7/SC-8/SC-10 (this phase is the record's primary consumer); stderr conventions (FATAL-class, CEILING_REACHED); flock/locking discipline (no new locking scheme); `BEHAVIOR_SEMANTIC_MONITOR` coupling — the gate is inert for fresh invocations without the monitor lifecycle.

**Interface Boundaries:**
- with-test-home CLI surface unchanged (`--resume-home`, `--continue`, `--session`, `--setup`, `--clean`, `--clean-all`); gate is a precondition check inside the resume path
- Gate predicate is mechanical — pure record predicate, no semantic judgment

**State Transitions:**
- aborted/killed dispatch → resume-blocked (no non-undetermined determination; FATAL-class); aborted/killed → resume-permitted (valid determination); resume-blocked → CEILING_REACHED-persistent (counter ≥ 3, cleared only by developer-level remediation)

**Cost frame:** Running the gate test costs minutes; verifying the ceiling predicate with synthetic records costs seconds. Skipping costs weeks — aborted dispatches resume ungated, producing verdicts about sessions with no recorded determination, and undetermined retry loops run unbounded burning live-model budget, a 1000× death-spiral multiplier.

---

- [ ] 54. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-8**
- [ ] 55. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-8**
- [ ] 56. **RED — determination gate (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — resume/re-run after abort without a determination proceeds; assertion fails. **→ SC-8**
- [ ] 57. **GREEN — determination gate (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — `with-test-home` resume/re-run path (both `--resume-home` and `--continue` variants) reads the determination record; missing/non-undetermined-record-absent → FATAL block; valid record → pass-through. **→ SC-8**
- [ ] 58. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-8**
- [ ] 59. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — abort → resume blocked with FATAL; valid determination → proceeds. **→ SC-8**
- [ ] 60. **commit-inline (**direct**).** Commit the with-test-home gate. **→ SC-8**
- [ ] 61. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-9**
- [ ] 62. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-9**
- [ ] 63. **RED — ceiling counter (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — third undetermined cycle does not block; assertion fails. **→ SC-9**
- [ ] 64. **GREEN — ceiling counter (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — counter persisted under the flock discipline; ≥ 3 → CEILING_REACHED mechanical block persisting until remediation. **→ SC-9**
- [ ] 65. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-9**
- [ ] 66. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — synthetic determination-record predicate tests (no model dispatch required); ceiling = 3 default and CEILING_REACHED message asserted. **→ SC-9**
- [ ] 67. **commit-inline (**direct**).** Commit the counter + gate predicate. **→ SC-9**

#### Phase 3 VbC

- [ ] 68. **VbC (**task-card**).** Verify both SC-8 (behavioral) and SC-9 (structural) verdicts are PASS with matching evidence types. **→ SC-8, SC-9**

**Concern transition:** Leaving the resume gate + ceiling → entering false-signal folding, enforcement scenario, and doc alignment. Phase 4 depends on Phase 3's implemented gate predicates.
