# Phase 6 — Semantic poll discipline + stall diagnosis

**Concern:** Every poll performs a full semantic check of progress so far (SC-14); polls occur no less often than every 5 minutes (SC-15); a semantically classified non-progressing run with an identifiable external cause produces decision=`terminate-with-root-cause` naming the diagnosed cause, with timer-escalation re-dispatch blocked (SC-13); GREEN-phase behavioral dispatches commit+push test-needed changes mechanically before the isolated run, with commit deliberation prohibited (SC-16); agent supervisors poll runs at ≤5-min intervals with a full semantic check per poll, retry loops without checks prohibited (SC-17); the mandate is mirrored into AGENTS.md §14 as default deck behavior (SC-18).

**Files:**
- `.opencode/tests-v2/behaviors/helpers.sh` (`__semantic_monitor` poll loop, per-poll semantic-check path, stall-classification path)
- `.opencode/tests-v2/behaviors/<stall-fixture-scenario>.sh` (new fixture scenario)
- `.opencode/tests-v2/AGENTS.md` (§14 alignment for the poll-discipline predicates — minimal delta)

**SCs:** SC-13, SC-14, SC-15, SC-16, SC-17, SC-18, SC-19, SC-20, SC-21, SC-22, SC-23, SC-24, SC-25, SC-26

**Dependencies:** Phase 4 (uses the SC-8 resume gate and the SC-3 determination-record schema; Phase 4 transitively depends on Phase 3)

**Entry Conditions:**
- Phase 4 complete and VbC passed (gate + record schema implemented)
- Coherence gate + baseline check passed (plan steps 1-2)

**Exit Conditions:**
- Every poll's classification is derived from message parts, reasoning parts, and tool calls in the session export; activity/uptime/tool-call count is inadmissible
- Poll interval ≤ 300s on monitored runs
- A semantically classified non-progressing run with an identifiable cause produces decision=`terminate-with-root-cause` naming the diagnosed cause; no re-dispatch path raises a timeout without a diagnosis-bearing record
- GREEN-phase behavioral dispatches commit+push all test-needed changes before the isolated run; no commit deliberation turns

**Code Path Coverage:**
- `__semantic_monitor` poll loop: interval ≤ 300s; per-poll full semantic check (message parts, reasoning parts, tool calls from session.yaml)
- `__semantic_monitor` stall-classification path: off-track/undetermined classification + identifiable-cause scan (orphaned `opencode run`/scenario processes, provider quota/error strings in run output) → decision-record write path constrained to `terminate-with-root-cause`
- GREEN-phase dispatch fixture: §4 ordering invariant (commit+push precede run invocation; no deliberation turns)

**Cross-Cutting SCs:** R-9 (diagnosis-before-retry on semantic classification), R-10 (full semantic check per poll), R-11 (cadence floor), R-12 (mechanical commit+push ordering); SC-8 gate is the blocking mechanism — no new gate introduced.

**Interface Boundaries:**
- No new locking scheme (existing `tmp/.behavior-run.lock` flock discipline)
- No new decision value-set values — `terminate-with-root-cause` already exists in SC-7's allowed set

**State Transitions:**
- any poll → full semantic check (content-derived classification)
- off-track/undetermined + identifiable cause → determination record (decision=`terminate-with-root-cause`, root-cause present) → SC-8 gate blocks resume/re-run until developer-level remediation

