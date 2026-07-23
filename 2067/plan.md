# Implementation Plan — [.opencode#2067](https://github.com/michael-conrad/.opencode/tree/issues-data/2067) — Remediate implementation audit failures

- **Goal:** Add Tier 1 CRITICAL VIOLATION rule + behavioral test, remediate 4 task card structural defects, expand SKILL.md Invocation tables, add Pipeline Steps section to write.md
- **Architecture:** 4 independent phases — Phase 1 (guideline + test), Phase 2 (task card edits), Phase 3 (SKILL.md Invocation expansion), Phase 4 (plan template Pipeline Steps)
- **Files:** 14 files across `.opencode/guidelines/`, `.opencode/tests-v2/behaviors/`, `.opencode/skills/writing-plans-creation/tasks/`, `.opencode/skills/spec-creation-validation/tasks/`, `.opencode/skills/audit/tasks/`, `.opencode/skills/writing-plans-holistic/tasks/`, `.opencode/skills/writing-plans/`, `.opencode/skills/spec-creation/`
- **Dispatch:** `skill({name: "writing-plans-creation"})` → `task(..., prompt: "execute write from writing-plans-creation")`

## Blast Radius

- `000-critical-rules.md` — Tier 1 section; adding a CRITICAL VIOLATION rule changes agent behavior for all spec-creation operations
- `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` — new behavioral test; no existing tests affected
- 4 task cards (`completion.md`, `operating-protocol.md`, `validate.md`, `spec-creation-validation/tasks/completion.md`) — structural section additions; existing content preserved
- 3 task cards (`clean-room.md`, `write.md`, `behavioral-sc-evaluator.md`) — marker/language removal; no behavioral change
- 6 task cards (`validate.md`, `update.md`, `solve.md`, `completion.md`, `write.md`, `holistic-self-check.md`) — sub-agent/dispatch reference fixes; no behavioral change
- `writing-plans/SKILL.md`, `spec-creation/SKILL.md` — Invocation table expansion; documentation-only
- No changes to behavioral test harness, helpers, or `implementation-pipeline/SKILL.md`

## Concern Map Reference

| Concern | Phase |
|---------|-------|
| Guideline enforcement gap | Phase 1 |
| Missing behavioral test | Phase 1 |
| Task card structural defects | Phase 2 |
| Orchestrator markers in task cards | Phase 2 |
| SKILL.md Invocation drift | Phase 3 |
| Missing Pipeline Steps section | Phase 4 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the result before proceeding. Do not batch steps, do not skip ahead, do not combine steps. Each step produces a verifiable outcome. If a step fails, stop and remediate before continuing.

### Step Status

Each step MUST be marked with one of: `[ ]` (pending), `[x]` (completed), `[~]` (in progress), `[!]` (blocked). Update the status marker immediately after completing or blocking a step. Do not leave steps in `[ ]` after they have been attempted.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Guideline rule + behavioral test | Guideline enforcement gap, missing behavioral test | SC-1, SC-2 | None | 1-8 | `(**clean-room**)` |
| 2 | Task card remediation | Task card structural defects, orchestrator markers | SC-3 through SC-8 | Phase 1 (independent files) | 9-22 | `(**clean-room**)` |
| 3 | SKILL.md Invocation expansion | SKILL.md Invocation drift | SC-9, SC-10 | Phase 2 (independent files) | 23-28 | `(**clean-room**)` |
| 4 | Plan template Pipeline Steps | Missing Pipeline Steps section | SC-3 | Phase 2 (same file: write.md) | 29-32 | `(**clean-room**)` |

---

## Phase 1 — Guideline rule + behavioral test

**Concern:** Guideline enforcement gap, missing behavioral test
**Files:**
- `.opencode/guidelines/000-critical-rules.md`
- `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh`
**SCs:** SC-1, SC-2
**Dependencies:** None
**Entry:** Spec approved, feature branch created
**Exit:** Tier 1 CRITICAL VIOLATION rule added to `000-critical-rules.md`; behavioral test file exists and is executable

### Code Path Coverage

- `000-critical-rules.md` Tier 1 section — add new CRITICAL VIOLATION entry
- `.opencode/tests-v2/behaviors/` — create new behavioral test file following v2 artifact-only generator paradigm

### Cross-Cutting SCs

None for this phase.

### Interface Boundaries

- `000-critical-rules.md` — guideline file read by all agents at session start; adding a Tier 1 rule changes agent behavior globally
- Behavioral test — follows v2 harness conventions; uses `behavior_run` and assertion helpers from `helpers.sh`

