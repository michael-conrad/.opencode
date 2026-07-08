# Plan: Replace Skill Dispatch Mandate prose with structured 5-item checklist in prompts/default.txt

**Issue:** #1783
**Status:** PLAN — APPROVED (auto-approved via `for_plan` scope)
**Spec:** `.opencode/.issues/1783/spec.md`
**Authorization Scope:** `for_plan`
**Halt At:** `plan_created`

## Goal

Replace ALL 5 existing dispatch-related sections in `prompts/default.txt` with ONE consolidated "Pre-Response Gate" section at position 1 (before Authorization Scope, before Startup Mode). The 5 sections to remove: "Skill Dispatch Mandate", "Bright-Line Mandates", "Evidence Hierarchy", "Cost Model Override", and "Rework Cost Recognition". The consolidated section includes: 4-step gate procedure, forbidden rationalizations list, cost model, and evidence hierarchy — all in one place.

## Architecture

Single-file edit to `prompts/default.txt` in the `.opencode` submodule. The change is a text replacement operation: remove 5 scattered sections and insert 1 consolidated section at position 1. No structural changes to the prompt file beyond these removals and insertions. All non-dispatch sections remain unchanged.

## Files

| File | Change Type | Description |
|------|-------------|-------------|
| `prompts/default.txt` | Edit | Remove 5 sections, insert 1 consolidated "Pre-Response Gate" section at position 1 |
| `.opencode/tests/behaviors/pre-response-gate-dispatch.sh` | Create | Behavioral test: agent dispatches skill when trigger matches (SC-9) |
| `.opencode/tests/behaviors/pre-response-gate-multi-turn.sh` | Create | Behavioral test: agent re-checks skills on subsequent messages (SC-10) |
| `.opencode/tests/behaviors/pre-response-gate-simple-task.sh` | Create | Behavioral test: agent does NOT inline "simple enough" tasks (SC-11) |

## Phase Table

| Phase | Description | Steps | SC Coverage |
|-------|-------------|-------|-------------|
| 1 | Consolidate dispatch sections in `prompts/default.txt` | 1-12 | SC-1 through SC-11 |

## Exit Criteria

- [ ] Plan artifact created at `.opencode/.issues/1783/plan.md`
- [ ] All 11 SCs from spec have corresponding implementation steps
- [ ] All mandatory implementation-pipeline steps referenced correctly
- [ ] RED/GREEN chains defined for behavioral tests
- [ ] Verification blocks defined per SC
- [ ] Plan committed to feature branch

---

## Phase 1: Consolidate dispatch sections in `prompts/default.txt`

### Step 1 — Pre-flight handoff

**Dispatch:** `sub-agent` via `task(..., prompt: "execute pre-flight-handoff from implementation-pipeline")`

**Chain:** `none`

**Context:** `{ issue_number: 1783, plan_path: .opencode/.issues/1783/plan.md, authorization_scope: for_plan, halt_at: plan_created }`

**Entry criteria:**
- [ ] Feature branch exists (create if not: `git checkout -b feature/consolidate-dispatch-gate-1783`)
- [ ] Submodule `.opencode` is on `dev` branch
- [ ] `todowrite` initialized with all pipeline steps

**Exit criteria:**
- [ ] Pre-flight handoff manifest written to `{project_root}/tmp/1783/artifacts/plan-to-pipeline-handoff-*.yaml`
- [ ] Handoff-consistency check PASS (spec-to-plan vs plan-to-pipeline manifests match)
- [ ] Submodule state verified at dev tip

---

### Step 2 — SC-Coherence Gate

**Dispatch:** `sub-agent` via `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`

**Chain:** `step_1`

**Context:** `{ issue_number: 1783 }`

**Entry criteria:**
- [ ] Pre-flight handoff PASS
- [ ] Spec at `.opencode/.issues/1783/spec.md` is readable

**Procedure:**
1. Read spec body from `.opencode/.issues/1783/spec.md`
2. Extract all 11 SCs with their evidence types and verification methods
3. Verify each SC is coherent (testable, unambiguous, scoped)
4. Verify SCs collectively cover the objective (replace 5 sections with 1 consolidated section)
5. Report coherence verdict

**Exit criteria:**
- [ ] All 11 SCs verified coherent
- [ ] No SC conflicts detected
- [ ] Coherence extraction artifact written

---

### Step 3 — Pre-RED Baseline

**Dispatch:** `sub-agent` via `task(..., prompt: "execute pre-red-baseline from implementation-pipeline")`