**Cost frame:** Running the fixtures costs minutes. Skipping costs days-to-weeks — activity-based "health" reasoning re-dispatches blindly while the actual blocker (orphaned processes, provider quota exhaustion) sits unread (live evidence: the 2026-09-21 #2437 RED run hung ~4 hours); unpinned poll cadence leaves silent stalls unexamined for the entire bash-tool timeout window.

---

- [ ] 92 **pre-regression (**task-card**).** `task(..., prompt: "execute phase-0 task from test-driven-development")`. **→ SC-13..SC-25**
- [ ] 93 **pre-regression-verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-13..SC-25**
- [ ] 94 **RED — diagnosis-before-retry (terminate-with-root-cause on identified-cause non-progressing classification; SC-8 gate blocks timer-escalation re-dispatch) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-13**
- [ ] 95 **GREEN — diagnosis-before-retry (terminate-with-root-cause on identified-cause non-progressing classification; SC-8 gate blocks timer-escalation re-dispatch) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-13**
- [ ] 96 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-13**
- [ ] 97 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-13**
- [ ] 98 **commit-inline (**direct**).** Commit the slice. **→ SC-13**
- [ ] 99 **RED — full-semantic-per-poll (classification derived from message/reasoning/tool-call parts; activity-only inadmissible) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-14**
- [ ] 100 **GREEN — full-semantic-per-poll (classification derived from message/reasoning/tool-call parts; activity-only inadmissible) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-14**
- [ ] 101 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-14**
- [ ] 102 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-14**
- [ ] 103 **commit-inline (**direct**).** Commit the slice. **→ SC-14**
- [ ] 104 **RED — cadence floor (no consecutive-poll gap exceeds 300s) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-15**
- [ ] 105 **GREEN — cadence floor (no consecutive-poll gap exceeds 300s) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-15**
- [ ] 106 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-15**
- [ ] 107 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-15**
- [ ] 108 **commit-inline (**direct**).** Commit the slice. **→ SC-15**
- [ ] 109 **RED — commit ordering (task/push precede the run invocation; no commit deliberation) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-16**
- [ ] 110 **GREEN — commit ordering (task/push precede the run invocation; no commit deliberation) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-16**
- [ ] 111 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-16**
- [ ] 112 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-16**
- [ ] 113 **commit-inline (**direct**).** Commit the slice. **→ SC-16**
- [ ] 114 **RED — supervisor cadence (≤300s gaps, each closed by a content-derived classification; no-check retry loops prohibited) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-17**
- [ ] 115 **GREEN — supervisor cadence (≤300s gaps, each closed by a content-derived classification; no-check retry loops prohibited) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-17**
- [ ] 116 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-17**
- [ ] 117 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-17**
- [ ] 118 **commit-inline (**direct**).** Commit the slice. **→ SC-17**
- [ ] 119 **RED — §14 mirror (supervisor mandate mirrored into AGENTS.md §14) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-18**
- [ ] 120 **GREEN — §14 mirror (supervisor mandate mirrored into AGENTS.md §14) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-18**
- [ ] 121 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-18**
- [ ] 122 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-18**
- [ ] 123 **commit-inline (**direct**).** Commit the slice. **→ SC-18**
- [ ] 124 **RED — async launch form (backgrounded launch + attached ≤300s SQLite-DB supervision schedule) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-19**
- [ ] 125 **GREEN — async launch form (backgrounded launch + attached ≤300s SQLite-DB supervision schedule) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-19**
- [ ] 126 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-19**
- [ ] 127 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-19**
- [ ] 128 **commit-inline (**direct**).** Commit the slice. **→ SC-19**
- [ ] 129 **RED — efficiency-defect marker (excessive deliberation recorded + notified; latency not a marker) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-20**
- [ ] 130 **GREEN — efficiency-defect marker (excessive deliberation recorded + notified; latency not a marker) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-20**
- [ ] 131 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-20**
- [ ] 132 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-20**
- [ ] 133 **commit-inline (**direct**).** Commit the slice. **→ SC-20**
- [ ] 134 **RED — defect-marker gate (recorded marker ⇒ sub-agent halt + ORCHESTRATOR_DECISION_REQUIRED; orchestrator researches/remediates; new dispatch or resume per orchestrator determination) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-21**
- [ ] 135 **GREEN — defect-marker gate (recorded marker ⇒ sub-agent halt + ORCHESTRATOR_DECISION_REQUIRED; orchestrator researches/remediates; new dispatch or resume per orchestrator determination) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-21**
- [ ] 136 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-21**
- [ ] 137 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-21**
- [ ] 138 **commit-inline (**direct**).** Commit the slice. **→ SC-21**
- [ ] 139 **RED — classification freshness (abort suppression valid only within the freshness window; stale verdicts never suppress) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-22**
- [ ] 140 **GREEN — classification freshness (abort suppression valid only within the freshness window; stale verdicts never suppress) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-22**
- [ ] 141 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-22**
- [ ] 142 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-22**
- [ ] 143 **commit-inline (**direct**).** Commit the slice. **→ SC-22**
- [ ] 144 **RED — fresh-session isolation (fresh test home + fresh session; no prior-session content) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-23**
- [ ] 145 **GREEN — fresh-session isolation (fresh test home + fresh session; no prior-session content) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-23**
- [ ] 146 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-23**
- [ ] 147 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-23**
- [ ] 148 **commit-inline (**direct**).** Commit the slice. **→ SC-23**
- [ ] 149 **RED — early termination (decided verdict ⇒ terminate run + monitor within one poll cycle) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-24**
- [ ] 150 **GREEN — early termination (decided verdict ⇒ terminate run + monitor within one poll cycle) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-24**
- [ ] 151 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-24**
- [ ] 152 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-24**
- [ ] 153 **commit-inline (**direct**).** Commit the slice. **→ SC-24**
- [ ] 154 **RED — cleanup target selection (kill targets by scenario markers; own-PID/parent-PID excluded) (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — the predicate is absent/unenforced on the current harness; the enforcement scenario fails. **→ SC-25**
- [ ] 155 **GREEN — cleanup target selection (kill targets by scenario markers; own-PID/parent-PID excluded) (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — implement the minimal predicate; the enforcement scenario passes. **→ SC-25**
- [ ] 156 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-25**
- [ ] 157 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — evidence per the SC's declared type. **→ SC-25**
- [ ] 158 **commit-inline (**direct**).** Commit the slice. **→ SC-25**
- [ ] 159 **RED — hang bound (**task-card**).** `task(..., prompt: "execute red task from test-driven-development")` — hung-stream fixture (no events/output across the bounded window, no provider-error on record); the supervisor lets it proceed — clear-FAIL assertion fails. **→ SC-26**
- [ ] 160 **GREEN — hang bound (**task-card**).** `task(..., prompt: "execute green task from test-driven-development")` — at the bound the supervisor records FAILED(stall) with root-cause provider-stream-hung and terminates run + monitor within one poll cycle. **→ SC-26**
- [ ] 161 **post-regression (**task-card**).** `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-26**
- [ ] 162 **verify (**task-card**).** `task(..., prompt: "execute verify task from verification-before-completion")` — session-export assertion: bound exceeded ⇒ FAILED verdict + termination; no wait-on-hang. **→ SC-26**
- [ ] 163 **commit-inline (**direct**).** Commit the hang-bound scenario. **→ SC-26**
- [ ] 164 **VbC (**task-card**).** Verify SC-13..SC-26 verdicts are PASS with matching evidence types. **→ SC-13..SC-26**
- [ ] 165 **VbC consolidation (**direct**).** Consolidate the fourteen verdicts into the phase evidence table.
- [ ] 166 **Phase 6 gate (**direct**).** Final phase-6 completeness confirmation (all fourteen SCs) before post-implementation entry.
- [ ] 160 **VbC consolidation (**direct**).** Consolidate the thirteen verdicts into the phase evidence table.
- [ ] 161 **Phase 6 gate (**direct**).** Final phase-6 completeness confirmation (all thirteen SCs) before post-implementation entry.

**Concern transition:** Leaving Phase 6 (semantic poll discipline + stall diagnosis) → entering the post-implementation pipeline.