### State Transitions

- Pre-state: No Tier 1 rule exists for `github_issue_write` spec content bypass
- Post-state: Tier 1 CRITICAL VIOLATION rule exists; behavioral test exists

### Step-by-step

- [ ] 1. **Pre-RED baseline (**clean-room**).** Verify existing tests pass before any changes. Run `bash .opencode/tests-v2/test-enforcement.sh --tag guideline-enforcement` to establish baseline. **→ SC-1, SC-2**
- [ ] 2. **RED — Write behavioral test (**clean-room**).** Create `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh`. The test sends a real-domain prompt asking the agent to create a spec for a simple change and verifies the agent dispatches through the spec-creation pipeline rather than using `github_issue_write` directly. Follow v2 artifact-only generator paradigm. The test MUST FAIL at this point because the guideline rule does not exist yet. **→ SC-2**
- [ ] 3. **GREEN — Add Tier 1 CRITICAL VIOLATION rule (**clean-room**).** Add the following rule to `000-critical-rules.md` in the Tier 1 section:

    ```
    ### [critical-rules-XXX] CRITICAL VIOLATION — Direct `github_issue_write` for spec content bypassing spec-creation pipeline

    Using `github_issue_write` to create or update spec issue content (issue body, title, or description for a [SPEC] or [SPEC-FIX] issue) instead of dispatching through the `spec-creation` pipeline is a CRITICAL VIOLATION. All spec content MUST be created and revised through `skill({name: "spec-creation"})` → `task(..., prompt: "execute create from spec-creation-validation")` or the equivalent revision task. Direct `github_issue_write` calls for spec content bypass the spec-creation pipeline's quality gates (brainstorming, decomposition, analytical artifacts, holistic self-check, spec-auditor).

    **Exception:** Non-substantive metadata updates (labels, assignees, status markers) via `github_issue_write` are permitted. Spec body content (problem statement, success criteria, approach, affected files) MUST go through the spec-creation pipeline.

    **🚫 FORBIDDEN:**
    - `github_issue_write(method=create, title="[SPEC] ...", body="...")` — creating a spec issue directly
    - `github_issue_write(method=update, body="...")` — updating spec body content directly
    - Any direct mutation of spec issue body content outside the spec-creation pipeline

    **✅ REQUIRED:**
    - `skill({name: "spec-creation"})` → `task(..., prompt: "execute create from spec-creation-validation")` for new specs
    - `skill({name: "spec-creation"})` → `task(..., prompt: "execute revise from spec-creation-validation")` for spec revisions
    - `github_issue_write` for labels, assignees, comments, and status markers only
    ```

    **→ SC-1**
- [ ] 4. **GREEN doublecheck (**clean-room**).** Run the behavioral test from step 2. It MUST PASS now because the guideline rule exists. **→ SC-1, SC-2**
- [ ] 5. **Checkpoint commit .** `git add .opencode/guidelines/000-critical-rules.md .opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh && git commit -m "feat: add Tier 1 CRITICAL VIOLATION for direct github_issue_write spec content + behavioral test"` **→ SC-1, SC-2**

#### Phase 1 VbC

- [ ] 6. **VbC (**clean-room**).** Verify SC-1: `grep -n "github_issue_write.*spec.*content\|spec.*content.*github_issue_write\|CRITICAL VIOLATION.*github_issue_write" .opencode/guidelines/000-critical-rules.md` returns at least one match in the Tier 1 section. Verify SC-2: `ls .opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` confirms file exists; `head -1` shows `#!/bin/bash`. **→ SC-1, SC-2**

**Concern transition:** Leaving guideline enforcement gap → entering task card structural defects. Phase 2 depends on Phase 1 checkpoint commit.

---

## Phase 2 — Task card remediation

**Concern:** Task card structural defects, orchestrator markers
**Files:**
- `.opencode/skills/writing-plans-creation/tasks/completion.md`
- `.opencode/skills/writing-plans-creation/tasks/operating-protocol.md`
- `.opencode/skills/writing-plans-creation/tasks/validate.md`
- `.opencode/skills/spec-creation-validation/tasks/completion.md`
- `.opencode/skills/writing-plans-creation/tasks/clean-room.md`
- `.opencode/skills/writing-plans-creation/tasks/write.md`
- `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md`
- `.opencode/skills/writing-plans-creation/tasks/update.md`
- `.opencode/skills/writing-plans-creation/tasks/solve.md`
- `.opencode/skills/writing-plans-holistic/tasks/holistic-self-check.md`
**SCs:** SC-3, SC-4, SC-5, SC-6, SC-7, SC-8
**Dependencies:** Phase 1 (independent files — no file overlap)
**Entry:** Phase 1 checkpoint committed
**Exit:** All 4 task cards have mandatory sections; `(orchestrator)` marker removed; `(**sub-agent**)` markers removed; orchestrator-dispatch language removed; sub-agent/dispatch references fixed in 6 task cards

