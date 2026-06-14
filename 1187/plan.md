# [PLAN] Restore pre-implementation readiness checks to verify-authorization chain

## Goal

Re-insert three readiness checks (verify-codebase, verify-blockers, verify-already-implemented) that were dropped during the `d188b375` decomposition of `verify-authorization.md`, plus add a main-issue closure check that was never present in the pre-image.

## Architecture

The verify-authorization chain is a sequential sub-task pipeline in `skills/approval-gate/tasks/verify-authorization.md`. Step 5d inserts between Step 5c (gap-fill) and Step 6 (auto-dispatch) as 4 new sub-tasks. The auto-dispatch procedure in `auto-dispatch.md` gains a Step 0 pre-check that reads Step 5d results before routing. The `verify-already-implemented.md` task file gains a Step 0 main-issue closure check.

## Orchestrator Execution Protocol

This plan is an **executable dispatch sequence**. The dispatch table format per phase conforms to the requirements defined in [michael-conrad/.opencode#1191](https://github.com/michael-conrad/.opencode/issues/1191) (pending implementation). The orchestrator MUST:

1. Read the dispatch tables in this plan to determine the gate sequence
2. Execute every gate in every phase in numeric order (G1, G2, G3, ...)
3. NOT skip any gate — every row is mandatory
4. NOT reorder gates — the sequence is the plan
5. For `sub-task` gates: call `task()` with the exact `Receives Context` JSON object as the prompt, using the specified `Sub-Agent Type`
6. For `inline` gates: execute the described operation directly (no sub-agent)
7. After each gate completes, verify the SCs listed in that gate's SCs column
8. Report progress via chat output only — zero GitHub Issue comments during implementation unless absolutely warranted (blocker that requires developer input, spec revision that changes scope). Issue bodies and plan files are revised directly and synced as needed — comments are not a revision mechanism. Per-gate status ticks, phase transitions, and intermediate state tracking in issue comments is forbidden — it creates useless noise for stakeholders and developers who must filter through hundreds of status updates to find meaningful content
9. After each phase completes, run the Inter-Phase Handoff steps before advancing to the next phase

## Tech Stack

- Markdown task files (`.md`) in `.opencode/skills/approval-gate/tasks/`
- Behavioral tests in `.opencode/tests/behaviors/` using `helpers.sh` assertion helpers
- Content-verification tests in `.opencode/tests/test-enforcement.sh`

## File Structure

| File | Responsibility |
|------|---------------|
| `skills/approval-gate/tasks/verify-authorization.md` | Sub-task run order table + path selection — add Step 5d rows, update path table |
| `skills/approval-gate/tasks/verify-authorization/verify-codebase.md` | NEW — thin wrapper dispatching `tasks/verify-codebase.md` |
| `skills/approval-gate/tasks/verify-authorization/verify-blockers.md` | NEW — thin wrapper dispatching `tasks/verify-blockers.md` |
| `skills/approval-gate/tasks/verify-authorization/verify-closed-issue-main.md` | NEW — main-issue closure check + reconcile-issue-graph dispatch |
| `skills/approval-gate/tasks/verify-authorization/verify-already-implemented.md` | NEW — thin wrapper dispatching `tasks/verify-already-implemented.md` |
| `skills/approval-gate/tasks/verify-authorization/auto-dispatch.md` | Add Step 0 pre-check reading Step 5d results |
| `skills/approval-gate/tasks/verify-already-implemented.md` | Add Step 0 main-issue closure check before SC verification |
| `.opencode/tests/behaviors/verify-auth-step5d.sh` | NEW — behavioral tests for SC-9, SC-10, SC-11 |

## SC-ID Traceability

| SC-ID | Phase | Evidence Type | Verification Method |
|-------|-------|---------------|-------------------|
| SC-1 | Phase 1 | `string` | grep for Step 5d rows in verify-authorization.md |
| SC-2 | Phase 1 | `string` | grep for path table updates in verify-authorization.md |
| SC-3 | Phase 2 | `structural` | file existence check |
| SC-4 | Phase 2 | `structural` | file existence check |
| SC-5 | Phase 2 | `structural` | file existence check |
| SC-6 | Phase 2 | `structural` | file existence check |
| SC-7 | Phase 3 | `string` | grep for Step 0 in auto-dispatch.md |
| SC-8 | Phase 4 | `string` | grep for Step 0 in verify-already-implemented.md |
| SC-9 | Phase 2 | `behavioral` | `opencode-cli run` → assert_semantic |
| SC-10 | Phase 2 | `behavioral` | `opencode-cli run` → assert_semantic |
| SC-11 | Phase 2 | `behavioral` | `opencode-cli run` → assert_semantic |

---

## Step 0.5: Pipeline-Readiness Gate Check (HARD GATE)

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G0.5: Pipeline-Readiness | inline | N/A | — | — | — |

**G0.5 orchestrator executes:**
1. Read `.opencode/.issues/1187/sc-pipeline-readiness.yaml`
2. Assert `status: PASS`
3. If FAIL or file missing: **HALT** with `SPEC_NOT_READY_FOR_PIPELINE`
4. If PASS: extract `sc_summary` (total_scs=11, atomic, with_dependencies, single_concern) and phase dependency declarations

---

## Phase 1: Add Step 5d to verify-authorization.md Sub-Task Table + Update Path Selection

### Phase 1 — Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: SC-Coherence-Gate | sub-task | yes (blind) | `pre-analysis` | `{"issue_number": 1187, "task_description": "verify SC-1 and SC-2 coherence for Phase 1", "pipeline_phase": "phase1", "sc_ids": ["SC-1", "SC-2"]}` | SC-1, SC-2 |
| G2: Pre-RED-Baseline | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm all PASS", "pipeline_phase": "phase1"}` | — |
| G3: RED-Phase | sub-task | yes (blind) | `general` | `{"task_description": "write content-verification test for SC-1 and SC-2 expecting FAIL", "pipeline_phase": "phase1", "sc_ids": ["SC-1", "SC-2"]}` | SC-1, SC-2 |
| G4: RED-Doublecheck | inline | N/A | — | — | SC-1, SC-2 |
| G5: GREEN-Phase | sub-task | yes (blind) | `general` | `{"task_description": "implement Step 5d rows + path table update in verify-authorization.md", "pipeline_phase": "phase1", "sc_ids": ["SC-1", "SC-2"]}` | SC-1, SC-2 |
| G6: Checkpoint-Commit | inline | N/A | — | — | — |
| G7: Structural-Checks | sub-task | yes (blind) | `general` | `{"task_description": "lint/format verify-authorization.md", "pipeline_phase": "phase1"}` | — |
| G8: GREEN-Doublecheck | inline | N/A | — | — | SC-1, SC-2 |
| G9: GREEN-VbC | sub-task | yes (blind) | `general` | `{"task_description": "verification-before-completion against SC-1, SC-2", "pipeline_phase": "phase1", "sc_ids": ["SC-1", "SC-2"]}` | SC-1, SC-2 |
| G10: Adversarial-Audit | sub-task | yes (blind) | `resolve-models` → 2 auditors | `{"audit_phase": "phase1", "audit_type": "plan-fidelity + concern-separation", "sc_ids": ["SC-1", "SC-2"]}` | SC-1, SC-2 |
| G11: Cross-Validate | inline | N/A | — | — | SC-1, SC-2 |
| G12: Regression-Check | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm nothing broken", "pipeline_phase": "phase1"}` | — |
| G13: Review-Prep | sub-task | yes (blind) | `general` | `{"task_description": "review-prep for phase 1 changes", "pipeline_phase": "phase1"}` | — |
| G14: Exec-Summary | inline | N/A | — | — | SC-1, SC-2 |
| G15: Z3 SAT Validation | sub-task | yes (blind) | `general` | `{"task_description": "run solve model + solve check for phase 1 dependency contract", "pipeline_phase": "phase1"}` | — |

**Concern boundary:** Entering — modifying the verify-authorization chain routing table. Leaving — spec analysis. Handoff: spec body parsed, affected files identified, SCs enumerated.

**Files:** `skills/approval-gate/tasks/verify-authorization.md` (lines 19-45: sub-task table + path selection)
**SCs covered:** SC-1, SC-2

### Phase 1 — GREEN Implementation Details (G5)

**G5 sub-agent implements:**

1. Insert 4 rows into sub-task run order table in `verify-authorization.md` after Step 5c row (line 34):
   ```
   | 5d.1 | `verify-authorization/verify-codebase` | Staleness detection, superseding issue check |
   | 5d.2 | `verify-authorization/verify-blockers` | Blocking dependency check |
   | 5d.3 | `verify-authorization/verify-closed-issue-main` | Main issue prior-closure verification |
   | 5d.4 | `verify-authorization/verify-already-implemented` | Terminal gate: auto-close or proceed |
   ```

2. Update path selection table (lines 40-45):
   - **gap-fill-path:** `0.5, 1, 5b.5+5c, **5d**, then 6`
   - **medium-path:** `0.5, 1, 4.5, 4.6, 5, **5d**, then 6`
   - **full-path:** all steps + 5d

3. Run test → capture output → expected PASS (exit 0)

---

## Phase 2: Create 4 New Sub-Task Files + Behavioral Tests

### Phase 2 — Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: SC-Coherence-Gate | sub-task | yes (blind) | `pre-analysis` | `{"issue_number": 1187, "task_description": "verify SC-3 through SC-6 and SC-9 through SC-11 coherence for Phase 2", "pipeline_phase": "phase2", "sc_ids": ["SC-3", "SC-4", "SC-5", "SC-6", "SC-9", "SC-10", "SC-11"]}` | SC-3–SC-6, SC-9–SC-11 |
| G2: Pre-RED-Baseline | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm all PASS", "pipeline_phase": "phase2"}` | — |
| G3: RED-Phase | sub-task | yes (blind) | `general` | `{"task_description": "write behavioral tests for SC-9/SC-10/SC-11 + content-verification tests for SC-3/SC-4/SC-5/SC-6, all expecting FAIL", "pipeline_phase": "phase2", "sc_ids": ["SC-3", "SC-4", "SC-5", "SC-6", "SC-9", "SC-10", "SC-11"]}` | SC-3–SC-6, SC-9–SC-11 |
| G4: RED-Doublecheck | inline | N/A | — | — | SC-3–SC-6, SC-9–SC-11 |
| G5: GREEN-Phase | sub-task | yes (blind) | `general` | `{"task_description": "create 4 sub-task wrapper files + behavioral test file", "pipeline_phase": "phase2", "sc_ids": ["SC-3", "SC-4", "SC-5", "SC-6", "SC-9", "SC-10", "SC-11"]}` | SC-3–SC-6, SC-9–SC-11 |
| G6: Checkpoint-Commit | inline | N/A | — | — | — |
| G7: Structural-Checks | sub-task | yes (blind) | `general` | `{"task_description": "lint/format verify-authorization/ directory", "pipeline_phase": "phase2"}` | — |
| G8: GREEN-Doublecheck | inline | N/A | — | — | SC-3–SC-6, SC-9–SC-11 |
| G9: GREEN-VbC | sub-task | yes (blind) | `general` | `{"task_description": "verification-before-completion against SC-3 through SC-6 and SC-9 through SC-11", "pipeline_phase": "phase2", "sc_ids": ["SC-3", "SC-4", "SC-5", "SC-6", "SC-9", "SC-10", "SC-11"]}` | SC-3–SC-6, SC-9–SC-11 |
| G10: Adversarial-Audit | sub-task | yes (blind) | `resolve-models` → 2 auditors | `{"audit_phase": "phase2", "audit_type": "plan-fidelity + concern-separation", "sc_ids": ["SC-3", "SC-4", "SC-5", "SC-6", "SC-9", "SC-10", "SC-11"]}` | SC-3–SC-6, SC-9–SC-11 |
| G11: Cross-Validate | inline | N/A | — | — | SC-3–SC-6, SC-9–SC-11 |
| G12: Regression-Check | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm nothing broken", "pipeline_phase": "phase2"}` | — |
| G13: Review-Prep | sub-task | yes (blind) | `general` | `{"task_description": "review-prep for phase 2 changes", "pipeline_phase": "phase2"}` | — |
| G14: Exec-Summary | inline | N/A | — | — | SC-3–SC-6, SC-9–SC-11 |
| G15: Z3 SAT Validation | sub-task | yes (blind) | `general` | `{"task_description": "run solve model + solve check for phase 2 dependency contract", "pipeline_phase": "phase2"}` | — |

**Concern boundary:** Entering — file creation for new sub-task wrappers. Leaving — Phase 1 table modifications. Handoff: verify-authorization.md now references Step 5d sub-tasks that don't exist yet.

**Files:**
- `skills/approval-gate/tasks/verify-authorization/verify-codebase.md` — NEW
- `skills/approval-gate/tasks/verify-authorization/verify-blockers.md` — NEW
- `skills/approval-gate/tasks/verify-authorization/verify-closed-issue-main.md` — NEW
- `skills/approval-gate/tasks/verify-authorization/verify-already-implemented.md` — NEW
- `.opencode/tests/behaviors/verify-auth-step5d.sh` — NEW (behavioral tests for SC-9, SC-10, SC-11)

**SCs covered:** SC-3, SC-4, SC-5, SC-6, SC-9, SC-10, SC-11

### Phase 2 — GREEN Implementation Details (G5)

**G5 sub-agent implements:**

1. Create `verify-authorization/verify-codebase.md`:
   - Thin wrapper dispatching `tasks/verify-codebase.md`
   - Entry criteria: authorization verified, sub-issues verified
   - Exit criteria: files exist, code valid, no superseding issues, no staleness
   - Reads from work state `## sub-issue-verification`, writes to `## verify-codebase`

2. Create `verify-authorization/verify-blockers.md`:
   - Thin wrapper dispatching `tasks/verify-blockers.md`
   - Entry criteria: authorization verified, sub-issues verified, codebase verified
   - Exit criteria: no blocking issues, no unresolved dependencies
   - Reads from work state `## verify-codebase`, writes to `## verify-blockers`

3. Create `verify-authorization/verify-closed-issue-main.md`:
   - NEW logic (not a wrapper):
     - Check main issue state via `github_issue_read(method=get)`
     - If closed with `state_reason: "completed"`: search for merged PR, verify merge, mark VERIFIED_CLOSED or VERIFICATION_GAP
     - If open: check for merged PRs referencing the issue
     - After verification: dispatch `reconcile-issue-graph` for main issue's cross-reference graph
   - Entry criteria: authorization verified, codebase checked, no blockers
   - Exit criteria: main issue closure verified, reconcile-issue-graph dispatched
   - Reads from work state `## verify-blockers`, writes to `## verify-closed-issue-main`

4. Create `verify-authorization/verify-already-implemented.md`:
   - Thin wrapper dispatching `tasks/verify-already-implemented.md`
   - Entry criteria: authorization verified, codebase checked, no blockers, main issue closure verified
   - Exit criteria: auto-close or proceed to implementation
   - Reads from work state `## verify-closed-issue-main`, writes to `## verify-already-implemented`

5. Create `.opencode/tests/behaviors/verify-auth-step5d.sh` with behavioral test scenarios for SC-9, SC-10, SC-11

6. Run all tests → expected PASS (exit 0)

---

## Phase 3: Update auto-dispatch.md Auto-Route Procedure with Step 0 Pre-Check

### Phase 3 — Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: SC-Coherence-Gate | sub-task | yes (blind) | `pre-analysis` | `{"issue_number": 1187, "task_description": "verify SC-7 coherence for Phase 3", "pipeline_phase": "phase3", "sc_ids": ["SC-7"]}` | SC-7 |
| G2: Pre-RED-Baseline | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm all PASS", "pipeline_phase": "phase3"}` | — |
| G3: RED-Phase | sub-task | yes (blind) | `general` | `{"task_description": "write content-verification test for SC-7 expecting FAIL", "pipeline_phase": "phase3", "sc_ids": ["SC-7"]}` | SC-7 |
| G4: RED-Doublecheck | inline | N/A | — | — | SC-7 |
| G5: GREEN-Phase | sub-task | yes (blind) | `general` | `{"task_description": "add Step 0 pre-check to auto-dispatch.md auto-route procedure", "pipeline_phase": "phase3", "sc_ids": ["SC-7"]}` | SC-7 |
| G6: Checkpoint-Commit | inline | N/A | — | — | — |
| G7: Structural-Checks | sub-task | yes (blind) | `general` | `{"task_description": "lint/format auto-dispatch.md", "pipeline_phase": "phase3"}` | — |
| G8: GREEN-Doublecheck | inline | N/A | — | — | SC-7 |
| G9: GREEN-VbC | sub-task | yes (blind) | `general` | `{"task_description": "verification-before-completion against SC-7", "pipeline_phase": "phase3", "sc_ids": ["SC-7"]}` | SC-7 |
| G10: Adversarial-Audit | sub-task | yes (blind) | `resolve-models` → 2 auditors | `{"audit_phase": "phase3", "audit_type": "plan-fidelity + concern-separation", "sc_ids": ["SC-7"]}` | SC-7 |
| G11: Cross-Validate | inline | N/A | — | — | SC-7 |
| G12: Regression-Check | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm nothing broken", "pipeline_phase": "phase3"}` | — |
| G13: Review-Prep | sub-task | yes (blind) | `general` | `{"task_description": "review-prep for phase 3 changes", "pipeline_phase": "phase3"}` | — |
| G14: Exec-Summary | inline | N/A | — | — | SC-7 |
| G15: Z3 SAT Validation | sub-task | yes (blind) | `general` | `{"task_description": "run solve model + solve check for phase 3 dependency contract", "pipeline_phase": "phase3"}` | — |

**Concern boundary:** Entering — modifying auto-dispatch routing logic. Leaving — sub-task file creation. Handoff: 4 new sub-task files exist, auto-dispatch needs to read their results.

**Files:** `skills/approval-gate/tasks/verify-authorization/auto-dispatch.md` (lines 64-82: auto-route procedure)
**SCs covered:** SC-7

### Phase 3 — GREEN Implementation Details (G5)

**G5 sub-agent implements:**

Insert new Step 0 in auto-route procedure (before existing Step 1 "Determine approval context"):

```
0. Check pre-implementation readiness results from Step 5d:
   - If verify-already-implemented returned positive → auto-close issue, check parent plan, HALT
   - If verify-codebase found staleness → HALT, report staleness
   - If verify-blockers found blockers → HALT, report blockers
   - If verify-closed-issue-main found VERIFICATION_GAP → flag-for-review, HALT
   - Otherwise → proceed to spec/plan routing
```

Also update the Auto-Dispatch Situation Differentiation table "Already implemented" row (line 40) to reference Step 5d results as the actionable execution path.

---

## Phase 4: Add Step 0 Main Issue Closure Check to verify-already-implemented.md

### Phase 4 — Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: SC-Coherence-Gate | sub-task | yes (blind) | `pre-analysis` | `{"issue_number": 1187, "task_description": "verify SC-8 coherence for Phase 4", "pipeline_phase": "phase4", "sc_ids": ["SC-8"]}` | SC-8 |
| G2: Pre-RED-Baseline | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm all PASS", "pipeline_phase": "phase4"}` | — |
| G3: RED-Phase | sub-task | yes (blind) | `general` | `{"task_description": "write content-verification test for SC-8 expecting FAIL", "pipeline_phase": "phase4", "sc_ids": ["SC-8"]}` | SC-8 |
| G4: RED-Doublecheck | inline | N/A | — | — | SC-8 |
| G5: GREEN-Phase | sub-task | yes (blind) | `general` | `{"task_description": "add Step 0 main issue closure check to verify-already-implemented.md", "pipeline_phase": "phase4", "sc_ids": ["SC-8"]}` | SC-8 |
| G6: Checkpoint-Commit | inline | N/A | — | — | — |
| G7: Structural-Checks | sub-task | yes (blind) | `general` | `{"task_description": "lint/format verify-already-implemented.md", "pipeline_phase": "phase4"}` | — |
| G8: GREEN-Doublecheck | inline | N/A | — | — | SC-8 |
| G9: GREEN-VbC | sub-task | yes (blind) | `general` | `{"task_description": "verification-before-completion against SC-8", "pipeline_phase": "phase4", "sc_ids": ["SC-8"]}` | SC-8 |
| G10: Adversarial-Audit | sub-task | yes (blind) | `resolve-models` → 2 auditors | `{"audit_phase": "phase4", "audit_type": "plan-fidelity + concern-separation", "sc_ids": ["SC-8"]}` | SC-8 |
| G11: Cross-Validate | inline | N/A | — | — | SC-8 |
| G12: Regression-Check | sub-task | yes (blind) | `general` | `{"task_description": "run full test suite --tag approval-gate, confirm nothing broken", "pipeline_phase": "phase4"}` | — |
| G13: Review-Prep | sub-task | yes (blind) | `general` | `{"task_description": "review-prep for phase 4 changes", "pipeline_phase": "phase4"}` | — |
| G14: Exec-Summary | inline | N/A | — | — | SC-8 |
| G15: Z3 SAT Validation | sub-task | yes (blind) | `general` | `{"task_description": "run solve model + solve check for phase 4 dependency contract", "pipeline_phase": "phase4"}` | — |

**Concern boundary:** Entering — modifying the verify-already-implemented task file. Leaving — auto-dispatch routing updates. Handoff: auto-dispatch now reads Step 5d results, verify-already-implemented needs to handle main-issue closure independently.

**Files:** `skills/approval-gate/tasks/verify-already-implemented.md` (before Step 1: Extract Success Criteria)
**SCs covered:** SC-8

### Phase 4 — GREEN Implementation Details (G5)

**G5 sub-agent implements:**

Insert new Step 0 before existing Step 1 (Extract Success Criteria) in `verify-already-implemented.md`:

```
### Step 0: Main Issue Closure Check

Before extracting success criteria, check the main issue's own closure state:

1. Read the main issue via `github_issue_read(method=get, issue_number=N)`
2. If issue is closed with `state_reason: "completed"`:
   - Search for merged PR referencing the issue via `github_search_pull_requests`
   - Verify PR merge via `github_pull_request_read(method=get)` confirming `merged == true`
   - If merged PR found AND all SCs pass → auto-close (existing Step 5 handles this)
   - If merged PR found AND some SCs fail → downgrade to PARTIALLY_IMPLEMENTED
3. If issue is open:
   - Check for merged PRs referencing the issue (issue may be open but work already done)
   - If merged PR found → proceed to Step 1 with PARTIALLY_IMPLEMENTED flag
   - If no merged PR → proceed to standard SC verification (existing Steps 1-4)
```

---

## Inter-Phase Handoff

Between each phase's G15 and the next phase's G1:

1. Update Z3 state file: `./.opencode/tools/solve state update` with phase N's gate states
2. Run `./.opencode/tools/solve check`: confirm phase N dependency contract still SAT
3. Verify checkpoint tag exists for phase N: `git tag -l "opencode-config/1187/checkpoint/phase-<N>-opencode-config"`
4. Append lifecycle manifest event for phase N completion

---

## Post-All-Phases Sweep

After Phase 4 G15:

| Step | Dispatch Type | Blind? | Sub-Agent Type | Receives Context |
|------|--------------|--------|----------------|-----------------|
| Finishing checklist | sub-task | yes (blind) | `general` | `{"task_description": "finishing checklist: git status clean, lint/typecheck, coverage sweep", "pipeline_phase": "post-all"}` |
| PR creation | sub-task | yes (blind) | `general` | `{"task_description": "git-workflow pr-creation: create PR via github_create_pull_request, extract html_url", "pipeline_phase": "post-all"}` |
| Post-merge cleanup | sub-task | yes (blind) | `general` | `{"task_description": "git-workflow cleanup: delete merged branches, close issues, sync dev", "pipeline_phase": "post-all"}` |

---

## Dependency Ordering

| Phase | Depends On | Rationale |
|-------|-----------|-----------|
| Phase 1 | None | Table modifications are independent |
| Phase 2 | Phase 1 | Sub-task files must exist before auto-dispatch can reference them |
| Phase 3 | Phase 2 | Auto-dispatch Step 0 reads Step 5d results from Phase 2 files |
| Phase 4 | Phase 2 | verify-already-implemented.md Step 0 is independent of auto-dispatch changes |

Phase 4 can run in parallel with Phase 3 (no dependency between them).

---

## Authorization Context

```
authorization_scope: for_plan
halt_at: plan_created
pr_strategy: none
pipeline_phase: plan_creation
authorization_source: "User approved #1187 on 2026-06-14"
```