**Chain:** `step_2`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Read current `prompts/default.txt` to establish baseline
2. Verify the 5 sections to remove exist at expected locations
3. Verify position 1 is available (before "Default Authorization Scope")
4. Record baseline SHA of `prompts/default.txt`

**Exit criteria:**
- [ ] Baseline established: all 5 sections confirmed present
- [ ] Position 1 confirmed available
- [ ] Baseline SHA recorded

---

### Step 4 — RED Phase: Write behavioral tests

**Dispatch:** `sub-agent` via `task(..., prompt: "execute red from test-driven-development")`

**Chain:** `step_3`

**Context:** `{ issue_number: 1783, sc_list: [SC-9, SC-10, SC-11] }`

**Procedure:**

#### SC-9: Agent dispatches skill when trigger matches

Create `.opencode/tests/behaviors/pre-response-gate-dispatch.sh`:

```bash
# SC-9: Agent dispatches skill when trigger matches (not inlines)
# RED: test should FAIL because the consolidated gate doesn't exist yet
source "$(dirname "$0")/helpers.sh"

behavior_run "implement a feature that validates user input" --scenario pre-response-gate-dispatch
assert_semantic "SC-9" "Agent called skill() before implementing, did not inline the work"
assert_stderr_pattern_present 'Skill "'  # secondary corroboration
```

#### SC-10: Agent re-checks skills on subsequent messages

Create `.opencode/tests/behaviors/pre-response-gate-multi-turn.sh`:

```bash
# SC-10: Agent re-checks skills on subsequent messages
# RED: test should FAIL because the consolidated gate doesn't exist yet
source "$(dirname "$0")/helpers.sh"

behavior_run "implement a feature that validates user input" --scenario pre-response-gate-multi-turn --multi-turn "now write tests for it"
assert_semantic "SC-10" "Agent re-evaluated available skills on the second message, did not assume previous dispatch was sufficient"
```

#### SC-11: Agent does NOT inline "simple enough" tasks

Create `.opencode/tests/behaviors/pre-response-gate-simple-task.sh`:

```bash
# SC-11: Agent does NOT produce output when "simple enough to handle inline" rationalization fires
# RED: test should FAIL because the consolidated gate doesn't exist yet
source "$(dirname "$0")/helpers.sh"

behavior_run "fix the typo in line 5 of README.md" --scenario pre-response-gate-simple-task
assert_semantic "SC-11" "Agent dispatched to a sub-agent or skill despite the task appearing simple, did not inline the fix"
```

**Exit criteria:**
- [ ] 3 behavioral test files created
- [ ] Each test FAILS on current codebase (RED confirmed)
- [ ] Tests committed to feature branch

---

### Step 5 — Z3 Check RED

**Dispatch:** `inline` via `solve --task check`

**Chain:** `step_4`

**Contract:** `.opencode/skills/writing-plans/contracts/create-output-template.yaml:z3-check-red`

**Procedure:**
1. Run `solve check` with RED phase contract
2. Verify RED test files exist and are non-empty
3. Verify each test has `assert_semantic` call

**Exit criteria:**
- [ ] Z3 check PASS
- [ ] RED phase verified complete

---

### Step 6 — RED Doublecheck

**Dispatch:** `sub-agent` via `task(..., prompt: "execute verify from verification-before-completion")`

**Chain:** `step_5`

**Context:** `{ issue_number: 1783, sc_list: [SC-9, SC-10, SC-11] }`

**Procedure:**
1. Read each behavioral test file
2. Verify each test has correct `assert_semantic` call with SC ID
3. Verify each test has `behavior_run` with appropriate prompt
4. Report PASS/FAIL per test

**Exit criteria:**
- [ ] All 3 behavioral tests verified correct
- [ ] RED doublecheck PASS

---

### Step 7 — Post-RED Enforcement

**Dispatch:** `sub-agent` via `task(..., prompt: "execute post-red-enforcement from implementation-pipeline")`

**Chain:** `step_6`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Verify RED phase completed all required test files
2. Verify no implementation work done yet
3. Record RED phase completion in pipeline state

**Exit criteria:**
- [ ] RED phase confirmed complete
- [ ] No GREEN work started
- [ ] Pipeline state updated

---

### Step 8 — GREEN Phase: Implement the consolidation

**Dispatch:** `sub-agent` via `task(..., prompt: "execute green from test-driven-development")`

**Chain:** `step_7`

**Context:** `{ issue_number: 1783, spec_path: .opencode/.issues/1783/spec.md }`

**Procedure:**