### Code Path Coverage

- `completion.md` (writing-plans-creation) — add ## Entry Criteria, ## Procedure, ## Exit Criteria; fix sub-agent/dispatch references
- `operating-protocol.md` — add ## Procedure section
- `validate.md` — add ## Entry Criteria, ## Procedure, ## Exit Criteria; fix sub-agent/dispatch references
- `completion.md` (spec-creation-validation) — add ## Entry Criteria, ## Procedure, ## Exit Criteria; fix sub-agent/dispatch references
- `clean-room.md` — remove `(orchestrator)` marker
- `write.md` — remove `(**sub-agent**)` markers (lines 131, 142, 160); fix sub-agent/dispatch references
- `behavioral-sc-evaluator.md` — remove orchestrator-dispatch language from lines 7-11
- `update.md` — fix sub-agent/dispatch references
- `solve.md` — fix sub-agent/dispatch references
- `holistic-self-check.md` — fix sub-agent/dispatch references

### Cross-Cutting SCs

SC-3 (Pipeline Steps section) is addressed in Phase 4, not Phase 2. Phase 2 handles the marker removal and sub-agent reference fixes in `write.md`.

### Interface Boundaries

All changes are structural/string-level edits to task cards. No behavioral changes to agent execution.

### State Transitions

- Pre-state: 4 task cards missing mandatory sections; 1 task card has `(orchestrator)` marker; 1 task card has `(**sub-agent**)` markers; 1 task card has orchestrator-dispatch language; 6 task cards have inappropriate sub-agent/dispatch references
- Post-state: All structural defects remediated

### Step-by-step

- [ ] 7. **Add sections to completion.md (writing-plans-creation) (**clean-room**).** Add ## Entry Criteria section before State Check Phase. Add ## Procedure section wrapping existing checklist items. Add ## Exit Criteria section after Procedure. Ensure ## Result Contract section is present and correct. Fix sub-agent/dispatch references. **→ SC-4, SC-8**
- [ ] 8. **Add ## Procedure to operating-protocol.md (**clean-room**).** Add ## Procedure section with concrete steps. Currently the file only has ## Entry Criteria, ## Exit Criteria, ## Result Contract and references to the SKILL.md for the actual protocol. **→ SC-4**
- [ ] 9. **Add sections to validate.md (**clean-room**).** Add ## Entry Criteria section before Validation Checks. Add ## Procedure section wrapping the validation check items. Add ## Exit Criteria section after Procedure. Ensure ## Result Contract section is present and correct. Fix sub-agent/dispatch references. **→ SC-4, SC-8**
- [ ] 10. **Add sections to spec-creation-validation/tasks/completion.md (**clean-room**).** Add ## Entry Criteria section before State Check Phase. Add ## Procedure section wrapping existing checklist items. Add ## Exit Criteria section after Procedure. Ensure ## Result Contract section is present and correct. Fix sub-agent/dispatch references. **→ SC-4, SC-8**
- [ ] 11. **Remove `(orchestrator)` marker from clean-room.md (**clean-room**).** Remove the `(orchestrator)` marker from `writing-plans-creation/tasks/clean-room.md`. **→ SC-5**
- [ ] 12. **Remove `(**sub-agent**)` markers from write.md (**clean-room**).** Remove `(**sub-agent**)` markers from lines 131, 142, 160. Replace with appropriate dispatch indicators (`` for orchestrator-direct steps, `(**clean-room**)` for clean-room sub-agent steps). **→ SC-6**
- [ ] 13. **Remove orchestrator-dispatch language from behavioral-sc-evaluator.md (**clean-room**).** Remove orchestrator-dispatch language from lines 7-11. Replace the "Orchestrator Dispatch Entry" section with a standard "## Entry Criteria" section. **→ SC-7**
- [ ] 14. **Fix sub-agent/dispatch references in validate.md (**clean-room**).** Remove or rephrase references to sub-agents, dispatch, sub-task. **→ SC-8**
- [ ] 15. **Fix sub-agent/dispatch references in update.md (**clean-room**).** Remove or rephrase references to sub-agents, dispatch, sub-task. **→ SC-8**
- [ ] 16. **Fix sub-agent/dispatch references in solve.md (**clean-room**).** Remove or rephrase references to sub-agents, dispatch, sub-task. **→ SC-8**
- [ ] 17. **Fix sub-agent/dispatch references in completion.md (**clean-room**).** Remove or rephrase references to sub-agents, dispatch, sub-task. **→ SC-8**
- [ ] 18. **Fix sub-agent/dispatch references in write.md (**clean-room**).** Remove or rephrase references to sub-agents, dispatch, sub-task. **→ SC-8**
- [ ] 19. **Fix sub-agent/dispatch references in holistic-self-check.md (**clean-room**).** Remove or rephrase references to sub-agents, dispatch, sub-task. **→ SC-8**
- [ ] 20. **Checkpoint commit .** `git add .opencode/skills/writing-plans-creation/tasks/completion.md .opencode/skills/writing-plans-creation/tasks/operating-protocol.md .opencode/skills/writing-plans-creation/tasks/validate.md .opencode/skills/spec-creation-validation/tasks/completion.md .opencode/skills/writing-plans-creation/tasks/clean-room.md .opencode/skills/writing-plans-creation/tasks/write.md .opencode/skills/audit/tasks/behavioral-sc-evaluator.md .opencode/skills/writing-plans-creation/tasks/update.md .opencode/skills/writing-plans-creation/tasks/solve.md .opencode/skills/writing-plans-holistic/tasks/holistic-self-check.md && git commit -m "fix: remediate task card structural defects — add mandatory sections, remove orchestrator/sub-agent markers, fix dispatch references"` **→ SC-4, SC-5, SC-6, SC-7, SC-8**

