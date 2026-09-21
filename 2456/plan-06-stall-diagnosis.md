# Phase 6 — Stall diagnosis enforcement

**Concern:** Diagnosis-before-retry on stalled runs (SC-13): a stall with zero progress evidence and an identifiable external cause must produce decision=`terminate-with-root-cause` naming the diagnosed cause; timer-escalation re-dispatch without diagnosis is prohibited and blocked by the SC-8 gate.

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (`__semantic_monitor` stall-classification path)
- `.opencode/tests-v2/behaviors/<stall-fixture-scenario>.sh` (new fixture scenario)
- `.opencode/tests-v2/AGENTS.md` (§14 alignment for the stall predicate — minimal delta)

**SCs:** SC-13

**Dependencies:** Phase 4 (uses the SC-8 resume gate and the SC-3 determination-record schema; Phase 4 transitively depends on Phase 3)

**Entry Conditions:**
- Phase 4 complete and VbC passed (gate + record schema implemented)
- Coherence gate + baseline check passed (plan steps 1-2)

**Exit Conditions:**
- Stall fixture run produces a determination record with decision=`terminate-with-root-cause` naming the diagnosed external cause; no re-dispatch path exists that raises a timeout without a diagnosis-bearing record

**Code Path Coverage:**
- `__semantic_monitor` stall detection: zero-progress poll window + identifiable-cause scan of run evidence (orphaned `opencode run`/scenario processes via process table, provider quota/error strings in run output)
- Decision-record write path: decision field constrained to `terminate-with-root-cause` for the stall class

**Cross-Cutting SCs:** R-9 (diagnosis-before-retry); SC-8 gate is the blocking mechanism — no new gate is introduced.

**Interface Boundaries:**
- No new locking scheme (existing `tmp/.behavior-run.lock` flock discipline)
- No new decision value-set values — `terminate-with-root-cause` already exists in SC-7's allowed set

**State Transitions:**
- stall-class run → determination record (decision=`terminate-with-root-cause`, root-cause present) → SC-8 gate blocks resume/re-run until developer-level remediation

**Cost frame:** Running the stall fixture costs minutes. Skipping costs days — stalls with identifiable causes get answered with endlessly increasing timers and blind re-dispatch (live evidence: the 2026-09-21 #2437 RED run hung ~4 hours on an orphaned `opencode run` while a provider quota error sat unread in the dispatch failure output).

---

- [ ] 92. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-13**
- [ ] 93. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-13**
- [ ] 94. **RED — stall fixture (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — stall fixture (hung child process + provider-error evidence in run logs) produces no decision or a bare continue-new-dispatch; assertion fails. **→ SC-13**
- [ ] 95. **GREEN — stall classification (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — `__semantic_monitor` classifies the stall, records decision=`terminate-with-root-cause` naming the diagnosed cause. **→ SC-13**
- [ ] 96. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-13**
- [ ] 97. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral assertion: determination record carries decision=`terminate-with-root-cause` with a root-cause naming the identified problem. **→ SC-13**
- [ ] 98. **commit-inline (**direct**).** Commit the stall-classification path + fixture. **→ SC-13**
- [ ] 99. **VbC (**task-card**).** Verify SC-13 (behavioral) verdict is PASS with matching evidence type. **→ SC-13**

**Concern transition:** Leaving Phase 6 (stall diagnosis enforcement) → entering the post-implementation pipeline.