1. **Read `prompts/default.txt`** to identify exact section boundaries
2. **Remove 5 sections:**
   - "Skill Dispatch Mandate" section (currently lines 45-60)
   - "Bright-Line Mandates" section (currently lines 174-186)
   - "Evidence Hierarchy" section (currently lines 188-198)
   - "Cost Model Override" section (currently lines 200-205)
   - "Rework Cost Recognition" section (currently lines 207-209)
3. **Insert consolidated "Pre-Response Gate" section at position 1** (before "Default Authorization Scope"):
   - Section heading: `# Pre-Response Gate — MANDATORY`
   - 4-step gate procedure (scan → dispatch → justify → route)
   - Confirmshaming line: "Professionals route. Amateurs inline."
   - Consequence statement: "Bypassing this gate invalidates all subsequent work."
   - Forbidden Rationalizations subsection with all 8 items
   - Cost Model subsection
   - Evidence Hierarchy subsection with 4-tier table and BRIGHT-LINE RULE
4. **Verify regression invariants:**
   - All non-dispatch sections unchanged
   - "Default Authorization Scope" and "Startup Mode" sections unchanged
   - No other prompt files modified
   - Consolidated section at position 1
   - All 5 original sections completely removed
   - Exactly ONE confirmshaming line

**Exit criteria:**
- [ ] `prompts/default.txt` edited with all changes
- [ ] Regression invariants verified
- [ ] Changes committed to feature branch

---

### Step 9 — Z3 Check GREEN

**Dispatch:** `inline` via `solve --task check`

**Chain:** `step_8`

**Contract:** `.opencode/skills/writing-plans/contracts/create-output-template.yaml:z3-check-green`

**Procedure:**
1. Run `solve check` with GREEN phase contract
2. Verify all 5 old sections removed (grep for each heading returns no match)
3. Verify new section at position 1 (grep for "Pre-Response Gate" returns match before "Default Authorization Scope")
4. Verify 4 steps present (grep -c for numbered items in gate section returns 4)
5. Verify exactly 1 confirmshaming line
6. Verify consequence statement present
7. Verify 8 rationalizations present
8. Verify cost model present
9. Verify evidence hierarchy table present

**Exit criteria:**
- [ ] Z3 check PASS
- [ ] All string SCs (SC-1 through SC-8) verified

---

### Step 10 — Post-GREEN Enforcement

**Dispatch:** `sub-agent` via `task(..., prompt: "execute post-green-enforcement from implementation-pipeline")`

**Chain:** `step_9`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Verify GREEN phase completed all required edits
2. Verify no behavioral tests were modified (they should still be RED)
3. Record GREEN phase completion in pipeline state

**Exit criteria:**
- [ ] GREEN phase confirmed complete
- [ ] Pipeline state updated

---

### Step 11 — Structural Checks

**Dispatch:** `sub-agent` via `task(..., prompt: "execute checklist from finishing-a-development-branch")`

**Chain:** `step_10`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Run `git status` to verify all changes tracked
2. Run `git diff --stat` to review changed files
3. Verify no unintended files modified
4. Verify `prompts/default.txt` is the only production file changed (+ 3 test files)

**Exit criteria:**
- [ ] Structural checks PASS
- [ ] Only intended files modified

---

### Step 12 — GREEN Doublecheck (Verification Before Completion)

**Dispatch:** `sub-agent` via `task(..., prompt: "execute verify from verification-before-completion")`

**Chain:** `step_11`

**Context:** `{ issue_number: 1783, sc_list: [SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8] }`

**Procedure:**

Verify each string SC with grep evidence:

| SC | Verification Command | Expected |
|----|---------------------|----------|
| SC-1 | `grep 'Pre-Response Gate' prompts/default.txt` | Match found; section appears before "Default Authorization Scope" |
| SC-2 | Count numbered items in gate section | 4 steps |
| SC-3 | `grep -c 'Professionals route.*Amateurs inline' prompts/default.txt` | 1 |
| SC-4 | `grep 'Bypassing this gate invalidates' prompts/default.txt` | Match found |
| SC-5 | Count `- "` items in rationalizations section | 8 |
| SC-6 | `grep 'Not dispatching is what.s actually inefficient' prompts/default.txt` | Match found |
| SC-7 | `grep 'Evidence Hierarchy' prompts/default.txt` | Match found; table has 4 rows |
| SC-8 | `grep 'Skill Dispatch Mandate' prompts/default.txt` | No match; same for Bright-Line Mandates, Cost Model Override, Rework Cost Recognition |

**Exit criteria:**
- [ ] All 8 string SCs verified PASS
- [ ] Evidence artifacts written to `{project_root}/tmp/1783/artifacts/`