#### Phase 2 VbC

- [ ] 21. **VbC (**clean-room**).** Verify SC-4: For each of the 4 task cards, `grep -c "## Entry Criteria\|## Procedure\|## Exit Criteria\|## Result Contract"` returns 4. Verify SC-5: `grep -c "(orchestrator)" .opencode/skills/writing-plans-creation/tasks/clean-room.md` returns 0. Verify SC-6: `grep -c "(**sub-agent**)" .opencode/skills/writing-plans-creation/tasks/write.md` returns 0. Verify SC-7: `grep -c "orchestrator dispatches\|The orchestrator dispatches" .opencode/skills/audit/tasks/behavioral-sc-evaluator.md` returns 0. Verify SC-8: For each of the 6 task cards, grep for "sub-agent\|dispatch\|sub-task" returns only appropriate references. **→ SC-4, SC-5, SC-6, SC-7, SC-8**

**Concern transition:** Leaving task card structural defects → entering SKILL.md Invocation drift. Phase 3 depends on Phase 2 checkpoint commit.

---

## Phase 3 — SKILL.md Invocation expansion

**Concern:** SKILL.md Invocation drift
**Files:**
- `.opencode/skills/writing-plans/SKILL.md`
- `.opencode/skills/spec-creation/SKILL.md`
**SCs:** SC-9, SC-10
**Dependencies:** Phase 2 (independent files)
**Entry:** Phase 2 checkpoint committed
**Exit:** `writing-plans/SKILL.md` Invocation lists 13 entries; `spec-creation/SKILL.md` Invocation lists 19 entries

### Code Path Coverage

- `writing-plans/SKILL.md` — expand Invocation table from 7 to 13 entries
- `spec-creation/SKILL.md` — expand Invocation table from 11 to 19 entries

### Cross-Cutting SCs

None for this phase.

### Interface Boundaries

Invocation tables are reference documentation for the orchestrator. No behavioral change to agent execution.

### State Transitions

- Pre-state: `writing-plans/SKILL.md` Invocation lists 7 entries; `spec-creation/SKILL.md` Invocation lists 11 entries
- Post-state: Both Invocation tables expanded to full task card count

### Step-by-step

- [ ] 22. **Expand writing-plans/SKILL.md Invocation (**clean-room**).** Expand the Invocation table from 7 to 13 entries covering all individual task cards across sub-skills:

    1. `create` → `writing-plans-creation`
    2. `update` → `writing-plans-creation`
    3. `retroactive` → `writing-plans-creation`
    4. `validate` → `writing-plans-creation`
    5. `solve` → `writing-plans-creation`
    6. `pre-plan-readiness` → `writing-plans-creation`
    7. `clean-room` → `writing-plans-creation`
    8. `write` → `writing-plans-creation`
    9. `completion` → `writing-plans-creation`
    10. `operating-protocol` → `writing-plans-creation`
    11. `holistic-self-check` → `writing-plans-holistic`
    12. `pre-red-baseline` → `writing-plans-creation` (if exists)
    13. `post-plan-audit` → `writing-plans-creation` (if exists)

    **→ SC-9**
