# Phase 6 — Semantic poll discipline + stall diagnosis

**Concern:** Every poll performs a full semantic check of progress so far (SC-14); polls occur no less often than every 5 minutes (SC-15); a semantically classified non-progressing run with an identifiable external cause produces decision=`terminate-with-root-cause` naming the diagnosed cause, with timer-escalation re-dispatch blocked (SC-13).

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (`__semantic_monitor` poll loop, per-poll semantic-check path, stall-classification path)
- `.opencode/tests-v2/behaviors/<stall-fixture-scenario>.sh` (new fixture scenario)
- `.opencode/tests-v2/AGENTS.md` (§14 alignment for the poll-discipline predicates — minimal delta)

**SCs:** SC-13, SC-14, SC-15

**Dependencies:** Phase 4 (uses the SC-8 resume gate and the SC-3 determination-record schema; Phase 4 transitively depends on Phase 3)

**Entry Conditions:**
- Phase 4 complete and VbC passed (gate + record schema implemented)
- Coherence gate + baseline check passed (plan steps 1-2)

**Exit Conditions:**
- Every poll's classification is derived from message parts, reasoning parts, and tool calls in the session export; activity/uptime/tool-call count is inadmissible
- Poll interval ≤ 300s on monitored runs
- A semantically classified non-progressing run with an identifiable cause produces decision=`terminate-with-root-cause` naming the diagnosed cause; no re-dispatch path raises a timeout without a diagnosis-bearing record

**Code Path Coverage:**
- `__semantic_monitor` poll loop: interval ≤ 300s; per-poll full semantic check (message parts, reasoning parts, tool calls from session.yaml)
- `__semantic_monitor` stall-classification path: off-track/undetermined classification + identifiable-cause scan (orphaned `opencode run`/scenario processes, provider quota/error strings in run output) → decision-record write path constrained to `terminate-with-root-cause`

**Cross-Cutting SCs:** R-9 (diagnosis-before-retry on semantic classification), R-10 (full semantic check per poll), R-11 (cadence floor); SC-8 gate is the blocking mechanism — no new gate introduced.

**Interface Boundaries:**
- No new locking scheme (existing `tmp/.behavior-run.lock` flock discipline)
- No new decision value-set values — `terminate-with-root-cause` already exists in SC-7's allowed set

**State Transitions:**
- any poll → full semantic check (content-derived classification)
- off-track/undetermined + identifiable cause → determination record (decision=`terminate-with-root-cause`, root-cause present) → SC-8 gate blocks resume/re-run until developer-level remediation

**Cost frame:** Running the fixtures costs minutes. Skipping costs days-to-weeks — activity-based "health" reasoning re-dispatches blindly while the actual blocker (orphaned processes, provider quota exhaustion) sits unread (live evidence: the 2026-09-21 #2437 RED run hung ~4 hours); unpinned poll cadence leaves silent stalls unexamined for the entire bash-tool timeout window.

---

- [ ] 92. **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-13, SC-14, SC-15**
- [ ] 93. **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-13, SC-14, SC-15**
- [ ] 94. **RED — full-semantic-per-poll (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — monitor poll issues a classification without deriving it from message/reasoning/tool-call parts (activity-only short-circuit); assertion fails. **→ SC-14**
- [ ] 95. **GREEN — full-semantic-per-poll (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — every poll performs a full semantic check of progress so far; classification record cites content parts; activity/uptime/tool-call count inadmissible. **→ SC-14**
- [ ] 96. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-14**
- [ ] 97. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral fixture asserts content-citing classification; activity-only classification fails. **→ SC-14**
- [ ] 98. **commit-inline (**direct**).** Commit the per-poll semantic-check path. **→ SC-14**
- [ ] 99. **RED — cadence floor (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — monitored fixture run shows a poll gap exceeding 300 seconds; assertion fails. **→ SC-15**
- [ ] 100. **GREEN — cadence floor (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — monitor polls at least every 5 minutes; no consecutive-poll gap exceeds 300s. **→ SC-15**
- [ ] 101. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-15**
- [ ] 102. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — poll-log gaps asserted ≤ 300s. **→ SC-15**
- [ ] 103. **commit-inline (**direct**).** Commit the monitor-loop interval. **→ SC-15**
- [ ] 104. **RED — diagnosis-before-retry (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — fixture run classified non-progressing by the full semantic check, with an identifiable external cause, produces no decision or a bare continue-new-dispatch; assertion fails. **→ SC-13**
- [ ] 105. **GREEN — diagnosis-before-retry (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — recorded decision is terminate-with-root-cause naming the diagnosed external cause; SC-8's gate blocks timer-escalation re-dispatch until the record exists. **→ SC-13**
- [ ] 106. **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-13**
- [ ] 107. **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — behavioral assertion: determination record carries decision=terminate-with-root-cause with a root-cause naming the identified problem. **→ SC-13**
- [ ] 108. **commit-inline (**direct**).** Commit the stall-classification path + fixture. **→ SC-13**
- [ ] 109. **VbC (**task-card**).** Verify SC-13/SC-14/SC-15 (behavioral) verdicts are PASS with matching evidence types. **→ SC-13, SC-14, SC-15**

**Concern transition:** Leaving Phase 6 (semantic poll discipline + stall diagnosis) → entering the post-implementation pipeline.