---

### Step 13 — GREEN VbC (Verification Before Completion — Behavioral)

**Dispatch:** `sub-agent` via `task(..., prompt: "execute completion from verification-before-completion")`

**Chain:** `step_12`

**Context:** `{ issue_number: 1783, sc_list: [SC-9, SC-10, SC-11] }`

**Procedure:**

Run each behavioral test and verify PASS:

1. **SC-9:** `bash .opencode/tests/behaviors/pre-response-gate-dispatch.sh`
   - Expected: `assert_semantic` confirms agent dispatched skill, did not inline
   - Expected: `assert_stderr_pattern_present 'Skill "'` as secondary corroboration

2. **SC-10:** `bash .opencode/tests/behaviors/pre-response-gate-multi-turn.sh`
   - Expected: `assert_semantic` confirms agent re-evaluated skills on second message

3. **SC-11:** `bash .opencode/tests/behaviors/pre-response-gate-simple-task.sh`
   - Expected: `assert_semantic` confirms agent dispatched despite task simplicity

**Exit criteria:**
- [ ] All 3 behavioral tests PASS
- [ ] Behavioral evidence artifacts preserved at `{project_root}/tmp/behavioral-evidence-*.{log,json}`

---

### Step 14 — Pre-PR Gate

**Dispatch:** `sub-agent` via `task(..., prompt: "execute verify from verification-before-completion")`

**Chain:** `step_13`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Read all SC verdicts from VbC artifacts
2. Verify ALL 11 SCs have PASS verdict
3. If any FAIL: BLOCK and report

**Exit criteria:**
- [ ] All 11 SCs PASS
- [ ] Pre-PR gate PASS

---

### Step 15 — Audit

**Dispatch:** `sub-agent` via `task(subagent_type="general", prompt: "execute verification-audit from audit")`

**Chain:** `step_14`

**Context:** `{ issue_number: 1783, spec_local_dir: .opencode/.issues/1783, artifact_evidence_dir: {project_root}/tmp/1783/artifacts }`

**Procedure:**
1. Audit verification evidence for all 11 SCs
2. Verify evidence type matches SC declaration (string for SC-1..8, behavioral for SC-9..11)
3. Report PASS/FAIL with evidence artifacts

**Exit criteria:**
- [ ] Audit PASS
- [ ] Evidence type compliance verified

---

### Step 16 — Cross-Validate

**Dispatch:** `sub-agent` via `task(..., prompt: "execute cross-validate from audit")`

**Chain:** `step_15`

**Context:** `{ issue_number: 1783, auditor_artifact_paths: [from step 15] }`

**Procedure:**
1. Cross-validate audit findings against VbC evidence
2. Verify no EVIDENCE_TYPE_MISMATCH (behavioral SCs have behavioral evidence)
3. Report consensus PASS/FAIL

**Exit criteria:**
- [ ] Cross-validate PASS
- [ ] Consensus confirmed

---

### Step 17 — Regression Check

**Dispatch:** `sub-agent` via `task(..., prompt: "execute patterns from test-driven-development")`

**Chain:** `step_16`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Verify regression invariants from spec:
   - All non-dispatch sections unchanged
   - "Default Authorization Scope" and "Startup Mode" sections unchanged
   - No other prompt files modified
   - Consolidated section at position 1
   - All 5 original sections completely removed
   - Exactly ONE confirmshaming line
2. Run existing enforcement tests to verify no regressions: `bash .opencode/tests/test-enforcement.sh --changed`

**Exit criteria:**
- [ ] All regression invariants verified
- [ ] Existing enforcement tests PASS

---

### Step 18 — Review Prep

**Dispatch:** `sub-agent` via `task(..., prompt: "execute review-prep from git-workflow")`

**Chain:** `step_17`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Push feature branch to remote
2. Generate compare URL: `https://github.com/michael-conrad/.opencode/compare/dev...feature/consolidate-dispatch-gate-1783`
3. Prepare PR body with Summary, Outcome, Fixes section

**Exit criteria:**
- [ ] Branch pushed
- [ ] Compare URL generated
- [ ] PR body prepared

---

### Step 19 — Exec Summary / Completion

**Dispatch:** `sub-agent` via `task(..., prompt: "execute completion from completion-core")`

**Chain:** `step_18`

**Context:** `{ issue_number: 1783 }`

**Procedure:**
1. Generate completion signal
2. Append lifecycle event to issue body
3. Report executive summary in chat

**Exit criteria:**
- [ ] Completion signal generated
- [ ] Lifecycle event appended
- [ ] Executive summary reported
- [ ] `todowrite(todos=[])` called to clear state
- [ ] HALT