- [ ] 23. **Expand spec-creation/SKILL.md Invocation (**clean-room**).** Expand the Invocation table from 11 to 19 entries covering all individual task cards across sub-skills:

    1. `create` → `spec-creation-validation`
    2. `requirements` → `spec-creation-requirements`
    3. `decompose` → `spec-creation-decomposition`
    4. `analytical-artifacts` → `spec-creation-decomposition`
    5. `holistic-self-check` → `spec-creation-validation`
    6. `pipeline-readiness-gate` → `spec-creation-validation`
    7. `risk` → `spec-creation-validation`
    8. `traceability` → `spec-creation-validation`
    9. `change-control` → `spec-creation-change-control`
    10. `operating-protocol` → `spec-creation-operating-protocol`
    11. `completion` → `spec-creation-validation`
    12. `revise` → `spec-creation-validation`
    13. `validate` → `spec-creation-validation`
    14. `pre-spec-inspection` → `spec-creation-decomposition`
    15. `blast-radius` → `spec-creation-decomposition`
    16. `code-path-inventory` → `spec-creation-decomposition`
    17. `cross-cutting-matrix` → `spec-creation-decomposition`
    18. `interface-compatibility` → `spec-creation-decomposition`
    19. `state-analysis` → `spec-creation-decomposition`

    **→ SC-10**
- [ ] 24. **Checkpoint commit .** `git add .opencode/skills/writing-plans/SKILL.md .opencode/skills/spec-creation/SKILL.md && git commit -m "docs: expand SKILL.md Invocation tables to cover all task cards"` **→ SC-9, SC-10**

#### Phase 3 VbC

- [ ] 25. **VbC (**clean-room**).** Verify SC-9: Count Invocation table rows in `.opencode/skills/writing-plans/SKILL.md` — 13 task entries. Verify SC-10: Count Invocation table rows in `.opencode/skills/spec-creation/SKILL.md` — 19 task entries. **→ SC-9, SC-10**

**Concern transition:** Leaving SKILL.md Invocation drift → entering plan template Pipeline Steps. Phase 4 depends on Phase 3 checkpoint commit.

---

## Phase 4 — Plan template Pipeline Steps

**Concern:** Missing Pipeline Steps section
**Files:**
- `.opencode/skills/writing-plans-creation/tasks/write.md`
**SCs:** SC-3
**Dependencies:** Phase 2 (same file: `write.md` — Phase 2 removed markers and fixed references; Phase 4 adds Pipeline Steps section)
**Entry:** Phase 3 checkpoint committed
**Exit:** `write.md` has ## Pipeline Steps section with all 15 implementation pipeline stages

### Code Path Coverage

- `write.md` — add ## Pipeline Steps section after the existing content, enumerating all 15 implementation pipeline stages

### Cross-Cutting SCs

SC-3 is the sole SC for this phase.

### Interface Boundaries

The Pipeline Steps section is a reference section in the plan template. It does not change agent execution behavior — it ensures all plans enumerate the full pipeline.

### State Transitions

- Pre-state: `write.md` has no ## Pipeline Steps section
- Post-state: `write.md` has ## Pipeline Steps section with all 15 stages

### Step-by-step