---

## Verification Blocks per SC

| SC | Evidence Type | Verification Step | Method |
|----|---------------|-----------------|--------|
| SC-1 | `string` | Step 12 (GREEN Doublecheck) | `grep 'Pre-Response Gate' prompts/default.txt`; verify before "Default Authorization Scope" |
| SC-2 | `string` | Step 12 | Count numbered items in gate section = 4 |
| SC-3 | `string` | Step 12 | `grep -c 'Professionals route.*Amateurs inline'` = 1 |
| SC-4 | `string` | Step 12 | `grep 'Bypassing this gate invalidates'` matches |
| SC-5 | `string` | Step 12 | Count `- "` items in rationalizations = 8 |
| SC-6 | `string` | Step 12 | `grep 'Not dispatching is what.s actually inefficient'` matches |
| SC-7 | `string` | Step 12 | `grep 'Evidence Hierarchy'` matches; table has 4 rows |
| SC-8 | `string` | Step 12 | `grep` for each removed section heading returns no match |
| SC-9 | `behavioral` | Step 13 (GREEN VbC) | `opencode-cli run` with trigger-matching prompt; `assert_semantic` confirms dispatch |
| SC-10 | `behavioral` | Step 13 | `opencode-cli run` multi-turn; `assert_semantic` confirms re-check on second message |
| SC-11 | `behavioral` | Step 13 | `opencode-cli run` with simple-task prompt; `assert_semantic` confirms dispatch despite simplicity |

---

## RED/GREEN Chains

| SC | RED File | GREEN Action |
|----|----------|-------------|
| SC-9 | `.opencode/tests/behaviors/pre-response-gate-dispatch.sh` | Edit `prompts/default.txt` — insert consolidated gate |
| SC-10 | `.opencode/tests/behaviors/pre-response-gate-multi-turn.sh` | Edit `prompts/default.txt` — insert consolidated gate |
| SC-11 | `.opencode/tests/behaviors/pre-response-gate-simple-task.sh` | Edit `prompts/default.txt` — insert consolidated gate |

All 3 behavioral tests are RED before implementation (Step 4), GREEN after implementation (Step 8). String SCs (SC-1 through SC-8) are verified in Step 12 after implementation.

---

## Mandatory Implementation-Pipeline Steps

All steps from the implementation-pipeline SKILL.md Trigger Dispatch Table are referenced:

| Pipeline Step | Plan Step | Skill/Task |
|---------------|-----------|------------|
| `assemble-work` | Step 1 (pre-flight handoff) | `implementation-pipeline --task pre-flight-handoff` |
| `sc-coherence-gate` | Step 2 | `audit --task coherence-extraction` |
| `pre-red-baseline` | Step 3 | `implementation-pipeline --task pre-red-baseline` |
| `red-phase` | Step 4 | `test-driven-development --task red` |
| `z3-check-red` | Step 5 | `solve --task check` |
| `red-doublecheck` | Step 6 | `verification-before-completion --task verify` |
| `post-red-enforcement` | Step 7 | `implementation-pipeline --task post-red-enforcement` |
| `green-phase` | Step 8 | `test-driven-development --task green` |
| `z3-check-green` | Step 9 | `solve --task check` |
| `post-green-enforcement` | Step 10 | `implementation-pipeline --task post-green-enforcement` |
| `structural-checks` | Step 11 | `finishing-a-development-branch --task checklist` |
| `green-doublecheck` | Step 12 | `verification-before-completion --task verify` |
| `green-vbc` | Step 13 | `verification-before-completion --task completion` |
| `pre-pr-gate` | Step 14 | `verification-before-completion --task verify` |
| `audit` | Step 15 | `audit --task verification-audit` |
| `cross-validate` | Step 16 | `audit --task cross-validate` |
| `regression-check` | Step 17 | `test-driven-development --task patterns` |
| `review-prep` | Step 18 | `git-workflow --task review-prep` |
| `exec-summary` | Step 19 | `completion-core --task completion` |

---

## Self-Review Evidence

- [ ] All 11 SCs from spec have corresponding implementation steps
- [ ] All 19 pipeline steps from implementation-pipeline Trigger Dispatch Table referenced
- [ ] RED/GREEN chains defined for all 3 behavioral SCs
- [ ] Verification blocks defined per SC with correct evidence type
- [ ] Single-task spec → single phase → single plan file (no split needed)
- [ ] Plan format matches writing-plans specification
- [ ] All mandatory implementation-pipeline steps included with correct skill/task references