- [ ] 26. **Add ## Pipeline Steps section to write.md (**clean-room**).** Add a ## Pipeline Steps section enumerating all 15 implementation pipeline stages from the `implementation-pipeline/SKILL.md` dispatch routing table:

    ```
    ## Pipeline Steps

    Every plan MUST enumerate all 15 implementation pipeline stages from the `implementation-pipeline/SKILL.md` dispatch routing table. No stage may be omitted. Stages are:

    1. **Pre-work** — `git-workflow --task pre-work`: trunk-tip verification, feature branch creation, submodule sync, checkpoint tagging
    2. **Coherence gate** — `skill({name: "completeness-gate"})`: verify spec-to-plan coherence before RED phase
    3. **Pre-RED baseline** — `skill({name: "test-driven-development"}) --task pre-red-baseline`: verify existing tests pass before any changes
    4. **RED phase** — `skill({name: "test-driven-development"}) --task red`: write enforcement test that FAILS
    5. **GREEN phase** — `skill({name: "test-driven-development"}) --task green`: implement change that makes test PASS
    6. **GREEN doublecheck** — `skill({name: "test-driven-development"}) --task green-doublecheck`: verify test still passes after implementation
    7. **Checkpoint commit** — `git-workflow --task commit`: commit with checkpoint tag
    8. **Verification-before-completion (VbC)** — `skill({name: "verification-before-completion"})`: verify all SCs against evidence
    9. **Audit** — `skill({name: "audit"})`: adversarial audit of deliverables
    10. **Cross-validate** — `skill({name: "audit"}) --task cross-validate`: cross-validate audit findings
    11. **Regression check** — `skill({name: "test-driven-development"}) --task regression`: verify no regressions
    12. **Finishing checklist** — `skill({name: "finishing-a-development-branch"})`: branch finishing gate
    13. **Review prep** — `skill({name: "git-workflow"}) --task review-prep`: PR readiness verification
    14. **PR creation** — `skill({name: "git-workflow"}) --task pr-creation`: create pull request
    15. **Cleanup** — `skill({name: "git-workflow"}) --task cleanup`: post-merge cleanup
    ```

    **→ SC-3**
- [ ] 27. **Checkpoint commit .** `git add .opencode/skills/writing-plans-creation/tasks/write.md && git commit -m "feat: add Pipeline Steps section to write.md plan template"` **→ SC-3**

#### Phase 4 VbC

- [ ] 28. **VbC (**clean-room**).** Verify SC-3: `grep "## Pipeline Steps" .opencode/skills/writing-plans-creation/tasks/write.md` returns a match; section contains at least 15 numbered stages. **→ SC-3**

**Concern transition:** Leaving plan template Pipeline Steps → entering global post-steps.

---

## Global Post-Steps

- [ ] 29. **Collect behavioral evidence (**clean-room**).** Collect behavioral evidence from `{project_root}/tmp/behavioral-evidence-*/` into `{project_root}/tmp/2067/artifacts/`. **→ SC-11**
- [ ] 30. **Audit (**clean-room**).** Dispatch `skill({name: "audit"})` for adversarial audit of all deliverables. **→ SC-11**
- [ ] 31. **Cross-validate (**clean-room**).** Dispatch `skill({name: "audit"}) --task cross-validate` to cross-validate audit findings. **→ SC-11**
- [ ] 32. **Regression check (**clean-room**).** Run `bash .opencode/tests-v2/test-enforcement.sh --changed` to verify no regressions. **→ SC-11**
- [ ] 33. **Finishing checklist (**clean-room**).** Dispatch `skill({name: "finishing-a-development-branch"})` for branch finishing gate. **→ SC-11**
- [ ] 34. **Review prep (**clean-room**).** Dispatch `skill({name: "git-workflow"}) --task review-prep` for PR readiness verification. **→ SC-11**
- [ ] 35. **PR creation (**clean-room**).** Dispatch `skill({name: "git-workflow"}) --task pr-creation` to create pull request. **→ SC-11**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** If any step fails, the agent MUST self-remediate before proceeding. Do not halt on the first failure — diagnose the root cause, fix it, and re-run the step. Only halt if remediation fails after 3 attempts. If a step produces unexpected output, investigate before proceeding. Do not skip failed steps or mark them complete without verification.

## Exit Criteria

- [ ] C1: SC-1 — `000-critical-rules.md` has Tier 1 CRITICAL VIOLATION rule for direct `github_issue_write` for spec content bypassing spec-creation pipeline
- [ ] C2: SC-2 — `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` exists and is executable
- [ ] C3: SC-3 — `write.md` has ## Pipeline Steps section with all 15 implementation pipeline stages
- [ ] C4: SC-4 — All 4 task cards have ## Entry Criteria, ## Procedure, ## Exit Criteria, ## Result Contract sections
- [ ] C5: SC-5 — `clean-room.md` has no `(orchestrator)` marker
- [ ] C6: SC-6 — `write.md` has no `(**sub-agent**)` markers
- [ ] C7: SC-7 — `behavioral-sc-evaluator.md` has no "orchestrator dispatches" language
- [ ] C8: SC-8 — 6 task cards have no inappropriate sub-agent/dispatch references
- [ ] C9: SC-9 — `writing-plans/SKILL.md` Invocation lists 13 entries
- [ ] C10: SC-10 — `spec-creation/SKILL.md` Invocation lists 19 entries
- [ ] C11: SC-11 — All 10 SCs above verified PASS
